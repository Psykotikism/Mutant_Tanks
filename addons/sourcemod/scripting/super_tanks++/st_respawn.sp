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

bool g_bCloneInstalled, g_bRespawn[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flRespawnChance[ST_MAXTYPES + 1], g_flRespawnChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iRespawnAbility[ST_MAXTYPES + 1], g_iRespawnAbility2[ST_MAXTYPES + 1], g_iRespawnAmount[ST_MAXTYPES + 1], g_iRespawnAmount2[ST_MAXTYPES + 1], g_iRespawnCount[MAXPLAYERS + 1], g_iRespawnCount2[MAXPLAYERS + 1], g_iRespawnMessage[ST_MAXTYPES + 1], g_iRespawnMessage2[ST_MAXTYPES + 1], g_iRespawnMode[ST_MAXTYPES + 1], g_iRespawnMode2[ST_MAXTYPES + 1], g_iRespawnType[ST_MAXTYPES + 1], g_iRespawnType2[ST_MAXTYPES + 1];

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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iRespawnAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iRespawnCount2[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons4");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "RespawnDetails");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_iRespawnAbility[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Ability Enabled", 0);
					g_iRespawnAbility[iIndex] = iClamp(g_iRespawnAbility[iIndex], 0, 1);
					g_iRespawnMessage[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Ability Message", 0);
					g_iRespawnMessage[iIndex] = iClamp(g_iRespawnMessage[iIndex], 0, 1);
					g_iRespawnAmount[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Amount", 1);
					g_iRespawnAmount[iIndex] = iClamp(g_iRespawnAmount[iIndex], 1, 9999999999);
					g_flRespawnChance[iIndex] = kvSuperTanks.GetFloat("Respawn Ability/Respawn Chance", 33.3);
					g_flRespawnChance[iIndex] = flClamp(g_flRespawnChance[iIndex], 0.0, 100.0);
					g_iRespawnMode[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Mode", 0);
					g_iRespawnMode[iIndex] = iClamp(g_iRespawnMode[iIndex], 0, 2);
					g_iRespawnType[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Type", 0);
					g_iRespawnType[iIndex] = iClamp(g_iRespawnType[iIndex], 0, 5000);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_iRespawnAbility2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Ability Enabled", g_iRespawnAbility[iIndex]);
					g_iRespawnAbility2[iIndex] = iClamp(g_iRespawnAbility2[iIndex], 0, 1);
					g_iRespawnMessage2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Ability Message", g_iRespawnMessage[iIndex]);
					g_iRespawnMessage2[iIndex] = iClamp(g_iRespawnMessage2[iIndex], 0, 1);
					g_iRespawnAmount2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Amount", g_iRespawnAmount[iIndex]);
					g_iRespawnAmount2[iIndex] = iClamp(g_iRespawnAmount2[iIndex], 1, 9999999999);
					g_flRespawnChance2[iIndex] = kvSuperTanks.GetFloat("Respawn Ability/Respawn Chance", g_flRespawnChance[iIndex]);
					g_flRespawnChance2[iIndex] = flClamp(g_flRespawnChance2[iIndex], 0.0, 100.0);
					g_iRespawnMode2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Mode", g_iRespawnMode[iIndex]);
					g_iRespawnMode2[iIndex] = iClamp(g_iRespawnMode2[iIndex], 0, 2);
					g_iRespawnType2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Type", g_iRespawnType[iIndex]);
					g_iRespawnType2[iIndex] = iClamp(g_iRespawnType2[iIndex], 0, 5000);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		float flRespawnChance = !g_bTankConfig[ST_GetTankType(iTank)] ? g_flRespawnChance[ST_GetTankType(iTank)] : g_flRespawnChance2[ST_GetTankType(iTank)];
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && ST_IsCloneSupported(iTank, g_bCloneInstalled) && iRespawnAbility(iTank) == 1 && GetRandomFloat(0.1, 100.0) <= flRespawnChance)
		{
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
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SPECIAL_KEY2 == ST_SPECIAL_KEY2)
		{
			if (iRespawnAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (g_bRespawn[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "RespawnHuman2");
					case false:
					{
						if (g_iRespawnCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
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

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iRespawnAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iRespawnAbility[ST_GetTankType(tank)] : g_iRespawnAbility2[ST_GetTankType(tank)];
}

public Action tTimerRespawn(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsPlayerIncapacitated(iTank) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || iRespawnAbility(iTank) == 0)
	{
		g_iRespawnCount[iTank] = 0;

		return Plugin_Stop;
	}

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && iHumanAbility(iTank) == 1 && !g_bRespawn[iTank])
	{
		g_bRespawn[iTank] = false;
		g_iRespawnCount[iTank] = 0;

		return Plugin_Stop;
	}

	int iFlags = pack.ReadCell(), iSequence = pack.ReadCell(),
		iRespawnAmount = !g_bTankConfig[ST_GetTankType(iTank)] ? g_iRespawnAmount[ST_GetTankType(iTank)] : g_iRespawnAmount2[ST_GetTankType(iTank)],
		iRespawnMessage = !g_bTankConfig[ST_GetTankType(iTank)] ? g_iRespawnMessage[ST_GetTankType(iTank)] : g_iRespawnMessage2[ST_GetTankType(iTank)],
		iRespawnMode = !g_bTankConfig[ST_GetTankType(iTank)] ? g_iRespawnMode[ST_GetTankType(iTank)] : g_iRespawnMode2[ST_GetTankType(iTank)],
		iRespawnType = !g_bTankConfig[ST_GetTankType(iTank)] ? g_iRespawnType[ST_GetTankType(iTank)] : g_iRespawnType2[ST_GetTankType(iTank)];

	float flPos[3], flAngles[3];
	flPos[0] = pack.ReadFloat();
	flPos[1] = pack.ReadFloat();
	flPos[2] = pack.ReadFloat();
	flAngles[0] = pack.ReadFloat();
	flAngles[1] = pack.ReadFloat();
	flAngles[2] = pack.ReadFloat();

	if (g_iRespawnCount[iTank] < iRespawnAmount && g_iRespawnCount2[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
	{
		g_bRespawn[iTank] = false;
		g_iRespawnCount[iTank]++;

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && iHumanAbility(iTank) == 1)
		{
			g_iRespawnCount2[iTank]++;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "RespawnHuman3", g_iRespawnCount2[iTank], iHumanAmmo(iTank));
		}

		bool bExists[MAXPLAYERS + 1];
		for (int iRespawn = 1; iRespawn <= MaxClients; iRespawn++)
		{
			bExists[iRespawn] = false;
			if (ST_IsTankSupported(iRespawn, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && ST_IsCloneSupported(iRespawn, g_bCloneInstalled))
			{
				bExists[iRespawn] = true;
			}
		}

		switch (iRespawnMode)
		{
			case 0: ST_SpawnTank(iTank, ST_GetTankType(iTank));
			case 1:
			{
				switch (iRespawnType)
				{
					case 0: vRandomRespawn(iTank);
					default: ST_SpawnTank(iTank, iRespawnType);
				}
			}
			case 2: vRandomRespawn(iTank);
		}

		int iNewTank;
		for (int iRespawn = 1; iRespawn <= MaxClients; iRespawn++)
		{
			if (ST_IsTankSupported(iRespawn, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && ST_IsCloneSupported(iRespawn, g_bCloneInstalled) && !bExists[iRespawn])
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

			if (iRespawnMessage == 1)
			{
				char sTankName[33];
				ST_GetTankName(iTank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Respawn", sTankName);
			}
		}
	}
	else
	{
		vRemoveRespawn(iTank);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && iHumanAbility(iTank) == 1)
		{
			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "RespawnAmmo");
		}
	}

	return Plugin_Continue;
}