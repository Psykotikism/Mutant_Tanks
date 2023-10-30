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

#define MT_HURT_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN
	#if MT_HURT_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities" while compiling "mt_abilities.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Hurt Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank repeatedly hurts survivors.",
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
			strcopy(error, err_max, "\"[MT] Hurt Ability\" only supports Left 4 Dead 1 & 2.");

			return APLRes_SilentFailure;
		}
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_BLOOD "boomer_explode_D"

#define SOUND_ATTACK "player/pz/voice/attack/zombiedog_attack2.wav"
#define SOUND_PAIN1 "player/tank/voice/pain/tank_fire_04.wav"
#define SOUND_PAIN2 "player/tank/voice/pain/tank_fire_08.wav" // Only available in L4D2
#else
	#if MT_HURT_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_HURT_SECTION "hurtability"
#define MT_HURT_SECTION2 "hurt ability"
#define MT_HURT_SECTION3 "hurt_ability"
#define MT_HURT_SECTION4 "hurt"

#define MT_MENU_HURT "Hurt Ability"

enum struct esHurtPlayer
{
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flCloseAreasOnly;
	float g_flHurtChance;
	float g_flHurtDamage;
	float g_flHurtInterval;
	float g_flHurtRange;
	float g_flHurtRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iHurtAbility;
	int g_iHurtCooldown;
	int g_iHurtDuration;
	int g_iHurtEffect;
	int g_iHurtHit;
	int g_iHurtHitMode;
	int g_iHurtMessage;
	int g_iHurtRangeCooldown;
	int g_iHurtSight;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iRangeCooldown;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esHurtPlayer g_esHurtPlayer[MAXPLAYERS + 1];

enum struct esHurtTeammate
{
	float g_flCloseAreasOnly;
	float g_flHurtChance;
	float g_flHurtDamage;
	float g_flHurtInterval;
	float g_flHurtRange;
	float g_flHurtRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iHurtAbility;
	int g_iHurtCooldown;
	int g_iHurtDuration;
	int g_iHurtEffect;
	int g_iHurtHit;
	int g_iHurtHitMode;
	int g_iHurtMessage;
	int g_iHurtRangeCooldown;
	int g_iHurtSight;
	int g_iRequiresHumans;
}

esHurtTeammate g_esHurtTeammate[MAXPLAYERS + 1];

enum struct esHurtAbility
{
	float g_flCloseAreasOnly;
	float g_flHurtChance;
	float g_flHurtDamage;
	float g_flHurtInterval;
	float g_flHurtRange;
	float g_flHurtRangeChance;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iHurtAbility;
	int g_iHurtCooldown;
	int g_iHurtDuration;
	int g_iHurtEffect;
	int g_iHurtHit;
	int g_iHurtHitMode;
	int g_iHurtMessage;
	int g_iHurtRangeCooldown;
	int g_iHurtSight;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esHurtAbility g_esHurtAbility[MT_MAXTYPES + 1];

enum struct esHurtSpecial
{
	float g_flCloseAreasOnly;
	float g_flHurtChance;
	float g_flHurtDamage;
	float g_flHurtInterval;
	float g_flHurtRange;
	float g_flHurtRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iHurtAbility;
	int g_iHurtCooldown;
	int g_iHurtDuration;
	int g_iHurtEffect;
	int g_iHurtHit;
	int g_iHurtHitMode;
	int g_iHurtMessage;
	int g_iHurtRangeCooldown;
	int g_iHurtSight;
	int g_iRequiresHumans;
}

esHurtSpecial g_esHurtSpecial[MT_MAXTYPES + 1];

enum struct esHurtCache
{
	float g_flCloseAreasOnly;
	float g_flHurtChance;
	float g_flHurtDamage;
	float g_flHurtInterval;
	float g_flHurtRange;
	float g_flHurtRangeChance;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanRangeCooldown;
	int g_iHurtAbility;
	int g_iHurtCooldown;
	int g_iHurtDuration;
	int g_iHurtEffect;
	int g_iHurtHit;
	int g_iHurtHitMode;
	int g_iHurtMessage;
	int g_iHurtRangeCooldown;
	int g_iHurtSight;
	int g_iRequiresHumans;
}

esHurtCache g_esHurtCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_hurt", cmdHurtInfo, "View information about the Hurt ability.");

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
void vHurtMapStart()
#else
public void OnMapStart()
#endif
{
	PrecacheSound(SOUND_ATTACK, true);

	switch (g_bSecondGame)
	{
		case true: PrecacheSound(SOUND_PAIN2, true);
		case false: PrecacheSound(SOUND_PAIN1, true);
	}

	vHurtReset();
}

#if defined MT_ABILITIES_MAIN
void vHurtClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnHurtTakeDamage);
	vHurtReset3(client);
}

#if defined MT_ABILITIES_MAIN
void vHurtClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vHurtReset3(client);
}

#if defined MT_ABILITIES_MAIN
void vHurtMapEnd()
#else
public void OnMapEnd()
#endif
{
	vHurtReset();
}

#if !defined MT_ABILITIES_MAIN
Action cmdHurtInfo(int client, int args)
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
		case false: vHurtMenu(client, MT_HURT_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vHurtMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_HURT_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iHurtMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Hurt Ability Information");
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

int iHurtMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esHurtCache[param1].g_iHurtAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esHurtCache[param1].g_iHumanAmmo - g_esHurtPlayer[param1].g_iAmmoCount), g_esHurtCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esHurtCache[param1].g_iHumanAbility == 1) ? g_esHurtCache[param1].g_iHumanCooldown : g_esHurtCache[param1].g_iHurtCooldown));
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "HurtDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esHurtCache[param1].g_iHurtDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esHurtCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityRangeCooldown", ((g_esHurtCache[param1].g_iHumanAbility == 1) ? g_esHurtCache[param1].g_iHumanRangeCooldown : g_esHurtCache[param1].g_iHurtRangeCooldown));
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vHurtMenu(param1, MT_HURT_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pHurt = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "HurtMenu", param1);
			pHurt.SetTitle(sMenuTitle);
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

#if defined MT_ABILITIES_MAIN
void vHurtDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_HURT, MT_MENU_HURT);
}

#if defined MT_ABILITIES_MAIN
void vHurtMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_HURT, false))
	{
		vHurtMenu(client, MT_HURT_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN
void vHurtMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_HURT, false))
	{
		FormatEx(buffer, size, "%T", "HurtMenu2", client);
	}
}

