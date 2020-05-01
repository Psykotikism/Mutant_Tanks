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

#undef REQUIRE_PLUGIN
#tryinclude <mt_clone>
#define REQUIRE_PLUGIN

#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Hypno Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank hypnotizes survivors to damage themselves or their teammates.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Hypno Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_HYPNO "Hypno Ability"

bool g_bCloneInstalled;

enum struct esPlayerSettings
{
	bool g_bHypno;
	bool g_bHypno2;
	bool g_bHypno3;
	bool g_bHypno4;
	bool g_bHypno5;

	int g_iAccessFlags2;
	int g_iHypnoCount;
	int g_iHypnoOwner;
	int g_iImmunityFlags2;
}

esPlayerSettings g_esPlayer[MAXPLAYERS + 1];

enum struct esAbilitySettings
{
	float g_flHumanCooldown;
	float g_flHypnoBulletDivisor;
	float g_flHypnoChance;
	float g_flHypnoDuration;
	float g_flHypnoExplosiveDivisor;
	float g_flHypnoFireDivisor;
	float g_flHypnoMeleeDivisor;
	float g_flHypnoRange;
	float g_flHypnoRangeChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHypnoAbility;
	int g_iHypnoEffect;
	int g_iHypnoHit;
	int g_iHypnoHitMode;
	int g_iHypnoMessage;
	int g_iHypnoMode;
	int g_iImmunityFlags;
}

