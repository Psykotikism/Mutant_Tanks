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
	name = "[ST++] Electric Ability",
	author = ST_AUTHOR,
	description = "The Super Tank electrocutes survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define PARTICLE_ELECTRICITY "electrical_arc_01_system"

#define SOUND_ELECTRICITY "ambient/energy/zap5.wav"
#define SOUND_ELECTRICITY2 "ambient/energy/zap7.wav"

#define ST_MENU_ELECTRIC "Electric Ability"

bool g_bCloneInstalled, g_bElectric[MAXPLAYERS + 1], g_bElectric2[MAXPLAYERS + 1], g_bElectric3[MAXPLAYERS + 1], g_bElectric4[MAXPLAYERS + 1], g_bElectric5[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sElectricEffect[ST_MAXTYPES + 1][4], g_sElectricEffect2[ST_MAXTYPES + 1][4], g_sElectricMessage[ST_MAXTYPES + 1][3], g_sElectricMessage2[ST_MAXTYPES + 1][3];

float g_flElectricChance[ST_MAXTYPES + 1], g_flElectricChance2[ST_MAXTYPES + 1], g_flElectricDamage[ST_MAXTYPES + 1], g_flElectricDamage2[ST_MAXTYPES + 1], g_flElectricDuration[ST_MAXTYPES + 1], g_flElectricDuration2[ST_MAXTYPES + 1], g_flElectricInterval[ST_MAXTYPES + 1], g_flElectricInterval2[ST_MAXTYPES + 1], g_flElectricRange[ST_MAXTYPES + 1], g_flElectricRange2[ST_MAXTYPES + 1], g_flElectricRangeChance[ST_MAXTYPES + 1], g_flElectricRangeChance2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

int g_iElectricAbility[ST_MAXTYPES + 1], g_iElectricAbility2[ST_MAXTYPES + 1], g_iElectricCount[MAXPLAYERS + 1], g_iElectricHit[ST_MAXTYPES + 1], g_iElectricHit2[ST_MAXTYPES + 1], g_iElectricHitMode[ST_MAXTYPES + 1], g_iElectricHitMode2[ST_MAXTYPES + 1], g_iElectricOwner[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Electric Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_electric", cmdElectricInfo, "View information about the Electric ability.");

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

	vReset3(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdElectricInfo(int client, int args)
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
		case false: vElectricMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vElectricMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iElectricMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Electric Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iElectricMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iElectricAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iElectricCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "ElectricDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flElectricDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vElectricMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "ElectricMenu", param1);
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
	menu.AddItem(ST_MENU_ELECTRIC, ST_MENU_ELECTRIC);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_ELECTRIC, false))
	{
		vElectricMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iElectricHitMode(attacker) == 0 || iElectricHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vElectricHit(victim, attacker, flElectricChance(attacker), iElectricHit(attacker), "1", "1");
			}
		}
		else if ((iElectricHitMode(victim) == 0 || iElectricHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vElectricHit(attacker, victim, flElectricChance(victim), iElectricHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Electric Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Electric Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iElectricAbility[iIndex] = kvSuperTanks.GetNum("Electric Ability/Ability Enabled", 0);
					g_iElectricAbility[iIndex] = iClamp(g_iElectricAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Electric Ability/Ability Effect", g_sElectricEffect[iIndex], sizeof(g_sElectricEffect[]), "0");
					kvSuperTanks.GetString("Electric Ability/Ability Message", g_sElectricMessage[iIndex], sizeof(g_sElectricMessage[]), "0");
					g_flElectricChance[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Chance", 33.3);
					g_flElectricChance[iIndex] = flClamp(g_flElectricChance[iIndex], 0.0, 100.0);
					g_flElectricDamage[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Damage", 1.0);
					g_flElectricDamage[iIndex] = flClamp(g_flElectricDamage[iIndex], 1.0, 9999999999.0);
					g_flElectricDuration[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Duration", 5.0);
					g_flElectricDuration[iIndex] = flClamp(g_flElectricDuration[iIndex], 0.1, 9999999999.0);
					g_iElectricHit[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Hit", 0);
					g_iElectricHit[iIndex] = iClamp(g_iElectricHit[iIndex], 0, 1);
					g_iElectricHitMode[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Hit Mode", 0);
					g_iElectricHitMode[iIndex] = iClamp(g_iElectricHitMode[iIndex], 0, 2);
					g_flElectricInterval[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Interval", 1.0);
					g_flElectricInterval[iIndex] = flClamp(g_flElectricInterval[iIndex], 0.1, 9999999999.0);
					g_flElectricRange[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Range", 150.0);
					g_flElectricRange[iIndex] = flClamp(g_flElectricRange[iIndex], 1.0, 9999999999.0);
					g_flElectricRangeChance[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Range Chance", 15.0);
					g_flElectricRangeChance[iIndex] = flClamp(g_flElectricRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iElectricAbility2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Ability Enabled", g_iElectricAbility[iIndex]);
					g_iElectricAbility2[iIndex] = iClamp(g_iElectricAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Electric Ability/Ability Effect", g_sElectricEffect2[iIndex], sizeof(g_sElectricEffect2[]), g_sElectricEffect[iIndex]);
					kvSuperTanks.GetString("Electric Ability/Ability Message", g_sElectricMessage2[iIndex], sizeof(g_sElectricMessage2[]), g_sElectricMessage[iIndex]);
					g_flElectricChance2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Chance", g_flElectricChance[iIndex]);
					g_flElectricChance2[iIndex] = flClamp(g_flElectricChance2[iIndex], 0.0, 100.0);
					g_flElectricDamage2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Damage", g_flElectricDamage[iIndex]);
					g_flElectricDamage2[iIndex] = flClamp(g_flElectricDamage2[iIndex], 1.0, 9999999999.0);
					g_flElectricDuration2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Duration", g_flElectricDuration[iIndex]);
					g_flElectricDuration2[iIndex] = flClamp(g_flElectricDuration2[iIndex], 0.1, 9999999999.0);
					g_iElectricHit2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Hit", g_iElectricHit[iIndex]);
					g_iElectricHit2[iIndex] = iClamp(g_iElectricHit2[iIndex], 0, 1);
					g_iElectricHitMode2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Hit Mode", g_iElectricHitMode[iIndex]);
					g_iElectricHitMode2[iIndex] = iClamp(g_iElectricHitMode2[iIndex], 0, 2);
					g_flElectricInterval2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Interval", g_flElectricInterval[iIndex]);
					g_flElectricInterval2[iIndex] = flClamp(g_flElectricInterval2[iIndex], 0.1, 9999999999.0);
					g_flElectricRange2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Range", g_flElectricRange[iIndex]);
					g_flElectricRange2[iIndex] = flClamp(g_flElectricRange2[iIndex], 1.0, 9999999999.0);
					g_flElectricRangeChance2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Range Chance", g_flElectricRangeChance[iIndex]);
					g_flElectricRangeChance2[iIndex] = flClamp(g_flElectricRangeChance2[iIndex], 0.0, 100.0);
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
			if (ST_CloneAllowed(iTank, g_bCloneInstalled) && iElectricAbility(iTank) == 1)
			{
				vAttachParticle(iTank, PARTICLE_ELECTRICITY, 2.0, 30.0);
			}

			vRemoveElectric(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iElectricAbility(tank) == 1)
	{
		vElectricAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iElectricAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bElectric2[tank] && !g_bElectric3[tank])
				{
					vElectricAbility(tank);
				}
				else if (g_bElectric2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ElectricHuman3");
				}
				else if (g_bElectric3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ElectricHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveElectric(tank);
}

static void vElectricAbility(int tank)
{
	if (g_iElectricCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bElectric4[tank] = false;
		g_bElectric5[tank] = false;

		float flElectricRange = !g_bTankConfig[ST_TankType(tank)] ? g_flElectricRange[ST_TankType(tank)] : g_flElectricRange2[ST_TankType(tank)],
			flElectricRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flElectricRangeChance[ST_TankType(tank)] : g_flElectricRangeChance2[ST_TankType(tank)],
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
				if (flDistance <= flElectricRange)
				{
					vElectricHit(iSurvivor, tank, flElectricRangeChance, iElectricAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "ElectricHuman5");
			}
		}
	}
	else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "ElectricAmmo");
	}
}

static void vElectricHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iElectricCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bElectric[survivor])
			{
				g_bElectric[survivor] = true;
				g_iElectricOwner[survivor] = tank;

				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bElectric2[tank])
				{
					g_bElectric2[tank] = true;
					g_iElectricCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ElectricHuman", g_iElectricCount[tank], iHumanAmmo(tank));
				}

				float flElectricInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flElectricInterval[ST_TankType(tank)] : g_flElectricInterval2[ST_TankType(tank)];
				DataPack dpElectric;
				CreateDataTimer(flElectricInterval, tTimerElectric, dpElectric, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpElectric.WriteCell(GetClientUserId(survivor));
				dpElectric.WriteCell(GetClientUserId(tank));
				dpElectric.WriteString(message);
				dpElectric.WriteCell(enabled);
				dpElectric.WriteFloat(GetEngineTime());

				vAttachParticle(survivor, PARTICLE_ELECTRICITY, 2.0, 30.0);

				char sElectricEffect[4];
				sElectricEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sElectricEffect[ST_TankType(tank)] : g_sElectricEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sElectricEffect, mode);

				char sElectricMessage[3];
				sElectricMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sElectricMessage[ST_TankType(tank)] : g_sElectricMessage2[ST_TankType(tank)];
				if (StrContains(sElectricMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Electric", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bElectric2[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bElectric4[tank])
				{
					g_bElectric4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ElectricHuman2");
				}
			}
		}
		else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bElectric5[tank])
		{
			g_bElectric5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "ElectricAmmo");
		}
	}
}

static void vRemoveElectric(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, "234") && g_bElectric[iSurvivor] && g_iElectricOwner[iSurvivor] == tank)
		{
			g_bElectric[iSurvivor] = false;
			g_iElectricOwner[iSurvivor] = 0;
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

			g_iElectricOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bElectric[survivor] = false;
	g_iElectricOwner[survivor] = 0;

	char sElectricMessage[3];
	sElectricMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sElectricMessage[ST_TankType(tank)] : g_sElectricMessage2[ST_TankType(tank)];
	if (StrContains(sElectricMessage, message) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Electric2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bElectric[tank] = false;
	g_bElectric2[tank] = false;
	g_bElectric3[tank] = false;
	g_bElectric4[tank] = false;
	g_bElectric5[tank] = false;
	g_iElectricCount[tank] = 0;
}

static float flElectricChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flElectricChance[ST_TankType(tank)] : g_flElectricChance2[ST_TankType(tank)];
}

static float flElectricDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flElectricDuration[ST_TankType(tank)] : g_flElectricDuration2[ST_TankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static int iElectricAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iElectricAbility[ST_TankType(tank)] : g_iElectricAbility2[ST_TankType(tank)];
}

static int iElectricHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iElectricHit[ST_TankType(tank)] : g_iElectricHit2[ST_TankType(tank)];
}

static int iElectricHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iElectricHitMode[ST_TankType(tank)] : g_iElectricHitMode2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

public Action tTimerElectric(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bElectric[iSurvivor] = false;
		g_iElectricOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bElectric[iSurvivor])
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iElectricEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iElectricEnabled == 0 || (flTime + flElectricDuration(iTank)) < GetEngineTime())
	{
		g_bElectric2[iTank] = false;

		vReset2(iSurvivor, iTank, sMessage);

		if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bElectric3[iTank])
		{
			g_bElectric3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ElectricHuman6");

			if (g_iElectricCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
			{
				CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bElectric3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	float flElectricDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_flElectricDamage[ST_TankType(iTank)] : g_flElectricDamage2[ST_TankType(iTank)];
	vDamageEntity(iSurvivor, iTank, flElectricDamage, "256");

	vAttachParticle(iSurvivor, PARTICLE_ELECTRICITY, 2.0, 30.0);

	switch (GetRandomInt(1, 2))
	{
		case 1: EmitSoundToAll(SOUND_ELECTRICITY, iSurvivor);
		case 2: EmitSoundToAll(SOUND_ELECTRICITY2, iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank, "02345") || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bElectric3[iTank])
	{
		g_bElectric3[iTank] = false;

		return Plugin_Stop;
	}

	g_bElectric3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ElectricHuman7");

	return Plugin_Continue;
}