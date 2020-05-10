/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2020  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#include <sourcemod>
#include <mutant_tanks>

#undef REQUIRE_PLUGIN
#tryinclude <mt_clone>
#define REQUIRE_PLUGIN

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Respawn Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank respawns upon death.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Respawn Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MT_MENU_RESPAWN "Respawn Ability"

bool g_bCloneInstalled;

enum struct esPlayerSettings
{
	bool g_bRespawn;

	int g_iAccessFlags2;
	int g_iRespawnCount;
	int g_iRespawnCount2;
}

esPlayerSettings g_esPlayer[MAXPLAYERS + 1];

enum struct esAbilitySettings
{
	float g_flRespawnChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iRespawnAbility;
	int g_iRespawnAmount;
	int g_iRespawnMessage;
	int g_iRespawnMode;
	int g_iRespawnType;
}

esAbilitySettings g_esAbility[MT_MAXTYPES + 1];

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("mt_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_respawn", cmdRespawnInfo, "View information about the Respawn ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveRespawn(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveRespawn(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdRespawnInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Mutant Tanks\x01 is disabled.", MT_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", MT_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iRespawnAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iRespawnCount2, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons4");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "RespawnDetails");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
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

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_RESPAWN, MT_MENU_RESPAWN);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_RESPAWN, false))
	{
		vRespawnMenu(client, 0);
	}
}

public void MT_OnPluginCheck(ArrayList &list)
{
	char sName[32];
	GetPluginFilename(null, sName, sizeof(sName));
	list.PushString(sName);
}

public void MT_OnAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString("respawnability");
	list2.PushString("respawn ability");
	list3.PushString("respawn_ability");
	list4.PushString("respawn");
}

public void MT_OnConfigsLoad(int mode)
{
	if (mode == 3)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				g_esPlayer[iPlayer].g_iAccessFlags2 = 0;
			}
		}
	}
	else if (mode == 1)
	{
		for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
		{
			g_esAbility[iIndex].g_iAccessFlags = 0;
			g_esAbility[iIndex].g_iHumanAbility = 0;
			g_esAbility[iIndex].g_iHumanAmmo = 5;
			g_esAbility[iIndex].g_iRespawnAbility = 0;
			g_esAbility[iIndex].g_iRespawnMessage = 0;
			g_esAbility[iIndex].g_iRespawnAmount = 1;
			g_esAbility[iIndex].g_flRespawnChance = 33.3;
			g_esAbility[iIndex].g_iRespawnMode = 0;
			g_esAbility[iIndex].g_iRespawnType = 0;
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "respawnability", false) || StrEqual(subsection, "respawn ability", false) || StrEqual(subsection, "respawn_ability", false) || StrEqual(subsection, "respawn", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags2 = (value[0] != '\0') ? ReadFlagString(value) : g_esPlayer[admin].g_iAccessFlags2;
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iRespawnAbility = iGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iRespawnAbility, value, 0, 1);
		g_esAbility[type].g_iRespawnMessage = iGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iRespawnMessage, value, 0, 1);
		g_esAbility[type].g_iRespawnAmount = iGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "RespawnAmount", "Respawn Amount", "Respawn_Amount", "amount", g_esAbility[type].g_iRespawnAmount, value, 1, 999999);
		g_esAbility[type].g_flRespawnChance = flGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "RespawnChance", "Respawn Chance", "Respawn_Chance", "chance", g_esAbility[type].g_flRespawnChance, value, 0.0, 100.0);
		g_esAbility[type].g_iRespawnMode = iGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "RespawnMode", "Respawn Mode", "Respawn_Mode", "mode", g_esAbility[type].g_iRespawnMode, value, 0, 2);
		g_esAbility[type].g_iRespawnType = iGetValue(subsection, "respawnability", "respawn ability", "respawn_ability", "respawn", key, "RespawnType", "Respawn Type", "Respawn_Type", "type", g_esAbility[type].g_iRespawnType, value, 0, MT_MAXTYPES);

		if (StrEqual(subsection, "respawnability", false) || StrEqual(subsection, "respawn ability", false) || StrEqual(subsection, "respawn_ability", false) || StrEqual(subsection, "respawn", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = (value[0] != '\0') ? ReadFlagString(value) : g_esAbility[type].g_iAccessFlags;
			}
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && bIsCloneAllowed(iTank, g_bCloneInstalled) && g_esAbility[MT_GetTankType(iTank)].g_iRespawnAbility == 1 && GetRandomFloat(0.1, 100.0) <= g_esAbility[MT_GetTankType(iTank)].g_flRespawnChance)
		{
			if (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank))
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

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & MT_SPECIAL_KEY2 == MT_SPECIAL_KEY2)
		{
			if (g_esAbility[MT_GetTankType(tank)].g_iRespawnAbility == 1 && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				switch (g_esPlayer[tank].g_bRespawn)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman2");
					case false:
					{
						if (g_esPlayer[tank].g_iRespawnCount2 < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
						{
							g_esPlayer[tank].g_bRespawn = true;

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman");
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnAmmo");
						}
					}
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveRespawn(tank);
}

static void vRemoveRespawn(int tank)
{
	g_esPlayer[tank].g_bRespawn = false;
	g_esPlayer[tank].g_iRespawnCount = 0;
	g_esPlayer[tank].g_iRespawnCount2 = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveRespawn(iPlayer);
		}
	}
}

