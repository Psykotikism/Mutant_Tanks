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
	name = "[ST++] Respawn Ability",
	author = ST_AUTHOR,
	description = "The Super Tank respawns upon death.",
	version = ST_VERSION,
	url = ST_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Respawn Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define ST_MENU_RESPAWN "Respawn Ability"

bool g_bCloneInstalled, g_bRespawn[MAXPLAYERS + 1];

float g_flRespawnChance[ST_MAXTYPES + 1];

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iRespawnAbility[ST_MAXTYPES + 1], g_iRespawnAmount[ST_MAXTYPES + 1], g_iRespawnCount[MAXPLAYERS + 1], g_iRespawnCount2[MAXPLAYERS + 1], g_iRespawnMessage[ST_MAXTYPES + 1], g_iRespawnMode[ST_MAXTYPES + 1], g_iRespawnType[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_respawn", cmdRespawnInfo, "View information about the Respawn ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveRespawn(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdRespawnInfo(int client, int args)
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
		case false: vRespawnMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vRespawnMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iRespawnMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Respawn Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iRespawnMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iRespawnAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iRespawnCount2[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons4");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "RespawnDetails");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vRespawnMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "RespawnMenu", param1);
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
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 4:
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
	menu.AddItem(ST_MENU_RESPAWN, ST_MENU_RESPAWN);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_RESPAWN, false))
	{
		vRespawnMenu(client, 0);
	}
}

public void ST_OnConfigsLoad()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_iAccessFlags2[iPlayer] = 0;
		}
	}

	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iAccessFlags[iIndex] = 0;
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_iRespawnAbility[iIndex] = 0;
		g_iRespawnMessage[iIndex] = 0;
		g_iRespawnAmount[iIndex] = 1;
		g_flRespawnChance[iIndex] = 33.3;
		g_iRespawnMode[iIndex] = 0;
		g_iRespawnType[iIndex] = 0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "respawnability", false) || StrEqual(subsection, "respawn ability", false) || StrEqual(subsection, "respawn_ability", false) || StrEqual(subsection, "respawn", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
		}
	}

	if (type > 0)
	{
		ST_FindAbility(type, 48, bHasAbilities(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn"));
		g_iHumanAbility[type] = iGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_iRespawnAbility[type] = iGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iRespawnAbility[type], value, 0, 1);
		g_iRespawnMessage[type] = iGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iRespawnMessage[type], value, 0, 1);
		g_iRespawnAmount[type] = iGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "RespawnAmount", "Respawn Amount", "Respawn_Amount", "amount", g_iRespawnAmount[type], value, 1, 9999999999);
		g_flRespawnChance[type] = flGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "RespawnChance", "Respawn Chance", "Respawn_Chance", "chance", g_flRespawnChance[type], value, 0.0, 100.0);
		g_iRespawnMode[type] = iGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "RespawnMode", "Respawn Mode", "Respawn_Mode", "mode", g_iRespawnMode[type], value, 0, 2);
		g_iRespawnType[type] = iGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "RespawnType", "Respawn Type", "Respawn_Type", "type", g_iRespawnType[type], value, 0, ST_MAXTYPES);

		if (StrEqual(subsection, "respawnability", false) || StrEqual(subsection, "respawn ability", false) || StrEqual(subsection, "respawn_ability", false) || StrEqual(subsection, "respawn", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags[type];
			}
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iRespawnAbility[ST_GetTankType(iTank)] == 1 && GetRandomFloat(0.1, 100.0) <= g_flRespawnChance[ST_GetTankType(iTank)])
		{
			if (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank))
			{
				return;
			}

			float flPos[3], flAngles[3];
			GetEntPropVector(iTank, Prop_Send, "m_vecOrigin", flPos);
			GetEntPropVector(iTank, Prop_Send, "m_angRotation", flAngles);

			int iFlags = GetEntProp(iTank, Prop_Send, "m_fFlags"), iSequence = GetEntProp(iTank, Prop_Data, "m_nSequence");

			DataPack dpRespawn;
			CreateDataTimer(0.4, tTimerRespawn, dpRespawn, TIMER_FLAG_NO_MAPCHANGE);
			dpRespawn.WriteCell(GetClientUserId(iTank));
			dpRespawn.WriteCell(iFlags);
			dpRespawn.WriteCell(iSequence);
			dpRespawn.WriteFloat(flPos[0]);
			dpRespawn.WriteFloat(flPos[1]);
			dpRespawn.WriteFloat(flPos[2]);
			dpRespawn.WriteFloat(flAngles[0]);
			dpRespawn.WriteFloat(flAngles[1]);
			dpRespawn.WriteFloat(flAngles[2]);
		}
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
		if (button & ST_SPECIAL_KEY2 == ST_SPECIAL_KEY2)
		{
			if (g_iRespawnAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_bRespawn[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "RespawnHuman2");
					case false:
					{
						if (g_iRespawnCount2[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
						{
							g_bRespawn[tank] = true;

							ST_PrintToChat(tank, "%s %t", ST_TAG3, "RespawnHuman");
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "RespawnAmmo");
						}
					}
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveRespawn(tank);
}

static void vRandomRespawn(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	int iTypeCount, iTankTypes[ST_MAXTYPES + 1];
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		if (!ST_IsTypeEnabled(iIndex) || !ST_CanTankSpawn(iIndex) || (ST_IsFinaleTank(iIndex) && (!bIsFinaleMap() || ST_GetCurrentFinaleWave() <= 0)) || ST_GetTankType(tank) == iIndex)
		{
			continue;
		}

		iTankTypes[iTypeCount + 1] = iIndex;
		iTypeCount++;
	}

	if (iTypeCount > 0)
	{
		int iChosen = iTankTypes[GetRandomInt(1, iTypeCount)];
		ST_SpawnTank(tank, iChosen);
	}
}

static void vRemoveRespawn(int tank)
{
	g_bRespawn[tank] = false;
	g_iRespawnCount[tank] = 0;
	g_iRespawnCount2[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveRespawn(iPlayer);
		}
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, ST_CHECK_FAKECLIENT))
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

