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

bool g_bCloneInstalled, g_bShake[MAXPLAYERS + 1], g_bShake2[MAXPLAYERS + 1], g_bShake3[MAXPLAYERS + 1], g_bShake4[MAXPLAYERS + 1], g_bShake5[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flShakeChance[ST_MAXTYPES + 1], g_flShakeDuration[ST_MAXTYPES + 1], g_flShakeInterval[ST_MAXTYPES + 1], g_flShakeRange[ST_MAXTYPES + 1], g_flShakeRangeChance[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iShakeAbility[ST_MAXTYPES + 1], g_iShakeCount[MAXPLAYERS + 1], g_iShakeEffect[ST_MAXTYPES + 1], g_iShakeHit[ST_MAXTYPES + 1], g_iShakeHitMode[ST_MAXTYPES + 1], g_iShakeMessage[ST_MAXTYPES + 1], g_iShakeOwner[MAXPLAYERS + 1];

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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iShakeAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iShakeCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "ShakeDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flShakeDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
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
		if ((g_iShakeHitMode[ST_GetTankType(attacker)] == 0 || g_iShakeHitMode[ST_GetTankType(attacker)] == 1) && ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsHumanSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vShakeHit(victim, attacker, g_flShakeChance[ST_GetTankType(attacker)], g_iShakeHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if ((g_iShakeHitMode[ST_GetTankType(victim)] == 0 || g_iShakeHitMode[ST_GetTankType(victim)] == 2) && ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vShakeHit(attacker, victim, g_flShakeChance[ST_GetTankType(victim)], g_iShakeHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
			}
		}
	}
}

public void ST_OnConfigsLoad()
{
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_iShakeAbility[iIndex] = 0;
		g_iShakeEffect[iIndex] = 0;
		g_iShakeMessage[iIndex] = 0;
		g_flShakeChance[iIndex] = 33.3;
		g_flShakeDuration[iIndex] = 5.0;
		g_iShakeHit[iIndex] = 0;
		g_iShakeHitMode[iIndex] = 0;
		g_flShakeInterval[iIndex] = 1.0;
		g_flShakeRange[iIndex] = 150.0;
		g_flShakeRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	ST_FindAbility(type, 52, bHasAbilities(subsection, "shakeability", "shake ability", "shake_ability", "shake"));
	g_iHumanAbility[type] = iGetValue(subsection, "shakeability", "shake ability", "shake_ability", "shake", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "shakeability", "shake ability", "shake_ability", "shake", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "shakeability", "shake ability", "shake_ability", "shake", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iShakeAbility[type] = iGetValue(subsection, "shakeability", "shake ability", "shake_ability", "shake", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iShakeAbility[type], value, 0, 0, 1);
	g_iShakeEffect[type] = iGetValue(subsection, "shakeability", "shake ability", "shake_ability", "shake", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iShakeEffect[type], value, 0, 0, 7);
	g_iShakeMessage[type] = iGetValue(subsection, "shakeability", "shake ability", "shake_ability", "shake", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iShakeMessage[type], value, 0, 0, 3);
	g_flShakeChance[type] = flGetValue(subsection, "shakeability", "shake ability", "shake_ability", "shake", key, "ShakeChance", "Shake Chance", "Shake_Chance", "chance", main, g_flShakeChance[type], value, 33.3, 0.0, 100.0);
	g_flShakeDuration[type] = flGetValue(subsection, "shakeability", "shake ability", "shake_ability", "shake", key, "ShakeDuration", "Shake Duration", "Shake_Duration", "duration", main, g_flShakeDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iShakeHit[type] = iGetValue(subsection, "shakeability", "shake ability", "shake_ability", "shake", key, "ShakeHit", "Shake Hit", "Shake_Hit", "hit", main, g_iShakeHit[type], value, 0, 0, 1);
	g_iShakeHitMode[type] = iGetValue(subsection, "shakeability", "shake ability", "shake_ability", "shake", key, "ShakeHitMode", "Shake Hit Mode", "Shake_Hit_Mode", "hitmode", main, g_iShakeHitMode[type], value, 0, 0, 2);
	g_flShakeInterval[type] = flGetValue(subsection, "shakeability", "shake ability", "shake_ability", "shake", key, "ShakeInterval", "Shake Interval", "Shake_Interval", "interval", main, g_flShakeInterval[type], value, 1.0, 0.1, 9999999999.0);
	g_flShakeRange[type] = flGetValue(subsection, "shakeability", "shake ability", "shake_ability", "shake", key, "ShakeRange", "Shake Range", "Shake_Range", "range", main, g_flShakeRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flShakeRangeChance[type] = flGetValue(subsection, "shakeability", "shake ability", "shake_ability", "shake", key, "ShakeRangeChance", "Shake Range Chance", "Shake_Range_Chance", "rangechance", main, g_flShakeRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			if (bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iShakeAbility[ST_GetTankType(iTank)] == 1)
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
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iShakeAbility[ST_GetTankType(tank)] == 1)
	{
		vShakeAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iShakeAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
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

public void ST_OnChangeType(int tank, bool revert)
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

	if (g_iShakeMessage[ST_GetTankType(tank)] & messages)
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
	if (g_iShakeCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bShake4[tank] = false;
		g_bShake5[tank] = false;

		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_flShakeRange[ST_GetTankType(tank)])
				{
					vShakeHit(iSurvivor, tank, g_flShakeRangeChance[ST_GetTankType(tank)], g_iShakeAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShakeHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShakeAmmo");
	}
}

static void vShakeHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iShakeCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bShake[survivor])
			{
				g_bShake[survivor] = true;
				g_iShakeOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bShake2[tank])
				{
					g_bShake2[tank] = true;
					g_iShakeCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShakeHuman", g_iShakeCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				DataPack dpShake;
				CreateDataTimer(g_flShakeInterval[ST_GetTankType(tank)], tTimerShake, dpShake, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpShake.WriteCell(GetClientUserId(survivor));
				dpShake.WriteCell(GetClientUserId(tank));
				dpShake.WriteCell(ST_GetTankType(tank));
				dpShake.WriteCell(messages);
				dpShake.WriteCell(enabled);
				dpShake.WriteFloat(GetEngineTime());

				vEffect(survivor, tank, g_iShakeEffect[ST_GetTankType(tank)], flags);

				if (g_iShakeMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Shake", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bShake2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bShake4[tank])
				{
					g_bShake4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShakeHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bShake5[tank])
		{
			g_bShake5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "ShakeAmmo");
		}
	}
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
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bShake[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iShakeEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iShakeEnabled == 0 || (flTime + g_flShakeDuration[ST_GetTankType(iTank)]) < GetEngineTime())
	{
		g_bShake2[iTank] = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bShake3[iTank])
		{
			g_bShake3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ShakeHuman6");

			if (g_iShakeCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
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
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bShake3[iTank])
	{
		g_bShake3[iTank] = false;

		return Plugin_Stop;
	}

	g_bShake3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ShakeHuman7");

	return Plugin_Continue;
}