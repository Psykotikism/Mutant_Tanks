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

#undef REQUIRE_PLUGIN
#tryinclude <mt_clone>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Heal Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank gains health from other nearby infected and sets survivors to temporary health who will die when they reach 0 HP.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Heal Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define SOUND_HEARTBEAT	 "player/heartbeatloop.wav"

#define MT_MENU_HEAL "Heal Ability"

enum struct esGeneralSettings
{
	bool g_bCloneInstalled;

	ConVar g_cvMTMaxIncapCount;
}

esGeneralSettings g_esGeneral;

enum struct esPlayerSettings
{
	bool g_bHeal;
	bool g_bHeal2;
	bool g_bHeal3;
	bool g_bHeal4;
	bool g_bHeal5;
	bool g_bHeal6;

	int g_iAccessFlags2;
	int g_iHealCount;
	int g_iHealCount2;
	int g_iImmunityFlags2;
}

esPlayerSettings g_esPlayer[MAXPLAYERS + 1];

enum struct esAbilitySettings
{
	float g_flHealAbsorbRange;
	float g_flHealBuffer;
	float g_flHealChance;
	float g_flHealInterval;
	float g_flHealRange;
	float g_flHealRangeChance;
	float g_flHumanCooldown;
	float g_flHumanDuration;

	int g_iAccessFlags;
	int g_iHealAbility;
	int g_iHealCommon;
	int g_iHealEffect;
	int g_iHealHit;
	int g_iHealHitMode;
	int g_iHealMessage;
	int g_iHealSpecial;
	int g_iHealTank;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanMode;
	int g_iImmunityFlags;
}

esAbilitySettings g_esAbility[MT_MAXTYPES + 1];

