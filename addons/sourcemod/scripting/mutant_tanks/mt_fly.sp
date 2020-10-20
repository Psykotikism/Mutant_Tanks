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

//#file "Fly Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Fly Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank can fly.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Fly Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_FLY_ATTACK (1 << 0) // when tank attacks
#define MT_FLY_HURT (1 << 1) // when tank is hurt
#define MT_FLY_THROW (1 << 2) // when tank throws a rock
#define MT_FLY_JUMP (1 << 3) // when tank jumps

#define MT_MENU_FLY "Fly Ability"

enum struct esPlayer
{
	bool g_bActivated;
	bool g_bFailed;

	float g_flCurrentVelocity[3];
	float g_flFlyChance;
	float g_flFlySpeed;
	float g_flLastTime;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iDuration;
	int g_iFlyAbility;
	int g_iFlyDuration;
	int g_iFlyMessage;
	int g_iFlyType;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flFlyChance;
	float g_flFlySpeed;

	int g_iAccessFlags;
	int g_iFlyAbility;
	int g_iFlyDuration;
	int g_iFlyMessage;
	int g_iFlyType;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flFlyChance;
	float g_flFlySpeed;

	int g_iFlyAbility;
	int g_iFlyDuration;
	int g_iFlyMessage;
	int g_iFlyType;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_fly", cmdFlyInfo, "View information about the Fly ability.");

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

	vRemoveFly(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveFly(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdFlyInfo(int client, int args)
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
		case false: vFlyMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vFlyMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iFlyMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Fly Ability Information");
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

public int iFlyMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iFlyAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "FlyDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iFlyDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vFlyMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "FlyMenu", param1);
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
	menu.AddItem(MT_MENU_FLY, MT_MENU_FLY);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_FLY, false))
	{
		vFlyMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_FLY, false))
	{
		FormatEx(buffer, size, "%T", "FlyMenu2", client);
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(client) || !g_esPlayer[client].g_bActivated || (MT_IsTankSupported(client, MT_CHECK_FAKECLIENT) && g_esCache[client].g_iHumanMode == 1) || g_esPlayer[client].g_iDuration == -1)
	{
		return Plugin_Continue;
	}

	static int iTime;
	iTime = GetTime();
	if (g_esPlayer[client].g_iDuration < iTime)
	{
		if (MT_IsTankSupported(client, MT_CHECK_FAKECLIENT) && (MT_HasAdminAccess(client) || bHasAdminAccess(client, g_esAbility[g_esPlayer[client].g_iTankType].g_iAccessFlags, g_esPlayer[client].g_iAccessFlags)) && g_esCache[client].g_iHumanAbility == 1 && (g_esPlayer[client].g_iCooldown == -1 || g_esPlayer[client].g_iCooldown < iTime))
		{
			vReset3(client);
		}

		vStopFly(client);
	}

	return Plugin_Continue;
}

public Action PreThink(int tank)
{
	switch (MT_IsTankSupported(tank) && g_esPlayer[tank].g_bActivated)
	{
		case true:
		{
			static float flDuration;
			static int iButtons;
			flDuration = GetEngineTime() - g_esPlayer[tank].g_flLastTime;
			iButtons = GetClientButtons(tank);

			vFlyThink(tank, iButtons, flDuration);
		}
		case false: SDKUnhook(tank, SDKHook_PreThink, PreThink);
	}
}

