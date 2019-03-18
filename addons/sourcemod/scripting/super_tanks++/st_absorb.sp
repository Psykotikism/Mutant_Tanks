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
	name = "[ST++] Absorb Ability",
	author = ST_AUTHOR,
	description = "The Super Tank absorbs most of the damage it receives.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Absorb Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_ABSORB "Absorb Ability"

bool g_bAbsorb[MAXPLAYERS + 1], g_bAbsorb2[MAXPLAYERS + 1], g_bCloneInstalled;

float g_flAbsorbBulletDivisor[ST_MAXTYPES + 1], g_flAbsorbChance[ST_MAXTYPES + 1], g_flAbsorbDuration[ST_MAXTYPES + 1], g_flAbsorbExplosiveDivisor[ST_MAXTYPES + 1], g_flAbsorbFireDivisor[ST_MAXTYPES + 1], g_flAbsorbMeleeDivisor[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1];

int g_iAbsorbAbility[ST_MAXTYPES + 1], g_iAbsorbCount[MAXPLAYERS + 1], g_iAbsorbMessage[ST_MAXTYPES + 1], g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_absorb", cmdAbsorbInfo, "View information about the Absorb ability.");

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

	vRemoveAbsorb(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdAbsorbInfo(int client, int args)
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
		case false: vAbsorbMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vAbsorbMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iAbsorbMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Absorb Ability Information");
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

public int iAbsorbMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iAbsorbAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iAbsorbCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanMode[ST_GetTankType(param1)] == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbsorbDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flAbsorbDuration[ST_GetTankType(param1)]);
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vAbsorbMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "AbsorbMenu", param1);
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
	menu.AddItem(ST_MENU_ABSORB, ST_MENU_ABSORB);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_ABSORB, false))
	{
		vAbsorbMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && g_bAbsorb[victim])
		{
			if (!bHasAdminAccess(victim) && !ST_HasAdminAccess(victim))
			{
				return Plugin_Continue;
			}

			if (damagetype & DMG_BULLET)
			{
				damage /= g_flAbsorbBulletDivisor[ST_GetTankType(victim)];
			}
			else if (damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA)
			{
				damage /= g_flAbsorbExplosiveDivisor[ST_GetTankType(victim)];
			}
			else if (damagetype & DMG_BURN)
			{
				damage /= g_flAbsorbFireDivisor[ST_GetTankType(victim)];
			}
			else if (damagetype & DMG_SLASH || damagetype & DMG_CLUB)
			{
				damage /= g_flAbsorbMeleeDivisor[ST_GetTankType(victim)];
			}

			return Plugin_Changed;
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
		}
	}

	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iAccessFlags[iIndex] = 0;
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_iHumanMode[iIndex] = 1;
		g_iAbsorbAbility[iIndex] = 0;
		g_iAbsorbMessage[iIndex] = 0;
		g_flAbsorbBulletDivisor[iIndex] = 20.0;
		g_flAbsorbChance[iIndex] = 33.3;
		g_flAbsorbDuration[iIndex] = 5.0;
		g_flAbsorbExplosiveDivisor[iIndex] = 20.0;
		g_flAbsorbFireDivisor[iIndex] = 200.0;
		g_flAbsorbMeleeDivisor[iIndex] = 200.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "absorbability", false) || StrEqual(subsection, "absorb ability", false) || StrEqual(subsection, "absorb_ability", false) || StrEqual(subsection, "absorb", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags2[admin] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags2[admin];
			}
		}
	}

	if (type > 0)
	{
		ST_FindAbility(type, 0, bHasAbilities(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb"));
		g_iHumanAbility[type] = iGetValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iHumanMode[type] = iGetValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "HumanMode", "Human Mode", "Human_Mode", "hmode", g_iHumanMode[type], value, 0, 1);
		g_iAbsorbAbility[type] = iGetValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iAbsorbAbility[type], value, 0, 1);
		g_iAbsorbMessage[type] = iGetValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iAbsorbMessage[type], value, 0, 1);
		g_flAbsorbBulletDivisor[type] = flGetValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbBulletDivisor", "Absorb Bullet Divisor", "Absorb_Bullet_Divisor", "bullet", g_flAbsorbBulletDivisor[type], value, 0.1, 9999999999.0);
		g_flAbsorbChance[type] = flGetValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbChance", "Absorb Chance", "Absorb_Chance", "chance", g_flAbsorbChance[type], value, 0.0, 100.0);
		g_flAbsorbDuration[type] = flGetValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbDuration", "Absorb Duration", "Absorb_Duration", "duration", g_flAbsorbDuration[type], value, 0.1, 9999999999.0);
		g_flAbsorbExplosiveDivisor[type] = flGetValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbExplosiveDivisor", "Absorb Explosive Divisor", "Absorb_Explosive_Divisor", "explosive", g_flAbsorbExplosiveDivisor[type], value, 0.1, 9999999999.0);
		g_flAbsorbFireDivisor[type] = flGetValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbFireDivisor", "Absorb Fire Divisor", "Absorb_Fire_Divisor", "fire", g_flAbsorbFireDivisor[type], value, 0.1, 9999999999.0);
		g_flAbsorbMeleeDivisor[type] = flGetValue(subsection, "absorbability", "absorb ability", "absorb_ability", "absorb", key, "AbsorbMeleeDivisor", "Absorb Melee Divisor", "Absorb_Melee_Divisor", "melee", g_flAbsorbMeleeDivisor[type], value, 0.1, 9999999999.0);

		if (StrEqual(subsection, "absorbability", false) || StrEqual(subsection, "absorb ability", false) || StrEqual(subsection, "absorb_ability", false) || StrEqual(subsection, "absorb", false))
		{
			if (StrEqual(key, "AccessFlags", false) || StrEqual(key, "Access Flags", false) || StrEqual(key, "Access_Flags", false) || StrEqual(key, "access", false))
			{
				g_iAccessFlags[type] = (value[0] != '\0') ? ReadFlagString(value) : g_iAccessFlags[type];
			}
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveAbsorb(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iAbsorbAbility[ST_GetTankType(tank)] == 1 && !g_bAbsorb[tank])
	{
		vAbsorbAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (g_iAbsorbAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_iHumanMode[ST_GetTankType(tank)])
				{
					case 0:
					{
						if (!g_bAbsorb[tank] && !g_bAbsorb2[tank])
						{
							vAbsorbAbility(tank);
						}
						else if (g_bAbsorb[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "AbsorbHuman3");
						}
						else if (g_bAbsorb2[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "AbsorbHuman4");
						}
					}
					case 1:
					{
						if (g_iAbsorbCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
						{
							if (!g_bAbsorb[tank] && !g_bAbsorb2[tank])
							{
								g_bAbsorb[tank] = true;
								g_iAbsorbCount[tank]++;

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "AbsorbHuman", g_iAbsorbCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "AbsorbAmmo");
						}
					}
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
			if (g_iAbsorbAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (g_iHumanMode[ST_GetTankType(tank)] == 1 && g_bAbsorb[tank] && !g_bAbsorb2[tank])
				{
					g_bAbsorb[tank] = false;

					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveAbsorb(tank);
}

static void vAbsorbAbility(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iAbsorbCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flAbsorbChance[ST_GetTankType(tank)])
		{
			g_bAbsorb[tank] = true;

			CreateTimer(g_flAbsorbDuration[ST_GetTankType(tank)], tTimerStopAbsorb, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				g_iAbsorbCount[tank]++;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "AbsorbHuman", g_iAbsorbCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
			}

			if (g_iAbsorbMessage[ST_GetTankType(tank)] == 1)
			{
				char sTankName[33];
				ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Absorb", sTankName);
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "AbsorbHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "AbsorbAmmo");
	}
}

static void vRemoveAbsorb(int tank)
{
	g_bAbsorb[tank] = false;
	g_bAbsorb2[tank] = false;
	g_iAbsorbCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveAbsorb(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bAbsorb2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "AbsorbHuman5");

	if (g_iAbsorbCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bAbsorb2[tank] = false;
	}
}

static bool bHasAdminAccess(int admin)
{
	if (!bIsValidClient(admin, ST_CHECK_INGAME|ST_CHECK_FAKECLIENT))
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

public Action tTimerStopAbsorb(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bAbsorb[iTank])
	{
		g_bAbsorb[iTank] = false;

		return Plugin_Stop;
	}

	g_bAbsorb[iTank] = false;

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && (ST_HasAdminAccess(iTank) || bHasAdminAccess(iTank)) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && !g_bAbsorb2[iTank])
	{
		vReset2(iTank);
	}

	if (g_iAbsorbMessage[ST_GetTankType(iTank)] == 1)
	{
		char sTankName[33];
		ST_GetTankName(iTank, ST_GetTankType(iTank), sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Absorb2", sTankName);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bAbsorb2[iTank])
	{
		g_bAbsorb2[iTank] = false;

		return Plugin_Stop;
	}

	g_bAbsorb2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "AbsorbHuman6");

	return Plugin_Continue;
}