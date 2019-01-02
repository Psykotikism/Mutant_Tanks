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
	name = "[ST++] Spam Ability",
	author = ST_AUTHOR,
	description = "The Super Tank spams rocks at survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_SPAM "Spam Ability"

bool g_bCloneInstalled, g_bSpam[MAXPLAYERS + 1], g_bSpam2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flSpamChance[ST_MAXTYPES + 1], g_flSpamChance2[ST_MAXTYPES + 1], g_flSpamDuration[ST_MAXTYPES + 1], g_flSpamDuration2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1], g_iSpamAbility[ST_MAXTYPES + 1], g_iSpamAbility2[ST_MAXTYPES + 1], g_iSpamCount[MAXPLAYERS + 1], g_iSpamDamage[ST_MAXTYPES + 1], g_iSpamDamage2[ST_MAXTYPES + 1], g_iSpamMessage[ST_MAXTYPES + 1], g_iSpamMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Spam Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_spam", cmdSpamInfo, "View information about the Spam ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveSpam(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdSpamInfo(int client, int args)
{
	if (!ST_PluginEnabled())
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
		case false: vSpamMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vSpamMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iSpamMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Spam Ability Information");
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

public int iSpamMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iSpamAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iSpamCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "SpamDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flSpamDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vSpamMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "SpamMenu", param1);
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
	menu.AddItem(ST_MENU_SPAM, ST_MENU_SPAM);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_SPAM, false))
	{
		vSpamMenu(client, 0);
	}
}

public void ST_OnConfigsLoaded(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);

	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Spam Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Spam Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Spam Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iSpamAbility[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Enabled", 0);
					g_iSpamAbility[iIndex] = iClamp(g_iSpamAbility[iIndex], 0, 1);
					g_iSpamMessage[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Message", 0);
					g_iSpamMessage[iIndex] = iClamp(g_iSpamMessage[iIndex], 0, 1);
					g_flSpamChance[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Spam Chance", 33.3);
					g_flSpamChance[iIndex] = flClamp(g_flSpamChance[iIndex], 0.0, 100.0);
					g_iSpamDamage[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Damage", 5);
					g_iSpamDamage[iIndex] = iClamp(g_iSpamDamage[iIndex], 1, 9999999999);
					g_flSpamDuration[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Spam Duration", 5.0);
					g_flSpamDuration[iIndex] = flClamp(g_flSpamDuration[iIndex], 0.1, 9999999999.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iSpamAbility2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Enabled", g_iSpamAbility[iIndex]);
					g_iSpamAbility2[iIndex] = iClamp(g_iSpamAbility2[iIndex], 0, 1);
					g_iSpamMessage2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Message", g_iSpamMessage[iIndex]);
					g_iSpamMessage2[iIndex] = iClamp(g_iSpamMessage2[iIndex], 0, 1);
					g_flSpamChance2[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Spam Chance", g_flSpamChance[iIndex]);
					g_flSpamChance2[iIndex] = flClamp(g_flSpamChance2[iIndex], 0.0, 100.0);
					g_iSpamDamage2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Damage", g_iSpamDamage[iIndex]);
					g_iSpamDamage2[iIndex] = iClamp(g_iSpamDamage2[iIndex], 1, 9999999999);
					g_flSpamDuration2[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Spam Duration", g_flSpamDuration[iIndex]);
					g_flSpamDuration2[iIndex] = flClamp(g_flSpamDuration2[iIndex], 0.1, 9999999999.0);
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
		if (ST_TankAllowed(iTank, "024"))
		{
			vRemoveSpam(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iSpamAbility(tank) == 1 && !g_bSpam[tank])
	{
		vSpamAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iSpamAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
				{
					case 0:
					{
						if (!g_bSpam[tank] && !g_bSpam2[tank])
						{
							vSpamAbility(tank);
						}
						else if (g_bSpam[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "SpamHuman3");
						}
						else if (g_bSpam2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "SpamHuman4");
						}
					}
					case 1:
					{
						if (g_iSpamCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bSpam[tank] && !g_bSpam2[tank])
							{
								g_bSpam[tank] = true;
								g_iSpamCount[tank]++;

								vSpam(tank);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "SpamHuman", g_iSpamCount[tank], iHumanAmmo(tank));
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "SpamAmmo");
						}
					}
				}
			}
		}
	}
}

public void ST_OnButtonReleased(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iSpamAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bSpam[tank] && !g_bSpam2[tank])
				{
					g_bSpam[tank] = false;

					vReset3(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveSpam(tank);
}

static void vRemoveSpam(int tank)
{
	g_bSpam[tank] = false;
	g_bSpam2[tank] = false;
	g_iSpamCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveSpam(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bSpam[tank] = false;

	if (iSpamMessage(tank) == 1)
	{
		char sTankName[33];
		ST_TankName(tank, sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Spam2", sTankName);
	}
}

static void vReset3(int tank)
{
	g_bSpam2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "SpamHuman5");

	if (g_iSpamCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bSpam2[tank] = false;
	}
}

static void vSpam(int tank)
{
	DataPack dpSpam;
	CreateDataTimer(0.5, tTimerSpam, dpSpam, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpSpam.WriteCell(GetClientUserId(tank));
	dpSpam.WriteFloat(GetEngineTime());
}

static void vSpamAbility(int tank)
{
	if (g_iSpamCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		float flSpamChance = !g_bTankConfig[ST_TankType(tank)] ? g_flSpamChance[ST_TankType(tank)] : g_flSpamChance2[ST_TankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flSpamChance)
		{
			g_bSpam[tank] = true;

			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				g_iSpamCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "SpamHuman", g_iSpamCount[tank], iHumanAmmo(tank));
			}

			vSpam(tank);

			if (iSpamMessage(tank) == 1)
			{
				char sTankName[33];
				ST_TankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Spam", sTankName);
			}
		}
		else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "SpamHuman2");
		}
	}
	else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "SpamAmmo");
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flSpamDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flSpamDuration[ST_TankType(tank)] : g_flSpamDuration2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iHumanMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanMode[ST_TankType(tank)] : g_iHumanMode2[ST_TankType(tank)];
}

static int iSpamAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iSpamAbility[ST_TankType(tank)] : g_iSpamAbility2[ST_TankType(tank)];
}

