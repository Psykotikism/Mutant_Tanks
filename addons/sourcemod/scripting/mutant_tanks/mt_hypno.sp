/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2019  Alfred "Crasher_3637/Psyk0tik" Llagas
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
#include <mt_clone>
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

bool g_bCloneInstalled, g_bHypno[MAXPLAYERS + 1], g_bHypno2[MAXPLAYERS + 1], g_bHypno3[MAXPLAYERS + 1], g_bHypno4[MAXPLAYERS + 1], g_bHypno5[MAXPLAYERS + 1];

float g_flHumanCooldown[MT_MAXTYPES + 1], g_flHypnoBulletDivisor[MT_MAXTYPES + 1], g_flHypnoChance[MT_MAXTYPES + 1], g_flHypnoDuration[MT_MAXTYPES + 1], g_flHypnoExplosiveDivisor[MT_MAXTYPES + 1], g_flHypnoFireDivisor[MT_MAXTYPES + 1], g_flHypnoMeleeDivisor[MT_MAXTYPES + 1], g_flHypnoRange[MT_MAXTYPES + 1], g_flHypnoRangeChance[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1], g_iHypnoAbility[MT_MAXTYPES + 1], g_iHypnoCount[MAXPLAYERS + 1], g_iHypnoEffect[MT_MAXTYPES + 1], g_iHypnoHit[MT_MAXTYPES + 1], g_iHypnoHitMode[MT_MAXTYPES + 1], g_iHypnoMessage[MT_MAXTYPES + 1], g_iHypnoMode[MT_MAXTYPES + 1], g_iHypnoOwner[MAXPLAYERS + 1], g_iImmunityFlags[MT_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1];

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
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
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

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHypnoAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iHypnoCount[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "HypnoDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_flHypnoDuration[MT_GetTankType(param1)]);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
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
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iHypnoHitMode[MT_GetTankType(attacker)] == 0 || g_iHypnoHitMode[MT_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHypnoHit(victim, attacker, g_flHypnoChance[MT_GetTankType(attacker)], g_iHypnoHit[MT_GetTankType(attacker)], MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if ((g_iHypnoHitMode[MT_GetTankType(victim)] == 0 || g_iHypnoHitMode[MT_GetTankType(victim)] == 2) && StrEqual(sClassname, "weapon_melee"))
			{
				if ((MT_HasAdminAccess(victim) || bHasAdminAccess(victim)) && !MT_IsAdminImmune(attacker, victim) && !bIsAdminImmune(attacker, victim))
				{
					vHypnoHit(attacker, victim, g_flHypnoChance[MT_GetTankType(victim)], g_iHypnoHit[MT_GetTankType(victim)], MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
				}
			}

			if (g_bHypno[attacker])
			{
				if (damagetype & DMG_BULLET)
				{
					damage /= g_flHypnoBulletDivisor[MT_GetTankType(victim)];
				}
				else if (damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA)
				{
					damage /= g_flHypnoExplosiveDivisor[MT_GetTankType(victim)];
				}
				else if (damagetype & DMG_BURN)
				{
					damage /= g_flHypnoFireDivisor[MT_GetTankType(victim)];
				}
				else if (damagetype & DMG_SLASH || damagetype & DMG_CLUB)
				{
					damage /= g_flHypnoMeleeDivisor[MT_GetTankType(victim)];
				}

				int iHealth = GetClientHealth(attacker), iTarget = iGetRandomSurvivor(attacker);
				if (iHealth > damage)
				{
					if (g_iHypnoMode[MT_GetTankType(victim)] == 1 && iTarget > 0)
					{
						SetEntityHealth(iTarget, iHealth - RoundToNearest(damage));
					}
					else
					{
						SetEntityHealth(attacker, iHealth - RoundToNearest(damage));
					}
				}
				else
				{
					if (g_iHypnoMode[MT_GetTankType(victim)] == 1 && iTarget > 0)
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

public void MT_OnConfigsLoad()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_iAccessFlags2[iPlayer] = 0;
			g_iImmunityFlags2[iPlayer] = 0;
		}
	}

	for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
	{
		g_iAccessFlags[iIndex] = 0;
		g_iImmunityFlags[iIndex] = 0;
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_iHypnoAbility[iIndex] = 0;
		g_iHypnoEffect[iIndex] = 0;
		g_iHypnoMessage[iIndex] = 0;
		g_flHypnoBulletDivisor[iIndex] = 20.0;
		g_flHypnoChance[iIndex] = 33.3;
		g_flHypnoDuration[iIndex] = 5.0;
		g_flHypnoExplosiveDivisor[iIndex] = 20.0;
		g_flHypnoFireDivisor[iIndex] = 200.0;
		g_iHypnoHit[iIndex] = 0;
		g_iHypnoHitMode[iIndex] = 0;
		g_flHypnoMeleeDivisor[iIndex] = 200.0;
		g_iHypnoMode[iIndex] = 0;
		g_flHypnoRange[iIndex] = 150.0;
		g_flHypnoRangeChance[iIndex] = 15.0;
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "hypnoability", false) || StrEqual(subsection, "hypno ability", false) || StrEqual(subsection, "hypno_ability", false) || StrEqual(subsection, "hypno", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_iImmunityFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iImmunityFlags2[admin];
			}
		}
	}

	if (type > 0)
	{
		MT_FindAbility(type, 26, bHasAbilities(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno"));
		g_iHumanAbility[type] = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iHypnoAbility[type] = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iHypnoAbility[type], value, 0, 1);
		g_iHypnoEffect[type] = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_iHypnoEffect[type], value, 0, 7);
		g_iHypnoMessage[type] = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iHypnoMessage[type], value, 0, 7);
		g_flHypnoBulletDivisor[type] = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoBulletDivisor", "Hypno Bullet Divisor", "Hypno_Bullet_Divisor", "bullet", g_flHypnoBulletDivisor[type], value, 0.1, 9999999999.0);
		g_flHypnoChance[type] = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoChance", "Hypno Chance", "Hypno_Chance", "chance", g_flHypnoChance[type], value, 0.0, 100.0);
		g_flHypnoDuration[type] = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoDuration", "Hypno Duration", "Hypno_Duration", "duration", g_flHypnoDuration[type], value, 0.1, 9999999999.0);
		g_flHypnoExplosiveDivisor[type] = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoExplosiveDivisor", "Hypno Explosive Divisor", "Hypno_Explosive_Divisor", "explosive", g_flHypnoExplosiveDivisor[type], value, 0.1, 9999999999.0);
		g_flHypnoFireDivisor[type] = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoFireDivisor", "Hypno Fire Divisor", "Hypno_Fire_Divisor", "fire", g_flHypnoFireDivisor[type], value, 0.1, 9999999999.0);
		g_iHypnoHit[type] = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoHit", "Hypno Hit", "Hypno_Hit", "hit", g_iHypnoHit[type], value, 0, 1);
		g_iHypnoHitMode[type] = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoHitMode", "Hypno Hit Mode", "Hypno_Hit_Mode", "hitmode", g_iHypnoHitMode[type], value, 0, 2);
		g_flHypnoMeleeDivisor[type] = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoMeleeDivisor", "Hypno Melee Divisor", "Hypno_Melee_Divisor", "melee", g_flHypnoMeleeDivisor[type], value, 0.1, 9999999999.0);
		g_iHypnoMode[type] = iGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoMode", "Hypno Mode", "Hypno_Mode", "mode", g_iHypnoMode[type], value, 0, 1);
		g_flHypnoRange[type] = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoRange", "Hypno Range", "Hypno_Range", "range", g_flHypnoRange[type], value, 1.0, 9999999999.0);
		g_flHypnoRangeChance[type] = flGetValue(subsection, "hypnoability", "hypno ability", "hypno_ability", "hypno", key, "HypnoRangeChance", "Hypno Range Chance", "Hypno_Range_Chance", "rangechance", g_flHypnoRangeChance[type], value, 0.0, 100.0);

		if (StrEqual(subsection, "hypnoability", false) || StrEqual(subsection, "hypno ability", false) || StrEqual(subsection, "hypno_ability", false) || StrEqual(subsection, "hypno", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags[type];
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_iImmunityFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iImmunityFlags[type];
			}
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveHypno(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iHypnoAbility[MT_GetTankType(tank)] == 1)
	{
		vHypnoAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & MT_SUB_KEY == MT_SUB_KEY)
		{
			if (g_iHypnoAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (!g_bHypno2[tank] && !g_bHypno3[tank])
				{
					vHypnoAbility(tank);
				}
				else if (g_bHypno2[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman3");
				}
				else if (g_bHypno3[tank])
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

	if (g_iHypnoCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		g_bHypno4[tank] = false;
		g_bHypno5[tank] = false;

		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_flHypnoRange[MT_GetTankType(tank)])
				{
					vHypnoHit(iSurvivor, tank, g_flHypnoRangeChance[MT_GetTankType(tank)], g_iHypnoAbility[MT_GetTankType(tank)], MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman5");
			}
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
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
		if (g_iHypnoCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bHypno[survivor])
			{
				g_bHypno[survivor] = true;
				g_iHypnoOwner[survivor] = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && (flags & MT_ATTACK_RANGE) && !g_bHypno2[tank])
				{
					g_bHypno2[tank] = true;
					g_iHypnoCount[tank]++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman", g_iHypnoCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
				}

				DataPack dpStopHypno;
				CreateDataTimer(g_flHypnoDuration[MT_GetTankType(tank)], tTimerStopHypno, dpStopHypno, TIMER_FLAG_NO_MAPCHANGE);
				dpStopHypno.WriteCell(GetClientUserId(survivor));
				dpStopHypno.WriteCell(GetClientUserId(tank));
				dpStopHypno.WriteCell(messages);

				vEffect(survivor, tank, g_iHypnoEffect[MT_GetTankType(tank)], flags);

				if (g_iHypnoMessage[MT_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Hypno", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && !g_bHypno2[tank])
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bHypno4[tank])
				{
					g_bHypno4[tank] = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoHuman2");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bHypno5[tank])
		{
			g_bHypno5[tank] = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "HypnoAmmo");
		}
	}
}

static void vRemoveHypno(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE) && g_bHypno[iSurvivor] && g_iHypnoOwner[iSurvivor] == tank)
		{
			g_bHypno[iSurvivor] = false;
			g_iHypnoOwner[iSurvivor] = 0;
		}
	}

	vReset2(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vReset2(iPlayer);

			g_iHypnoOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_bHypno[tank] = false;
	g_bHypno2[tank] = false;
	g_bHypno3[tank] = false;
	g_bHypno4[tank] = false;
	g_bHypno5[tank] = false;
	g_iHypnoCount[tank] = 0;
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_iAccessFlags[MT_GetTankType(admin)];
	if (iAbilityFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iAbilityFlags)) ? false : true;
		}
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iTypeFlags)) ? false : true;
		}
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iGlobalFlags)) ? false : true;
		}
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0)
		{
			return (!(iClientTypeFlags & iAbilityFlags)) ? false : true;
		}
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0)
		{
			return (!(iClientGlobalFlags & iAbilityFlags)) ? false : true;
		}
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

	int iAbilityFlags = g_iImmunityFlags[MT_GetTankType(survivor)];
	if (iAbilityFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iAbilityFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iTypeFlags = MT_GetImmunityFlags(2, MT_GetTankType(survivor));
	if (iTypeFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iTypeFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iGlobalFlags = MT_GetImmunityFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iGlobalFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iClientTypeFlags = MT_GetImmunityFlags(4, MT_GetTankType(tank), survivor),
		iClientTypeFlags2 = MT_GetImmunityFlags(4, MT_GetTankType(tank), tank);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0 && (iClientTypeFlags & iAbilityFlags))
		{
			return ((iClientTypeFlags2 & iAbilityFlags) && iClientTypeFlags <= iClientTypeFlags2) ? false : true;
		}
	}

	int iClientGlobalFlags = MT_GetImmunityFlags(3, 0, survivor),
		iClientGlobalFlags2 = MT_GetImmunityFlags(3, 0, tank);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0 && (iClientGlobalFlags & iAbilityFlags))
		{
			return ((iClientGlobalFlags2 & iAbilityFlags) && iClientGlobalFlags <= iClientGlobalFlags2) ? false : true;
		}
	}

	if (iAbilityFlags != 0)
	{
		return ((GetUserFlagBits(tank) & iAbilityFlags) && GetUserFlagBits(survivor) <= GetUserFlagBits(tank)) ? false : true;
	}

	return false;
}

