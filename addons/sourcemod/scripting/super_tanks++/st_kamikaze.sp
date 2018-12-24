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
	name = "[ST++] Kamikaze Ability",
	author = ST_AUTHOR,
	description = "The Super Tank kills itself along with a survivor victim.",
	version = ST_VERSION,
	url = ST_URL
};

#define PARTICLE_BLOOD "boomer_explode_D"

#define SOUND_GROWL "player/tank/voice/growl/tank_climb_01.wav"
#define SOUND_SMASH "player/charger/hit/charger_smash_02.wav"

#define ST_MENU_KAMIKAZE "Kamikaze Ability"

bool g_bCloneInstalled, g_bKamikaze[MAXPLAYERS + 1], g_bKamikaze2[MAXPLAYERS + 1], g_bKamikaze3[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sKamikazeEffect[ST_MAXTYPES + 1][4], g_sKamikazeEffect2[ST_MAXTYPES + 1][4], g_sKamikazeMessage[ST_MAXTYPES + 1][3], g_sKamikazeMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flKamikazeChance[ST_MAXTYPES + 1], g_flKamikazeChance2[ST_MAXTYPES + 1], g_flKamikazeRange[ST_MAXTYPES + 1], g_flKamikazeRange2[ST_MAXTYPES + 1], g_flKamikazeRangeChance[ST_MAXTYPES + 1], g_flKamikazeRangeChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iKamikazeAbility[ST_MAXTYPES + 1], g_iKamikazeAbility2[ST_MAXTYPES + 1], g_iKamikazeCount[MAXPLAYERS + 1], g_iKamikazeHit[ST_MAXTYPES + 1], g_iKamikazeHit2[ST_MAXTYPES + 1], g_iKamikazeHitMode[ST_MAXTYPES + 1], g_iKamikazeHitMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Kamikaze Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_kamikaze", cmdKamikazeInfo, "View information about the Kamikaze ability.");

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

	vRemoveKamikaze(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdKamikazeInfo(int client, int args)
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
		case false: vKamikazeMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vKamikazeMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iKamikazeMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Kamikaze Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iKamikazeMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iKamikazeAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iKamikazeCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "KamikazeDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vKamikazeMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "KamikazeMenu", param1);
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
	menu.AddItem(ST_MENU_KAMIKAZE, ST_MENU_KAMIKAZE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_KAMIKAZE, false))
	{
		vKamikazeMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && (iKamikazeHitMode(attacker) == 0 || iKamikazeHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vKamikazeHit(victim, attacker, flKamikazeChance(attacker), iKamikazeHit(attacker), "1", "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && (iKamikazeHitMode(victim) == 0 || iKamikazeHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vKamikazeHit(attacker, victim, flKamikazeChance(victim), iKamikazeHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 1, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iKamikazeAbility[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Ability Enabled", 0);
					g_iKamikazeAbility[iIndex] = iClamp(g_iKamikazeAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Kamikaze Ability/Ability Effect", g_sKamikazeEffect[iIndex], sizeof(g_sKamikazeEffect[]), "0");
					kvSuperTanks.GetString("Kamikaze Ability/Ability Message", g_sKamikazeMessage[iIndex], sizeof(g_sKamikazeMessage[]), "0");
					g_flKamikazeChance[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Kamikaze Chance", 33.3);
					g_flKamikazeChance[iIndex] = flClamp(g_flKamikazeChance[iIndex], 0.0, 100.0);
					g_iKamikazeHit[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Hit", 0);
					g_iKamikazeHit[iIndex] = iClamp(g_iKamikazeHit[iIndex], 0, 1);
					g_iKamikazeHitMode[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Hit Mode", 0);
					g_iKamikazeHitMode[iIndex] = iClamp(g_iKamikazeHitMode[iIndex], 0, 2);
					g_flKamikazeRange[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Kamikaze Range", 150.0);
					g_flKamikazeRange[iIndex] = flClamp(g_flKamikazeRange[iIndex], 1.0, 9999999999.0);
					g_flKamikazeRangeChance[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Kamikaze Range Chance", 15.0);
					g_flKamikazeRangeChance[iIndex] = flClamp(g_flKamikazeRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 1, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iKamikazeAbility2[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Ability Enabled", g_iKamikazeAbility[iIndex]);
					g_iKamikazeAbility2[iIndex] = iClamp(g_iKamikazeAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Kamikaze Ability/Ability Effect", g_sKamikazeEffect2[iIndex], sizeof(g_sKamikazeEffect2[]), g_sKamikazeEffect[iIndex]);
					kvSuperTanks.GetString("Kamikaze Ability/Ability Message", g_sKamikazeMessage2[iIndex], sizeof(g_sKamikazeMessage2[]), g_sKamikazeMessage[iIndex]);
					g_flKamikazeChance2[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Kamikaze Chance", g_flKamikazeChance[iIndex]);
					g_flKamikazeChance2[iIndex] = flClamp(g_flKamikazeChance2[iIndex], 0.0, 100.0);
					g_iKamikazeHit2[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Hit", g_iKamikazeHit[iIndex]);
					g_iKamikazeHit2[iIndex] = iClamp(g_iKamikazeHit2[iIndex], 0, 1);
					g_iKamikazeHitMode2[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Hit Mode", g_iKamikazeHitMode[iIndex]);
					g_iKamikazeHitMode2[iIndex] = iClamp(g_iKamikazeHitMode2[iIndex], 0, 2);
					g_flKamikazeRange2[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Kamikaze Range", g_flKamikazeRange[iIndex]);
					g_flKamikazeRange2[iIndex] = flClamp(g_flKamikazeRange2[iIndex], 1.0, 9999999999.0);
					g_flKamikazeRangeChance2[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Kamikaze Range Chance", g_flKamikazeRangeChance[iIndex]);
					g_flKamikazeRangeChance2[iIndex] = flClamp(g_flKamikazeRangeChance2[iIndex], 0.0, 100.0);
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
			vRemoveKamikaze(iPlayer);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_TankAllowed(tank) && (!ST_TankAllowed(tank, "5") || iHumanAbility(tank) == 0) && ST_CloneAllowed(tank, g_bCloneInstalled) && iKamikazeAbility(tank) == 1)
	{
		vKamikazeAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_TankAllowed(tank, "02345") && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iKamikazeAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (g_bKamikaze[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "KamikazeHuman3");
					case false: vKamikazeAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveKamikaze(tank);
}

static void vKamikazeAbility(int tank)
{
	if (g_iKamikazeCount[tank] < iHumanAmmo(tank))
	{
		g_bKamikaze2[tank] = false;
		g_bKamikaze3[tank] = false;

		float flKamikazeRange = !g_bTankConfig[ST_TankType(tank)] ? g_flKamikazeRange[ST_TankType(tank)] : g_flKamikazeRange2[ST_TankType(tank)],
			flKamikazeRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flKamikazeRangeChance[ST_TankType(tank)] : g_flKamikazeRangeChance2[ST_TankType(tank)],
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
				if (flDistance <= flKamikazeRange)
				{
					vKamikazeHit(iSurvivor, tank, flKamikazeRangeChance, iKamikazeAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "KamikazeHuman4");
			}
		}
	}
	else
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "KamikazeAmmo");
	}
}

static void vKamikazeHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iKamikazeCount[tank] < iHumanAmmo(tank))
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bKamikaze[tank])
				{
					g_bKamikaze[tank] = true;
					g_iKamikazeCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "KamikazeHuman", g_iKamikazeCount[tank], iHumanAmmo(tank));

					if (g_iKamikazeCount[tank] < iHumanAmmo(tank))
					{
						CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bKamikaze[tank] = false;
					}
				}

				EmitSoundToAll(SOUND_SMASH, survivor);
				vAttachParticle(survivor, PARTICLE_BLOOD, 0.1, 0.0);
				ForcePlayerSuicide(survivor);

				EmitSoundToAll(SOUND_GROWL, tank);
				vAttachParticle(tank, PARTICLE_BLOOD, 0.1, 0.0);
				ForcePlayerSuicide(tank);

				char sKamikazeEffect[4];
				sKamikazeEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sKamikazeEffect[ST_TankType(tank)] : g_sKamikazeEffect2[ST_TankType(tank)];
				vEffect(survivor, tank, sKamikazeEffect, mode);

				char sKamikazeMessage[3];
				sKamikazeMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sKamikazeMessage[ST_TankType(tank)] : g_sKamikazeMessage2[ST_TankType(tank)];
				if (StrContains(sKamikazeMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Kamikaze", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bKamikaze[tank])
			{
				if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bKamikaze2[tank])
				{
					g_bKamikaze2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "KamikazeHuman2");
				}
			}
		}
		else
		{
			if (ST_TankAllowed(tank, "5") && iHumanAbility(tank) == 1 && !g_bKamikaze3[tank])
			{
				g_bKamikaze3[tank] = true;

				ST_PrintToChat(tank, "%s %t", ST_TAG3, "KamikazeAmmo");
			}
		}
	}
}

static void vRemoveKamikaze(int tank)
{
	g_bKamikaze[tank] = false;
	g_bKamikaze2[tank] = false;
	g_bKamikaze3[tank] = false;
	g_iKamikazeCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveKamikaze(iPlayer);
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHumanCooldown[ST_TankType(tank)] : g_flHumanCooldown2[ST_TankType(tank)];
}

static float flKamikazeChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flKamikazeChance[ST_TankType(tank)] : g_flKamikazeChance2[ST_TankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAbility[ST_TankType(tank)] : g_iHumanAbility2[ST_TankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHumanAmmo[ST_TankType(tank)] : g_iHumanAmmo2[ST_TankType(tank)];
}

static int iKamikazeAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iKamikazeAbility[ST_TankType(tank)] : g_iKamikazeAbility2[ST_TankType(tank)];
}

static int iKamikazeHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iKamikazeHit[ST_TankType(tank)] : g_iKamikazeHit2[ST_TankType(tank)];
}

static int iKamikazeHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iKamikazeHitMode[ST_TankType(tank)] : g_iKamikazeHitMode2[ST_TankType(tank)];
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bKamikaze[iTank])
	{
		g_bKamikaze[iTank] = false;

		return Plugin_Stop;
	}

	g_bKamikaze[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "KamikazeHuman5");

	return Plugin_Continue;
}