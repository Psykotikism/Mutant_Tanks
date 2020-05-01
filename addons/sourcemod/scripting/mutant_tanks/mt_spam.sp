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
	name = "[MT] Spam Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank spams rocks at survivors.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Spam Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define SOUND_ROCK "player/tank/attack/thrown_missile_loop_1.wav"

#define MT_MENU_SPAM "Spam Ability"

bool g_bCloneInstalled;

enum struct esPlayerSettings
{
	bool g_bSpam;
	bool g_bSpam2;

	int g_iAccessFlags2;
	int g_iSpamCount;
}

esPlayerSettings g_esPlayer[MAXPLAYERS + 1];

enum struct esAbilitySettings
{
	float g_flHumanCooldown;
	float g_flSpamChance;
	float g_flSpamDuration;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanMode;
	int g_iSpamAbility;
	int g_iSpamDamage;
	int g_iSpamMessage;
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

	RegConsoleCmd("sm_mt_spam", cmdSpamInfo, "View information about the Spam ability.");
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iSpamAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iSpamCount, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esAbility[MT_GetTankType(param1)].g_flHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "SpamDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esAbility[MT_GetTankType(param1)].g_flSpamDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
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

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_SPAM, MT_MENU_SPAM);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_SPAM, false))
	{
		vSpamMenu(client, 0);
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
	list.PushString("spamability");
	list2.PushString("spam ability");
	list3.PushString("spam_ability");
	list4.PushString("spam");
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
			g_esAbility[iIndex].g_iSpamAbility = 0;
			g_esAbility[iIndex].g_iSpamMessage = 0;
			g_esAbility[iIndex].g_flSpamChance = 33.3;
			g_esAbility[iIndex].g_iSpamDamage = 5;
			g_esAbility[iIndex].g_flSpamDuration = 5.0;
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "spamability", false) || StrEqual(subsection, "spam ability", false) || StrEqual(subsection, "spam_ability", false) || StrEqual(subsection, "spam", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags2 = (value[0] != '\0') ? ReadFlagString(value) : g_esPlayer[admin].g_iAccessFlags2;
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAmmo = iGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_flHumanCooldown = flGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_flHumanCooldown, value, 0.0, 999999.0);
		g_esAbility[type].g_iHumanMode = iGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iSpamAbility = iGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iSpamAbility, value, 0, 1);
		g_esAbility[type].g_iSpamMessage = iGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iSpamMessage, value, 0, 1);
		g_esAbility[type].g_flSpamChance = flGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "SpamChance", "Spam Chance", "Spam_Chance", "chance", g_esAbility[type].g_flSpamChance, value, 0.0, 100.0);
		g_esAbility[type].g_iSpamDamage = iGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "SpamDamage", "Spam Damage", "Spam_Damage", "damage", g_esAbility[type].g_iSpamDamage, value, 1, 999999);
		g_esAbility[type].g_flSpamDuration = flGetValue(subsection, "spamability", "spam ability", "spam_ability", "spam", key, "SpamDuration", "Spam Duration", "Spam_Duration", "duration", g_esAbility[type].g_flSpamDuration, value, 0.1, 999999.0);

		if (StrEqual(subsection, "spamability", false) || StrEqual(subsection, "spam ability", false) || StrEqual(subsection, "spam_ability", false) || StrEqual(subsection, "spam", false))
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
			vRemoveSpam(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esAbility[MT_GetTankType(tank)].g_iSpamAbility == 1 && !g_esPlayer[tank].g_bSpam)
	{
		vSpamAbility(tank);
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
			if (g_esAbility[MT_GetTankType(tank)].g_iSpamAbility == 1 && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				switch (g_esAbility[MT_GetTankType(tank)].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bSpam && !g_esPlayer[tank].g_bSpam2)
						{
							vSpamAbility(tank);
						}
						else if (g_esPlayer[tank].g_bSpam)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "SpamHuman3");
						}
						else if (g_esPlayer[tank].g_bSpam2)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "SpamHuman4");
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iSpamCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bSpam && !g_esPlayer[tank].g_bSpam2)
							{
								g_esPlayer[tank].g_bSpam = true;
								g_esPlayer[tank].g_iSpamCount++;

								vSpam(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "SpamHuman", g_esPlayer[tank].g_iSpamCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bSpam)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "SpamHuman3");
							}
							else if (g_esPlayer[tank].g_bSpam2)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "SpamHuman4");
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "SpamAmmo");
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
			if (g_esAbility[MT_GetTankType(tank)].g_iSpamAbility == 1 && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				if (g_esAbility[MT_GetTankType(tank)].g_iHumanMode == 1 && g_esPlayer[tank].g_bSpam && !g_esPlayer[tank].g_bSpam2)
				{
					vReset2(tank);

					vReset3(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveSpam(tank);
}

static void vRemoveSpam(int tank)
{
	g_esPlayer[tank].g_bSpam = false;
	g_esPlayer[tank].g_bSpam2 = false;
	g_esPlayer[tank].g_iSpamCount = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveSpam(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bSpam = false;

	CreateTimer(3.0, tTimerStopRockSound, _, TIMER_FLAG_NO_MAPCHANGE);
}

static void vReset3(int tank)
{
	g_esPlayer[tank].g_bSpam2 = true;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "SpamHuman5");

	if (g_esPlayer[tank].g_iSpamCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
	{
		CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flHumanCooldown, tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_esPlayer[tank].g_bSpam2 = false;
	}
}

static void vSpam(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	char sDamage[11];
	IntToString(g_esAbility[MT_GetTankType(tank)].g_iSpamDamage, sDamage, sizeof(sDamage));

	int iSpam = CreateEntityByName("env_rock_launcher");
	if (bIsValidEntity(iSpam))
	{
		SetEntPropEnt(iSpam, Prop_Send, "m_hOwnerEntity", tank);
		DispatchSpawn(iSpam);
		DispatchKeyValue(iSpam, "rockdamageoverride", sDamage);
		iSpam = EntIndexToEntRef(iSpam);
	}

	int iSpam2 = CreateEntityByName("env_rock_launcher");
	if (bIsValidEntity(iSpam2))
	{
		SetEntPropEnt(iSpam2, Prop_Send, "m_hOwnerEntity", tank);
		DispatchSpawn(iSpam2);
		DispatchKeyValue(iSpam2, "rockdamageoverride", sDamage);
		iSpam2 = EntIndexToEntRef(iSpam2);
	}

	int iSpam3 = CreateEntityByName("env_rock_launcher");
	if (bIsValidEntity(iSpam3))
	{
		SetEntPropEnt(iSpam3, Prop_Send, "m_hOwnerEntity", tank);
		DispatchSpawn(iSpam3);
		DispatchKeyValue(iSpam3, "rockdamageoverride", sDamage);
		iSpam3 = EntIndexToEntRef(iSpam3);
	}

	DataPack dpSpam;
	CreateDataTimer(0.5, tTimerSpam, dpSpam, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpSpam.WriteCell(iSpam);
	dpSpam.WriteCell(iSpam2);
	dpSpam.WriteCell(iSpam3);
	dpSpam.WriteCell(GetClientUserId(tank));
	dpSpam.WriteCell(MT_GetTankType(tank));
	dpSpam.WriteFloat(GetEngineTime());
}

static void vSpamAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_esPlayer[tank].g_iSpamCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esAbility[MT_GetTankType(tank)].g_flSpamChance)
		{
			g_esPlayer[tank].g_bSpam = true;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				g_esPlayer[tank].g_iSpamCount++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "SpamHuman", g_esPlayer[tank].g_iSpamCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
			}

			vSpam(tank);

			if (g_esAbility[MT_GetTankType(tank)].g_iSpamMessage == 1)
			{
				char sTankName[33];
				MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Spam", sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "SpamHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "SpamAmmo");
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

public Action tTimerSpam(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSpam = EntRefToEntIndex(pack.ReadCell()), iSpam2 = EntRefToEntIndex(pack.ReadCell()), iSpam3 = EntRefToEntIndex(pack.ReadCell()), iTank = GetClientOfUserId(pack.ReadCell());
	if ((iSpam == INVALID_ENT_REFERENCE || !bIsValidEntity(iSpam)) && (iSpam2 == INVALID_ENT_REFERENCE || !bIsValidEntity(iSpam2)) && (iSpam3 == INVALID_ENT_REFERENCE || !bIsValidEntity(iSpam3)))
	{
		g_esPlayer[iTank].g_bSpam = false;

		return Plugin_Stop;
	}

	int iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || !g_esPlayer[iTank].g_bSpam)
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (g_esAbility[MT_GetTankType(iTank)].g_iSpamAbility == 0 || ((!MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) || (g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && g_esAbility[MT_GetTankType(iTank)].g_iHumanMode == 0)) && (flTime + g_esAbility[MT_GetTankType(iTank)].g_flSpamDuration) < GetEngineTime()))
	{
		vReset2(iTank);

		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && g_esAbility[MT_GetTankType(iTank)].g_iHumanMode == 0 && !g_esPlayer[iTank].g_bSpam2)
		{
			vReset3(iTank);
		}

		if (g_esAbility[MT_GetTankType(iTank)].g_iSpamMessage == 1)
		{
			char sTankName[33];
			MT_GetTankName(iTank, MT_GetTankType(iTank), sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Spam2", sTankName);
		}

		return Plugin_Stop;
	}

	float flPos[3], flAngles[3];
	GetClientEyePosition(iTank, flPos);
	GetClientEyeAngles(iTank, flAngles);
	flPos[2] += 70.0;

	if (bIsValidEntity(iSpam))
	{
		TeleportEntity(iSpam, flPos, flAngles, NULL_VECTOR);
		AcceptEntityInput(iSpam, "LaunchRock");
	}

	flPos[1] += 50.0;
	flAngles[1] += 45.0;

	if (bIsValidEntity(iSpam2))
	{
		TeleportEntity(iSpam2, flPos, flAngles, NULL_VECTOR);
		AcceptEntityInput(iSpam2, "LaunchRock");
	}

	flPos[1] -= 100.0;
	flAngles[1] -= 90.0;

	if (bIsValidEntity(iSpam3))
	{
		TeleportEntity(iSpam3, flPos, flAngles, NULL_VECTOR);
		AcceptEntityInput(iSpam3, "LaunchRock");
	}

	return Plugin_Continue;
}

public Action tTimerStopRockSound(Handle timer)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			StopSound(iPlayer, SNDCHAN_BODY, SOUND_ROCK);
		}
	}
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iTank].g_bSpam2)
	{
		g_esPlayer[iTank].g_bSpam2 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bSpam2 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "SpamHuman6");

	return Plugin_Continue;
}