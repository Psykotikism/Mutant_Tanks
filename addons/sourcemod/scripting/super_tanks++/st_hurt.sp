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
	name = "[ST++] Hurt Ability",
	author = ST_AUTHOR,
	description = "The Super Tank repeatedly hurts survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Hurt Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_HURT "Hurt Ability"

bool g_bCloneInstalled, g_bHurt[MAXPLAYERS + 1], g_bHurt2[MAXPLAYERS + 1], g_bHurt3[MAXPLAYERS + 1], g_bHurt4[MAXPLAYERS + 1], g_bHurt5[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHurtChance[ST_MAXTYPES + 1], g_flHurtDamage[ST_MAXTYPES + 1], g_flHurtDuration[ST_MAXTYPES + 1], g_flHurtInterval[ST_MAXTYPES + 1], g_flHurtRange[ST_MAXTYPES + 1], g_flHurtRangeChance[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHurtAbility[ST_MAXTYPES + 1], g_iHurtCount[MAXPLAYERS + 1], g_iHurtEffect[ST_MAXTYPES + 1], g_iHurtHit[ST_MAXTYPES + 1], g_iHurtHitMode[ST_MAXTYPES + 1], g_iHurtMessage[ST_MAXTYPES + 1], g_iHurtOwner[MAXPLAYERS + 1];

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

	RegConsoleCmd("sm_st_hurt", cmdHurtInfo, "View information about the Hurt ability.");

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

public Action cmdHurtInfo(int client, int args)
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
		case false: vHurtMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vHurtMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iHurtMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Hurt Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Duration", "Duration");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iHurtMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHurtAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iHurtCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "HurtDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityDuration", g_flHurtDuration[ST_GetTankType(param1)]);
				case 6: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vHurtMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "HurtMenu", param1);
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
	menu.AddItem(ST_MENU_HURT, ST_MENU_HURT);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_HURT, false))
	{
		vHurtMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((g_iHurtHitMode[ST_GetTankType(attacker)] == 0 || g_iHurtHitMode[ST_GetTankType(attacker)] == 1) && ST_IsTankSupported(attacker) && bIsCloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHurtHit(victim, attacker, g_flHurtChance[ST_GetTankType(attacker)], g_iHurtHit[ST_GetTankType(attacker)], ST_MESSAGE_MELEE, ST_ATTACK_CLAW);
			}
		}
		else if ((g_iHurtHitMode[ST_GetTankType(victim)] == 0 || g_iHurtHitMode[ST_GetTankType(victim)] == 2) && ST_IsTankSupported(victim) && bIsCloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vHurtHit(attacker, victim, g_flHurtChance[ST_GetTankType(victim)], g_iHurtHit[ST_GetTankType(victim)], ST_MESSAGE_MELEE, ST_ATTACK_MELEE);
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
		g_iHurtAbility[iIndex] = 0;
		g_iHurtEffect[iIndex] = 0;
		g_iHurtMessage[iIndex] = 0;
		g_flHurtChance[iIndex] = 33.3;
		g_flHurtDamage[iIndex] = 5.0;
		g_flHurtDuration[iIndex] = 5.0;
		g_iHurtHit[iIndex] = 0;
		g_iHurtHitMode[iIndex] = 0;
		g_flHurtInterval[iIndex] = 1.0;
		g_flHurtRange[iIndex] = 150.0;
		g_flHurtRangeChance[iIndex] = 15.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	ST_FindAbility(type, 25, bHasAbilities(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt"));
	g_iHumanAbility[type] = iGetValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 30.0, 0.0, 9999999999.0);
	g_iHurtAbility[type] = iGetValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iHurtAbility[type], value, 0, 0, 1);
	g_iHurtEffect[type] = iGetValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "AbilityEffect", "Ability Effect", "Ability_Effect", "effect", main, g_iHurtEffect[type], value, 0, 0, 7);
	g_iHurtMessage[type] = iGetValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iHurtMessage[type], value, 0, 0, 3);
	g_flHurtChance[type] = flGetValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtChance", "Hurt Chance", "Hurt_Chance", "chance", main, g_flHurtChance[type], value, 33.3, 0.0, 100.0);
	g_flHurtDamage[type] = flGetValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtDamage", "Hurt Damage", "Hurt_Damage", "damage", main, g_flHurtDamage[type], value, 5.0, 1.0, 9999999999.0);
	g_flHurtDuration[type] = flGetValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtDuration", "Hurt Duration", "Hurt_Duration", "duration", main, g_flHurtDuration[type], value, 5.0, 0.1, 9999999999.0);
	g_iHurtHit[type] = iGetValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtHit", "Hurt Hit", "Hurt_Hit", "hit", main, g_iHurtHit[type], value, 0, 0, 1);
	g_iHurtHitMode[type] = iGetValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtHitMode", "Hurt Hit Mode", "Hurt_Hit_Mode", "hitmode", main, g_iHurtHitMode[type], value, 0, 0, 2);
	g_flHurtInterval[type] = flGetValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtInterval", "Hurt Interval", "Hurt_Interval", "interval", main, g_flHurtInterval[type], value, 1.0, 0.1, 9999999999.0);
	g_flHurtRange[type] = flGetValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtRange", "Hurt Range", "Hurt_Range", "range", main, g_flHurtRange[type], value, 150.0, 1.0, 9999999999.0);
	g_flHurtRangeChance[type] = flGetValue(subsection, "hurtability", "hurt ability", "hurt_ability", "hurt", key, "HurtRangeChance", "Hurt Range Chance", "Hurt_Range_Chance", "rangechance", main, g_flHurtRangeChance[type], value, 15.0, 0.0, 100.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveHurt(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iHurtAbility[ST_GetTankType(tank)] == 1)
	{
		vHurtAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (g_iHurtAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				if (!g_bHurt2[tank] && !g_bHurt3[tank])
				{
					vHurtAbility(tank);
				}
				else if (g_bHurt2[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "HurtHuman3");
				}
				else if (g_bHurt3[tank])
				{
					ST_PrintToChat(tank, "%s %t", ST_TAG3, "HurtHuman4");
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveHurt(tank);
}

static void vHurtAbility(int tank)
{
	if (g_iHurtCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		g_bHurt4[tank] = false;
		g_bHurt5[tank] = false;

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
				if (flDistance <= g_flHurtRange[ST_GetTankType(tank)])
				{
					vHurtHit(iSurvivor, tank, g_flHurtRangeChance[ST_GetTankType(tank)], g_iHurtAbility[ST_GetTankType(tank)], ST_MESSAGE_RANGE, ST_ATTACK_RANGE);

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "HurtHuman5");
			}
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "HurtAmmo");
	}
}

static void vHurtHit(int survivor, int tank, float chance, int enabled, int messages, int flags)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iHurtCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance && !g_bHurt[survivor])
			{
				g_bHurt[survivor] = true;
				g_iHurtOwner[survivor] = tank;

				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && (flags & ST_ATTACK_RANGE) && !g_bHurt2[tank])
				{
					g_bHurt2[tank] = true;
					g_iHurtCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "HurtHuman", g_iHurtCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);
				}

				DataPack dpHurt;
				CreateDataTimer(g_flHurtInterval[ST_GetTankType(tank)], tTimerHurt, dpHurt, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				dpHurt.WriteCell(GetClientUserId(survivor));
				dpHurt.WriteCell(GetClientUserId(tank));
				dpHurt.WriteCell(ST_GetTankType(tank));
				dpHurt.WriteCell(messages);
				dpHurt.WriteCell(enabled);
				dpHurt.WriteFloat(GetEngineTime());

				vEffect(survivor, tank, g_iHurtEffect[ST_GetTankType(tank)], flags);

				if (g_iHurtMessage[ST_GetTankType(tank)] & messages)
				{
					char sTankName[33];
					ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Hurt", sTankName, survivor);
				}
			}
			else if ((flags & ST_ATTACK_RANGE) && !g_bHurt2[tank])
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bHurt4[tank])
				{
					g_bHurt4[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "HurtHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bHurt5[tank])
		{
			g_bHurt5[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "HurtAmmo");
		}
	}
}

