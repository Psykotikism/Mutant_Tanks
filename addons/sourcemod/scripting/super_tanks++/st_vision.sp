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
	name = "[ST++] Vision Ability",
	author = ST_AUTHOR,
	description = "The Super Tank changes the survivors' field of view.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_VISION "Vision Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1], g_bVision[MAXPLAYERS + 1], g_bVision2[MAXPLAYERS + 1], g_bVision3[MAXPLAYERS + 1], g_bVision4[MAXPLAYERS + 1], g_bVision5[MAXPLAYERS + 1];

char g_sVisionEffect[ST_MAXTYPES + 1][4], g_sVisionEffect2[ST_MAXTYPES + 1][4], g_sVisionMessage[ST_MAXTYPES + 1][3], g_sVisionMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flVisionChance[ST_MAXTYPES + 1], g_flVisionChance2[ST_MAXTYPES + 1], g_flVisionDuration[ST_MAXTYPES + 1], g_flVisionDuration2[ST_MAXTYPES + 1], g_flVisionRange[ST_MAXTYPES + 1], g_flVisionRange2[ST_MAXTYPES + 1], g_flVisionRangeChance[ST_MAXTYPES + 1], g_flVisionRangeChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iVisionAbility[ST_MAXTYPES + 1], g_iVisionAbility2[ST_MAXTYPES + 1], g_iVisionCount[MAXPLAYERS + 1], g_iVisionFOV[ST_MAXTYPES + 1], g_iVisionFOV2[ST_MAXTYPES + 1], g_iVisionHit[ST_MAXTYPES + 1], g_iVisionHit2[ST_MAXTYPES + 1], g_iVisionHitMode[ST_MAXTYPES + 1], g_iVisionHitMode2[ST_MAXTYPES + 1], g_iVisionOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Vision Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_vision", cmdVisionInfo, "View information about the Vision ability.");

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

