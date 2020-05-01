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
#tryinclude <mt_clone>
#define REQUIRE_PLUGIN

#include <mutant_tanks>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[MT] Jump Ability",
	author = MT_AUTHOR,
	description = "The Mutant Tank jumps periodically or sporadically and makes survivors jump uncontrollably.",
	version = MT_VERSION,
	url = MT_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[MT] Jump Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define MT_MENU_JUMP "Jump Ability"

bool g_bCloneInstalled;

enum struct esPlayerSettings
{
	bool g_bJump;
	bool g_bJump2;
	bool g_bJump3;
	bool g_bJump4;
	bool g_bJump5;
	bool g_bJump6;
	bool g_bJump7;

	int g_iAccessFlags2;
	int g_iImmunityFlags2;
	int g_iJumpCount;
	int g_iJumpCount2;
	int g_iJumpOwner;
}

esPlayerSettings g_esPlayer[MAXPLAYERS + 1];

enum struct esAbilitySettings
{
	float g_flHumanCooldown;
	float g_flJumpChance;
	float g_flJumpDuration;
	float g_flJumpHeight;
	float g_flJumpInterval;
	float g_flJumpRange;
	float g_flJumpRangeChance;
	float g_flJumpSporadicChance;
	float g_flJumpSporadicHeight;

	int g_iAccessFlags;
	int g_iHumanAbility;
	int g_iHumanAmmo;
	int g_iHumanMode;
	int g_iImmunityFlags;
	int g_iJumpAbility;
	int g_iJumpEffect;
	int g_iJumpHit;
	int g_iJumpHitMode;
	int g_iJumpMessage;
	int g_iJumpMode;
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

	RegConsoleCmd("sm_mt_jump", cmdJumpInfo, "View information about the Jump ability.");

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

	vReset4(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdJumpInfo(int client, int args)
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
		case false: vJumpMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vJumpMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iJumpMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Jump Ability Information");
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

public int iJumpMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iJumpAbility == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iJumpCount, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo - g_esPlayer[param1].g_iJumpCount2, g_esAbility[MT_GetTankType(param1)].g_iHumanAmmo);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanMode == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_esAbility[MT_GetTankType(param1)].g_flHumanCooldown);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "JumpDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_esAbility[MT_GetTankType(param1)].g_flJumpDuration);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_esAbility[MT_GetTankType(param1)].g_iHumanAbility == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
			{
				vJumpMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "JumpMenu", param1);
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
	menu.AddItem(MT_MENU_JUMP, MT_MENU_JUMP);
}

