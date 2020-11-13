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

#pragma semicolon 1
#pragma newdecls required

//#file "Minion Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Minion Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank spawns minions.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Minion Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MT_CONFIG_SECTION "minionability"
#define MT_CONFIG_SECTION2 "minion ability"
#define MT_CONFIG_SECTION3 "minion_ability"
#define MT_CONFIG_SECTION4 "minion"
#define MT_CONFIG_SECTIONS MT_CONFIG_SECTION, MT_CONFIG_SECTION2, MT_CONFIG_SECTION3, MT_CONFIG_SECTION4

#define MT_MENU_MINION "Minion Ability"

enum struct esPlayer
{
	bool g_bMinion;

	float g_flMinionChance;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iCooldown;
	int g_iCount;
	int g_iCount2;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iMinionAbility;
	int g_iMinionAmount;
	int g_iMinionMessage;
	int g_iMinionReplace;
	int g_iMinionTypes;
	int g_iOpenAreasOnly;
	int g_iOwner;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flMinionChance;

	int g_iAccessFlags;
	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iMinionAbility;
	int g_iMinionAmount;
	int g_iMinionMessage;
	int g_iMinionReplace;
	int g_iMinionTypes;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flMinionChance;

	int g_iComboAbility;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iMinionAbility;
	int g_iMinionAmount;
	int g_iMinionMessage;
	int g_iMinionReplace;
	int g_iMinionTypes;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_minion", cmdMinionInfo, "View information about the Minion ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveMinion(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveMinion(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdMinionInfo(int client, int args)
{
	if (!MT_IsCorePluginEnabled())
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG4, "PluginDisabled");

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		MT_ReplyToCommand(client, "%s %t", MT_TAG, "Command is in-game only");

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: MT_ReplyToCommand(client, "%s %t", MT_TAG2, "Vote in Progress");
		case false: vMinionMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vMinionMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iMinionMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Minion Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iMinionMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iMinionAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount2, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons3");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "MinionDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vMinionMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "MinionMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[PLATFORM_MAX_PATH];

			switch (param2)
			{
				case 0:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 1:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Ammunition", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 2:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 3:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);

					return RedrawMenuItem(sMenuOption);
				}
			}
		}
	}

	return 0;
}

public void MT_OnDisplayMenu(Menu menu)
{
	menu.AddItem(MT_MENU_MINION, MT_MENU_MINION);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_MINION, false))
	{
		vMinionMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_MINION, false))
	{
		FormatEx(buffer, size, "%T", "MinionMenu2", client);
	}
}