public void OnAllPluginsLoaded()
{
	g_esGeneral.g_bCloneInstalled = LibraryExists("mt_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_esGeneral.g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_esGeneral.g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_heal", cmdHealInfo, "View information about the Heal ability.");

	g_esGeneral.g_cvMTMaxIncapCount = FindConVar("survivor_max_incapacitated_count");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	PrecacheSound(SOUND_HEARTBEAT, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveHeal(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveHeal(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdHealInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Mutant Tanks\x01 is disabled.", MT_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", MT_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vHealMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vHealMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iHealMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Heal Ability Information");
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

public int iHealMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHealAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iHealCount, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iHealCount2, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esAbility[MT_GetTankType(param1)].g_flHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "HealDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esAbility[MT_GetTankType(param1)].g_flHumanDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vHealMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "HealMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[255];
			switch (param2)
			{
				case 0:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 1:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Ammunition", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 2:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 3:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "ButtonMode", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 6:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 7:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);

					return RedrawMenuItem(sMenuOption);
				}
			}
		}
	}

	return 0;
}

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_HEAL, MT_MENU_HEAL);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_HEAL, false))
	{
		vHealMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_esGeneral.g_bCloneInstalled) && (g_esAbility[MT_GetTankType(attacker)].g_iHealHitMode == 0 || g_esAbility[MT_GetTankType(attacker)].g_iHealHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHealHit(victim, attacker, g_esAbility[MT_GetTankType(attacker)].g_flHealChance, g_esAbility[MT_GetTankType(attacker)].g_iHealHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_esGeneral.g_bCloneInstalled) && (g_esAbility[MT_GetTankType(victim)].g_iHealHitMode == 0 || g_esAbility[MT_GetTankType(victim)].g_iHealHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vHealHit(attacker, victim, g_esAbility[MT_GetTankType(victim)].g_flHealChance, g_esAbility[MT_GetTankType(victim)].g_iHealHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("healability");
	list2.PushString("heal ability");
	list3.PushString("heal_ability");
	list4.PushString("heal");
}

public void MT_OnConfigsLoad(int mode)
{
	if (mode == 3)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				g_esPlayer[iPlayer].g_iAccessFlags2 = 0;
				g_esPlayer[iPlayer].g_iImmunityFlags2 = 0;
			}
		}
	}
	else if (mode == 1)
	{
		for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
		{
			g_esAbility[iIndex].g_iAccessFlags = 0;
			g_esAbility[iIndex].g_iImmunityFlags = 0;
			g_esAbility[iIndex].g_iHumanAbility = 0;
			g_esAbility[iIndex].g_iHumanAmmo = 5;
			g_esAbility[iIndex].g_flHumanCooldown = 30.0;
			g_esAbility[iIndex].g_flHumanDuration = 5.0;
			g_esAbility[iIndex].g_iHumanMode = 1;
			g_esAbility[iIndex].g_iHealAbility = 0;
			g_esAbility[iIndex].g_iHealEffect = 0;
			g_esAbility[iIndex].g_iHealMessage = 0;
			g_esAbility[iIndex].g_flHealAbsorbRange = 500.0;
			g_esAbility[iIndex].g_flHealBuffer = 25.0;
			g_esAbility[iIndex].g_flHealChance = 33.3;
			g_esAbility[iIndex].g_iHealHit = 0;
			g_esAbility[iIndex].g_iHealHitMode = 0;
			g_esAbility[iIndex].g_flHealInterval = 5.0;
			g_esAbility[iIndex].g_flHealRange = 150.0;
			g_esAbility[iIndex].g_flHealRangeChance = 15.0;
			g_esAbility[iIndex].g_iHealCommon = 50;
			g_esAbility[iIndex].g_iHealSpecial = 100;
			g_esAbility[iIndex].g_iHealTank = 500;
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "healability", false) || StrEqual(subsection, "heal ability", false) || StrEqual(subsection, "heal_ability", false) || StrEqual(subsection, "heal", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags2 = (value[0] != '\0') ? ReadFlagString(value) : g_esPlayer[admin].g_iAccessFlags2;
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esPlayer[admin].g_iImmunityFlags2 = (value[0] != '\0') ? ReadFlagString(value) : g_esPlayer[admin].g_iImmunityFlags2;
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_flHumanCooldown = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_flHumanCooldown, value, 0.0, 999999.0);
		g_esAbility[type].g_flHumanDuration = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esAbility[type].g_flHumanDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_iHumanMode = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iHealAbility = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iHealAbility, value, 0, 3);
		g_esAbility[type].g_iHealEffect = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iHealEffect, value, 0, 7);
		g_esAbility[type].g_iHealMessage = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iHealMessage, value, 0, 7);
		g_esAbility[type].g_flHealAbsorbRange = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealAbsorbRange", "Heal Absorb Range", "Heal_Absorb_Range", "absorbrange", g_esAbility[type].g_flHealAbsorbRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flHealBuffer = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealBuffer", "Heal Buffer", "Heal_Buffer", "buffer", g_esAbility[type].g_flHealBuffer, value, 1.0, float(MT_MAXHEALTH));
		g_esAbility[type].g_flHealChance = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealChance", "Heal Chance", "Heal_Chance", "chance", g_esAbility[type].g_flHealChance, value, 0.0, 100.0);
		g_esAbility[type].g_iHealHit = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealHit", "Heal Hit", "Heal_Hit", "hit", g_esAbility[type].g_iHealHit, value, 0, 1);
		g_esAbility[type].g_iHealHitMode = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealHitMode", "Heal Hit Mode", "Heal_Hit_Mode", "hitmode", g_esAbility[type].g_iHealHitMode, value, 0, 2);
		g_esAbility[type].g_flHealInterval = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealInterval", "Heal Interval", "Heal_Interval", "interval", g_esAbility[type].g_flHealInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_flHealRange = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealRange", "Heal Range", "Heal_Range", "range", g_esAbility[type].g_flHealRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flHealRangeChance = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealRangeChance", "Heal Range Chance", "Heal_Range_Chance", "rangechance", g_esAbility[type].g_flHealRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_iHealCommon = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealthFromCommons", "Health From Commons", "Health_From_Commons", "commons", g_esAbility[type].g_iHealCommon, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
		g_esAbility[type].g_iHealSpecial = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealthFromSpecials", "Health From Specials", "Health_From_Specials", "specials", g_esAbility[type].g_iHealSpecial, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);
		g_esAbility[type].g_iHealTank = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealthFromTanks", "Health From Tanks", "Health_From_Tanks", "tanks", g_esAbility[type].g_iHealTank, value, MT_MAX_HEALTH_REDUCTION, MT_MAXHEALTH);

		if (StrEqual(subsection, "healability", false) || StrEqual(subsection, "heal ability", false) || StrEqual(subsection, "heal_ability", false) || StrEqual(subsection, "heal", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = (value[0] != '\0') ? ReadFlagString(value) : g_esAbility[type].g_iAccessFlags;
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esAbility[type].g_iImmunityFlags = (value[0] != '\0') ? ReadFlagString(value) : g_esAbility[type].g_iImmunityFlags;
			}
		}
	}
}

