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
	name = "[ST++] Vision Ability",
	author = ST_AUTHOR,
	description = "The Super Tank changes the survivors' field of view.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Vision Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_VISION "Vision Ability"

bool g_bCloneInstalled, g_bVision[MAXPLAYERS + 1], g_bVision2[MAXPLAYERS + 1], g_bVision3[MAXPLAYERS + 1], g_bVision4[MAXPLAYERS + 1], g_bVision5[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flVisionChance[ST_MAXTYPES + 1], g_flVisionDuration[ST_MAXTYPES + 1], g_flVisionRange[ST_MAXTYPES + 1], g_flVisionRangeChance[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iVisionAbility[ST_MAXTYPES + 1], g_iVisionCount[MAXPLAYERS + 1], g_iVisionEffect[ST_MAXTYPES + 1], g_iVisionFOV[ST_MAXTYPES + 1], g_iVisionHit[ST_MAXTYPES + 1], g_iVisionHitMode[ST_MAXTYPES + 1], g_iVisionMessage[ST_MAXTYPES + 1], g_iVisionOwner[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_vision", cmdVisionInfo, "View information about the Vision ability.");

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

public Action cmdVisionInfo(int client, int args)
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
		case false: vVisionMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vVisionMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iVisionMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Vision Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iVisionMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iVisionAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iVisionCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "VisionDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flVisionDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vVisionMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "VisionMenu", param1);
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
	menu.AddItem(ST_MENU_VISION, ST_MENU_VISION);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_VISION, false))
	{
		vVisionMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((g_iVisionHitMode[ST_GetTankType(attacker)] == 0 || g_iVisionHitMode[ST_GetTankType(attacker)] == 1) && ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsHumanSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vVisionHit(victim, attacker, g_flVisionChance[ST_GetTankType(attacker)], g_iVisionHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if ((g_iVisionHitMode[ST_GetTankType(victim)] == 0 || g_iVisionHitMode[ST_GetTankType(victim)] == 2) && ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vVisionHit(attacker, victim, g_flVisionChance[ST_GetTankType(victim)], g_iVisionHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iVisionAbility[iIndex] = 0;
		g_iVisionEffect[iIndex] = 0;
		g_iVisionMessage[iIndex] = 0;
		g_flVisionChance[iIndex] = 33.3;
		g_flVisionDuration[iIndex] = 5.0;
		g_iVisionFOV[iIndex] = 160;
		g_iVisionHit[iIndex] = 0;
		g_iVisionHitMode[iIndex] = 0;
		g_flVisionRange[iIndex] = 150.0;
		g_flVisionRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	g_iHumanAbility[type] = iGetValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iVisionAbility[type] = iGetValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iVisionAbility[type], value, 0, 0, 1);
	g_iVisionEffect[type] = iGetValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iVisionEffect[type], value, 0, 0, 7);
	g_iVisionMessage[type] = iGetValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iVisionMessage[type], value, 0, 0, 3);
	g_flVisionChance[type] = flGetValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionChance", "Vision Chance", "Vision_Chance", "chance", main, g_flVisionChance[type], value, 33.3, 0.0, 100.0);
	g_flVisionDuration[type] = flGetValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionDuration", "Vision Duration", "Vision_Duration", "duration", main, g_flVisionDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iVisionFOV[type] = iGetValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionFOV", "Vision FOV", "Vision_FOV", "fov", main, g_iVisionFOV[type], value, 160, 1, 160);
	g_iVisionHit[type] = iGetValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionHit", "Vision Hit", "Vision_Hit", "hit", main, g_iVisionHit[type], value, 0, 0, 1);
	g_iVisionHitMode[type] = iGetValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionHitMode", "Vision Hit Mode", "Vision_Hit_Mode", "hitmode", main, g_iVisionHitMode[type], value, 0, 0, 2);
	g_flVisionRange[type] = flGetValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionRange", "Vision Range", "Vision_Range", "range", main, g_flVisionRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flVisionRangeChance[type] = flGetValue(subsection, "visionability", "vision ability", "vision_ability", "vision", key, "VisionRangeChance", "Vision Range Chance", "Vision_Range_Chance", "rangechance", main, g_flVisionRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnPluginEnd()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bVision[iSurvivor])
		{
			SetEntProp(iSurvivor, Prop_Send, "m_iFOV", 90);
			SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", 90);
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
			vRemoveVision(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iVisionAbility[ST_GetTankType(tank)] == 1)
	{
		vVisionAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iVisionAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bVision2[tank] && !g_bVision3[tank])
				{
					vVisionAbility(tank);
				}
				else if (g_bVision2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "VisionHuman3");
				}
				else if (g_bVision3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "VisionHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveVision(tank);
}

static void vRemoveVision(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bVision[iSurvivor] && g_iVisionOwner[iSurvivor] == tank)
		{
			g_bVision[iSurvivor] = false;
			g_iVisionOwner[iSurvivor] = 0;
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

			g_iVisionOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_bVision[survivor] = false;
	g_iVisionOwner[survivor] = 0;

	SetEntProp(survivor, Prop_Send, "m_iFOV", 90);
	SetEntProp(survivor, Prop_Send, "m_iDefaultFOV", 90);

	if (g_iVisionMessage[ST_GetTankType(tank)] & messages)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Vision2", survivor, 90);
	}
}

static void vReset3(int tank)
{
	g_bVision[tank] = false;
	g_bVision2[tank] = false;
	g_bVision3[tank] = false;
	g_bVision4[tank] = false;
	g_bVision5[tank] = false;
	g_iVisionCount[tank] = 0;
}

static void vVisionAbility(int tank)
{
	if (g_iVisionCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bVision4[tank] = false;
		g_bVision5[tank] = false;

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
				if (flDistance <= g_flVisionRange[ST_GetTankType(tank)])
				{
					vVisionHit(iSurvivor, tank, g_flVisionRangeChance[ST_GetTankType(tank)], g_iVisionAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "VisionHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "VisionAmmo");
	}
}

static void vVisionHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iVisionCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bVision[survivor])
			{
				g_bVision[survivor] = true;
				g_iVisionOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bVision2[tank])
				{
					g_bVision2[tank] = true;
					g_iVisionCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "VisionHuman", g_iVisionCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				DataPack dpVision;
				CreateDataTimer(0.1, tTimerVision, dpVision, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpVision.WriteCell(GetClientUserId(survivor));
				dpVision.WriteCell(GetClientUserId(tank));
				dpVision.WriteCell(ST_GetTankType(tank));
				dpVision.WriteCell(messages);
				dpVision.WriteCell(enabled);
				dpVision.WriteFloat(GetEngineTime());

				vEffect(survivor, tank, g_iVisionEffect[ST_GetTankType(tank)], flags);

				if (g_iVisionMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Vision", sTankName, survivor, g_iVisionFOV[ST_GetTankType(tank)]);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bVision2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bVision4[tank])
				{
					g_bVision4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "VisionHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bVision5[tank])
		{
			g_bVision5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "VisionAmmo");
		}
	}
}

public Action tTimerVision(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsHumanSurvivor(iSurvivor))
	{
		g_bVision[iSurvivor] = false;
		g_iVisionOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bVision[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iVisionEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iVisionEnabled == 0 || (flTime + g_flVisionDuration[ST_GetTankType(iTank)]) < GetEngineTime())
	{
		g_bVision2[iTank] = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bVision3[iTank])
		{
			g_bVision3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "VisionHuman6");

			if (g_iVisionCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bVision3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	SetEntProp(iSurvivor, Prop_Send, "m_iFOV", g_iVisionFOV[ST_GetTankType(iTank)]);
	SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", g_iVisionFOV[ST_GetTankType(iTank)]);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bVision3[iTank])
	{
		g_bVision3[iTank] = false;

		return Plugin_Stop;
	}

	g_bVision3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "VisionHuman7");

	return Plugin_Continue;
}