public void MT_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, MT_MENU_JUMP, false))
	{
		vJumpMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && damage >= 0.5)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_esAbility[MT_GetTankType(attacker)].g_iJumpHitMode == 0 || g_esAbility[MT_GetTankType(attacker)].g_iJumpHitMode == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vJumpHit(victim, attacker, g_esAbility[MT_GetTankType(attacker)].g_flJumpChance, g_esAbility[MT_GetTankType(attacker)].g_iJumpHit, MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_esAbility[MT_GetTankType(victim)].g_iJumpHitMode == 0 || g_esAbility[MT_GetTankType(victim)].g_iJumpHitMode == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vJumpHit(attacker, victim, g_esAbility[MT_GetTankType(victim)].g_flJumpChance, g_esAbility[MT_GetTankType(victim)].g_iJumpHit, MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
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
	list.PushString("jumpability");
	list2.PushString("jump ability");
	list3.PushString("jump_ability");
	list4.PushString("jump");
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
			g_esAbility[iIndex].g_iJumpAbility = 0;
			g_esAbility[iIndex].g_iJumpEffect = 0;
			g_esAbility[iIndex].g_iJumpMessage = 0;
			g_esAbility[iIndex].g_flJumpChance = 33.3;
			g_esAbility[iIndex].g_flJumpDuration = 5.0;
			g_esAbility[iIndex].g_flJumpHeight = 300.0;
			g_esAbility[iIndex].g_iJumpHit = 0;
			g_esAbility[iIndex].g_iJumpHitMode = 0;
			g_esAbility[iIndex].g_flJumpInterval = 1.0;
			g_esAbility[iIndex].g_iJumpMode = 0;
			g_esAbility[iIndex].g_flJumpRange = 150.0;
			g_esAbility[iIndex].g_flJumpRangeChance = 15.0;
			g_esAbility[iIndex].g_flJumpSporadicChance = 33.3;
			g_esAbility[iIndex].g_flJumpSporadicHeight = 750.0;
		}
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin, int mode)
{
	if (mode == 3 && bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "jumpability", false) || StrEqual(subsection, "jump ability", false) || StrEqual(subsection, "jump_ability", false) || StrEqual(subsection, "jump", false))
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
		g_esAbility[type].g_iHumanAbility = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_esAbility[type].g_iHumanAbility, value, 0, 1);
		g_esAbility[type].g_iHumanAmmo = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_esAbility[type].g_iHumanAmmo, value, 0, 999999);
		g_esAbility[type].g_flHumanCooldown = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_esAbility[type].g_flHumanCooldown, value, 0.0, 999999.0);
		g_esAbility[type].g_iHumanMode = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_esAbility[type].g_iHumanMode, value, 0, 1);
		g_esAbility[type].g_iJumpAbility = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_esAbility[type].g_iJumpAbility, value, 0, 3);
		g_esAbility[type].g_iJumpEffect = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_esAbility[type].g_iJumpEffect, value, 0, 7);
		g_esAbility[type].g_iJumpMessage = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_esAbility[type].g_iJumpMessage, value, 0, 7);
		g_esAbility[type].g_flJumpChance = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpChance", "Jump Chance", "Jump_Chance", "chance", g_esAbility[type].g_flJumpChance, value, 0.0, 100.0);
		g_esAbility[type].g_flJumpDuration = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpDuration", "Jump Duration", "Jump_Duration", "duration", g_esAbility[type].g_flJumpDuration, value, 0.1, 999999.0);
		g_esAbility[type].g_flJumpHeight = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpHeight", "Jump Height", "Jump_Height", "height", g_esAbility[type].g_flJumpHeight, value, 0.1, 999999.0);
		g_esAbility[type].g_iJumpHit = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpHit", "Jump Hit", "Jump_Hit", "hit", g_esAbility[type].g_iJumpHit, value, 0, 1);
		g_esAbility[type].g_iJumpHitMode = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpHitMode", "Jump Hit Mode", "Jump_Hit_Mode", "hitmode", g_esAbility[type].g_iJumpHitMode, value, 0, 2);
		g_esAbility[type].g_flJumpInterval = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpInterval", "Jump Interval", "Jump_Interval", "interval", g_esAbility[type].g_flJumpInterval, value, 0.1, 999999.0);
		g_esAbility[type].g_iJumpMode = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpMode", "Jump Mode", "Jump_Mode", "mode", g_esAbility[type].g_iJumpMode, value, 0, 1);
		g_esAbility[type].g_flJumpRange = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpRange", "Jump Range", "Jump_Range", "range", g_esAbility[type].g_flJumpRange, value, 1.0, 999999.0);
		g_esAbility[type].g_flJumpRangeChance = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpRangeChance", "Jump Range Chance", "Jump_Range_Chance", "rangechance", g_esAbility[type].g_flJumpRangeChance, value, 0.0, 100.0);
		g_esAbility[type].g_flJumpSporadicChance = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpSporadicChance", "Jump Sporadic Chance", "Jump_Sporadic_Chance", "sporadicchance", g_esAbility[type].g_flJumpSporadicChance, value, 0.0, 100.0);
		g_esAbility[type].g_flJumpSporadicHeight = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpSporadicHeight", "Jump Sporadic Height", "Jump_Sporadic_Height", "sporadicheight", g_esAbility[type].g_flJumpSporadicHeight, value, 0.1, 999999.0);

		if (StrEqual(subsection, "jumpability", false) || StrEqual(subsection, "jump ability", false) || StrEqual(subsection, "jump_ability", false) || StrEqual(subsection, "jump", false))
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
	}
}