public void MT_OnHookEvent(bool hooked)
{
	switch (hooked)
	{
		case true: HookEvent("heal_success", MT_OnEventFired);
		case false: UnhookEvent("heal_success", MT_OnEventFired);
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "heal_success"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
		if (bIsSurvivor(iSurvivor))
		{
			g_esPlayer[iSurvivor].g_bHeal4 = false;

			SetEntProp(iSurvivor, Prop_Send, "m_currentReviveCount", 0);
			SetEntProp(iSurvivor, Prop_Send, "m_isGoingToDie", 0);

			if (bIsValidGame())
			{
				SetEntProp(iSurvivor, Prop_Send, "m_bIsOnThirdStrike", 0);
			}

			vStopSound(iSurvivor, SOUND_HEARTBEAT);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iUserId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iUserId);
		if (bIsSurvivor(iPlayer))
		{
			vStopSound(iPlayer, SOUND_HEARTBEAT);
		}
		else if (MT_IsTankSupported(iPlayer, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveHeal(iPlayer);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility != 1) && bIsCloneAllowed(tank, g_esGeneral.g_bCloneInstalled) && g_esAbility[MT_GetTankType(tank)].g_iHealAbility > 0)
	{
		vHealAbility(tank, true);
		vHealAbility(tank, false);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_esGeneral.g_bCloneInstalled))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if ((g_esAbility[MT_GetTankType(tank)].g_iHealAbility == 2 || g_esAbility[MT_GetTankType(tank)].g_iHealAbility == 3) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				switch (g_esAbility[MT_GetTankType(tank)].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bHeal && !g_esPlayer[tank].g_bHeal2)
						{
							vHealAbility(tank, false);
						}
						else if (g_esPlayer[tank].g_bHeal)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman4");
						}
						else if (g_esPlayer[tank].g_bHeal2)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman5");
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iHealCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bHeal && !g_esPlayer[tank].g_bHeal2)
							{
								g_esPlayer[tank].g_bHeal = true;
								g_esPlayer[tank].g_iHealCount++;

								vHeal(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman", g_esPlayer[tank].g_iHealCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bHeal)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman4");
							}
							else if (g_esPlayer[tank].g_bHeal2)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman5");
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealAmmo");
						}
					}
				}
			}
		}

		if (button & MT_SUB_KEY == MT_SUB_KEY)
		{
			if ((g_esAbility[MT_GetTankType(tank)].g_iHealAbility == 1 || g_esAbility[MT_GetTankType(tank)].g_iHealAbility == 3) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				switch (g_esPlayer[tank].g_bHeal3)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman6");
					case false: vHealAbility(tank, true);
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_esGeneral.g_bCloneInstalled))
	{
		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if ((g_esAbility[MT_GetTankType(tank)].g_iHealAbility == 2 || g_esAbility[MT_GetTankType(tank)].g_iHealAbility == 3) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				if (g_esAbility[MT_GetTankType(tank)].g_iHumanMode == 1 && g_esPlayer[tank].g_bHeal && !g_esPlayer[tank].g_bHeal2)
				{
					vReset2(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveHeal(tank);
}

static void vHeal(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	DataPack dpHeal;
	CreateDataTimer(g_esAbility[MT_GetTankType(tank)].g_flHealInterval, tTimerHeal, dpHeal, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpHeal.WriteCell(GetClientUserId(tank));
	dpHeal.WriteCell(MT_GetTankType(tank));
	dpHeal.WriteFloat(GetEngineTime());
}

static void vHealAbility(int tank, bool main)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_esAbility[MT_GetTankType(tank)].g_iHealAbility == 1 || g_esAbility[MT_GetTankType(tank)].g_iHealAbility == 3)
			{
				if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iHealCount2 < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0))
				{
					g_esPlayer[tank].g_bHeal5 = false;
					g_esPlayer[tank].g_bHeal6 = false;

					float flTankPos[3];
					GetClientAbsOrigin(tank, flTankPos);

					int iSurvivorCount;
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
						{
							float flSurvivorPos[3];
							GetClientAbsOrigin(iSurvivor, flSurvivorPos);

							float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
							if (flDistance <= g_esAbility[MT_GetTankType(tank)].g_flHealRange)
							{
								vHealHit(iSurvivor, tank, g_esAbility[MT_GetTankType(tank)].g_flHealRangeChance, g_esAbility[MT_GetTankType(tank)].g_iHealAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman7");
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealAmmo2");
				}
			}
		}
		case false:
		{
			if ((g_esAbility[MT_GetTankType(tank)].g_iHealAbility == 2 || g_esAbility[MT_GetTankType(tank)].g_iHealAbility == 3) && !g_esPlayer[tank].g_bHeal)
			{
				if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iHealCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0))
				{
					g_esPlayer[tank].g_bHeal = true;

					if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
					{
						g_esPlayer[tank].g_iHealCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman", g_esPlayer[tank].g_iHealCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
					}

					vHeal(tank);

					if (g_esAbility[MT_GetTankType(tank)].g_iHealMessage & MT_MESSAGE_SPECIAL)
					{
						char sTankName[33];
						MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Heal2", sTankName);
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealAmmo");
				}
			}
		}
	}
}