static void vRemoveHurt(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor, ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && g_bHurt[iSurvivor] && g_iHurtOwner[iSurvivor] == tank)
		{
			g_bHurt[iSurvivor] = false;
			g_iHurtOwner[iSurvivor] = 0;
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

			g_iHurtOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int messages)
{
	g_bHurt[survivor] = false;
	g_iHurtOwner[survivor] = 0;

	if (g_iHurtMessage[ST_GetTankType(tank)] & messages)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Hurt2", survivor);
	}
}

static void vReset3(int tank)
{
	g_bHurt[tank] = false;
	g_bHurt2[tank] = false;
	g_bHurt3[tank] = false;
	g_bHurt4[tank] = false;
	g_bHurt5[tank] = false;
	g_iHurtCount[tank] = 0;
}

public Action tTimerHurt(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!ST_IsCorePluginEnabled() || !bIsSurvivor(iSurvivor))
	{
		g_bHurt[iSurvivor] = false;
		g_iHurtOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iType = pack.ReadCell(), iMessage = pack.ReadCell();
	if (!ST_IsTankSupported(iTank) || !ST_IsTypeEnabled(ST_GetTankType(iTank)) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || iType != ST_GetTankType(iTank) || !g_bHurt[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iMessage);

		return Plugin_Stop;
	}

	int iHurtEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();
	if (iHurtEnabled == 0 || (flTime + g_flHurtDuration[ST_GetTankType(iTank)]) < GetEngineTime())
	{
		g_bHurt2[iTank] = false;

		vReset2(iSurvivor, iTank, iMessage);

		if (ST_IsTankSupported(iTank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(iTank)] == 1 && (iMessage & ST_MESSAGE_RANGE) && !g_bHurt3[iTank])
		{
			g_bHurt3[iTank] = true;

			ST_PrintToChat(iTank, "%s %t", ST_TAG3, "HurtHuman6");

			if (g_iHurtCount[iTank] < g_iHumanAmmo[ST_GetTankType(iTank)] && g_iHumanAmmo[ST_GetTankType(iTank)] > 0)
			{
				CreateTimer(g_flHumanCooldown[ST_GetTankType(iTank)], tTimerResetCooldown, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
			}
			else
			{
				g_bHurt3[iTank] = false;
			}
		}

		return Plugin_Stop;
	}

	vDamageEntity(iSurvivor, iTank, g_flHurtDamage[ST_GetTankType(iTank)]);

	return Plugin_Continue;
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bHurt3[iTank])
	{
		g_bHurt3[iTank] = false;

		return Plugin_Stop;
	}

	g_bHurt3[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "HurtHuman7");

	return Plugin_Continue;
}