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
	name = "[ST++] Whirl Ability",
	author = ST_AUTHOR,
	description = "The Super Tank makes survivors' screens whirl.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Whirl Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define SPRITE_DOT "sprites/dot.vmt"

#define ST_MENU_WHIRL "Whirl Ability"

bool g_bCloneInstalled, g_bWhirl[MAXPLAYERS + 1], g_bWhirl2[MAXPLAYERS + 1], g_bWhirl3[MAXPLAYERS + 1], g_bWhirl4[MAXPLAYERS + 1], g_bWhirl5[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flWhirlChance[ST_MAXTYPES + 1], g_flWhirlDuration[ST_MAXTYPES + 1], g_flWhirlRange[ST_MAXTYPES + 1], g_flWhirlSpeed[ST_MAXTYPES + 1], g_flWhirlRangeChance[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iWhirlAbility[ST_MAXTYPES + 1], g_iWhirlAxis[ST_MAXTYPES + 1], g_iWhirlCount[MAXPLAYERS + 1], g_iWhirlEffect[ST_MAXTYPES + 1], g_iWhirlHit[ST_MAXTYPES + 1], g_iWhirlHitMode[ST_MAXTYPES + 1], g_iWhirlMessage[ST_MAXTYPES + 1], g_iWhirlOwner[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_whirl", cmdWhirlInfo, "View information about the Whirl ability.");

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
	PrecacheModel(SPRITE_DOT, true);

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

public Action cmdWhirlInfo(int client, int args)
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
		case false: vWhirlMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vWhirlMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iWhirlMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Whirl Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iWhirlMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iWhirlAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iWhirlCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "WhirlDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flWhirlDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vWhirlMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "WhirlMenu", param1);
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
	menu.AddItem(ST_MENU_WHIRL, ST_MENU_WHIRL);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_WHIRL, false))
	{
		vWhirlMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((g_iWhirlHitMode[ST_GetTankType(attacker)] == 0 || g_iWhirlHitMode[ST_GetTankType(attacker)] == 1) && ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsHumanSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vWhirlHit(victim, attacker, g_flWhirlChance[ST_GetTankType(attacker)], g_iWhirlHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if ((g_iWhirlHitMode[ST_GetTankType(victim)] == 0 || g_iWhirlHitMode[ST_GetTankType(victim)] == 2) && ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vWhirlHit(attacker, victim, g_flWhirlChance[ST_GetTankType(victim)], g_iWhirlHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iWhirlAbility[iIndex] = 0;
		g_iWhirlEffect[iIndex] = 0;
		g_iWhirlMessage[iIndex] = 0;
		g_iWhirlAxis[iIndex] = 0;
		g_flWhirlChance[iIndex] = 33.3;
		g_flWhirlDuration[iIndex] = 5.0;
		g_iWhirlHit[iIndex] = 0;
		g_iWhirlHitMode[iIndex] = 0;
		g_flWhirlRange[iIndex] = 150.0;
		g_flWhirlRangeChance[iIndex] = 15.0;
		g_flWhirlSpeed[iIndex] = 500.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	
	g_iHumanAbility[type] = iGetValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iWhirlAbility[type] = iGetValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iWhirlAbility[type], value, 0, 0, 1);
	g_iWhirlEffect[type] = iGetValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iWhirlEffect[type], value, 0, 0, 7);
	g_iWhirlMessage[type] = iGetValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iWhirlMessage[type], value, 0, 0, 3);
	g_iWhirlAxis[type] = iGetValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlAxis", "Whirl Axis", "Whirl_Axis", "axis", main, g_iWhirlAxis[type], value, 0, 0, 7);
	g_flWhirlChance[type] = flGetValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlChance", "Whirl Chance", "Whirl_Chance", "chance", main, g_flWhirlChance[type], value, 33.3, 0.0, 100.0);
	g_flWhirlDuration[type] = flGetValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlDuration", "Whirl Duration", "Whirl_Duration", "duration", main, g_flWhirlDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iWhirlHit[type] = iGetValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlHit", "Whirl Hit", "Whirl_Hit", "hit", main, g_iWhirlHit[type], value, 0, 0, 1);
	g_iWhirlHitMode[type] = iGetValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlHitMode", "Whirl Hit Mode", "Whirl_Hit_Mode", "hitmode", main, g_iWhirlHitMode[type], value, 0, 0, 2);
	g_flWhirlRange[type] = flGetValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlRange", "Whirl Range", "Whirl_Range", "range", main, g_flWhirlRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flWhirlRangeChance[type] = flGetValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlRangeChance", "Whirl Range Chance", "Whirl_Range_Chance", "rangechance", main, g_flWhirlRangeChance[type], value, 15.0, 0.0, 100.0);
	g_flWhirlSpeed[type] = flGetValue(subsection, "whirlability", "whirl ability", "whirl_ability", "whirl", key, "WhirlSpeed", "Whirl Speed", "Whirl_Speed", "speed", main, g_flWhirlSpeed[type], value, 500.0, 1.0, 9999999999.0);
}

