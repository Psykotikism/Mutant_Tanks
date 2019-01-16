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
	name = "[ST++] Smite Ability",
	author = ST_AUTHOR,
	description = "The Super Tank smites survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define SPRITE_GLOW "sprites/glow.vmt"

#define SOUND_EXPLOSION "ambient/explosions/explode_2.wav"

#define ST_MENU_SMITE "Smite Ability"

bool g_bCloneInstalled, g_bLateLoad, g_bSmite[MAXPLAYERS + 1], g_bSmite2[MAXPLAYERS + 1], g_bSmite3[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sSmiteEffect[ST_MAXTYPES + 1][4], g_sSmiteEffect2[ST_MAXTYPES + 1][4], g_sSmiteMessage[ST_MAXTYPES + 1][3], g_sSmiteMessage2[ST_MAXTYPES + 1][3];

float g_flHumanCooldown[ST_MAXTYPES + 1], g_flHumanCooldown2[ST_MAXTYPES + 1], g_flSmiteChance[ST_MAXTYPES + 1], g_flSmiteChance2[ST_MAXTYPES + 1], g_flSmiteRange[ST_MAXTYPES + 1], g_flSmiteRange2[ST_MAXTYPES + 1], g_flSmiteRangeChance[ST_MAXTYPES + 1], g_flSmiteRangeChance2[ST_MAXTYPES + 1];

int g_iHumanAbility[ST_MAXTYPES + 1], g_iHumanAbility2[ST_MAXTYPES + 1], g_iHumanAmmo[ST_MAXTYPES + 1], g_iHumanAmmo2[ST_MAXTYPES + 1], g_iSmiteAbility[ST_MAXTYPES + 1], g_iSmiteAbility2[ST_MAXTYPES + 1], g_iSmiteCount[MAXPLAYERS + 1], g_iSmiteHit[ST_MAXTYPES + 1], g_iSmiteHit2[ST_MAXTYPES + 1], g_iSmiteHitMode[ST_MAXTYPES + 1], g_iSmiteHitMode2[ST_MAXTYPES + 1], g_iSmiteSprite = -1;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Smite Ability\" only supports Left 4 Dead 1 & 2.");

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

	RegConsoleCmd("sm_st_smite", cmdSmiteInfo, "View information about the Smite ability.");

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
	g_iSmiteSprite = PrecacheModel(SPRITE_GLOW, true);

	PrecacheSound(SOUND_EXPLOSION, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	vRemoveSmite(client);
}

public void OnMapEnd()
{
	vReset();
}

public Action cmdSmiteInfo(int client, int args)
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
		case false: vSmiteMenu(client, 0);
	}

	return Plugin_Handled;
}

static void vSmiteMenu(int client, int item)
{
	Menu mAbilityMenu = new Menu(iSmiteMenuHandler, MENU_ACTIONS_DEFAULT|MenuAction_Display|MenuAction_DisplayItem);
	mAbilityMenu.SetTitle("Smite Ability Information");
	mAbilityMenu.AddItem("Status", "Status");
	mAbilityMenu.AddItem("Ammunition", "Ammunition");
	mAbilityMenu.AddItem("Buttons", "Buttons");
	mAbilityMenu.AddItem("Cooldown", "Cooldown");
	mAbilityMenu.AddItem("Details", "Details");
	mAbilityMenu.AddItem("Human Support", "Human Support");
	mAbilityMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iSmiteMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: ST_PrintToChat(param1, "%s %t", ST_TAG3, iSmiteAbility(param1) == 0 ? "AbilityStatus1" : "AbilityStatus2");
				case 1: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityAmmo", iHumanAmmo(param1) - g_iSmiteCount[param1], iHumanAmmo(param1));
				case 2: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityButtons2");
				case 3: ST_PrintToChat(param1, "%s %t", ST_TAG3, "AbilityCooldown", flHumanCooldown(param1));
				case 4: ST_PrintToChat(param1, "%s %t", ST_TAG3, "SmiteDetails");
				case 5: ST_PrintToChat(param1, "%s %t", ST_TAG3, iHumanAbility(param1) == 0 ? "AbilityHumanSupport1" : "AbilityHumanSupport2");
			}

			if (bIsValidClient(param1, "24"))
			{
				vSmiteMenu(param1, menu.Selection);
			}
		}
		case MenuAction_Display:
		{
			char sMenuTitle[255];
			Panel panel = view_as<Panel>(param2);
			Format(sMenuTitle, sizeof(sMenuTitle), "%T", "SmiteMenu", param1);
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
	menu.AddItem(ST_MENU_SMITE, ST_MENU_SMITE);
}

