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
	name = "[ST++] Puke Ability",
	author = ST_AUTHOR,
	description = "The Super Tank pukes on survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_PUKE "Puke Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bPuke[MAXPLAYERS + 1], g_bPuke2[MAXPLAYERS + 1], g_bPuke3[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sPukeEffect[ST_MAXTYPES + 1][4], g_sPukeEffect2[ST_MAXTYPES + 1][4], g_sPukeMessage[ST_MAXTYPES + 1][3], g_sPukeMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flPukeChance[ST_MAXTYPES + 1], g_flPukeChance2[ST_MAXTYPES + 1], g_flPukeRange[ST_MAXTYPES + 1], g_flPukeRange2[ST_MAXTYPES + 1], g_flPukeRangeChance[ST_MAXTYPES + 1], g_flPukeRangeChance2[ST_MAXTYPES + 1];

Handle g_hSDKPukePlayer;

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iPukeAbility[ST_MAXTYPES + 1], g_iPukeAbility2[ST_MAXTYPES + 1], g_iPukeCount[MAXPLAYERS + 1], g_iPukeHit[ST_MAXTYPES + 1], g_iPukeHit2[ST_MAXTYPES + 1], g_iPukeHitMode[ST_MAXTYPES + 1], g_iPukeHitMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Puke Ability\" only supports Left 4 Dead 1 & 2.");

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
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_puke", cmdPukeInfo, "View information about the Puke ability.");

	GameData gdSuperTanks = new GameData("super_tanks++");

	if (gdSuperTanks == null)
	{
		SetFailState("Unable to load the \"super_tanks++\" gamedata file.");
		return;
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDKPukePlayer = EndPrepSDKCall();

	if (g_hSDKPukePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnVomitedUpon\" signature is outdated.", ST_TAG);
	}

	delete gdSuperTanks;

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

	vRemovePuke(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdPukeInfo(int client, int args)
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
		case false: vPukeMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vPukeMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iPukeMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Puke Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iPukeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iPukeAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iPukeCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "PukeDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vPukeMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "PukeMenu", param1);
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
	menu.AddItem(ST_MENU_PUKE, ST_MENU_PUKE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_PUKE, false))
	{
		vPukeMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && (iPukeHitMode(attacker) == 0 || iPukeHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vPukeHit(victim, attacker, flPukeChance(attacker), iPukeHit(attacker), "1", "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && (iPukeHitMode(victim) == 0 || iPukeHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vPukeHit(attacker, victim, flPukeChance(victim), iPukeHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Puke Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Puke Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iPukeAbility[iIndex] = kvSuperTanks.GetNum("Puke Ability/Ability Enabled", 0);
					g_iPukeAbility[iIndex] = iClamp(g_iPukeAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Puke Ability/Ability Effect", g_sPukeEffect[iIndex], sizeof(g_sPukeEffect[]), "0");
					kvSuperTanks.GetString("Puke Ability/Ability Message", g_sPukeMessage[iIndex], sizeof(g_sPukeMessage[]), "0");
					g_flPukeChance[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Chance", 33.3);
					g_flPukeChance[iIndex] = flClamp(g_flPukeChance[iIndex], 0.0, 100.0);
					g_iPukeHit[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Hit", 0);
					g_iPukeHit[iIndex] = iClamp(g_iPukeHit[iIndex], 0, 1);
					g_iPukeHitMode[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Hit Mode", 0);
					g_iPukeHitMode[iIndex] = iClamp(g_iPukeHitMode[iIndex], 0, 2);
					g_flPukeRange[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Range", 150.0);
					g_flPukeRange[iIndex] = flClamp(g_flPukeRange[iIndex], 1.0, 9999999999.0);
					g_flPukeRangeChance[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Range Chance", 15.0);
					g_flPukeRangeChance[iIndex] = flClamp(g_flPukeRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iPukeAbility2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Ability Enabled", g_iPukeAbility[iIndex]);
					g_iPukeAbility2[iIndex] = iClamp(g_iPukeAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Puke Ability/Ability Effect", g_sPukeEffect2[iIndex], sizeof(g_sPukeEffect2[]), g_sPukeEffect[iIndex]);
					kvSuperTanks.GetString("Puke Ability/Ability Message", g_sPukeMessage2[iIndex], sizeof(g_sPukeMessage2[]), g_sPukeMessage[iIndex]);
					g_flPukeChance2[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Chance", g_flPukeChance[iIndex]);
					g_flPukeChance2[iIndex] = flClamp(g_flPukeChance2[iIndex], 0.0, 100.0);
					g_iPukeHit2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Hit", g_iPukeHit[iIndex]);
					g_iPukeHit2[iIndex] = iClamp(g_iPukeHit2[iIndex], 0, 1);
					g_iPukeHitMode2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Hit Mode", g_iPukeHitMode[iIndex]);
					g_iPukeHitMode2[iIndex] = iClamp(g_iPukeHitMode2[iIndex], 0, 2);
					g_flPukeRange2[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Range", g_flPukeRange[iIndex]);
					g_flPukeRange2[iIndex] = flClamp(g_flPukeRange2[iIndex], 1.0, 9999999999.0);
					g_flPukeRangeChance2[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Range Chance", g_flPukeRangeChance[iIndex]);
					g_flPukeRangeChance2[iIndex] = flClamp(g_flPukeRangeChance2[iIndex], 0.0, 100.0);
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
			vRemovePuke(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iPukeAbility(tank) == 1)
	{
		vPukeAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iPukeAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (g_bPuke[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "PukeHuman3");
					case false: vPukeAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemovePuke(tank);
}

static void vPukeAbility(int tank)
{
	if (g_iPukeCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bPuke2[tank] = false;
		g_bPuke3[tank] = false;

		float flPukeRange = !g_bTankConfig[ST_TankType(tank)] ? g_flPukeRange[ST_TankType(tank)] : g_flPukeRange2[ST_TankType(tank)],
			flPukeRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flPukeRangeChance[ST_TankType(tank)] : g_flPukeRangeChance2[ST_TankType(tank)],
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
				if (flDistance <= flPukeRange)
				{
					vPukeHit(iSurvivor, tank, flPukeRangeChance, iPukeAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "PukeHuman4");
			}
		}
	}
	else
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "PukeAmmo");
	}
}

static void vPukeHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iPukeCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bPuke[tank])
				{
					g_bPuke[tank] = true;
					g_iPukeCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "PukeHuman", g_iPukeCount[tank], iHumanAmmo(tank));

					if (g_iPukeCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
					{
						CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bPuke[tank] = false;
					}
				}

				SDKCall(g_hSDKPukePlayer, survivor, tank, true);

				char sPukeEffect[4];
				sPukeEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sPukeEffect[ST_TankType(tank)] : g_sPukeEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sPukeEffect, mode);

				char sPukeMessage[3];
				sPukeMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sPukeMessage[ST_TankType(tank)] : g_sPukeMessage2[ST_TankType(tank)];
				if (StrContains(sPukeMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Puke", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bPuke[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bPuke2[tank])
				{
					g_bPuke2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "PukeHuman2");
				}
			}
		}
		else
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bPuke3[tank])
			{
				g_bPuke3[tank] = true;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "PukeAmmo");
			}
		}
	}
}

static void vRemovePuke(int tank)
{
	g_bPuke[tank] = false;
	g_bPuke2[tank] = false;
	g_bPuke3[tank] = false;
	g_iPukeCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemovePuke(iPlayer);
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flPukeChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flPukeChance[ST_TankType(tank)] : g_flPukeChance2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iPukeAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPukeAbility[ST_TankType(tank)] : g_iPukeAbility2[ST_TankType(tank)];
}

static int iPukeHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPukeHit[ST_TankType(tank)] : g_iPukeHit2[ST_TankType(tank)];
}

static int iPukeHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPukeHitMode[ST_TankType(tank)] : g_iPukeHitMode2[ST_TankType(tank)];
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bPuke[iTank])
	{
		g_bPuke[iTank] = false;

		return Plugin_Stop;
	}

	g_bPuke[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "PukeHuman5");

	return Plugin_Continue;
}