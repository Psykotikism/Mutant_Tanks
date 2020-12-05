/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2020  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#include <sourcemod>
#include <sdkhooks>
#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Ghost Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank cloaks itself and disarms survivors.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Ghost Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_CONCRETE_CHUNK "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_TREE_TRUNK "models/props_foliage/tree_trunk.mdl"
#define MODEL_JETPACK "models/props_equipment/oxygentank01.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_TANK_MAIN "models/infected/hulk.mdl"
#define MODEL_TANK_DLC "models/infected/hulk_dlc3.mdl"
#define MODEL_TANK_L4D1 "models/infected/hulk_l4d1.mdl"
#define MODEL_TIRES "models/props_vehicles/tire001c_car.mdl"

#define SOUND_DEATH "npc/infected/action/die/male/death_42.wav"
#define SOUND_DEATH2 "npc/infected/action/die/male/death_43.wav"

#define MT_CONFIG_SECTION "ghostability"
#define MT_CONFIG_SECTION2 "ghost ability"
#define MT_CONFIG_SECTION3 "ghost_ability"
#define MT_CONFIG_SECTION4 "ghost"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_GHOST "Ghost Ability"

enum struct esPlayer
{
	bool g_bActivated;
	bool g_bActivated2;
	bool g_bAffected[MAXPLAYERS + 1];
	bool g_bFailed;
	bool g_bNoAmmo;

	float g_flGhostChance;
	float g_flGhostFadeRate;
	float g_flGhostRange;
	float g_flGhostRangeChance;
	float g_flGhostSpecialsChance;
	float g_flGhostSpecialsRange;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iAmmoCount2;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iCooldown2;
	int g_iDuration;
	int g_iGhostAbility;
	int g_iGhostAlpha;
	int g_iGhostEffect;
	int g_iGhostFadeAlpha;
	int g_iGhostFadeDelay;
	int g_iGhostFadeLimit;
	int g_iGhostHit;
	int g_iGhostHitMode;
	int g_iGhostMessage;
	int g_iGhostSpecials;
	int g_iGhostWeaponSlots;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flGhostChance;
	float g_flGhostFadeRate;
	float g_flGhostRange;
	float g_flGhostRangeChance;
	float g_flGhostSpecialsChance;
	float g_flGhostSpecialsRange;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iGhostAbility;
	int g_iGhostEffect;
	int g_iGhostFadeAlpha;
	int g_iGhostFadeDelay;
	int g_iGhostFadeLimit;
	int g_iGhostHit;
	int g_iGhostHitMode;
	int g_iGhostMessage;
	int g_iGhostSpecials;
	int g_iGhostWeaponSlots;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flGhostChance;
	float g_flGhostFadeRate;
	float g_flGhostRange;
	float g_flGhostRangeChance;
	float g_flGhostSpecialsChance;
	float g_flGhostSpecialsRange;

