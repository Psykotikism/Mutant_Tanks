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
	name = "[ST++] Whirl Ability",
	author = ST_AUTHOR,
	description = "The Super Tank makes survivors' screens whirl.",
	version = ST_VERSION,
	url = ST_URL
};

#define SPRITE_DOT "sprites/dot.vmt"

#define ST_MENU_WHIRL "Whirl Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1], g_bWhirl[MAXPLAYERS + 1], g_bWhirl2[MAXPLAYERS + 1], g_bWhirl3[MAXPLAYERS + 1], g_bWhirl4[MAXPLAYERS + 1], g_bWhirl5[MAXPLAYERS + 1];

char g_sWhirlAxis[ST_MAXTYPES + 1][7], g_sWhirlAxis2[ST_MAXTYPES + 1][7], g_sWhirlEffect[ST_MAXTYPES + 1][4], g_sWhirlEffect2[ST_MAXTYPES + 1][4], g_sWhirlMessage[ST_MAXTYPES + 1][3], g_sWhirlMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flWhirlChance[ST_MAXTYPES + 1], g_flWhirlChance2[ST_MAXTYPES + 1], g_flWhirlDuration[ST_MAXTYPES + 1], g_flWhirlDuration2[ST_MAXTYPES + 1], g_flWhirlRange[ST_MAXTYPES + 1], g_flWhirlRange2[ST_MAXTYPES + 1], g_flWhirlSpeed[ST_MAXTYPES + 1], g_flWhirlSpeed2[ST_MAXTYPES + 1], g_flWhirlRangeChance[ST_MAXTYPES + 1], g_flWhirlRangeChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iWhirlAbility[ST_MAXTYPES + 1], g_iWhirlAbility2[ST_MAXTYPES + 1], g_iWhirlCount[MAXPLAYERS + 1], g_iWhirlHit[ST_MAXTYPES + 1], g_iWhirlHit2[ST_MAXTYPES + 1], g_iWhirlHitMode[ST_MAXTYPES + 1], g_iWhirlHitMode2[ST_MAXTYPES + 1], g_iWhirlOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Whirl Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_whirl", cmdWhirlInfo, "View information about the Whirl ability.");

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
	PrecacheModel(SPRITE_DOT, true);

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

