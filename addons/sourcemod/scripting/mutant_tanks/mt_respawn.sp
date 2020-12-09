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
#include <dhooks>
#include <mutant_tanks>

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

#define MT_CONFIG_SECTION "respawnability"
#define MT_CONFIG_SECTION2 "respawn ability"
#define MT_CONFIG_SECTION3 "respawn_ability"
#define MT_CONFIG_SECTION4 "respawn"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_RESPAWN "Respawn Ability"

DynamicDetour g_ddEventKilled;

enum struct esPlayer
{
	bool g_bActivated;

	float g_flRespawnChance;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iRespawnAbility;
	int g_iRespawnAmount;
	int g_iRespawnMaxType;
	int g_iRespawnMinType;
	int g_iRespawnMessage;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flRespawnChance;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iRespawnAbility;
	int g_iRespawnAmount;
	int g_iRespawnMaxType;
	int g_iRespawnMinType;
	int g_iRespawnMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flRespawnChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iRespawnAbility;
	int g_iRespawnAmount;
	int g_iRespawnMaxType;
	int g_iRespawnMinType;
	int g_iRespawnMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_respawn", cmdRespawnInfo, "View information about the Respawn ability.");

	GameData gdMutantTanks = new GameData("mutant_tanks");
	if (gdMutantTanks == null)
	{
		SetFailState("Unable to load the \"mutant_tanks\" gamedata file.");

		return;
	}

	g_ddEventKilled = DynamicDetour.FromConf(gdMutantTanks, "CTerrorPlayer::Event_Killed");
	if (g_ddEventKilled == null)
	{
		SetFailState("Failed to find signature: CTerrorPlayer::Event_Killed");
	}

	delete gdMutantTanks;
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
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iRespawnAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons4");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "RespawnDetails");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vRespawnMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pRespawn = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "RespawnMenu", param1);
			pRespawn.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			if (param2 >= 0)
			{
				char sMenuOption[PLATFORM_MAX_PATH];

				switch (param2)
				{
					case 0: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);
					case 1: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Ammunition", param1);
					case 2: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);
					case 3: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					case 4: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
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

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_RESPAWN, false))
	{
		FormatEx(buffer, size, "%T", "RespawnMenu2", client);
	}
}

public MRESReturn mreEventKilledPre(int pThis, DHookParam hParams)
{
	if (MT_IsTankSupported(pThis, MT_CHECK_INDEX|MT_CHECK_INGAME) && MT_IsCustomTankSupported(pThis) && g_esCache[pThis].g_iRespawnAbility == 1 && g_esCache[pThis].g_iComboAbility == 0 && GetRandomFloat(0.1, 100.0) <= g_esCache[pThis].g_flRespawnChance)
	{
		vRespawn(pThis);
	}

	return MRES_Ignored;
}

public void MT_OnPluginCheck(ArrayList &list)
{
	char sName[32];
	GetPluginFilename(null, sName, sizeof(sName));
	list.PushString(sName);
}

public void MT_OnAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString(MT_CONFIG_SECTION);
	list2.PushString(MT_CONFIG_SECTION2);
	list3.PushString(MT_CONFIG_SECTION3);
	list4.PushString(MT_CONFIG_SECTION4);
}

