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
	name = "[ST++] Leech Ability",
	author = ST_AUTHOR,
	description = "The Super Tank leeches health off of survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_LEECH "Leech Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bLeech[MAXPLAYERS + 1], g_bLeech2[MAXPLAYERS + 1], g_bLeech3[MAXPLAYERS + 1], g_bLeech4[MAXPLAYERS + 1], g_bLeech5[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sLeechEffect[ST_MAXTYPES + 1][4], g_sLeechEffect2[ST_MAXTYPES + 1][4], g_sLeechMessage[ST_MAXTYPES + 1][3], g_sLeechMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flLeechChance[ST_MAXTYPES + 1], g_flLeechChance2[ST_MAXTYPES + 1], g_flLeechDuration[ST_MAXTYPES + 1], g_flLeechDuration2[ST_MAXTYPES + 1], g_flLeechInterval[ST_MAXTYPES + 1], g_flLeechInterval2[ST_MAXTYPES + 1], g_flLeechRange[ST_MAXTYPES + 1], g_flLeechRange2[ST_MAXTYPES + 1], g_flLeechRangeChance[ST_MAXTYPES + 1], g_flLeechRangeChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iLeechAbility[ST_MAXTYPES + 1], g_iLeechAbility2[ST_MAXTYPES + 1], g_iLeechCount[MAXPLAYERS + 1], g_iLeechHit[ST_MAXTYPES + 1], g_iLeechHit2[ST_MAXTYPES + 1], g_iLeechHitMode[ST_MAXTYPES + 1], g_iLeechHitMode2[ST_MAXTYPES + 1], g_iLeechOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Leech Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_leech", cmdLeechInfo, "View information about the Leech ability.");

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

	vReset3(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdLeechInfo(int client, int args)
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
		case false: vLeechMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vLeechMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iLeechMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Leech Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iLeechMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iLeechAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iLeechCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "LeechDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flLeechDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vLeechMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "LeechMenu", param1);
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
	menu.AddItem(ST_MENU_LEECH, ST_MENU_LEECH);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_LEECH, false))
	{
		vLeechMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iLeechHitMode(attacker) == 0 || iLeechHitMode(attacker) == 1) && ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vLeechHit(victim, attacker, flLeechChance(attacker), iLeechHit(attacker), "1", "1");
			}
		}
		else if ((iLeechHitMode(victim) == 0 || iLeechHitMode(victim) == 2) && ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vLeechHit(attacker, victim, flLeechChance(victim), iLeechHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Leech Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Leech Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iLeechAbility[iIndex] = kvSuperTanks.GetNum("Leech Ability/Ability Enabled", 0);
					g_iLeechAbility[iIndex] = iClamp(g_iLeechAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Leech Ability/Ability Effect", g_sLeechEffect[iIndex], sizeof(g_sLeechEffect[]), "0");
					kvSuperTanks.GetString("Leech Ability/Ability Message", g_sLeechMessage[iIndex], sizeof(g_sLeechMessage[]), "0");
					g_flLeechChance[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Chance", 33.3);
					g_flLeechChance[iIndex] = flClamp(g_flLeechChance[iIndex], 0.0, 100.0);
					g_flLeechDuration[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Duration", 5.0);
					g_flLeechDuration[iIndex] = flClamp(g_flLeechDuration[iIndex], 0.1, 9999999999.0);
					g_iLeechHit[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Hit", 0);
					g_iLeechHit[iIndex] = iClamp(g_iLeechHit[iIndex], 0, 1);
					g_iLeechHitMode[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Hit Mode", 0);
					g_iLeechHitMode[iIndex] = iClamp(g_iLeechHitMode[iIndex], 0, 2);
					g_flLeechInterval[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Interval", 1.0);
					g_flLeechInterval[iIndex] = flClamp(g_flLeechInterval[iIndex], 0.1, 9999999999.0);
					g_flLeechRange[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Range", 150.0);
					g_flLeechRange[iIndex] = flClamp(g_flLeechRange[iIndex], 1.0, 9999999999.0);
					g_flLeechRangeChance[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Range Chance", 15.0);
					g_flLeechRangeChance[iIndex] = flClamp(g_flLeechRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Leech Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Leech Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iLeechAbility2[iIndex] = kvSuperTanks.GetNum("Leech Ability/Ability Enabled", g_iLeechAbility[iIndex]);
					g_iLeechAbility2[iIndex] = iClamp(g_iLeechAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Leech Ability/Ability Effect", g_sLeechEffect2[iIndex], sizeof(g_sLeechEffect2[]), g_sLeechEffect[iIndex]);
					kvSuperTanks.GetString("Leech Ability/Ability Message", g_sLeechMessage2[iIndex], sizeof(g_sLeechMessage2[]), g_sLeechMessage[iIndex]);
					g_flLeechChance2[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Chance", g_flLeechChance[iIndex]);
					g_flLeechChance2[iIndex] = flClamp(g_flLeechChance2[iIndex], 0.0, 100.0);
					g_flLeechDuration2[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Duration", g_flLeechDuration[iIndex]);
					g_flLeechDuration2[iIndex] = flClamp(g_flLeechDuration2[iIndex], 0.1, 9999999999.0);
					g_iLeechHit2[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Hit", g_iLeechHit[iIndex]);
					g_iLeechHit2[iIndex] = iClamp(g_iLeechHit2[iIndex], 0, 1);
					g_iLeechHitMode2[iIndex] = kvSuperTanks.GetNum("Leech Ability/Leech Hit Mode", g_iLeechHitMode[iIndex]);
					g_iLeechHitMode2[iIndex] = iClamp(g_iLeechHitMode2[iIndex], 0, 2);
					g_flLeechInterval2[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Interval", g_flLeechInterval[iIndex]);
					g_flLeechInterval2[iIndex] = flClamp(g_flLeechInterval2[iIndex], 0.1, 9999999999.0);
					g_flLeechRange2[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Range", g_flLeechRange[iIndex]);
					g_flLeechRange2[iIndex] = flClamp(g_flLeechRange2[iIndex], 1.0, 9999999999.0);
					g_flLeechRangeChance2[iIndex] = kvSuperTanks.GetFloat("Leech Ability/Leech Range Chance", g_flLeechRangeChance[iIndex]);
					g_flLeechRangeChance2[iIndex] = flClamp(g_flLeechRangeChance2[iIndex], 0.0, 100.0);
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
			vRemoveLeech(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, "5") || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iLeechAbility(tank) == 1)
	{
		vLeechAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iLeechAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bLeech2[tank] && !g_bLeech3[tank])
				{
					vLeechAbility(tank);
				}
				else if (g_bLeech2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "LeechHuman3");
				}
				else if (g_bLeech3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "LeechHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveLeech(tank);
}

static void vLeechAbility(int tank)
{
	if (g_iLeechCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bLeech4[tank] = false;
		g_bLeech5[tank] = false;

		float flLeechRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flLeechRange[ST_GetTankType(tank)] : g_flLeechRange2[ST_GetTankType(tank)],
			flLeechRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flLeechRangeChance[ST_GetTankType(tank)] : g_flLeechRangeChance2[ST_GetTankType(tank)],
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
				if (flDistance <= flLeechRange)
				{
					vLeechHit(iSurvivor, tank, flLeechRangeChance, iLeechAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "LeechHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "LeechAmmo");
	}
}

static void vLeechHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iLeechCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bLeech[survivor])
			{
				g_bLeech[survivor] = true;
				g_iLeechOwner[survivor] = tank;

				float flLeechInterval = !g_bTankConfig[ST_GetTankType(tank)] ? g_flLeechInterval[ST_GetTankType(tank)] : g_flLeechInterval2[ST_GetTankType(tank)];
				DataPack dpLeech;
				CreateDataTimer(flLeechInterval, tTimerLeech, dpLeech, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpLeech.WriteCell(GetClientUserId(survivor));
				dpLeech.WriteCell(GetClientUserId(tank));
				dpLeech.WriteCell(ST_GetTankType(tank));
				dpLeech.WriteString(message);
				dpLeech.WriteCell(enabled);
				dpLeech.WriteFloat(GetEngineTime());

				char sLeechEffect[4];
				sLeechEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_sLeechEffect[ST_GetTankType(tank)] : g_sLeechEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, sLeechEffect, mode);

				char sLeechMessage[3];
				sLeechMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sLeechMessage[ST_GetTankType(tank)] : g_sLeechMessage2[ST_GetTankType(tank)];
				if (StrContains(sLeechMessage, message) != -1)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Leech", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bLeech2[tank])
			{
				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bLeech4[tank])
				{
					g_bLeech4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "LeechHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bLeech5[tank])
		{
			g_bLeech5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "LeechAmmo");
		}
	}
}

static void vRemoveLeech(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, "234") && g_bLeech[iSurvivor] && g_iLeechOwner[iSurvivor] == tank)
		{
			g_bLeech[iSurvivor] = false;
			g_iLeechOwner[iSurvivor] = 0;
		}
	}

	vReset3(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vReset3(iPlayer);

			g_iLeechOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bLeech[survivor] = false;
	g_iLeechOwner[survivor] = 0;

	char sLeechMessage[3];
	sLeechMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sLeechMessage[ST_GetTankType(tank)] : g_sLeechMessage2[ST_GetTankType(tank)];
	if (StrContains(sLeechMessage, message) != -1)
	{
		char sTankName[33];
		ST_GetTankName(tank, sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Leech2", sTankName, survivor);
	}
}

static void vReset3(int tank)
{
	g_bLeech[tank] = false;
	g_bLeech2[tank] = false;
	g_bLeech3[tank] = false;
	g_bLeech4[tank] = false;
	g_bLeech5[tank] = false;
	g_iLeechCount[tank] = 0;
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flLeechChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flLeechChance[ST_GetTankType(tank)] : g_flLeechChance2[ST_GetTankType(tank)];
}

static float flLeechDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flLeechDuration[ST_GetTankType(tank)] : g_flLeechDuration2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iLeechAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iLeechAbility[ST_GetTankType(tank)] : g_iLeechAbility2[ST_GetTankType(tank)];
}

static int iLeechHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iLeechHit[ST_GetTankType(tank)] : g_iLeechHit2[ST_GetTankType(tank)];
}

static int iLeechHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iLeechHitMode[ST_GetTankType(tank)] : g_iLeechHitMode2[ST_GetTankType(tank)];
}

public Action tTimerLeech(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bLeech[iSurvivor] = false;
		g_iLeechOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bLeech[iSurvivor])
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iLeechEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iLeechEnabled == 0 || (flTime + flLeechDuration(iTank)) < GetEngineTime())
	{
		g_bLeech2[iTank] = false;

		vReset2(iSurvivor, iTank, sMessage);

		if (ST_IsTankSupported(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bLeech3[iTank])
		{
			g_bLeech3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "LeechHuman6");

			if (g_iLeechCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
			{
				CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bLeech3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	int iSurvivorHealth = GetClientHealth(iSurvivor), iTankHealth = GetClientHealth(iTank), iNewHealth = iSurvivorHealth - 1, iNewHealth2 = iTankHealth + 1,
		iFinalHealth = (iNewHealth < 1) ? 1 : iNewHealth, iFinalHealth2 = (iNewHealth2 > ST_MAXHEALTH) ? ST_MAXHEALTH : iNewHealth2;
	SetEntityHealth(iSurvivor, iFinalHealth);
	SetEntityHealth(iTank, iFinalHealth2);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bLeech3[iTank])
	{
		g_bLeech3[iTank] = false;

		return Plugin_Stop;
	}

	g_bLeech3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "LeechHuman7");

	return Plugin_Continue;
}