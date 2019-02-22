/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2018  Alfred "Crasher_3637/Psyk0tik" Llagas
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

bool g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1], g_bUltimate[MAXPLAYERS + 1], g_bUltimate2[MAXPLAYERS + 1], g_bUltimate3[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flUltimateDamage[MAXPLAYERS + 1], g_flUltimateDamageBoost[ST_MAXTYPES + 1], g_flUltimateDamageBoost2[ST_MAXTYPES + 1], g_flUltimateDamageRequired[ST_MAXTYPES + 1], g_flUltimateDamageRequired2[ST_MAXTYPES + 1], g_flUltimateDuration[ST_MAXTYPES + 1], g_flUltimateDuration2[ST_MAXTYPES + 1], g_flUltimateHealthPortion[ST_MAXTYPES + 1], g_flUltimateHealthPortion2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iUltimateAbility[ST_MAXTYPES + 1], g_iUltimateAbility2[ST_MAXTYPES + 1], g_iUltimateAmount[ST_MAXTYPES + 1], g_iUltimateAmount2[ST_MAXTYPES + 1], g_iUltimateCount[MAXPLAYERS + 1], g_iUltimateCount2[MAXPLAYERS + 1], g_iUltimateHealth[MAXPLAYERS + 1], g_iUltimateHealthLimit[ST_MAXTYPES + 1], g_iUltimateHealthLimit2[ST_MAXTYPES + 1], g_iUltimateMessage[ST_MAXTYPES + 1], g_iUltimateMessage2[ST_MAXTYPES + 1];

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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iUltimateAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iUltimateCount2[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "UltimateDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flUltimateDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
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
		if (ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (iUltimateAbility(attacker) == 1)
			{
				float flUltimateDamageRequired = !g_bTankConfig[ST_GetTankType(attacker)] ? g_flUltimateDamageRequired[ST_GetTankType(attacker)] : g_flUltimateDamageRequired2[ST_GetTankType(attacker)];
				if (!g_bUltimate[attacker])
				{
					g_flUltimateDamage[attacker] += damage;

					if (ST_IsTankSupported(attacker, ST_CHECK_FAKECLIENT))
					{
						ST_PrintToChat(attacker, "%s %t", ST_TAG3, "Ultimate3", g_flUltimateDamage[attacker], flUltimateDamageRequired);
					}

					if (g_flUltimateDamage[attacker] >= flUltimateDamageRequired)
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
					float flUltimateDamageBoost = !g_bTankConfig[ST_GetTankType(attacker)] ? g_flUltimateDamageBoost[ST_GetTankType(attacker)] : g_flUltimateDamageBoost2[ST_GetTankType(attacker)];
					damage *= flUltimateDamageBoost;

					return Plugin_Changed;
				}
			}
		}
	}

	return Plugin_Continue;
}

