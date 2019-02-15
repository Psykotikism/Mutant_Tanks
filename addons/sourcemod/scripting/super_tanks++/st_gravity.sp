/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2018  Alfred "Crasher_3637/Psyk0tik" Llagas
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
	name = "[ST++] Gravity Ability",
	author = ST_AUTHOR,
	description = "The Super Tank pulls in or pushes away survivors and any other nearby infected, and changes the survivors' gravity.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_GRAVITY "Gravity Ability"

bool g_bCloneInstalled, g_bGravity[MAXPLAYERS + 1], g_bGravity2[MAXPLAYERS + 1], g_bGravity3[MAXPLAYERS + 1], g_bGravity4[MAXPLAYERS + 1], g_bGravity5[MAXPLAYERS + 1], g_bGravity6[MAXPLAYERS + 1], g_bGravity7[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sGravityEffect[ST_MAXTYPES + 1][4], g_sGravityEffect2[ST_MAXTYPES + 1][4], g_sGravityMessage[ST_MAXTYPES + 1][4], g_sGravityMessage2[ST_MAXTYPES + 1][4];

float g_flGravityChance[ST_MAXTYPES + 1], g_flGravityChance2[ST_MAXTYPES + 1], g_flGravityDuration[ST_MAXTYPES + 1], g_flGravityDuration2[ST_MAXTYPES + 1], g_flGravityForce[ST_MAXTYPES + 1], g_flGravityForce2[ST_MAXTYPES + 1], g_flGravityRange[ST_MAXTYPES + 1], g_flGravityRange2[ST_MAXTYPES + 1], g_flGravityRangeChance[ST_MAXTYPES + 1], g_flGravityRangeChance2[ST_MAXTYPES + 1], g_flGravityValue[ST_MAXTYPES + 1], g_flGravityValue2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

int g_iGravity[MAXPLAYERS + 1], g_iGravityAbility[ST_MAXTYPES + 1], g_iGravityAbility2[ST_MAXTYPES + 1], g_iGravityCount[MAXPLAYERS + 1], g_iGravityCount2[MAXPLAYERS + 1], g_iGravityHit[ST_MAXTYPES + 1], g_iGravityHit2[ST_MAXTYPES + 1], g_iGravityHitMode[ST_MAXTYPES + 1], g_iGravityHitMode2[ST_MAXTYPES + 1], g_iGravityOwner[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Gravity Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

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

	RegConsoleCmd("sm_st_gravity", cmdGravityInfo, "View information about the Gravity ability.");

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer, "24"))
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

	vReset2(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdGravityInfo(int client, int args)
{
	if (!ST_IsCorePluginEnabled())
	{
		ReplyToCommand(client, "%s Super Tanks++\x01 is disabled.", ST_TAG4);

		return Plugin_Handled;
	}

	if (!bIsValidClient(client, "0245"))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", ST_TAG);

		return Plugin_Handled;
	}

	switch (IsVoteInProgress())
	{
		case true: ReplyToCommand(client, "%s %t", ST_TAG2, "Vote in Progress");
		case false: vGravityMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vGravityMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iGravityMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Gravity Ability Information");
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

public int iGravityMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iGravityAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iGravityCount[param1], iHumanAmmo(param1));
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo2", iHumanAmmo(param1) - g_iGravityCount2[param1], iHumanAmmo(param1));
				}
				case 2:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				}
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "GravityDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flGravityDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vGravityMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "GravityMenu", param1);
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
	menu.AddItem(ST_MENU_GRAVITY, ST_MENU_GRAVITY);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_GRAVITY, false))
	{
		vGravityMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && (iGravityHitMode(attacker) == 0 || iGravityHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vGravityHit(victim, attacker, flGravityChance(attacker), iGravityHit(attacker), "1", "1");
			}
		}
		else if (ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && (iGravityHitMode(victim) == 0 || iGravityHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vGravityHit(attacker, victim, flGravityChance(victim), iGravityHit(victim), "1", "2");
			}
		}
	}
}