	int g_iComboAbility;
	int g_iGhostAbility;
	int g_iGhostEffect;
	int g_iGhostFadeAlpha;
	int g_iGhostFadeDelay;
	int g_iGhostFadeLimit;
	int g_iGhostHit;
	int g_iGhostHitMode;
	int g_iGhostMessage;
	int g_iGhostSpecials;
	int g_iGhostWeaponSlots;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanDuration;
	int g_iHumanMode;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

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

public void OnMapStart()
{
	PrecacheSound(SOUND_DEATH, true);
	PrecacheSound(SOUND_DEATH2, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveGhost(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveGhost(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdGhostInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

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
		case false: vGhostMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vGhostMenu(int client, int item)
{
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
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iGhostMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iGhostAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount, g_esCache[param1].g_iHumanAmmo);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount2, g_esCache[param1].g_iHumanAmmo);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "GhostDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iHumanDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vGhostMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pGhost = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "GhostMenu", param1);
			pGhost.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);
					case 1: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Ammunition", param1);
					case 2: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);
					case 3: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "ButtonMode", param1);
					case 4: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					case 5: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					case 6: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);
					case 7: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_GHOST, MT_MENU_GHOST);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_GHOST, false))
	{
		vGhostMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_GHOST, false))
	{
		FormatEx(buffer, size, "%T", "GhostMenu2", client);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(client) || !g_esPlayer[client].g_bActivated2 || g_esPlayer[client].g_iDuration == -1)
	{
		return Plugin_Continue;
	}

	static int iTime;
	iTime = GetTime();
	if (g_esPlayer[client].g_iDuration < iTime)
	{
		if (g_esCache[client].g_iGhostMessage & MT_MESSAGE_SPECIAL)
		{
			char sTankName[33];
			MT_GetTankName(client, sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Ghost3", sTankName);
			MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Ghost3", LANG_SERVER, sTankName);
		}

		g_esPlayer[client].g_bActivated2 = false;
		g_esPlayer[client].g_iDuration = -1;
		g_esPlayer[client].g_iGhostAlpha = 255;

		vResetRender(client);
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && MT_IsCustomTankSupported(attacker) && (g_esCache[attacker].g_iGhostHitMode == 0 || g_esCache[attacker].g_iGhostHitMode == 1) && bIsSurvivor(victim) && g_esCache[attacker].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vGhostHit(victim, attacker, GetRandomFloat(0.1, 100.0), g_esCache[attacker].g_flGhostChance, g_esCache[attacker].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && MT_IsCustomTankSupported(victim) && (g_esCache[victim].g_iGhostHitMode == 0 || g_esCache[victim].g_iGhostHitMode == 2) && bIsSurvivor(attacker) && g_esCache[victim].g_iComboAbility == 0)
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vGhostHit(attacker, victim, GetRandomFloat(0.1, 100.0), g_esCache[victim].g_flGhostChance, g_esCache[victim].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

public void MT_OnPluginCheck(ArrayList &list)
{
	char sName[32];
	GetPluginFilename(null, sName, sizeof(sName));
	list.PushString(sName);
}

public void MT_OnAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString(MT_CONFIG_SECTION);
	list2.PushString(MT_CONFIG_SECTION2);
	list3.PushString(MT_CONFIG_SECTION3);
	list4.PushString(MT_CONFIG_SECTION4);
}

public void MT_OnCombineAbilities(int tank, int type, float random, const char[] combo, int survivor, int weapon, const char[] classname)
{
	if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	static char sAbilities[320], sSet[4][32];
	FormatEx(sAbilities, sizeof(sAbilities), ",%s,", combo);
	FormatEx(sSet[0], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION);
	FormatEx(sSet[1], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION2);
	FormatEx(sSet[2], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION3);
	FormatEx(sSet[3], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION4);
	if (g_esCache[tank].g_iComboAbility == 1 && (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1))
	{
		static char sSubset[10][32];
		ExplodeString(combo, ",", sSubset, sizeof(sSubset), sizeof(sSubset[]));
		for (int iPos = 0; iPos < sizeof(sSubset); iPos++)
		{
			if (StrEqual(sSubset[iPos], MT_CONFIG_SECTION, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION2, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION3, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION4, false))
			{
				static float flDelay;
				flDelay = MT_GetCombinationSetting(tank, 3, iPos);

				switch (type)
				{
					case MT_COMBO_MAINRANGE:
					{
						if (g_esCache[tank].g_iGhostAbility == 1 || g_esCache[tank].g_iGhostAbility == 3)
						{
							switch (flDelay)
							{
								case 0.0: vGhostAbility(tank, true, random, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerCombo, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteFloat(random);
									dpCombo.WriteCell(iPos);
								}
							}
						}
						else if (g_esCache[tank].g_iGhostAbility == 2 || g_esCache[tank].g_iGhostAbility == 3)
						{
							switch (flDelay)
							{
								case 0.0: vGhostAbility(tank, false, _, iPos);
								default:
								{
									DataPack dpCombo;
									CreateDataTimer(flDelay, tTimerCombo2, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
									dpCombo.WriteCell(GetClientUserId(tank));
									dpCombo.WriteCell(iPos);
								}
							}
						}
					}
					case MT_COMBO_MELEEHIT:
					{
						static float flChance;
						flChance = MT_GetCombinationSetting(tank, 1, iPos);

						switch (flDelay)
						{
							case 0.0:
							{
								if ((g_esCache[tank].g_iGhostHitMode == 0 || g_esCache[tank].g_iGhostHitMode == 1) && (StrEqual(classname, "weapon_tank_claw") || StrEqual(classname, "tank_rock")))
								{
									vGhostHit(survivor, tank, random, flChance, g_esCache[tank].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
								}
								else if ((g_esCache[tank].g_iGhostHitMode == 0 || g_esCache[tank].g_iGhostHitMode == 2) && StrEqual(classname, "weapon_melee"))
								{
									vGhostHit(survivor, tank, random, flChance, g_esCache[tank].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
								}
							}
							default:
							{
								DataPack dpCombo;
								CreateDataTimer(flDelay, tTimerCombo3, dpCombo, TIMER_FLAG_NO_MAPCHANGE);
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

public void MT_OnConfigsLoad(int mode)
{
	switch (mode)
	{
		case 1:
		{
			for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
			{
				g_esAbility[iIndex].g_iAccessFlags = 0;
				g_esAbility[iIndex].g_iImmunityFlags = 0;
				g_esAbility[iIndex].g_iComboAbility = 0;
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iHumanCooldown = 30;
				g_esAbility[iIndex].g_iHumanDuration = 5;
				g_esAbility[iIndex].g_iHumanMode = 1;
				g_esAbility[iIndex].g_iOpenAreasOnly = 0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iGhostAbility = 0;
				g_esAbility[iIndex].g_iGhostEffect = 0;
				g_esAbility[iIndex].g_iGhostMessage = 0;
				g_esAbility[iIndex].g_flGhostChance = 33.3;
				g_esAbility[iIndex].g_iGhostFadeAlpha = 2;
				g_esAbility[iIndex].g_iGhostFadeDelay = 5;
				g_esAbility[iIndex].g_iGhostFadeLimit = 0;
				g_esAbility[iIndex].g_flGhostFadeRate = 0.1;
				g_esAbility[iIndex].g_iGhostHit = 0;
				g_esAbility[iIndex].g_iGhostHitMode = 0;
				g_esAbility[iIndex].g_flGhostRange = 150.0;
				g_esAbility[iIndex].g_flGhostRangeChance = 15.0;
				g_esAbility[iIndex].g_iGhostSpecials = 1;
				g_esAbility[iIndex].g_flGhostSpecialsChance = 33.3;
				g_esAbility[iIndex].g_flGhostSpecialsRange = 500.0;
				g_esAbility[iIndex].g_iGhostWeaponSlots = 0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esPlayer[iPlayer].g_iAccessFlags = 0;
					g_esPlayer[iPlayer].g_iImmunityFlags = 0;
					g_esPlayer[iPlayer].g_iComboAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iHumanDuration = 0;
					g_esPlayer[iPlayer].g_iHumanMode = 0;
					g_esPlayer[iPlayer].g_iOpenAreasOnly = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iGhostAbility = 0;
					g_esPlayer[iPlayer].g_iGhostEffect = 0;
					g_esPlayer[iPlayer].g_iGhostMessage = 0;
					g_esPlayer[iPlayer].g_flGhostChance = 0.0;
					g_esPlayer[iPlayer].g_iGhostFadeAlpha = 0;
					g_esPlayer[iPlayer].g_iGhostFadeDelay = 0;
					g_esPlayer[iPlayer].g_iGhostFadeLimit = 0;
					g_esPlayer[iPlayer].g_flGhostFadeRate = 0.0;
					g_esPlayer[iPlayer].g_iGhostHit = 0;
					g_esPlayer[iPlayer].g_iGhostHitMode = 0;
					g_esPlayer[iPlayer].g_flGhostRange = 0.0;
					g_esPlayer[iPlayer].g_flGhostRangeChance = 0.0;
					g_esPlayer[iPlayer].g_iGhostSpecials = 0;
					g_esPlayer[iPlayer].g_flGhostSpecialsChance = 0.0;
					g_esPlayer[iPlayer].g_flGhostSpecialsRange = 0.0;
					g_esPlayer[iPlayer].g_iGhostWeaponSlots = 0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esPlayer[admin].g_iComboAbility, value, 0, 1);
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHumanDuration = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esPlayer[admin].g_iHumanDuration, value, 1, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_iOpenAreasOnly = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_iOpenAreasOnly, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iGhostAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iGhostAbility, value, 0, 3);
		g_esPlayer[admin].g_iGhostEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esPlayer[admin].g_iGhostEffect, value, 0, 7);
		g_esPlayer[admin].g_iGhostMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iGhostMessage, value, 0, 7);
		g_esPlayer[admin].g_flGhostChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostChance", "Ghost Chance", "Ghost_Chance", "chance", g_esPlayer[admin].g_flGhostChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iGhostFadeAlpha = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostFadeAlpha", "Ghost Fade Alpha", "Ghost_Fade_Alpha", "fadealpha", g_esPlayer[admin].g_iGhostFadeAlpha, value, 0, 255);
		g_esPlayer[admin].g_iGhostFadeDelay = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostFadeDelay", "Ghost Fade Delay", "Ghost_Fade_Delay", "fadedelay", g_esPlayer[admin].g_iGhostFadeDelay, value, 1, 999999);
		g_esPlayer[admin].g_iGhostFadeLimit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostFadeLimit", "Ghost Fade Limit", "Ghost_Fade_Limit", "fadelimit", g_esPlayer[admin].g_iGhostFadeLimit, value, 0, 255);
		g_esPlayer[admin].g_flGhostFadeRate = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostFadeRate", "Ghost Fade Rate", "Ghost_Fade_Rate", "faderate", g_esPlayer[admin].g_flGhostFadeRate, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iGhostHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostHit", "Ghost Hit", "Ghost_Hit", "hit", g_esPlayer[admin].g_iGhostHit, value, 0, 1);
		g_esPlayer[admin].g_iGhostHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostHitMode", "Ghost Hit Mode", "Ghost_Hit_Mode", "hitmode", g_esPlayer[admin].g_iGhostHitMode, value, 0, 2);
		g_esPlayer[admin].g_flGhostRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostRange", "Ghost Range", "Ghost_Range", "range", g_esPlayer[admin].g_flGhostRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_flGhostRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostRangeChance", "Ghost Range Chance", "Ghost_Range_Chance", "rangechance", g_esPlayer[admin].g_flGhostRangeChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iGhostSpecials = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostSpecials", "Ghost Specials", "Ghost_Specials", "specials", g_esPlayer[admin].g_iGhostSpecials, value, 0, 1);
		g_esPlayer[admin].g_flGhostSpecialsChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostSpecialsChance", "Ghost Specials Chance", "Ghost_Specials_Chance", "specialschance", g_esPlayer[admin].g_flGhostSpecialsChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flGhostSpecialsRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostSpecialsRange", "Ghost Specials Range", "Ghost_Specials_Range", "specialsrange", g_esPlayer[admin].g_flGhostSpecialsRange, value, 1.0, 999999.0);
		g_esPlayer[admin].g_iGhostWeaponSlots = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostWeaponSlots", "Ghost Weapon Slots", "Ghost_Weapon_Slots", "slots", g_esPlayer[admin].g_iGhostWeaponSlots, value, 0, 31);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esPlayer[admin].g_iImmunityFlags = ReadFlagString(value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esAbility[type].g_iComboAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanDuration = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esAbility[type].g_iHumanDuration, value, 1, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iOpenAreasOnly = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_iOpenAreasOnly, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iGhostAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iGhostAbility, value, 0, 3);
		g_esAbility[type].g_iGhostEffect = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iGhostEffect, value, 0, 7);
		g_esAbility[type].g_iGhostMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iGhostMessage, value, 0, 7);
		g_esAbility[type].g_flGhostChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostChance", "Ghost Chance", "Ghost_Chance", "chance", g_esAbility[type].g_flGhostChance, value, 0.0, 100.0);
		g_esAbility[type].g_iGhostFadeAlpha = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostFadeAlpha", "Ghost Fade Alpha", "Ghost_Fade_Alpha", "fadealpha", g_esAbility[type].g_iGhostFadeAlpha, value, 0, 255);
		g_esAbility[type].g_iGhostFadeDelay = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostFadeDelay", "Ghost Fade Delay", "Ghost_Fade_Delay", "fadedelay", g_esAbility[type].g_iGhostFadeDelay, value, 1, 999999);
		g_esAbility[type].g_iGhostFadeLimit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostFadeLimit", "Ghost Fade Limit", "Ghost_Fade_Limit", "fadelimit", g_esAbility[type].g_iGhostFadeLimit, value, 0, 255);
		g_esAbility[type].g_flGhostFadeRate = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostFadeRate", "Ghost Fade Rate", "Ghost_Fade_Rate", "faderate", g_esAbility[type].g_flGhostFadeRate, value, 0.1, 999999.0);
		g_esAbility[type].g_iGhostHit = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostHit", "Ghost Hit", "Ghost_Hit", "hit", g_esAbility[type].g_iGhostHit, value, 0, 1);
		g_esAbility[type].g_iGhostHitMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostHitMode", "Ghost Hit Mode", "Ghost_Hit_Mode", "hitmode", g_esAbility[type].g_iGhostHitMode, value, 0, 2);
		g_esAbility[type].g_flGhostRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostRange", "Ghost Range", "Ghost_Range", "range", g_esAbility[type].g_flGhostRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flGhostRangeChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostRangeChance", "Ghost Range Chance", "Ghost_Range_Chance", "rangechance", g_esAbility[type].g_flGhostRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_iGhostSpecials = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostSpecials", "Ghost Specials", "Ghost_Specials", "specials", g_esAbility[type].g_iGhostSpecials, value, 0, 1);
		g_esAbility[type].g_flGhostSpecialsChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostSpecialsChance", "Ghost Specials Chance", "Ghost_Specials_Chance", "specialschance", g_esAbility[type].g_flGhostSpecialsChance, value, 0.0, 100.0);
		g_esAbility[type].g_flGhostSpecialsRange = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostSpecialsRange", "Ghost Specials Range", "Ghost_Specials_Range", "specialsrange", g_esAbility[type].g_flGhostSpecialsRange, value, 1.0, 999999.0);
		g_esAbility[type].g_iGhostWeaponSlots = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "GhostWeaponSlots", "Ghost Weapon Slots", "Ghost_Weapon_Slots", "slots", g_esAbility[type].g_iGhostWeaponSlots, value, 0, 31);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esAbility[type].g_iImmunityFlags = ReadFlagString(value);
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	g_esCache[tank].g_flGhostChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGhostChance, g_esAbility[type].g_flGhostChance);
	g_esCache[tank].g_flGhostFadeRate = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGhostFadeRate, g_esAbility[type].g_flGhostFadeRate);
	g_esCache[tank].g_flGhostRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGhostRange, g_esAbility[type].g_flGhostRange);
	g_esCache[tank].g_flGhostRangeChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGhostRangeChance, g_esAbility[type].g_flGhostRangeChance);
	g_esCache[tank].g_flGhostSpecialsChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGhostSpecialsChance, g_esAbility[type].g_flGhostSpecialsChance);
	g_esCache[tank].g_flGhostSpecialsRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flGhostSpecialsRange, g_esAbility[type].g_flGhostSpecialsRange);
	g_esCache[tank].g_iGhostAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostAbility, g_esAbility[type].g_iGhostAbility);
	g_esCache[tank].g_iGhostEffect = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostEffect, g_esAbility[type].g_iGhostEffect);
	g_esCache[tank].g_iGhostFadeAlpha = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostFadeAlpha, g_esAbility[type].g_iGhostFadeAlpha);
	g_esCache[tank].g_iGhostFadeDelay = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostFadeDelay, g_esAbility[type].g_iGhostFadeDelay);
	g_esCache[tank].g_iGhostFadeLimit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostFadeLimit, g_esAbility[type].g_iGhostFadeLimit);
	g_esCache[tank].g_iGhostHit = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostHit, g_esAbility[type].g_iGhostHit);
	g_esCache[tank].g_iGhostHitMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostHitMode, g_esAbility[type].g_iGhostHitMode);
	g_esCache[tank].g_iGhostMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostMessage, g_esAbility[type].g_iGhostMessage);
	g_esCache[tank].g_iGhostSpecials = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostSpecials, g_esAbility[type].g_iGhostSpecials);
	g_esCache[tank].g_iGhostWeaponSlots = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iGhostWeaponSlots, g_esAbility[type].g_iGhostWeaponSlots);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanDuration, g_esAbility[type].g_iHumanDuration);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_iOpenAreasOnly = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOpenAreasOnly, g_esAbility[type].g_iOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveGhost(oldTank);
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsTank(iTank))
		{
			vCopyStats(iBot, iTank);
			vRemoveGhost(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
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
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start"))
	{
		vReset();
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iGhostAbility > 0 && g_esCache[tank].g_iComboAbility == 0)
	{
		vGhostAbility(tank, false);
		vGhostAbility(tank, true, GetRandomFloat(0.1, 100.0));
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		static int iTime;
		iTime = GetTime();
		if (button & MT_MAIN_KEY)
		{
			if ((g_esCache[tank].g_iGhostAbility == 2 || g_esCache[tank].g_iGhostAbility == 3) && g_esCache[tank].g_iHumanAbility == 1)
			{
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;

				switch (g_esCache[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bActivated && !bRecharging)
						{
							vGhostAbility(tank, false);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman4");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman5", g_esPlayer[tank].g_iCooldown - iTime);
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bActivated && !bRecharging)
							{
								g_esPlayer[tank].g_bActivated = true;
								g_esPlayer[tank].g_iAmmoCount++;

								vGhost(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman4");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman5", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostAmmo");
						}
					}
				}
			}
		}

		if (button & MT_SUB_KEY)
		{
			if ((g_esCache[tank].g_iGhostAbility == 1 || g_esCache[tank].g_iGhostAbility == 3) && g_esCache[tank].g_iHumanAbility == 1)
			{
				switch (g_esPlayer[tank].g_iCooldown2 != -1 && g_esPlayer[tank].g_iCooldown2 > iTime)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman6", g_esPlayer[tank].g_iCooldown2 - iTime);
					case false: vGhostAbility(tank, true, GetRandomFloat(0.1, 100.0));
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iHumanAbility == 1)
	{
		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iHumanMode == 1 && g_esPlayer[tank].g_bActivated && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < GetTime()))
			{
				vReset2(tank);
			}
		}
	}
}

