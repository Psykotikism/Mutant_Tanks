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

// Super Tanks++: Pimp Ability
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
	name = "[ST++] Pimp Ability",
	author = ST_AUTHOR,
	description = "The Super Tank pimp slaps survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bPimp[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sPimpEffect[ST_MAXTYPES + 1][4], g_sPimpEffect2[ST_MAXTYPES + 1][4], g_sPimpMessage[ST_MAXTYPES + 1][3], g_sPimpMessage2[ST_MAXTYPES + 1][3];

float g_flPimpChance[ST_MAXTYPES + 1], g_flPimpChance2[ST_MAXTYPES + 1], g_flPimpInterval[ST_MAXTYPES + 1], g_flPimpInterval2[ST_MAXTYPES + 1], g_flPimpRange[ST_MAXTYPES + 1], g_flPimpRange2[ST_MAXTYPES + 1], g_flPimpRangeChance[ST_MAXTYPES + 1], g_flPimpRangeChance2[ST_MAXTYPES + 1];

int g_iPimpAbility[ST_MAXTYPES + 1], g_iPimpAbility2[ST_MAXTYPES + 1], g_iPimpAmount[ST_MAXTYPES + 1], g_iPimpAmount2[ST_MAXTYPES + 1], g_iPimpCount[MAXPLAYERS + 1], g_iPimpDamage[ST_MAXTYPES + 1], g_iPimpDamage2[ST_MAXTYPES + 1], g_iPimpHit[ST_MAXTYPES + 1], g_iPimpHit2[ST_MAXTYPES + 1], g_iPimpHitMode[ST_MAXTYPES + 1], g_iPimpHitMode2[ST_MAXTYPES + 1], g_iPimpOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Pimp Ability\" only supports Left 4 Dead 1 & 2.");

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

	g_bPimp[client] = false;
	g_iPimpCount[client] = 0;
	g_iPimpOwner[client] = 0;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iPimpHitMode(attacker) == 0 || iPimpHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vPimpHit(victim, attacker, flPimpChance(attacker), iPimpHit(attacker), "1", "1");
			}
		}
		else if ((iPimpHitMode(victim) == 0 || iPimpHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vPimpHit(attacker, victim, flPimpChance(victim), iPimpHit(victim), "1", "2");
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

				g_iPimpAbility[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Ability Enabled", 0);
				g_iPimpAbility[iIndex] = iClamp(g_iPimpAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Pimp Ability/Ability Effect", g_sPimpEffect[iIndex], sizeof(g_sPimpEffect[]), "0");
				kvSuperTanks.GetString("Pimp Ability/Ability Message", g_sPimpMessage[iIndex], sizeof(g_sPimpMessage[]), "0");
				g_iPimpAmount[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Amount", 5);
				g_iPimpAmount[iIndex] = iClamp(g_iPimpAmount[iIndex], 1, 9999999999);
				g_flPimpChance[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Chance", 33.3);
				g_flPimpChance[iIndex] = flClamp(g_flPimpChance[iIndex], 0.0, 100.0);
				g_iPimpDamage[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Damage", 1);
				g_iPimpDamage[iIndex] = iClamp(g_iPimpDamage[iIndex], 1, 9999999999);
				g_iPimpHit[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Hit", 0);
				g_iPimpHit[iIndex] = iClamp(g_iPimpHit[iIndex], 0, 1);
				g_iPimpHitMode[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Hit Mode", 0);
				g_iPimpHitMode[iIndex] = iClamp(g_iPimpHitMode[iIndex], 0, 2);
				g_flPimpInterval[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Interval", 1.0);
				g_flPimpInterval[iIndex] = flClamp(g_flPimpInterval[iIndex], 0.1, 9999999999.0);
				g_flPimpRange[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Range", 150.0);
				g_flPimpRange[iIndex] = flClamp(g_flPimpRange[iIndex], 1.0, 9999999999.0);
				g_flPimpRangeChance[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Range Chance", 15.0);
				g_flPimpRangeChance[iIndex] = flClamp(g_flPimpRangeChance[iIndex], 0.0, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iPimpAbility2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Ability Enabled", g_iPimpAbility[iIndex]);
				g_iPimpAbility2[iIndex] = iClamp(g_iPimpAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Pimp Ability/Ability Effect", g_sPimpEffect2[iIndex], sizeof(g_sPimpEffect2[]), g_sPimpEffect[iIndex]);
				kvSuperTanks.GetString("Pimp Ability/Ability Message", g_sPimpMessage2[iIndex], sizeof(g_sPimpMessage2[]), g_sPimpMessage[iIndex]);
				g_iPimpAmount2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Amount", g_iPimpAmount[iIndex]);
				g_iPimpAmount2[iIndex] = iClamp(g_iPimpAmount2[iIndex], 1, 9999999999);
				g_flPimpChance2[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Chance", g_flPimpChance[iIndex]);
				g_flPimpChance2[iIndex] = flClamp(g_flPimpChance2[iIndex], 0.0, 100.0);
				g_iPimpDamage2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Damage", g_iPimpDamage[iIndex]);
				g_iPimpDamage2[iIndex] = iClamp(g_iPimpDamage2[iIndex], 1, 9999999999);
				g_iPimpHit2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Hit", g_iPimpHit[iIndex]);
				g_iPimpHit2[iIndex] = iClamp(g_iPimpHit2[iIndex], 0, 1);
				g_iPimpHitMode2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Hit Mode", g_iPimpHitMode[iIndex]);
				g_iPimpHitMode2[iIndex] = iClamp(g_iPimpHitMode2[iIndex], 0, 2);
				g_flPimpInterval2[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Interval", g_flPimpInterval[iIndex]);
				g_flPimpInterval2[iIndex] = flClamp(g_flPimpInterval2[iIndex], 0.1, 9999999999.0);
				g_flPimpRange2[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Range", g_flPimpRange[iIndex]);
				g_flPimpRange2[iIndex] = flClamp(g_flPimpRange2[iIndex], 1.0, 9999999999.0);
				g_flPimpRangeChance2[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Range Chance", g_flPimpRangeChance[iIndex]);
				g_flPimpRangeChance2[iIndex] = flClamp(g_flPimpRangeChance2[iIndex], 0.0, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		int iPimpAbility = !g_bTankConfig[ST_TankType(tank)] ? g_iPimpAbility[ST_TankType(tank)] : g_iPimpAbility2[ST_TankType(tank)];

		float flPimpRange = !g_bTankConfig[ST_TankType(tank)] ? g_flPimpRange[ST_TankType(tank)] : g_flPimpRange2[ST_TankType(tank)],
			flPimpRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flPimpRangeChance[ST_TankType(tank)] : g_flPimpRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flPimpRange)
				{
					vPimpHit(iSurvivor, tank, flPimpRangeChance, iPimpAbility, "2", "3");
				}
			}
		}
	}
}

public void ST_BossStage(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor) && g_bPimp[iSurvivor] && g_iPimpOwner[iSurvivor] == tank)
			{
				g_bPimp[iSurvivor] = false;
				g_iPimpCount[iSurvivor] = 0;
				g_iPimpOwner[iSurvivor] = 0;
			}
		}
	}
}

static void vPimpHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bPimp[survivor])
	{
		g_bPimp[survivor] = true;
		g_iPimpOwner[survivor] = tank;

		float flPimpInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flPimpInterval[ST_TankType(tank)] : g_flPimpInterval2[ST_TankType(tank)];
		DataPack dpPimp;
		CreateDataTimer(flPimpInterval, tTimerPimp, dpPimp, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpPimp.WriteCell(GetClientUserId(survivor));
		dpPimp.WriteCell(GetClientUserId(tank));
		dpPimp.WriteString(message);
		dpPimp.WriteCell(enabled);

		char sPimpEffect[4];
		sPimpEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sPimpEffect[ST_TankType(tank)] : g_sPimpEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sPimpEffect, mode);

		char sPimpMessage[3];
		sPimpMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sPimpMessage[ST_TankType(tank)] : g_sPimpMessage2[ST_TankType(tank)];
		if (StrContains(sPimpMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Pimp", sTankName, survivor);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bPimp[iPlayer] = false;
			g_iPimpCount[iPlayer] = 0;
			g_iPimpOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bPimp[survivor] = false;
	g_iPimpCount[survivor] = 0;
	g_iPimpOwner[survivor] = 0;

	char sPimpMessage[3];
	sPimpMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sPimpMessage[ST_TankType(tank)] : g_sPimpMessage2[ST_TankType(tank)];
	if (StrContains(sPimpMessage, message) != -1)
	{
		PrintToChatAll("%s %t", ST_TAG2, "Pimp2", survivor);
	}
}

static float flPimpChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flPimpChance[ST_TankType(tank)] : g_flPimpChance2[ST_TankType(tank)];
}

static int iPimpHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPimpHit[ST_TankType(tank)] : g_iPimpHit2[ST_TankType(tank)];
}

static int iPimpHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPimpHitMode[ST_TankType(tank)] : g_iPimpHitMode2[ST_TankType(tank)];
}

public Action tTimerPimp(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bPimp[iSurvivor] = false;
		g_iPimpCount[iSurvivor] = 0;
		g_iPimpOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bPimp[iSurvivor])
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iPimpAbility = pack.ReadCell(),
		iPimpAmount = !g_bTankConfig[ST_TankType(iTank)] ? g_iPimpAmount[ST_TankType(iTank)] : g_iPimpAmount2[ST_TankType(iTank)];

	if (iPimpAbility == 0 || g_iPimpCount[iSurvivor] >= iPimpAmount)
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iPimpDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_iPimpDamage[ST_TankType(iTank)] : g_iPimpDamage2[ST_TankType(iTank)];
	SlapPlayer(iSurvivor, iPimpDamage, true);

	g_iPimpCount[iSurvivor]++;

	return Plugin_Continue;
}