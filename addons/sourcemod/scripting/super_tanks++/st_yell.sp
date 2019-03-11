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
	name = "[ST++] Yell Ability",
	author = ST_AUTHOR,
	description = "The Super Tank yells to deafen survivors.",
	version = ST_VERSION,
	url = ST_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Yell Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define SOUND_YELL "player/tank/voice/yell/tank_yell_01.wav"
#define SOUND_YELL2 "player/tank/voice/yell/tank_yell_02.wav"
#define SOUND_YELL3 "player/tank/voice/yell/tank_yell_03.wav"
#define SOUND_YELL4 "player/tank/voice/yell/tank_yell_04.wav"
#define SOUND_YELL5 "player/tank/voice/yell/tank_yell_05.wav"
#define SOUND_YELL6 "player/tank/voice/yell/tank_yell_06.wav"
#define SOUND_YELL7 "player/tank/voice/yell/tank_yell_07.wav"
#define SOUND_YELL8 "player/tank/voice/yell/tank_yell_08.wav"
#define SOUND_YELL9 "player/tank/voice/yell/tank_yell_09.wav"
#define SOUND_YELL10 "player/tank/voice/yell/tank_yell_10.wav"
#define SOUND_YELL11 "player/tank/voice/yell/tank_yell_12.wav"

#define ST_MENU_YELL "Yell Ability"

bool g_bCloneInstalled, g_bYell[MAXPLAYERS + 1], g_bYell2[MAXPLAYERS + 1], g_bYell3[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flYellChance[ST_MAXTYPES + 1], g_flYellDuration[ST_MAXTYPES + 1], g_flYellRange[ST_MAXTYPES + 1];

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iImmunityFlags[ST_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1], g_iYellAbility[ST_MAXTYPES + 1], g_iYellCount[MAXPLAYERS + 1], g_iYellMessage[ST_MAXTYPES + 1], g_iYellOwner[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_yell", cmdYellInfo, "View information about the Yell ability.");
}

public void OnMapStart()
{
	PrecacheSound(SOUND_YELL, true);
	PrecacheSound(SOUND_YELL2, true);
	PrecacheSound(SOUND_YELL3, true);
	PrecacheSound(SOUND_YELL4, true);
	PrecacheSound(SOUND_YELL5, true);
	PrecacheSound(SOUND_YELL6, true);
	PrecacheSound(SOUND_YELL7, true);
	PrecacheSound(SOUND_YELL8, true);
	PrecacheSound(SOUND_YELL9, true);
	PrecacheSound(SOUND_YELL10, true);
	PrecacheSound(SOUND_YELL11, true);

	vReset();

	AddNormalSoundHook(SoundHook);
}

public void OnClientPutInServer(int client)
{
	vRemoveYell(client);
}

public void OnMapEnd()
{
	vReset();

	RemoveNormalSoundHook(SoundHook);
}

public Action cmdYellInfo(int client, int args)
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
		case false: vYellMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vYellMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iYellMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Yell Ability Information");
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

public int iYellMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iYellAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iYellCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanMode[ST_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "YellDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flYellDuration[ST_GetTankType(param1)]);
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vYellMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "YellMenu", param1);
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
	menu.AddItem(ST_MENU_YELL, ST_MENU_YELL);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_YELL, false))
	{
		vYellMenu(client, 0);
	}
}

