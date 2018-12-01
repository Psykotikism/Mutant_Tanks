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

// Super Tanks++: Pyro Ability
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
	name = "[ST++] Pyro Ability",
	author = ST_AUTHOR,
	description = "The Super Tank gains a speed boost when on fire.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bPyro[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sPyroEffect[ST_MAXTYPES + 1][4], g_sPyroEffect2[ST_MAXTYPES + 1][4], g_sPyroMessage[ST_MAXTYPES + 1][4], g_sPyroMessage2[ST_MAXTYPES + 1][4];

float g_flPyroBoost[ST_MAXTYPES + 1], g_flPyroBoost2[ST_MAXTYPES + 1], g_flPyroChance[ST_MAXTYPES + 1], g_flPyroChance2[ST_MAXTYPES + 1], g_flPyroDuration[ST_MAXTYPES + 1], g_flPyroDuration2[ST_MAXTYPES + 1], g_flPyroRange[ST_MAXTYPES + 1], g_flPyroRange2[ST_MAXTYPES + 1], g_flRunSpeed[ST_MAXTYPES + 1], g_flRunSpeed2[ST_MAXTYPES + 1], g_flPyroRangeChance[ST_MAXTYPES + 1], g_flPyroRangeChance2[ST_MAXTYPES + 1];

