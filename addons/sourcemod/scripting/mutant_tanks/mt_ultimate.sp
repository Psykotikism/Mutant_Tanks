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

#define PARTICLE_ELECTRICITY "electrical_arc_01_parent"

#define SOUND_ELECTRICITY "items/suitchargeok1.wav"
#define SOUND_EXPLOSION "ambient/explosions/explode_2.wav"
#define SOUND_GROWL1 "player/tank/voice/growl/hulk_growl_1.wav" //Only exists on L4D1
#define SOUND_GROWL2 "player/tank/voice/growl/tank_climb_01.wav" //Only exists on L4D2
#define SOUND_SMASH1 "player/tank/hit/hulk_punch_1.wav"
#define SOUND_SMASH2 "player/charger/hit/charger_smash_02.wav" //Only exists on L4D2

#define MT_MENU_ULTIMATE "Ultimate Ability"

bool g_bCloneInstalled;

enum struct esPlayerSettings
{
	bool g_bUltimate;
	bool g_bUltimate2;
	bool g_bUltimate3;

	float g_flUltimateDamage;

	int g_iAccessFlags2;
	int g_iImmunityFlags2;
	int g_iUltimateCount;
	int g_iUltimateCount2;
	int g_iUltimateHealth;
}

esPlayerSettings g_esPlayer[MAXPLAYERS + 1];

enum struct esAbilitySettings
{
	float g_flHumanCooldown;
	float g_flUltimateDamageBoost;
	float g_flUltimateDamageRequired;
	float g_flUltimateDuration;
	float g_flUltimateHealthPortion;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iImmunityFlags;
	int g_iUltimateAbility;
	int g_iUltimateAmount;
	int g_iUltimateHealthLimit;
	int g_iUltimateMessage;
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

	RegConsoleCmd("sm_mt_god", cmdUltimateInfo, "View information about the Ultimate ability.");

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
	vPrecacheParticle(PARTICLE_ELECTRICITY);

	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_EXPLOSION, true);

	if (bIsValidGame())
	{
		PrecacheSound(SOUND_GROWL2, true);
		PrecacheSound(SOUND_SMASH2, true);
	}
	else
	{
		PrecacheSound(SOUND_GROWL1, true);
		PrecacheSound(SOUND_SMASH1, true);
	}

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

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iUltimateAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iUltimateCount2, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esAbility[MT_GetTankType(param1)].g_flHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "UltimateDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esAbility[MT_GetTankType(param1)].g_flUltimateDuration);
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
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
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage > 0.0)
	{
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (g_esAbility[MT_GetTankType(attacker)].g_iUltimateAbility == 1)
			{
				if (!g_esPlayer[attacker].g_bUltimate)
				{
					g_esPlayer[attacker].g_flUltimateDamage += damage;

					if (MT_IsTankSupported(attacker, MT_CHECK_FAKECLIENT))
					{
						MT_PrintToChat(attacker, "%s %t", MT_TAG3, "Ultimate3", g_esPlayer[attacker].g_flUltimateDamage, g_esAbility[MT_GetTankType(attacker)].g_flUltimateDamageRequired);
					}

					if (g_esPlayer[attacker].g_flUltimateDamage >= g_esAbility[MT_GetTankType(attacker)].g_flUltimateDamageRequired)
					{
						g_esPlayer[attacker].g_bUltimate = true;

						if (MT_IsTankSupported(attacker, MT_CHECK_FAKECLIENT))
						{
							MT_PrintToChat(attacker, "%s %t", MT_TAG3, "Ultimate4");
						}
					}
				}

				if (g_esPlayer[attacker].g_bUltimate2 && !g_esPlayer[attacker].g_bUltimate3)
				{
					damage *= g_esAbility[MT_GetTankType(attacker)].g_flUltimateDamageBoost;

					return Plugin_Changed;
				}
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
	list.PushString("ultimateability");
	list2.PushString("ultimate ability");
	list3.PushString("ultimate_ability");
	list4.PushString("ultimate");
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
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "ultimateability", false) || StrEqual(subsection, "ultimate ability", false) || StrEqual(subsection, "ultimate_ability", false) || StrEqual(subsection, "ultimate", false))
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
		g_esAbility[type].g_iHumanAbility = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAmmo = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_flHumanCooldown = flGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_flHumanCooldown, value, 0.0, 999999.0);
		g_esAbility[type].g_iUltimateAbility = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iUltimateAbility, value, 0, 1);
		g_esAbility[type].g_iUltimateMessage = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iUltimateMessage, value, 0, 1);
		g_esAbility[type].g_iUltimateAmount = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateAmount", "Ultimate Amount", "Ultimate_Amount", "amount", g_esAbility[type].g_iUltimateAmount, value, 1, 999999);
		g_esAbility[type].g_flUltimateDamageBoost = flGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateDamageBoost", "Ultimate Damage Boost", "Ultimate_Damage_Boost", "dmgboost", g_esAbility[type].g_flUltimateDamageBoost, value, 0.1, 999999.0);
		g_esAbility[type].g_flUltimateDamageRequired = flGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateDamageRequired", "Ultimate Damage Required", "Ultimate_Damage_Required", "dmgrequired", g_esAbility[type].g_flUltimateDamageRequired, value, 0.1, 999999.0);
		g_esAbility[type].g_flUltimateDuration = flGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateDuration", "Ultimate Duration", "Ultimate_Duration", "duration", g_esAbility[type].g_flUltimateDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_iUltimateHealthLimit = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateHealthLimit", "Ultimate Health Limit", "Ultimate_Health_Limit", "healthlimit", g_esAbility[type].g_iUltimateHealthLimit, value, 1, MT_MAXHEALTH);
		g_esAbility[type].g_flUltimateHealthPortion = flGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateHealthPortion", "Ultimate Health Portion", "Ultimate_Health_Portion", "healthportion", g_esAbility[type].g_flUltimateHealthPortion, value, 0.1, 1.0);

		if (StrEqual(subsection, "ultimateability", false) || StrEqual(subsection, "ultimate ability", false) || StrEqual(subsection, "ultimate_ability", false) || StrEqual(subsection, "ultimate", false))
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

