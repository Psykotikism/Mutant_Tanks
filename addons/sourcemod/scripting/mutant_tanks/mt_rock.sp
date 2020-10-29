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

//#file "Rock Ability v8.80"

public Plugin myinfo =
{
	name = "[MT] Rock Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank creates rock showers.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Rock Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define SOUND_ROCK "player/tank/attack/thrown_missile_loop_1.wav"

#define MT_MENU_ROCK "Rock Ability"

enum struct esPlayer
{
	bool g_bActivated;

	float g_flRockChance;
	float g_flRockInterval;
	float g_flRockRadius[2];

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iLauncher;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iRockAbility;
	int g_iRockDamage;
	int g_iRockDuration;
	int g_iRockMessage;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flRockChance;
	float g_flRockInterval;
	float g_flRockRadius[2];

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iRockAbility;
	int g_iRockDamage;
	int g_iRockDuration;
	int g_iRockMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flRockChance;
	float g_flRockInterval;
	float g_flRockRadius[2];

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iOpenAreasOnly;
	int g_iRequiresHumans;
	int g_iRockAbility;
	int g_iRockDamage;
	int g_iRockDuration;
	int g_iRockMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_rock", cmdRockInfo, "View information about the Rock ability.");
}

public void OnMapStart()
{
	PrecacheSound(SOUND_ROCK, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveRock(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveRock(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdRockInfo(int client, int args)
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
		case false: vRockMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vRockMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iRockMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Rock Ability Information");
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

public int iRockMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iRockAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "RockDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iRockDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vRockMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[PLATFORM_MAX_PATH];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "RockMenu", param1);
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
	menu.AddItem(MT_MENU_ROCK, MT_MENU_ROCK);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_ROCK, false))
	{
		vRockMenu(client, 0);
	}
}

public void MT_OnMenuItemDisplayed(int client, const char[] info, char[] buffer, int size)
{
	if (StrEqual(info, MT_MENU_ROCK, false))
	{
		FormatEx(buffer, size, "%T", "RockMenu2", client);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && bIsValidEntity(inflictor) && damage >= 0.5)
	{
		static char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (StrEqual(sClassname, "tank_rock"))
		{
			static int iLauncher;
			iLauncher = HasEntProp(inflictor, Prop_Send, "m_hOwnerEntity") ? GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity") : 0;
			if (bIsValidEntity(iLauncher))
			{
				static int iTank;
				iTank = HasEntProp(iLauncher, Prop_Send, "m_hOwnerEntity") ? GetEntPropEnt(iLauncher, Prop_Send, "m_hOwnerEntity") : 0;
				if (g_esPlayer[iTank].g_iLauncher != INVALID_ENT_REFERENCE && iLauncher == EntRefToEntIndex(g_esPlayer[iTank].g_iLauncher) && MT_IsTankSupported(iTank) && MT_IsCustomTankSupported(iTank) && (MT_HasAdminAccess(iTank) || bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)))
				{
					if (bIsInfected(victim) || (bIsSurvivor(victim) && (MT_IsAdminImmune(victim, iTank) || bIsAdminImmune(victim, g_esPlayer[iTank].g_iTankType, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iImmunityFlags, g_esPlayer[victim].g_iImmunityFlags))))
					{
						return Plugin_Handled;
					}

					damage = MT_GetScaledDamage(float(g_esCache[iTank].g_iRockDamage));

					return Plugin_Changed;
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
	list.PushString("rockability");
	list2.PushString("rock ability");
	list3.PushString("rock_ability");
	list4.PushString("rock");
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
				g_esAbility[iIndex].g_iOpenAreasOnly = 1;
				g_esAbility[iIndex].g_iRequiresHumans = 1;
				g_esAbility[iIndex].g_iRockAbility = 0;
				g_esAbility[iIndex].g_iRockMessage = 0;
				g_esAbility[iIndex].g_flRockChance = 33.3;
				g_esAbility[iIndex].g_iRockDamage = 5;
				g_esAbility[iIndex].g_iRockDuration = 5;
				g_esAbility[iIndex].g_flRockInterval = 0.2;
				g_esAbility[iIndex].g_flRockRadius[0] = -1.25;
				g_esAbility[iIndex].g_flRockRadius[1] = 1.25;
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
					g_esPlayer[iPlayer].g_iOpenAreasOnly = 0;
					g_esPlayer[iPlayer].g_iRequiresHumans = 0;
					g_esPlayer[iPlayer].g_iRockAbility = 0;
					g_esPlayer[iPlayer].g_iRockMessage = 0;
					g_esPlayer[iPlayer].g_flRockChance = 0.0;
					g_esPlayer[iPlayer].g_iRockDamage = 0;
					g_esPlayer[iPlayer].g_iRockDuration = 0;
					g_esPlayer[iPlayer].g_flRockInterval = 0.0;
					g_esPlayer[iPlayer].g_flRockRadius[0] = 0.0;
					g_esPlayer[iPlayer].g_flRockRadius[1] = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_iOpenAreasOnly = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esPlayer[admin].g_iOpenAreasOnly, value, 0, 1);
		g_esPlayer[admin].g_iRequiresHumans = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esPlayer[admin].g_iRequiresHumans, value, 0, 32);
		g_esPlayer[admin].g_iRockAbility = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iRockAbility, value, 0, 1);
		g_esPlayer[admin].g_iRockMessage = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iRockMessage, value, 0, 1);
		g_esPlayer[admin].g_flRockChance = flGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "RockChance", "Rock Chance", "Rock_Chance", "chance", g_esPlayer[admin].g_flRockChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_iRockDamage = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "RockDamage", "Rock Damage", "Rock_Damage", "damage", g_esPlayer[admin].g_iRockDamage, value, 1, 999999);
		g_esPlayer[admin].g_iRockDuration = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "RockDuration", "Rock Duration", "Rock_Duration", "duration", g_esPlayer[admin].g_iRockDuration, value, 1, 999999);
		g_esPlayer[admin].g_flRockInterval = flGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "RockInterval", "Rock Interval", "Rock_Interval", "interval", g_esPlayer[admin].g_flRockInterval, value, 0.1, 999999.0);

		if (StrEqual(subsection, "rockability", false) || StrEqual(subsection, "rock ability", false) || StrEqual(subsection, "rock_ability", false) || StrEqual(subsection, "rock", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esPlayer[admin].g_iImmunityFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "RockRadius", false) || StrEqual(key, "Rock Radius", false) || StrEqual(key, "Rock_Radius", false) || StrEqual(key, "radius", false))
			{
				static char sSet[2][6], sValue[12];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

				g_esPlayer[admin].g_flRockRadius[0] = (sSet[0][0] != '\0') ? flClamp(StringToFloat(sSet[0]), -5.0, 0.0) : g_esPlayer[admin].g_flRockRadius[0];
				g_esPlayer[admin].g_flRockRadius[1] = (sSet[1][0] != '\0') ? flClamp(StringToFloat(sSet[1]), 0.0, 5.0) : g_esPlayer[admin].g_flRockRadius[1];
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iOpenAreasOnly = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "OpenAreasOnly", "Open Areas Only", "Open_Areas_Only", "openareas", g_esAbility[type].g_iOpenAreasOnly, value, 0, 1);
		g_esAbility[type].g_iRequiresHumans = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "RequiresHumans", "Requires Humans", "Requires_Humans", "hrequire", g_esAbility[type].g_iRequiresHumans, value, 0, 32);
		g_esAbility[type].g_iRockAbility = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iRockAbility, value, 0, 1);
		g_esAbility[type].g_iRockMessage = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iRockMessage, value, 0, 1);
		g_esAbility[type].g_flRockChance = flGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "RockChance", "Rock Chance", "Rock_Chance", "chance", g_esAbility[type].g_flRockChance, value, 0.0, 100.0);
		g_esAbility[type].g_iRockDamage = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "RockDamage", "Rock Damage", "Rock_Damage", "damage", g_esAbility[type].g_iRockDamage, value, 1, 999999);
		g_esAbility[type].g_iRockDuration = iGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "RockDuration", "Rock Duration", "Rock_Duration", "duration", g_esAbility[type].g_iRockDuration, value, 1, 999999);
		g_esAbility[type].g_flRockInterval = flGetKeyValue(subsection, "rockability", "rock ability", "rock_ability", "rock", key, "RockInterval", "Rock Interval", "Rock_Interval", "interval", g_esAbility[type].g_flRockInterval, value, 0.1, 999999.0);

		if (StrEqual(subsection, "rockability", false) || StrEqual(subsection, "rock ability", false) || StrEqual(subsection, "rock_ability", false) || StrEqual(subsection, "rock", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esAbility[type].g_iImmunityFlags = ReadFlagString(value);
			}
			else if (StrEqual(key, "RockRadius", false) || StrEqual(key, "Rock Radius", false) || StrEqual(key, "Rock_Radius", false) || StrEqual(key, "radius", false))
			{
				static char sSet[2][6], sValue[12];
				strcopy(sValue, sizeof(sValue), value);
				ReplaceString(sValue, sizeof(sValue), " ", "");
				ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

				g_esAbility[type].g_flRockRadius[0] = (sSet[0][0] != '\0') ? flClamp(StringToFloat(sSet[0]), -5.0, 0.0) : g_esAbility[type].g_flRockRadius[0];
				g_esAbility[type].g_flRockRadius[1] = (sSet[1][0] != '\0') ? flClamp(StringToFloat(sSet[1]), 0.0, 5.0) : g_esAbility[type].g_flRockRadius[1];
			}
		}
	}
}

