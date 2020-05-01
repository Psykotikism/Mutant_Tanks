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

#undef REQUIRE_PLUGIN
#include <mt_clone>
#define REQUIRE_PLUGIN

#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Shield Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank protects itself with a shield and throws propane tanks or gas cans.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Shield Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_SHIELD "models/props_unique/airport/atlas_break_ball.mdl"

#define MT_MENU_SHIELD "Shield Ability"

enum struct esGeneralSettings
{
	bool g_bCloneInstalled;

	ConVar g_cvMTTankThrowForce;
}

esGeneralSettings g_esGeneral;

enum struct esPlayerSettings
{
	bool g_bShield;
	bool g_bShield2;

	int g_iAccessFlags2;
	int g_iImmunityFlags2;
	int g_iShield;
	int g_iShieldCount;
}

esPlayerSettings g_esPlayer[MAXPLAYERS + 1];

enum struct esAbilitySettings
{
	float g_flHumanCooldown;
	float g_flHumanDuration;
	float g_flShieldChance;
	float g_flShieldDelay;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iShieldAbility;
	int g_iShieldColor[4];
	int g_iShieldMessage;
	int g_iShieldType;
}

esAbilitySettings g_esAbility[MT_MAXTYPES + 1];

public void OnAllPluginsLoaded()
{
	g_esGeneral.g_bCloneInstalled = LibraryExists("mt_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_esGeneral.g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "mt_clone", false))
	{
		g_esGeneral.g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("mutant_tanks.phrases");

	RegConsoleCmd("sm_mt_shield", cmdShieldInfo, "View information about the Shield ability.");

	g_esGeneral.g_cvMTTankThrowForce = FindConVar("z_tank_throw_force");

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
	PrecacheModel(MODEL_GASCAN, true);
	PrecacheModel(MODEL_SHIELD, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vReset2(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdShieldInfo(int client, int args)
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
		case false: vShieldMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vShieldMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iShieldMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Shield Ability Information");
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

public int iShieldMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iShieldAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iShieldCount, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
				case 2: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esAbility[MT_GetTankType(param1)].g_flHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "ShieldDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esAbility[MT_GetTankType(param1)].g_flHumanDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vShieldMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "ShieldMenu", param1);
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
	menu.AddItem(MT_MENU_SHIELD, MT_MENU_SHIELD);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_SHIELD, false))
	{
		vShieldMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_esGeneral.g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				vShieldAbility(victim, false);

				return Plugin_Continue;
			}

			if (g_esPlayer[victim].g_bShield)
			{
				switch (g_esAbility[MT_GetTankType(victim)].g_iShieldType)
				{
					case 0:
					{
						if (damagetype & DMG_BULLET)
						{
							vShieldAbility(victim, false);
						}

						return Plugin_Handled;

					}
					case 1:
					{
						if ((damagetype & DMG_BLAST) || (damagetype & DMG_BLAST_SURFACE) || (damagetype & DMG_AIRBOAT) || (damagetype & DMG_PLASMA))
						{
							vShieldAbility(victim, false);
						}

						return Plugin_Handled;
					}
					case 2:
					{
						if (damagetype & DMG_BURN)
						{
							vShieldAbility(victim, false);
						}

						return Plugin_Handled;
					}
					case 3:
					{
						if ((damagetype & DMG_SLASH) || (damagetype & DMG_CLUB))
						{
							vShieldAbility(victim, false);
						}

						return Plugin_Handled;
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
	list.PushString("shieldability");
	list2.PushString("shield ability");
	list3.PushString("shield_ability");
	list4.PushString("shield");
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
			g_esAbility[iIndex].g_flHumanDuration = 5.0;
			g_esAbility[iIndex].g_iHumanMode = 1;
			g_esAbility[iIndex].g_iShieldAbility = 0;
			g_esAbility[iIndex].g_iShieldMessage = 0;
			g_esAbility[iIndex].g_flShieldChance = 33.3;
			g_esAbility[iIndex].g_flShieldDelay = 5.0;
			g_esAbility[iIndex].g_iShieldType = 1;

			for (int iPos = 0; iPos < 4; iPos++)
			{
				g_esAbility[iIndex].g_iShieldColor[iPos] = -1;
			}
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "shieldability", false) || StrEqual(subsection, "shield ability", false) || StrEqual(subsection, "shield_ability", false) || StrEqual(subsection, "shield", false))
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
		g_esAbility[type].g_iHumanAbility = iGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAmmo = iGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_flHumanCooldown = flGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_flHumanCooldown, value, 0.0, 999999.0);
		g_esAbility[type].g_flHumanDuration = flGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_esAbility[type].g_flHumanDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_iHumanMode = iGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iShieldAbility = iGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iShieldAbility, value, 0, 1);
		g_esAbility[type].g_iShieldMessage = iGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iShieldMessage, value, 0, 1);
		g_esAbility[type].g_flShieldChance = flGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "ShieldChance", "Shield Chance", "Shield_Chance", "chance", g_esAbility[type].g_flShieldChance, value, 0.0, 100.0);
		g_esAbility[type].g_flShieldDelay = flGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "ShieldDelay", "Shield Delay", "Shield_Delay", "delay", g_esAbility[type].g_flShieldDelay, value, 0.1, 999999.0);
		g_esAbility[type].g_iShieldType = iGetValue(subsection, "shieldability", "shield ability", "shield_ability", "shield", key, "ShieldType", "Shield Type", "Shield_Type", "type", g_esAbility[type].g_iShieldType, value, 0, 3);

		if (StrEqual(subsection, "shieldability", false) || StrEqual(subsection, "shield ability", false) || StrEqual(subsection, "shield_ability", false) || StrEqual(subsection, "shield", false))
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

		if ((StrEqual(subsection, "shieldability", false) || StrEqual(subsection, "shield ability", false) || StrEqual(subsection, "shield_ability", false) || StrEqual(subsection, "shield", false)) && (StrEqual(key, "ShieldColor", false) || StrEqual(key, "Shield Color", false) || StrEqual(key, "Shield_Color", false) || StrEqual(key, "color", false)) && value[0] != '\0')
		{
			char sSet[4][4], sValue[16];
			strcopy(sValue, sizeof(sValue), value);
			ReplaceString(sValue, sizeof(sValue), " ", "");
			ExplodeString(sValue, ",", sSet, sizeof(sSet), sizeof(sSet[]));

			for (int iPos = 0; iPos < 4; iPos++)
			{
				if (sSet[iPos][0] == '\0')
				{
					continue;
				}

				g_esAbility[type].g_iShieldColor[iPos] = (StringToInt(sSet[iPos]) >= 0) ? iClamp(StringToInt(sSet[iPos]), 0, 255) : GetRandomInt(0, 255);
			}
		}
	}
}

