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

#undef REQUIRE_PLUGIN
#include <mt_clone>
#define REQUIRE_PLUGIN

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

#define PARTICLE_ELECTRICITY "electrical_arc_01_system"

#define SOUND_ELECTRICITY "ambient/energy/zap1.wav"

#define MT_MENU_LASER "Laser Ability"

bool g_bCloneInstalled, g_bLaser[MAXPLAYERS + 1], g_bLaser2[MAXPLAYERS + 1];

float g_flHumanCooldown[MT_MAXTYPES + 1], g_flLaserChance[MT_MAXTYPES + 1], g_flLaserDamage[MT_MAXTYPES + 1], g_flLaserDuration[MT_MAXTYPES + 1], g_flLaserInterval[MT_MAXTYPES + 1], g_flLaserRange[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1], g_iHumanMode[MT_MAXTYPES + 1], g_iImmunityFlags[MT_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1], g_iLaserAbility[MT_MAXTYPES + 1], g_iLaserCount[MAXPLAYERS + 1], g_iLaserMessage[MT_MAXTYPES + 1], g_iLaserSprite = -1;

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("mt_clone");
}

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

	vPrecacheParticle(PARTICLE_ELECTRICITY);

	PrecacheSound(SOUND_ELECTRICITY, true);

	vReset();
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iLaserAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iLaserCount[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanMode[MT_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "LaserDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_flLaserDuration[MT_GetTankType(param1)]);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
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
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "LaserMenu", param1);
			panel.SetTitle(sMenuTitle);
		}
		case MenuAction_DisplayItem:
		{
			char sMenuOption[255];
			switch (param2)
			{
				case 0:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Status", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 1:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Ammunition", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 2:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Buttons", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 3:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "ButtonMode", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 6:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 7:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "HumanSupport", param1);
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

public void MT_OnConfigsLoad(int mode)
{
	if (mode == 3)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				g_iAccessFlags2[iPlayer] = 0;
				g_iImmunityFlags2[iPlayer] = 0;
			}
		}
	}
	else if (mode == 1)
	{
		for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
		{
			g_iAccessFlags[iIndex] = 0;
			g_iImmunityFlags[iIndex] = 0;
			g_iHumanAbility[iIndex] = 0;
			g_iHumanAmmo[iIndex] = 5;
			g_flHumanCooldown[iIndex] = 30.0;
			g_iHumanMode[iIndex] = 1;
			g_iLaserAbility[iIndex] = 0;
			g_iLaserMessage[iIndex] = 0;
			g_flLaserChance[iIndex] = 33.3;
			g_flLaserDamage[iIndex] = 5.0;
			g_flLaserDuration[iIndex] = 5.0;
			g_flLaserInterval[iIndex] = 1.0;
			g_flLaserRange[iIndex] = 500.0;
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "laserability", false) || StrEqual(subsection, "laser ability", false) || StrEqual(subsection, "laser_ability", false) || StrEqual(subsection, "laser", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_iImmunityFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iImmunityFlags2[admin];
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_iHumanAbility[type] = iGetValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iLaserAbility[type] = iGetValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iLaserAbility[type], value, 0, 1);
		g_iLaserMessage[type] = iGetValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iLaserMessage[type], value, 0, 3);
		g_flLaserChance[type] = flGetValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "LaserChance", "Laser Chance", "Laser_Chance", "chance", g_flLaserChance[type], value, 0.0, 100.0);
		g_flLaserDamage[type] = flGetValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "LaserDamage", "Laser Damage", "Laser_Damage", "damage", g_flLaserDamage[type], value, 0.1, 999999.0);
		g_flLaserDuration[type] = flGetValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "LaserDuration", "Laser Duration", "Laser_Duration", "duration", g_flLaserDuration[type], value, 0.1, 999999.0);
		g_flLaserInterval[type] = flGetValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "LaserInterval", "Laser Interval", "Laser_Interval", "interval", g_flLaserInterval[type], value, 0.1, 999999.0);
		g_flLaserRange[type] = flGetValue(subsection, "laserability", "laser ability", "laser_ability", "laser", key, "LaserRange", "Laser Range", "Laser_Range", "range", g_flLaserRange[type], value, 0.1, 999999.0);

		if (StrEqual(subsection, "laserability", false) || StrEqual(subsection, "laser ability", false) || StrEqual(subsection, "laser_ability", false) || StrEqual(subsection, "laser", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags[type];
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_iImmunityFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iImmunityFlags[type];
			}
		}
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
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
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iLaserAbility[MT_GetTankType(tank)] == 1 && !g_bLaser[tank])
	{
		vLaserAbility(tank);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if (g_iLaserAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[MT_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bLaser[tank] && !g_bLaser2[tank])
						{
							vLaserAbility(tank);
						}
						else if (g_bLaser[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserHuman3");
						}
						else if (g_bLaser2[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserHuman4");
						}
					}
					case 1:
					{
						if (g_iLaserCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
						{
							if (!g_bLaser[tank] && !g_bLaser2[tank])
							{
								g_bLaser[tank] = true;
								g_iLaserCount[tank]++;

								vLaser(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserHuman", g_iLaserCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
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
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if (g_iLaserAbility[MT_GetTankType(tank)] == 1 && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[MT_GetTankType(tank)] == 1 && g_bLaser[tank] && !g_bLaser2[tank])
				{
					g_bLaser[tank] = false;

					vReset3(tank);
				}
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
	float flTankAngles[3], flTankPos[3];
	GetEntPropVector(tank, Prop_Send, "m_angRotation", flTankAngles);
	GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flTankPos);
	flTankPos[2] += 65.0;

	int iSurvivor = iGetNearestSurvivor(tank, flTankPos);
	if (iSurvivor > 0)
	{
		float flSurvivorPos[3];
		GetClientEyePosition(iSurvivor, flSurvivorPos);
		flSurvivorPos[2] -= 15.0;

		vAttachParticle2(flSurvivorPos, NULL_VECTOR, PARTICLE_ELECTRICITY, 3.0);
		EmitSoundToAll(SOUND_ELECTRICITY, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, flSurvivorPos, NULL_VECTOR, true, 0.0);
		EmitSoundToAll(SOUND_ELECTRICITY, 0, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, 1.0, SNDPITCH_NORMAL, -1, flTankPos, NULL_VECTOR, true, 0.0);

		int iColor[4];
		MT_GetTankColors(tank, GetRandomInt(1, 2), iColor[0], iColor[1], iColor[2], iColor[3]);

		TE_SetupBeamPoints(flTankPos, flSurvivorPos, g_iLaserSprite, 0, 0, 0, 0.5, 5.0, 5.0, 1, 0.0, iColor, 0);
		TE_SendToAll();

		vDamageEntity(iSurvivor, tank, g_flLaserDamage[MT_GetTankType(tank)], "256");

		if (g_iLaserMessage[MT_GetTankType(tank)] == 1)
		{
			char sTankName[33];
			MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Laser", sTankName, iSurvivor);
		}
	}
}

static void vLaserAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iLaserCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flLaserChance[MT_GetTankType(tank)] && !g_bLaser[tank])
		{
			g_bLaser[tank] = true;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				g_iLaserCount[tank]++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserHuman", g_iLaserCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
			}

			DataPack dpLaser;
			CreateDataTimer(g_flLaserInterval[MT_GetTankType(tank)], tTimerLaser, dpLaser, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpLaser.WriteCell(GetClientUserId(tank));
			dpLaser.WriteCell(MT_GetTankType(tank));
			dpLaser.WriteFloat(GetEngineTime());
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserAmmo");
	}
}

static void vRemoveLaser(int tank)
{
	g_bLaser[tank] = false;
	g_bLaser2[tank] = false;
	g_iLaserCount[tank] = 0;
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
	g_bLaser[tank] = false;

	if (g_iLaserMessage[MT_GetTankType(tank)] == 1)
	{
		char sTankName[33];
		MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
		MT_PrintToChatAll("%s %t", MT_TAG2, "Laser2", sTankName);
	}
}

static void vReset3(int tank)
{
	g_bLaser2[tank] = true;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "LaserHuman5");

	if (g_iLaserCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[MT_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bLaser2[tank] = false;
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_iAccessFlags[MT_GetTankType(admin)];
	if (iAbilityFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iAbilityFlags)) ? false : true;
		}
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iTypeFlags)) ? false : true;
		}
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0)
		{
			return (!(g_iAccessFlags2[admin] & iGlobalFlags)) ? false : true;
		}
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0)
		{
			return (!(iClientTypeFlags & iAbilityFlags)) ? false : true;
		}
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0)
		{
			return (!(iClientGlobalFlags & iAbilityFlags)) ? false : true;
		}
	}

	if (iAbilityFlags != 0)
	{
		return (!(GetUserFlagBits(admin) & iAbilityFlags)) ? false : true;
	}

	return true;
}

