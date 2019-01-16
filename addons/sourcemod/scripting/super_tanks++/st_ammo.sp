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
	name = "[ST++] Ammo Ability",
	author = ST_AUTHOR,
	description = "The Super Tank takes away survivors' ammunition.",
	version = ST_VERSION,
	url = ST_URL
};

#define ST_MENU_AMMO "Ammo Ability"

bool g_bAmmo[MAXPLAYERS + 1], g_bAmmo2[MAXPLAYERS + 1], g_bAmmo3[MAXPLAYERS + 1], g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sAmmoEffect[ST_MAXTYPES + 1][4], g_sAmmoEffect2[ST_MAXTYPES + 1][4], g_sAmmoMessage[ST_MAXTYPES + 1][3], g_sAmmoMessage2[ST_MAXTYPES + 1][3];

float g_flAmmoChance[ST_MAXTYPES + 1], g_flAmmoChance2[ST_MAXTYPES + 1], g_flAmmoRange[ST_MAXTYPES + 1], g_flAmmoRange2[ST_MAXTYPES + 1], g_flAmmoRangeChance[ST_MAXTYPES + 1], g_flAmmoRangeChance2[ST_MAXTYPES + 1], g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1];

int g_iAmmoAbility[ST_MAXTYPES + 1], g_iAmmoAbility2[ST_MAXTYPES + 1], g_iAmmoAmount[ST_MAXTYPES + 1], g_iAmmoAmount2[ST_MAXTYPES + 1], g_iAmmoCount[MAXPLAYERS + 1], g_iAmmoHit[ST_MAXTYPES + 1], g_iAmmoHit2[ST_MAXTYPES + 1], g_iAmmoHitMode[ST_MAXTYPES + 1], g_iAmmoHitMode2[ST_MAXTYPES + 1], g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Ammo Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_ammo", cmdAmmoInfo, "View information about the Ammo ability.");

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

	vRemoveAmmo(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdAmmoInfo(int client, int args)
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
		case false: vAmmoMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vAmmoMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iAmmoMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Ammo Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iAmmoMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iAmmoAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iAmmoCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AmmoDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vAmmoMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "AmmoMenu", param1);
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
	menu.AddItem(ST_MENU_AMMO, ST_MENU_AMMO);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_AMMO, false))
	{
		vAmmoMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && (iAmmoHitMode(attacker) == 0 || iAmmoHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vAmmoHit(victim, attacker, flAmmoChance(attacker), iAmmoHit(attacker), "1", "1");
			}
		}
		else if (ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && (iAmmoHitMode(victim) == 0 || iAmmoHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vAmmoHit(attacker, victim, flAmmoChance(victim), iAmmoHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Ammo Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iAmmoAbility[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ability Enabled", 0);
					g_iAmmoAbility[iIndex] = iClamp(g_iAmmoAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Ammo Ability/Ability Effect", g_sAmmoEffect[iIndex], sizeof(g_sAmmoEffect[]), "0");
					kvSuperTanks.GetString("Ammo Ability/Ability Message", g_sAmmoMessage[iIndex], sizeof(g_sAmmoMessage[]), "0");
					g_flAmmoChance[iIndex] = kvSuperTanks.GetFloat("Ammo Ability/Ammo Chance", 33.3);
					g_flAmmoChance[iIndex] = flClamp(g_flAmmoChance[iIndex], 0.0, 100.0);
					g_iAmmoAmount[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Count", 0);
					g_iAmmoAmount[iIndex] = iClamp(g_iAmmoAmount[iIndex], 0, 25);
					g_iAmmoHit[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Hit", 0);
					g_iAmmoHit[iIndex] = iClamp(g_iAmmoHit[iIndex], 0, 1);
					g_iAmmoHitMode[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Hit Mode", 0);
					g_iAmmoHitMode[iIndex] = iClamp(g_iAmmoHitMode[iIndex], 0, 2);
					g_flAmmoRange[iIndex] = kvSuperTanks.GetFloat("Ammo Ability/Ammo Range", 150.0);
					g_flAmmoRange[iIndex] = flClamp(g_flAmmoRange[iIndex], 1.0, 9999999999.0);
					g_flAmmoRangeChance[iIndex] = kvSuperTanks.GetFloat("Ammo Ability/Ammo Range Chance", 15.0);
					g_flAmmoRangeChance[iIndex] = flClamp(g_flAmmoRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Ammo Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iAmmoAbility2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ability Enabled", g_iAmmoAbility[iIndex]);
					g_iAmmoAbility2[iIndex] = iClamp(g_iAmmoAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Ammo Ability/Ability Effect", g_sAmmoEffect2[iIndex], sizeof(g_sAmmoEffect2[]), g_sAmmoEffect[iIndex]);
					kvSuperTanks.GetString("Ammo Ability/Ability Message", g_sAmmoMessage2[iIndex], sizeof(g_sAmmoMessage2[]), g_sAmmoMessage[iIndex]);
					g_flAmmoChance2[iIndex] = kvSuperTanks.GetFloat("Ammo Ability/Ammo Chance", g_flAmmoChance[iIndex]);
					g_flAmmoChance2[iIndex] = flClamp(g_flAmmoChance2[iIndex], 0.0, 100.0);
					g_iAmmoAmount2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Count", g_iAmmoAmount[iIndex]);
					g_iAmmoAmount2[iIndex] = iClamp(g_iAmmoAmount2[iIndex], 0, 25);
					g_iAmmoHit2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Hit", g_iAmmoHit[iIndex]);
					g_iAmmoHit2[iIndex] = iClamp(g_iAmmoHit2[iIndex], 0, 1);
					g_iAmmoHitMode2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Hit Mode", g_iAmmoHitMode[iIndex]);
					g_iAmmoHitMode2[iIndex] = iClamp(g_iAmmoHitMode2[iIndex], 0, 2);
					g_flAmmoRange2[iIndex] = kvSuperTanks.GetFloat("Ammo Ability/Ammo Range", g_flAmmoRange[iIndex]);
					g_flAmmoRange2[iIndex] = flClamp(g_flAmmoRange2[iIndex], 1.0, 9999999999.0);
					g_flAmmoRangeChance2[iIndex] = kvSuperTanks.GetFloat("Ammo Ability/Ammo Range Chance", g_flAmmoRangeChance[iIndex]);
					g_flAmmoRangeChance2[iIndex] = flClamp(g_flAmmoRangeChance2[iIndex], 0.0, 100.0);
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
		if (ST_IsTankSupported(iTank, "024"))
		{
			vRemoveAmmo(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, "5") || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iAmmoAbility(tank) == 1)
	{
		vAmmoAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iAmmoAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (g_bAmmo[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "AmmoHuman3");
					case false: vAmmoAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveAmmo(tank);
}

static void vAmmoAbility(int tank)
{
	if (g_iAmmoCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bAmmo2[tank] = false;
		g_bAmmo3[tank] = false;

		float flAmmoRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flAmmoRange[ST_GetTankType(tank)] : g_flAmmoRange2[ST_GetTankType(tank)],
			flAmmoRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flAmmoRangeChance[ST_GetTankType(tank)] : g_flAmmoRangeChance2[ST_GetTankType(tank)],
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
				if (flDistance <= flAmmoRange)
				{
					vAmmoHit(iSurvivor, tank, flAmmoRangeChance, iAmmoAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "AmmoHuman4");
			}
		}
	}
	else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "AmmoAmmo");
	}
}

static void vAmmoHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor) && GetPlayerWeaponSlot(survivor, 0) > 0)
	{
		if (g_iAmmoCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bAmmo[tank])
				{
					g_bAmmo[tank] = true;
					g_iAmmoCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "AmmoHuman", g_iAmmoCount[tank], iHumanAmmo(tank));

					if (g_iAmmoCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
					{
						CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bAmmo[tank] = false;
					}
				}

				char sWeapon[32];
				int iActiveWeapon = GetEntPropEnt(survivor, Prop_Data, "m_hActiveWeapon"),
					iAmmoAmount = !g_bTankConfig[ST_GetTankType(tank)] ? g_iAmmoAmount[ST_GetTankType(tank)] : g_iAmmoAmount2[ST_GetTankType(tank)];
				GetEntityClassname(iActiveWeapon, sWeapon, sizeof(sWeapon));
				if (bIsValidEntity(iActiveWeapon))
				{
					if (StrEqual(sWeapon, "weapon_rifle") || StrEqual(sWeapon, "weapon_rifle_desert") || StrEqual(sWeapon, "weapon_rifle_ak47") || StrEqual(sWeapon, "weapon_rifle_sg552"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", iAmmoAmount, _, 3);
					}
					else if (StrEqual(sWeapon, "weapon_smg") || StrEqual(sWeapon, "weapon_smg_silenced") || StrEqual(sWeapon, "weapon_smg_mp5"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", iAmmoAmount, _, 5);
					}
					else if (StrEqual(sWeapon, "weapon_pumpshotgun"))
					{
						switch (bIsValidGame())
						{
							case true: SetEntProp(survivor, Prop_Data, "m_iAmmo", iAmmoAmount, _, 7);
							case false: SetEntProp(survivor, Prop_Data, "m_iAmmo", iAmmoAmount, _, 6);
						}
					}
					else if (StrEqual(sWeapon, "weapon_shotgun_chrome"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", iAmmoAmount, _, 7);
					}
					else if (StrEqual(sWeapon, "weapon_autoshotgun"))
					{
						switch (bIsValidGame())
						{
							case true: SetEntProp(survivor, Prop_Data, "m_iAmmo", iAmmoAmount, _, 8);
							case false: SetEntProp(survivor, Prop_Data, "m_iAmmo", iAmmoAmount, _, 6);
						}
					}
					else if (StrEqual(sWeapon, "weapon_shotgun_spas"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", iAmmoAmount, _, 8);
					}
					else if (StrEqual(sWeapon, "weapon_hunting_rifle"))
					{
						switch (bIsValidGame())
						{
							case true: SetEntProp(survivor, Prop_Data, "m_iAmmo", iAmmoAmount, _, 9);
							case false: SetEntProp(survivor, Prop_Data, "m_iAmmo", iAmmoAmount, _, 2);
						}
					}
					else if (StrEqual(sWeapon, "weapon_sniper_scout") || StrEqual(sWeapon, "weapon_sniper_military") || StrEqual(sWeapon, "weapon_sniper_awp"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", iAmmoAmount, _, 10);
					}
					else if (StrEqual(sWeapon, "weapon_grenade_launcher"))
					{
						SetEntProp(survivor, Prop_Data, "m_iAmmo", iAmmoAmount, _, 17);
					}
				}

				SetEntProp(GetPlayerWeaponSlot(survivor, 0), Prop_Data, "m_iClip1", iAmmoAmount, 1);

				char sAmmoEffect[4];
				sAmmoEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_sAmmoEffect[ST_GetTankType(tank)] : g_sAmmoEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, sAmmoEffect, mode);

				char sAmmoMessage[3];
				sAmmoMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sAmmoMessage[ST_GetTankType(tank)] : g_sAmmoMessage2[ST_GetTankType(tank)];
				if (StrContains(sAmmoMessage, message) != -1)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Ammo", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bAmmo[tank])
			{
				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bAmmo2[tank])
				{
					g_bAmmo2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "AmmoHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bAmmo3[tank])
		{
			g_bAmmo3[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "AmmoAmmo");
		}
	}
}

static void vRemoveAmmo(int tank)
{
	g_bAmmo[tank] = false;
	g_bAmmo2[tank] = false;
	g_bAmmo3[tank] = false;
	g_iAmmoCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveAmmo(iPlayer);
		}
	}
}

static float flAmmoChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flAmmoChance[ST_GetTankType(tank)] : g_flAmmoChance2[ST_GetTankType(tank)];
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static int iAmmoAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iAmmoAbility[ST_GetTankType(tank)] : g_iAmmoAbility2[ST_GetTankType(tank)];
}

static int iAmmoHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iAmmoHit[ST_GetTankType(tank)] : g_iAmmoHit2[ST_GetTankType(tank)];
}

static int iAmmoHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iAmmoHitMode[ST_GetTankType(tank)] : g_iAmmoHitMode2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bAmmo[iTank])
	{
		g_bAmmo[iTank] = false;

		return Plugin_Stop;
	}

	g_bAmmo[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "AmmoHuman5");

	return Plugin_Continue;
}