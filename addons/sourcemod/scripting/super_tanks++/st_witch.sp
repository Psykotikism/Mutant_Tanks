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
	name = "[ST++] Witch Ability",
	author = ST_AUTHOR,
	description = "The Super Tank converts nearby common infected into Witch minions.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_WITCH "Witch Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1], g_bWitch[MAXPLAYERS + 1];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flWitchChance[ST_MAXTYPES + 1], g_flWitchChance2[ST_MAXTYPES + 1], g_flWitchDamage[ST_MAXTYPES + 1], g_flWitchDamage2[ST_MAXTYPES + 1], g_flWitchRange[ST_MAXTYPES + 1], g_flWitchRange2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iWitchAbility[ST_MAXTYPES + 1], g_iWitchAbility2[ST_MAXTYPES + 1], g_iWitchAmount[ST_MAXTYPES + 1], g_iWitchAmount2[ST_MAXTYPES + 1], g_iWitchCount[MAXPLAYERS + 1], g_iWitchMessage[ST_MAXTYPES + 1], g_iWitchMessage2[ST_MAXTYPES + 1];

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

	vRemoveWitch(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdWitchInfo(int client, int args)
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
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iWitchAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iWitchCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons3");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "WitchDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
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
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		if (bIsWitch(attacker) && bIsSurvivor(victim))
		{
			int iOwner;
			if (HasEntProp(attacker, Prop_Send, "m_hOwnerEntity"))
			{
				iOwner = GetEntPropEnt(attacker, Prop_Send, "m_hOwnerEntity");
			}

			if (ST_TankAllowed(iOwner) && ST_CloneAllowed(iOwner, g_bCloneInstalled))
			{
				float flWitchDamage = !g_bTankConfig[ST_TankType(iOwner)] ? g_flWitchDamage[ST_TankType(iOwner)] : g_flWitchDamage2[ST_TankType(iOwner)];
				damage = flWitchDamage;

				return Plugin_Changed;
			}
		}
	}

	return Plugin_Continue;
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Witch Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Witch Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Witch Ability/Human Cooldown", 60.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iWitchAbility[iIndex] = kvSuperTanks.GetNum("Witch Ability/Ability Enabled", 0);
					g_iWitchAbility[iIndex] = iClamp(g_iWitchAbility[iIndex], 0, 1);
					g_iWitchMessage[iIndex] = kvSuperTanks.GetNum("Witch Ability/Ability Message", 0);
					g_iWitchMessage[iIndex] = iClamp(g_iWitchMessage[iIndex], 0, 1);
					g_iWitchAmount[iIndex] = kvSuperTanks.GetNum("Witch Ability/Witch Amount", 3);
					g_iWitchAmount[iIndex] = iClamp(g_iWitchAmount[iIndex], 1, 25);
					g_flWitchChance[iIndex] = kvSuperTanks.GetFloat("Witch Ability/Witch Chance", 33.3);
					g_flWitchChance[iIndex] = flClamp(g_flWitchChance[iIndex], 0.0, 100.0);
					g_flWitchDamage[iIndex] = kvSuperTanks.GetFloat("Witch Ability/Witch Damage", 5.0);
					g_flWitchDamage[iIndex] = flClamp(g_flWitchDamage[iIndex], 1.0, 9999999999.0);
					g_flWitchRange[iIndex] = kvSuperTanks.GetFloat("Witch Ability/Witch Range", 500.0);
					g_flWitchRange[iIndex] = flClamp(g_flWitchRange[iIndex], 1.0, 9999999999.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Witch Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Witch Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Witch Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iWitchAbility2[iIndex] = kvSuperTanks.GetNum("Witch Ability/Ability Enabled", g_iWitchAbility[iIndex]);
					g_iWitchAbility2[iIndex] = iClamp(g_iWitchAbility2[iIndex], 0, 1);
					g_iWitchMessage2[iIndex] = kvSuperTanks.GetNum("Witch Ability/Ability Message", g_iWitchMessage[iIndex]);
					g_iWitchMessage2[iIndex] = iClamp(g_iWitchMessage2[iIndex], 0, 1);
					g_iWitchAmount2[iIndex] = kvSuperTanks.GetNum("Witch Ability/Witch Amount", g_iWitchAmount[iIndex]);
					g_iWitchAmount2[iIndex] = iClamp(g_iWitchAmount2[iIndex], 1, 25);
					g_flWitchChance2[iIndex] = kvSuperTanks.GetFloat("Witch Ability/Witch Chance", g_flWitchChance[iIndex]);
					g_flWitchChance2[iIndex] = flClamp(g_flWitchChance2[iIndex], 0.0, 100.0);
					g_flWitchDamage2[iIndex] = kvSuperTanks.GetFloat("Witch Ability/Witch Damage", g_flWitchDamage[iIndex]);
					g_flWitchDamage2[iIndex] = flClamp(g_flWitchDamage2[iIndex], 1.0, 9999999999.0);
					g_flWitchRange2[iIndex] = kvSuperTanks.GetFloat("Witch Ability/Witch Range", g_flWitchRange[iIndex]);
					g_flWitchRange2[iIndex] = flClamp(g_flWitchRange2[iIndex], 1.0, 9999999999.0);
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
			vRemoveWitch(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iWitchAbility(tank) == 1)
	{
		vWitchAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SPECIAL_KEY == ST_SPECIAL_KEY)
		{
			if (iWitchAbility(tank) == 1 && iHumanAbility(tank) == 1)
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

public void ST_OnChangeType(int tank)
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
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveWitch(iPlayer);
		}
	}
}