public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
{
	vRenderProps(tank, RENDER_NORMAL);
	vRemoveGhost(tank);
}

public void MT_OnPostTankSpawn(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME))
	{
		vRenderProps(tank, RENDER_NORMAL);
	}
}

public void MT_OnRockThrow(int tank, int rock)
{
	if (MT_IsTankSupported(tank) && MT_IsCustomTankSupported(tank) && (g_esCache[tank].g_iGhostAbility == 2 || g_esCache[tank].g_iGhostAbility == 3))
	{
		DataPack dpRender;
		CreateDataTimer(0.1, tTimerRenderRock, dpRender, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpRender.WriteCell(EntIndexToEntRef(rock));
		dpRender.WriteCell(GetClientUserId(tank));
	}
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iAmmoCount = g_esPlayer[oldTank].g_iAmmoCount;
	g_esPlayer[newTank].g_iAmmoCount2 = g_esPlayer[oldTank].g_iAmmoCount2;
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
	g_esPlayer[newTank].g_iCooldown2 = g_esPlayer[oldTank].g_iCooldown2;
}

static void vGhost(int tank, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	static float flInterval;
	flInterval = (pos != -1) ? MT_GetCombinationSetting(tank, 5, pos) : g_esCache[tank].g_flGhostFadeRate;
	DataPack dpGhost;
	CreateDataTimer(flInterval, tTimerGhost, dpGhost, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpGhost.WriteCell(GetClientUserId(tank));
	dpGhost.WriteCell(g_esPlayer[tank].g_iTankType);
	dpGhost.WriteCell(GetTime());
	dpGhost.WriteFloat(GetRandomFloat(0.1, 100.0));

	SetEntityRenderMode(tank, RENDER_TRANSCOLOR);
}

static void vGhostAbility(int tank, bool main, float random = 0.0, int pos = -1)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_esCache[tank].g_iGhostAbility == 1 || g_esCache[tank].g_iGhostAbility == 3)
			{
				if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
				{
					g_esPlayer[tank].g_bFailed = false;
					g_esPlayer[tank].g_bNoAmmo = false;

					static float flTankPos[3], flSurvivorPos[3], flRange, flChance;
					GetClientAbsOrigin(tank, flTankPos);
					flRange = (pos != -1) ? MT_GetCombinationSetting(tank, 8, pos) : g_esCache[tank].g_flGhostRange;
					flChance = (pos != -1) ? MT_GetCombinationSetting(tank, 9, pos) : g_esCache[tank].g_flGhostRangeChance;
					static int iSurvivorCount;
					iSurvivorCount = 0;
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
						{
							GetClientAbsOrigin(iSurvivor, flSurvivorPos);
							if (GetVectorDistance(flTankPos, flSurvivorPos) <= flRange)
							{
								vGhostHit(iSurvivor, tank, random, flChance, g_esCache[tank].g_iGhostAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman7");
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostAmmo2");
				}
			}
		}
		case false:
		{
			if ((g_esCache[tank].g_iGhostAbility == 2 || g_esCache[tank].g_iGhostAbility == 3) && !g_esPlayer[tank].g_bActivated)
			{
				if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
				{
					g_esPlayer[tank].g_bActivated = true;
					g_esPlayer[tank].g_iGhostAlpha = 255;

					vGhost(tank, pos);

					if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
					{
						g_esPlayer[tank].g_iAmmoCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);
					}

					if (g_esCache[tank].g_iGhostMessage & MT_MESSAGE_SPECIAL)
					{
						static char sTankName[33];
						MT_GetTankName(tank, sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Ghost2", sTankName);
						MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Ghost2", LANG_SERVER, sTankName);
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostAmmo");
				}
			}
		}
	}
}

static void vGhostHit(int survivor, int tank, float random, float chance, int enabled, int messages, int flags)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[survivor].g_iImmunityFlags))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
		{
			static int iTime;
			iTime = GetTime();
			if (random <= chance)
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown2 == -1 || g_esPlayer[tank].g_iCooldown2 < iTime))
				{
					g_esPlayer[tank].g_iAmmoCount2++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman2", g_esPlayer[tank].g_iAmmoCount2, g_esCache[tank].g_iHumanAmmo);

					g_esPlayer[tank].g_iCooldown2 = (g_esPlayer[tank].g_iAmmoCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
					if (g_esPlayer[tank].g_iCooldown2 != -1 && g_esPlayer[tank].g_iCooldown2 > iTime)
					{
						MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman9", g_esPlayer[tank].g_iCooldown2 - iTime);
					}
				}

				for (int iBit = 0; iBit < 5; iBit++)
				{
					if (((g_esCache[tank].g_iGhostWeaponSlots & (1 << iBit)) || g_esCache[tank].g_iGhostWeaponSlots == 0) && GetPlayerWeaponSlot(survivor, iBit) > 0)
					{
						SDKHooks_DropWeapon(survivor, GetPlayerWeaponSlot(survivor, iBit), NULL_VECTOR, NULL_VECTOR);
					}
				}

				vEffect(survivor, tank, g_esCache[tank].g_iGhostEffect, flags);

				switch (GetRandomInt(1, 2))
				{
					case 1: EmitSoundToClient(survivor, SOUND_DEATH, tank);
					case 2: EmitSoundToClient(survivor, SOUND_DEATH2, tank);
				}

				if (g_esCache[tank].g_iGhostMessage & messages)
				{
					static char sTankName[33];
					MT_GetTankName(tank, sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Ghost", sTankName, survivor);
					MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Ghost", LANG_SERVER, sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && (g_esPlayer[tank].g_iCooldown2 == -1 || g_esPlayer[tank].g_iCooldown2 < iTime))
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman3");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bNoAmmo)
		{
			g_esPlayer[tank].g_bNoAmmo = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostAmmo2");
		}
	}
}

static void vRemoveGhost(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_bActivated2 = false;
	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_bNoAmmo = false;
	g_esPlayer[tank].g_iAmmoCount = 0;
	g_esPlayer[tank].g_iAmmoCount2 = 0;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCooldown2 = -1;
	g_esPlayer[tank].g_iDuration = -1;
	g_esPlayer[tank].g_iGhostAlpha = 255;

	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		g_esPlayer[tank].g_bAffected[iInfected] = false;
	}
}