public Action StartTouch(int tank, int other)
{
	vStopFly(tank); 
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		if (MT_IsTankSupported(attacker) && !MT_IsTankSupported(attacker, MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(attacker) && g_esCache[attacker].g_iFlyAbility == 1 && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iAccessFlags, g_esPlayer[attacker].g_iAccessFlags)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, g_esPlayer[attacker].g_iTankType, g_esAbility[g_esPlayer[attacker].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			static char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				if ((g_esCache[attacker].g_iFlyType == 0 || (g_esCache[attacker].g_iFlyType & MT_FLY_ATTACK)) && !g_esPlayer[attacker].g_bActivated)
				{
					vFlyAbility(attacker);
				}
				else if (g_esPlayer[attacker].g_bActivated)
				{
					vStopFly(attacker);
				}
			}
		}
		else if (MT_IsTankSupported(victim) && !MT_IsTankSupported(victim, MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(victim) && g_esCache[victim].g_iFlyAbility == 1 && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim, g_esAbility[g_esPlayer[victim].g_iTankType].g_iAccessFlags, g_esPlayer[victim].g_iAccessFlags)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, g_esPlayer[victim].g_iTankType, g_esAbility[g_esPlayer[victim].g_iTankType].g_iImmunityFlags, g_esPlayer[attacker].g_iImmunityFlags))
			{
				return Plugin_Continue;
			}

			if ((g_esCache[victim].g_iFlyType == 0 || (g_esCache[victim].g_iFlyType & MT_FLY_HURT)) && !g_esPlayer[victim].g_bActivated)
			{
				vFlyAbility(victim);
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
	list.PushString("flyability");
	list2.PushString("fly ability");
	list3.PushString("fly_ability");
	list4.PushString("fly");
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
				g_esAbility[iIndex].g_iHumanAmmo = 5;
				g_esAbility[iIndex].g_iHumanCooldown = 30;
				g_esAbility[iIndex].g_iHumanMode = 1;
				g_esAbility[iIndex].g_iRequiresHumans = 1;
				g_esAbility[iIndex].g_iFlyAbility = 0;
				g_esAbility[iIndex].g_iFlyMessage = 0;
				g_esAbility[iIndex].g_flFlyChance = 33.3;
				g_esAbility[iIndex].g_iFlyDuration = 30;
				g_esAbility[iIndex].g_flFlySpeed = 500.0;
				g_esAbility[iIndex].g_iFlyType = 0;
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
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iHumanMode = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iFlyAbility = 0;
					g_esPlayer[iPlayer].g_iFlyMessage = 0;
					g_esPlayer[iPlayer].g_flFlyChance = 0.0;
					g_esPlayer[iPlayer].g_iFlyDuration = 0;
					g_esPlayer[iPlayer].g_flFlySpeed = 0.0;
					g_esPlayer[iPlayer].g_iFlyType = 0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 1);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iFlyAbility = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iFlyAbility, value, 0, 1);
		g_esPlayer[admin].g_iFlyMessage = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iFlyMessage, value, 0, 1);
		g_esPlayer[admin].g_flFlyChance = flGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "FlyChance", "Fly Chance", "Fly_Chance", "chance", g_esPlayer[admin].g_flFlyChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iFlyDuration = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "FlyDuration", "Fly Duration", "Fly_Duration", "duration", g_esPlayer[admin].g_iFlyDuration, value, 1, 999999);
		g_esPlayer[admin].g_flFlySpeed = flGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "FlySpeed", "Fly Speed", "Fly_Speed", "speed", g_esPlayer[admin].g_flFlySpeed, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iFlyType = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "FlyType", "Fly Type", "Fly_Type", "type", g_esPlayer[admin].g_iFlyType, value, 0, 15);

		if (StrEqual(subsection, "flyability", false) || StrEqual(subsection, "fly ability", false) || StrEqual(subsection, "fly_ability", false) || StrEqual(subsection, "fly", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iFlyAbility = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iFlyAbility, value, 0, 1);
		g_esAbility[type].g_iFlyMessage = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iFlyMessage, value, 0, 1);
		g_esAbility[type].g_flFlyChance = flGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "FlyChance", "Fly Chance", "Fly_Chance", "chance", g_esAbility[type].g_flFlyChance, value, 0.0, 100.0);
		g_esAbility[type].g_iFlyDuration = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "FlyDuration", "Fly Duration", "Fly_Duration", "duration", g_esAbility[type].g_iFlyDuration, value, 1, 999999);
		g_esAbility[type].g_flFlySpeed = flGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "FlySpeed", "Fly Speed", "Fly_Speed", "speed", g_esAbility[type].g_flFlySpeed, value, 0.1, 999999.0);
		g_esAbility[type].g_iFlyType = iGetKeyValue(subsection, "flyability", "fly ability", "fly_ability", "fly", key, "FlyType", "Fly Type", "Fly_Type", "type", g_esAbility[type].g_iFlyType, value, 0, 15);

		if (StrEqual(subsection, "flyability", false) || StrEqual(subsection, "fly ability", false) || StrEqual(subsection, "fly_ability", false) || StrEqual(subsection, "fly", false))
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
	g_esCache[tank].g_flFlyChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFlyChance, g_esAbility[type].g_flFlyChance);
	g_esCache[tank].g_flFlySpeed = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flFlySpeed, g_esAbility[type].g_flFlySpeed);
	g_esCache[tank].g_iFlyAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFlyAbility, g_esAbility[type].g_iFlyAbility);
	g_esCache[tank].g_iFlyDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFlyDuration, g_esAbility[type].g_iFlyDuration);
	g_esCache[tank].g_iFlyType = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iFlyType, g_esAbility[type].g_iFlyType);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_jump"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT))
		{
			if (g_esCache[iTank].g_iFlyAbility == 1 && (g_esCache[iTank].g_iFlyType == 0 || (g_esCache[iTank].g_iFlyType & MT_FLY_JUMP)) && !g_esPlayer[iTank].g_bActivated)
			{
				vFlyAbility(iTank);
			}
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveFly(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iFlyAbility == 1 && !g_esPlayer[tank].g_bActivated)
	{
		vFlyAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iFlyAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
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
							vFlyAbility(tank);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlyHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlyHuman4", g_esPlayer[tank].g_iCooldown - iTime);
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

								vFly(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlyHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlyHuman3");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlyHuman4", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlyAmmo");
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
				vStopFly(tank);
				vReset3(tank);
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveFly(tank);
}

public void MT_OnRockThrow(int tank, int rock)
{
	if (MT_IsTankSupported(tank) && !MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iFlyAbility == 1 && (g_esCache[tank].g_iFlyType == 0 || (g_esCache[tank].g_iFlyType & MT_FLY_THROW)) && !g_esPlayer[tank].g_bActivated)
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			return;
		}

		vFlyAbility(tank);
	}
}

