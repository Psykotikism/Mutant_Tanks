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

//#file "Car Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Car Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank creates car showers.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Car Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MODEL_CAR "models/props_vehicles/cara_82hatchback.mdl"
#define MODEL_CAR2 "models/props_vehicles/cara_69sedan.mdl"
#define MODEL_CAR3 "models/props_vehicles/cara_84sedan.mdl"

#define MT_MENU_CAR "Car Ability"

enum struct esPlayer
{
	bool g_bActivated;

	float g_flCarChance;
	float g_flCarInterval;
	float g_flCarRadius[2];

	int g_iAccessFlags;
	int g_iCarAbility;
	int g_iCarDuration;
	int g_iCarMessage;
	int g_iCarOptions;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flCarChance;
	float g_flCarInterval;
	float g_flCarRadius[2];

	int g_iAccessFlags;
	int g_iCarAbility;
	int g_iCarDuration;
	int g_iCarMessage;
	int g_iCarOptions;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flCarChance;
	float g_flCarInterval;
	float g_flCarRadius[2];

	int g_iCarAbility;
	int g_iCarDuration;
	int g_iCarMessage;
	int g_iCarOptions;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_car", cmdCarInfo, "View information about the Car ability.");
}

public void OnMapStart()
{
	PrecacheModel(MODEL_CAR, true);
	PrecacheModel(MODEL_CAR2, true);
	PrecacheModel(MODEL_CAR3, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveCar(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveCar(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdCarInfo(int client, int args)
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
		case false: vCarMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vCarMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iCarMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Car Ability Information");
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

public int iCarMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iCarAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "CarDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iCarDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vCarMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "CarMenu", param1);
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
	menu.AddItem(MT_MENU_CAR, MT_MENU_CAR);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_CAR, false))
	{
		vCarMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_CAR, false))
	{
		FormatEx(buffer, size, "%T", "CarMenu2", client);
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
	list.PushString("carability");
	list2.PushString("car ability");
	list3.PushString("car_ability");
	list4.PushString("car");
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
				g_esAbility[iIndex].g_iOpenAreasOnly = 1;
				g_esAbility[iIndex].g_iRequiresHumans = 1;
				g_esAbility[iIndex].g_iCarAbility = 0;
				g_esAbility[iIndex].g_iCarMessage = 0;
				g_esAbility[iIndex].g_flCarChance = 33.3;
				g_esAbility[iIndex].g_iCarDuration = 5;
				g_esAbility[iIndex].g_iCarOptions = 0;
				g_esAbility[iIndex].g_flCarInterval = 0.6;
				g_esAbility[iIndex].g_flCarRadius[0] = -180.0;
				g_esAbility[iIndex].g_flCarRadius[1] = 180.0;
			}
		}
		case 3:
		{
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsValidClient(iPlayer))
				{
					g_esPlayer[iPlayer].g_iAccessFlags = 0;
					g_esPlayer[iPlayer].g_iHumanAmmo = 0;
					g_esPlayer[iPlayer].g_iHumanCooldown = 0;
					g_esPlayer[iPlayer].g_iHumanMode = 0;
					g_esPlayer[iPlayer].g_iOpenAreasOnly = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iCarAbility = 0;
					g_esPlayer[iPlayer].g_iCarMessage = 0;
					g_esPlayer[iPlayer].g_flCarChance = 0.0;
					g_esPlayer[iPlayer].g_iCarDuration = 0;
					g_esPlayer[iPlayer].g_iCarOptions = 0;
					g_esPlayer[iPlayer].g_flCarInterval = 0.0;
					g_esPlayer[iPlayer].g_flCarRadius[0] = 0.0;
					g_esPlayer[iPlayer].g_flCarRadius[1] = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_iOpenAreasOnly = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_iOpenAreasOnly, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iCarAbility = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iCarAbility, value, 0, 1);
		g_esPlayer[admin].g_iCarMessage = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iCarMessage, value, 0, 1);
		g_esPlayer[admin].g_flCarChance = flGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "CarChance", "Car Chance", "Car_Chance", "chance", g_esPlayer[admin].g_flCarChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iCarDuration = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "CarDuration", "Car Duration", "Car_Duration", "duration", g_esPlayer[admin].g_iCarDuration, value, 1, 999999);
		g_esPlayer[admin].g_flCarInterval = flGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "CarInterval", "Car Interval", "Car_Interval", "interval", g_esPlayer[admin].g_flCarInterval, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iCarOptions = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "CarOptions", "Car Options", "Car_Options", "options", g_esPlayer[admin].g_iCarOptions, value, 0, 7);

		if (StrEqual(subsection, "carability", false) || StrEqual(subsection, "car ability", false) || StrEqual(subsection, "car_ability", false) || StrEqual(subsection, "car", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "CarRadius", false) || StrEqual(key, "Car Radius", false) || StrEqual(key, "Car_Radius", false) || StrEqual(key, "radius", false))
			{
				static char sSet[2][7], sValue[14];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

				g_esPlayer[admin].g_flCarRadius[0] = (sSet[0][0] != '\0') ? flClamp(StringToFloat(sSet[0]), -200.0, 0.0) : g_esPlayer[admin].g_flCarRadius[0];
				g_esPlayer[admin].g_flCarRadius[1] = (sSet[1][0] != '\0') ? flClamp(StringToFloat(sSet[1]), 0.0, 200.0) : g_esPlayer[admin].g_flCarRadius[1];
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iOpenAreasOnly = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_iOpenAreasOnly, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iCarAbility = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iCarAbility, value, 0, 1);
		g_esAbility[type].g_iCarMessage = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iCarMessage, value, 0, 1);
		g_esAbility[type].g_flCarChance = flGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "CarChance", "Car Chance", "Car_Chance", "chance", g_esAbility[type].g_flCarChance, value, 0.0, 100.0);
		g_esAbility[type].g_iCarDuration = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "CarDuration", "Car Duration", "Car_Duration", "duration", g_esAbility[type].g_iCarDuration, value, 1, 999999);
		g_esAbility[type].g_flCarInterval = flGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "CarInterval", "Car Interval", "Car_Interval", "interval", g_esAbility[type].g_flCarInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_iCarOptions = iGetKeyValue(subsection, "carability", "car ability", "car_ability", "car", key, "CarOptions", "Car Options", "Car_Options", "options", g_esAbility[type].g_iCarOptions, value, 0, 7);

		if (StrEqual(subsection, "carability", false) || StrEqual(subsection, "car ability", false) || StrEqual(subsection, "car_ability", false) || StrEqual(subsection, "car", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "CarRadius", false) || StrEqual(key, "Car Radius", false) || StrEqual(key, "Car_Radius", false) || StrEqual(key, "radius", false))
			{
				static char sSet[2][7], sValue[14];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

				g_esAbility[type].g_flCarRadius[0] = (sSet[0][0] != '\0') ? flClamp(StringToFloat(sSet[0]), -200.0, 0.0) : g_esAbility[type].g_flCarRadius[0];
				g_esAbility[type].g_flCarRadius[1] = (sSet[1][0] != '\0') ? flClamp(StringToFloat(sSet[1]), 0.0, 200.0) : g_esAbility[type].g_flCarRadius[1];
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	g_esCache[tank].g_flCarChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flCarChance, g_esAbility[type].g_flCarChance);
	g_esCache[tank].g_flCarInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flCarInterval, g_esAbility[type].g_flCarInterval);
	g_esCache[tank].g_flCarRadius[0] = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flCarRadius[0], g_esAbility[type].g_flCarRadius[0]);
	g_esCache[tank].g_flCarRadius[1] = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flCarRadius[1], g_esAbility[type].g_flCarRadius[1]);
	g_esCache[tank].g_iCarAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iCarAbility, g_esAbility[type].g_iCarAbility);
	g_esCache[tank].g_iCarDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iCarDuration, g_esAbility[type].g_iCarDuration);
	g_esCache[tank].g_iCarMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iCarMessage, g_esAbility[type].g_iCarMessage);
	g_esCache[tank].g_iCarOptions = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iCarOptions, g_esAbility[type].g_iCarOptions);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_iOpenAreasOnly = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOpenAreasOnly, g_esAbility[type].g_iOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveCar(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iCarAbility == 1 && !g_esPlayer[tank].g_bActivated)
	{
		vCarAbility(tank);
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

		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iCarAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
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
							vCarAbility(tank);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman4", g_esPlayer[tank].g_iCooldown - iTime);
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

								vCar(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman3");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman4", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarAmmo");
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
	vRemoveCar(tank);
}

static void vCar(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	DataPack dpCar;
	CreateDataTimer(g_esCache[tank].g_flCarInterval, tTimerCar, dpCar, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpCar.WriteCell(GetClientUserId(tank));
	dpCar.WriteCell(g_esPlayer[tank].g_iTankType);
	dpCar.WriteCell(GetTime());
}

static void vCarAbility(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flCarChance)
		{
			g_esPlayer[tank].g_bActivated = true;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				g_esPlayer[tank].g_iCount++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
			}

			vCar(tank);

			if (g_esCache[tank].g_iCarMessage == 1)
			{
				static char sTankName[33];
				MT_GetTankName(tank, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Car", sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Car", LANG_SERVER, sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarAmmo");
	}
}

static void vRemoveCar(int tank)
{
	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iCount = 0;
	g_esPlayer[tank].g_iCooldown = -1;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveCar(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bActivated = false;

	if (g_esCache[tank].g_iCarMessage == 1)
	{
		static char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Car2", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Car2", LANG_SERVER, sTankName);
	}
}

static void vReset3(int tank)
{
	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "CarHuman5", g_esPlayer[tank].g_iCooldown - iTime);
	}
}

