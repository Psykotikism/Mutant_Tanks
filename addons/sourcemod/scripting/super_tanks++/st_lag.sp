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
	name = "[ST++] Lag Ability",
	author = ST_AUTHOR,
	description = "The Super Tank makes survivors lag.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_LAG "Lag Ability"

bool g_bCloneInstalled, g_bLag[MAXPLAYERS + 1], g_bLag2[MAXPLAYERS + 1], g_bLag3[MAXPLAYERS + 1], g_bLag4[MAXPLAYERS + 1], g_bLag5[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sLagEffect[ST_MAXTYPES + 1][4], g_sLagEffect2[ST_MAXTYPES + 1][4], g_sLagMessage[ST_MAXTYPES + 1][3], g_sLagMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flLagChance[ST_MAXTYPES + 1], g_flLagChance2[ST_MAXTYPES + 1], g_flLagDuration[ST_MAXTYPES + 1], g_flLagDuration2[ST_MAXTYPES + 1], g_flLagPosition[MAXPLAYERS + 1][4], g_flLagRange[ST_MAXTYPES + 1], g_flLagRange2[ST_MAXTYPES + 1], g_flLagRangeChance[ST_MAXTYPES + 1], g_flLagRangeChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iLagAbility[ST_MAXTYPES + 1], g_iLagAbility2[ST_MAXTYPES + 1], g_iLagCount[MAXPLAYERS + 1], g_iLagHit[ST_MAXTYPES + 1], g_iLagHit2[ST_MAXTYPES + 1], g_iLagHitMode[ST_MAXTYPES + 1], g_iLagHitMode2[ST_MAXTYPES + 1], g_iLagOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Lag Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_lag", cmdLagInfo, "View information about the Lag ability.");

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

public Action cmdLagInfo(int client, int args)
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
		case false: vLagMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vLagMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iLagMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Lag Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iLagMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iLagAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iLagCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "LagDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flLagDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vLagMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "LagMenu", param1);
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
	menu.AddItem(ST_MENU_LAG, ST_MENU_LAG);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_LAG, false))
	{
		vLagMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iLagHitMode(attacker) == 0 || iLagHitMode(attacker) == 1) && ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vLagHit(victim, attacker, flLagChance(attacker), iLagHit(attacker), "1", "1");
			}
		}
		else if ((iLagHitMode(victim) == 0 || iLagHitMode(victim) == 2) && ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vLagHit(attacker, victim, flLagChance(victim), iLagHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Lag Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Lag Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iLagAbility[iIndex] = kvSuperTanks.GetNum("Lag Ability/Ability Enabled", 0);
					g_iLagAbility[iIndex] = iClamp(g_iLagAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Lag Ability/Ability Effect", g_sLagEffect[iIndex], sizeof(g_sLagEffect[]), "0");
					kvSuperTanks.GetString("Lag Ability/Ability Message", g_sLagMessage[iIndex], sizeof(g_sLagMessage[]), "0");
					g_flLagChance[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Chance", 33.3);
					g_flLagChance[iIndex] = flClamp(g_flLagChance[iIndex], 0.0, 100.0);
					g_flLagDuration[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Duration", 5.0);
					g_flLagDuration[iIndex] = flClamp(g_flLagDuration[iIndex], 0.1, 9999999999.0);
					g_iLagHit[iIndex] = kvSuperTanks.GetNum("Lag Ability/Lag Hit", 0);
					g_iLagHit[iIndex] = iClamp(g_iLagHit[iIndex], 0, 1);
					g_iLagHitMode[iIndex] = kvSuperTanks.GetNum("Lag Ability/Lag Hit Mode", 0);
					g_iLagHitMode[iIndex] = iClamp(g_iLagHitMode[iIndex], 0, 2);
					g_flLagRange[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Range", 150.0);
					g_flLagRange[iIndex] = flClamp(g_flLagRange[iIndex], 1.0, 9999999999.0);
					g_flLagRangeChance[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Range Chance", 15.0);
					g_flLagRangeChance[iIndex] = flClamp(g_flLagRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Lag Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Lag Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iLagAbility2[iIndex] = kvSuperTanks.GetNum("Lag Ability/Ability Enabled", g_iLagAbility[iIndex]);
					g_iLagAbility2[iIndex] = iClamp(g_iLagAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Lag Ability/Ability Effect", g_sLagEffect2[iIndex], sizeof(g_sLagEffect2[]), g_sLagEffect[iIndex]);
					kvSuperTanks.GetString("Lag Ability/Ability Message", g_sLagMessage2[iIndex], sizeof(g_sLagMessage2[]), g_sLagMessage[iIndex]);
					g_flLagChance2[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Chance", g_flLagChance[iIndex]);
					g_flLagChance2[iIndex] = flClamp(g_flLagChance2[iIndex], 0.0, 100.0);
					g_flLagDuration2[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Duration", g_flLagDuration[iIndex]);
					g_flLagDuration2[iIndex] = flClamp(g_flLagDuration2[iIndex], 0.1, 9999999999.0);
					g_iLagHit2[iIndex] = kvSuperTanks.GetNum("Lag Ability/Lag Hit", g_iLagHit[iIndex]);
					g_iLagHit2[iIndex] = iClamp(g_iLagHit2[iIndex], 0, 1);
					g_iLagHitMode2[iIndex] = kvSuperTanks.GetNum("Lag Ability/Lag Hit Mode", g_iLagHitMode[iIndex]);
					g_iLagHitMode2[iIndex] = iClamp(g_iLagHitMode2[iIndex], 0, 2);
					g_flLagRange2[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Range", g_flLagRange[iIndex]);
					g_flLagRange2[iIndex] = flClamp(g_flLagRange2[iIndex], 1.0, 9999999999.0);
					g_flLagRangeChance2[iIndex] = kvSuperTanks.GetFloat("Lag Ability/Lag Range Chance", g_flLagRangeChance[iIndex]);
					g_flLagRangeChance2[iIndex] = flClamp(g_flLagRangeChance2[iIndex], 0.0, 100.0);
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
			vRemoveLag(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, "5") || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iLagAbility(tank) == 1)
	{
		vLagAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iLagAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bLag2[tank] && !g_bLag3[tank])
				{
					vLagAbility(tank);
				}
				else if (g_bLag2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "LagHuman3");
				}
				else if (g_bLag3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "LagHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveLag(tank);
}

static void vLagAbility(int tank)
{
	if (g_iLagCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bLag4[tank] = false;
		g_bLag5[tank] = false;

		float flLagRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flLagRange[ST_GetTankType(tank)] : g_flLagRange2[ST_GetTankType(tank)],
			flLagRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flLagRangeChance[ST_GetTankType(tank)] : g_flLagRangeChance2[ST_GetTankType(tank)],
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
				if (flDistance <= flLagRange)
				{
					vLagHit(iSurvivor, tank, flLagRangeChance, iLagAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "LagHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "LagAmmo");
	}
}

static void vLagHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iLagCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bLag[survivor])
			{
				g_bLag[survivor] = true;
				g_iLagOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bLag2[tank])
				{
					g_bLag2[tank] = true;
					g_iLagCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "LagHuman", g_iLagCount[tank], iHumanAmmo(tank));
				}

				float flPos[3];
				GetClientAbsOrigin(survivor, flPos);
				g_flLagPosition[survivor][1] = flPos[0];
				g_flLagPosition[survivor][2] = flPos[1];
				g_flLagPosition[survivor][3] = flPos[2];

				DataPack dpLagTeleport;
				CreateDataTimer(1.0, tTimerLagTeleport, dpLagTeleport, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpLagTeleport.WriteCell(GetClientUserId(survivor));
				dpLagTeleport.WriteCell(GetClientUserId(tank));
				dpLagTeleport.WriteCell(ST_GetTankType(tank));
				dpLagTeleport.WriteString(message);
				dpLagTeleport.WriteCell(enabled);
				dpLagTeleport.WriteFloat(GetEngineTime());

				DataPack dpLagPosition;
				CreateDataTimer(0.5, tTimerLagPosition, dpLagPosition, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpLagPosition.WriteCell(GetClientUserId(survivor));
				dpLagPosition.WriteCell(GetClientUserId(tank));
				dpLagPosition.WriteCell(ST_GetTankType(tank));
				dpLagPosition.WriteCell(enabled);
				dpLagPosition.WriteFloat(GetEngineTime());

				char sLagEffect[4];
				sLagEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_sLagEffect[ST_GetTankType(tank)] : g_sLagEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, sLagEffect, mode);

				char sLagMessage[3];
				sLagMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sLagMessage[ST_GetTankType(tank)] : g_sLagMessage2[ST_GetTankType(tank)];
				if (StrContains(sLagMessage, message) != -1)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Lag", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bLag2[tank])
			{
				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bLag4[tank])
				{
					g_bLag4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "LagHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bLag5[tank])
		{
			g_bLag5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "LagAmmo");
		}
	}
}

static void vRemoveLag(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, "234") && g_bLag[iSurvivor] && g_iLagOwner[iSurvivor] == tank)
		{
			g_bLag[iSurvivor] = false;
			g_iLagOwner[iSurvivor] = 0;
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

			g_iLagOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bLag[survivor] = false;
	g_iLagOwner[survivor] = 0;

	char sLagMessage[3];
	sLagMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sLagMessage[ST_GetTankType(tank)] : g_sLagMessage2[ST_GetTankType(tank)];
	if (StrContains(sLagMessage, message) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Lag2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bLag[tank] = false;
	g_bLag2[tank] = false;
	g_bLag3[tank] = false;
	g_bLag4[tank] = false;
	g_bLag5[tank] = false;
	g_iLagCount[tank] = 0;
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flLagChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flLagChance[ST_GetTankType(tank)] : g_flLagChance2[ST_GetTankType(tank)];
}

static float flLagDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flLagDuration[ST_GetTankType(tank)] : g_flLagDuration2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iLagAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iLagAbility[ST_GetTankType(tank)] : g_iLagAbility2[ST_GetTankType(tank)];
}

static int iLagHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iLagHit[ST_GetTankType(tank)] : g_iLagHit2[ST_GetTankType(tank)];
}

static int iLagHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iLagHitMode[ST_GetTankType(tank)] : g_iLagHitMode2[ST_GetTankType(tank)];
}

public Action tTimerLagTeleport(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bLag[iSurvivor] = false;
		g_iLagOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bLag[iSurvivor])
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iLagEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iLagEnabled == 0 || (flTime + flLagDuration(iTank) < GetEngineTime()))
	{
		g_bLag2[iTank] = false;

		vReset2(iSurvivor, iTank, sMessage);

		if (ST_IsTankSupported(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bLag3[iTank])
		{
			g_bLag3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "LagHuman6");

			if (g_iLagCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
			{
				CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bLag3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	float flPos[3];
	flPos[0] = g_flLagPosition[iSurvivor][1];
	flPos[1] = g_flLagPosition[iSurvivor][2];
	flPos[2] = g_flLagPosition[iSurvivor][3];
	TeleportEntity(iSurvivor, flPos, NULL_VECTOR, NULL_VECTOR);

	return Plugin_Continue;
}

public Action tTimerLagPosition(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor) || !g_bLag[iSurvivor])
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank))
	{
		return Plugin_Stop;
	}

	int iLagEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iLagEnabled == 0 || (flTime + flLagDuration(iTank) < GetEngineTime()))
	{
		return Plugin_Stop;
	}

	float flPos[3];
	GetClientAbsOrigin(iSurvivor, flPos);
	g_flLagPosition[iSurvivor][1] = flPos[0];
	g_flLagPosition[iSurvivor][2] = flPos[1];
	g_flLagPosition[iSurvivor][3] = flPos[2];

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bLag3[iTank])
	{
		g_bLag3[iTank] = false;

		return Plugin_Stop;
	}

	g_bLag3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "LagHuman7");

	return Plugin_Continue;
}