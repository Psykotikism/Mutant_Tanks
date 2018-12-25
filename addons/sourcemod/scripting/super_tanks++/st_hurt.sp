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
	name = "[ST++] Hurt Ability",
	author = ST_AUTHOR,
	description = "The Super Tank repeatedly hurts survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_HURT "Hurt Ability"

bool g_bCloneInstalled, g_bHurt[MAXPLAYERS + 1], g_bHurt2[MAXPLAYERS + 1], g_bHurt3[MAXPLAYERS + 1], g_bHurt4[MAXPLAYERS + 1], g_bHurt5[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sHurtEffect[ST_MAXTYPES + 1][4], g_sHurtEffect2[ST_MAXTYPES + 1][4], g_sHurtMessage[ST_MAXTYPES + 1][3], g_sHurtMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flHurtChance[ST_MAXTYPES + 1], g_flHurtChance2[ST_MAXTYPES + 1], g_flHurtDamage[ST_MAXTYPES + 1], g_flHurtDamage2[ST_MAXTYPES + 1], g_flHurtDuration[ST_MAXTYPES + 1], g_flHurtDuration2[ST_MAXTYPES + 1], g_flHurtInterval[ST_MAXTYPES + 1], g_flHurtInterval2[ST_MAXTYPES + 1], g_flHurtRange[ST_MAXTYPES + 1], g_flHurtRange2[ST_MAXTYPES + 1], g_flHurtRangeChance[ST_MAXTYPES + 1], g_flHurtRangeChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHurtAbility[ST_MAXTYPES + 1], g_iHurtAbility2[ST_MAXTYPES + 1], g_iHurtCount[MAXPLAYERS + 1], g_iHurtHit[ST_MAXTYPES + 1], g_iHurtHit2[ST_MAXTYPES + 1], g_iHurtHitMode[ST_MAXTYPES + 1], g_iHurtHitMode2[ST_MAXTYPES + 1], g_iHurtOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Hurt Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_hurt", cmdHurtInfo, "View information about the Hurt ability.");

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

public Action cmdHurtInfo(int client, int args)
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
		case false: vHurtMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vHurtMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iHurtMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Hurt Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iHurtMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHurtAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iHurtCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "HurtDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flHurtDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vHurtMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "HurtMenu", param1);
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
	menu.AddItem(ST_MENU_HURT, ST_MENU_HURT);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_HURT, false))
	{
		vHurtMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iHurtHitMode(attacker) == 0 || iHurtHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHurtHit(victim, attacker, flHurtChance(attacker), iHurtHit(attacker), "1", "1");
			}
		}
		else if ((iHurtHitMode(victim) == 0 || iHurtHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vHurtHit(attacker, victim, flHurtChance(victim), iHurtHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iHurtAbility[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Ability Enabled", 0);
					g_iHurtAbility[iIndex] = iClamp(g_iHurtAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Hurt Ability/Ability Effect", g_sHurtEffect[iIndex], sizeof(g_sHurtEffect[]), "0");
					kvSuperTanks.GetString("Hurt Ability/Ability Message", g_sHurtMessage[iIndex], sizeof(g_sHurtMessage[]), "0");
					g_flHurtChance[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Chance", 33.3);
					g_flHurtChance[iIndex] = flClamp(g_flHurtChance[iIndex], 0.0, 100.0);
					g_flHurtDamage[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Damage", 5.0);
					g_flHurtDamage[iIndex] = flClamp(g_flHurtDamage[iIndex], 1.0, 9999999999.0);
					g_flHurtDuration[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Duration", 5.0);
					g_flHurtDuration[iIndex] = flClamp(g_flHurtDuration[iIndex], 0.1, 9999999999.0);
					g_iHurtHit[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Hit", 0);
					g_iHurtHit[iIndex] = iClamp(g_iHurtHit[iIndex], 0, 1);
					g_iHurtHitMode[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Hit Mode", 0);
					g_iHurtHitMode[iIndex] = iClamp(g_iHurtHitMode[iIndex], 0, 2);
					g_flHurtInterval[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Interval", 1.0);
					g_flHurtInterval[iIndex] = flClamp(g_flHurtInterval[iIndex], 0.1, 9999999999.0);
					g_flHurtRange[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Range", 150.0);
					g_flHurtRange[iIndex] = flClamp(g_flHurtRange[iIndex], 1.0, 9999999999.0);
					g_flHurtRangeChance[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Range Chance", 15.0);
					g_flHurtRangeChance[iIndex] = flClamp(g_flHurtRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iHurtAbility2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Ability Enabled", g_iHurtAbility[iIndex]);
					g_iHurtAbility2[iIndex] = iClamp(g_iHurtAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Hurt Ability/Ability Effect", g_sHurtEffect2[iIndex], sizeof(g_sHurtEffect2[]), g_sHurtEffect[iIndex]);
					kvSuperTanks.GetString("Hurt Ability/Ability Message", g_sHurtMessage2[iIndex], sizeof(g_sHurtMessage2[]), g_sHurtMessage[iIndex]);
					g_flHurtChance2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Chance", g_flHurtChance[iIndex]);
					g_flHurtChance2[iIndex] = flClamp(g_flHurtChance2[iIndex], 0.0, 100.0);
					g_flHurtDamage2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Damage", g_flHurtDamage[iIndex]);
					g_flHurtDamage2[iIndex] = flClamp(g_flHurtDamage2[iIndex], 1.0, 9999999999.0);
					g_flHurtDuration2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Duration", g_flHurtDuration[iIndex]);
					g_flHurtDuration2[iIndex] = flClamp(g_flHurtDuration2[iIndex], 0.1, 9999999999.0);
					g_iHurtHit2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Hit", g_iHurtHit[iIndex]);
					g_iHurtHit2[iIndex] = iClamp(g_iHurtHit2[iIndex], 0, 1);
					g_iHurtHitMode2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Hit Mode", g_iHurtHitMode[iIndex]);
					g_iHurtHitMode2[iIndex] = iClamp(g_iHurtHitMode2[iIndex], 0, 2);
					g_flHurtInterval2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Interval", g_flHurtInterval[iIndex]);
					g_flHurtInterval2[iIndex] = flClamp(g_flHurtInterval2[iIndex], 0.1, 9999999999.0);
					g_flHurtRange2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Range", g_flHurtRange[iIndex]);
					g_flHurtRange2[iIndex] = flClamp(g_flHurtRange2[iIndex], 1.0, 9999999999.0);
					g_flHurtRangeChance2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Range Chance", g_flHurtRangeChance[iIndex]);
					g_flHurtRangeChance2[iIndex] = flClamp(g_flHurtRangeChance2[iIndex], 0.0, 100.0);
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
		if (ST_TankAllowed(iTank, "024") && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveHurt(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iHurtAbility(tank) == 1)
	{
		vHurtAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iHurtAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bHurt2[tank] && !g_bHurt3[tank])
				{
					vHurtAbility(tank);
				}
				else if (g_bHurt2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "HurtHuman3");
				}
				else if (g_bHurt3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "HurtHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveHurt(tank);
}

static void vHurtAbility(int tank)
{
	if (g_iHurtCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bHurt4[tank] = false;
		g_bHurt5[tank] = false;

		float flHurtRange = !g_bTankConfig[ST_TankType(tank)] ? g_flHurtRange[ST_TankType(tank)] : g_flHurtRange2[ST_TankType(tank)],
			flHurtRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flHurtRangeChance[ST_TankType(tank)] : g_flHurtRangeChance2[ST_TankType(tank)],
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
				if (flDistance <= flHurtRange)
				{
					vHurtHit(iSurvivor, tank, flHurtRangeChance, iHurtAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "HurtHuman5");
			}
		}
	}
	else
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "HurtAmmo");
	}
}

static void vHurtHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iHurtCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bHurt[survivor])
			{
				g_bHurt[survivor] = true;
				g_iHurtOwner[survivor] = tank;

				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bHurt2[tank])
				{
					g_bHurt2[tank] = true;
					g_iHurtCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "HurtHuman", g_iHurtCount[tank], iHumanAmmo(tank));
				}

				float flHurtInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flHurtInterval[ST_TankType(tank)] : g_flHurtInterval2[ST_TankType(tank)];
				DataPack dpHurt;
				CreateDataTimer(flHurtInterval, tTimerHurt, dpHurt, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpHurt.WriteCell(GetClientUserId(survivor));
				dpHurt.WriteCell(GetClientUserId(tank));
				dpHurt.WriteString(message);
				dpHurt.WriteCell(enabled);
				dpHurt.WriteFloat(GetEngineTime());

				char sHurtEffect[4];
				sHurtEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sHurtEffect[ST_TankType(tank)] : g_sHurtEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sHurtEffect, mode);

				char sHurtMessage[3];
				sHurtMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sHurtMessage[ST_TankType(tank)] : g_sHurtMessage2[ST_TankType(tank)];
				if (StrContains(sHurtMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Hurt", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bHurt2[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bHurt4[tank])
				{
					g_bHurt4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "HurtHuman2");
				}
			}
		}
		else
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bHurt5[tank])
			{
				g_bHurt5[tank] = true;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "HurtAmmo");
			}
		}
	}
}

static void vRemoveHurt(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, "234") && g_bHurt[iSurvivor] && g_iHurtOwner[iSurvivor] == tank)
		{
			g_bHurt[iSurvivor] = false;
			g_iHurtOwner[iSurvivor] = 0;
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

			g_iHurtOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bHurt[survivor] = false;
	g_iHurtOwner[survivor] = 0;

	char sHurtMessage[3];
	sHurtMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sHurtMessage[ST_TankType(tank)] : g_sHurtMessage2[ST_TankType(tank)];
	if (StrContains(sHurtMessage, message) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Hurt2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bHurt[tank] = false;
	g_bHurt2[tank] = false;
	g_bHurt3[tank] = false;
	g_bHurt4[tank] = false;
	g_bHurt5[tank] = false;
	g_iHurtCount[tank] = 0;
}

static float flHurtChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHurtChance[ST_TankType(tank)] : g_flHurtChance2[ST_TankType(tank)];
}

static float flHurtDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHurtDuration[ST_TankType(tank)] : g_flHurtDuration2[ST_TankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iHurtAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHurtAbility[ST_TankType(tank)] : g_iHurtAbility2[ST_TankType(tank)];
}

static int iHurtHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHurtHit[ST_TankType(tank)] : g_iHurtHit2[ST_TankType(tank)];
}

static int iHurtHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHurtHitMode[ST_TankType(tank)] : g_iHurtHitMode2[ST_TankType(tank)];
}

public Action tTimerHurt(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bHurt[iSurvivor] = false;
		g_iHurtOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bHurt[iSurvivor])
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iHurtEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iHurtEnabled == 0 || (flTime + flHurtDuration(iTank)) < GetEngineTime())
	{
		g_bHurt2[iTank] = false;

		vReset2(iSurvivor, iTank, sMessage);

		if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bHurt3[iTank])
		{
			g_bHurt3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "HurtHuman6");

			if (g_iHurtCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
			{
				CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bHurt3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	float flHurtDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_flHurtDamage[ST_TankType(iTank)] : g_flHurtDamage2[ST_TankType(iTank)];
	vDamageEntity(iSurvivor, iTank, flHurtDamage);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bHurt3[iTank])
	{
		g_bHurt3[iTank] = false;

		return Plugin_Stop;
	}

	g_bHurt3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "HurtHuman7");

	return Plugin_Continue;
}