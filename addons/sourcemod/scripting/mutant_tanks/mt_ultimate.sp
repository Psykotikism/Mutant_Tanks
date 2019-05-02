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
	name = "[MT] Ultimate Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank activates ultimate mode when low on health to gain temporary godmode and damage boost.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Ultimate Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_ELECTRICITY "electrical_arc_01_system"

#define SOUND_ELECTRICITY "items/suitchargeok1.wav"
#define SOUND_EXPLOSION "ambient/explosions/exp2.wav"
#define SOUND_GROWL "player/tank/voice/growl/tank_climb_01.wav"
#define SOUND_SMASH "player/charger/hit/charger_smash_02.wav"

#define MT_MENU_ULTIMATE "Ultimate Ability"

bool g_bCloneInstalled, g_bUltimate[MAXPLAYERS + 1], g_bUltimate2[MAXPLAYERS + 1], g_bUltimate3[MAXPLAYERS + 1];

float g_flHumanCooldown[MT_MAXTYPES + 1], g_flUltimateDamage[MAXPLAYERS + 1], g_flUltimateDamageBoost[MT_MAXTYPES + 1], g_flUltimateDamageRequired[MT_MAXTYPES + 1], g_flUltimateDuration[MT_MAXTYPES + 1], g_flUltimateHealthPortion[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1], g_iImmunityFlags[MT_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1], g_iUltimateAbility[MT_MAXTYPES + 1], g_iUltimateAmount[MT_MAXTYPES + 1], g_iUltimateCount[MAXPLAYERS + 1], g_iUltimateCount2[MAXPLAYERS + 1], g_iUltimateHealth[MAXPLAYERS + 1], g_iUltimateHealthLimit[MT_MAXTYPES + 1], g_iUltimateMessage[MT_MAXTYPES + 1];

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

	RegConsoleCmd("sm_mt_god", cmdUltimateInfo, "View information about the Ultimate ability.");

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
	vPrecacheParticle(PARTICLE_ELECTRICITY);

	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_EXPLOSION, true);
	PrecacheSound(SOUND_GROWL, true);
	PrecacheSound(SOUND_SMASH, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveUltimate(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdUltimateInfo(int client, int args)
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
		case false: vUltimateMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vUltimateMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iUltimateMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Ultimate Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iUltimateMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iUltimateAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iUltimateCount2[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "UltimateDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_flUltimateDuration[MT_GetTankType(param1)]);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
			{
				vUltimateMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "UltimateMenu", param1);
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
	menu.AddItem(MT_MENU_ULTIMATE, MT_MENU_ULTIMATE);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_ULTIMATE, false))
	{
		vUltimateMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && damage > 0.0)
	{
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (g_iUltimateAbility[MT_GetTankType(attacker)] == 1)
			{
				if (!g_bUltimate[attacker])
				{
					g_flUltimateDamage[attacker] += damage;

					if (MT_IsTankSupported(attacker, MT_CHECK_FAKECLIENT))
					{
						MT_PrintToChat(attacker, "%s %t", MT_TAG3, "Ultimate3", g_flUltimateDamage[attacker], g_flUltimateDamageRequired[MT_GetTankType(attacker)]);
					}

					if (g_flUltimateDamage[attacker] >= g_flUltimateDamageRequired[MT_GetTankType(attacker)])
					{
						g_bUltimate[attacker] = true;

						if (MT_IsTankSupported(attacker, MT_CHECK_FAKECLIENT))
						{
							MT_PrintToChat(attacker, "%s %t", MT_TAG3, "Ultimate4");
						}
					}
				}

				if (g_bUltimate2[attacker] && !g_bUltimate3[attacker])
				{
					damage *= g_flUltimateDamageBoost[MT_GetTankType(attacker)];

					return Plugin_Changed;
				}
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
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "ultimateability", false) || StrEqual(subsection, "ultimate ability", false) || StrEqual(subsection, "ultimate_ability", false) || StrEqual(subsection, "ultimate", false))
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
		g_iHumanAbility[type] = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iUltimateAbility[type] = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iUltimateAbility[type], value, 0, 1);
		g_iUltimateMessage[type] = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iUltimateMessage[type], value, 0, 1);
		g_iUltimateAmount[type] = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateAmount", "Ultimate Amount", "Ultimate_Amount", "amount", g_iUltimateAmount[type], value, 1, 9999999999);
		g_flUltimateDamageBoost[type] = flGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateDamageBoost", "Ultimate Damage Boost", "Ultimate_Damage_Boost", "dmgboost", g_flUltimateDamageBoost[type], value, 0.1, 9999999999.0);
		g_flUltimateDamageRequired[type] = flGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateDamageRequired", "Ultimate Damage Required", "Ultimate_Damage_Required", "dmgrequired", g_flUltimateDamageRequired[type], value, 0.1, 9999999999.0);
		g_flUltimateDuration[type] = flGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateDuration", "Ultimate Duration", "Ultimate_Duration", "duration", g_flUltimateDuration[type], value, 0.1, 9999999999.0);
		g_iUltimateHealthLimit[type] = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateHealthLimit", "Ultimate Health Limit", "Ultimate_Health_Limit", "healthlimit", g_iUltimateHealthLimit[type], value, 1, MT_MAXHEALTH);
		g_flUltimateHealthPortion[type] = flGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateHealthPortion", "Ultimate Health Portion", "Ultimate_Health_Portion", "healthportion", g_flUltimateHealthPortion[type], value, 0.1, 1.0);

		if (StrEqual(subsection, "ultimateability", false) || StrEqual(subsection, "ultimate ability", false) || StrEqual(subsection, "ultimate_ability", false) || StrEqual(subsection, "ultimate", false))
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