public void MT_OnSettingsCached(int tank, bool apply, int type)
{
	bool bHuman = MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT);
	g_esCache[tank].g_flRockChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRockChance, g_esAbility[type].g_flRockChance);
	g_esCache[tank].g_flRockInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRockInterval, g_esAbility[type].g_flRockInterval);
	g_esCache[tank].g_flRockRadius[0] = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRockRadius[0], g_esAbility[type].g_flRockRadius[0]);
	g_esCache[tank].g_flRockRadius[1] = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flRockRadius[1], g_esAbility[type].g_flRockRadius[1]);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_iOpenAreasOnly = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iOpenAreasOnly, g_esAbility[type].g_iOpenAreasOnly);
	g_esCache[tank].g_iRequiresHumans = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRequiresHumans, g_esAbility[type].g_iRequiresHumans);
	g_esCache[tank].g_iRockAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRockAbility, g_esAbility[type].g_iRockAbility);
	g_esCache[tank].g_iRockDamage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRockDamage, g_esAbility[type].g_iRockDamage);
	g_esCache[tank].g_iRockDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRockDuration, g_esAbility[type].g_iRockDuration);
	g_esCache[tank].g_iRockMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iRockMessage, g_esAbility[type].g_iRockMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnCopyStats(int oldTank, int newTank)
{
	g_esPlayer[newTank].g_iCooldown = g_esPlayer[oldTank].g_iCooldown;
	g_esPlayer[newTank].g_iCount = g_esPlayer[oldTank].g_iCount;
	g_esPlayer[newTank].g_iTankType = g_esPlayer[oldTank].g_iTankType;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveRock(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && MT_IsCustomTankSupported(tank) && g_esCache[tank].g_iRockAbility == 1 && !g_esPlayer[tank].g_bActivated)
	{
		vRockAbility(tank);
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
			if (g_esCache[tank].g_iRockAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
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
							vRockAbility(tank);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "RockHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "RockHuman4", g_esPlayer[tank].g_iCooldown - iTime);
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

								vRock(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "RockHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "RockHuman3");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "RockHuman4", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "RockAmmo");
						}
					}
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
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
	vRemoveRock(tank);
}

static void vRemoveLauncher(int tank)
{
	if (bIsValidEntRef(g_esPlayer[tank].g_iLauncher))
	{
		g_esPlayer[tank].g_iLauncher = EntRefToEntIndex(g_esPlayer[tank].g_iLauncher);
		if (bIsValidEntity(g_esPlayer[tank].g_iLauncher))
		{
			RemoveEntity(g_esPlayer[tank].g_iLauncher);
		}
	}

	g_esPlayer[tank].g_iLauncher = INVALID_ENT_REFERENCE;
}

static void vRemoveRock(int tank)
{
	vRemoveLauncher(tank);

	g_esPlayer[tank].g_bActivated = false;
	g_esPlayer[tank].g_iCooldown = -1;
	g_esPlayer[tank].g_iCount = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveRock(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	vRemoveLauncher(tank);

	g_esPlayer[tank].g_bActivated = false;

	CreateTimer(3.0, tTimerStopRockSound, _, TIMER_FLAG_NO_MAPCHANGE);

	if (g_esCache[tank].g_iRockMessage == 1)
	{
		static char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Rock2", sTankName);
		MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Rock2", LANG_SERVER, sTankName);
	}
}

static void vReset3(int tank)
{
	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "RockHuman5", g_esPlayer[tank].g_iCooldown - iTime);
	}
}

