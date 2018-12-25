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
	name = "[ST++] Smash Ability",
	author = ST_AUTHOR,
	description = "The Super Tank smashes survivors to death.",
	version = ST_VERSION,
	url = ST_URL
};

#define PARTICLE_BLOOD "boomer_explode_D"

#define SOUND_GROWL "player/tank/voice/growl/tank_climb_01.wav"
#define SOUND_SMASH "player/charger/hit/charger_smash_02.wav"

#define ST_MENU_SMASH "Smash Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bSmash[MAXPLAYERS + 1], g_bSmash2[MAXPLAYERS + 1], g_bSmash3[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sSmashEffect[ST_MAXTYPES + 1][4], g_sSmashEffect2[ST_MAXTYPES + 1][4], g_sSmashMessage[ST_MAXTYPES + 1][3], g_sSmashMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flSmashChance[ST_MAXTYPES + 1], g_flSmashChance2[ST_MAXTYPES + 1], g_flSmashRange[ST_MAXTYPES + 1], g_flSmashRange2[ST_MAXTYPES + 1], g_flSmashRangeChance[ST_MAXTYPES + 1], g_flSmashRangeChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iSmashAbility[ST_MAXTYPES + 1], g_iSmashAbility2[ST_MAXTYPES + 1], g_iSmashCount[MAXPLAYERS + 1], g_iSmashHit[ST_MAXTYPES + 1], g_iSmashHit2[ST_MAXTYPES + 1], g_iSmashHitMode[ST_MAXTYPES + 1], g_iSmashHitMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Smash Ability\" only supports Left 4 Dead 1 & 2.");

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
	LoadTranslations("super_tanks++.phrases");

	RegConsoleCmd("sm_st_smash", cmdSmashInfo, "View information about the Smash ability.");

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
	vPrecacheParticle(PARTICLE_BLOOD);

	PrecacheSound(SOUND_GROWL, true);
	PrecacheSound(SOUND_SMASH, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveSmash(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdSmashInfo(int client, int args)
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
		case false: vSmashMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vSmashMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iSmashMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Smash Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iSmashMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iSmashAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iSmashCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "SmashDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vSmashMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "SmashMenu", param1);
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
	menu.AddItem(ST_MENU_SMASH, ST_MENU_SMASH);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_SMASH, false))
	{
		vSmashMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && (iSmashHitMode(attacker) == 0 || iSmashHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vSmashHit(victim, attacker, flSmashChance(attacker), iSmashHit(attacker), "1", "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && (iSmashHitMode(victim) == 0 || iSmashHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vSmashHit(attacker, victim, flSmashChance(victim), iSmashHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Smash Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Smash Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iSmashAbility[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Enabled", 0);
					g_iSmashAbility[iIndex] = iClamp(g_iSmashAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Smash Ability/Ability Effect", g_sSmashEffect[iIndex], sizeof(g_sSmashEffect[]), "0");
					kvSuperTanks.GetString("Smash Ability/Ability Message", g_sSmashMessage[iIndex], sizeof(g_sSmashMessage[]), "0");
					g_flSmashChance[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Chance", 33.3);
					g_flSmashChance[iIndex] = flClamp(g_flSmashChance[iIndex], 0.0, 100.0);
					g_iSmashHit[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit", 0);
					g_iSmashHit[iIndex] = iClamp(g_iSmashHit[iIndex], 0, 1);
					g_iSmashHitMode[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit Mode", 0);
					g_iSmashHitMode[iIndex] = iClamp(g_iSmashHitMode[iIndex], 0, 2);
					g_flSmashRange[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range", 150.0);
					g_flSmashRange[iIndex] = flClamp(g_flSmashRange[iIndex], 1.0, 9999999999.0);
					g_flSmashRangeChance[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range Chance", 15.0);
					g_flSmashRangeChance[iIndex] = flClamp(g_flSmashRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iSmashAbility2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Enabled", g_iSmashAbility[iIndex]);
					g_iSmashAbility2[iIndex] = iClamp(g_iSmashAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Smash Ability/Ability Effect", g_sSmashEffect2[iIndex], sizeof(g_sSmashEffect2[]), g_sSmashEffect[iIndex]);
					kvSuperTanks.GetString("Smash Ability/Ability Message", g_sSmashMessage2[iIndex], sizeof(g_sSmashMessage2[]), g_sSmashMessage[iIndex]);
					g_flSmashChance2[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Chance", g_flSmashChance[iIndex]);
					g_flSmashChance2[iIndex] = flClamp(g_flSmashChance2[iIndex], 0.0, 100.0);
					g_iSmashHit2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit", g_iSmashHit[iIndex]);
					g_iSmashHit2[iIndex] = iClamp(g_iSmashHit2[iIndex], 0, 1);
					g_iSmashHitMode2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit Mode", g_iSmashHitMode[iIndex]);
					g_iSmashHitMode2[iIndex] = iClamp(g_iSmashHitMode2[iIndex], 0, 2);
					g_flSmashRange2[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range", g_flSmashRange[iIndex]);
					g_flSmashRange2[iIndex] = flClamp(g_flSmashRange2[iIndex], 1.0, 9999999999.0);
					g_flSmashRangeChance2[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range Chance", g_flSmashRangeChance[iIndex]);
					g_flSmashRangeChance2[iIndex] = flClamp(g_flSmashRangeChance2[iIndex], 0.0, 100.0);
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
		int iUserId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iUserId),
			iTankId = event.GetInt("attacker"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank, "024") && ST_CloneAllowed(iTank, g_bCloneInstalled) && bIsSurvivor(iPlayer))
		{
			int iCorpse = -1;
			while ((iCorpse = FindEntityByClassname(iCorpse, "survivor_death_model")) != INVALID_ENT_REFERENCE)
			{
				int iOwner = GetEntPropEnt(iCorpse, Prop_Send, "m_hOwnerEntity");
				if (iPlayer == iOwner)
				{
					RemoveEntity(iCorpse);
				}
			}
		}

		if (ST_TankAllowed(iPlayer, "024") && ST_CloneAllowed(iPlayer, g_bCloneInstalled))
		{
			vRemoveSmash(iPlayer);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iSmashAbility(tank) == 1)
	{
		vSmashAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iSmashAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (g_bSmash[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "SmashHuman3");
					case false: vSmashAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveSmash(tank);
}

static void vRemoveSmash(int tank)
{
	g_bSmash[tank] = false;
	g_bSmash2[tank] = false;
	g_bSmash3[tank] = false;
	g_iSmashCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveSmash(iPlayer);
		}
	}
}

static void vSmashAbility(int tank)
{
	if (g_iSmashCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bSmash2[tank] = false;
		g_bSmash3[tank] = false;

		float flSmashRange = !g_bTankConfig[ST_TankType(tank)] ? g_flSmashRange[ST_TankType(tank)] : g_flSmashRange2[ST_TankType(tank)],
			flSmashRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flSmashRangeChance[ST_TankType(tank)] : g_flSmashRangeChance2[ST_TankType(tank)],
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
				if (flDistance <= flSmashRange)
				{
					vSmashHit(iSurvivor, tank, flSmashRangeChance, iSmashAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "SmashHuman4");
			}
		}
	}
	else
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "SmashAmmo");
	}
}

static void vSmashHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iSmashCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bSmash[tank])
				{
					g_bSmash[tank] = true;
					g_iSmashCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "SmashHuman", g_iSmashCount[tank], iHumanAmmo(tank));

					if (g_iSmashCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
					{
						CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bSmash[tank] = false;
					}
				}

				EmitSoundToAll(SOUND_SMASH, survivor);
				EmitSoundToAll(SOUND_GROWL, tank);

				vAttachParticle(survivor, PARTICLE_BLOOD, 0.1, 0.0);
				ForcePlayerSuicide(survivor);

				char sSmashEffect[4];
				sSmashEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sSmashEffect[ST_TankType(tank)] : g_sSmashEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sSmashEffect, mode);

				char sSmashMessage[3];
				sSmashMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sSmashMessage[ST_TankType(tank)] : g_sSmashMessage2[ST_TankType(tank)];
				if (StrContains(sSmashMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Smash", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bSmash[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bSmash2[tank])
				{
					g_bSmash2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "SmashHuman2");
				}
			}
		}
		else
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bSmash3[tank])
			{
				g_bSmash3[tank] = true;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "SmashAmmo");
			}
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flSmashChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flSmashChance[ST_TankType(tank)] : g_flSmashChance2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iSmashAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iSmashAbility[ST_TankType(tank)] : g_iSmashAbility2[ST_TankType(tank)];
}

static int iSmashHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iSmashHit[ST_TankType(tank)] : g_iSmashHit2[ST_TankType(tank)];
}

static int iSmashHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iSmashHitMode[ST_TankType(tank)] : g_iSmashHitMode2[ST_TankType(tank)];
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bSmash[iTank])
	{
		g_bSmash[iTank] = false;

		return Plugin_Stop;
	}

	g_bSmash[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "SmashHuman5");

	return Plugin_Continue;
}