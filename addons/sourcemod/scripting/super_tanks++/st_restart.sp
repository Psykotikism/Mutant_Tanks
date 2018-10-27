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

// Super Tanks++: Restart Ability
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Restart Ability",
	author = ST_AUTHOR,
	description = "The Super Tank forces survivors to restart at the beginning of the map or near a teammate with a new loadout.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bRestartValid, g_bTankConfig[ST_MAXTYPES + 1];

char g_sRestartEffect[ST_MAXTYPES + 1][4], g_sRestartEffect2[ST_MAXTYPES + 1][4], g_sRestartLoadout[ST_MAXTYPES + 1][325], g_sRestartLoadout2[ST_MAXTYPES + 1][325], g_sRestartMessage[ST_MAXTYPES + 1][3], g_sRestartMessage2[ST_MAXTYPES + 1][3];

float g_flRestartChance[ST_MAXTYPES + 1], g_flRestartChance2[ST_MAXTYPES + 1], g_flRestartPosition[3], g_flRestartRange[ST_MAXTYPES + 1], g_flRestartRange2[ST_MAXTYPES + 1], g_flRestartRangeChance[ST_MAXTYPES + 1], g_flRestartRangeChance2[ST_MAXTYPES + 1];

Handle g_hSDKRespawnPlayer;

int g_iRestartAbility[ST_MAXTYPES + 1], g_iRestartAbility2[ST_MAXTYPES + 1], g_iRestartHit[ST_MAXTYPES + 1], g_iRestartHit2[ST_MAXTYPES + 1], g_iRestartHitMode[ST_MAXTYPES + 1], g_iRestartHitMode2[ST_MAXTYPES + 1], g_iRestartMode[ST_MAXTYPES + 1], g_iRestartMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Restart Ability only supports Left 4 Dead 1 & 2.");

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

	GameData gdSuperTanks = new GameData("super_tanks++");

	if (gdSuperTanks == null)
	{
		SetFailState("Unable to load the \"super_tanks++\" gamedata file.");
		return;
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "RoundRespawn");
	g_hSDKRespawnPlayer = EndPrepSDKCall();

	if (g_hSDKRespawnPlayer == null)
	{
		PrintToServer("%s Your \"RoundRespawn\" signature is outdated.", ST_TAG);
	}

	delete gdSuperTanks;

	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				OnClientPutInServer(iPlayer);
			}
		}

		g_bLateLoad = false;
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iRestartHitMode(attacker) == 0 || iRestartHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRestartHit(victim, attacker, flRestartChance(attacker), iRestartHit(attacker), "1", "1");
			}
		}
		else if ((iRestartHitMode(victim) == 0 || iRestartHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vRestartHit(attacker, victim, flRestartChance(victim), iRestartHit(victim), "1", "2");
			}
		}
	}
}