static void vRock(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	static char sDamage[11];
	IntToString(RoundToNearest(MT_GetScaledDamage(float(g_esCache[tank].g_iRockDamage))), sDamage, sizeof(sDamage));

	static float flPos[3], flAngles[3];
	GetClientEyePosition(tank, flPos);
	GetClientEyeAngles(tank, flAngles);

	static int iLauncher;
	iLauncher = CreateEntityByName("env_rock_launcher");
	if (bIsValidEntity(iLauncher))
	{
		SetEntPropEnt(iLauncher, Prop_Send, "m_hOwnerEntity", tank);
		TeleportEntity(iLauncher, flPos, flAngles, NULL_VECTOR);
		DispatchSpawn(iLauncher);
		DispatchKeyValue(iLauncher, "rockdamageoverride", sDamage);
		iLauncher = EntIndexToEntRef(iLauncher);
		g_esPlayer[tank].g_iLauncher = iLauncher;
	}

	DataPack dpRock;
	CreateDataTimer(g_esCache[tank].g_flRockInterval, tTimerRock, dpRock, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpRock.WriteCell(iLauncher);
	dpRock.WriteCell(GetClientUserId(tank));
	dpRock.WriteCell(g_esPlayer[tank].g_iTankType);
	dpRock.WriteCell(GetTime());
}

static void vRockAbility(int tank)
{
	if (bIsAreaNarrow(tank, g_esCache[tank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[tank].g_iTankType) || (g_esCache[tank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[tank].g_iRequiresHumans) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flRockChance)
		{
			g_esPlayer[tank].g_bActivated = true;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				g_esPlayer[tank].g_iCount++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "RockHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
			}

			vRock(tank);

			if (g_esCache[tank].g_iRockMessage == 1)
			{
				static char sTankName[33];
				MT_GetTankName(tank, sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Rock", sTankName);
				MT_LogMessage(MT_LOG_ABILITY, "%s %T", MT_TAG, "Rock", LANG_SERVER, sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "RockHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "RockAmmo");
	}
}

public Action tTimerRock(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iLauncher, iTank;
	iLauncher = EntRefToEntIndex(pack.ReadCell());
	iTank = GetClientOfUserId(pack.ReadCell());
	if (iLauncher == INVALID_ENT_REFERENCE || !bIsValidEntity(iLauncher))
	{
		g_esPlayer[iTank].g_bActivated = false;

		return Plugin_Stop;
	}

	static int iType;
	iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || bIsAreaNarrow(iTank, g_esCache[iTank].g_iOpenAreasOnly) || MT_DoesTypeRequireHumans(g_esPlayer[iTank].g_iTankType) || (g_esCache[iTank].g_iRequiresHumans > 0 && iGetHumanCount() < g_esCache[iTank].g_iRequiresHumans) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags)) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !MT_IsCustomTankSupported(iTank) || iType != g_esPlayer[iTank].g_iTankType || !g_esPlayer[iTank].g_bActivated)
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	static int iTime, iCurrentTime;
	iTime = pack.ReadCell();
	iCurrentTime = GetTime();
	if (g_esCache[iTank].g_iRockAbility == 0 || ((!MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) || (g_esCache[iTank].g_iHumanAbility == 1 && g_esCache[iTank].g_iHumanMode == 0)) && (iTime + g_esCache[iTank].g_iRockDuration) < iCurrentTime))
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
	flPos[2] += 20.0;

	static float flAngles[3];
	flAngles[0] = GetRandomFloat(-1.0, 1.0);
	flAngles[1] = GetRandomFloat(-1.0, 1.0);
	flAngles[2] = 2.0;
	GetVectorAngles(flAngles, flAngles);

	static float flHitPos[3];
	iGetRayHitPos(flPos, flAngles, flHitPos, iTank, true, 2);

	static float flDistance, flVector[3];
	flDistance = GetVectorDistance(flPos, flHitPos);
	if (flDistance > 800.0)
	{
		flDistance = 800.0;
	}

	MakeVectorFromPoints(flPos, flHitPos, flVector);
	NormalizeVector(flVector, flVector);
	ScaleVector(flVector, flDistance - 40.0);
	AddVectors(flPos, flVector, flHitPos);

	if (flDistance > 300.0)
	{
		static float flAngles2[3];
		if (bIsValidEntity(iLauncher))
		{
			flAngles2[0] = GetRandomFloat(g_esCache[iTank].g_flRockRadius[0], g_esCache[iTank].g_flRockRadius[1]);
			flAngles2[1] = GetRandomFloat(g_esCache[iTank].g_flRockRadius[0], g_esCache[iTank].g_flRockRadius[1]);
			flAngles2[2] = -2.0;
			GetVectorAngles(flAngles2, flAngles2);

			TeleportEntity(iLauncher, flHitPos, flAngles2, NULL_VECTOR);
			AcceptEntityInput(iLauncher, "LaunchRock");
		}
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