public void MT_OnPluginCheck(ArrayList &list)
{
	char sName[32];
	GetPluginFilename(null, sName, sizeof(sName));
	list.PushString(sName);
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
		if (type == MT_COMBO_MAINRANGE && g_esCache[tank].g_iMinionAbility == 1 && g_esCache[tank].g_iComboAbility == 1)
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
							case 0.0: vMinion(tank);
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
				g_esAbility[iIndex].g_iHumanCooldown = 60;
				g_esAbility[iIndex].g_iOpenAreasOnly = 1;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iMinionAbility = 0;
				g_esAbility[iIndex].g_iMinionMessage = 0;
				g_esAbility[iIndex].g_iMinionAmount = 5;
				g_esAbility[iIndex].g_flMinionChance = 33.3;
				g_esAbility[iIndex].g_iMinionReplace = 1;
				g_esAbility[iIndex].g_iMinionTypes = 0;
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
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iOpenAreasOnly = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iMinionAbility = 0;
					g_esPlayer[iPlayer].g_iMinionMessage = 0;
					g_esPlayer[iPlayer].g_iMinionAmount = 0;
					g_esPlayer[iPlayer].g_flMinionChance = 0.0;
					g_esPlayer[iPlayer].g_iMinionReplace = 0;
					g_esPlayer[iPlayer].g_iMinionTypes = 0;
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
		g_esPlayer[admin].g_iMinionAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esPlayer[admin].g_iMinionAbility, value, 0, 1);
		g_esPlayer[admin].g_iMinionMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iMinionMessage, value, 0, 1);
		g_esPlayer[admin].g_iMinionAmount = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MinionAmount", "Minion Amount", "Minion_Amount", "amount", g_esPlayer[admin].g_iMinionAmount, value, 1, 15);
		g_esPlayer[admin].g_flMinionChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MinionChance", "Minion Chance", "Minion_Chance", "chance", g_esPlayer[admin].g_flMinionChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iMinionReplace = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MinionReplace", "Minion Replace", "Minion_Replace", "replace", g_esPlayer[admin].g_iMinionReplace, value, 0, 1);
		g_esPlayer[admin].g_iMinionTypes = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MinionTypes", "Minion Types", "Minion_Types", "types", g_esPlayer[admin].g_iMinionTypes, value, 0, 63);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
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
		g_esAbility[type].g_iMinionAbility = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "aenabled", g_esAbility[type].g_iMinionAbility, value, 0, 1);
		g_esAbility[type].g_iMinionMessage = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iMinionMessage, value, 0, 1);
		g_esAbility[type].g_iMinionAmount = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MinionAmount", "Minion Amount", "Minion_Amount", "amount", g_esAbility[type].g_iMinionAmount, value, 1, 15);
		g_esAbility[type].g_flMinionChance = flGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MinionChance", "Minion Chance", "Minion_Chance", "chance", g_esAbility[type].g_flMinionChance, value, 0.0, 100.0);
		g_esAbility[type].g_iMinionReplace = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MinionReplace", "Minion Replace", "Minion_Replace", "replace", g_esAbility[type].g_iMinionReplace, value, 0, 1);
		g_esAbility[type].g_iMinionTypes = iGetKeyValue(subsection, MT_CONFIG_SECTIONS, key, "MinionTypes", "Minion Types", "Minion_Types", "types", g_esAbility[type].g_iMinionTypes, value, 0, 63);

		if (StrEqual(subsection, MT_CONFIG_SECTION, false) || StrEqual(subsection, MT_CONFIG_SECTION2, false) || StrEqual(subsection, MT_CONFIG_SECTION3, false) || StrEqual(subsection, MT_CONFIG_SECTION4, false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	g_esCache[tank].g_flMinionChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flMinionChance, g_esAbility[type].g_flMinionChance);
	g_esCache[tank].g_iComboAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iComboAbility, g_esAbility[type].g_iComboAbility);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iMinionAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iMinionAbility, g_esAbility[type].g_iMinionAbility);
	g_esCache[tank].g_iMinionAmount = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iMinionAmount, g_esAbility[type].g_iMinionAmount);
	g_esCache[tank].g_iMinionMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iMinionMessage, g_esAbility[type].g_iMinionMessage);
	g_esCache[tank].g_iMinionReplace = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iMinionReplace, g_esAbility[type].g_iMinionReplace);
	g_esCache[tank].g_iMinionTypes = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iMinionTypes, g_esAbility[type].g_iMinionTypes);
	g_esCache[tank].g_iOpenAreasOnly = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOpenAreasOnly, g_esAbility[type].g_iOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	vCopyStats(oldTank, newTank);

	if (oldTank != newTank)
	{
		vRemoveMinion(oldTank);
	}
}