public Action tTimerRespawn(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsPlayerIncapacitated(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || g_iRespawnAbility[ST_GetTankType(iTank)] == 0)
	{
		g_iRespawnCount[iTank] = 0;

		return Plugin_Stop;
	}

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && !g_bRespawn[iTank])
	{
		g_bRespawn[iTank] = false;
		g_iRespawnCount[iTank] = 0;

		return Plugin_Stop;
	}

	int iFlags = pack.ReadCell(), iSequence = pack.ReadCell();

	float flPos[3], flAngles[3];
	flPos[0] = pack.ReadFloat();
	flPos[1] = pack.ReadFloat();
	flPos[2] = pack.ReadFloat();
	flAngles[0] = pack.ReadFloat();
	flAngles[1] = pack.ReadFloat();
	flAngles[2] = pack.ReadFloat();

	if (g_iRespawnCount[iTank] < g_iRespawnAmount[ST_GetTankType(iTank)] && g_iRespawnCount2[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
	{
		g_bRespawn[iTank] = false;
		g_iRespawnCount[iTank]++;

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1)
		{
			g_iRespawnCount2[iTank]++;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "RespawnHuman3", g_iRespawnCount2[iTank], g_iHumanAmmo[ST_GetTankType(iTank)]);
		}

		bool bExists[MAXPLAYERS + 1];
		for (int iRespawn = 1; iRespawn <= MaxClients; iRespawn++)
		{
			bExists[iRespawn] = false;
			if (ST_IsTankSupported(iRespawn, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && bIsCloneAllowed(iRespawn, g_bCloneInstalled))
			{
				bExists[iRespawn] = true;
			}
		}

		switch (g_iRespawnMode[ST_GetTankType(iTank)])
		{
			case 0: ST_SpawnTank(iTank, ST_GetTankType(iTank));
			case 1:
			{
				switch (g_iRespawnType[ST_GetTankType(iTank)])
				{
					case 0: vRandomRespawn(iTank);
					default: ST_SpawnTank(iTank, g_iRespawnType[ST_GetTankType(iTank)]);
				}
			}
			case 2: vRandomRespawn(iTank);
		}

		int iNewTank;
		for (int iRespawn = 1; iRespawn <= MaxClients; iRespawn++)
		{
			if (ST_IsTankSupported(iRespawn, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && bIsCloneAllowed(iRespawn, g_bCloneInstalled) && !bExists[iRespawn])
			{
				iNewTank = iRespawn;
				g_bRespawn[iNewTank] = false;
				g_iRespawnCount[iNewTank] = g_iRespawnCount[iTank];
				g_iRespawnCount2[iNewTank] = g_iRespawnCount2[iTank];

				vRemoveRespawn(iTank);

				break;
			}
			else
			{
				vRemoveRespawn(iTank);

				break;
			}
		}

		if (iNewTank > 0)
		{
			SetEntProp(iNewTank, Prop_Send, "m_fFlags", iFlags);
			SetEntProp(iNewTank, Prop_Data, "m_nSequence", iSequence);
			TeleportEntity(iNewTank, flPos, flAngles, NULL_VECTOR);

			if (g_iRespawnMessage[ST_GetTankType(iTank)] == 1)
			{
				char sTankName[33];
				ST_GetTankName(iTank, ST_GetTankType(iTank), sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Respawn", sTankName);
			}
		}
	}
	else
	{
		vRemoveRespawn(iTank);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1)
		{
			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "RespawnAmmo");
		}
	}

	return Plugin_Continue;
}