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

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Meteor Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates meteor showers.",
	version = ST_VERSION,
	url = ST_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Meteor Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MODEL_CONCRETE "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"

#define SOUND_ROCK "player/tank/attack/thrown_missile_loop_1.wav"

#define ST_MENU_METEOR "Meteor Ability"

bool g_bCloneInstalled, g_bMeteor[MAXPLAYERS + 1], g_bMeteor2[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flMeteorChance[ST_MAXTYPES + 1], g_flMeteorDamage[ST_MAXTYPES + 1], g_flMeteorDuration[ST_MAXTYPES + 1], g_flMeteorRadius[ST_MAXTYPES + 1][2];

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iImmunityFlags[ST_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1], g_iMeteorAbility[ST_MAXTYPES + 1], g_iMeteorCount[MAXPLAYERS + 1], g_iMeteorMessage[ST_MAXTYPES + 1], g_iMeteorMode[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_meteor", cmdMeteorInfo, "View information about the Meteor ability.");
}

public void OnMapStart()
{
	PrecacheModel(MODEL_GASCAN, true);
	PrecacheModel(MODEL_PROPANETANK, true);

	PrecacheSound(SOUND_ROCK, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveMeteor(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdMeteorInfo(int client, int args)
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
		case false: vMeteorMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vMeteorMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iMeteorMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Meteor Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Button Mode", "Button Mode");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iMeteorMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iMeteorAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iMeteorCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanMode[ST_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "MeteorDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flMeteorDuration[ST_GetTankType(param1)]);
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vMeteorMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "MeteorMenu", param1);
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
					Format(sMenuOption, sizeof(sMenuOption), "%T", "ButtonMode", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 6:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 7:
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
	menu.AddItem(ST_MENU_METEOR, ST_MENU_METEOR);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_METEOR, false))
	{
		vMeteorMenu(client, 0);
	}
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
		g_iHumanMode[iIndex] = 1;
		g_iMeteorAbility[iIndex] = 0;
		g_iMeteorMessage[iIndex] = 0;
		g_flMeteorChance[iIndex] = 33.3;
		g_flMeteorDamage[iIndex] = 5.0;
		g_flMeteorDuration[iIndex] = 5.0;
		g_iMeteorMode[iIndex] = 0;
		g_flMeteorRadius[iIndex][0] = -180.0;
		g_flMeteorRadius[iIndex][1] = 180.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "meteorability", false) || StrEqual(subsection, "meteor ability", false) || StrEqual(subsection, "meteor_ability", false) || StrEqual(subsection, "meteor", false))
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
		ST_FindAbility(type, 36, bHasAbilities(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor"));
		g_iHumanAbility[type] = iGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iMeteorAbility[type] = iGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iMeteorAbility[type], value, 0, 1);
		g_iMeteorMessage[type] = iGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iMeteorMessage[type], value, 0, 1);
		g_flMeteorChance[type] = flGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "MeteorChance", "Meteor Chance", "Meteor_Chance", "chance", g_flMeteorChance[type], value, 0.0, 100.0);
		g_flMeteorDamage[type] = flGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "MeteorDamage", "Meteor Damage", "Meteor_Damage", "damage", g_flMeteorDamage[type], value, 1.0, 9999999999.0);
		g_flMeteorDuration[type] = flGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "MeteorDuration", "Meteor Duration", "Meteor_Duration", "duration", g_flMeteorDuration[type], value, 0.1, 9999999999.0);
		g_iMeteorMode[type] = iGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "MeteorMode", "Meteor Mode", "Meteor_Mode", "mode", g_iMeteorMode[type], value, 0, 1);

		if (StrEqual(subsection, "meteorability", false) || StrEqual(subsection, "meteor ability", false) || StrEqual(subsection, "meteor_ability", false) || StrEqual(subsection, "meteor", false))
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

		if ((StrEqual(subsection, "meteorability", false) || StrEqual(subsection, "meteor ability", false) || StrEqual(subsection, "meteor_ability", false) || StrEqual(subsection, "meteor", false)) && (StrEqual(key, "MeteorRadius", false) || StrEqual(key, "Meteor Radius", false) || StrEqual(key, "Meteor_Radius", false) || StrEqual(key, "radius", false)) && value[0] != '\0')
		{
			char sSet[2][7], sValue[14];
			strcopy(sValue, sizeof(sValue), value);
			ReplaceString(sValue, sizeof(sValue), " ", "");
			ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

			g_flMeteorRadius[type][0] = (sSet[0][0] != '\0') ? flClamp(StringToFloat(sSet[0]), -200.0, 0.0) : g_flMeteorRadius[type][0];
			g_flMeteorRadius[type][1] = (sSet[1][0] != '\0') ? flClamp(StringToFloat(sSet[1]), 0.0, 200.0) : g_flMeteorRadius[type][1];
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
			vRemoveMeteor(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iMeteorAbility[ST_GetTankType(tank)] == 1 && !g_bMeteor[tank])
	{
		vMeteorAbility(tank);
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
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (g_iMeteorAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[ST_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bMeteor[tank] && !g_bMeteor2[tank])
						{
							vMeteorAbility(tank);
						}
						else if (g_bMeteor[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "MeteorHuman3");
						}
						else if (g_bMeteor2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "MeteorHuman4");
						}
					}
					case 1:
					{
						if (g_iMeteorCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
						{
							if (!g_bMeteor[tank] && !g_bMeteor2[tank])
							{
								g_bMeteor[tank] = true;
								g_iMeteorCount[tank]++;

								vMeteor2(tank);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "MeteorHuman", g_iMeteorCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "MeteorAmmo");
						}
					}
				}
			}
		}
	}
}

