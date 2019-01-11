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
	name = "[ST++] Shove Ability",
	author = ST_AUTHOR,
	description = "The Super Tank repeatedly shoves survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_SHOVE "Shove Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bShove[MAXPLAYERS + 1], g_bShove2[MAXPLAYERS + 1], g_bShove3[MAXPLAYERS + 1], g_bShove4[MAXPLAYERS + 1], g_bShove5[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sShoveEffect[ST_MAXTYPES + 1][4], g_sShoveEffect2[ST_MAXTYPES + 1][4], g_sShoveMessage[ST_MAXTYPES + 1][3], g_sShoveMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flShoveChance[ST_MAXTYPES + 1], g_flShoveChance2[ST_MAXTYPES + 1], g_flShoveDuration[ST_MAXTYPES + 1], g_flShoveDuration2[ST_MAXTYPES + 1], g_flShoveInterval[ST_MAXTYPES + 1], g_flShoveInterval2[ST_MAXTYPES + 1], g_flShoveRange[ST_MAXTYPES + 1], g_flShoveRange2[ST_MAXTYPES + 1], g_flShoveRangeChance[ST_MAXTYPES + 1], g_flShoveRangeChance2[ST_MAXTYPES + 1];

Handle g_hSDKShovePlayer;

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iShoveAbility[ST_MAXTYPES + 1], g_iShoveAbility2[ST_MAXTYPES + 1], g_iShoveCount[MAXPLAYERS + 1], g_iShoveHit[ST_MAXTYPES + 1], g_iShoveHit2[ST_MAXTYPES + 1], g_iShoveHitMode[ST_MAXTYPES + 1], g_iShoveHitMode2[ST_MAXTYPES + 1], g_iShoveOwner[MAXPLAYERS + 1];

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

public Action cmdShoveInfo(int client, int args)
{
	if (!ST_IsCorePluginEnabled())
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iShoveAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iShoveCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "ShoveDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flShoveDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
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
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iShoveHitMode(attacker) == 0 || iShoveHitMode(attacker) == 1) && ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vShoveHit(victim, attacker, flShoveChance(attacker), iShoveHit(attacker), "1", "1");
			}
		}
		else if ((iShoveHitMode(victim) == 0 || iShoveHitMode(victim) == 2) && ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vShoveHit(attacker, victim, flShoveChance(victim), iShoveHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Shove Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Shove Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iShoveAbility[iIndex] = kvSuperTanks.GetNum("Shove Ability/Ability Enabled", 0);
					g_iShoveAbility[iIndex] = iClamp(g_iShoveAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Shove Ability/Ability Effect", g_sShoveEffect[iIndex], sizeof(g_sShoveEffect[]), "0");
					kvSuperTanks.GetString("Shove Ability/Ability Message", g_sShoveMessage[iIndex], sizeof(g_sShoveMessage[]), "0");
					g_flShoveChance[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Chance", 33.3);
					g_flShoveChance[iIndex] = flClamp(g_flShoveChance[iIndex], 0.0, 100.0);
					g_flShoveDuration[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Duration", 5.0);
					g_flShoveDuration[iIndex] = flClamp(g_flShoveDuration[iIndex], 0.1, 9999999999.0);
					g_iShoveHit[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit", 0);
					g_iShoveHit[iIndex] = iClamp(g_iShoveHit[iIndex], 0, 1);
					g_iShoveHitMode[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit Mode", 0);
					g_iShoveHitMode[iIndex] = iClamp(g_iShoveHitMode[iIndex], 0, 2);
					g_flShoveInterval[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Interval", 1.0);
					g_flShoveInterval[iIndex] = flClamp(g_flShoveInterval[iIndex], 0.1, 9999999999.0);
					g_flShoveRange[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Range", 150.0);
					g_flShoveRange[iIndex] = flClamp(g_flShoveRange[iIndex], 1.0, 9999999999.0);
					g_flShoveRangeChance[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Range Chance", 15.0);
					g_flShoveRangeChance[iIndex] = flClamp(g_flShoveRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iShoveAbility2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Ability Enabled", g_iShoveAbility[iIndex]);
					g_iShoveAbility2[iIndex] = iClamp(g_iShoveAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Shove Ability/Ability Effect", g_sShoveEffect2[iIndex], sizeof(g_sShoveEffect2[]), g_sShoveEffect[iIndex]);
					kvSuperTanks.GetString("Shove Ability/Ability Message", g_sShoveMessage2[iIndex], sizeof(g_sShoveMessage2[]), g_sShoveMessage[iIndex]);
					g_flShoveChance2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Chance", g_flShoveChance[iIndex]);
					g_flShoveChance2[iIndex] = flClamp(g_flShoveChance2[iIndex], 0.0, 100.0);
					g_flShoveDuration2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Duration", g_flShoveDuration[iIndex]);
					g_flShoveDuration2[iIndex] = flClamp(g_flShoveDuration2[iIndex], 0.1, 9999999999.0);
					g_iShoveHit2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit", g_iShoveHit[iIndex]);
					g_iShoveHit2[iIndex] = iClamp(g_iShoveHit2[iIndex], 0, 1);
					g_iShoveHitMode2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit Mode", g_iShoveHitMode[iIndex]);
					g_iShoveHitMode2[iIndex] = iClamp(g_iShoveHitMode2[iIndex], 0, 2);
					g_flShoveInterval2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Interval", g_flShoveInterval[iIndex]);
					g_flShoveInterval2[iIndex] = flClamp(g_flShoveInterval2[iIndex], 0.1, 9999999999.0);
					g_flShoveRange2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Range", g_flShoveRange[iIndex]);
					g_flShoveRange2[iIndex] = flClamp(g_flShoveRange2[iIndex], 1.0, 9999999999.0);
					g_flShoveRangeChance2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Range Chance", g_flShoveRangeChance[iIndex]);
					g_flShoveRangeChance2[iIndex] = flClamp(g_flShoveRangeChance2[iIndex], 0.0, 100.0);
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
		if (ST_IsTankSupported(iTank, "024"))
		{
			if (ST_IsCloneSupported(iTank, g_bCloneInstalled) && iShoveAbility(iTank) == 1)
			{
				float flTankPos[3];
				GetClientAbsOrigin(iTank, flTankPos);

				for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
				{
					if (bIsSurvivor(iSurvivor, "234"))
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
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, "5") || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iShoveAbility(tank) == 1)
	{
		vShoveAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iShoveAbility(tank) == 1 && iHumanAbility(tank) == 1)
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

public void ST_OnChangeType(int tank)
{
	vRemoveShove(tank);
}

static void vRemoveShove(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, "234") && g_bShove[iSurvivor] && g_iShoveOwner[iSurvivor] == tank)
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
		if (bIsValidClient(iPlayer, "24"))
		{
			vReset3(iPlayer);

			g_iShoveOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bShove[survivor] = false;
	g_iShoveOwner[survivor] = 0;

	char sShoveMessage[3];
	sShoveMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sShoveMessage[ST_GetTankType(tank)] : g_sShoveMessage2[ST_GetTankType(tank)];
	if (StrContains(sShoveMessage, message) != -1)
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
	if (g_iShoveCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bShove4[tank] = false;
		g_bShove5[tank] = false;

		float flShoveRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flShoveRange[ST_GetTankType(tank)] : g_flShoveRange2[ST_GetTankType(tank)],
			flShoveRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flShoveRangeChance[ST_GetTankType(tank)] : g_flShoveRangeChance2[ST_GetTankType(tank)],
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
				if (flDistance <= flShoveRange)
				{
					vShoveHit(iSurvivor, tank, flShoveRangeChance, iShoveAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShoveHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShoveAmmo");
	}
}

static void vShoveHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iShoveCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bShove[survivor])
			{
				g_bShove[survivor] = true;
				g_iShoveOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bShove2[tank])
				{
					g_bShove2[tank] = true;
					g_iShoveCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShoveHuman", g_iShoveCount[tank], iHumanAmmo(tank));
				}

				float flShoveInterval = !g_bTankConfig[ST_GetTankType(tank)] ? g_flShoveInterval[ST_GetTankType(tank)] : g_flShoveInterval2[ST_GetTankType(tank)];
				DataPack dpShove;
				CreateDataTimer(flShoveInterval, tTimerShove, dpShove, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpShove.WriteCell(GetClientUserId(survivor));
				dpShove.WriteCell(GetClientUserId(tank));
				dpShove.WriteString(message);
				dpShove.WriteCell(enabled);
				dpShove.WriteFloat(GetEngineTime());

				char sShoveEffect[4];
				sShoveEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_sShoveEffect[ST_GetTankType(tank)] : g_sShoveEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, sShoveEffect, mode);

				char sShoveMessage[3];
				sShoveMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sShoveMessage[ST_GetTankType(tank)] : g_sShoveMessage2[ST_GetTankType(tank)];
				if (StrContains(sShoveMessage, message) != -1)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Shove", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bShove2[tank])
			{
				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bShove4[tank])
				{
					g_bShove4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShoveHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bShove5[tank])
		{
			g_bShove5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShoveAmmo");
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flShoveChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flShoveChance[ST_GetTankType(tank)] : g_flShoveChance2[ST_GetTankType(tank)];
}

static float flShoveDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flShoveDuration[ST_GetTankType(tank)] : g_flShoveDuration2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iShoveAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iShoveAbility[ST_GetTankType(tank)] : g_iShoveAbility2[ST_GetTankType(tank)];
}

static int iShoveHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iShoveHit[ST_GetTankType(tank)] : g_iShoveHit2[ST_GetTankType(tank)];
}

static int iShoveHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iShoveHitMode[ST_GetTankType(tank)] : g_iShoveHitMode2[ST_GetTankType(tank)];
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

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bShove[iSurvivor])
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iShoveEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iShoveEnabled == 0 || (flTime + flShoveDuration(iTank)) < GetEngineTime())
	{
		g_bShove2[iTank] = false;

		vReset2(iSurvivor, iTank, sMessage);

		if (ST_IsTankSupported(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bShove3[iTank])
		{
			g_bShove3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ShoveHuman6");

			if (g_iShoveCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
			{
				CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
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
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bShove3[iTank])
	{
		g_bShove3[iTank] = false;

		return Plugin_Stop;
	}

	g_bShove3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ShoveHuman7");

	return Plugin_Continue;
}