static void vRenderProps(int tank, RenderMode mode, int alpha = 255)
{
	static int iProp;
	iProp = -1;
	while ((iProp = FindEntityByClassname(iProp, "prop_dynamic")) != INVALID_ENT_REFERENCE)
	{
		static char sModel[128];
		GetEntPropString(iProp, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		if (StrEqual(sModel, MODEL_JETPACK, false) || StrEqual(sModel, MODEL_CONCRETE_CHUNK, false) || StrEqual(sModel, MODEL_TREE_TRUNK, false) || StrEqual(sModel, MODEL_TIRES, false) || StrEqual(sModel, MODEL_PROPANETANK, false) || StrEqual(sModel, MODEL_TANK_MAIN, false) || StrEqual(sModel, MODEL_TANK_DLC, false) || StrEqual(sModel, MODEL_TANK_L4D1, false))
		{
			static int iTank;
			iTank = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
			if (iTank == tank)
			{
				if (StrEqual(sModel, MODEL_JETPACK, false))
				{
					static int iOzTankColor[4];
					MT_GetPropColors(tank, 2, iOzTankColor[0], iOzTankColor[1], iOzTankColor[2], iOzTankColor[3]);
					SetEntityRenderMode(iProp, mode);
					SetEntityRenderColor(iProp, iOzTankColor[0], iOzTankColor[1], iOzTankColor[2], alpha);
				}

				if (StrEqual(sModel, MODEL_CONCRETE_CHUNK, false) || StrEqual(sModel, MODEL_TREE_TRUNK, false))
				{
					static int iRockColor[4];
					MT_GetPropColors(tank, 4, iRockColor[0], iRockColor[1], iRockColor[2], iRockColor[3]);
					SetEntityRenderMode(iProp, mode);
					SetEntityRenderColor(iProp, iRockColor[0], iRockColor[1], iRockColor[2], alpha);
				}

				if (StrEqual(sModel, MODEL_TIRES, false))
				{
					static int iTireColor[4];
					MT_GetPropColors(tank, 5, iTireColor[0], iTireColor[1], iTireColor[2], iTireColor[3]);
					SetEntityRenderMode(iProp, mode);
					SetEntityRenderColor(iProp, iTireColor[0], iTireColor[1], iTireColor[2], alpha);
				}

				if (StrEqual(sModel, MODEL_PROPANETANK, false))
				{
					static int iPropTankColor[4];
					MT_GetPropColors(tank, 6, iPropTankColor[0], iPropTankColor[1], iPropTankColor[2], iPropTankColor[3]);
					SetEntityRenderMode(iProp, mode);
					SetEntityRenderColor(iProp, iPropTankColor[0], iPropTankColor[1], iPropTankColor[2], alpha);
				}

				if (StrEqual(sModel, MODEL_TANK_MAIN, false) || StrEqual(sModel, MODEL_TANK_DLC, false) || StrEqual(sModel, MODEL_TANK_L4D1, false))
				{
					static int iSkinColor[4];
					MT_GetTankColors(tank, 1, iSkinColor[0], iSkinColor[1], iSkinColor[2], iSkinColor[3]);
					SetEntityRenderMode(iProp, mode);
					SetEntityRenderColor(iProp, iSkinColor[0], iSkinColor[1], iSkinColor[2], alpha);
				}
			}
		}
	}

	iProp = -1;
	while ((iProp = FindEntityByClassname(iProp, "beam_spotlight")) != INVALID_ENT_REFERENCE)
	{
		static int iTank;
		iTank = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iTank == tank)
		{
			static char sParentName[64], sTargetName[64];
			GetEntPropString(iTank, Prop_Data, "m_iName", sTargetName, sizeof(sTargetName));
			FormatEx(sParentName, sizeof(sParentName), "mutant_tank_%i_%i_", iTank, MT_GetTankType(iTank));
			static int iColor[4];
			if (StrContains(sTargetName, sParentName, false) == 0)
			{
				MT_GetPropColors(tank, 1, iColor[0], iColor[1], iColor[2], iColor[3]);
				SetEntityRenderMode(iProp, mode);
				SetEntityRenderColor(iProp, iColor[0], iColor[1], iColor[2], alpha);
			}
			else
			{
				MT_GetPropColors(tank, 8, iColor[0], iColor[1], iColor[2], iColor[3]);
				SetEntityRenderMode(iProp, mode);
				SetEntityRenderColor(iProp, iColor[0], iColor[1], iColor[2], alpha);
			}
		}
	}

	iProp = -1;
	while ((iProp = FindEntityByClassname(iProp, "env_steam")) != INVALID_ENT_REFERENCE)
	{
		static int iTank;
		iTank = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iTank == tank)
		{
			static int iFlameColor[4];
			MT_GetPropColors(tank, 3, iFlameColor[0], iFlameColor[1], iFlameColor[2], iFlameColor[3]);
			SetEntityRenderMode(iProp, mode);
			SetEntityRenderColor(iProp, iFlameColor[0], iFlameColor[1], iFlameColor[2], alpha);
		}
	}

	iProp = -1;
	while ((iProp = FindEntityByClassname(iProp, "light_dynamic")) != INVALID_ENT_REFERENCE)
	{
		static int iTank;
		iTank = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iTank == tank)
		{
			static int iFlashlightColor[4];
			MT_GetPropColors(tank, 7, iFlashlightColor[0], iFlashlightColor[1], iFlashlightColor[2], iFlashlightColor[3]);
			SetEntityRenderMode(iProp, mode);
			SetEntityRenderColor(iProp, iFlashlightColor[0], iFlashlightColor[1], iFlashlightColor[2], alpha);
		}
	}
}

