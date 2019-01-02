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
	name = "[ST++] Drug Ability",
	author = ST_AUTHOR,
	description = "The Super Tank drugs survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_DRUG "Drug Ability"

bool g_bCloneInstalled, g_bDrug[MAXPLAYERS + 1], g_bDrug2[MAXPLAYERS + 1], g_bDrug3[MAXPLAYERS + 1], g_bDrug4[MAXPLAYERS + 1], g_bDrug5[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sDrugEffect[ST_MAXTYPES + 1][4], g_sDrugEffect2[ST_MAXTYPES + 1][4], g_sDrugMessage[ST_MAXTYPES + 1][3], g_sDrugMessage2[ST_MAXTYPES + 1][3];

float g_flDrugAngles[20] = {0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 20.0, 15.0, 10.0, 5.0, 0.0, -5.0, -10.0, -15.0, -20.0, -25.0, -20.0, -15.0, -10.0, -5.0}, g_flDrugChance[ST_MAXTYPES + 1], g_flDrugChance2[ST_MAXTYPES + 1], g_flDrugDuration[ST_MAXTYPES + 1], g_flDrugDuration2[ST_MAXTYPES + 1], g_flDrugInterval[ST_MAXTYPES + 1], g_flDrugInterval2[ST_MAXTYPES + 1], g_flDrugRange[ST_MAXTYPES + 1], g_flDrugRange2[ST_MAXTYPES + 1], g_flDrugRangeChance[ST_MAXTYPES + 1], g_flDrugRangeChance2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

int g_iDrugAbility[ST_MAXTYPES + 1], g_iDrugAbility2[ST_MAXTYPES + 1], g_iDrugCount[MAXPLAYERS + 1], g_iDrugHit[ST_MAXTYPES + 1], g_iDrugHit2[ST_MAXTYPES + 1], g_iDrugHitMode[ST_MAXTYPES + 1], g_iDrugHitMode2[ST_MAXTYPES + 1], g_iDrugOwner[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1];

UserMsg g_umFadeUserMsgId;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Drug Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_drug", cmdDrugInfo, "View information about the Drug ability.");

	g_umFadeUserMsgId = GetUserMessageId("Fade");

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

	vReset3(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdDrugInfo(int client, int args)
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
		case false: vDrugMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vDrugMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iDrugMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Drug Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iDrugMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iDrugAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iDrugCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "DrugDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", flDrugDuration(param1));
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vDrugMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "DrugMenu", param1);
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
	menu.AddItem(ST_MENU_DRUG, ST_MENU_DRUG);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_DRUG, false))
	{
		vDrugMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && (iDrugHitMode(attacker) == 0 || iDrugHitMode(attacker) == 1) && bIsHumanSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vDrugHit(victim, attacker, flDrugChance(attacker), iDrugHit(attacker), "1", "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && (iDrugHitMode(victim) == 0 || iDrugHitMode(victim) == 2) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vDrugHit(attacker, victim, flDrugChance(victim), iDrugHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Drug Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Drug Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iDrugAbility[iIndex] = kvSuperTanks.GetNum("Drug Ability/Ability Enabled", 0);
					g_iDrugAbility[iIndex] = iClamp(g_iDrugAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Drug Ability/Ability Effect", g_sDrugEffect[iIndex], sizeof(g_sDrugEffect[]), "0");
					kvSuperTanks.GetString("Drug Ability/Ability Message", g_sDrugMessage[iIndex], sizeof(g_sDrugMessage[]), "0");
					g_flDrugChance[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Drug Chance", 33.3);
					g_flDrugChance[iIndex] = flClamp(g_flDrugChance[iIndex], 0.0, 100.0);
					g_flDrugDuration[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Drug Duration", 5.0);
					g_flDrugDuration[iIndex] = flClamp(g_flDrugDuration[iIndex], 0.1, 9999999999.0);
					g_iDrugHit[iIndex] = kvSuperTanks.GetNum("Drug Ability/Drug Hit", 0);
					g_iDrugHit[iIndex] = iClamp(g_iDrugHit[iIndex], 0, 1);
					g_iDrugHitMode[iIndex] = kvSuperTanks.GetNum("Drug Ability/Drug Hit Mode", 0);
					g_iDrugHitMode[iIndex] = iClamp(g_iDrugHitMode[iIndex], 0, 2);
					g_flDrugInterval[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Drug Interval", 1.0);
					g_flDrugInterval[iIndex] = flClamp(g_flDrugInterval[iIndex], 0.1, 9999999999.0);
					g_flDrugRange[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Drug Range", 150.0);
					g_flDrugRange[iIndex] = flClamp(g_flDrugRange[iIndex], 1.0, 9999999999.0);
					g_flDrugRangeChance[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Drug Range Chance", 15.0);
					g_flDrugRangeChance[iIndex] = flClamp(g_flDrugRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Drug Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Drug Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iDrugAbility2[iIndex] = kvSuperTanks.GetNum("Drug Ability/Ability Enabled", g_iDrugAbility[iIndex]);
					g_iDrugAbility2[iIndex] = iClamp(g_iDrugAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Drug Ability/Ability Effect", g_sDrugEffect2[iIndex], sizeof(g_sDrugEffect2[]), g_sDrugEffect[iIndex]);
					kvSuperTanks.GetString("Drug Ability/Ability Message", g_sDrugMessage2[iIndex], sizeof(g_sDrugMessage2[]), g_sDrugMessage[iIndex]);
					g_flDrugChance2[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Drug Chance", g_flDrugChance[iIndex]);
					g_flDrugChance2[iIndex] = flClamp(g_flDrugChance2[iIndex], 0.0, 100.0);
					g_flDrugDuration2[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Drug Duration", g_flDrugDuration[iIndex]);
					g_flDrugDuration2[iIndex] = flClamp(g_flDrugDuration2[iIndex], 0.1, 9999999999.0);
					g_iDrugHit2[iIndex] = kvSuperTanks.GetNum("Drug Ability/Drug Hit", g_iDrugHit[iIndex]);
					g_iDrugHit2[iIndex] = iClamp(g_iDrugHit2[iIndex], 0, 1);
					g_iDrugHitMode2[iIndex] = kvSuperTanks.GetNum("Drug Ability/Drug Hit Mode", g_iDrugHitMode[iIndex]);
					g_iDrugHitMode2[iIndex] = iClamp(g_iDrugHitMode2[iIndex], 0, 2);
					g_flDrugInterval2[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Drug Interval", g_flDrugInterval[iIndex]);
					g_flDrugInterval2[iIndex] = flClamp(g_flDrugInterval2[iIndex], 0.1, 9999999999.0);
					g_flDrugRange2[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Drug Range", g_flDrugRange[iIndex]);
					g_flDrugRange2[iIndex] = flClamp(g_flDrugRange2[iIndex], 1.0, 9999999999.0);
					g_flDrugRangeChance2[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Drug Range Chance", g_flDrugRangeChance[iIndex]);
					g_flDrugRangeChance2[iIndex] = flClamp(g_flDrugRangeChance2[iIndex], 0.0, 100.0);
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
			vRemoveDrug(iTank);
		}
	}
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank, "024"))
		{
			vRemoveDrug(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iDrugAbility(tank) == 1)
	{
		vDrugAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iDrugAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				if (!g_bDrug2[tank] && !g_bDrug3[tank])
				{
					vDrugAbility(tank);
				}
				else if (g_bDrug2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "DrugHuman3");
				}
				else if (g_bDrug3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "DrugHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveDrug(tank);
}

static void vDrug(int survivor, bool toggle, float angles[20])
{
	float flAngles[3];
	GetClientEyeAngles(survivor, flAngles);
	flAngles[2] = toggle ? angles[GetRandomInt(0, 100) % 20] : 0.0;
	TeleportEntity(survivor, NULL_VECTOR, flAngles, NULL_VECTOR);

	int iClients[2], iColor[4] = {0, 0, 0, 128}, iColor2[4] = {0, 0, 0, 0}, iFlags = toggle ? 0x0002 : (0x0001|0x0010);
	iClients[0] = survivor;

	if (toggle)
	{
		iColor[0] = GetRandomInt(0, 255);
		iColor[1] = GetRandomInt(0, 255);
		iColor[2] = GetRandomInt(0, 255);
	}

	Handle hDrugTarget = StartMessageEx(g_umFadeUserMsgId, iClients, 1);
	switch (GetUserMessageType() == UM_Protobuf)
	{
		case true:
		{
			Protobuf pbSet = UserMessageToProtobuf(hDrugTarget);
			pbSet.SetInt("duration", toggle ? 255: 1536);
			pbSet.SetInt("hold_time", toggle ? 255 : 1536);
			pbSet.SetInt("flags", iFlags);
			pbSet.SetColor("clr", toggle ? iColor : iColor2);
		}
		case false:
		{
			BfWrite bfWrite = UserMessageToBfWrite(hDrugTarget);
			bfWrite.WriteShort(toggle ? 255 : 1536);
			bfWrite.WriteShort(toggle ? 255 : 1536);
			bfWrite.WriteShort(iFlags);
			bfWrite.WriteByte(toggle ? iColor[0] : iColor2[0]);
			bfWrite.WriteByte(toggle ? iColor[1] : iColor2[1]);
			bfWrite.WriteByte(toggle ? iColor[2] : iColor2[2]);
			bfWrite.WriteByte(toggle ? iColor[3] : iColor2[3]);
		}
	}

	EndMessage();
}

static void vDrugAbility(int tank)
{
	if (g_iDrugCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bDrug4[tank] = false;
		g_bDrug5[tank] = false;

		float flDrugRange = !g_bTankConfig[ST_TankType(tank)] ? g_flDrugRange[ST_TankType(tank)] : g_flDrugRange2[ST_TankType(tank)],
			flDrugRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flDrugRangeChance[ST_TankType(tank)] : g_flDrugRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(iSurvivor, "234"))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flDrugRange)
				{
					vDrugHit(iSurvivor, tank, flDrugRangeChance, iDrugAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "DrugHuman5");
			}
		}
	}
	else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "DrugAmmo");
	}
}

static void vDrugHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsHumanSurvivor(survivor))
	{
		if (g_iDrugCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bDrug[survivor])
			{
				g_bDrug[survivor] = true;
				g_iDrugOwner[survivor] = tank;

				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bDrug2[tank])
				{
					g_bDrug2[tank] = true;
					g_iDrugCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "DrugHuman", g_iDrugCount[tank], iHumanAmmo(tank));
				}

				float flDrugInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flDrugInterval[ST_TankType(tank)] : g_flDrugInterval2[ST_TankType(tank)];
				DataPack dpDrug;
				CreateDataTimer(flDrugInterval, tTimerDrug, dpDrug, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpDrug.WriteCell(GetClientUserId(survivor));
				dpDrug.WriteCell(GetClientUserId(tank));
				dpDrug.WriteString(message);
				dpDrug.WriteCell(enabled);
				dpDrug.WriteFloat(GetEngineTime());

				char sDrugEffect[4];
				sDrugEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sDrugEffect[ST_TankType(tank)] : g_sDrugEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sDrugEffect, mode);

				char sDrugMessage[3];
				sDrugMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sDrugMessage[ST_TankType(tank)] : g_sDrugMessage2[ST_TankType(tank)];
				if (StrContains(sDrugMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Drug", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bDrug2[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bDrug4[tank])
				{
					g_bDrug4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "DrugHuman2");
				}
			}
		}
		else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bDrug5[tank])
		{
			g_bDrug5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "DrugAmmo");
		}
	}
}

static void vRemoveDrug(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, "24") && g_bDrug[iSurvivor] && g_iDrugOwner[iSurvivor] == tank)
		{
			vDrug(iSurvivor, false, g_flDrugAngles);

			g_bDrug[iSurvivor] = false;
			g_iDrugOwner[iSurvivor] = 0;
		}
	}

	vReset3(tank);
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vReset3(iPlayer);

			g_iDrugOwner[iPlayer] = 0;
		}
	}
}