public void MT_OnCombineAbilities(int tank, int type, float random, const char[] combo, int survivor, int weapon, const char[] classname)
{
	if (bIsTank(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility != 2)
	{
		return;
	}

	static char sAbilities[320], sSet[4][32];
	FormatEx(sAbilities, sizeof(sAbilities), ",%s,", combo);
	FormatEx(sSet[0], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION);
	FormatEx(sSet[1], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION2);
	FormatEx(sSet[2], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION3);
	FormatEx(sSet[3], sizeof(sSet[]), ",%s,", MT_CONFIG_SECTION4);
	if (StrContains(sAbilities, sSet[0], false) != -1 || StrContains(sAbilities, sSet[1], false) != -1 || StrContains(sAbilities, sSet[2], false) != -1 || StrContains(sAbilities, sSet[3], false) != -1)
	{
		if (type == MT_COMBO_UPONDEATH && g_esCache[tank].g_iRespawnAbility == 1 && g_esCache[tank].g_iComboAbility == 1)
		{
			static char sSubset[10][32];
			ExplodeString(combo, ",", sSubset, sizeof(sSubset), sizeof(sSubset[]));
			for (int iPos = 0; iPos < sizeof(sSubset); iPos++)
			{
				if (StrEqual(sSubset[iPos], MT_CONFIG_SECTION, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION2, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION3, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION4, false))
				{
					if (random <= MT_GetCombinationSetting(tank, 1, iPos))
					{
						static float flDelay;
						flDelay = MT_GetCombinationSetting(tank, 3, iPos);

						switch (flDelay)
						{
							case 0.0: vRespawn(tank);
							default: CreateTimer(flDelay, tTimerCombo, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
						}

						break;
					}
				}
			}
		}
	}
}

public void MT_OnConfigsLoad(int mode)
{
	switch (mode)
	{
		case 1:
		{
			for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
			{
				g_esAbility[iIndex].g_iAccessFlags = 0;
				g_esAbility[iIndex].g_iComboAbility = 0;
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iOpenAreasOnly = 0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iRespawnAbility = 0;
				g_esAbility[iIndex].g_iRespawnMessage = 0;
				g_esAbility[iIndex].g_iRespawnAmount = 1;
				g_esAbility[iIndex].g_flRespawnChance = 33.3;
				g_esAbility[iIndex].g_iRespawnMaxType = 0;
				g_esAbility[iIndex].g_iRespawnMinType = 0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esPlayer[iPlayer].g_iAccessFlags = 0;
					g_esPlayer[iPlayer].g_iComboAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iOpenAreasOnly = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iRespawnAbility = 0;
					g_esPlayer[iPlayer].g_iRespawnMessage = 0;
					g_esPlayer[iPlayer].g_iRespawnAmount = 0;
					g_esPlayer[iPlayer].g_flRespawnChance = 0.0;
					g_esPlayer[iPlayer].g_iRespawnMaxType = 0;
					g_esPlayer[iPlayer].g_iRespawnMinType = 0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iComboAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esPlayer[admin].g_iComboAbility, value, 0, 1);
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iOpenAreasOnly = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_iOpenAreasOnly, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iRespawnAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iRespawnAbility, value, 0, 1);
		g_esPlayer[admin].g_iRespawnMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iRespawnMessage, value, 0, 1);
		g_esPlayer[admin].g_iRespawnAmount = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RespawnAmount", "Respawn Amount", "Respawn_Amount", "amount", g_esPlayer[admin].g_iRespawnAmount, value, 1, 999999);
		g_esPlayer[admin].g_flRespawnChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RespawnChance", "Respawn Chance", "Respawn_Chance", "chance", g_esPlayer[admin].g_flRespawnChance, value, 0.0, 100.0);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "RespawnType", false) || StrEqual(key, "Respawn Type", false) || StrEqual(key, "Respawn_Type", false) || StrEqual(key, "type", false))
			{
				static char sValue[10];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");

				static char sRange[2][5];
				ExplodeString(sValue, "-", sRange, sizeof(sRange), sizeof(sRange[]));

				g_esPlayer[admin].g_iRespawnMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, MT_MAXTYPES) : g_esPlayer[admin].g_iRespawnMinType;
				g_esPlayer[admin].g_iRespawnMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, MT_MAXTYPES) : g_esPlayer[admin].g_iRespawnMaxType;
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esAbility[type].g_iComboAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iOpenAreasOnly = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_iOpenAreasOnly, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iRespawnAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iRespawnAbility, value, 0, 1);
		g_esAbility[type].g_iRespawnMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iRespawnMessage, value, 0, 1);
		g_esAbility[type].g_iRespawnAmount = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RespawnAmount", "Respawn Amount", "Respawn_Amount", "amount", g_esAbility[type].g_iRespawnAmount, value, 1, 999999);
		g_esAbility[type].g_flRespawnChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RespawnChance", "Respawn Chance", "Respawn_Chance", "chance", g_esAbility[type].g_flRespawnChance, value, 0.0, 100.0);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "RespawnType", false) || StrEqual(key, "Respawn Type", false) || StrEqual(key, "Respawn_Type", false) || StrEqual(key, "type", false))
			{
				static char sValue[10];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");

				static char sRange[2][5];
				ExplodeString(sValue, "-", sRange, sizeof(sRange), sizeof(sRange[]));

				g_esAbility[type].g_iRespawnMinType = (sRange[0][0] != '\0') ? iClamp(StringToInt(sRange[0]), 0, MT_MAXTYPES) : g_esAbility[type].g_iRespawnMinType;
				g_esAbility[type].g_iRespawnMaxType = (sRange[1][0] != '\0') ? iClamp(StringToInt(sRange[1]), 0, MT_MAXTYPES) : g_esAbility[type].g_iRespawnMaxType;
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);\
	g_esCache[tank].g_flRespawnChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRespawnChance, g_esAbility[type].g_flRespawnChance);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iOpenAreasOnly = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOpenAreasOnly, g_esAbility[type].g_iOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iRespawnAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRespawnAbility, g_esAbility[type].g_iRespawnAbility);
	g_esCache[tank].g_iRespawnAmount = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRespawnAmount, g_esAbility[type].g_iRespawnAmount);
	g_esCache[tank].g_iRespawnMaxType = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRespawnMaxType, g_esAbility[type].g_iRespawnMaxType);
	g_esCache[tank].g_iRespawnMinType = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRespawnMinType, g_esAbility[type].g_iRespawnMinType);
	g_esCache[tank].g_iRespawnMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRespawnMessage, g_esAbility[type].g_iRespawnMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveRespawn(oldTank);
	}
}

