/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2024  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#define MT_GRAVITY_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN
	#if MT_GRAVITY_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities" while compiling "mt_abilities.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Gravity Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank pulls in or pushes away survivors and any other nearby infected, and changes the survivors' gravity.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "\"[MT] Gravity Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}

#define SOUND_BELL "plats/churchbell_end.wav"
#else
	#if MT_GRAVITY_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_GRAVITY_SECTION "gravityability"
#define MT_GRAVITY_SECTION2 "gravity ability"
#define MT_GRAVITY_SECTION3 "gravity_ability"
#define MT_GRAVITY_SECTION4 "gravity"

#define MT_MENU_GRAVITY "Gravity Ability"

enum struct esGravityPlayer
{
	bool g_bActivated;
	bool g_bAffected;
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flCloseAreasOnly;
	float g_flGravityChance;
	float g_flGravityForce;
	float g_flGravityRadius;
	float g_flGravityRange;
	float g_flGravityRangeChance;
	float g_flGravityRockChance;
	float g_flGravityValue;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iAmmoCount2;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iCooldown2;
	int g_iDuration;
	int g_iGravityAbility;
	int g_iGravityCooldown;
	int g_iGravityDuration;
	int g_iGravityEffect;
	int g_iGravityFlags;
	int g_iGravityHit;
	int g_iGravityHitMode;
	int g_iGravityMessage;
	int g_iGravityPointPush;
	int g_iGravityRangeCooldown;
	int g_iGravityRockBreak;
	int g_iGravityRockCooldown;
	int g_iGravitySight;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRangeCooldown;
	int g_iHumanRockCooldown;
	int g_iImmunityFlags;
	int g_iOwner;
	int g_iRangeCooldown;
	int g_iRequiresHumans;
	int g_iRockCooldown;
	int g_iTankType;
	int g_iTankTypeRecorded;
}

esGravityPlayer g_esGravityPlayer[MAXPLAYERS + 1];

enum struct esGravityTeammate
{
	float g_flCloseAreasOnly;
	float g_flGravityChance;
	float g_flGravityForce;
	float g_flGravityRadius;
	float g_flGravityRange;
	float g_flGravityRangeChance;
	float g_flGravityRockChance;
	float g_flGravityValue;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iGravityAbility;
	int g_iGravityCooldown;
	int g_iGravityDuration;
	int g_iGravityEffect;
	int g_iGravityFlags;
	int g_iGravityHit;
	int g_iGravityHitMode;
	int g_iGravityMessage;
	int g_iGravityPointPush;
	int g_iGravityRangeCooldown;
	int g_iGravityRockBreak;
	int g_iGravityRockCooldown;
	int g_iGravitySight;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRangeCooldown;
	int g_iHumanRockCooldown;
	int g_iRequiresHumans;
}

esGravityTeammate g_esGravityTeammate[MAXPLAYERS + 1];

enum struct esGravityAbility
{
	float g_flCloseAreasOnly;
	float g_flGravityChance;
	float g_flGravityForce;
	float g_flGravityRadius;
	float g_flGravityRange;
	float g_flGravityRangeChance;
	float g_flGravityRockChance;
	float g_flGravityValue;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iComboPosition;
	int g_iGravityAbility;
	int g_iGravityCooldown;
	int g_iGravityDuration;
	int g_iGravityEffect;
	int g_iGravityFlags;
	int g_iGravityHit;
	int g_iGravityHitMode;
	int g_iGravityMessage;
	int g_iGravityRangeCooldown;
	int g_iGravityRockBreak;
	int g_iGravityRockCooldown;
	int g_iGravitySight;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRangeCooldown;
	int g_iHumanRockCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esGravityAbility g_esGravityAbility[MT_MAXTYPES + 1];

enum struct esGravitySpecial
{
	float g_flCloseAreasOnly;
	float g_flGravityChance;
	float g_flGravityForce;
	float g_flGravityRadius;
	float g_flGravityRange;
	float g_flGravityRangeChance;
	float g_flGravityRockChance;
	float g_flGravityValue;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iGravityAbility;
	int g_iGravityCooldown;
	int g_iGravityDuration;
	int g_iGravityEffect;
	int g_iGravityFlags;
	int g_iGravityHit;
	int g_iGravityHitMode;
	int g_iGravityMessage;
	int g_iGravityRangeCooldown;
	int g_iGravityRockBreak;
	int g_iGravityRockCooldown;
	int g_iGravitySight;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRangeCooldown;
	int g_iHumanRockCooldown;
	int g_iRequiresHumans;
}

esGravitySpecial g_esGravitySpecial[MT_MAXTYPES + 1];

enum struct esGravityCache
{
	float g_flCloseAreasOnly;
	float g_flGravityChance;
	float g_flGravityForce;
	float g_flGravityRadius;
	float g_flGravityRange;
	float g_flGravityRangeChance;
	float g_flGravityRockChance;
	float g_flGravityValue;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iGravityAbility;
	int g_iGravityCooldown;
	int g_iGravityDuration;
	int g_iGravityEffect;
	int g_iGravityFlags;
	int g_iGravityHit;
	int g_iGravityHitMode;
	int g_iGravityMessage;
	int g_iGravityRangeCooldown;
	int g_iGravityRockBreak;
	int g_iGravityRockCooldown;
	int g_iGravitySight;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRangeCooldown;
	int g_iHumanRockCooldown;
	int g_iRequiresHumans;
}

esGravityCache g_esGravityCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_gravity", cmdGravityInfo, "View information about the Gravity ability.");

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
void vGravityMapStart()
#else
public void OnMapStart()
#endif
{
	PrecacheSound(SOUND_BELL, true);

	vGravityReset();
}

#if defined MT_ABILITIES_MAIN
void vGravityClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnGravityTakeDamage);
	vGravityReset2(client);
}

#if defined MT_ABILITIES_MAIN
void vGravityClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vGravityReset2(client);
}

#if defined MT_ABILITIES_MAIN
void vGravityMapEnd()
#else
public void OnMapEnd()
#endif
{
	vGravityReset();
}

#if !defined MT_ABILITIES_MAIN
Action cmdGravityInfo(int client, int args)
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
		case false: vGravityMenu(client, MT_GRAVITY_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vGravityMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_GRAVITY_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iGravityMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Gravity Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Button Mode", "Button Mode");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.AddItem("Range Cooldown", "Range Cooldown");
	mAbilityMenu.AddItem("Rock Cooldown", "Rock Cooldown");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

int iGravityMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esGravityCache[param1].g_iGravityAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esGravityCache[param1].g_iHumanAmmo - g_esGravityPlayer[param1].g_iAmmoCount), g_esGravityCache[param1].g_iHumanAmmo);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", (g_esGravityCache[param1].g_iHumanAmmo - g_esGravityPlayer[param1].g_iAmmoCount2), g_esGravityCache[param1].g_iHumanAmmo);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esGravityCache[param1].g_iHumanMode == 0) ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esGravityCache[param1].g_iHumanAbility == 1) ? g_esGravityCache[param1].g_iHumanCooldown : g_esGravityCache[param1].g_iGravityCooldown));
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "GravityDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", ((g_esGravityCache[param1].g_iHumanAbility == 1) ? g_esGravityCache[param1].g_iHumanDuration : g_esGravityCache[param1].g_iGravityDuration));
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esGravityCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
				case 8: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityRangeCooldown", ((g_esGravityCache[param1].g_iHumanAbility == 1) ? g_esGravityCache[param1].g_iHumanRangeCooldown : g_esGravityCache[param1].g_iGravityRangeCooldown));
				case 9: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityRockCooldown", ((g_esGravityCache[param1].g_iHumanAbility == 1) ? g_esGravityCache[param1].g_iHumanRockCooldown : g_esGravityCache[param1].g_iGravityRockCooldown));
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vGravityMenu(param1, MT_GRAVITY_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pGravity = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "GravityMenu", param1);
			pGravity.SetTitle(sMenuTitle);
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
					case 8: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "RangeCooldown", param1);
					case 9: FormatEx(sMenuOption, sizeof sMenuOption, "%T", "RockCooldown", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

#if defined MT_ABILITIES_MAIN
void vGravityDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_GRAVITY, MT_MENU_GRAVITY);
}

#if defined MT_ABILITIES_MAIN
void vGravityMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_GRAVITY, false))
	{
		vGravityMenu(client, MT_GRAVITY_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN
void vGravityMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_GRAVITY, false))
	{
		FormatEx(buffer, size, "%T", "GravityMenu2", client);
	}
}

#if defined MT_ABILITIES_MAIN
void vGravityPlayerRunCmd(int client)
#else
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
#endif
{
	if (!MT_IsTankSupported(client) || !g_esGravityPlayer[client].g_bActivated || (bIsInfected(client, MT_CHECK_FAKECLIENT) && g_esGravityCache[client].g_iHumanMode == 1) || g_esGravityPlayer[client].g_iDuration == -1)
	{
#if defined MT_ABILITIES_MAIN
		return;
#else
		return Plugin_Continue;
#endif
	}

	int iTime = GetTime();
	if (g_esGravityPlayer[client].g_iDuration <= iTime)
	{
		if (g_esGravityPlayer[client].g_iCooldown == -1 || g_esGravityPlayer[client].g_iCooldown <= iTime)
		{
			vGravityReset4(client);
		}

		vGravityReset3(client);
	}
#if !defined MT_ABILITIES_MAIN
	return Plugin_Continue;
#endif
}

Action OnGravityTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		char sClassname[32];
		if (bIsValidEntity(inflictor))
		{
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esGravityCache[attacker].g_iGravityHitMode == 0 || g_esGravityCache[attacker].g_iGravityHitMode == 1) && bIsSurvivor(victim) && g_esGravityCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esGravityAbility[g_esGravityPlayer[attacker].g_iTankTypeRecorded].g_iAccessFlags, g_esGravityPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esGravityPlayer[attacker].g_iTankType, g_esGravityAbility[g_esGravityPlayer[attacker].g_iTankTypeRecorded].g_iImmunityFlags, g_esGravityPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			bool bCaught = bIsSurvivorCaught(victim);
			if ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vGravityHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esGravityCache[attacker].g_flGravityChance, g_esGravityCache[attacker].g_iGravityHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esGravityCache[victim].g_iGravityHitMode == 0 || g_esGravityCache[victim].g_iGravityHitMode == 2) && bIsSurvivor(attacker) && g_esGravityCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esGravityAbility[g_esGravityPlayer[victim].g_iTankTypeRecorded].g_iAccessFlags, g_esGravityPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esGravityPlayer[victim].g_iTankType, g_esGravityAbility[g_esGravityPlayer[victim].g_iTankTypeRecorded].g_iImmunityFlags, g_esGravityPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname[7], "melee"))
			{
				vGravityHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esGravityCache[victim].g_flGravityChance, g_esGravityCache[victim].g_iGravityHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN
void vGravityPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_GRAVITY);
}

