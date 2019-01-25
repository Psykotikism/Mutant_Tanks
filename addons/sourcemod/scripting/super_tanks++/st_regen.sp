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
	name = "[ST++] Regen Ability",
	author = ST_AUTHOR,
	description = "The Super Tank regenerates health.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_REGEN "Regen Ability"

bool g_bCloneInstalled, g_bRegen[MAXPLAYERS + 1], g_bRegen2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flHumanDuration[ST_MAXTYPES + 1], g_flHumanDuration2[ST_MAXTYPES + 1], g_flRegenChance[ST_MAXTYPES + 1], g_flRegenChance2[ST_MAXTYPES + 1], g_flRegenInterval[ST_MAXTYPES + 1], g_flRegenInterval2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1], g_iRegenAbility[ST_MAXTYPES + 1], g_iRegenAbility2[ST_MAXTYPES + 1], g_iRegenCount[MAXPLAYERS + 1], g_iRegenHealth[ST_MAXTYPES + 1], g_iRegenHealth2[ST_MAXTYPES + 1], g_iRegenLimit[ST_MAXTYPES + 1], g_iRegenLimit2[ST_MAXTYPES + 1], g_iRegenMessage[ST_MAXTYPES + 1], g_iRegenMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Regen Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

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

	RegConsoleCmd("sm_st_regen", cmdRegenInfo, "View information about the Regen ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveRegen(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdRegenInfo(int client, int args)
{
	if (!ST_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Super Tanks++\x01 is disabled.", ST_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, "0245"))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", ST_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", ST_TAG2, "Vote in Progress");
		case false: vRegenMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vRegenMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iRegenMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Regen Ability Information");
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

public int iRegenMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iRegenAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iRegenCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "RegenDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flHumanDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vRegenMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "RegenMenu", param1);
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
	menu.AddItem(ST_MENU_REGEN, ST_MENU_REGEN);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_REGEN, false))
	{
		vRegenMenu(client, 0);
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Regen Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Regen Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_flHumanDuration[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Human Duration", 5.0);
					g_flHumanDuration[iIndex] = flClamp(g_flHumanDuration[iIndex], 0.1, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Regen Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iRegenAbility[iIndex] = kvSuperTanks.GetNum("Regen Ability/Ability Enabled", 0);
					g_iRegenAbility[iIndex] = iClamp(g_iRegenAbility[iIndex], 0, 1);
					g_iRegenMessage[iIndex] = kvSuperTanks.GetNum("Regen Ability/Ability Message", 0);
					g_iRegenMessage[iIndex] = iClamp(g_iRegenMessage[iIndex], 0, 1);
					g_flRegenChance[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Regen Chance", 33.3);
					g_flRegenChance[iIndex] = flClamp(g_flRegenChance[iIndex], 0.0, 100.0);
					g_iRegenHealth[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Health", 1);
					g_iRegenHealth[iIndex] = iClamp(g_iRegenHealth[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
					g_flRegenInterval[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Regen Interval", 1.0);
					g_flRegenInterval[iIndex] = flClamp(g_flRegenInterval[iIndex], 0.1, 9999999999.0);
					g_iRegenLimit[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Limit", ST_MAXHEALTH);
					g_iRegenLimit[iIndex] = iClamp(g_iRegenLimit[iIndex], 1, ST_MAXHEALTH);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_flHumanDuration2[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Human Duration", g_flHumanDuration[iIndex]);
					g_flHumanDuration2[iIndex] = flClamp(g_flHumanDuration2[iIndex], 0.1, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iRegenAbility2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Ability Enabled", g_iRegenAbility[iIndex]);
					g_iRegenAbility2[iIndex] = iClamp(g_iRegenAbility2[iIndex], 0, 1);
					g_iRegenMessage2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Ability Message", g_iRegenMessage[iIndex]);
					g_iRegenMessage2[iIndex] = iClamp(g_iRegenMessage2[iIndex], 0, 1);
					g_flRegenChance2[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Regen Chance", g_flRegenChance[iIndex]);
					g_flRegenChance2[iIndex] = flClamp(g_flRegenChance2[iIndex], 0.0, 100.0);
					g_iRegenHealth2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Health", g_iRegenHealth[iIndex]);
					g_iRegenHealth2[iIndex] = iClamp(g_iRegenHealth2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
					g_flRegenInterval2[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Regen Interval", g_flRegenInterval[iIndex]);
					g_flRegenInterval2[iIndex] = flClamp(g_flRegenInterval2[iIndex], 0.1, 9999999999.0);
					g_iRegenLimit2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Limit", g_iRegenLimit[iIndex]);
					g_iRegenLimit2[iIndex] = iClamp(g_iRegenLimit2[iIndex], 1, ST_MAXHEALTH);
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
		if (ST_IsTankSupported(iTank, "024"))
		{
			vRemoveRegen(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, "5") || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iRegenAbility(tank) == 1 && !g_bRegen[tank])
	{
		vRegenAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iRegenAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
				{
					case 0:
					{
						if (!g_bRegen[tank] && !g_bRegen2[tank])
						{
							vRegenAbility(tank);
						}
						else if (g_bRegen[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "RegenHuman3");
						}
						else if (g_bRegen2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "RegenHuman4");
						}
					}
					case 1:
					{
						if (g_iRegenCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bRegen[tank] && !g_bRegen2[tank])
							{
								g_bRegen[tank] = true;
								g_iRegenCount[tank]++;

								vRegen(tank);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "RegenHuman", g_iRegenCount[tank], iHumanAmmo(tank));
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "RegenAmmo");
						}
					}
				}
			}
		}
	}
}

public void ST_OnButtonReleased(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iRegenAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bRegen[tank] && !g_bRegen2[tank])
				{
					g_bRegen[tank] = false;

					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveRegen(tank);
}

static void vRegen(int tank)
{
	DataPack dpRegen;
	CreateDataTimer(flRegenInterval(tank), tTimerRegen, dpRegen, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpRegen.WriteCell(GetClientUserId(tank));
	dpRegen.WriteCell(ST_GetTankType(tank));
	dpRegen.WriteFloat(GetEngineTime());
}

static void vRegenAbility(int tank)
{
	if (g_iRegenCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		float flRegenChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flRegenChance[ST_GetTankType(tank)] : g_flRegenChance2[ST_GetTankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flRegenChance)
		{
			g_bRegen[tank] = true;

			if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
			{
				g_iRegenCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "RegenHuman", g_iRegenCount[tank], iHumanAmmo(tank));
			}

			vRegen(tank);

			if (iRegenMessage(tank) == 1)
			{
				char sTankName[33];
				ST_GetTankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Regen", sTankName, flRegenInterval(tank));
			}
		}
		else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "RegenHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "RegenAmmo");
	}
}

static void vRemoveRegen(int tank)
{
	g_bRegen[tank] = false;
	g_bRegen2[tank] = false;
	g_iRegenCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveRegen(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bRegen2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "RegenHuman5");

	if (g_iRegenCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bRegen2[tank] = false;
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flHumanDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanDuration[ST_GetTankType(tank)] : g_flHumanDuration2[ST_GetTankType(tank)];
}

static float flRegenInterval(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flRegenInterval[ST_GetTankType(tank)] : g_flRegenInterval2[ST_GetTankType(tank)];
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

static int iRegenAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iRegenAbility[ST_GetTankType(tank)] : g_iRegenAbility2[ST_GetTankType(tank)];
}

static int iRegenMessage(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iRegenMessage[ST_GetTankType(tank)] : g_iRegenMessage2[ST_GetTankType(tank)];
}

public Action tTimerRegen(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || iRegenAbility(iTank) == 0 || !g_bRegen[iTank])
	{
		g_bRegen[iTank] = false;

		if (iRegenMessage(iTank) == 1)
		{
			char sTankName[33];
			ST_GetTankName(iTank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Regen2", sTankName);
		}

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (ST_IsTankSupported(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0 && (flTime + flHumanDuration(iTank)) < GetEngineTime() && !g_bRegen2[iTank])
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	int iHealth = GetClientHealth(iTank),
		iRegenHealth = !g_bTankConfig[ST_GetTankType(iTank)] ? (g_iRegenHealth[ST_GetTankType(iTank)]) : (g_iRegenHealth2[ST_GetTankType(iTank)]),
		iRegenLimit = !g_bTankConfig[ST_GetTankType(iTank)] ? g_iRegenLimit[ST_GetTankType(iTank)] : g_iRegenLimit2[ST_GetTankType(iTank)],
		iExtraHealth = iHealth + iRegenHealth,
		iNewHealth = (iExtraHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iExtraHealth,
		iNewHealth2 = (iExtraHealth <= 1) ? iHealth : iExtraHealth,
		iRealHealth = (iRegenHealth >= 1) ? iNewHealth : iNewHealth2,
		iFinalHealth = (iRegenHealth >= 1 && iRealHealth >= iRegenLimit) ? iRegenLimit : iRealHealth;

	SetEntityHealth(iTank, iFinalHealth);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bRegen2[iTank])
	{
		g_bRegen2[iTank] = false;

		return Plugin_Stop;
	}

	g_bRegen2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "RegenHuman6");

	return Plugin_Continue;
}