public Action cmdVisionInfo(int client, int args)
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
		case false: vVisionMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vVisionMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iVisionMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Vision Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iVisionMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iVisionAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iVisionCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "VisionDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flVisionDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vVisionMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "VisionMenu", param1);
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
	menu.AddItem(ST_MENU_VISION, ST_MENU_VISION);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_VISION, false))
	{
		vVisionMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iVisionHitMode(attacker) == 0 || iVisionHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsHumanSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vVisionHit(victim, attacker, flVisionChance(attacker), iVisionHit(attacker), "1", "1");
			}
		}
		else if ((iVisionHitMode(victim) == 0 || iVisionHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vVisionHit(attacker, victim, flVisionChance(victim), iVisionHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Vision Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Vision Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iVisionAbility[iIndex] = kvSuperTanks.GetNum("Vision Ability/Ability Enabled", 0);
					g_iVisionAbility[iIndex] = iClamp(g_iVisionAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Vision Ability/Ability Effect", g_sVisionEffect[iIndex], sizeof(g_sVisionEffect[]), "0");
					kvSuperTanks.GetString("Vision Ability/Ability Message", g_sVisionMessage[iIndex], sizeof(g_sVisionMessage[]), "0");
					g_flVisionChance[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Chance", 33.3);
					g_flVisionChance[iIndex] = flClamp(g_flVisionChance[iIndex], 0.0, 100.0);
					g_flVisionDuration[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Duration", 5.0);
					g_flVisionDuration[iIndex] = flClamp(g_flVisionDuration[iIndex], 0.1, 9999999999.0);
					g_iVisionFOV[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision FOV", 160);
					g_iVisionFOV[iIndex] = iClamp(g_iVisionFOV[iIndex], 1, 160);
					g_iVisionHit[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Hit", 0);
					g_iVisionHit[iIndex] = iClamp(g_iVisionHit[iIndex], 0, 1);
					g_iVisionHitMode[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Hit Mode", 0);
					g_iVisionHitMode[iIndex] = iClamp(g_iVisionHitMode[iIndex], 0, 2);
					g_flVisionRange[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Range", 150.0);
					g_flVisionRange[iIndex] = flClamp(g_flVisionRange[iIndex], 1.0, 9999999999.0);
					g_flVisionRangeChance[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Range Chance", 15.0);
					g_flVisionRangeChance[iIndex] = flClamp(g_flVisionRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iVisionAbility2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Ability Enabled", g_iVisionAbility[iIndex]);
					g_iVisionAbility2[iIndex] = iClamp(g_iVisionAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Vision Ability/Ability Effect", g_sVisionEffect2[iIndex], sizeof(g_sVisionEffect2[]), g_sVisionEffect[iIndex]);
					kvSuperTanks.GetString("Vision Ability/Ability Message", g_sVisionMessage2[iIndex], sizeof(g_sVisionMessage2[]), g_sVisionMessage[iIndex]);
					g_flVisionChance2[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Chance", g_flVisionChance[iIndex]);
					g_flVisionChance2[iIndex] = flClamp(g_flVisionChance2[iIndex], 0.0, 100.0);
					g_flVisionDuration2[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Duration", g_flVisionDuration[iIndex]);
					g_flVisionDuration2[iIndex] = flClamp(g_flVisionDuration2[iIndex], 0.1, 9999999999.0);
					g_iVisionFOV2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision FOV", g_iVisionFOV[iIndex]);
					g_iVisionFOV2[iIndex] = iClamp(g_iVisionFOV2[iIndex], 1, 160);
					g_iVisionHit2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Hit", g_iVisionHit[iIndex]);
					g_iVisionHit2[iIndex] = iClamp(g_iVisionHit2[iIndex], 0, 1);
					g_iVisionHitMode2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Hit Mode", g_iVisionHitMode[iIndex]);
					g_iVisionHitMode2[iIndex] = iClamp(g_iVisionHitMode2[iIndex], 0, 2);
					g_flVisionRange2[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Range", g_flVisionRange[iIndex]);
					g_flVisionRange2[iIndex] = flClamp(g_flVisionRange2[iIndex], 1.0, 9999999999.0);
					g_flVisionRangeChance2[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Range Chance", g_flVisionRangeChance[iIndex]);
					g_flVisionRangeChance2[iIndex] = flClamp(g_flVisionRangeChance2[iIndex], 0.0, 100.0);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_OnPluginEnd()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, "234") && g_bVision[iSurvivor])
		{
			SetEntProp(iSurvivor, Prop_Send, "m_iFOV", 90);
			SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", 90);
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank, "024") && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveVision(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iVisionAbility(tank) == 1)
	{
		vVisionAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iVisionAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bVision2[tank] && !g_bVision3[tank])
				{
					vVisionAbility(tank);
				}
				else if (g_bVision2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "VisionHuman3");
				}
				else if (g_bVision3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "VisionHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveVision(tank);
}

static void vVisionAbility(int tank)
{
	if (g_iVisionCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bVision4[tank] = false;
		g_bVision5[tank] = false;

		float flVisionRange = !g_bTankConfig[ST_TankType(tank)] ? g_flVisionRange[ST_TankType(tank)] : g_flVisionRange2[ST_TankType(tank)],
			flVisionRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flVisionRangeChance[ST_TankType(tank)] : g_flVisionRangeChance2[ST_TankType(tank)],
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
				if (flDistance <= flVisionRange)
				{
					vVisionHit(iSurvivor, tank, flVisionRangeChance, iVisionAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "VisionHuman5");
			}
		}
	}
	else
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "VisionAmmo");
	}
}

static void vRemoveVision(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, "234") && g_bVision[iSurvivor] && g_iVisionOwner[iSurvivor] == tank)
		{
			g_bVision[iSurvivor] = false;
			g_iVisionOwner[iSurvivor] = 0;
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

			g_iVisionOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bVision[survivor] = false;
	g_iVisionOwner[survivor] = 0;

	SetEntProp(survivor, Prop_Send, "m_iFOV", 90);
	SetEntProp(survivor, Prop_Send, "m_iDefaultFOV", 90);

	char sVisionMessage[3];
	sVisionMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sVisionMessage[ST_TankType(tank)] : g_sVisionMessage2[ST_TankType(tank)];
	if (StrContains(sVisionMessage, message) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Vision2", survivor, 90);
	}
}

static void vReset3(int tank)
{
	g_bVision[tank] = false;
	g_bVision2[tank] = false;
	g_bVision3[tank] = false;
	g_bVision4[tank] = false;
	g_bVision5[tank] = false;
	g_iVisionCount[tank] = 0;
}

static void vVisionHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iVisionCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bVision[survivor])
			{
				g_bVision[survivor] = true;
				g_iVisionOwner[survivor] = tank;

				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bVision2[tank])
				{
					g_bVision2[tank] = true;
					g_iVisionCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "VisionHuman", g_iVisionCount[tank], iHumanAmmo(tank));
				}

				DataPack dpVision;
				CreateDataTimer(0.1, tTimerVision, dpVision, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpVision.WriteCell(GetClientUserId(survivor));
				dpVision.WriteCell(GetClientUserId(tank));
				dpVision.WriteString(message);
				dpVision.WriteCell(enabled);
				dpVision.WriteFloat(GetEngineTime());

				char sVisionEffect[4];
				sVisionEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sVisionEffect[ST_TankType(tank)] : g_sVisionEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sVisionEffect, mode);

				char sVisionMessage[3];
				sVisionMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sVisionMessage[ST_TankType(tank)] : g_sVisionMessage2[ST_TankType(tank)];
				if (StrContains(sVisionMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Vision", sTankName, survivor, iVisionFOV(tank));
				}
			}
			else if (StrEqual(mode, "3") && !g_bVision2[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bVision4[tank])
				{
					g_bVision4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "VisionHuman2");
				}
			}
		}
		else
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bVision5[tank])
			{
				g_bVision5[tank] = true;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "VisionAmmo");
			}
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flVisionChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flVisionChance[ST_TankType(tank)] : g_flVisionChance2[ST_TankType(tank)];
}

static float flVisionDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flVisionDuration[ST_TankType(tank)] : g_flVisionDuration2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iVisionAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iVisionAbility[ST_TankType(tank)] : g_iVisionAbility2[ST_TankType(tank)];
}

static int iVisionFOV(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iVisionFOV[ST_TankType(tank)] : g_iVisionFOV2[ST_TankType(tank)];
}

static int iVisionHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iVisionHit[ST_TankType(tank)] : g_iVisionHit2[ST_TankType(tank)];
}

static int iVisionHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iVisionHitMode[ST_TankType(tank)] : g_iVisionHitMode2[ST_TankType(tank)];
}

public Action tTimerVision(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !bIsHumanSurvivor(iSurvivor))
	{
		g_bVision[iSurvivor] = false;
		g_iVisionOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bVision[iSurvivor])
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iVisionEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iVisionEnabled == 0 || (flTime + flVisionDuration(iTank)) < GetEngineTime())
	{
		g_bVision2[iTank] = false;

		vReset2(iSurvivor, iTank, sMessage);

		if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bVision3[iTank])
		{
			g_bVision3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "VisionHuman6");

			if (g_iVisionCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
			{
				CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bVision3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	SetEntProp(iSurvivor, Prop_Send, "m_iFOV", iVisionFOV(iTank));
	SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", iVisionFOV(iTank));

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bVision3[iTank])
	{
		g_bVision3[iTank] = false;

		return Plugin_Stop;
	}

	g_bVision3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "VisionHuman7");

	return Plugin_Continue;
}