static void vFly(int tank)
{
	static float flOrigin[3], flPos[3], flAngles[3], flEyeAngles[3];
	flAngles[0] = -89.0;
	GetClientEyePosition(tank, flOrigin);

	static Handle hTrace;
	hTrace = TR_TraceRayFilterEx(flOrigin, flAngles, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelf, tank);
	if (hTrace != null)
	{
		if (TR_DidHit(hTrace))
		{
			TR_GetEndPosition(flPos, hTrace); 

			if (GetVectorDistance(flPos, flOrigin) <= 100.0)
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bFailed)
				{
					g_esPlayer[tank].g_bFailed = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlyHuman6");
				}

				delete hTrace;

				return;
			}
		}

		delete hTrace;
	}

	g_esPlayer[tank].g_bActivated = true;
	g_esPlayer[tank].g_iDuration = GetTime() + g_esCache[tank].g_iFlyDuration;
	g_esPlayer[tank].g_flLastTime = GetEngineTime() - 0.01;

	GetEntPropVector(tank, Prop_Data, "m_vecAbsOrigin", flOrigin);
	GetClientEyeAngles(tank, flEyeAngles);
	flOrigin[2] += 5.0;
	flEyeAngles[2] = 30.0;

	GetAngleVectors(flEyeAngles, flEyeAngles, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(flEyeAngles, flEyeAngles);
	ScaleVector(flEyeAngles, 55.0);
	TeleportEntity(tank, flOrigin, flEyeAngles, NULL_VECTOR);
	vCopyVector(flEyeAngles, g_esPlayer[tank].g_flCurrentVelocity);

	SDKUnhook(tank, SDKHook_PreThink, PreThink);
	SDKHook(tank, SDKHook_PreThink, PreThink);
	SDKUnhook(tank, SDKHook_StartTouch, StartTouch);
	SDKHook(tank, SDKHook_StartTouch, StartTouch);
}

static void vFlyAbility(int tank)
{
	if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		g_esPlayer[tank].g_bFailed = false;

		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flFlyChance)
		{
			vFly(tank);

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				g_esPlayer[tank].g_iCount++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlyHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
			}

			if (g_esCache[tank].g_iFlyMessage == 1)
			{
				static char sTankName[33];
				MT_GetTankName(tank, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Fly", sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Fly", LANG_SERVER, sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlyHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlyAmmo");
	}
}