static int iSpamMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iSpamMessage[ST_TankType(tank)] : g_iSpamMessage2[ST_TankType(tank)];
}

public Action tTimerSpam(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bSpam[iTank])
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (iSpamAbility(iTank) == 0 || ((!ST_TankAllowed(iTank, "5") || (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0)) && (flTime + flSpamDuration(iTank)) < GetEngineTime()))
	{
		vReset2(iTank);

		if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0 && !g_bSpam2[iTank])
		{
			vReset3(iTank);
		}

		return Plugin_Stop;
	}

	char sDamage[11];
	int iSpamDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_iSpamDamage[ST_TankType(iTank)] : g_iSpamDamage2[ST_TankType(iTank)];
	IntToString(iSpamDamage, sDamage, sizeof(sDamage));

	float flPos[3], flAngles[3];
	GetClientEyePosition(iTank, flPos);
	GetClientEyeAngles(iTank, flAngles);
	flPos[2] += 80.0;

	int iSpammer = CreateEntityByName("env_rock_launcher");
	if (bIsValidEntity(iSpammer))
	{
		DispatchKeyValue(iSpammer, "rockdamageoverride", sDamage);
		TeleportEntity(iSpammer, flPos, flAngles, NULL_VECTOR);
		DispatchSpawn(iSpammer);

		AcceptEntityInput(iSpammer, "LaunchRock");
		RemoveEntity(iSpammer);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank, "02345") || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bSpam2[iTank])
	{
		g_bSpam2[iTank] = false;

		return Plugin_Stop;
	}

	g_bSpam2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "SpamHuman6");

	return Plugin_Continue;
}