Action OnHurtTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		char sClassname[32];
		if (bIsValidEntity(inflictor))
		{
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esHurtCache[attacker].g_iHurtHitMode == 0 || g_esHurtCache[attacker].g_iHurtHitMode == 1) && bIsSurvivor(victim) && g_esHurtCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esHurtAbility[g_esHurtPlayer[attacker].g_iTankType].g_iAccessFlags, g_esHurtPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esHurtPlayer[attacker].g_iTankType, g_esHurtAbility[g_esHurtPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esHurtPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			bool bCaught = bIsSurvivorCaught(victim);
			if ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHurtHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esHurtCache[attacker].g_flHurtChance, g_esHurtCache[attacker].g_iHurtHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esHurtCache[victim].g_iHurtHitMode == 0 || g_esHurtCache[victim].g_iHurtHitMode == 2) && bIsSurvivor(attacker) && g_esHurtCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esHurtAbility[g_esHurtPlayer[victim].g_iTankType].g_iAccessFlags, g_esHurtPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esHurtPlayer[victim].g_iTankType, g_esHurtAbility[g_esHurtPlayer[victim].g_iTankType].g_iImmunityFlags, g_esHurtPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname[7], "melee"))
			{
				vHurtHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esHurtCache[victim].g_flHurtChance, g_esHurtCache[victim].g_iHurtHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN
void vHurtPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_HURT);
}

#if defined MT_ABILITIES_MAIN
void vHurtAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_HURT_SECTION);
	list2.PushString(MT_HURT_SECTION2);
	list3.PushString(MT_HURT_SECTION3);
	list4.PushString(MT_HURT_SECTION4);
}

