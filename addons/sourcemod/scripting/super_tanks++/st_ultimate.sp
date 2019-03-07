/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
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
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Ultimate Ability",
	author = ST_AUTHOR,
	description = "The Super Tank activates ultimate mode when low on health to gain temporary godmode and damage boost.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Ultimate Ability\" only supports Left 4 Dead 1 & 2.");

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

#define ST_MENU_ULTIMATE "Ultimate Ability"

bool g_bCloneInstalled, g_bUltimate[MAXPLAYERS + 1], g_bUltimate2[MAXPLAYERS + 1], g_bUltimate3[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flUltimateDamage[MAXPLAYERS + 1], g_flUltimateDamageBoost[ST_MAXTYPES + 1], g_flUltimateDamageRequired[ST_MAXTYPES + 1], g_flUltimateDuration[ST_MAXTYPES + 1], g_flUltimateHealthPortion[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iUltimateAbility[ST_MAXTYPES + 1], g_iUltimateAmount[ST_MAXTYPES + 1], g_iUltimateCount[MAXPLAYERS + 1], g_iUltimateCount2[MAXPLAYERS + 1], g_iUltimateHealth[MAXPLAYERS + 1], g_iUltimateHealthLimit[ST_MAXTYPES + 1], g_iUltimateMessage[ST_MAXTYPES + 1];

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("st_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_god", cmdUltimateInfo, "View information about the Ultimate ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
	if (!ST_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Super Tanks++\x01 is disabled.", ST_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", ST_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", ST_TAG2, "Vote in Progress");
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iUltimateAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iUltimateCount2[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "UltimateDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flUltimateDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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

public void ST_OnDisplayMenu(Menu menu)
{
	menu.AddItem(ST_MENU_ULTIMATE, ST_MENU_ULTIMATE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_ULTIMATE, false))
	{
		vUltimateMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (g_iUltimateAbility[ST_GetTankType(attacker)] == 1)
			{
				if (!g_bUltimate[attacker])
				{
					g_flUltimateDamage[attacker] += damage;

					if (ST_IsTankSupported(attacker, ST_CHECK_FAKECLIENT))
					{
						ST_PrintToChat(attacker, "%s %t", ST_TAG3, "Ultimate3", g_flUltimateDamage[attacker], g_flUltimateDamageRequired[ST_GetTankType(attacker)]);
					}

					if (g_flUltimateDamage[attacker] >= g_flUltimateDamageRequired[ST_GetTankType(attacker)])
					{
						g_bUltimate[attacker] = true;

						if (ST_IsTankSupported(attacker, ST_CHECK_FAKECLIENT))
						{
							ST_PrintToChat(attacker, "%s %t", ST_TAG3, "Ultimate4");
						}
					}
				}

				if (g_bUltimate2[attacker] && !g_bUltimate3[attacker])
				{
					damage *= g_flUltimateDamageBoost[ST_GetTankType(attacker)];

					return Plugin_Changed;
				}
			}
		}
	}

	return Plugin_Continue;
}

public void ST_OnConfigsLoad()
{
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	ST_FindAbility(type, 62, bHasAbilities(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate"));
	g_iHumanAbility[type] = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iUltimateAbility[type] = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iUltimateAbility[type], value, 0, 0, 1);
	g_iUltimateMessage[type] = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iUltimateMessage[type], value, 0, 0, 1);
	g_iUltimateAmount[type] = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateAmount", "Ultimate Amount", "Ultimate_Amount", "amount", main, g_iUltimateAmount[type], value, 1, 1, 9999999999);
	g_flUltimateDamageBoost[type] = flGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateDamageBoost", "Ultimate Damage Boost", "Ultimate_Damage_Boost", "dmgboost", main, g_flUltimateDamageBoost[type], value, 1.2, 0.1, 9999999999.0);
	g_flUltimateDamageRequired[type] = flGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateDamageRequired", "Ultimate Damage Required", "Ultimate_Damage_Required", "dmgrequired", main, g_flUltimateDamageRequired[type], value, 200.0, 0.1, 9999999999.0);
	g_flUltimateDuration[type] = flGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateDuration", "Ultimate Duration", "Ultimate_Duration", "duration", main, g_flUltimateDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iUltimateHealthLimit[type] = iGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateHealthLimit", "Ultimate Health Limit", "Ultimate_Health_Limit", "healthlimit", main, g_iUltimateHealthLimit[type], value, 100, 1, ST_MAXHEALTH);
	g_flUltimateHealthPortion[type] = flGetValue(subsection, "ultimateability", "ultimate ability", "ultimate_ability", "ultimate", key, "UltimateHealthPortion", "Ultimate Health Portion", "Ultimate_Health_Portion", "healthportion", main, g_flUltimateHealthPortion[type], value, 0.5, 0.1, 1.0);
}

public void ST_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bUltimate[iTank])
		{
			SetEntProp(iTank, Prop_Data, "m_takedamage", 2, 1);
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveUltimate(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iUltimateAbility[ST_GetTankType(tank)] == 1 && g_bUltimate[tank] && !g_bUltimate2[tank])
	{
		vUltimateAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (g_iUltimateAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bUltimate[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "UltimateHuman2");

					return;
				}

				if (!g_bUltimate2[tank] && !g_bUltimate3[tank])
				{
					vUltimateAbility(tank);
				}
				else if (g_bUltimate2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "UltimateHuman3");
				}
				else if (g_bUltimate3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "UltimateHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveUltimate(tank);
}

public void ST_OnPostTankSpawn(int tank)
{
	if (ST_IsTankSupported(tank))
	{
		g_iUltimateHealth[tank] = GetClientHealth(tank);
	}
}

static void vUltimateAbility(int tank)
{
	if (GetClientHealth(tank) <= g_iUltimateHealthLimit[ST_GetTankType(tank)])
	{
		if (g_iUltimateCount[tank] < g_iUltimateAmount[ST_GetTankType(tank)] && g_iUltimateCount2[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
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

			SetEntityHealth(tank, RoundToNearest(g_iUltimateHealth[tank] * g_flUltimateHealthPortion[ST_GetTankType(tank)]));

			SetEntProp(tank, Prop_Data, "m_takedamage", 0, 1);

			CreateTimer(g_flUltimateDuration[ST_GetTankType(tank)], tTimerStopUltimate, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				g_iUltimateCount2[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "UltimateHuman", g_iUltimateCount2[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
			}

			if (g_iUltimateMessage[ST_GetTankType(tank)] == 1)
			{
				char sTankName[33];
				ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Ultimate", sTankName);
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "UltimateAmmo");
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

	if (ST_IsTankSupported(tank))
	{
		SetEntProp(tank, Prop_Data, "m_takedamage", 2, 1);
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveUltimate(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bUltimate3[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "UltimateHuman5");

	if (g_iUltimateCount2[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bUltimate3[tank] = false;
	}
}

public Action tTimerStopUltimate(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bUltimate[iTank] = false;
		g_bUltimate2[iTank] = false;

		return Plugin_Stop;
	}

	g_bUltimate[iTank] = false;
	g_bUltimate2[iTank] = false;

	SetEntProp(iTank, Prop_Data, "m_takedamage", 2, 1);

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && !g_bUltimate3[iTank])
	{
		vReset2(iTank);
	}

	if (g_iUltimateMessage[ST_GetTankType(iTank)] == 1)
	{
		char sTankName[33];
		ST_GetTankName(iTank, ST_GetTankType(iTank), sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Ultimate2", sTankName);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bUltimate3[iTank])
	{
		g_bUltimate3[iTank] = false;

		return Plugin_Stop;
	}

	g_bUltimate3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "UltimateHuman6");

	return Plugin_Continue;
}