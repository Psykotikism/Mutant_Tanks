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
	name = "[ST++] Shake Ability",
	author = ST_AUTHOR,
	description = "The Super Tank shakes the survivors' screens.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Shake Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_SHAKE "Shake Ability"

bool g_bCloneInstalled, g_bShake[MAXPLAYERS + 1], g_bShake2[MAXPLAYERS + 1], g_bShake3[MAXPLAYERS + 1], g_bShake4[MAXPLAYERS + 1], g_bShake5[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flShakeChance[ST_MAXTYPES + 1], g_flShakeChance2[ST_MAXTYPES + 1], g_flShakeDuration[ST_MAXTYPES + 1], g_flShakeDuration2[ST_MAXTYPES + 1], g_flShakeInterval[ST_MAXTYPES + 1], g_flShakeInterval2[ST_MAXTYPES + 1], g_flShakeRange[ST_MAXTYPES + 1], g_flShakeRange2[ST_MAXTYPES + 1], g_flShakeRangeChance[ST_MAXTYPES + 1], g_flShakeRangeChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iShakeAbility[ST_MAXTYPES + 1], g_iShakeAbility2[ST_MAXTYPES + 1], g_iShakeCount[MAXPLAYERS + 1], g_iShakeEffect[ST_MAXTYPES + 1], g_iShakeEffect2[ST_MAXTYPES + 1], g_iShakeHit[ST_MAXTYPES + 1], g_iShakeHit2[ST_MAXTYPES + 1], g_iShakeHitMode[ST_MAXTYPES + 1], g_iShakeHitMode2[ST_MAXTYPES + 1], g_iShakeMessage[ST_MAXTYPES + 1], g_iShakeMessage2[ST_MAXTYPES + 1], g_iShakeOwner[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_shake", cmdShakeInfo, "View information about the Shake ability.");

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

	vReset3(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdShakeInfo(int client, int args)
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
		case false: vShakeMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vShakeMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iShakeMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Shake Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iShakeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iShakeAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iShakeCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "ShakeDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flShakeDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vShakeMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "ShakeMenu", param1);
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
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Cooldown", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 4:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Details", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 5:
				{
					Format(sMenuOption, sizeof(sMenuOption), "%T", "Duration", param1);
					return RedrawMenuItem(sMenuOption);
				}
				case 6:
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
	menu.AddItem(ST_MENU_SHAKE, ST_MENU_SHAKE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_SHAKE, false))
	{
		vShakeMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iShakeHitMode(attacker) == 0 || iShakeHitMode(attacker) == 1) && ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && bIsHumanSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vShakeHit(victim, attacker, flShakeChance(attacker), iShakeHit(attacker), ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if ((iShakeHitMode(victim) == 0 || iShakeHitMode(victim) == 2) && ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vShakeHit(attacker, victim, flShakeChance(victim), iShakeHit(victim), ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Shake Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Shake Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iShakeAbility[iIndex] = kvSuperTanks.GetNum("Shake Ability/Ability Enabled", 0);
					g_iShakeAbility[iIndex] = iClamp(g_iShakeAbility[iIndex], 0, 1);
					g_iShakeEffect[iIndex] = kvSuperTanks.GetNum("Shake Ability/Ability Effect", 0);
					g_iShakeEffect[iIndex] = iClamp(g_iShakeEffect[iIndex], 0, 7);
					g_iShakeMessage[iIndex] = kvSuperTanks.GetNum("Shake Ability/Ability Message", 0);
					g_iShakeMessage[iIndex] = iClamp(g_iShakeMessage[iIndex], 0, 3);
					g_flShakeChance[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Chance", 33.3);
					g_flShakeChance[iIndex] = flClamp(g_flShakeChance[iIndex], 0.0, 100.0);
					g_flShakeDuration[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Duration", 5.0);
					g_flShakeDuration[iIndex] = flClamp(g_flShakeDuration[iIndex], 0.1, 9999999999.0);
					g_iShakeHit[iIndex] = kvSuperTanks.GetNum("Shake Ability/Shake Hit", 0);
					g_iShakeHit[iIndex] = iClamp(g_iShakeHit[iIndex], 0, 1);
					g_iShakeHitMode[iIndex] = kvSuperTanks.GetNum("Shake Ability/Shake Hit Mode", 0);
					g_iShakeHitMode[iIndex] = iClamp(g_iShakeHitMode[iIndex], 0, 2);
					g_flShakeInterval[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Interval", 1.0);
					g_flShakeInterval[iIndex] = flClamp(g_flShakeInterval[iIndex], 0.1, 9999999999.0);
					g_flShakeRange[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Range", 150.0);
					g_flShakeRange[iIndex] = flClamp(g_flShakeRange[iIndex], 1.0, 9999999999.0);
					g_flShakeRangeChance[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Range Chance", 15.0);
					g_flShakeRangeChance[iIndex] = flClamp(g_flShakeRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Shake Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Shake Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iShakeAbility2[iIndex] = kvSuperTanks.GetNum("Shake Ability/Ability Enabled", g_iShakeAbility[iIndex]);
					g_iShakeAbility2[iIndex] = iClamp(g_iShakeAbility2[iIndex], 0, 1);
					g_iShakeEffect2[iIndex] = kvSuperTanks.GetNum("Shake Ability/Ability Effect", g_iShakeEffect[iIndex]);
					g_iShakeEffect2[iIndex] = iClamp(g_iShakeEffect2[iIndex], 0, 7);
					g_iShakeMessage2[iIndex] = kvSuperTanks.GetNum("Shake Ability/Ability Message", g_iShakeMessage[iIndex]);
					g_iShakeMessage2[iIndex] = iClamp(g_iShakeMessage2[iIndex], 0, 3);
					g_flShakeChance2[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Chance", g_flShakeChance[iIndex]);
					g_flShakeChance2[iIndex] = flClamp(g_flShakeChance2[iIndex], 0.0, 100.0);
					g_flShakeDuration2[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Duration", g_flShakeDuration[iIndex]);
					g_flShakeDuration2[iIndex] = flClamp(g_flShakeDuration2[iIndex], 0.1, 9999999999.0);
					g_iShakeHit2[iIndex] = kvSuperTanks.GetNum("Shake Ability/Shake Hit", g_iShakeHit[iIndex]);
					g_iShakeHit2[iIndex] = iClamp(g_iShakeHit2[iIndex], 0, 1);
					g_iShakeHitMode2[iIndex] = kvSuperTanks.GetNum("Shake Ability/Shake Hit Mode", g_iShakeHitMode[iIndex]);
					g_iShakeHitMode2[iIndex] = iClamp(g_iShakeHitMode2[iIndex], 0, 2);
					g_flShakeInterval2[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Interval", g_flShakeInterval[iIndex]);
					g_flShakeInterval2[iIndex] = flClamp(g_flShakeInterval2[iIndex], 0.1, 9999999999.0);
					g_flShakeRange2[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Range", g_flShakeRange[iIndex]);
					g_flShakeRange2[iIndex] = flClamp(g_flShakeRange2[iIndex], 1.0, 9999999999.0);
					g_flShakeRangeChance2[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Range Chance", g_flShakeRangeChance[iIndex]);
					g_flShakeRangeChance2[iIndex] = flClamp(g_flShakeRangeChance2[iIndex], 0.0, 100.0);
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
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			if (ST_IsCloneSupported(iTank, g_bCloneInstalled) && iShakeAbility(iTank) == 1)
			{
				float flTankPos[3];
				GetClientAbsOrigin(iTank, flTankPos);

				for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
				{
					if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
					{
						float flSurvivorPos[3];
						GetClientAbsOrigin(iSurvivor, flSurvivorPos);

						float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
						if (flDistance <= 200.0)
						{
							vShake(iTank, 2.0);
						}
					}
				}
			}

			vRemoveShake(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iShakeAbility(tank) == 1)
	{
		vShakeAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iShakeAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bShake2[tank] && !g_bShake3[tank])
				{
					vShakeAbility(tank);
				}
				else if (g_bShake2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShakeHuman3");
				}
				else if (g_bShake3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShakeHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveShake(tank);
}

static void vRemoveShake(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bShake[iSurvivor] && g_iShakeOwner[iSurvivor] == tank)
		{
			g_bShake[iSurvivor] = false;
			g_iShakeOwner[iSurvivor] = 0;
		}
	}

	vReset3(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vReset3(iPlayer);

			g_iShakeOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_bShake[survivor] = false;
	g_iShakeOwner[survivor] = 0;

	if (iShakeMessage(tank) & messages)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Shake2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bShake[tank] = false;
	g_bShake2[tank] = false;
	g_bShake3[tank] = false;
	g_bShake4[tank] = false;
	g_bShake5[tank] = false;
	g_iShakeCount[tank] = 0;
}

static void vShake(int survivor, float duration = 1.0)
{
	Handle hShakeTarget = StartMessageOne("Shake", survivor);
	if (hShakeTarget != null)
	{
		BfWrite bfWrite = UserMessageToBfWrite(hShakeTarget);
		bfWrite.WriteByte(0);
		bfWrite.WriteFloat(16.0);
		bfWrite.WriteFloat(0.5);
		bfWrite.WriteFloat(duration);
		EndMessage();
	}
}

static void vShakeAbility(int tank)
{
	if (g_iShakeCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bShake4[tank] = false;
		g_bShake5[tank] = false;

		float flShakeRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flShakeRange[ST_GetTankType(tank)] : g_flShakeRange2[ST_GetTankType(tank)],
			flShakeRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flShakeRangeChance[ST_GetTankType(tank)] : g_flShakeRangeChance2[ST_GetTankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flShakeRange)
				{
					vShakeHit(iSurvivor, tank, flShakeRangeChance, iShakeAbility(tank), ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShakeHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShakeAmmo");
	}
}

static void vShakeHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iShakeCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bShake[survivor])
			{
				g_bShake[survivor] = true;
				g_iShakeOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && (flags & ST_ATTACK_RANGE) && !g_bShake2[tank])
				{
					g_bShake2[tank] = true;
					g_iShakeCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShakeHuman", g_iShakeCount[tank], iHumanAmmo(tank));
				}

				float flShakeInterval = !g_bTankConfig[ST_GetTankType(tank)] ? g_flShakeInterval[ST_GetTankType(tank)] : g_flShakeInterval2[ST_GetTankType(tank)];
				DataPack dpShake;
				CreateDataTimer(flShakeInterval, tTimerShake, dpShake, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpShake.WriteCell(GetClientUserId(survivor));
				dpShake.WriteCell(GetClientUserId(tank));
				dpShake.WriteCell(ST_GetTankType(tank));
				dpShake.WriteCell(messages);
				dpShake.WriteCell(enabled);
				dpShake.WriteFloat(GetEngineTime());

				int iShakeEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_iShakeEffect[ST_GetTankType(tank)] : g_iShakeEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, iShakeEffect, flags);

				if (iShakeMessage(tank) & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Shake", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bShake2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && !g_bShake4[tank])
				{
					g_bShake4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShakeHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && !g_bShake5[tank])
		{
			g_bShake5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShakeAmmo");
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flShakeChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flShakeChance[ST_GetTankType(tank)] : g_flShakeChance2[ST_GetTankType(tank)];
}

static float flShakeDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flShakeDuration[ST_GetTankType(tank)] : g_flShakeDuration2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iShakeAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iShakeAbility[ST_GetTankType(tank)] : g_iShakeAbility2[ST_GetTankType(tank)];
}

static int iShakeHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iShakeHit[ST_GetTankType(tank)] : g_iShakeHit2[ST_GetTankType(tank)];
}

static int iShakeHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iShakeHitMode[ST_GetTankType(tank)] : g_iShakeHitMode2[ST_GetTankType(tank)];
}

static int iShakeMessage(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iShakeMessage[ST_GetTankType(tank)] : g_iShakeMessage2[ST_GetTankType(tank)];
}

public Action tTimerShake(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsHumanSurvivor(iSurvivor))
	{
		g_bShake[iSurvivor] = false;
		g_iShakeOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bShake[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iShakeEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iShakeEnabled == 0 || (flTime + flShakeDuration(iTank)) < GetEngineTime())
	{
		g_bShake2[iTank] = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && iHumanAbility(iTank) == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bShake3[iTank])
		{
			g_bShake3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ShakeHuman6");

			if (g_iShakeCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
			{
				CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bShake3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	vShake(iSurvivor);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bShake3[iTank])
	{
		g_bShake3[iTank] = false;

		return Plugin_Stop;
	}

	g_bShake3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ShakeHuman7");

	return Plugin_Continue;
}