#if defined MT_ABILITIES_MAIN
void vHurtCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, const char[] classname)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHurtCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_HURT_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_HURT_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_HURT_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_HURT_SECTION4);
	if (g_esHurtCache[tank].g_iComboAbility == 1 && (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1))
	{
		char sAbilities[320], sSubset[10][32];
		strcopy(sAbilities, sizeof sAbilities, combo);
		ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

		float flChance = 0.0, flDelay = 0.0;
		for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_HURT_SECTION, false) || StrEqual(sSubset[iPos], MT_HURT_SECTION2, false) || StrEqual(sSubset[iPos], MT_HURT_SECTION3, false) || StrEqual(sSubset[iPos], MT_HURT_SECTION4, false))
			{
				flDelay = MT_GetCombinationSetting(tank, 4, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esHurtCache[tank].g_iHurtAbility == 1)
						{
							switch (flDelay)
							{
								case 0.0: vHurtAbility(tank, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerHurtCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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
								if ((g_esHurtCache[tank].g_iHurtHitMode == 0 || g_esHurtCache[tank].g_iHurtHitMode == 1) && (StrEqual(classname[7], "tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vHurtHit(survivor, tank, random, flChance, g_esHurtCache[tank].g_iHurtHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
								}
								else if ((g_esHurtCache[tank].g_iHurtHitMode == 0 || g_esHurtCache[tank].g_iHurtHitMode == 2) && StrEqual(classname[7], "melee"))
								{
									vHurtHit(survivor, tank, random, flChance, g_esHurtCache[tank].g_iHurtHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerHurtCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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
void vHurtConfigsLoad(int mode)
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
				g_esHurtAbility[iIndex].g_iAccessFlags = 0;
				g_esHurtAbility[iIndex].g_iImmunityFlags = 0;
				g_esHurtAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esHurtAbility[iIndex].g_iComboAbility = 0;
				g_esHurtAbility[iIndex].g_iHumanAbility = 0;
				g_esHurtAbility[iIndex].g_iHumanAmmo = 5;
				g_esHurtAbility[iIndex].g_iHumanCooldown = 0;
				g_esHurtAbility[iIndex].g_iHumanRangeCooldown = 0;
				g_esHurtAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esHurtAbility[iIndex].g_iRequiresHumans = 0;
				g_esHurtAbility[iIndex].g_iHurtAbility = 0;
				g_esHurtAbility[iIndex].g_iHurtEffect = 0;
				g_esHurtAbility[iIndex].g_iHurtMessage = 0;
				g_esHurtAbility[iIndex].g_flHurtChance = 33.3;
				g_esHurtAbility[iIndex].g_iHurtCooldown = 0;
				g_esHurtAbility[iIndex].g_flHurtDamage = 5.0;
				g_esHurtAbility[iIndex].g_iHurtDuration = 5;
				g_esHurtAbility[iIndex].g_iHurtHit = 0;
				g_esHurtAbility[iIndex].g_iHurtHitMode = 0;
				g_esHurtAbility[iIndex].g_flHurtInterval = 1.0;
				g_esHurtAbility[iIndex].g_flHurtRange = 150.0;
				g_esHurtAbility[iIndex].g_flHurtRangeChance = 15.0;
				g_esHurtAbility[iIndex].g_iHurtRangeCooldown = 0;
				g_esHurtAbility[iIndex].g_iHurtSight = 0;

				g_esHurtSpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esHurtSpecial[iIndex].g_iComboAbility = -1;
				g_esHurtSpecial[iIndex].g_iHumanAbility = -1;
				g_esHurtSpecial[iIndex].g_iHumanAmmo = -1;
				g_esHurtSpecial[iIndex].g_iHumanCooldown = -1;
				g_esHurtSpecial[iIndex].g_iHumanRangeCooldown = -1;
				g_esHurtSpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esHurtSpecial[iIndex].g_iRequiresHumans = -1;
				g_esHurtSpecial[iIndex].g_iHurtAbility = -1;
				g_esHurtSpecial[iIndex].g_iHurtEffect = -1;
				g_esHurtSpecial[iIndex].g_iHurtMessage = -1;
				g_esHurtSpecial[iIndex].g_flHurtChance = -1.0;
				g_esHurtSpecial[iIndex].g_iHurtCooldown = -1;
				g_esHurtSpecial[iIndex].g_flHurtDamage = -1.0;
				g_esHurtSpecial[iIndex].g_iHurtDuration = -1;
				g_esHurtSpecial[iIndex].g_iHurtHit = -1;
				g_esHurtSpecial[iIndex].g_iHurtHitMode = -1;
				g_esHurtSpecial[iIndex].g_flHurtInterval = -1.0;
				g_esHurtSpecial[iIndex].g_flHurtRange = -1.0;
				g_esHurtSpecial[iIndex].g_flHurtRangeChance = -1.0;
				g_esHurtSpecial[iIndex].g_iHurtRangeCooldown = -1;
				g_esHurtSpecial[iIndex].g_iHurtSight = -1;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esHurtPlayer[iPlayer].g_iAccessFlags = -1;
				g_esHurtPlayer[iPlayer].g_iImmunityFlags = -1;
				g_esHurtPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esHurtPlayer[iPlayer].g_iComboAbility = -1;
				g_esHurtPlayer[iPlayer].g_iHumanAbility = -1;
				g_esHurtPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esHurtPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esHurtPlayer[iPlayer].g_iHumanRangeCooldown = -1;
				g_esHurtPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esHurtPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esHurtPlayer[iPlayer].g_iHurtAbility = -1;
				g_esHurtPlayer[iPlayer].g_iHurtEffect = -1;
				g_esHurtPlayer[iPlayer].g_iHurtMessage = -1;
				g_esHurtPlayer[iPlayer].g_flHurtChance = -1.0;
				g_esHurtPlayer[iPlayer].g_iHurtCooldown = -1;
				g_esHurtPlayer[iPlayer].g_flHurtDamage = -1.0;
				g_esHurtPlayer[iPlayer].g_iHurtDuration = -1;
				g_esHurtPlayer[iPlayer].g_iHurtHit = -1;
				g_esHurtPlayer[iPlayer].g_iHurtHitMode = -1;
				g_esHurtPlayer[iPlayer].g_flHurtInterval = -1.0;
				g_esHurtPlayer[iPlayer].g_flHurtRange = -1.0;
				g_esHurtPlayer[iPlayer].g_flHurtRangeChance = -1.0;
				g_esHurtPlayer[iPlayer].g_iHurtRangeCooldown = -1;
				g_esHurtPlayer[iPlayer].g_iHurtSight = -1;

				g_esHurtTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esHurtTeammate[iPlayer].g_iComboAbility = -1;
				g_esHurtTeammate[iPlayer].g_iHumanAbility = -1;
				g_esHurtTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esHurtTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esHurtTeammate[iPlayer].g_iHumanRangeCooldown = -1;
				g_esHurtTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esHurtTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esHurtTeammate[iPlayer].g_iHurtAbility = -1;
				g_esHurtTeammate[iPlayer].g_iHurtEffect = -1;
				g_esHurtTeammate[iPlayer].g_iHurtMessage = -1;
				g_esHurtTeammate[iPlayer].g_flHurtChance = -1.0;
				g_esHurtTeammate[iPlayer].g_iHurtCooldown = -1;
				g_esHurtTeammate[iPlayer].g_flHurtDamage = -1.0;
				g_esHurtTeammate[iPlayer].g_iHurtDuration = -1;
				g_esHurtTeammate[iPlayer].g_iHurtHit = -1;
				g_esHurtTeammate[iPlayer].g_iHurtHitMode = -1;
				g_esHurtTeammate[iPlayer].g_flHurtInterval = -1.0;
				g_esHurtTeammate[iPlayer].g_flHurtRange = -1.0;
				g_esHurtTeammate[iPlayer].g_flHurtRangeChance = -1.0;
				g_esHurtTeammate[iPlayer].g_iHurtRangeCooldown = -1;
				g_esHurtTeammate[iPlayer].g_iHurtSight = -1;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHurtConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esHurtTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esHurtTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esHurtTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esHurtTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esHurtTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esHurtTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esHurtTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esHurtTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esHurtTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esHurtTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esHurtTeammate[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esHurtTeammate[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esHurtTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esHurtTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esHurtTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esHurtTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esHurtTeammate[admin].g_iHurtAbility = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esHurtTeammate[admin].g_iHurtAbility, value, -1, 1);
			g_esHurtTeammate[admin].g_iHurtEffect = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esHurtTeammate[admin].g_iHurtEffect, value, -1, 7);
			g_esHurtTeammate[admin].g_iHurtMessage = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esHurtTeammate[admin].g_iHurtMessage, value, -1, 3);
			g_esHurtTeammate[admin].g_iHurtSight = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esHurtTeammate[admin].g_iHurtSight, value, -1, 2);
			g_esHurtTeammate[admin].g_flHurtChance = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtChance", "Hurt Chance", "Hurt_Chance", "chance", g_esHurtTeammate[admin].g_flHurtChance, value, -1.0, 100.0);
			g_esHurtTeammate[admin].g_iHurtCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtCooldown", "Hurt Cooldown", "Hurt_Cooldown", "cooldown", g_esHurtTeammate[admin].g_iHurtCooldown, value, -1, 99999);
			g_esHurtTeammate[admin].g_flHurtDamage = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtDamage", "Hurt Damage", "Hurt_Damage", "damage", g_esHurtTeammate[admin].g_flHurtDamage, value, -1.0, 99999.0);
			g_esHurtTeammate[admin].g_iHurtDuration = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtDuration", "Hurt Duration", "Hurt_Duration", "duration", g_esHurtTeammate[admin].g_iHurtDuration, value, -1, 99999);
			g_esHurtTeammate[admin].g_iHurtHit = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtHit", "Hurt Hit", "Hurt_Hit", "hit", g_esHurtTeammate[admin].g_iHurtHit, value, -1, 1);
			g_esHurtTeammate[admin].g_iHurtHitMode = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtHitMode", "Hurt Hit Mode", "Hurt_Hit_Mode", "hitmode", g_esHurtTeammate[admin].g_iHurtHitMode, value, -1, 2);
			g_esHurtTeammate[admin].g_flHurtInterval = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtInterval", "Hurt Interval", "Hurt_Interval", "interval", g_esHurtTeammate[admin].g_flHurtInterval, value, -1.0, 99999.0);
			g_esHurtTeammate[admin].g_flHurtRange = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtRange", "Hurt Range", "Hurt_Range", "range", g_esHurtTeammate[admin].g_flHurtRange, value, -1.0, 99999.0);
			g_esHurtTeammate[admin].g_flHurtRangeChance = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtRangeChance", "Hurt Range Chance", "Hurt_Range_Chance", "rangechance", g_esHurtTeammate[admin].g_flHurtRangeChance, value, -1.0, 100.0);
			g_esHurtTeammate[admin].g_iHurtRangeCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtRangeCooldown", "Hurt Range Cooldown", "Hurt_Range_Cooldown", "rangecooldown", g_esHurtTeammate[admin].g_iHurtRangeCooldown, value, -1, 99999);
		}
		else
		{
			g_esHurtPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esHurtPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esHurtPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esHurtPlayer[admin].g_iComboAbility, value, -1, 1);
			g_esHurtPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esHurtPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esHurtPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esHurtPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esHurtPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esHurtPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esHurtPlayer[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esHurtPlayer[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esHurtPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esHurtPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esHurtPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esHurtPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esHurtPlayer[admin].g_iHurtAbility = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esHurtPlayer[admin].g_iHurtAbility, value, -1, 1);
			g_esHurtPlayer[admin].g_iHurtEffect = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esHurtPlayer[admin].g_iHurtEffect, value, -1, 7);
			g_esHurtPlayer[admin].g_iHurtMessage = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esHurtPlayer[admin].g_iHurtMessage, value, -1, 3);
			g_esHurtPlayer[admin].g_iHurtSight = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esHurtPlayer[admin].g_iHurtSight, value, -1, 2);
			g_esHurtPlayer[admin].g_flHurtChance = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtChance", "Hurt Chance", "Hurt_Chance", "chance", g_esHurtPlayer[admin].g_flHurtChance, value, -1.0, 100.0);
			g_esHurtPlayer[admin].g_iHurtCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtCooldown", "Hurt Cooldown", "Hurt_Cooldown", "cooldown", g_esHurtPlayer[admin].g_iHurtCooldown, value, -1, 99999);
			g_esHurtPlayer[admin].g_flHurtDamage = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtDamage", "Hurt Damage", "Hurt_Damage", "damage", g_esHurtPlayer[admin].g_flHurtDamage, value, -1.0, 99999.0);
			g_esHurtPlayer[admin].g_iHurtDuration = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtDuration", "Hurt Duration", "Hurt_Duration", "duration", g_esHurtPlayer[admin].g_iHurtDuration, value, -1, 99999);
			g_esHurtPlayer[admin].g_iHurtHit = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtHit", "Hurt Hit", "Hurt_Hit", "hit", g_esHurtPlayer[admin].g_iHurtHit, value, -1, 1);
			g_esHurtPlayer[admin].g_iHurtHitMode = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtHitMode", "Hurt Hit Mode", "Hurt_Hit_Mode", "hitmode", g_esHurtPlayer[admin].g_iHurtHitMode, value, -1, 2);
			g_esHurtPlayer[admin].g_flHurtInterval = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtInterval", "Hurt Interval", "Hurt_Interval", "interval", g_esHurtPlayer[admin].g_flHurtInterval, value, -1.0, 99999.0);
			g_esHurtPlayer[admin].g_flHurtRange = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtRange", "Hurt Range", "Hurt_Range", "range", g_esHurtPlayer[admin].g_flHurtRange, value, -1.0, 99999.0);
			g_esHurtPlayer[admin].g_flHurtRangeChance = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtRangeChance", "Hurt Range Chance", "Hurt_Range_Chance", "rangechance", g_esHurtPlayer[admin].g_flHurtRangeChance, value, -1.0, 100.0);
			g_esHurtPlayer[admin].g_iHurtRangeCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtRangeCooldown", "Hurt Range Cooldown", "Hurt_Range_Cooldown", "rangecooldown", g_esHurtPlayer[admin].g_iHurtRangeCooldown, value, -1, 99999);
			g_esHurtPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esHurtPlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esHurtSpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esHurtSpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esHurtSpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esHurtSpecial[type].g_iComboAbility, value, -1, 1);
			g_esHurtSpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esHurtSpecial[type].g_iHumanAbility, value, -1, 2);
			g_esHurtSpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esHurtSpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esHurtSpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esHurtSpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esHurtSpecial[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esHurtSpecial[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esHurtSpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esHurtSpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esHurtSpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esHurtSpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esHurtSpecial[type].g_iHurtAbility = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esHurtSpecial[type].g_iHurtAbility, value, -1, 1);
			g_esHurtSpecial[type].g_iHurtEffect = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esHurtSpecial[type].g_iHurtEffect, value, -1, 7);
			g_esHurtSpecial[type].g_iHurtMessage = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esHurtSpecial[type].g_iHurtMessage, value, -1, 3);
			g_esHurtSpecial[type].g_iHurtSight = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esHurtSpecial[type].g_iHurtSight, value, -1, 2);
			g_esHurtSpecial[type].g_flHurtChance = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtChance", "Hurt Chance", "Hurt_Chance", "chance", g_esHurtSpecial[type].g_flHurtChance, value, -1.0, 100.0);
			g_esHurtSpecial[type].g_iHurtCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtCooldown", "Hurt Cooldown", "Hurt_Cooldown", "cooldown", g_esHurtSpecial[type].g_iHurtCooldown, value, -1, 99999);
			g_esHurtSpecial[type].g_flHurtDamage = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtDamage", "Hurt Damage", "Hurt_Damage", "damage", g_esHurtSpecial[type].g_flHurtDamage, value, -1.0, 99999.0);
			g_esHurtSpecial[type].g_iHurtDuration = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtDuration", "Hurt Duration", "Hurt_Duration", "duration", g_esHurtSpecial[type].g_iHurtDuration, value, -1, 99999);
			g_esHurtSpecial[type].g_iHurtHit = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtHit", "Hurt Hit", "Hurt_Hit", "hit", g_esHurtSpecial[type].g_iHurtHit, value, -1, 1);
			g_esHurtSpecial[type].g_iHurtHitMode = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtHitMode", "Hurt Hit Mode", "Hurt_Hit_Mode", "hitmode", g_esHurtSpecial[type].g_iHurtHitMode, value, -1, 2);
			g_esHurtSpecial[type].g_flHurtInterval = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtInterval", "Hurt Interval", "Hurt_Interval", "interval", g_esHurtSpecial[type].g_flHurtInterval, value, -1.0, 99999.0);
			g_esHurtSpecial[type].g_flHurtRange = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtRange", "Hurt Range", "Hurt_Range", "range", g_esHurtSpecial[type].g_flHurtRange, value, -1.0, 99999.0);
			g_esHurtSpecial[type].g_flHurtRangeChance = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtRangeChance", "Hurt Range Chance", "Hurt_Range_Chance", "rangechance", g_esHurtSpecial[type].g_flHurtRangeChance, value, -1.0, 100.0);
			g_esHurtSpecial[type].g_iHurtRangeCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtRangeCooldown", "Hurt Range Cooldown", "Hurt_Range_Cooldown", "rangecooldown", g_esHurtSpecial[type].g_iHurtRangeCooldown, value, -1, 99999);
		}
		else
		{
			g_esHurtAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esHurtAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esHurtAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esHurtAbility[type].g_iComboAbility, value, -1, 1);
			g_esHurtAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esHurtAbility[type].g_iHumanAbility, value, -1, 2);
			g_esHurtAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esHurtAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esHurtAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esHurtAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esHurtAbility[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esHurtAbility[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esHurtAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esHurtAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esHurtAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esHurtAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esHurtAbility[type].g_iHurtAbility = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esHurtAbility[type].g_iHurtAbility, value, -1, 1);
			g_esHurtAbility[type].g_iHurtEffect = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esHurtAbility[type].g_iHurtEffect, value, -1, 7);
			g_esHurtAbility[type].g_iHurtMessage = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esHurtAbility[type].g_iHurtMessage, value, -1, 3);
			g_esHurtAbility[type].g_iHurtSight = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esHurtAbility[type].g_iHurtSight, value, -1, 2);
			g_esHurtAbility[type].g_flHurtChance = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtChance", "Hurt Chance", "Hurt_Chance", "chance", g_esHurtAbility[type].g_flHurtChance, value, -1.0, 100.0);
			g_esHurtAbility[type].g_iHurtCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtCooldown", "Hurt Cooldown", "Hurt_Cooldown", "cooldown", g_esHurtAbility[type].g_iHurtCooldown, value, -1, 99999);
			g_esHurtAbility[type].g_flHurtDamage = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtDamage", "Hurt Damage", "Hurt_Damage", "damage", g_esHurtAbility[type].g_flHurtDamage, value, -1.0, 99999.0);
			g_esHurtAbility[type].g_iHurtDuration = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtDuration", "Hurt Duration", "Hurt_Duration", "duration", g_esHurtAbility[type].g_iHurtDuration, value, -1, 99999);
			g_esHurtAbility[type].g_iHurtHit = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtHit", "Hurt Hit", "Hurt_Hit", "hit", g_esHurtAbility[type].g_iHurtHit, value, -1, 1);
			g_esHurtAbility[type].g_iHurtHitMode = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtHitMode", "Hurt Hit Mode", "Hurt_Hit_Mode", "hitmode", g_esHurtAbility[type].g_iHurtHitMode, value, -1, 2);
			g_esHurtAbility[type].g_flHurtInterval = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtInterval", "Hurt Interval", "Hurt_Interval", "interval", g_esHurtAbility[type].g_flHurtInterval, value, -1.0, 99999.0);
			g_esHurtAbility[type].g_flHurtRange = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtRange", "Hurt Range", "Hurt_Range", "range", g_esHurtAbility[type].g_flHurtRange, value, -1.0, 99999.0);
			g_esHurtAbility[type].g_flHurtRangeChance = flGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtRangeChance", "Hurt Range Chance", "Hurt_Range_Chance", "rangechance", g_esHurtAbility[type].g_flHurtRangeChance, value, -1.0, 100.0);
			g_esHurtAbility[type].g_iHurtRangeCooldown = iGetKeyValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "HurtRangeCooldown", "Hurt Range Cooldown", "Hurt_Range_Cooldown", "rangecooldown", g_esHurtAbility[type].g_iHurtRangeCooldown, value, -1, 99999);
			g_esHurtAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esHurtAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_HURT_SECTION, MT_HURT_SECTION2, MT_HURT_SECTION3, MT_HURT_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHurtSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esHurtPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esHurtPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esHurtPlayer[tank].g_iTankTypeRecorded;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esHurtCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_flCloseAreasOnly, g_esHurtPlayer[tank].g_flCloseAreasOnly, g_esHurtSpecial[iType].g_flCloseAreasOnly, g_esHurtAbility[iType].g_flCloseAreasOnly, 1);
		g_esHurtCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_iComboAbility, g_esHurtPlayer[tank].g_iComboAbility, g_esHurtSpecial[iType].g_iComboAbility, g_esHurtAbility[iType].g_iComboAbility, 1);
		g_esHurtCache[tank].g_flHurtChance = flGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_flHurtChance, g_esHurtPlayer[tank].g_flHurtChance, g_esHurtSpecial[iType].g_flHurtChance, g_esHurtAbility[iType].g_flHurtChance, 1);
		g_esHurtCache[tank].g_flHurtDamage = flGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_flHurtDamage, g_esHurtPlayer[tank].g_flHurtDamage, g_esHurtSpecial[iType].g_flHurtDamage, g_esHurtAbility[iType].g_flHurtDamage, 1);
		g_esHurtCache[tank].g_flHurtInterval = flGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_flHurtInterval, g_esHurtPlayer[tank].g_flHurtInterval, g_esHurtSpecial[iType].g_flHurtInterval, g_esHurtAbility[iType].g_flHurtInterval, 1);
		g_esHurtCache[tank].g_flHurtRange = flGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_flHurtRange, g_esHurtPlayer[tank].g_flHurtRange, g_esHurtSpecial[iType].g_flHurtRange, g_esHurtAbility[iType].g_flHurtRange, 1);
		g_esHurtCache[tank].g_flHurtRangeChance = flGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_flHurtRangeChance, g_esHurtPlayer[tank].g_flHurtRangeChance, g_esHurtSpecial[iType].g_flHurtRangeChance, g_esHurtAbility[iType].g_flHurtRangeChance, 1);
		g_esHurtCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_iHumanAbility, g_esHurtPlayer[tank].g_iHumanAbility, g_esHurtSpecial[iType].g_iHumanAbility, g_esHurtAbility[iType].g_iHumanAbility, 1);
		g_esHurtCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_iHumanAmmo, g_esHurtPlayer[tank].g_iHumanAmmo, g_esHurtSpecial[iType].g_iHumanAmmo, g_esHurtAbility[iType].g_iHumanAmmo, 1);
		g_esHurtCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_iHumanCooldown, g_esHurtPlayer[tank].g_iHumanCooldown, g_esHurtSpecial[iType].g_iHumanCooldown, g_esHurtAbility[iType].g_iHumanCooldown, 1);
		g_esHurtCache[tank].g_iHumanRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_iHumanRangeCooldown, g_esHurtPlayer[tank].g_iHumanRangeCooldown, g_esHurtSpecial[iType].g_iHumanRangeCooldown, g_esHurtAbility[iType].g_iHumanRangeCooldown, 1);
		g_esHurtCache[tank].g_iHurtAbility = iGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_iHurtAbility, g_esHurtPlayer[tank].g_iHurtAbility, g_esHurtSpecial[iType].g_iHurtAbility, g_esHurtAbility[iType].g_iHurtAbility, 1);
		g_esHurtCache[tank].g_iHurtCooldown = iGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_iHurtCooldown, g_esHurtPlayer[tank].g_iHurtCooldown, g_esHurtSpecial[iType].g_iHurtCooldown, g_esHurtAbility[iType].g_iHurtCooldown, 1);
		g_esHurtCache[tank].g_iHurtDuration = iGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_iHurtDuration, g_esHurtPlayer[tank].g_iHurtDuration, g_esHurtSpecial[iType].g_iHurtDuration, g_esHurtAbility[iType].g_iHurtDuration, 1);
		g_esHurtCache[tank].g_iHurtEffect = iGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_iHurtEffect, g_esHurtPlayer[tank].g_iHurtEffect, g_esHurtSpecial[iType].g_iHurtEffect, g_esHurtAbility[iType].g_iHurtEffect, 1);
		g_esHurtCache[tank].g_iHurtHit = iGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_iHurtHit, g_esHurtPlayer[tank].g_iHurtHit, g_esHurtSpecial[iType].g_iHurtHit, g_esHurtAbility[iType].g_iHurtHit, 1);
		g_esHurtCache[tank].g_iHurtHitMode = iGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_iHurtHitMode, g_esHurtPlayer[tank].g_iHurtHitMode, g_esHurtSpecial[iType].g_iHurtHitMode, g_esHurtAbility[iType].g_iHurtHitMode, 1);
		g_esHurtCache[tank].g_iHurtMessage = iGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_iHurtMessage, g_esHurtPlayer[tank].g_iHurtMessage, g_esHurtSpecial[iType].g_iHurtMessage, g_esHurtAbility[iType].g_iHurtMessage, 1);
		g_esHurtCache[tank].g_iHurtRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_iHurtRangeCooldown, g_esHurtPlayer[tank].g_iHurtRangeCooldown, g_esHurtSpecial[iType].g_iHurtRangeCooldown, g_esHurtAbility[iType].g_iHurtRangeCooldown, 1);
		g_esHurtCache[tank].g_iHurtSight = iGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_iHurtSight, g_esHurtPlayer[tank].g_iHurtSight, g_esHurtSpecial[iType].g_iHurtSight, g_esHurtAbility[iType].g_iHurtSight, 1);
		g_esHurtCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_flOpenAreasOnly, g_esHurtPlayer[tank].g_flOpenAreasOnly, g_esHurtSpecial[iType].g_flOpenAreasOnly, g_esHurtAbility[iType].g_flOpenAreasOnly, 1);
		g_esHurtCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esHurtTeammate[tank].g_iRequiresHumans, g_esHurtPlayer[tank].g_iRequiresHumans, g_esHurtSpecial[iType].g_iRequiresHumans, g_esHurtAbility[iType].g_iRequiresHumans, 1);
	}
	else
	{
		g_esHurtCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_flCloseAreasOnly, g_esHurtAbility[iType].g_flCloseAreasOnly, 1);
		g_esHurtCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_iComboAbility, g_esHurtAbility[iType].g_iComboAbility, 1);
		g_esHurtCache[tank].g_flHurtChance = flGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_flHurtChance, g_esHurtAbility[iType].g_flHurtChance, 1);
		g_esHurtCache[tank].g_flHurtDamage = flGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_flHurtDamage, g_esHurtAbility[iType].g_flHurtDamage, 1);
		g_esHurtCache[tank].g_flHurtInterval = flGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_flHurtInterval, g_esHurtAbility[iType].g_flHurtInterval, 1);
		g_esHurtCache[tank].g_flHurtRange = flGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_flHurtRange, g_esHurtAbility[iType].g_flHurtRange, 1);
		g_esHurtCache[tank].g_flHurtRangeChance = flGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_flHurtRangeChance, g_esHurtAbility[iType].g_flHurtRangeChance, 1);
		g_esHurtCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_iHumanAbility, g_esHurtAbility[iType].g_iHumanAbility, 1);
		g_esHurtCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_iHumanAmmo, g_esHurtAbility[iType].g_iHumanAmmo, 1);
		g_esHurtCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_iHumanCooldown, g_esHurtAbility[iType].g_iHumanCooldown, 1);
		g_esHurtCache[tank].g_iHumanRangeCooldown = iGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_iHumanRangeCooldown, g_esHurtAbility[iType].g_iHumanRangeCooldown, 1);
		g_esHurtCache[tank].g_iHurtAbility = iGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_iHurtAbility, g_esHurtAbility[iType].g_iHurtAbility, 1);
		g_esHurtCache[tank].g_iHurtCooldown = iGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_iHurtCooldown, g_esHurtAbility[iType].g_iHurtCooldown, 1);
		g_esHurtCache[tank].g_iHurtDuration = iGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_iHurtDuration, g_esHurtAbility[iType].g_iHurtDuration, 1);
		g_esHurtCache[tank].g_iHurtEffect = iGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_iHurtEffect, g_esHurtAbility[iType].g_iHurtEffect, 1);
		g_esHurtCache[tank].g_iHurtHit = iGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_iHurtHit, g_esHurtAbility[iType].g_iHurtHit, 1);
		g_esHurtCache[tank].g_iHurtHitMode = iGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_iHurtHitMode, g_esHurtAbility[iType].g_iHurtHitMode, 1);
		g_esHurtCache[tank].g_iHurtMessage = iGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_iHurtMessage, g_esHurtAbility[iType].g_iHurtMessage, 1);
		g_esHurtCache[tank].g_iHurtRangeCooldown = iGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_iHurtRangeCooldown, g_esHurtAbility[iType].g_iHurtRangeCooldown, 1);
		g_esHurtCache[tank].g_iHurtSight = iGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_iHurtSight, g_esHurtAbility[iType].g_iHurtSight, 1);
		g_esHurtCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_flOpenAreasOnly, g_esHurtAbility[iType].g_flOpenAreasOnly, 1);
		g_esHurtCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esHurtPlayer[tank].g_iRequiresHumans, g_esHurtAbility[iType].g_iRequiresHumans, 1);
	}
}