static void vHealHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iHealCount2 < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0))
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_esPlayer[survivor].g_bHeal4)
			{
				int iHealth = GetClientHealth(survivor);
				if (iHealth > 0 && !bIsPlayerIncapacitated(survivor))
				{
					g_esPlayer[survivor].g_bHeal4 = true;

					if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && !g_esPlayer[tank].g_bHeal3)
					{
						g_esPlayer[tank].g_bHeal3 = true;
						g_esPlayer[tank].g_iHealCount2++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman2", g_esPlayer[tank].g_iHealCount2, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);

						if (g_esPlayer[tank].g_iHealCount2 < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
						{
							CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flHumanCooldown, tTimerResetCooldown2, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
						}
						else
						{
							g_esPlayer[tank].g_bHeal3 = false;
						}
					}

					SetEntProp(survivor, Prop_Data, "m_iHealth", 1);
					SetEntPropFloat(survivor, Prop_Send, "m_healthBufferTime", GetGameTime());
					SetEntPropFloat(survivor, Prop_Send, "m_healthBuffer", g_esAbility[MT_GetTankType(tank)].g_flHealBuffer);
					SetEntProp(survivor, Prop_Send, "m_currentReviveCount", g_esGeneral.g_cvMTMaxIncapCount.IntValue);

					vEffect(survivor, tank, g_esAbility[MT_GetTankType(tank)].g_iHealEffect, flags);

					if (g_esAbility[MT_GetTankType(tank)].g_iHealMessage & messages)
					{
						char sTankName[33];
						MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Heal", sTankName, survivor);
					}
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && !g_esPlayer[tank].g_bHeal3)
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bHeal5)
				{
					g_esPlayer[tank].g_bHeal5 = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman3");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bHeal6)
		{
			g_esPlayer[tank].g_bHeal6 = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealAmmo2");
		}
	}
}