static void vFlyThink(int tank, int buttons, float duration)
{
	if (bIsValidClient(tank))
	{
		if (MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
		{
			vStopFly(tank);

			return;
		}

		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT))
		{
			if (buttons & IN_USE)
			{
				static float flFall;
				if (buttons & IN_SPEED)
				{
					flFall = 0.75;
				}
				else
				{
					switch (buttons & IN_DUCK)
					{
						case true: flFall = 0.5;
						case false: flFall = 1.0;
					}
				}

				SetEntityGravity(tank, flFall);

				return;
			}

			SetEntityMoveType(tank, MOVETYPE_FLYGRAVITY); 

			static float flEyeAngles[3], flOrigin[3], flTemp[3], flSpeed[3], flSpeed2, flForce[3], flForce2, flGravity, flGravity2; 
			flForce2 = 50.0;
			flGravity = 0.001;
			flGravity2 = 0.01;

			GetEntPropVector(tank, Prop_Data, "m_vecVelocity", flSpeed);
			GetClientEyeAngles(tank, flEyeAngles);
			GetClientAbsOrigin(tank, flOrigin);

			static bool bJumping;
			bJumping = false;

			if (buttons & IN_JUMP) 
			{
				bJumping = true;
				flEyeAngles[0] = -50.0;

				GetAngleVectors(flEyeAngles, flEyeAngles, NULL_VECTOR, NULL_VECTOR);
				NormalizeVector(flEyeAngles, flEyeAngles);
				ScaleVector(flEyeAngles, g_esCache[tank].g_flFlySpeed);
				TeleportEntity(tank, NULL_VECTOR, flEyeAngles, NULL_VECTOR);

				return;
			}

			if ((buttons & IN_SPEED) && !bJumping)
			{
				flSpeed2 = g_esCache[tank].g_flFlySpeed * 75.0 / 100.0;
				if (buttons & IN_FORWARD)
				{
					flSpeed2 = g_esCache[tank].g_flFlySpeed;
				}

				GetAngleVectors(flEyeAngles, flEyeAngles, NULL_VECTOR, NULL_VECTOR);
				NormalizeVector(flEyeAngles, flEyeAngles);
				ScaleVector(flEyeAngles, flSpeed2);
				TeleportEntity(tank, NULL_VECTOR, flEyeAngles, NULL_VECTOR);

				return;
			}
			else if (!(buttons & IN_SPEED) && (buttons & IN_DUCK) && !bJumping)
			{
				flSpeed2 = g_esCache[tank].g_flFlySpeed * 33.33 / 100.0;
				if (buttons & IN_FORWARD)
				{
					flSpeed2 = g_esCache[tank].g_flFlySpeed * 50.0 / 100.0;
				}

				GetAngleVectors(flEyeAngles, flEyeAngles, NULL_VECTOR, NULL_VECTOR);
				NormalizeVector(flEyeAngles, flEyeAngles);
				ScaleVector(flEyeAngles, flSpeed2);
				TeleportEntity(tank, NULL_VECTOR, flEyeAngles, NULL_VECTOR);

				return;
			}
			
			if (buttons & IN_FORWARD)
			{
				GetAngleVectors(flEyeAngles, flTemp, NULL_VECTOR, NULL_VECTOR);
				NormalizeVector(flTemp, flTemp);
				AddVectors(flForce, flTemp, flForce);
			}
			else if (buttons & IN_BACK)
			{
				GetAngleVectors(flEyeAngles, flTemp, NULL_VECTOR, NULL_VECTOR);
				NormalizeVector(flTemp, flTemp); 
				SubtractVectors(flForce, flTemp, flForce);
			}

			if (buttons & IN_MOVELEFT)
			{
				GetAngleVectors(flEyeAngles, NULL_VECTOR, flTemp, NULL_VECTOR);
				NormalizeVector(flTemp, flTemp); 
				SubtractVectors(flForce, flTemp, flForce);
			}
			else if (buttons & IN_MOVERIGHT)
			{
				GetAngleVectors(flEyeAngles, NULL_VECTOR, flTemp, NULL_VECTOR);
				NormalizeVector(flTemp, flTemp); 
				AddVectors(flForce, flTemp, flForce);
			}

			NormalizeVector(flForce, flForce);
			ScaleVector(flForce, flForce2 * duration);

			switch (FloatAbs(flSpeed[2]) > 40.0)
			{
				case true: flGravity = flSpeed[2] * duration;
				case false: flGravity = flGravity2;
			}

			static float flSpeed3;
			flSpeed3 = GetVectorLength(flSpeed);

			if (flGravity > 0.5)
			{
				flGravity = 0.5;
			}
			else if (flGravity < -0.5)
			{
				flGravity = -0.5; 
			}

			if (flSpeed3 > g_esCache[tank].g_flFlySpeed)
			{
				NormalizeVector(flSpeed, flSpeed);
				ScaleVector(flSpeed, g_esCache[tank].g_flFlySpeed);
				TeleportEntity(tank, NULL_VECTOR, NULL_VECTOR, flSpeed);
				flGravity = flGravity2;
			}

			SetEntityGravity(tank, flGravity);

			return;
		}

		static float flPos[3], flVelocity[3];
		GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flPos);
		GetEntPropVector(tank, Prop_Data, "m_vecVelocity", flVelocity);
		flPos[2] += 30.0;

		vCopyVector(g_esPlayer[tank].g_flCurrentVelocity, flVelocity);

		if (GetVectorLength(flVelocity) < 10.0)
		{
			return;
		}

		NormalizeVector(flVelocity, flVelocity);

		static int iTarget;
		if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT))
		{
			iTarget = iGetFlyTarget(flPos, flVelocity, tank);
		}
		else
		{
			float flDirection[3];
			GetClientEyeAngles(tank, flDirection);
			GetAngleVectors(flDirection, flDirection, NULL_VECTOR, NULL_VECTOR); 
			NormalizeVector(flDirection, flDirection);
			iTarget = iGetFlyTarget(flPos, flDirection, tank);
		}

		static float flVector[3], flVelocity2[3], flAngles[3], flDistance;
		flDistance = 1000.0;
		static bool bVisible;
		bVisible = false;

		if (bIsSurvivor(iTarget))
		{
			static float flPos2[3];
			GetClientEyePosition(iTarget, flPos2);
			flDistance = GetVectorDistance(flPos, flPos2);
			bVisible = bVisiblePosition(flPos, flPos2, tank, 1);

			GetEntPropVector(iTarget, Prop_Data, "m_vecVelocity", flVelocity2);
			ScaleVector(flVelocity2, duration);
			AddVectors(flPos2, flVelocity2, flPos2);
			MakeVectorFromPoints(flPos, flPos2, flVector);
		}

		static float flLeft[3], flRight[3], flUp[3], flDown[3], flFront[3], flVector1[3], flVector2[3], flVector3[3], flVector4[3],
			flVector5[3], flVector6[3], flVector7[3], flVector8[3], flVector9, flFactor1, flFactor2, flBase, flBase2;
		flFactor1 = 0.2;
		flFactor2 = 0.5;
		flBase = 1500.0;
		flBase2 = 10.0;

		GetVectorAngles(flVelocity, flAngles);

		static float flFront2, flDown2, flUp2, flLeft2, flRight2, flDistance2, flDistance3, flDistance4, flDistance5, flDistance6, flDistance7, flDistance8, flDistance9;
		flFront2 = flGetDistance(flPos, flAngles, 0.0, 0.0, flFront, tank, 3);
		flDown2 = flGetDistance(flPos, flAngles, 90.0, 0.0, flDown, tank, 3);
		flUp2 = flGetDistance(flPos, flAngles, -90.0, 0.0, flUp, tank, 3);
		flLeft2 = flGetDistance(flPos, flAngles, 0.0, 90.0, flLeft, tank, 3);
		flRight2 = flGetDistance(flPos, flAngles, 0.0, -90.0, flRight, tank, 3);
		flDistance2 = flGetDistance(flPos, flAngles, 30.0, 0.0, flVector1, tank, 3);
		flDistance3 = flGetDistance(flPos, flAngles, 30.0, 45.0, flVector2, tank, 3);
		flDistance4 = flGetDistance(flPos, flAngles, 0.0, 45.0, flVector3, tank, 3);
		flDistance5 = flGetDistance(flPos, flAngles, -30.0, 45.0, flVector4, tank, 3);
		flDistance6 = flGetDistance(flPos, flAngles, -30.0, 0.0, flVector5, tank, 3);
		flDistance7 = flGetDistance(flPos, flAngles, -30.0, -45.0, flVector6, tank, 3);
		flDistance8 = flGetDistance(flPos, flAngles, 0.0, -45.0, flVector7, tank, 3);
		flDistance9 = flGetDistance(flPos, flAngles, 30.0, -45.0, flVector8, tank, 3);

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

		if (bVisible)
		{
			flBase = 80.0;
		}

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

		if (flFront2 < flBase2)
		{
			flFront2 = flBase2;
		}

		if (flUp2 < flBase2)
		{
			flUp2 = flBase2;
		}

		if (flDown2  < flBase2)
		{
			flDown2 = flBase2;
		}

		if (flLeft2  < flBase2)
		{
			flLeft2 = flBase2;
		}

		if (flRight2 < flBase2)
		{
			flRight2 = flBase2;
		}

		if (flDistance2 < flBase2)
		{
			flDistance2 = flBase2;
		}

		if (flDistance3 < flBase2)
		{
			flDistance3 = flBase2;	
		}

		if (flDistance4 < flBase2)
		{
			flDistance4 = flBase2;
		}

		if (flDistance5 < flBase2)
		{
			flDistance5 = flBase2;
		}

		if (flDistance6 < flBase2)
		{
			flDistance6 = flBase2;
		}

		if (flDistance7 < flBase2)
		{
			flDistance7 = flBase2;
		}

		if (flDistance8 < flBase2)
		{
			flDistance8 = flBase2;
		}

		if (flDistance9 < flBase2)
		{
			flDistance9 = flBase2;
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
		ScaleVector(flFront, 3.141592 * duration * 2.0);

		static float flVelocity3[3];
		AddVectors(flVelocity, flFront, flVelocity3);

		NormalizeVector(flVelocity3, flVelocity3);
		ScaleVector(flVelocity3, g_esCache[tank].g_flFlySpeed);

		SetEntityMoveType(tank, MOVETYPE_FLY);
		vCopyVector(flVelocity3, g_esPlayer[tank].g_flCurrentVelocity);
		
		TeleportEntity(tank, NULL_VECTOR, NULL_VECTOR, flVelocity3);
	}
}