static void vWitchAbility(int tank)
{
	if (g_iWitchCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		float flWitchChance = !g_bTankConfig[ST_TankType(tank)] ? g_flWitchChance[ST_TankType(tank)] : g_flWitchChance2[ST_TankType(tank)];
		if (GetRandomFloat(0.1, 100.0) <= flWitchChance)
		{
			int iInfected = -1;
			while ((iInfected = FindEntityByClassname(iInfected, "infected")) != INVALID_ENT_REFERENCE)
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bWitch[tank])
				{
					g_bWitch[tank] = true;
					g_iWitchCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "WitchHuman", g_iWitchCount[tank], iHumanAmmo(tank));

					if (g_iWitchCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
					{
						CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bWitch[tank] = false;
					}
				}

				int iWitchAmount = !g_bTankConfig[ST_TankType(tank)] ? g_iWitchAmount[ST_TankType(tank)] : g_iWitchAmount2[ST_TankType(tank)];
				if (iGetWitchCount() < iWitchAmount)
				{
					float flTankPos[3], flInfectedPos[3], flInfectedAng[3];
					GetClientAbsOrigin(tank, flTankPos);
					GetEntPropVector(iInfected, Prop_Send, "m_vecOrigin", flInfectedPos);
					GetEntPropVector(iInfected, Prop_Send, "m_angRotation", flInfectedAng);

					float flWitchRange = !g_bTankConfig[ST_TankType(tank)] ? g_flWitchRange[ST_TankType(tank)] : g_flWitchRange[ST_TankType(tank)], flDistance = GetVectorDistance(flInfectedPos, flTankPos);
					if (flDistance <= flWitchRange)
					{
						RemoveEntity(iInfected);

						int iWitch = CreateEntityByName("witch");
						if (bIsValidEntity(iWitch))
						{
							TeleportEntity(iWitch, flInfectedPos, flInfectedAng, NULL_VECTOR);

							DispatchSpawn(iWitch);
							ActivateEntity(iWitch);
							SetEntPropEnt(iWitch, Prop_Send, "m_hOwnerEntity", tank);
						}
					}
				}

				int iWitchMessage = !g_bTankConfig[ST_TankType(tank)] ? g_iWitchMessage[ST_TankType(tank)] : g_iWitchMessage2[ST_TankType(tank)];
				if (iWitchMessage == 1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Witch", sTankName);
				}
			}
		}
		else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
		{
			ST_PrintToChat(tank, "%s %t", ST_TAG3, "WitchHuman2");
		}
	}
	else if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "WitchAmmo");
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iWitchAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWitchAbility[ST_TankType(tank)] : g_iWitchAbility2[ST_TankType(tank)];
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank, "02345") || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bWitch[iTank])
	{
		g_bWitch[iTank] = false;

		return Plugin_Stop;
	}

	g_bWitch[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "WitchHuman4");

	return Plugin_Continue;
}