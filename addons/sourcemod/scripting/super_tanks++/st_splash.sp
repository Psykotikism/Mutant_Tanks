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
	name = "[ST++] Splash Ability",
	author = ST_AUTHOR,
	description = "The Super Tank constantly deals splash damage to nearby survivors.",
	version = ST_VERSION,
	url = ST_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Splash Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define ST_MENU_SPLASH "Splash Ability"

bool g_bCloneInstalled, g_bSplash[MAXPLAYERS + 1], g_bSplash2[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanDuration[ST_MAXTYPES + 1], g_flSplashChance[ST_MAXTYPES + 1], g_flSplashDamage[ST_MAXTYPES + 1], g_flSplashInterval[ST_MAXTYPES + 1], g_flSplashRange[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iSplashAbility[ST_MAXTYPES + 1], g_iSplashCount[MAXPLAYERS + 1], g_iSplashMessage[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_splash", cmdSplashInfo, "View information about the Splash ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveSplash(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdSplashInfo(int client, int args)
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
		case false: vSplashMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vSplashMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iSplashMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Splash Ability Information");
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

public int iSplashMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iSplashAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iSplashCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanMode[ST_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "SplashDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flHumanDuration[ST_GetTankType(param1)]);
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vSplashMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "SplashMenu", param1);
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
	menu.AddItem(ST_MENU_SPLASH, ST_MENU_SPLASH);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_SPLASH, false))
	{
		vSplashMenu(client, 0);
	}
}

public void ST_OnConfigsLoad()
{
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_flHumanDuration[iIndex] = 5.0;
		g_iHumanMode[iIndex] = 1;
		g_iSplashAbility[iIndex] = 0;
		g_iSplashMessage[iIndex] = 0;
		g_flSplashChance[iIndex] = 33.3;
		g_flSplashDamage[iIndex] = 5.0;
		g_flSplashInterval[iIndex] = 5.0;
		g_flSplashRange[iIndex] = 500.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	g_iHumanAbility[type] = iGetValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_flHumanDuration[type] = flGetValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", main, g_flHumanDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iHumanMode[type] = iGetValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", main, g_iHumanMode[type], value, 1, 0, 1);
	g_iSplashAbility[type] = iGetValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iSplashAbility[type], value, 0, 0, 1);
	g_iSplashMessage[type] = iGetValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iSplashMessage[type], value, 0, 0, 1);
	g_flSplashChance[type] = flGetValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "SplashChance", "Splash Chance", "Splash_Chance", "chance", main, g_flSplashChance[type], value, 33.3, 0.0, 100.0);
	g_flSplashDamage[type] = flGetValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "SplashDamage", "Splash Damage", "Splash_Damage", "damage", main, g_flSplashDamage[type], value, 5.0, 1.0, 9999999999.0);
	g_flSplashInterval[type] = flGetValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "SplashInterval", "Splash Interval", "Splash_Interval", "interval", main, g_flSplashInterval[type], value, 5.0, 0.1, 9999999999.0);
	g_flSplashRange[type] = flGetValue(subsection, "splashability", "splash ability", "splash_ability", "splash", key, "SplashRange", "Splash Range", "Splash_Range", "range", main, g_flSplashRange[type], value, 500.0, 1.0, 9999999999.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iSplashAbility[ST_GetTankType(iTank)] == 1 && GetRandomFloat(0.1, 100.0) <= g_flSplashChance[ST_GetTankType(iTank)])
		{
			vSplash(iTank, 0.4, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveSplash(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iSplashAbility[ST_GetTankType(tank)] == 1 && !g_bSplash[tank])
	{
		vSplashAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (g_iSplashAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[ST_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bSplash[tank] && !g_bSplash2[tank])
						{
							vSplashAbility(tank);
						}
						else if (g_bSplash[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "SplashHuman3");
						}
						else if (g_bSplash2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "SplashHuman4");
						}
					}
					case 1:
					{
						if (g_iSplashCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
						{
							if (!g_bSplash[tank] && !g_bSplash2[tank])
							{
								g_bSplash[tank] = true;
								g_iSplashCount[tank]++;

								vSplash(tank, g_flSplashInterval[ST_GetTankType(tank)], TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "SplashHuman", g_iSplashCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "SplashAmmo");
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
			if (g_iSplashAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[ST_GetTankType(tank)] == 1 && g_bSplash[tank] && !g_bSplash2[tank])
				{
					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveSplash(tank);
}

static void vRemoveSplash(int tank)
{
	g_bSplash[tank] = false;
	g_bSplash2[tank] = false;
	g_iSplashCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveSplash(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bSplash[tank] = false;
	g_bSplash2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "SplashHuman5");

	if (g_iSplashCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bSplash2[tank] = false;
	}
}

static void vSplash(int tank, float time, int flags)
{
	DataPack dpSplash;
	CreateDataTimer(time, tTimerSplash, dpSplash, flags);
	dpSplash.WriteCell(GetClientUserId(tank));
	dpSplash.WriteCell(ST_GetTankType(tank));
	dpSplash.WriteFloat(GetEngineTime());
}

static void vSplashAbility(int tank)
{
	if (g_iSplashCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flSplashChance[ST_GetTankType(tank)])
		{
			g_bSplash[tank] = true;

			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				g_iSplashCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "SplashHuman", g_iSplashCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
			}

			vSplash(tank, g_flSplashInterval[ST_GetTankType(tank)], TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

			if (g_iSplashMessage[ST_GetTankType(tank)] == 1)
			{
				char sTankName[33];
				ST_GetTankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Splash", sTankName);
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "SplashHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "SplashAmmo");
	}
}

public Action tTimerSplash(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || g_iSplashAbility[ST_GetTankType(iTank)] == 0 || !g_bSplash[iTank])
	{
		g_bSplash[iTank] = false;

		if (g_iSplashMessage[ST_GetTankType(iTank)] == 1)
		{
			char sTankName[33];
			ST_GetTankName(iTank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Splash2", sTankName);
		}

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && g_iHumanMode[ST_GetTankType(iTank)] == 0 && (flTime + g_flHumanDuration[ST_GetTankType(iTank)]) < GetEngineTime() && !g_bSplash2[iTank])
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	float flTankPos[3];
	GetClientAbsOrigin(iTank, flTankPos);

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
		{
			float flSurvivorPos[3];
			GetClientAbsOrigin(iSurvivor, flSurvivorPos);

			float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
			if (flDistance <= g_flSplashRange[ST_GetTankType(iTank)])
			{
				vDamageEntity(iSurvivor, iTank, g_flSplashDamage[ST_GetTankType(iTank)], "65536");
			}
		}
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bSplash2[iTank])
	{
		g_bSplash2[iTank] = false;

		return Plugin_Stop;
	}

	g_bSplash2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "SplashHuman6");

	return Plugin_Continue;
}