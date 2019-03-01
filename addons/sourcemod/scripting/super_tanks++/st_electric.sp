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
	name = "[ST++] Electric Ability",
	author = ST_AUTHOR,
	description = "The Super Tank electrocutes survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Electric Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define PARTICLE_ELECTRICITY "electrical_arc_01_system"

#define SOUND_ELECTRICITY "ambient/energy/zap5.wav"
#define SOUND_ELECTRICITY2 "ambient/energy/zap7.wav"

#define ST_MENU_ELECTRIC "Electric Ability"

bool g_bCloneInstalled, g_bElectric[MAXPLAYERS + 1], g_bElectric2[MAXPLAYERS + 1], g_bElectric3[MAXPLAYERS + 1], g_bElectric4[MAXPLAYERS + 1], g_bElectric5[MAXPLAYERS + 1];

float g_flElectricChance[ST_MAXTYPES + 1], g_flElectricDamage[ST_MAXTYPES + 1], g_flElectricDuration[ST_MAXTYPES + 1], g_flElectricInterval[ST_MAXTYPES + 1], g_flElectricRange[ST_MAXTYPES + 1], g_flElectricRangeChance[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1];

int g_iElectricAbility[ST_MAXTYPES + 1], g_iElectricCount[MAXPLAYERS + 1], g_iElectricEffect[ST_MAXTYPES + 1], g_iElectricHit[ST_MAXTYPES + 1], g_iElectricHitMode[ST_MAXTYPES + 1], g_iElectricMessage[ST_MAXTYPES + 1], g_iElectricOwner[MAXPLAYERS + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_electric", cmdElectricInfo, "View information about the Electric ability.");

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
	vPrecacheParticle(PARTICLE_ELECTRICITY);

	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_ELECTRICITY2, true);

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

