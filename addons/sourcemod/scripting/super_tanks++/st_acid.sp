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
	name = "[ST++] Acid Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates acid puddles.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

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

#define PARTICLE_BLOOD "boomer_explode_D"

#define ST_MENU_ACID "Acid Ability"

bool g_bAcid[MAXPLAYERS + 1], g_bAcid2[MAXPLAYERS + 1], g_bAcid3[MAXPLAYERS + 1], g_bCloneInstalled;

float g_flAcidChance[ST_MAXTYPES + 1], g_flAcidRange[ST_MAXTYPES + 1], g_flAcidRangeChance[ST_MAXTYPES + 1], g_flAcidRockChance[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1];

Handle g_hSDKAcidPlayer, g_hSDKPukePlayer;

int g_iAcidAbility[ST_MAXTYPES + 1], g_iAcidCount[MAXPLAYERS + 1], g_iAcidEffect[ST_MAXTYPES + 1], g_iAcidHit[ST_MAXTYPES + 1], g_iAcidHitMode[ST_MAXTYPES + 1], g_iAcidMessage[ST_MAXTYPES + 1], g_iAcidRockBreak[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1];

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

	if (!bIsValidClient(client, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT))
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iAcidAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iAcidCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AcidDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iAcidHitMode[ST_GetTankType(attacker)] == 0 || g_iAcidHitMode[ST_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vAcidHit(victim, attacker, g_flAcidChance[ST_GetTankType(attacker)], g_iAcidHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iAcidHitMode[ST_GetTankType(victim)] == 0 || g_iAcidHitMode[ST_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vAcidHit(attacker, victim, g_flAcidChance[ST_GetTankType(victim)], g_iAcidHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iAcidAbility[iIndex] = 0;
		g_iAcidEffect[iIndex] = 0;
		g_iAcidMessage[iIndex] = 0;
		g_flAcidChance[iIndex] = 33.3;
		g_iAcidHit[iIndex] = 0;
		g_iAcidHitMode[iIndex] = 0;
		g_flAcidRange[iIndex] = 150.0;
		g_flAcidRangeChance[iIndex] = 15.0;
		g_iAcidRockBreak[iIndex] = 0;
		g_flAcidRockChance[iIndex] = 33.3;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	g_iHumanAbility[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iAcidAbility[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iAcidAbility[type], value, 0, 0, 1);
	g_iAcidEffect[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iAcidEffect[type], value, 0, 0, 7);
	g_iAcidMessage[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iAcidMessage[type], value, 0, 0, 7);
	g_flAcidChance[type] = flGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AcidChance", "Acid Chance", "Acid_Chance", "chance", main, g_flAcidChance[type], value, 33.3, 0.0, 100.0);
	g_iAcidHit[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AcidHit", "Acid Hit", "Acid_Hit", "hit", main, g_iAcidHit[type], value, 0, 0, 1);
	g_iAcidHitMode[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AcidHitMode", "Acid Hit Mode", "Acid_Hit_Mode", "hitmode", main, g_iAcidHitMode[type], value, 0, 0, 2);
	g_flAcidRange[type] = flGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AcidRange", "Acid Range", "Acid_Range", "range", main, g_flAcidRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flAcidRangeChance[type] = flGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AcidRangeChance", "Acid Range Chance", "Acid_Range_Chance", "rangechance", main, g_flAcidRangeChance[type], value, 15.0, 0.0, 100.0);
	g_iAcidRockBreak[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AcidRockBreak", "Acid Rock Break", "Acid_Rock_Break", "rock", main, g_iAcidRockBreak[type], value, 0, 0, 1);
	g_flAcidRockChance[type] = flGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AcidRockChance", "Acid Rock Chance", "Acid_Rock_Chance", "rockchance", main, g_flAcidRockChance[type], value, 33.3, 0.0, 100.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			if (bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iAcidAbility[ST_GetTankType(iTank)] == 1)
			{
				switch (bIsValidGame())
				{
					case true: vAcid(iTank, iTank);
					case false:
					{
						vAttachParticle(iTank, PARTICLE_BLOOD, 0.1, 0.0);

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
									SDKCall(g_hSDKPukePlayer, iSurvivor, iTank, true);
								}
							}
						}
					}
				}
			}

			vRemoveAcid(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iAcidAbility[ST_GetTankType(tank)] == 1)
	{
		vAcidAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iAcidAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
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

public void ST_OnChangeType(int tank, bool revert)
{
	if (ST_IsTankSupported(tank) && bIsCloneAllowed(tank, g_bCloneInstalled) && bIsValidGame() && g_iAcidAbility[ST_GetTankType(tank)] == 1)
	{
		vAcid(tank, tank);
	}

	vRemoveAcid(tank);
}

public void ST_OnRockBreak(int tank, int rock)
{
	if (ST_IsTankSupported(tank) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iAcidRockBreak[ST_GetTankType(tank)] == 1 && bIsValidGame())
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flAcidRockChance[ST_GetTankType(tank)])
		{
			float flOrigin[3], flAngles[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flOrigin);
			flOrigin[2] += 40.0;

			SDKCall(g_hSDKAcidPlayer, flOrigin, flAngles, flAngles, flAngles, tank, 2.0);

			if (g_iAcidMessage[ST_GetTankType(tank)] & ST_MESSAGE_SPECIAL)
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
	if (g_iAcidCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bAcid2[tank] = false;
		g_bAcid3[tank] = false;

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
				if (flDistance <= g_flAcidRange[ST_GetTankType(tank)])
				{
					vAcidHit(iSurvivor, tank, g_flAcidRangeChance[ST_GetTankType(tank)], g_iAcidAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "AcidHuman4");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "AcidAmmo");
	}
}

static void vAcidHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iAcidCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bAcid[tank])
				{
					g_bAcid[tank] = true;
					g_iAcidCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "AcidHuman", g_iAcidCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);

					if (g_iAcidCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
					{
						CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bAcid[tank] = false;
					}
				}

				char sTankName[33];
				ST_GetTankName(tank, sTankName);

				switch (bIsValidGame())
				{
					case true:
					{
						vAcid(survivor, tank);

						if (g_iAcidMessage[ST_GetTankType(tank)] & messages)
						{
							ST_PrintToChatAll("%s %t", ST_TAG2, "Acid", sTankName, survivor);
						}
					}
					case false:
					{
						SDKCall(g_hSDKPukePlayer, survivor, tank, true);

						if (g_iAcidMessage[ST_GetTankType(tank)] & messages)
						{
							ST_PrintToChatAll("%s %t", ST_TAG2, "Puke", sTankName, survivor);
						}
					}
				}

				vEffect(survivor, tank, g_iAcidEffect[ST_GetTankType(tank)], flags);
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bAcid[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bAcid2[tank])
				{
					g_bAcid2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "AcidHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bAcid3[tank])
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
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveAcid(iPlayer);
		}
	}
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bAcid[iTank])
	{
		g_bAcid[iTank] = false;

		return Plugin_Stop;
	}

	g_bAcid[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "AcidHuman5");

	return Plugin_Continue;
}