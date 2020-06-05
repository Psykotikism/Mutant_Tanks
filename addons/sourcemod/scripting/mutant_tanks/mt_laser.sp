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

public Plugin myinfo =
{
	name = "[MT] Laser Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank shoots lasers at survivors.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Laser Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define PARTICLE_ELECTRICITY "electrical_arc_01_parent"

#define SOUND_ELECTRICITY "ambient/energy/zap5.wav"
#define SOUND_ELECTRICITY2 "ambient/energy/zap7.wav"

#define MT_MENU_LASER "Laser Ability"

enum struct esPlayer
{
	bool g_bActivated;

	float g_flLaserChance;
	float g_flLaserDamage;
	float g_flLaserInterval;
	float g_flLaserRange;

	int g_iAccessFlags;
	int g_iCooldown;
	int g_iCount;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iLaserAbility;
	int g_iLaserDuration;
	int g_iLaserMessage;
	int g_iTankType;
}

esPlayer g_esPlayer[MAXPLAYERS + 1];

enum struct esAbility
{
	float g_flLaserChance;
	float g_flLaserDamage;
	float g_flLaserInterval;
	float g_flLaserRange;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iLaserAbility;
	int g_iLaserDuration;
	int g_iLaserMessage;
}

esAbility g_esAbility[MT_MAXTYPES + 1];

enum struct esCache
{
	float g_flLaserChance;
	float g_flLaserDamage;
	float g_flLaserInterval;
	float g_flLaserRange;

	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanCooldown;
	int g_iHumanMode;
	int g_iLaserAbility;
	int g_iLaserDuration;
	int g_iLaserMessage;
}

esCache g_esCache[MAXPLAYERS + 1];

int g_iLaserSprite = -1;

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_laser", cmdLaserInfo, "View information about the Laser ability.");
}

public void OnMapStart()
{
	switch (bIsValidGame())
	{
		case true: g_iLaserSprite = PrecacheModel("materials/sprites/laserbeam.vmt");
		case false: g_iLaserSprite = PrecacheModel("materials/sprites/laser.vmt");
	}

	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_ELECTRICITY2, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveLaser(client);
}

