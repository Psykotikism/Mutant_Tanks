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

#define MT_GHOST_COMPILE_METHOD 0 // 0: packaged, 1: standalone

#if !defined MT_ABILITIES_MAIN
	#if MT_GHOST_COMPILE_METHOD == 1
		#include <sourcemod>
		#include <mutant_tanks>
	#else
		#error This file must be inside "scripting/mutant_tanks/abilities" while compiling "mt_abilities.sp" to include its content.
	#endif
public Plugin myinfo =
{
	name = "[MT] Ghost Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank cloaks itself and disarms survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bDedicated, g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "\"[MT] Ghost Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bDedicated = IsDedicatedServer();
	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_CONCRETE_CHUNK "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_OXYGENTANK "models/props_equipment/oxygentank01.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_TANK_MAIN "models/infected/hulk.mdl"
#define MODEL_TANK_DLC "models/infected/hulk_dlc3.mdl"
#define MODEL_TANK_L4D1 "models/infected/hulk_l4d1.mdl"
#define MODEL_TIRES "models/props_vehicles/tire001c_car.mdl"
#define MODEL_TREE_TRUNK "models/props_foliage/tree_trunk.mdl"

#define SOUND_DEATH "npc/infected/action/die/male/death_42.wav"
#define SOUND_DEATH2 "npc/infected/action/die/male/death_43.wav"
#else
	#if MT_GHOST_COMPILE_METHOD == 1
		#error This file must be compiled as a standalone plugin.
	#endif
#endif

#define MT_GHOST_SECTION "ghostability"
#define MT_GHOST_SECTION2 "ghost ability"
#define MT_GHOST_SECTION3 "ghost_ability"
#define MT_GHOST_SECTION4 "ghost"

#define MT_MENU_GHOST "Ghost Ability"

enum struct esGhostPlayer
{
	bool g_bActivated;
	bool g_bActivated2;
	bool g_bAffected[MAXPLAYERS + 1];
	bool g_bFailed;
	bool g_bNoAmmo;
	bool g_bPhased;

	float g_flCloseAreasOnly;
	float g_flGhostChance;
	float g_flGhostFadeRate;
	float g_flGhostRange;
	float g_flGhostRangeChance;
	float g_flGhostSpecialsChance;
	float g_flGhostSpecialsRange;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iAmmoCount2;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iCooldown2;
	int g_iDuration;
	int g_iGhostAbility;
	int g_iGhostAlpha;
	int g_iGhostCooldown;
	int g_iGhostDuration;
	int g_iGhostEffect;
	int g_iGhostFadeAlpha;
	int g_iGhostFadeDelay;
	int g_iGhostFadeLimit;
	int g_iGhostFadePhase;
	int g_iGhostHit;
	int g_iGhostHitMode;
	int g_iGhostMessage;
	int g_iGhostRangeCooldown;
	int g_iGhostSight;
	int g_iGhostSpecials;
	int g_iGhostWeaponSlots;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iInfectedType;
	int g_iRangeCooldown;
	int g_iRequiresHumans;
	int g_iTankType;
}

esGhostPlayer g_esGhostPlayer[MAXPLAYERS + 1];

enum struct esGhostTeammate
{
	float g_flCloseAreasOnly;
	float g_flGhostChance;
	float g_flGhostFadeRate;
	float g_flGhostRange;
	float g_flGhostRangeChance;
	float g_flGhostSpecialsChance;
	float g_flGhostSpecialsRange;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iGhostAbility;
	int g_iGhostAlpha;
	int g_iGhostCooldown;
	int g_iGhostDuration;
	int g_iGhostEffect;
	int g_iGhostFadeAlpha;
	int g_iGhostFadeDelay;
	int g_iGhostFadeLimit;
	int g_iGhostFadePhase;
	int g_iGhostHit;
	int g_iGhostHitMode;
	int g_iGhostMessage;
	int g_iGhostRangeCooldown;
	int g_iGhostSight;
	int g_iGhostSpecials;
	int g_iGhostWeaponSlots;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
}

esGhostTeammate g_esGhostTeammate[MAXPLAYERS + 1][6];

enum struct esGhostAbility
{
	float g_flCloseAreasOnly;
	float g_flGhostChance;
	float g_flGhostFadeRate;
	float g_flGhostRange;
	float g_flGhostRangeChance;
	float g_flGhostSpecialsChance;
	float g_flGhostSpecialsRange;
	float g_flOpenAreasOnly;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iComboPosition;
	int g_iGhostAbility;
	int g_iGhostCooldown;
	int g_iGhostDuration;
	int g_iGhostEffect;
	int g_iGhostFadeAlpha;
	int g_iGhostFadeDelay;
	int g_iGhostFadeLimit;
	int g_iGhostFadePhase;
	int g_iGhostHit;
	int g_iGhostHitMode;
	int g_iGhostMessage;
	int g_iGhostRangeCooldown;
	int g_iGhostSight;
	int g_iGhostSpecials;
	int g_iGhostWeaponSlots;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRangeCooldown;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esGhostAbility g_esGhostAbility[MT_MAXTYPES + 1];

enum struct esGhostSpecial
{
	float g_flCloseAreasOnly;
	float g_flGhostChance;
	float g_flGhostFadeRate;
	float g_flGhostRange;
	float g_flGhostRangeChance;
	float g_flGhostSpecialsChance;
	float g_flGhostSpecialsRange;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iGhostAbility;
	int g_iGhostCooldown;
	int g_iGhostDuration;
	int g_iGhostEffect;
	int g_iGhostFadeAlpha;
	int g_iGhostFadeDelay;
	int g_iGhostFadeLimit;
	int g_iGhostFadePhase;
	int g_iGhostHit;
	int g_iGhostHitMode;
	int g_iGhostMessage;
	int g_iGhostRangeCooldown;
	int g_iGhostSight;
	int g_iGhostSpecials;
	int g_iGhostWeaponSlots;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
}

esGhostSpecial g_esGhostSpecial[MT_MAXTYPES + 1][6];

enum struct esGhostCache
{
	float g_flCloseAreasOnly;
	float g_flGhostChance;
	float g_flGhostFadeRate;
	float g_flGhostRange;
	float g_flGhostRangeChance;
	float g_flGhostSpecialsChance;
	float g_flGhostSpecialsRange;
	float g_flOpenAreasOnly;

	int g_iComboAbility;
	int g_iGhostAbility;
	int g_iGhostCooldown;
	int g_iGhostDuration;
	int g_iGhostEffect;
	int g_iGhostFadeAlpha;
	int g_iGhostFadeDelay;
	int g_iGhostFadeLimit;
	int g_iGhostFadePhase;
	int g_iGhostHit;
	int g_iGhostHitMode;
	int g_iGhostMessage;
	int g_iGhostRangeCooldown;
	int g_iGhostSight;
	int g_iGhostSpecials;
	int g_iGhostWeaponSlots;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iHumanRangeCooldown;
	int g_iRequiresHumans;
}

esGhostCache g_esGhostCache[MAXPLAYERS + 1];

#if !defined MT_ABILITIES_MAIN
public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");
	LoadTranslations("mutant_tanks_names.phrases");

	RegConsoleCmd("sm_mt_ghost", cmdGhostInfo, "View information about the Ghost ability.");

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
void vGhostMapStart()
#else
public void OnMapStart()
#endif
{
	PrecacheSound(SOUND_DEATH, true);
	PrecacheSound(SOUND_DEATH2, true);

	vGhostReset();
}

#if defined MT_ABILITIES_MAIN
void vGhostClientPutInServer(int client)
#else
public void OnClientPutInServer(int client)
#endif
{
	SDKHook(client, SDKHook_OnTakeDamage, OnGhostTakeDamage);
	vRemoveGhost(client);
}

#if defined MT_ABILITIES_MAIN
void vGhostClientDisconnect_Post(int client)
#else
public void OnClientDisconnect_Post(int client)
#endif
{
	vRemoveGhost(client);
}

#if defined MT_ABILITIES_MAIN
void vGhostMapEnd()
#else
public void OnMapEnd()
#endif
{
	vGhostReset();
}

#if !defined MT_ABILITIES_MAIN
Action cmdGhostInfo(int client, int args)
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
		case false: vGhostMenu(client, MT_GHOST_SECTION4, 0);
	}

	return Plugin_Handled;
}
#endif

void vGhostMenu(int client, const char[] name, int item)
{
	if (StrContains(MT_GHOST_SECTION4, name, false) == -1)
	{
		return;
	}

	Menu mAbilityMenu = new Menu(iGhostMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Ghost Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Button Mode", "Button Mode");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.AddItem("Range Cooldown", "Range Cooldown");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

int iGhostMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esGhostCache[param1].g_iGhostAbility == 0) ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", (g_esGhostCache[param1].g_iHumanAmmo - g_esGhostPlayer[param1].g_iAmmoCount), g_esGhostCache[param1].g_iHumanAmmo);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", (g_esGhostCache[param1].g_iHumanAmmo - g_esGhostPlayer[param1].g_iAmmoCount2), g_esGhostCache[param1].g_iHumanAmmo);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esGhostCache[param1].g_iHumanMode == 0) ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", ((g_esGhostCache[param1].g_iHumanAbility == 1) ? g_esGhostCache[param1].g_iHumanCooldown : g_esGhostCache[param1].g_iGhostCooldown));
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "GhostDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", ((g_esGhostCache[param1].g_iHumanAbility == 1) ? g_esGhostCache[param1].g_iHumanDuration : g_esGhostCache[param1].g_iGhostDuration));
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, (g_esGhostCache[param1].g_iHumanAbility == 0) ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
				case 8: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityRangeCooldown", ((g_esGhostCache[param1].g_iHumanAbility == 1) ? g_esGhostCache[param1].g_iHumanRangeCooldown : g_esGhostCache[param1].g_iGhostRangeCooldown));
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vGhostMenu(param1, MT_GHOST_SECTION4, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pGhost = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof sMenuTitle, "%T", "GhostMenu", param1);
			pGhost.SetTitle(sMenuTitle);
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
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

#if defined MT_ABILITIES_MAIN
void vGhostDisplayMenu(Menu menu)
#else
public void MT_OnDisplayMenu(Menu menu)
#endif
{
	menu.AddItem(MT_MENU_GHOST, MT_MENU_GHOST);
}

#if defined MT_ABILITIES_MAIN
void vGhostMenuItemSelected(int client, const char[] info)
#else
public void MT_OnMenuItemSelected(int client, const char[] info)
#endif
{
	if (StrEqual(info, MT_MENU_GHOST, false))
	{
		vGhostMenu(client, MT_GHOST_SECTION4, 0);
	}
}

#if defined MT_ABILITIES_MAIN
void vGhostMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#else
public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
#endif
{
	if (StrEqual(info, MT_MENU_GHOST, false))
	{
		FormatEx(buffer, size, "%T", "GhostMenu2", client);
	}
}

#if defined MT_ABILITIES_MAIN
void vGhostPlayerRunCmd(int client)
#else
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
#endif
{
	if (!MT_IsTankSupported(client) || !g_esGhostPlayer[client].g_bActivated2 || g_esGhostPlayer[client].g_iDuration == -1)
	{
#if defined MT_ABILITIES_MAIN
		return;
#else
		return Plugin_Continue;
#endif
	}

	int iTime = GetTime();
	if (g_esGhostPlayer[client].g_iDuration <= iTime)
	{
		if (g_esGhostCache[client].g_iGhostMessage & MT_MESSAGE_SPECIAL)
		{
			char sTankName[33];
			MT_GetTankName(client, sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Ghost3", sTankName);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Ghost3", LANG_SERVER, sTankName);
		}

		g_esGhostPlayer[client].g_bActivated2 = false;
		g_esGhostPlayer[client].g_bPhased = true;
		g_esGhostPlayer[client].g_iDuration = -1;
		g_esGhostPlayer[client].g_iGhostAlpha = 255;

		vGhostResetRender(client);
	}
#if !defined MT_ABILITIES_MAIN
	return Plugin_Continue;
#endif
}