public void ST_OnConfigsLoaded(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);

	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		char sTankName[33];
		Format(sTankName, sizeof(sTankName), "Tank #%i", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName))
		{
			switch (main)
			{
				case true:
				{
					g_bTankConfig[iIndex] = false;

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iGravityAbility[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Ability Enabled", 0);
					g_iGravityAbility[iIndex] = iClamp(g_iGravityAbility[iIndex], 0, 3);
					kvSuperTanks.GetString("Gravity Ability/Ability Effect", g_sGravityEffect[iIndex], sizeof(g_sGravityEffect[]), "0");
					kvSuperTanks.GetString("Gravity Ability/Ability Message", g_sGravityMessage[iIndex], sizeof(g_sGravityMessage[]), "0");
					g_flGravityChance[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Chance", 33.3);
					g_flGravityChance[iIndex] = flClamp(g_flGravityChance[iIndex], 0.0, 100.0);
					g_flGravityDuration[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Duration", 5.0);
					g_flGravityDuration[iIndex] = flClamp(g_flGravityDuration[iIndex], 0.1, 9999999999.0);
					g_flGravityForce[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Force", -50.0);
					g_flGravityForce[iIndex] = flClamp(g_flGravityForce[iIndex], -100.0, 100.0);
					g_iGravityHit[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit", 0);
					g_iGravityHit[iIndex] = iClamp(g_iGravityHit[iIndex], 0, 1);
					g_iGravityHitMode[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit Mode", 0);
					g_iGravityHitMode[iIndex] = iClamp(g_iGravityHitMode[iIndex], 0, 2);
					g_flGravityRange[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Range", 150.0);
					g_flGravityRange[iIndex] = flClamp(g_flGravityRange[iIndex], 1.0, 9999999999.0);
					g_flGravityRangeChance[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Range Chance", 15.0);
					g_flGravityRangeChance[iIndex] = flClamp(g_flGravityRangeChance[iIndex], 0.0, 100.0);
					g_flGravityValue[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Value", 0.3);
					g_flGravityValue[iIndex] = flClamp(g_flGravityValue[iIndex], 0.1, 9999999999.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iGravityAbility2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Ability Enabled", g_iGravityAbility[iIndex]);
					g_iGravityAbility2[iIndex] = iClamp(g_iGravityAbility2[iIndex], 0, 3);
					kvSuperTanks.GetString("Gravity Ability/Ability Effect", g_sGravityEffect2[iIndex], sizeof(g_sGravityEffect2[]), g_sGravityEffect[iIndex]);
					kvSuperTanks.GetString("Gravity Ability/Ability Message", g_sGravityMessage2[iIndex], sizeof(g_sGravityMessage2[]), g_sGravityMessage[iIndex]);
					g_flGravityChance2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Chance", g_flGravityChance[iIndex]);
					g_flGravityChance2[iIndex] = flClamp(g_flGravityChance2[iIndex], 0.0, 100.0);
					g_flGravityDuration2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Duration", g_flGravityDuration[iIndex]);
					g_flGravityDuration2[iIndex] = flClamp(g_flGravityDuration2[iIndex], 0.1, 9999999999.0);
					g_flGravityForce2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Force", g_flGravityForce[iIndex]);
					g_flGravityForce2[iIndex] = flClamp(g_flGravityForce2[iIndex], -100.0, 100.0);
					g_iGravityHit2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit", g_iGravityHit[iIndex]);
					g_iGravityHit2[iIndex] = iClamp(g_iGravityHit2[iIndex], 0, 1);
					g_iGravityHitMode2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit Mode", g_iGravityHitMode[iIndex]);
					g_iGravityHitMode2[iIndex] = iClamp(g_iGravityHitMode2[iIndex], 0, 2);
					g_flGravityRange2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Range", g_flGravityRange[iIndex]);
					g_flGravityRange2[iIndex] = flClamp(g_flGravityRange2[iIndex], 1.0, 9999999999.0);
					g_flGravityRangeChance2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Range Chance", g_flGravityRangeChance[iIndex]);
					g_flGravityRangeChance2[iIndex] = flClamp(g_flGravityRangeChance2[iIndex], 0.0, 100.0);
					g_flGravityValue2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Value", g_flGravityValue[iIndex]);
					g_flGravityValue2[iIndex] = flClamp(g_flGravityValue2[iIndex], 0.1, 9999999999.0);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, "234"))
		{
			vRemoveGravity(iTank);
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "bot_player_replace"))
	{
		int iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId),
			iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId);
		if (bIsValidClient(iBot) && bIsTank(iTank))
		{
			vRemoveGravity(iBot);
		}
	}
	else if (StrEqual(name, "player_bot_replace"))
	{
		int iTankId = event.GetInt("player"), iTank = GetClientOfUserId(iTankId),
			iBotId = event.GetInt("bot"), iBot = GetClientOfUserId(iBotId);
		if (bIsValidClient(iTank) && bIsTank(iBot))
		{
			vRemoveGravity(iTank);
		}
	}
	else if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, "024"))
		{
			vRemoveGravity(iTank);

			vReset2(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, "5") || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iGravityAbility(tank) > 0)
	{
		vGravityAbility(tank, true);
		vGravityAbility(tank, false);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if ((iGravityAbility(tank) == 2 || iGravityAbility(tank) == 3) && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
				{
					case 0:
					{
						if (!g_bGravity[tank] && !g_bGravity3[tank])
						{
							vGravityAbility(tank, false);
						}
						else if (g_bGravity[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman4");
						}
						else if (g_bGravity3[tank])
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman5");
						}
					}
					case 1:
					{
						if (g_iGravityCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bGravity[tank] && !g_bGravity3[tank])
							{
								g_bGravity[tank] = true;
								g_iGravityCount[tank]++;

								g_iGravity[tank] = CreateEntityByName("point_push");
								if (bIsValidEntity(g_iGravity[tank]))
								{
									vGravity(tank);
								}

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman", g_iGravityCount[tank], iHumanAmmo(tank));
							}
						}
						else
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityAmmo");
						}
					}
				}
			}
		}

		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if ((iGravityAbility(tank) == 1 || iGravityAbility(tank) == 3) && iHumanAbility(tank) == 1)
			{
				if (!g_bGravity4[tank] && !g_bGravity5[tank])
				{
					vGravityAbility(tank, true);
				}
				else if (g_bGravity4[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman6");
				}
				else if (g_bGravity5[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman7");
				}
			}
		}
	}
}

public void ST_OnButtonReleased(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if ((iGravityAbility(tank) == 2 || iGravityAbility(tank) == 3) && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bGravity[tank] && !g_bGravity3[tank])
				{
					vReset3(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	if (ST_IsTankSupported(tank))
	{
		vRemoveGravity(tank);
	}

	vReset2(tank);
}

static void vGravity(int tank)
{
	float flGravityForce = !g_bTankConfig[ST_GetTankType(tank)] ? g_flGravityForce[ST_GetTankType(tank)] : g_flGravityForce2[ST_GetTankType(tank)],
		flOrigin[3], flAngles[3];
	GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
	GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);
	flAngles[0] += -90.0;

	DispatchKeyValueVector(g_iGravity[tank], "origin", flOrigin);
	DispatchKeyValueVector(g_iGravity[tank], "angles", flAngles);
	DispatchKeyValue(g_iGravity[tank], "radius", "750");
	DispatchKeyValueFloat(g_iGravity[tank], "magnitude", flGravityForce);
	DispatchKeyValue(g_iGravity[tank], "spawnflags", "8");
	vSetEntityParent(g_iGravity[tank], tank, true);
	AcceptEntityInput(g_iGravity[tank], "Enable");
}

static void vGravityAbility(int tank, bool main)
{
	switch (main)
	{
		case true:
		{
			if (iGravityAbility(tank) == 1 || iGravityAbility(tank) == 3)
			{
				if (g_iGravityCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
				{
					g_bGravity6[tank] = false;
					g_bGravity7[tank] = false;

					float flGravityRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flGravityRange[ST_GetTankType(tank)] : g_flGravityRange2[ST_GetTankType(tank)],
						flGravityRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flGravityRangeChance[ST_GetTankType(tank)] : g_flGravityRangeChance2[ST_GetTankType(tank)],
						flTankPos[3];

					GetClientAbsOrigin(tank, flTankPos);

					int iSurvivorCount;

					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor, "234"))
						{
							float flSurvivorPos[3];
							GetClientAbsOrigin(iSurvivor, flSurvivorPos);

							float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
							if (flDistance <= flGravityRange)
							{
								vGravityHit(iSurvivor, tank, flGravityRangeChance, iGravityAbility(tank), "2", "3");

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman8");
						}
					}
				}
				else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityAmmo2");
				}
			}
		}
		case false:
		{
			if ((iGravityAbility(tank) == 2 || iGravityAbility(tank) == 3) && !g_bGravity[tank])
			{
				if (g_iGravityCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
				{
					g_bGravity[tank] = true;

					g_iGravity[tank] = CreateEntityByName("point_push");
					if (bIsValidEntity(g_iGravity[tank]))
					{
						if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
						{
							g_iGravityCount[tank]++;

							ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman", g_iGravityCount[tank], iHumanAmmo(tank));
						}

						vGravity(tank);

						DataPack dpGravity;
						CreateDataTimer(flGravityDuration(tank), tTimerGravity, dpGravity, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						dpGravity.WriteCell(GetClientUserId(tank));
						dpGravity.WriteCell(ST_GetTankType(tank));
						dpGravity.WriteFloat(GetEngineTime());

						char sGravityMessage[4];
						sGravityMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sGravityMessage[ST_GetTankType(tank)] : g_sGravityMessage2[ST_GetTankType(tank)];
						if (StrContains(sGravityMessage, "3") != -1)
						{
							char sTankName[33];
							ST_GetTankName(tank, sTankName);
							ST_PrintToChatAll("%s %t", ST_TAG2, "Gravity3", sTankName);
						}
					}
				}
				else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityAmmo");
				}
			}
		}
	}
}

static void vGravityHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (g_iGravityCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bGravity2[survivor])
			{
				g_bGravity2[survivor] = true;
				g_iGravityOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bGravity4[tank])
				{
					g_bGravity4[tank] = true;
					g_iGravityCount2[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman2", g_iGravityCount2[tank], iHumanAmmo(tank));
				}

				float flGravityValue = !g_bTankConfig[ST_GetTankType(tank)] ? g_flGravityValue[ST_GetTankType(tank)] : g_flGravityValue2[ST_GetTankType(tank)];
				SetEntityGravity(survivor, flGravityValue);

				DataPack dpStopGravity;
				CreateDataTimer(flGravityDuration(tank), tTimerStopGravity, dpStopGravity, TIMER_FLAG_NO_MAPCHANGE);
				dpStopGravity.WriteCell(GetClientUserId(survivor));
				dpStopGravity.WriteCell(GetClientUserId(tank));
				dpStopGravity.WriteString(message);

				char sGravityEffect[4];
				sGravityEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_sGravityEffect[ST_GetTankType(tank)] : g_sGravityEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, sGravityEffect, mode);

				char sGravityMessage[4];
				sGravityMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sGravityMessage[ST_GetTankType(tank)] : g_sGravityMessage2[ST_GetTankType(tank)];
				if (StrContains(sGravityMessage, message) != -1)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Gravity", sTankName, survivor, flGravityValue);
				}
			}
			else if (StrEqual(mode, "3") && !g_bGravity4[tank])
			{
				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bGravity6[tank])
				{
					g_bGravity6[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman3");
				}
			}
		}
		else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bGravity7[tank])
		{
			g_bGravity7[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityAmmo2");
		}
	}
}