static void vRespawn(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	int iTypeCount, iTankTypes[MT_MAXTYPES + 1];
	for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
	{
		if (!MT_IsTypeEnabled(iIndex) || !MT_CanTypeSpawn(iIndex) || MT_GetTankType(tank) == iIndex)
		{
			continue;
		}

		iTankTypes[iTypeCount + 1] = iIndex;
		iTypeCount++;
	}

	if (iTypeCount > 0)
	{
		int iChosen = iTankTypes[GetRandomInt(1, iTypeCount)];
		MT_SpawnTank(tank, iChosen);
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_esAbility[MT_GetTankType(admin)].g_iAccessFlags;
	if (iAbilityFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iAbilityFlags)) ? false : true;
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iTypeFlags)) ? false : true;
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iGlobalFlags)) ? false : true;
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0 && iAbilityFlags != 0)
	{
		return (!(iClientTypeFlags & iAbilityFlags)) ? false : true;
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0 && iAbilityFlags != 0)
	{
		return (!(iClientGlobalFlags & iAbilityFlags)) ? false : true;
	}

	if (iAbilityFlags != 0)
	{
		return (!(GetUserFlagBits(admin) & iAbilityFlags)) ? false : true;
	}

	return true;
}

public Action tTimerRespawn(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsPlayerIncapacitated(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || g_esAbility[MT_GetTankType(iTank)].g_iRespawnAbility == 0)
	{
		g_esPlayer[iTank].g_iRespawnCount = 0;

		return Plugin_Stop;
	}

	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && !g_esPlayer[iTank].g_bRespawn)
	{
		g_esPlayer[iTank].g_bRespawn = false;
		g_esPlayer[iTank].g_iRespawnCount = 0;

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

	if (g_esPlayer[iTank].g_iRespawnCount < g_esAbility[MT_GetTankType(iTank)].g_iRespawnAmount && (!MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) || (g_esPlayer[iTank].g_iRespawnCount2 < g_esAbility[MT_GetTankType(iTank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(iTank)].g_iHumanAmmo > 0)))
	{
		g_esPlayer[iTank].g_bRespawn = false;
		g_esPlayer[iTank].g_iRespawnCount++;

		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1)
		{
			g_esPlayer[iTank].g_iRespawnCount2++;

			MT_PrintToChat(iTank, "%s %t", MT_TAG3, "RespawnHuman3", g_esPlayer[iTank].g_iRespawnCount2, g_esAbility[MT_GetTankType(iTank)].g_iHumanAmmo);
		}

		bool bExists[MAXPLAYERS + 1];
		for (int iRespawn = 1; iRespawn <= MaxClients; iRespawn++)
		{
			bExists[iRespawn] = false;
			if (MT_IsTankSupported(iRespawn, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && bIsCloneAllowed(iRespawn, g_bCloneInstalled))
			{
				bExists[iRespawn] = true;
			}
		}

		switch (g_esAbility[MT_GetTankType(iTank)].g_iRespawnMode)
		{
			case 0: MT_SpawnTank(iTank, MT_GetTankType(iTank));
			case 1:
			{
				switch (g_esAbility[MT_GetTankType(iTank)].g_iRespawnType)
				{
					case 0: vRespawn(iTank);
					default: MT_SpawnTank(iTank, g_esAbility[MT_GetTankType(iTank)].g_iRespawnType);
				}
			}
			case 2: vRespawn(iTank);
		}

		int iNewTank;
		for (int iRespawn = 1; iRespawn <= MaxClients; iRespawn++)
		{
			if (MT_IsTankSupported(iRespawn, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && bIsCloneAllowed(iRespawn, g_bCloneInstalled) && !bExists[iRespawn])
			{
				iNewTank = iRespawn;
				g_esPlayer[iNewTank].g_bRespawn = false;
				g_esPlayer[iNewTank].g_iRespawnCount = g_esPlayer[iTank].g_iRespawnCount;
				g_esPlayer[iNewTank].g_iRespawnCount2 = g_esPlayer[iTank].g_iRespawnCount2;

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

			if (g_esAbility[MT_GetTankType(iTank)].g_iRespawnMessage == 1)
			{
				char sTankName[33];
				MT_GetTankName(iTank, MT_GetTankType(iTank), sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Respawn", sTankName);
			}
		}
	}
	else
	{
		vRemoveRespawn(iTank);

		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1)
		{
			MT_PrintToChat(iTank, "%s %t", MT_TAG3, "RespawnAmmo");
		}
	}

	return Plugin_Continue;
}