Action OnGhostTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage > 0.0)
	{
		char sClassname[32];
		if (bIsValidEntity(inflictor))
		{
			GetEntityClassname(inflictor, sClassname, sizeof sClassname);
		}

		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esGhostCache[attacker].g_iGhostHitMode == 0 || g_esGhostCache[attacker].g_iGhostHitMode == 1) && bIsSurvivor(victim) && g_esGhostCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esGhostAbility[g_esGhostPlayer[attacker].g_iTankType].g_iAccessFlags, g_esGhostPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esGhostPlayer[attacker].g_iTankType, g_esGhostAbility[g_esGhostPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esGhostPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			bool bCaught = bIsSurvivorCaught(victim);
			if ((bIsSpecialInfected(attacker) && (bCaught || (!bCaught && (damagetype & DMG_CLUB)) || (bIsSpitter(attacker) && StrEqual(sClassname, "insect_swarm")))) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vGhostHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esGhostCache[attacker].g_flGhostChance, g_esGhostCache[attacker].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && bIsSurvivor(attacker))
		{
			if ((g_esGhostCache[victim].g_iGhostHitMode == 0 || g_esGhostCache[victim].g_iGhostHitMode == 2) && g_esGhostCache[victim].g_iComboAbility == 0)
			{
				if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esGhostAbility[g_esGhostPlayer[victim].g_iTankType].g_iAccessFlags, g_esGhostPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esGhostPlayer[victim].g_iTankType, g_esGhostAbility[g_esGhostPlayer[victim].g_iTankType].g_iImmunityFlags, g_esGhostPlayer[attacker].g_iImmunityFlags))
				{
					return Plugin_Continue;
				}

				if (StrEqual(sClassname[7], "melee"))
				{
					vGhostHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esGhostCache[victim].g_flGhostChance, g_esGhostCache[victim].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
				}
			}

			if (g_esGhostCache[victim].g_iGhostFadePhase == 1 && g_esGhostPlayer[victim].g_bPhased)
			{
				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

#if defined MT_ABILITIES_MAIN
void vGhostPluginCheck(ArrayList list)
#else
public void MT_OnPluginCheck(ArrayList list)
#endif
{
	list.PushString(MT_MENU_GHOST);
}

#if defined MT_ABILITIES_MAIN
void vGhostAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#else
public void MT_OnAbilityCheck(ArrayList list, ArrayList list2, ArrayList list3, ArrayList list4)
#endif
{
	list.PushString(MT_GHOST_SECTION);
	list2.PushString(MT_GHOST_SECTION2);
	list3.PushString(MT_GHOST_SECTION3);
	list4.PushString(MT_GHOST_SECTION4);
}

#if defined MT_ABILITIES_MAIN
void vGhostCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, const char[] classname)
#else
public void MT_OnCombineAbilities(int tank, int type, const float random, const char[] combo, int survivor, int weapon, const char[] classname)
#endif
{
	if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGhostCache[tank].g_iHumanAbility != 2)
	{
		g_esGhostAbility[g_esGhostPlayer[tank].g_iTankType].g_iComboPosition = -1;

		return;
	}

	g_esGhostAbility[g_esGhostPlayer[tank].g_iTankType].g_iComboPosition = -1;

	char sCombo[320], sSet[4][32];
	FormatEx(sCombo, sizeof sCombo, ",%s,", combo);
	FormatEx(sSet[0], sizeof sSet[], ",%s,", MT_GHOST_SECTION);
	FormatEx(sSet[1], sizeof sSet[], ",%s,", MT_GHOST_SECTION2);
	FormatEx(sSet[2], sizeof sSet[], ",%s,", MT_GHOST_SECTION3);
	FormatEx(sSet[3], sizeof sSet[], ",%s,", MT_GHOST_SECTION4);
	if (g_esGhostCache[tank].g_iComboAbility == 1 && (StrContains(sCombo, sSet[0], false) != -1 || StrContains(sCombo, sSet[1], false) != -1 || StrContains(sCombo, sSet[2], false) != -1 || StrContains(sCombo, sSet[3], false) != -1))
	{
		char sAbilities[320], sSubset[10][32];
		strcopy(sAbilities, sizeof sAbilities, combo);
		ExplodeString(sAbilities, ",", sSubset, sizeof sSubset, sizeof sSubset[]);

		float flChance = 0.0, flDelay = 0.0;
		for (int iPos = 0; iPos < (sizeof sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_GHOST_SECTION, false) || StrEqual(sSubset[iPos], MT_GHOST_SECTION2, false) || StrEqual(sSubset[iPos], MT_GHOST_SECTION3, false) || StrEqual(sSubset[iPos], MT_GHOST_SECTION4, false))
			{
				g_esGhostAbility[g_esGhostPlayer[tank].g_iTankType].g_iComboPosition = iPos;
				flDelay = MT_GetCombinationSetting(tank, 4, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esGhostCache[tank].g_iGhostAbility == 1 || g_esGhostCache[tank].g_iGhostAbility == 3)
						{
							switch (flDelay)
							{
								case 0.0: vGhostAbility(tank, true, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerGhostCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteFloat(random);
									dpCombo.WriteCell(iPos);
								}
							}
						}

						if (g_esGhostCache[tank].g_iGhostAbility == 2 || g_esGhostCache[tank].g_iGhostAbility == 3)
						{
							switch (flDelay)
							{
								case 0.0: vGhostAbility(tank, false, .pos = iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerGhostCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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
								if ((g_esGhostCache[tank].g_iGhostHitMode == 0 || g_esGhostCache[tank].g_iGhostHitMode == 1) && (StrEqual(classname[7], "tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vGhostHit(survivor, tank, random, flChance, g_esGhostCache[tank].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
								}
								else if ((g_esGhostCache[tank].g_iGhostHitMode == 0 || g_esGhostCache[tank].g_iGhostHitMode == 2) && StrEqual(classname[7], "melee"))
								{
									vGhostHit(survivor, tank, random, flChance, g_esGhostCache[tank].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerGhostCombo3, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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
void vGhostConfigsLoad(int mode)
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
				g_esGhostAbility[iIndex].g_iAccessFlags = 0;
				g_esGhostAbility[iIndex].g_iImmunityFlags = 0;
				g_esGhostAbility[iIndex].g_flCloseAreasOnly = 0.0;
				g_esGhostAbility[iIndex].g_iComboAbility = 0;
				g_esGhostAbility[iIndex].g_iComboPosition = -1;
				g_esGhostAbility[iIndex].g_iHumanAbility = 0;
				g_esGhostAbility[iIndex].g_iHumanAmmo = 5;
				g_esGhostAbility[iIndex].g_iHumanCooldown = 0;
				g_esGhostAbility[iIndex].g_iHumanDuration = 5;
				g_esGhostAbility[iIndex].g_iHumanMode = 1;
				g_esGhostAbility[iIndex].g_iHumanRangeCooldown = 0;
				g_esGhostAbility[iIndex].g_flOpenAreasOnly = 0.0;
				g_esGhostAbility[iIndex].g_iRequiresHumans = 0;
				g_esGhostAbility[iIndex].g_iGhostAbility = 0;
				g_esGhostAbility[iIndex].g_iGhostEffect = 0;
				g_esGhostAbility[iIndex].g_iGhostMessage = 0;
				g_esGhostAbility[iIndex].g_flGhostChance = 33.3;
				g_esGhostAbility[iIndex].g_iGhostCooldown = 0;
				g_esGhostAbility[iIndex].g_iGhostDuration = 0;
				g_esGhostAbility[iIndex].g_iGhostFadeAlpha = 2;
				g_esGhostAbility[iIndex].g_iGhostFadeDelay = 5;
				g_esGhostAbility[iIndex].g_iGhostFadeLimit = 0;
				g_esGhostAbility[iIndex].g_iGhostFadePhase = 0;
				g_esGhostAbility[iIndex].g_flGhostFadeRate = 0.1;
				g_esGhostAbility[iIndex].g_iGhostHit = 0;
				g_esGhostAbility[iIndex].g_iGhostHitMode = 0;
				g_esGhostAbility[iIndex].g_flGhostRange = 150.0;
				g_esGhostAbility[iIndex].g_flGhostRangeChance = 15.0;
				g_esGhostAbility[iIndex].g_iGhostRangeCooldown = 0;
				g_esGhostAbility[iIndex].g_iGhostSight = 0;
				g_esGhostAbility[iIndex].g_iGhostSpecials = 1;
				g_esGhostAbility[iIndex].g_flGhostSpecialsChance = 33.3;
				g_esGhostAbility[iIndex].g_flGhostSpecialsRange = 500.0;
				g_esGhostAbility[iIndex].g_iGhostWeaponSlots = 0;

				for (int iSpecType = 0; iSpecType < 6; iSpecType++)
				{
					g_esGhostSpecial[iIndex][iSpecType].g_flCloseAreasOnly = -1.0;
					g_esGhostSpecial[iIndex][iSpecType].g_iComboAbility = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iHumanAbility = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iHumanAmmo = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iHumanCooldown = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iHumanDuration = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iHumanMode = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iHumanRangeCooldown = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_flOpenAreasOnly = -1.0;
					g_esGhostSpecial[iIndex][iSpecType].g_iRequiresHumans = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iGhostAbility = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iGhostEffect = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iGhostMessage = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_flGhostChance = -1.0;
					g_esGhostSpecial[iIndex][iSpecType].g_iGhostCooldown = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iGhostDuration = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iGhostFadeAlpha = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iGhostFadeDelay = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iGhostFadeLimit = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iGhostFadePhase = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_flGhostFadeRate = -1.0;
					g_esGhostSpecial[iIndex][iSpecType].g_iGhostHit = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iGhostHitMode = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_flGhostRange = -1.0;
					g_esGhostSpecial[iIndex][iSpecType].g_flGhostRangeChance = -1.0;
					g_esGhostSpecial[iIndex][iSpecType].g_iGhostRangeCooldown = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iGhostSight = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_iGhostSpecials = -1;
					g_esGhostSpecial[iIndex][iSpecType].g_flGhostSpecialsChance = -1.0;
					g_esGhostSpecial[iIndex][iSpecType].g_flGhostSpecialsRange = -1.0;
					g_esGhostSpecial[iIndex][iSpecType].g_iGhostWeaponSlots = -1;
				}
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				g_esGhostPlayer[iPlayer].g_iAccessFlags = -1;
				g_esGhostPlayer[iPlayer].g_iImmunityFlags = -1;
				g_esGhostPlayer[iPlayer].g_flCloseAreasOnly = -1.0;
				g_esGhostPlayer[iPlayer].g_iComboAbility = -1;
				g_esGhostPlayer[iPlayer].g_iHumanAbility = -1;
				g_esGhostPlayer[iPlayer].g_iHumanAmmo = -1;
				g_esGhostPlayer[iPlayer].g_iHumanCooldown = -1;
				g_esGhostPlayer[iPlayer].g_iHumanDuration = -1;
				g_esGhostPlayer[iPlayer].g_iHumanMode = -1;
				g_esGhostPlayer[iPlayer].g_iHumanRangeCooldown = -1;
				g_esGhostPlayer[iPlayer].g_flOpenAreasOnly = -1.0;
				g_esGhostPlayer[iPlayer].g_iRequiresHumans = -1;
				g_esGhostPlayer[iPlayer].g_iGhostAbility = -1;
				g_esGhostPlayer[iPlayer].g_iGhostEffect = -1;
				g_esGhostPlayer[iPlayer].g_iGhostMessage = -1;
				g_esGhostPlayer[iPlayer].g_flGhostChance = -1.0;
				g_esGhostPlayer[iPlayer].g_iGhostCooldown = -1;
				g_esGhostPlayer[iPlayer].g_iGhostDuration = -1;
				g_esGhostPlayer[iPlayer].g_iGhostFadeAlpha = -1;
				g_esGhostPlayer[iPlayer].g_iGhostFadeDelay = -1;
				g_esGhostPlayer[iPlayer].g_iGhostFadeLimit = -1;
				g_esGhostPlayer[iPlayer].g_iGhostFadePhase = -1;
				g_esGhostPlayer[iPlayer].g_flGhostFadeRate = -1.0;
				g_esGhostPlayer[iPlayer].g_iGhostHit = -1;
				g_esGhostPlayer[iPlayer].g_iGhostHitMode = -1;
				g_esGhostPlayer[iPlayer].g_flGhostRange = -1.0;
				g_esGhostPlayer[iPlayer].g_flGhostRangeChance = -1.0;
				g_esGhostPlayer[iPlayer].g_iGhostRangeCooldown = -1;
				g_esGhostPlayer[iPlayer].g_iGhostSight = -1;
				g_esGhostPlayer[iPlayer].g_iGhostSpecials = -1;
				g_esGhostPlayer[iPlayer].g_flGhostSpecialsChance = -1.0;
				g_esGhostPlayer[iPlayer].g_flGhostSpecialsRange = -1.0;
				g_esGhostPlayer[iPlayer].g_iGhostWeaponSlots = -1;

				for (int iSpecType = 0; iSpecType < 6; iSpecType++)
				{
					g_esGhostTeammate[iPlayer][iSpecType].g_flCloseAreasOnly = -1.0;
					g_esGhostTeammate[iPlayer][iSpecType].g_iComboAbility = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iHumanAbility = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iHumanAmmo = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iHumanCooldown = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iHumanDuration = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iHumanMode = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iHumanRangeCooldown = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_flOpenAreasOnly = -1.0;
					g_esGhostTeammate[iPlayer][iSpecType].g_iRequiresHumans = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iGhostAbility = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iGhostEffect = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iGhostMessage = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_flGhostChance = -1.0;
					g_esGhostTeammate[iPlayer][iSpecType].g_iGhostCooldown = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iGhostDuration = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iGhostFadeAlpha = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iGhostFadeDelay = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iGhostFadeLimit = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iGhostFadePhase = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_flGhostFadeRate = -1.0;
					g_esGhostTeammate[iPlayer][iSpecType].g_iGhostHit = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iGhostHitMode = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_flGhostRange = -1.0;
					g_esGhostTeammate[iPlayer][iSpecType].g_flGhostRangeChance = -1.0;
					g_esGhostTeammate[iPlayer][iSpecType].g_iGhostRangeCooldown = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iGhostSight = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_iGhostSpecials = -1;
					g_esGhostTeammate[iPlayer][iSpecType].g_flGhostSpecialsChance = -1.0;
					g_esGhostTeammate[iPlayer][iSpecType].g_flGhostSpecialsRange = -1.0;
					g_esGhostTeammate[iPlayer][iSpecType].g_iGhostWeaponSlots = -1;
				}
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vGhostConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection, const char[] specName, int specType)
#else
public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode, bool special, const char[] specsection, const char[] specName, int specType)
#endif
{
	if ((mode == -1 || mode == 3) && bIsValidClient(admin))
	{
		if (special && specsection[0] != '\0')
		{
			g_esGhostTeammate[admin][specType].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esGhostTeammate[admin][specType].g_flCloseAreasOnly, value, -1.0, 99999.0, specName, specType);
			g_esGhostTeammate[admin][specType].g_iComboAbility = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esGhostTeammate[admin][specType].g_iComboAbility, value, -1, 1, specName, specType);
			g_esGhostTeammate[admin][specType].g_iHumanAbility = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esGhostTeammate[admin][specType].g_iHumanAbility, value, -1, 2, specName, specType);
			g_esGhostTeammate[admin][specType].g_iHumanAmmo = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esGhostTeammate[admin][specType].g_iHumanAmmo, value, -1, 99999, specName, specType);
			g_esGhostTeammate[admin][specType].g_iHumanCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esGhostTeammate[admin][specType].g_iHumanCooldown, value, -1, 99999, specName, specType);
			g_esGhostTeammate[admin][specType].g_iHumanDuration = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esGhostTeammate[admin][specType].g_iHumanDuration, value, -1, 99999, specName, specType);
			g_esGhostTeammate[admin][specType].g_iHumanMode = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esGhostTeammate[admin][specType].g_iHumanMode, value, -1, 1, specName, specType);
			g_esGhostTeammate[admin][specType].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esGhostTeammate[admin][specType].g_iHumanRangeCooldown, value, -1, 99999, specName, specType);
			g_esGhostTeammate[admin][specType].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esGhostTeammate[admin][specType].g_flOpenAreasOnly, value, -1.0, 99999.0, specName, specType);
			g_esGhostTeammate[admin][specType].g_iRequiresHumans = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esGhostTeammate[admin][specType].g_iRequiresHumans, value, -1, 32, specName, specType);
			g_esGhostTeammate[admin][specType].g_iGhostAbility = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esGhostTeammate[admin][specType].g_iGhostAbility, value, -1, 3, specName, specType);
			g_esGhostTeammate[admin][specType].g_iGhostEffect = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esGhostTeammate[admin][specType].g_iGhostEffect, value, -1, 7, specName, specType);
			g_esGhostTeammate[admin][specType].g_iGhostMessage = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esGhostTeammate[admin][specType].g_iGhostMessage, value, -1, 7, specName, specType);
			g_esGhostTeammate[admin][specType].g_iGhostSight = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esGhostTeammate[admin][specType].g_iGhostSight, value, -1, 2, specName, specType);
			g_esGhostTeammate[admin][specType].g_flGhostChance = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostChance", "Ghost Chance", "Ghost_Chance", "chance", g_esGhostTeammate[admin][specType].g_flGhostChance, value, -1.0, 100.0, specName, specType);
			g_esGhostTeammate[admin][specType].g_iGhostCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostCooldown", "Ghost Cooldown", "Ghost_Cooldown", "cooldown", g_esGhostTeammate[admin][specType].g_iGhostCooldown, value, -1, 99999, specName, specType);
			g_esGhostTeammate[admin][specType].g_iGhostDuration = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostDuration", "Ghost Duration", "Ghost_Duration", "duration", g_esGhostTeammate[admin][specType].g_iGhostDuration, value, -1, 99999, specName, specType);
			g_esGhostTeammate[admin][specType].g_iGhostFadeAlpha = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeAlpha", "Ghost Fade Alpha", "Ghost_Fade_Alpha", "fadealpha", g_esGhostTeammate[admin][specType].g_iGhostFadeAlpha, value, -1, 255, specName, specType);
			g_esGhostTeammate[admin][specType].g_iGhostFadeDelay = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeDelay", "Ghost Fade Delay", "Ghost_Fade_Delay", "fadedelay", g_esGhostTeammate[admin][specType].g_iGhostFadeDelay, value, -1, 99999, specName, specType);
			g_esGhostTeammate[admin][specType].g_iGhostFadeLimit = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeLimit", "Ghost Fade Limit", "Ghost_Fade_Limit", "fadelimit", g_esGhostTeammate[admin][specType].g_iGhostFadeLimit, value, -1, 255, specName, specType);
			g_esGhostTeammate[admin][specType].g_iGhostFadePhase = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadePhase", "Ghost Fade Phase", "Ghost_Fade_Phase", "fadephase", g_esGhostTeammate[admin][specType].g_iGhostFadePhase, value, -1, 1, specName, specType);
			g_esGhostTeammate[admin][specType].g_flGhostFadeRate = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeRate", "Ghost Fade Rate", "Ghost_Fade_Rate", "faderate", g_esGhostTeammate[admin][specType].g_flGhostFadeRate, value, -1.0, 99999.0, specName, specType);
			g_esGhostTeammate[admin][specType].g_iGhostHit = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostHit", "Ghost Hit", "Ghost_Hit", "hit", g_esGhostTeammate[admin][specType].g_iGhostHit, value, -1, 1, specName, specType);
			g_esGhostTeammate[admin][specType].g_iGhostHitMode = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostHitMode", "Ghost Hit Mode", "Ghost_Hit_Mode", "hitmode", g_esGhostTeammate[admin][specType].g_iGhostHitMode, value, -1, 2, specName, specType);
			g_esGhostTeammate[admin][specType].g_flGhostRange = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostRange", "Ghost Range", "Ghost_Range", "range", g_esGhostTeammate[admin][specType].g_flGhostRange, value, -1.0, 99999.0, specName, specType);
			g_esGhostTeammate[admin][specType].g_flGhostRangeChance = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostRangeChance", "Ghost Range Chance", "Ghost_Range_Chance", "rangechance", g_esGhostTeammate[admin][specType].g_flGhostRangeChance, value, -1.0, 100.0, specName, specType);
			g_esGhostTeammate[admin][specType].g_iGhostRangeCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostRangeCooldown", "Ghost Range Cooldown", "Ghost_Range_Cooldown", "rangecooldown", g_esGhostTeammate[admin][specType].g_iGhostRangeCooldown, value, -1, 99999, specName, specType);
			g_esGhostTeammate[admin][specType].g_iGhostSpecials = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostSpecials", "Ghost Specials", "Ghost_Specials", "specials", g_esGhostTeammate[admin][specType].g_iGhostSpecials, value, -1, 1, specName, specType);
			g_esGhostTeammate[admin][specType].g_flGhostSpecialsChance = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostSpecialsChance", "Ghost Specials Chance", "Ghost_Specials_Chance", "specialschance", g_esGhostTeammate[admin][specType].g_flGhostSpecialsChance, value, -1.0, 100.0, specName, specType);
			g_esGhostTeammate[admin][specType].g_flGhostSpecialsRange = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostSpecialsRange", "Ghost Specials Range", "Ghost_Specials_Range", "specialsrange", g_esGhostTeammate[admin][specType].g_flGhostSpecialsRange, value, -1.0, 99999.0, specName, specType);
			g_esGhostTeammate[admin][specType].g_iGhostWeaponSlots = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostWeaponSlots", "Ghost Weapon Slots", "Ghost_Weapon_Slots", "slots", g_esGhostTeammate[admin][specType].g_iGhostWeaponSlots, value, -1, 31, specName, specType);
		}
		else
		{
			g_esGhostPlayer[admin].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esGhostPlayer[admin].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esGhostPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esGhostPlayer[admin].g_iComboAbility, value, -1, 1);
			g_esGhostPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esGhostPlayer[admin].g_iHumanAbility, value, -1, 2);
			g_esGhostPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esGhostPlayer[admin].g_iHumanAmmo, value, -1, 99999);
			g_esGhostPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esGhostPlayer[admin].g_iHumanCooldown, value, -1, 99999);
			g_esGhostPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esGhostPlayer[admin].g_iHumanDuration, value, -1, 99999);
			g_esGhostPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esGhostPlayer[admin].g_iHumanMode, value, -1, 1);
			g_esGhostPlayer[admin].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esGhostPlayer[admin].g_iHumanRangeCooldown, value, -1, 99999);
			g_esGhostPlayer[admin].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esGhostPlayer[admin].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esGhostPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esGhostPlayer[admin].g_iRequiresHumans, value, -1, 32);
			g_esGhostPlayer[admin].g_iGhostAbility = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esGhostPlayer[admin].g_iGhostAbility, value, -1, 3);
			g_esGhostPlayer[admin].g_iGhostEffect = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esGhostPlayer[admin].g_iGhostEffect, value, -1, 7);
			g_esGhostPlayer[admin].g_iGhostMessage = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esGhostPlayer[admin].g_iGhostMessage, value, -1, 7);
			g_esGhostPlayer[admin].g_iGhostSight = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esGhostPlayer[admin].g_iGhostSight, value, -1, 2);
			g_esGhostPlayer[admin].g_flGhostChance = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostChance", "Ghost Chance", "Ghost_Chance", "chance", g_esGhostPlayer[admin].g_flGhostChance, value, -1.0, 100.0);
			g_esGhostPlayer[admin].g_iGhostCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostCooldown", "Ghost Cooldown", "Ghost_Cooldown", "cooldown", g_esGhostPlayer[admin].g_iGhostCooldown, value, -1, 99999);
			g_esGhostPlayer[admin].g_iGhostDuration = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostDuration", "Ghost Duration", "Ghost_Duration", "duration", g_esGhostPlayer[admin].g_iGhostDuration, value, -1, 99999);
			g_esGhostPlayer[admin].g_iGhostFadeAlpha = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeAlpha", "Ghost Fade Alpha", "Ghost_Fade_Alpha", "fadealpha", g_esGhostPlayer[admin].g_iGhostFadeAlpha, value, -1, 255);
			g_esGhostPlayer[admin].g_iGhostFadeDelay = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeDelay", "Ghost Fade Delay", "Ghost_Fade_Delay", "fadedelay", g_esGhostPlayer[admin].g_iGhostFadeDelay, value, -1, 99999);
			g_esGhostPlayer[admin].g_iGhostFadeLimit = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeLimit", "Ghost Fade Limit", "Ghost_Fade_Limit", "fadelimit", g_esGhostPlayer[admin].g_iGhostFadeLimit, value, -1, 255);
			g_esGhostPlayer[admin].g_iGhostFadePhase = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadePhase", "Ghost Fade Phase", "Ghost_Fade_Phase", "fadephase", g_esGhostPlayer[admin].g_iGhostFadePhase, value, -1, 1);
			g_esGhostPlayer[admin].g_flGhostFadeRate = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeRate", "Ghost Fade Rate", "Ghost_Fade_Rate", "faderate", g_esGhostPlayer[admin].g_flGhostFadeRate, value, -1.0, 99999.0);
			g_esGhostPlayer[admin].g_iGhostHit = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostHit", "Ghost Hit", "Ghost_Hit", "hit", g_esGhostPlayer[admin].g_iGhostHit, value, -1, 1);
			g_esGhostPlayer[admin].g_iGhostHitMode = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostHitMode", "Ghost Hit Mode", "Ghost_Hit_Mode", "hitmode", g_esGhostPlayer[admin].g_iGhostHitMode, value, -1, 2);
			g_esGhostPlayer[admin].g_flGhostRange = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostRange", "Ghost Range", "Ghost_Range", "range", g_esGhostPlayer[admin].g_flGhostRange, value, -1.0, 99999.0);
			g_esGhostPlayer[admin].g_flGhostRangeChance = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostRangeChance", "Ghost Range Chance", "Ghost_Range_Chance", "rangechance", g_esGhostPlayer[admin].g_flGhostRangeChance, value, -1.0, 100.0);
			g_esGhostPlayer[admin].g_iGhostRangeCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostRangeCooldown", "Ghost Range Cooldown", "Ghost_Range_Cooldown", "rangecooldown", g_esGhostPlayer[admin].g_iGhostRangeCooldown, value, -1, 99999);
			g_esGhostPlayer[admin].g_iGhostSpecials = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostSpecials", "Ghost Specials", "Ghost_Specials", "specials", g_esGhostPlayer[admin].g_iGhostSpecials, value, -1, 1);
			g_esGhostPlayer[admin].g_flGhostSpecialsChance = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostSpecialsChance", "Ghost Specials Chance", "Ghost_Specials_Chance", "specialschance", g_esGhostPlayer[admin].g_flGhostSpecialsChance, value, -1.0, 100.0);
			g_esGhostPlayer[admin].g_flGhostSpecialsRange = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostSpecialsRange", "Ghost Specials Range", "Ghost_Specials_Range", "specialsrange", g_esGhostPlayer[admin].g_flGhostSpecialsRange, value, -1.0, 99999.0);
			g_esGhostPlayer[admin].g_iGhostWeaponSlots = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostWeaponSlots", "Ghost Weapon Slots", "Ghost_Weapon_Slots", "slots", g_esGhostPlayer[admin].g_iGhostWeaponSlots, value, -1, 31);
			g_esGhostPlayer[admin].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esGhostPlayer[admin].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}

	if (mode < 3 && type > 0)
	{
		if (special && specsection[0] != '\0')
		{
			g_esGhostSpecial[type][specType].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esGhostSpecial[type][specType].g_flCloseAreasOnly, value, -1.0, 99999.0, specName, specType);
			g_esGhostSpecial[type][specType].g_iComboAbility = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esGhostSpecial[type][specType].g_iComboAbility, value, -1, 1, specName, specType);
			g_esGhostSpecial[type][specType].g_iHumanAbility = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esGhostSpecial[type][specType].g_iHumanAbility, value, -1, 2, specName, specType);
			g_esGhostSpecial[type][specType].g_iHumanAmmo = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esGhostSpecial[type][specType].g_iHumanAmmo, value, -1, 99999, specName, specType);
			g_esGhostSpecial[type][specType].g_iHumanCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esGhostSpecial[type][specType].g_iHumanCooldown, value, -1, 99999, specName, specType);
			g_esGhostSpecial[type][specType].g_iHumanDuration = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esGhostSpecial[type][specType].g_iHumanDuration, value, -1, 99999, specName, specType);
			g_esGhostSpecial[type][specType].g_iHumanMode = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esGhostSpecial[type][specType].g_iHumanMode, value, -1, 1, specName, specType);
			g_esGhostSpecial[type][specType].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esGhostSpecial[type][specType].g_iHumanRangeCooldown, value, -1, 99999, specName, specType);
			g_esGhostSpecial[type][specType].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esGhostSpecial[type][specType].g_flOpenAreasOnly, value, -1.0, 99999.0, specName, specType);
			g_esGhostSpecial[type][specType].g_iRequiresHumans = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esGhostSpecial[type][specType].g_iRequiresHumans, value, -1, 32, specName, specType);
			g_esGhostSpecial[type][specType].g_iGhostAbility = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esGhostSpecial[type][specType].g_iGhostAbility, value, -1, 3, specName, specType);
			g_esGhostSpecial[type][specType].g_iGhostEffect = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esGhostSpecial[type][specType].g_iGhostEffect, value, -1, 7, specName, specType);
			g_esGhostSpecial[type][specType].g_iGhostMessage = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esGhostSpecial[type][specType].g_iGhostMessage, value, -1, 7, specName, specType);
			g_esGhostSpecial[type][specType].g_iGhostSight = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esGhostSpecial[type][specType].g_iGhostSight, value, -1, 2, specName, specType);
			g_esGhostSpecial[type][specType].g_flGhostChance = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostChance", "Ghost Chance", "Ghost_Chance", "chance", g_esGhostSpecial[type][specType].g_flGhostChance, value, -1.0, 100.0, specName, specType);
			g_esGhostSpecial[type][specType].g_iGhostCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostCooldown", "Ghost Cooldown", "Ghost_Cooldown", "cooldown", g_esGhostSpecial[type][specType].g_iGhostCooldown, value, -1, 99999, specName, specType);
			g_esGhostSpecial[type][specType].g_iGhostDuration = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostDuration", "Ghost Duration", "Ghost_Duration", "duration", g_esGhostSpecial[type][specType].g_iGhostDuration, value, -1, 99999, specName, specType);
			g_esGhostSpecial[type][specType].g_iGhostFadeAlpha = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeAlpha", "Ghost Fade Alpha", "Ghost_Fade_Alpha", "fadealpha", g_esGhostSpecial[type][specType].g_iGhostFadeAlpha, value, -1, 255, specName, specType);
			g_esGhostSpecial[type][specType].g_iGhostFadeDelay = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeDelay", "Ghost Fade Delay", "Ghost_Fade_Delay", "fadedelay", g_esGhostSpecial[type][specType].g_iGhostFadeDelay, value, -1, 99999, specName, specType);
			g_esGhostSpecial[type][specType].g_iGhostFadeLimit = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeLimit", "Ghost Fade Limit", "Ghost_Fade_Limit", "fadelimit", g_esGhostSpecial[type][specType].g_iGhostFadeLimit, value, -1, 255, specName, specType);
			g_esGhostSpecial[type][specType].g_iGhostFadePhase = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadePhase", "Ghost Fade Phase", "Ghost_Fade_Phase", "fadephase", g_esGhostSpecial[type][specType].g_iGhostFadePhase, value, -1, 1, specName, specType);
			g_esGhostSpecial[type][specType].g_flGhostFadeRate = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeRate", "Ghost Fade Rate", "Ghost_Fade_Rate", "faderate", g_esGhostSpecial[type][specType].g_flGhostFadeRate, value, -1.0, 99999.0, specName, specType);
			g_esGhostSpecial[type][specType].g_iGhostHit = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostHit", "Ghost Hit", "Ghost_Hit", "hit", g_esGhostSpecial[type][specType].g_iGhostHit, value, -1, 1, specName, specType);
			g_esGhostSpecial[type][specType].g_iGhostHitMode = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostHitMode", "Ghost Hit Mode", "Ghost_Hit_Mode", "hitmode", g_esGhostSpecial[type][specType].g_iGhostHitMode, value, -1, 2, specName, specType);
			g_esGhostSpecial[type][specType].g_flGhostRange = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostRange", "Ghost Range", "Ghost_Range", "range", g_esGhostSpecial[type][specType].g_flGhostRange, value, -1.0, 99999.0, specName, specType);
			g_esGhostSpecial[type][specType].g_flGhostRangeChance = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostRangeChance", "Ghost Range Chance", "Ghost_Range_Chance", "rangechance", g_esGhostSpecial[type][specType].g_flGhostRangeChance, value, -1.0, 100.0, specName, specType);
			g_esGhostSpecial[type][specType].g_iGhostRangeCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostRangeCooldown", "Ghost Range Cooldown", "Ghost_Range_Cooldown", "rangecooldown", g_esGhostSpecial[type][specType].g_iGhostRangeCooldown, value, -1, 99999, specName, specType);
			g_esGhostSpecial[type][specType].g_iGhostSpecials = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostSpecials", "Ghost Specials", "Ghost_Specials", "specials", g_esGhostSpecial[type][specType].g_iGhostSpecials, value, -1, 1, specName, specType);
			g_esGhostSpecial[type][specType].g_flGhostSpecialsChance = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostSpecialsChance", "Ghost Specials Chance", "Ghost_Specials_Chance", "specialschance", g_esGhostSpecial[type][specType].g_flGhostSpecialsChance, value, -1.0, 100.0, specName, specType);
			g_esGhostSpecial[type][specType].g_flGhostSpecialsRange = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostSpecialsRange", "Ghost Specials Range", "Ghost_Specials_Range", "specialsrange", g_esGhostSpecial[type][specType].g_flGhostSpecialsRange, value, -1.0, 99999.0, specName, specType);
			g_esGhostSpecial[type][specType].g_iGhostWeaponSlots = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostWeaponSlots", "Ghost Weapon Slots", "Ghost_Weapon_Slots", "slots", g_esGhostSpecial[type][specType].g_iGhostWeaponSlots, value, -1, 31, specName, specType);
		}
		else
		{
			g_esGhostAbility[type].g_flCloseAreasOnly = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "CloseAreasOnly", "Close Areas Only", "Close_Areas_Only", "closeareas", g_esGhostAbility[type].g_flCloseAreasOnly, value, -1.0, 99999.0);
			g_esGhostAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esGhostAbility[type].g_iComboAbility, value, -1, 1);
			g_esGhostAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esGhostAbility[type].g_iHumanAbility, value, -1, 2);
			g_esGhostAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esGhostAbility[type].g_iHumanAmmo, value, -1, 99999);
			g_esGhostAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esGhostAbility[type].g_iHumanCooldown, value, -1, 99999);
			g_esGhostAbility[type].g_iHumanDuration = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esGhostAbility[type].g_iHumanDuration, value, -1, 99999);
			g_esGhostAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esGhostAbility[type].g_iHumanMode, value, -1, 1);
			g_esGhostAbility[type].g_iHumanRangeCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "HumanRangeCooldown", "Human Range Cooldown", "Human_Range_Cooldown", "hrangecooldown", g_esGhostAbility[type].g_iHumanRangeCooldown, value, -1, 99999);
			g_esGhostAbility[type].g_flOpenAreasOnly = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esGhostAbility[type].g_flOpenAreasOnly, value, -1.0, 99999.0);
			g_esGhostAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esGhostAbility[type].g_iRequiresHumans, value, -1, 32);
			g_esGhostAbility[type].g_iGhostAbility = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esGhostAbility[type].g_iGhostAbility, value, -1, 3);
			g_esGhostAbility[type].g_iGhostEffect = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esGhostAbility[type].g_iGhostEffect, value, -1, 7);
			g_esGhostAbility[type].g_iGhostMessage = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esGhostAbility[type].g_iGhostMessage, value, -1, 7);
			g_esGhostAbility[type].g_iGhostSight = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AbilitySight", "Ability Sight", "Ability_Sight", "sight", g_esGhostAbility[type].g_iGhostSight, value, -1, 2);
			g_esGhostAbility[type].g_flGhostChance = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostChance", "Ghost Chance", "Ghost_Chance", "chance", g_esGhostAbility[type].g_flGhostChance, value, -1.0, 100.0);
			g_esGhostAbility[type].g_iGhostCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostCooldown", "Ghost Cooldown", "Ghost_Cooldown", "cooldown", g_esGhostAbility[type].g_iGhostCooldown, value, -1, 99999);
			g_esGhostAbility[type].g_iGhostDuration = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostDuration", "Ghost Duration", "Ghost_Duration", "duration", g_esGhostAbility[type].g_iGhostDuration, value, -1, 99999);
			g_esGhostAbility[type].g_iGhostFadeAlpha = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeAlpha", "Ghost Fade Alpha", "Ghost_Fade_Alpha", "fadealpha", g_esGhostAbility[type].g_iGhostFadeAlpha, value, -1, 255);
			g_esGhostAbility[type].g_iGhostFadeDelay = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeDelay", "Ghost Fade Delay", "Ghost_Fade_Delay", "fadedelay", g_esGhostAbility[type].g_iGhostFadeDelay, value, -1, 99999);
			g_esGhostAbility[type].g_iGhostFadeLimit = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeLimit", "Ghost Fade Limit", "Ghost_Fade_Limit", "fadelimit", g_esGhostAbility[type].g_iGhostFadeLimit, value, -1, 255);
			g_esGhostAbility[type].g_iGhostFadePhase = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadePhase", "Ghost Fade Phase", "Ghost_Fade_Phase", "fadephase", g_esGhostAbility[type].g_iGhostFadePhase, value, -1, 1);
			g_esGhostAbility[type].g_flGhostFadeRate = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostFadeRate", "Ghost Fade Rate", "Ghost_Fade_Rate", "faderate", g_esGhostAbility[type].g_flGhostFadeRate, value, -1.0, 99999.0);
			g_esGhostAbility[type].g_iGhostHit = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostHit", "Ghost Hit", "Ghost_Hit", "hit", g_esGhostAbility[type].g_iGhostHit, value, -1, 1);
			g_esGhostAbility[type].g_iGhostHitMode = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostHitMode", "Ghost Hit Mode", "Ghost_Hit_Mode", "hitmode", g_esGhostAbility[type].g_iGhostHitMode, value, -1, 2);
			g_esGhostAbility[type].g_flGhostRange = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostRange", "Ghost Range", "Ghost_Range", "range", g_esGhostAbility[type].g_flGhostRange, value, -1.0, 99999.0);
			g_esGhostAbility[type].g_flGhostRangeChance = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostRangeChance", "Ghost Range Chance", "Ghost_Range_Chance", "rangechance", g_esGhostAbility[type].g_flGhostRangeChance, value, -1.0, 100.0);
			g_esGhostAbility[type].g_iGhostRangeCooldown = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostRangeCooldown", "Ghost Range Cooldown", "Ghost_Range_Cooldown", "rangecooldown", g_esGhostAbility[type].g_iGhostRangeCooldown, value, -1, 99999);
			g_esGhostAbility[type].g_iGhostSpecials = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostSpecials", "Ghost Specials", "Ghost_Specials", "specials", g_esGhostAbility[type].g_iGhostSpecials, value, -1, 1);
			g_esGhostAbility[type].g_flGhostSpecialsChance = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostSpecialsChance", "Ghost Specials Chance", "Ghost_Specials_Chance", "specialschance", g_esGhostAbility[type].g_flGhostSpecialsChance, value, -1.0, 100.0);
			g_esGhostAbility[type].g_flGhostSpecialsRange = flGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostSpecialsRange", "Ghost Specials Range", "Ghost_Specials_Range", "specialsrange", g_esGhostAbility[type].g_flGhostSpecialsRange, value, -1.0, 99999.0);
			g_esGhostAbility[type].g_iGhostWeaponSlots = iGetKeyValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "GhostWeaponSlots", "Ghost Weapon Slots", "Ghost_Weapon_Slots", "slots", g_esGhostAbility[type].g_iGhostWeaponSlots, value, -1, 31);
			g_esGhostAbility[type].g_iAccessFlags = iGetAdminFlagsValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "AccessFlags", "Access Flags", "Access_Flags", "access", value);
			g_esGhostAbility[type].g_iImmunityFlags = iGetAdminFlagsValue(subsection, MT_GHOST_SECTION, MT_GHOST_SECTION2, MT_GHOST_SECTION3, MT_GHOST_SECTION4, key, "ImmunityFlags", "Immunity Flags", "Immunity_Flags", "immunity", value);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vGhostSettingsCached(int tank, bool apply, int type)