public void OnClientDisconnect_Post(int client)
{
	vRemoveLaser(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdLaserInfo(int client, int args)
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
		case false: vLaserMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vLaserMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iLaserMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Laser Ability Information");
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

public int iLaserMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iLaserAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esCache[param1].g_iHumanAmmo - g_esPlayer[param1].g_iCount, g_esCache[param1].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esCache[param1].g_iHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "LaserDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration2", g_esCache[param1].g_iLaserDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esCache[param1].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vLaserMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			FormatEx(sMenuTitle, sizeof(sMenuTitle), "%T", "LaserMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[255];

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
	menu.AddItem(MT_MENU_LASER, MT_MENU_LASER);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_LASER, false))
	{
		vLaserMenu(client, 0);
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
	list.PushString("laserability");
	list2.PushString("laser ability");
	list3.PushString("laser_ability");
	list4.PushString("laser");
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
				g_esAbility[iIndex].g_iLaserAbility = 0;
				g_esAbility[iIndex].g_iLaserMessage = 0;
				g_esAbility[iIndex].g_flLaserChance = 33.3;
				g_esAbility[iIndex].g_flLaserDamage = 5.0;
				g_esAbility[iIndex].g_iLaserDuration = 5;
				g_esAbility[iIndex].g_flLaserInterval = 1.0;
				g_esAbility[iIndex].g_flLaserRange = 500.0;
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
					g_esPlayer[iPlayer].g_iLaserAbility = 0;
					g_esPlayer[iPlayer].g_iLaserMessage = 0;
					g_esPlayer[iPlayer].g_flLaserChance = 0.0;
					g_esPlayer[iPlayer].g_flLaserDamage = 0.0;
					g_esPlayer[iPlayer].g_iLaserDuration = 0;
					g_esPlayer[iPlayer].g_flLaserInterval = 0.0;
					g_esPlayer[iPlayer].g_flLaserRange = 0.0;
				}
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin))
	{
		g_esPlayer[admin].g_iHumanAbility = iGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esPlayer[admin].g_iHumanAbility, value, 0, 2);
		g_esPlayer[admin].g_iHumanAmmo = iGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esPlayer[admin].g_iHumanAmmo, value, 0, 999999);
		g_esPlayer[admin].g_iHumanCooldown = iGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esPlayer[admin].g_iHumanCooldown, value, 0, 999999);
		g_esPlayer[admin].g_iHumanMode = iGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esPlayer[admin].g_iHumanMode, value, 0, 1);
		g_esPlayer[admin].g_iLaserAbility = iGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esPlayer[admin].g_iLaserAbility, value, 0, 1);
		g_esPlayer[admin].g_iLaserMessage = iGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esPlayer[admin].g_iLaserMessage, value, 0, 3);
		g_esPlayer[admin].g_flLaserChance = flGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "LaserChance", "Laser Chance", "Laser_Chance", "chance", g_esPlayer[admin].g_flLaserChance, value, 0.0, 100.0);
		g_esPlayer[admin].g_flLaserDamage = flGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "LaserDamage", "Laser Damage", "Laser_Damage", "damage", g_esPlayer[admin].g_flLaserDamage, value, 0.1, 999999.0);
		g_esPlayer[admin].g_iLaserDuration = iGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "LaserDuration", "Laser Duration", "Laser_Duration", "duration", g_esPlayer[admin].g_iLaserDuration, value, 1, 999999);
		g_esPlayer[admin].g_flLaserInterval = flGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "LaserInterval", "Laser Interval", "Laser_Interval", "interval", g_esPlayer[admin].g_flLaserInterval, value, 0.1, 999999.0);
		g_esPlayer[admin].g_flLaserRange = flGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "LaserRange", "Laser Range", "Laser_Range", "range", g_esPlayer[admin].g_flLaserRange, value, 0.1, 999999.0);

		if (StrEqual(subsection, "laserability", false) || StrEqual(subsection, "laser ability", false) || StrEqual(subsection, "laser_ability", false) || StrEqual(subsection, "laser", false))
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
		g_esAbility[type].g_iHumanAbility = iGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 2);
		g_esAbility[type].g_iHumanAmmo = iGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_iHumanCooldown = iGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_iHumanCooldown, value, 0, 999999);
		g_esAbility[type].g_iHumanMode = iGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iLaserAbility = iGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iLaserAbility, value, 0, 1);
		g_esAbility[type].g_iLaserMessage = iGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iLaserMessage, value, 0, 3);
		g_esAbility[type].g_flLaserChance = flGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "LaserChance", "Laser Chance", "Laser_Chance", "chance", g_esAbility[type].g_flLaserChance, value, 0.0, 100.0);
		g_esAbility[type].g_flLaserDamage = flGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "LaserDamage", "Laser Damage", "Laser_Damage", "damage", g_esAbility[type].g_flLaserDamage, value, 0.1, 999999.0);
		g_esAbility[type].g_iLaserDuration = iGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "LaserDuration", "Laser Duration", "Laser_Duration", "duration", g_esAbility[type].g_iLaserDuration, value, 1, 999999);
		g_esAbility[type].g_flLaserInterval = flGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "LaserInterval", "Laser Interval", "Laser_Interval", "interval", g_esAbility[type].g_flLaserInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_flLaserRange = flGetKeyValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "LaserRange", "Laser Range", "Laser_Range", "range", g_esAbility[type].g_flLaserRange, value, 0.1, 999999.0);

		if (StrEqual(subsection, "laserability", false) || StrEqual(subsection, "laser ability", false) || StrEqual(subsection, "laser_ability", false) || StrEqual(subsection, "laser", false))
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
	g_esCache[tank].g_flLaserChance = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flLaserChance, g_esAbility[type].g_flLaserChance);
	g_esCache[tank].g_flLaserDamage = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flLaserDamage, g_esAbility[type].g_flLaserDamage);
	g_esCache[tank].g_flLaserInterval = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flLaserInterval, g_esAbility[type].g_flLaserInterval);
	g_esCache[tank].g_flLaserRange = flGetSettingValue(apply, bHuman, g_esPlayer[tank].g_flLaserRange, g_esAbility[type].g_flLaserRange);
	g_esCache[tank].g_iHumanAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAbility, g_esAbility[type].g_iHumanAbility);
	g_esCache[tank].g_iHumanAmmo = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanAmmo, g_esAbility[type].g_iHumanAmmo);
	g_esCache[tank].g_iHumanCooldown = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanCooldown, g_esAbility[type].g_iHumanCooldown);
	g_esCache[tank].g_iHumanMode = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iHumanMode, g_esAbility[type].g_iHumanMode);
	g_esCache[tank].g_iLaserAbility = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iLaserAbility, g_esAbility[type].g_iLaserAbility);
	g_esCache[tank].g_iLaserDuration = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iLaserDuration, g_esAbility[type].g_iLaserDuration);
	g_esCache[tank].g_iLaserMessage = iGetSettingValue(apply, bHuman, g_esPlayer[tank].g_iLaserMessage, g_esAbility[type].g_iLaserMessage);
	g_esPlayer[tank].g_iTankType = apply ? type : 0;
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveLaser(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags)) || g_esCache[tank].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esCache[tank].g_iHumanAbility != 1) && bIsCloneAllowed(tank) && g_esCache[tank].g_iLaserAbility == 1 && !g_esPlayer[tank].g_bActivated)
	{
		vLaserAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
		{
			return;
		}

		if (button & MT_MAIN_KEY)
		{
			if (g_esCache[tank].g_iLaserAbility == 1 && g_esCache[tank].g_iHumanAbility == 1)
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
							vLaserAbility(tank);
						}
						else if (g_esPlayer[tank].g_bActivated)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserHuman3");
						}
						else if (bRecharging)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserHuman4", g_esPlayer[tank].g_iCooldown - iTime);
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

								vLaser(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bActivated)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserHuman3");
							}
							else if (bRecharging)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserHuman4", g_esPlayer[tank].g_iCooldown - iTime);
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserAmmo");
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
	vRemoveLaser(tank);
}

