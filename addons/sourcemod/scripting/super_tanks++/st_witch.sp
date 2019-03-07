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
	name = "[ST++] Witch Ability",
	author = ST_AUTHOR,
	description = "The Super Tank converts nearby common infected into Witch minions.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Witch Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

	g_bLateLoad = late;

	return APLRes_Success;
}

#define ST_MENU_WITCH "Witch Ability"

bool g_bCloneInstalled, g_bWitch[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flWitchChance[ST_MAXTYPES + 1], g_flWitchDamage[ST_MAXTYPES + 1], g_flWitchRange[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iWitchAbility[ST_MAXTYPES + 1], g_iWitchAmount[ST_MAXTYPES + 1], g_iWitchCount[MAXPLAYERS + 1], g_iWitchMessage[ST_MAXTYPES + 1];

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

	RegConsoleCmd("sm_st_witch", cmdWitchInfo, "View information about the Witch ability.");

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

	vRemoveWitch(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdWitchInfo(int client, int args)
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
		case false: vWitchMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vWitchMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iWitchMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Witch Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iWitchMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iWitchAbility[ST_GetTankType(param1)] == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", g_iHumanAmmo[ST_GetTankType(param1)] - g_iWitchCount[param1], g_iHumanAmmo[ST_GetTankType(param1)]);
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons3");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", g_flHumanCooldown[ST_GetTankType(param1)]);
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "WitchDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, g_iHumanAbility[ST_GetTankType(param1)] == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
			{
				vWitchMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "WitchMenu", param1);
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
	menu.AddItem(ST_MENU_WITCH, ST_MENU_WITCH);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_WITCH, false))
	{
		vWitchMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE) && damage > 0.0)
	{
		if (bIsWitch(attacker) && bIsSurvivor(victim))
		{
			int iOwner;
			if (HasEntProp(attacker, Prop_Send, "m_hOwnerEntity"))
			{
				iOwner = GetEntPropEnt(attacker, Prop_Send, "m_hOwnerEntity");
			}

			if (ST_IsTankSupported(iOwner) && bIsCloneAllowed(iOwner, g_bCloneInstalled))
			{
				damage = g_flWitchDamage[ST_GetTankType(iOwner)];

				return Plugin_Changed;
			}
		}
	}

	return Plugin_Continue;
}

public void ST_OnConfigsLoad()
{
	for (int iIndex = ST_GetMinType(); iIndex <= ST_GetMaxType(); iIndex++)
	{
		g_iHumanAbility[iIndex] = 0;
		g_iHumanAmmo[iIndex] = 5;
		g_flHumanCooldown[iIndex] = 30.0;
		g_iWitchAbility[iIndex] = 0;
		g_iWitchMessage[iIndex] = 0;
		g_iWitchAmount[iIndex] = 3;
		g_flWitchChance[iIndex] = 33.3;
		g_flWitchDamage[iIndex] = 5.0;
		g_flWitchRange[iIndex] = 500.0;
	}
}

public void ST_OnConfigsLoaded(const char[] subsection, const char[] key, bool main, const char[] value, int type)
{
	ST_FindAbility(type, 68, bHasAbilities(subsection, "witchability", "witch ability", "witch_ability", "witch"));
	g_iHumanAbility[type] = iGetValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "HumanAbility", "Human Ability", "Human_Ability", "human", main, g_iHumanAbility[type], value, 0, 0, 1);
	g_iHumanAmmo[type] = iGetValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "HumanAmmo", "Human Ammo", "Human_Ammo", "hammo", main, g_iHumanAmmo[type], value, 5, 0, 9999999999);
	g_flHumanCooldown[type] = flGetValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "HumanCooldown", "Human Cooldown", "Human_Cooldown", "hcooldown", main, g_flHumanCooldown[type], value, 60.0, 0.0, 9999999999.0);
	g_iWitchAbility[type] = iGetValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "AbilityEnabled", "Ability Enabled", "Ability_Enabled", "enabled", main, g_iWitchAbility[type], value, 0, 0, 1);
	g_iWitchMessage[type] = iGetValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "AbilityMessage", "Ability Message", "Ability_Message", "message", main, g_iWitchMessage[type], value, 0, 0, 1);
	g_iWitchAmount[type] = iGetValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "WitchAmount", "Witch Amount", "Witch_Amount", "amount", main, g_iWitchAmount[type], value, 3, 1, 25);
	g_flWitchChance[type] = flGetValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "WitchChance", "Witch Chance", "Witch_Chance", "chance", main, g_flWitchChance[type], value, 33.3, 0.0, 100.0);
	g_flWitchDamage[type] = flGetValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "WitchDamage", "Witch Damage", "Witch_Damage", "damage", main, g_flWitchDamage[type], value, 5.0, 1.0, 9999999999.0);
	g_flWitchRange[type] = flGetValue(subsection, "witchability", "witch ability", "witch_ability", "witch", key, "WitchRange", "Witch Range", "Witch_Range", "range", main, g_flWitchRange[type], value, 500.0, 1.0, 9999999999.0);
}

