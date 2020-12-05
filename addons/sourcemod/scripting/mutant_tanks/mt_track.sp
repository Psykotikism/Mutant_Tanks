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
#include <sdkhooks>
#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Track Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank throws heat-seeking rocks that will track down the nearest survivors.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Track Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MT_CONFIG_SECTION "trackability"
#define MT_CONFIG_SECTION2 "track ability"
#define MT_CONFIG_SECTION3 "track_ability"
#define MT_CONFIG_SECTION4 "track"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_TRACK "Track Ability"

enum struct esPlayer
{
	bool g_bActivated;

	float g_flTrackChance;
	float g_flTrackSpeed;

	int g_iAccessFlags;
	int g_iAmmoCount;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iTrackAbility;
	int g_iTrackGlow;
	int g_iTrackMessage;
	int g_iTrackMode;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flTrackChance;
	float g_flTrackSpeed;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iTrackAbility;
	int g_iTrackGlow;
	int g_iTrackMessage;
	int g_iTrackMode;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flTrackChance;
	float g_flTrackSpeed;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iTrackAbility;
	int g_iTrackGlow;
	int g_iTrackMessage;
	int g_iTrackMode;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_track", cmdTrackInfo, "View information about the Track ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveTrack(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveTrack(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdTrackInfo(int client, int args)
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
		case false: vTrackMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vTrackMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iTrackMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Track Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iTrackMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iTrackAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iAmmoCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons4");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "TrackDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME))
			{
				vTrackMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel pTrack = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "TrackMenu", param1);
			pTrack.SetTitle(sMenuTitle);
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
					case 3: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					case 4: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					case 5: FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
				}

				return RedrawMenuItem(sMenuOption);
			}
		}
	}

	return 0;
}

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_TRACK, MT_MENU_TRACK);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_TRACK, false))
	{
		vTrackMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_TRACK, false))
	{
		FormatEx(buffer, size, "%T", "TrackMenu2", client);
	}
}