esAbilitySettings g_esAbility[MT_MAXTYPES + 1];

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("mt_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_hypno", cmdHypnoInfo, "View information about the Hypno ability.");

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
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vReset2(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdHypnoInfo(int client, int args)
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
		case false: vHypnoMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vHypnoMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iHypnoMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Hypno Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iHypnoMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHypnoAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iHypnoCount, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esAbility[MT_GetTankType(param1)].g_flHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "HypnoDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esAbility[MT_GetTankType(param1)].g_flHypnoDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vHypnoMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "HypnoMenu", param1);
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
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 6:
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
	menu.AddItem(MT_MENU_HYPNO, MT_MENU_HYPNO);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_HYPNO, false))
	{
		vHypnoMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_esAbility[MT_GetTankType(attacker)].g_iHypnoHitMode == 0 || g_esAbility[MT_GetTankType(attacker)].g_iHypnoHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHypnoHit(victim, attacker, g_esAbility[MT_GetTankType(attacker)].g_flHypnoChance, g_esAbility[MT_GetTankType(attacker)].g_iHypnoHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if ((g_esAbility[MT_GetTankType(victim)].g_iHypnoHitMode == 0 || g_esAbility[MT_GetTankType(victim)].g_iHypnoHitMode == 2) && StrEqual(sClassname, "weapon_melee"))
			{
				if ((MT_HasAdminAccess(victim) || bHasAdminAccess(victim)) && !MT_IsAdminImmune(attacker, victim) && !bIsAdminImmune(attacker, victim))
				{
					vHypnoHit(attacker, victim, g_esAbility[MT_GetTankType(victim)].g_flHypnoChance, g_esAbility[MT_GetTankType(victim)].g_iHypnoHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
				}
			}

			if (g_esPlayer[attacker].g_bHypno)
			{
				if (damagetype & DMG_BULLET)
				{
					damage /= g_esAbility[MT_GetTankType(victim)].g_flHypnoBulletDivisor;
				}
				else if ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA))
				{
					damage /= g_esAbility[MT_GetTankType(victim)].g_flHypnoExplosiveDivisor;
				}
				else if (damagetype & DMG_BURN)
				{
					damage /= g_esAbility[MT_GetTankType(victim)].g_flHypnoFireDivisor;
				}
				else if (damagetype & DMG_SLASH || (damagetype & DMG_CLUB))
				{
					damage /= g_esAbility[MT_GetTankType(victim)].g_flHypnoMeleeDivisor;
				}

				int iHealth = GetClientHealth(attacker), iTarget = iGetRandomSurvivor(attacker);
				if (iHealth > damage)
				{
					if (g_esAbility[MT_GetTankType(victim)].g_iHypnoMode == 1 && iTarget > 0)
					{
						//SetEntityHealth(iTarget, iHealth - RoundToNearest(damage));
						SetEntProp(iTarget, Prop_Data, "m_iHealth", iHealth - RoundToNearest(damage));
					}
					else
					{
						//SetEntityHealth(attacker, iHealth - RoundToNearest(damage));
						SetEntProp(attacker, Prop_Data, "m_iHealth", iHealth - RoundToNearest(damage));
					}
				}
				else
				{
					if (g_esAbility[MT_GetTankType(victim)].g_iHypnoMode == 1 && iTarget > 0)
					{
						SetEntProp(iTarget, Prop_Send, "m_isIncapacitated", 1);
					}
					else
					{
						SetEntProp(attacker, Prop_Send, "m_isIncapacitated", 1);
					}
				}

				return Plugin_Changed;
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
	list.PushString("hypnoability");
	list2.PushString("hypno ability");
	list3.PushString("hypno_ability");
	list4.PushString("hypno");
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
			g_esAbility[iIndex].g_iHypnoAbility = 0;
			g_esAbility[iIndex].g_iHypnoEffect = 0;
			g_esAbility[iIndex].g_iHypnoMessage = 0;
			g_esAbility[iIndex].g_flHypnoBulletDivisor = 20.0;
			g_esAbility[iIndex].g_flHypnoChance = 33.3;
			g_esAbility[iIndex].g_flHypnoDuration = 5.0;
			g_esAbility[iIndex].g_flHypnoExplosiveDivisor = 20.0;
			g_esAbility[iIndex].g_flHypnoFireDivisor = 200.0;
			g_esAbility[iIndex].g_iHypnoHit = 0;
			g_esAbility[iIndex].g_iHypnoHitMode = 0;
			g_esAbility[iIndex].g_flHypnoMeleeDivisor = 200.0;
			g_esAbility[iIndex].g_iHypnoMode = 0;
			g_esAbility[iIndex].g_flHypnoRange = 150.0;
			g_esAbility[iIndex].g_flHypnoRangeChance = 15.0;
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "hypnoability", false) || StrEqual(subsection, "hypno ability", false) || StrEqual(subsection, "hypno_ability", false) || StrEqual(subsection, "hypno", false))
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
		g_esAbility[type].g_iHumanAbility = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAmmo = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_flHumanCooldown = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_flHumanCooldown, value, 0.0, 999999.0);
		g_esAbility[type].g_iHypnoAbility = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iHypnoAbility, value, 0, 1);
		g_esAbility[type].g_iHypnoEffect = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iHypnoEffect, value, 0, 7);
		g_esAbility[type].g_iHypnoMessage = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iHypnoMessage, value, 0, 7);
		g_esAbility[type].g_flHypnoBulletDivisor = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoBulletDivisor", "Hypno Bullet Divisor", "Hypno_Bullet_Divisor", "bullet", g_esAbility[type].g_flHypnoBulletDivisor, value, 0.1, 999999.0);
		g_esAbility[type].g_flHypnoChance = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoChance", "Hypno Chance", "Hypno_Chance", "chance", g_esAbility[type].g_flHypnoChance, value, 0.0, 100.0);
		g_esAbility[type].g_flHypnoDuration = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoDuration", "Hypno Duration", "Hypno_Duration", "duration", g_esAbility[type].g_flHypnoDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_flHypnoExplosiveDivisor = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoExplosiveDivisor", "Hypno Explosive Divisor", "Hypno_Explosive_Divisor", "explosive", g_esAbility[type].g_flHypnoExplosiveDivisor, value, 0.1, 999999.0);
		g_esAbility[type].g_flHypnoFireDivisor = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoFireDivisor", "Hypno Fire Divisor", "Hypno_Fire_Divisor", "fire", g_esAbility[type].g_flHypnoFireDivisor, value, 0.1, 999999.0);
		g_esAbility[type].g_iHypnoHit = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoHit", "Hypno Hit", "Hypno_Hit", "hit", g_esAbility[type].g_iHypnoHit, value, 0, 1);
		g_esAbility[type].g_iHypnoHitMode = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoHitMode", "Hypno Hit Mode", "Hypno_Hit_Mode", "hitmode", g_esAbility[type].g_iHypnoHitMode, value, 0, 2);
		g_esAbility[type].g_flHypnoMeleeDivisor = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoMeleeDivisor", "Hypno Melee Divisor", "Hypno_Melee_Divisor", "melee", g_esAbility[type].g_flHypnoMeleeDivisor, value, 0.1, 999999.0);
		g_esAbility[type].g_iHypnoMode = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoMode", "Hypno Mode", "Hypno_Mode", "mode", g_esAbility[type].g_iHypnoMode, value, 0, 1);
		g_esAbility[type].g_flHypnoRange = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoRange", "Hypno Range", "Hypno_Range", "range", g_esAbility[type].g_flHypnoRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flHypnoRangeChance = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoRangeChance", "Hypno Range Chance", "Hypno_Range_Chance", "rangechance", g_esAbility[type].g_flHypnoRangeChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "hypnoability", false) || StrEqual(subsection, "hypno ability", false) || StrEqual(subsection, "hypno_ability", false) || StrEqual(subsection, "hypno", false))
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

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveHypno(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esAbility[MT_GetTankType(tank)].g_iHypnoAbility == 1)
	{
		vHypnoAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & MT_SUB_KEY == MT_SUB_KEY)
		{
			if (g_esAbility[MT_GetTankType(tank)].g_iHypnoAbility == 1 && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				if (!g_esPlayer[tank].g_bHypno2 && !g_esPlayer[tank].g_bHypno3)
				{
					vHypnoAbility(tank);
				}
				else if (g_esPlayer[tank].g_bHypno2)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman3");
				}
				else if (g_esPlayer[tank].g_bHypno3)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman4");
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveHypno(tank);
}