static void vRemoveHeal(int tank)
{
	g_esPlayer[tank].g_bHeal = false;
	g_esPlayer[tank].g_bHeal2 = false;
	g_esPlayer[tank].g_bHeal3 = false;
	g_esPlayer[tank].g_bHeal4 = false;
	g_esPlayer[tank].g_bHeal5 = false;
	g_esPlayer[tank].g_bHeal6 = false;
	g_esPlayer[tank].g_iHealCount = 0;
	g_esPlayer[tank].g_iHealCount2 = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveHeal(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bHeal = false;
	g_esPlayer[tank].g_bHeal2 = true;

	SetEntProp(tank, Prop_Send, "m_bFlashing", 0);

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "HealHuman8");

	if (g_esPlayer[tank].g_iHealCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
	{
		CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flHumanCooldown, tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_esPlayer[tank].g_bHeal2 = false;
	}
}

static void vResetGlow(int tank)
{
	if (!bIsValidGame())
	{
		return;
	}

	switch (MT_IsGlowEnabled(tank))
	{
		case true:
		{
			int iGlowColor[4];
			MT_GetTankColors(tank, 2, iGlowColor[0], iGlowColor[1], iGlowColor[2], iGlowColor[3]);
			SetEntProp(tank, Prop_Send, "m_iGlowType", 3);
			SetEntProp(tank, Prop_Send, "m_glowColorOverride", iGetRGBColor(iGlowColor[0], iGlowColor[1], iGlowColor[2]));
			SetEntProp(tank, Prop_Send, "m_bFlashing", 0);
		}
		case false:
		{
			SetEntProp(tank, Prop_Send, "m_iGlowType", 0);
			SetEntProp(tank, Prop_Send, "m_glowColorOverride", 0);
			SetEntProp(tank, Prop_Send, "m_bFlashing", 0);
		}
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_esAbility[MT_GetTankType(admin)].g_iAccessFlags;
	if (iAbilityFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iAbilityFlags)) ? false : true;
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iTypeFlags)) ? false : true;
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iGlobalFlags)) ? false : true;
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0 && iAbilityFlags != 0)
	{
		return (!(iClientTypeFlags & iAbilityFlags)) ? false : true;
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0 && iAbilityFlags != 0)
	{
		return (!(iClientGlobalFlags & iAbilityFlags)) ? false : true;
	}

	if (iAbilityFlags != 0)
	{
		return (!(GetUserFlagBits(admin) & iAbilityFlags)) ? false : true;
	}

	return true;
}

