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

// Super Tanks++: Panic Ability
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
	name = "[ST++] Panic Ability",
	author = ST_AUTHOR,
	description = "The Super Tank starts panic events.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bPanic[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sPanicEffect[ST_MAXTYPES + 1][4], g_sPanicEffect2[ST_MAXTYPES + 1][4], g_sPanicMessage[ST_MAXTYPES + 1][4], g_sPanicMessage2[ST_MAXTYPES + 1][4];

float g_flPanicChance[ST_MAXTYPES + 1], g_flPanicChance2[ST_MAXTYPES + 1], g_flPanicInterval[ST_MAXTYPES + 1], g_flPanicInterval2[ST_MAXTYPES + 1], g_flPanicRange[ST_MAXTYPES + 1], g_flPanicRange2[ST_MAXTYPES + 1], g_flPanicRangeChance[ST_MAXTYPES + 1], g_flPanicRangeChance2[ST_MAXTYPES + 1];

int g_iPanicAbility[ST_MAXTYPES + 1], g_iPanicAbility2[ST_MAXTYPES + 1], g_iPanicHit[ST_MAXTYPES + 1], g_iPanicHit2[ST_MAXTYPES + 1], g_iPanicHitMode[ST_MAXTYPES + 1], g_iPanicHitMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Panic Ability\" only supports Left 4 Dead 1 & 2.");

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

	g_bPanic[client] = false;
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

		if ((iPanicHitMode(attacker) == 0 || iPanicHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vPanicHit(victim, attacker, flPanicChance(attacker), iPanicHit(attacker), "1", "1");
			}
		}
		else if ((iPanicHitMode(victim) == 0 || iPanicHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vPanicHit(attacker, victim, flPanicChance(victim), iPanicHit(victim), "1", "2");
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

				g_iPanicAbility[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Enabled", 0);
				g_iPanicAbility[iIndex] = iClamp(g_iPanicAbility[iIndex], 0, 3);
				kvSuperTanks.GetString("Panic Ability/Ability Effect", g_sPanicEffect[iIndex], sizeof(g_sPanicEffect[]), "0");
				kvSuperTanks.GetString("Panic Ability/Ability Message", g_sPanicMessage[iIndex], sizeof(g_sPanicMessage[]), "0");
				g_flPanicChance[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Chance", 33.3);
				g_flPanicChance[iIndex] = flClamp(g_flPanicChance[iIndex], 0.0, 100.0);
				g_iPanicHit[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Hit", 0);
				g_iPanicHit[iIndex] = iClamp(g_iPanicHit[iIndex], 0, 1);
				g_iPanicHitMode[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Hit Mode", 0);
				g_iPanicHitMode[iIndex] = iClamp(g_iPanicHitMode[iIndex], 0, 2);
				g_flPanicInterval[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Interval", 5.0);
				g_flPanicInterval[iIndex] = flClamp(g_flPanicInterval[iIndex], 0.1, 9999999999.0);
				g_flPanicRange[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Range", 150.0);
				g_flPanicRange[iIndex] = flClamp(g_flPanicRange[iIndex], 1.0, 9999999999.0);
				g_flPanicRangeChance[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Range Chance", 15.0);
				g_flPanicRangeChance[iIndex] = flClamp(g_flPanicRangeChance[iIndex], 0.0, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iPanicAbility2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Enabled", g_iPanicAbility[iIndex]);
				g_iPanicAbility2[iIndex] = iClamp(g_iPanicAbility2[iIndex], 0, 3);
				kvSuperTanks.GetString("Panic Ability/Ability Effect", g_sPanicEffect2[iIndex], sizeof(g_sPanicEffect2[]), g_sPanicEffect[iIndex]);
				kvSuperTanks.GetString("Panic Ability/Ability Message", g_sPanicMessage2[iIndex], sizeof(g_sPanicMessage2[]), g_sPanicMessage[iIndex]);
				g_flPanicChance2[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Chance", g_flPanicChance[iIndex]);
				g_flPanicChance2[iIndex] = flClamp(g_flPanicChance2[iIndex], 0.0, 100.0);
				g_iPanicHit2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Hit", g_iPanicHit[iIndex]);
				g_iPanicHit2[iIndex] = iClamp(g_iPanicHit2[iIndex], 0, 1);
				g_iPanicHitMode2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Hit Mode", g_iPanicHitMode[iIndex]);
				g_iPanicHitMode2[iIndex] = iClamp(g_iPanicHitMode2[iIndex], 0, 2);
				g_flPanicInterval2[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Interval", g_flPanicInterval[iIndex]);
				g_flPanicInterval2[iIndex] = flClamp(g_flPanicInterval2[iIndex], 0.1, 9999999999.0);
				g_flPanicRange2[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Range", g_flPanicRange[iIndex]);
				g_flPanicRange2[iIndex] = flClamp(g_flPanicRange2[iIndex], 1.0, 9999999999.0);
				g_flPanicRangeChance2[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Range Chance", g_flPanicRangeChance[iIndex]);
				g_flPanicRangeChance2[iIndex] = flClamp(g_flPanicRangeChance2[iIndex], 0.0, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iPanicAbility(iTank) == 1 && GetRandomFloat(0.1, 100.0) <= flPanicChance(iTank) && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vCheatCommand(iTank, "director_force_panic_event");
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flPanicRange = !g_bTankConfig[ST_TankType(tank)] ? g_flPanicRange[ST_TankType(tank)] : g_flPanicRange2[ST_TankType(tank)],
			flPanicRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flPanicRangeChance[ST_TankType(tank)] : g_flPanicRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flPanicRange)
				{
					vPanicHit(iSurvivor, tank, flPanicRangeChance, iPanicAbility(tank), "2", "3");
				}
			}
		}

		if ((iPanicAbility(tank) == 2 || iPanicAbility(tank) == 3) && !g_bPanic[tank])
		{
			g_bPanic[tank] = true;

			float flPanicInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flPanicInterval[ST_TankType(tank)] : g_flPanicInterval2[ST_TankType(tank)];
			CreateTimer(flPanicInterval, tTimerPanic, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}

public void ST_BossStage(int tank)
{
	g_bPanic[tank] = false;
}

static void vPanicHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if ((enabled == 1 || enabled == 3) && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor))
	{
		vCheatCommand(survivor, "director_force_panic_event");

		char sPanicEffect[4];
		sPanicEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sPanicEffect[ST_TankType(tank)] : g_sPanicEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sPanicEffect, mode);

		char sPanicMessage[4];
		sPanicMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sPanicMessage[ST_TankType(tank)] : g_sPanicMessage[ST_TankType(tank)];
		if (StrContains(sPanicMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Panic", sTankName);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bPanic[iPlayer] = false;
		}
	}
}

static float flPanicChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flPanicChance[ST_TankType(tank)] : g_flPanicChance2[ST_TankType(tank)];
}

static int iPanicAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPanicAbility[ST_TankType(tank)] : g_iPanicAbility2[ST_TankType(tank)];
}

static int iPanicHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPanicHit[ST_TankType(tank)] : g_iPanicHit2[ST_TankType(tank)];
}

static int iPanicHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPanicHitMode[ST_TankType(tank)] : g_iPanicHitMode2[ST_TankType(tank)];
}

public Action tTimerPanic(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || (iPanicAbility(iTank) != 2 && iPanicAbility(iTank) != 3) || !g_bPanic[iTank])
	{
		g_bPanic[iTank] = false;

		return Plugin_Stop;
	}

	vCheatCommand(iTank, "director_force_panic_event");

	char sPanicMessage[4];
	sPanicMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sPanicMessage[ST_TankType(iTank)] : g_sPanicMessage[ST_TankType(iTank)];
	if (StrContains(sPanicMessage, "3") != -1)
	{
		char sTankName[33];
		ST_TankName(iTank, sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Panic", sTankName);
	}

	return Plugin_Continue;
}