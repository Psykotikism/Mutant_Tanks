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
	name = "[ST++] Heal Ability",
	author = ST_AUTHOR,
	description = "The Super Tank gains health from other nearby infected and sets survivors to temporary health who will die when they reach 0 HP.",
	version = ST_VERSION,
	url = ST_URL
};

#define SOUND_HEARTBEAT	 "player/heartbeatloop.wav"

#define ST_MENU_HEAL "Heal Ability"

bool g_bCloneInstalled, g_bHeal[MAXPLAYERS + 1], g_bHeal2[MAXPLAYERS + 1], g_bHeal3[MAXPLAYERS + 1], g_bHeal4[MAXPLAYERS + 1], g_bHeal5[MAXPLAYERS + 1], g_bHeal6[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sHealEffect[ST_MAXTYPES + 1][4], g_sHealEffect2[ST_MAXTYPES + 1][4], g_sHealMessage[ST_MAXTYPES + 1][4], g_sHealMessage2[ST_MAXTYPES + 1][4];

ConVar g_cvSTMaxIncapCount;

float g_flHealHealRange[ST_MAXTYPES + 1], g_flHealHealRange2[ST_MAXTYPES + 1], g_flHealBuffer[ST_MAXTYPES + 1], g_flHealBuffer2[ST_MAXTYPES + 1], g_flHealChance[ST_MAXTYPES + 1], g_flHealChance2[ST_MAXTYPES + 1], g_flHealInterval[ST_MAXTYPES + 1], g_flHealInterval2[ST_MAXTYPES + 1], g_flHealRange[ST_MAXTYPES + 1], g_flHealRange2[ST_MAXTYPES + 1], g_flHealRangeChance[ST_MAXTYPES + 1], g_flHealRangeChance2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flHumanDuration[ST_MAXTYPES + 1], g_flHumanDuration2[ST_MAXTYPES + 1];

int g_iHealAbility[ST_MAXTYPES + 1], g_iHealAbility2[ST_MAXTYPES + 1], g_iHealCommon[ST_MAXTYPES + 1], g_iHealCommon2[ST_MAXTYPES + 1], g_iHealCount[MAXPLAYERS + 1], g_iHealCount2[MAXPLAYERS + 1], g_iHealHit[ST_MAXTYPES + 1], g_iHealHit2[ST_MAXTYPES + 1], g_iHealHitMode[ST_MAXTYPES + 1], g_iHealHitMode2[ST_MAXTYPES + 1], g_iHealSpecial[ST_MAXTYPES + 1], g_iHealSpecial2[ST_MAXTYPES + 1], g_iHealTank[ST_MAXTYPES + 1], g_iHealTank2[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iHumanMode[ST_MAXTYPES + 1], g_iHumanMode2[ST_MAXTYPES + 1];

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

	if (!bIsValidClient(client, "0245"))
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHealAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iHealCount[param1], iHumanAmmo(param1));
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo2", iHumanAmmo(param1) - g_iHealCount2[param1], iHumanAmmo(param1));
				}
				case 2:
				{
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons");
					ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				}
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanMode(param1) == 0 ? "AbilityButtonMode1" : "AbilityButtonMode2");
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "HealDetails");
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flHumanDuration(param1));
				case 7: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
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
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && (iHealHitMode(attacker) == 0 || iHealHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHealHit(victim, attacker, flHealChance(attacker), iHealHit(attacker), "1", "1");
			}
		}
		else if (ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && (iHealHitMode(victim) == 0 || iHealHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vHealHit(attacker, victim, flHealChance(victim), iHealHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Heal Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Heal Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_flHumanDuration[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Human Duration", 5.0);
					g_flHumanDuration[iIndex] = flClamp(g_flHumanDuration[iIndex], 0.1, 9999999999.0);
					g_iHumanMode[iIndex] = kvSuperTanks.GetNum("Heal Ability/Human Mode", 1);
					g_iHumanMode[iIndex] = iClamp(g_iHumanMode[iIndex], 0, 1);
					g_iHealAbility[iIndex] = kvSuperTanks.GetNum("Heal Ability/Ability Enabled", 0);
					g_iHealAbility[iIndex] = iClamp(g_iHealAbility[iIndex], 0, 3);
					kvSuperTanks.GetString("Heal Ability/Ability Effect", g_sHealEffect[iIndex], sizeof(g_sHealEffect[]), "0");
					kvSuperTanks.GetString("Heal Ability/Ability Message", g_sHealMessage[iIndex], sizeof(g_sHealMessage[]), "0");
					g_flHealHealRange[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Heal Range", 500.0);
					g_flHealHealRange[iIndex] = flClamp(g_flHealHealRange[iIndex], 1.0, 9999999999.0);
					g_flHealBuffer[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Buffer", 25.0);
					g_flHealBuffer[iIndex] = flClamp(g_flHealBuffer[iIndex], 1.0, float(ST_MAXHEALTH));
					g_flHealChance[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Chance", 33.3);
					g_flHealChance[iIndex] = flClamp(g_flHealChance[iIndex], 0.0, 100.0);
					g_iHealCommon[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Commons", 50);
					g_iHealCommon[iIndex] = iClamp(g_iHealCommon[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
					g_iHealHit[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Hit", 0);
					g_iHealHit[iIndex] = iClamp(g_iHealHit[iIndex], 0, 1);
					g_iHealHitMode[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Hit Mode", 0);
					g_iHealHitMode[iIndex] = iClamp(g_iHealHitMode[iIndex], 0, 2);
					g_flHealInterval[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Interval", 5.0);
					g_flHealInterval[iIndex] = flClamp(g_flHealInterval[iIndex], 0.1, 9999999999.0);
					g_flHealRange[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Range", 150.0);
					g_flHealRange[iIndex] = flClamp(g_flHealRange[iIndex], 1.0, 9999999999.0);
					g_flHealRangeChance[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Range Chance", 15.0);
					g_flHealRangeChance[iIndex] = flClamp(g_flHealRangeChance[iIndex], 0.0, 100.0);
					g_iHealSpecial[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Specials", 100);
					g_iHealSpecial[iIndex] = iClamp(g_iHealSpecial[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
					g_iHealTank[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Tanks", 500);
					g_iHealTank[iIndex] = iClamp(g_iHealTank[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_flHumanDuration2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Human Duration", g_flHumanDuration[iIndex]);
					g_flHumanDuration2[iIndex] = flClamp(g_flHumanDuration2[iIndex], 0.1, 9999999999.0);
					g_iHumanMode2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Human Mode", g_iHumanMode[iIndex]);
					g_iHumanMode2[iIndex] = iClamp(g_iHumanMode2[iIndex], 0, 1);
					g_iHealAbility2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Ability Enabled", g_iHealAbility[iIndex]);
					g_iHealAbility2[iIndex] = iClamp(g_iHealAbility2[iIndex], 0, 3);
					kvSuperTanks.GetString("Heal Ability/Ability Effect", g_sHealEffect2[iIndex], sizeof(g_sHealEffect2[]), g_sHealEffect[iIndex]);
					kvSuperTanks.GetString("Heal Ability/Ability Message", g_sHealMessage2[iIndex], sizeof(g_sHealMessage2[]), g_sHealMessage[iIndex]);
					g_flHealHealRange2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Heal Range", g_flHealHealRange[iIndex]);
					g_flHealHealRange2[iIndex] = flClamp(g_flHealHealRange2[iIndex], 1.0, 9999999999.0);
					g_flHealBuffer2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Buffer", g_flHealBuffer[iIndex]);
					g_flHealBuffer2[iIndex] = flClamp(g_flHealBuffer2[iIndex], 1.0, float(ST_MAXHEALTH));
					g_flHealChance2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Chance", g_flHealChance[iIndex]);
					g_flHealChance2[iIndex] = flClamp(g_flHealChance2[iIndex], 0.0, 100.0);
					g_iHealCommon2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Commons", g_iHealCommon[iIndex]);
					g_iHealCommon2[iIndex] = iClamp(g_iHealCommon2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
					g_iHealHit2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Hit", g_iHealHit[iIndex]);
					g_iHealHit2[iIndex] = iClamp(g_iHealHit2[iIndex], 0, 1);
					g_iHealHitMode2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Hit Mode", g_iHealHitMode[iIndex]);
					g_iHealHitMode2[iIndex] = iClamp(g_iHealHitMode2[iIndex], 0, 2);
					g_flHealInterval2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Interval", g_flHealInterval[iIndex]);
					g_flHealInterval2[iIndex] = flClamp(g_flHealInterval2[iIndex], 0.1, 9999999999.0);
					g_flHealRange2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Range", g_flHealRange[iIndex]);
					g_flHealRange2[iIndex] = flClamp(g_flHealRange2[iIndex], 1.0, 9999999999.0);
					g_flHealRangeChance2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Range Chance", g_flHealRangeChance[iIndex]);
					g_flHealRangeChance2[iIndex] = flClamp(g_flHealRangeChance2[iIndex], 0.0, 100.0);
					g_iHealSpecial2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Specials", g_iHealSpecial[iIndex]);
					g_iHealSpecial2[iIndex] = iClamp(g_iHealSpecial2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
					g_iHealTank2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Tanks", g_iHealTank[iIndex]);
					g_iHealTank2[iIndex] = iClamp(g_iHealTank2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				}
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
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
		else if (ST_IsTankSupported(iPlayer, "024"))
		{
			vRemoveHeal(iPlayer);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, "5") || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iHealAbility(tank) > 0)
	{
		vHealAbility(tank, true);
		vHealAbility(tank, false);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if ((iHealAbility(tank) == 2 || iHealAbility(tank) == 3) && iHumanAbility(tank) == 1)
			{
				switch (iHumanMode(tank))
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
						if (g_iHealCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							if (!g_bHeal[tank] && !g_bHeal2[tank])
							{
								g_bHeal[tank] = true;
								g_iHealCount[tank]++;

								vHeal(tank);

								ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealHuman", g_iHealCount[tank], iHumanAmmo(tank));
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
			if ((iHealAbility(tank) == 1 || iHealAbility(tank) == 3) && iHumanAbility(tank) == 1)
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
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_MAIN_KEY == ST_MAIN_KEY)
		{
			if ((iHealAbility(tank) == 2 || iHealAbility(tank) == 3) && iHumanAbility(tank) == 1)
			{
				if (iHumanMode(tank) == 1 && g_bHeal[tank] && !g_bHeal2[tank])
				{
					vReset2(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveHeal(tank);
}

static void vHeal(int tank)
{
	float flHealInterval = !g_bTankConfig[ST_GetTankType(tank)] ? g_flHealInterval[ST_GetTankType(tank)] : g_flHealInterval2[ST_GetTankType(tank)];
	DataPack dpHeal;
	CreateDataTimer(flHealInterval, tTimerHeal, dpHeal, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpHeal.WriteCell(GetClientUserId(tank));
	dpHeal.WriteFloat(GetEngineTime());
}

static void vHealAbility(int tank, bool main)
{
	switch (main)
	{
		case true:
		{
			if (iHealAbility(tank) == 1 || iHealAbility(tank) == 3)
			{
				if (g_iHealCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
				{
					g_bHeal5[tank] = false;
					g_bHeal6[tank] = false;

					float flHealRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flHealRange[ST_GetTankType(tank)] : g_flHealRange2[ST_GetTankType(tank)],
						flHealRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flHealRangeChance[ST_GetTankType(tank)] : g_flHealRangeChance2[ST_GetTankType(tank)],
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
							if (flDistance <= flHealRange)
							{
								vHealHit(iSurvivor, tank, flHealRangeChance, iHealAbility(tank), "2", "3");

								iSurvivorCount++;
							}
						}
					}

					if (iSurvivorCount == 0)
					{
						if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
						{
							ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealHuman7");
						}
					}
				}
				else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealAmmo2");
				}
			}
		}
		case false:
		{
			if ((iHealAbility(tank) == 2 || iHealAbility(tank) == 3) && !g_bHeal[tank])
			{
				if (g_iHealCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
				{
					g_bHeal[tank] = true;

					if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
					{
						g_iHealCount[tank]++;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealHuman", g_iHealCount[tank], iHumanAmmo(tank));
					}

					vHeal(tank);

					char sHealMessage[4];
					sHealMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sHealMessage[ST_GetTankType(tank)] : g_sHealMessage2[ST_GetTankType(tank)];
					if (StrContains(sHealMessage, "3") != -1)
					{
						char sTankName[33];
						ST_GetTankName(tank, sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Heal2", sTankName);
					}
				}
				else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealAmmo");
				}
			}
		}
	}
}

static void vHealHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if ((enabled == 1 || enabled == 3) && bIsSurvivor(survivor))
	{
		if (g_iHealCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bHeal4[survivor])
			{
				int iHealth = GetClientHealth(survivor);
				if (iHealth > 0 && !bIsPlayerIncapacitated(survivor))
				{
					g_bHeal4[survivor] = true;

					if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bHeal3[tank])
					{
						g_bHeal3[tank] = true;
						g_iHealCount2[tank]++;

						ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealHuman2", g_iHealCount2[tank], iHumanAmmo(tank));

						if (g_iHealCount2[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
						{
							CreateTimer(flHumanCooldown(tank), tTimerResetCooldown2, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
						}
						else
						{
							g_bHeal3[tank] = false;
						}
					}

					float flHealBuffer = !g_bTankConfig[ST_GetTankType(tank)] ? g_flHealBuffer[ST_GetTankType(tank)] : g_flHealBuffer2[ST_GetTankType(tank)];
					SetEntityHealth(survivor, 1);
					SetEntPropFloat(survivor, Prop_Send, "m_healthBufferTime", GetGameTime());
					SetEntPropFloat(survivor, Prop_Send, "m_healthBuffer", flHealBuffer);
					SetEntProp(survivor, Prop_Send, "m_currentReviveCount", g_cvSTMaxIncapCount.IntValue);

					char sHealEffect[4];
					sHealEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_sHealEffect[ST_GetTankType(tank)] : g_sHealEffect2[ST_GetTankType(tank)];
					vEffect(survivor, tank, sHealEffect, mode);

					char sHealMessage[4];
					sHealMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sHealMessage[ST_GetTankType(tank)] : g_sHealMessage2[ST_GetTankType(tank)];
					if (StrContains(sHealMessage, message) != -1)
					{
						char sTankName[33];
						ST_GetTankName(tank, sTankName);
						ST_PrintToChatAll("%s %t", ST_TAG2, "Heal", sTankName, survivor);
					}
				}
			}
			else if (StrEqual(mode, "3") && !g_bHeal3[tank])
			{
				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bHeal5[tank])
				{
					g_bHeal5[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "HealHuman3");
				}
			}
		}
		else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bHeal6[tank])
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
		if (bIsValidClient(iPlayer, "24"))
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

	if (g_iHealCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
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
			int iGlowRed, iGlowGreen, iGlowBlue, iGlowAlpha;
			ST_GetTankColors(tank, 2, iGlowRed, iGlowGreen, iGlowBlue, iGlowAlpha);
			SetEntProp(tank, Prop_Send, "m_iGlowType", 3);
			SetEntProp(tank, Prop_Send, "m_glowColorOverride", iGetRGBColor(iGlowRed, iGlowGreen, iGlowBlue));
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

static float flHealChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHealChance[ST_GetTankType(tank)] : g_flHealChance2[ST_GetTankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flHumanDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanDuration[ST_GetTankType(tank)] : g_flHumanDuration2[ST_GetTankType(tank)];
}

static int iHealAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHealAbility[ST_GetTankType(tank)] : g_iHealAbility2[ST_GetTankType(tank)];
}

static int iHealHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHealHit[ST_GetTankType(tank)] : g_iHealHit2[ST_GetTankType(tank)];
}

static int iHealHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHealHitMode[ST_GetTankType(tank)] : g_iHealHitMode2[ST_GetTankType(tank)];
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

public Action tTimerHeal(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || (iHealAbility(iTank) != 2 && iHealAbility(iTank) != 3) || !g_bHeal[iTank])
	{
		g_bHeal[iTank] = false;

		vResetGlow(iTank);

		char sHealMessage[4];
		sHealMessage = !g_bTankConfig[ST_GetTankType(iTank)] ? g_sHealMessage[ST_GetTankType(iTank)] : g_sHealMessage2[ST_GetTankType(iTank)];
		if (StrContains(sHealMessage, "3") != -1)
		{
			char sTankName[33];
			ST_GetTankName(iTank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Heal3", sTankName);
		}

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if (ST_IsTankSupported(iTank, "5") && iHumanAbility(iTank) == 1 && iHumanMode(iTank) == 0 && (flTime + flHumanDuration(iTank)) < GetEngineTime() && !g_bHeal2[iTank])
	{
		vReset2(iTank);

		return Plugin_Stop;
	}

	int iType, iSpecial = -1;
	float flHealHealRange = !g_bTankConfig[ST_GetTankType(iTank)] ? g_flHealHealRange[ST_GetTankType(iTank)] : g_flHealHealRange2[ST_GetTankType(iTank)];

	while ((iSpecial = FindEntityByClassname(iSpecial, "infected")) != INVALID_ENT_REFERENCE)
	{
		float flTankPos[3], flInfectedPos[3];
		GetClientAbsOrigin(iTank, flTankPos);
		GetEntPropVector(iSpecial, Prop_Send, "m_vecOrigin", flInfectedPos);

		float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
		if (flDistance <= flHealHealRange)
		{
			int iHealth = GetClientHealth(iTank),
				iCommonHealth = !g_bTankConfig[ST_GetTankType(iTank)] ? (iHealth + g_iHealCommon[ST_GetTankType(iTank)]) : (iHealth + g_iHealCommon2[ST_GetTankType(iTank)]),
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

				iType = 1;
			}
		}
	}

	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (bIsSpecialInfected(iInfected, "234"))
		{
			float flTankPos[3], flInfectedPos[3];
			GetClientAbsOrigin(iTank, flTankPos);
			GetClientAbsOrigin(iInfected, flInfectedPos);

			float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
			if (flDistance <= flHealHealRange)
			{
				int iHealth = GetClientHealth(iTank),
					iSpecialHealth = !g_bTankConfig[ST_GetTankType(iTank)] ? (iHealth + g_iHealSpecial[ST_GetTankType(iTank)]) : (iHealth + g_iHealSpecial2[ST_GetTankType(iTank)]),
					iExtraHealth = (iSpecialHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iSpecialHealth,
					iExtraHealth2 = (iSpecialHealth < iHealth) ? 1 : iSpecialHealth,
					iRealHealth = (iSpecialHealth >= 0) ? iExtraHealth : iExtraHealth2;
				if (iHealth > 500)
				{
					SetEntityHealth(iTank, iRealHealth);

					if (iType < 2)
					{
						if (bIsValidGame())
						{
							SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
							SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 220, 0));
							SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);
						}

						iType = 1;
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
			if (flDistance <= flHealHealRange)
			{
				int iHealth = GetClientHealth(iTank),
					iTankHealth = !g_bTankConfig[ST_GetTankType(iTank)] ? (iHealth + g_iHealTank[ST_GetTankType(iTank)]) : (iHealth + g_iHealTank2[ST_GetTankType(iTank)]),
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

					iType = 2;
				}
			}
		}
	}

	if (iType == 0 && bIsValidGame())
	{
		vResetGlow(iTank);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bHeal2[iTank])
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
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bHeal3[iTank])
	{
		g_bHeal3[iTank] = false;

		return Plugin_Stop;
	}

	g_bHeal3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "HealHuman10");

	return Plugin_Continue;
}