public void Think(int rock)
{
	switch (bIsValidEntity(rock))
	{
		case true: vTrackThink(rock);
		case false: SDKUnhook(rock, SDKHook_Think, Think);
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
		if (type == MT_COMBO_ROCKTHROW && g_esCache[tank].g_iTrackAbility == 1 && g_esCache[tank].g_iComboAbility == 1 && bIsValidEntity(weapon))
		{
			static char sSubset[10][32];
			ExplodeString(combo, ",", sSubset, sizeof(sSubset), sizeof(sSubset[]));
			for (int iPos = 0; iPos < sizeof(sSubset); iPos++)
			{
				if (StrEqual(sSubset[iPos], MT_CONFIG_SECTION, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION2, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION3, false) || StrEqual(sSubset[iPos], MT_CONFIG_SECTION4, false))
				{
					if (random <= MT_GetCombinationSetting(tank, 1, iPos))
					{
						vTrack(tank, weapon);

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
				g_esAbility[iIndex].g_iImmunityFlags = 0;
				g_esAbility[iIndex].g_iComboAbility = 0;
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iHumanCooldown = 30;
				g_esAbility[iIndex].g_iOpenAreasOnly = 0;
				g_esAbility[iIndex].g_iRequiresHumans = 1;
				g_esAbility[iIndex].g_iTrackAbility = 0;
				g_esAbility[iIndex].g_iTrackMessage = 0;
				g_esAbility[iIndex].g_flTrackChance = 33.3;
				g_esAbility[iIndex].g_iTrackGlow = 1;
				g_esAbility[iIndex].g_iTrackMode = 1;
				g_esAbility[iIndex].g_flTrackSpeed = 500.0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esPlayer[iPlayer].g_iAccessFlags = 0;
					g_esPlayer[iPlayer].g_iImmunityFlags = 0;
					g_esPlayer[iPlayer].g_iComboAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iOpenAreasOnly = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iTrackAbility = 0;
					g_esPlayer[iPlayer].g_iTrackMessage = 0;
					g_esPlayer[iPlayer].g_flTrackChance = 0.0;
					g_esPlayer[iPlayer].g_iTrackGlow = 0;
					g_esPlayer[iPlayer].g_iTrackMode = 0;
					g_esPlayer[iPlayer].g_flTrackSpeed = 0.0;
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
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iOpenAreasOnly = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_iOpenAreasOnly, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iTrackAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iTrackAbility, value, 0, 1);
		g_esPlayer[admin].g_iTrackMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iTrackMessage, value, 0, 1);
		g_esPlayer[admin].g_flTrackChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "TrackChance", "Track Chance", "Track_Chance", "chance", g_esPlayer[admin].g_flTrackChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iTrackGlow = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "TrackGlow", "Track Glow", "Track_Glow", "glow", g_esPlayer[admin].g_iTrackGlow, value, 0, 1);
		g_esPlayer[admin].g_iTrackMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "TrackMode", "Track Mode", "Track_Mode", "mode", g_esPlayer[admin].g_iTrackMode, value, 0, 1);
		g_esPlayer[admin].g_flTrackSpeed = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "TrackSpeed", "Track Speed", "Track_Speed", "speed", g_esPlayer[admin].g_flTrackSpeed, value, 0.1, 999999.0);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esPlayer[admin].g_iImmunityFlags = ReadFlagString(value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iComboAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "ComboAbility", "Combo Ability", "Combo_Ability", "combo", g_esAbility[type].g_iComboAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iOpenAreasOnly = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_iOpenAreasOnly, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iTrackAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iTrackAbility, value, 0, 1);
		g_esAbility[type].g_iTrackMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iTrackMessage, value, 0, 1);
		g_esAbility[type].g_flTrackChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "TrackChance", "Track Chance", "Track_Chance", "chance", g_esAbility[type].g_flTrackChance, value, 0.0, 100.0);
		g_esAbility[type].g_iTrackGlow = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "TrackGlow", "Track Glow", "Track_Glow", "glow", g_esAbility[type].g_iTrackGlow, value, 0, 1);
		g_esAbility[type].g_iTrackMode = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "TrackMode", "Track Mode", "Track_Mode", "mode", g_esAbility[type].g_iTrackMode, value, 0, 1);
		g_esAbility[type].g_flTrackSpeed = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "TrackSpeed", "Track Speed", "Track_Speed", "speed", g_esAbility[type].g_flTrackSpeed, value, 0.1, 999999.0);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esAbility[type].g_iImmunityFlags = ReadFlagString(value);
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	g_esCache[tank].g_flTrackChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flTrackChance, g_esAbility[type].g_flTrackChance);
	g_esCache[tank].g_flTrackSpeed = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flTrackSpeed, g_esAbility[type].g_flTrackSpeed);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iOpenAreasOnly = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOpenAreasOnly, g_esAbility[type].g_iOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iTrackAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iTrackAbility, g_esAbility[type].g_iTrackAbility);
	g_esCache[tank].g_iTrackGlow = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iTrackGlow, g_esAbility[type].g_iTrackGlow);
	g_esCache[tank].g_iTrackMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iTrackMessage, g_esAbility[type].g_iTrackMessage);
	g_esCache[tank].g_iTrackMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iTrackMode, g_esAbility[type].g_iTrackMode);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveTrack(oldTank);
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
			vRemoveTrack(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveTrack(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME))
		{
			vRemoveTrack(iTank);
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

		if (button & MT_SPECIAL_KEY)
		{
			if (g_esCache[tank].g_iTrackAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;
				if (!g_esPlayer[tank].g_bActivated && !bRecharging)
				{
					switch (g_esPlayer[tank].g_iAmmoCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)
					{
						case true:
						{
							g_esPlayer[tank].g_bActivated = true;
							g_esPlayer[tank].g_iAmmoCount++;

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "TrackHuman", g_esPlayer[tank].g_iAmmoCount, g_esCache[tank].g_iHumanAmmo);
						}
						case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "TrackAmmo");
					}
				}
				else if (g_esPlayer[tank].g_bActivated)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "TrackHuman2");
				}
				else if (bRecharging)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "TrackHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, int oldType, int newType, bool revert)
{
	vRemoveTrack(tank);
}

public void MT_OnRockBreak(int tank, int rock)
{
	vSetGlow(rock, 0, 0, 0, 0, 0);
}

public void MT_OnRockThrow(int tank, int rock)
{
	if (MT_IsTankSupported(tank) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iTrackAbility == 1 && g_esCache[tank].g_iComboAbility == 0 && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flTrackChance)
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		vTrack(tank, rock);
	}
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iAmmoCount = g_esPlayer[oldTank].g_iAmmoCount;
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
}

static void vRemoveTrack(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iAmmoCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME))
		{
			vRemoveTrack(iPlayer);
		}
	}
}

static void vSetGlow(int rock, int color, int flashing, int min, int max, int type)
{
	if (!bIsValidGame())
	{
		return;
	}

	SetEntProp(rock, Prop_Send, "m_glowColorOverride", color);
	SetEntProp(rock, Prop_Send, "m_bFlashing", flashing);
	SetEntProp(rock, Prop_Send, "m_nGlowRangeMin", min);
	SetEntProp(rock, Prop_Send, "m_nGlowRange", max);
	SetEntProp(rock, Prop_Send, "m_iGlowType", type);
}