public Action tTimerCar(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || iType != g_esPlayer[iTank].g_iTankType || !g_esPlayer[iTank].g_bActivated)
	{
		g_esPlayer[iTank].g_bActivated = false;

		return Plugin_Stop;
	}

	static int iTime, iCurrentTime;
	iTime = pack.ReadCell();
	iCurrentTime = GetTime();
	if (g_esCache[iTank].g_iCarAbility == 0 || bIsAreaNarrow(iTank, g_esCache[iTank].g_iOpenAreasOnly) || ((!MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) || (g_esCache[iTank].g_iHumanAbility == 1 && g_esCache[iTank].g_iHumanMode == 0)) && (iTime + g_esCache[iTank].g_iCarDuration) < iCurrentTime))
	{
		vReset2(iTank);

		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esCache[iTank].g_iHumanAbility == 1 && g_esCache[iTank].g_iHumanMode == 0 && (g_esPlayer[iTank].g_iCooldown == -1 || g_esPlayer[iTank].g_iCooldown < iCurrentTime))
		{
			vReset3(iTank);
		}

		return Plugin_Stop;
	}

	static float flPos[3];
	GetClientEyePosition(iTank, flPos);

	static float flAngles[3];
	flAngles[0] = GetRandomFloat(-20.0, 20.0);
	flAngles[1] = GetRandomFloat(-20.0, 20.0);
	flAngles[2] = 60.0;

	GetVectorAngles(flAngles, flAngles);

	static float flHitpos[3];
	iGetRayHitPos(flPos, flAngles, flHitpos, iTank, true, 2);

	static float flDistance;
	flDistance = GetVectorDistance(flPos, flHitpos);
	if (flDistance > 1600.0)
	{
		flDistance = 1600.0;
	}

	static float flVector[3];
	MakeVectorFromPoints(flPos, flHitpos, flVector);
	NormalizeVector(flVector, flVector);
	ScaleVector(flVector, flDistance - 40.0);
	AddVectors(flPos, flVector, flHitpos);

	if (flDistance > 100.0)
	{
		int iCar = CreateEntityByName("prop_physics");
		if (bIsValidEntity(iCar))
		{
			static int iOptionCount, iOptions[3], iFlag;
			iOptionCount = 0;
			for (int iBit = 0; iBit < sizeof(iOptions); iBit++)
			{
				iFlag = (1 << iBit);
				if (!(g_esCache[iTank].g_iCarOptions & iFlag))
				{
					continue;
				}

				iOptions[iOptionCount] = iFlag;
				iOptionCount++;
			}

			switch (iOptions[GetRandomInt(0, iOptionCount - 1)])
			{
				case 1: SetEntityModel(iCar, MODEL_CAR);
				case 2: SetEntityModel(iCar, MODEL_CAR2);
				case 4: SetEntityModel(iCar, MODEL_CAR3);
				default:
				{
					switch (GetRandomInt(1, 3))
					{
						case 1: SetEntityModel(iCar, MODEL_CAR);
						case 2: SetEntityModel(iCar, MODEL_CAR2);
						case 3: SetEntityModel(iCar, MODEL_CAR3);
					}
				}
			}

			static int iCarColor[3];
			static float flAngles2[3];
			for (int iPos = 0; iPos < sizeof(iCarColor); iPos++)
			{
				iCarColor[iPos] = GetRandomInt(0, 255);
				flAngles2[iPos] = GetRandomFloat(g_esCache[iTank].g_flCarRadius[0], g_esCache[iTank].g_flCarRadius[1]);
			}

			SetEntityRenderColor(iCar, iCarColor[0], iCarColor[1], iCarColor[2], 255);

			static float flVelocity[3];
			flVelocity[0] = GetRandomFloat(0.0, 350.0);
			flVelocity[1] = GetRandomFloat(0.0, 350.0);
			flVelocity[2] = GetRandomFloat(0.0, 30.0);

			TeleportEntity(iCar, flHitpos, flAngles2, flVelocity);
			DispatchSpawn(iCar);

			iCar = EntIndexToEntRef(iCar);
			CreateTimer(6.0, tTimerSetCarVelocity, iCar, TIMER_FLAG_NO_MAPCHANGE);
			vDeleteEntity(iCar, 30.0);
		}
	}

	return Plugin_Continue;
}

public Action tTimerSetCarVelocity(Handle timer, int ref)
{
	static int iCar;
	iCar = EntRefToEntIndex(ref);
	if (iCar == INVALID_ENT_REFERENCE || !bIsValidEntity(iCar))
	{
		return Plugin_Stop;
	}

	TeleportEntity(iCar, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));

	return Plugin_Continue;
}