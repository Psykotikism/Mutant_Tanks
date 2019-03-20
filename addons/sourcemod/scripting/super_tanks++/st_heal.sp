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
	name = "[ST++] Heal Ability",
	author = ST_AUTHOR,
	description = "The Super Tank gains health from other nearby infected and sets survivors to temporary health who will die when they reach 0 HP.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Heal Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define SOUND_HEARTBEAT	 "player/heartbeatloop.wav"

#define ST_MENU_HEAL "Heal Ability"

bool g_bCloneInstalled, g_bHeal[MAXPLAYERS + 1], g_bHeal2[MAXPLAYERS + 1], g_bHeal3[MAXPLAYERS + 1], g_bHeal4[MAXPLAYERS + 1], g_bHeal5[MAXPLAYERS + 1], g_bHeal6[MAXPLAYERS + 1];

ConVar g_cvSTMaxIncapCount;

float g_flHealAbsorbRange[ST_MAXTYPES + 1], g_flHealBuffer[ST_MAXTYPES + 1], g_flHealChance[ST_MAXTYPES + 1], g_flHealInterval[ST_MAXTYPES + 1], g_flHealRange[ST_MAXTYPES + 1], g_flHealRangeChance[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanDuration[ST_MAXTYPES + 1];

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHealAbility[ST_MAXTYPES + 1], g_iHealCommon[ST_MAXTYPES + 1], g_iHealCount[MAXPLAYERS + 1], g_iHealCount2[MAXPLAYERS + 1], g_iHealEffect[ST_MAXTYPES + 1], g_iHealHit[ST_MAXTYPES + 1], g_iHealHitMode[ST_MAXTYPES + 1], g_iHealMessage[ST_MAXTYPES + 1], g_iHealSpecial[ST_MAXTYPES + 1], g_iHealTank[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iImmunityFlags[ST_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_heal", cmdHealInfo, "View information about the Heal ability.");

	g_cvSTMaxIncapCount = FindConVar("survivor_max_incapacitated_count");

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
	PrecacheSound(SOUND_HEARTBEAT, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveHeal(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdHealInfo(int client, int args)
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
		case false: vHealMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vHealMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iHealMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Heal Ability Information");
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

public int iHealMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHealAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iHealCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo2", g_iHumanAmmo[ST_GetTankType(param1)] - g_iHealCount2[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				}
				case 2:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				}
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanMode[ST_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "HealDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flHumanDuration[ST_GetTankType(param1)]);
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vHealMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "HealMenu", param1);
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
	menu.AddItem(ST_MENU_HEAL, ST_MENU_HEAL);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_HEAL, false))
	{
		vHealMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iHealHitMode[ST_GetTankType(attacker)] == 0 || g_iHealHitMode[ST_GetTankType(attacker)] == 1) && bIsSurvivor(victim))
		{
			if ((!ST_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || ST_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHealHit(victim, attacker, g_flHealChance[ST_GetTankType(attacker)], g_iHealHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iHealHitMode[ST_GetTankType(victim)] == 0 || g_iHealHitMode[ST_GetTankType(victim)] == 2) && bIsSurvivor(attacker))
		{
			if ((!ST_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || ST_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vHealHit(attacker, victim, g_flHealChance[ST_GetTankType(victim)], g_iHealHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_flHumanDuration[iIndex] = 5.0;
		g_iHumanMode[iIndex] = 1;
		g_iHealAbility[iIndex] = 0;
		g_iHealEffect[iIndex] = 0;
		g_iHealMessage[iIndex] = 0;
		g_flHealAbsorbRange[iIndex] = 500.0;
		g_flHealBuffer[iIndex] = 25.0;
		g_flHealChance[iIndex] = 33.3;
		g_iHealHit[iIndex] = 0;
		g_iHealHitMode[iIndex] = 0;
		g_flHealInterval[iIndex] = 5.0;
		g_flHealRange[iIndex] = 150.0;
		g_flHealRangeChance[iIndex] = 15.0;
		g_iHealCommon[iIndex] = 50;
		g_iHealSpecial[iIndex] = 100;
		g_iHealTank[iIndex] = 500;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "healability", false) || StrEqual(subsection, "heal ability", false) || StrEqual(subsection, "heal_ability", false) || StrEqual(subsection, "heal", false))
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
		ST_FindAbility(type, 23, bHasAbilities(subsection, "healability", "heal ability", "heal_ability", "heal"));
		g_iHumanAbility[type] = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_flHumanDuration[type] = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HumanDuration", "Human Duration", "Human_Duration", "hduration", g_flHumanDuration[type], value, 0.1, 9999999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iHealAbility[type] = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iHealAbility[type], value, 0, 3);
		g_iHealEffect[type] = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_iHealEffect[type], value, 0, 7);
		g_iHealMessage[type] = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iHealMessage[type], value, 0, 7);
		g_flHealAbsorbRange[type] = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealAbsorbRange", "Heal Absorb Range", "Heal_Absorb_Range", "absorbrange", g_flHealAbsorbRange[type], value, 1.0, 9999999999.0);
		g_flHealBuffer[type] = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealBuffer", "Heal Buffer", "Heal_Buffer", "buffer", g_flHealBuffer[type], value, 1.0, float(ST_MAXHEALTH));
		g_flHealChance[type] = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealChance", "Heal Chance", "Heal_Chance", "chance", g_flHealChance[type], value, 0.0, 100.0);
		g_iHealHit[type] = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealHit", "Heal Hit", "Heal_Hit", "hit", g_iHealHit[type], value, 0, 1);
		g_iHealHitMode[type] = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealHitMode", "Heal Hit Mode", "Heal_Hit_Mode", "hitmode", g_iHealHitMode[type], value, 0, 2);
		g_flHealInterval[type] = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealInterval", "Heal Interval", "Heal_Interval", "interval", g_flHealInterval[type], value, 0.1, 9999999999.0);
		g_flHealRange[type] = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealRange", "Heal Range", "Heal_Range", "range", g_flHealRange[type], value, 1.0, 9999999999.0);
		g_flHealRangeChance[type] = flGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealRangeChance", "Heal Range Chance", "Heal_Range_Chance", "rangechance", g_flHealRangeChance[type], value, 0.0, 100.0);
		g_iHealCommon[type] = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealthFromCommons", "Health From Commons", "Health_From_Commons", "commons", g_iHealCommon[type], value, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
		g_iHealSpecial[type] = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealthFromSpecials", "Health From Specials", "Health_From_Specials", "specials", g_iHealSpecial[type], value, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
		g_iHealTank[type] = iGetValue(subsection, "healability", "heal ability", "heal_ability", "heal", key, "HealthFromTanks", "Health From Tanks", "Health_From_Tanks", "tanks", g_iHealTank[type], value, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);

		if (StrEqual(subsection, "healability", false) || StrEqual(subsection, "heal ability", false) || StrEqual(subsection, "heal_ability", false) || StrEqual(subsection, "heal", false))
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

public void ST_OnHookEvent(bool mode)
{
	switch (mode)
	{
		case true: HookEvent("heal_success", ST_OnEventFired);
		case false: UnhookEvent("heal_success", ST_OnEventFired);
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "heal_success"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
		if (bIsSurvivor(iSurvivor))
		{
			g_bHeal4[iSurvivor] = false;

			SetEntProp(iSurvivor, Prop_Send, "m_currentReviveCount", 0);
			SetEntProp(iSurvivor, Prop_Send, "m_isGoingToDie", 0);

			StopSound(iSurvivor, SNDCHAN_AUTO, SOUND_HEARTBEAT);
		}
	}
	else if (StrEqual(name, "player_death"))
	{
		int iUserId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iUserId);
		if (bIsSurvivor(iPlayer))
		{
			StopSound(iPlayer, SNDCHAN_AUTO, SOUND_HEARTBEAT);
		}
		else if (ST_IsTankSupported(iPlayer, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveHeal(iPlayer);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INGAME|ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iHealAbility[ST_GetTankType(tank)] > 0)
	{
		vHealAbility(tank, true);
		vHealAbility(tank, false);
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
			if ((g_iHealAbility[ST_GetTankType(tank)] == 2 || g_iHealAbility[ST_GetTankType(tank)] == 3) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[ST_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bHeal[tank] && !g_bHeal2[tank])
						{
							vHealAbility(tank, false);
						}
						else if (g_bHeal[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealHuman4");
						}
						else if (g_bHeal2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealHuman5");
						}
					}
					case 1:
					{
						if (g_iHealCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
						{
							if (!g_bHeal[tank] && !g_bHeal2[tank])
							{
								g_bHeal[tank] = true;
								g_iHealCount[tank]++;

								vHeal(tank);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealHuman", g_iHealCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealAmmo");
						}
					}
				}
			}
		}

		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if ((g_iHealAbility[ST_GetTankType(tank)] == 1 || g_iHealAbility[ST_GetTankType(tank)] == 3) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_bHeal3[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealHuman6");
					case false: vHealAbility(tank, true);
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
			if ((g_iHealAbility[ST_GetTankType(tank)] == 2 || g_iHealAbility[ST_GetTankType(tank)] == 3) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[ST_GetTankType(tank)] == 1 && g_bHeal[tank] && !g_bHeal2[tank])
				{
					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveHeal(tank);
}

static void vHeal(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	DataPack dpHeal;
	CreateDataTimer(g_flHealInterval[ST_GetTankType(tank)], tTimerHeal, dpHeal, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpHeal.WriteCell(GetClientUserId(tank));
	dpHeal.WriteCell(ST_GetTankType(tank));
	dpHeal.WriteFloat(GetEngineTime());
}

static void vHealAbility(int tank, bool main)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	switch (main)
	{
		case true:
		{
			if (g_iHealAbility[ST_GetTankType(tank)] == 1 || g_iHealAbility[ST_GetTankType(tank)] == 3)
			{
				if (g_iHealCount2[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
				{
					g_bHeal5[tank] = false;
					g_bHeal6[tank] = false;

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
							if (flDistance <= g_flHealRange[ST_GetTankType(tank)])
							{
								vHealHit(iSurvivor, tank, g_flHealRangeChance[ST_GetTankType(tank)], g_iHealAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealHuman7");
						}
					}
				}
				else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealAmmo2");
				}
			}
		}
		case false:
		{
			if ((g_iHealAbility[ST_GetTankType(tank)] == 2 || g_iHealAbility[ST_GetTankType(tank)] == 3) && !g_bHeal[tank])
			{
				if (g_iHealCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
				{
					g_bHeal[tank] = true;

					if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
					{
						g_iHealCount[tank]++;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealHuman", g_iHealCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
					}

					vHeal(tank);

					if (g_iHealMessage[ST_GetTankType(tank)] & ST_MESSAGE_SPECIAL)
					{
						char sTankName[33];
						ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Heal2", sTankName);
					}
				}
				else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealAmmo");
				}
			}
		}
	}
}

static void vHealHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || ST_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (g_iHealCount2[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bHeal4[survivor])
			{
				int iHealth = GetClientHealth(survivor);
				if (iHealth > 0 && !bIsPlayerIncapacitated(survivor))
				{
					g_bHeal4[survivor] = true;

					if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bHeal3[tank])
					{
						g_bHeal3[tank] = true;
						g_iHealCount2[tank]++;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealHuman2", g_iHealCount2[tank], g_iHumanAmmo[ST_GetTankType(tank)]);

						if (g_iHealCount2[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
						{
							CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown2, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
						}
						else
						{
							g_bHeal3[tank] = false;
						}
					}

					SetEntityHealth(survivor, 1);
					SetEntPropFloat(survivor, Prop_Send, "m_healthBufferTime", GetGameTime());
					SetEntPropFloat(survivor, Prop_Send, "m_healthBuffer", g_flHealBuffer[ST_GetTankType(tank)]);
					SetEntProp(survivor, Prop_Send, "m_currentReviveCount", g_cvSTMaxIncapCount.IntValue);

					vEffect(survivor, tank, g_iHealEffect[ST_GetTankType(tank)], flags);

					if (g_iHealMessage[ST_GetTankType(tank)] & messages)
					{
						char sTankName[33];
						ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Heal", sTankName, survivor);
					}
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bHeal3[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bHeal5[tank])
				{
					g_bHeal5[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealHuman3");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bHeal6[tank])
		{
			g_bHeal6[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealAmmo2");
		}
	}
}

static void vRemoveHeal(int tank)
{
	g_bHeal[tank] = false;
	g_bHeal2[tank] = false;
	g_bHeal3[tank] = false;
	g_bHeal4[tank] = false;
	g_bHeal5[tank] = false;
	g_bHeal6[tank] = false;
	g_iHealCount[tank] = 0;
	g_iHealCount2[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveHeal(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bHeal[tank] = false;
	g_bHeal2[tank] = true;

	SetEntProp(tank, Prop_Send, "m_bFlashing", 0);

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealHuman8");

	if (g_iHealCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bHeal2[tank] = false;
	}
}

static void vResetGlow(int tank)
{
	switch (ST_IsGlowEnabled(tank))
	{
		case true:
		{
			int iGlowColor[4];
			ST_GetTankColors(tank, 2, iGlowColor[0], iGlowColor[1], iGlowColor[2], iGlowColor[3]);
			SetEntProp(tank, Prop_Send, "m_iGlowType", 3);
			SetEntProp(tank, Prop_Send, "m_glowColorOverride", iGetRGBColor(iGlowColor[0], iGlowColor[1], iGlowColor[2]));
			SetEntProp(tank, Prop_Send, "m_bFlashing", 0);
		}
		case false:
		{
			SetEntProp(tank, Prop_Send, "m_iGlowType", 0);
			SetEntProp(tank, Prop_Send, "m_glowColorOverride", 0);
			SetEntProp(tank, Prop_Send, "m_bFlashing", 0);
		}
	}
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

public Action tTimerHeal(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || (g_iHealAbility[ST_GetTankType(iTank)] != 2 && g_iHealAbility[ST_GetTankType(iTank)] != 3) || !g_bHeal[iTank])
	{
		g_bHeal[iTank] = false;

		vResetGlow(iTank);

		if (g_iHealMessage[ST_GetTankType(iTank)] & ST_MESSAGE_SPECIAL)
		{
			char sTankName[33];
			ST_GetTankName(iTank, ST_GetTankType(iTank), sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Heal3", sTankName);
		}

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && (ST_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && g_iHumanMode[ST_GetTankType(iTank)] == 0 && (flTime + g_flHumanDuration[ST_GetTankType(iTank)]) < GetEngineTime() && !g_bHeal2[iTank])
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	int iHealType, iSpecial = -1;

	while ((iSpecial = FindEntityByClassname(iSpecial, "infected")) != INVALID_ENT_REFERENCE)
	{
		float flTankPos[3], flInfectedPos[3];
		GetClientAbsOrigin(iTank, flTankPos);
		GetEntPropVector(iSpecial, Prop_Send, "m_vecOrigin", flInfectedPos);

		float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
		if (flDistance <= g_flHealAbsorbRange[ST_GetTankType(iTank)])
		{
			int iHealth = GetClientHealth(iTank),
				iCommonHealth = iHealth + g_iHealCommon[ST_GetTankType(iTank)],
				iExtraHealth = (iCommonHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iCommonHealth,
				iExtraHealth2 = (iCommonHealth < iHealth) ? 1 : iCommonHealth,
				iRealHealth = (iCommonHealth >= 0) ? iExtraHealth : iExtraHealth2;
			if (iHealth > 500)
			{
				SetEntityHealth(iTank, iRealHealth);

				if (bIsValidGame())
				{
					SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
					SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 185, 0));
					SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);
				}

				iHealType = 1;
			}
		}
	}

	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (bIsSpecialInfected(iInfected, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
		{
			float flTankPos[3], flInfectedPos[3];
			GetClientAbsOrigin(iTank, flTankPos);
			GetClientAbsOrigin(iInfected, flInfectedPos);

			float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
			if (flDistance <= g_flHealAbsorbRange[ST_GetTankType(iTank)])
			{
				int iHealth = GetClientHealth(iTank),
					iSpecialHealth = iHealth + g_iHealSpecial[ST_GetTankType(iTank)],
					iExtraHealth = (iSpecialHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iSpecialHealth,
					iExtraHealth2 = (iSpecialHealth < iHealth) ? 1 : iSpecialHealth,
					iRealHealth = (iSpecialHealth >= 0) ? iExtraHealth : iExtraHealth2;
				if (iHealth > 500)
				{
					SetEntityHealth(iTank, iRealHealth);

					if (iHealType < 2)
					{
						if (bIsValidGame())
						{
							SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
							SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 220, 0));
							SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);
						}

						iHealType = 1;
					}
				}
			}
		}
		else if (ST_IsTankSupported(iInfected) && iInfected != iTank)
		{
			float flTankPos[3], flInfectedPos[3];
			GetClientAbsOrigin(iTank, flTankPos);
			GetClientAbsOrigin(iInfected, flInfectedPos);

			float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
			if (flDistance <= g_flHealAbsorbRange[ST_GetTankType(iTank)])
			{
				int iHealth = GetClientHealth(iTank),
					iTankHealth = iHealth + g_iHealTank[ST_GetTankType(iTank)],
					iExtraHealth = (iTankHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iTankHealth,
					iExtraHealth2 = (iTankHealth < iHealth) ? 1 : iTankHealth,
					iRealHealth = (iTankHealth >= 0) ? iExtraHealth : iExtraHealth2;
				if (iHealth > 500)
				{
					SetEntityHealth(iTank, iRealHealth);

					if (bIsValidGame())
					{
						SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
						SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 255, 0));
						SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);
					}

					iHealType = 2;
				}
			}
		}
	}

	if (iHealType == 0 && bIsValidGame())
	{
		vResetGlow(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bHeal2[iTank])
	{
		g_bHeal2[iTank] = false;

		return Plugin_Stop;
	}

	g_bHeal2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "HealHuman9");

	return Plugin_Continue;
}

public Action tTimerResetCooldown2(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bHeal3[iTank])
	{
		g_bHeal3[iTank] = false;

		return Plugin_Stop;
	}

	g_bHeal3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "HealHuman10");

	return Plugin_Continue;
}