public void MT_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death") || StrEqual(name, "player_spawn"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vRemoveJump(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_esAbility[MT_GetTankType(tank)].g_iJumpAbility > 0)
	{
		vJumpAbility(tank, true);
		vJumpAbility(tank, false);
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
			if ((g_esAbility[MT_GetTankType(tank)].g_iJumpAbility == 2 || g_esAbility[MT_GetTankType(tank)].g_iJumpAbility == 3) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				switch (g_esAbility[MT_GetTankType(tank)].g_iHumanMode)
				{
					case 0:
					{
						if (!g_esPlayer[tank].g_bJump && !g_esPlayer[tank].g_bJump3)
						{
							vJumpAbility(tank, false);
						}
						else if (g_esPlayer[tank].g_bJump)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman4");
						}
						else if (g_esPlayer[tank].g_bJump3)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman5");
						}
					}
					case 1:
					{
						if (g_esPlayer[tank].g_iJumpCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
						{
							if (!g_esPlayer[tank].g_bJump && !g_esPlayer[tank].g_bJump3)
							{
								g_esPlayer[tank].g_bJump = true;
								g_esPlayer[tank].g_iJumpCount++;

								vJump2(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman", g_esPlayer[tank].g_iJumpCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
							}
							else if (g_esPlayer[tank].g_bJump)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman4");
							}
							else if (g_esPlayer[tank].g_bJump3)
							{
								MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman5");
							}
						}
						else
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpAmmo");
						}
					}
				}
			}
		}

		if (button & MT_SUB_KEY == MT_SUB_KEY)
		{
			if ((g_esAbility[MT_GetTankType(tank)].g_iJumpAbility == 1 || g_esAbility[MT_GetTankType(tank)].g_iJumpAbility == 3) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				if (!g_esPlayer[tank].g_bJump4 && !g_esPlayer[tank].g_bJump5)
				{
					vJumpAbility(tank, true);
				}
				else if (g_esPlayer[tank].g_bJump4)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman6");
				}
				else if (g_esPlayer[tank].g_bJump5)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman7");
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
			if ((g_esAbility[MT_GetTankType(tank)].g_iJumpAbility == 2 || g_esAbility[MT_GetTankType(tank)].g_iJumpAbility == 3) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
			{
				if (g_esAbility[MT_GetTankType(tank)].g_iHumanMode == 1 && g_esPlayer[tank].g_bJump && !g_esPlayer[tank].g_bJump3)
				{
					vReset3(tank);
				}
			}
		}
	}
}

public void MT_OnChangeType(int tank, bool revert)
{
	vRemoveJump(tank);
}

static void vJump(int survivor, int tank)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	float flVelocity[3];
	GetEntPropVector(survivor, Prop_Data, "m_vecVelocity", flVelocity);
	flVelocity[2] += g_esAbility[MT_GetTankType(tank)].g_flJumpHeight;

	TeleportEntity(survivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
}

