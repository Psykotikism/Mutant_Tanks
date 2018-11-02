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

// Super Tanks++: Enforce Ability
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
	name = "[ST++] Enforce Ability",
	author = ST_AUTHOR,
	description = "The Super Tank forces survivors to only use a certain weapon slot.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bEnforce[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sEnforceEffect[ST_MAXTYPES + 1][4], g_sEnforceEffect2[ST_MAXTYPES + 1][4], g_sEnforceMessage[ST_MAXTYPES + 1][3], g_sEnforceMessage2[ST_MAXTYPES + 1][3], g_sEnforceSlot[ST_MAXTYPES + 1][6], g_sEnforceSlot2[ST_MAXTYPES + 1][6];

float g_flEnforceChance[ST_MAXTYPES + 1], g_flEnforceChance2[ST_MAXTYPES + 1], g_flEnforceDuration[ST_MAXTYPES + 1], g_flEnforceDuration2[ST_MAXTYPES + 1], g_flEnforceRange[ST_MAXTYPES + 1], g_flEnforceRange2[ST_MAXTYPES + 1], g_flEnforceRangeChance[ST_MAXTYPES + 1], g_flEnforceRangeChance2[ST_MAXTYPES + 1];

int g_iEnforceAbility[ST_MAXTYPES + 1], g_iEnforceAbility2[ST_MAXTYPES + 1], g_iEnforceHit[ST_MAXTYPES + 1], g_iEnforceHit2[ST_MAXTYPES + 1], g_iEnforceHitMode[ST_MAXTYPES + 1], g_iEnforceHitMode2[ST_MAXTYPES + 1], g_iEnforceSlot[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Enforce Ability\" only supports Left 4 Dead 1 & 2.");

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

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	g_bEnforce[client] = false;
	g_iEnforceSlot[client] = -1;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!ST_PluginEnabled())
	{
		return Plugin_Continue;
	}

	if (bIsSurvivor(client) && g_bEnforce[client])
	{
		weapon = GetPlayerWeaponSlot(client, g_iEnforceSlot[client]);
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iEnforceHitMode(attacker) == 0 || iEnforceHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vEnforceHit(victim, attacker, flEnforceChance(attacker), iEnforceHit(attacker), "1", "1");
			}
		}
		else if ((iEnforceHitMode(victim) == 0 || iEnforceHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vEnforceHit(attacker, victim, flEnforceChance(victim), iEnforceHit(victim), "1", "2");
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

				g_iEnforceAbility[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Ability Enabled", 0);
				g_iEnforceAbility[iIndex] = iClamp(g_iEnforceAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Enforce Ability/Ability Effect", g_sEnforceEffect[iIndex], sizeof(g_sEnforceEffect[]), "0");
				kvSuperTanks.GetString("Enforce Ability/Ability Message", g_sEnforceMessage[iIndex], sizeof(g_sEnforceMessage[]), "0");
				g_flEnforceChance[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Chance", 33.3);
				g_flEnforceChance[iIndex] = flClamp(g_flEnforceChance[iIndex], 0.1, 100.0);
				g_flEnforceDuration[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Duration", 5.0);
				g_flEnforceDuration[iIndex] = flClamp(g_flEnforceDuration[iIndex], 0.1, 9999999999.0);
				g_iEnforceHit[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Hit", 0);
				g_iEnforceHit[iIndex] = iClamp(g_iEnforceHit[iIndex], 0, 1);
				g_iEnforceHitMode[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Hit Mode", 0);
				g_iEnforceHitMode[iIndex] = iClamp(g_iEnforceHitMode[iIndex], 0, 2);
				g_flEnforceRange[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Range", 150.0);
				g_flEnforceRange[iIndex] = flClamp(g_flEnforceRange[iIndex], 1.0, 9999999999.0);
				g_flEnforceRangeChance[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Range Chance", 15.0);
				g_flEnforceRangeChance[iIndex] = flClamp(g_flEnforceRangeChance[iIndex], 0.1, 100.0);
				kvSuperTanks.GetString("Enforce Ability/Enforce Weapon Slots", g_sEnforceSlot[iIndex], sizeof(g_sEnforceSlot[]), "12345");
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iEnforceAbility2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Ability Enabled", g_iEnforceAbility[iIndex]);
				g_iEnforceAbility2[iIndex] = iClamp(g_iEnforceAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Enforce Ability/Ability Effect", g_sEnforceEffect2[iIndex], sizeof(g_sEnforceEffect2[]), g_sEnforceEffect[iIndex]);
				kvSuperTanks.GetString("Enforce Ability/Ability Message", g_sEnforceMessage2[iIndex], sizeof(g_sEnforceMessage2[]), g_sEnforceMessage[iIndex]);
				g_flEnforceChance2[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Chance", g_flEnforceChance[iIndex]);
				g_flEnforceChance2[iIndex] = flClamp(g_flEnforceChance2[iIndex], 0.1, 100.0);
				g_flEnforceDuration2[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Duration", g_flEnforceDuration[iIndex]);
				g_flEnforceDuration2[iIndex] = flClamp(g_flEnforceDuration2[iIndex], 0.1, 9999999999.0);
				g_iEnforceHit2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Hit", g_iEnforceHit[iIndex]);
				g_iEnforceHit2[iIndex] = iClamp(g_iEnforceHit2[iIndex], 0, 1);
				g_iEnforceHitMode2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Hit Mode", g_iEnforceHitMode[iIndex]);
				g_iEnforceHitMode2[iIndex] = iClamp(g_iEnforceHitMode2[iIndex], 0, 2);
				g_flEnforceRange2[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Range", g_flEnforceRange[iIndex]);
				g_flEnforceRange2[iIndex] = flClamp(g_flEnforceRange2[iIndex], 1.0, 9999999999.0);
				g_flEnforceRangeChance2[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Range Chance", g_flEnforceRangeChance[iIndex]);
				g_flEnforceRangeChance2[iIndex] = flClamp(g_flEnforceRangeChance2[iIndex], 0.1, 100.0);
				kvSuperTanks.GetString("Enforce Ability/Enforce Weapon Slots", g_sEnforceSlot2[iIndex], sizeof(g_sEnforceSlot2[]), g_sEnforceSlot[iIndex]);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vRemoveEnforce();
	vReset();
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveEnforce();
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flEnforceRange = !g_bTankConfig[ST_TankType(tank)] ? g_flEnforceRange[ST_TankType(tank)] : g_flEnforceRange2[ST_TankType(tank)],
			flEnforceRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flEnforceRangeChance[ST_TankType(tank)] : g_flEnforceRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flEnforceRange)
				{
					vEnforceHit(iSurvivor, tank, flEnforceRangeChance, iEnforceAbility(tank), "2", "3");
				}
			}
		}
	}
}

public void ST_BossStage(int tank)
{
	if (iEnforceAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveEnforce();
	}
}

static void vEnforceHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bEnforce[survivor])
	{
		g_bEnforce[survivor] = true;

		char sNumbers = !g_bTankConfig[ST_TankType(tank)] ? g_sEnforceSlot[ST_TankType(tank)][GetRandomInt(0, strlen(g_sEnforceSlot[ST_TankType(tank)]) - 1)] : g_sEnforceSlot2[ST_TankType(tank)][GetRandomInt(0, strlen(g_sEnforceSlot2[ST_TankType(tank)]) - 1)],
			sSlotNumber[32];
		switch (sNumbers)
		{
			case '1': sSlotNumber = "1st", g_iEnforceSlot[survivor] = 0;
			case '2': sSlotNumber = "2nd", g_iEnforceSlot[survivor] = 1;
			case '3': sSlotNumber = "3rd", g_iEnforceSlot[survivor] = 2;
			case '4': sSlotNumber = "4th", g_iEnforceSlot[survivor] = 3;
			case '5': sSlotNumber = "5th", g_iEnforceSlot[survivor] = 4;
		}

		float flEnforceDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flEnforceDuration[ST_TankType(tank)] : g_flEnforceDuration2[ST_TankType(tank)];
		DataPack dpStopEnforce;
		CreateDataTimer(flEnforceDuration, tTimerStopEnforce, dpStopEnforce, TIMER_FLAG_NO_MAPCHANGE);
		dpStopEnforce.WriteCell(GetClientUserId(survivor));
		dpStopEnforce.WriteCell(GetClientUserId(tank));
		dpStopEnforce.WriteString(message);

		char sEnforceEffect[4];
		sEnforceEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sEnforceEffect[ST_TankType(tank)] : g_sEnforceEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sEnforceEffect, mode);

		char sEnforceMessage[3];
		sEnforceMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sEnforceMessage[ST_TankType(tank)] : g_sEnforceMessage2[ST_TankType(tank)];
		if (StrContains(sEnforceMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Enforce", sTankName, survivor, sSlotNumber);
		}
	}
}

static void vRemoveEnforce()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bEnforce[iSurvivor])
		{
			g_bEnforce[iSurvivor] = false;
			g_iEnforceSlot[iSurvivor] = -1;
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bEnforce[iPlayer] = false;
			g_iEnforceSlot[iPlayer] = -1;
		}
	}
}

static float flEnforceChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flEnforceChance[ST_TankType(tank)] : g_flEnforceChance2[ST_TankType(tank)];
}

static int iEnforceAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iEnforceAbility[ST_TankType(tank)] : g_iEnforceAbility2[ST_TankType(tank)];
}

static int iEnforceHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iEnforceHit[ST_TankType(tank)] : g_iEnforceHit2[ST_TankType(tank)];
}

static int iEnforceHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iEnforceHitMode[ST_TankType(tank)] : g_iEnforceHitMode2[ST_TankType(tank)];
}

public Action tTimerStopEnforce(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bEnforce[iSurvivor])
	{
		g_bEnforce[iSurvivor] = false;
		g_iEnforceSlot[iSurvivor] = -1;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bEnforce[iSurvivor] = false;
		g_iEnforceSlot[iSurvivor] = -1;

		return Plugin_Stop;
	}

	g_bEnforce[iSurvivor] = false;
	g_iEnforceSlot[iSurvivor] = -1;

	char sEnforceMessage[3], sMessage[3];
	sEnforceMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sEnforceMessage[ST_TankType(iTank)] : g_sEnforceMessage2[ST_TankType(iTank)];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (StrContains(sEnforceMessage, sMessage) != -1)
	{
		PrintToChatAll("%s %t", ST_TAG2, "Enforce2", iSurvivor);
	}

	return Plugin_Continue;
}