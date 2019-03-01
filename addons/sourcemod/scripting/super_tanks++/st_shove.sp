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
	name = "[ST++] Shove Ability",
	author = ST_AUTHOR,
	description = "The Super Tank repeatedly shoves survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Shove Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_SHOVE "Shove Ability"

bool g_bCloneInstalled, g_bShove[MAXPLAYERS + 1], g_bShove2[MAXPLAYERS + 1], g_bShove3[MAXPLAYERS + 1], g_bShove4[MAXPLAYERS + 1], g_bShove5[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flShoveChance[ST_MAXTYPES + 1], g_flShoveDuration[ST_MAXTYPES + 1], g_flShoveInterval[ST_MAXTYPES + 1], g_flShoveRange[ST_MAXTYPES + 1], g_flShoveRangeChance[ST_MAXTYPES + 1];

Handle g_hSDKShovePlayer;

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iShoveAbility[ST_MAXTYPES + 1], g_iShoveCount[MAXPLAYERS + 1], g_iShoveEffect[ST_MAXTYPES + 1], g_iShoveHit[ST_MAXTYPES + 1], g_iShoveHitMode[ST_MAXTYPES + 1], g_iShoveMessage[ST_MAXTYPES + 1], g_iShoveOwner[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_shove", cmdShoveInfo, "View information about the Shove ability.");

	GameData gdSuperTanks = new GameData("super_tanks++");

	if (gdSuperTanks == null)
	{
		SetFailState("Unable to load the \"super_tanks++\" gamedata file.");
		return;
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "CTerrorPlayer_OnStaggered");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	g_hSDKShovePlayer = EndPrepSDKCall();

	if (g_hSDKShovePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnStaggered\" signature is outdated.", ST_TAG);
	}

	delete gdSuperTanks;

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

public Action cmdShoveInfo(int client, int args)
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
		case false: vShoveMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vShoveMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iShoveMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Shove Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iShoveMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iShoveAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iShoveCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "ShoveDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flShoveDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vShoveMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "ShoveMenu", param1);
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
	menu.AddItem(ST_MENU_SHOVE, ST_MENU_SHOVE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_SHOVE, false))
	{
		vShoveMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((g_iShoveHitMode[ST_GetTankType(attacker)] == 0 || g_iShoveHitMode[ST_GetTankType(attacker)] == 1) && ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vShoveHit(victim, attacker, g_flShoveChance[ST_GetTankType(attacker)], g_iShoveHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if ((g_iShoveHitMode[ST_GetTankType(victim)] == 0 || g_iShoveHitMode[ST_GetTankType(victim)] == 2) && ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vShoveHit(attacker, victim, g_flShoveChance[ST_GetTankType(victim)], g_iShoveHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iShoveAbility[iIndex] = 0;
		g_iShoveEffect[iIndex] = 0;
		g_iShoveMessage[iIndex] = 0;
		g_flShoveChance[iIndex] = 33.3;
		g_flShoveDuration[iIndex] = 5.0;
		g_iShoveHit[iIndex] = 0;
		g_iShoveHitMode[iIndex] = 0;
		g_flShoveInterval[iIndex] = 1.0;
		g_flShoveRange[iIndex] = 150.0;
		g_flShoveRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	g_iHumanAbility[type] = iGetValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iShoveAbility[type] = iGetValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iShoveAbility[type], value, 0, 0, 1);
	g_iShoveEffect[type] = iGetValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iShoveEffect[type], value, 0, 0, 7);
	g_iShoveMessage[type] = iGetValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iShoveMessage[type], value, 0, 0, 3);
	g_flShoveChance[type] = flGetValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveChance", "Shove Chance", "Shove_Chance", "chance", main, g_flShoveChance[type], value, 33.3, 0.0, 100.0);
	g_flShoveDuration[type] = flGetValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveDuration", "Shove Duration", "Shove_Duration", "duration", main, g_flShoveDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iShoveHit[type] = iGetValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveHit", "Shove Hit", "Shove_Hit", "hit", main, g_iShoveHit[type], value, 0, 0, 1);
	g_iShoveHitMode[type] = iGetValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveHitMode", "Shove Hit Mode", "Shove_Hit_Mode", "hitmode", main, g_iShoveHitMode[type], value, 0, 0, 2);
	g_flShoveInterval[type] = flGetValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveInterval", "Shove Interval", "Shove_Interval", "interval", main, g_flShoveInterval[type], value, 1.0, 0.1, 9999999999.0);
	g_flShoveRange[type] = flGetValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveRange", "Shove Range", "Shove_Range", "range", main, g_flShoveRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flShoveRangeChance[type] = flGetValue(subsection, "shoveability", "shove ability", "shove_ability", "shove", key, "ShoveRangeChance", "Shove Range Chance", "Shove_Range_Chance", "rangechance", main, g_flShoveRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			if (bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iShoveAbility[ST_GetTankType(iTank)] == 1)
			{
				float flTankPos[3];
				GetClientAbsOrigin(iTank, flTankPos);

				for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
				{
					if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
					{
						float flSurvivorPos[3];
						GetClientAbsOrigin(iSurvivor, flSurvivorPos);

						float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
						if (flDistance <= 200.0)
						{
							SDKCall(g_hSDKShovePlayer, iSurvivor, iSurvivor, flSurvivorPos);
						}
					}
				}
			}

			vRemoveShove(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iShoveAbility[ST_GetTankType(tank)] == 1)
	{
		vShoveAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iShoveAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bShove2[tank] && !g_bShove3[tank])
				{
					vShoveAbility(tank);
				}
				else if (g_bShove2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShoveHuman3");
				}
				else if (g_bShove3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShoveHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveShove(tank);
}

static void vRemoveShove(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bShove[iSurvivor] && g_iShoveOwner[iSurvivor] == tank)
		{
			g_bShove[iSurvivor] = false;
			g_iShoveOwner[iSurvivor] = 0;
		}
	}

	vReset3(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vReset3(iPlayer);

			g_iShoveOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_bShove[survivor] = false;
	g_iShoveOwner[survivor] = 0;

	if (g_iShoveMessage[ST_GetTankType(tank)] & messages)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Shove2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bShove[tank] = false;
	g_bShove2[tank] = false;
	g_bShove3[tank] = false;
	g_bShove4[tank] = false;
	g_bShove5[tank] = false;
	g_iShoveCount[tank] = 0;
}

