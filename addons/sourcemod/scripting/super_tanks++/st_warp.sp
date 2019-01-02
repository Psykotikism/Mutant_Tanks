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
	name = "[ST++] Warp Ability",
	author = ST_AUTHOR,
	description = "The Super Tank warps to survivors and warps survivors to random teammates.",
	version = ST_VERSION,
	url = ST_URL
};

#define PARTICLE_ELECTRICITY "electrical_arc_01_system"

#define SOUND_ELECTRICITY "ambient/energy/zap5.wav"
#define SOUND_ELECTRICITY2 "ambient/energy/zap7.wav"

#define ST_MENU_WARP "Warp Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1], g_bWarp[MAXPLAYERS + 1], g_bWarp2[MAXPLAYERS + 1], g_bWarp3[MAXPLAYERS + 1], g_bWarp4[MAXPLAYERS + 1], g_bWarp5[MAXPLAYERS + 1];

char g_sWarpEffect[ST_MAXTYPES + 1][4], g_sWarpEffect2[ST_MAXTYPES + 1][4], g_sWarpMessage[ST_MAXTYPES + 1][4], g_sWarpMessage2[ST_MAXTYPES + 1][4];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flHumanDuration[ST_MAXTYPES + 1], g_flHumanDuration2[ST_MAXTYPES + 1], g_flWarpChance[ST_MAXTYPES + 1], g_flWarpChance2[ST_MAXTYPES + 1], g_flWarpInterval[ST_MAXTYPES + 1], g_flWarpInterval2[ST_MAXTYPES + 1], g_flWarpRange[ST_MAXTYPES + 1], g_flWarpRange2[ST_MAXTYPES + 1], g_flWarpRangeChance[ST_MAXTYPES + 1], g_flWarpRangeChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1], g_iWarpAbility[ST_MAXTYPES + 1], g_iWarpAbility2[ST_MAXTYPES + 1], g_iWarpCount[MAXPLAYERS + 1], g_iWarpCount2[MAXPLAYERS + 1], g_iWarpHit[ST_MAXTYPES + 1], g_iWarpHit2[ST_MAXTYPES + 1], g_iWarpHitMode[ST_MAXTYPES + 1], g_iWarpHitMode2[ST_MAXTYPES + 1], g_iWarpMode[ST_MAXTYPES + 1], g_iWarpMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Warp Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_warp", cmdWarpInfo, "View information about the Warp ability.");

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
	vPrecacheParticle(PARTICLE_ELECTRICITY);

	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_ELECTRICITY2, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveWarp(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdWarpInfo(int client, int args)
{
	if (!ST_PluginEnabled())
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
		case false: vWarpMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vWarpMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iWarpMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Warp Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Button Mode", "Button Mode");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iWarpMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iWarpAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iWarpCount[param1], iHumanAmmo(param1));
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo2", iHumanAmmo(param1) - g_iWarpCount2[param1], iHumanAmmo(param1));
				}
				case 2:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				}
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "WarpDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flHumanDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vWarpMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "WarpMenu", param1);
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
					Format(sMenuOption, sizeof(sMenuOption), "%T", "ButtonMode", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 6:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 7:
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
	menu.AddItem(ST_MENU_WARP, ST_MENU_WARP);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_WARP, false))
	{
		vWarpMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && (iWarpHitMode(attacker) == 0 || iWarpHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vWarpHit(victim, attacker, flWarpChance(attacker), iWarpHit(attacker), "1", "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && (iWarpHitMode(victim) == 0 || iWarpHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vWarpHit(attacker, victim, flWarpChance(victim), iWarpHit(victim), "1", "2");
			}
		}
	}
}