static void vJump2(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	switch (g_esAbility[MT_GetTankType(tank)].g_iJumpMode)
	{
		case 0:
		{
			DataPack dpJump;
			CreateDataTimer(g_esAbility[MT_GetTankType(tank)].g_flJumpInterval, tTimerJump, dpJump, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpJump.WriteCell(GetClientUserId(tank));
			dpJump.WriteCell(MT_GetTankType(tank));
			dpJump.WriteFloat(GetEngineTime());
		}
		case 1:
		{
			DataPack dpJump2;
			CreateDataTimer(1.0, tTimerJump2, dpJump2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpJump2.WriteCell(GetClientUserId(tank));
			dpJump2.WriteCell(MT_GetTankType(tank));
			dpJump2.WriteFloat(GetEngineTime());
		}
	}
}

static void vJumpAbility(int tank, bool main)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_esAbility[MT_GetTankType(tank)].g_iJumpAbility == 1 || g_esAbility[MT_GetTankType(tank)].g_iJumpAbility == 3)
			{
				if (g_esPlayer[tank].g_iJumpCount2 < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
				{
					g_esPlayer[tank].g_bJump6 = false;
					g_esPlayer[tank].g_bJump7 = false;

					float flTankPos[3];
					GetClientAbsOrigin(tank, flTankPos);

					int iSurvivorCount;
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
						{
							float flSurvivorPos[3];
							GetClientAbsOrigin(iSurvivor, flSurvivorPos);

							float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
							if (flDistance <= g_esAbility[MT_GetTankType(tank)].g_flJumpRange)
							{
								vJumpHit(iSurvivor, tank, g_esAbility[MT_GetTankType(tank)].g_flJumpRangeChance, g_esAbility[MT_GetTankType(tank)].g_iJumpAbility, MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman8");
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpAmmo");
				}
			}
		}
		case false:
		{
			if ((g_esAbility[MT_GetTankType(tank)].g_iJumpAbility == 2 || g_esAbility[MT_GetTankType(tank)].g_iJumpAbility == 3) && !g_esPlayer[tank].g_bJump)
			{
				if (g_esPlayer[tank].g_iJumpCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
				{
					g_esPlayer[tank].g_bJump = true;

					if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
					{
						g_esPlayer[tank].g_iJumpCount++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman", g_esPlayer[tank].g_iJumpCount, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
					}

					vJump2(tank);

					if (g_esAbility[MT_GetTankType(tank)].g_iJumpMessage & MT_MESSAGE_SPECIAL)
					{
						char sTankName[33];
						MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Jump3", sTankName);
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpAmmo");
				}
			}
		}
	}
}

static void vJumpHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || MT_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (g_esPlayer[tank].g_iJumpCount2 < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_esPlayer[survivor].g_bJump2)
			{
				g_esPlayer[survivor].g_bJump2 = true;
				g_esPlayer[survivor].g_iJumpOwner = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && (flags & MT_ATTACK_RANGE) && !g_esPlayer[tank].g_bJump4)
				{
					g_esPlayer[tank].g_bJump4 = true;
					g_esPlayer[tank].g_iJumpCount2++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman2", g_esPlayer[tank].g_iJumpCount2, g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo);
				}

				DataPack dpJump3;
				CreateDataTimer(0.25, tTimerJump3, dpJump3, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpJump3.WriteCell(GetClientUserId(survivor));
				dpJump3.WriteCell(GetClientUserId(tank));
				dpJump3.WriteCell(MT_GetTankType(tank));
				dpJump3.WriteCell(messages);
				dpJump3.WriteCell(enabled);
				dpJump3.WriteFloat(GetEngineTime());

				vEffect(survivor, tank, g_esAbility[MT_GetTankType(tank)].g_iJumpEffect, flags);

				if (g_esAbility[MT_GetTankType(tank)].g_iJumpMessage & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Jump", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && !g_esPlayer[tank].g_bJump4)
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bJump6)
				{
					g_esPlayer[tank].g_bJump6 = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman3");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(tank)].g_iHumanAbility == 1 && !g_esPlayer[tank].g_bJump7)
		{
			g_esPlayer[tank].g_bJump7 = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpAmmo2");
		}
	}
}

static void vRemoveJump(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE) && g_esPlayer[iSurvivor].g_bJump2 && g_esPlayer[iSurvivor].g_iJumpOwner == tank)
		{
			g_esPlayer[iSurvivor].g_bJump2 = false;
			g_esPlayer[iSurvivor].g_iJumpOwner = 0;
		}
	}

	vReset4(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_INKICKQUEUE))
		{
			vReset4(iPlayer);
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_esPlayer[survivor].g_bJump2 = false;
	g_esPlayer[survivor].g_iJumpOwner = 0;

	if (g_esAbility[MT_GetTankType(tank)].g_iJumpMessage & messages)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Jump2", survivor);
	}
}

static void vReset3(int tank)
{
	g_esPlayer[tank].g_bJump = false;
	g_esPlayer[tank].g_bJump3 = true;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman9");

	if (g_esPlayer[tank].g_iJumpCount < g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(tank)].g_iHumanAmmo > 0)
	{
		CreateTimer(g_esAbility[MT_GetTankType(tank)].g_flHumanCooldown, tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_esPlayer[tank].g_bJump3 = false;
	}
}

static void vReset4(int tank)
{
	g_esPlayer[tank].g_bJump = false;
	g_esPlayer[tank].g_bJump2 = false;
	g_esPlayer[tank].g_bJump3 = false;
	g_esPlayer[tank].g_bJump4 = false;
	g_esPlayer[tank].g_bJump5 = false;
	g_esPlayer[tank].g_bJump6 = false;
	g_esPlayer[tank].g_bJump7 = false;
	g_esPlayer[tank].g_iJumpCount = 0;
	g_esPlayer[tank].g_iJumpCount2 = 0;
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

static float flGetNearestSurvivor(int tank)
{
	float flDistance;
	if (bIsTank(tank))
	{
		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				flDistance = GetVectorDistance(flTankPos, flSurvivorPos);

				break;
			}
		}
	}

	return flDistance;
}