public void MT_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && g_bUltimate[iTank])
		{
			SetEntProp(iTank, Prop_Data, "m_takedamage", 2, 1);
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveUltimate(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iUltimateAbility[MT_GetTankType(tank)] == 1 && g_bUltimate[tank] && !g_bUltimate2[tank])
	{
		vUltimateAbility(tank);
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

		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if (g_iUltimateAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (!g_bUltimate[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateHuman2");

					return;
				}

				if (!g_bUltimate2[tank] && !g_bUltimate3[tank])
				{
					vUltimateAbility(tank);
				}
				else if (g_bUltimate2[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateHuman3");
				}
				else if (g_bUltimate3[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateHuman4");
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveUltimate(tank);
}

public void MT_OnPostTankSpawn(int tank)
{
	if (MT_IsTankSupported(tank))
	{
		g_iUltimateHealth[tank] = GetClientHealth(tank);
	}
}

static void vUltimateAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (GetClientHealth(tank) <= g_iUltimateHealthLimit[MT_GetTankType(tank)])
	{
		if (g_iUltimateCount[tank] < g_iUltimateAmount[MT_GetTankType(tank)] && g_iUltimateCount2[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
		{
			g_bUltimate2[tank] = true;
			g_iUltimateCount[tank]++;
			g_flUltimateDamage[tank] = 0.0;

			ExtinguishEntity(tank);
			vAttachParticle(tank, PARTICLE_ELECTRICITY, 2.0, 30.0);
			EmitSoundToAll(SOUND_ELECTRICITY, tank);
			EmitSoundToAll(SOUND_EXPLOSION, tank);
			EmitSoundToAll(SOUND_GROWL, tank);
			EmitSoundToAll(SOUND_SMASH, tank);

			SetEntityHealth(tank, RoundToNearest(g_iUltimateHealth[tank] * g_flUltimateHealthPortion[MT_GetTankType(tank)]));

			SetEntProp(tank, Prop_Data, "m_takedamage", 0, 1);

			CreateTimer(g_flUltimateDuration[MT_GetTankType(tank)], tTimerStopUltimate, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				g_iUltimateCount2[tank]++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateHuman", g_iUltimateCount2[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
			}

			if (g_iUltimateMessage[MT_GetTankType(tank)] == 1)
			{
				char sTankName[33];
				MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Ultimate", sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateAmmo");
		}
	}
}

static void vRemoveUltimate(int tank)
{
	g_bUltimate[tank] = false;
	g_bUltimate2[tank] = false;
	g_bUltimate3[tank] = false;
	g_flUltimateDamage[tank] = 0.0;
	g_iUltimateCount[tank] = 0;
	g_iUltimateCount2[tank] = 0;

	if (MT_IsTankSupported(tank))
	{
		SetEntProp(tank, Prop_Data, "m_takedamage", 2, 1);
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveUltimate(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bUltimate3[tank] = true;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateHuman5");

	if (g_iUltimateCount2[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[MT_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bUltimate3[tank] = false;
	}
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

public Action tTimerStopUltimate(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bUltimate[iTank] = false;
		g_bUltimate2[iTank] = false;

		return Plugin_Stop;
	}

	g_bUltimate[iTank] = false;
	g_bUltimate2[iTank] = false;

	SetEntProp(iTank, Prop_Data, "m_takedamage", 2, 1);

	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_iHumanAbility[MT_GetTankType(iTank)] == 1 && !g_bUltimate3[iTank])
	{
		vReset2(iTank);
	}

	if (g_iUltimateMessage[MT_GetTankType(iTank)] == 1)
	{
		char sTankName[33];
		MT_GetTankName(iTank, MT_GetTankType(iTank), sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Ultimate2", sTankName);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bUltimate3[iTank])
	{
		g_bUltimate3[iTank] = false;

		return Plugin_Stop;
	}

	g_bUltimate3[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "UltimateHuman6");

	return Plugin_Continue;
}