#if defined MT_ABILITIES_MAIN
void vHurtCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vHurtCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveHurt(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN
void vHurtEventFired(Event event, const char[] name)
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
			vHurtCopyStats2(iBot, iTank);
			vRemoveHurt(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vHurtReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vHurtCopyStats2(iTank, iBot);
			vRemoveHurt(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveHurt(iTank);
		}
	}
	else if (StrEqual(name, "player_now_it"))
	{
		bool bExploded = event.GetBool("exploded");
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iBoomerId = event.GetInt("attacker"), iBoomer = GetClientOfUserId(iBoomerId);
		if (bIsBoomer(iBoomer) && bIsSurvivor(iSurvivor) && !bExploded)
		{
			vHurtHit(iSurvivor, iBoomer, GetRandomFloat(0.1, 100.0), g_esHurtCache[iBoomer].g_flHurtChance, g_esHurtCache[iBoomer].g_iHurtHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHurtAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esHurtAbility[g_esHurtPlayer[tank].g_iTankType].g_iAccessFlags, g_esHurtPlayer[tank].g_iAccessFlags)) || g_esHurtCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esHurtCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esHurtCache[tank].g_iHurtAbility == 1 && g_esHurtCache[tank].g_iComboAbility == 0)
	{
		vHurtAbility(tank, GetRandomFloat(0.1, 100.0));
	}
}