public Action tTimerJump(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || (g_esAbility[MT_GetTankType(iTank)].g_iJumpAbility != 2 && g_esAbility[MT_GetTankType(iTank)].g_iJumpAbility != 3) || !g_esPlayer[iTank].g_bJump)
	{
		g_esPlayer[iTank].g_bJump = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && g_esAbility[MT_GetTankType(iTank)].g_iHumanMode == 0 && (flTime + g_esAbility[MT_GetTankType(iTank)].g_flJumpDuration) < GetEngineTime() && !g_esPlayer[iTank].g_bJump3)
	{
		vReset3(iTank);

		return Plugin_Stop;
	}

	if (!bIsEntityGrounded(iTank))
	{
		return Plugin_Continue;
	}

	vJump(iTank, iTank);

	return Plugin_Continue;
}

public Action tTimerJump2(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || (g_esAbility[MT_GetTankType(iTank)].g_iJumpAbility != 2 && g_esAbility[MT_GetTankType(iTank)].g_iJumpAbility != 3) || !g_esPlayer[iTank].g_bJump)
	{
		g_esPlayer[iTank].g_bJump = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && g_esAbility[MT_GetTankType(iTank)].g_iHumanMode == 0 && (flTime + g_esAbility[MT_GetTankType(iTank)].g_flJumpDuration) < GetEngineTime() && !g_esPlayer[iTank].g_bJump3)
	{
		vReset3(iTank);

		return Plugin_Stop;
	}

	if (GetRandomFloat(0.1, 100.0) > g_esAbility[MT_GetTankType(iTank)].g_flJumpSporadicChance)
	{
		return Plugin_Continue;
	}

	float flNearestSurvivor = flGetNearestSurvivor(iTank);
	if (flNearestSurvivor > 100.0 && flNearestSurvivor < 1000.0)
	{
		float flVelocity[3];
		GetEntPropVector(iTank, Prop_Data, "m_vecVelocity", flVelocity);

		if (flVelocity[0] > 0.0 && flVelocity[0] < 500.0)
		{
			flVelocity[0] += 500.0;
		}
		else if (flVelocity[0] < 0.0 && flVelocity[0] > -500.0)
		{
			flVelocity[0] += -500.0;
		}
		if (flVelocity[1] > 0.0 && flVelocity[1] < 500.0)
		{
			flVelocity[1] += 500.0;
		}
		else if (flVelocity[1] < 0.0 && flVelocity[1] > -500.0)
		{
			flVelocity[1] += -500.0;
		}

		flVelocity[2] += g_esAbility[MT_GetTankType(iTank)].g_flJumpSporadicHeight;
		TeleportEntity(iTank, NULL_VECTOR, NULL_VECTOR, flVelocity);
	}

	return Plugin_Continue;
}

public Action tTimerJump3(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!MT_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_esPlayer[iSurvivor].g_bJump2 = false;
		g_esPlayer[iSurvivor].g_iJumpOwner = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, iTank) || !g_esPlayer[iSurvivor].g_bJump2)
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iJumpEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if ((iJumpEnabled != 1 && iJumpEnabled != 3) || (flTime + g_esAbility[MT_GetTankType(iTank)].g_flJumpDuration < GetEngineTime()))
	{
		g_esPlayer[iTank].g_bJump4 = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_esAbility[MT_GetTankType(iTank)].g_iHumanAbility == 1 && (iMessage & MT_MESSAGE_RANGE) && !g_esPlayer[iTank].g_bJump5)
		{
			g_esPlayer[iTank].g_bJump5 = true;

			MT_PrintToChat(iTank, "%s %t", MT_TAG3, "JumpHuman10");

			if (g_esPlayer[iTank].g_iJumpCount2 < g_esAbility[MT_GetTankType(iTank)].g_iHumanAmmo && g_esAbility[MT_GetTankType(iTank)].g_iHumanAmmo > 0)
			{
				CreateTimer(g_esAbility[MT_GetTankType(iTank)].g_flHumanCooldown, tTimerResetCooldown2, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_esPlayer[iTank].g_bJump5 = false;
			}
		}

		return Plugin_Stop;
	}

	if (!bIsEntityGrounded(iSurvivor))
	{
		return Plugin_Continue;
	}

	vJump(iSurvivor, iTank);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iTank].g_bJump3)
	{
		g_esPlayer[iTank].g_bJump3 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bJump3 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "JumpHuman11");

	return Plugin_Continue;
}

public Action tTimerResetCooldown2(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_INKICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_esPlayer[iTank].g_bJump5)
	{
		g_esPlayer[iTank].g_bJump5 = false;

		return Plugin_Stop;
	}

	g_esPlayer[iTank].g_bJump5 = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "JumpHuman12");

	return Plugin_Continue;
}