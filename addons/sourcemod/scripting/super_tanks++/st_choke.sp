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
	name = "[ST++] Choke Ability",
	author = ST_AUTHOR,
	description = "The Super Tank chokes survivors in midair.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_CHOKE "Choke Ability"

bool g_bChoke[MAXPLAYERS + 1], g_bChoke2[MAXPLAYERS + 1], g_bChoke3[MAXPLAYERS + 1], g_bChoke4[MAXPLAYERS + 1], g_bChoke5[MAXPLAYERS + 1], g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sChokeEffect[ST_MAXTYPES + 1][4], g_sChokeEffect2[ST_MAXTYPES + 1][4], g_sChokeMessage[ST_MAXTYPES + 1][3], g_sChokeMessage2[ST_MAXTYPES + 1][3];

float g_flChokeAngle[MAXPLAYERS + 1][3], g_flChokeChance[ST_MAXTYPES + 1], g_flChokeChance2[ST_MAXTYPES + 1], g_flChokeDamage[ST_MAXTYPES + 1], g_flChokeDamage2[ST_MAXTYPES + 1], g_flChokeDelay[ST_MAXTYPES + 1], g_flChokeDelay2[ST_MAXTYPES + 1], g_flChokeDuration[ST_MAXTYPES + 1], g_flChokeDuration2[ST_MAXTYPES + 1], g_flChokeHeight[ST_MAXTYPES + 1], g_flChokeHeight2[ST_MAXTYPES + 1], g_flChokeRange[ST_MAXTYPES + 1], g_flChokeRange2[ST_MAXTYPES + 1], g_flChokeRangeChance[ST_MAXTYPES + 1], g_flChokeRangeChance2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