static void vLaser(int tank)
{
	static float flTankAngles[3], flTankPos[3];
	GetEntPropVector(tank, Prop_Send, "m_angRotation", flTankAngles);
	GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flTankPos);
	flTankPos[2] += 65.0;

	static int iSurvivor;
	iSurvivor = iGetNearestSurvivor(tank, flTankPos);
	if (bIsSurvivor(iSurvivor))
	{
		static float flSurvivorPos[3];
		GetClientEyePosition(iSurvivor, flSurvivorPos);
		flSurvivorPos[2] -= 15.0;

		vAttachParticle2(flSurvivorPos, NULL_VECTOR, PARTICLE_ELECTRICITY, 3.0);
		EmitSoundToAll((GetRandomInt(1, 2) == 1 ? SOUND_ELECTRICITY : SOUND_ELECTRICITY2), 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, flSurvivorPos, NULL_VECTOR, true, 0.0);
		EmitSoundToAll((GetRandomInt(1, 2) == 1 ? SOUND_ELECTRICITY : SOUND_ELECTRICITY2), 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, flTankPos, NULL_VECTOR, true, 0.0);

		static int iColor[4];
		MT_GetTankColors(tank, GetRandomInt(1, 2), iColor[0], iColor[1], iColor[2], iColor[3]);

		TE_SetupBeamPoints(flTankPos, flSurvivorPos, g_iLaserSprite, 0, 0, 0, 0.5, 5.0, 5.0, 1, 0.0, iColor, 0);
		TE_SendToAll();

		vDamageEntity(iSurvivor, tank, g_esCache[tank].g_flLaserDamage, "1024");

		if (g_esCache[tank].g_iLaserMessage == 1)
		{
			static char sTankName[33];
			MT_GetTankName(tank, sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Laser", sTankName, iSurvivor);
		}
	}
}