static void vRemoveGravity(int tank)
{
	if (bIsValidEntity(g_iGravity[tank]))
	{
		RemoveEntity(g_iGravity[tank]);
	}

	g_iGravity[tank] = 0;

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "234") && g_bGravity2[iSurvivor] && g_iGravityOwner[iSurvivor] == tank)
		{
			g_bGravity2[iSurvivor] = false;
			g_iGravityOwner[iSurvivor] = 0;

			SetEntityGravity(iSurvivor, 1.0);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vReset2(iPlayer);

			g_iGravityOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_bGravity[tank] = false;
	g_bGravity2[tank] = false;
	g_bGravity3[tank] = false;
	g_bGravity4[tank] = false;
	g_bGravity5[tank] = false;
	g_bGravity6[tank] = false;
	g_bGravity7[tank] = false;
	g_iGravity[tank] = 0;
	g_iGravityCount[tank] = 0;
	g_iGravityCount2[tank] = 0;
}

static void vReset3(int tank)
{
	g_bGravity[tank] = false;
	g_bGravity3[tank] = true;

	if (bIsValidEntity(g_iGravity[tank]))
	{
		RemoveEntity(g_iGravity[tank]);
	}

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "GravityHuman9");

	if (g_iGravityCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bGravity3[tank] = false;
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flGravityChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flGravityChance[ST_GetTankType(tank)] : g_flGravityChance2[ST_GetTankType(tank)];
}

