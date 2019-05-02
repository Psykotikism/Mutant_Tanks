/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2019  Alfred "Crasher_3637/Psyk0tik" Llagas
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

bool g_bCloneInstalled, g_bJump[MAXPLAYERS + 1], g_bJump2[MAXPLAYERS + 1], g_bJump3[MAXPLAYERS + 1], g_bJump4[MAXPLAYERS + 1], g_bJump5[MAXPLAYERS + 1], g_bJump6[MAXPLAYERS + 1], g_bJump7[MAXPLAYERS + 1];

float g_flHumanCooldown[MT_MAXTYPES + 1], g_flJumpChance[MT_MAXTYPES + 1], g_flJumpDuration[MT_MAXTYPES + 1], g_flJumpHeight[MT_MAXTYPES + 1], g_flJumpInterval[MT_MAXTYPES + 1], g_flJumpRange[MT_MAXTYPES + 1], g_flJumpRangeChance[MT_MAXTYPES + 1], g_flJumpSporadicChance[MT_MAXTYPES + 1], g_flJumpSporadicHeight[MT_MAXTYPES + 1];

int g_iAccessFlags[MT_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[MT_MAXTYPES + 1], g_iHumanAmmo[MT_MAXTYPES + 1], g_iHumanMode[MT_MAXTYPES + 1], g_iImmunityFlags[MT_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1], g_iJumpAbility[MT_MAXTYPES + 1], g_iJumpCount[MAXPLAYERS + 1], g_iJumpCount2[MAXPLAYERS + 1], g_iJumpEffect[MT_MAXTYPES + 1], g_iJumpHit[MT_MAXTYPES + 1], g_iJumpHitMode[MT_MAXTYPES + 1], g_iJumpMessage[MT_MAXTYPES + 1], g_iJumpMode[MT_MAXTYPES + 1], g_iJumpOwner[MAXPLAYERS + 1];

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
			if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
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

	if (!bIsValidClient(client, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT))
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
				case 0: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iJumpAbility[MT_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo", g_iHumanAmmo[MT_GetTankType(param1)] - g_iJumpCount[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityAmmo2", g_iHumanAmmo[MT_GetTankType(param1)] - g_iJumpCount2[param1], g_iHumanAmmo[MT_GetTankType(param1)]);
				}
				case 2:
				{
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons");
					MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityButtons2");
				}
				case 3: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanMode[MT_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityCooldown", g_flHumanCooldown[MT_GetTankType(param1)]);
				case 5: MT_PrintToChat(param1, "%s %t", MT_TAG3, "JumpDetails");
				case 6: MT_PrintToChat(param1, "%s %t", MT_TAG3, "AbilityDuration", g_flJumpDuration[MT_GetTankType(param1)]);
				case 7: MT_PrintToChat(param1, "%s %t", MT_TAG3, g_iHumanAbility[MT_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
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
	if (MT_IsCorePluginEnabled() && bIsValidClient(victim, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (MT_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iJumpHitMode[MT_GetTankType(attacker)] == 0 || g_iJumpHitMode[MT_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if ((!MT_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || MT_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vJumpHit(victim, attacker, g_flJumpChance[MT_GetTankType(attacker)], g_iJumpHit[MT_GetTankType(attacker)], MT_MESSAGE_MELEE, MT_ATTACK_CLAW);
			}
		}
		else if (MT_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iJumpHitMode[MT_GetTankType(victim)] == 0 || g_iJumpHitMode[MT_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if ((!MT_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || MT_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vJumpHit(attacker, victim, g_flJumpChance[MT_GetTankType(victim)], g_iJumpHit[MT_GetTankType(victim)], MT_MESSAGE_MELEE, MT_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

public void MT_OnConfigsLoad()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_iAccessFlags2[iPlayer] = 0;
			g_iImmunityFlags2[iPlayer] = 0;
		}
	}

	for (int iIndex = MT_GetMinType(); iIndex <= MT_GetMaxType(); iIndex++)
	{
		g_iAccessFlags[iIndex] = 0;
		g_iImmunityFlags[iIndex] = 0;
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_iHumanMode[iIndex] = 1;
		g_iJumpAbility[iIndex] = 0;
		g_iJumpEffect[iIndex] = 0;
		g_iJumpMessage[iIndex] = 0;
		g_flJumpChance[iIndex] = 33.3;
		g_flJumpDuration[iIndex] = 5.0;
		g_flJumpHeight[iIndex] = 300.0;
		g_iJumpHit[iIndex] = 0;
		g_iJumpHitMode[iIndex] = 0;
		g_flJumpInterval[iIndex] = 1.0;
		g_iJumpMode[iIndex] = 0;
		g_flJumpRange[iIndex] = 150.0;
		g_flJumpRangeChance[iIndex] = 15.0;
		g_flJumpSporadicChance[iIndex] = 33.3;
		g_flJumpSporadicHeight[iIndex] = 750.0;
	}
}

public void MT_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "jumpability", false) || StrEqual(subsection, "jump ability", false) || StrEqual(subsection, "jump_ability", false) || StrEqual(subsection, "jump", false))
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

	if (type > 0)
	{
		g_iHumanAbility[type] = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iJumpAbility[type] = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iJumpAbility[type], value, 0, 3);
		g_iJumpEffect[type] = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_iJumpEffect[type], value, 0, 7);
		g_iJumpMessage[type] = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iJumpMessage[type], value, 0, 7);
		g_flJumpChance[type] = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpChance", "Jump Chance", "Jump_Chance", "chance", g_flJumpChance[type], value, 0.0, 100.0);
		g_flJumpDuration[type] = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpDuration", "Jump Duration", "Jump_Duration", "duration", g_flJumpDuration[type], value, 0.1, 9999999999.0);
		g_flJumpHeight[type] = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpHeight", "Jump Height", "Jump_Height", "height", g_flJumpHeight[type], value, 0.1, 9999999999.0);
		g_iJumpHit[type] = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpHit", "Jump Hit", "Jump_Hit", "hit", g_iJumpHit[type], value, 0, 1);
		g_iJumpHitMode[type] = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpHitMode", "Jump Hit Mode", "Jump_Hit_Mode", "hitmode", g_iJumpHitMode[type], value, 0, 2);
		g_flJumpInterval[type] = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpInterval", "Jump Interval", "Jump_Interval", "interval", g_flJumpInterval[type], value, 0.1, 9999999999.0);
		g_iJumpMode[type] = iGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpMode", "Jump Mode", "Jump_Mode", "mode", g_iJumpMode[type], value, 0, 1);
		g_flJumpRange[type] = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpRange", "Jump Range", "Jump_Range", "range", g_flJumpRange[type], value, 1.0, 9999999999.0);
		g_flJumpRangeChance[type] = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpRangeChance", "Jump Range Chance", "Jump_Range_Chance", "rangechance", g_flJumpRangeChance[type], value, 0.0, 100.0);
		g_flJumpSporadicChance[type] = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpSporadicChance", "Jump Sporadic Chance", "Jump_Sporadic_Chance", "sporadicchance", g_flJumpSporadicChance[type], value, 0.0, 100.0);
		g_flJumpSporadicHeight[type] = flGetValue(subsection, "jumpability", "jump ability", "jump_ability", "jump", key, "JumpSporadicHeight", "Jump Sporadic Height", "Jump_Sporadic_Height", "sporadicheight", g_flJumpSporadicHeight[type], value, 0.1, 9999999999.0);

		if (StrEqual(subsection, "jumpability", false) || StrEqual(subsection, "jump ability", false) || StrEqual(subsection, "jump_ability", false) || StrEqual(subsection, "jump", false))
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
		if (MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vRemoveJump(iTank);
		}
	}
}

public void MT_OnAbilityActivated(int tank)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INGAME|MT_CHECK_FAKECLIENT) && ((!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[MT_GetTankType(tank)] == 0))
	{
		return;
	}

	if (MT_IsTankSupported(tank) && (!MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) || g_iHumanAbility[MT_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iJumpAbility[MT_GetTankType(tank)] > 0)
	{
		vJumpAbility(tank, true);
		vJumpAbility(tank, false);
	}
}

public void MT_OnButtonPressed(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if ((g_iJumpAbility[MT_GetTankType(tank)] == 2 || g_iJumpAbility[MT_GetTankType(tank)] == 3) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[MT_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bJump[tank] && !g_bJump3[tank])
						{
							vJumpAbility(tank, false);
						}
						else if (g_bJump[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman4");
						}
						else if (g_bJump3[tank])
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman5");
						}
					}
					case 1:
					{
						if (g_iJumpCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
						{
							if (!g_bJump[tank] && !g_bJump3[tank])
							{
								g_bJump[tank] = true;
								g_iJumpCount[tank]++;

								vJump2(tank);

								MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman", g_iJumpCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
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
			if ((g_iJumpAbility[MT_GetTankType(tank)] == 1 || g_iJumpAbility[MT_GetTankType(tank)] == 3) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (!g_bJump4[tank] && !g_bJump5[tank])
				{
					vJumpAbility(tank, true);
				}
				else if (g_bJump4[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman6");
				}
				else if (g_bJump5[tank])
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman7");
				}
			}
		}
	}
}

public void MT_OnButtonReleased(int tank, int button)
{
	if (MT_IsTankSupported(tank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & MT_MAIN_KEY == MT_MAIN_KEY)
		{
			if ((g_iJumpAbility[MT_GetTankType(tank)] == 2 || g_iJumpAbility[MT_GetTankType(tank)] == 3) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[MT_GetTankType(tank)] == 1 && g_bJump[tank] && !g_bJump3[tank])
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
	flVelocity[2] += g_flJumpHeight[MT_GetTankType(tank)];

	TeleportEntity(survivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
}

static void vJump2(int tank)
{
	if (!MT_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	switch (g_iJumpMode[MT_GetTankType(tank)])
	{
		case 0:
		{
			DataPack dpJump;
			CreateDataTimer(g_flJumpInterval[MT_GetTankType(tank)], tTimerJump, dpJump, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
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
			if (g_iJumpAbility[MT_GetTankType(tank)] == 1 || g_iJumpAbility[MT_GetTankType(tank)] == 3)
			{
				if (g_iJumpCount2[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
				{
					g_bJump6[tank] = false;
					g_bJump7[tank] = false;

					float flTankPos[3];
					GetClientAbsOrigin(tank, flTankPos);

					int iSurvivorCount;
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
						{
							float flSurvivorPos[3];
							GetClientAbsOrigin(iSurvivor, flSurvivorPos);

							float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
							if (flDistance <= g_flJumpRange[MT_GetTankType(tank)])
							{
								vJumpHit(iSurvivor, tank, g_flJumpRangeChance[MT_GetTankType(tank)], g_iJumpAbility[MT_GetTankType(tank)], MT_MESSAGE_RANGE, MT_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
						{
							MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman8");
						}
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
				{
					MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpAmmo");
				}
			}
		}
		case false:
		{
			if ((g_iJumpAbility[MT_GetTankType(tank)] == 2 || g_iJumpAbility[MT_GetTankType(tank)] == 3) && !g_bJump[tank])
			{
				if (g_iJumpCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
				{
					g_bJump[tank] = true;

					if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
					{
						g_iJumpCount[tank]++;

						MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman", g_iJumpCount[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
					}

					vJump2(tank);

					if (g_iJumpMessage[MT_GetTankType(tank)] & MT_MESSAGE_SPECIAL)
					{
						char sTankName[33];
						MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
						MT_PrintToChatAll("%s %t", MT_TAG2, "Jump3", sTankName);
					}
				}
				else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1)
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
		if (g_iJumpCount2[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bJump2[survivor])
			{
				g_bJump2[survivor] = true;
				g_iJumpOwner[survivor] = tank;

				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && (flags & MT_ATTACK_RANGE) && !g_bJump4[tank])
				{
					g_bJump4[tank] = true;
					g_iJumpCount2[tank]++;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman2", g_iJumpCount2[tank], g_iHumanAmmo[MT_GetTankType(tank)]);
				}

				DataPack dpJump3;
				CreateDataTimer(0.25, tTimerJump3, dpJump3, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpJump3.WriteCell(GetClientUserId(survivor));
				dpJump3.WriteCell(GetClientUserId(tank));
				dpJump3.WriteCell(MT_GetTankType(tank));
				dpJump3.WriteCell(messages);
				dpJump3.WriteCell(enabled);
				dpJump3.WriteFloat(GetEngineTime());

				vEffect(survivor, tank, g_iJumpEffect[MT_GetTankType(tank)], flags);

				if (g_iJumpMessage[MT_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					MT_GetTankName(tank, MT_GetTankType(tank), sTankName);
					MT_PrintToChatAll("%s %t", MT_TAG2, "Jump", sTankName, survivor);
				}
			}
			else if ((flags & MT_ATTACK_RANGE) && !g_bJump4[tank])
			{
				if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bJump6[tank])
				{
					g_bJump6[tank] = true;

					MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman3");
				}
			}
		}
		else if (MT_IsTankSupported(tank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(tank)] == 1 && !g_bJump7[tank])
		{
			g_bJump7[tank] = true;

			MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpAmmo2");
		}
	}
}

static void vRemoveJump(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE) && g_bJump2[iSurvivor] && g_iJumpOwner[iSurvivor] == tank)
		{
			g_bJump2[iSurvivor] = false;
			g_iJumpOwner[iSurvivor] = 0;
		}
	}

	vReset4(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, MT_CHECK_INGAME|MT_CHECK_KICKQUEUE))
		{
			vReset4(iPlayer);
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_bJump2[survivor] = false;
	g_iJumpOwner[survivor] = 0;

	if (g_iJumpMessage[MT_GetTankType(tank)] & messages)
	{
		MT_PrintToChatAll("%s %t", MT_TAG2, "Jump2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bJump[tank] = false;
	g_bJump3[tank] = true;

	MT_PrintToChat(tank, "%s %t", MT_TAG3, "JumpHuman9");

	if (g_iJumpCount[tank] < g_iHumanAmmo[MT_GetTankType(tank)] && g_iHumanAmmo[MT_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[MT_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bJump3[tank] = false;
	}
}

static void vReset4(int tank)
{
	g_bJump[tank] = false;
	g_bJump2[tank] = false;
	g_bJump3[tank] = false;
	g_bJump4[tank] = false;
	g_bJump5[tank] = false;
	g_bJump6[tank] = false;
	g_bJump7[tank] = false;
	g_iJumpCount[tank] = 0;
	g_iJumpCount2[tank] = 0;
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

static float flGetNearestSurvivor(int tank)
{
	float flDistance;
	if (bIsTank(tank))
	{
		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE) && !MT_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
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
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || (g_iJumpAbility[MT_GetTankType(iTank)] != 2 && g_iJumpAbility[MT_GetTankType(iTank)] != 3) || !g_bJump[iTank])
	{
		g_bJump[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(iTank)] == 1 && g_iHumanMode[MT_GetTankType(iTank)] == 0 && (flTime + g_flJumpDuration[MT_GetTankType(iTank)]) < GetEngineTime() && !g_bJump3[iTank])
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
	if (!MT_IsCorePluginEnabled() || !MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || (g_iJumpAbility[MT_GetTankType(iTank)] != 2 && g_iJumpAbility[MT_GetTankType(iTank)] != 3) || !g_bJump[iTank])
	{
		g_bJump[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(iTank)] == 1 && g_iHumanMode[MT_GetTankType(iTank)] == 0 && (flTime + g_flJumpDuration[MT_GetTankType(iTank)]) < GetEngineTime() && !g_bJump3[iTank])
	{
		vReset3(iTank);

		return Plugin_Stop;
	}

	if (GetRandomFloat(0.1, 100.0) > g_flJumpSporadicChance[MT_GetTankType(iTank)])
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

		flVelocity[2] += g_flJumpSporadicHeight[MT_GetTankType(iTank)];
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
		g_bJump2[iSurvivor] = false;
		g_iJumpOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!MT_IsTankSupported(iTank) || (!MT_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !MT_IsTypeEnabled(MT_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != MT_GetTankType(iTank) || MT_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, iTank) || !g_bJump2[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iJumpEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if ((iJumpEnabled != 1 && iJumpEnabled != 3) || (flTime + g_flJumpDuration[MT_GetTankType(iTank)] < GetEngineTime()))
	{
		g_bJump4[iTank] = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (MT_IsTankSupported(iTank, MT_CHECK_FAKECLIENT) && g_iHumanAbility[MT_GetTankType(iTank)] == 1 && (iMessage & MT_MESSAGE_RANGE) && !g_bJump5[iTank])
		{
			g_bJump5[iTank] = true;

			MT_PrintToChat(iTank, "%s %t", MT_TAG3, "JumpHuman10");

			if (g_iJumpCount2[iTank] < g_iHumanAmmo[MT_GetTankType(iTank)] && g_iHumanAmmo[MT_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[MT_GetTankType(iTank)], tTimerResetCooldown2, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bJump5[iTank] = false;
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
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bJump3[iTank])
	{
		g_bJump3[iTank] = false;

		return Plugin_Stop;
	}

	g_bJump3[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "JumpHuman11");

	return Plugin_Continue;
}

public Action tTimerResetCooldown2(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!MT_IsTankSupported(iTank, MT_CHECK_INDEX|MT_CHECK_INGAME|MT_CHECK_ALIVE|MT_CHECK_KICKQUEUE|MT_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bJump5[iTank])
	{
		g_bJump5[iTank] = false;

		return Plugin_Stop;
	}

	g_bJump5[iTank] = false;

	MT_PrintToChat(iTank, "%s %t", MT_TAG3, "JumpHuman12");

	return Plugin_Continue;
}