public Action cmdWhirlInfo(int client, int args)
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
		case false: vWhirlMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vWhirlMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iWhirlMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Whirl Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iWhirlMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iWhirlAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iWhirlCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "WhirlDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flWhirlDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vWhirlMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "WhirlMenu", param1);
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
	menu.AddItem(ST_MENU_WHIRL, ST_MENU_WHIRL);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_WHIRL, false))
	{
		vWhirlMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iWhirlHitMode(attacker) == 0 || iWhirlHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsHumanSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vWhirlHit(victim, attacker, flWhirlChance(attacker), iWhirlHit(attacker), "1", "1");
			}
		}
		else if ((iWhirlHitMode(victim) == 0 || iWhirlHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vWhirlHit(attacker, victim, flWhirlChance(victim), iWhirlHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 1, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iWhirlAbility[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Ability Enabled", 0);
					g_iWhirlAbility[iIndex] = iClamp(g_iWhirlAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Whirl Ability/Ability Effect", g_sWhirlEffect[iIndex], sizeof(g_sWhirlEffect[]), "0");
					kvSuperTanks.GetString("Whirl Ability/Ability Message", g_sWhirlMessage[iIndex], sizeof(g_sWhirlMessage[]), "0");
					kvSuperTanks.GetString("Whirl Ability/Whirl Axis", g_sWhirlAxis[iIndex], sizeof(g_sWhirlAxis[]), "123");
					g_flWhirlChance[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Chance", 33.3);
					g_flWhirlChance[iIndex] = flClamp(g_flWhirlChance[iIndex], 0.0, 100.0);
					g_flWhirlDuration[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Duration", 5.0);
					g_flWhirlDuration[iIndex] = flClamp(g_flWhirlDuration[iIndex], 0.1, 9999999999.0);
					g_iWhirlHit[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Whirl Hit", 0);
					g_iWhirlHit[iIndex] = iClamp(g_iWhirlHit[iIndex], 0, 1);
					g_iWhirlHitMode[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Whirl Hit Mode", 0);
					g_iWhirlHitMode[iIndex] = iClamp(g_iWhirlHitMode[iIndex], 0, 2);
					g_flWhirlRange[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Range", 150.0);
					g_flWhirlRange[iIndex] = flClamp(g_flWhirlRange[iIndex], 1.0, 9999999999.0);
					g_flWhirlRangeChance[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Range Chance", 15.0);
					g_flWhirlRangeChance[iIndex] = flClamp(g_flWhirlRangeChance[iIndex], 0.0, 100.0);
					g_flWhirlSpeed[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Speed", 500.0);
					g_flWhirlSpeed[iIndex] = flClamp(g_flWhirlSpeed[iIndex], 1.0, 9999999999.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 1, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iWhirlAbility2[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Ability Enabled", g_iWhirlAbility[iIndex]);
					g_iWhirlAbility2[iIndex] = iClamp(g_iWhirlAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Whirl Ability/Ability Effect", g_sWhirlEffect2[iIndex], sizeof(g_sWhirlEffect2[]), g_sWhirlEffect[iIndex]);
					kvSuperTanks.GetString("Whirl Ability/Ability Message", g_sWhirlMessage2[iIndex], sizeof(g_sWhirlMessage2[]), g_sWhirlMessage[iIndex]);
					kvSuperTanks.GetString("Whirl Ability/Whirl Axis", g_sWhirlAxis2[iIndex], sizeof(g_sWhirlAxis2[]), g_sWhirlAxis[iIndex]);
					g_flWhirlChance2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Chance", g_flWhirlChance[iIndex]);
					g_flWhirlChance2[iIndex] = flClamp(g_flWhirlChance2[iIndex], 0.0, 100.0);
					g_flWhirlDuration2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Duration", g_flWhirlDuration[iIndex]);
					g_flWhirlDuration2[iIndex] = flClamp(g_flWhirlDuration2[iIndex], 0.1, 9999999999.0);
					g_iWhirlHit2[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Whirl Hit", g_iWhirlHit[iIndex]);
					g_iWhirlHit2[iIndex] = iClamp(g_iWhirlHit2[iIndex], 0, 1);
					g_iWhirlHitMode2[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Whirl Hit Mode", g_iWhirlHitMode[iIndex]);
					g_iWhirlHitMode2[iIndex] = iClamp(g_iWhirlHitMode2[iIndex], 0, 2);
					g_flWhirlRange2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Range", g_flWhirlRange[iIndex]);
					g_flWhirlRange2[iIndex] = flClamp(g_flWhirlRange2[iIndex], 1.0, 9999999999.0);
					g_flWhirlRangeChance2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Range Chance", g_flWhirlRangeChance[iIndex]);
					g_flWhirlRangeChance2[iIndex] = flClamp(g_flWhirlRangeChance2[iIndex], 0.0, 100.0);
					g_flWhirlSpeed2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Speed", g_flWhirlSpeed[iIndex]);
					g_flWhirlSpeed2[iIndex] = flClamp(g_flWhirlSpeed2[iIndex], 1.0, 9999999999.0);
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
		if (bIsHumanSurvivor(iSurvivor, "234") && g_bWhirl[iSurvivor])
		{
			SetClientViewEntity(iSurvivor, iSurvivor);
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
			vRemoveWhirl(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iWhirlAbility(tank) == 1)
	{
		vWhirlAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iWhirlAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bWhirl2[tank] && !g_bWhirl3[tank])
				{
					vWhirlAbility(tank);
				}
				else if (g_bWhirl2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WhirlHuman3");
				}
				else if (g_bWhirl3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WhirlHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveWhirl(tank);
}

static void vWhirlAbility(int tank)
{
	if (g_iWhirlCount[tank] < iHumanAmmo(tank))
	{
		g_bWhirl4[tank] = false;
		g_bWhirl5[tank] = false;

		float flWhirlRange = !g_bTankConfig[ST_TankType(tank)] ? g_flWhirlRange[ST_TankType(tank)] : g_flWhirlRange2[ST_TankType(tank)],
			flWhirlRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flWhirlRangeChance[ST_TankType(tank)] : g_flWhirlRangeChance2[ST_TankType(tank)],
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
				if (flDistance <= flWhirlRange)
				{
					vWhirlHit(iSurvivor, tank, flWhirlRangeChance, iWhirlAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "WhirlHuman5");
			}
		}
	}
	else
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "WhirlAmmo");
	}
}

static void vRemoveWhirl(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, "234") && g_bWhirl[iSurvivor] && g_iWhirlOwner[iSurvivor] == tank)
		{
			g_bWhirl[iSurvivor] = false;
			g_iWhirlOwner[iSurvivor] = 0;
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

			g_iWhirlOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int camera, const char[] message)
{
	vStopWhirl(survivor, camera);

	SetClientViewEntity(survivor, survivor);

	char sWhirlMessage[3];
	sWhirlMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sWhirlMessage[ST_TankType(tank)] : g_sWhirlMessage2[ST_TankType(tank)];
	if (StrContains(sWhirlMessage, message) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Whirl2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bWhirl[tank] = false;
	g_bWhirl2[tank] = false;
	g_bWhirl3[tank] = false;
	g_bWhirl4[tank] = false;
	g_bWhirl5[tank] = false;
	g_iWhirlCount[tank] = 0;
}

static void vStopWhirl(int survivor, int camera)
{
	g_bWhirl[survivor] = false;
	g_iWhirlOwner[survivor] = 0;

	RemoveEntity(camera);
}

static void vWhirlHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iWhirlCount[tank] < iHumanAmmo(tank))
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bWhirl[survivor])
			{
				int iCamera = CreateEntityByName("env_sprite");
				if (!bIsValidEntity(iCamera))
				{
					return;
				}

				g_bWhirl[survivor] = true;
				g_iWhirlOwner[survivor] = tank;

				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bWhirl2[tank])
				{
					g_bWhirl2[tank] = true;
					g_iWhirlCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WhirlHuman", g_iWhirlCount[tank], iHumanAmmo(tank));
				}

				float flEyePos[3], flAngles[3];
				GetClientEyePosition(survivor, flEyePos);
				GetClientEyeAngles(survivor, flAngles);

				SetEntityModel(iCamera, SPRITE_DOT);
				SetEntityRenderMode(iCamera, RENDER_TRANSCOLOR);
				SetEntityRenderColor(iCamera, 0, 0, 0, 0);
				DispatchSpawn(iCamera);

				TeleportEntity(iCamera, flEyePos, flAngles, NULL_VECTOR);
				TeleportEntity(survivor, NULL_VECTOR, flAngles, NULL_VECTOR);

				vSetEntityParent(iCamera, survivor);
				SetClientViewEntity(survivor, iCamera);

				char sNumbers = !g_bTankConfig[ST_TankType(tank)] ? g_sWhirlAxis[ST_TankType(tank)][GetRandomInt(0, strlen(g_sWhirlAxis[ST_TankType(tank)]) - 1)] : g_sWhirlAxis2[ST_TankType(tank)][GetRandomInt(0, strlen(g_sWhirlAxis2[ST_TankType(tank)]) - 1)];
				int iAxis;
				switch (sNumbers)
				{
					case '1': iAxis = 0;
					case '2': iAxis = 1;
					case '3': iAxis = 2;
					default: iAxis = GetRandomInt(0, 2);
				}

				DataPack dpWhirl;
				CreateDataTimer(0.1, tTimerWhirl, dpWhirl, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpWhirl.WriteCell(EntIndexToEntRef(iCamera));
				dpWhirl.WriteCell(GetClientUserId(survivor));
				dpWhirl.WriteCell(GetClientUserId(tank));
				dpWhirl.WriteString(message);
				dpWhirl.WriteCell(enabled);
				dpWhirl.WriteCell(iAxis);
				dpWhirl.WriteFloat(GetEngineTime());

				char sWhirlEffect[4];
				sWhirlEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sWhirlEffect[ST_TankType(tank)] : g_sWhirlEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sWhirlEffect, mode);

				char sWhirlMessage[3];
				sWhirlMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sWhirlMessage[ST_TankType(tank)] : g_sWhirlMessage2[ST_TankType(tank)];
				if (StrContains(sWhirlMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Whirl", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bWhirl2[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bWhirl4[tank])
				{
					g_bWhirl4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WhirlHuman2");
				}
			}
		}
		else
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bWhirl5[tank])
			{
				g_bWhirl5[tank] = true;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "WhirlAmmo");
			}
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flWhirlChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flWhirlChance[ST_TankType(tank)] : g_flWhirlChance2[ST_TankType(tank)];
}

static float flWhirlDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flWhirlDuration[ST_TankType(tank)] : g_flWhirlDuration2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iWhirlAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWhirlAbility[ST_TankType(tank)] : g_iWhirlAbility2[ST_TankType(tank)];
}

static int iWhirlHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWhirlHit[ST_TankType(tank)] : g_iWhirlHit2[ST_TankType(tank)];
}

static int iWhirlHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWhirlHitMode[ST_TankType(tank)] : g_iWhirlHitMode2[ST_TankType(tank)];
}

public Action tTimerWhirl(Handle timer, DataPack pack)
{
	pack.Reset();

	int iCamera = EntRefToEntIndex(pack.ReadCell()), iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || iCamera == INVALID_ENT_REFERENCE || !bIsValidEntity(iCamera))
	{
		g_bWhirl[iSurvivor] = false;
		g_iWhirlOwner[iSurvivor] = 0;

		SetClientViewEntity(iSurvivor, iSurvivor);

		return Plugin_Stop;
	}

	if (!bIsHumanSurvivor(iSurvivor))
	{
		vStopWhirl(iSurvivor, iCamera);

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bWhirl[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iCamera, sMessage);

		return Plugin_Stop;
	}

	int iWhirlEnabled = pack.ReadCell(), iWhirlAxis = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iWhirlEnabled == 0 || (flTime + flWhirlDuration(iTank)) < GetEngineTime())
	{
		g_bWhirl2[iTank] = false;

		vReset2(iSurvivor, iTank, iCamera, sMessage);

		if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bWhirl3[iTank])
		{
			g_bWhirl3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "WhirlHuman6");

			if (g_iWhirlCount[iTank] < iHumanAmmo(iTank))
			{
				CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bWhirl3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	float flWhirlSpeed = !g_bTankConfig[ST_TankType(iTank)] ? g_flWhirlSpeed[ST_TankType(iTank)] : g_flWhirlSpeed2[ST_TankType(iTank)],
		flAngles[3];
	GetEntPropVector(iCamera, Prop_Send, "m_angRotation", flAngles);

	flAngles[iWhirlAxis] += flWhirlSpeed;
	TeleportEntity(iCamera, NULL_VECTOR, flAngles, NULL_VECTOR);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bWhirl3[iTank])
	{
		g_bWhirl3[iTank] = false;

		return Plugin_Stop;
	}

	g_bWhirl3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "WhirlHuman7");

	return Plugin_Continue;
}