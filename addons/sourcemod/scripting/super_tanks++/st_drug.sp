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
	name = "[ST++] Drug Ability",
	author = ST_AUTHOR,
	description = "The Super Tank drugs survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

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

#define ST_MENU_DRUG "Drug Ability"

bool g_bCloneInstalled, g_bDrug[MAXPLAYERS + 1], g_bDrug2[MAXPLAYERS + 1], g_bDrug3[MAXPLAYERS + 1], g_bDrug4[MAXPLAYERS + 1], g_bDrug5[MAXPLAYERS + 1];

float g_flDrugAngles[20] = {0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 20.0, 15.0, 10.0, 5.0, 0.0, -5.0, -10.0, -15.0, -20.0, -25.0, -20.0, -15.0, -10.0, -5.0}, g_flDrugChance[ST_MAXTYPES + 1], g_flDrugDuration[ST_MAXTYPES + 1], g_flDrugInterval[ST_MAXTYPES + 1], g_flDrugRange[ST_MAXTYPES + 1], g_flDrugRangeChance[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1];

int g_iAccessFlags[ST_MAXTYPES + 1], g_iAccessFlags2[MAXPLAYERS + 1], g_iDrugAbility[ST_MAXTYPES + 1], g_iDrugCount[MAXPLAYERS + 1], g_iDrugEffect[ST_MAXTYPES + 1], g_iDrugHit[ST_MAXTYPES + 1], g_iDrugHitMode[ST_MAXTYPES + 1], g_iDrugMessage[ST_MAXTYPES + 1], g_iDrugOwner[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iImmunityFlags[ST_MAXTYPES + 1], g_iImmunityFlags2[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_drug", cmdDrugInfo, "View information about the Drug ability.");

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

	vReset3(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdDrugInfo(int client, int args)
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iDrugAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iDrugCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "DrugDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flDrugDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && (g_iDrugHitMode[ST_GetTankType(attacker)] == 0 || g_iDrugHitMode[ST_GetTankType(attacker)] == 1) && bIsHumanSurvivor(victim))
		{
			if ((!ST_HasAdminAccess(attacker) && !bHasAdminAccess(attacker)) || ST_IsAdminImmune(victim, attacker) || bIsAdminImmune(victim, attacker))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vDrugHit(victim, attacker, g_flDrugChance[ST_GetTankType(attacker)], g_iDrugHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if (ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && (g_iDrugHitMode[ST_GetTankType(victim)] == 0 || g_iDrugHitMode[ST_GetTankType(victim)] == 2) && bIsHumanSurvivor(attacker))
		{
			if ((!ST_HasAdminAccess(victim) && !bHasAdminAccess(victim)) || ST_IsAdminImmune(attacker, victim) || bIsAdminImmune(attacker, victim))
			{
				return Plugin_Continue;
			}

			if (StrEqual(sClassname, "weapon_melee"))
			{
				vDrugHit(attacker, victim, g_flDrugChance[ST_GetTankType(victim)], g_iDrugHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iDrugAbility[iIndex] = 0;
		g_iDrugEffect[iIndex] = 0;
		g_iDrugMessage[iIndex] = 0;
		g_flDrugChance[iIndex] = 33.3;
		g_flDrugDuration[iIndex] = 5.0;
		g_iDrugHit[iIndex] = 0;
		g_iDrugHitMode[iIndex] = 0;
		g_flDrugInterval[iIndex] = 1.0;
		g_flDrugRange[iIndex] = 150.0;
		g_flDrugRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, const char[] value, int type, int admin)
{
	if (bIsValidClient(admin) && value[0] != '\0')
	{
		if (StrEqual(subsection, "drugability", false) || StrEqual(subsection, "drug ability", false) || StrEqual(subsection, "drug_ability", false) || StrEqual(subsection, "drug", false))
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
		ST_FindAbility(type, 12, bHasAbilities(subsection, "drugability", "drug ability", "drug_ability", "drug"));
		g_iHumanAbility[type] = iGetValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "HumanAbility", "Human Ability", "Human_Ability", "human", g_iHumanAbility[type], value, 0, 1);
		g_iHumanAmmo[type] = iGetValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", g_iHumanAmmo[type], value, 0, 9999999999);
		g_flHumanCooldown[type] = flGetValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", g_flHumanCooldown[type], value, 0.0, 9999999999.0);
		g_iDrugAbility[type] = iGetValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", g_iDrugAbility[type], value, 0, 1);
		g_iDrugEffect[type] = iGetValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", g_iDrugEffect[type], value, 0, 7);
		g_iDrugMessage[type] = iGetValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", g_iDrugMessage[type], value, 0, 3);
		g_flDrugChance[type] = flGetValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugChance", "Drug Chance", "Drug_Chance", "chance", g_flDrugChance[type], value, 0.0, 100.0);
		g_flDrugDuration[type] = flGetValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugDuration", "Drug Duration", "Drug_Duration", "duration", g_flDrugDuration[type], value, 0.1, 9999999999.0);
		g_iDrugHit[type] = iGetValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugHit", "Drug Hit", "Drug_Hit", "hit", g_iDrugHit[type], value, 0, 1);
		g_iDrugHitMode[type] = iGetValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugHitMode", "Drug Hit Mode", "Drug_Hit_Mode", "hitmode", g_iDrugHitMode[type], value, 0, 2);
		g_flDrugInterval[type] = flGetValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugInterval", "Drug Interval", "Drug_Interval", "interval", g_flDrugInterval[type], value, 0.1, 9999999999.0);
		g_flDrugRange[type] = flGetValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugRange", "Drug Range", "Drug_Range", "range", g_flDrugRange[type], value, 1.0, 9999999999.0);
		g_flDrugRangeChance[type] = flGetValue(subsection, "drugability", "drug ability", "drug_ability", "drug", key, "DrugRangeChance", "Drug Range Chance", "Drug_Range_Chance", "rangechance", g_flDrugRangeChance[type], value, 0.0, 100.0);

		if (StrEqual(subsection, "drugability", false) || StrEqual(subsection, "drug ability", false) || StrEqual(subsection, "drug_ability", false) || StrEqual(subsection, "drug", false))
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

public void ST_OnPluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE))
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
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveDrug(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || g_iHumanAbility[ST_GetTankType(tank)] == 0))
	{
		return;
	}

	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iDrugAbility[ST_GetTankType(tank)] == 1)
	{
		vDrugAbility(tank);
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
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iDrugAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
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

public void ST_OnChangeType(int tank, bool revert)
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
		for (int iPos = 0; iPos < 3; iPos++)
		{
			iColor[iPos] = GetRandomInt(0, 255);
		}
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

			for (int iPos = 0; iPos < 4; iPos++)
			{
				bfWrite.WriteByte(toggle ? iColor[iPos] : iColor2[iPos]);
			}
		}
	}

	EndMessage();
}

static void vDrugAbility(int tank)
{
	if (!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank))
	{
		return;
	}

	if (g_iDrugCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bDrug4[tank] = false;
		g_bDrug5[tank] = false;

		float flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		int iSurvivorCount;
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && !ST_IsAdminImmune(iSurvivor, tank) && !bIsAdminImmune(iSurvivor, tank))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= g_flDrugRange[ST_GetTankType(tank)])
				{
					vDrugHit(iSurvivor, tank, g_flDrugRangeChance[ST_GetTankType(tank)], g_iDrugAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "DrugHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "DrugAmmo");
	}
}

static void vDrugHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if ((!ST_HasAdminAccess(tank) && !bHasAdminAccess(tank)) || ST_IsAdminImmune(survivor, tank) || bIsAdminImmune(survivor, tank))
	{
		return;
	}

	if (enabled == 1 && bIsHumanSurvivor(survivor))
	{
		if (g_iDrugCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bDrug[survivor])
			{
				g_bDrug[survivor] = true;
				g_iDrugOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bDrug2[tank])
				{
					g_bDrug2[tank] = true;
					g_iDrugCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "DrugHuman", g_iDrugCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				DataPack dpDrug;
				CreateDataTimer(g_flDrugInterval[ST_GetTankType(tank)], tTimerDrug, dpDrug, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpDrug.WriteCell(GetClientUserId(survivor));
				dpDrug.WriteCell(GetClientUserId(tank));
				dpDrug.WriteCell(ST_GetTankType(tank));
				dpDrug.WriteCell(messages);
				dpDrug.WriteCell(enabled);
				dpDrug.WriteFloat(GetEngineTime());

				vEffect(survivor, tank, g_iDrugEffect[ST_GetTankType(tank)], flags);

				if (g_iDrugMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Drug", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bDrug2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bDrug4[tank])
				{
					g_bDrug4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "DrugHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bDrug5[tank])
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
		if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE) && g_bDrug[iSurvivor] && g_iDrugOwner[iSurvivor] == tank)
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
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
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

static void vReset2(int survivor, int tank, int messages)
{
	g_bDrug[survivor] = false;
	g_iDrugOwner[survivor] = 0;

	vDrug(survivor, false, g_flDrugAngles);

	if (g_iDrugMessage[ST_GetTankType(tank)] & messages)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Drug2", survivor);
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

static bool bIsAdminImmune(int survivor, int tank)
{
	if (!bIsValidClient(survivor, ST_CHECK_INGAME|ST_CHECK_FAKECLIENT))
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

public Action tTimerDrug(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsHumanSurvivor(iSurvivor))
	{
		g_bDrug[iSurvivor] = false;
		g_iDrugOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || (!ST_HasAdminAccess(iTank) && !bHasAdminAccess(iTank)) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || ST_IsAdminImmune(iSurvivor, iTank) || bIsAdminImmune(iSurvivor, iTank) || !g_bDrug[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iDrugEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iDrugEnabled == 0 || (flTime + g_flDrugDuration[ST_GetTankType(iTank)]) < GetEngineTime())
	{
		g_bDrug2[iTank] = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bDrug3[iTank])
		{
			g_bDrug3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "DrugHuman6");

			if (g_iDrugCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
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
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bDrug3[iTank])
	{
		g_bDrug3[iTank] = false;

		return Plugin_Stop;
	}

	g_bDrug3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "DrugHuman7");

	return Plugin_Continue;
}