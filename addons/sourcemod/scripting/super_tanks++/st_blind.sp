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
	name = "[ST++] Blind Ability",
	author = ST_AUTHOR,
	description = "The Super Tank blinds survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Blind Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_BLIND "Blind Ability"

bool g_bBlind[MAXPLAYERS + 1], g_bBlind2[MAXPLAYERS + 1], g_bBlind3[MAXPLAYERS + 1], g_bBlind4[MAXPLAYERS + 1], g_bBlind5[MAXPLAYERS + 1], g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1];

float g_flBlindChance[ST_MAXTYPES + 1], g_flBlindChance2[ST_MAXTYPES + 1], g_flBlindDuration[ST_MAXTYPES + 1], g_flBlindDuration2[ST_MAXTYPES + 1], g_flBlindRange[ST_MAXTYPES + 1], g_flBlindRange2[ST_MAXTYPES + 1], g_flBlindRangeChance[ST_MAXTYPES + 1], g_flBlindRangeChance2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

int g_iBlindAbility[ST_MAXTYPES + 1], g_iBlindAbility2[ST_MAXTYPES + 1], g_iBlindCount[MAXPLAYERS + 1], g_iBlindEffect[ST_MAXTYPES + 1], g_iBlindEffect2[ST_MAXTYPES + 1], g_iBlindHit[ST_MAXTYPES + 1], g_iBlindHit2[ST_MAXTYPES + 1], g_iBlindHitMode[ST_MAXTYPES + 1], g_iBlindHitMode2[ST_MAXTYPES + 1], g_iBlindIntensity[ST_MAXTYPES + 1], g_iBlindIntensity2[ST_MAXTYPES + 1], g_iBlindMessage[ST_MAXTYPES + 1], g_iBlindMessage2[ST_MAXTYPES + 1], g_iBlindOwner[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1];