int g_iChokeAbility[ST_MAXTYPES + 1], g_iChokeAbility2[ST_MAXTYPES + 1], g_iChokeCount[MAXPLAYERS + 1], g_iChokeHit[ST_MAXTYPES + 1], g_iChokeHit2[ST_MAXTYPES + 1], g_iChokeHitMode[ST_MAXTYPES + 1], g_iChokeHitMode2[ST_MAXTYPES + 1], g_iChokeOwner[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Choke Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_choke", cmdChokeInfo, "View information about the Choke ability.");

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

public Action cmdChokeInfo(int client, int args)
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
		case false: vChokeMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vChokeMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iChokeMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Choke Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iChokeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iChokeAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iChokeCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "ChokeDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flChokeDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vChokeMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "ChokeMenu", param1);
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
	menu.AddItem(ST_MENU_CHOKE, ST_MENU_CHOKE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_CHOKE, false))
	{
		vChokeMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && (iChokeHitMode(attacker) == 0 || iChokeHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vChokeHit(victim, attacker, flChokeChance(attacker), iChokeHit(attacker), "1", "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && (iChokeHitMode(victim) == 0 || iChokeHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vChokeHit(attacker, victim, flChokeChance(victim), iChokeHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Choke Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Choke Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 1, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iChokeAbility[iIndex] = kvSuperTanks.GetNum("Choke Ability/Ability Enabled", 0);
					g_iChokeAbility[iIndex] = iClamp(g_iChokeAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Choke Ability/Ability Effect", g_sChokeEffect[iIndex], sizeof(g_sChokeEffect[]), "0");
					kvSuperTanks.GetString("Choke Ability/Ability Message", g_sChokeMessage[iIndex], sizeof(g_sChokeMessage[]), "0");
					g_flChokeChance[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Chance", 33.3);
					g_flChokeChance[iIndex] = flClamp(g_flChokeChance[iIndex], 0.0, 100.0);
					g_flChokeDamage[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Damage", 5.0);
					g_flChokeDamage[iIndex] = flClamp(g_flChokeDamage[iIndex], 1.0, 9999999999.0);
					g_flChokeDelay[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Delay", 1.0);
					g_flChokeDelay[iIndex] = flClamp(g_flChokeDelay[iIndex], 0.1, 9999999999.0);
					g_flChokeDuration[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Duration", 5.0);
					g_flChokeDuration[iIndex] = flClamp(g_flChokeDuration[iIndex], 0.1, 9999999999.0);
					g_flChokeHeight[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Height", 300.0);
					g_flChokeHeight[iIndex] = flClamp(g_flChokeHeight[iIndex], 0.1, 9999999999.0);
					g_iChokeHit[iIndex] = kvSuperTanks.GetNum("Choke Ability/Choke Hit", 0);
					g_iChokeHit[iIndex] = iClamp(g_iChokeHit[iIndex], 0, 1);
					g_iChokeHitMode[iIndex] = kvSuperTanks.GetNum("Choke Ability/Choke Hit Mode", 0);
					g_iChokeHitMode[iIndex] = iClamp(g_iChokeHitMode[iIndex], 0, 2);
					g_flChokeRange[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Range", 150.0);
					g_flChokeRange[iIndex] = flClamp(g_flChokeRange[iIndex], 1.0, 9999999999.0);
					g_flChokeRangeChance[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Range Chance", 15.0);
					g_flChokeRangeChance[iIndex] = flClamp(g_flChokeRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Choke Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Choke Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 1, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iChokeAbility2[iIndex] = kvSuperTanks.GetNum("Choke Ability/Ability Enabled", g_iChokeAbility[iIndex]);
					g_iChokeAbility2[iIndex] = iClamp(g_iChokeAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Choke Ability/Ability Effect", g_sChokeEffect2[iIndex], sizeof(g_sChokeEffect2[]), g_sChokeEffect[iIndex]);
					kvSuperTanks.GetString("Choke Ability/Ability Message", g_sChokeMessage2[iIndex], sizeof(g_sChokeMessage2[]), g_sChokeMessage[iIndex]);
					g_flChokeChance2[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Chance", g_flChokeChance[iIndex]);
					g_flChokeChance2[iIndex] = flClamp(g_flChokeChance2[iIndex], 0.0, 100.0);
					g_flChokeDamage2[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Damage", g_flChokeDamage[iIndex]);
					g_flChokeDamage2[iIndex] = flClamp(g_flChokeDamage2[iIndex], 1.0, 9999999999.0);
					g_flChokeDelay2[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Delay", g_flChokeDelay[iIndex]);
					g_flChokeDelay2[iIndex] = flClamp(g_flChokeDelay2[iIndex], 0.1, 9999999999.0);
					g_flChokeDuration2[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Duration", g_flChokeDuration[iIndex]);
					g_flChokeDuration2[iIndex] = flClamp(g_flChokeDuration2[iIndex], 0.1, 9999999999.0);
					g_flChokeHeight2[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Height", g_flChokeHeight[iIndex]);
					g_flChokeHeight2[iIndex] = flClamp(g_flChokeHeight2[iIndex], 0.1, 9999999999.0);
					g_iChokeHit2[iIndex] = kvSuperTanks.GetNum("Choke Ability/Choke Hit", g_iChokeHit[iIndex]);
					g_iChokeHit2[iIndex] = iClamp(g_iChokeHit2[iIndex], 0, 1);
					g_iChokeHitMode2[iIndex] = kvSuperTanks.GetNum("Choke Ability/Choke Hit Mode", g_iChokeHitMode[iIndex]);
					g_iChokeHitMode2[iIndex] = iClamp(g_iChokeHitMode2[iIndex], 0, 2);
					g_flChokeRange2[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Range", g_flChokeRange[iIndex]);
					g_flChokeRange2[iIndex] = flClamp(g_flChokeRange2[iIndex], 1.0, 9999999999.0);
					g_flChokeRangeChance2[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Range Chance", g_flChokeRangeChance[iIndex]);
					g_flChokeRangeChance2[iIndex] = flClamp(g_flChokeRangeChance2[iIndex], 0.0, 100.0);
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
		if (bIsSurvivor(iSurvivor, "234") && g_bChoke[iSurvivor])
		{
			SetEntityMoveType(iSurvivor, MOVETYPE_WALK);
			SetEntityGravity(iSurvivor, 1.0);
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
			vRemoveChoke(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iChokeAbility(tank) == 1)
	{
		vChokeAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iChokeAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bChoke2[tank] && !g_bChoke3[tank])
				{
					vChokeAbility(tank);
				}
				else if (g_bChoke2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ChokeHuman3");
				}
				else if (g_bChoke3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ChokeHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveChoke(tank);
}

static void vChokeAbility(int tank)
{
	if (g_iChokeCount[tank] < iHumanAmmo(tank))
	{
		g_bChoke4[tank] = false;
		g_bChoke5[tank] = false;

		float flChokeRange = !g_bTankConfig[ST_TankType(tank)] ? g_flChokeRange[ST_TankType(tank)] : g_flChokeRange2[ST_TankType(tank)],
			flChokeRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flChokeRangeChance[ST_TankType(tank)] : g_flChokeRangeChance2[ST_TankType(tank)],
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
				if (flDistance <= flChokeRange)
				{
					vChokeHit(iSurvivor, tank, flChokeRangeChance, iChokeAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "ChokeHuman5");
			}
		}
	}
	else
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "ChokeAmmo");
	}
}

static void vChokeHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iChokeCount[tank] < iHumanAmmo(tank))
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bChoke[survivor])
			{
				g_bChoke[survivor] = true;
				g_iChokeOwner[survivor] = tank;

				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bChoke2[tank])
				{
					g_bChoke2[tank] = true;
					g_iChokeCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ChokeHuman", g_iChokeCount[tank], iHumanAmmo(tank));
				}

				GetClientEyeAngles(survivor, g_flChokeAngle[survivor]);

				float flChokeDelay = !g_bTankConfig[ST_TankType(tank)] ? g_flChokeDelay[ST_TankType(tank)] : g_flChokeDelay2[ST_TankType(tank)];
				DataPack dpChokeLaunch;
				CreateDataTimer(flChokeDelay, tTimerChokeLaunch, dpChokeLaunch, TIMER_FLAG_NO_MAPCHANGE);
				dpChokeLaunch.WriteCell(GetClientUserId(survivor));
				dpChokeLaunch.WriteCell(GetClientUserId(tank));
				dpChokeLaunch.WriteCell(enabled);
				dpChokeLaunch.WriteString(message);

				char sChokeEffect[4];
				sChokeEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sChokeEffect[ST_TankType(tank)] : g_sChokeEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sChokeEffect, mode);

				char sChokeMessage[3];
				sChokeMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sChokeMessage[ST_TankType(tank)] : g_sChokeMessage2[ST_TankType(tank)];
				if (StrContains(sChokeMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Choke", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bChoke2[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bChoke4[tank])
				{
					g_bChoke4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ChokeHuman2");
				}
			}
		}
		else
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bChoke5[tank])
			{
				g_bChoke5[tank] = true;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "ChokeAmmo");
			}
		}
	}
}

static void vRemoveChoke(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "24") && g_bChoke[iSurvivor] && g_iChokeOwner[iSurvivor] == tank)
		{
			g_bChoke[iSurvivor] = false;
			g_iChokeOwner[iSurvivor] = 0;
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

			g_iChokeOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bChoke[survivor] = false;
	g_iChokeOwner[survivor] = 0;

	SetEntityMoveType(survivor, MOVETYPE_WALK);
	SetEntityGravity(survivor, 1.0);

	char sChokeMessage[3];
	sChokeMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sChokeMessage[ST_TankType(tank)] : g_sChokeMessage2[ST_TankType(tank)];
	if (StrContains(sChokeMessage, message) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Choke2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bChoke[tank] = false;
	g_bChoke2[tank] = false;
	g_bChoke3[tank] = false;
	g_bChoke4[tank] = false;
	g_bChoke5[tank] = false;
	g_iChokeCount[tank] = 0;
}

static float flChokeChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flChokeChance[ST_TankType(tank)] : g_flChokeChance2[ST_TankType(tank)];
}

static float flChokeDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flChokeDuration[ST_TankType(tank)] : g_flChokeDuration2[ST_TankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static int iChokeAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iChokeAbility[ST_TankType(tank)] : g_iChokeAbility2[ST_TankType(tank)];
}

static int iChokeHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iChokeHit[ST_TankType(tank)] : g_iChokeHit2[ST_TankType(tank)];
}

static int iChokeHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iChokeHitMode[ST_TankType(tank)] : g_iChokeHitMode2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

public Action tTimerChokeLaunch(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !bIsSurvivor(iSurvivor) || !g_bChoke[iSurvivor])
	{
		g_bChoke[iSurvivor] = false;
		g_iChokeOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iChokeEnabled = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || iChokeEnabled == 0)
	{
		g_bChoke[iSurvivor] = false;
		g_iChokeOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));

	float flChokeHeight = !g_bTankConfig[ST_TankType(iTank)] ? g_flChokeHeight[ST_TankType(iTank)] : g_flChokeHeight2[ST_TankType(iTank)],
		flVelocity[3];
	flVelocity[0] = 0.0;
	flVelocity[1] = 0.0;
	flVelocity[2] = flChokeHeight;

	TeleportEntity(iSurvivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
	SetEntityGravity(iSurvivor, 0.1);

	DataPack dpChokeDamage;
	CreateDataTimer(1.0, tTimerChokeDamage, dpChokeDamage, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpChokeDamage.WriteCell(GetClientUserId(iSurvivor));
	dpChokeDamage.WriteCell(GetClientUserId(iTank));
	dpChokeDamage.WriteString(sMessage);
	dpChokeDamage.WriteCell(iChokeEnabled);
	dpChokeDamage.WriteFloat(GetEngineTime());

	return Plugin_Continue;
}

public Action tTimerChokeDamage(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bChoke[iSurvivor] = false;
		g_iChokeOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bChoke[iSurvivor])
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iChokeEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iChokeEnabled == 0 || (flTime + flChokeDuration(iTank)) < GetEngineTime())
	{
		g_bChoke2[iTank] = false;

		vReset2(iSurvivor, iTank, sMessage);

		if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bChoke3[iTank])
		{
			g_bChoke3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ChokeHuman6");

			if (g_iChokeCount[iTank] < iHumanAmmo(iTank))
			{
				CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bChoke3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	TeleportEntity(iSurvivor, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));

	SetEntityMoveType(iSurvivor, MOVETYPE_NONE);
	SetEntityGravity(iSurvivor, 1.0);

	float flChokeDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_flChokeDamage[ST_TankType(iTank)] : g_flChokeDamage2[ST_TankType(iTank)];
	vDamageEntity(iSurvivor, iTank, flChokeDamage, "16384");

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bChoke3[iTank])
	{
		g_bChoke3[iTank] = false;

		return Plugin_Stop;
	}

	g_bChoke3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ChokeHuman7");

	return Plugin_Continue;
}