public void ST_Configs(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sTankName[33];
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iRestartAbility[iIndex] = kvSuperTanks.GetNum("Restart Ability/Ability Enabled", 0);
				g_iRestartAbility[iIndex] = iClamp(g_iRestartAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Restart Ability/Ability Effect", g_sRestartEffect[iIndex], sizeof(g_sRestartEffect[]), "123");
				kvSuperTanks.GetString("Restart Ability/Ability Message", g_sRestartMessage[iIndex], sizeof(g_sRestartMessage[]), "0");
				g_flRestartChance[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Chance", 33.3);
				g_flRestartChance[iIndex] = flClamp(g_flRestartChance[iIndex], 0.1, 100.0);
				g_iRestartHit[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Hit", 0);
				g_iRestartHit[iIndex] = iClamp(g_iRestartHit[iIndex], 0, 1);
				g_iRestartHitMode[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Hit Mode", 0);
				g_iRestartHitMode[iIndex] = iClamp(g_iRestartHitMode[iIndex], 0, 2);
				kvSuperTanks.GetString("Restart Ability/Restart Loadout", g_sRestartLoadout[iIndex], sizeof(g_sRestartLoadout[]), "smg,pistol,pain_pills");
				g_iRestartMode[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Mode", 1);
				g_iRestartMode[iIndex] = iClamp(g_iRestartMode[iIndex], 0, 1);
				g_flRestartRange[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Range", 150.0);
				g_flRestartRange[iIndex] = flClamp(g_flRestartRange[iIndex], 1.0, 9999999999.0);
				g_flRestartRangeChance[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Range Chance", 15.0);
				g_flRestartRangeChance[iIndex] = flClamp(g_flRestartRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iRestartAbility2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Ability Enabled", g_iRestartAbility[iIndex]);
				g_iRestartAbility2[iIndex] = iClamp(g_iRestartAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Restart Ability/Ability Effect", g_sRestartEffect2[iIndex], sizeof(g_sRestartEffect2[]), g_sRestartEffect[iIndex]);
				kvSuperTanks.GetString("Restart Ability/Ability Message", g_sRestartMessage2[iIndex], sizeof(g_sRestartMessage2[]), g_sRestartMessage[iIndex]);
				g_flRestartChance2[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Chance", g_flRestartChance[iIndex]);
				g_flRestartChance2[iIndex] = flClamp(g_flRestartChance2[iIndex], 0.1, 100.0);
				g_iRestartHit2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Hit", g_iRestartHit[iIndex]);
				g_iRestartHit2[iIndex] = iClamp(g_iRestartHit2[iIndex], 0, 1);
				g_iRestartHitMode2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Hit Mode", g_iRestartHitMode[iIndex]);
				g_iRestartHitMode2[iIndex] = iClamp(g_iRestartHitMode2[iIndex], 0, 2);
				kvSuperTanks.GetString("Restart Ability/Restart Loadout", g_sRestartLoadout2[iIndex], sizeof(g_sRestartLoadout2[]), g_sRestartLoadout[iIndex]);
				g_iRestartMode2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Mode", g_iRestartMode[iIndex]);
				g_iRestartMode2[iIndex] = iClamp(g_iRestartMode2[iIndex], 0, 1);
				g_flRestartRange2[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Range", g_flRestartRange[iIndex]);
				g_flRestartRange2[iIndex] = flClamp(g_flRestartRange2[iIndex], 1.0, 9999999999.0);
				g_flRestartRangeChance2[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Range Chance", g_flRestartRangeChance[iIndex]);
				g_flRestartRangeChance2[iIndex] = flClamp(g_flRestartRangeChance2[iIndex], 0.1, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "round_start"))
	{
		CreateTimer(10.0, tTimerRestartCoordinates, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		int iRestartAbility = !g_bTankConfig[ST_TankType(tank)] ? g_iRestartAbility[ST_TankType(tank)] : g_iRestartAbility2[ST_TankType(tank)];

		float flRestartRange = !g_bTankConfig[ST_TankType(tank)] ? g_flRestartRange[ST_TankType(tank)] : g_flRestartRange2[ST_TankType(tank)],
			flRestartRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flRestartRangeChance[ST_TankType(tank)] : g_flRestartRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flRestartRange)
				{
					vRestartHit(iSurvivor, tank, flRestartRangeChance, iRestartAbility, "2", "3");
				}
			}
		}
	}
}

static void vRemoveWeapon(int survivor, int slot)
{
	int iSlot = GetPlayerWeaponSlot(survivor, slot);
	if (iSlot > 0)
	{
		RemovePlayerItem(survivor, iSlot);
		RemoveEntity(iSlot);
	}
}

static void vRestartHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor))
	{
		SDKCall(g_hSDKRespawnPlayer, survivor);

		char sRestartLoadout[325], sItems[5][64];
		int iRestartMode = !g_bTankConfig[ST_TankType(tank)] ? g_iRestartMode[ST_TankType(tank)] : g_iRestartMode2[ST_TankType(tank)];

		sRestartLoadout = !g_bTankConfig[ST_TankType(tank)] ? g_sRestartLoadout[ST_TankType(tank)] : g_sRestartLoadout2[ST_TankType(tank)];

		ExplodeString(sRestartLoadout, ",", sItems, sizeof(sItems), sizeof(sItems[]));
		vRemoveWeapon(survivor, 0);
		vRemoveWeapon(survivor, 1);
		vRemoveWeapon(survivor, 2);
		vRemoveWeapon(survivor, 3);
		vRemoveWeapon(survivor, 4);

		for (int iItem = 0; iItem < sizeof(sItems); iItem++)
		{
			if (StrContains(sRestartLoadout, sItems[iItem]) != -1 && sItems[iItem][0] != '\0')
			{
				vCheatCommand(survivor, "give", sItems[iItem]);
			}
		}

		if (g_bRestartValid && iRestartMode == 0)
		{
			TeleportEntity(survivor, g_flRestartPosition, NULL_VECTOR, NULL_VECTOR);
		}
		else
		{
			float flCurrentOrigin[3];
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (!bIsSurvivor(iPlayer) || bIsPlayerIncapacitated(iPlayer) || iPlayer == survivor)
				{
					continue;
				}

				GetClientAbsOrigin(iPlayer, flCurrentOrigin);
				TeleportEntity(survivor, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);
				break;
			}
		}

		char sRestartEffect[4];
		sRestartEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sRestartEffect[ST_TankType(tank)] : g_sRestartEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sRestartEffect, mode);

		char sRestartMessage[3];
		sRestartMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sRestartMessage[ST_TankType(tank)] : g_sRestartMessage2[ST_TankType(tank)];
		if (StrContains(sRestartMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Restart", sTankName, survivor);
		}
	}
}

static float flRestartChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flRestartChance[ST_TankType(tank)] : g_flRestartChance2[ST_TankType(tank)];
}

static int iRestartHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRestartHit[ST_TankType(tank)] : g_iRestartHit2[ST_TankType(tank)];
}

static int iRestartHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRestartHitMode[ST_TankType(tank)] : g_iRestartHitMode2[ST_TankType(tank)];
}

public Action tTimerRestartCoordinates(Handle timer)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor))
		{
			g_bRestartValid = true;
			GetClientAbsOrigin(iSurvivor, g_flRestartPosition);
			break;
		}
	}

	if (g_flRestartPosition[0] == 0.0 && g_flRestartPosition[1] == 0.0 && g_flRestartPosition[2] == 0.0)
	{
		g_bRestartValid = false;
	}
}