UserMsg g_umFadeUserMsgId;

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

	RegConsoleCmd("sm_st_blind", cmdBlindInfo, "View information about the Blind ability.");

	g_umFadeUserMsgId = GetUserMessageId("Fade");

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

	vReset2(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdBlindInfo(int client, int args)
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
		case false: vBlindMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vBlindMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iBlindMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Blind Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iBlindMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iBlindAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iBlindCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "BlindDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flBlindDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vBlindMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "BlindMenu", param1);
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
	menu.AddItem(ST_MENU_BLIND, ST_MENU_BLIND);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_BLIND, false))
	{
		vBlindMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && (iBlindHitMode(attacker) == 0 || iBlindHitMode(attacker) == 1) && bIsHumanSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vBlindHit(victim, attacker, flBlindChance(attacker), iBlindHit(attacker), ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && (iBlindHitMode(victim) == 0 || iBlindHitMode(victim) == 2) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vBlindHit(attacker, victim, flBlindChance(victim), iBlindHit(victim), ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Blind Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Blind Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iBlindAbility[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Enabled", 0);
					g_iBlindAbility[iIndex] = iClamp(g_iBlindAbility[iIndex], 0, 1);
					g_iBlindEffect[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Effect", 0);
					g_iBlindEffect[iIndex] = iClamp(g_iBlindEffect[iIndex], 0, 7);
					g_iBlindMessage[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Message", 0);
					g_iBlindMessage[iIndex] = iClamp(g_iBlindMessage[iIndex], 0, 3);
					g_flBlindChance[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Chance", 33.3);
					g_flBlindChance[iIndex] = flClamp(g_flBlindChance[iIndex], 0.0, 100.0);
					g_flBlindDuration[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Duration", 5.0);
					g_flBlindDuration[iIndex] = flClamp(g_flBlindDuration[iIndex], 0.1, 9999999999.0);
					g_iBlindHit[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Hit", 0);
					g_iBlindHit[iIndex] = iClamp(g_iBlindHit[iIndex], 0, 1);
					g_iBlindHitMode[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Hit Mode", 0);
					g_iBlindHitMode[iIndex] = iClamp(g_iBlindHitMode[iIndex], 0, 2);
					g_iBlindIntensity[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Intensity", 255);
					g_iBlindIntensity[iIndex] = iClamp(g_iBlindIntensity[iIndex], 0, 255);
					g_flBlindRange[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Range", 150.0);
					g_flBlindRange[iIndex] = flClamp(g_flBlindRange[iIndex], 1.0, 9999999999.0);
					g_flBlindRangeChance[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Range Chance", 15.0);
					g_flBlindRangeChance[iIndex] = flClamp(g_flBlindRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iBlindAbility2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Enabled", g_iBlindAbility[iIndex]);
					g_iBlindAbility2[iIndex] = iClamp(g_iBlindAbility2[iIndex], 0, 1);
					g_iBlindEffect2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Effect", g_iBlindEffect[iIndex]);
					g_iBlindEffect2[iIndex] = iClamp(g_iBlindEffect2[iIndex], 0, 7);
					g_iBlindMessage2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Message", g_iBlindMessage[iIndex]);
					g_iBlindMessage2[iIndex] = iClamp(g_iBlindMessage2[iIndex], 0, 3);
					g_flBlindChance2[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Chance", g_flBlindChance[iIndex]);
					g_flBlindChance2[iIndex] = flClamp(g_flBlindChance2[iIndex], 0.0, 100.0);
					g_flBlindDuration2[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Duration", g_flBlindDuration[iIndex]);
					g_flBlindDuration2[iIndex] = flClamp(g_flBlindDuration2[iIndex], 0.1, 9999999999.0);
					g_iBlindHit2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Hit", g_iBlindHit[iIndex]);
					g_iBlindHit2[iIndex] = iClamp(g_iBlindHit2[iIndex], 0, 1);
					g_iBlindHitMode2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Hit Mode", g_iBlindHitMode[iIndex]);
					g_iBlindHitMode2[iIndex] = iClamp(g_iBlindHitMode2[iIndex], 0, 2);
					g_iBlindIntensity2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Intensity", g_iBlindIntensity[iIndex]);
					g_iBlindIntensity2[iIndex] = iClamp(g_iBlindIntensity2[iIndex], 0, 255);
					g_flBlindRange2[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Range", g_flBlindRange[iIndex]);
					g_flBlindRange2[iIndex] = flClamp(g_flBlindRange2[iIndex], 1.0, 9999999999.0);
					g_flBlindRangeChance2[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Range Chance", g_flBlindRangeChance[iIndex]);
					g_flBlindRangeChance2[iIndex] = flClamp(g_flBlindRangeChance2[iIndex], 0.0, 100.0);
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
		if (bIsTank(iTank, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
		{
			vRemoveBlind(iTank);
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
			vRemoveBlind(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iBlindAbility(tank) == 1)
	{
		vBlindAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iBlindAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bBlind2[tank] && !g_bBlind3[tank])
				{
					vBlindAbility(tank);
				}
				else if (g_bBlind2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "BlindHuman3");
				}
				else if (g_bBlind3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "BlindHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveBlind(tank);
}

static void vBlind(int survivor, int intensity)
{
	int iTargets[2], iFlags = intensity == 0 ? (0x0001|0x0010) : (0x0002|0x0008), iColor[4] = {0, 0, 0, 0};

	iTargets[0] = survivor;
	iColor[3] = intensity;

	Handle hBlindTarget = StartMessageEx(g_umFadeUserMsgId, iTargets, 1);
	switch (GetUserMessageType() == UM_Protobuf)
	{
		case true:
		{
			Protobuf pbSet = UserMessageToProtobuf(hBlindTarget);
			pbSet.SetInt("duration", 1536);
			pbSet.SetInt("hold_time", 1536);
			pbSet.SetInt("flags", iFlags);
			pbSet.SetColor("clr", iColor);
		}
		case false:
		{
			BfWrite bfWrite = UserMessageToBfWrite(hBlindTarget);
			bfWrite.WriteShort(1536);
			bfWrite.WriteShort(1536);
			bfWrite.WriteShort(iFlags);
			bfWrite.WriteByte(iColor[0]);
			bfWrite.WriteByte(iColor[1]);
			bfWrite.WriteByte(iColor[2]);
			bfWrite.WriteByte(iColor[3]);
		}
	}

	EndMessage();
}

static void vBlindAbility(int tank)
{
	if (g_iBlindCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bBlind4[tank] = false;
		g_bBlind5[tank] = false;

		float flBlindRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flBlindRange[ST_GetTankType(tank)] : g_flBlindRange2[ST_GetTankType(tank)],
			flBlindRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flBlindRangeChance[ST_GetTankType(tank)] : g_flBlindRangeChance2[ST_GetTankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flBlindRange)
				{
					vBlindHit(iSurvivor, tank, flBlindRangeChance, iBlindAbility(tank), ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "BlindHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "BlindAmmo");
	}
}

static void vBlindHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsHumanSurvivor(survivor))
	{
		if (g_iBlindCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bBlind[survivor])
			{
				g_bBlind[survivor] = true;
				g_iBlindOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && (flags & ST_ATTACK_RANGE) && !g_bBlind2[tank])
				{
					g_bBlind2[tank] = true;
					g_iBlindCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "BlindHuman", g_iBlindCount[tank], iHumanAmmo(tank));
				}

				DataPack dpBlind;
				CreateDataTimer(1.0, tTimerBlind, dpBlind, TIMER_FLAG_NO_MAPCHANGE);
				dpBlind.WriteCell(GetClientUserId(survivor));
				dpBlind.WriteCell(GetClientUserId(tank));
				dpBlind.WriteCell(ST_GetTankType(tank));
				dpBlind.WriteCell(enabled);

				DataPack dpStopBlind;
				CreateDataTimer(flBlindDuration(tank) + 1.0, tTimerStopBlind, dpStopBlind, TIMER_FLAG_NO_MAPCHANGE);
				dpStopBlind.WriteCell(GetClientUserId(survivor));
				dpStopBlind.WriteCell(GetClientUserId(tank));
				dpStopBlind.WriteCell(messages);

				int iBlindEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_iBlindEffect[ST_GetTankType(tank)] : g_iBlindEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, iBlindEffect, flags);

				if (iBlindMessage(tank) & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Blind", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bBlind2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && !g_bBlind4[tank])
				{
					g_bBlind4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "BlindHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && iHumanAbility(tank) == 1 && !g_bBlind5[tank])
		{
			g_bBlind5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "BlindAmmo");
		}
	}
}

static void vRemoveBlind(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bBlind[iSurvivor] && g_iBlindOwner[iSurvivor] == tank)
		{
			vBlind(iSurvivor, 0);

			g_bBlind[iSurvivor] = false;
			g_iBlindOwner[iSurvivor] = 0;
		}
	}

	vReset2(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vReset2(iPlayer);

			g_iBlindOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int tank)
{
	g_bBlind[tank] = false;
	g_bBlind2[tank] = false;
	g_bBlind3[tank] = false;
	g_bBlind4[tank] = false;
	g_bBlind5[tank] = false;
	g_iBlindCount[tank] = 0;
}

static float flBlindChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flBlindChance[ST_GetTankType(tank)] : g_flBlindChance2[ST_GetTankType(tank)];
}

static float flBlindDuration(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flBlindDuration[ST_GetTankType(tank)] : g_flBlindDuration2[ST_GetTankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static int iBlindAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iBlindAbility[ST_GetTankType(tank)] : g_iBlindAbility2[ST_GetTankType(tank)];
}

static int iBlindHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iBlindHit[ST_GetTankType(tank)] : g_iBlindHit2[ST_GetTankType(tank)];
}

static int iBlindHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iBlindHitMode[ST_GetTankType(tank)] : g_iBlindHitMode2[ST_GetTankType(tank)];
}

static int iBlindMessage(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iBlindMessage[ST_GetTankType(tank)] : g_iBlindMessage2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

public Action tTimerBlind(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsHumanSurvivor(iSurvivor) || !g_bBlind[iSurvivor])
	{
		g_bBlind[iSurvivor] = false;
		g_iBlindOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iBlindEnabled = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || iBlindEnabled == 0)
	{
		g_bBlind[iSurvivor] = false;
		g_iBlindOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iBlindIntensity = !g_bTankConfig[ST_GetTankType(iTank)] ? g_iBlindIntensity[ST_GetTankType(iTank)] : g_iBlindIntensity2[ST_GetTankType(iTank)];
	vBlind(iSurvivor, iBlindIntensity);

	return Plugin_Continue;
}

public Action tTimerStopBlind(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsHumanSurvivor(iSurvivor))
	{
		g_bBlind[iSurvivor] = false;
		g_iBlindOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsTankSupported(iTank) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bBlind[iSurvivor])
	{
		g_bBlind[iSurvivor] = false;
		g_iBlindOwner[iSurvivor] = 0;

		vBlind(iSurvivor, 0);

		return Plugin_Stop;
	}

	g_bBlind[iSurvivor] = false;
	g_bBlind2[iTank] = false;
	g_iBlindOwner[iSurvivor] = 0;

	vBlind(iSurvivor, 0);

	int iMessage = pack.ReadCell();

	if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && iHumanAbility(iTank) == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bBlind3[iTank])
	{
		g_bBlind3[iTank] = true;

		ST_PrintToChat(iTank, "%s %t", ST_TAG3, "BlindHuman6");

		if (g_iBlindCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
		{
			CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			g_bBlind3[iTank] = false;
		}
	}

	if (iBlindMessage(iTank) & iMessage)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Blind2", iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bBlind3[iTank])
	{
		g_bBlind3[iTank] = false;

		return Plugin_Stop;
	}

	g_bBlind3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "BlindHuman7");

	return Plugin_Continue;
}