int g_iPyroAbility[ST_MAXTYPES + 1], g_iPyroAbility2[ST_MAXTYPES + 1], g_iPyroHit[ST_MAXTYPES + 1], g_iPyroHit2[ST_MAXTYPES + 1], g_iPyroHitMode[ST_MAXTYPES + 1], g_iPyroHitMode2[ST_MAXTYPES + 1], g_iPyroMode[ST_MAXTYPES + 1], g_iPyroMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Pyro Ability\" only supports Left 4 Dead 1 & 2.");

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

	g_bPyro[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iPyroHitMode(attacker) == 0 || iPyroHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vPyroHit(victim, attacker, flPyroChance(attacker), iPyroHit(attacker), "1", "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled))
		{
			if ((iPyroHitMode(victim) == 0 || iPyroHitMode(victim) == 2) && bIsSurvivor(attacker) && StrEqual(sClassname, "weapon_melee"))
			{
				vPyroHit(attacker, victim, flPyroChance(victim), iPyroHit(victim), "1", "2");
			}

			if (iPyroAbility(victim) == 2 || iPyroAbility(victim) == 3)
			{
				if (damagetype & DMG_BURN || damagetype & (DMG_BURN|DMG_PREVENT_PHYSICS_FORCE) || damagetype & (DMG_BURN|DMG_DIRECT))
				{
					int iPyroMode = !g_bTankConfig[ST_TankType(victim)] ? g_iPyroMode[ST_TankType(victim)] : g_iPyroMode2[ST_TankType(victim)];
					float flPyroBoost = !g_bTankConfig[ST_TankType(victim)] ? g_flPyroBoost[ST_TankType(victim)] : g_flPyroBoost2[ST_TankType(victim)],
						flRunSpeed = !g_bTankConfig[ST_TankType(victim)] ? g_flRunSpeed[ST_TankType(victim)] : g_flRunSpeed2[ST_TankType(victim)];

					switch (iPyroMode)
					{
						case 0: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", flRunSpeed + flPyroBoost);
						case 1: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", flPyroBoost);
					}

					if (!g_bPyro[victim])
					{
						g_bPyro[victim] = true;

						DataPack dpPyro;
						CreateDataTimer(1.0, tTimerPyro, dpPyro, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						dpPyro.WriteCell(GetClientUserId(victim));
						dpPyro.WriteFloat(GetEngineTime());

						char sPyroMessage[4];
						sPyroMessage = !g_bTankConfig[ST_TankType(victim)] ? g_sPyroMessage[ST_TankType(victim)] : g_sPyroMessage2[ST_TankType(victim)];
						if (StrContains(sPyroMessage, "3") != -1)
						{
							char sTankName[33];
							ST_TankName(victim, sTankName);
							ST_PrintToChatAll("%s %t", ST_TAG2, "Pyro2", sTankName);
						}
					}
				}
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
		Format(sTankName, sizeof(sTankName), "Tank #%i", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_flRunSpeed[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", 1.0);
				g_flRunSpeed[iIndex] = flClamp(g_flRunSpeed[iIndex], 0.1, 3.0);
				g_iPyroAbility[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Ability Enabled", 0);
				g_iPyroAbility[iIndex] = iClamp(g_iPyroAbility[iIndex], 0, 3);
				kvSuperTanks.GetString("Pyro Ability/Ability Effect", g_sPyroEffect[iIndex], sizeof(g_sPyroEffect[]), "0");
				kvSuperTanks.GetString("Pyro Ability/Ability Message", g_sPyroMessage[iIndex], sizeof(g_sPyroMessage[]), "0");
				g_flPyroBoost[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Boost", 1.0);
				g_flPyroBoost[iIndex] = flClamp(g_flPyroBoost[iIndex], 0.1, 3.0);
				g_flPyroChance[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Chance", 33.3);
				g_flPyroChance[iIndex] = flClamp(g_flPyroChance[iIndex], 0.0, 100.0);
				g_flPyroDuration[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Duration", 5.0);
				g_flPyroDuration[iIndex] = flClamp(g_flPyroDuration[iIndex], 0.1, 9999999999.0);
				g_iPyroHit[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Hit", 0);
				g_iPyroHit[iIndex] = iClamp(g_iPyroHit[iIndex], 0, 1);
				g_iPyroHitMode[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Hit Mode", 0);
				g_iPyroHitMode[iIndex] = iClamp(g_iPyroHitMode[iIndex], 0, 2);
				g_iPyroMode[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Mode", 0);
				g_iPyroMode[iIndex] = iClamp(g_iPyroMode[iIndex], 0, 1);
				g_flPyroRange[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Range", 150.0);
				g_flPyroRange[iIndex] = flClamp(g_flPyroRange[iIndex], 1.0, 9999999999.0);
				g_flPyroRangeChance[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Range Chance", 15.0);
				g_flPyroRangeChance[iIndex] = flClamp(g_flPyroRangeChance[iIndex], 0.0, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_flRunSpeed2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", g_flRunSpeed[iIndex]);
				g_flRunSpeed2[iIndex] = flClamp(g_flRunSpeed2[iIndex], 0.1, 3.0);
				g_iPyroAbility2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Ability Enabled", g_iPyroAbility[iIndex]);
				g_iPyroAbility2[iIndex] = iClamp(g_iPyroAbility2[iIndex], 0, 3);
				kvSuperTanks.GetString("Pyro Ability/Ability Effect", g_sPyroEffect2[iIndex], sizeof(g_sPyroEffect2[]), g_sPyroEffect[iIndex]);
				kvSuperTanks.GetString("Pyro Ability/Ability Message", g_sPyroMessage2[iIndex], sizeof(g_sPyroMessage2[]), g_sPyroMessage[iIndex]);
				g_flPyroBoost2[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Boost", g_flPyroBoost[iIndex]);
				g_flPyroBoost2[iIndex] = flClamp(g_flPyroBoost2[iIndex], 0.1, 3.0);
				g_flPyroChance2[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Chance", g_flPyroChance[iIndex]);
				g_flPyroChance2[iIndex] = flClamp(g_flPyroChance2[iIndex], 0.0, 100.0);
				g_flPyroDuration2[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Duration", g_flPyroDuration[iIndex]);
				g_flPyroDuration2[iIndex] = flClamp(g_flPyroDuration2[iIndex], 0.1, 9999999999.0);
				g_iPyroHit2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Hit", g_iPyroHit[iIndex]);
				g_iPyroHit2[iIndex] = iClamp(g_iPyroHit2[iIndex], 0, 1);
				g_iPyroHitMode2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Hit Mode", g_iPyroHitMode[iIndex]);
				g_iPyroHitMode2[iIndex] = iClamp(g_iPyroHitMode2[iIndex], 0, 2);
				g_iPyroMode2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Mode", g_iPyroMode[iIndex]);
				g_iPyroMode2[iIndex] = iClamp(g_iPyroMode2[iIndex], 0, 1);
				g_flPyroRange2[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Range", g_flPyroRange[iIndex]);
				g_flPyroRange2[iIndex] = flClamp(g_flPyroRange2[iIndex], 1.0, 9999999999.0);
				g_flPyroRangeChance2[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Range Chance", g_flPyroRangeChance[iIndex]);
				g_flPyroRangeChance2[iIndex] = flClamp(g_flPyroRangeChance2[iIndex], 0.0, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, "234") && g_bPyro[iTank])
		{
			ExtinguishEntity(iTank);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		float flPyroRange = !g_bTankConfig[ST_TankType(tank)] ? g_flPyroRange[ST_TankType(tank)] : g_flPyroRange2[ST_TankType(tank)],
			flPyroRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flPyroRangeChance[ST_TankType(tank)] : g_flPyroRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, "234"))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flPyroRange)
				{
					vPyroHit(iSurvivor, tank, flPyroRangeChance, iPyroAbility(tank), "2", "3");
				}
			}
		}
	}
}

public void ST_ChangeType(int tank)
{
	g_bPyro[tank] = false;
}

static void vPyroHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if ((enabled == 1 || enabled == 3) && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bPyro[tank])
	{
		IgniteEntity(tank, flPyroDuration(tank), true);

		char sPyroEffect[4];
		sPyroEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sPyroEffect[ST_TankType(tank)] : g_sPyroEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sPyroEffect, mode);

		char sPyroMessage[4];
		sPyroMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sPyroMessage[ST_TankType(tank)] : g_sPyroMessage2[ST_TankType(tank)];
		if (StrContains(sPyroMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Pyro", sTankName);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			g_bPyro[iPlayer] = false;
		}
	}
}

static float flPyroChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flPyroChance[ST_TankType(tank)] : g_flPyroChance2[ST_TankType(tank)];
}

static float flPyroDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flPyroDuration[ST_TankType(tank)] : g_flPyroDuration2[ST_TankType(tank)];
}

static int iPyroAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPyroAbility[ST_TankType(tank)] : g_iPyroAbility2[ST_TankType(tank)];
}

static int iPyroHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPyroHit[ST_TankType(tank)] : g_iPyroHit2[ST_TankType(tank)];
}

static int iPyroHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPyroHitMode[ST_TankType(tank)] : g_iPyroHitMode2[ST_TankType(tank)];
}

public Action tTimerPyro(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_PluginEnabled() || !ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bPyro[iTank] = false;

		return Plugin_Stop;
	}

	float flTime = pack.ReadFloat();
	if ((iPyroAbility(iTank) != 2 && iPyroAbility(iTank) != 3) || !bIsPlayerBurning(iTank) || (flTime + flPyroDuration(iTank) < GetEngineTime()) || !g_bPyro[iTank])
	{
		g_bPyro[iTank] = false;

		ExtinguishEntity(iTank);

		char sPyroMessage[4];
		sPyroMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sPyroMessage[ST_TankType(iTank)] : g_sPyroMessage2[ST_TankType(iTank)];
		if (StrContains(sPyroMessage, "3") != -1)
		{
			char sTankName[33];
			ST_TankName(iTank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Pyro3", sTankName);
		}

		return Plugin_Stop;
	}

	return Plugin_Continue;
}