#if defined MT_ABILITIES_MAIN
void vGravityAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_GRAVITY_SECTION);
	list2.PushString(MT_GRAVITY_SECTION2);
	list3.PushString(MT_GRAVITY_SECTION3);
	list4.PushString(MT_GRAVITY_SECTION4);
}

#if defined MT_ABILITIES_MAIN
void vGravityCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility != 2)
	{
		g_esGravityAbility[g_esGravityPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

		return;
	}

	g_esGravityAbility[g_esGravityPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = -1;

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_GRAVITY_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_GRAVITY_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_GRAVITY_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_GRAVITY_SECTION4);
	if (g_esGravityCache[tank].g_iComboAbility == 1 && (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1))
	{
		char sAbilities[320], sSubset[10][32];
		strcopy(sAbilities, sizeof sAbilities, combo);
		ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

		float flChance = 0.0, flDelay = 0.0;
		for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_GRAVITY_SECTION, false) || StrEqual(sSubset[iPos], MT_GRAVITY_SECTION2, false) || StrEqual(sSubset[iPos], MT_GRAVITY_SECTION3, false) || StrEqual(sSubset[iPos], MT_GRAVITY_SECTION4, false))
			{
				g_esGravityAbility[g_esGravityPlayer[tank].g_iTankTypeRecorded].g_iComboPosition = iPos;
				flDelay = MT_GetCombinationSetting(tank, 4, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esGravityCache[tank].g_iGravityAbility == 1 || g_esGravityCache[tank].g_iGravityAbility == 3)
						{
							switch (flDelay)
							{
								case 0.0: vGravityAbility(tank, true, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerGravityCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteFloat(random);
									dpCombo.WriteCell(iPos);
								}
							}
						}

						if (g_esGravityCache[tank].g_iGravityAbility == 2 || g_esGravityCache[tank].g_iGravityAbility == 3)
						{
							switch (flDelay)
							{
								case 0.0: vGravityAbility(tank, false, .pos = iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerGravityCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
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
								if ((g_esGravityCache[tank].g_iGravityHitMode == 0 || g_esGravityCache[tank].g_iGravityHitMode == 1) && (StrEqual(classname[7], "tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vGravityHit(survivor, tank, random, flChance, g_esGravityCache[tank].g_iGravityHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
								}
								else if ((g_esGravityCache[tank].g_iGravityHitMode == 0 || g_esGravityCache[tank].g_iGravityHitMode == 2) && StrEqual(classname[7], "melee"))
								{
									vGravityHit(survivor, tank, random, flChance, g_esGravityCache[tank].g_iGravityHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerGravityCombo3, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
								dpCombo.WriteCell(GetClientUserId(survivor));
								dpCombo.WriteCell(GetClientUserId(tank));
								dpCombo.WriteFloat(random);
								dpCombo.WriteFloat(flChance);
								dpCombo.WriteCell(iPos);
								dpCombo.WriteString(classname);
							}
						}
					}
					case MT_COMBO_ROCKBREAK:
					{
						if (g_esGravityCache[tank].g_iGravityRockBreak == 1 && bIsValidEntity(weapon))
						{
							vGravityRockBreak2(tank, weapon, random, iPos);
						}
					}
				}

				break;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vGravityConfigsLoad(int mode)
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
				g_esGravityAbility[iIndex].g_iAccessFlags = 0;
				g_esGravityAbility[iIndex].g_iImmunityFlags = 0;
				g_esGravityAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esGravityAbility[iIndex].g_iComboAbility = 0;
				g_esGravityAbility[iIndex].g_iComboPosition = -1;
				g_esGravityAbility[iIndex].g_iHumanAbility = 0;
				g_esGravityAbility[iIndex].g_iHumanAmmo = 5;
				g_esGravityAbility[iIndex].g_iHumanCooldown = 0;
				g_esGravityAbility[iIndex].g_iHumanDuration = 5;
				g_esGravityAbility[iIndex].g_iHumanMode = 1;
				g_esGravityAbility[iIndex].g_iHumanRangeCooldown = 0;
				g_esGravityAbility[iIndex].g_iHumanRockCooldown = 0;
				g_esGravityAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esGravityAbility[iIndex].g_iRequiresHumans = 0;
				g_esGravityAbility[iIndex].g_iGravityAbility = 0;
				g_esGravityAbility[iIndex].g_iGravityEffect = 0;
				g_esGravityAbility[iIndex].g_iGravityMessage = 0;
				g_esGravityAbility[iIndex].g_flGravityChance = 33.3;
				g_esGravityAbility[iIndex].g_iGravityCooldown = 0;
				g_esGravityAbility[iIndex].g_iGravityDuration = 5;
				g_esGravityAbility[iIndex].g_iGravityFlags = 8;
				g_esGravityAbility[iIndex].g_flGravityForce = -50.0;
				g_esGravityAbility[iIndex].g_iGravityHit = 0;
				g_esGravityAbility[iIndex].g_iGravityHitMode = 0;
				g_esGravityAbility[iIndex].g_flGravityRadius = 750.0;
				g_esGravityAbility[iIndex].g_flGravityRange = 150.0;
				g_esGravityAbility[iIndex].g_flGravityRangeChance = 15.0;
				g_esGravityAbility[iIndex].g_iGravityRangeCooldown = 0;
				g_esGravityAbility[iIndex].g_iGravitySight = 0;
				g_esGravityAbility[iIndex].g_iGravityRockBreak = 0;
				g_esGravityAbility[iIndex].g_flGravityRockChance = 33.3;
				g_esGravityAbility[iIndex].g_iGravityRockCooldown = 0;
				g_esGravityAbility[iIndex].g_flGravityValue = 0.3;

				g_esGravitySpecial[iIndex].g_flCloseAreasOnly = -1.0;
				g_esGravitySpecial[iIndex].g_iComboAbility = -1;
				g_esGravitySpecial[iIndex].g_iHumanAbility = -1;
				g_esGravitySpecial[iIndex].g_iHumanAmmo = -1;
				g_esGravitySpecial[iIndex].g_iHumanCooldown = -1;
				g_esGravitySpecial[iIndex].g_iHumanDuration = -1;
				g_esGravitySpecial[iIndex].g_iHumanMode = -1;
				g_esGravitySpecial[iIndex].g_iHumanRangeCooldown = -1;
				g_esGravitySpecial[iIndex].g_iHumanRockCooldown = -1;
				g_esGravitySpecial[iIndex].g_flOpenAreasOnly = -1.0;
				g_esGravitySpecial[iIndex].g_iRequiresHumans = -1;
				g_esGravitySpecial[iIndex].g_iGravityAbility = -1;
				g_esGravitySpecial[iIndex].g_iGravityEffect = -1;
				g_esGravitySpecial[iIndex].g_iGravityMessage = -1;
				g_esGravitySpecial[iIndex].g_flGravityChance = -1.0;
				g_esGravitySpecial[iIndex].g_iGravityCooldown = -1;
				g_esGravitySpecial[iIndex].g_iGravityDuration = -1;
				g_esGravitySpecial[iIndex].g_iGravityFlags = -1;
				g_esGravitySpecial[iIndex].g_flGravityForce = -1.0;
				g_esGravitySpecial[iIndex].g_iGravityHit = -1;
				g_esGravitySpecial[iIndex].g_iGravityHitMode = -1;
				g_esGravitySpecial[iIndex].g_flGravityRadius = -1.0;
				g_esGravitySpecial[iIndex].g_flGravityRange = -1.0;
				g_esGravitySpecial[iIndex].g_flGravityRangeChance = -1.0;
				g_esGravitySpecial[iIndex].g_iGravityRangeCooldown = -1;
				g_esGravitySpecial[iIndex].g_iGravityRockBreak = -1;
				g_esGravitySpecial[iIndex].g_flGravityRockChance = -1.0;
				g_esGravitySpecial[iIndex].g_iGravityRockCooldown = -1;
				g_esGravitySpecial[iIndex].g_iGravitySight = -1;
				g_esGravitySpecial[iIndex].g_flGravityValue = -1.0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esGravityPlayer[iPlayer].g_iAccessFlags = -1;
				g_esGravityPlayer[iPlayer].g_iImmunityFlags = -1;
				g_esGravityPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esGravityPlayer[iPlayer].g_iComboAbility = -1;
				g_esGravityPlayer[iPlayer].g_iHumanAbility = -1;
				g_esGravityPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esGravityPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esGravityPlayer[iPlayer].g_iHumanDuration = -1;
				g_esGravityPlayer[iPlayer].g_iHumanMode = -1;
				g_esGravityPlayer[iPlayer].g_iHumanRangeCooldown = -1;
				g_esGravityPlayer[iPlayer].g_iHumanRockCooldown = -1;
				g_esGravityPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esGravityPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esGravityPlayer[iPlayer].g_iGravityAbility = -1;
				g_esGravityPlayer[iPlayer].g_iGravityEffect = -1;
				g_esGravityPlayer[iPlayer].g_iGravityMessage = -1;
				g_esGravityPlayer[iPlayer].g_flGravityChance = -1.0;
				g_esGravityPlayer[iPlayer].g_iGravityCooldown = -1;
				g_esGravityPlayer[iPlayer].g_iGravityDuration = -1;
				g_esGravityPlayer[iPlayer].g_iGravityFlags = -1;
				g_esGravityPlayer[iPlayer].g_flGravityForce = -1.0;
				g_esGravityPlayer[iPlayer].g_iGravityHit = -1;
				g_esGravityPlayer[iPlayer].g_iGravityHitMode = -1;
				g_esGravityPlayer[iPlayer].g_flGravityRadius = -1.0;
				g_esGravityPlayer[iPlayer].g_flGravityRange = -1.0;
				g_esGravityPlayer[iPlayer].g_flGravityRangeChance = -1.0;
				g_esGravityPlayer[iPlayer].g_iGravityRangeCooldown = -1;
				g_esGravityPlayer[iPlayer].g_iGravityRockBreak = -1;
				g_esGravityPlayer[iPlayer].g_flGravityRockChance = -1.0;
				g_esGravityPlayer[iPlayer].g_iGravityRockCooldown = -1;
				g_esGravityPlayer[iPlayer].g_iGravitySight = -1;
				g_esGravityPlayer[iPlayer].g_flGravityValue = -1.0;

				g_esGravityTeammate[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esGravityTeammate[iPlayer].g_iComboAbility = -1;
				g_esGravityTeammate[iPlayer].g_iHumanAbility = -1;
				g_esGravityTeammate[iPlayer].g_iHumanAmmo = -1;
				g_esGravityTeammate[iPlayer].g_iHumanCooldown = -1;
				g_esGravityTeammate[iPlayer].g_iHumanDuration = -1;
				g_esGravityTeammate[iPlayer].g_iHumanMode = -1;
				g_esGravityTeammate[iPlayer].g_iHumanRangeCooldown = -1;
				g_esGravityTeammate[iPlayer].g_iHumanRockCooldown = -1;
				g_esGravityTeammate[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esGravityTeammate[iPlayer].g_iRequiresHumans = -1;
				g_esGravityTeammate[iPlayer].g_iGravityAbility = -1;
				g_esGravityTeammate[iPlayer].g_iGravityEffect = -1;
				g_esGravityTeammate[iPlayer].g_iGravityMessage = -1;
				g_esGravityTeammate[iPlayer].g_flGravityChance = -1.0;
				g_esGravityTeammate[iPlayer].g_iGravityCooldown = -1;
				g_esGravityTeammate[iPlayer].g_iGravityDuration = -1;
				g_esGravityTeammate[iPlayer].g_iGravityFlags = -1;
				g_esGravityTeammate[iPlayer].g_flGravityForce = -1.0;
				g_esGravityTeammate[iPlayer].g_iGravityHit = -1;
				g_esGravityTeammate[iPlayer].g_iGravityHitMode = -1;
				g_esGravityTeammate[iPlayer].g_flGravityRadius = -1.0;
				g_esGravityTeammate[iPlayer].g_flGravityRange = -1.0;
				g_esGravityTeammate[iPlayer].g_flGravityRangeChance = -1.0;
				g_esGravityTeammate[iPlayer].g_iGravityRangeCooldown = -1;
				g_esGravityTeammate[iPlayer].g_iGravityRockBreak = -1;
				g_esGravityTeammate[iPlayer].g_flGravityRockChance = -1.0;
				g_esGravityTeammate[iPlayer].g_iGravityRockCooldown = -1;
				g_esGravityTeammate[iPlayer].g_iGravitySight = -1;
				g_esGravityTeammate[iPlayer].g_flGravityValue = -1.0;
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vGravityConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esGravityTeammate[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esGravityTeammate[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esGravityTeammate[admin].g_iComboAbility = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esGravityTeammate[admin].g_iComboAbility, value, -1, 1);
			g_esGravityTeammate[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esGravityTeammate[admin].g_iHumanAbility, value, -1, 2);
			g_esGravityTeammate[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esGravityTeammate[admin].g_iHumanAmmo, value, -1, 99999);
			g_esGravityTeammate[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esGravityTeammate[admin].g_iHumanCooldown, value, -1, 99999);
			g_esGravityTeammate[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esGravityTeammate[admin].g_iHumanDuration, value, -1, 99999);
			g_esGravityTeammate[admin].g_iHumanMode = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esGravityTeammate[admin].g_iHumanMode, value, -1, 1);
			g_esGravityTeammate[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esGravityTeammate[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esGravityTeammate[admin].g_iHumanRockCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanRockCooldown", "Human Rock Cooldown", "Human_Rock_Cooldown", "hrockcooldown", g_esGravityTeammate[admin].g_iHumanRockCooldown, value, -1, 99999);
			g_esGravityTeammate[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esGravityTeammate[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esGravityTeammate[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esGravityTeammate[admin].g_iRequiresHumans, value, -1, 32);
			g_esGravityTeammate[admin].g_iGravityAbility = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esGravityTeammate[admin].g_iGravityAbility, value, -1, 3);
			g_esGravityTeammate[admin].g_iGravityEffect = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esGravityTeammate[admin].g_iGravityEffect, value, -1, 7);
			g_esGravityTeammate[admin].g_iGravityMessage = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esGravityTeammate[admin].g_iGravityMessage, value, -1, 7);
			g_esGravityTeammate[admin].g_iGravitySight = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esGravityTeammate[admin].g_iGravitySight, value, -1, 5);
			g_esGravityTeammate[admin].g_flGravityChance = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityChance", "Gravity Chance", "Gravity_Chance", "chance", g_esGravityTeammate[admin].g_flGravityChance, value, -1.0, 100.0);
			g_esGravityTeammate[admin].g_iGravityCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityCooldown", "Gravity Cooldown", "Gravity_Cooldown", "cooldown", g_esGravityTeammate[admin].g_iGravityCooldown, value, -1, 99999);
			g_esGravityTeammate[admin].g_iGravityDuration = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityDuration", "Gravity Duration", "Gravity_Duration", "duration", g_esGravityTeammate[admin].g_iGravityDuration, value, -1, 99999);
			g_esGravityTeammate[admin].g_iGravityFlags = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityFlags", "Gravity Flags", "Gravity_Flags", "flags", g_esGravityTeammate[admin].g_iGravityFlags, value, -1, 31);
			g_esGravityTeammate[admin].g_flGravityForce = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityForce", "Gravity Force", "Gravity_Force", "force", g_esGravityTeammate[admin].g_flGravityForce, value, -100.0, 100.0);
			g_esGravityTeammate[admin].g_iGravityHit = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityHit", "Gravity Hit", "Gravity_Hit", "hit", g_esGravityTeammate[admin].g_iGravityHit, value, -1, 1);
			g_esGravityTeammate[admin].g_iGravityHitMode = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityHitMode", "Gravity Hit Mode", "Gravity_Hit_Mode", "hitmode", g_esGravityTeammate[admin].g_iGravityHitMode, value, -1, 2);
			g_esGravityTeammate[admin].g_flGravityRadius = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRadius", "Gravity Radius", "Gravity_Radius", "radius", g_esGravityTeammate[admin].g_flGravityRadius, value, -1.0, 99999.0);
			g_esGravityTeammate[admin].g_flGravityRange = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRange", "Gravity Range", "Gravity_Range", "range", g_esGravityTeammate[admin].g_flGravityRange, value, -1.0, 99999.0);
			g_esGravityTeammate[admin].g_flGravityRangeChance = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRangeChance", "Gravity Range Chance", "Gravity_Range_Chance", "rangechance", g_esGravityTeammate[admin].g_flGravityRangeChance, value, -1.0, 100.0);
			g_esGravityTeammate[admin].g_iGravityRangeCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRangeCooldown", "Gravity Range Cooldown", "Gravity_Range_Cooldown", "rangecooldown", g_esGravityTeammate[admin].g_iGravityRangeCooldown, value, -1, 99999);
			g_esGravityTeammate[admin].g_iGravityRockBreak = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRockBreak", "Gravity Rock Break", "Gravity_Rock_Break", "rock", g_esGravityTeammate[admin].g_iGravityRockBreak, value, -1, 1);
			g_esGravityTeammate[admin].g_flGravityRockChance = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRockChance", "Gravity Rock Chance", "Gravity_Rock_Chance", "rockchance", g_esGravityTeammate[admin].g_flGravityRockChance, value, -1.0, 100.0);
			g_esGravityTeammate[admin].g_iGravityRockCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRockCooldown", "Gravity Rock Cooldown", "Gravity_Rock_Cooldown", "rockcooldown", g_esGravityTeammate[admin].g_iGravityRockCooldown, value, -1, 99999);
			g_esGravityTeammate[admin].g_flGravityValue = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityValue", "Gravity Value", "Gravity_Value", "value", g_esGravityTeammate[admin].g_flGravityValue, value, -1.0, 99999.0);
		}
		else
		{
			g_esGravityPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esGravityPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esGravityPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esGravityPlayer[admin].g_iComboAbility, value, -1, 1);
			g_esGravityPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esGravityPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esGravityPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esGravityPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esGravityPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esGravityPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esGravityPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esGravityPlayer[admin].g_iHumanDuration, value, -1, 99999);
			g_esGravityPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esGravityPlayer[admin].g_iHumanMode, value, -1, 1);
			g_esGravityPlayer[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esGravityPlayer[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esGravityPlayer[admin].g_iHumanRockCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanRockCooldown", "Human Rock Cooldown", "Human_Rock_Cooldown", "hrockcooldown", g_esGravityPlayer[admin].g_iHumanRockCooldown, value, -1, 99999);
			g_esGravityPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esGravityPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esGravityPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esGravityPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esGravityPlayer[admin].g_iGravityAbility = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esGravityPlayer[admin].g_iGravityAbility, value, -1, 3);
			g_esGravityPlayer[admin].g_iGravityEffect = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esGravityPlayer[admin].g_iGravityEffect, value, -1, 7);
			g_esGravityPlayer[admin].g_iGravityMessage = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esGravityPlayer[admin].g_iGravityMessage, value, -1, 7);
			g_esGravityPlayer[admin].g_iGravitySight = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esGravityPlayer[admin].g_iGravitySight, value, -1, 5);
			g_esGravityPlayer[admin].g_flGravityChance = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityChance", "Gravity Chance", "Gravity_Chance", "chance", g_esGravityPlayer[admin].g_flGravityChance, value, -1.0, 100.0);
			g_esGravityPlayer[admin].g_iGravityCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityCooldown", "Gravity Cooldown", "Gravity_Cooldown", "cooldown", g_esGravityPlayer[admin].g_iGravityCooldown, value, -1, 99999);
			g_esGravityPlayer[admin].g_iGravityDuration = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityDuration", "Gravity Duration", "Gravity_Duration", "duration", g_esGravityPlayer[admin].g_iGravityDuration, value, -1, 99999);
			g_esGravityPlayer[admin].g_iGravityFlags = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityFlags", "Gravity Flags", "Gravity_Flags", "flags", g_esGravityPlayer[admin].g_iGravityFlags, value, -1, 31);
			g_esGravityPlayer[admin].g_flGravityForce = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityForce", "Gravity Force", "Gravity_Force", "force", g_esGravityPlayer[admin].g_flGravityForce, value, -100.0, 100.0);
			g_esGravityPlayer[admin].g_iGravityHit = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityHit", "Gravity Hit", "Gravity_Hit", "hit", g_esGravityPlayer[admin].g_iGravityHit, value, -1, 1);
			g_esGravityPlayer[admin].g_iGravityHitMode = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityHitMode", "Gravity Hit Mode", "Gravity_Hit_Mode", "hitmode", g_esGravityPlayer[admin].g_iGravityHitMode, value, -1, 2);
			g_esGravityPlayer[admin].g_flGravityRadius = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRadius", "Gravity Radius", "Gravity_Radius", "radius", g_esGravityPlayer[admin].g_flGravityRadius, value, -1.0, 99999.0);
			g_esGravityPlayer[admin].g_flGravityRange = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRange", "Gravity Range", "Gravity_Range", "range", g_esGravityPlayer[admin].g_flGravityRange, value, -1.0, 99999.0);
			g_esGravityPlayer[admin].g_flGravityRangeChance = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRangeChance", "Gravity Range Chance", "Gravity_Range_Chance", "rangechance", g_esGravityPlayer[admin].g_flGravityRangeChance, value, -1.0, 100.0);
			g_esGravityPlayer[admin].g_iGravityRangeCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRangeCooldown", "Gravity Range Cooldown", "Gravity_Range_Cooldown", "rangecooldown", g_esGravityPlayer[admin].g_iGravityRangeCooldown, value, -1, 99999);
			g_esGravityPlayer[admin].g_iGravityRockBreak = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRockBreak", "Gravity Rock Break", "Gravity_Rock_Break", "rock", g_esGravityPlayer[admin].g_iGravityRockBreak, value, -1, 1);
			g_esGravityPlayer[admin].g_flGravityRockChance = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRockChance", "Gravity Rock Chance", "Gravity_Rock_Chance", "rockchance", g_esGravityPlayer[admin].g_flGravityRockChance, value, -1.0, 100.0);
			g_esGravityPlayer[admin].g_iGravityRockCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRockCooldown", "Gravity Rock Cooldown", "Gravity_Rock_Cooldown", "rockcooldown", g_esGravityPlayer[admin].g_iGravityRockCooldown, value, -1, 99999);
			g_esGravityPlayer[admin].g_flGravityValue = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityValue", "Gravity Value", "Gravity_Value", "value", g_esGravityPlayer[admin].g_flGravityValue, value, -1.0, 99999.0);
			g_esGravityPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esGravityPlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esGravitySpecial[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esGravitySpecial[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esGravitySpecial[type].g_iComboAbility = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esGravitySpecial[type].g_iComboAbility, value, -1, 1);
			g_esGravitySpecial[type].g_iHumanAbility = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esGravitySpecial[type].g_iHumanAbility, value, -1, 2);
			g_esGravitySpecial[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esGravitySpecial[type].g_iHumanAmmo, value, -1, 99999);
			g_esGravitySpecial[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esGravitySpecial[type].g_iHumanCooldown, value, -1, 99999);
			g_esGravitySpecial[type].g_iHumanDuration = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esGravitySpecial[type].g_iHumanDuration, value, -1, 99999);
			g_esGravitySpecial[type].g_iHumanMode = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esGravitySpecial[type].g_iHumanMode, value, -1, 1);
			g_esGravitySpecial[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esGravitySpecial[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esGravitySpecial[type].g_iHumanRockCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanRockCooldown", "Human Rock Cooldown", "Human_Rock_Cooldown", "hrockcooldown", g_esGravitySpecial[type].g_iHumanRockCooldown, value, -1, 99999);
			g_esGravitySpecial[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esGravitySpecial[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esGravitySpecial[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esGravitySpecial[type].g_iRequiresHumans, value, -1, 32);
			g_esGravitySpecial[type].g_iGravityAbility = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esGravitySpecial[type].g_iGravityAbility, value, -1, 3);
			g_esGravitySpecial[type].g_iGravityEffect = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esGravitySpecial[type].g_iGravityEffect, value, -1, 7);
			g_esGravitySpecial[type].g_iGravityMessage = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esGravitySpecial[type].g_iGravityMessage, value, -1, 7);
			g_esGravitySpecial[type].g_iGravitySight = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esGravitySpecial[type].g_iGravitySight, value, -1, 5);
			g_esGravitySpecial[type].g_flGravityChance = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityChance", "Gravity Chance", "Gravity_Chance", "chance", g_esGravitySpecial[type].g_flGravityChance, value, -1.0, 100.0);
			g_esGravitySpecial[type].g_iGravityCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityCooldown", "Gravity Cooldown", "Gravity_Cooldown", "cooldown", g_esGravitySpecial[type].g_iGravityCooldown, value, -1, 99999);
			g_esGravitySpecial[type].g_iGravityDuration = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityDuration", "Gravity Duration", "Gravity_Duration", "duration", g_esGravitySpecial[type].g_iGravityDuration, value, -1, 99999);
			g_esGravitySpecial[type].g_iGravityFlags = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityFlags", "Gravity Flags", "Gravity_Flags", "flags", g_esGravitySpecial[type].g_iGravityFlags, value, -1, 31);
			g_esGravitySpecial[type].g_flGravityForce = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityForce", "Gravity Force", "Gravity_Force", "force", g_esGravitySpecial[type].g_flGravityForce, value, -100.0, 100.0);
			g_esGravitySpecial[type].g_iGravityHit = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityHit", "Gravity Hit", "Gravity_Hit", "hit", g_esGravitySpecial[type].g_iGravityHit, value, -1, 1);
			g_esGravitySpecial[type].g_iGravityHitMode = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityHitMode", "Gravity Hit Mode", "Gravity_Hit_Mode", "hitmode", g_esGravitySpecial[type].g_iGravityHitMode, value, -1, 2);
			g_esGravitySpecial[type].g_flGravityRadius = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRadius", "Gravity Radius", "Gravity_Radius", "radius", g_esGravitySpecial[type].g_flGravityRadius, value, -1.0, 99999.0);
			g_esGravitySpecial[type].g_flGravityRange = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRange", "Gravity Range", "Gravity_Range", "range", g_esGravitySpecial[type].g_flGravityRange, value, -1.0, 99999.0);
			g_esGravitySpecial[type].g_flGravityRangeChance = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRangeChance", "Gravity Range Chance", "Gravity_Range_Chance", "rangechance", g_esGravitySpecial[type].g_flGravityRangeChance, value, -1.0, 100.0);
			g_esGravitySpecial[type].g_iGravityRangeCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRangeCooldown", "Gravity Range Cooldown", "Gravity_Range_Cooldown", "rangecooldown", g_esGravitySpecial[type].g_iGravityRangeCooldown, value, -1, 99999);
			g_esGravitySpecial[type].g_iGravityRockBreak = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRockBreak", "Gravity Rock Break", "Gravity_Rock_Break", "rock", g_esGravitySpecial[type].g_iGravityRockBreak, value, -1, 1);
			g_esGravitySpecial[type].g_flGravityRockChance = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRockChance", "Gravity Rock Chance", "Gravity_Rock_Chance", "rockchance", g_esGravitySpecial[type].g_flGravityRockChance, value, -1.0, 100.0);
			g_esGravitySpecial[type].g_iGravityRockCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRockCooldown", "Gravity Rock Cooldown", "Gravity_Rock_Cooldown", "rockcooldown", g_esGravitySpecial[type].g_iGravityRockCooldown, value, -1, 99999);
			g_esGravitySpecial[type].g_flGravityValue = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityValue", "Gravity Value", "Gravity_Value", "value", g_esGravitySpecial[type].g_flGravityValue, value, -1.0, 99999.0);
		}
		else
		{
			g_esGravityAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esGravityAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esGravityAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esGravityAbility[type].g_iComboAbility, value, -1, 1);
			g_esGravityAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esGravityAbility[type].g_iHumanAbility, value, -1, 2);
			g_esGravityAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esGravityAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esGravityAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esGravityAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esGravityAbility[type].g_iHumanDuration = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esGravityAbility[type].g_iHumanDuration, value, -1, 99999);
			g_esGravityAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esGravityAbility[type].g_iHumanMode, value, -1, 1);
			g_esGravityAbility[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esGravityAbility[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esGravityAbility[type].g_iHumanRockCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "HumanRockCooldown", "Human Rock Cooldown", "Human_Rock_Cooldown", "hrockcooldown", g_esGravityAbility[type].g_iHumanRockCooldown, value, -1, 99999);
			g_esGravityAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esGravityAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esGravityAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esGravityAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esGravityAbility[type].g_iGravityAbility = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esGravityAbility[type].g_iGravityAbility, value, -1, 3);
			g_esGravityAbility[type].g_iGravityEffect = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esGravityAbility[type].g_iGravityEffect, value, -1, 7);
			g_esGravityAbility[type].g_iGravityMessage = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esGravityAbility[type].g_iGravityMessage, value, -1, 7);
			g_esGravityAbility[type].g_iGravitySight = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esGravityAbility[type].g_iGravitySight, value, -1, 5);
			g_esGravityAbility[type].g_flGravityChance = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityChance", "Gravity Chance", "Gravity_Chance", "chance", g_esGravityAbility[type].g_flGravityChance, value, -1.0, 100.0);
			g_esGravityAbility[type].g_iGravityCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityCooldown", "Gravity Cooldown", "Gravity_Cooldown", "cooldown", g_esGravityAbility[type].g_iGravityCooldown, value, -1, 99999);
			g_esGravityAbility[type].g_iGravityDuration = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityDuration", "Gravity Duration", "Gravity_Duration", "duration", g_esGravityAbility[type].g_iGravityDuration, value, -1, 99999);
			g_esGravityAbility[type].g_iGravityFlags = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityFlags", "Gravity Flags", "Gravity_Flags", "flags", g_esGravityAbility[type].g_iGravityFlags, value, -1, 31);
			g_esGravityAbility[type].g_flGravityForce = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityForce", "Gravity Force", "Gravity_Force", "force", g_esGravityAbility[type].g_flGravityForce, value, -100.0, 100.0);
			g_esGravityAbility[type].g_iGravityHit = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityHit", "Gravity Hit", "Gravity_Hit", "hit", g_esGravityAbility[type].g_iGravityHit, value, -1, 1);
			g_esGravityAbility[type].g_iGravityHitMode = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityHitMode", "Gravity Hit Mode", "Gravity_Hit_Mode", "hitmode", g_esGravityAbility[type].g_iGravityHitMode, value, -1, 2);
			g_esGravityAbility[type].g_flGravityRadius = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRadius", "Gravity Radius", "Gravity_Radius", "radius", g_esGravityAbility[type].g_flGravityRadius, value, -1.0, 99999.0);
			g_esGravityAbility[type].g_flGravityRange = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRange", "Gravity Range", "Gravity_Range", "range", g_esGravityAbility[type].g_flGravityRange, value, -1.0, 99999.0);
			g_esGravityAbility[type].g_flGravityRangeChance = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRangeChance", "Gravity Range Chance", "Gravity_Range_Chance", "rangechance", g_esGravityAbility[type].g_flGravityRangeChance, value, -1.0, 100.0);
			g_esGravityAbility[type].g_iGravityRangeCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRangeCooldown", "Gravity Range Cooldown", "Gravity_Range_Cooldown", "rangecooldown", g_esGravityAbility[type].g_iGravityRangeCooldown, value, -1, 99999);
			g_esGravityAbility[type].g_iGravityRockBreak = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRockBreak", "Gravity Rock Break", "Gravity_Rock_Break", "rock", g_esGravityAbility[type].g_iGravityRockBreak, value, -1, 1);
			g_esGravityAbility[type].g_flGravityRockChance = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRockChance", "Gravity Rock Chance", "Gravity_Rock_Chance", "rockchance", g_esGravityAbility[type].g_flGravityRockChance, value, -1.0, 100.0);
			g_esGravityAbility[type].g_iGravityRockCooldown = iGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityRockCooldown", "Gravity Rock Cooldown", "Gravity_Rock_Cooldown", "rockcooldown", g_esGravityAbility[type].g_iGravityRockCooldown, value, -1, 99999);
			g_esGravityAbility[type].g_flGravityValue = flGetKeyValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "GravityValue", "Gravity Value", "Gravity_Value", "value", g_esGravityAbility[type].g_flGravityValue, value, -1.0, 99999.0);
			g_esGravityAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esGravityAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_GRAVITY_SECTION, MT_GRAVITY_SECTION2, MT_GRAVITY_SECTION3, MT_GRAVITY_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vGravitySettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esGravityPlayer[tank].g_iTankTypeRecorded = apply ? MT_GetRecordedTankType(tank, type) : 0;
	g_esGravityPlayer[tank].g_iTankType = apply ? type : 0;
	int iType = g_esGravityPlayer[tank].g_iTankTypeRecorded;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esGravityCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_flCloseAreasOnly, g_esGravityPlayer[tank].g_flCloseAreasOnly, g_esGravitySpecial[iType].g_flCloseAreasOnly, g_esGravityAbility[iType].g_flCloseAreasOnly, 1);
		g_esGravityCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iComboAbility, g_esGravityPlayer[tank].g_iComboAbility, g_esGravitySpecial[iType].g_iComboAbility, g_esGravityAbility[iType].g_iComboAbility, 1);
		g_esGravityCache[tank].g_flGravityChance = flGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_flGravityChance, g_esGravityPlayer[tank].g_flGravityChance, g_esGravitySpecial[iType].g_flGravityChance, g_esGravityAbility[iType].g_flGravityChance, 1);
		g_esGravityCache[tank].g_flGravityForce = flGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_flGravityForce, g_esGravityPlayer[tank].g_flGravityForce, g_esGravitySpecial[iType].g_flGravityForce, g_esGravityAbility[iType].g_flGravityForce, 2, -1.0);
		g_esGravityCache[tank].g_flGravityRadius = flGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_flGravityRadius, g_esGravityPlayer[tank].g_flGravityRadius, g_esGravitySpecial[iType].g_flGravityRadius, g_esGravityAbility[iType].g_flGravityRadius, 1);
		g_esGravityCache[tank].g_flGravityRange = flGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_flGravityRange, g_esGravityPlayer[tank].g_flGravityRange, g_esGravitySpecial[iType].g_flGravityRange, g_esGravityAbility[iType].g_flGravityRange, 1);
		g_esGravityCache[tank].g_flGravityRangeChance = flGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_flGravityRangeChance, g_esGravityPlayer[tank].g_flGravityRangeChance, g_esGravitySpecial[iType].g_flGravityRangeChance, g_esGravityAbility[iType].g_flGravityRangeChance, 1);
		g_esGravityCache[tank].g_flGravityRockChance = flGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_flGravityRockChance, g_esGravityPlayer[tank].g_flGravityRockChance, g_esGravitySpecial[iType].g_flGravityRockChance, g_esGravityAbility[iType].g_flGravityRockChance, 1);
		g_esGravityCache[tank].g_flGravityValue = flGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_flGravityValue, g_esGravityPlayer[tank].g_flGravityValue, g_esGravitySpecial[iType].g_flGravityValue, g_esGravityAbility[iType].g_flGravityValue, 1);
		g_esGravityCache[tank].g_iGravityAbility = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iGravityAbility, g_esGravityPlayer[tank].g_iGravityAbility, g_esGravitySpecial[iType].g_iGravityAbility, g_esGravityAbility[iType].g_iGravityAbility, 1);
		g_esGravityCache[tank].g_iGravityCooldown = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iGravityCooldown, g_esGravityPlayer[tank].g_iGravityCooldown, g_esGravitySpecial[iType].g_iGravityCooldown, g_esGravityAbility[iType].g_iGravityCooldown, 1);
		g_esGravityCache[tank].g_iGravityDuration = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iGravityDuration, g_esGravityPlayer[tank].g_iGravityDuration, g_esGravitySpecial[iType].g_iGravityDuration, g_esGravityAbility[iType].g_iGravityDuration, 1);
		g_esGravityCache[tank].g_iGravityEffect = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iGravityEffect, g_esGravityPlayer[tank].g_iGravityEffect, g_esGravitySpecial[iType].g_iGravityEffect, g_esGravityAbility[iType].g_iGravityEffect, 1);
		g_esGravityCache[tank].g_iGravityFlags = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iGravityFlags, g_esGravityPlayer[tank].g_iGravityFlags, g_esGravitySpecial[iType].g_iGravityFlags, g_esGravityAbility[iType].g_iGravityFlags, 1);
		g_esGravityCache[tank].g_iGravityHit = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iGravityHit, g_esGravityPlayer[tank].g_iGravityHit, g_esGravitySpecial[iType].g_iGravityHit, g_esGravityAbility[iType].g_iGravityHit, 1);
		g_esGravityCache[tank].g_iGravityHitMode = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iGravityHitMode, g_esGravityPlayer[tank].g_iGravityHitMode, g_esGravitySpecial[iType].g_iGravityHitMode, g_esGravityAbility[iType].g_iGravityHitMode, 1);
		g_esGravityCache[tank].g_iGravityMessage = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iGravityMessage, g_esGravityPlayer[tank].g_iGravityMessage, g_esGravitySpecial[iType].g_iGravityMessage, g_esGravityAbility[iType].g_iGravityMessage, 1);
		g_esGravityCache[tank].g_iGravityRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iGravityRangeCooldown, g_esGravityPlayer[tank].g_iGravityRangeCooldown, g_esGravitySpecial[iType].g_iGravityRangeCooldown, g_esGravityAbility[iType].g_iGravityRangeCooldown, 1);
		g_esGravityCache[tank].g_iGravityRockBreak = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iGravityRockBreak, g_esGravityPlayer[tank].g_iGravityRockBreak, g_esGravitySpecial[iType].g_iGravityRockBreak, g_esGravityAbility[iType].g_iGravityRockBreak, 1);
		g_esGravityCache[tank].g_iGravityRockCooldown = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iGravityRockCooldown, g_esGravityPlayer[tank].g_iGravityRockCooldown, g_esGravitySpecial[iType].g_iGravityRockCooldown, g_esGravityAbility[iType].g_iGravityRockCooldown, 1);
		g_esGravityCache[tank].g_iGravitySight = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iGravitySight, g_esGravityPlayer[tank].g_iGravitySight, g_esGravitySpecial[iType].g_iGravitySight, g_esGravityAbility[iType].g_iGravitySight, 1);
		g_esGravityCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iHumanAbility, g_esGravityPlayer[tank].g_iHumanAbility, g_esGravitySpecial[iType].g_iHumanAbility, g_esGravityAbility[iType].g_iHumanAbility, 1);
		g_esGravityCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iHumanAmmo, g_esGravityPlayer[tank].g_iHumanAmmo, g_esGravitySpecial[iType].g_iHumanAmmo, g_esGravityAbility[iType].g_iHumanAmmo, 1);
		g_esGravityCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iHumanCooldown, g_esGravityPlayer[tank].g_iHumanCooldown, g_esGravitySpecial[iType].g_iHumanCooldown, g_esGravityAbility[iType].g_iHumanCooldown, 1);
		g_esGravityCache[tank].g_iHumanDuration = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iHumanDuration, g_esGravityPlayer[tank].g_iHumanDuration, g_esGravitySpecial[iType].g_iHumanDuration, g_esGravityAbility[iType].g_iHumanDuration, 1);
		g_esGravityCache[tank].g_iHumanMode = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iHumanMode, g_esGravityPlayer[tank].g_iHumanMode, g_esGravitySpecial[iType].g_iHumanMode, g_esGravityAbility[iType].g_iHumanMode, 1);
		g_esGravityCache[tank].g_iHumanRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iHumanRangeCooldown, g_esGravityPlayer[tank].g_iHumanRangeCooldown, g_esGravitySpecial[iType].g_iHumanRangeCooldown, g_esGravityAbility[iType].g_iHumanRangeCooldown, 1);
		g_esGravityCache[tank].g_iHumanRockCooldown = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iHumanRockCooldown, g_esGravityPlayer[tank].g_iHumanRockCooldown, g_esGravitySpecial[iType].g_iHumanRockCooldown, g_esGravityAbility[iType].g_iHumanRockCooldown, 1);
		g_esGravityCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_flOpenAreasOnly, g_esGravityPlayer[tank].g_flOpenAreasOnly, g_esGravitySpecial[iType].g_flOpenAreasOnly, g_esGravityAbility[iType].g_flOpenAreasOnly, 1);
		g_esGravityCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esGravityTeammate[tank].g_iRequiresHumans, g_esGravityPlayer[tank].g_iRequiresHumans, g_esGravitySpecial[iType].g_iRequiresHumans, g_esGravityAbility[iType].g_iRequiresHumans, 1);
	}
	else
	{
		g_esGravityCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_flCloseAreasOnly, g_esGravityAbility[iType].g_flCloseAreasOnly, 1);
		g_esGravityCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iComboAbility, g_esGravityAbility[iType].g_iComboAbility, 1);
		g_esGravityCache[tank].g_flGravityChance = flGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_flGravityChance, g_esGravityAbility[iType].g_flGravityChance, 1);
		g_esGravityCache[tank].g_flGravityForce = flGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_flGravityForce, g_esGravityAbility[iType].g_flGravityForce, 2, -1.0);
		g_esGravityCache[tank].g_flGravityRadius = flGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_flGravityRadius, g_esGravityAbility[iType].g_flGravityRadius, 1);
		g_esGravityCache[tank].g_flGravityRange = flGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_flGravityRange, g_esGravityAbility[iType].g_flGravityRange, 1);
		g_esGravityCache[tank].g_flGravityRangeChance = flGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_flGravityRangeChance, g_esGravityAbility[iType].g_flGravityRangeChance, 1);
		g_esGravityCache[tank].g_flGravityRockChance = flGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_flGravityRockChance, g_esGravityAbility[iType].g_flGravityRockChance, 1);
		g_esGravityCache[tank].g_flGravityValue = flGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_flGravityValue, g_esGravityAbility[iType].g_flGravityValue, 1);
		g_esGravityCache[tank].g_iGravityAbility = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iGravityAbility, g_esGravityAbility[iType].g_iGravityAbility, 1);
		g_esGravityCache[tank].g_iGravityCooldown = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iGravityCooldown, g_esGravityAbility[iType].g_iGravityCooldown, 1);
		g_esGravityCache[tank].g_iGravityDuration = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iGravityDuration, g_esGravityAbility[iType].g_iGravityDuration, 1);
		g_esGravityCache[tank].g_iGravityEffect = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iGravityEffect, g_esGravityAbility[iType].g_iGravityEffect, 1);
		g_esGravityCache[tank].g_iGravityFlags = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iGravityFlags, g_esGravityAbility[iType].g_iGravityFlags, 1);
		g_esGravityCache[tank].g_iGravityHit = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iGravityHit, g_esGravityAbility[iType].g_iGravityHit, 1);
		g_esGravityCache[tank].g_iGravityHitMode = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iGravityHitMode, g_esGravityAbility[iType].g_iGravityHitMode, 1);
		g_esGravityCache[tank].g_iGravityMessage = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iGravityMessage, g_esGravityAbility[iType].g_iGravityMessage, 1);
		g_esGravityCache[tank].g_iGravityRangeCooldown = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iGravityRangeCooldown, g_esGravityAbility[iType].g_iGravityRangeCooldown, 1);
		g_esGravityCache[tank].g_iGravityRockBreak = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iGravityRockBreak, g_esGravityAbility[iType].g_iGravityRockBreak, 1);
		g_esGravityCache[tank].g_iGravityRockCooldown = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iGravityRockCooldown, g_esGravityAbility[iType].g_iGravityRockCooldown, 1);
		g_esGravityCache[tank].g_iGravitySight = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iGravitySight, g_esGravityAbility[iType].g_iGravitySight, 1);
		g_esGravityCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iHumanAbility, g_esGravityAbility[iType].g_iHumanAbility, 1);
		g_esGravityCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iHumanAmmo, g_esGravityAbility[iType].g_iHumanAmmo, 1);
		g_esGravityCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iHumanCooldown, g_esGravityAbility[iType].g_iHumanCooldown, 1);
		g_esGravityCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iHumanDuration, g_esGravityAbility[iType].g_iHumanDuration, 1);
		g_esGravityCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iHumanMode, g_esGravityAbility[iType].g_iHumanMode, 1);
		g_esGravityCache[tank].g_iHumanRangeCooldown = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iHumanRangeCooldown, g_esGravityAbility[iType].g_iHumanRangeCooldown, 1);
		g_esGravityCache[tank].g_iHumanRockCooldown = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iHumanRockCooldown, g_esGravityAbility[iType].g_iHumanRockCooldown, 1);
		g_esGravityCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_flOpenAreasOnly, g_esGravityAbility[iType].g_flOpenAreasOnly, 1);
		g_esGravityCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esGravityPlayer[tank].g_iRequiresHumans, g_esGravityAbility[iType].g_iRequiresHumans, 1);
	}
}