static void vHypnoAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_esPlayer[tank].g_iHypnoCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
	{
		g_esPlayer[tank].g_bHypno4 = false;
		g_esPlayer[tank].g_bHypno5 = false;

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
				if (flDistance <= g_esAbility[MT_GetTankType(tank)].g_flHypnoRange)
				{
					vHypnoHit(iSurvivor, tank, g_esAbility[MT_GetTankType(tank)].g_flHypnoRangeChance, g_esAbility[MT_GetTankType(tank)].g_iHypnoAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman5");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoAmmo");
	}
}

static void vHypnoHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_esPlayer[tank].g_iHypnoCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_esPlayer[survivor].g_bHypno)
			{
				g_esPlayer[survivor].g_bHypno = true;
				g_esPlayer[survivor].g_iHypnoOwner = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && !g_esPlayer[tank].g_bHypno2)
				{
					g_esPlayer[tank].g_bHypno2 = true;
					g_esPlayer[tank].g_iHypnoCount++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman", g_esPlayer[tank].g_iHypnoCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
				}

				DataPack dpStopHypno;
				CreateDataTimer(g_esAbility[MT_GetTankType(tank)].g_flHypnoDuration, tTimerStopHypno, dpStopHypno, TIMER_FLAG_NO_MAPCHANGE);
				dpStopHypno.WriteCell(GetClientUserId(survivor));
				dpStopHypno.WriteCell(GetClientUserId(tank));
				dpStopHypno.WriteCell(messages);

				vEffect(survivor, tank, g_esAbility[MT_GetTankType(tank)].g_iHypnoEffect, flags);

				if (g_esAbility[MT_GetTankType(tank)].g_iHypnoMessage & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Hypno", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && !g_esPlayer[tank].g_bHypno2)
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bHypno4)
				{
					g_esPlayer[tank].g_bHypno4 = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bHypno5)
		{
			g_esPlayer[tank].g_bHypno5 = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoAmmo");
		}
	}
}

static void vRemoveHypno(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bHypno && g_esPlayer[iSurvivor].g_iHypnoOwner == tank)
		{
			g_esPlayer[iSurvivor].g_bHypno = false;
			g_esPlayer[iSurvivor].g_iHypnoOwner = 0;
		}
	}

	vReset2(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vReset2(iPlayer);

			g_esPlayer[iPlayer].g_iHypnoOwner = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bHypno = false;
	g_esPlayer[tank].g_bHypno2 = false;
	g_esPlayer[tank].g_bHypno3 = false;
	g_esPlayer[tank].g_bHypno4 = false;
	g_esPlayer[tank].g_bHypno5 = false;
	g_esPlayer[tank].g_iHypnoCount = 0;
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

public Action tTimerStopHypno(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_esPlayer[iSurvivor].g_bHypno)
	{
		g_esPlayer[iSurvivor].g_bHypno = false;
		g_esPlayer[iSurvivor].g_iHypnoOwner = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled))
	{
		g_esPlayer[iSurvivor].g_bHypno = false;
		g_esPlayer[iSurvivor].g_iHypnoOwner = 0;

		return Plugin_Stop;
	}

	g_esPlayer[iSurvivor].g_bHypno = false;
	g_esPlayer[iTank].g_bHypno2 = false;
	g_esPlayer[iSurvivor].g_iHypnoOwner = 0;

	int iMessage = pack.ReadCell();

	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && (iMessage & MT_MESSAGE_RANGE) && !g_esPlayer[iTank].g_bHypno3)
	{
		g_esPlayer[iTank].g_bHypno3 = true;

		MT_PrintToChat(iTank, "%s %t", MT_TAG3, "HypnoHuman6");

		if (g_esPlayer[iTank].g_iHypnoCount < g_esAbility[MT_GetTankType(iTank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(iTank)].g_iHumanAmmo > 0)
		{
			CreateTimer(g_esAbility[MT_GetTankType(iTank)].g_flHumanCooldown, tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_esPlayer[iTank].g_bHypno3 = false;
		}
	}

	if (g_esAbility[MT_GetTankType(iTank)].g_iHypnoMessage & iMessage)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Hypno2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iTank].g_bHypno3)
	{
		g_esPlayer[iTank].g_bHypno3 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bHypno3 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "HypnoHuman7");

	return Plugin_Continue;
}