public void MT_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iTank].g_bUltimate)
		{
			SetEntProp(iTank, Prop_Data, "m_takedamage", 2, 1);
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveUltimate(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esAbility[MT_GetTankType(tank)].g_iUltimateAbility == 1 && g_esPlayer[tank].g_bUltimate && !g_esPlayer[tank].g_bUltimate2)
	{
		vUltimateAbility(tank);
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

		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if (g_esAbility[MT_GetTankType(tank)].g_iUltimateAbility == 1 && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				if (!g_esPlayer[tank].g_bUltimate)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateHuman2");

					return;
				}

				if (!g_esPlayer[tank].g_bUltimate2 && !g_esPlayer[tank].g_bUltimate3)
				{
					vUltimateAbility(tank);
				}
				else if (g_esPlayer[tank].g_bUltimate2)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateHuman3");
				}
				else if (g_esPlayer[tank].g_bUltimate3)
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
		g_esPlayer[tank].g_iUltimateHealth = GetClientHealth(tank);
	}
}

static void vUltimateAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (GetClientHealth(tank) <= g_esAbility[MT_GetTankType(tank)].g_iUltimateHealthLimit)
	{
		if (g_esPlayer[tank].g_iUltimateCount< g_esAbility[MT_GetTankType(tank)].g_iUltimateAmount && g_esPlayer[tank].g_iUltimateCount2 < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
		{
			g_esPlayer[tank].g_bUltimate2 = true;
			g_esPlayer[tank].g_iUltimateCount++;
			g_esPlayer[tank].g_flUltimateDamage = 0.0;

			ExtinguishEntity(tank);
			vAttachParticle(tank, PARTICLE_ELECTRICITY, 2.0, 30.0);
			EmitSoundToAll(SOUND_ELECTRICITY, tank);
			EmitSoundToAll(SOUND_EXPLOSION, tank);

			if (bIsValidGame())
			{
				EmitSoundToAll(SOUND_GROWL2, tank);
				EmitSoundToAll(SOUND_SMASH2, tank);
			}
			else
			{
				EmitSoundToAll(SOUND_GROWL1, tank);
				EmitSoundToAll(SOUND_SMASH1, tank);
			}

 			SetEntityHealth(tank, RoundToNearest(g_esPlayer[tank].g_iUltimateHealth * g_esAbility[MT_GetTankType(tank)].g_flUltimateHealthPortion));
			//SetEntProp(tank, Prop_Send, "m_iHealth", RoundToNearest(g_esPlayer[tank].g_iUltimateHealth * g_esAbility[MT_GetTankType(tank)].g_flUltimateHealthPortion));
			SetEntProp(tank, Prop_Data, "m_takedamage", 0, 1);

			CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flUltimateDuration, tTimerStopUltimate, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				g_esPlayer[tank].g_iUltimateCount2++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateHuman", g_esPlayer[tank].g_iUltimateCount2, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
			}

			if (g_esAbility[MT_GetTankType(tank)].g_iUltimateMessage == 1)
			{
				char sTankName[33];
				MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Ultimate", sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateAmmo");
		}
	}
}

static void vRemoveUltimate(int tank)
{
	g_esPlayer[tank].g_bUltimate = false;
	g_esPlayer[tank].g_bUltimate2 = false;
	g_esPlayer[tank].g_bUltimate3 = false;
	g_esPlayer[tank].g_flUltimateDamage = 0.0;
	g_esPlayer[tank].g_iUltimateCount = 0;
	g_esPlayer[tank].g_iUltimateCount2 = 0;

	if (MT_IsTankSupported(tank))
	{
		SetEntProp(tank, Prop_Data, "m_takedamage", 2, 1);
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveUltimate(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bUltimate3 = true;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "UltimateHuman5");

	if (g_esPlayer[tank].g_iUltimateCount2 < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
	{
		CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flHumanCooldown, tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_esPlayer[tank].g_bUltimate3 = false;
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

public Action tTimerStopUltimate(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled))
	{
		g_esPlayer[iTank].g_bUltimate = false;
		g_esPlayer[iTank].g_bUltimate2 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bUltimate = false;
	g_esPlayer[iTank].g_bUltimate2 = false;

	SetEntProp(iTank, Prop_Data, "m_takedamage", 2, 1);

	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && !g_esPlayer[iTank].g_bUltimate3)
	{
		vReset2(iTank);
	}

	if (g_esAbility[MT_GetTankType(iTank)].g_iUltimateMessage == 1)
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
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iTank].g_bUltimate3)
	{
		g_esPlayer[iTank].g_bUltimate3 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bUltimate3 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "UltimateHuman6");

	return Plugin_Continue;
}