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
	name = "[ST++] Ice Ability",
	author = ST_AUTHOR,
	description = "The Super Tank freezes survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Ice Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define SOUND_BULLET "physics/glass/glass_impact_bullet4.wav"

#define ST_MENU_ICE "Ice Ability"

bool g_bCloneInstalled, g_bIce[MAXPLAYERS + 1], g_bIce2[MAXPLAYERS + 1], g_bIce3[MAXPLAYERS + 1], g_bIce4[MAXPLAYERS + 1], g_bIce5[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flIceChance[ST_MAXTYPES + 1], g_flIceDuration[ST_MAXTYPES + 1], g_flIceRange[ST_MAXTYPES + 1], g_flIceRangeChance[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iIceAbility[ST_MAXTYPES + 1], g_iIceCount[MAXPLAYERS + 1], g_iIceEffect[ST_MAXTYPES + 1], g_iIceHit[ST_MAXTYPES + 1], g_iIceHitMode[ST_MAXTYPES + 1], g_iIceMessage[ST_MAXTYPES + 1], g_iIceOwner[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_ice", cmdIceInfo, "View information about the Ice ability.");

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
	PrecacheSound(SOUND_BULLET, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vReset2(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdIceInfo(int client, int args)
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
		case false: vIceMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vIceMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iIceMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Ice Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iIceMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iIceAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iIceCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "IceDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flIceDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vIceMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "IceMenu", param1);
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
	menu.AddItem(ST_MENU_ICE, ST_MENU_ICE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_ICE, false))
	{
		vIceMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((g_iIceHitMode[ST_GetTankType(attacker)] == 0 || g_iIceHitMode[ST_GetTankType(attacker)] == 1) && ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vIceHit(victim, attacker, g_flIceChance[ST_GetTankType(attacker)], g_iIceHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if ((g_iIceHitMode[ST_GetTankType(victim)] == 0 || g_iIceHitMode[ST_GetTankType(victim)] == 2) && ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vIceHit(attacker, victim, g_flIceChance[ST_GetTankType(victim)], g_iIceHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iIceAbility[iIndex] = 0;
		g_iIceEffect[iIndex] = 0;
		g_iIceMessage[iIndex] = 0;
		g_flIceChance[iIndex] = 33.3;
		g_flIceDuration[iIndex] = 5.0;
		g_iIceHit[iIndex] = 0;
		g_iIceHitMode[iIndex] = 0;
		g_flIceRange[iIndex] = 150.0;
		g_flIceRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	ST_FindAbility(type, 27, bHasAbilities(subsection, "iceability", "ice ability", "ice_ability", "ice"));
	g_iHumanAbility[type] = iGetValue(subsection, "iceability", "ice ability", "ice_ability", "ice", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "iceability", "ice ability", "ice_ability", "ice", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "iceability", "ice ability", "ice_ability", "ice", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iIceAbility[type] = iGetValue(subsection, "iceability", "ice ability", "ice_ability", "ice", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iIceAbility[type], value, 0, 0, 1);
	g_iIceEffect[type] = iGetValue(subsection, "iceability", "ice ability", "ice_ability", "ice", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iIceEffect[type], value, 0, 0, 7);
	g_iIceMessage[type] = iGetValue(subsection, "iceability", "ice ability", "ice_ability", "ice", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iIceMessage[type], value, 0, 0, 3);
	g_flIceChance[type] = flGetValue(subsection, "iceability", "ice ability", "ice_ability", "ice", key, "IceChance", "Ice Chance", "Ice_Chance", "chance", main, g_flIceChance[type], value, 33.3, 0.0, 100.0);
	g_flIceDuration[type] = flGetValue(subsection, "iceability", "ice ability", "ice_ability", "ice", key, "IceDuration", "Ice Duration", "Ice_Duration", "duration", main, g_flIceDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iIceHit[type] = iGetValue(subsection, "iceability", "ice ability", "ice_ability", "ice", key, "IceHit", "Ice Hit", "Ice_Hit", "hit", main, g_iIceHit[type], value, 0, 0, 1);
	g_iIceHitMode[type] = iGetValue(subsection, "iceability", "ice ability", "ice_ability", "ice", key, "IceHitMode", "Ice Hit Mode", "Ice_Hit_Mode", "hitmode", main, g_iIceHitMode[type], value, 0, 0, 2);
	g_flIceRange[type] = flGetValue(subsection, "iceability", "ice ability", "ice_ability", "ice", key, "IceRange", "Ice Range", "Ice_Range", "range", main, g_flIceRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flIceRangeChance[type] = flGetValue(subsection, "iceability", "ice ability", "ice_ability", "ice", key, "IceRangeChance", "Ice Range Chance", "Ice_Range_Chance", "rangechance", main, g_flIceRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
		{
			vRemoveIce(iTank);
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
			vRemoveIce(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iIceAbility[ST_GetTankType(tank)] == 1)
	{
		vIceAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iIceAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bIce2[tank] && !g_bIce3[tank])
				{
					vIceAbility(tank);
				}
				else if (g_bIce2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "IceHuman3");
				}
				else if (g_bIce3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "IceHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveIce(tank);
}

static void vIceAbility(int tank)
{
	if (g_iIceCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bIce4[tank] = false;
		g_bIce5[tank] = false;

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
				if (flDistance <= g_flIceRange[ST_GetTankType(tank)])
				{
					vIceHit(iSurvivor, tank, g_flIceRangeChance[ST_GetTankType(tank)], g_iIceAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "IceHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "IceAmmo");
	}
}

static void vIceHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iIceCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bIce[survivor])
			{
				g_bIce[survivor] = true;
				g_iIceOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bIce2[tank])
				{
					g_bIce2[tank] = true;
					g_iIceCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "IceHuman", g_iIceCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				float flPos[3];
				GetClientEyePosition(survivor, flPos);

				if (GetEntityMoveType(survivor) != MOVETYPE_NONE)
				{
					SetEntityMoveType(survivor, MOVETYPE_NONE);
				}

				SetEntityRenderColor(survivor, 0, 130, 255, 190);
				EmitAmbientSound(SOUND_BULLET, flPos, survivor, SNDLEVEL_RAIDSIREN);

				DataPack dpStopIce;
				CreateDataTimer(g_flIceDuration[ST_GetTankType(tank)], tTimerStopIce, dpStopIce, TIMER_FLAG_NO_MAPCHANGE);
				dpStopIce.WriteCell(GetClientUserId(survivor));
				dpStopIce.WriteCell(GetClientUserId(tank));
				dpStopIce.WriteCell(messages);

				vEffect(survivor, tank, g_iIceEffect[ST_GetTankType(tank)], flags);

				if (g_iIceMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Ice", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bIce2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bIce4[tank])
				{
					g_bIce4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "IceHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bIce5[tank])
		{
			g_bIce5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "IceAmmo");
		}
	}
}

static void vRemoveIce(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bIce[iSurvivor] && g_iIceOwner[iSurvivor] == tank)
		{
			vStopIce(iSurvivor);
		}
	}

	vReset2(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vReset2(iPlayer);

			g_iIceOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_bIce[tank] = false;
	g_bIce2[tank] = false;
	g_bIce3[tank] = false;
	g_bIce4[tank] = false;
	g_bIce5[tank] = false;
	g_iIceCount[tank] = 0;
}

static void vStopIce(int survivor)
{
	g_bIce[survivor] = false;
	g_iIceOwner[survivor] = 0;

	float flPos[3];
	GetClientEyePosition(survivor, flPos);

	if (GetEntityMoveType(survivor) == MOVETYPE_NONE)
	{
		SetEntityMoveType(survivor, MOVETYPE_WALK);
	}

	TeleportEntity(survivor, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
	SetEntityRenderColor(survivor, 255, 255, 255, 255);
	EmitAmbientSound(SOUND_BULLET, flPos, survivor, SNDLEVEL_RAIDSIREN);
}

public Action tTimerStopIce(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bIce[iSurvivor] = false;
		g_iIceOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bIce[iSurvivor])
	{
		vStopIce(iSurvivor);

		return Plugin_Stop;
	}

	g_bIce2[iTank] = false;

	vStopIce(iSurvivor);

	int iMessage = pack.ReadCell();

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bIce3[iTank])
	{
		g_bIce3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "IceHuman6");

		if (g_iIceCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
		{
			CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bIce3[iTank] = false;
		}
	}

	if (g_iIceMessage[ST_GetTankType(iTank)] & iMessage)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Ice2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bIce3[iTank])
	{
		g_bIce3[iTank] = false;

		return Plugin_Stop;
	}

	g_bIce3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "IceHuman7");

	return Plugin_Continue;
}