static bool bIsAdminImmune(int survivor, int tank)
{
	if (!bIsValidClient(survivor, MT_CHECK_FAKECLIENT))
	{
		return false;
	}

	int iAbilityFlags = g_esAbility[MT_GetTankType(tank)].g_iImmunityFlags;
	if (iAbilityFlags != 0 && g_esPlayer[survivor].g_iImmunityFlags2 != 0 && (g_esPlayer[survivor].g_iImmunityFlags2 & iAbilityFlags))
	{
		return (g_esPlayer[tank].g_iImmunityFlags2 != 0 && (g_esPlayer[tank].g_iImmunityFlags2 & iAbilityFlags) && g_esPlayer[survivor].g_iImmunityFlags2 <= g_esPlayer[tank].g_iImmunityFlags2) ? false : true;
	}

	int iTypeFlags = MT_GetImmunityFlags(2, MT_GetTankType(tank));
	if (iTypeFlags != 0 && g_esPlayer[survivor].g_iImmunityFlags2 != 0 && (g_esPlayer[survivor].g_iImmunityFlags2 & iTypeFlags))
	{
		return (g_esPlayer[tank].g_iImmunityFlags2 != 0 && (g_esPlayer[tank].g_iImmunityFlags2 & iAbilityFlags) && g_esPlayer[survivor].g_iImmunityFlags2 <= g_esPlayer[tank].g_iImmunityFlags2) ? false : true;
	}

	int iGlobalFlags = MT_GetImmunityFlags(1);
	if (iGlobalFlags != 0 && g_esPlayer[survivor].g_iImmunityFlags2 != 0 && (g_esPlayer[survivor].g_iImmunityFlags2 & iGlobalFlags))
	{
		return (g_esPlayer[tank].g_iImmunityFlags2 != 0 && (g_esPlayer[tank].g_iImmunityFlags2 & iAbilityFlags) && g_esPlayer[survivor].g_iImmunityFlags2 <= g_esPlayer[tank].g_iImmunityFlags2) ? false : true;
	}

	int iClientTypeFlags = MT_GetImmunityFlags(4, MT_GetTankType(tank), survivor),
		iClientTypeFlags2 = MT_GetImmunityFlags(4, MT_GetTankType(tank), tank);
	if (iClientTypeFlags != 0 && iAbilityFlags != 0 && (iClientTypeFlags & iAbilityFlags))
	{
		return (iClientTypeFlags2 != 0 && (iClientTypeFlags2 & iAbilityFlags) && iClientTypeFlags <= iClientTypeFlags2) ? false : true;
	}

	int iClientGlobalFlags = MT_GetImmunityFlags(3, 0, survivor),
		iClientGlobalFlags2 = MT_GetImmunityFlags(3, 0, tank);
	if (iClientGlobalFlags != 0 && iAbilityFlags != 0 && (iClientGlobalFlags & iAbilityFlags))
	{
		return (iClientGlobalFlags2 != 0 && (iClientGlobalFlags2 & iAbilityFlags) && iClientGlobalFlags <= iClientGlobalFlags2) ? false : true;
	}

	int iSurvivorFlags = GetUserFlagBits(survivor), iTankFlags = GetUserFlagBits(tank);
	if (iAbilityFlags != 0 && iSurvivorFlags != 0 && (iSurvivorFlags & iAbilityFlags))
	{
		return (iTankFlags != 0 && iSurvivorFlags <= iTankFlags) ? false : true;
	}

	return false;
}

