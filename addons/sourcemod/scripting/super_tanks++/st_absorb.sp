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

// Super Tanks++: Absorb Ability
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

#define ST_MENU_ABSORB "Absorb Ability"

bool g_bAbsorb[MAXPLAYERS + 1], g_bAbsorb2[MAXPLAYERS + 1], g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

float g_flAbsorbBulletDivisor[ST_MAXTYPES + 1], g_flAbsorbBulletDivisor2[ST_MAXTYPES + 1], g_flAbsorbChance[ST_MAXTYPES + 1], g_flAbsorbChance2[ST_MAXTYPES + 1], g_flAbsorbDuration[ST_MAXTYPES + 1], g_flAbsorbDuration2[ST_MAXTYPES + 1], g_flAbsorbExplosiveDivisor[ST_MAXTYPES + 1], g_flAbsorbExplosiveDivisor2[ST_MAXTYPES + 1], g_flAbsorbFireDivisor[ST_MAXTYPES + 1], g_flAbsorbFireDivisor2[ST_MAXTYPES + 1], g_flAbsorbMeleeDivisor[ST_MAXTYPES + 1], g_flAbsorbMeleeDivisor2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

int g_iAbsorbAbility[ST_MAXTYPES + 1], g_iAbsorbAbility2[ST_MAXTYPES + 1], g_iAbsorbCount[MAXPLAYERS + 1], g_iAbsorbMessage[ST_MAXTYPES + 1], g_iAbsorbMessage2[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1];

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
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_absorb", cmdAbsorbInfo, "View information about the Absorb ability.");

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

	vRemoveAbsorb(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdAbsorbInfo(int client, int args)
{
	if (!ST_PluginEnabled())
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iAbsorbAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iAbsorbCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbsorbDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flAbsorbDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
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
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && g_bAbsorb[victim])
		{
			float flAbsorbBulletDivisor = !g_bTankConfig[ST_TankType(victim)] ? g_flAbsorbBulletDivisor[ST_TankType(victim)] : g_flAbsorbBulletDivisor2[ST_TankType(victim)],
				flAbsorbExplosiveDivisor = !g_bTankConfig[ST_TankType(victim)] ? g_flAbsorbExplosiveDivisor[ST_TankType(victim)] : g_flAbsorbExplosiveDivisor2[ST_TankType(victim)],
				flAbsorbFireDivisor = !g_bTankConfig[ST_TankType(victim)] ? g_flAbsorbFireDivisor[ST_TankType(victim)] : g_flAbsorbFireDivisor2[ST_TankType(victim)],
				flAbsorbMeleeDivisor = !g_bTankConfig[ST_TankType(victim)] ? g_flAbsorbMeleeDivisor[ST_TankType(victim)] : g_flAbsorbMeleeDivisor2[ST_TankType(victim)];
			if (damagetype & DMG_BULLET)
			{
				damage /= flAbsorbBulletDivisor;
			}
			else if (damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA)
			{
				damage /= flAbsorbExplosiveDivisor;
			}
			else if (damagetype & DMG_BURN)
			{
				damage /= flAbsorbFireDivisor;
			}
			else if (damagetype & DMG_SLASH || damagetype & DMG_CLUB)
			{
				damage /= flAbsorbMeleeDivisor;
			}

			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
}

public void ST_OnConfigsLoaded(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);

	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 1, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iAbsorbAbility[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Ability Enabled", 0);
					g_iAbsorbAbility[iIndex] = iClamp(g_iAbsorbAbility[iIndex], 0, 1);
					g_iAbsorbMessage[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Ability Message", 0);
					g_iAbsorbMessage[iIndex] = iClamp(g_iAbsorbMessage[iIndex], 0, 1);
					g_flAbsorbBulletDivisor[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Bullet Divisor", 20.0);
					g_flAbsorbBulletDivisor[iIndex] = flClamp(g_flAbsorbBulletDivisor[iIndex], 0.1, 9999999999.0);
					g_flAbsorbChance[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Chance", 33.3);
					g_flAbsorbChance[iIndex] = flClamp(g_flAbsorbChance[iIndex], 0.0, 100.0);
					g_flAbsorbDuration[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Duration", 5.0);
					g_flAbsorbDuration[iIndex] = flClamp(g_flAbsorbDuration[iIndex], 0.1, 9999999999.0);
					g_flAbsorbExplosiveDivisor[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Explosive Divisor", 20.0);
					g_flAbsorbExplosiveDivisor[iIndex] = flClamp(g_flAbsorbExplosiveDivisor[iIndex], 0.1, 9999999999.0);
					g_flAbsorbFireDivisor[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Fire Divisor", 200.0);
					g_flAbsorbFireDivisor[iIndex] = flClamp(g_flAbsorbFireDivisor[iIndex], 0.1, 9999999999.0);
					g_flAbsorbMeleeDivisor[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Melee Divisor", 200.0);
					g_flAbsorbMeleeDivisor[iIndex] = flClamp(g_flAbsorbMeleeDivisor[iIndex], 0.1, 9999999999.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 1, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iAbsorbAbility2[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Ability Enabled", g_iAbsorbAbility[iIndex]);
					g_iAbsorbAbility2[iIndex] = iClamp(g_iAbsorbAbility2[iIndex], 0, 1);
					g_iAbsorbMessage2[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Ability Message", g_iAbsorbMessage[iIndex]);
					g_iAbsorbMessage2[iIndex] = iClamp(g_iAbsorbMessage2[iIndex], 0, 1);
					g_flAbsorbBulletDivisor2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Bullet Divisor", g_flAbsorbBulletDivisor[iIndex]);
					g_flAbsorbBulletDivisor2[iIndex] = flClamp(g_flAbsorbBulletDivisor2[iIndex], 0.1, 9999999999.0);
					g_flAbsorbChance2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Chance", g_flAbsorbChance[iIndex]);
					g_flAbsorbChance2[iIndex] = flClamp(g_flAbsorbChance2[iIndex], 0.0, 100.0);
					g_flAbsorbDuration2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Duration", g_flAbsorbDuration[iIndex]);
					g_flAbsorbDuration2[iIndex] = flClamp(g_flAbsorbDuration2[iIndex], 0.1, 9999999999.0);
					g_flAbsorbExplosiveDivisor2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Explosive Divisor", g_flAbsorbExplosiveDivisor[iIndex]);
					g_flAbsorbExplosiveDivisor2[iIndex] = flClamp(g_flAbsorbExplosiveDivisor2[iIndex], 0.1, 9999999999.0);
					g_flAbsorbFireDivisor2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Fire Divisor", g_flAbsorbFireDivisor[iIndex]);
					g_flAbsorbFireDivisor2[iIndex] = flClamp(g_flAbsorbFireDivisor2[iIndex], 0.1, 9999999999.0);
					g_flAbsorbMeleeDivisor2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Melee Divisor", g_flAbsorbMeleeDivisor[iIndex]);
					g_flAbsorbMeleeDivisor2[iIndex] = flClamp(g_flAbsorbMeleeDivisor2[iIndex], 0.1, 9999999999.0);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank, "024") && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			if (g_bAbsorb[iTank])
			{
				tTimerStopAbsorb(null, GetClientUserId(iTank));
			}

			g_iAbsorbCount[iTank] = 0;
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iAbsorbAbility(tank) == 1 && !g_bAbsorb[tank])
	{
		vAbsorbAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iAbsorbAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
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
						if (g_iAbsorbCount[tank] < iHumanAmmo(tank))
						{
							if (!g_bAbsorb[tank] && !g_bAbsorb2[tank])
							{
								g_bAbsorb[tank] = true;
								g_iAbsorbCount[tank]++;

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "AbsorbHuman", g_iAbsorbCount[tank], iHumanAmmo(tank));
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
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if (iAbsorbAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bAbsorb[tank] && !g_bAbsorb2[tank])
				{
					g_bAbsorb[tank] = false;

					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveAbsorb(tank);
}

static void vAbsorbAbility(int tank)
{
	if (iAbsorbAbility(tank) == 1)
	{
		if (g_iAbsorbCount[tank] < iHumanAmmo(tank))
		{
			float flAbsorbChance = !g_bTankConfig[ST_TankType(tank)] ? g_flAbsorbChance[ST_TankType(tank)] : g_flAbsorbChance2[ST_TankType(tank)];
			if (GetRandomFloat(0.1, 100.0) <= flAbsorbChance)
			{
				g_bAbsorb[tank] = true;

				CreateTimer(flAbsorbDuration(tank), tTimerStopAbsorb, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
				{
					g_iAbsorbCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "AbsorbHuman", g_iAbsorbCount[tank], iHumanAmmo(tank));
				}

				if (iAbsorbMessage(tank) == 1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Absorb", sTankName);
				}
			}
			else
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "AbsorbHuman2");
				}
			}
		}
		else
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "AbsorbAmmo");
		}
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
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveAbsorb(iPlayer);
		}
	}
}

static void vReset2(int tank)
{
	g_bAbsorb2[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "AbsorbHuman5");

	if (g_iAbsorbCount[tank] < iHumanAmmo(tank))
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		g_bAbsorb2[tank] = false;
	}
}

static float flAbsorbDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flAbsorbDuration[ST_TankType(tank)] : g_flAbsorbDuration2[ST_TankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static int iAbsorbAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iAbsorbAbility[ST_TankType(tank)] : g_iAbsorbAbility2[ST_TankType(tank)];
}

static int iAbsorbMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iAbsorbMessage[ST_TankType(tank)] : g_iAbsorbMessage2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iHumanMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanMode[ST_TankType(tank)] : g_iHumanMode2[ST_TankType(tank)];
}

public Action tTimerStopAbsorb(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bAbsorb[iTank])
	{
		g_bAbsorb[iTank] = false;

		return Plugin_Stop;
	}

	g_bAbsorb[iTank] = false;

	if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && !g_bAbsorb2[iTank])
	{
		vReset2(iTank);
	}

	if (iAbsorbMessage(iTank) == 1)
	{
		char sTankName[33];
		ST_TankName(iTank, sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Absorb2", sTankName);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bAbsorb2[iTank])
	{
		g_bAbsorb2[iTank] = false;

		return Plugin_Stop;
	}

	g_bAbsorb2[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "AbsorbHuman6");

	return Plugin_Continue;
}