#if defined MT_ABILITIES_MAIN
void vGravityCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vGravityCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveGravity(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN
void vGravityPluginEnd()
#else
public void MT_OnPluginEnd()
#endif
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsInfected(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			vRemoveGravity(iTank);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vGravityEventFired(Event event, const char[] name)
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
			vGravityCopyStats2(iBot, iTank);
			vRemoveGravity(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vGravityReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vGravityCopyStats2(iTank, iBot);
			vRemoveGravity(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iPlayerId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iPlayerId);
		if (MT_IsTankSupported(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveGravity(iPlayer);
			vGravityReset2(iPlayer);
		}
		else if (bIsSurvivor(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vStopGravity(iPlayer);
		}
	}
	else if (StrEqual(name, "player_now_it"))
	{
		bool bExploded = event.GetBool("exploded");
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iBoomerId = event.GetInt("attacker"), iBoomer = GetClientOfUserId(iBoomerId);
		if (bIsBoomer(iBoomer) && bIsSurvivor(iSurvivor) && !bExploded)
		{
			vGravityHit(iSurvivor, iBoomer, GetRandomFloat(0.1, 100.0), g_esGravityCache[iBoomer].g_flGravityChance, g_esGravityCache[iBoomer].g_iGravityHit, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vGravityRewardSurvivor(int survivor, int &type, bool apply)
#else
public Action MT_OnRewardSurvivor(int survivor, int tank, int &type, int priority, float &duration, bool apply)
#endif
{
	if (bIsSurvivor(survivor) && apply && (type & MT_REWARD_SPEEDBOOST) && g_esGravityPlayer[survivor].g_bAffected)
	{
		vStopGravity(survivor);
	}
#if !defined MT_ABILITIES_MAIN
	return Plugin_Continue;
#endif
}

#if defined MT_ABILITIES_MAIN
void vGravityAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esGravityAbility[g_esGravityPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esGravityPlayer[tank].g_iAccessFlags)) || g_esGravityCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esGravityCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esGravityCache[tank].g_iGravityAbility > 0 && g_esGravityCache[tank].g_iComboAbility == 0)
	{
		vGravityAbility(tank, false);
		vGravityAbility(tank, true, GetRandomFloat(0.1, 100.0));
	}
}

#if defined MT_ABILITIES_MAIN
void vGravityButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esGravityCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esGravityCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esGravityPlayer[tank].g_iTankType, tank) || (g_esGravityCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esGravityCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esGravityAbility[g_esGravityPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esGravityPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		int iTime = GetTime();
		if ((button & MT_MAIN_KEY) && (g_esGravityCache[tank].g_iGravityAbility == 2 || g_esGravityCache[tank].g_iGravityAbility == 3) && g_esGravityCache[tank].g_iHumanAbility == 1)
		{
			bool bRecharging = g_esGravityPlayer[tank].g_iCooldown != -1 && g_esGravityPlayer[tank].g_iCooldown >= iTime;

			switch (g_esGravityCache[tank].g_iHumanMode)
			{
				case 0:
				{
					if (!g_esGravityPlayer[tank].g_bActivated && !bRecharging)
					{
						vGravityAbility(tank, false);
					}
					else if (g_esGravityPlayer[tank].g_bActivated)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman4");
					}
					else if (bRecharging)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman5", (g_esGravityPlayer[tank].g_iCooldown - iTime));
					}
				}
				case 1:
				{
					if (g_esGravityPlayer[tank].g_iAmmoCount < g_esGravityCache[tank].g_iHumanAmmo && g_esGravityCache[tank].g_iHumanAmmo > 0)
					{
						if (!g_esGravityPlayer[tank].g_bActivated && !bRecharging)
						{
							g_esGravityPlayer[tank].g_bActivated = true;
							g_esGravityPlayer[tank].g_iAmmoCount++;

							vGravity(tank);
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman", g_esGravityPlayer[tank].g_iAmmoCount, g_esGravityCache[tank].g_iHumanAmmo);
						}
						else if (g_esGravityPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman4");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman5", (g_esGravityPlayer[tank].g_iCooldown - iTime));
						}
					}
					else
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityAmmo");
					}
				}
			}
		}

		if ((button & MT_SUB_KEY) && (g_esGravityCache[tank].g_iGravityAbility == 1 || g_esGravityCache[tank].g_iGravityAbility == 3) && g_esGravityCache[tank].g_iHumanAbility == 1)
		{
			switch (g_esGravityPlayer[tank].g_iRangeCooldown == -1 || g_esGravityPlayer[tank].g_iRangeCooldown <= iTime)
			{
				case true: vGravityAbility(tank, true, GetRandomFloat(0.1, 100.0));
				case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman6", (g_esGravityPlayer[tank].g_iRangeCooldown - iTime));
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vGravityButtonReleased(int tank, int button)
#else
public void MT_OnButtonReleased(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility == 1)
	{
		if ((button & MT_MAIN_KEY) && g_esGravityCache[tank].g_iHumanMode == 1 && g_esGravityPlayer[tank].g_bActivated && (g_esGravityPlayer[tank].g_iCooldown == -1 || g_esGravityPlayer[tank].g_iCooldown <= GetTime()))
		{
			vGravityReset3(tank);
			vGravityReset4(tank);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vGravityChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		vRemoveGravity(tank);
	}

	vGravityReset2(tank);
}

#if defined MT_ABILITIES_MAIN
void vGravityRockBreak(int tank, int rock)
#else
public void MT_OnRockBreak(int tank, int rock)
#endif
{
	if (bIsAreaNarrow(tank, g_esGravityCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esGravityCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esGravityPlayer[tank].g_iTankType, tank) || (g_esGravityCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esGravityCache[tank].g_iRequiresHumans) || (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esGravityAbility[g_esGravityPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esGravityPlayer[tank].g_iAccessFlags)) || g_esGravityCache[tank].g_iHumanAbility == 0)))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && MT_IsCustomTankSupported(tank) && g_esGravityCache[tank].g_iGravityRockBreak == 1 && g_esGravityCache[tank].g_iComboAbility == 0)
	{
		vGravityRockBreak2(tank, rock, GetRandomFloat(0.1, 100.0));
	}
}