#else
public void MT_OnSettingsCached(int tank, bool apply, int type)
#endif
{
	bool bHuman = bIsValidClient(tank, MT_CHECK_FAKECLIENT);
	g_esGhostPlayer[tank].g_iInfectedType = iGetInfectedType(tank);
	g_esGhostPlayer[tank].g_iTankType = apply ? type : 0;
	int iSpecType = g_esGhostPlayer[tank].g_iInfectedType;

	if (bIsSpecialInfected(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		g_esGhostCache[tank].g_flCloseAreasOnly = flGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_flCloseAreasOnly, g_esGhostPlayer[tank].g_flCloseAreasOnly, g_esGhostSpecial[type][iSpecType - 1].g_flCloseAreasOnly, g_esGhostAbility[type].g_flCloseAreasOnly, 1);
		g_esGhostCache[tank].g_iComboAbility = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iComboAbility, g_esGhostPlayer[tank].g_iComboAbility, g_esGhostSpecial[type][iSpecType - 1].g_iComboAbility, g_esGhostAbility[type].g_iComboAbility, 1);
		g_esGhostCache[tank].g_flGhostChance = flGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_flGhostChance, g_esGhostPlayer[tank].g_flGhostChance, g_esGhostSpecial[type][iSpecType - 1].g_flGhostChance, g_esGhostAbility[type].g_flGhostChance, 1);
		g_esGhostCache[tank].g_flGhostFadeRate = flGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_flGhostFadeRate, g_esGhostPlayer[tank].g_flGhostFadeRate, g_esGhostSpecial[type][iSpecType - 1].g_flGhostFadeRate, g_esGhostAbility[type].g_flGhostFadeRate, 1);
		g_esGhostCache[tank].g_flGhostRange = flGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_flGhostRange, g_esGhostPlayer[tank].g_flGhostRange, g_esGhostSpecial[type][iSpecType - 1].g_flGhostRange, g_esGhostAbility[type].g_flGhostRange, 1);
		g_esGhostCache[tank].g_flGhostRangeChance = flGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_flGhostRangeChance, g_esGhostPlayer[tank].g_flGhostRangeChance, g_esGhostSpecial[type][iSpecType - 1].g_flGhostRangeChance, g_esGhostAbility[type].g_flGhostRangeChance, 1);
		g_esGhostCache[tank].g_flGhostSpecialsChance = flGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_flGhostSpecialsChance, g_esGhostPlayer[tank].g_flGhostSpecialsChance, g_esGhostSpecial[type][iSpecType - 1].g_flGhostSpecialsChance, g_esGhostAbility[type].g_flGhostSpecialsChance, 1);
		g_esGhostCache[tank].g_flGhostSpecialsRange = flGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_flGhostSpecialsRange, g_esGhostPlayer[tank].g_flGhostSpecialsRange, g_esGhostSpecial[type][iSpecType - 1].g_flGhostSpecialsRange, g_esGhostAbility[type].g_flGhostSpecialsRange, 1);
		g_esGhostCache[tank].g_iGhostAbility = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iGhostAbility, g_esGhostPlayer[tank].g_iGhostAbility, g_esGhostSpecial[type][iSpecType - 1].g_iGhostAbility, g_esGhostAbility[type].g_iGhostAbility, 1);
		g_esGhostCache[tank].g_iGhostCooldown = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iGhostCooldown, g_esGhostPlayer[tank].g_iGhostCooldown, g_esGhostSpecial[type][iSpecType - 1].g_iGhostCooldown, g_esGhostAbility[type].g_iGhostCooldown, 1);
		g_esGhostCache[tank].g_iGhostDuration = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iGhostDuration, g_esGhostPlayer[tank].g_iGhostDuration, g_esGhostSpecial[type][iSpecType - 1].g_iGhostDuration, g_esGhostAbility[type].g_iGhostDuration, 1);
		g_esGhostCache[tank].g_iGhostEffect = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iGhostEffect, g_esGhostPlayer[tank].g_iGhostEffect, g_esGhostSpecial[type][iSpecType - 1].g_iGhostEffect, g_esGhostAbility[type].g_iGhostEffect, 1);
		g_esGhostCache[tank].g_iGhostFadeAlpha = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iGhostFadeAlpha, g_esGhostPlayer[tank].g_iGhostFadeAlpha, g_esGhostSpecial[type][iSpecType - 1].g_iGhostFadeAlpha, g_esGhostAbility[type].g_iGhostFadeAlpha, 1);
		g_esGhostCache[tank].g_iGhostFadeDelay = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iGhostFadeDelay, g_esGhostPlayer[tank].g_iGhostFadeDelay, g_esGhostSpecial[type][iSpecType - 1].g_iGhostFadeDelay, g_esGhostAbility[type].g_iGhostFadeDelay, 1);
		g_esGhostCache[tank].g_iGhostFadeLimit = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iGhostFadeLimit, g_esGhostPlayer[tank].g_iGhostFadeLimit, g_esGhostSpecial[type][iSpecType - 1].g_iGhostFadeLimit, g_esGhostAbility[type].g_iGhostFadeLimit, 1);
		g_esGhostCache[tank].g_iGhostFadePhase = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iGhostFadePhase, g_esGhostPlayer[tank].g_iGhostFadePhase, g_esGhostSpecial[type][iSpecType - 1].g_iGhostFadePhase, g_esGhostAbility[type].g_iGhostFadePhase, 1);
		g_esGhostCache[tank].g_iGhostHit = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iGhostHit, g_esGhostPlayer[tank].g_iGhostHit, g_esGhostSpecial[type][iSpecType - 1].g_iGhostHit, g_esGhostAbility[type].g_iGhostHit, 1);
		g_esGhostCache[tank].g_iGhostHitMode = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iGhostHitMode, g_esGhostPlayer[tank].g_iGhostHitMode, g_esGhostSpecial[type][iSpecType - 1].g_iGhostHitMode, g_esGhostAbility[type].g_iGhostHitMode, 1);
		g_esGhostCache[tank].g_iGhostMessage = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iGhostMessage, g_esGhostPlayer[tank].g_iGhostMessage, g_esGhostSpecial[type][iSpecType - 1].g_iGhostMessage, g_esGhostAbility[type].g_iGhostMessage, 1);
		g_esGhostCache[tank].g_iGhostRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iGhostRangeCooldown, g_esGhostPlayer[tank].g_iGhostRangeCooldown, g_esGhostSpecial[type][iSpecType - 1].g_iGhostRangeCooldown, g_esGhostAbility[type].g_iGhostRangeCooldown, 1);
		g_esGhostCache[tank].g_iGhostSight = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iGhostSight, g_esGhostPlayer[tank].g_iGhostSight, g_esGhostSpecial[type][iSpecType - 1].g_iGhostSight, g_esGhostAbility[type].g_iGhostSight, 1);
		g_esGhostCache[tank].g_iGhostSpecials = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iGhostSpecials, g_esGhostPlayer[tank].g_iGhostSpecials, g_esGhostSpecial[type][iSpecType - 1].g_iGhostSpecials, g_esGhostAbility[type].g_iGhostSpecials, 1);
		g_esGhostCache[tank].g_iGhostWeaponSlots = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iGhostWeaponSlots, g_esGhostPlayer[tank].g_iGhostWeaponSlots, g_esGhostSpecial[type][iSpecType - 1].g_iGhostWeaponSlots, g_esGhostAbility[type].g_iGhostWeaponSlots, 1);
		g_esGhostCache[tank].g_iHumanAbility = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iHumanAbility, g_esGhostPlayer[tank].g_iHumanAbility, g_esGhostSpecial[type][iSpecType - 1].g_iHumanAbility, g_esGhostAbility[type].g_iHumanAbility, 1);
		g_esGhostCache[tank].g_iHumanAmmo = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iHumanAmmo, g_esGhostPlayer[tank].g_iHumanAmmo, g_esGhostSpecial[type][iSpecType - 1].g_iHumanAmmo, g_esGhostAbility[type].g_iHumanAmmo, 1);
		g_esGhostCache[tank].g_iHumanCooldown = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iHumanCooldown, g_esGhostPlayer[tank].g_iHumanCooldown, g_esGhostSpecial[type][iSpecType - 1].g_iHumanCooldown, g_esGhostAbility[type].g_iHumanCooldown, 1);
		g_esGhostCache[tank].g_iHumanDuration = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iHumanDuration, g_esGhostPlayer[tank].g_iHumanDuration, g_esGhostSpecial[type][iSpecType - 1].g_iHumanDuration, g_esGhostAbility[type].g_iHumanDuration, 1);
		g_esGhostCache[tank].g_iHumanMode = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iHumanMode, g_esGhostPlayer[tank].g_iHumanMode, g_esGhostSpecial[type][iSpecType - 1].g_iHumanMode, g_esGhostAbility[type].g_iHumanMode, 1);
		g_esGhostCache[tank].g_iHumanRangeCooldown = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iHumanRangeCooldown, g_esGhostPlayer[tank].g_iHumanRangeCooldown, g_esGhostSpecial[type][iSpecType - 1].g_iHumanRangeCooldown, g_esGhostAbility[type].g_iHumanRangeCooldown, 1);
		g_esGhostCache[tank].g_flOpenAreasOnly = flGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_flOpenAreasOnly, g_esGhostPlayer[tank].g_flOpenAreasOnly, g_esGhostSpecial[type][iSpecType - 1].g_flOpenAreasOnly, g_esGhostAbility[type].g_flOpenAreasOnly, 1);
		g_esGhostCache[tank].g_iRequiresHumans = iGetSubSettingValue(apply, bHuman, g_esGhostTeammate[tank][iSpecType - 1].g_iRequiresHumans, g_esGhostPlayer[tank].g_iRequiresHumans, g_esGhostSpecial[type][iSpecType - 1].g_iRequiresHumans, g_esGhostAbility[type].g_iRequiresHumans, 1);
	}
	else
	{
		g_esGhostCache[tank].g_flCloseAreasOnly = flGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_flCloseAreasOnly, g_esGhostAbility[type].g_flCloseAreasOnly, 1);
		g_esGhostCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iComboAbility, g_esGhostAbility[type].g_iComboAbility, 1);
		g_esGhostCache[tank].g_flGhostChance = flGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_flGhostChance, g_esGhostAbility[type].g_flGhostChance, 1);
		g_esGhostCache[tank].g_flGhostFadeRate = flGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_flGhostFadeRate, g_esGhostAbility[type].g_flGhostFadeRate, 1);
		g_esGhostCache[tank].g_flGhostRange = flGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_flGhostRange, g_esGhostAbility[type].g_flGhostRange, 1);
		g_esGhostCache[tank].g_flGhostRangeChance = flGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_flGhostRangeChance, g_esGhostAbility[type].g_flGhostRangeChance, 1);
		g_esGhostCache[tank].g_flGhostSpecialsChance = flGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_flGhostSpecialsChance, g_esGhostAbility[type].g_flGhostSpecialsChance, 1);
		g_esGhostCache[tank].g_flGhostSpecialsRange = flGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_flGhostSpecialsRange, g_esGhostAbility[type].g_flGhostSpecialsRange, 1);
		g_esGhostCache[tank].g_iGhostAbility = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iGhostAbility, g_esGhostAbility[type].g_iGhostAbility, 1);
		g_esGhostCache[tank].g_iGhostCooldown = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iGhostCooldown, g_esGhostAbility[type].g_iGhostCooldown, 1);
		g_esGhostCache[tank].g_iGhostDuration = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iGhostDuration, g_esGhostAbility[type].g_iGhostDuration, 1);
		g_esGhostCache[tank].g_iGhostEffect = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iGhostEffect, g_esGhostAbility[type].g_iGhostEffect, 1);
		g_esGhostCache[tank].g_iGhostFadeAlpha = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iGhostFadeAlpha, g_esGhostAbility[type].g_iGhostFadeAlpha, 1);
		g_esGhostCache[tank].g_iGhostFadeDelay = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iGhostFadeDelay, g_esGhostAbility[type].g_iGhostFadeDelay, 1);
		g_esGhostCache[tank].g_iGhostFadeLimit = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iGhostFadeLimit, g_esGhostAbility[type].g_iGhostFadeLimit, 1);
		g_esGhostCache[tank].g_iGhostFadePhase = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iGhostFadePhase, g_esGhostAbility[type].g_iGhostFadePhase, 1);
		g_esGhostCache[tank].g_iGhostHit = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iGhostHit, g_esGhostAbility[type].g_iGhostHit, 1);
		g_esGhostCache[tank].g_iGhostHitMode = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iGhostHitMode, g_esGhostAbility[type].g_iGhostHitMode, 1);
		g_esGhostCache[tank].g_iGhostMessage = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iGhostMessage, g_esGhostAbility[type].g_iGhostMessage, 1);
		g_esGhostCache[tank].g_iGhostRangeCooldown = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iGhostRangeCooldown, g_esGhostAbility[type].g_iGhostRangeCooldown, 1);
		g_esGhostCache[tank].g_iGhostSight = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iGhostSight, g_esGhostAbility[type].g_iGhostSight, 1);
		g_esGhostCache[tank].g_iGhostSpecials = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iGhostSpecials, g_esGhostAbility[type].g_iGhostSpecials, 1);
		g_esGhostCache[tank].g_iGhostWeaponSlots = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iGhostWeaponSlots, g_esGhostAbility[type].g_iGhostWeaponSlots, 1);
		g_esGhostCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iHumanAbility, g_esGhostAbility[type].g_iHumanAbility, 1);
		g_esGhostCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iHumanAmmo, g_esGhostAbility[type].g_iHumanAmmo, 1);
		g_esGhostCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iHumanCooldown, g_esGhostAbility[type].g_iHumanCooldown, 1);
		g_esGhostCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iHumanDuration, g_esGhostAbility[type].g_iHumanDuration, 1);
		g_esGhostCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iHumanMode, g_esGhostAbility[type].g_iHumanMode, 1);
		g_esGhostCache[tank].g_iHumanRangeCooldown = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iHumanRangeCooldown, g_esGhostAbility[type].g_iHumanRangeCooldown, 1);
		g_esGhostCache[tank].g_flOpenAreasOnly = flGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_flOpenAreasOnly, g_esGhostAbility[type].g_flOpenAreasOnly, 1);
		g_esGhostCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esGhostPlayer[tank].g_iRequiresHumans, g_esGhostAbility[type].g_iRequiresHumans, 1);
	}
}