public Action SoundHook(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (ST_IsCorePluginEnabled() && StrContains(sample, "player", false) != -1)
	{
		for (int iSurvivor = 0; iSurvivor < numClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(clients[iSurvivor], ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bYell3[clients[iSurvivor]])
			{
				for (int iPlayers = iSurvivor; iPlayers < numClients - 1; iPlayers++)
				{
					clients[iPlayers] = clients[iPlayers + 1];
				}

				numClients--;
				iSurvivor--;
			}
		}

		return (numClients > 0) ? Plugin_Changed : Plugin_Stop;
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
		g_iHumanMode[iIndex] = 1;
		g_iYellAbility[iIndex] = 0;
		g_iYellMessage[iIndex] = 0;
		g_flYellChance[iIndex] = 33.3;
		g_flYellDuration[iIndex] = 5.0;
		g_flYellRange[iIndex] = 500.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "yellability", false) || StrEqual(subsection, "yell ability", false) || StrEqual(subsection, "yell_ability", false) || StrEqual(subsection, "yell", false))
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
		ST_FindAbility(type, 70, bHasAbilities(subsection, "yellability", "yell ability", "yell_ability", "yell"));
		g_iHumanAbility[type] = iGetValue(subsection, "yellability", "yell ability", "yell_ability", "yell", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "yellability", "yell ability", "yell_ability", "yell", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "yellability", "yell ability", "yell_ability", "yell", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "yellability", "yell ability", "yell_ability", "yell", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iYellAbility[type] = iGetValue(subsection, "yellability", "yell ability", "yell_ability", "yell", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iYellAbility[type], value, 0, 1);
		g_iYellMessage[type] = iGetValue(subsection, "yellability", "yell ability", "yell_ability", "yell", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iYellMessage[type], value, 0, 3);
		g_flYellChance[type] = flGetValue(subsection, "yellability", "yell ability", "yell_ability", "yell", key, "YellChance", "Yell Chance", "Yell_Chance", "chance", g_flYellChance[type], value, 0.0, 100.0);
		g_flYellDuration[type] = flGetValue(subsection, "yellability", "yell ability", "yell_ability", "yell", key, "YellDuration", "Yell Duration", "Yell_Duration", "duration", g_flYellDuration[type], value, 0.1, 9999999999.0);
		g_flYellRange[type] = flGetValue(subsection, "yellability", "yell ability", "yell_ability", "yell", key, "YellRange", "Yell Range", "Yell_Range", "range", g_flYellDuration[type], value, 0.1, 9999999999.0);

		if (StrEqual(subsection, "yellability", false) || StrEqual(subsection, "yell ability", false) || StrEqual(subsection, "yell_ability", false) || StrEqual(subsection, "yell", false))
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
			vRemoveYell(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iYellAbility[ST_GetTankType(tank)] == 1 && !g_bYell[tank])
	{
		vYellAbility(tank);
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
			if (g_iYellAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[ST_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bYell[tank] && !g_bYell2[tank])
						{
							vYellAbility(tank);
						}
						else if (g_bYell[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "YellHuman3");
						}
						else if (g_bYell2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "YellHuman4");
						}
					}
					case 1:
					{
						if (g_iYellCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
						{
							if (!g_bYell[tank] && !g_bYell2[tank])
							{
								g_bYell[tank] = true;
								g_iYellCount[tank]++;

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "YellHuman", g_iYellCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "YellAmmo");
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
			if (g_iYellAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[ST_GetTankType(tank)] == 1 && g_bYell[tank] && !g_bYell2[tank])
				{
					g_bYell[tank] = false;

					vReset3(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveYell(tank);
}

static void vRemoveYell(int tank)
{
	vReset4(tank);

	g_bYell[tank] = false;
	g_bYell2[tank] = false;
	g_bYell3[tank] = false;
	g_iYellCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveYell(iPlayer);

			g_iYellOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_bYell[tank] = false;

	vReset4(tank);

	if (g_iYellMessage[ST_GetTankType(tank)] == 1)
	{
		char sTankName[33];
		ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Yell2", sTankName);
	}
}

static void vReset3(int tank)
{
	g_bYell2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "YellHuman5");

	if (g_iYellCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bYell2[tank] = false;
	}
}

static void vReset4(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && g_bYell3[iSurvivor] && g_iYellOwner[iSurvivor] == tank)
		{
			g_bYell3[iSurvivor] = false;
			g_iYellOwner[iSurvivor] = 0;
		}
	}
}

static void vYellAbility(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iYellCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flYellChance[ST_GetTankType(tank)])
		{
			float flTankPos[3];
			GetClientAbsOrigin(tank, flTankPos);

			int iSurvivorCount;
			for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
			{
				if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && !ST_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank) && !g_bYell3[iSurvivor])
				{
					float flSurvivorPos[3];
					GetClientAbsOrigin(iSurvivor, flSurvivorPos);

					float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
					if (flDistance <= g_flYellRange[ST_GetTankType(tank)])
					{
						g_bYell3[iSurvivor] = true;
						g_iYellOwner[iSurvivor] = tank;

						iSurvivorCount++;
					}
				}
			}

			if (iSurvivorCount > 0 && !g_bYell[tank])
			{
				g_bYell[tank] = true;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
				{
					g_iYellCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "YellHuman", g_iYellCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				EmitSoundToAll(SOUND_YELL, tank);
				EmitSoundToAll(SOUND_YELL2, tank);
				EmitSoundToAll(SOUND_YELL3, tank);
				EmitSoundToAll(SOUND_YELL4, tank);
				EmitSoundToAll(SOUND_YELL5, tank);
				EmitSoundToAll(SOUND_YELL6, tank);
				EmitSoundToAll(SOUND_YELL7, tank);
				EmitSoundToAll(SOUND_YELL8, tank);
				EmitSoundToAll(SOUND_YELL9, tank);
				EmitSoundToAll(SOUND_YELL10, tank);
				EmitSoundToAll(SOUND_YELL11, tank);

				CreateTimer(g_flYellDuration[ST_GetTankType(tank)], tTimerStopYell, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

				if (g_iYellMessage[ST_GetTankType(tank)] == 1)
				{
					char sTankName[33];
					ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Yell", sTankName);
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "YellHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "YellAmmo");
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

static bool bIsAdminImmune(int survivor, int tank)
{
	if (!bIsValidClient(survivor, ST_CHECK_FAKECLIENT))
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

public Action tTimerStopYell(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	vReset2(iTank);

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && (ST_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && !g_bYell2[iTank])
	{
		vReset3(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bYell2[iTank])
	{
		g_bYell2[iTank] = false;

		return Plugin_Stop;
	}

	g_bYell2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "YellHuman6");

	return Plugin_Continue;
}