void vGravity(int tank, bool save = true, int rock = -1, int pos = -1)
{
	if (save && ((g_esGravityPlayer[tank].g_iCooldown != -1 && g_esGravityPlayer[tank].g_iCooldown >= GetTime()) || bIsAreaNarrow(tank, g_esGravityCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esGravityCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esGravityPlayer[tank].g_iTankType, tank) || (g_esGravityCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esGravityCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esGravityAbility[g_esGravityPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esGravityPlayer[tank].g_iAccessFlags))))
	{
		return;
	}

	float flOrigin[3], flAngles[3];
	if (save)
	{
		GetClientAbsOrigin(tank, flOrigin);
		GetClientAbsAngles(tank, flAngles);
	}
	else
	{
		GetEntPropVector(rock, Prop_Data, "m_vecOrigin", flOrigin);
		GetEntPropVector(rock, Prop_Data, "m_angRotation", flAngles);
	}

	flAngles[0] += -90.0;

	int iPointPush = CreateEntityByName("point_push");
	if (bIsValidEntity(iPointPush))
	{
		DispatchKeyValueVector(iPointPush, "origin", flOrigin);
		DispatchKeyValueVector(iPointPush, "angles", flAngles);
		DispatchKeyValueFloat(iPointPush, "magnitude", g_esGravityCache[tank].g_flGravityForce);
		DispatchKeyValueFloat(iPointPush, "radius", g_esGravityCache[tank].g_flGravityRadius);
		DispatchKeyValueInt(iPointPush, "spawnflags", g_esGravityCache[tank].g_iGravityFlags);
		vSetEntityParent(iPointPush, tank, true);
		AcceptEntityInput(iPointPush, "Enable");

		switch (save)
		{
			case true: g_esGravityPlayer[tank].g_iGravityPointPush = EntIndexToEntRef(iPointPush);
			case false:
			{
				float flDuration = (pos != -1) ? MT_GetCombinationSetting(tank, 5, pos) : float(g_esGravityCache[tank].g_iGravityDuration);
				flDuration = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility == 1) ? float(g_esGravityCache[tank].g_iHumanDuration) : flDuration;
				iPointPush = EntIndexToEntRef(iPointPush);
				vDeleteEntity(iPointPush, flDuration);
			}
		}
	}
}