public void ST_OnConfigsLoaded(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);

	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		char sTankName[33];
		Format(sTankName, sizeof(sTankName), "Tank #%i", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName))
		{
			switch (main)
			{
				case true:
				{
					g_bTankConfig[iIndex] = false;

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Ultimate Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Ultimate Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Ultimate Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iUltimateAbility[iIndex] = kvSuperTanks.GetNum("Ultimate Ability/Ability Enabled", 0);
					g_iUltimateAbility[iIndex] = iClamp(g_iUltimateAbility[iIndex], 0, 1);
					g_iUltimateMessage[iIndex] = kvSuperTanks.GetNum("Ultimate Ability/Ability Message", 0);
					g_iUltimateMessage[iIndex] = iClamp(g_iUltimateMessage[iIndex], 0, 1);
					g_iUltimateAmount[iIndex] = kvSuperTanks.GetNum("Ultimate Ability/Ultimate Amount", 1);
					g_iUltimateAmount[iIndex] = iClamp(g_iUltimateAmount[iIndex], 1, 9999999999);
					g_flUltimateDamageBoost[iIndex] = kvSuperTanks.GetFloat("Ultimate Ability/Ultimate Damage Boost", 1.2);
					g_flUltimateDamageBoost[iIndex] = flClamp(g_flUltimateDamageBoost[iIndex], 0.1, 9999999999.0);
					g_flUltimateDamageRequired[iIndex] = kvSuperTanks.GetFloat("Ultimate Ability/Ultimate Damage Required", 200.0);
					g_flUltimateDamageRequired[iIndex] = flClamp(g_flUltimateDamageRequired[iIndex], 0.1, 9999999999.0);
					g_flUltimateDuration[iIndex] = kvSuperTanks.GetFloat("Ultimate Ability/Ultimate Duration", 5.0);
					g_flUltimateDuration[iIndex] = flClamp(g_flUltimateDuration[iIndex], 0.1, 9999999999.0);
					g_iUltimateHealthLimit[iIndex] = kvSuperTanks.GetNum("Ultimate Ability/Ultimate Health Limit", 100);
					g_iUltimateHealthLimit[iIndex] = iClamp(g_iUltimateHealthLimit[iIndex], 1, ST_MAXHEALTH);
					g_flUltimateHealthPortion[iIndex] = kvSuperTanks.GetFloat("Ultimate Ability/Ultimate Health Portion", 0.5);
					g_flUltimateHealthPortion[iIndex] = flClamp(g_flUltimateHealthPortion[iIndex], 0.1, 1.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Ultimate Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Ultimate Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Ultimate Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iUltimateAbility2[iIndex] = kvSuperTanks.GetNum("Ultimate Ability/Ability Enabled", g_iUltimateAbility[iIndex]);
					g_iUltimateAbility2[iIndex] = iClamp(g_iUltimateAbility2[iIndex], 0, 1);
					g_iUltimateMessage2[iIndex] = kvSuperTanks.GetNum("Ultimate Ability/Ability Message", g_iUltimateMessage[iIndex]);
					g_iUltimateMessage2[iIndex] = iClamp(g_iUltimateMessage2[iIndex], 0, 1);
					g_iUltimateAmount2[iIndex] = kvSuperTanks.GetNum("Ultimate Ability/Ultimate Amount", g_iUltimateAmount[iIndex]);
					g_iUltimateAmount2[iIndex] = iClamp(g_iUltimateAmount2[iIndex], 1, 9999999999);
					g_flUltimateDamageBoost2[iIndex] = kvSuperTanks.GetFloat("Ultimate Ability/Ultimate Damage Boost", g_flUltimateDamageBoost[iIndex]);
					g_flUltimateDamageBoost2[iIndex] = flClamp(g_flUltimateDamageBoost2[iIndex], 0.1, 9999999999.0);
					g_flUltimateDamageRequired2[iIndex] = kvSuperTanks.GetFloat("Ultimate Ability/Ultimate Damage Required", g_flUltimateDamageRequired[iIndex]);
					g_flUltimateDamageRequired2[iIndex] = flClamp(g_flUltimateDamageRequired2[iIndex], 0.1, 9999999999.0);
					g_flUltimateDuration2[iIndex] = kvSuperTanks.GetFloat("Ultimate Ability/Ultimate Duration", g_flUltimateDuration[iIndex]);
					g_flUltimateDuration2[iIndex] = flClamp(g_flUltimateDuration2[iIndex], 0.1, 9999999999.0);
					g_iUltimateHealthLimit2[iIndex] = kvSuperTanks.GetNum("Ultimate Ability/Ultimate Health Limit", g_iUltimateHealthLimit[iIndex]);
					g_iUltimateHealthLimit2[iIndex] = iClamp(g_iUltimateHealthLimit2[iIndex], 1, ST_MAXHEALTH);
					g_flUltimateHealthPortion2[iIndex] = kvSuperTanks.GetFloat("Ultimate Ability/Ultimate Health Portion", g_flUltimateHealthPortion[iIndex]);
					g_flUltimateHealthPortion2[iIndex] = flClamp(g_flUltimateHealthPortion2[iIndex], 0.1, 1.0);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
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
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iUltimateAbility(tank) == 1 && g_bUltimate[tank] && !g_bUltimate2[tank])
	{
		vUltimateAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iUltimateAbility(tank) == 1 && iHumanAbility(tank) == 1)
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

public void ST_OnChangeType(int tank)
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
	int iUltimateHealthLimit = !g_bTankConfig[ST_GetTankType(tank)] ? g_iUltimateHealthLimit[ST_GetTankType(tank)] : g_iUltimateHealthLimit2[ST_GetTankType(tank)];
	if (GetClientHealth(tank) <= iUltimateHealthLimit)
	{
		int iUltimateAmount = !g_bTankConfig[ST_GetTankType(tank)] ? g_iUltimateAmount[ST_GetTankType(tank)] : g_iUltimateAmount2[ST_GetTankType(tank)];
		if (g_iUltimateCount[tank] < iUltimateAmount && g_iUltimateCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
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

			float flUltimateHealthPortion = !g_bTankConfig[ST_GetTankType(tank)] ? g_flUltimateHealthPortion[ST_GetTankType(tank)] : g_flUltimateHealthPortion2[ST_GetTankType(tank)];
			SetEntityHealth(tank, RoundToNearest(g_iUltimateHealth[tank] * flUltimateHealthPortion));

			SetEntProp(tank, Prop_Data, "m_takedamage", 0, 1);

			CreateTimer(flUltimateDuration(tank), tTimerStopUltimate, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
			{
				g_iUltimateCount2[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "UltimateHuman", g_iUltimateCount2[tank], iHumanAmmo(tank));
			}

			if (iUltimateMessage(tank) == 1)
			{
				char sTankName[33];
				ST_GetTankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Ultimate", sTankName);
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
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

	if (g_iUltimateCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bUltimate3[tank] = false;
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flUltimateDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flUltimateDuration[ST_GetTankType(tank)] : g_flUltimateDuration2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iUltimateAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iUltimateAbility[ST_GetTankType(tank)] : g_iUltimateAbility2[ST_GetTankType(tank)];
}

static int iUltimateMessage(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iUltimateMessage[ST_GetTankType(tank)] : g_iUltimateMessage2[ST_GetTankType(tank)];
}

public Action tTimerStopUltimate(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank) || !ST_IsCloneSupported(iTank, g_bCloneInstalled))
	{
		g_bUltimate[iTank] = false;
		g_bUltimate2[iTank] = false;

		return Plugin_Stop;
	}

	g_bUltimate[iTank] = false;
	g_bUltimate2[iTank] = false;

	SetEntProp(iTank, Prop_Data, "m_takedamage", 2, 1);

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && iHumanAbility(iTank) == 1 && !g_bUltimate3[iTank])
	{
		vReset2(iTank);
	}

	if (iUltimateMessage(iTank) == 1)
	{
		char sTankName[33];
		ST_GetTankName(iTank, sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Ultimate2", sTankName);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bUltimate3[iTank])
	{
		g_bUltimate3[iTank] = false;

		return Plugin_Stop;
	}

	g_bUltimate3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "UltimateHuman6");

	return Plugin_Continue;
}