static void vRenderSpecials(int tank, bool mode, int red = 255, int green = 255, int blue = 255)
{
	static float flTankPos[3], flInfectedPos[3];
	GetClientAbsOrigin(tank, flTankPos);
	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (bIsSpecialInfected(iInfected, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			switch (mode)
			{
				case true:
				{
					GetClientAbsOrigin(iInfected, flInfectedPos);
					if (g_esPlayer[tank].g_bAffected[iInfected] || GetVectorDistance(flTankPos, flInfectedPos) <= g_esCache[tank].g_flGhostSpecialsRange)
					{
						g_esPlayer[tank].g_bAffected[iInfected] = true;

						SetEntityRenderMode(iInfected, RENDER_TRANSCOLOR);
						SetEntityRenderColor(iInfected, red, green, blue, g_esPlayer[tank].g_iGhostAlpha);
					}
				}
				case false:
				{
					g_esPlayer[tank].g_bAffected[iInfected] = false;

					SetEntityRenderMode(iInfected, RENDER_NORMAL);
					SetEntityRenderColor(iInfected, red, green, blue, 255);
				}
			}
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveGhost(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iGhostAlpha = 255;

	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "GhostHuman8", g_esPlayer[tank].g_iCooldown - iTime);
	}
}

static void vResetRender(int tank)
{
	static int iSkinColor[4];
	MT_GetTankColors(tank, 1, iSkinColor[0], iSkinColor[1], iSkinColor[2], iSkinColor[3]);
	vRenderProps(tank, RENDER_TRANSCOLOR, g_esPlayer[tank].g_iGhostAlpha);
	SetEntityRenderMode(tank, RENDER_TRANSCOLOR);
	SetEntityRenderColor(tank, iSkinColor[0], iSkinColor[1], iSkinColor[2], g_esPlayer[tank].g_iGhostAlpha);
}

public Action tTimerCombo(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iGhostAbility == 0 || g_esCache[iTank].g_iGhostAbility == 2)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat();
	int iPos = pack.ReadCell();
	vGhostAbility(iTank, true, flRandom, iPos);

	return Plugin_Continue;
}