void vGravityAbility(int tank, bool main, float random = 0.0, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esGravityCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esGravityCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esGravityPlayer[tank].g_iTankType, tank) || (g_esGravityCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esGravityCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esGravityAbility[g_esGravityPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esGravityPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_esGravityCache[tank].g_iGravityAbility == 1 || g_esGravityCache[tank].g_iGravityAbility == 3)
			{
				if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esGravityPlayer[tank].g_iAmmoCount2 < g_esGravityCache[tank].g_iHumanAmmo && g_esGravityCache[tank].g_iHumanAmmo > 0))
				{
					g_esGravityPlayer[tank].g_bFailed = false;
					g_esGravityPlayer[tank].g_bNoAmmo = false;

					float flTankPos[3], flSurvivorPos[3];
					GetClientAbsOrigin(tank, flTankPos);
					float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esGravityCache[tank].g_flGravityRange,
						flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 10, pos) : g_esGravityCache[tank].g_flGravityRangeChance;
					int iSurvivorCount = 0;
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esGravityPlayer[tank].g_iTankType, g_esGravityAbility[g_esGravityPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esGravityPlayer[iSurvivor].g_iImmunityFlags))
						{
							GetClientAbsOrigin(iSurvivor, flSurvivorPos);
							if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esGravityCache[tank].g_iGravitySight, .range = flRange))
							{
								vGravityHit(iSurvivor, tank, random, flChance, g_esGravityCache[tank].g_iGravityAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE, pos);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman7");
						}
					}
				}
				else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityAmmo2");
				}
			}
		}
		case false:
		{
			int iTime = GetTime();
			if (g_esGravityPlayer[tank].g_iCooldown != -1 && g_esGravityPlayer[tank].g_iCooldown >= iTime)
			{
				return;
			}

			if ((g_esGravityCache[tank].g_iGravityAbility == 2 || g_esGravityCache[tank].g_iGravityAbility == 3) && !g_esGravityPlayer[tank].g_bActivated)
			{
				if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esGravityPlayer[tank].g_iAmmoCount < g_esGravityCache[tank].g_iHumanAmmo && g_esGravityCache[tank].g_iHumanAmmo > 0))
				{
					int iDuration = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 5, pos)) : g_esGravityCache[tank].g_iGravityDuration;
					iDuration = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility == 1) ? g_esGravityCache[tank].g_iHumanDuration : iDuration;
					g_esGravityPlayer[tank].g_bActivated = true;
					g_esGravityPlayer[tank].g_iDuration = (iTime + iDuration);

					vGravity(tank);

					if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility == 1)
					{
						g_esGravityPlayer[tank].g_iAmmoCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman", g_esGravityPlayer[tank].g_iAmmoCount, g_esGravityCache[tank].g_iHumanAmmo);
					}

					if (g_esGravityCache[tank].g_iGravityMessage & MT_MESSAGE_SPECIAL)
					{
						char sTankName[64];
						MT_GetTankName(tank, sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Gravity3", sTankName);
						MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Gravity3", LANG_SERVER, sTankName);
					}
				}
				else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityAmmo");
				}
			}
		}
	}
}

void vGravityHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esGravityCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esGravityCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esGravityPlayer[tank].g_iTankType, tank) || (g_esGravityCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esGravityCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esGravityAbility[g_esGravityPlayer[tank].g_iTankTypeRecorded].g_iAccessFlags, g_esGravityPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esGravityPlayer[tank].g_iTankType, g_esGravityAbility[g_esGravityPlayer[tank].g_iTankTypeRecorded].g_iImmunityFlags, g_esGravityPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	int iTime = GetTime();
	if (((flags & MT_ATTACK_RANGE) && g_esGravityPlayer[tank].g_iRangeCooldown != -1 && g_esGravityPlayer[tank].g_iRangeCooldown >= iTime) || (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && g_esGravityPlayer[tank].g_iCooldown2 != -1 && g_esGravityPlayer[tank].g_iCooldown2 >= iTime))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor) && !MT_DoesSurvivorHaveRewardType(survivor, MT_REWARD_SPEEDBOOST))
	{
		if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE) || (g_esGravityPlayer[tank].g_iAmmoCount2 < g_esGravityCache[tank].g_iHumanAmmo && g_esGravityCache[tank].g_iHumanAmmo > 0))
		{
			if (random <= chance && !g_esGravityPlayer[survivor].g_bAffected)
			{
				if ((messages & MT_MESSAGE_MELEE) && !bIsVisibleToPlayer(tank, survivor, g_esGravityCache[tank].g_iGravitySight, .range = 100.0))
				{
					return;
				}

				g_esGravityPlayer[survivor].g_bAffected = true;
				g_esGravityPlayer[survivor].g_iOwner = tank;

				int iCooldown = -1;
				if ((flags & MT_ATTACK_RANGE) && (g_esGravityPlayer[tank].g_iRangeCooldown == -1 || g_esGravityPlayer[tank].g_iRangeCooldown <= iTime))
				{
					if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility == 1)
					{
						g_esGravityPlayer[tank].g_iAmmoCount2++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman2", g_esGravityPlayer[tank].g_iAmmoCount2, g_esGravityCache[tank].g_iHumanAmmo);
					}

					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 11, pos)) : g_esGravityCache[tank].g_iGravityRangeCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility == 1 && g_esGravityPlayer[tank].g_iAmmoCount2 < g_esGravityCache[tank].g_iHumanAmmo && g_esGravityCache[tank].g_iHumanAmmo > 0) ? g_esGravityCache[tank].g_iHumanRangeCooldown : iCooldown;
					g_esGravityPlayer[tank].g_iRangeCooldown = (iTime + iCooldown);
					if (g_esGravityPlayer[tank].g_iRangeCooldown != -1 && g_esGravityPlayer[tank].g_iRangeCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman9", (g_esGravityPlayer[tank].g_iRangeCooldown - iTime));
					}
				}
				else if (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && (g_esGravityPlayer[tank].g_iCooldown2 == -1 || g_esGravityPlayer[tank].g_iCooldown2 <= iTime))
				{
					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, pos)) : g_esGravityCache[tank].g_iGravityCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility == 1) ? g_esGravityCache[tank].g_iHumanCooldown : iCooldown;
					g_esGravityPlayer[tank].g_iCooldown2 = (iTime + iCooldown);
					if (g_esGravityPlayer[tank].g_iCooldown2 != -1 && g_esGravityPlayer[tank].g_iCooldown2 >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman9", (g_esGravityPlayer[tank].g_iCooldown2 - iTime));
					}
				}

				SetEntityGravity(survivor, g_esGravityCache[tank].g_flGravityValue);
				vScreenEffect(survivor, tank, g_esGravityCache[tank].g_iGravityEffect, flags);
				EmitSoundToAll(SOUND_BELL, survivor);

				float flDuration = (pos != -1) ? MT_GetCombinationSetting(tank, 5, pos) : float(g_esGravityCache[tank].g_iGravityDuration);
				flDuration = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility == 1) ? float(g_esGravityCache[tank].g_iHumanDuration) : flDuration;
				DataPack dpStopGravity;
				CreateDataTimer(0.1, tTimerStopGravity, dpStopGravity, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpStopGravity.WriteCell(GetClientUserId(survivor));
				dpStopGravity.WriteCell(GetClientUserId(tank));
				dpStopGravity.WriteFloat(GetGameTime());
				dpStopGravity.WriteFloat(flDuration);
				dpStopGravity.WriteCell(messages);

				if (g_esGravityCache[tank].g_iGravityMessage & messages)
				{
					char sTankName[64];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Gravity", sTankName, survivor, g_esGravityCache[tank].g_flGravityValue);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Gravity", LANG_SERVER, sTankName, survivor, g_esGravityCache[tank].g_flGravityValue);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esGravityPlayer[tank].g_iRangeCooldown == -1 || g_esGravityPlayer[tank].g_iRangeCooldown <= iTime))
			{
				if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility == 1 && !g_esGravityPlayer[tank].g_bFailed)
				{
					g_esGravityPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman3");
				}
			}
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility == 1 && !g_esGravityPlayer[tank].g_bNoAmmo)
		{
			g_esGravityPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityAmmo2");
		}
	}
}