static void vRemoveFly(int tank)
{
	vStopFly(tank);
	vReset4(tank);

	g_esPlayer[tank].g_bFailed = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveFly(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	vReset4(tank);

	if (g_esCache[tank].g_iFlyMessage == 1)
	{
		char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Fly2", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Fly2", LANG_SERVER, sTankName);
	}
}

static void vReset3(int tank)
{
	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "FlyHuman5", g_esPlayer[tank].g_iCooldown - iTime);
	}
}

static void vReset4(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_flCurrentVelocity[0] = 0.0;
	g_esPlayer[tank].g_flCurrentVelocity[1] = 0.0;
	g_esPlayer[tank].g_flCurrentVelocity[2] = 0.0;
	g_esPlayer[tank].g_flLastTime = 0.0;
	g_esPlayer[tank].g_iDuration = -1;
}

static void vStopFly(int tank)
{
	vReset2(tank);

	SDKUnhook(tank, SDKHook_PreThink, PreThink);
	SDKUnhook(tank, SDKHook_StartTouch, StartTouch);

	if (MT_IsTankSupported(tank))
	{
		SetEntityMoveType(tank, MOVETYPE_WALK);
		SetEntityGravity(tank, 1.0);
	}
}

static int iGetFlyTarget(float pos[3], float angle[3], int tank)
{
	static float flMin, flPos[3], flAngle;
	flMin = 4.0;
	static int iTarget;
	iTarget = 0;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE))
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