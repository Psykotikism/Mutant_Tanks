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
	name = "[ST++] Enforce Ability",
	author = ST_AUTHOR,
	description = "The Super Tank forces survivors to only use a certain weapon slot.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Enforce Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_ENFORCE "Enforce Ability"

bool g_bCloneInstalled, g_bEnforce[MAXPLAYERS + 1], g_bEnforce2[MAXPLAYERS + 1], g_bEnforce3[MAXPLAYERS + 1], g_bEnforce4[MAXPLAYERS + 1], g_bEnforce5[MAXPLAYERS + 1];

float g_flEnforceChance[ST_MAXTYPES + 1], g_flEnforceDuration[ST_MAXTYPES + 1], g_flEnforceRange[ST_MAXTYPES + 1], g_flEnforceRangeChance[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1];

int g_iEnforceAbility[ST_MAXTYPES + 1], g_iEnforceCount[MAXPLAYERS + 1], g_iEnforceEffect[ST_MAXTYPES + 1], g_iEnforceHit[ST_MAXTYPES + 1], g_iEnforceHitMode[ST_MAXTYPES + 1], g_iEnforceMessage[ST_MAXTYPES + 1], g_iEnforceOwner[MAXPLAYERS + 1], g_iEnforceSlot[MAXPLAYERS + 1], g_iEnforceWeaponSlots[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_enforce", cmdEnforceInfo, "View information about the Enforce ability.");

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

public Action cmdEnforceInfo(int client, int args)
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
		case false: vEnforceMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vEnforceMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iEnforceMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Enforce Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iEnforceMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iEnforceAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iEnforceCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "EnforceDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flEnforceDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vEnforceMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "EnforceMenu", param1);
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
	menu.AddItem(ST_MENU_ENFORCE, ST_MENU_ENFORCE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_ENFORCE, false))
	{
		vEnforceMenu(client, 0);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!ST_IsCorePluginEnabled())
	{
		return Plugin_Continue;
	}

	if (bIsSurvivor(client) && g_bEnforce[client])
	{
		weapon = GetPlayerWeaponSlot(client, g_iEnforceSlot[client]);
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((g_iEnforceHitMode[ST_GetTankType(attacker)] == 0 || g_iEnforceHitMode[ST_GetTankType(attacker)] == 1) && ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vEnforceHit(victim, attacker, g_flEnforceChance[ST_GetTankType(attacker)], g_iEnforceHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if ((g_iEnforceHitMode[ST_GetTankType(victim)] == 0 || g_iEnforceHitMode[ST_GetTankType(victim)] == 2) && ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vEnforceHit(attacker, victim, g_flEnforceChance[ST_GetTankType(victim)], g_iEnforceHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
			}
		}
	}
}

public void ST_OnConfigsLoad()
{
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_iEnforceAbility[iIndex] = 0;
		g_iEnforceEffect[iIndex] = 0;
		g_iEnforceMessage[iIndex] = 0;
		g_flEnforceChance[iIndex] = 33.3;
		g_flEnforceDuration[iIndex] = 5.0;
		g_iEnforceHit[iIndex] = 0;
		g_iEnforceHitMode[iIndex] = 0;
		g_flEnforceRange[iIndex] = 150.0;
		g_flEnforceRangeChance[iIndex] = 15.0;
		g_iEnforceWeaponSlots[iIndex] = 0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	g_iHumanAbility[type] = iGetValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iEnforceAbility[type] = iGetValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iEnforceAbility[type], value, 0, 0, 1);
	g_iEnforceEffect[type] = iGetValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iEnforceEffect[type], value, 0, 0, 7);
	g_iEnforceMessage[type] = iGetValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iEnforceMessage[type], value, 0, 0, 3);
	g_flEnforceChance[type] = flGetValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceChance", "Enforce Chance", "Enforce_Chance", "chance", main, g_flEnforceChance[type], value, 33.3, 0.0, 100.0);
	g_flEnforceDuration[type] = flGetValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceDuration", "Enforce Duration", "Enforce_Duration", "duration", main, g_flEnforceDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iEnforceHit[type] = iGetValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceHit", "Enforce Hit", "Enforce_Hit", "hit", main, g_iEnforceHit[type], value, 0, 0, 1);
	g_iEnforceHitMode[type] = iGetValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceHitMode", "Enforce Hit Mode", "Enforce_Hit_Mode", "hitmode", main, g_iEnforceHitMode[type], value, 0, 0, 2);
	g_flEnforceRange[type] = flGetValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceRange", "Enforce Range", "Enforce_Range", "range", main, g_flEnforceRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flEnforceRangeChance[type] = flGetValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceRangeChance", "Enforce Range Chance", "Enforce_Range_Chance", "rangechance", main, g_flEnforceRangeChance[type], value, 15.0, 0.0, 100.0);
	g_iEnforceWeaponSlots[type] = iGetValue(subsection, "enforceability", "enforce ability", "enforce_ability", "enforce", key, "EnforceWeaponSlots", "Enforce Weapon Slots", "Enforce_Weapon_Slots", "slots", main, g_iEnforceWeaponSlots[type], value, 0, 0, 31);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveEnforce(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iEnforceAbility[ST_GetTankType(tank)] == 1)
	{
		vEnforceAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iEnforceAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bEnforce2[tank] && !g_bEnforce3[tank])
				{
					vEnforceAbility(tank);
				}
				else if (g_bEnforce2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "EnforceHuman3");
				}
				else if (g_bEnforce3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "EnforceHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveEnforce(tank);
}