void vGravityRockBreak2(int tank, int rock, float random, int pos = -1)
{
	float flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 14, pos) : g_esGravityCache[tank].g_flGravityRockChance;
	if (random <= flChance)
	{
		int iTime = GetTime(), iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility == 1) ? g_esGravityCache[tank].g_iHumanRockCooldown : g_esGravityCache[tank].g_iGravityRockCooldown;
		iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 15, pos)) : iCooldown;
		if (g_esGravityPlayer[tank].g_iRockCooldown == -1 || g_esGravityPlayer[tank].g_iRockCooldown <= iTime)
		{
			g_esGravityPlayer[tank].g_iRockCooldown = (iTime + iCooldown);
			if (g_esGravityPlayer[tank].g_iRockCooldown != -1 && g_esGravityPlayer[tank].g_iRockCooldown >= iTime)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman8", (g_esGravityPlayer[tank].g_iRockCooldown - iTime));
			}
		}
		else if (g_esGravityPlayer[tank].g_iRockCooldown != -1 && g_esGravityPlayer[tank].g_iRockCooldown >= iTime)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman5", (g_esGravityPlayer[tank].g_iRockCooldown - iTime));

			return;
		}

		vGravity(tank, false, rock, pos);

		if (g_esGravityCache[tank].g_iGravityMessage & MT_MESSAGE_SPECIAL)
		{
			char sTankName[64];
			MT_GetTankName(tank, sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Gravity4", sTankName);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Gravity4", LANG_SERVER, sTankName);
		}
	}
}

