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

//#file "Item Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Item Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank gives survivors items upon death.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Item Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MT_MENU_ITEM "Item Ability"

enum struct esPlayer
{
	bool g_bActivated;

	char g_sItemLoadout[325];

	float g_flItemChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iItemAbility;
	int g_iItemMessage;
	int g_iItemMode;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	char g_sItemLoadout[325];

	float g_flItemChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iItemAbility;
	int g_iItemMessage;
	int g_iItemMode;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	char g_sItemLoadout[325];

	float g_flItemChance;

	int g_iHumanAbility;
	int g_iItemAbility;
	int g_iItemMessage;
	int g_iItemMode;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

bool g_bCloneInstalled;

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

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("mt_clone");
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_item", cmdItemInfo, "View information about the Item ability.");
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	g_esPlayer[client].g_bActivated = false;
}

public void OnClientDisconnect_Post(int client)
{
	g_esPlayer[client].g_bActivated = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdItemInfo(int client, int args)
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
		case false: vItemMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vItemMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iItemMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Item Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iItemMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iItemAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons4");
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "ItemDetails");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vItemMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "ItemMenu", param1);
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
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 2:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 3:
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
	menu.AddItem(MT_MENU_ITEM, MT_MENU_ITEM);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_ITEM, false))
	{
		vItemMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_ITEM, false))
	{
		FormatEx(buffer, size, "%T", "ItemMenu2", client);
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
	list.PushString("itemability");
	list2.PushString("item ability");
	list3.PushString("item_ability");
	list4.PushString("item");
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
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iItemAbility = 0;
				g_esAbility[iIndex].g_iItemMessage = 0;
				g_esAbility[iIndex].g_flItemChance = 33.3;
				g_esAbility[iIndex].g_sItemLoadout = "rifle,pistol,first_aid_kit,pain_pills";
				g_esAbility[iIndex].g_iItemMode = 0;
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
					g_esPlayer[iPlayer].g_iHumanAbility = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iItemAbility = 0;
					g_esPlayer[iPlayer].g_iItemMessage = 0;
					g_esPlayer[iPlayer].g_flItemChance = 0.0;
					g_esPlayer[iPlayer].g_sItemLoadout[0] = '\0';
					g_esPlayer[iPlayer].g_iItemMode = 0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "itemability", "item ability", "item_ability", "item", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "itemability", "item ability", "item_ability", "item", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iItemAbility = iGetKeyValue(subsection, "itemability", "item ability", "item_ability", "item", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iItemAbility, value, 0, 1);
		g_esPlayer[admin].g_iItemMessage = iGetKeyValue(subsection, "itemability", "item ability", "item_ability", "item", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iItemMessage, value, 0, 1);
		g_esPlayer[admin].g_flItemChance = flGetKeyValue(subsection, "itemability", "item ability", "item_ability", "item", key, "ItemChance", "Item Chance", "Item_Chance", "chance", g_esPlayer[admin].g_flItemChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iItemMode = iGetKeyValue(subsection, "itemability", "item ability", "item_ability", "item", key, "ItemMode", "Item Mode", "Item_Mode", "mode", g_esPlayer[admin].g_iItemMode, value, 0, 1);

		if (StrEqual(subsection, "itemability", false) || StrEqual(subsection, "item ability", false) || StrEqual(subsection, "item_ability", false) || StrEqual(subsection, "item", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esPlayer[admin].g_iImmunityFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ItemLoadout", false) || StrEqual(key, "Item Loadout", false) || StrEqual(key, "Item_Loadout", false) || StrEqual(key, "loadout", false))
			{
				strcopy(g_esPlayer[admin].g_sItemLoadout, sizeof(esPlayer::g_sItemLoadout), value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "itemability", "item ability", "item_ability", "item", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "itemability", "item ability", "item_ability", "item", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iItemAbility = iGetKeyValue(subsection, "itemability", "item ability", "item_ability", "item", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iItemAbility, value, 0, 1);
		g_esAbility[type].g_iItemMessage = iGetKeyValue(subsection, "itemability", "item ability", "item_ability", "item", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iItemMessage, value, 0, 1);
		g_esAbility[type].g_flItemChance = flGetKeyValue(subsection, "itemability", "item ability", "item_ability", "item", key, "ItemChance", "Item Chance", "Item_Chance", "chance", g_esAbility[type].g_flItemChance, value, 0.0, 100.0);
		g_esAbility[type].g_iItemMode = iGetKeyValue(subsection, "itemability", "item ability", "item_ability", "item", key, "ItemMode", "Item Mode", "Item_Mode", "mode", g_esAbility[type].g_iItemMode, value, 0, 1);

		if (StrEqual(subsection, "itemability", false) || StrEqual(subsection, "item ability", false) || StrEqual(subsection, "item_ability", false) || StrEqual(subsection, "item", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esAbility[type].g_iImmunityFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ItemLoadout", false) || StrEqual(key, "Item Loadout", false) || StrEqual(key, "Item_Loadout", false) || StrEqual(key, "loadout", false))
			{
				strcopy(g_esAbility[type].g_sItemLoadout, sizeof(esAbility::g_sItemLoadout), value);
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	vGetSettingValue(apply, bHuman, g_esCache[tank].g_sItemLoadout, sizeof(esCache::g_sItemLoadout), g_esPlayer[tank].g_sItemLoadout, g_esAbility[type].g_sItemLoadout);
	g_esCache[tank].g_flItemChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flItemChance, g_esAbility[type].g_flItemChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iItemAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iItemAbility, g_esAbility[type].g_iItemAbility);
	g_esCache[tank].g_iItemMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iItemMessage, g_esAbility[type].g_iItemMessage);
	g_esCache[tank].g_iItemMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iItemMode, g_esAbility[type].g_iItemMode);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && bIsCloneAllowed(iTank, g_bCloneInstalled) && g_esCache[iTank].g_iItemAbility == 1 && GetRandomFloat(0.1, 100.0) <= g_esCache[iTank].g_flItemChance && g_esPlayer[iTank].g_bActivated)
		{
			vItemAbility(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esCache[tank].g_iItemAbility == 1 && GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flItemChance && !g_esPlayer[tank].g_bActivated)
	{
		g_esPlayer[tank].g_bActivated = true;
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SPECIAL_KEY2)
		{
			if (g_esCache[tank].g_iItemAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				switch (g_esPlayer[tank].g_bActivated)
				{
					case true: MT_PrintToChat(tank, "%s %t", MT_TAG3, "ItemHuman2");
					case false:
					{
						g_esPlayer[tank].g_bActivated = true;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "ItemHuman");
					}
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esCache[tank].g_iItemAbility == 1)
	{
		vItemAbility(tank);
	}
}

static void vItemAbility(int tank)
{
	g_esPlayer[tank].g_bActivated = false;

	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	static char sItems[5][64];
	ReplaceString(g_esCache[tank].g_sItemLoadout, sizeof(esCache::g_sItemLoadout), " ", "");
	ExplodeString(g_esCache[tank].g_sItemLoadout, ",", sItems, sizeof(sItems), sizeof(sItems[]));

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
		{
			switch (g_esCache[tank].g_iItemMode)
			{
				case 0: vCheatCommand(iSurvivor, "give", sItems[GetRandomInt(1, 5) - 1]);
				case 1:
				{
					for (int iItem = 0; iItem < sizeof(sItems); iItem++)
					{
						if (StrContains(g_esCache[tank].g_sItemLoadout, sItems[iItem]) != -1 && sItems[iItem][0] != '\0')
						{
							vCheatCommand(iSurvivor, "give", sItems[iItem]);
						}
					}
				}
			}
		}
	}

	if (g_esCache[tank].g_iItemMessage == 1)
	{
		static char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Item", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Item", LANG_SERVER, sTankName);
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			g_esPlayer[iPlayer].g_bActivated = false;
		}
	}
}