static void vLaserAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank, g_esAbility[g_esPlayer[tank].g_iTankType].g_iAccessFlags, g_esPlayer[tank].g_iAccessFlags))
	{
		return;
	}

	if (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0))
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esCache[tank].g_flLaserChance && !g_esPlayer[tank].g_bActivated)
		{
			g_esPlayer[tank].g_bActivated = true;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
			{
				g_esPlayer[tank].g_iCount++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserHuman", g_esPlayer[tank].g_iCount, g_esCache[tank].g_iHumanAmmo);
			}

			DataPack dpLaser;
			CreateDataTimer(g_esCache[tank].g_flLaserInterval, tTimerLaser, dpLaser, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpLaser.WriteCell(GetClientUserId(tank));
			dpLaser.WriteCell(g_esPlayer[tank].g_iTankType);
			dpLaser.WriteCell(GetTime());
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esCache[tank].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserAmmo");
	}
}

static void vRemoveLaser(int tank)
{
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
			vRemoveLaser(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bActivated = false;

	if (g_esCache[tank].g_iLaserMessage == 1)
	{
		char sTankName[33];
		MT_GetTankName(tank, sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Laser2", sTankName);
	}
}

static void vReset3(int tank)
{
	int iTime = GetTime();
	g_esPlayer[tank].g_iCooldown = (g_esPlayer[tank].g_iCount < g_esCache[tank].g_iHumanAmmo && g_esCache[tank].g_iHumanAmmo > 0) ? (iTime + g_esCache[tank].g_iHumanCooldown) : -1;
	if (g_esPlayer[tank].g_iCooldown != -1 && g_esPlayer[tank].g_iCooldown > iTime)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserHuman5", g_esPlayer[tank].g_iCooldown - iTime);
	}
}

static int iGetNearestSurvivor(int tank, float pos[3])
{
	static float flSurvivorPos[3], flDistance;
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !bIsAdminImmune(iSurvivor, g_esPlayer[tank].g_iTankType, g_esAbility[g_esPlayer[tank].g_iTankType].g_iImmunityFlags, g_esPlayer[iSurvivor].g_iImmunityFlags))
		{
			GetClientEyePosition(iSurvivor, flSurvivorPos);

			flDistance = GetVectorDistance(pos, flSurvivorPos);
			if (flDistance <= g_esCache[tank].g_flLaserRange && bVisiblePosition(pos, flSurvivorPos, tank, 1))
			{
				return iSurvivor;
			}
		}
	}

	return 0;
}

public Action tTimerLaser(Handle timer, DataPack pack)
{
	pack.Reset();

	static int iTank, iType;
	iTank = GetClientOfUserId(pack.ReadCell());
	iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || !MT_HasAdminAccess(iTank) || !bHasAdminAccess(iTank, g_esAbility[g_esPlayer[iTank].g_iTankType].g_iAccessFlags, g_esPlayer[iTank].g_iAccessFlags) || !MT_IsTypeEnabled(g_esPlayer[iTank].g_iTankType) || !bIsCloneAllowed(iTank) || iType != g_esPlayer[iTank].g_iTankType || !g_esPlayer[iTank].g_bActivated)
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	static int iTime;
	iTime = pack.ReadCell();
	if ((iTime + g_esCache[iTank].g_iLaserDuration) < GetTime())
	{
		vReset2(iTank);
		vReset3(iTank);

		return Plugin_Stop;
	}

	vLaser(iTank);

	return Plugin_Continue;
}