public void ST_OnEventFired(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			if (bIsCloneAllowed(iTank, g_bCloneInstalled) && g_iWitchAbility[ST_GetTankType(iTank)] == 1)
			{
				float flTankPos[3], flTankAngles[3];
				GetClientAbsOrigin(iTank, flTankPos);
				GetClientAbsAngles(iTank, flTankAngles);

				vSpawnWitch(iTank, flTankPos, flTankAngles);
			}

			vRemoveWitch(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) || g_iHumanAbility[ST_GetTankType(tank)] == 0) && bIsCloneAllowed(tank, g_bCloneInstalled) && g_iWitchAbility[ST_GetTankType(tank)] == 1)
	{
		vWitchAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) && bIsCloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SPECIAL_KEY == ST_SPECIAL_KEY)
		{
			if (g_iWitchAbility[ST_GetTankType(tank)] == 1 && g_iHumanAbility[ST_GetTankType(tank)] == 1)
			{
				switch (g_bWitch[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "WitchHuman3");
					case false: vWitchAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank, bool revert)
{
	vRemoveWitch(tank);
}

static void vRemoveWitch(int tank)
{
	g_bWitch[tank] = false;
	g_iWitchCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, ST_CHECK_INGAME|ST_CHECK_KICKQUEUE))
		{
			vRemoveWitch(iPlayer);
		}
	}
}

static void vSpawnWitch(int tank, float pos[3], float angles[3])
{
	int iWitch = CreateEntityByName("witch");
	if (bIsValidEntity(iWitch))
	{
		TeleportEntity(iWitch, pos, angles, NULL_VECTOR);
		DispatchSpawn(iWitch);
		ActivateEntity(iWitch);
		SetEntPropEnt(iWitch, Prop_Send, "m_hOwnerEntity", tank);
	}
}

static void vWitchAbility(int tank)
{
	if (g_iWitchCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
	{
		if (GetRandomFloat(0.1, 100.0) <= g_flWitchChance[ST_GetTankType(tank)])
		{
			int iInfected = -1;
			while ((iInfected = FindEntityByClassname(iInfected, "infected")) != INVALID_ENT_REFERENCE)
			{
				if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1 && !g_bWitch[tank])
				{
					g_bWitch[tank] = true;
					g_iWitchCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WitchHuman", g_iWitchCount[tank], g_iHumanAmmo[ST_GetTankType(tank)]);

					if (g_iWitchCount[tank] < g_iHumanAmmo[ST_GetTankType(tank)] && g_iHumanAmmo[ST_GetTankType(tank)] > 0)
					{
						CreateTimer(g_flHumanCooldown[ST_GetTankType(tank)], tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bWitch[tank] = false;
					}
				}

				if (iGetWitchCount() < g_iWitchAmount[ST_GetTankType(tank)])
				{
					float flTankPos[3], flInfectedPos[3], flInfectedAngles[3];
					GetClientAbsOrigin(tank, flTankPos);
					GetEntPropVector(iInfected, Prop_Send, "m_vecOrigin", flInfectedPos);
					GetEntPropVector(iInfected, Prop_Send, "m_angRotation", flInfectedAngles);

					float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
					if (flDistance <= g_flWitchRange[ST_GetTankType(tank)])
					{
						RemoveEntity(iInfected);
						vSpawnWitch(tank, flInfectedPos, flInfectedAngles);
					}
				}

				if (g_iWitchMessage[ST_GetTankType(tank)] == 1)
				{
					char sTankName[33];
					ST_GetTankName(tank, ST_GetTankType(tank), sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Witch", sTankName);
				}
			}
		}
		else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "WitchHuman2");
		}
	}
	else if (ST_IsTankSupported(tank, ST_CHECK_FAKECLIENT) && g_iHumanAbility[ST_GetTankType(tank)] == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "WitchAmmo");
	}
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, ST_CHECK_INDEX|ST_CHECK_INGAME|ST_CHECK_ALIVE|ST_CHECK_KICKQUEUE|ST_CHECK_FAKECLIENT) || !bIsCloneAllowed(iTank, g_bCloneInstalled) || !g_bWitch[iTank])
	{
		g_bWitch[iTank] = false;

		return Plugin_Stop;
	}

	g_bWitch[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "WitchHuman4");

	return Plugin_Continue;
}