#if defined MT_ABILITIES_MAIN
void vGhostCopyStats(int oldTank, int newTank)
#else
public void MT_OnCopyStats(int oldTank, int newTank)
#endif
{
	vGhostCopyStats2(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveGhost(oldTank);
	}
}

#if !defined MT_ABILITIES_MAIN
public void MT_OnPluginUpdate()
{
	MT_ReloadPlugin(null);
}
#endif

#if defined MT_ABILITIES_MAIN
void vGhostEventFired(Event event, const char[] name)
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
			vGhostCopyStats2(iBot, iTank);
			vRemoveGhost(iBot);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start") || StrEqual(name, "round_end"))
	{
		vGhostReset();
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsInfected(iBot))
		{
			vGhostCopyStats2(iTank, iBot);
			vRemoveGhost(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveGhost(iTank);
		}
	}
	else if (StrEqual(name, "player_now_it"))
	{
		bool bExploded = event.GetBool("exploded");
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iBoomerId = event.GetInt("attacker"), iBoomer = GetClientOfUserId(iBoomerId);
		if (bIsBoomer(iBoomer) && bIsSurvivor(iSurvivor) && !bExploded)
		{
			vGhostHit(iSurvivor, iBoomer, GetRandomFloat(0.1, 100.0), g_esGhostCache[iBoomer].g_flGhostChance, g_esGhostCache[iBoomer].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vGhostAbilityActivated(int tank)
#else
public void MT_OnAbilityActivated(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esGhostAbility[g_esGhostPlayer[tank].g_iTankType].g_iAccessFlags, g_esGhostPlayer[tank].g_iAccessFlags)) || g_esGhostCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || g_esGhostCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esGhostCache[tank].g_iGhostAbility > 0 && g_esGhostCache[tank].g_iComboAbility == 0)
	{
		vGhostAbility(tank, false);
		vGhostAbility(tank, true, GetRandomFloat(0.1, 100.0));
	}
}