public void MT_OnPluginEnd()
{
	for (int iMinion = 1; iMinion <= MaxClients; iMinion++)
	{
		if ((bIsTank(iMinion, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) || bIsSpecialInfected(iMinion, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE)) && g_esPlayer[iMinion].g_bMinion)
		{
			switch (bIsValidClient(iMinion, MT_CHECK_FAKECLIENT))
			{
				case true: ForcePlayerSuicide(iMinion);
				case false: KickClient(iMinion);
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
			vRemoveMinion(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vCopyStats(iTank, iBot);
			vRemoveMinion(iTank);
		}
	}
	else if (StrEqual(name, "player_death"))
	{
		int iInfectedId = event.GetInt("userid"), iInfected = GetClientOfUserId(iInfectedId);
		if (MT_IsTankSupported(iInfected, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveMinion(iInfected);
		}

		if (bIsSpecialInfected(iInfected) && g_esPlayer[iInfected].g_bMinion)
		{
			for (int iOwner = 1; iOwner <= MaxClients; iOwner++)
			{
				if (MT_IsTankSupported(iOwner, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && MT_IsCustomTankSupported(iOwner) && g_esPlayer[iInfected].g_iOwner == iOwner)
				{
					g_esPlayer[iInfected].g_bMinion = false;
					g_esPlayer[iInfected].g_iOwner = 0;

					if (g_esCache[iOwner].g_iMinionAbility == 1)
					{
						switch (g_esPlayer[iOwner].g_iCount)
						{
							case 0, 1: g_esPlayer[iOwner].g_iCount = 0;
							default:
							{
								if (g_esCache[iOwner].g_iMinionReplace == 1)
								{
									g_esPlayer[iOwner].g_iCount--;
								}

								MT_PrintToChat(iOwner, "%s %t", MT_TAG3, "MinionHuman4");
							}
						}
					}

					break;
				}
			}
		}
	}
	else if (StrEqual(name, "mission_lost") || StrEqual(name, "round_start"))
	{
		vReset();
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iMinionAbility == 1 && g_esCache[tank].g_iComboAbility == 0)
	{
		vMinionAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SPECIAL_KEY)
		{
			if (g_esCache[tank].g_iMinionAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();

				switch (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime)
				{
					case true: vMinionAbility(tank);
					case false: MT_PrintToChat(tank, "%s %t", MT_TAG3, "MinionHuman3", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveMinion(tank, revert);
}

static void vCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
	g_esPlayer[newTank].g_iCount = g_esPlayer[oldTank].g_iCount;
	g_esPlayer[newTank].g_iCount2 = g_esPlayer[oldTank].g_iCount2;
}

static void vMinion(int tank)
{
	if (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iMinionAmount)
	{
		static float flHitPosition[3], flPosition[3], flAngles[3], flVector[3];
		GetClientEyePosition(tank, flPosition);
		GetClientEyeAngles(tank, flAngles);
		flAngles[0] = -25.0;

		GetAngleVectors(flAngles, flAngles, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(flAngles, flAngles);
		ScaleVector(flAngles, -1.0);
		vCopyVector(flAngles, flVector);
		GetVectorAngles(flAngles, flAngles);

		static Handle hTrace;
		hTrace = TR_TraceRayFilterEx(flPosition, flAngles, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelf, tank);
		if (hTrace != null)
		{
			if (TR_DidHit(hTrace))
			{
				TR_GetEndPosition(flHitPosition, hTrace);
				NormalizeVector(flVector, flVector);
				ScaleVector(flVector, -40.0);
				AddVectors(flHitPosition, flVector, flHitPosition);

				static float flDistance;
				flDistance = GetVectorDistance(flHitPosition, flPosition);
				if (40.0 < flDistance < 200.0)
				{
					bool[] bSpecialInfected = new bool[MaxClients + 1];
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						bSpecialInfected[iPlayer] = false;
						if (bIsInfected(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
						{
							bSpecialInfected[iPlayer] = true;
						}
					}

					static int iTypeCount, iTypes[6];
					iTypeCount = 0;
					for (int iBit = 0; iBit < sizeof(iTypes); iBit++)
					{
						int iFlag = (1 << iBit);
						if (!(g_esCache[tank].g_iMinionTypes & iFlag))
						{
							continue;
						}

						iTypes[iTypeCount] = iFlag;
						iTypeCount++;
					}

					switch (iTypes[GetRandomInt(0, iTypeCount - 1)])
					{
						case 1: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "smoker");
						case 2: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "boomer");
						case 4: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "hunter");
						case 8: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "spitter" : "boomer");
						case 16: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "jockey" : "hunter");
						case 32: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "charger" : "smoker");
						default:
						{
							switch (GetRandomInt(1, 6))
							{
								case 1: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "smoker");
								case 2: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "boomer");
								case 3: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "hunter");
								case 4: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "spitter" : "boomer");
								case 5: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "jockey" : "hunter");
								case 6: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "charger" : "smoker");
							}
						}
					}

					static int iSelectedType;
					iSelectedType = 0;
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						if (bIsInfected(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && !bSpecialInfected[iPlayer])
						{
							iSelectedType = iPlayer;

							break;
						}
					}

					if (bIsInfected(iSelectedType))
					{
						TeleportEntity(iSelectedType, flHitPosition, NULL_VECTOR, NULL_VECTOR);

						g_esPlayer[iSelectedType].g_bMinion = true;
						g_esPlayer[tank].g_iCount++;
						g_esPlayer[iSelectedType].g_iOwner = tank;

						static int iTime;
						iTime = GetTime();
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < iTime))
						{
							g_esPlayer[tank].g_iCount2++;

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MinionHuman", g_esPlayer[tank].g_iCount2, g_esCache[tank].g_iHumanAmmo);

							g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
							if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "MinionHuman5", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}

						if (g_esCache[tank].g_iMinionMessage == 1)
						{
							static char sTankName[33];
							MT_GetTankName(tank, sTankName);
							MT_PrintToChatAll("%s %t", MT_TAG2, "Minion", sTankName);
							MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Minion", LANG_SERVER, sTankName);
						}
					}
				}
			}

			delete hTrace;
		}
	}
}

static void vMinionAbility(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iMinionAmount && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flMinionChance)
		{
			vMinion(tank);
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "MinionHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "MinionAmmo");
	}
}

static void vRemoveMinion(int tank, bool revert = false)
{
	if (!revert)
	{
		g_esPlayer[tank].g_bMinion = false;
	}

	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCount2 = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveMinion(iPlayer);

			g_esPlayer[iPlayer].g_iOwner = 0;
		}
	}
}

public Action tTimerCombo(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || g_esCache[iTank].g_iMinionAbility == 0)
	{
		return Plugin_Stop;
	}

	vMinion(iTank);

	return Plugin_Continue;
}