public void MT_OnHookEvent(bool hooked)
{
	switch (hooked)
	{
		case true:
		{
			if (!g_ddEventKilled.Enable(Hook_Pre, mreEventKilledPre))
			{
				SetFailState("Failed to enable detour pre: CTerrorPlayer::Event_Killed");
			}
		}
		case false:
		{
			if (!g_ddEventKilled.Disable(Hook_Pre, mreEventKilledPre))
			{
				SetFailState("Failed to disable detour pre: CTerrorPlayer::Event_Killed");
			}
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsTank(iTank))
		{
			vCopyStats(iBot, iTank);
			vRemoveRespawn(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveRespawn(iTank);
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start"))
	{
		vReset();
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SPECIAL_KEY2)
		{
			if (g_esCache[tank].g_iRespawnAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				switch (g_esPlayer[tank].g_bActivated)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman2");
					case false:
					{
						switch (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)
						{
							case true:
							{
								g_esPlayer[tank].g_bActivated = true;

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman");
							}
							case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnAmmo");
						}
					}
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
{
	vRemoveRespawn(tank, revert);
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_bActivated = g_esPlayer[oldTank].g_bActivated;
	g_esPlayer[newTank].g_iAmmoCount = g_esPlayer[oldTank].g_iAmmoCount;
	g_esPlayer[newTank].g_iCount = g_esPlayer[oldTank].g_iCount;
}

static void vRemoveRespawn(int tank, bool revert = false)
{
	g_esPlayer[tank].g_bActivated = false;

	if (revert)
	{
		g_esPlayer[tank].g_iAmmoCount = 0;
		g_esPlayer[tank].g_iCount = 0;
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveRespawn(iPlayer);
		}
	}
}

static void vRespawn(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bActivated)
	{
		g_esPlayer[tank].g_bActivated = false;
		g_esPlayer[tank].g_iCount = 0;

		return;
	}

	if (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iRespawnAmount && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)))
	{
		g_esPlayer[tank].g_bActivated = false;
		g_esPlayer[tank].g_iCount++;

		if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			g_esPlayer[tank].g_iAmmoCount++;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnHuman3", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);
		}

		bool[] bExists = new bool[MaxClients + 1];
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			bExists[iPlayer] = false;
			if (bIsTank(iPlayer, MT_CHECK_INGAME))
			{
				bExists[iPlayer] = true;
			}
		}

		switch (g_esCache[tank].g_iRespawnMinType == 0 || g_esCache[tank].g_iRespawnMaxType == 0)
		{
			case true: vRespawn2(tank);
			case false: vRespawn2(tank, g_esCache[tank].g_iRespawnMinType, g_esCache[tank].g_iRespawnMaxType);
		}

		static int iTank;
		iTank = 0;
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsTank(iPlayer, MT_CHECK_INGAME|MT_CHECK_ALIVE) && !bExists[iPlayer] && iPlayer != tank)
			{
				iTank = iPlayer;
				g_esPlayer[iTank].g_bActivated = false;
				g_esPlayer[iTank].g_iAmmoCount = g_esPlayer[tank].g_iAmmoCount;
				g_esPlayer[iTank].g_iCount = g_esPlayer[tank].g_iCount;

				vRemoveRespawn(tank);

				break;
			}
		}

		if (bIsTank(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			static float flPos[3], flAngles[3];
			GetClientAbsOrigin(tank, flPos);
			GetClientEyeAngles(tank, flAngles);
			TeleportEntity(iTank, flPos, flAngles, NULL_VECTOR);

			if (g_esCache[tank].g_iRespawnMessage == 1)
			{
				static char sTankName[33];
				MT_GetTankName(tank, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Respawn", sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Respawn", LANG_SERVER, sTankName);
			}
		}
		else
		{
			vRemoveRespawn(tank);
		}
	}
	else
	{
		vRemoveRespawn(tank);

		if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "RespawnAmmo");
		}
	}
}

static void vRespawn2(int tank, int min = 0, int max = 0)
{
	static int iMin, iMax, iTypeCount, iTankTypes[MT_MAXTYPES + 1];
	iMin = (min > 0) ? min : MT_GetMinType();
	iMax = (max > 0) ? max : MT_GetMaxType();
	iTypeCount = 0;
	for (int iIndex = iMin; iIndex <= iMax; iIndex++)
	{
		if (!MT_IsTypeEnabled(iIndex) || !MT_CanTypeSpawn(iIndex) || MT_DoesTypeRequireHumans(iIndex))
		{
			continue;
		}

		iTankTypes[iTypeCount + 1] = iIndex;
		iTypeCount++;
	}

	static int iType;
	iType = (iTypeCount > 0) ? iTankTypes[GetRandomInt(1, iTypeCount)] : g_esPlayer[tank].g_iTankType;
	MT_SpawnTank(tank, iType);
}

public Action tTimerCombo(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iRespawnAbility == 0)
	{
		return Plugin_Stop;
	}

	vRespawn(iTank);

	return Plugin_Continue;
}