#if defined MT_ABILITIES_MAIN
void vGhostButtonPressed(int tank, int button)
#else
public void MT_OnButtonPressed(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esGhostCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esGhostCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esGhostPlayer[tank].g_iTankType, tank) || (g_esGhostCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esGhostCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esGhostAbility[g_esGhostPlayer[tank].g_iTankType].g_iAccessFlags, g_esGhostPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		int iTime = GetTime();
		if ((button & MT_MAIN_KEY) && (g_esGhostCache[tank].g_iGhostAbility == 2 || g_esGhostCache[tank].g_iGhostAbility == 3) && g_esGhostCache[tank].g_iHumanAbility == 1)
		{
			bool bRecharging = g_esGhostPlayer[tank].g_iCooldown != -1 && g_esGhostPlayer[tank].g_iCooldown >= iTime;

			switch (g_esGhostCache[tank].g_iHumanMode)
			{
				case 0:
				{
					if (!g_esGhostPlayer[tank].g_bActivated && !bRecharging)
					{
						vGhostAbility(tank, false);
					}
					else if (g_esGhostPlayer[tank].g_bActivated)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman4");
					}
					else if (bRecharging)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman5", (g_esGhostPlayer[tank].g_iCooldown - iTime));
					}
				}
				case 1:
				{
					if (g_esGhostPlayer[tank].g_iAmmoCount < g_esGhostCache[tank].g_iHumanAmmo && g_esGhostCache[tank].g_iHumanAmmo > 0)
					{
						if (!g_esGhostPlayer[tank].g_bActivated && !bRecharging)
						{
							g_esGhostPlayer[tank].g_bActivated = true;
							g_esGhostPlayer[tank].g_bPhased = true;
							g_esGhostPlayer[tank].g_iAmmoCount++;

							vGhost(tank);
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman", g_esGhostPlayer[tank].g_iAmmoCount, g_esGhostCache[tank].g_iHumanAmmo);
						}
						else if (g_esGhostPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman4");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman5", (g_esGhostPlayer[tank].g_iCooldown - iTime));
						}
					}
					else
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostAmmo");
					}
				}
			}
		}

		if ((button & MT_SUB_KEY) && (g_esGhostCache[tank].g_iGhostAbility == 1 || g_esGhostCache[tank].g_iGhostAbility == 3) && g_esGhostCache[tank].g_iHumanAbility == 1)
		{
			switch (g_esGhostPlayer[tank].g_iRangeCooldown == -1 || g_esGhostPlayer[tank].g_iRangeCooldown <= iTime)
			{
				case true: vGhostAbility(tank, true, GetRandomFloat(0.1, 100.0));
				case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman6", (g_esGhostPlayer[tank].g_iRangeCooldown - iTime));
			}
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vGhostButtonReleased(int tank, int button)
#else
public void MT_OnButtonReleased(int tank, int button)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank) && g_esGhostCache[tank].g_iHumanAbility == 1)
	{
		if ((button & MT_MAIN_KEY) && g_esGhostCache[tank].g_iHumanMode == 1 && g_esGhostPlayer[tank].g_bActivated && (g_esGhostPlayer[tank].g_iCooldown == -1 || g_esGhostPlayer[tank].g_iCooldown <= GetTime()))
		{
			vGhostReset2(tank);
		}
	}
}