#if defined MT_ABILITIES_MAIN
void vHurtButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esHurtCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esHurtCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esHurtPlayer[tank].g_iTankType, tank) || (g_esHurtCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esHurtCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esHurtAbility[g_esHurtPlayer[tank].g_iTankType].g_iAccessFlags, g_esHurtPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if ((button & MT_SUB_KEY) && g_esHurtCache[tank].g_iHurtAbility == 1 && g_esHurtCache[tank].g_iHumanAbility == 1)
		{
			int iTime = GetTime();

			switch (g_esHurtPlayer[tank].g_iRangeCooldown == -1 || g_esHurtPlayer[tank].g_iRangeCooldown <= iTime)
			{
				case true: vHurtAbility(tank, GetRandomFloat(0.1, 100.0));
				case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "HurtHuman3", (g_esHurtPlayer[tank].g_iRangeCooldown - iTime));
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vHurtChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRemoveHurt(tank);
}

void vHurtAbility(int tank, float random, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esHurtCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esHurtCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esHurtPlayer[tank].g_iTankType, tank) || (g_esHurtCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esHurtCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esHurtAbility[g_esHurtPlayer[tank].g_iTankType].g_iAccessFlags, g_esHurtPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esHurtPlayer[tank].g_iAmmoCount < g_esHurtCache[tank].g_iHumanAmmo && g_esHurtCache[tank].g_iHumanAmmo > 0))
	{
		g_esHurtPlayer[tank].g_bFailed = false;
		g_esHurtPlayer[tank].g_bNoAmmo = false;

		float flTankPos[3], flSurvivorPos[3];
		GetClientAbsOrigin(tank, flTankPos);
		float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esHurtCache[tank].g_flHurtRange,
			flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 10, pos) : g_esHurtCache[tank].g_flHurtRangeChance;
		int iSurvivorCount = 0;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esHurtPlayer[tank].g_iTankType, g_esHurtAbility[g_esHurtPlayer[tank].g_iTankType].g_iImmunityFlags, g_esHurtPlayer[iSurvivor].g_iImmunityFlags))
			{
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esHurtCache[tank].g_iHurtSight, .range = flRange))
				{
					vHurtHit(iSurvivor, tank, random, flChance, g_esHurtCache[tank].g_iHurtAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE, pos);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHurtCache[tank].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "HurtHuman4");
			}
		}
	}
	else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHurtCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "HurtAmmo");
	}
}

void vHurtHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esHurtCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esHurtCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esHurtPlayer[tank].g_iTankType, tank) || (g_esHurtCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esHurtCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esHurtAbility[g_esHurtPlayer[tank].g_iTankType].g_iAccessFlags, g_esHurtPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esHurtPlayer[tank].g_iTankType, g_esHurtAbility[g_esHurtPlayer[tank].g_iTankType].g_iImmunityFlags, g_esHurtPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	int iTime = GetTime();
	if (((flags & MT_ATTACK_RANGE) && g_esHurtPlayer[tank].g_iRangeCooldown != -1 && g_esHurtPlayer[tank].g_iRangeCooldown >= iTime) || (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && g_esHurtPlayer[tank].g_iCooldown != -1 && g_esHurtPlayer[tank].g_iCooldown >= iTime))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE) || (g_esHurtPlayer[tank].g_iAmmoCount < g_esHurtCache[tank].g_iHumanAmmo && g_esHurtCache[tank].g_iHumanAmmo > 0))
		{
			if (random <= chance && !g_esHurtPlayer[survivor].g_bAffected)
			{
				g_esHurtPlayer[survivor].g_bAffected = true;
				g_esHurtPlayer[survivor].g_iOwner = tank;

				int iCooldown = -1;
				if ((flags & MT_ATTACK_RANGE) && (g_esHurtPlayer[tank].g_iRangeCooldown == -1 || g_esHurtPlayer[tank].g_iRangeCooldown <= iTime))
				{
					if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHurtCache[tank].g_iHumanAbility == 1)
					{
						g_esHurtPlayer[tank].g_iAmmoCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HurtHuman", g_esHurtPlayer[tank].g_iAmmoCount, g_esHurtCache[tank].g_iHumanAmmo);
					}

					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 11, pos)) : g_esHurtCache[tank].g_iHurtRangeCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHurtCache[tank].g_iHumanAbility == 1 && g_esHurtPlayer[tank].g_iAmmoCount < g_esHurtCache[tank].g_iHumanAmmo && g_esHurtCache[tank].g_iHumanAmmo > 0) ? g_esHurtCache[tank].g_iHumanRangeCooldown : iCooldown;
					g_esHurtPlayer[tank].g_iRangeCooldown = (iTime + iCooldown);
					if (g_esHurtPlayer[tank].g_iRangeCooldown != -1 && g_esHurtPlayer[tank].g_iRangeCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HurtHuman5", (g_esHurtPlayer[tank].g_iRangeCooldown - iTime));
					}
				}
				else if (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && (g_esHurtPlayer[tank].g_iCooldown == -1 || g_esHurtPlayer[tank].g_iCooldown <= iTime))
				{
					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, pos)) : g_esHurtCache[tank].g_iHurtCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHurtCache[tank].g_iHumanAbility == 1) ? g_esHurtCache[tank].g_iHumanCooldown : iCooldown;
					g_esHurtPlayer[tank].g_iCooldown = (iTime + iCooldown);
					if (g_esHurtPlayer[tank].g_iCooldown != -1 && g_esHurtPlayer[tank].g_iCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HurtHuman5", (g_esHurtPlayer[tank].g_iCooldown - iTime));
					}
				}

				float flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 6, pos) : g_esHurtCache[tank].g_flHurtInterval;
				if (flInterval > 0.0)
				{
					DataPack dpHurt;
					CreateDataTimer(flInterval, tTimerHurt, dpHurt, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					dpHurt.WriteCell(GetClientUserId(survivor));
					dpHurt.WriteCell(GetClientUserId(tank));
					dpHurt.WriteCell(g_esHurtPlayer[tank].g_iTankType);
					dpHurt.WriteCell(messages);
					dpHurt.WriteCell(enabled);
					dpHurt.WriteCell(pos);
					dpHurt.WriteCell(iTime);
				}

				vScreenEffect(survivor, tank, g_esHurtCache[tank].g_iHurtEffect, flags);

				switch (g_bSecondGame)
				{
					case true: EmitSoundToAll(SOUND_PAIN2, survivor);
					case false: EmitSoundToAll(SOUND_PAIN1, survivor);
				}

				if (g_esHurtCache[tank].g_iHurtMessage & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Hurt", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Hurt", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esHurtPlayer[tank].g_iRangeCooldown == -1 || g_esHurtPlayer[tank].g_iRangeCooldown <= iTime))
			{
				if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHurtCache[tank].g_iHumanAbility == 1 && !g_esHurtPlayer[tank].g_bFailed)
				{
					g_esHurtPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HurtHuman2");
				}
			}
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esHurtCache[tank].g_iHumanAbility == 1 && !g_esHurtPlayer[tank].g_bNoAmmo)
		{
			g_esHurtPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "HurtAmmo");
		}
	}
}

