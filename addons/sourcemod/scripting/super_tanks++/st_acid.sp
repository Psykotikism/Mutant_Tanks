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
	name = "[ST++] Acid Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates acid puddles.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_ACID "Acid Ability"

bool g_bAcid[MAXPLAYERS + 1], g_bAcid2[MAXPLAYERS + 1], g_bAcid3[MAXPLAYERS + 1], g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sAcidEffect[ST_MAXTYPES + 1][4], g_sAcidEffect2[ST_MAXTYPES + 1][4], g_sAcidMessage[ST_MAXTYPES + 1][4], g_sAcidMessage2[ST_MAXTYPES + 1][4];

float g_flAcidChance[ST_MAXTYPES + 1], g_flAcidChance2[ST_MAXTYPES + 1], g_flAcidRange[ST_MAXTYPES + 1], g_flAcidRange2[ST_MAXTYPES + 1], g_flAcidRangeChance[ST_MAXTYPES + 1], g_flAcidRangeChance2[ST_MAXTYPES + 1], g_flAcidRockChance[ST_MAXTYPES + 1], g_flAcidRockChance2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

Handle g_hSDKAcidPlayer, g_hSDKPukePlayer;

int g_iAcidAbility[ST_MAXTYPES + 1], g_iAcidAbility2[ST_MAXTYPES + 1], g_iAcidCount[MAXPLAYERS + 1], g_iAcidHit[ST_MAXTYPES + 1], g_iAcidHit2[ST_MAXTYPES + 1], g_iAcidHitMode[ST_MAXTYPES + 1], g_iAcidHitMode2[ST_MAXTYPES + 1], g_iAcidRockBreak[ST_MAXTYPES + 1], g_iAcidRockBreak2[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Acid Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_acid", cmdAcidInfo, "View information about the Acid ability.");

	GameData gdSuperTanks = new GameData("super_tanks++");

	if (gdSuperTanks == null)
	{
		SetFailState("Unable to load the \"super_tanks++\" gamedata file.");
		return;
	}

	switch (bIsValidGame())
	{
		case true:
		{
			StartPrepSDKCall(SDKCall_Static);
			PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "CSpitterProjectile_Create");
			PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
			PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
			PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
			PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
			PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
			PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
			PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
			g_hSDKAcidPlayer = EndPrepSDKCall();

			if (g_hSDKAcidPlayer == null)
			{
				PrintToServer("%s Your \"CSpitterProjectile_Create\" signature is outdated.", ST_TAG);
			}
		}
		case false:
		{
			StartPrepSDKCall(SDKCall_Player);
			PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
			PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
			PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
			g_hSDKPukePlayer = EndPrepSDKCall();

			if (g_hSDKPukePlayer == null)
			{
				PrintToServer("%s Your \"CTerrorPlayer_OnVomitedUpon\" signature is outdated.", ST_TAG);
			}
		}
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

	vRemoveAcid(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdAcidInfo(int client, int args)
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
		case false: vAcidMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vAcidMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iAcidMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Acid Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iAcidMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iAcidAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iAcidCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AcidDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vAcidMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "AcidMenu", param1);
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
	menu.AddItem(ST_MENU_ACID, ST_MENU_ACID);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_ACID, false))
	{
		vAcidMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && (iAcidHitMode(attacker) == 0 || iAcidHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vAcidHit(victim, attacker, flAcidChance(attacker), iAcidHit(attacker), "1", "1");
			}
		}
		else if (ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && (iAcidHitMode(victim) == 0 || iAcidHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vAcidHit(attacker, victim, flAcidChance(victim), iAcidHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Acid Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Acid Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Acid Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iAcidAbility[iIndex] = kvSuperTanks.GetNum("Acid Ability/Ability Enabled", 0);
					g_iAcidAbility[iIndex] = iClamp(g_iAcidAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Acid Ability/Ability Effect", g_sAcidEffect[iIndex], sizeof(g_sAcidEffect[]), "0");
					kvSuperTanks.GetString("Acid Ability/Ability Message", g_sAcidMessage[iIndex], sizeof(g_sAcidMessage[]), "0");
					g_flAcidChance[iIndex] = kvSuperTanks.GetFloat("Acid Ability/Acid Chance", 33.3);
					g_flAcidChance[iIndex] = flClamp(g_flAcidChance[iIndex], 0.0, 100.0);
					g_iAcidHit[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Hit", 0);
					g_iAcidHit[iIndex] = iClamp(g_iAcidHit[iIndex], 0, 1);
					g_iAcidHitMode[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Hit Mode", 0);
					g_iAcidHitMode[iIndex] = iClamp(g_iAcidHitMode[iIndex], 0, 2);
					g_flAcidRange[iIndex] = kvSuperTanks.GetFloat("Acid Ability/Acid Range", 150.0);
					g_flAcidRange[iIndex] = flClamp(g_flAcidRange[iIndex], 1.0, 9999999999.0);
					g_flAcidRangeChance[iIndex] = kvSuperTanks.GetFloat("Acid Ability/Acid Range Chance", 15.0);
					g_flAcidRangeChance[iIndex] = flClamp(g_flAcidRangeChance[iIndex], 0.0, 100.0);
					g_iAcidRockBreak[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Rock Break", 0);
					g_iAcidRockBreak[iIndex] = iClamp(g_iAcidRockBreak[iIndex], 0, 1);
					g_flAcidRockChance[iIndex] = kvSuperTanks.GetFloat("Acid Ability/Acid Rock Chance", 33.3);
					g_flAcidRockChance[iIndex] = flClamp(g_flAcidRockChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Acid Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iAcidAbility2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Ability Enabled", g_iAcidAbility[iIndex]);
					g_iAcidAbility2[iIndex] = iClamp(g_iAcidAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Acid Ability/Ability Effect", g_sAcidEffect2[iIndex], sizeof(g_sAcidEffect2[]), g_sAcidEffect[iIndex]);
					kvSuperTanks.GetString("Acid Ability/Ability Message", g_sAcidMessage2[iIndex], sizeof(g_sAcidMessage2[]), g_sAcidMessage[iIndex]);
					g_flAcidChance2[iIndex] = kvSuperTanks.GetFloat("Acid Ability/Acid Chance", g_flAcidChance[iIndex]);
					g_flAcidChance2[iIndex] = flClamp(g_flAcidChance2[iIndex], 0.0, 100.0);
					g_iAcidHit2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Hit", g_iAcidHit[iIndex]);
					g_iAcidHit2[iIndex] = iClamp(g_iAcidHit2[iIndex], 0, 1);
					g_iAcidHitMode2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Hit Mode", g_iAcidHitMode[iIndex]);
					g_iAcidHitMode2[iIndex] = iClamp(g_iAcidHitMode2[iIndex], 0, 2);
					g_flAcidRange2[iIndex] = kvSuperTanks.GetFloat("Acid Ability/Acid Range", g_flAcidRange[iIndex]);
					g_flAcidRange2[iIndex] = flClamp(g_flAcidRange2[iIndex], 1.0, 9999999999.0);
					g_flAcidRangeChance2[iIndex] = kvSuperTanks.GetFloat("Acid Ability/Acid Range Chance", g_flAcidRangeChance[iIndex]);
					g_flAcidRangeChance2[iIndex] = flClamp(g_flAcidRangeChance2[iIndex], 0.0, 100.0);
					g_iAcidRockBreak2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Rock Break", g_iAcidRockBreak[iIndex]);
					g_iAcidRockBreak2[iIndex] = iClamp(g_iAcidRockBreak2[iIndex], 0, 1);
					g_flAcidRockChance2[iIndex] = kvSuperTanks.GetFloat("Acid Ability/Acid Rock Chance", g_flAcidRockChance[iIndex]);
					g_flAcidRockChance2[iIndex] = flClamp(g_flAcidRockChance2[iIndex], 0.0, 100.0);
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
			if (ST_IsCloneSupported(iTank, g_bCloneInstalled) && iAcidAbility(iTank) == 1 && bIsValidGame())
			{
				vAcid(iTank, iTank);
			}

			vRemoveAcid(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, "5") || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iAcidAbility(tank) == 1)
	{
		vAcidAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iAcidAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (g_bAcid[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "AcidHuman3");
					case false: vAcidAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	if (ST_IsTankSupported(tank) && ST_IsCloneSupported(tank, g_bCloneInstalled) && bIsValidGame() && iAcidAbility(tank) == 1)
	{
		vAcid(tank, tank);
	}

	vRemoveAcid(tank);
}

public void ST_OnRockBreak(int tank, int rock)
{
	int iAcidRockBreak = !g_bTankConfig[ST_GetTankType(tank)] ? g_iAcidRockBreak[ST_GetTankType(tank)] : g_iAcidRockBreak2[ST_GetTankType(tank)];
	if (ST_IsTankSupported(tank) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iAcidRockBreak == 1 && bIsValidGame())
	{
		float flAcidRockChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flAcidRockChance[ST_GetTankType(tank)] : g_flAcidRockChance2[ST_GetTankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flAcidRockChance)
		{
			float flOrigin[3], flAngles[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flOrigin);
			flOrigin[2] += 40.0;

			SDKCall(g_hSDKAcidPlayer, flOrigin, flAngles, flAngles, flAngles, tank, 2.0);

			char sAcidMessage[4];
			sAcidMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sAcidMessage[ST_GetTankType(tank)] : g_sAcidMessage2[ST_GetTankType(tank)];
			if (StrContains(sAcidMessage, "3") != -1)
			{
				char sTankName[33];
				ST_GetTankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Acid2", sTankName);
			}
		}
	}
}

static void vAcid(int survivor, int tank)
{
	float flOrigin[3], flAngles[3];
	GetClientAbsOrigin(survivor, flOrigin);
	GetClientAbsAngles(survivor, flAngles);

	SDKCall(g_hSDKAcidPlayer, flOrigin, flAngles, flAngles, flAngles, tank, 2.0);
}

static void vAcidAbility(int tank)
{
	if (g_iAcidCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bAcid2[tank] = false;
		g_bAcid3[tank] = false;

		float flAcidRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flAcidRange[ST_GetTankType(tank)] : g_flAcidRange2[ST_GetTankType(tank)],
			flAcidRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flAcidRangeChance[ST_GetTankType(tank)] : g_flAcidRangeChance2[ST_GetTankType(tank)],
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
				if (flDistance <= flAcidRange)
				{
					vAcidHit(iSurvivor, tank, flAcidRangeChance, iAcidAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "AcidHuman4");
			}
		}
	}
	else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "AcidAmmo");
	}
}

static void vAcidHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iAcidCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bAcid[tank])
				{
					g_bAcid[tank] = true;
					g_iAcidCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "AcidHuman", g_iAcidCount[tank], iHumanAmmo(tank));

					if (g_iAcidCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
					{
						CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bAcid[tank] = false;
					}
				}

				char sTankName[33], sAcidMessage[4];
				ST_GetTankName(tank, sTankName);
				sAcidMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sAcidMessage[ST_GetTankType(tank)] : g_sAcidMessage2[ST_GetTankType(tank)];

				switch (bIsValidGame())
				{
					case true:
					{
						vAcid(survivor, tank);

						if (StrContains(sAcidMessage, message) != -1)
						{
							ST_PrintToChatAll("%s %t", ST_TAG2, "Acid", sTankName, survivor);
						}
					}
					case false:
					{
						SDKCall(g_hSDKPukePlayer, survivor, tank, true);

						if (StrContains(sAcidMessage, message) != -1)
						{
							ST_PrintToChatAll("%s %t", ST_TAG2, "Puke", sTankName, survivor);
						}
					}
				}

				char sAcidEffect[4];
				sAcidEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_sAcidEffect[ST_GetTankType(tank)] : g_sAcidEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, sAcidEffect, mode);
			}
			else if (StrEqual(mode, "3") && !g_bAcid[tank])
			{
				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bAcid2[tank])
				{
					g_bAcid2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "AcidHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bAcid3[tank])
		{
			g_bAcid3[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "AcidAmmo");
		}
	}
}

static void vRemoveAcid(int tank)
{
	g_bAcid[tank] = false;
	g_bAcid2[tank] = false;
	g_bAcid3[tank] = false;
	g_iAcidCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveAcid(iPlayer);
		}
	}
}

static float flAcidChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flAcidChance[ST_GetTankType(tank)] : g_flAcidChance2[ST_GetTankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static int iAcidAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iAcidAbility[ST_GetTankType(tank)] : g_iAcidAbility2[ST_GetTankType(tank)];
}

static int iAcidHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iAcidHit[ST_GetTankType(tank)] : g_iAcidHit2[ST_GetTankType(tank)];
}

static int iAcidHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iAcidHitMode[ST_GetTankType(tank)] : g_iAcidHitMode2[ST_GetTankType(tank)];
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
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bAcid[iTank])
	{
		g_bAcid[iTank] = false;

		return Plugin_Stop;
	}

	g_bAcid[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "AcidHuman5");

	return Plugin_Continue;
}