public void ST_OnPluginEnd()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bWhirl[iSurvivor])
		{
			SetClientViewEntity(iSurvivor, iSurvivor);
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
			vRemoveWhirl(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iWhirlAbility[ST_GetTankType(tank)] == 1)
	{
		vWhirlAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iWhirlAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bWhirl2[tank] && !g_bWhirl3[tank])
				{
					vWhirlAbility(tank);
				}
				else if (g_bWhirl2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WhirlHuman3");
				}
				else if (g_bWhirl3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WhirlHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveWhirl(tank);
}

static void vRemoveWhirl(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bWhirl[iSurvivor] && g_iWhirlOwner[iSurvivor] == tank)
		{
			g_bWhirl[iSurvivor] = false;
			g_iWhirlOwner[iSurvivor] = 0;
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

			g_iWhirlOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int camera, int messages)
{
	vStopWhirl(survivor, camera);

	SetClientViewEntity(survivor, survivor);

	if (g_iWhirlMessage[ST_GetTankType(tank)] & messages)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Whirl2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bWhirl[tank] = false;
	g_bWhirl2[tank] = false;
	g_bWhirl3[tank] = false;
	g_bWhirl4[tank] = false;
	g_bWhirl5[tank] = false;
	g_iWhirlCount[tank] = 0;
}

static void vStopWhirl(int survivor, int camera)
{
	g_bWhirl[survivor] = false;
	g_iWhirlOwner[survivor] = 0;

	RemoveEntity(camera);
}

static void vWhirlAbility(int tank)
{
	if (g_iWhirlCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bWhirl4[tank] = false;
		g_bWhirl5[tank] = false;

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
				if (flDistance <= g_flWhirlRange[ST_GetTankType(tank)])
				{
					vWhirlHit(iSurvivor, tank, g_flWhirlRangeChance[ST_GetTankType(tank)], g_iWhirlAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "WhirlHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "WhirlAmmo");
	}
}

static void vWhirlHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iWhirlCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bWhirl[survivor])
			{
				int iCamera = CreateEntityByName("env_sprite");
				if (!bIsValidEntity(iCamera))
				{
					return;
				}

				g_bWhirl[survivor] = true;
				g_iWhirlOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bWhirl2[tank])
				{
					g_bWhirl2[tank] = true;
					g_iWhirlCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WhirlHuman", g_iWhirlCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				float flEyePos[3], flAngles[3];
				GetClientEyePosition(survivor, flEyePos);
				GetClientEyeAngles(survivor, flAngles);

				SetEntityModel(iCamera, SPRITE_DOT);
				SetEntityRenderMode(iCamera, RENDER_TRANSCOLOR);
				SetEntityRenderColor(iCamera, 0, 0, 0, 0);
				DispatchSpawn(iCamera);

				TeleportEntity(iCamera, flEyePos, flAngles, NULL_VECTOR);
				TeleportEntity(survivor, NULL_VECTOR, flAngles, NULL_VECTOR);

				vSetEntityParent(iCamera, survivor);
				SetClientViewEntity(survivor, iCamera);

				int iAxis, iAxisCount, iAxes[4];
				for (int iBit = 0; iBit < 3; iBit++)
				{
					int iFlag = (1 << iBit);
					if (!(g_iWhirlAxis[ST_GetTankType(tank)] & iFlag))
					{
						continue;
					}

					iAxes[iAxisCount] = iFlag;
					iAxisCount++;
				}

				switch (iAxes[GetRandomInt(0, iAxisCount - 1)])
				{
					case 1: iAxis = 0;
					case 2: iAxis = 1;
					case 4: iAxis = 2;
					default: iAxis = GetRandomInt(0, 2);
				}

				DataPack dpWhirl;
				CreateDataTimer(0.1, tTimerWhirl, dpWhirl, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpWhirl.WriteCell(EntIndexToEntRef(iCamera));
				dpWhirl.WriteCell(GetClientUserId(survivor));
				dpWhirl.WriteCell(GetClientUserId(tank));
				dpWhirl.WriteCell(ST_GetTankType(tank));
				dpWhirl.WriteCell(messages);
				dpWhirl.WriteCell(enabled);
				dpWhirl.WriteCell(iAxis);
				dpWhirl.WriteFloat(GetEngineTime());

				vEffect(survivor, tank, g_iWhirlEffect[ST_GetTankType(tank)], flags);

				if (g_iWhirlMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Whirl", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bWhirl2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bWhirl4[tank])
				{
					g_bWhirl4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WhirlHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bWhirl5[tank])
		{
			g_bWhirl5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "WhirlAmmo");
		}
	}
}

public Action tTimerWhirl(Handle timer, DataPack pack)
{
	pack.Reset();

	int iCamera = EntRefToEntIndex(pack.ReadCell()), iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || iCamera == INVALID_ENT_REFERENCE || !bIsValidEntity(iCamera))
	{
		g_bWhirl[iSurvivor] = false;
		g_iWhirlOwner[iSurvivor] = 0;

		SetClientViewEntity(iSurvivor, iSurvivor);

		return Plugin_Stop;
	}

	if (!bIsHumanSurvivor(iSurvivor))
	{
		vStopWhirl(iSurvivor, iCamera);

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bWhirl[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iCamera, iMessage);

		return Plugin_Stop;
	}

	int iWhirlEnabled = pack.ReadCell(), iWhirlAxis = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iWhirlEnabled == 0 || (flTime + g_flWhirlDuration[ST_GetTankType(iTank)]) < GetEngineTime())
	{
		g_bWhirl2[iTank] = false;

		vReset2(iSurvivor, iTank, iCamera, iMessage);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bWhirl3[iTank])
		{
			g_bWhirl3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "WhirlHuman6");

			if (g_iWhirlCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bWhirl3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	float flAngles[3];
	GetEntPropVector(iCamera, Prop_Send, "m_angRotation", flAngles);
	flAngles[iWhirlAxis] += g_flWhirlSpeed[ST_GetTankType(iTank)];
	TeleportEntity(iCamera, NULL_VECTOR, flAngles, NULL_VECTOR);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bWhirl3[iTank])
	{
		g_bWhirl3[iTank] = false;

		return Plugin_Stop;
	}

	g_bWhirl3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "WhirlHuman7");

	return Plugin_Continue;
}