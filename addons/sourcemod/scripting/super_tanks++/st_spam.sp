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
	name = "[ST++] Spam Ability",
	author = ST_AUTHOR,
	description = "The Super Tank spams rocks at survivors.",
	version = ST_VERSION,
	url = ST_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Spam Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define SOUND_ROCK "player/tank/attack/thrown_missile_loop_1.wav"

#define ST_MENU_SPAM "Spam Ability"

bool g_bCloneInstalled, g_bSpam[MAXPLAYERS + 1], g_bSpam2[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flSpamChance[ST_MAXTYPES + 1], g_flSpamDuration[ST_MAXTYPES + 1];

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iSpam[MAXPLAYERS + 1], g_iSpamAbility[ST_MAXTYPES + 1], g_iSpamCount[MAXPLAYERS + 1], g_iSpamDamage[ST_MAXTYPES + 1], g_iSpamMessage[ST_MAXTYPES + 1];

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
	PrecacheSound(SOUND_ROCK, true);

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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iSpamAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iSpamCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanMode[ST_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "SpamDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flSpamDuration[ST_GetTankType(param1)]);
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
		g_flHumanCooldown[iIndex] = 30.0;
		g_iHumanMode[iIndex] = 1;
		g_iSpamAbility[iIndex] = 0;
		g_iSpamMessage[iIndex] = 0;
		g_flSpamChance[iIndex] = 33.3;
		g_iSpamDamage[iIndex] = 5;
		g_flSpamDuration[iIndex] = 5.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "spamability", false) || StrEqual(subsection, "spam ability", false) || StrEqual(subsection, "spam_ability", false) || StrEqual(subsection, "spam", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
		}
	}

	if (type > 0)
	{
		ST_FindAbility(type, 58, bHasAbilities(subsection, "spamability", "spam ability", "spam_ability", "spam"));
		g_iHumanAbility[type] = iGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iSpamAbility[type] = iGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iSpamAbility[type], value, 0, 1);
		g_iSpamMessage[type] = iGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iSpamMessage[type], value, 0, 1);
		g_flSpamChance[type] = flGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "SpamChance", "Spam Chance", "Spam_Chance", "chance", g_flSpamChance[type], value, 0.0, 100.0);
		g_iSpamDamage[type] = iGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "SpamDamage", "Spam Damage", "Spam_Damage", "damage", g_iSpamDamage[type], value, 1, 9999999999);
		g_flSpamDuration[type] = flGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "SpamDuration", "Spam Duration", "Spam_Duration", "duration", g_flSpamDuration[type], value, 0.1, 9999999999.0);

		if (StrEqual(subsection, "spamability", false) || StrEqual(subsection, "spam ability", false) || StrEqual(subsection, "spam_ability", false) || StrEqual(subsection, "spam", false))
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
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveSpam(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INGAME|ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iSpamAbility[ST_GetTankType(tank)] == 1 && !g_bSpam[tank])
	{
		vSpamAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (g_iSpamAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[ST_GetTankType(tank)])
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
						if (g_iSpamCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
						{
							if (!g_bSpam[tank] && !g_bSpam2[tank])
							{
								g_iSpam[tank] = CreateEntityByName("env_rock_launcher");
								if (bIsValidEntity(g_iSpam[tank]))
								{
									g_bSpam[tank] = true;
									g_iSpamCount[tank]++;

									vSpam(tank);

									ST_PrintToChat(tank, "%s %t", ST_TAG3, "SpamHuman", g_iSpamCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
								}
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
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (g_iSpamAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[ST_GetTankType(tank)] == 1 && g_bSpam[tank] && !g_bSpam2[tank])
				{
					vReset2(tank);

					vReset3(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveSpam(tank);
}

static void vRemoveSpam(int tank)
{
	g_bSpam[tank] = false;
	g_bSpam2[tank] = false;
	g_iSpam[tank] = INVALID_ENT_REFERENCE;
	g_iSpamCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveSpam(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bSpam[tank] = false;

	if (bIsValidEntity(g_iSpam[tank]))
	{
		RemoveEntity(g_iSpam[tank]);
	}

	g_iSpam[tank] = INVALID_ENT_REFERENCE;

	CreateTimer(3.0, tTimerStopRockSound, _, TIMER_FLAG_NO_MAPCHANGE);
}

static void vReset3(int tank)
{
	g_bSpam2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "SpamHuman5");

	if (g_iSpamCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bSpam2[tank] = false;
	}
}

static void vSpam(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	char sDamage[11];
	IntToString(g_iSpamDamage[ST_GetTankType(tank)], sDamage, sizeof(sDamage));
	DispatchSpawn(g_iSpam[tank]);
	DispatchKeyValue(g_iSpam[tank], "rockdamageoverride", sDamage);

	DataPack dpSpam;
	CreateDataTimer(0.5, tTimerSpam, dpSpam, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpSpam.WriteCell(EntIndexToEntRef(g_iSpam[tank]));
	dpSpam.WriteCell(GetClientUserId(tank));
	dpSpam.WriteCell(ST_GetTankType(tank));
	dpSpam.WriteFloat(GetEngineTime());
}

static void vSpamAbility(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iSpamCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flSpamChance[ST_GetTankType(tank)])
		{
			g_iSpam[tank] = CreateEntityByName("env_rock_launcher");
			if (!bIsValidEntity(g_iSpam[tank]))
			{
				return;
			}

			g_bSpam[tank] = true;

			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				g_iSpamCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "SpamHuman", g_iSpamCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
			}

			vSpam(tank);

			if (g_iSpamMessage[ST_GetTankType(tank)] == 1)
			{
				char sTankName[33];
				ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Spam", sTankName);
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "SpamHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "SpamAmmo");
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

public Action tTimerSpam(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSpam = EntRefToEntIndex(pack.ReadCell()), iTank = GetClientOfUserId(pack.ReadCell());
	if (iSpam == INVALID_ENT_REFERENCE || !bIsValidEntity(iSpam))
	{
		g_bSpam[iTank] = false;

		return Plugin_Stop;
	}

	int iType = pack.ReadCell();
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bSpam[iTank])
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (g_iSpamAbility[ST_GetTankType(iTank)] == 0 || ((!ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) || (g_iHumanAbility[ST_GetTankType(iTank)] == 1 && g_iHumanMode[ST_GetTankType(iTank)] == 0)) && (flTime + g_flSpamDuration[ST_GetTankType(iTank)]) < GetEngineTime()))
	{
		vReset2(iTank);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && g_iHumanMode[ST_GetTankType(iTank)] == 0 && !g_bSpam2[iTank])
		{
			vReset3(iTank);
		}

		if (g_iSpamMessage[ST_GetTankType(iTank)] == 1)
		{
			char sTankName[33];
			ST_GetTankName(iTank, ST_GetTankType(iTank), sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Spam2", sTankName);
		}

		return Plugin_Stop;
	}

	float flPos[3], flAngles[3];
	GetClientEyePosition(iTank, flPos);
	GetClientEyeAngles(iTank, flAngles);
	flPos[2] += 80.0;

	TeleportEntity(iSpam, flPos, flAngles, NULL_VECTOR);
	AcceptEntityInput(iSpam, "LaunchRock");

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
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bSpam2[iTank])
	{
		g_bSpam2[iTank] = false;

		return Plugin_Stop;
	}

	g_bSpam2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "SpamHuman6");

	return Plugin_Continue;
}