public Action tTimerCombo2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iGhostAbility == 0 || g_esCache[iTank].g_iGhostAbility == 1)
	{
		return Plugin_Stop;
	}

	int iPos = pack.ReadCell();
	vGhostAbility(iTank, false, _, iPos);

	return Plugin_Continue;
}

public Action tTimerCombo3(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iGhostHit == 0)
	{
		return Plugin_Stop;
	}

	float flRandom = pack.ReadFloat(), flChance = pack.ReadFloat();
	char sClassname[32];
	pack.ReadString(sClassname, sizeof(sClassname));
	if ((g_esCache[iTank].g_iGhostHitMode == 0 || g_esCache[iTank].g_iGhostHitMode == 1) && (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock")))
	{
		vGhostHit(iSurvivor, iTank, flRandom, flChance, g_esCache[iTank].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
	}
	else if ((g_esCache[iTank].g_iGhostHitMode == 0 || g_esCache[iTank].g_iGhostHitMode == 2) && StrEqual(sClassname, "weapon_melee"))
	{
		vGhostHit(iSurvivor, iTank, flRandom, flChance, g_esCache[iTank].g_iGhostHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
	}

	return Plugin_Continue;
}

public Action tTimerGhost(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esCache[iTank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || iType != g_esPlayer[iTank].g_iTankType || (g_esCache[iTank].g_iGhostAbility != 2 && g_esCache[iTank].g_iGhostAbility != 3) || !g_esPlayer[iTank].g_bActivated)
	{
		g_esPlayer[iTank].g_bActivated = false;
		g_esPlayer[iTank].g_iGhostAlpha = 255;

		vRenderSpecials(iTank, false);

		return Plugin_Stop;
	}

	static int iTime, iCurrentTime;
	iTime = pack.ReadCell();
	iCurrentTime = GetTime();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esCache[iTank].g_iHumanAbility == 1 && g_esCache[iTank].g_iHumanMode == 0 && (iTime + g_esCache[iTank].g_iHumanDuration) < iCurrentTime && (g_esPlayer[iTank].g_iCooldown == -1 || g_esPlayer[iTank].g_iCooldown < iCurrentTime))
	{
		vRenderSpecials(iTank, false);
		vReset2(iTank);

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_iGhostAlpha -= g_esCache[iTank].g_iGhostFadeAlpha;

	if (g_esPlayer[iTank].g_iGhostAlpha <= g_esCache[iTank].g_iGhostFadeLimit)
	{
		g_esPlayer[iTank].g_iGhostAlpha = g_esCache[iTank].g_iGhostFadeLimit;
		if (!g_esPlayer[iTank].g_bActivated2)
		{
			g_esPlayer[iTank].g_bActivated2 = true;
			g_esPlayer[iTank].g_iDuration = iCurrentTime + g_esCache[iTank].g_iGhostFadeDelay;
		}
	}

	vResetRender(iTank);

	static float flRandom;
	flRandom = pack.ReadFloat();
	if (g_esCache[iTank].g_iGhostSpecials == 1 && flRandom <= g_esCache[iTank].g_flGhostSpecialsChance)
	{
		static int iSkinColor[4];
		MT_GetTankColors(iTank, 1, iSkinColor[0], iSkinColor[1], iSkinColor[2], iSkinColor[3]);
		vRenderSpecials(iTank, true, iSkinColor[0], iSkinColor[1], iSkinColor[2]);
	}

	return Plugin_Continue;
}

public Action tTimerRenderRock(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iRock, iTank;
	iRock = EntRefToEntIndex(pack.ReadCell());
	iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock) || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || (g_esCache[iTank].g_iGhostAbility != 2 && g_esCache[iTank].g_iGhostAbility != 3) || !g_esPlayer[iTank].g_bActivated)
	{
		return Plugin_Stop;
	}

	static int iRockColor[4];
	MT_GetPropColors(iTank, 4, iRockColor[0], iRockColor[1], iRockColor[2], iRockColor[3]);
	SetEntityRenderMode(iRock, GetEntityRenderMode(iTank));
	SetEntityRenderColor(iRock, iRockColor[0], iRockColor[1], iRockColor[2], g_esPlayer[iTank].g_iGhostAlpha);

	return Plugin_Continue;
}