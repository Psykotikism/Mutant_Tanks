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
	name = "[ST++] Enforce Ability",
	author = ST_AUTHOR,
	description = "The Super Tank forces survivors to only use a certain weapon slot.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_ENFORCE "Enforce Ability"

bool g_bCloneInstalled, g_bEnforce[MAXPLAYERS + 1], g_bEnforce2[MAXPLAYERS + 1], g_bEnforce3[MAXPLAYERS + 1], g_bEnforce4[MAXPLAYERS + 1], g_bEnforce5[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sEnforceEffect[ST_MAXTYPES + 1][4], g_sEnforceEffect2[ST_MAXTYPES + 1][4], g_sEnforceMessage[ST_MAXTYPES + 1][3], g_sEnforceMessage2[ST_MAXTYPES + 1][3], g_sEnforceSlot[ST_MAXTYPES + 1][6], g_sEnforceSlot2[ST_MAXTYPES + 1][6];

float g_flEnforceChance[ST_MAXTYPES + 1], g_flEnforceChance2[ST_MAXTYPES + 1], g_flEnforceDuration[ST_MAXTYPES + 1], g_flEnforceDuration2[ST_MAXTYPES + 1], g_flEnforceRange[ST_MAXTYPES + 1], g_flEnforceRange2[ST_MAXTYPES + 1], g_flEnforceRangeChance[ST_MAXTYPES + 1], g_flEnforceRangeChance2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

int g_iEnforceAbility[ST_MAXTYPES + 1], g_iEnforceAbility2[ST_MAXTYPES + 1], g_iEnforceCount[MAXPLAYERS + 1], g_iEnforceHit[ST_MAXTYPES + 1], g_iEnforceHit2[ST_MAXTYPES + 1], g_iEnforceHitMode[ST_MAXTYPES + 1], g_iEnforceHitMode2[ST_MAXTYPES + 1], g_iEnforceOwner[MAXPLAYERS + 1], g_iEnforceSlot[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1];

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
			if (bIsValidClient(iPlayer, "24"))
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

	if (!bIsValidClient(client, "0245"))
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iEnforceAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iEnforceCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "EnforceDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flEnforceDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
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
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iEnforceHitMode(attacker) == 0 || iEnforceHitMode(attacker) == 1) && ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vEnforceHit(victim, attacker, flEnforceChance(attacker), iEnforceHit(attacker), "1", "1");
			}
		}
		else if ((iEnforceHitMode(victim) == 0 || iEnforceHitMode(victim) == 2) && ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vEnforceHit(attacker, victim, flEnforceChance(victim), iEnforceHit(victim), "1", "2");
			}
		}
	}
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iEnforceAbility[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Ability Enabled", 0);
					g_iEnforceAbility[iIndex] = iClamp(g_iEnforceAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Enforce Ability/Ability Effect", g_sEnforceEffect[iIndex], sizeof(g_sEnforceEffect[]), "0");
					kvSuperTanks.GetString("Enforce Ability/Ability Message", g_sEnforceMessage[iIndex], sizeof(g_sEnforceMessage[]), "0");
					g_flEnforceChance[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Chance", 33.3);
					g_flEnforceChance[iIndex] = flClamp(g_flEnforceChance[iIndex], 0.0, 100.0);
					g_flEnforceDuration[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Duration", 5.0);
					g_flEnforceDuration[iIndex] = flClamp(g_flEnforceDuration[iIndex], 0.1, 9999999999.0);
					g_iEnforceHit[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Hit", 0);
					g_iEnforceHit[iIndex] = iClamp(g_iEnforceHit[iIndex], 0, 1);
					g_iEnforceHitMode[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Hit Mode", 0);
					g_iEnforceHitMode[iIndex] = iClamp(g_iEnforceHitMode[iIndex], 0, 2);
					g_flEnforceRange[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Range", 150.0);
					g_flEnforceRange[iIndex] = flClamp(g_flEnforceRange[iIndex], 1.0, 9999999999.0);
					g_flEnforceRangeChance[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Range Chance", 15.0);
					g_flEnforceRangeChance[iIndex] = flClamp(g_flEnforceRangeChance[iIndex], 0.0, 100.0);
					kvSuperTanks.GetString("Enforce Ability/Enforce Weapon Slots", g_sEnforceSlot[iIndex], sizeof(g_sEnforceSlot[]), "12345");
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iEnforceAbility2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Ability Enabled", g_iEnforceAbility[iIndex]);
					g_iEnforceAbility2[iIndex] = iClamp(g_iEnforceAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Enforce Ability/Ability Effect", g_sEnforceEffect2[iIndex], sizeof(g_sEnforceEffect2[]), g_sEnforceEffect[iIndex]);
					kvSuperTanks.GetString("Enforce Ability/Ability Message", g_sEnforceMessage2[iIndex], sizeof(g_sEnforceMessage2[]), g_sEnforceMessage[iIndex]);
					g_flEnforceChance2[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Chance", g_flEnforceChance[iIndex]);
					g_flEnforceChance2[iIndex] = flClamp(g_flEnforceChance2[iIndex], 0.0, 100.0);
					g_flEnforceDuration2[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Duration", g_flEnforceDuration[iIndex]);
					g_flEnforceDuration2[iIndex] = flClamp(g_flEnforceDuration2[iIndex], 0.1, 9999999999.0);
					g_iEnforceHit2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Hit", g_iEnforceHit[iIndex]);
					g_iEnforceHit2[iIndex] = iClamp(g_iEnforceHit2[iIndex], 0, 1);
					g_iEnforceHitMode2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Hit Mode", g_iEnforceHitMode[iIndex]);
					g_iEnforceHitMode2[iIndex] = iClamp(g_iEnforceHitMode2[iIndex], 0, 2);
					g_flEnforceRange2[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Range", g_flEnforceRange[iIndex]);
					g_flEnforceRange2[iIndex] = flClamp(g_flEnforceRange2[iIndex], 1.0, 9999999999.0);
					g_flEnforceRangeChance2[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Range Chance", g_flEnforceRangeChance[iIndex]);
					g_flEnforceRangeChance2[iIndex] = flClamp(g_flEnforceRangeChance2[iIndex], 0.0, 100.0);
					kvSuperTanks.GetString("Enforce Ability/Enforce Weapon Slots", g_sEnforceSlot2[iIndex], sizeof(g_sEnforceSlot2[]), g_sEnforceSlot[iIndex]);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, "024"))
		{
			vRemoveEnforce(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, "5") || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iEnforceAbility(tank) == 1)
	{
		vEnforceAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iEnforceAbility(tank) == 1 && iHumanAbility(tank) == 1)
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

public void ST_OnChangeType(int tank)
{
	vRemoveEnforce(tank);
}

static void vEnforceAbility(int tank)
{
	if (g_iEnforceCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bEnforce4[tank] = false;
		g_bEnforce5[tank] = false;

		float flEnforceRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flEnforceRange[ST_GetTankType(tank)] : g_flEnforceRange2[ST_GetTankType(tank)],
			flEnforceRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flEnforceRangeChance[ST_GetTankType(tank)] : g_flEnforceRangeChance2[ST_GetTankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, "234"))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flEnforceRange)
				{
					vEnforceHit(iSurvivor, tank, flEnforceRangeChance, iEnforceAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "EnforceHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "EnforceAmmo");
	}
}

static void vEnforceHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iEnforceCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bEnforce[survivor])
			{
				g_bEnforce[survivor] = true;
				g_iEnforceOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bEnforce2[tank])
				{
					g_bEnforce2[tank] = true;
					g_iEnforceCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "EnforceHuman", g_iEnforceCount[tank], iHumanAmmo(tank));
				}

				char sNumbers = !g_bTankConfig[ST_GetTankType(tank)] ? g_sEnforceSlot[ST_GetTankType(tank)][GetRandomInt(0, strlen(g_sEnforceSlot[ST_GetTankType(tank)]) - 1)] : g_sEnforceSlot2[ST_GetTankType(tank)][GetRandomInt(0, strlen(g_sEnforceSlot2[ST_GetTankType(tank)]) - 1)],
					sSlotNumber[32];
				switch (sNumbers)
				{
					case '1': sSlotNumber = "1st", g_iEnforceSlot[survivor] = 0;
					case '2': sSlotNumber = "2nd", g_iEnforceSlot[survivor] = 1;
					case '3': sSlotNumber = "3rd", g_iEnforceSlot[survivor] = 2;
					case '4': sSlotNumber = "4th", g_iEnforceSlot[survivor] = 3;
					case '5': sSlotNumber = "5th", g_iEnforceSlot[survivor] = 4;
				}

				DataPack dpStopEnforce;
				CreateDataTimer(flEnforceDuration(tank), tTimerStopEnforce, dpStopEnforce, TIMER_FLAG_NO_MAPCHANGE);
				dpStopEnforce.WriteCell(GetClientUserId(survivor));
				dpStopEnforce.WriteCell(GetClientUserId(tank));
				dpStopEnforce.WriteString(message);

				char sEnforceEffect[4];
				sEnforceEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_sEnforceEffect[ST_GetTankType(tank)] : g_sEnforceEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, sEnforceEffect, mode);

				char sEnforceMessage[3];
				sEnforceMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sEnforceMessage[ST_GetTankType(tank)] : g_sEnforceMessage2[ST_GetTankType(tank)];
				if (StrContains(sEnforceMessage, message) != -1)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Enforce", sTankName, survivor, sSlotNumber);
				}
			}
			else if (StrEqual(mode, "3") && !g_bEnforce2[tank])
			{
				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bEnforce4[tank])
				{
					g_bEnforce4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "EnforceHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bEnforce5[tank])
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
		if (bIsSurvivor(iSurvivor, "24") && g_bEnforce[iSurvivor] && g_iEnforceOwner[iSurvivor] == tank)
		{
			g_bEnforce[iSurvivor] = false;
			g_iEnforceOwner[iSurvivor] = 0;
			g_iEnforceSlot[iSurvivor] = -1;
		}
	}

	vReset2(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vReset2(iPlayer);

			g_iEnforceOwner[iPlayer] = 0;
			g_iEnforceSlot[iPlayer] = -1;
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

static float flEnforceChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flEnforceChance[ST_GetTankType(tank)] : g_flEnforceChance2[ST_GetTankType(tank)];
}

static float flEnforceDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flEnforceDuration[ST_GetTankType(tank)] : g_flEnforceDuration2[ST_GetTankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static int iEnforceAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iEnforceAbility[ST_GetTankType(tank)] : g_iEnforceAbility2[ST_GetTankType(tank)];
}

static int iEnforceHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iEnforceHit[ST_GetTankType(tank)] : g_iEnforceHit2[ST_GetTankType(tank)];
}

static int iEnforceHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iEnforceHitMode[ST_GetTankType(tank)] : g_iEnforceHitMode2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

public Action tTimerStopEnforce(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bEnforce[iSurvivor])
	{
		g_bEnforce[iSurvivor] = false;
		g_iEnforceOwner[iSurvivor] = 0;
		g_iEnforceSlot[iSurvivor] = -1;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsTankSupported(iTank) || !ST_IsCloneSupported(iTank, g_bCloneInstalled))
	{
		g_bEnforce[iSurvivor] = false;
		g_iEnforceOwner[iSurvivor] = 0;
		g_iEnforceSlot[iSurvivor] = -1;

		return Plugin_Stop;
	}

	g_bEnforce[iSurvivor] = false;
	g_bEnforce2[iTank] = false;
	g_iEnforceOwner[iSurvivor] = 0;
	g_iEnforceSlot[iSurvivor] = -1;

	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));

	if (ST_IsTankSupported(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bEnforce3[iTank])
	{
		g_bEnforce3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "EnforceHuman6");

		if (g_iEnforceCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
		{
			CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bEnforce3[iTank] = false;
		}
	}

	char sEnforceMessage[3];
	sEnforceMessage = !g_bTankConfig[ST_GetTankType(iTank)] ? g_sEnforceMessage[ST_GetTankType(iTank)] : g_sEnforceMessage2[ST_GetTankType(iTank)];
	if (StrContains(sEnforceMessage, sMessage) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Enforce2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bEnforce3[iTank])
	{
		g_bEnforce3[iTank] = false;

		return Plugin_Stop;
	}

	g_bEnforce3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "EnforceHuman7");

	return Plugin_Continue;
}