void vGravityCopyStats2(int oldTank, int newTank)
{
	g_esGravityPlayer[newTank].g_iAmmoCount = g_esGravityPlayer[oldTank].g_iAmmoCount;
	g_esGravityPlayer[newTank].g_iAmmoCount2 = g_esGravityPlayer[oldTank].g_iAmmoCount2;
	g_esGravityPlayer[newTank].g_iCooldown = g_esGravityPlayer[oldTank].g_iCooldown;
	g_esGravityPlayer[newTank].g_iCooldown2 = g_esGravityPlayer[oldTank].g_iCooldown2;
	g_esGravityPlayer[newTank].g_iRangeCooldown = g_esGravityPlayer[oldTank].g_iRangeCooldown;
	g_esGravityPlayer[newTank].g_iRockCooldown = g_esGravityPlayer[oldTank].g_iRockCooldown;
}

void vRemoveGravity(int tank)
{
	vRemoveGravity2(tank);

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && g_esGravityPlayer[iSurvivor].g_bAffected && g_esGravityPlayer[iSurvivor].g_iOwner == tank)
		{
			vStopGravity(iSurvivor);
		}
	}
}

void vRemoveGravity2(int tank)
{
	if (bIsValidEntRef(g_esGravityPlayer[tank].g_iGravityPointPush))
	{
		g_esGravityPlayer[tank].g_iGravityPointPush = EntRefToEntIndex(g_esGravityPlayer[tank].g_iGravityPointPush);
		if (bIsValidEntity(g_esGravityPlayer[tank].g_iGravityPointPush))
		{
			RemoveEntity(g_esGravityPlayer[tank].g_iGravityPointPush);
		}
	}

	g_esGravityPlayer[tank].g_bActivated = false;
	g_esGravityPlayer[tank].g_iGravityPointPush = INVALID_ENT_REFERENCE;
}

void vGravityReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveGravity(iPlayer);
			vGravityReset2(iPlayer);

			g_esGravityPlayer[iPlayer].g_iOwner = -1;
		}
	}
}

void vGravityReset2(int tank)
{
	g_esGravityPlayer[tank].g_bAffected = false;
	g_esGravityPlayer[tank].g_bFailed = false;
	g_esGravityPlayer[tank].g_bNoAmmo = false;
	g_esGravityPlayer[tank].g_iAmmoCount = 0;
	g_esGravityPlayer[tank].g_iAmmoCount2 = 0;
	g_esGravityPlayer[tank].g_iCooldown = -1;
	g_esGravityPlayer[tank].g_iCooldown2 = -1;
	g_esGravityPlayer[tank].g_iDuration = -1;
	g_esGravityPlayer[tank].g_iGravityPointPush = INVALID_ENT_REFERENCE;
	g_esGravityPlayer[tank].g_iRangeCooldown = -1;
	g_esGravityPlayer[tank].g_iRockCooldown = -1;
}

void vGravityReset3(int tank)
{
	g_esGravityPlayer[tank].g_bActivated = false;
	g_esGravityPlayer[tank].g_iDuration = -1;

	vRemoveGravity2(tank);

	if (g_esGravityCache[tank].g_iGravityMessage & MT_MESSAGE_SPECIAL)
	{
		char sTankName[64];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Gravity4", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Gravity4", LANG_SERVER, sTankName);
	}
}

void vGravityReset4(int tank)
{
	int iTime = GetTime(), iPos = g_esGravityAbility[g_esGravityPlayer[tank].g_iTankTypeRecorded].g_iComboPosition, iCooldown = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, iPos)) : g_esGravityCache[tank].g_iGravityCooldown;
	iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGravityCache[tank].g_iHumanAbility == 1 && g_esGravityCache[tank].g_iHumanMode == 0 && g_esGravityPlayer[tank].g_iAmmoCount < g_esGravityCache[tank].g_iHumanAmmo && g_esGravityCache[tank].g_iHumanAmmo > 0) ? g_esGravityCache[tank].g_iHumanCooldown : iCooldown;
	g_esGravityPlayer[tank].g_iCooldown = (iTime + iCooldown);
	if (g_esGravityPlayer[tank].g_iCooldown != -1 && g_esGravityPlayer[tank].g_iCooldown >= iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "GravityHuman8", (g_esGravityPlayer[tank].g_iCooldown - iTime));
	}
}

void vStopGravity(int survivor)
{
	g_esGravityPlayer[survivor].g_bAffected = false;
	g_esGravityPlayer[survivor].g_iOwner = -1;

	SetEntityGravity(survivor, 1.0);
}

void tTimerGravityCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esGravityAbility[g_esGravityPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esGravityPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esGravityPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esGravityCache[iTank].g_iGravityAbility == 0 || g_esGravityCache[iTank].g_iGravityAbility == 2)
	{
		return;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vGravityAbility(iTank, true, flRandom, iPos);
}

void tTimerGravityCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esGravityAbility[g_esGravityPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esGravityPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esGravityPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esGravityCache[iTank].g_iGravityAbility == 0 || g_esGravityCache[iTank].g_iGravityAbility == 1)
	{
		return;
	}

	int iPos = pack.ReadCell();
	vGravityAbility(iTank, false, .pos = iPos);
}

void tTimerGravityCombo3(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || g_esGravityPlayer[iSurvivor].g_bAffected)
	{
		return;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esGravityAbility[g_esGravityPlayer[iTank].g_iTankTypeRecorded].g_iAccessFlags, g_esGravityPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esGravityPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esGravityCache[iTank].g_iGravityHit == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	int iPos = pack.ReadCell();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof sClassname);
	if ((g_esGravityCache[iTank].g_iGravityHitMode == 0 || g_esGravityCache[iTank].g_iGravityHitMode == 1) && (bIsSpecialInfected(iTank) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vGravityHit(iSurvivor, iTank, flRandom, flChance, g_esGravityCache[iTank].g_iGravityHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW, iPos);
	}
	else if ((g_esGravityCache[iTank].g_iGravityHitMode == 0 || g_esGravityCache[iTank].g_iGravityHitMode == 2) && StrEqual(sClassname[7], "melee"))
	{
		vGravityHit(iSurvivor, iTank, flRandom, flChance, g_esGravityCache[iTank].g_iGravityHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE, iPos);
	}
}

Action tTimerStopGravity(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_esGravityPlayer[iSurvivor].g_bAffected = false;
		g_esGravityPlayer[iSurvivor].g_iOwner = -1;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || !MT_IsCustomTankSupported(iTank) || !g_esGravityPlayer[iSurvivor].g_bAffected)
	{
		vStopGravity(iSurvivor);

		return Plugin_Stop;
	}

	float flCurrentTime = pack.ReadFloat(), flDuration = pack.ReadFloat();
	int iMessage = pack.ReadCell();
	if ((flCurrentTime + flDuration) < GetGameTime())
	{
		vStopGravity(iSurvivor);

		if (g_esGravityCache[iTank].g_iGravityMessage & iMessage)
		{
			MT_PrintToChatAll("%s %t", MT_TAG2, "Gravity2", iSurvivor);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Gravity2", LANG_SERVER, iSurvivor);
		}

		return Plugin_Stop;
	}

	switch (bIsVisibleToPlayer(iTank, iSurvivor, g_esGravityCache[iTank].g_iGravitySight))
	{
		case true: SetEntityGravity(iSurvivor, g_esGravityCache[iTank].g_flGravityValue);
		case false: SetEntityGravity(iSurvivor, 1.0);
	}

	return Plugin_Continue;
}