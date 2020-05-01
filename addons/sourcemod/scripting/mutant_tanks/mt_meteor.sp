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
	name = "[MT] Meteor Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank creates meteor showers.",
	version = MT_VERSION,
	url = MT_URL
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Meteor Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define MODEL_CONCRETE_CHUNK "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_TREE_TRUNK "models/props_foliage/tree_trunk.mdl"
#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"

#define SOUND_ROCK "player/tank/attack/thrown_missile_loop_1.wav"

#define MT_MENU_METEOR "Meteor Ability"

bool g_bCloneInstalled;

enum struct esPlayerSettings
{
	bool g_bMeteor;
	bool g_bMeteor2;

	int g_iAccessFlags2;
	int g_iImmunityFlags2;
	int g_iMeteorCount;
}

esPlayerSettings g_esPlayer[MAXPLAYERS + 1];

enum struct esAbilitySettings
{
	float g_flHumanCooldown;
	float g_flMeteorChance;
	float g_flMeteorDamage;
	float g_flMeteorDuration;
	float g_flMeteorRadius[2];

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iMeteorAbility;
	int g_iMeteorMessage;
	int g_iMeteorMode;
}

esAbilitySettings g_esAbility[MT_MAXTYPES + 1];

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

	RegConsoleCmd("sm_mt_meteor", cmdMeteorInfo, "View information about the Meteor ability.");
}