static void vReset3(int tank)
{
	g_bDrug[tank] = false;
	g_bDrug2[tank] = false;
	g_bDrug3[tank] = false;
	g_bDrug4[tank] = false;
	g_bDrug5[tank] = false;
	g_iDrugCount[tank] = 0;
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bDrug[survivor] = false;
	g_iDrugOwner[survivor] = 0;

	vDrug(survivor, false, g_flDrugAngles);

	char sDrugMessage[3];
	sDrugMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sDrugMessage[ST_TankType(tank)] : g_sDrugMessage2[ST_TankType(tank)];
	if (StrContains(sDrugMessage, message) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Drug2", survivor);
	}
}

static float flDrugChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flDrugChance[ST_TankType(tank)] : g_flDrugChance2[ST_TankType(tank)];
}

static float flDrugDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flDrugDuration[ST_TankType(tank)] : g_flDrugDuration2[ST_TankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static int iDrugAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iDrugAbility[ST_TankType(tank)] : g_iDrugAbility2[ST_TankType(tank)];
}

static int iDrugHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iDrugHit[ST_TankType(tank)] : g_iDrugHit2[ST_TankType(tank)];
}

static int iDrugHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iDrugHitMode[ST_TankType(tank)] : g_iDrugHitMode2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

public Action tTimerDrug(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !bIsHumanSurvivor(iSurvivor))
	{
		g_bDrug[iSurvivor] = false;
		g_iDrugOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bDrug[iSurvivor])
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iDrugEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iDrugEnabled == 0 || (flTime + flDrugDuration(iTank)) < GetEngineTime())
	{
		g_bDrug2[iTank] = false;

		vReset2(iSurvivor, iTank, sMessage);

		if (ST_TankAllowed(iTank, "5") && iHumanAbility(iTank) == 1 && StrContains(sMessage, "2") != -1 && !g_bDrug3[iTank])
		{
			g_bDrug3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "DrugHuman6");

			if (g_iDrugCount[iTank] < iHumanAmmo(iTank) && iHumanAmmo(iTank) > 0)
			{
				CreateTimer(flHumanCooldown(iTank), tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bDrug3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	vDrug(iSurvivor, true, g_flDrugAngles);

	return Plugin_Handled;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank, "02345") || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bDrug3[iTank])
	{
		g_bDrug3[iTank] = false;

		return Plugin_Stop;
	}

	g_bDrug3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "DrugHuman7");

	return Plugin_Continue;
}