public void ST_OnButtonReleased(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (g_iMeteorAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[ST_GetTankType(tank)] == 1 && g_bMeteor[tank] && !g_bMeteor2[tank])
				{
					g_bMeteor[tank] = false;

					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveMeteor(tank);
}

static void vMeteor(int tank, int rock)
{
	if (!ST_IsTankSupported(tank) || (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || !bIsCloneAllowed(tank, g_bCloneInstalled) || !bIsValidEntity(rock))
	{
		return;
	}

	RemoveEntity(rock);

	CreateTimer(3.0, tTimerStopRockSound, _, TIMER_FLAG_NO_MAPCHANGE);

	switch (g_iMeteorMode[ST_GetTankType(tank)])
	{
		case 0:
		{
			float flRockPos[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flRockPos);

			vSpecialAttack(tank, flRockPos, 50.0, MODEL_GASCAN);
			vSpecialAttack(tank, flRockPos, 50.0, MODEL_PROPANETANK);
		}
		case 1:
		{
			float flRockPos[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flRockPos);

			vSpecialAttack(tank, flRockPos, 50.0, MODEL_PROPANETANK);

			float flTankPos[3];
			GetClientAbsOrigin(tank, flTankPos);

			for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
			{
				if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && !ST_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
				{
					float flSurvivorPos[3];
					GetClientAbsOrigin(iSurvivor, flSurvivorPos);

					float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
					if (flDistance < 200.0)
					{
						vDamageEntity(iSurvivor, tank, g_flMeteorDamage[ST_GetTankType(tank)], "16");
					}
				}
			}

			int iPointPush = CreateEntityByName("point_push");
			if (bIsValidEntity(iPointPush))
			{
				SetEntPropEnt(iPointPush, Prop_Send, "m_hOwnerEntity", tank);
				DispatchKeyValueFloat(iPointPush, "magnitude", 600.0);
				DispatchKeyValueFloat(iPointPush, "radius", 200.0);
				DispatchKeyValue(iPointPush, "spawnflags", "8");
				TeleportEntity(iPointPush, flRockPos, NULL_VECTOR, NULL_VECTOR);

				DispatchSpawn(iPointPush);
				AcceptEntityInput(iPointPush, "Enable");

				iPointPush = EntIndexToEntRef(iPointPush);
				vDeleteEntity(iPointPush, 0.5);
			}
		}
	}
}

static void vMeteor2(int tank)
{
	DataPack dpMeteor;
	CreateDataTimer(0.6, tTimerMeteor, dpMeteor, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpMeteor.WriteCell(GetClientUserId(tank));
	dpMeteor.WriteCell(ST_GetTankType(tank));
	dpMeteor.WriteFloat(GetEngineTime());
}

static void vMeteorAbility(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iMeteorCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flMeteorChance[ST_GetTankType(tank)])
		{
			g_bMeteor[tank] = true;

			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bMeteor2[tank])
			{
				g_bMeteor2[tank] = true;
				g_iMeteorCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "MeteorHuman", g_iMeteorCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
			}

			vMeteor2(tank);

			if (g_iMeteorMessage[ST_GetTankType(tank)] == 1)
			{
				char sTankName[33];
				ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Meteor", sTankName);
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "MeteorHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "MeteorAmmo");
	}
}

static void vRemoveMeteor(int tank)
{
	g_bMeteor[tank] = false;
	g_bMeteor2[tank] = false;
	g_iMeteorCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveMeteor(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bMeteor2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "MeteorHuman5");

	if (g_iMeteorCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bMeteor2[tank] = false;
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

public Action tTimerMeteor(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bMeteor[iTank])
	{
		g_bMeteor[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (g_iMeteorAbility[ST_GetTankType(iTank)] == 0 || ((!ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) || (g_iHumanAbility[ST_GetTankType(iTank)] == 1 && g_iHumanMode[ST_GetTankType(iTank)] == 0)) && (flTime + g_flMeteorDuration[ST_GetTankType(iTank)]) < GetEngineTime()))
	{
		g_bMeteor[iTank] = false;

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && g_iHumanMode[ST_GetTankType(iTank)] == 0 && !g_bMeteor2[iTank])
		{
			vReset2(iTank);
		}

		if (g_iMeteorMessage[ST_GetTankType(iTank)] == 1)
		{
			char sTankName[33];
			ST_GetTankName(iTank, ST_GetTankType(iTank), sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Meteor2", sTankName);
		}

		return Plugin_Stop;
	}

	float flPos[3];
	GetClientEyePosition(iTank, flPos);

	float flAngles[3];
	flAngles[0] = GetRandomFloat(-20.0, 20.0);
	flAngles[1] = GetRandomFloat(-20.0, 20.0);
	flAngles[2] = 60.0;
	GetVectorAngles(flAngles, flAngles);
	float flHitpos[3];
	iGetRayHitPos(flPos, flAngles, flHitpos, iTank, true, 2);

	float flDistance = GetVectorDistance(flPos, flHitpos);
	if (flDistance > 1600.0)
	{
		flDistance = 1600.0;
	}

	float flVector[3];
	MakeVectorFromPoints(flPos, flHitpos, flVector);
	NormalizeVector(flVector, flVector);
	ScaleVector(flVector, flDistance - 40.0);
	AddVectors(flPos, flVector, flHitpos);

	if (flDistance > 100.0)
	{
		int iMeteor = CreateEntityByName("tank_rock");
		if (bIsValidEntity(iMeteor))
		{
			SetEntityModel(iMeteor, MODEL_CONCRETE);

			int iRockColor[4];
			ST_GetPropColors(iTank, 4, iRockColor[0], iRockColor[1], iRockColor[2], iRockColor[3]);
			SetEntityRenderColor(iMeteor, iRockColor[0], iRockColor[1], iRockColor[2], iRockColor[3]);

			float flAngles2[3];
			for (int iPos = 0; iPos < 3; iPos++)
			{
				flAngles2[iPos] = GetRandomFloat(g_flMeteorRadius[ST_GetTankType(iTank)][0], g_flMeteorRadius[ST_GetTankType(iTank)][1]);
			}

			float flVelocity[3];
			flVelocity[0] = GetRandomFloat(0.0, 350.0);
			flVelocity[1] = GetRandomFloat(0.0, 350.0);
			flVelocity[2] = GetRandomFloat(0.0, 30.0);

			TeleportEntity(iMeteor, flHitpos, flAngles2, flVelocity);

			DispatchSpawn(iMeteor);
			ActivateEntity(iMeteor);
			AcceptEntityInput(iMeteor, "Ignite");

			SetEntPropEnt(iMeteor, Prop_Send, "m_hOwnerEntity", iTank);
			iMeteor = EntIndexToEntRef(iMeteor);
			vDeleteEntity(iMeteor, 60.0);
		}
	}

	int iMeteor = -1;
	while ((iMeteor = FindEntityByClassname(iMeteor, "tank_rock")) != INVALID_ENT_REFERENCE)
	{
		int iOwner = GetEntPropEnt(iMeteor, Prop_Send, "m_hOwnerEntity");
		if (iTank == iOwner)
		{
			if (flGetGroundUnits(iMeteor) < 200.0)
			{
				vMeteor(iOwner, iMeteor);
			}
		}
	}

	return Plugin_Continue;
}

public Action tTimerStopRockSound(Handle timer)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			StopSound(iPlayer, SNDCHAN_BODY, SOUND_ROCK);
		}
	}
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bMeteor2[iTank])
	{
		g_bMeteor2[iTank] = false;

		return Plugin_Stop;
	}

	g_bMeteor2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "MeteorHuman6");

	return Plugin_Continue;
}