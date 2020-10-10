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

#file "Pyro Ability v8.79"

public Plugin myinfo =
{
	name = "[MT] Pyro Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank ignites itself and gains a speed boost when on fire.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Pyro Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_PYRO "Pyro Ability"

enum struct esPlayer
{
	bool g_bActivated;
	bool g_bActivated2;

	float g_flPyroChance;
	float g_flPyroDamageBoost;
	float g_flPyroSpeedBoost;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iDuration;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iPyroAbility;
	int g_iPyroDuration;
	int g_iPyroMessage;
	int g_iPyroMode;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flPyroChance;
	float g_flPyroDamageBoost;
	float g_flPyroSpeedBoost;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iPyroAbility;
	int g_iPyroDuration;
	int g_iPyroMessage;
	int g_iPyroMode;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flPyroChance;
	float g_flPyroDamageBoost;
	float g_flPyroSpeedBoost;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iPyroAbility;
	int g_iPyroDuration;
	int g_iPyroMessage;
	int g_iPyroMode;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_pyro", cmdPyroInfo, "View information about the Pyro ability.");

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

	vRemovePyro(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemovePyro(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdPyroInfo(int client, int args)
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
		case false: vPyroMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vPyroMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iPyroMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Pyro Ability Information");
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

public int iPyroMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iPyroAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "PyroDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iPyroDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vPyroMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "PyroMenu", param1);
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
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "ButtonMode", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 6:
				{
					FormatEx(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);

					return RedrawMenuItem(sMenuOption);
				}
				case 7:
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
	menu.AddItem(MT_MENU_PYRO, MT_MENU_PYRO);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_PYRO, false))
	{
		vPyroMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_PYRO, false))
	{
		FormatEx(buffer, size, "%T", "PyroMenu2", client);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(client) || !g_esPlayer[client].g_bActivated || (MT_IsTankSupported(client, MT_CHECK_FAKECLIENT) && g_esCache[client].g_iHumanMode == 1))
	{
		return Plugin_Continue;
	}

	if (!bIsPlayerBurning(client))
	{
		IgniteEntity(client, float(g_esCache[client].g_iPyroDuration));
	}

	static int iTime;
	iTime = GetTime();
	if (g_esPlayer[client].g_iDuration != -1 && g_esPlayer[client].g_iDuration < iTime)
	{
		if (MT_IsTankSupported(client, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(client) || bHasAdminAccess(client, g_esAbility[g_esPlayer[client].g_iTankType].g_iAccessFlags, g_esPlayer[client].g_iAccessFlags)) && g_esCache[client].g_iHumanAbility == 1 && (g_esPlayer[client].g_iCooldown == -1 || g_esPlayer[client].g_iCooldown < iTime))
		{
			vReset3(client);
		}

		vReset2(client);
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim))
		{
			if (!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags))
			{
				return Plugin_Continue;
			}

			if (g_esCache[victim].g_iPyroAbility == 1)
			{
				if ((damagetype & DMG_BURN) || bIsPlayerBurning(victim))
				{
					if (!g_esPlayer[victim].g_bActivated)
					{
						g_esPlayer[victim].g_bActivated = true;
						g_esPlayer[victim].g_iDuration = GetTime() + g_esCache[victim].g_iPyroDuration;
					}

					switch (g_esCache[victim].g_iPyroMode)
					{
						case 0: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", MT_GetRunSpeed(victim) + g_esCache[victim].g_flPyroSpeedBoost);
						case 1: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", g_esCache[victim].g_flPyroSpeedBoost);
					}

					if (!g_esPlayer[victim].g_bActivated2 && g_esCache[victim].g_iPyroMessage == 1)
					{
						g_esPlayer[victim].g_bActivated2 = true;

						static char sTankName[33];
						MT_GetTankName(victim, sTankName);
						MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Pyro2", sTankName);
					}
				}
			}
		}
		else if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker))
		{
			if (!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags))
			{
				return Plugin_Continue;
			}

			if (g_esCache[attacker].g_iPyroAbility == 1)
			{
				if (g_esPlayer[attacker].g_bActivated)
				{
					static char sClassname[32];
					GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
					if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
					{
						switch (g_esCache[attacker].g_iPyroMode)
						{
							case 0: damage += g_esCache[attacker].g_flPyroDamageBoost;
							case 1: damage = g_esCache[attacker].g_flPyroDamageBoost;
						}

						return Plugin_Changed;
					}
				}
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
	list.PushString("pyroability");
	list2.PushString("pyro ability");
	list3.PushString("pyro_ability");
	list4.PushString("pyro");
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
				g_esAbility[iIndex].g_iHumanMode = 1;
				g_esAbility[iIndex].g_iRequiresHumans = 0;
				g_esAbility[iIndex].g_iPyroAbility = 0;
				g_esAbility[iIndex].g_iPyroMessage = 0;
				g_esAbility[iIndex].g_flPyroChance = 33.3;
				g_esAbility[iIndex].g_flPyroDamageBoost = 5.0;
				g_esAbility[iIndex].g_iPyroDuration = 5;
				g_esAbility[iIndex].g_iPyroMode = 0;
				g_esAbility[iIndex].g_flPyroSpeedBoost = 1.0;
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
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iHumanMode = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iPyroAbility = 0;
					g_esPlayer[iPlayer].g_iPyroMessage = 0;
					g_esPlayer[iPlayer].g_flPyroChance = 0.0;
					g_esPlayer[iPlayer].g_flPyroDamageBoost = 0.0;
					g_esPlayer[iPlayer].g_iPyroDuration = 0;
					g_esPlayer[iPlayer].g_iPyroMode = 0;
					g_esPlayer[iPlayer].g_flPyroSpeedBoost = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 1);
		g_esPlayer[admin].g_iPyroAbility = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iPyroAbility, value, 0, 1);
		g_esPlayer[admin].g_iPyroMessage = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iPyroMessage, value, 0, 1);
		g_esPlayer[admin].g_flPyroChance = flGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroChance", "Pyro Chance", "Pyro_Chance", "chance", g_esPlayer[admin].g_flPyroChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flPyroDamageBoost = flGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroDamageBoost", "Pyro Damage Boost", "Pyro_Damage_Boost", "dmgboost", g_esPlayer[admin].g_flPyroDamageBoost, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iPyroDuration = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroDuration", "Pyro Duration", "Pyro_Duration", "duration", g_esPlayer[admin].g_iPyroDuration, value, 1, 999999);
		g_esPlayer[admin].g_iPyroMode = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroMode", "Pyro Mode", "Pyro_Mode", "mode", g_esPlayer[admin].g_iPyroMode, value, 0, 1);
		g_esPlayer[admin].g_flPyroSpeedBoost = flGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroSpeedBoost", "Pyro Speed Boost", "Pyro_Speed_Boost", "speedboost", g_esPlayer[admin].g_flPyroSpeedBoost, value, 0.1, 3.0);

		if (StrEqual(subsection, "pyroability", false) || StrEqual(subsection, "pyro ability", false) || StrEqual(subsection, "pyro_ability", false) || StrEqual(subsection, "pyro", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 1);
		g_esAbility[type].g_iPyroAbility = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iPyroAbility, value, 0, 1);
		g_esAbility[type].g_iPyroMessage = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iPyroMessage, value, 0, 1);
		g_esAbility[type].g_flPyroChance = flGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroChance", "Pyro Chance", "Pyro_Chance", "chance", g_esAbility[type].g_flPyroChance, value, 0.0, 100.0);
		g_esAbility[type].g_flPyroDamageBoost = flGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroDamageBoost", "Pyro Damage Boost", "Pyro_Damage_Boost", "dmgboost", g_esAbility[type].g_flPyroDamageBoost, value, 0.1, 999999.0);
		g_esAbility[type].g_iPyroDuration = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroDuration", "Pyro Duration", "Pyro_Duration", "duration", g_esAbility[type].g_iPyroDuration, value, 1, 999999);
		g_esAbility[type].g_iPyroMode = iGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroMode", "Pyro Mode", "Pyro_Mode", "mode", g_esAbility[type].g_iPyroMode, value, 0, 1);
		g_esAbility[type].g_flPyroSpeedBoost = flGetKeyValue(subsection, "pyroability", "pyro ability", "pyro_ability", "pyro", key, "PyroSpeedBoost", "Pyro Speed Boost", "Pyro_Speed_Boost", "speedboost", g_esAbility[type].g_flPyroSpeedBoost, value, 0.1, 3.0);

		if (StrEqual(subsection, "pyroability", false) || StrEqual(subsection, "pyro ability", false) || StrEqual(subsection, "pyro_ability", false) || StrEqual(subsection, "pyro", false))
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
	g_esCache[tank].g_flPyroChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flPyroChance, g_esAbility[type].g_flPyroChance);
	g_esCache[tank].g_flPyroDamageBoost = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flPyroDamageBoost, g_esAbility[type].g_flPyroDamageBoost);
	g_esCache[tank].g_flPyroSpeedBoost = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flPyroSpeedBoost, g_esAbility[type].g_flPyroSpeedBoost);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_iPyroAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPyroAbility, g_esAbility[type].g_iPyroAbility);
	g_esCache[tank].g_iPyroDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPyroDuration, g_esAbility[type].g_iPyroDuration);
	g_esCache[tank].g_iPyroMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPyroMessage, g_esAbility[type].g_iPyroMessage);
	g_esCache[tank].g_iPyroMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iPyroMode, g_esAbility[type].g_iPyroMode);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iTank].g_bActivated)
		{
			SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", 1.0);
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
			vRemovePyro(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iPyroAbility == 1 && !g_esPlayer[tank].g_bActivated)
	{
		vPyroAbility(tank);
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

		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iPyroAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
			{
				static int iTime;
				iTime = GetTime();
				static bool bRecharging;
				bRecharging = g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime;

				switch (g_esCache[tank].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bActivated && !bRecharging)
						{
							vPyroAbility(tank);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman4", g_esPlayer[tank].g_iCooldown - iTime);
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bActivated && !bRecharging)
							{
								g_esPlayer[tank].g_bActivated = true;
								g_esPlayer[tank].g_iCount++;

								IgniteEntity(tank, float(g_esCache[tank].g_iPyroDuration));
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman3");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman4", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroAmmo");
						}
					}
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
	{
		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iHumanMode == 1 && g_esPlayer[tank].g_bActivated && (g_esPlayer[tank].g_iCooldown == -1 || g_esPlayer[tank].g_iCooldown < GetTime()))
			{
				vReset2(tank);
				vReset3(tank);
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemovePyro(tank);
}

static void vPyroAbility(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans == 1 && iGetHumanCount() == 0) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flPyroChance)
		{
			g_esPlayer[tank].g_bActivated = true;
			g_esPlayer[tank].g_iDuration = GetTime() + g_esCache[tank].g_iPyroDuration;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				g_esPlayer[tank].g_iCount++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
			}

			IgniteEntity(tank, float(g_esCache[tank].g_iPyroDuration));

			if (g_esCache[tank].g_iPyroMessage == 1)
			{
				static char sTankName[33];
				MT_GetTankName(tank, sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Pyro", sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroAmmo");
	}
}

static void vRemovePyro(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_bActivated2 = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iDuration = -1;
	g_esPlayer[tank].g_iCount = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemovePyro(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_bActivated2 = false;
	g_esPlayer[tank].g_iDuration = -1;

	ExtinguishEntity(tank);
	SetEntPropFloat(tank, Prop_Send, "m_flLaggedMovementValue", MT_GetRunSpeed(tank));

	if (g_esCache[tank].g_iPyroMessage == 1)
	{
		char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %t", MT_TAG2, "Pyro3", sTankName);
	}
}

static void vReset3(int tank)
{
	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "PyroHuman5", g_esPlayer[tank].g_iCooldown - iTime);
	}
}