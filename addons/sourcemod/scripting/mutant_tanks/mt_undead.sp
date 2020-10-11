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

//#file "Undead Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Undead Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank cannot die.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Undead Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_UNDEAD "Undead Ability"

enum struct esPlayer
{
	bool g_bActivated;

	float g_flUndeadChance;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iCount2;
	int g_iHealth;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iTankType;
	int g_iUndeadAbility;
	int g_iUndeadAmount;
	int g_iUndeadMessage;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flUndeadChance;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iUndeadAbility;
	int g_iUndeadAmount;
	int g_iUndeadMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flUndeadChance;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iRequiresHumans;
	int g_iUndeadAbility;
	int g_iUndeadAmount;
	int g_iUndeadMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_undead", cmdUndeadInfo, "View information about the Undead ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveUndead(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveUndead(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdUndeadInfo(int client, int args)
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
		case false: vUndeadMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vUndeadMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iUndeadMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Undead Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iUndeadMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iUndeadAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount2, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "UndeadDetails");
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vUndeadMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "UndeadMenu", param1);
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
	menu.AddItem(MT_MENU_UNDEAD, MT_MENU_UNDEAD);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_UNDEAD, false))
	{
		vUndeadMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_UNDEAD, false))
	{
		FormatEx(buffer, size, "%T", "UndeadMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim) && g_esPlayer[victim].g_bActivated)
		{
			if (MT_DoesTypeRequireHumans(g_esPlayer[victim].g_iTankType) || (g_esCache[victim].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)))
			{
				return Plugin_Continue;
			}

			if (GetClientHealth(victim) - RoundToNearest(damage) <= 0)
			{
				g_esPlayer[victim].g_bActivated = false;

				//SetEntityHealth(victim, g_esPlayer[victim].g_iHealth);
				SetEntProp(victim, Prop_Data, "m_iHealth", g_esPlayer[victim].g_iHealth);

				static int iTime;
				iTime = GetTime();
				if (MT_IsTankSupported(victim, MT_CHECK_FAKECLIENT) && g_esCache[victim].g_iHumanAbility == 1 && (g_esPlayer[victim].g_iCooldown == -1 || g_esPlayer[victim].g_iCooldown < iTime))
				{
					g_esPlayer[victim].g_iCooldown = (g_esPlayer[victim].g_iCount < g_esCache[victim].g_iHumanAmmo && g_esCache[victim].g_iHumanAmmo > 0) ? (iTime + g_esCache[victim].g_iHumanCooldown) : -1;
					if (g_esPlayer[victim].g_iCooldown != -1 && g_esPlayer[victim].g_iCooldown > iTime)
					{
						MT_PrintToChat(victim, "%s %t", MT_TAG3, "UndeadHuman5", g_esPlayer[victim].g_iCooldown - iTime);
					}
				}

				if (g_esCache[victim].g_iUndeadMessage == 1)
				{
					static char sTankName[33];
					MT_GetTankName(victim, sTankName);
					MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Undead2", sTankName);
				}

				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

public void MT_OnPluginCheck(ArrayList &list)
{
	char sName[32];
	GetPluginFilename(null, sName, sizeof(sName));
	list.PushString(sName);
}

public void MT_OnAbilityCheck(ArrayList &list, ArrayList &list2, ArrayList &list3, ArrayList &list4)
{
	list.PushString("undeadability");
	list2.PushString("undead ability");
	list3.PushString("undead_ability");
	list4.PushString("undead");
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
				g_esAbility[iIndex].g_iHumanAbility = 0;
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iHumanCooldown = 30;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iUndeadAbility = 0;
				g_esAbility[iIndex].g_iUndeadMessage = 0;
				g_esAbility[iIndex].g_iUndeadAmount = 1;
				g_esAbility[iIndex].g_flUndeadChance = 33.3;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esPlayer[iPlayer].g_iAccessFlags = 0;
					g_esPlayer[iPlayer].g_iHumanAbility = 0;
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iUndeadAbility = 0;
					g_esPlayer[iPlayer].g_iUndeadMessage = 0;
					g_esPlayer[iPlayer].g_iUndeadAmount = 0;
					g_esPlayer[iPlayer].g_flUndeadChance = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 1);
		g_esPlayer[admin].g_iUndeadAbility = iGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iUndeadAbility, value, 0, 1);
		g_esPlayer[admin].g_iUndeadMessage = iGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iUndeadMessage, value, 0, 1);
		g_esPlayer[admin].g_iUndeadAmount = iGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "UndeadAmount", "Undead Amount", "Undead_Amount", "amount", g_esPlayer[admin].g_iUndeadAmount, value, 1, 999999);
		g_esPlayer[admin].g_flUndeadChance = flGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "UndeadChance", "Undead Chance", "Undead_Chance", "chance", g_esPlayer[admin].g_flUndeadChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "undeadability", false) || StrEqual(subsection, "undead ability", false) || StrEqual(subsection, "undead_ability", false) || StrEqual(subsection, "undead", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 1);
		g_esAbility[type].g_iUndeadAbility = iGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iUndeadAbility, value, 0, 1);
		g_esAbility[type].g_iUndeadMessage = iGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iUndeadMessage, value, 0, 1);
		g_esAbility[type].g_iUndeadAmount = iGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "UndeadAmount", "Undead Amount", "Undead_Amount", "amount", g_esAbility[type].g_iUndeadAmount, value, 1, 999999);
		g_esAbility[type].g_flUndeadChance = flGetKeyValue(subsection, "undeadability", "undead ability", "undead_ability", "undead", key, "UndeadChance", "Undead Chance", "Undead_Chance", "chance", g_esAbility[type].g_flUndeadChance, value, 0.0, 100.0);

		if (StrEqual(subsection, "undeadability", false) || StrEqual(subsection, "undead ability", false) || StrEqual(subsection, "undead_ability", false) || StrEqual(subsection, "undead", false))
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
	g_esCache[tank].g_flUndeadChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flUndeadChance, g_esAbility[type].g_flUndeadChance);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iUndeadAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iUndeadAbility, g_esAbility[type].g_iUndeadAbility);
	g_esCache[tank].g_iUndeadAmount = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iUndeadAmount, g_esAbility[type].g_iUndeadAmount);
	g_esCache[tank].g_iUndeadMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iUndeadMessage, g_esAbility[type].g_iUndeadMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveUndead(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iUndeadAbility == 1 && !g_esPlayer[tank].g_bActivated)
	{
		vUndeadAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_SPECIAL_KEY)
		{
			if (g_esCache[tank].g_iUndeadAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;
				if (!g_esPlayer[tank].g_bActivated && !bRecharging)
				{
					vUndeadAbility(tank);
				}
				else if (g_esPlayer[tank].g_bActivated)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "UndeadHuman3");
				}
				else if (bRecharging)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "UndeadHuman4", g_esPlayer[tank].g_iCooldown - iTime);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveUndead(tank);
}

public void MT_OnPostTankSpawn(int tank)
{
	if (MT_IsTankSupported(tank))
	{
		g_esPlayer[tank].g_iHealth = GetClientHealth(tank);
	}
}

static void vRemoveUndead(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCount2 = 0;
	g_esPlayer[tank].g_iHealth = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveUndead(iPlayer);
		}
	}
}

static void vUndeadAbility(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iUndeadAmount && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount2 < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flUndeadChance)
		{
			g_esPlayer[tank].g_bActivated = true;
			g_esPlayer[tank].g_iCount++;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				g_esPlayer[tank].g_iCount2++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "UndeadHuman", g_esPlayer[tank].g_iCount2, g_esCache[tank].g_iHumanAmmo);
			}

			if (g_esCache[tank].g_iUndeadMessage == 1)
			{
				static char sTankName[33];
				MT_GetTankName(tank, sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Undead", sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "UndeadHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "UndeadAmmo");
	}
}