#if defined MT_ABILITIES_MAIN
void vGhostChangeType(int tank, int oldType)
#else
public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
#endif
{
	if (oldType <= 0)
	{
		return;
	}

	vRenderProps(tank, RENDER_NORMAL);
	vRemoveGhost(tank);
}

#if defined MT_ABILITIES_MAIN
void vGhostPostTankSpawn(int tank)
#else
public void MT_OnPostTankSpawn(int tank)
#endif
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		vRenderProps(tank, RENDER_NORMAL);
	}
}

#if defined MT_ABILITIES_MAIN
void vGhostRockThrow(int tank, int rock)
#else
public void MT_OnRockThrow(int tank, int rock)
#endif
{
	if (MT_IsTankSupported(tank) && MT_IsCustomTankSupported(tank) && (g_esGhostCache[tank].g_iGhostAbility == 2 || g_esGhostCache[tank].g_iGhostAbility == 3))
	{
		DataPack dpRender;
		CreateDataTimer(0.1, tTimerRenderRock, dpRender, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpRender.WriteCell(EntIndexToEntRef(rock));
		dpRender.WriteCell(GetClientUserId(tank));
	}
}

void vGhost(int tank, int pos = -1)
{
	int iTime = GetTime();
	if ((g_esGhostPlayer[tank].g_iCooldown != -1 && g_esGhostPlayer[tank].g_iCooldown >= iTime) || bIsAreaNarrow(tank, g_esGhostCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esGhostCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esGhostPlayer[tank].g_iTankType, tank) || (g_esGhostCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esGhostCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esGhostAbility[g_esGhostPlayer[tank].g_iTankType].g_iAccessFlags, g_esGhostPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	DataPack dpGhost;
	CreateDataTimer(g_esGhostCache[tank].g_flGhostFadeRate, tTimerGhost, dpGhost, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpGhost.WriteCell(GetClientUserId(tank));
	dpGhost.WriteCell(g_esGhostPlayer[tank].g_iTankType);
	dpGhost.WriteCell(iTime);
	dpGhost.WriteCell(pos);
	dpGhost.WriteFloat(GetRandomFloat(0.1, 100.0));
}

void vGhostAbility(int tank, bool main, float random = 0.0, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esGhostCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esGhostCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esGhostPlayer[tank].g_iTankType, tank) || (g_esGhostCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esGhostCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esGhostAbility[g_esGhostPlayer[tank].g_iTankType].g_iAccessFlags, g_esGhostPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_esGhostCache[tank].g_iGhostAbility == 1 || g_esGhostCache[tank].g_iGhostAbility == 3)
			{
				if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esGhostPlayer[tank].g_iAmmoCount2 < g_esGhostCache[tank].g_iHumanAmmo && g_esGhostCache[tank].g_iHumanAmmo > 0))
				{
					g_esGhostPlayer[tank].g_bFailed = false;
					g_esGhostPlayer[tank].g_bNoAmmo = false;

					float flTankPos[3], flSurvivorPos[3];
					GetClientAbsOrigin(tank, flTankPos);
					float flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esGhostCache[tank].g_flGhostRange,
						flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 10, pos) : g_esGhostCache[tank].g_flGhostRangeChance;
					int iSurvivorCount = 0;
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esGhostPlayer[tank].g_iTankType, g_esGhostAbility[g_esGhostPlayer[tank].g_iTankType].g_iImmunityFlags, g_esGhostPlayer[iSurvivor].g_iImmunityFlags))
						{
							GetClientAbsOrigin(iSurvivor, flSurvivorPos);
							if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange && bIsVisibleToPlayer(tank, iSurvivor, g_esGhostCache[tank].g_iGhostSight, .range = flRange))
							{
								vGhostHit(iSurvivor, tank, random, flChance, g_esGhostCache[tank].g_iGhostAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGhostCache[tank].g_iHumanAbility == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman7");
						}
					}
				}
				else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGhostCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostAmmo2");
				}
			}
		}
		case false:
		{
			if (g_esGhostPlayer[tank].g_iCooldown != -1 && g_esGhostPlayer[tank].g_iCooldown >= GetTime())
			{
				return;
			}

			if ((g_esGhostCache[tank].g_iGhostAbility == 2 || g_esGhostCache[tank].g_iGhostAbility == 3) && !g_esGhostPlayer[tank].g_bActivated)
			{
				if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (g_esGhostPlayer[tank].g_iAmmoCount < g_esGhostCache[tank].g_iHumanAmmo && g_esGhostCache[tank].g_iHumanAmmo > 0))
				{
					g_esGhostPlayer[tank].g_bActivated = true;
					g_esGhostPlayer[tank].g_bPhased = true;
					g_esGhostPlayer[tank].g_iGhostAlpha = 255;

					vGhost(tank, pos);

					if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGhostCache[tank].g_iHumanAbility == 1)
					{
						g_esGhostPlayer[tank].g_iAmmoCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman", g_esGhostPlayer[tank].g_iAmmoCount, g_esGhostCache[tank].g_iHumanAmmo);
					}

					if (g_esGhostCache[tank].g_iGhostMessage & MT_MESSAGE_SPECIAL)
					{
						char sTankName[33];
						MT_GetTankName(tank, sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Ghost2", sTankName);
						MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Ghost2", LANG_SERVER, sTankName);
					}
				}
				else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGhostCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostAmmo");
				}
			}
		}
	}
}

void vGhostHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esGhostCache[tank].g_flOpenAreasOnly) || bIsAreaWide(tank, g_esGhostCache[tank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esGhostPlayer[tank].g_iTankType, tank) || (g_esGhostCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esGhostCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esGhostAbility[g_esGhostPlayer[tank].g_iTankType].g_iAccessFlags, g_esGhostPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esGhostPlayer[tank].g_iTankType, g_esGhostAbility[g_esGhostPlayer[tank].g_iTankType].g_iImmunityFlags, g_esGhostPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	int iTime = GetTime();
	if (((flags & MT_ATTACK_RANGE) && g_esGhostPlayer[tank].g_iRangeCooldown != -1 && g_esGhostPlayer[tank].g_iRangeCooldown >= iTime) || (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && g_esGhostPlayer[tank].g_iCooldown2 != -1 && g_esGhostPlayer[tank].g_iCooldown2 >= iTime))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor) && !bIsSurvivorDisabled(survivor))
	{
		if (!bIsInfected(tank, MT_CHECK_FAKECLIENT) || (flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE) || (g_esGhostPlayer[tank].g_iAmmoCount2 < g_esGhostCache[tank].g_iHumanAmmo && g_esGhostCache[tank].g_iHumanAmmo > 0))
		{
			if (random <= chance)
			{
				int iCooldown = -1;
				if ((flags & MT_ATTACK_RANGE) && (g_esGhostPlayer[tank].g_iRangeCooldown == -1 || g_esGhostPlayer[tank].g_iRangeCooldown <= iTime))
				{
					if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGhostCache[tank].g_iHumanAbility == 1)
					{
						g_esGhostPlayer[tank].g_iAmmoCount2++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman2", g_esGhostPlayer[tank].g_iAmmoCount2, g_esGhostCache[tank].g_iHumanAmmo);
					}

					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 11, pos)) : g_esGhostCache[tank].g_iGhostRangeCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGhostCache[tank].g_iHumanAbility == 1 && g_esGhostPlayer[tank].g_iAmmoCount2 < g_esGhostCache[tank].g_iHumanAmmo && g_esGhostCache[tank].g_iHumanAmmo > 0) ? g_esGhostCache[tank].g_iHumanRangeCooldown : iCooldown;
					g_esGhostPlayer[tank].g_iRangeCooldown = (iTime + iCooldown);
					if (g_esGhostPlayer[tank].g_iRangeCooldown != -1 && g_esGhostPlayer[tank].g_iRangeCooldown >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman9", (g_esGhostPlayer[tank].g_iRangeCooldown - iTime));
					}
				}
				else if (((flags & MT_ATTACK_CLAW) || (flags & MT_ATTACK_MELEE)) && (g_esGhostPlayer[tank].g_iCooldown2 == -1 || g_esGhostPlayer[tank].g_iCooldown2 <= iTime))
				{
					iCooldown = (pos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, pos)) : g_esGhostCache[tank].g_iGhostCooldown;
					iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGhostCache[tank].g_iHumanAbility == 1) ? g_esGhostCache[tank].g_iHumanCooldown : iCooldown;
					g_esGhostPlayer[tank].g_iCooldown2 = (iTime + iCooldown);
					if (g_esGhostPlayer[tank].g_iCooldown2 != -1 && g_esGhostPlayer[tank].g_iCooldown2 >= iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman9", (g_esGhostPlayer[tank].g_iCooldown2 - iTime));
					}
				}

				int iSlot = 0, iStart = MT_DoesSurvivorHaveRewardType(survivor, MT_REWARD_INFAMMO) ? 1 : 0;
				for (int iBit = iStart; iBit < 5; iBit++)
				{
					iSlot = GetPlayerWeaponSlot(survivor, iBit);
					if ((g_esGhostCache[tank].g_iGhostWeaponSlots == 0 || (g_esGhostCache[tank].g_iGhostWeaponSlots & (1 << iBit))) && iSlot > MaxClients)
					{
						SDKHooks_DropWeapon(survivor, iSlot, NULL_VECTOR, NULL_VECTOR);
					}
				}

				vScreenEffect(survivor, tank, g_esGhostCache[tank].g_iGhostEffect, flags);

				switch (MT_GetRandomInt(1, 2))
				{
					case 1: EmitSoundToClient(survivor, SOUND_DEATH, tank);
					case 2: EmitSoundToClient(survivor, SOUND_DEATH2, tank);
				}

				if (g_esGhostCache[tank].g_iGhostMessage & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Ghost", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Ghost", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esGhostPlayer[tank].g_iRangeCooldown == -1 || g_esGhostPlayer[tank].g_iRangeCooldown <= iTime))
			{
				if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGhostCache[tank].g_iHumanAbility == 1 && !g_esGhostPlayer[tank].g_bFailed)
				{
					g_esGhostPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman3");
				}
			}
		}
		else if (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGhostCache[tank].g_iHumanAbility == 1 && !g_esGhostPlayer[tank].g_bNoAmmo)
		{
			g_esGhostPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostAmmo2");
		}
	}
}

void vGhostCopyStats2(int oldTank, int newTank)
{
	g_esGhostPlayer[newTank].g_iAmmoCount = g_esGhostPlayer[oldTank].g_iAmmoCount;
	g_esGhostPlayer[newTank].g_iAmmoCount2 = g_esGhostPlayer[oldTank].g_iAmmoCount2;
	g_esGhostPlayer[newTank].g_iCooldown = g_esGhostPlayer[oldTank].g_iCooldown;
	g_esGhostPlayer[newTank].g_iCooldown2 = g_esGhostPlayer[oldTank].g_iCooldown2;
	g_esGhostPlayer[newTank].g_iRangeCooldown = g_esGhostPlayer[oldTank].g_iRangeCooldown;
}