static void vEnforceAbility(int tank)
{
	if (g_iEnforceCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bEnforce4[tank] = false;
		g_bEnforce5[tank] = false;

		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_flEnforceRange[ST_GetTankType(tank)])
				{
					vEnforceHit(iSurvivor, tank, g_flEnforceRangeChance[ST_GetTankType(tank)], g_iEnforceAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "EnforceHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "EnforceAmmo");
	}
}

static void vEnforceHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iEnforceCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bEnforce[survivor])
			{
				g_bEnforce[survivor] = true;
				g_iEnforceOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bEnforce2[tank])
				{
					g_bEnforce2[tank] = true;
					g_iEnforceCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "EnforceHuman", g_iEnforceCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				int iSlotCount, iSlots[6];
				for (int iBit = 0; iBit < 5; iBit++)
				{
					int iFlag = (1 << iBit);
					if (!(g_iEnforceWeaponSlots[ST_GetTankType(tank)] & iFlag))
					{
						continue;
					}

					iSlots[iSlotCount] = iFlag;
					iSlotCount++;
				}

				char sSlotNumber[32];
				switch (iSlots[GetRandomInt(0, iSlotCount - 1)])
				{
					case 1:
					{
						sSlotNumber = "1st";
						g_iEnforceSlot[survivor] = 0;
					}
					case 2:
					{
						sSlotNumber = "2nd";
						g_iEnforceSlot[survivor] = 1;
					}
					case 4:
					{
						sSlotNumber = "3rd";
						g_iEnforceSlot[survivor] = 2;
					}
					case 8:
					{
						sSlotNumber = "4th";
						g_iEnforceSlot[survivor] = 3;
					}
					case 16:
					{
						sSlotNumber = "5th";
						g_iEnforceSlot[survivor] = 4;
					}
					default:
					{
						switch (GetRandomInt(1, 5))
						{
							case 1:
							{
								sSlotNumber = "1st";
								g_iEnforceSlot[survivor] = 0;
							}
							case 2:
							{
								sSlotNumber = "2nd";
								g_iEnforceSlot[survivor] = 1;
							}
							case 3:
							{
								sSlotNumber = "3rd";
								g_iEnforceSlot[survivor] = 2;
							}
							case 4:
							{
								sSlotNumber = "4th";
								g_iEnforceSlot[survivor] = 3;
							}
							case 5:
							{
								sSlotNumber = "5th";
								g_iEnforceSlot[survivor] = 4;
							}
						}
					}
				}

				DataPack dpStopEnforce;
				CreateDataTimer(g_flEnforceDuration[ST_GetTankType(tank)], tTimerStopEnforce, dpStopEnforce, TIMER_FLAG_NO_MAPCHANGE);
				dpStopEnforce.WriteCell(GetClientUserId(survivor));
				dpStopEnforce.WriteCell(GetClientUserId(tank));
				dpStopEnforce.WriteCell(messages);

				vEffect(survivor, tank, g_iEnforceEffect[ST_GetTankType(tank)], flags);

				if (g_iEnforceMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Enforce", sTankName, survivor, sSlotNumber);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bEnforce2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bEnforce4[tank])
				{
					g_bEnforce4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "EnforceHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bEnforce5[tank])
		{
			g_bEnforce5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "EnforceAmmo");
		}
	}
}

static void vRemoveEnforce(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && g_bEnforce[iSurvivor] && g_iEnforceOwner[iSurvivor] == tank)
		{
			g_bEnforce[iSurvivor] = false;
			g_iEnforceOwner[iSurvivor] = 0;
			g_iEnforceSlot[iSurvivor] = INVALID_ENT_REFERENCE;
		}
	}

	vReset2(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vReset2(iPlayer);

			g_iEnforceOwner[iPlayer] = 0;
			g_iEnforceSlot[iPlayer] = INVALID_ENT_REFERENCE;
		}
	}
}

static void vReset2(int tank)
{
	g_bEnforce[tank] = false;
	g_bEnforce2[tank] = false;
	g_bEnforce3[tank] = false;
	g_bEnforce4[tank] = false;
	g_bEnforce5[tank] = false;
	g_iEnforceCount[tank] = 0;
}

static void vReset3(int survivor)
{
	g_bEnforce[survivor] = false;
	g_iEnforceOwner[survivor] = 0;
	g_iEnforceSlot[survivor] = INVALID_ENT_REFERENCE;
}

public Action tTimerStopEnforce(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bEnforce[iSurvivor])
	{
		vReset3(iSurvivor);

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset3(iSurvivor);

		return Plugin_Stop;
	}

	g_bEnforce2[iTank] = false;

	vReset3(iSurvivor);

	int iMessage = pack.ReadCell();

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bEnforce3[iTank])
	{
		g_bEnforce3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "EnforceHuman6");

		if (g_iEnforceCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
		{
			CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bEnforce3[iTank] = false;
		}
	}

	if (g_iEnforceMessage[ST_GetTankType(iTank)] & iMessage)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Enforce2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bEnforce3[iTank])
	{
		g_bEnforce3[iTank] = false;

		return Plugin_Stop;
	}

	g_bEnforce3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "EnforceHuman7");

	return Plugin_Continue;
}