void vHurtCopyStats2(int oldTank, int newTank)
{
	g_esHurtPlayer[newTank].g_iAmmoCount = g_esHurtPlayer[oldTank].g_iAmmoCount;
	g_esHurtPlayer[newTank].g_iCooldown = g_esHurtPlayer[oldTank].g_iCooldown;
	g_esHurtPlayer[newTank].g_iRangeCooldown = g_esHurtPlayer[oldTank].g_iRangeCooldown;
}

void vRemoveHurt(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esHurtPlayer[iSurvivor].g_bAffected && g_esHurtPlayer[iSurvivor].g_iOwner == tank)
		{
			g_esHurtPlayer[iSurvivor].g_bAffected = false;
			g_esHurtPlayer[iSurvivor].g_iOwner = -1;
		}
	}

	vHurtReset3(tank);
}

void vHurtReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vHurtReset3(iPlayer);

			g_esHurtPlayer[iPlayer].g_iOwner = -1;
		}
	}
}

void vHurtReset2(int survivor, int tank, int messages)
{
	g_esHurtPlayer[survivor].g_bAffected = false;
	g_esHurtPlayer[survivor].g_iOwner = -1;

	if (g_esHurtCache[tank].g_iHurtMessage & messages)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Hurt2", survivor);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Hurt2", LANG_SERVER, survivor);
	}
}