public void OnMapStart()
{
	PrecacheModel(MODEL_GASCAN, true);

	PrecacheSound(SOUND_ROCK, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	vRemoveMeteor(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdMeteorInfo(int client, int args)
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
		case false: vMeteorMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vMeteorMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iMeteorMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Meteor Ability Information");
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

public int iMeteorMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iMeteorAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iMeteorCount, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esAbility[MT_GetTankType(param1)].g_flHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "MeteorDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esAbility[MT_GetTankType(param1)].g_flMeteorDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vMeteorMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "MeteorMenu", param1);
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
	menu.AddItem(MT_MENU_METEOR, MT_MENU_METEOR);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_METEOR, false))
	{
		vMeteorMenu(client, 0);
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
	list.PushString("meteorability");
	list2.PushString("meteor ability");
	list3.PushString("meteor_ability");
	list4.PushString("meteor");
}

public void MT_OnConfigsLoad(int mode)
{
	if (mode == 3)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				g_esPlayer[iPlayer].g_iAccessFlags2 = 0;
				g_esPlayer[iPlayer].g_iImmunityFlags2 = 0;
			}
		}
	}
	else if (mode == 1)
	{
		for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
		{
			g_esAbility[iIndex].g_iAccessFlags = 0;
			g_esAbility[iIndex].g_iImmunityFlags = 0;
			g_esAbility[iIndex].g_iHumanAbility = 0;
			g_esAbility[iIndex].g_iHumanAmmo = 5;
			g_esAbility[iIndex].g_flHumanCooldown = 30.0;
			g_esAbility[iIndex].g_iHumanMode = 1;
			g_esAbility[iIndex].g_iMeteorAbility = 0;
			g_esAbility[iIndex].g_iMeteorMessage = 0;
			g_esAbility[iIndex].g_flMeteorChance = 33.3;
			g_esAbility[iIndex].g_flMeteorDamage = 5.0;
			g_esAbility[iIndex].g_flMeteorDuration = 5.0;
			g_esAbility[iIndex].g_iMeteorMode = 0;
			g_esAbility[iIndex].g_flMeteorRadius[0] = -180.0;
			g_esAbility[iIndex].g_flMeteorRadius[1] = 180.0;
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "meteorability", false) || StrEqual(subsection, "meteor ability", false) || StrEqual(subsection, "meteor_ability", false) || StrEqual(subsection, "meteor", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esPlayer[admin].g_iAccessFlags2 = (value[0] != '\0') ? ReadFlagString(value) : g_esPlayer[admin].g_iAccessFlags2;
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esPlayer[admin].g_iImmunityFlags2 = (value[0] != '\0') ? ReadFlagString(value) : g_esPlayer[admin].g_iImmunityFlags2;
			}
		}
	}

	if (mode < 3 && type > 0)
	{
		g_esAbility[type].g_iHumanAbility = iGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAmmo = iGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_flHumanCooldown = flGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_flHumanCooldown, value, 0.0, 999999.0);
		g_esAbility[type].g_iHumanMode = iGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iMeteorAbility = iGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iMeteorAbility, value, 0, 1);
		g_esAbility[type].g_iMeteorMessage = iGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iMeteorMessage, value, 0, 1);
		g_esAbility[type].g_flMeteorChance = flGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "MeteorChance", "Meteor Chance", "Meteor_Chance", "chance", g_esAbility[type].g_flMeteorChance, value, 0.0, 100.0);
		g_esAbility[type].g_flMeteorDamage = flGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "MeteorDamage", "Meteor Damage", "Meteor_Damage", "damage", g_esAbility[type].g_flMeteorDamage, value, 1.0, 999999.0);
		g_esAbility[type].g_flMeteorDuration = flGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "MeteorDuration", "Meteor Duration", "Meteor_Duration", "duration", g_esAbility[type].g_flMeteorDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_iMeteorMode = iGetValue(subsection, "meteorability", "meteor ability", "meteor_ability", "meteor", key, "MeteorMode", "Meteor Mode", "Meteor_Mode", "mode", g_esAbility[type].g_iMeteorMode, value, 0, 1);

		if (StrEqual(subsection, "meteorability", false) || StrEqual(subsection, "meteor ability", false) || StrEqual(subsection, "meteor_ability", false) || StrEqual(subsection, "meteor", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_esAbility[type].g_iAccessFlags = (value[0] != '\0') ? ReadFlagString(value) : g_esAbility[type].g_iAccessFlags;
			}
			else if (StrEqual(key, "ImmunityFlags", false) || StrEqual(key, "Immunity Flags", false) || StrEqual(key, "Immunity_Flags", false) || StrEqual(key, "immunity", false))
			{
				g_esAbility[type].g_iImmunityFlags = (value[0] != '\0') ? ReadFlagString(value) : g_esAbility[type].g_iImmunityFlags;
			}
		}

		if ((StrEqual(subsection, "meteorability", false) || StrEqual(subsection, "meteor ability", false) || StrEqual(subsection, "meteor_ability", false) || StrEqual(subsection, "meteor", false)) && (StrEqual(key, "MeteorRadius", false) || StrEqual(key, "Meteor Radius", false) || StrEqual(key, "Meteor_Radius", false) || StrEqual(key, "radius", false)) && value[0] != '\0')
		{
			char sSet[2][7], sValue[14];
			strcopy(sValue, sizeof(sValue), value);
			ReplaceString(sValue, sizeof(sValue), " ", "");
			ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

			g_esAbility[type].g_flMeteorRadius[0] = (sSet[0][0] != '\0') ? flClamp(StringToFloat(sSet[0]), -200.0, 0.0) : g_esAbility[type].g_flMeteorRadius[0];
			g_esAbility[type].g_flMeteorRadius[1] = (sSet[1][0] != '\0') ? flClamp(StringToFloat(sSet[1]), 0.0, 200.0) : g_esAbility[type].g_flMeteorRadius[1];
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
			vRemoveMeteor(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esAbility[MT_GetTankType(tank)].g_iMeteorAbility == 1 && !g_esPlayer[tank].g_bMeteor)
	{
		vMeteorAbility(tank);
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
			if (g_esAbility[MT_GetTankType(tank)].g_iMeteorAbility == 1 && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				switch (g_esAbility[MT_GetTankType(tank)].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bMeteor && !g_esPlayer[tank].g_bMeteor2)
						{
							vMeteorAbility(tank);
						}
						else if (g_esPlayer[tank].g_bMeteor)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman3");
						}
						else if (g_esPlayer[tank].g_bMeteor2)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman4");
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iMeteorCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bMeteor && !g_esPlayer[tank].g_bMeteor2)
							{
								g_esPlayer[tank].g_bMeteor = true;
								g_esPlayer[tank].g_iMeteorCount++;

								vMeteor2(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman", g_esPlayer[tank].g_iMeteorCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bMeteor)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman3");
							}
							else if (g_esPlayer[tank].g_bMeteor2)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman4");
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorAmmo");
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
			if (g_esAbility[MT_GetTankType(tank)].g_iMeteorAbility == 1 && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				if (g_esAbility[MT_GetTankType(tank)].g_iHumanMode == 1 && g_esPlayer[tank].g_bMeteor && !g_esPlayer[tank].g_bMeteor2)
				{
					g_esPlayer[tank].g_bMeteor = false;

					vReset2(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveMeteor(tank);
}

static void vMeteor(int tank, int rock)
{
	if (!MT_IsTankSupported(tank) || (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || !MT_IsTypeEnabled(MT_GetTankType(tank)) || !bIsCloneAllowed(tank, g_bCloneInstalled) || !bIsValidEntity(rock))
	{
		return;
	}

	RemoveEntity(rock);

	CreateTimer(3.0, tTimerStopRockSound, _, TIMER_FLAG_NO_MAPCHANGE);

	switch (g_esAbility[MT_GetTankType(tank)].g_iMeteorMode)
	{
		case 0:
		{
			float flRockPos[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flRockPos);

			vSpecialAttack(tank, flRockPos, 50.0, MODEL_GASCAN);
			vSpecialAttack(tank, flRockPos, 50.0, MODEL_PROPANETANK);
		}
		case 1:
		{
			float flRockPos[3];
			GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flRockPos);

			vSpecialAttack(tank, flRockPos, 50.0, MODEL_PROPANETANK);

			float flTankPos[3];
			GetClientAbsOrigin(tank, flTankPos);

			for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
			{
				if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
				{
					float flSurvivorPos[3];
					GetClientAbsOrigin(iSurvivor, flSurvivorPos);

					float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
					if (flDistance < 200.0)
					{
						vDamageEntity(iSurvivor, tank, g_esAbility[MT_GetTankType(tank)].g_flMeteorDamage, "16");
					}
				}
			}

			int iPointPush = CreateEntityByName("point_push");
			if (bIsValidEntity(iPointPush))
			{
				SetEntPropEnt(iPointPush, Prop_Send, "m_hOwnerEntity", tank);
				DispatchKeyValueFloat(iPointPush, "magnitude", 600.0);
				DispatchKeyValueFloat(iPointPush, "radius", 200.0);
				DispatchKeyValue(iPointPush, "spawnflags", "8");
				TeleportEntity(iPointPush, flRockPos, NULL_VECTOR, NULL_VECTOR);

				DispatchSpawn(iPointPush);
				AcceptEntityInput(iPointPush, "Enable");

				iPointPush = EntIndexToEntRef(iPointPush);
				vDeleteEntity(iPointPush, 0.5);
			}
		}
	}
}

static void vMeteor2(int tank)
{
	DataPack dpMeteor;
	CreateDataTimer(0.6, tTimerMeteor, dpMeteor, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpMeteor.WriteCell(GetClientUserId(tank));
	dpMeteor.WriteCell(MT_GetTankType(tank));
	dpMeteor.WriteFloat(GetEngineTime());
}

static void vMeteorAbility(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_esPlayer[tank].g_iMeteorCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_esAbility[MT_GetTankType(tank)].g_flMeteorChance)
		{
			g_esPlayer[tank].g_bMeteor = true;

			if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bMeteor2)
			{
				g_esPlayer[tank].g_bMeteor2 = true;
				g_esPlayer[tank].g_iMeteorCount++;

				MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman", g_esPlayer[tank].g_iMeteorCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
			}

			vMeteor2(tank);

			if (g_esAbility[MT_GetTankType(tank)].g_iMeteorMessage == 1)
			{
				char sTankName[33];
				MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Meteor", sTankName);
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
		{
			MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman2");
		}
	}
	else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
	{
		MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorAmmo");
	}
}

static void vRemoveMeteor(int tank)
{
	g_esPlayer[tank].g_bMeteor = false;
	g_esPlayer[tank].g_bMeteor2 = false;
	g_esPlayer[tank].g_iMeteorCount = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveMeteor(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_esPlayer[tank].g_bMeteor2 = true;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "MeteorHuman5");

	if (g_esPlayer[tank].g_iMeteorCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
	{
		CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flHumanCooldown, tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_esPlayer[tank].g_bMeteor2 = false;
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, MT_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_esAbility[MT_GetTankType(admin)].g_iAccessFlags;
	if (iAbilityFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iAbilityFlags)) ? false : true;
	}

	int iTypeFlags = MT_GetAccessFlags(2, MT_GetTankType(admin));
	if (iTypeFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iTypeFlags)) ? false : true;
	}

	int iGlobalFlags = MT_GetAccessFlags(1);
	if (iGlobalFlags != 0 && g_esPlayer[admin].g_iAccessFlags2 != 0)
	{
		return (!(g_esPlayer[admin].g_iAccessFlags2 & iGlobalFlags)) ? false : true;
	}

	int iClientTypeFlags = MT_GetAccessFlags(4, MT_GetTankType(admin), admin);
	if (iClientTypeFlags != 0 && iAbilityFlags != 0)
	{
		return (!(iClientTypeFlags & iAbilityFlags)) ? false : true;
	}

	int iClientGlobalFlags = MT_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0 && iAbilityFlags != 0)
	{
		return (!(iClientGlobalFlags & iAbilityFlags)) ? false : true;
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

	int iAbilityFlags = g_esAbility[MT_GetTankType(tank)].g_iImmunityFlags;
	if (iAbilityFlags != 0 && g_esPlayer[survivor].g_iImmunityFlags2 != 0 && (g_esPlayer[survivor].g_iImmunityFlags2 & iAbilityFlags))
	{
		return (g_esPlayer[tank].g_iImmunityFlags2 != 0 && (g_esPlayer[tank].g_iImmunityFlags2 & iAbilityFlags) && g_esPlayer[survivor].g_iImmunityFlags2 <= g_esPlayer[tank].g_iImmunityFlags2) ? false : true;
	}

	int iTypeFlags = MT_GetImmunityFlags(2, MT_GetTankType(tank));
	if (iTypeFlags != 0 && g_esPlayer[survivor].g_iImmunityFlags2 != 0 && (g_esPlayer[survivor].g_iImmunityFlags2 & iTypeFlags))
	{
		return (g_esPlayer[tank].g_iImmunityFlags2 != 0 && (g_esPlayer[tank].g_iImmunityFlags2 & iAbilityFlags) && g_esPlayer[survivor].g_iImmunityFlags2 <= g_esPlayer[tank].g_iImmunityFlags2) ? false : true;
	}

	int iGlobalFlags = MT_GetImmunityFlags(1);
	if (iGlobalFlags != 0 && g_esPlayer[survivor].g_iImmunityFlags2 != 0 && (g_esPlayer[survivor].g_iImmunityFlags2 & iGlobalFlags))
	{
		return (g_esPlayer[tank].g_iImmunityFlags2 != 0 && (g_esPlayer[tank].g_iImmunityFlags2 & iAbilityFlags) && g_esPlayer[survivor].g_iImmunityFlags2 <= g_esPlayer[tank].g_iImmunityFlags2) ? false : true;
	}

	int iClientTypeFlags = MT_GetImmunityFlags(4, MT_GetTankType(tank), survivor),
		iClientTypeFlags2 = MT_GetImmunityFlags(4, MT_GetTankType(tank), tank);
	if (iClientTypeFlags != 0 && iAbilityFlags != 0 && (iClientTypeFlags & iAbilityFlags))
	{
		return (iClientTypeFlags2 != 0 && (iClientTypeFlags2 & iAbilityFlags) && iClientTypeFlags <= iClientTypeFlags2) ? false : true;
	}

	int iClientGlobalFlags = MT_GetImmunityFlags(3, 0, survivor),
		iClientGlobalFlags2 = MT_GetImmunityFlags(3, 0, tank);
	if (iClientGlobalFlags != 0 && iAbilityFlags != 0 && (iClientGlobalFlags & iAbilityFlags))
	{
		return (iClientGlobalFlags2 != 0 && (iClientGlobalFlags2 & iAbilityFlags) && iClientGlobalFlags <= iClientGlobalFlags2) ? false : true;
	}

	int iSurvivorFlags = GetUserFlagBits(survivor), iTankFlags = GetUserFlagBits(tank);
	if (iAbilityFlags != 0 && iSurvivorFlags != 0 && (iSurvivorFlags & iAbilityFlags))
	{
		return (iTankFlags != 0 && iSurvivorFlags <= iTankFlags) ? false : true;
	}

	return false;
}

public Action tTimerMeteor(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || !g_esPlayer[iTank].g_bMeteor)
	{
		g_esPlayer[iTank].g_bMeteor = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (g_esAbility[MT_GetTankType(iTank)].g_iMeteorAbility == 0 || ((!MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) || (g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && g_esAbility[MT_GetTankType(iTank)].g_iHumanMode == 0)) && (flTime + g_esAbility[MT_GetTankType(iTank)].g_flMeteorDuration) < GetEngineTime()))
	{
		g_esPlayer[iTank].g_bMeteor = false;

		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && g_esAbility[MT_GetTankType(iTank)].g_iHumanMode == 0 && !g_esPlayer[iTank].g_bMeteor2)
		{
			vReset2(iTank);
		}

		if (g_esAbility[MT_GetTankType(iTank)].g_iMeteorMessage == 1)
		{
			char sTankName[33];
			MT_GetTankName(iTank, MT_GetTankType(iTank), sTankName);
			MT_PrintToChatAll("%s %t", MT_TAG2, "Meteor2", sTankName);
		}

		return Plugin_Stop;
	}

	float flPos[3];
	GetClientEyePosition(iTank, flPos);

	float flAngles[3];
	flAngles[0] = GetRandomFloat(-20.0, 20.0);
	flAngles[1] = GetRandomFloat(-20.0, 20.0);
	flAngles[2] = 60.0;
	GetVectorAngles(flAngles, flAngles);
	float flHitpos[3];
	iGetRayHitPos(flPos, flAngles, flHitpos, iTank, true, 2);

	float flDistance = GetVectorDistance(flPos, flHitpos);
	if (flDistance > 1600.0)
	{
		flDistance = 1600.0;
	}

	float flVector[3];
	MakeVectorFromPoints(flPos, flHitpos, flVector);
	NormalizeVector(flVector, flVector);
	ScaleVector(flVector, flDistance - 40.0);
	AddVectors(flPos, flVector, flHitpos);

	if (flDistance > 100.0)
	{
		int iMeteor = CreateEntityByName("tank_rock");
		if (bIsValidEntity(iMeteor))
		{
			float flAngles2[3];
			for (int iPos = 0; iPos < 3; iPos++)
			{
				flAngles2[iPos] = GetRandomFloat(g_esAbility[MT_GetTankType(iTank)].g_flMeteorRadius[0], g_esAbility[MT_GetTankType(iTank)].g_flMeteorRadius[1]);
			}

			float flVelocity[3];
			flVelocity[0] = GetRandomFloat(0.0, 350.0);
			flVelocity[1] = GetRandomFloat(0.0, 350.0);
			flVelocity[2] = GetRandomFloat(0.0, 30.0);

			TeleportEntity(iMeteor, flHitpos, flAngles2, flVelocity);

			DispatchSpawn(iMeteor);
			ActivateEntity(iMeteor);
			AcceptEntityInput(iMeteor, "Ignite");

			SetEntPropEnt(iMeteor, Prop_Data, "m_hThrower", iTank);
			iMeteor = EntIndexToEntRef(iMeteor);
			vDeleteEntity(iMeteor, 30.0);

			DataPack dpMeteor;
			CreateDataTimer(10.0, tTimerMeteorExplode, dpMeteor, TIMER_FLAG_NO_MAPCHANGE);
			dpMeteor.WriteCell(iMeteor);
			dpMeteor.WriteCell(GetClientUserId(iTank));
		}
	}

	int iMeteor = -1;
	while ((iMeteor = FindEntityByClassname(iMeteor, "tank_rock")) != INVALID_ENT_REFERENCE)
	{
		int iOwner = GetEntPropEnt(iMeteor, Prop_Data, "m_hThrower");
		if (iTank == iOwner)
		{
			if (flGetGroundUnits(iMeteor) < 200.0)
			{
				vMeteor(iOwner, iMeteor);
			}
		}
	}

	return Plugin_Continue;
}

public Action tTimerMeteorExplode(Handle timer, DataPack pack)
{
	pack.Reset();

	int iMeteor = EntRefToEntIndex(pack.ReadCell()), iTank = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsTankSupported(iTank) || iMeteor == INVALID_ENT_REFERENCE || !bIsValidEntity(iMeteor))
	{
		return Plugin_Stop;
	}

	vMeteor(iTank, iMeteor);

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

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iTank].g_bMeteor2)
	{
		g_esPlayer[iTank].g_bMeteor2 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bMeteor2 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "MeteorHuman6");

	return Plugin_Continue;
}