public Action tTimerStopHypno(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bHypno[iSurvivor])
	{
		g_bHypno[iSurvivor] = false;
		g_iHypnoOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bHypno[iSurvivor] = false;
		g_iHypnoOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	g_bHypno[iSurvivor] = false;
	g_bHypno2[iTank] = false;
	g_iHypnoOwner[iSurvivor] = 0;

	int iMessage = pack.ReadCell();

	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_iHumanAbility[MT_GetTankType(iTank)] == 1 && (iMessage & MT_MESSAGE_RANGE) && !g_bHypno3[iTank])
	{
		g_bHypno3[iTank] = true;

		MT_PrintToChat(iTank, "%s %t", MT_TAG3, "HypnoHuman6");

		if (g_iHypnoCount[iTank] < g_iHumanAmmo[MT_GetTankType(iTank)] && g_iHumanAmmo[MT_GetTankType(iTank)] > 0)
		{
			CreateTimer(g_flHumanCooldown[MT_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bHypno3[iTank] = false;
		}
	}

	if (g_iHypnoMessage[MT_GetTankType(iTank)] & iMessage)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Hypno2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bHypno3[iTank])
	{
		g_bHypno3[iTank] = false;

		return Plugin_Stop;
	}

	g_bHypno3[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "HypnoHuman7");

	return Plugin_Continue;
}