static float flGravityDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flGravityDuration[ST_GetTankType(tank)] : g_flGravityDuration2[ST_GetTankType(tank)];
}

static int iGravityAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iGravityAbility[ST_GetTankType(tank)] : g_iGravityAbility2[ST_GetTankType(tank)];
}

static int iGravityHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iGravityHit[ST_GetTankType(tank)] : g_iGravityHit2[ST_GetTankType(tank)];
}

static int iGravityHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iGravityHitMode[ST_GetTankType(tank)] : g_iGravityHitMode2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iHumanMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanMode[ST_GetTankType(tank)] : g_iHumanMode2[ST_GetTankType(tank)];
}

public Action tTimerGravity(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bGravity[iTank])
	{
		g_bGravity[iTank] = false;

		char sGravityMessage[4];
		sGravityMessage = !g_bTankConfig[ST_GetTankType(iTank)] ? g_sGravityMessage[ST_GetTankType(iTank)] : g_sGravityMessage2[ST_GetTankType(iTank)];
		if (StrContains(sGravityMessage, "3") != -1)
		{
			char sTankName[33];
			ST_GetTankName(iTank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Gravity4", sTankName);
		}

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (ST_IsTankSupported(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0 && (flTime + flGravityDuration(iTank)) < GetEngineTime() && !g_bGravity3[iTank])
	{
		vReset3(iTank);

		return Plugin_Stop;
	}

	return Plugin_Continue;
}

public Action tTimerStopGravity(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bGravity2[iSurvivor] = false;
		g_iGravityOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsTankSupported(iTank) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bGravity2[iSurvivor])
	{
		g_bGravity2[iSurvivor] = false;
		g_iGravityOwner[iSurvivor] = 0;

		SetEntityGravity(iSurvivor, 1.0);

		return Plugin_Stop;
	}

	g_bGravity2[iSurvivor] = false;
	g_bGravity4[iTank] = false;
	g_iGravityOwner[iSurvivor] = 0;

	SetEntityGravity(iSurvivor, 1.0);

	char sMessage[4];
	pack.ReadString(sMessage, sizeof(sMessage));

	if (ST_IsTankSupported(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bGravity5[iTank])
	{
		g_bGravity5[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "GravityHuman10");

		if (g_iGravityCount2[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
		{
			CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown2, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bGravity5[iTank] = false;
		}
	}

	char sGravityMessage[4];
	sGravityMessage = !g_bTankConfig[ST_GetTankType(iTank)] ? g_sGravityMessage[ST_GetTankType(iTank)] : g_sGravityMessage2[ST_GetTankType(iTank)];
	if (StrContains(sGravityMessage, sMessage) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Gravity2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bGravity3[iTank])
	{
		g_bGravity3[iTank] = false;

		return Plugin_Stop;
	}

	g_bGravity3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "GravityHuman11");

	return Plugin_Continue;
}

public Action tTimerResetCooldown2(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bGravity5[iTank])
	{
		g_bGravity5[iTank] = false;

		return Plugin_Stop;
	}

	g_bGravity5[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "GravityHuman12");

	return Plugin_Continue;
}