public Action tTimerHeal(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_esGeneral.g_bCloneInstalled) || iType != MT_GetTankType(iTank) || (g_esAbility[MT_GetTankType(iTank)].g_iHealAbility != 2 && g_esAbility[MT_GetTankType(iTank)].g_iHealAbility != 3) || !g_esPlayer[iTank].g_bHeal)
	{
		g_esPlayer[iTank].g_bHeal = false;

		vResetGlow(iTank);

		if (g_esAbility[MT_GetTankType(iTank)].g_iHealMessage & MT_MESSAGE_SPECIAL)
		{
			char sTankName[33];
			MT_GetTankName(iTank, MT_GetTankType(iTank), sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Heal3", sTankName);
		}

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && g_esAbility[MT_GetTankType(iTank)].g_iHumanMode == 0 && (flTime + g_esAbility[MT_GetTankType(iTank)].g_flHumanDuration) < GetEngineTime() && !g_esPlayer[iTank].g_bHeal2)
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	int iHealType, iCommon = -1;

	while ((iCommon = FindEntityByClassname(iCommon, "infected")) != INVALID_ENT_REFERENCE)
	{
		float flTankPos[3], flInfectedPos[3];
		GetClientAbsOrigin(iTank, flTankPos);
		GetEntPropVector(iCommon, Prop_Send, "m_vecOrigin", flInfectedPos);

		float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
		if (flDistance <= g_esAbility[MT_GetTankType(iTank)].g_flHealAbsorbRange)
		{
			int iHealth = GetClientHealth(iTank),
				iCommonHealth = iHealth + g_esAbility[MT_GetTankType(iTank)].g_iHealCommon,
				iExtraHealth = (iCommonHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iCommonHealth,
				iExtraHealth2 = (iCommonHealth < iHealth) ? 1 : iCommonHealth,
				iRealHealth = (iCommonHealth >= 0) ? iExtraHealth : iExtraHealth2;
			if (iHealth > 500)
			{
				//SetEntityHealth(iTank, iRealHealth);
				SetEntProp(iTank, Prop_Data, "m_iHealth", iRealHealth);

				if (bIsValidGame())
				{
					SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
					SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 185, 0));
					SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);
				}

				iHealType = 1;
			}
		}
	}

	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (bIsSpecialInfected(iInfected, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE))
		{
			float flTankPos[3], flInfectedPos[3];
			GetClientAbsOrigin(iTank, flTankPos);
			GetClientAbsOrigin(iInfected, flInfectedPos);

			float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
			if (flDistance <= g_esAbility[MT_GetTankType(iTank)].g_flHealAbsorbRange)
			{
				int iHealth = GetClientHealth(iTank),
					iSpecialHealth = iHealth + g_esAbility[MT_GetTankType(iTank)].g_iHealSpecial,
					iExtraHealth = (iSpecialHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iSpecialHealth,
					iExtraHealth2 = (iSpecialHealth < iHealth) ? 1 : iSpecialHealth,
					iRealHealth = (iSpecialHealth >= 0) ? iExtraHealth : iExtraHealth2;
				if (iHealth > 500)
				{
					//SetEntityHealth(iTank, iRealHealth);
					SetEntProp(iTank, Prop_Data, "m_iHealth", iRealHealth);

					if (iHealType < 2)
					{
						if (bIsValidGame())
						{
							SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
							SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 220, 0));
							SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);
						}

						iHealType = 1;
					}
				}
			}
		}
		else if (MT_IsTankSupported(iInfected) && iInfected != iTank)
		{
			float flTankPos[3], flInfectedPos[3];
			GetClientAbsOrigin(iTank, flTankPos);
			GetClientAbsOrigin(iInfected, flInfectedPos);

			float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
			if (flDistance <= g_esAbility[MT_GetTankType(iTank)].g_flHealAbsorbRange)
			{
				int iHealth = GetClientHealth(iTank),
					iTankHealth = iHealth + g_esAbility[MT_GetTankType(iTank)].g_iHealTank,
					iExtraHealth = (iTankHealth > MT_MAXHEALTH) ? MT_MAXHEALTH : iTankHealth,
					iExtraHealth2 = (iTankHealth < iHealth) ? 1 : iTankHealth,
					iRealHealth = (iTankHealth >= 0) ? iExtraHealth : iExtraHealth2;
				if (iHealth > 500)
				{
					//SetEntityHealth(iTank, iRealHealth);
					SetEntProp(iTank, Prop_Data, "m_iHealth", iRealHealth);

					if (bIsValidGame())
					{
						SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
						SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 255, 0));
						SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);
					}

					iHealType = 2;
				}
			}
		}
	}

	if (iHealType == 0 && bIsValidGame())
	{
		vResetGlow(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_esGeneral.g_bCloneInstalled) || !g_esPlayer[iTank].g_bHeal2)
	{
		g_esPlayer[iTank].g_bHeal2 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bHeal2 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "HealHuman9");

	return Plugin_Continue;
}

public Action tTimerResetCooldown2(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_esGeneral.g_bCloneInstalled) || !g_esPlayer[iTank].g_bHeal3)
	{
		g_esPlayer[iTank].g_bHeal3 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bHeal3 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "HealHuman10");

	return Plugin_Continue;
}