public void MT_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && g_esPlayer[iTank].g_bShield)
		{
			vRemoveShield(iTank);
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
			vRemoveShield(iBot);

			vReset2(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vRemoveShield(iTank);

			vReset2(iTank);
		}
	}
	else if (StrEqual(name, "player_death") || StrEqual(name, "player_incapacitated") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveShield(iTank);

			vReset2(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0) && bIsCloneAllowed(tank, g_esGeneral.g_bCloneInstalled) && g_esAbility[MT_GetTankType(tank)].g_iShieldAbility == 1 && !g_esPlayer[tank].g_bShield && !g_esPlayer[tank].g_bShield2)
	{
		vShieldAbility(tank, true);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_esGeneral.g_bCloneInstalled))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if (g_esAbility[MT_GetTankType(tank)].g_iShieldAbility == 1 && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				switch (g_esAbility[MT_GetTankType(tank)].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bShield && !g_esPlayer[tank].g_bShield2)
						{
							vShieldAbility(tank, true);
						}
						else if (g_esPlayer[tank].g_bShield)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman3");
						}
						else if (g_esPlayer[tank].g_bShield2)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman4");
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iShieldCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bShield && !g_esPlayer[tank].g_bShield2)
							{
								g_esPlayer[tank].g_bShield = true;
								g_esPlayer[tank].g_iShieldCount++;

								g_esPlayer[tank].g_iShield = CreateEntityByName("prop_dynamic");
								if (bIsValidEntity(g_esPlayer[tank].g_iShield))
								{
									vShield(tank);
								}

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman", g_esPlayer[tank].g_iShieldCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bShield)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman3");
							}
							else if (g_esPlayer[tank].g_bShield2)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman4");
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldAmmo");
						}
					}
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_esGeneral.g_bCloneInstalled))
	{
		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if (g_esAbility[MT_GetTankType(tank)].g_iShieldAbility == 1 && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				if (g_esAbility[MT_GetTankType(tank)].g_iHumanMode == 1 && g_esPlayer[tank].g_bShield && !g_esPlayer[tank].g_bShield2)
				{
					vRemoveShield(tank);

					g_esPlayer[tank].g_bShield = false;

					vReset3(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
	{
		vRemoveShield(tank);
	}

	vReset2(tank, revert);
}

public void MT_OnRockThrow(int tank, int rock)
{
	if (MT_IsTankSupported(tank) && bIsCloneAllowed(tank, g_esGeneral.g_bCloneInstalled) && g_esAbility[MT_GetTankType(tank)].g_iShieldAbility == 1 && GetRandomFloat(0.1, 100.0) <= g_esAbility[MT_GetTankType(tank)].g_flShieldChance)
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		DataPack dpShieldThrow;
		CreateDataTimer(0.1, tTimerShieldThrow, dpShieldThrow, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpShieldThrow.WriteCell(EntIndexToEntRef(rock));
		dpShieldThrow.WriteCell(GetClientUserId(tank));
		dpShieldThrow.WriteCell(MT_GetTankType(tank));
	}
}

static void vRemoveShield(int tank)
{
	if (bIsValidEntRef(g_esPlayer[tank].g_iShield))
	{
		g_esPlayer[tank].g_iShield = EntRefToEntIndex(g_esPlayer[tank].g_iShield);
		if (bIsValidEntity(g_esPlayer[tank].g_iShield))
		{
			MT_HideEntity(g_esPlayer[tank].g_iShield, false);
			RemoveEntity(g_esPlayer[tank].g_iShield);
		}
	}

	g_esPlayer[tank].g_iShield = INVALID_ENT_REFERENCE;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vReset2(iPlayer);
		}
	}
}

static void vReset2(int tank, bool revert = false)
{
	if (!revert)
	{
		g_esPlayer[tank].g_bShield = false;
	}

	g_esPlayer[tank].g_bShield2 = false;
	g_esPlayer[tank].g_iShield = INVALID_ENT_REFERENCE;
	g_esPlayer[tank].g_iShieldCount = 0;
}

static void vReset3(int tank)
{
	if (!g_esPlayer[tank].g_bShield2)
	{
		g_esPlayer[tank].g_bShield2 = true;

		MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman5");

		if (g_esPlayer[tank].g_iShieldCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
		{
			CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flHumanCooldown, tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_esPlayer[tank].g_bShield2 = false;
		}
	}
}

static void vShield(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	float flOrigin[3];
	GetClientAbsOrigin(tank, flOrigin);
	flOrigin[2] -= 120.0;

	SetEntityModel(g_esPlayer[tank].g_iShield, MODEL_SHIELD);

	DispatchKeyValueVector(g_esPlayer[tank].g_iShield, "origin", flOrigin);
	DispatchSpawn(g_esPlayer[tank].g_iShield);
	vSetEntityParent(g_esPlayer[tank].g_iShield, tank, true);

	SetEntityRenderMode(g_esPlayer[tank].g_iShield, RENDER_TRANSTEXTURE);
	SetEntityRenderColor(g_esPlayer[tank].g_iShield, g_esAbility[MT_GetTankType(tank)].g_iShieldColor[0], g_esAbility[MT_GetTankType(tank)].g_iShieldColor[1], g_esAbility[MT_GetTankType(tank)].g_iShieldColor[2], g_esAbility[MT_GetTankType(tank)].g_iShieldColor[3]);

	SetEntProp(g_esPlayer[tank].g_iShield, Prop_Send, "m_CollisionGroup", 1);

	MT_HideEntity(g_esPlayer[tank].g_iShield, true);
	g_esPlayer[tank].g_iShield = EntIndexToEntRef(g_esPlayer[tank].g_iShield);
}

static void vShieldAbility(int tank, bool shield)
{
	switch (shield)
	{
		case true:
		{
			if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
			{
				return;
			}

			if (g_esPlayer[tank].g_iShieldCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
			{
				if (GetRandomFloat(0.1, 100.0) <= g_esAbility[MT_GetTankType(tank)].g_flShieldChance)
				{
					g_esPlayer[tank].g_iShield = CreateEntityByName("prop_dynamic");
					if (bIsValidEntity(g_esPlayer[tank].g_iShield))
					{
						vShield(tank);

						g_esPlayer[tank].g_bShield = true;

						ExtinguishEntity(tank);

						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
						{
							g_esPlayer[tank].g_iShieldCount++;

							CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flHumanDuration, tTimerStopShield, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

							MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman", g_esPlayer[tank].g_iShieldCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
						}

						if (g_esAbility[MT_GetTankType(tank)].g_iShieldMessage == 1)
						{
							char sTankName[33];
							MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
							MT_PrintToChatAll("%s %t", MT_TAG2, "Shield", sTankName);
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldHuman2");
				}
			}
			else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				MT_PrintToChat(tank, "%s %t", MT_TAG3, "ShieldAmmo");
			}
		}
		case false:
		{
			vRemoveShield(tank);

			g_esPlayer[tank].g_bShield = false;

			switch (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT))
			{
				case true: vReset3(tank);
				case false:
				{
					if (!g_esPlayer[tank].g_bShield2)
					{
						g_esPlayer[tank].g_bShield2 = true;

						CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flShieldDelay, tTimerShield, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}

			if (g_esAbility[MT_GetTankType(tank)].g_iShieldMessage == 1)
			{
				char sTankName[33];
				MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
				MT_PrintToChatAll("%s %t", MT_TAG2, "Shield2", sTankName);
			}
		}
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

public Action tTimerShield(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_esGeneral.g_bCloneInstalled) || g_esAbility[MT_GetTankType(iTank)].g_iShieldAbility == 0 || !g_esPlayer[iTank].g_bShield2)
	{
		g_esPlayer[iTank].g_bShield2 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bShield2 = false;

	vShieldAbility(iTank, true);

	return Plugin_Continue;
}

public Action tTimerShieldThrow(Handle timer, DataPack pack)
{
	pack.Reset();

	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_esGeneral.g_bCloneInstalled) || iType != MT_GetTankType(iTank) || g_esAbility[MT_GetTankType(iTank)].g_iShieldAbility == 0 || !g_esPlayer[iTank].g_bShield)
	{
		return Plugin_Stop;
	}

	if (g_esAbility[MT_GetTankType(iTank)].g_iShieldType != 1 && g_esAbility[MT_GetTankType(iTank)].g_iShieldType != 2)
	{
		return Plugin_Stop;
	}

	float flVelocity[3];
	GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);

	float flVector = GetVectorLength(flVelocity);
	if (flVector > 500.0)
	{
		int iThrowable = CreateEntityByName("prop_physics");
		if (bIsValidEntity(iThrowable))
		{
			switch (g_esAbility[MT_GetTankType(iTank)].g_iShieldType)
			{
				case 1: SetEntityModel(iThrowable, MODEL_PROPANETANK);
				case 2: SetEntityModel(iThrowable, MODEL_GASCAN);
			}

			float flPos[3];
			GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
			RemoveEntity(iRock);

			NormalizeVector(flVelocity, flVelocity);
			ScaleVector(flVelocity, g_esGeneral.g_cvMTTankThrowForce.FloatValue * 1.4);

			DispatchSpawn(iThrowable);
			TeleportEntity(iThrowable, flPos, NULL_VECTOR, flVelocity);
		}

		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action tTimerStopShield(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_esGeneral.g_bCloneInstalled) || !g_esPlayer[iTank].g_bShield)
	{
		vShieldAbility(iTank, false);

		return Plugin_Stop;
	}

	vShieldAbility(iTank, false);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_esGeneral.g_bCloneInstalled) || !g_esPlayer[iTank].g_bShield2)
	{
		g_esPlayer[iTank].g_bShield2 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bShield2 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "ShieldHuman6");

	return Plugin_Continue;
}