static void vShoveAbility(int tank)
{
	if (g_iShoveCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bShove4[tank] = false;
		g_bShove5[tank] = false;

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
				if (flDistance <= g_flShoveRange[ST_GetTankType(tank)])
				{
					vShoveHit(iSurvivor, tank, g_flShoveRangeChance[ST_GetTankType(tank)], g_iShoveAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShoveHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShoveAmmo");
	}
}

static void vShoveHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iShoveCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bShove[survivor])
			{
				g_bShove[survivor] = true;
				g_iShoveOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bShove2[tank])
				{
					g_bShove2[tank] = true;
					g_iShoveCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShoveHuman", g_iShoveCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				DataPack dpShove;
				CreateDataTimer(g_flShoveInterval[ST_GetTankType(tank)], tTimerShove, dpShove, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpShove.WriteCell(GetClientUserId(survivor));
				dpShove.WriteCell(GetClientUserId(tank));
				dpShove.WriteCell(ST_GetTankType(tank));
				dpShove.WriteCell(messages);
				dpShove.WriteCell(enabled);
				dpShove.WriteFloat(GetEngineTime());

				vEffect(survivor, tank, g_iShoveEffect[ST_GetTankType(tank)], flags);

				if (g_iShoveMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Shove", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bShove2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bShove4[tank])
				{
					g_bShove4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShoveHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bShove5[tank])
		{
			g_bShove5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShoveAmmo");
		}
	}
}

public Action tTimerShove(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bShove[iSurvivor] = false;
		g_iShoveOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bShove[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iShoveEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iShoveEnabled == 0 || (flTime + g_flShoveDuration[ST_GetTankType(iTank)]) < GetEngineTime())
	{
		g_bShove2[iTank] = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bShove3[iTank])
		{
			g_bShove3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ShoveHuman6");

			if (g_iShoveCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bShove3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	float flOrigin[3];
	GetClientAbsOrigin(iSurvivor, flOrigin);

	SDKCall(g_hSDKShovePlayer, iSurvivor, iSurvivor, flOrigin);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bShove3[iTank])
	{
		g_bShove3[iTank] = false;

		return Plugin_Stop;
	}

	g_bShove3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ShoveHuman7");

	return Plugin_Continue;
}