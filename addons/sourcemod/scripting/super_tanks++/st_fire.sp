/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2019  Alfred "Crasher_3637/Psyk0tik" Llagas
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
	name = "[ST++] Fire Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates fires.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Fire Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"

#define ST_MENU_FIRE "Fire Ability"

bool g_bFire[MAXPLAYERS + 1], g_bFire2[MAXPLAYERS + 1], g_bFire3[MAXPLAYERS + 1], g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1];

float g_flFireChance[ST_MAXTYPES + 1], g_flFireChance2[ST_MAXTYPES + 1], g_flFireRange[ST_MAXTYPES + 1], g_flFireRange2[ST_MAXTYPES + 1], g_flFireRangeChance[ST_MAXTYPES + 1], g_flFireRangeChance2[ST_MAXTYPES + 1], g_flFireRockChance[ST_MAXTYPES + 1], g_flFireRockChance2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

int g_iFireAbility[ST_MAXTYPES + 1], g_iFireAbility2[ST_MAXTYPES + 1], g_iFireCount[MAXPLAYERS + 1], g_iFireEffect[ST_MAXTYPES + 1], g_iFireEffect2[ST_MAXTYPES + 1], g_iFireHit[ST_MAXTYPES + 1], g_iFireHit2[ST_MAXTYPES + 1], g_iFireHitMode[ST_MAXTYPES + 1], g_iFireHitMode2[ST_MAXTYPES + 1], g_iFireMessage[ST_MAXTYPES + 1], g_iFireMessage2[ST_MAXTYPES + 1], g_iFireRockBreak[ST_MAXTYPES + 1], g_iFireRockBreak2[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_fire", cmdFireInfo, "View information about the Fire ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	PrecacheModel(MODEL_GASCAN, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveFire(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdFireInfo(int client, int args)
{
	if (!ST_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Super Tanks++\x01 is disabled.", ST_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", ST_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", ST_TAG2, "Vote in Progress");
		case false: vFireMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vFireMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iFireMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Fire Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iFireMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iFireAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iFireCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "FireDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vFireMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "FireMenu", param1);
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
	menu.AddItem(ST_MENU_FIRE, ST_MENU_FIRE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_FIRE, false))
	{
		vFireMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && (iFireHitMode(attacker) == 0 || iFireHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vFireHit(victim, attacker, flFireChance(attacker), iFireHit(attacker), ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && (iFireHitMode(victim) == 0 || iFireHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vFireHit(attacker, victim, flFireChance(victim), iFireHit(victim), ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Fire Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Fire Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iFireAbility[iIndex] = kvSuperTanks.GetNum("Fire Ability/Ability Enabled", 0);
					g_iFireAbility[iIndex] = iClamp(g_iFireAbility[iIndex], 0, 1);
					g_iFireEffect[iIndex] = kvSuperTanks.GetNum("Fire Ability/Ability Effect", 0);
					g_iFireEffect[iIndex] = iClamp(g_iFireEffect[iIndex], 0, 7);
					g_iFireMessage[iIndex] = kvSuperTanks.GetNum("Fire Ability/Ability Message", 0);
					g_iFireMessage[iIndex] = iClamp(g_iFireMessage[iIndex], 0, 7);
					g_flFireChance[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Chance", 33.3);
					g_flFireChance[iIndex] = flClamp(g_flFireChance[iIndex], 0.0, 100.0);
					g_iFireHit[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Hit", 0);
					g_iFireHit[iIndex] = iClamp(g_iFireHit[iIndex], 0, 1);
					g_iFireHitMode[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Hit Mode", 0);
					g_iFireHitMode[iIndex] = iClamp(g_iFireHitMode[iIndex], 0, 2);
					g_flFireRange[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Range", 150.0);
					g_flFireRange[iIndex] = flClamp(g_flFireRange[iIndex], 1.0, 9999999999.0);
					g_flFireRangeChance[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Range Chance", 15.0);
					g_flFireRangeChance[iIndex] = flClamp(g_flFireRangeChance[iIndex], 0.0, 100.0);
					g_iFireRockBreak[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Rock Break", 0);
					g_iFireRockBreak[iIndex] = iClamp(g_iFireRockBreak[iIndex], 0, 1);
					g_flFireRockChance[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Rock Chance", 33.3);
					g_flFireRockChance[iIndex] = flClamp(g_flFireRockChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iFireAbility2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Ability Enabled", g_iFireAbility[iIndex]);
					g_iFireAbility2[iIndex] = iClamp(g_iFireAbility2[iIndex], 0, 1);
					g_iFireEffect2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Ability Effect", g_iFireEffect[iIndex]);
					g_iFireEffect2[iIndex] = iClamp(g_iFireEffect2[iIndex], 0, 7);
					g_iFireMessage2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Ability Message", g_iFireMessage[iIndex]);
					g_iFireMessage2[iIndex] = iClamp(g_iFireMessage2[iIndex], 0, 7);
					g_flFireChance2[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Chance", g_flFireChance[iIndex]);
					g_flFireChance2[iIndex] = flClamp(g_flFireChance2[iIndex], 0.0, 100.0);
					g_iFireHit2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Hit", g_iFireHit[iIndex]);
					g_iFireHit2[iIndex] = iClamp(g_iFireHit2[iIndex], 0, 1);
					g_iFireHitMode2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Hit Mode", g_iFireHitMode[iIndex]);
					g_iFireHitMode2[iIndex] = iClamp(g_iFireHitMode2[iIndex], 0, 2);
					g_flFireRange2[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Range", g_flFireRange[iIndex]);
					g_flFireRange2[iIndex] = flClamp(g_flFireRange2[iIndex], 1.0, 9999999999.0);
					g_flFireRangeChance2[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Range Chance", g_flFireRangeChance[iIndex]);
					g_flFireRangeChance2[iIndex] = flClamp(g_flFireRangeChance2[iIndex], 0.0, 100.0);
					g_iFireRockBreak2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Rock Break", g_iFireRockBreak[iIndex]);
					g_iFireRockBreak2[iIndex] = iClamp(g_iFireRockBreak2[iIndex], 0, 1);
					g_flFireRockChance2[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Rock Chance", g_flFireRockChance[iIndex]);
					g_flFireRockChance2[iIndex] = flClamp(g_flFireRockChance2[iIndex], 0.0, 100.0);
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
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			if (ST_IsCloneSupported(iTank, g_bCloneInstalled) && iFireAbility(iTank) == 1)
			{
				float flPos[3];
				GetClientAbsOrigin(iTank, flPos);
				vSpecialAttack(iTank, flPos, 10.0, MODEL_GASCAN);
			}

			vRemoveFire(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iFireAbility(tank) == 1)
	{
		vFireAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iFireAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (g_bFire[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "FireHuman3");
					case false: vFireAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	if (ST_IsTankSupported(tank) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iFireAbility(tank) == 1)
	{
		float flPos[3];
		GetClientAbsOrigin(tank, flPos);
		vSpecialAttack(tank, flPos, 10.0, MODEL_GASCAN);
	}

	vRemoveFire(tank);
}

public void ST_OnRockBreak(int tank, int rock)
{
	int iFireRockBreak = !g_bTankConfig[ST_GetTankType(tank)] ? g_iFireRockBreak[ST_GetTankType(tank)] : g_iFireRockBreak2[ST_GetTankType(tank)];
	if (ST_IsTankSupported(tank) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iFireRockBreak == 1)
	{
		float flFireRockChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flFireRockChance[ST_GetTankType(tank)] : g_flFireRockChance2[ST_GetTankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flFireRockChance)
		{
			float flPos[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flPos);
			vSpecialAttack(tank, flPos, 10.0, MODEL_GASCAN);

			if (iFireMessage(tank) & ST_MESSAGE_SPECIAL)
			{
				char sTankName[33];
				ST_GetTankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Fire2", sTankName);
			}
		}
	}
}

static void vFireAbility(int tank)
{
	if (g_iFireCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bFire2[tank] = false;
		g_bFire3[tank] = false;

		float flFireRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flFireRange[ST_GetTankType(tank)] : g_flFireRange2[ST_GetTankType(tank)],
			flFireRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flFireRangeChance[ST_GetTankType(tank)] : g_flFireRangeChance2[ST_GetTankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flFireRange)
				{
					vFireHit(iSurvivor, tank, flFireRangeChance, iFireAbility(tank), ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "FireHuman4");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "FireAmmo");
	}
}

static void vFireHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iFireCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && (flags & ST_ATTACK_RANGE) && !g_bFire[tank])
				{
					g_bFire[tank] = true;
					g_iFireCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "FireHuman", g_iFireCount[tank], iHumanAmmo(tank));

					if (g_iFireCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
					{
						CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bFire[tank] = false;
					}
				}

				float flPos[3];
				GetClientAbsOrigin(survivor, flPos);
				vSpecialAttack(tank, flPos, 10.0, MODEL_GASCAN);

				int iFireEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_iFireEffect[ST_GetTankType(tank)] : g_iFireEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, iFireEffect, flags);

				if (iFireMessage(tank) & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Fire", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bFire[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && !g_bFire2[tank])
				{
					g_bFire2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "FireHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && !g_bFire3[tank])
		{
			g_bFire3[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "FireAmmo");
		}
	}
}

static void vRemoveFire(int tank)
{
	g_bFire[tank] = false;
	g_bFire2[tank] = false;
	g_bFire3[tank] = false;
	g_iFireCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveFire(iPlayer);
		}
	}
}

static float flFireChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flFireChance[ST_GetTankType(tank)] : g_flFireChance2[ST_GetTankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static int iFireAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iFireAbility[ST_GetTankType(tank)] : g_iFireAbility2[ST_GetTankType(tank)];
}

static int iFireHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iFireHit[ST_GetTankType(tank)] : g_iFireHit2[ST_GetTankType(tank)];
}

static int iFireHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iFireHitMode[ST_GetTankType(tank)] : g_iFireHitMode2[ST_GetTankType(tank)];
}

static int iFireMessage(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iFireMessage[ST_GetTankType(tank)] : g_iFireMessage2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bFire[iTank])
	{
		g_bFire[iTank] = false;

		return Plugin_Stop;
	}

	g_bFire[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "FireHuman5");

	return Plugin_Continue;
}