void vRemoveGhost(int tank)
{
	g_esGhostPlayer[tank].g_bActivated = false;
	g_esGhostPlayer[tank].g_bActivated2 = false;
	g_esGhostPlayer[tank].g_bFailed = false;
	g_esGhostPlayer[tank].g_bNoAmmo = false;
	g_esGhostPlayer[tank].g_bPhased = false;
	g_esGhostPlayer[tank].g_iAmmoCount = 0;
	g_esGhostPlayer[tank].g_iAmmoCount2 = 0;
	g_esGhostPlayer[tank].g_iCooldown = -1;
	g_esGhostPlayer[tank].g_iCooldown2 = -1;
	g_esGhostPlayer[tank].g_iDuration = -1;
	g_esGhostPlayer[tank].g_iGhostAlpha = 255;
	g_esGhostPlayer[tank].g_iRangeCooldown = -1;

	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		g_esGhostPlayer[tank].g_bAffected[iInfected] = false;
	}
}

void vRenderProps(int tank, RenderMode mode, int alpha = 255)
{
	int iProp = -1, iTank;
	while ((iProp = FindEntityByClassname(iProp, "prop_dynamic")) != INVALID_ENT_REFERENCE)
	{
		char sModel[128];
		GetEntPropString(iProp, Prop_Data, "m_ModelName", sModel, sizeof sModel);
		if (StrEqual(sModel, MODEL_OXYGENTANK, false) || StrEqual(sModel, MODEL_CONCRETE_CHUNK, false) || StrEqual(sModel, MODEL_TREE_TRUNK, false) || StrEqual(sModel, MODEL_TIRES, false) || StrEqual(sModel, MODEL_PROPANETANK, false) || StrEqual(sModel, MODEL_TANK_MAIN, false) || StrEqual(sModel, MODEL_TANK_DLC, false) || StrEqual(sModel, MODEL_TANK_L4D1, false))
		{
			iTank = GetEntPropEnt(iProp, Prop_Data, "m_hOwnerEntity");
			if (iTank == tank)
			{
				SetEntityRenderMode(iProp, mode);
				SetEntData(iProp, (GetEntSendPropOffs(iProp, "m_clrRender") + 3), alpha, 1, true);
			}
		}
	}

	iProp = -1;
	while ((iProp = FindEntityByClassname(iProp, "env_steam")) != INVALID_ENT_REFERENCE)
	{
		iTank = GetEntPropEnt(iProp, Prop_Data, "m_hOwnerEntity");
		if (iTank == tank)
		{
			SetEntityRenderMode(iProp, mode);
			SetEntData(iProp, (GetEntSendPropOffs(iProp, "m_clrRender") + 3), alpha, 1, true);
		}
	}

	char sColor[12];
	int iColor[4];
	iProp = -1;
	while ((iProp = FindEntityByClassname(iProp, "light_dynamic")) != INVALID_ENT_REFERENCE)
	{
		iTank = GetEntPropEnt(iProp, Prop_Data, "m_hOwnerEntity");
		if (iTank == tank)
		{
			SetEntityRenderMode(iProp, mode);
			MT_GetPropColors(tank, 7, iColor[0], iColor[1], iColor[2], iColor[3]);
			FormatEx(sColor, sizeof sColor, "%i %i %i %i", iGetRandomColor(iColor[0]), iGetRandomColor(iColor[1]), iGetRandomColor(iColor[2]), alpha);
			DispatchKeyValue(iProp, "_light", sColor);
		}
	}
}

void vRenderSpecials(int tank, bool mode, int red = 255, int green = 255, int blue = 255)
{
	float flTankPos[3], flInfectedPos[3];
	if (mode)
	{
		GetClientAbsOrigin(tank, flTankPos);
	}

	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (bIsSpecialInfected(iInfected, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			switch (mode)
			{
				case true:
				{
					GetClientAbsOrigin(iInfected, flInfectedPos);
					if (g_esGhostPlayer[tank].g_bAffected[iInfected] || GetVectorDistance(flTankPos, flInfectedPos) <= g_esGhostCache[tank].g_flGhostSpecialsRange)
					{
						g_esGhostPlayer[tank].g_bAffected[iInfected] = true;

						SetEntityRenderMode(iInfected, RENDER_TRANSCOLOR);
						SetEntityRenderColor(iInfected, red, green, blue, g_esGhostPlayer[tank].g_iGhostAlpha);
					}
				}
				case false:
				{
					g_esGhostPlayer[tank].g_bAffected[iInfected] = false;

					SetEntityRenderMode(iInfected, RENDER_NORMAL);
					SetEntityRenderColor(iInfected, red, green, blue, 255);
				}
			}
		}
	}
}

void vGhostReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveGhost(iPlayer);
		}
	}
}

void vGhostReset2(int tank)
{
	g_esGhostPlayer[tank].g_bActivated = false;
	g_esGhostPlayer[tank].g_bPhased = false;
	g_esGhostPlayer[tank].g_iGhostAlpha = 255;

	int iTime = GetTime(), iPos = g_esGhostAbility[g_esGhostPlayer[tank].g_iTankType].g_iComboPosition, iCooldown = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(tank, 2, iPos)) : g_esGhostCache[tank].g_iGhostCooldown;
	iCooldown = (bIsInfected(tank, MT_CHECK_FAKECLIENT) && g_esGhostCache[tank].g_iHumanAbility == 1 && g_esGhostCache[tank].g_iHumanMode == 0 && g_esGhostPlayer[tank].g_iAmmoCount < g_esGhostCache[tank].g_iHumanAmmo && g_esGhostCache[tank].g_iHumanAmmo > 0) ? g_esGhostCache[tank].g_iHumanCooldown : iCooldown;
	g_esGhostPlayer[tank].g_iCooldown = (iTime + iCooldown);
	if (g_esGhostPlayer[tank].g_iCooldown != -1 && g_esGhostPlayer[tank].g_iCooldown >= iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman8", (g_esGhostPlayer[tank].g_iCooldown - iTime));
	}
}

void vGhostResetRender(int tank)
{
	int iSkinColor[4];
	GetEntityRenderColor(tank, iSkinColor[0], iSkinColor[1], iSkinColor[2], iSkinColor[3]);
	vRenderProps(tank, RENDER_TRANSCOLOR, g_esGhostPlayer[tank].g_iGhostAlpha);
	SetEntityRenderMode(tank, RENDER_TRANSCOLOR);
	SetEntityRenderColor(tank, iSkinColor[0], iSkinColor[1], iSkinColor[2], g_esGhostPlayer[tank].g_iGhostAlpha);
}

void tTimerGhostCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esGhostAbility[g_esGhostPlayer[iTank].g_iTankType].g_iAccessFlags, g_esGhostPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esGhostPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esGhostCache[iTank].g_iGhostAbility == 0 || g_esGhostCache[iTank].g_iGhostAbility == 2)
	{
		return;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vGhostAbility(iTank, true, flRandom, iPos);
}

void tTimerGhostCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esGhostAbility[g_esGhostPlayer[iTank].g_iTankType].g_iAccessFlags, g_esGhostPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esGhostPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esGhostCache[iTank].g_iGhostAbility == 0 || g_esGhostCache[iTank].g_iGhostAbility == 1)
	{
		return;
	}

	int iPos = pack.ReadCell();
	vGhostAbility(iTank, false, .pos = iPos);
}

void tTimerGhostCombo3(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		return;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esGhostAbility[g_esGhostPlayer[iTank].g_iTankType].g_iAccessFlags, g_esGhostPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esGhostPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || g_esGhostCache[iTank].g_iGhostHit == 0)
	{
		return;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof sClassname);
	if ((g_esGhostCache[iTank].g_iGhostHitMode == 0 || g_esGhostCache[iTank].g_iGhostHitMode == 1) && (bIsSpecialInfected(iTank) || StrEqual(sClassname[7], "tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vGhostHit(iSurvivor, iTank, flRandom, flChance, g_esGhostCache[iTank].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
	}
	else if ((g_esGhostCache[iTank].g_iGhostHitMode == 0 || g_esGhostCache[iTank].g_iGhostHitMode == 2) && StrEqual(sClassname[7], "melee"))
	{
		vGhostHit(iSurvivor, iTank, flRandom, flChance, g_esGhostCache[iTank].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
	}
}

Action tTimerGhost(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esGhostCache[iTank].g_flOpenAreasOnly) || bIsAreaWide(iTank, g_esGhostCache[iTank].g_flCloseAreasOnly) || MT_DoesTypeRequireHumans(g_esGhostPlayer[iTank].g_iTankType, iTank) || (g_esGhostCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esGhostCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esGhostAbility[g_esGhostPlayer[iTank].g_iTankType].g_iAccessFlags, g_esGhostPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esGhostPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || iType != g_esGhostPlayer[iTank].g_iTankType || (g_esGhostCache[iTank].g_iGhostAbility != 2 && g_esGhostCache[iTank].g_iGhostAbility != 3) || !g_esGhostPlayer[iTank].g_bActivated)
	{
		g_esGhostPlayer[iTank].g_bActivated = false;
		g_esGhostPlayer[iTank].g_bPhased = false;
		g_esGhostPlayer[iTank].g_iGhostAlpha = 255;

		vRenderSpecials(iTank, false);

		return Plugin_Stop;
	}

	bool bHuman = bIsInfected(iTank, MT_CHECK_FAKECLIENT);
	int iTime = pack.ReadCell(), iCurrentTime = GetTime(), iPos = pack.ReadCell(),
		iDuration = (iPos != -1) ? RoundToNearest(MT_GetCombinationSetting(iTank, 5, iPos)) : g_esGhostCache[iTank].g_iGhostDuration;
	iDuration = (bHuman && g_esGhostCache[iTank].g_iHumanAbility == 1) ? g_esGhostCache[iTank].g_iHumanDuration : iDuration;
	if (iDuration > 0 && (!bHuman || (bHuman && g_esGhostCache[iTank].g_iHumanAbility == 1 && g_esGhostCache[iTank].g_iHumanMode == 0)) && (iTime + iDuration) < iCurrentTime && (g_esGhostPlayer[iTank].g_iCooldown == -1 || g_esGhostPlayer[iTank].g_iCooldown < iCurrentTime))
	{
		vRenderSpecials(iTank, false);
		vGhostReset2(iTank);

		return Plugin_Stop;
	}

	g_esGhostPlayer[iTank].g_iGhostAlpha -= g_esGhostCache[iTank].g_iGhostFadeAlpha;

	if (g_esGhostPlayer[iTank].g_iGhostAlpha <= g_esGhostCache[iTank].g_iGhostFadeLimit)
	{
		g_esGhostPlayer[iTank].g_bPhased = false;
		g_esGhostPlayer[iTank].g_iGhostAlpha = g_esGhostCache[iTank].g_iGhostFadeLimit;

		if (!g_esGhostPlayer[iTank].g_bActivated2)
		{
			g_esGhostPlayer[iTank].g_bActivated2 = true;
			g_esGhostPlayer[iTank].g_iDuration = (iCurrentTime + g_esGhostCache[iTank].g_iGhostFadeDelay);
		}
	}

	vGhostResetRender(iTank);

	float flRandom = pack.ReadFloat();
	if (g_esGhostCache[iTank].g_iGhostSpecials == 1 && flRandom <= g_esGhostCache[iTank].g_flGhostSpecialsChance)
	{
		int iSkinColor[4];
		GetEntityRenderColor(iTank, iSkinColor[0], iSkinColor[1], iSkinColor[2], iSkinColor[3]);
		vRenderSpecials(iTank, true, iSkinColor[0], iSkinColor[1], iSkinColor[2]);
	}

	return Plugin_Continue;
}

Action tTimerRenderRock(Handle timer, DataPack pack)
{
	pack.Reset();

	int iRock = EntRefToEntIndex(pack.ReadCell()), iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock) || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esGhostAbility[g_esGhostPlayer[iTank].g_iTankType].g_iAccessFlags, g_esGhostPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esGhostPlayer[iTank].g_iTankType, iTank) || !MT_IsCustomTankSupported(iTank) || (g_esGhostCache[iTank].g_iGhostAbility != 2 && g_esGhostCache[iTank].g_iGhostAbility != 3) || !g_esGhostPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	SetEntityRenderMode(iRock, GetEntityRenderMode(iTank));
	SetEntData(iRock, (GetEntSendPropOffs(iRock, "m_clrRender") + 3), g_esGhostPlayer[iTank].g_iGhostAlpha, 1, true);

	return Plugin_Continue;
}