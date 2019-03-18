/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
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
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Jump Ability",
	author = ST_AUTHOR,
	description = "The Super Tank jumps periodically or sporadically and makes survivors jump uncontrollably.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Jump Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_JUMP "Jump Ability"

bool g_bCloneInstalled, g_bJump[MAXPLAYERS + 1], g_bJump2[MAXPLAYERS + 1], g_bJump3[MAXPLAYERS + 1], g_bJump4[MAXPLAYERS + 1], g_bJump5[MAXPLAYERS + 1], g_bJump6[MAXPLAYERS + 1], g_bJump7[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flJumpChance[ST_MAXTYPES + 1], g_flJumpDuration[ST_MAXTYPES + 1], g_flJumpHeight[ST_MAXTYPES + 1], g_flJumpInterval[ST_MAXTYPES + 1], g_flJumpRange[ST_MAXTYPES + 1], g_flJumpRangeChance[ST_MAXTYPES + 1], g_flJumpSporadicChance[ST_MAXTYPES + 1], g_flJumpSporadicHeight[ST_MAXTYPES + 1];

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iImmunityFlags[ST_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1], g_iJumpAbility[ST_MAXTYPES + 1], g_iJumpCount[MAXPLAYERS + 1], g_iJumpCount2[MAXPLAYERS + 1], g_iJumpEffect[ST_MAXTYPES + 1], g_iJumpHit[ST_MAXTYPES + 1], g_iJumpHitMode[ST_MAXTYPES + 1], g_iJumpMessage[ST_MAXTYPES + 1], g_iJumpMode[ST_MAXTYPES + 1], g_iJumpOwner[MAXPLAYERS + 1];

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("st_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_jump", cmdJumpInfo, "View information about the Jump ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
	if (!ST_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Super Tanks++\x01 is disabled.", ST_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", ST_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", ST_TAG2, "Vote in Progress");
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iJumpAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iJumpCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo2", g_iHumanAmmo[ST_GetTankType(param1)] - g_iJumpCount2[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				}
				case 2:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				}
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanMode[ST_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "JumpDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flJumpDuration[ST_GetTankType(param1)]);
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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

public void ST_OnDisplayMenu(Menu menu)
{
	menu.AddItem(ST_MENU_JUMP, ST_MENU_JUMP);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_JUMP, false))
	{
		vJumpMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iJumpHitMode[ST_GetTankType(attacker)] == 0 || g_iJumpHitMode[ST_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if ((!ST_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || ST_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vJumpHit(victim, attacker, g_flJumpChance[ST_GetTankType(attacker)], g_iJumpHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iJumpHitMode[ST_GetTankType(victim)] == 0 || g_iJumpHitMode[ST_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if ((!ST_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || ST_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vJumpHit(attacker, victim, g_flJumpChance[ST_GetTankType(victim)], g_iJumpHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
			}
		}
	}

	return Plugin_Continue;
}

public void ST_OnConfigsLoad()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_iAccessFlags2[iPlayer] = 0;
			g_iImmunityFlags2[iPlayer] = 0;
		}
	}

	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
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

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
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
		ST_FindAbility(type, 31, bHasAbilities(subsection, "jumpability", "jump ability", "jump_ability", "jump"));
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

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveJump(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INGAME|ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iJumpAbility[ST_GetTankType(tank)] > 0)
	{
		vJumpAbility(tank, true);
		vJumpAbility(tank, false);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
		{
			return;
		}

		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if ((g_iJumpAbility[ST_GetTankType(tank)] == 2 || g_iJumpAbility[ST_GetTankType(tank)] == 3) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[ST_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bJump[tank] && !g_bJump3[tank])
						{
							vJumpAbility(tank, false);
						}
						else if (g_bJump[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman4");
						}
						else if (g_bJump3[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman5");
						}
					}
					case 1:
					{
						if (g_iJumpCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
						{
							if (!g_bJump[tank] && !g_bJump3[tank])
							{
								g_bJump[tank] = true;
								g_iJumpCount[tank]++;

								vJump2(tank);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman", g_iJumpCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpAmmo");
						}
					}
				}
			}
		}

		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if ((g_iJumpAbility[ST_GetTankType(tank)] == 1 || g_iJumpAbility[ST_GetTankType(tank)] == 3) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bJump4[tank] && !g_bJump5[tank])
				{
					vJumpAbility(tank, true);
				}
				else if (g_bJump4[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman6");
				}
				else if (g_bJump5[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman7");
				}
			}
		}
	}
}

public void ST_OnButtonReleased(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if ((g_iJumpAbility[ST_GetTankType(tank)] == 2 || g_iJumpAbility[ST_GetTankType(tank)] == 3) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[ST_GetTankType(tank)] == 1 && g_bJump[tank] && !g_bJump3[tank])
				{
					vReset3(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveJump(tank);
}

static void vJump(int survivor, int tank)
{
	if ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || ST_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	float flVelocity[3];
	GetEntPropVector(survivor, Prop_Data, "m_vecVelocity", flVelocity);
	flVelocity[2] += g_flJumpHeight[ST_GetTankType(tank)];

	TeleportEntity(survivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
}

static void vJump2(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	switch (g_iJumpMode[ST_GetTankType(tank)])
	{
		case 0:
		{
			DataPack dpJump;
			CreateDataTimer(g_flJumpInterval[ST_GetTankType(tank)], tTimerJump, dpJump, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpJump.WriteCell(GetClientUserId(tank));
			dpJump.WriteCell(ST_GetTankType(tank));
			dpJump.WriteFloat(GetEngineTime());
		}
		case 1:
		{
			DataPack dpJump2;
			CreateDataTimer(1.0, tTimerJump2, dpJump2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpJump2.WriteCell(GetClientUserId(tank));
			dpJump2.WriteCell(ST_GetTankType(tank));
			dpJump2.WriteFloat(GetEngineTime());
		}
	}
}

static void vJumpAbility(int tank, bool main)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_iJumpAbility[ST_GetTankType(tank)] == 1 || g_iJumpAbility[ST_GetTankType(tank)] == 3)
			{
				if (g_iJumpCount2[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
				{
					g_bJump6[tank] = false;
					g_bJump7[tank] = false;

					float flTankPos[3];
					GetClientAbsOrigin(tank, flTankPos);

					int iSurvivorCount;
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && !ST_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
						{
							float flSurvivorPos[3];
							GetClientAbsOrigin(iSurvivor, flSurvivorPos);

							float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
							if (flDistance <= g_flJumpRange[ST_GetTankType(tank)])
							{
								vJumpHit(iSurvivor, tank, g_flJumpRangeChance[ST_GetTankType(tank)], g_iJumpAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman8");
						}
					}
				}
				else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpAmmo");
				}
			}
		}
		case false:
		{
			if ((g_iJumpAbility[ST_GetTankType(tank)] == 2 || g_iJumpAbility[ST_GetTankType(tank)] == 3) && !g_bJump[tank])
			{
				if (g_iJumpCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
				{
					g_bJump[tank] = true;

					if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
					{
						g_iJumpCount[tank]++;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman", g_iJumpCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
					}

					vJump2(tank);

					if (g_iJumpMessage[ST_GetTankType(tank)] & ST_MESSAGE_SPECIAL)
					{
						char sTankName[33];
						ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Jump3", sTankName);
					}
				}
				else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpAmmo");
				}
			}
		}
	}
}

static void vJumpHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || ST_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (g_iJumpCount2[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bJump2[survivor])
			{
				g_bJump2[survivor] = true;
				g_iJumpOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bJump4[tank])
				{
					g_bJump4[tank] = true;
					g_iJumpCount2[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman2", g_iJumpCount2[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				DataPack dpJump3;
				CreateDataTimer(0.25, tTimerJump3, dpJump3, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpJump3.WriteCell(GetClientUserId(survivor));
				dpJump3.WriteCell(GetClientUserId(tank));
				dpJump3.WriteCell(ST_GetTankType(tank));
				dpJump3.WriteCell(messages);
				dpJump3.WriteCell(enabled);
				dpJump3.WriteFloat(GetEngineTime());

				vEffect(survivor, tank, g_iJumpEffect[ST_GetTankType(tank)], flags);

				if (g_iJumpMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Jump", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bJump4[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bJump6[tank])
				{
					g_bJump6[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman3");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bJump7[tank])
		{
			g_bJump7[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpAmmo2");
		}
	}
}

static void vRemoveJump(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && g_bJump2[iSurvivor] && g_iJumpOwner[iSurvivor] == tank)
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
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vReset4(iPlayer);
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_bJump2[survivor] = false;
	g_iJumpOwner[survivor] = 0;

	if (g_iJumpMessage[ST_GetTankType(tank)] & messages)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Jump2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bJump[tank] = false;
	g_bJump3[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman9");

	if (g_iJumpCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
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
	if (!bIsValidClient(admin, ST_CHECK_FAKECLIENT))
	{
		return true;
	}

	int iAbilityFlags = g_iAccessFlags[ST_GetTankType(admin)];
	if (iAbilityFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iAbilityFlags))
		{
			return false;
		}
	}

	int iTypeFlags = ST_GetAccessFlags(2, ST_GetTankType(admin));
	if (iTypeFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iTypeFlags))
		{
			return false;
		}
	}

	int iGlobalFlags = ST_GetAccessFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iAccessFlags2[admin] != 0 && !(g_iAccessFlags2[admin] & iGlobalFlags))
		{
			return false;
		}
	}

	int iClientTypeFlags = ST_GetAccessFlags(4, ST_GetTankType(admin), admin);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0 && !(iClientTypeFlags & iAbilityFlags))
		{
			return false;
		}
	}

	int iClientGlobalFlags = ST_GetAccessFlags(3, 0, admin);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0 && !(iClientGlobalFlags & iAbilityFlags))
		{
			return false;
		}
	}

	return true;
}

static bool bIsAdminImmune(int survivor, int tank)
{
	if (!bIsValidClient(survivor, ST_CHECK_FAKECLIENT))
	{
		return false;
	}

	int iAbilityFlags = g_iImmunityFlags[ST_GetTankType(survivor)];
	if (iAbilityFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iAbilityFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iTypeFlags = ST_GetImmunityFlags(2, ST_GetTankType(survivor));
	if (iTypeFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iTypeFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iGlobalFlags = ST_GetImmunityFlags(1);
	if (iGlobalFlags != 0)
	{
		if (g_iImmunityFlags2[survivor] != 0 && (g_iImmunityFlags2[survivor] & iGlobalFlags))
		{
			return ((g_iImmunityFlags2[tank] & iAbilityFlags) && g_iImmunityFlags2[survivor] <= g_iImmunityFlags2[tank]) ? false : true;
		}
	}

	int iClientTypeFlags = ST_GetImmunityFlags(4, ST_GetTankType(tank), survivor),
		iClientTypeFlags2 = ST_GetImmunityFlags(4, ST_GetTankType(tank), tank);
	if (iClientTypeFlags != 0)
	{
		if (iAbilityFlags != 0 && (iClientTypeFlags & iAbilityFlags))
		{
			return ((iClientTypeFlags2 & iAbilityFlags) && iClientTypeFlags <= iClientTypeFlags2) ? false : true;
		}
	}

	int iClientGlobalFlags = ST_GetImmunityFlags(3, 0, survivor),
		iClientGlobalFlags2 = ST_GetImmunityFlags(3, 0, tank);
	if (iClientGlobalFlags != 0)
	{
		if (iAbilityFlags != 0 && (iClientGlobalFlags & iAbilityFlags))
		{
			return ((iClientGlobalFlags2 & iAbilityFlags) && iClientGlobalFlags <= iClientGlobalFlags2) ? false : true;
		}
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
			if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && !ST_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
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
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || (g_iJumpAbility[ST_GetTankType(iTank)] != 2 && g_iJumpAbility[ST_GetTankType(iTank)] != 3) || !g_bJump[iTank])
	{
		g_bJump[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && g_iHumanMode[ST_GetTankType(iTank)] == 0 && (flTime + g_flJumpDuration[ST_GetTankType(iTank)]) < GetEngineTime() && !g_bJump3[iTank])
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
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || (g_iJumpAbility[ST_GetTankType(iTank)] != 2 && g_iJumpAbility[ST_GetTankType(iTank)] != 3) || !g_bJump[iTank])
	{
		g_bJump[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && g_iHumanMode[ST_GetTankType(iTank)] == 0 && (flTime + g_flJumpDuration[ST_GetTankType(iTank)]) < GetEngineTime() && !g_bJump3[iTank])
	{
		vReset3(iTank);

		return Plugin_Stop;
	}

	if (GetRandomFloat(0.1, 100.0) > g_flJumpSporadicChance[ST_GetTankType(iTank)])
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

		flVelocity[2] += g_flJumpSporadicHeight[ST_GetTankType(iTank)];
		TeleportEntity(iTank, NULL_VECTOR, NULL_VECTOR, flVelocity);
	}

	return Plugin_Continue;
}

public Action tTimerJump3(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bJump2[iSurvivor] = false;
		g_iJumpOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || ST_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, iTank) || !g_bJump2[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iJumpEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if ((iJumpEnabled != 1 && iJumpEnabled != 3) || (flTime + g_flJumpDuration[ST_GetTankType(iTank)] < GetEngineTime()))
	{
		g_bJump4[iTank] = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bJump5[iTank])
		{
			g_bJump5[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "JumpHuman10");

			if (g_iJumpCount2[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown2, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
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
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bJump3[iTank])
	{
		g_bJump3[iTank] = false;

		return Plugin_Stop;
	}

	g_bJump3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "JumpHuman11");

	return Plugin_Continue;
}

public Action tTimerResetCooldown2(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bJump5[iTank])
	{
		g_bJump5[iTank] = false;

		return Plugin_Stop;
	}

	g_bJump5[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "JumpHuman12");

	return Plugin_Continue;
}