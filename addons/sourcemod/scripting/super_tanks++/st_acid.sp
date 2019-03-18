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

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iAcidAbility[ST_MAXTYPES + 1], g_iAcidCount[MAXPLAYERS + 1], g_iAcidEffect[ST_MAXTYPES + 1], g_iAcidHit[ST_MAXTYPES + 1], g_iAcidHitMode[ST_MAXTYPES + 1], g_iAcidMessage[ST_MAXTYPES + 1], g_iAcidRockBreak[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iImmunityFlags[ST_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1];

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
			if ((!ST_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || ST_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vAcidHit(victim, attacker, g_flAcidChance[ST_GetTankType(attacker)], g_iAcidHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iAcidHitMode[ST_GetTankType(victim)] == 0 || g_iAcidHitMode[ST_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if ((!ST_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || ST_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vAcidHit(attacker, victim, g_flAcidChance[ST_GetTankType(victim)], g_iAcidHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

public void ST_OnConfigsLoad()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_iAccessFlags2[iPlayer] = 0;
			g_iImmunityFlags2[iPlayer] = 0;
		}
	}

	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iAccessFlags[iIndex] = 0;
		g_iImmunityFlags[iIndex] = 0;
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

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "acidability", false) || StrEqual(subsection, "acid ability", false) || StrEqual(subsection, "acid_ability", false) || StrEqual(subsection, "acid", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_iImmunityFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iImmunityFlags2[admin];
			}
		}
	}

	if (type > 0)
	{
		ST_FindAbility(type, 1, bHasAbilities(subsection, "acidability", "acid ability", "acid_ability", "acid"));
		g_iHumanAbility[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iAcidAbility[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iAcidAbility[type], value, 0, 1);
		g_iAcidEffect[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_iAcidEffect[type], value, 0, 7);
		g_iAcidMessage[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iAcidMessage[type], value, 0, 7);
		g_flAcidChance[type] = flGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AcidChance", "Acid Chance", "Acid_Chance", "chance", g_flAcidChance[type], value, 0.0, 100.0);
		g_iAcidHit[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AcidHit", "Acid Hit", "Acid_Hit", "hit", g_iAcidHit[type], value, 0, 1);
		g_iAcidHitMode[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AcidHitMode", "Acid Hit Mode", "Acid_Hit_Mode", "hitmode", g_iAcidHitMode[type], value, 0, 2);
		g_flAcidRange[type] = flGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AcidRange", "Acid Range", "Acid_Range", "range", g_flAcidRange[type], value, 1.0, 9999999999.0);
		g_flAcidRangeChance[type] = flGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AcidRangeChance", "Acid Range Chance", "Acid_Range_Chance", "rangechance", g_flAcidRangeChance[type], value, 0.0, 100.0);
		g_iAcidRockBreak[type] = iGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AcidRockBreak", "Acid Rock Break", "Acid_Rock_Break", "rock", g_iAcidRockBreak[type], value, 0, 1);
		g_flAcidRockChance[type] = flGetValue(subsection, "acidability", "acid ability", "acid_ability", "acid", key, "AcidRockChance", "Acid Rock Chance", "Acid_Rock_Chance", "rockchance", g_flAcidRockChance[type], value, 0.0, 100.0);

		if (StrEqual(subsection, "acidability", false) || StrEqual(subsection, "acid ability", false) || StrEqual(subsection, "acid_ability", false) || StrEqual(subsection, "acid", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags[type];
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_iImmunityFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iImmunityFlags[type];
			}
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveAcid(iTank);

			if (bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iAcidAbility[ST_GetTankType(iTank)] == 1)
			{
				if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && ((ST_HasAdminAccess(iTank) && bHasAdminAccess(iTank)) || g_iHumanAbility[ST_GetTankType(iTank)] == 0))
				{
					return;
				}

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
							if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && !ST_IsAdminImmune(iSurvivor, iTank) && !bIsAdminImmune(iSurvivor, iTank))
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
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iAcidAbility[ST_GetTankType(tank)] == 1)
	{
		vAcidAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

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
	vRemoveAcid(tank);

	if (ST_IsTankSupported(tank) && bIsCloneAllowed(tank, g_bCloneInstalled) && bIsValidGame() && g_iAcidAbility[ST_GetTankType(tank)] == 1)
	{
		if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
		{
			return;
		}

		vAcid(tank, tank);
	}
}

public void ST_OnRockBreak(int tank, int rock)
{
	if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

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
				ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Acid2", sTankName);
			}
		}
	}
}

static void vAcid(int survivor, int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	float flOrigin[3], flAngles[3];
	GetClientAbsOrigin(survivor, flOrigin);
	GetClientAbsAngles(survivor, flAngles);

	SDKCall(g_hSDKAcidPlayer, flOrigin, flAngles, flAngles, flAngles, tank, 2.0);
}

static void vAcidAbility(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iAcidCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bAcid2[tank] = false;
		g_bAcid3[tank] = false;

		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && !ST_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
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
	if ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || ST_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

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
				ST_GetTankName(tank, ST_GetTankType(tank), sTankName);

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

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, ST_CHECK_INGAME|ST_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_iAccessFlags[ST_GetTankType(admin)];
	if (iAbilityFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iAbilityFlags))
		{
			return false;
		}
	}

	int iTypeFlags = ST_GetAccessFlags(2, ST_GetTankType(admin));
	if (iTypeFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iTypeFlags))
		{
			return false;
		}
	}

	int iGlobalFlags = ST_GetAccessFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iGlobalFlags))
		{
			return false;
		}
	}

	int iClientTypeFlags = ST_GetAccessFlags(4, ST_GetTankType(admin), admin);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0 && !(iClientTypeFlags & iAbilityFlags))
		{
			return false;
		}
	}

	int iClientGlobalFlags = ST_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0 && !(iClientGlobalFlags & iAbilityFlags))
		{
			return false;
		}
	}

	return true;
}

static bool bIsAdminImmune(int survivor, int tank)
{
	if (!bIsValidClient(survivor, ST_CHECK_INGAME|ST_CHECK_FAKECLIENT))
	{
		return false;
	}

	int iAbilityFlags = g_iImmunityFlags[ST_GetTankType(survivor)];
	if (iAbilityFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iAbilityFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iTypeFlags = ST_GetImmunityFlags(2, ST_GetTankType(survivor));
	if (iTypeFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iTypeFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iGlobalFlags = ST_GetImmunityFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iGlobalFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iClientTypeFlags = ST_GetImmunityFlags(4, ST_GetTankType(tank), survivor),
		iClientTypeFlags2 = ST_GetImmunityFlags(4, ST_GetTankType(tank), tank);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0 && (iClientTypeFlags & iAbilityFlags))
		{
			return ((iClientTypeFlags2 & iAbilityFlags) && iClientTypeFlags <= iClientTypeFlags2) ? false : true;
		}
	}

	int iClientGlobalFlags = ST_GetImmunityFlags(3, 0, survivor),
		iClientGlobalFlags2 = ST_GetImmunityFlags(3, 0, tank);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0 && (iClientGlobalFlags & iAbilityFlags))
		{
			return ((iClientGlobalFlags2 & iAbilityFlags) && iClientGlobalFlags <= iClientGlobalFlags2) ? false : true;
		}
	}

	return false;
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