static bool bIsAdminImmune(int survivor, int tank)
{
	if (!bIsValidClient(survivor, MT_CHECK_FAKECLIENT))
	{
		return false;
	}

	int iAbilityFlags = g_iImmunityFlags[MT_GetTankType(survivor)];
	if (iAbilityFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iAbilityFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iTypeFlags = MT_GetImmunityFlags(2, MT_GetTankType(survivor));
	if (iTypeFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iTypeFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iGlobalFlags = MT_GetImmunityFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iGlobalFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iClientTypeFlags = MT_GetImmunityFlags(4, MT_GetTankType(tank), survivor),
		iClientTypeFlags2 = MT_GetImmunityFlags(4, MT_GetTankType(tank), tank);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0 && (iClientTypeFlags & iAbilityFlags))
		{
			return ((iClientTypeFlags2 & iAbilityFlags) && iClientTypeFlags <= iClientTypeFlags2) ? false : true;
		}
	}

	int iClientGlobalFlags = MT_GetImmunityFlags(3, 0, survivor),
		iClientGlobalFlags2 = MT_GetImmunityFlags(3, 0, tank);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0 && (iClientGlobalFlags & iAbilityFlags))
		{
			return ((iClientGlobalFlags2 & iAbilityFlags) && iClientGlobalFlags <= iClientGlobalFlags2) ? false : true;
		}
	}

	if (iAbilityFlags != 0)
	{
		return ((GetUserFlagBits(tank) & iAbilityFlags) && GetUserFlagBits(survivor) <= GetUserFlagBits(tank)) ? false : true;
	}

	return false;
}

static int iGetNearestSurvivor(int tank, float pos[3])
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !bIsAdminImmune(iSurvivor, tank))
		{
			float flSurvivorPos[3];
			GetClientEyePosition(iSurvivor, flSurvivorPos);

			float flDistance = GetVectorDistance(pos, flSurvivorPos);
			if (flDistance <= g_flLaserRange[MT_GetTankType(tank)] && bVisiblePosition(pos, flSurvivorPos, tank, 1))
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

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || !MT_HasAdminAccess(iTank) || !bHasAdminAccess(iTank) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || !g_bLaser[iTank])
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if ((flTime + g_flLaserDuration[MT_GetTankType(iTank)]) < GetEngineTime())
	{
		vReset2(iTank);
		vReset3(iTank);

		return Plugin_Stop;
	}

	vLaser(iTank);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bLaser2[iTank])
	{
		g_bLaser2[iTank] = false;

		return Plugin_Stop;
	}

	g_bLaser2[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "LaserHuman6");

	return Plugin_Continue;
}