public void ST_OnConfigsLoaded(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);

	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Warp Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Warp Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_flHumanDuration[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Human Duration", 5.0);
					g_flHumanDuration[iIndex] = flClamp(g_flHumanDuration[iIndex], 0.1, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Warp Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iWarpAbility[iIndex] = kvSuperTanks.GetNum("Warp Ability/Ability Enabled", 0);
					g_iWarpAbility[iIndex] = iClamp(g_iWarpAbility[iIndex], 0, 3);
					kvSuperTanks.GetString("Warp Ability/Ability Effect", g_sWarpEffect[iIndex], sizeof(g_sWarpEffect[]), "0");
					kvSuperTanks.GetString("Warp Ability/Ability Message", g_sWarpMessage[iIndex], sizeof(g_sWarpMessage[]), "0");
					g_flWarpChance[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Chance", 33.3);
					g_flWarpChance[iIndex] = flClamp(g_flWarpChance[iIndex], 0.0, 100.0);
					g_iWarpHit[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Hit", 0);
					g_iWarpHit[iIndex] = iClamp(g_iWarpHit[iIndex], 0, 1);
					g_iWarpHitMode[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Hit Mode", 0);
					g_iWarpHitMode[iIndex] = iClamp(g_iWarpHitMode[iIndex], 0, 2);
					g_flWarpInterval[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Interval", 5.0);
					g_flWarpInterval[iIndex] = flClamp(g_flWarpInterval[iIndex], 0.1, 9999999999.0);
					g_iWarpMode[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Mode", 0);
					g_iWarpMode[iIndex] = iClamp(g_iWarpMode[iIndex], 0, 1);
					g_flWarpRange[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Range", 150.0);
					g_flWarpRange[iIndex] = flClamp(g_flWarpRange[iIndex], 1.0, 9999999999.0);
					g_flWarpRangeChance[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Range Chance", 15.0);
					g_flWarpRangeChance[iIndex] = flClamp(g_flWarpRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_flHumanDuration2[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Human Duration", g_flHumanDuration[iIndex]);
					g_flHumanDuration2[iIndex] = flClamp(g_flHumanDuration2[iIndex], 0.1, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iWarpAbility2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Ability Enabled", g_iWarpAbility[iIndex]);
					g_iWarpAbility2[iIndex] = iClamp(g_iWarpAbility2[iIndex], 0, 3);
					kvSuperTanks.GetString("Warp Ability/Ability Effect", g_sWarpEffect2[iIndex], sizeof(g_sWarpEffect2[]), g_sWarpEffect[iIndex]);
					kvSuperTanks.GetString("Warp Ability/Ability Message", g_sWarpMessage2[iIndex], sizeof(g_sWarpMessage2[]), g_sWarpMessage[iIndex]);
					g_flWarpChance2[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Chance", g_flWarpChance[iIndex]);
					g_flWarpChance2[iIndex] = flClamp(g_flWarpChance2[iIndex], 0.0, 100.0);
					g_iWarpHit2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Hit", g_iWarpHit[iIndex]);
					g_iWarpHit2[iIndex] = iClamp(g_iWarpHit2[iIndex], 0, 1);
					g_iWarpHitMode2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Hit Mode", g_iWarpHitMode[iIndex]);
					g_iWarpHitMode2[iIndex] = iClamp(g_iWarpHitMode2[iIndex], 0, 2);
					g_flWarpInterval2[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Interval", g_flWarpInterval[iIndex]);
					g_flWarpInterval2[iIndex] = flClamp(g_flWarpInterval2[iIndex], 0.1, 9999999999.0);
					g_iWarpMode2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Mode", g_iWarpMode[iIndex]);
					g_iWarpMode2[iIndex] = iClamp(g_iWarpMode2[iIndex], 0, 1);
					g_flWarpRange2[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Range", g_flWarpRange[iIndex]);
					g_flWarpRange2[iIndex] = flClamp(g_flWarpRange2[iIndex], 1.0, 9999999999.0);
					g_flWarpRangeChance2[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Range Chance", g_flWarpRangeChance[iIndex]);
					g_flWarpRangeChance2[iIndex] = flClamp(g_flWarpRangeChance2[iIndex], 0.0, 100.0);
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
		if (ST_TankAllowed(iTank, "024"))
		{
			vRemoveWarp(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iWarpAbility(tank) > 0)
	{
		vWarpAbility(tank, true);
		vWarpAbility(tank, false);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if ((iWarpAbility(tank) == 2 || iWarpAbility(tank) == 3) && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
				{
					case 0:
					{
						if (!g_bWarp[tank] && !g_bWarp2[tank])
						{
							vWarpAbility(tank, false);
						}
						else if (g_bWarp[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman4");
						}
						else if (g_bWarp2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman5");
						}
					}
					case 1:
					{
						if (g_iWarpCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bWarp[tank] && !g_bWarp2[tank])
							{
								g_bWarp[tank] = true;
								g_iWarpCount[tank]++;

								vWarp(tank);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman", g_iWarpCount[tank], iHumanAmmo(tank));
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpAmmo");
						}
					}
				}
			}
		}

		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if ((iWarpAbility(tank) == 1 || iWarpAbility(tank) == 3) && iHumanAbility(tank) == 1)
			{
				switch (g_bWarp3[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman6");
					case false: vWarpAbility(tank, true);
				}
			}
		}
	}
}

public void ST_OnButtonReleased(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if ((iWarpAbility(tank) == 2 || iWarpAbility(tank) == 3) && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bWarp[tank] && !g_bWarp2[tank])
				{
					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveWarp(tank);
}

static void vRemoveWarp(int tank)
{
	g_bWarp[tank] = false;
	g_bWarp2[tank] = false;
	g_bWarp3[tank] = false;
	g_bWarp4[tank] = false;
	g_bWarp5[tank] = false;
	g_iWarpCount[tank] = 0;
	g_iWarpCount2[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveWarp(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bWarp[tank] = false;
	g_bWarp2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman8");

	if (g_iWarpCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bWarp2[tank] = false;
	}
}

static void vWarp(int tank)
{
	float flWarpInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flWarpInterval[ST_TankType(tank)] : g_flWarpInterval2[ST_TankType(tank)];
	DataPack dpWarp;
	CreateDataTimer(flWarpInterval, tTimerWarp, dpWarp, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpWarp.WriteCell(GetClientUserId(tank));
	dpWarp.WriteFloat(GetEngineTime());
}

static void vWarpAbility(int tank, bool main)
{
	switch (main)
	{
		case true:
		{
			if (iWarpAbility(tank) == 1 || iWarpAbility(tank) == 3)
			{
				if (g_iWarpCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
				{
					g_bWarp4[tank] = false;
					g_bWarp5[tank] = false;

					float flWarpRange = !g_bTankConfig[ST_TankType(tank)] ? g_flWarpRange[ST_TankType(tank)] : g_flWarpRange2[ST_TankType(tank)],
						flWarpRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flWarpRangeChance[ST_TankType(tank)] : g_flWarpRangeChance2[ST_TankType(tank)],
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
							if (flDistance <= flWarpRange)
							{
								vWarpHit(iSurvivor, tank, flWarpRangeChance, iWarpAbility(tank), "2", "3");

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman7");
						}
					}
				}
				else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpAmmo");
				}
			}
		}
		case false:
		{
			if ((iWarpAbility(tank) == 2 || iWarpAbility(tank) == 3) && !g_bWarp[tank])
			{
				if (g_iWarpCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
				{
					g_bWarp[tank] = true;

					if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
					{
						g_iWarpCount[tank]++;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman", g_iWarpCount[tank], iHumanAmmo(tank));
					}

					vWarp(tank);

					char sWarpMessage[4];
					sWarpMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sWarpMessage[ST_TankType(tank)] : g_sWarpMessage2[ST_TankType(tank)];
					if (StrContains(sWarpMessage, "3") != -1)
					{
						char sTankName[33];
						ST_TankName(tank, sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Warp2", sTankName);
					}
				}
				else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpAmmo");
				}
			}
		}
	}
}

static void vWarpHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (g_iWarpCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				float flCurrentOrigin[3];
				for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
				{
					if (bIsSurvivor(iPlayer) && !bIsPlayerIncapacitated(iPlayer) && iPlayer != survivor)
					{
						if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bWarp3[tank])
						{
							g_bWarp3[tank] = true;
							g_iWarpCount2[tank]++;

							ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman2", g_iWarpCount2[tank], iHumanAmmo(tank));

							if (g_iWarpCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
							{
								CreateTimer(flHumanCooldown(tank), tTimerResetCooldown2, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
							}
							else
							{
								g_bWarp3[tank] = false;
							}
						}

						GetClientAbsOrigin(iPlayer, flCurrentOrigin);
						TeleportEntity(survivor, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);

						char sWarpMessage[4];
						sWarpMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sWarpMessage[ST_TankType(tank)] : g_sWarpMessage2[ST_TankType(tank)];
						if (StrContains(sWarpMessage, message) != -1)
						{
							char sTankName[33];
							ST_TankName(tank, sTankName);
							ST_PrintToChatAll("%s %t", ST_TAG2, "Warp", sTankName, survivor, iPlayer);
						}

						break;
					}
				}

				char sWarpEffect[4];
				sWarpEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sWarpEffect[ST_TankType(tank)] : g_sWarpEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sWarpEffect, mode);
			}
			else if (StrEqual(mode, "3") && !g_bWarp3[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bWarp4[tank])
				{
					g_bWarp4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpHuman3");
				}
			}
		}
		else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bWarp5[tank])
		{
			g_bWarp5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "WarpAmmo2");
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flHumanDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanDuration[ST_TankType(tank)] : g_flHumanDuration2[ST_TankType(tank)];
}

static float flWarpChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flWarpChance[ST_TankType(tank)] : g_flWarpChance2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iHumanMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanMode[ST_TankType(tank)] : g_iHumanMode2[ST_TankType(tank)];
}

static int iWarpAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWarpAbility[ST_TankType(tank)] : g_iWarpAbility2[ST_TankType(tank)];
}

static int iWarpHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWarpHit[ST_TankType(tank)] : g_iWarpHit2[ST_TankType(tank)];
}

static int iWarpHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWarpHitMode[ST_TankType(tank)] : g_iWarpHitMode2[ST_TankType(tank)];
}

public Action tTimerWarp(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || (iWarpAbility(iTank) != 2 && iWarpAbility(iTank) != 3) || !g_bWarp[iTank])
	{
		g_bWarp[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0 && (flTime + flHumanDuration(iTank)) < GetEngineTime() && !g_bWarp2[iTank])
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	int iSurvivor = iGetRandomSurvivor(iTank);
	if (iSurvivor > 0)
	{
		float flTankOrigin[3], flTankAngles[3], flSurvivorOrigin[3], flSurvivorAngles[3];

		GetClientAbsOrigin(iTank, flTankOrigin);
		GetClientAbsAngles(iTank, flTankAngles);

		GetClientAbsOrigin(iSurvivor, flSurvivorOrigin);
		GetClientAbsAngles(iSurvivor, flSurvivorAngles);

		vCreateParticle(iTank, PARTICLE_ELECTRICITY, 1.0, 0.0);
		EmitSoundToAll(SOUND_ELECTRICITY, iTank);

		TeleportEntity(iTank, flSurvivorOrigin, flSurvivorAngles, NULL_VECTOR);

		int iWarpMode = !g_bTankConfig[ST_TankType(iTank)] ? g_iWarpMode[ST_TankType(iTank)] : g_iWarpMode2[ST_TankType(iTank)];
		if (iWarpMode == 1)
		{
			vCreateParticle(iSurvivor, PARTICLE_ELECTRICITY, 1.0, 0.0);
			EmitSoundToAll(SOUND_ELECTRICITY2, iSurvivor);

			TeleportEntity(iSurvivor, flTankOrigin, flTankAngles, NULL_VECTOR);
		}

		char sWarpMessage[4];
		sWarpMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sWarpMessage[ST_TankType(iTank)] : g_sWarpMessage2[ST_TankType(iTank)];
		if (StrContains(sWarpMessage, "3") != -1)
		{
			char sTankName[33];
			ST_TankName(iTank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Warp3", sTankName);
		}
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bWarp2[iTank])
	{
		g_bWarp2[iTank] = false;

		return Plugin_Stop;
	}

	g_bWarp2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "WarpHuman9");

	return Plugin_Continue;
}

public Action tTimerResetCooldown2(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank, "02345") || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bWarp3[iTank])
	{
		g_bWarp3[iTank] = false;

		return Plugin_Stop;
	}

	g_bWarp3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "WarpHuman10");

	return Plugin_Continue;
}