void vHurtReset3(int tank)
{
	g_esHurtPlayer[tank].g_bAffected = false;
	g_esHurtPlayer[tank].g_bFailed = false;
	g_esHurtPlayer[tank].g_bNoAmmo = false;
	g_esHurtPlayer[tank].g_iAmmoCount = 0;
	g_esHurtPlayer[tank].g_iCooldown = -1;
	g_esHurtPlayer[tank].g_iRangeCooldown = -1;
}

void tTimerHurtCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esHurtAbility[g_esHurtPlayer[iTank].g_iTankType].g_iAccessFlags, g_esHurtPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esHurtPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esHurtCache[iTank].g_iHurtAbility == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vHurtAbility(iTank, flRandom, iPos);
}

void tTimerHurtCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || g_esHurtPlayer[iSurvivor].g_bAffected)
	{
		return;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esHurtAbility[g_esHurtPlayer[iTank].g_iTankType].g_iAccessFlags, g_esHurtPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esHurtPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esHurtCache[iTank].g_iHurtHit == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	int iPos = pack.ReadCell();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof sClassname);
	if ((g_esHurtCache[iTank].g_iHurtHitMode == 0 || g_esHurtCache[iTank].g_iHurtHitMode == 1) && (bIsSpecialInfected(iTank) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vHurtHit(iSurvivor, iTank, flRandom, flChance, g_esHurtCache[iTank].g_iHurtHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
	}
	else if ((g_esHurtCache[iTank].g_iHurtHitMode == 0 || g_esHurtCache[iTank].g_iHurtHitMode == 2) && StrEqual(sClassname[7], "melee"))
	{
		vHurtHit(iSurvivor, iTank, flRandom, flChance, g_esHurtCache[iTank].g_iHurtHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
	}
}

Action tTimerHurt(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_esHurtPlayer[iSurvivor].g_bAffected = false;
		g_esHurtPlayer[iSurvivor].g_iOwner = -1;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esHurtCache[iTank].g_flOpenAreasOnly) || bIsAreaWide(iTank, g_esHurtCache[iTank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esHurtPlayer[iTank].g_iTankType, iTank) || (g_esHurtCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esHurtCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esHurtAbility[g_esHurtPlayer[iTank].g_iTankType].g_iAccessFlags, g_esHurtPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esHurtPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || iType != g_esHurtPlayer[iTank].g_iTankType || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, g_esHurtPlayer[iTank].g_iTankType, g_esHurtAbility[g_esHurtPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esHurtPlayer[iSurvivor].g_iImmunityFlags) || !g_esHurtPlayer[iSurvivor].g_bAffected)
	{
		vHurtReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iHurtEnabled = pack.ReadCell(), iPos = pack.ReadCell(),
		iDuration = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(iTank, 5, iPos)) : g_esHurtCache[iTank].g_iHurtDuration,
		iTime = pack.ReadCell();
	if (iHurtEnabled == 0 || (iTime + iDuration) <= GetTime())
	{
		vHurtReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	float flDamage = (iPos != -1) ? MT_GetCombinationSetting(iTank, 3, iPos) : g_esHurtCache[iTank].g_flHurtDamage;
	if (flDamage > 0.0)
	{
		vDamagePlayer(iSurvivor, iTank, MT_GetScaledDamage(flDamage));
	}

	vAttachParticle(iSurvivor, PARTICLE_BLOOD, 0.1);
	EmitSoundToAll(SOUND_ATTACK, iSurvivor);

	return Plugin_Continue;
}