public Action cmdElectricInfo(int client, int args)
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
		case false: vElectricMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vElectricMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iElectricMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Electric Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iElectricMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iElectricAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iElectricCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "ElectricDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flElectricDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vElectricMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "ElectricMenu", param1);
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
	menu.AddItem(ST_MENU_ELECTRIC, ST_MENU_ELECTRIC);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_ELECTRIC, false))
	{
		vElectricMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((g_iElectricHitMode[ST_GetTankType(attacker)] == 0 || g_iElectricHitMode[ST_GetTankType(attacker)] == 1) && ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vElectricHit(victim, attacker, g_flElectricChance[ST_GetTankType(attacker)], g_iElectricHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if ((g_iElectricHitMode[ST_GetTankType(victim)] == 0 || g_iElectricHitMode[ST_GetTankType(victim)] == 2) && ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vElectricHit(attacker, victim, g_flElectricChance[ST_GetTankType(victim)], g_iElectricHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iElectricAbility[iIndex] = 0;
		g_iElectricEffect[iIndex] = 0;
		g_iElectricMessage[iIndex] = 0;
		g_flElectricChance[iIndex] = 33.3;
		g_flElectricDamage[iIndex] = 1.0;
		g_flElectricDuration[iIndex] = 5.0;
		g_iElectricHit[iIndex] = 0;
		g_iElectricHitMode[iIndex] = 0;
		g_flElectricInterval[iIndex] = 1.0;
		g_flElectricRange[iIndex] = 150.0;
		g_flElectricRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	g_iHumanAbility[type] = iGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iElectricAbility[type] = iGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iElectricAbility[type], value, 0, 0, 1);
	g_iElectricEffect[type] = iGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iElectricEffect[type], value, 0, 0, 7);
	g_iElectricMessage[type] = iGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iElectricMessage[type], value, 0, 0, 3);
	g_flElectricChance[type] = flGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricChance", "Electric Chance", "Electric_Chance", "chance", main, g_flElectricChance[type], value, 33.3, 0.0, 100.0);
	g_flElectricDamage[type] = flGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricDamage", "Electric Damage", "Electric_Damage", "damage", main, g_flElectricDamage[type], value, 1.0, 1.0, 9999999999.0);
	g_flElectricDuration[type] = flGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricDuration", "Electric Duration", "Electric_Duration", "duration", main, g_flElectricDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iElectricHit[type] = iGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricHit", "Electric Hit", "Electric_Hit", "hit", main, g_iElectricHit[type], value, 0, 0, 1);
	g_iElectricHitMode[type] = iGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricHitMode", "Electric Hit Mode", "Electric_Hit_Mode", "hitmode", main, g_iElectricHitMode[type], value, 0, 0, 2);
	g_flElectricInterval[type] = flGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricInterval", "Electric Interval", "Electric_Interval", "interval", main, g_flElectricInterval[type], value, 1.0, 0.1, 9999999999.0);
	g_flElectricRange[type] = flGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricRange", "Electric Range", "Electric_Range", "range", main, g_flElectricRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flElectricRangeChance[type] = flGetValue(subsection, "electricability", "electric ability", "electric_ability", "electric", key, "ElectricRangeChance", "Electric Range Chance", "Electric_Range_Chance", "rangechance", main, g_flElectricRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			if (bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iElectricAbility[ST_GetTankType(iTank)] == 1)
			{
				vAttachParticle(iTank, PARTICLE_ELECTRICITY, 2.0, 30.0);
			}

			vRemoveElectric(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iElectricAbility[ST_GetTankType(tank)] == 1)
	{
		vElectricAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iElectricAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bElectric2[tank] && !g_bElectric3[tank])
				{
					vElectricAbility(tank);
				}
				else if (g_bElectric2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ElectricHuman3");
				}
				else if (g_bElectric3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ElectricHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveElectric(tank);
}

static void vElectricAbility(int tank)
{
	if (g_iElectricCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bElectric4[tank] = false;
		g_bElectric5[tank] = false;

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
				if (flDistance <= g_flElectricRange[ST_GetTankType(tank)])
				{
					vElectricHit(iSurvivor, tank, g_flElectricRangeChance[ST_GetTankType(tank)], g_iElectricAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "ElectricHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "ElectricAmmo");
	}
}

static void vElectricHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iElectricCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bElectric[survivor])
			{
				g_bElectric[survivor] = true;
				g_iElectricOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bElectric2[tank])
				{
					g_bElectric2[tank] = true;
					g_iElectricCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ElectricHuman", g_iElectricCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				DataPack dpElectric;
				CreateDataTimer(g_flElectricInterval[ST_GetTankType(tank)], tTimerElectric, dpElectric, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpElectric.WriteCell(GetClientUserId(survivor));
				dpElectric.WriteCell(GetClientUserId(tank));
				dpElectric.WriteCell(ST_GetTankType(tank));
				dpElectric.WriteCell(messages);
				dpElectric.WriteCell(enabled);
				dpElectric.WriteFloat(GetEngineTime());

				vAttachParticle(survivor, PARTICLE_ELECTRICITY, 2.0, 30.0);

				vEffect(survivor, tank, g_iElectricEffect[ST_GetTankType(tank)], flags);

				if (g_iElectricMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Electric", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bElectric2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bElectric4[tank])
				{
					g_bElectric4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "ElectricHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bElectric5[tank])
		{
			g_bElectric5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "ElectricAmmo");
		}
	}
}

static void vRemoveElectric(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bElectric[iSurvivor] && g_iElectricOwner[iSurvivor] == tank)
		{
			g_bElectric[iSurvivor] = false;
			g_iElectricOwner[iSurvivor] = 0;
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

			g_iElectricOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_bElectric[survivor] = false;
	g_iElectricOwner[survivor] = 0;

	if (g_iElectricMessage[ST_GetTankType(tank)] & messages)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Electric2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bElectric[tank] = false;
	g_bElectric2[tank] = false;
	g_bElectric3[tank] = false;
	g_bElectric4[tank] = false;
	g_bElectric5[tank] = false;
	g_iElectricCount[tank] = 0;
}

public Action tTimerElectric(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bElectric[iSurvivor] = false;
		g_iElectricOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bElectric[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iElectricEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iElectricEnabled == 0 || (flTime + g_flElectricDuration[ST_GetTankType(iTank)]) < GetEngineTime())
	{
		g_bElectric2[iTank] = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bElectric3[iTank])
		{
			g_bElectric3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ElectricHuman6");

			if (g_iElectricCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bElectric3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	vDamageEntity(iSurvivor, iTank, g_flElectricDamage[ST_GetTankType(iTank)], "256");

	vAttachParticle(iSurvivor, PARTICLE_ELECTRICITY, 2.0, 30.0);

	switch (GetRandomInt(1, 2))
	{
		case 1: EmitSoundToAll(SOUND_ELECTRICITY, iSurvivor);
		case 2: EmitSoundToAll(SOUND_ELECTRICITY2, iSurvivor);
	}

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bElectric3[iTank])
	{
		g_bElectric3[iTank] = false;

		return Plugin_Stop;
	}

	g_bElectric3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "ElectricHuman7");

	return Plugin_Continue;
}