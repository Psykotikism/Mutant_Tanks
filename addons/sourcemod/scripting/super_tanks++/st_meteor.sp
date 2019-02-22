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

bool g_bCloneInstalled, g_bMeteor[MAXPLAYERS + 1], g_bMeteor2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sMeteorRadius[ST_MAXTYPES + 1][13], g_sMeteorRadius2[ST_MAXTYPES + 1][13];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flMeteorChance[ST_MAXTYPES + 1], g_flMeteorChance2[ST_MAXTYPES + 1], g_flMeteorDamage[ST_MAXTYPES + 1], g_flMeteorDamage2[ST_MAXTYPES + 1], g_flMeteorDuration[ST_MAXTYPES + 1], g_flMeteorDuration2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1], g_iMeteorAbility[ST_MAXTYPES + 1], g_iMeteorAbility2[ST_MAXTYPES + 1], g_iMeteorCount[MAXPLAYERS + 1], g_iMeteorMessage[ST_MAXTYPES + 1], g_iMeteorMessage2[ST_MAXTYPES + 1], g_iMeteorMode[ST_MAXTYPES + 1], g_iMeteorMode2[ST_MAXTYPES + 1];

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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iMeteorAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iMeteorCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "MeteorDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flMeteorDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Meteor Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iMeteorAbility[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Ability Enabled", 0);
					g_iMeteorAbility[iIndex] = iClamp(g_iMeteorAbility[iIndex], 0, 1);
					g_iMeteorMessage[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Ability Message", 0);
					g_iMeteorMessage[iIndex] = iClamp(g_iMeteorMessage[iIndex], 0, 1);
					g_flMeteorChance[iIndex] = kvSuperTanks.GetFloat("Meteor Ability/Meteor Chance", 33.3);
					g_flMeteorChance[iIndex] = flClamp(g_flMeteorChance[iIndex], 0.0, 100.0);
					g_flMeteorDamage[iIndex] = kvSuperTanks.GetFloat("Meteor Ability/Meteor Damage", 5.0);
					g_flMeteorDamage[iIndex] = flClamp(g_flMeteorDamage[iIndex], 1.0, 9999999999.0);
					g_flMeteorDuration[iIndex] = kvSuperTanks.GetFloat("Meteor Ability/Meteor Duration", 5.0);
					g_flMeteorDuration[iIndex] = flClamp(g_flMeteorDuration[iIndex], 0.1, 9999999999.0);
					g_iMeteorMode[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Meteor Mode", 0);
					g_iMeteorMode[iIndex] = iClamp(g_iMeteorMode[iIndex], 0, 1);
					kvSuperTanks.GetString("Meteor Ability/Meteor Radius", g_sMeteorRadius[iIndex], sizeof(g_sMeteorRadius[]), "-180.0,180.0");
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Meteor Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iMeteorAbility2[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Ability Enabled", g_iMeteorAbility[iIndex]);
					g_iMeteorAbility2[iIndex] = iClamp(g_iMeteorAbility2[iIndex], 0, 1);
					g_iMeteorMessage2[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Ability Message", g_iMeteorMessage[iIndex]);
					g_iMeteorMessage2[iIndex] = iClamp(g_iMeteorMessage2[iIndex], 0, 1);
					g_flMeteorChance2[iIndex] = kvSuperTanks.GetFloat("Meteor Ability/Meteor Chance", g_flMeteorChance[iIndex]);
					g_flMeteorChance2[iIndex] = flClamp(g_flMeteorChance2[iIndex], 0.0, 100.0);
					g_flMeteorDamage2[iIndex] = kvSuperTanks.GetFloat("Meteor Ability/Meteor Damage", g_flMeteorDamage[iIndex]);
					g_flMeteorDamage2[iIndex] = flClamp(g_flMeteorDamage2[iIndex], 1.0, 9999999999.0);
					g_flMeteorDuration2[iIndex] = kvSuperTanks.GetFloat("Meteor Ability/Meteor Duration", g_flMeteorDuration[iIndex]);
					g_flMeteorDuration2[iIndex] = flClamp(g_flMeteorDuration2[iIndex], 0.1, 9999999999.0);
					g_iMeteorMode2[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Meteor Mode", g_iMeteorMode[iIndex]);
					g_iMeteorMode2[iIndex] = iClamp(g_iMeteorMode2[iIndex], 0, 1);
					kvSuperTanks.GetString("Meteor Ability/Meteor Radius", g_sMeteorRadius2[iIndex], sizeof(g_sMeteorRadius2[]), g_sMeteorRadius[iIndex]);
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
			vRemoveMeteor(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iMeteorAbility(tank) == 1 && !g_bMeteor[tank])
	{
		vMeteorAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iMeteorAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
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
						if (g_iMeteorCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bMeteor[tank] && !g_bMeteor2[tank])
							{
								g_bMeteor[tank] = true;
								g_iMeteorCount[tank]++;

								vMeteor2(tank);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "MeteorHuman", g_iMeteorCount[tank], iHumanAmmo(tank));
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
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iMeteorAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bMeteor[tank] && !g_bMeteor2[tank])
				{
					g_bMeteor[tank] = false;

					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveMeteor(tank);
}

static void vMeteor(int tank, int rock)
{
	if (!ST_IsTankSupported(tank) || !ST_IsCloneSupported(tank, g_bCloneInstalled) || !bIsValidEntity(rock))
	{
		return;
	}

	RemoveEntity(rock);

	CreateTimer(3.0, tTimerStopRockSound, _, TIMER_FLAG_NO_MAPCHANGE);

	int iMeteorMode = !g_bTankConfig[ST_GetTankType(tank)] ? g_iMeteorMode[ST_GetTankType(tank)] : g_iMeteorMode2[ST_GetTankType(tank)];
	switch (iMeteorMode)
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
				if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
				{
					float flSurvivorPos[3];
					GetClientAbsOrigin(iSurvivor, flSurvivorPos);

					float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
					if (flDistance < 200.0)
					{
						float flMeteorDamage = !g_bTankConfig[ST_GetTankType(tank)] ? g_flMeteorDamage[ST_GetTankType(tank)] : g_flMeteorDamage2[ST_GetTankType(tank)];
						vDamageEntity(iSurvivor, tank, flMeteorDamage, "16");
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
	if (g_iMeteorCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		float flMeteorChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flMeteorChance[ST_GetTankType(tank)] : g_flMeteorChance2[ST_GetTankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flMeteorChance)
		{
			g_bMeteor[tank] = true;

			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && !g_bMeteor2[tank])
			{
				g_bMeteor2[tank] = true;
				g_iMeteorCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "MeteorHuman", g_iMeteorCount[tank], iHumanAmmo(tank));
			}

			vMeteor2(tank);

			if (iMeteorMessage(tank) == 1)
			{
				char sTankName[33];
				ST_GetTankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Meteor", sTankName);
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "MeteorHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
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

	if (g_iMeteorCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bMeteor2[tank] = false;
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flMeteorDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flMeteorDuration[ST_GetTankType(tank)] : g_flMeteorDuration2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iHumanMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanMode[ST_GetTankType(tank)] : g_iHumanMode2[ST_GetTankType(tank)];
}

static int iMeteorAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iMeteorAbility[ST_GetTankType(tank)] : g_iMeteorAbility2[ST_GetTankType(tank)];
}

static int iMeteorMessage(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iMeteorMessage[ST_GetTankType(tank)] : g_iMeteorMessage2[ST_GetTankType(tank)];
}

public Action tTimerMeteor(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bMeteor[iTank])
	{
		g_bMeteor[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (iMeteorAbility(iTank) == 0 || ((!ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) || (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0)) && (flTime + flMeteorDuration(iTank)) < GetEngineTime()))
	{
		g_bMeteor[iTank] = false;

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0 && !g_bMeteor2[iTank])
		{
			vReset2(iTank);
		}

		if (iMeteorMessage(iTank) == 1)
		{
			char sTankName[33];
			ST_GetTankName(iTank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Meteor2", sTankName);
		}

		return Plugin_Stop;
	}

	char sRadius[2][7], sMeteorRadius[13];
	sMeteorRadius = !g_bTankConfig[ST_GetTankType(iTank)] ? g_sMeteorRadius[ST_GetTankType(iTank)] : g_sMeteorRadius2[ST_GetTankType(iTank)];
	ReplaceString(sMeteorRadius, sizeof(sMeteorRadius), " ", "");
	ExplodeString(sMeteorRadius, ",", sRadius, sizeof(sRadius), sizeof(sRadius[]));

	float flMin = (sRadius[0][0] != '\0') ? StringToFloat(sRadius[0]) : -200.0,
		flMax = (sRadius[1][0] != '\0') ? StringToFloat(sRadius[1]) : 200.0;
	flMin = flClamp(flMin, -200.0, 0.0);
	flMax = flClamp(flMax, 0.0, 200.0);

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

			int iRockRed, iRockGreen, iRockBlue, iRockAlpha;
			ST_GetPropColors(iTank, 4, iRockRed, iRockGreen, iRockBlue, iRockAlpha);
			SetEntityRenderColor(iMeteor, iRockRed, iRockGreen, iRockBlue, iRockAlpha);

			float flAngles2[3];
			flAngles2[0] = GetRandomFloat(flMin, flMax);
			flAngles2[1] = GetRandomFloat(flMin, flMax);
			flAngles2[2] = GetRandomFloat(flMin, flMax);

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
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bMeteor2[iTank])
	{
		g_bMeteor2[iTank] = false;

		return Plugin_Stop;
	}

	g_bMeteor2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "MeteorHuman6");

	return Plugin_Continue;
}