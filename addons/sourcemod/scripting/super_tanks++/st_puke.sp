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
	name = "[ST++] Puke Ability",
	author = ST_AUTHOR,
	description = "The Super Tank pukes on survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Puke Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_BLOOD "boomer_explode_D"

#define ST_MENU_PUKE "Puke Ability"

bool g_bCloneInstalled, g_bPuke[MAXPLAYERS + 1], g_bPuke2[MAXPLAYERS + 1], g_bPuke3[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flPukeChance[ST_MAXTYPES + 1], g_flPukeRange[ST_MAXTYPES + 1], g_flPukeRangeChance[ST_MAXTYPES + 1];

Handle g_hSDKPukePlayer;

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iPukeAbility[ST_MAXTYPES + 1], g_iPukeCount[MAXPLAYERS + 1], g_iPukeEffect[ST_MAXTYPES + 1], g_iPukeHit[ST_MAXTYPES + 1], g_iPukeHitMode[ST_MAXTYPES + 1], g_iPukeMessage[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_puke", cmdPukeInfo, "View information about the Puke ability.");

	GameData gdSuperTanks = new GameData("super_tanks++");

	if (gdSuperTanks == null)
	{
		SetFailState("Unable to load the \"super_tanks++\" gamedata file.");
		return;
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDKPukePlayer = EndPrepSDKCall();

	if (g_hSDKPukePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnVomitedUpon\" signature is outdated.", ST_TAG);
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

	vRemovePuke(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdPukeInfo(int client, int args)
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
		case false: vPukeMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vPukeMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iPukeMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Puke Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iPukeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iPukeAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iPukeCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "PukeDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vPukeMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "PukeMenu", param1);
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
	menu.AddItem(ST_MENU_PUKE, ST_MENU_PUKE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_PUKE, false))
	{
		vPukeMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iPukeHitMode[ST_GetTankType(attacker)] == 0 || g_iPukeHitMode[ST_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vPukeHit(victim, attacker, g_flPukeChance[ST_GetTankType(attacker)], g_iPukeHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iPukeHitMode[ST_GetTankType(victim)] == 0 || g_iPukeHitMode[ST_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vPukeHit(attacker, victim, g_flPukeChance[ST_GetTankType(victim)], g_iPukeHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iPukeAbility[iIndex] = 0;
		g_iPukeEffect[iIndex] = 0;
		g_iPukeMessage[iIndex] = 0;
		g_flPukeChance[iIndex] = 33.3;
		g_iPukeHit[iIndex] = 0;
		g_iPukeHitMode[iIndex] = 0;
		g_flPukeRange[iIndex] = 150.0;
		g_flPukeRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	ST_FindAbility(type, 43, bHasAbilities(subsection, "pukeability", "puke ability", "puke_ability", "puke"));
	g_iHumanAbility[type] = iGetValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iPukeAbility[type] = iGetValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iPukeAbility[type], value, 0, 0, 1);
	g_iPukeEffect[type] = iGetValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iPukeEffect[type], value, 0, 0, 7);
	g_iPukeMessage[type] = iGetValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iPukeMessage[type], value, 0, 0, 3);
	g_flPukeChance[type] = flGetValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeChance", "Puke Chance", "Puke_Chance", "chance", main, g_flPukeChance[type], value, 33.3, 0.0, 100.0);
	g_iPukeHit[type] = iGetValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeHit", "Puke Hit", "Puke_Hit", "hit", main, g_iPukeHit[type], value, 0, 0, 1);
	g_iPukeHitMode[type] = iGetValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeHitMode", "Puke Hit Mode", "Puke_Hit_Mode", "hitmode", main, g_iPukeHitMode[type], value, 0, 0, 2);
	g_flPukeRange[type] = flGetValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeRange", "Puke Range", "Puke_Range", "range", main, g_flPukeRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flPukeRangeChance[type] = flGetValue(subsection, "pukeability", "puke ability", "puke_ability", "puke", key, "PukeRangeChance", "Puke Range Chance", "Puke_Range_Chance", "rangechance", main, g_flPukeRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			if (bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iPukeAbility[ST_GetTankType(iTank)] == 1)
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

			vRemovePuke(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iPukeAbility[ST_GetTankType(tank)] == 1)
	{
		vPukeAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iPukeAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_bPuke[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "PukeHuman3");
					case false: vPukeAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemovePuke(tank);
}

static void vPukeAbility(int tank)
{
	if (g_iPukeCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bPuke2[tank] = false;
		g_bPuke3[tank] = false;

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
				if (flDistance <= g_flPukeRange[ST_GetTankType(tank)])
				{
					vPukeHit(iSurvivor, tank, g_flPukeRangeChance[ST_GetTankType(tank)], g_iPukeAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "PukeHuman4");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "PukeAmmo");
	}
}

static void vPukeHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iPukeCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bPuke[tank])
				{
					g_bPuke[tank] = true;
					g_iPukeCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "PukeHuman", g_iPukeCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);

					if (g_iPukeCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
					{
						CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bPuke[tank] = false;
					}
				}

				SDKCall(g_hSDKPukePlayer, survivor, tank, true);

				vEffect(survivor, tank, g_iPukeEffect[ST_GetTankType(tank)], flags);

				if (g_iPukeMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Puke", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bPuke[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bPuke2[tank])
				{
					g_bPuke2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "PukeHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bPuke3[tank])
		{
			g_bPuke3[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "PukeAmmo");
		}
	}
}

static void vRemovePuke(int tank)
{
	g_bPuke[tank] = false;
	g_bPuke2[tank] = false;
	g_bPuke3[tank] = false;
	g_iPukeCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemovePuke(iPlayer);
		}
	}
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bPuke[iTank])
	{
		g_bPuke[iTank] = false;

		return Plugin_Stop;
	}

	g_bPuke[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "PukeHuman5");

	return Plugin_Continue;
}