static void vTrack(int tank, int rock)
{
	if ((!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && !g_esPlayer[tank].g_bActivated)
	{
		g_esPlayer[tank].g_bActivated = true;
	}

	DataPack dpTrack;
	CreateDataTimer(0.5, tTimerTrack, dpTrack, TIMER_FLAG_NO_MAPCHANGE);
	dpTrack.WriteCell(EntIndexToEntRef(rock));
	dpTrack.WriteCell(GetClientUserId(tank));
	dpTrack.WriteCell(g_esPlayer[tank].g_iTankType);

	if (g_esCache[tank].g_iTrackMessage == 1)
	{
		static char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Track", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Track", LANG_SERVER, sTankName);
	}
}

static void vTrackThink(int rock)
{
	static int iTank;
	iTank = GetEntPropEnt(rock, Prop_Data, "m_hThrower");
	if (bIsValidClient(iTank))
	{
		if (bIsAreaNarrow(iTank, g_esCache[iTank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)))
		{
			return;
		}

		switch (g_esCache[iTank].g_iTrackMode)
		{
			case 0:
			{
				static float flPos[3], flVelocity[3];
				GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flPos);
				GetEntPropVector(rock, Prop_Data, "m_vecVelocity", flVelocity);

				static float flVector;
				flVector = GetVectorLength(flVelocity);
				if (flVector < 100.0)
				{
					return;
				}

				NormalizeVector(flVelocity, flVelocity);

				static int iTarget;
				iTarget = iGetRockTarget(flPos, flVelocity, iTank);
				if (bIsSurvivor(iTarget))
				{
					static float flPos2[3], flVelocity2[3];
					GetClientEyePosition(iTarget, flPos2);
					GetEntPropVector(iTarget, Prop_Data, "m_vecVelocity", flVelocity2);
					if (!bVisiblePosition(flPos, flPos2, rock, 2) || GetVectorDistance(flPos, flPos2) > 500.0)
					{
						return;
					}

					SetEntityGravity(rock, 0.01);

					static float flDirection[3], flVelocity3[3];
					SubtractVectors(flPos2, flPos, flDirection);
					NormalizeVector(flDirection, flDirection);

					ScaleVector(flDirection, 0.5);
					AddVectors(flVelocity, flDirection, flVelocity3);

					NormalizeVector(flVelocity3, flVelocity3);
					ScaleVector(flVelocity3, flVector);

					TeleportEntity(rock, NULL_VECTOR, NULL_VECTOR, flVelocity3);
				}
			}
			case 1:
			{
				static float flPos[3], flVelocity[3];
				GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flPos);
				GetEntPropVector(rock, Prop_Data, "m_vecVelocity", flVelocity);

				if (GetVectorLength(flVelocity) < 50.0)
				{
					return;
				}

				NormalizeVector(flVelocity, flVelocity);

				static int iTarget;
				iTarget = iGetRockTarget(flPos, flVelocity, iTank);
				static float flVelocity2[3], flVector[3], flAngles[3], flDistance;
				flDistance = 1000.0;
				static bool bVisible;
				bVisible = false;
				flVector[0] = flVector[1] = flVector[2] = 0.0;

				if (bIsSurvivor(iTarget))
				{
					static float flPos2[3];
					GetClientEyePosition(iTarget, flPos2);
					flDistance = GetVectorDistance(flPos, flPos2);
					bVisible = bVisiblePosition(flPos, flPos2, rock, 1);

					GetEntPropVector(iTarget, Prop_Data, "m_vecVelocity", flVelocity2);
					AddVectors(flPos2, flVelocity2, flPos2);
					MakeVectorFromPoints(flPos, flPos2, flVector);
				}

				GetVectorAngles(flVelocity, flAngles);

				static float flLeft[3], flRight[3], flUp[3], flDown[3], flFront[3], flVector1[3], flVector2[3], flVector3[3], flVector4[3],
					flVector5[3], flVector6[3], flVector7[3], flVector8[3], flVector9, flFactor1, flFactor2, flBase;
				flFactor1 = 0.2;
				flFactor2 = 0.5;
				flBase = 1500.0;
				flFront[0] = flFront[1] = flFront[2] = 0.0;

				if (bVisible)
				{
					flBase = 80.0;

					static float flFront2, flDown2, flUp2, flLeft2, flRight2, flDistance2, flDistance3, flDistance4, flDistance5, flDistance6, flDistance7, flDistance8, flDistance9;
					flFront2 = flGetDistance(flPos, flAngles, 0.0, 0.0, flFront, rock, 3);
					flDown2 = flGetDistance(flPos, flAngles, 90.0, 0.0, flDown, rock, 3);
					flUp2 = flGetDistance(flPos, flAngles, -90.0, 0.0, flUp, rock, 3);
					flLeft2 = flGetDistance(flPos, flAngles, 0.0, 90.0, flLeft, rock, 3);
					flRight2 = flGetDistance(flPos, flAngles, 0.0, -90.0, flRight, rock, 3);
					flDistance2 = flGetDistance(flPos, flAngles, 30.0, 0.0, flVector1, rock, 3);
					flDistance3 = flGetDistance(flPos, flAngles, 30.0, 45.0, flVector2, rock, 3);
					flDistance4 = flGetDistance(flPos, flAngles, 0.0, 45.0, flVector3, rock, 3);
					flDistance5 = flGetDistance(flPos, flAngles, -30.0, 45.0, flVector4, rock, 3);
					flDistance6 = flGetDistance(flPos, flAngles, -30.0, 0.0, flVector5, rock, 3);
					flDistance7 = flGetDistance(flPos, flAngles, -30.0, -45.0, flVector6, rock, 3);
					flDistance8 = flGetDistance(flPos, flAngles, 0.0, -45.0, flVector7, rock, 3);
					flDistance9 = flGetDistance(flPos, flAngles, 30.0, -45.0, flVector8, rock, 3);

					NormalizeVector(flFront, flFront);
					NormalizeVector(flUp, flUp);
					NormalizeVector(flDown, flDown);
					NormalizeVector(flLeft, flLeft);
					NormalizeVector(flRight, flRight);
					NormalizeVector(flVector, flVector);
					NormalizeVector(flVector1, flVector1);
					NormalizeVector(flVector2, flVector2);
					NormalizeVector(flVector3, flVector3);
					NormalizeVector(flVector4, flVector4);
					NormalizeVector(flVector5, flVector5);
					NormalizeVector(flVector6, flVector6);
					NormalizeVector(flVector7, flVector7);
					NormalizeVector(flVector8, flVector8);

					if (flFront2 > flBase)
					{
						flFront2 = flBase;
					}

					if (flUp2 > flBase)
					{
						flUp2 = flBase;
					}

					if (flDown2 > flBase)
					{
						flDown2 = flBase;
					}

					if (flLeft2 > flBase)
					{
						flLeft2 = flBase;
					}

					if (flRight2 > flBase)
					{
						flRight2 = flBase;
					}

					if (flDistance2 > flBase)
					{
						flDistance2 = flBase;
					}

					if (flDistance3 > flBase)
					{
						flDistance3 = flBase;
					}

					if (flDistance4 > flBase)
					{
						flDistance4 = flBase;
					}

					if (flDistance5 > flBase)
					{
						flDistance5 = flBase;
					}

					if (flDistance6 > flBase)
					{
						flDistance6 = flBase;
					}

					if (flDistance7 > flBase)
					{
						flDistance7 = flBase;
					}

					if (flDistance8 > flBase)
					{
						flDistance8 = flBase;
					}

					if (flDistance9 > flBase)
					{
						flDistance9 = flBase;
					}

					flVector9 =- 1.0 * flFactor1 * (flBase - flFront2) / flBase;
					ScaleVector(flFront, flVector9);

					flVector9 =- 1.0 * flFactor1 * (flBase - flUp2) / flBase;
					ScaleVector(flUp, flVector9);

					flVector9 =- 1.0 * flFactor1 * (flBase - flDown2) / flBase;
					ScaleVector(flDown, flVector9);

					flVector9 =- 1.0 * flFactor1 * (flBase - flLeft2) / flBase;
					ScaleVector(flLeft, flVector9);

					flVector9 =- 1.0 * flFactor1 * (flBase - flRight2) / flBase;
					ScaleVector(flRight, flVector9);

					flVector9 =- 1.0 * flFactor1 * (flBase - flDistance2) / flDistance2;
					ScaleVector(flVector1, flVector9);

					flVector9 =- 1.0 * flFactor1 * (flBase - flDistance3) / flDistance3;
					ScaleVector(flVector2, flVector9);

					flVector9 =- 1.0 * flFactor1 * (flBase - flDistance4) / flDistance4;
					ScaleVector(flVector3, flVector9);

					flVector9 =- 1.0 * flFactor1 * (flBase - flDistance5) / flDistance5;
					ScaleVector(flVector4, flVector9);

					flVector9 =- 1.0 * flFactor1 * (flBase - flDistance6) / flDistance6;
					ScaleVector(flVector5, flVector9);

					flVector9 =- 1.0 * flFactor1 * (flBase - flDistance7) / flDistance7;
					ScaleVector(flVector6, flVector9);

					flVector9 =- 1.0 * flFactor1 * (flBase - flDistance8) / flDistance8;
					ScaleVector(flVector7, flVector9);

					flVector9 =- 1.0 * flFactor1 * (flBase - flDistance9) / flDistance9;
					ScaleVector(flVector8, flVector9);

					if (flDistance >= 500.0)
					{
						flDistance = 500.0;
					}

					flVector9 = 1.0 * flFactor2 * (1000.0 - flDistance) / 500.0;
					ScaleVector(flVector, flVector9);

					AddVectors(flFront, flUp, flFront);
					AddVectors(flFront, flDown, flFront);
					AddVectors(flFront, flLeft, flFront);
					AddVectors(flFront, flRight, flFront);
					AddVectors(flFront, flVector1, flFront);
					AddVectors(flFront, flVector2, flFront);
					AddVectors(flFront, flVector3, flFront);
					AddVectors(flFront, flVector4, flFront);
					AddVectors(flFront, flVector5, flFront);
					AddVectors(flFront, flVector6, flFront);
					AddVectors(flFront, flVector7, flFront);
					AddVectors(flFront, flVector8, flFront);
					AddVectors(flFront, flVector, flFront);

					NormalizeVector(flFront, flFront);
				}

				static float flAngles2, flVelocity3[3];
				flAngles2 = flGetAngle(flFront, flVelocity);
				ScaleVector(flFront, flAngles2);
				AddVectors(flVelocity, flFront, flVelocity3);
				NormalizeVector(flVelocity3, flVelocity3);

				ScaleVector(flVelocity3, g_esCache[iTank].g_flTrackSpeed);

				SetEntityGravity(rock, 0.01);
				TeleportEntity(rock, NULL_VECTOR, NULL_VECTOR, flVelocity3);

				if (g_esCache[iTank].g_iTrackGlow == 1)
				{
					static int iGlowColor[4];
					MT_GetTankColors(iTank, 2, iGlowColor[0], iGlowColor[1], iGlowColor[2], iGlowColor[3]);
					vSetGlow(rock, iGetRGBColor(iGlowColor[0], iGlowColor[1], iGlowColor[2]), (MT_IsGlowFlashing(iTank) ? 1 : 0), MT_GetGlowRange(iTank, false), MT_GetGlowRange(iTank, true), (MT_GetGlowType(iTank) == 1 ? 3 : 2));
				}
			}
		}
	}
}

