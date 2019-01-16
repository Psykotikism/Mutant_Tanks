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
	name = "[ST++] Recoil Ability",
	author = ST_AUTHOR,
	description = "The Super Tank gives survivors strong gun recoil.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_RECOIL "Recoil Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bRecoil[MAXPLAYERS + 1], g_bRecoil2[MAXPLAYERS + 1], g_bRecoil3[MAXPLAYERS + 1], g_bRecoil4[MAXPLAYERS + 1], g_bRecoil5[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sRecoilEffect[ST_MAXTYPES + 1][4], g_sRecoilEffect2[ST_MAXTYPES + 1][4], g_sRecoilMessage[ST_MAXTYPES + 1][3], g_sRecoilMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flRecoilChance[ST_MAXTYPES + 1], g_flRecoilChance2[ST_MAXTYPES + 1], g_flRecoilDuration[ST_MAXTYPES + 1], g_flRecoilDuration2[ST_MAXTYPES + 1], g_flRecoilRange[ST_MAXTYPES + 1], g_flRecoilRange2[ST_MAXTYPES + 1], g_flRecoilRangeChance[ST_MAXTYPES + 1], g_flRecoilRangeChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iRecoilAbility[ST_MAXTYPES + 1], g_iRecoilAbility2[ST_MAXTYPES + 1], g_iRecoilCount[MAXPLAYERS + 1], g_iRecoilHit[ST_MAXTYPES + 1], g_iRecoilHit2[ST_MAXTYPES + 1], g_iRecoilHitMode[ST_MAXTYPES + 1], g_iRecoilHitMode2[ST_MAXTYPES + 1], g_iRecoilOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Recoil Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_recoil", cmdRecoilInfo, "View information about the Recoil ability.");

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

public Action cmdRecoilInfo(int client, int args)
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
		case false: vRecoilMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vRecoilMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iRecoilMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Recoil Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iRecoilMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iRecoilAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iRecoilCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "RecoilDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flRecoilDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vRecoilMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "RecoilMenu", param1);
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
	menu.AddItem(ST_MENU_RECOIL, ST_MENU_RECOIL);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_RECOIL, false))
	{
		vRecoilMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iRecoilHitMode(attacker) == 0 || iRecoilHitMode(attacker) == 1) && ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRecoilHit(victim, attacker, flRecoilChance(attacker), iRecoilHit(attacker), "1", "1");
			}
		}
		else if ((iRecoilHitMode(victim) == 0 || iRecoilHitMode(victim) == 2) && ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vRecoilHit(attacker, victim, flRecoilChance(victim), iRecoilHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iRecoilAbility[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Ability Enabled", 0);
					g_iRecoilAbility[iIndex] = iClamp(g_iRecoilAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Recoil Ability/Ability Effect", g_sRecoilEffect[iIndex], sizeof(g_sRecoilEffect[]), "0");
					kvSuperTanks.GetString("Recoil Ability/Ability Message", g_sRecoilMessage[iIndex], sizeof(g_sRecoilMessage[]), "0");
					g_flRecoilChance[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Chance", 33.3);
					g_flRecoilChance[iIndex] = flClamp(g_flRecoilChance[iIndex], 0.0, 100.0);
					g_flRecoilDuration[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Duration", 5.0);
					g_flRecoilDuration[iIndex] = flClamp(g_flRecoilDuration[iIndex], 0.1, 9999999999.0);
					g_iRecoilHit[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Hit", 0);
					g_iRecoilHit[iIndex] = iClamp(g_iRecoilHit[iIndex], 0, 1);
					g_iRecoilHitMode[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Hit Mode", 0);
					g_iRecoilHitMode[iIndex] = iClamp(g_iRecoilHitMode[iIndex], 0, 2);
					g_flRecoilRange[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Range", 150.0);
					g_flRecoilRange[iIndex] = flClamp(g_flRecoilRange[iIndex], 1.0, 9999999999.0);
					g_flRecoilRangeChance[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Range Chance", 15.0);
					g_flRecoilRangeChance[iIndex] = flClamp(g_flRecoilRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iRecoilAbility2[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Ability Enabled", g_iRecoilAbility[iIndex]);
					g_iRecoilAbility2[iIndex] = iClamp(g_iRecoilAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Recoil Ability/Ability Effect", g_sRecoilEffect2[iIndex], sizeof(g_sRecoilEffect2[]), g_sRecoilEffect[iIndex]);
					kvSuperTanks.GetString("Recoil Ability/Ability Message", g_sRecoilMessage2[iIndex], sizeof(g_sRecoilMessage2[]), g_sRecoilMessage[iIndex]);
					g_flRecoilChance2[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Chance", g_flRecoilChance[iIndex]);
					g_flRecoilChance2[iIndex] = flClamp(g_flRecoilChance2[iIndex], 0.0, 100.0);
					g_flRecoilDuration2[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Duration", g_flRecoilDuration[iIndex]);
					g_flRecoilDuration2[iIndex] = flClamp(g_flRecoilDuration2[iIndex], 0.1, 9999999999.0);
					g_iRecoilHit2[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Hit", g_iRecoilHit[iIndex]);
					g_iRecoilHit2[iIndex] = iClamp(g_iRecoilHit2[iIndex], 0, 1);
					g_iRecoilHitMode2[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Hit Mode", g_iRecoilHitMode[iIndex]);
					g_iRecoilHitMode2[iIndex] = iClamp(g_iRecoilHitMode2[iIndex], 0, 2);
					g_flRecoilRange2[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Range", g_flRecoilRange[iIndex]);
					g_flRecoilRange2[iIndex] = flClamp(g_flRecoilRange2[iIndex], 1.0, 9999999999.0);
					g_flRecoilRangeChance2[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Range Chance", g_flRecoilRangeChance[iIndex]);
					g_flRecoilRangeChance2[iIndex] = flClamp(g_flRecoilRangeChance2[iIndex], 0.0, 100.0);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_OnHookEvent(bool mode)
{
	switch (mode)
	{
		case true: HookEvent("weapon_fire", ST_OnEventFired);
		case false: UnhookEvent("weapon_fire", ST_OnEventFired);
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, "024"))
		{
			vRemoveRecoil(iTank);
		}
	}
	else if (StrEqual(name, "weapon_fire"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
		if (bIsSurvivor(iSurvivor) && bIsGunWeapon(iSurvivor) && g_bRecoil[iSurvivor])
		{
			float flRecoil[3];
			flRecoil[0] = GetRandomFloat(-20.0, -80.0);
			flRecoil[1] = GetRandomFloat(-25.0, 25.0);
			flRecoil[2] = GetRandomFloat(-25.0, 25.0);
			SetEntPropVector(iSurvivor, Prop_Send, "m_vecPunchAngle", flRecoil);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, "5") || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iRecoilAbility(tank) == 1)
	{
		vRecoilAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iRecoilAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bRecoil2[tank] && !g_bRecoil3[tank])
				{
					vRecoilAbility(tank);
				}
				else if (g_bRecoil2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "RecoilHuman3");
				}
				else if (g_bRecoil3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "RecoilHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveRecoil(tank);
}

static void vRecoilAbility(int tank)
{
	if (g_iRecoilCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bRecoil4[tank] = false;
		g_bRecoil5[tank] = false;

		float flRecoilRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flRecoilRange[ST_GetTankType(tank)] : g_flRecoilRange2[ST_GetTankType(tank)],
			flRecoilRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flRecoilRangeChance[ST_GetTankType(tank)] : g_flRecoilRangeChance2[ST_GetTankType(tank)],
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
				if (flDistance <= flRecoilRange)
				{
					vRecoilHit(iSurvivor, tank, flRecoilRangeChance, iRecoilAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "RecoilHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "RecoilAmmo");
	}
}

static void vRecoilHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iRecoilCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bRecoil[survivor])
			{
				g_bRecoil[survivor] = true;
				g_iRecoilOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bRecoil2[tank])
				{
					g_bRecoil2[tank] = true;
					g_iRecoilCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "RecoilHuman", g_iRecoilCount[tank], iHumanAmmo(tank));
				}

				DataPack dpStopRecoil;
				CreateDataTimer(flRecoilDuration(tank), tTimerStopRecoil, dpStopRecoil, TIMER_FLAG_NO_MAPCHANGE);
				dpStopRecoil.WriteCell(GetClientUserId(survivor));
				dpStopRecoil.WriteCell(GetClientUserId(tank));
				dpStopRecoil.WriteString(message);

				char sRecoilEffect[4];
				sRecoilEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_sRecoilEffect[ST_GetTankType(tank)] : g_sRecoilEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, sRecoilEffect, mode);

				char sRecoilMessage[3];
				sRecoilMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sRecoilMessage[ST_GetTankType(tank)] : g_sRecoilMessage2[ST_GetTankType(tank)];
				if (StrContains(sRecoilMessage, message) != -1)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Recoil", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bRecoil2[tank])
			{
				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bRecoil4[tank])
				{
					g_bRecoil4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "RecoilHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bRecoil5[tank])
		{
			g_bRecoil5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "RecoilAmmo");
		}
	}
}

static void vRemoveRecoil(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "24") && g_bRecoil[iSurvivor] && g_iRecoilOwner[iSurvivor] == tank)
		{
			g_bRecoil[iSurvivor] = false;
			g_iRecoilOwner[iSurvivor] = 0;
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

			g_iRecoilOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_bRecoil[tank] = false;
	g_bRecoil2[tank] = false;
	g_bRecoil3[tank] = false;
	g_bRecoil4[tank] = false;
	g_bRecoil5[tank] = false;
	g_iRecoilCount[tank] = 0;
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flRecoilChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flRecoilChance[ST_GetTankType(tank)] : g_flRecoilChance2[ST_GetTankType(tank)];
}

static float flRecoilDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flRecoilDuration[ST_GetTankType(tank)] : g_flRecoilDuration2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iRecoilAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iRecoilAbility[ST_GetTankType(tank)] : g_iRecoilAbility2[ST_GetTankType(tank)];
}

static int iRecoilHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iRecoilHit[ST_GetTankType(tank)] : g_iRecoilHit2[ST_GetTankType(tank)];
}

static int iRecoilHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iRecoilHitMode[ST_GetTankType(tank)] : g_iRecoilHitMode2[ST_GetTankType(tank)];
}

public Action tTimerStopRecoil(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor) || !g_bRecoil[iSurvivor])
	{
		g_bRecoil[iSurvivor] = false;
		g_iRecoilOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsTankSupported(iTank) || !ST_IsCloneSupported(iTank, g_bCloneInstalled))
	{
		g_bRecoil[iSurvivor] = false;
		g_iRecoilOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	g_bRecoil[iSurvivor] = false;
	g_bRecoil2[iTank] = false;
	g_iRecoilOwner[iSurvivor] = 0;

	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));

	if (ST_IsTankSupported(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bRecoil3[iTank])
	{
		g_bRecoil3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "RecoilHuman6");

		if (g_iRecoilCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
		{
			CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bRecoil3[iTank] = false;
		}
	}

	char sRecoilMessage[3];
	sRecoilMessage = !g_bTankConfig[ST_GetTankType(iTank)] ? g_sRecoilMessage[ST_GetTankType(iTank)] : g_sRecoilMessage2[ST_GetTankType(iTank)];
	if (StrContains(sRecoilMessage, sMessage) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Recoil2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bRecoil3[iTank])
	{
		g_bRecoil3[iTank] = false;

		return Plugin_Stop;
	}

	g_bRecoil3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "RecoilHuman7");

	return Plugin_Continue;
}