public void ST_OnMenuItemSelected(int client, const char[] info)
{
	if (StrEqual(info, ST_MENU_SMITE, false))
	{
		vSmiteMenu(client, 0);
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_IsCorePluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if (ST_IsTankSupported(attacker) && ST_IsCloneSupported(attacker, g_bCloneInstalled) && (iSmiteHitMode(attacker) == 0 || iSmiteHitMode(attacker) == 1) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vSmiteHit(victim, attacker, flSmiteChance(attacker), iSmiteHit(attacker), "1", "1");
			}
		}
		else if (ST_IsTankSupported(victim) && ST_IsCloneSupported(victim, g_bCloneInstalled) && (iSmiteHitMode(victim) == 0 || iSmiteHitMode(victim) == 2) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vSmiteHit(attacker, victim, flSmiteChance(victim), iSmiteHit(victim), "1", "2");
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

					g_iHumanAbility[iIndex] = kvSuperTanks.GetNum("Smite Ability/Human Ability", 0);
					g_iHumanAbility[iIndex] = iClamp(g_iHumanAbility[iIndex], 0, 1);
					g_iHumanAmmo[iIndex] = kvSuperTanks.GetNum("Smite Ability/Human Ammo", 5);
					g_iHumanAmmo[iIndex] = iClamp(g_iHumanAmmo[iIndex], 0, 9999999999);
					g_flHumanCooldown[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Human Cooldown", 30.0);
					g_flHumanCooldown[iIndex] = flClamp(g_flHumanCooldown[iIndex], 0.0, 9999999999.0);
					g_iSmiteAbility[iIndex] = kvSuperTanks.GetNum("Smite Ability/Ability Enabled", 0);
					g_iSmiteAbility[iIndex] = iClamp(g_iSmiteAbility[iIndex], 0, 1);
					kvSuperTanks.GetString("Smite Ability/Ability Effect", g_sSmiteEffect[iIndex], sizeof(g_sSmiteEffect[]), "0");
					kvSuperTanks.GetString("Smite Ability/Ability Message", g_sSmiteMessage[iIndex], sizeof(g_sSmiteMessage[]), "0");
					g_flSmiteChance[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Chance", 33.3);
					g_flSmiteChance[iIndex] = flClamp(g_flSmiteChance[iIndex], 0.0, 100.0);
					g_iSmiteHit[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Hit", 0);
					g_iSmiteHit[iIndex] = iClamp(g_iSmiteHit[iIndex], 0, 1);
					g_iSmiteHitMode[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Hit Mode", 0);
					g_iSmiteHitMode[iIndex] = iClamp(g_iSmiteHitMode[iIndex], 0, 2);
					g_flSmiteRange[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Range", 150.0);
					g_flSmiteRange[iIndex] = flClamp(g_flSmiteRange[iIndex], 1.0, 9999999999.0);
					g_flSmiteRangeChance[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Range Chance", 15.0);
					g_flSmiteRangeChance[iIndex] = flClamp(g_flSmiteRangeChance[iIndex], 0.0, 100.0);
				}
				case false:
				{
					g_bTankConfig[iIndex] = true;

					g_iHumanAbility2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Human Ability", g_iHumanAbility[iIndex]);
					g_iHumanAbility2[iIndex] = iClamp(g_iHumanAbility2[iIndex], 0, 1);
					g_iHumanAmmo2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Human Ammo", g_iHumanAmmo[iIndex]);
					g_iHumanAmmo2[iIndex] = iClamp(g_iHumanAmmo2[iIndex], 0, 9999999999);
					g_flHumanCooldown2[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Human Cooldown", g_flHumanCooldown[iIndex]);
					g_flHumanCooldown2[iIndex] = flClamp(g_flHumanCooldown2[iIndex], 0.0, 9999999999.0);
					g_iSmiteAbility2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Ability Enabled", g_iSmiteAbility[iIndex]);
					g_iSmiteAbility2[iIndex] = iClamp(g_iSmiteAbility2[iIndex], 0, 1);
					kvSuperTanks.GetString("Smite Ability/Ability Effect", g_sSmiteEffect2[iIndex], sizeof(g_sSmiteEffect2[]), g_sSmiteEffect[iIndex]);
					kvSuperTanks.GetString("Smite Ability/Ability Message", g_sSmiteMessage2[iIndex], sizeof(g_sSmiteMessage2[]), g_sSmiteMessage[iIndex]);
					g_flSmiteChance2[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Chance", g_flSmiteChance[iIndex]);
					g_flSmiteChance2[iIndex] = flClamp(g_flSmiteChance2[iIndex], 0.0, 100.0);
					g_iSmiteHit2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Hit", g_iSmiteHit[iIndex]);
					g_iSmiteHit2[iIndex] = iClamp(g_iSmiteHit2[iIndex], 0, 1);
					g_iSmiteHitMode2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Hit Mode", g_iSmiteHitMode[iIndex]);
					g_iSmiteHitMode2[iIndex] = iClamp(g_iSmiteHitMode2[iIndex], 0, 2);
					g_flSmiteRange2[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Range", g_flSmiteRange[iIndex]);
					g_flSmiteRange2[iIndex] = flClamp(g_flSmiteRange2[iIndex], 1.0, 9999999999.0);
					g_flSmiteRangeChance2[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Range Chance", g_flSmiteRangeChance[iIndex]);
					g_flSmiteRangeChance2[iIndex] = flClamp(g_flSmiteRangeChance2[iIndex], 0.0, 100.0);
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
			if (ST_IsCloneSupported(iTank, g_bCloneInstalled) && iSmiteAbility(iTank) == 1)
			{
				vSmite(iTank);
			}

			vRemoveSmite(iTank);
		}
	}
}

public void ST_OnAbilityActivated(int tank)
{
	if (ST_IsTankSupported(tank) && (!ST_IsTankSupported(tank, "5") || iHumanAbility(tank) == 0) && ST_IsCloneSupported(tank, g_bCloneInstalled) && iSmiteAbility(tank) == 1)
	{
		vSmiteAbility(tank);
	}
}

public void ST_OnButtonPressed(int tank, int button)
{
	if (ST_IsTankSupported(tank, "02345") && ST_IsCloneSupported(tank, g_bCloneInstalled))
	{
		if (button & ST_SUB_KEY == ST_SUB_KEY)
		{
			if (iSmiteAbility(tank) == 1 && iHumanAbility(tank) == 1)
			{
				switch (g_bSmite[tank])
				{
					case true: ST_PrintToChat(tank, "%s %t", ST_TAG3, "SmiteHuman3");
					case false: vSmiteAbility(tank);
				}
			}
		}
	}
}

public void ST_OnChangeType(int tank)
{
	vRemoveSmite(tank);
}

static void vRemoveSmite(int tank)
{
	g_bSmite[tank] = false;
	g_bSmite2[tank] = false;
	g_bSmite3[tank] = false;
	g_iSmiteCount[tank] = 0;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			vRemoveSmite(iPlayer);
		}
	}
}

static void vSmite(int survivor)
{
	float flPosition[3], flStartPosition[3];
	int iColor[4] = {255, 255, 255, 255};

	GetClientAbsOrigin(survivor, flPosition);
	flPosition[2] -= 26;
	flStartPosition[0] = flPosition[0] + GetRandomInt(-500, 500), flStartPosition[1] = flPosition[1] + GetRandomInt(-500, 500), flStartPosition[2] = flPosition[2] + 800;

	TE_SetupBeamPoints(flStartPosition, flPosition, g_iSmiteSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, iColor, 3);
	TE_SendToAll();

	TE_SetupSparks(flPosition, view_as<float>({0.0, 0.0, 0.0}), 5000, 1000);
	TE_SendToAll();

	TE_SetupEnergySplash(flPosition, view_as<float>({0.0, 0.0, 0.0}), false);
	TE_SendToAll();

	EmitAmbientSound(SOUND_EXPLOSION, flStartPosition, survivor, SNDLEVEL_RAIDSIREN);
}

static void vSmiteAbility(int tank)
{
	if (g_iSmiteCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
	{
		g_bSmite2[tank] = false;
		g_bSmite3[tank] = false;

		float flSmiteRange = !g_bTankConfig[ST_GetTankType(tank)] ? g_flSmiteRange[ST_GetTankType(tank)] : g_flSmiteRange2[ST_GetTankType(tank)],
			flSmiteRangeChance = !g_bTankConfig[ST_GetTankType(tank)] ? g_flSmiteRangeChance[ST_GetTankType(tank)] : g_flSmiteRangeChance2[ST_GetTankType(tank)],
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
				if (flDistance <= flSmiteRange)
				{
					vSmiteHit(iSurvivor, tank, flSmiteRangeChance, iSmiteAbility(tank), "2", "3");

					iSurvivorCount++;
				}
			}
		}

		if (iSurvivorCount == 0)
		{
			if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
			{
				ST_PrintToChat(tank, "%s %t", ST_TAG3, "SmiteHuman4");
			}
		}
	}
	else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1)
	{
		ST_PrintToChat(tank, "%s %t", ST_TAG3, "SmiteAmmo");
	}
}

static void vSmiteHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && bIsSurvivor(survivor))
	{
		if (g_iSmiteCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
		{
			if (GetRandomFloat(0.1, 100.0) <= chance)
			{
				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && StrEqual(mode, "3") && !g_bSmite[tank])
				{
					g_bSmite[tank] = true;
					g_iSmiteCount[tank]++;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "SmiteHuman", g_iSmiteCount[tank], iHumanAmmo(tank));

					if (g_iSmiteCount[tank] < iHumanAmmo(tank) && iHumanAmmo(tank) > 0)
					{
						CreateTimer(flHumanCooldown(tank), tTimerResetCooldown, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
					}
					else
					{
						g_bSmite[tank] = false;
					}
				}

				vSmite(survivor);
				ForcePlayerSuicide(survivor);

				char sSmiteEffect[4];
				sSmiteEffect = !g_bTankConfig[ST_GetTankType(tank)] ? g_sSmiteEffect[ST_GetTankType(tank)] : g_sSmiteEffect2[ST_GetTankType(tank)];
				vEffect(survivor, tank, sSmiteEffect, mode);

				char sSmiteMessage[3];
				sSmiteMessage = !g_bTankConfig[ST_GetTankType(tank)] ? g_sSmiteMessage[ST_GetTankType(tank)] : g_sSmiteMessage2[ST_GetTankType(tank)];
				if (StrContains(sSmiteMessage, message) != -1)
				{
					char sTankName[33];
					ST_GetTankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Smite", sTankName, survivor);
				}
			}
			else if (StrEqual(mode, "3") && !g_bSmite[tank])
			{
				if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bSmite2[tank])
				{
					g_bSmite2[tank] = true;

					ST_PrintToChat(tank, "%s %t", ST_TAG3, "SmiteHuman2");
				}
			}
		}
		else if (ST_IsTankSupported(tank, "5") && iHumanAbility(tank) == 1 && !g_bSmite3[tank])
		{
			g_bSmite3[tank] = true;

			ST_PrintToChat(tank, "%s %t", ST_TAG3, "SmiteAmmo");
		}
	}
}

static float flHumanCooldown(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flHumanCooldown[ST_GetTankType(tank)] : g_flHumanCooldown2[ST_GetTankType(tank)];
}

static float flSmiteChance(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_flSmiteChance[ST_GetTankType(tank)] : g_flSmiteChance2[ST_GetTankType(tank)];
}

static int iHumanAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAbility[ST_GetTankType(tank)] : g_iHumanAbility2[ST_GetTankType(tank)];
}

static int iHumanAmmo(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iHumanAmmo[ST_GetTankType(tank)] : g_iHumanAmmo2[ST_GetTankType(tank)];
}

static int iSmiteAbility(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iSmiteAbility[ST_GetTankType(tank)] : g_iSmiteAbility2[ST_GetTankType(tank)];
}

static int iSmiteHit(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iSmiteHit[ST_GetTankType(tank)] : g_iSmiteHit2[ST_GetTankType(tank)];
}

static int iSmiteHitMode(int tank)
{
	return !g_bTankConfig[ST_GetTankType(tank)] ? g_iSmiteHitMode[ST_GetTankType(tank)] : g_iSmiteHitMode2[ST_GetTankType(tank)];
}

public Action tTimerResetCooldown(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_IsTankSupported(iTank, "02345") || !ST_IsCloneSupported(iTank, g_bCloneInstalled) || !g_bSmite[iTank])
	{
		g_bSmite[iTank] = false;

		return Plugin_Stop;
	}

	g_bSmite[iTank] = false;

	ST_PrintToChat(iTank, "%s %t", ST_TAG3, "SmiteHuman5");

	return Plugin_Continue;
}