static int iGetRockTarget(float pos[3], float angle[3], int tank)
{
	static float flMin, flPos[3], flAngle;
	flMin = 4.0;
	static int iTarget;
	iTarget = 0;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE))
		{
			if (MT_IsAdminImmune(iSurvivor, tank) || bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
			{
				continue;
			}

			GetClientEyePosition(iSurvivor, flPos);
			MakeVectorFromPoints(pos, flPos, flPos);
			flAngle = flGetAngle(angle, flPos);
			if (flAngle <= flMin)
			{
				flMin = flAngle;
				iTarget = iSurvivor;
			}
		}
	}

	return iTarget;
}

public Action tTimerTrack(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iRock;
	iRock = EntRefToEntIndex(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esCache[iTank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || iType != g_esPlayer[iTank].g_iTankType || g_esCache[iTank].g_iTrackAbility == 0 || !g_esPlayer[iTank].g_bActivated)
	{
		g_esPlayer[iTank].g_bActivated = false;

		return Plugin_Stop;
	}

	SDKUnhook(iRock, SDKHook_Think, Think);
	SDKHook(iRock, SDKHook_Think, Think);

	static int iTime;
	iTime = GetTime();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esCache[iTank].g_iHumanAbility == 1 && (g_esPlayer[iTank].g_iCooldown == -1 || g_esPlayer[iTank].g_iCooldown < iTime))
	{
		g_esPlayer[iTank].g_bActivated = false;

		g_esPlayer[iTank].g_iCooldown = (g_esPlayer[iTank].g_iAmmoCount < g_esCache[iTank].g_iHumanAmmo && g_esCache[iTank].g_iHumanAmmo > 0) ? (iTime + g_esCache[iTank].g_iHumanCooldown) : -1;
		if (g_esPlayer[iTank].g_iCooldown != -1 && g_esPlayer[iTank].g_iCooldown > iTime)
		{
			MT_PrintToChat(iTank, "%s %t", MT_TAG3, "TrackHuman4", g_esPlayer[iTank].g_iCooldown - iTime);
		}
	}

	return Plugin_Continue;
}