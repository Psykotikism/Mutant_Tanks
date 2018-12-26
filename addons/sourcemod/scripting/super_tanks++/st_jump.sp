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
	name = "[ST++] Jump Ability",
	author = ST_AUTHOR,
	description = "The Super Tank jumps periodically or sporadically and makes survivors jump uncontrollably.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_JUMP "Jump Ability"

bool g_bCloneInstalled, g_bJump[MAXPLAYERS + 1], g_bJump2[MAXPLAYERS + 1], g_bJump3[MAXPLAYERS + 1], g_bJump4[MAXPLAYERS + 1], g_bJump5[MAXPLAYERS + 1], g_bJump6[MAXPLAYERS + 1], g_bJump7[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sJumpEffect[ST_MAXTYPES + 1][4], g_sJumpEffect2[ST_MAXTYPES + 1][4], g_sJumpMessage[ST_MAXTYPES + 1][4], g_sJumpMessage2[ST_MAXTYPES + 1][4];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flJumpChance[ST_MAXTYPES + 1], g_flJumpChance2[ST_MAXTYPES + 1], g_flJumpDuration[ST_MAXTYPES + 1], g_flJumpDuration2[ST_MAXTYPES + 1], g_flJumpHeight[ST_MAXTYPES + 1], g_flJumpHeight2[ST_MAXTYPES + 1], g_flJumpInterval[ST_MAXTYPES + 1], g_flJumpInterval2[ST_MAXTYPES + 1], g_flJumpRange[ST_MAXTYPES + 1], g_flJumpRange2[ST_MAXTYPES + 1], g_flJumpRangeChance[ST_MAXTYPES + 1], g_flJumpRangeChance2[ST_MAXTYPES + 1], g_flJumpSporadicChance[ST_MAXTYPES + 1], g_flJumpSporadicChance2[ST_MAXTYPES + 1], g_flJumpSporadicHeight[ST_MAXTYPES + 1], g_flJumpSporadicHeight2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1], g_iJumpAbility[ST_MAXTYPES + 1], g_iJumpAbility2[ST_MAXTYPES + 1], g_iJumpCount[MAXPLAYERS + 1], g_iJumpCount2[MAXPLAYERS + 1], g_iJumpHit[ST_MAXTYPES + 1], g_iJumpHit2[ST_MAXTYPES + 1], g_iJumpHitMode[ST_MAXTYPES + 1], g_iJumpHitMode2[ST_MAXTYPES + 1], g_iJumpMode[ST_MAXTYPES + 1], g_iJumpMode2[ST_MAXTYPES + 1], g_iJumpOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Jump Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

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

	RegConsoleCmd("sm_st_jump", cmdJumpInfo, "View information about the Jump ability.");
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iJumpAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iJumpCount[param1], iHumanAmmo(param1));
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo2", iHumanAmmo(param1) - g_iJumpCount2[param1], iHumanAmmo(param1));
				}
				case 2:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				}
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "JumpDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flJumpDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
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
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && (iJumpHitMode(attacker) == 0 || iJumpHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vJumpHit(victim, attacker, flJumpChance(attacker), iJumpHit(attacker), "1", "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && (iJumpHitMode(victim) == 0 || iJumpHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vJumpHit(attacker, victim, flJumpChance(victim), iJumpHit(victim), "1", "2");
			}
		}
	}
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Jump Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Jump Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Jump Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iJumpAbility[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Enabled", 0);
					g_iJumpAbility[iIndex] = iClamp(g_iJumpAbility[iIndex], 0, 3);
					kvSuperTanks.GetString("Jump Ability/Ability Effect", g_sJumpEffect[iIndex], sizeof(g_sJumpEffect[]), "0");
					kvSuperTanks.GetString("Jump Ability/Ability Message", g_sJumpMessage[iIndex], sizeof(g_sJumpMessage[]), "0");
					g_flJumpChance[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Chance", 33.3);
					g_flJumpChance[iIndex] = flClamp(g_flJumpChance[iIndex], 0.0, 100.0);
					g_flJumpDuration[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Duration", 5.0);
					g_flJumpDuration[iIndex] = flClamp(g_flJumpDuration[iIndex], 0.1, 9999999999.0);
					g_flJumpHeight[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Height", 300.0);
					g_flJumpHeight[iIndex] = flClamp(g_flJumpHeight[iIndex], 0.1, 9999999999.0);
					g_iJumpHit[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Hit", 0);
					g_iJumpHit[iIndex] = iClamp(g_iJumpHit[iIndex], 0, 1);
					g_iJumpHitMode[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Hit Mode", 0);
					g_iJumpHitMode[iIndex] = iClamp(g_iJumpHitMode[iIndex], 0, 2);
					g_flJumpInterval[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Interval", 1.0);
					g_flJumpInterval[iIndex] = flClamp(g_flJumpInterval[iIndex], 0.1, 9999999999.0);
					g_iJumpMode[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Mode", 0);
					g_iJumpMode[iIndex] = iClamp(g_iJumpMode[iIndex], 0, 1);
					g_flJumpRange[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Range", 150.0);
					g_flJumpRange[iIndex] = flClamp(g_flJumpRange[iIndex], 1.0, 9999999999.0);
					g_flJumpRangeChance[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Range Chance", 15.0);
					g_flJumpRangeChance[iIndex] = flClamp(g_flJumpRangeChance[iIndex], 0.0, 100.0);
					g_flJumpSporadicChance[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Sporadic Chance", 33.3);
					g_flJumpSporadicChance[iIndex] = flClamp(g_flJumpSporadicChance[iIndex], 0.0, 100.0);
					g_flJumpSporadicHeight[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Sporadic Height", 750.0);
					g_flJumpSporadicHeight[iIndex] = flClamp(g_flJumpSporadicHeight[iIndex], 0.1, 9999999999.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iJumpAbility2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Enabled", g_iJumpAbility[iIndex]);
					g_iJumpAbility2[iIndex] = iClamp(g_iJumpAbility2[iIndex], 0, 3);
					kvSuperTanks.GetString("Jump Ability/Ability Effect", g_sJumpEffect2[iIndex], sizeof(g_sJumpEffect2[]), g_sJumpEffect[iIndex]);
					kvSuperTanks.GetString("Jump Ability/Ability Message", g_sJumpMessage2[iIndex], sizeof(g_sJumpMessage2[]), g_sJumpMessage[iIndex]);
					g_flJumpChance2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Chance", g_flJumpChance[iIndex]);
					g_flJumpChance2[iIndex] = flClamp(g_flJumpChance2[iIndex], 0.0, 100.0);
					g_flJumpDuration2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Duration", g_flJumpDuration[iIndex]);
					g_flJumpDuration2[iIndex] = flClamp(g_flJumpDuration2[iIndex], 0.1, 9999999999.0);
					g_flJumpHeight2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Height", g_flJumpHeight[iIndex]);
					g_flJumpHeight2[iIndex] = flClamp(g_flJumpHeight2[iIndex], 0.1, 9999999999.0);
					g_iJumpHit2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Hit", g_iJumpHit[iIndex]);
					g_iJumpHit2[iIndex] = iClamp(g_iJumpHit2[iIndex], 0, 1);
					g_iJumpHitMode2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Hit Mode", g_iJumpHitMode[iIndex]);
					g_iJumpHitMode2[iIndex] = iClamp(g_iJumpHitMode2[iIndex], 0, 2);
					g_flJumpInterval2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Interval", g_flJumpInterval[iIndex]);
					g_flJumpInterval2[iIndex] = flClamp(g_flJumpInterval2[iIndex], 0.1, 9999999999.0);
					g_iJumpMode2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Mode", g_iJumpMode[iIndex]);
					g_iJumpMode2[iIndex] = iClamp(g_iJumpMode2[iIndex], 0, 1);
					g_flJumpRange2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Range", g_flJumpRange[iIndex]);
					g_flJumpRange2[iIndex] = flClamp(g_flJumpRange2[iIndex], 1.0, 9999999999.0);
					g_flJumpRangeChance2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Range Chance", g_flJumpRangeChance[iIndex]);
					g_flJumpRangeChance2[iIndex] = flClamp(g_flJumpRangeChance2[iIndex], 0.0, 100.0);
					g_flJumpSporadicChance2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Sporadic Chance", g_flJumpSporadicChance[iIndex]);
					g_flJumpSporadicChance2[iIndex] = flClamp(g_flJumpSporadicChance2[iIndex], 0.0, 100.0);
					g_flJumpSporadicHeight2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Sporadic Height", g_flJumpSporadicHeight[iIndex]);
					g_flJumpSporadicHeight2[iIndex] = flClamp(g_flJumpSporadicHeight2[iIndex], 0.1, 9999999999.0);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank, "024"))
		{
			vRemoveJump(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iJumpAbility(tank) > 0)
	{
		vJumpAbility(tank, true);
		vJumpAbility(tank, false);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if ((iJumpAbility(tank) == 2 || iJumpAbility(tank) == 3) && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
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
						if (g_iJumpCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bJump[tank] && !g_bJump3[tank])
							{
								g_bJump[tank] = true;
								g_iJumpCount[tank]++;

								vJump2(tank);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman", g_iJumpCount[tank], iHumanAmmo(tank));
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
			if ((iJumpAbility(tank) == 1 || iJumpAbility(tank) == 3) && iHumanAbility(tank) == 1)
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
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if ((iJumpAbility(tank) == 2 || iJumpAbility(tank) == 3) && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bJump[tank] && !g_bJump3[tank])
				{
					vReset3(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveJump(tank);
}

static void vJump(int survivor, int tank)
{
	float flJumpHeight = !g_bTankConfig[ST_TankType(tank)] ? g_flJumpHeight[ST_TankType(tank)] : g_flJumpHeight2[ST_TankType(tank)],
		flVelocity[3];
	GetEntPropVector(survivor, Prop_Data, "m_vecVelocity", flVelocity);
	flVelocity[2] += flJumpHeight;

	TeleportEntity(survivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
}

static void vJump2(int tank)
{
	int iJumpMode = !g_bTankConfig[ST_TankType(tank)] ? g_iJumpMode[ST_TankType(tank)] : g_iJumpMode2[ST_TankType(tank)];
	switch (iJumpMode)
	{
		case 0:
		{
			float flJumpInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flJumpInterval[ST_TankType(tank)] : g_flJumpInterval2[ST_TankType(tank)];
			DataPack dpJump;
			CreateDataTimer(flJumpInterval, tTimerJump, dpJump, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpJump.WriteCell(GetClientUserId(tank));
			dpJump.WriteFloat(GetEngineTime());
		}
		case 1:
		{
			DataPack dpJump2;
			CreateDataTimer(1.0, tTimerJump2, dpJump2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpJump2.WriteCell(GetClientUserId(tank));
			dpJump2.WriteFloat(GetEngineTime());
		}
	}
}

static void vJumpAbility(int tank, bool main)
{
	switch (main)
	{
		case true:
		{
			if (iJumpAbility(tank) == 1 || iJumpAbility(tank) == 3)
			{
				if (g_iJumpCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
				{
					g_bJump6[tank] = false;
					g_bJump7[tank] = false;

					float flJumpRange = !g_bTankConfig[ST_TankType(tank)] ? g_flJumpRange[ST_TankType(tank)] : g_flJumpRange2[ST_TankType(tank)],
						flJumpRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flJumpRangeChance[ST_TankType(tank)] : g_flJumpRangeChance2[ST_TankType(tank)],
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
							if (flDistance <= flJumpRange)
							{
								vJumpHit(iSurvivor, tank, flJumpRangeChance, iJumpAbility(tank), "2", "3");

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman8");
						}
					}
				}
				else
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpAmmo");
				}
			}
		}
		case false:
		{
			if ((iJumpAbility(tank) == 2 || iJumpAbility(tank) == 3) && !g_bJump[tank])
			{
				if (g_iJumpCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
				{
					g_bJump[tank] = true;

					if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
					{
						g_iJumpCount[tank]++;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman", g_iJumpCount[tank], iHumanAmmo(tank));
					}

					vJump2(tank);

					char sJumpMessage[4];
					sJumpMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sJumpMessage[ST_TankType(tank)] : g_sJumpMessage2[ST_TankType(tank)];
					if (StrContains(sJumpMessage, "3") != -1)
					{
						char sTankName[33];
						ST_TankName(tank, sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Jump3", sTankName);
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

static void vJumpHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (g_iJumpCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bJump2[survivor])
			{
				g_bJump2[survivor] = true;
				g_iJumpOwner[survivor] = tank;

				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bJump4[tank])
				{
					g_bJump4[tank] = true;
					g_iJumpCount2[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman2", g_iJumpCount2[tank], iHumanAmmo(tank));
				}

				DataPack dpJump3;
				CreateDataTimer(0.25, tTimerJump3, dpJump3, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpJump3.WriteCell(GetClientUserId(survivor));
				dpJump3.WriteCell(GetClientUserId(tank));
				dpJump3.WriteString(message);
				dpJump3.WriteCell(enabled);
				dpJump3.WriteFloat(GetEngineTime());

				char sJumpEffect[4];
				sJumpEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sJumpEffect[ST_TankType(tank)] : g_sJumpEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sJumpEffect, mode);

				char sJumpMessage[4];
				sJumpMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sJumpMessage[ST_TankType(tank)] : g_sJumpMessage2[ST_TankType(tank)];
				if (StrContains(sJumpMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Jump", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bJump4[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bJump6[tank])
				{
					g_bJump6[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman3");
				}
			}
		}
		else
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bJump7[tank])
			{
				g_bJump7[tank] = true;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpAmmo2");
			}
		}
	}
}

static void vRemoveJump(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "24") && g_bJump2[iSurvivor] && g_iJumpOwner[iSurvivor] == tank)
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
		if (bIsValidClient(iPlayer, "24"))
		{
			vReset4(iPlayer);
		}
	}
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bJump2[survivor] = false;
	g_iJumpOwner[survivor] = 0;

	char sJumpMessage[4];
	sJumpMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sJumpMessage[ST_TankType(tank)] : g_sJumpMessage2[ST_TankType(tank)];
	if (StrContains(sJumpMessage, message) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Jump2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bJump[tank] = false;
	g_bJump3[tank] = true;

	ST_PrintToChat(tank, "%s %t", ST_TAG3, "JumpHuman9");

	if (g_iJumpCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
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

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flJumpChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flJumpChance[ST_TankType(tank)] : g_flJumpChance2[ST_TankType(tank)];
}

static float flJumpDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flJumpDuration[ST_TankType(tank)] : g_flJumpDuration2[ST_TankType(tank)];
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

static int iJumpAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iJumpAbility[ST_TankType(tank)] : g_iJumpAbility2[ST_TankType(tank)];
}

static int iJumpHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iJumpHit[ST_TankType(tank)] : g_iJumpHit2[ST_TankType(tank)];
}

static int iJumpHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iJumpHitMode[ST_TankType(tank)] : g_iJumpHitMode2[ST_TankType(tank)];
}

public Action tTimerJump(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || (iJumpAbility(iTank) != 2 && iJumpAbility(iTank) != 3) || !g_bJump[iTank])
	{
		g_bJump[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0 && (flTime + flJumpDuration(iTank)) < GetEngineTime() && !g_bJump3[iTank])
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

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || (iJumpAbility(iTank) != 2 && iJumpAbility(iTank) != 3) || !g_bJump[iTank])
	{
		g_bJump[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0 && (flTime + flJumpDuration(iTank)) < GetEngineTime() && !g_bJump3[iTank])
	{
		vReset3(iTank);

		return Plugin_Stop;
	}

	float flJumpSporadicChance = !g_bTankConfig[ST_TankType(iTank)] ? g_flJumpSporadicChance[ST_TankType(iTank)] : g_flJumpSporadicChance2[ST_TankType(iTank)];
	if (GetRandomFloat(0.1, 100.0) > flJumpSporadicChance)
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

		float flJumpSporadicHeight = !g_bTankConfig[ST_TankType(iTank)] ? g_flJumpSporadicHeight[ST_TankType(iTank)] : g_flJumpSporadicHeight2[ST_TankType(iTank)];
		flVelocity[2] += flJumpSporadicHeight;
		TeleportEntity(iTank, NULL_VECTOR, NULL_VECTOR, flVelocity);
	}

	return Plugin_Continue;
}

public Action tTimerJump3(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bJump2[iSurvivor] = false;
		g_iJumpOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[4];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bJump2[iSurvivor])
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iJumpEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if ((iJumpEnabled != 1 && iJumpEnabled != 3) || (flTime + flJumpDuration(iTank) < GetEngineTime()))
	{
		g_bJump4[iTank] = false;

		vReset2(iSurvivor, iTank, sMessage);

		if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bJump5[iTank])
		{
			g_bJump5[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "JumpHuman10");

			if (g_iJumpCount2[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
			{
				CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown2, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
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
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bJump3[iTank])
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
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bJump5[iTank])
	{
		g_bJump5[iTank] = false;

		return Plugin_Stop;
	}

	g_bJump5[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "JumpHuman12");

	return Plugin_Continue;
}