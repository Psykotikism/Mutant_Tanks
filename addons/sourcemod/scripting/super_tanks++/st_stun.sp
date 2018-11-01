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

// Super Tanks++: Stun Ability
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
	name = "[ST++] Stun Ability",
	author = ST_AUTHOR,
	description = "The Super Tank stuns and slows survivors down.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bStun[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sStunEffect[ST_MAXTYPES + 1][4], g_sStunEffect2[ST_MAXTYPES + 1][4], g_sStunMessage[ST_MAXTYPES + 1][3], g_sStunMessage2[ST_MAXTYPES + 1][3];

float g_flStunChance[ST_MAXTYPES + 1], g_flStunChance2[ST_MAXTYPES + 1], g_flStunDuration[ST_MAXTYPES + 1], g_flStunDuration2[ST_MAXTYPES + 1], g_flStunRange[ST_MAXTYPES + 1], g_flStunRange2[ST_MAXTYPES + 1], g_flStunRangeChance[ST_MAXTYPES + 1], g_flStunRangeChance2[ST_MAXTYPES + 1], g_flStunSpeed[ST_MAXTYPES + 1], g_flStunSpeed2[ST_MAXTYPES + 1];

int g_iStunAbility[ST_MAXTYPES + 1], g_iStunAbility2[ST_MAXTYPES + 1], g_iStunHit[ST_MAXTYPES + 1], g_iStunHit2[ST_MAXTYPES + 1], g_iStunHitMode[ST_MAXTYPES + 1], g_iStunHitMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Stun Ability\" only supports Left 4 Dead 1 & 2.");

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

	g_bStun[client] = false;
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

		if ((iStunHitMode(attacker) == 0 || iStunHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vStunHit(victim, attacker, flStunChance(attacker), iStunHit(attacker), "1", "1");
			}
		}
		else if ((iStunHitMode(victim) == 0 || iStunHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vStunHit(attacker, victim, flStunChance(victim), iStunHit(victim), "1", "2");
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

				g_iStunAbility[iIndex] = kvSuperTanks.GetNum("Stun Ability/Ability Enabled", 0);
				g_iStunAbility[iIndex] = iClamp(g_iStunAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Stun Ability/Ability Effect", g_sStunEffect[iIndex], sizeof(g_sStunEffect[]), "123");
				kvSuperTanks.GetString("Stun Ability/Ability Message", g_sStunMessage[iIndex], sizeof(g_sStunMessage[]), "0");
				g_flStunChance[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Chance", 33.3);
				g_flStunChance[iIndex] = flClamp(g_flStunChance[iIndex], 0.1, 100.0);
				g_flStunDuration[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Duration", 5.0);
				g_flStunDuration[iIndex] = flClamp(g_flStunDuration[iIndex], 0.1, 9999999999.0);
				g_iStunHit[iIndex] = kvSuperTanks.GetNum("Stun Ability/Stun Hit", 0);
				g_iStunHit[iIndex] = iClamp(g_iStunHit[iIndex], 0, 1);
				g_iStunHitMode[iIndex] = kvSuperTanks.GetNum("Stun Ability/Stun Hit Mode", 0);
				g_iStunHitMode[iIndex] = iClamp(g_iStunHitMode[iIndex], 0, 2);
				g_flStunRange[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Range", 150.0);
				g_flStunRange[iIndex] = flClamp(g_flStunRange[iIndex], 1.0, 9999999999.0);
				g_flStunRangeChance[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Range Chance", 15.0);
				g_flStunRangeChance[iIndex] = flClamp(g_flStunRangeChance[iIndex], 0.1, 100.0);
				g_flStunSpeed[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Speed", 0.25);
				g_flStunSpeed[iIndex] = flClamp(g_flStunSpeed[iIndex], 0.1, 0.9);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iStunAbility2[iIndex] = kvSuperTanks.GetNum("Stun Ability/Ability Enabled", g_iStunAbility[iIndex]);
				g_iStunAbility2[iIndex] = iClamp(g_iStunAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Stun Ability/Ability Effect", g_sStunEffect2[iIndex], sizeof(g_sStunEffect2[]), g_sStunEffect[iIndex]);
				kvSuperTanks.GetString("Stun Ability/Ability Message", g_sStunMessage2[iIndex], sizeof(g_sStunMessage2[]), g_sStunMessage[iIndex]);
				g_flStunChance2[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Chance", g_flStunChance[iIndex]);
				g_flStunChance2[iIndex] = flClamp(g_flStunChance2[iIndex], 0.1, 100.0);
				g_flStunDuration2[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Duration", g_flStunDuration[iIndex]);
				g_flStunDuration2[iIndex] = flClamp(g_flStunDuration2[iIndex], 0.1, 9999999999.0);
				g_iStunHit2[iIndex] = kvSuperTanks.GetNum("Stun Ability/Stun Hit", g_iStunHit[iIndex]);
				g_iStunHit2[iIndex] = iClamp(g_iStunHit2[iIndex], 0, 1);
				g_iStunHitMode2[iIndex] = kvSuperTanks.GetNum("Stun Ability/Stun Hit Mode", g_iStunHitMode[iIndex]);
				g_iStunHitMode2[iIndex] = iClamp(g_iStunHitMode2[iIndex], 0, 2);
				g_flStunRange2[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Range", g_flStunRange[iIndex]);
				g_flStunRange2[iIndex] = flClamp(g_flStunRange2[iIndex], 1.0, 9999999999.0);
				g_flStunRangeChance2[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Range Chance", g_flStunRangeChance[iIndex]);
				g_flStunRangeChance2[iIndex] = flClamp(g_flStunRangeChance2[iIndex], 0.1, 100.0);
				g_flStunSpeed2[iIndex] = kvSuperTanks.GetFloat("Stun Ability/Stun Speed", g_flStunSpeed[iIndex]);
				g_flStunSpeed2[iIndex] = flClamp(g_flStunSpeed2[iIndex], 0.1, 0.9);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			vRemoveStun(iPlayer);
		}
	}

	vReset();
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveStun(iTank);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flStunRange = !g_bTankConfig[ST_TankType(tank)] ? g_flStunRange[ST_TankType(tank)] : g_flStunRange2[ST_TankType(tank)],
			flStunRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flStunRangeChance[ST_TankType(tank)] : g_flStunRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flStunRange)
				{
					vStunHit(iSurvivor, tank, flStunRangeChance, iStunAbility(tank), "2", "3");
				}
			}
		}
	}
}

public void ST_BossStage(int tank)
{
	if (iStunAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveStun(tank);
	}
}

static void vRemoveStun(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bStun[iSurvivor])
		{
			DataPack dpStopStun;
			CreateDataTimer(0.1, tTimerStopStun, dpStopStun, TIMER_FLAG_NO_MAPCHANGE);
			dpStopStun.WriteCell(GetClientUserId(iSurvivor));
			dpStopStun.WriteCell(GetClientUserId(tank));
			dpStopStun.WriteString("0");
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bStun[iPlayer] = false;
		}
	}
}

static void vStunHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bStun[survivor])
	{
		g_bStun[survivor] = true;

		float flStunSpeed = !g_bTankConfig[ST_TankType(tank)] ? g_flStunSpeed[ST_TankType(tank)] : g_flStunSpeed2[ST_TankType(tank)],
			flStunDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flStunDuration[ST_TankType(tank)] : g_flStunDuration2[ST_TankType(tank)];

		SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", flStunSpeed);

		DataPack dpStopStun;
		CreateDataTimer(flStunDuration, tTimerStopStun, dpStopStun, TIMER_FLAG_NO_MAPCHANGE);
		dpStopStun.WriteCell(GetClientUserId(survivor));
		dpStopStun.WriteCell(GetClientUserId(tank));
		dpStopStun.WriteString(message);

		char sStunEffect[4];
		sStunEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sStunEffect[ST_TankType(tank)] : g_sStunEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sStunEffect, mode);

		char sStunMessage[3];
		sStunMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sStunMessage[ST_TankType(tank)] : g_sStunMessage2[ST_TankType(tank)];
		if (StrContains(sStunMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Stun", sTankName, survivor, flStunSpeed);
		}
	}
}

static float flStunChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flStunChance[ST_TankType(tank)] : g_flStunChance2[ST_TankType(tank)];
}

static int iStunAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iStunAbility[ST_TankType(tank)] : g_iStunAbility2[ST_TankType(tank)];
}

static int iStunHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iStunHit[ST_TankType(tank)] : g_iStunHit2[ST_TankType(tank)];
}

static int iStunHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iStunHitMode[ST_TankType(tank)] : g_iStunHitMode2[ST_TankType(tank)];
}

public Action tTimerStopStun(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bStun[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bStun[iSurvivor])
	{
		g_bStun[iSurvivor] = false;

		SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);

		return Plugin_Stop;
	}

	g_bStun[iSurvivor] = false;

	SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);

	char sStunMessage[3], sMessage[3];
	sStunMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sStunMessage[ST_TankType(iTank)] : g_sStunMessage2[ST_TankType(iTank)];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (StrContains(sStunMessage, sMessage) != -1)
	{
		PrintToChatAll("%s %t", ST_TAG2, "Stun2", iSurvivor);
	}

	return Plugin_Continue;
}