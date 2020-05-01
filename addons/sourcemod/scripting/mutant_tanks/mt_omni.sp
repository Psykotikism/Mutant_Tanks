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

#undef REQUIRE_PLUGIN
#include <mt_clone>
#define REQUIRE_PLUGIN

#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Omni Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank has omni-level access to other nearby Mutant Tanks' abilities.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Omni Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MT_MENU_OMNI "Omni Ability"

bool g_bCloneInstalled;

enum struct esPlayerSettings
{
	bool g_bOmni;
	bool g_bOmni2;

	int g_iAccessFlags2;
	int g_iOmniCount;
	int g_iOmniType;
}

esPlayerSettings g_esPlayer[MAXPLAYERS + 1];

enum struct esAbilitySettings
{
	float g_flHumanCooldown;
	float g_flOmniChance;
	float g_flOmniDuration;
	float g_flOmniRange;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanMode;
	int g_iOmniAbility;
	int g_iOmniMessage;
	int g_iOmniMode;
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

	RegConsoleCmd("sm_mt_omni", cmdOmniInfo, "View information about the Omni ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveOmni(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdOmniInfo(int client, int args)
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
		case false: vOmniMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vOmniMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iOmniMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Omni Ability Information");
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

public int iOmniMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			int iType = iGetRealType(param1);

			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[iType].g_iOmniAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esAbility[iType].g_iHumanAmmo - g_esPlayer[param1].g_iOmniCount, g_esAbility[iType].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[iType].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esAbility[iType].g_flHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "OmniDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esAbility[iType].g_flOmniDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[iType].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vOmniMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "OmniMenu", param1);
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

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_OMNI, MT_MENU_OMNI);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_OMNI, false))
	{
		vOmniMenu(client, 0);
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
	list.PushString("omniability");
	list2.PushString("omni ability");
	list3.PushString("omni_ability");
	list4.PushString("omni");
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
			g_esAbility[iIndex].g_flHumanCooldown = 30.0;
			g_esAbility[iIndex].g_iHumanMode = 1;
			g_esAbility[iIndex].g_iOmniAbility = 0;
			g_esAbility[iIndex].g_iOmniMessage = 0;
			g_esAbility[iIndex].g_flOmniChance = 33.3;
			g_esAbility[iIndex].g_flOmniDuration = 5.0;
			g_esAbility[iIndex].g_iOmniMode = 0;
			g_esAbility[iIndex].g_flOmniRange = 500.0;
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "omniability", false) || StrEqual(subsection, "omni ability", false) || StrEqual(subsection, "omni_ability", false) || StrEqual(subsection, "omni", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags2 = (value[0] != '\0') ? ReadFlagString(value) : g_esPlayer[admin].g_iAccessFlags2;
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAmmo = iGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_flHumanCooldown = flGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_flHumanCooldown, value, 0.0, 999999.0);
		g_esAbility[type].g_iHumanMode = iGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iOmniAbility = iGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iOmniAbility, value, 0, 1);
		g_esAbility[type].g_iOmniMessage = iGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iOmniMessage, value, 0, 1);
		g_esAbility[type].g_flOmniChance = flGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniChance", "Omni Chance", "Omni_Chance", "chance", g_esAbility[type].g_flOmniChance, value, 0.0, 100.0);
		g_esAbility[type].g_flOmniDuration = flGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniDuration", "Omni Duration", "Omni_Duration", "duration", g_esAbility[type].g_flOmniDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_iOmniMode = iGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniMode", "Omni Mode", "Omni_Mode", "mode", g_esAbility[type].g_iOmniMode, value, 0, 1);
		g_esAbility[type].g_flOmniRange = flGetValue(subsection, "omniability", "omni ability", "omni_ability", "omni", key, "OmniRange", "Omni Range", "Omni_Range", "range", g_esAbility[type].g_flOmniRange, value, 1.0, 999999.0);

		if (StrEqual(subsection, "omniability", false) || StrEqual(subsection, "omni ability", false) || StrEqual(subsection, "omni_ability", false) || StrEqual(subsection, "omni", false))
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
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveOmni(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	int iType = iGetRealType(tank);
	if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_esAbility[iType].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esAbility[iType].g_iHumanAbility == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esAbility[iType].g_iOmniAbility == 1 && !g_esPlayer[tank].g_bOmni)
	{
		vOmniAbility(tank);
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

		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			int iType = iGetRealType(tank);
			if (g_esAbility[iType].g_iOmniAbility == 1 && g_esAbility[iType].g_iHumanAbility == 1)
			{
				switch (g_esAbility[iType].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bOmni && !g_esPlayer[tank].g_bOmni2)
						{
							vOmniAbility(tank);
						}
						else if (g_esPlayer[tank].g_bOmni)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman3");
						}
						else if (g_esPlayer[tank].g_bOmni2)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman4");
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iOmniCount < g_esAbility[iType].g_iHumanAmmo && g_esAbility[iType].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bOmni && !g_esPlayer[tank].g_bOmni2)
							{
								g_esPlayer[tank].g_bOmni = true;
								g_esPlayer[tank].g_iOmniCount++;

								vOmni(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman", g_esPlayer[tank].g_iOmniCount, g_esAbility[iType].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bOmni)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman3");
							}
							else if (g_esPlayer[tank].g_bOmni2)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman4");
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniAmmo");
						}
					}
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			int iType = iGetRealType(tank);
			if (g_esAbility[iType].g_iOmniAbility == 1 && g_esAbility[iType].g_iHumanAbility == 1)
			{
				if (g_esAbility[iType].g_iHumanMode == 1 && g_esPlayer[tank].g_bOmni && !g_esPlayer[tank].g_bOmni2)
				{
					g_esPlayer[tank].g_bOmni = false;

					MT_SetTankType(tank, g_esPlayer[tank].g_iOmniType, view_as<bool>(g_esAbility[iType].g_iOmniMode));

					vReset3(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveOmni(tank);
}

static void vOmni(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	g_esPlayer[tank].g_iOmniType = MT_GetTankType(tank);

	int iType = iGetRealType(tank);

	float flTankPos[3];
	GetClientAbsOrigin(tank, flTankPos);

	int iTypeCount, iTypes[MT_MAXTYPES + 1];
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (MT_IsTankSupported(iTank, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && bIsCloneAllowed(iTank, g_bCloneInstalled) && iTank != tank)
		{
			float flTankPos2[3];
			GetClientAbsOrigin(iTank, flTankPos2);

			float flDistance = GetVectorDistance(flTankPos, flTankPos2);
			if (flDistance <= g_esAbility[iType].g_flOmniRange)
			{
				iTypes[iTypeCount + 1] = MT_GetTankType(iTank);
				iTypeCount++;
			}
		}
	}

	if (iTypeCount > 0)
	{
		MT_SetTankType(tank, iTypes[GetRandomInt(1, iTypeCount)], view_as<bool>(g_esAbility[iType].g_iOmniMode));
	}
	else
	{
		int iTypeCount2, iTypes2[MT_MAXTYPES + 1];
		for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
		{
			if (!MT_IsTypeEnabled(iIndex) || !MT_CanTypeSpawn(iIndex) || g_esPlayer[tank].g_iOmniType == iIndex)
			{
				continue;
			}

			iTypes2[iTypeCount2 + 1] = iIndex;
			iTypeCount2++;
		}

		MT_SetTankType(tank, iTypes2[GetRandomInt(1, iTypeCount2)], view_as<bool>(g_esAbility[iType].g_iOmniMode));
	}
}

static void vOmniAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	int iType = iGetRealType(tank);

	if (g_esPlayer[tank].g_iOmniCount < g_esAbility[iType].g_iHumanAmmo && g_esAbility[iType].g_iHumanAmmo > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esAbility[iType].g_flOmniChance)
		{
			g_esPlayer[tank].g_bOmni = true;

			vOmni(tank);

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[iType].g_iHumanAbility == 1)
			{
				g_esPlayer[tank].g_iOmniCount++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman", g_esPlayer[tank].g_iOmniCount, g_esAbility[iType].g_iHumanAmmo);
			}

			CreateTimer(g_esAbility[iType].g_flOmniDuration, tTimerStopOmni, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

			if (g_esAbility[iType].g_iOmniMessage == 1)
			{
				char sTankName[33];
				MT_GetTankName(tank, g_esPlayer[tank].g_iOmniType, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Omni", sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[iType].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[iType].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniAmmo");
	}
}

static void vRemoveOmni(int tank)
{
	g_esPlayer[tank].g_bOmni = false;
	g_esPlayer[tank].g_bOmni2 = false;
	g_esPlayer[tank].g_iOmniCount = 0;
	g_esPlayer[tank].g_iOmniType = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveOmni(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bOmni = false;

	if (g_esAbility[iGetRealType(tank)].g_iOmniMessage == 1)
	{
		char sTankName[33];
		MT_GetTankName(tank, g_esPlayer[tank].g_iOmniType, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Omni2", sTankName);
	}
}

static void vReset3(int tank)
{
	g_esPlayer[tank].g_bOmni2 = true;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "OmniHuman5");

	int iType = iGetRealType(tank);
	if (g_esPlayer[tank].g_iOmniCount < g_esAbility[iType].g_iHumanAmmo && g_esAbility[iType].g_iHumanAmmo > 0)
	{
		CreateTimer(g_esAbility[iType].g_flHumanCooldown, tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_esPlayer[tank].g_bOmni2 = false;
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

static int iGetRealType(int tank)
{
	return g_esPlayer[tank].g_iOmniType > 0 ? g_esPlayer[tank].g_iOmniType : MT_GetTankType(tank);
}

public Action tTimerStopOmni(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid), iType = iGetRealType(iTank);
	if (!MT_IsTankSupported(iTank) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled))
	{
		g_esPlayer[iTank].g_iOmniType = 0;

		vReset2(iTank);

		return Plugin_Stop;
	}

	vReset2(iTank);

	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_esAbility[iType].g_iHumanAbility == 1 && !g_esPlayer[iTank].g_bOmni2)
	{
		vReset3(iTank);
	}

	MT_SetTankType(iTank, g_esPlayer[iTank].g_iOmniType, view_as<bool>(g_esAbility[iType].g_iOmniMode));
	g_esPlayer[iTank].g_iOmniType = 0;

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iTank].g_bOmni2)
	{
		g_esPlayer[iTank].g_bOmni2 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bOmni2 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "OmniHuman6");

	return Plugin_Continue;
}