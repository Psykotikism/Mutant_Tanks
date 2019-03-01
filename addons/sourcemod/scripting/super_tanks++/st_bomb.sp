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
	name = "[ST++] Bomb Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates explosions.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Bomb Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"

#define ST_MENU_BOMB "Bomb Ability"

bool g_bBomb[MAXPLAYERS + 1], g_bBomb2[MAXPLAYERS + 1], g_bBomb3[MAXPLAYERS + 1], g_bCloneInstalled;

float g_flBombChance[ST_MAXTYPES + 1], g_flBombRange[ST_MAXTYPES + 1], g_flBombRangeChance[ST_MAXTYPES + 1], g_flBombRockChance[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1];

int g_iBombAbility[ST_MAXTYPES + 1], g_iBombCount[MAXPLAYERS + 1], g_iBombEffect[ST_MAXTYPES + 1], g_iBombHit[ST_MAXTYPES + 1], g_iBombHitMode[ST_MAXTYPES + 1], g_iBombMessage[ST_MAXTYPES + 1], g_iBombRockBreak[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_bomb", cmdBombInfo, "View information about the Bomb ability.");

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
	PrecacheModel(MODEL_PROPANETANK, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveBomb(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdBombInfo(int client, int args)
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
		case false: vBombMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vBombMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iBombMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Bomb Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iBombMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iBombAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iBombCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "BombDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vBombMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "BombMenu", param1);
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
	menu.AddItem(ST_MENU_BOMB, ST_MENU_BOMB);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_BOMB, false))
	{
		vBombMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iBombHitMode[ST_GetTankType(attacker)] == 0 || g_iBombHitMode[ST_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vBombHit(victim, attacker, g_flBombChance[ST_GetTankType(attacker)], g_iBombHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iBombHitMode[ST_GetTankType(victim)] == 0 || g_iBombHitMode[ST_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vBombHit(attacker, victim, g_flBombChance[ST_GetTankType(victim)], g_iBombHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
			}
		}
	}
}

public void ST_OnConfigsLoad()
{
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_iBombAbility[iIndex] = 0;
		g_iBombEffect[iIndex] = 0;
		g_iBombMessage[iIndex] = 0;
		g_flBombChance[iIndex] = 33.3;
		g_iBombHit[iIndex] = 0;
		g_iBombHitMode[iIndex] = 0;
		g_flBombRange[iIndex] = 150.0;
		g_flBombRangeChance[iIndex] = 15.0;
		g_iBombRockBreak[iIndex] = 0;
		g_flBombRockChance[iIndex] = 33.3;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	g_iHumanAbility[type] = iGetValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iBombAbility[type] = iGetValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iBombAbility[type], value, 0, 0, 1);
	g_iBombEffect[type] = iGetValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iBombEffect[type], value, 0, 0, 7);
	g_iBombMessage[type] = iGetValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iBombMessage[type], value, 0, 0, 7);
	g_flBombChance[type] = flGetValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombChance", "Bomb Chance", "Bomb_Chance", "chance", main, g_flBombChance[type], value, 33.3, 0.0, 100.0);
	g_iBombHit[type] = iGetValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombHit", "Bomb Hit", "Bomb_Hit", "hit", main, g_iBombHit[type], value, 0, 0, 1);
	g_iBombHitMode[type] = iGetValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombHitMode", "Bomb Hit Mode", "Bomb_Hit_Mode", "hitmode", main, g_iBombHitMode[type], value, 0, 0, 2);
	g_flBombRange[type] = flGetValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombRange", "Bomb Range", "Bomb_Range", "range", main, g_flBombRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flBombRangeChance[type] = flGetValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombRangeChance", "Bomb Range Chance", "Bomb_Range_Chance", "rangechance", main, g_flBombRangeChance[type], value, 15.0, 0.0, 100.0);
	g_iBombRockBreak[type] = iGetValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombRockBreak", "Bomb Rock Break", "Bomb_Rock_Break", "rock", main, g_iBombRockBreak[type], value, 0, 0, 1);
	g_flBombRockChance[type] = flGetValue(subsection, "bombability", "bomb ability", "bomb_ability", "bomb", key, "BombRockChance", "Bomb Rock Chance", "Bomb_Rock_Chance", "rockchance", main, g_flBombRockChance[type], value, 33.3, 0.0, 100.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			if (bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iBombAbility[ST_GetTankType(iTank)] == 1)
			{
				float flPos[3];
				GetClientAbsOrigin(iTank, flPos);
				vSpecialAttack(iTank, flPos, 10.0, MODEL_PROPANETANK);
			}

			vRemoveBomb(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iBombAbility[ST_GetTankType(tank)] == 1)
	{
		vBombAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iBombAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_bBomb[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "BombHuman3");
					case false: vBombAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	if (ST_IsTankSupported(tank) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iBombAbility[ST_GetTankType(tank)] == 1)
	{
		float flPos[3];
		GetClientAbsOrigin(tank, flPos);
		vSpecialAttack(tank, flPos, 10.0, MODEL_PROPANETANK);
	}

	vRemoveBomb(tank);
}

public void ST_OnRockBreak(int tank, int rock)
{
	if (ST_IsTankSupported(tank) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iBombRockBreak[ST_GetTankType(tank)] == 1)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flBombRockChance[ST_GetTankType(tank)])
		{
			float flPos[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flPos);
			vSpecialAttack(tank, flPos, 10.0, MODEL_PROPANETANK);

			if (g_iBombMessage[ST_GetTankType(tank)] & ST_MESSAGE_SPECIAL)
			{
				char sTankName[33];
				ST_GetTankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Bomb2", sTankName);
			}
		}
	}
}

static void vBombAbility(int tank)
{
	if (g_iBombCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bBomb2[tank] = false;
		g_bBomb3[tank] = false;

		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_flBombRange[ST_GetTankType(tank)])
				{
					vBombHit(iSurvivor, tank, g_flBombRangeChance[ST_GetTankType(tank)], g_iBombAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "BombHuman4");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "BombAmmo");
	}
}

static void vBombHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iBombCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bBomb[tank])
				{
					g_bBomb[tank] = true;
					g_iBombCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "BombHuman", g_iBombCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);

					if (g_iBombCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
					{
						CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bBomb[tank] = false;
					}
				}

				float flPos[3];
				GetClientAbsOrigin(survivor, flPos);
				vSpecialAttack(tank, flPos, 10.0, MODEL_PROPANETANK);

				vEffect(survivor, tank, g_iBombEffect[ST_GetTankType(tank)], flags);

				if (g_iBombMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Bomb", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bBomb[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bBomb2[tank])
				{
					g_bBomb2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "BombHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bBomb3[tank])
		{
			g_bBomb3[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "BombAmmo");
		}
	}
}

static void vRemoveBomb(int tank)
{
	g_bBomb[tank] = false;
	g_bBomb2[tank] = false;
	g_bBomb3[tank] = false;
	g_iBombCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveBomb(iPlayer);
		}
	}
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bBomb[iTank])
	{
		g_bBomb[iTank] = false;

		return Plugin_Stop;
	}

	g_bBomb[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "BombHuman5");

	return Plugin_Continue;
}