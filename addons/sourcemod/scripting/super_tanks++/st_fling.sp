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
	name = "[ST++] Fling Ability",
	author = ST_AUTHOR,
	description = "The Super Tank flings survivors high into the air.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Fling Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_BLOOD "boomer_explode_D"

#define ST_MENU_FLING "Fling Ability"

bool g_bCloneInstalled, g_bFling[MAXPLAYERS + 1], g_bFling2[MAXPLAYERS + 1], g_bFling3[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flFlingChance[ST_MAXTYPES + 1], g_flFlingChance2[ST_MAXTYPES + 1], g_flFlingForce[ST_MAXTYPES + 1], g_flFlingForce2[ST_MAXTYPES + 1], g_flFlingRange[ST_MAXTYPES + 1], g_flFlingRange2[ST_MAXTYPES + 1], g_flFlingRangeChance[ST_MAXTYPES + 1], g_flFlingRangeChance2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

Handle g_hSDKFlingPlayer, g_hSDKPukePlayer;

int g_iFlingAbility[ST_MAXTYPES + 1], g_iFlingAbility2[ST_MAXTYPES + 1], g_iFlingCount[MAXPLAYERS + 1], g_iFlingEffect[ST_MAXTYPES + 1], g_iFlingEffect2[ST_MAXTYPES + 1], g_iFlingHit[ST_MAXTYPES + 1], g_iFlingHit2[ST_MAXTYPES + 1], g_iFlingHitMode[ST_MAXTYPES + 1], g_iFlingHitMode2[ST_MAXTYPES + 1], g_iFlingMessage[ST_MAXTYPES + 1], g_iFlingMessage2[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_fling", cmdFlingInfo, "View information about the Fling ability.");

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
			StartPrepSDKCall(SDKCall_Player);
			PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "CTerrorPlayer_Fling");
			PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
			PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
			PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
			PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
			g_hSDKFlingPlayer = EndPrepSDKCall();

			if (g_hSDKFlingPlayer == null)
			{
				PrintToServer("%s Your \"CTerrorPlayer_Fling\" signature is outdated.", ST_TAG);
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
	vPrecacheParticle(PARTICLE_BLOOD);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveFling(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdFlingInfo(int client, int args)
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
		case false: vFlingMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vFlingMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iFlingMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Fling Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iFlingMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iFlingAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iFlingCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "FlingDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vFlingMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "FlingMenu", param1);
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
	menu.AddItem(ST_MENU_FLING, ST_MENU_FLING);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_FLING, false))
	{
		vFlingMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && (iFlingHitMode(attacker) == 0 || iFlingHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vFlingHit(victim, attacker, flFlingChance(attacker), iFlingHit(attacker), ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && (iFlingHitMode(victim) == 0 || iFlingHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vFlingHit(attacker, victim, flFlingChance(victim), iFlingHit(victim), ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Fling Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Fling Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iFlingAbility[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Enabled", 0);
					g_iFlingAbility[iIndex] = iClamp(g_iFlingAbility[iIndex], 0, 1);
					g_iFlingEffect[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Effect", 0);
					g_iFlingEffect[iIndex] = iClamp(g_iFlingEffect[iIndex], 0, 7);
					g_iFlingMessage[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Message", 0);
					g_iFlingMessage[iIndex] = iClamp(g_iFlingMessage[iIndex], 0, 3);
					g_flFlingChance[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Chance", 33.3);
					g_flFlingChance[iIndex] = flClamp(g_flFlingChance[iIndex], 0.0, 100.0);
					g_flFlingForce[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Force", 300.0);
					g_flFlingForce[iIndex] = flClamp(g_flFlingForce[iIndex], 1.0, 9999999999.0);
					g_iFlingHit[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit", 0);
					g_iFlingHit[iIndex] = iClamp(g_iFlingHit[iIndex], 0, 1);
					g_iFlingHitMode[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit Mode", 0);
					g_iFlingHitMode[iIndex] = iClamp(g_iFlingHitMode[iIndex], 0, 2);
					g_flFlingRange[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range", 150.0);
					g_flFlingRange[iIndex] = flClamp(g_flFlingRange[iIndex], 1.0, 9999999999.0);
					g_flFlingRangeChance[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range Chance", 15.0);
					g_flFlingRangeChance[iIndex] = flClamp(g_flFlingRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iFlingAbility2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Enabled", g_iFlingAbility[iIndex]);
					g_iFlingAbility2[iIndex] = iClamp(g_iFlingAbility2[iIndex], 0, 1);
					g_iFlingEffect2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Effect", g_iFlingEffect[iIndex]);
					g_iFlingEffect2[iIndex] = iClamp(g_iFlingEffect2[iIndex], 0, 7);
					g_iFlingMessage2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Message", g_iFlingMessage[iIndex]);
					g_iFlingMessage2[iIndex] = iClamp(g_iFlingMessage2[iIndex], 0, 3);
					g_flFlingChance2[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Chance", g_flFlingChance[iIndex]);
					g_flFlingChance2[iIndex] = flClamp(g_flFlingChance2[iIndex], 0.0, 100.0);
					g_flFlingForce2[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Force", g_flFlingForce[iIndex]);
					g_flFlingForce2[iIndex] = flClamp(g_flFlingForce2[iIndex], 1.0, 9999999999.0);
					g_iFlingHit2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit", g_iFlingHit[iIndex]);
					g_iFlingHit2[iIndex] = iClamp(g_iFlingHit2[iIndex], 0, 1);
					g_iFlingHitMode2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit Mode", g_iFlingHitMode[iIndex]);
					g_iFlingHitMode2[iIndex] = iClamp(g_iFlingHitMode2[iIndex], 0, 2);
					g_flFlingRange2[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range", g_flFlingRange[iIndex]);
					g_flFlingRange2[iIndex] = flClamp(g_flFlingRange2[iIndex], 1.0, 9999999999.0);
					g_flFlingRangeChance2[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range Chance", g_flFlingRangeChance[iIndex]);
					g_flFlingRangeChance2[iIndex] = flClamp(g_flFlingRangeChance2[iIndex], 0.0, 100.0);
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
			if (ST_IsCloneSupported(iTank, g_bCloneInstalled) && iFlingAbility(iTank) == 1)
			{
				if (!bIsValidGame())
				{
					vAttachParticle(iTank, PARTICLE_BLOOD, 0.1, 0.0);
				}

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
							switch (bIsValidGame())
							{
								case true: vFling(iSurvivor, iTank);
								case false: SDKCall(g_hSDKPukePlayer, iSurvivor, iTank, true);
							}
						}
					}
				}
			}

			vRemoveFling(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iFlingAbility(tank) == 1)
	{
		vFlingAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iFlingAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (g_bFling[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlingHuman3");
					case false: vFlingAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveFling(tank);
}

static void vFling(int survivor, int tank)
{
	float flSurvivorPos[3], flTankPos[3], flDistance[3], flRatio[3], flVelocity[3],
		flFlingForce = !g_bTankConfig[ST_GetTankType(tank)] ? g_flFlingForce[ST_GetTankType(tank)] : g_flFlingForce2[ST_GetTankType(tank)];

	GetClientAbsOrigin(survivor, flSurvivorPos);
	GetClientAbsOrigin(tank, flTankPos);

	flDistance[0] = (flTankPos[0] - flSurvivorPos[0]);
	flDistance[1] = (flTankPos[1] - flSurvivorPos[1]);
	flDistance[2] = (flTankPos[2] - flSurvivorPos[2]);

	flRatio[0] = flDistance[0] / (SquareRoot((flDistance[1] * flDistance[1]) + (flDistance[0] * flDistance[0])));
	flRatio[1] = flDistance[1] / (SquareRoot((flDistance[1] * flDistance[1]) + (flDistance[0] * flDistance[0])));

	flVelocity[0] = (flRatio[0] * -1) * flFlingForce;
	flVelocity[1] = (flRatio[1] * -1) * flFlingForce;
	flVelocity[2] = flFlingForce;

	SDKCall(g_hSDKFlingPlayer, survivor, flVelocity, 76, tank, 3.0);
}

static void vFlingAbility(int tank)
{
	if (g_iFlingCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bFling2[tank] = false;
		g_bFling3[tank] = false;

		float flFlingRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flFlingRange[ST_GetTankType(tank)] : g_flFlingRange2[ST_GetTankType(tank)],
			flFlingRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flFlingRangeChance[ST_GetTankType(tank)] : g_flFlingRangeChance2[ST_GetTankType(tank)],
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
				if (flDistance <= flFlingRange)
				{
					vFlingHit(iSurvivor, tank, flFlingRangeChance, iFlingAbility(tank), ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlingHuman4");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlingAmmo");
	}
}

static void vFlingHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iFlingCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && (flags & ST_ATTACK_RANGE) && !g_bFling[tank])
				{
					g_bFling[tank] = true;
					g_iFlingCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlingHuman", g_iFlingCount[tank], iHumanAmmo(tank));

					if (g_iFlingCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
					{
						CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bFling[tank] = false;
					}
				}

				int iFlingEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_iFlingEffect[ST_GetTankType(tank)] : g_iFlingEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, iFlingEffect, flags);

				char sTankName[33];
				ST_GetTankName(tank, sTankName);
				int iFlingMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_iFlingMessage[ST_GetTankType(tank)] : g_iFlingMessage2[ST_GetTankType(tank)];

				switch (bIsValidGame())
				{
					case true:
					{
						vFling(survivor, tank);

						if (iFlingMessage & messages)
						{
							ST_PrintToChatAll("%s %t", ST_TAG2, "Fling", sTankName, survivor);
						}
					}
					case false:
					{
						SDKCall(g_hSDKPukePlayer, survivor, tank, true);

						if (iFlingMessage & messages)
						{
							ST_PrintToChatAll("%s %t", ST_TAG2, "Puke", sTankName, survivor);
						}
					}
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bFling[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && !g_bFling2[tank])
				{
					g_bFling2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlingHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && !g_bFling3[tank])
		{
			g_bFling3[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "FlingAmmo");
		}
	}
}

static void vRemoveFling(int tank)
{
	g_bFling[tank] = false;
	g_bFling2[tank] = false;
	g_bFling3[tank] = false;
	g_iFlingCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveFling(iPlayer);
		}
	}
}

static float flFlingChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flFlingChance[ST_GetTankType(tank)] : g_flFlingChance2[ST_GetTankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static int iFlingAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iFlingAbility[ST_GetTankType(tank)] : g_iFlingAbility2[ST_GetTankType(tank)];
}

static int iFlingHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iFlingHit[ST_GetTankType(tank)] : g_iFlingHit2[ST_GetTankType(tank)];
}

static int iFlingHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iFlingHitMode[ST_GetTankType(tank)] : g_iFlingHitMode2[ST_GetTankType(tank)];
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
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bFling[iTank])
	{
		g_bFling[iTank] = false;

		return Plugin_Stop;
	}

	g_bFling[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "FlingHuman5");

	return Plugin_Continue;
}