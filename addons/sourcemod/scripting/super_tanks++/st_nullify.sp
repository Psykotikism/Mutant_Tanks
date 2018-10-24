/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2018  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Super Tanks++: Nullify Ability
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
	name = "[ST++] Nullify Ability",
	author = ST_AUTHOR,
	description = "The Super Tank nullifies all of the survivors' damage.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bNullify[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sNullifyEffect[ST_MAXTYPES + 1][4], g_sNullifyEffect2[ST_MAXTYPES + 1][4];

float g_flNullifyChance[ST_MAXTYPES + 1], g_flNullifyChance2[ST_MAXTYPES + 1], g_flNullifyDuration[ST_MAXTYPES + 1], g_flNullifyDuration2[ST_MAXTYPES + 1], g_flNullifyRange[ST_MAXTYPES + 1], g_flNullifyRange2[ST_MAXTYPES + 1], g_flNullifyRangeChance[ST_MAXTYPES + 1], g_flNullifyRangeChance2[ST_MAXTYPES + 1];

int g_iNullifyAbility[ST_MAXTYPES + 1], g_iNullifyAbility2[ST_MAXTYPES + 1], g_iNullifyHit[ST_MAXTYPES + 1], g_iNullifyHit2[ST_MAXTYPES + 1], g_iNullifyHitMode[ST_MAXTYPES + 1], g_iNullifyHitMode2[ST_MAXTYPES + 1], g_iNullifyMessage[ST_MAXTYPES + 1], g_iNullifyMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Nullify Ability only supports Left 4 Dead 1 & 2.");

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

	g_bNullify[client] = false;
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

		if ((iNullifyHitMode(attacker) == 0 || iNullifyHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vNullifyHit(victim, attacker, flNullifyChance(attacker), iNullifyHit(attacker), 1, "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if ((iNullifyHitMode(victim) == 0 || iNullifyHitMode(victim) == 2) && StrEqual(sClassname, "weapon_melee"))
			{
				vNullifyHit(attacker, victim, flNullifyChance(victim), iNullifyHit(victim), 1, "2");
			}

			if (g_bNullify[attacker])
			{
				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
}

public void ST_Configs(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sTankName[33];
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName, true))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iNullifyAbility[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Ability Enabled", 0);
				g_iNullifyAbility[iIndex] = iClamp(g_iNullifyAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Nullify Ability/Ability Effect", g_sNullifyEffect[iIndex], sizeof(g_sNullifyEffect[]), "123");
				g_iNullifyMessage[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Ability Message", 0);
				g_iNullifyMessage[iIndex] = iClamp(g_iNullifyMessage[iIndex], 0, 3);
				g_flNullifyChance[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Chance", 33.3);
				g_flNullifyChance[iIndex] = flClamp(g_flNullifyChance[iIndex], 0.1, 100.0);
				g_flNullifyDuration[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Duration", 5.0);
				g_flNullifyDuration[iIndex] = flClamp(g_flNullifyDuration[iIndex], 0.1, 9999999999.0);
				g_iNullifyHit[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit", 0);
				g_iNullifyHit[iIndex] = iClamp(g_iNullifyHit[iIndex], 0, 1);
				g_iNullifyHitMode[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit Mode", 0);
				g_iNullifyHitMode[iIndex] = iClamp(g_iNullifyHitMode[iIndex], 0, 2);
				g_flNullifyRange[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Range", 150.0);
				g_flNullifyRange[iIndex] = flClamp(g_flNullifyRange[iIndex], 1.0, 9999999999.0);
				g_flNullifyRangeChance[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Range Chance", 15.0);
				g_flNullifyRangeChance[iIndex] = flClamp(g_flNullifyRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iNullifyAbility2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Ability Enabled", g_iNullifyAbility[iIndex]);
				g_iNullifyAbility2[iIndex] = iClamp(g_iNullifyAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Nullify Ability/Ability Effect", g_sNullifyEffect2[iIndex], sizeof(g_sNullifyEffect2[]), g_sNullifyEffect[iIndex]);
				g_iNullifyMessage2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Ability Message", g_iNullifyMessage[iIndex]);
				g_iNullifyMessage2[iIndex] = iClamp(g_iNullifyMessage2[iIndex], 0, 3);
				g_flNullifyChance2[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Chance", g_flNullifyChance[iIndex]);
				g_flNullifyChance2[iIndex] = flClamp(g_flNullifyChance2[iIndex], 0.1, 100.0);
				g_flNullifyDuration2[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Duration", g_flNullifyDuration[iIndex]);
				g_flNullifyDuration2[iIndex] = flClamp(g_flNullifyDuration2[iIndex], 0.1, 9999999999.0);
				g_iNullifyHit2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit", g_iNullifyHit[iIndex]);
				g_iNullifyHit2[iIndex] = iClamp(g_iNullifyHit2[iIndex], 0, 1);
				g_iNullifyHitMode2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit Mode", g_iNullifyHitMode[iIndex]);
				g_iNullifyHitMode2[iIndex] = iClamp(g_iNullifyHitMode2[iIndex], 0, 2);
				g_flNullifyRange2[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Range", g_flNullifyRange[iIndex]);
				g_flNullifyRange2[iIndex] = flClamp(g_flNullifyRange2[iIndex], 1.0, 9999999999.0);
				g_flNullifyRangeChance2[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Range Chance", g_flNullifyRangeChance[iIndex]);
				g_flNullifyRangeChance2[iIndex] = flClamp(g_flNullifyRangeChance2[iIndex], 0.1, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vRemoveNullify();
	vReset();
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveNullify();
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flNullifyRange = !g_bTankConfig[ST_TankType(tank)] ? g_flNullifyRange[ST_TankType(tank)] : g_flNullifyRange2[ST_TankType(tank)],
			flNullifyRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flNullifyRangeChance[ST_TankType(tank)] : g_flNullifyRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flNullifyRange)
				{
					vNullifyHit(iSurvivor, tank, flNullifyRangeChance, iNullifyAbility(tank), 2, "3");
				}
			}
		}
	}
}

public void ST_BossStage(int tank)
{
	if (iNullifyAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveNullify();
	}
}

static void vNullifyHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bNullify[survivor])
	{
		g_bNullify[survivor] = true;

		float flNullifyDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flNullifyDuration[ST_TankType(tank)] : g_flNullifyDuration2[ST_TankType(tank)];
		DataPack dpStopNullify;
		CreateDataTimer(flNullifyDuration, tTimerStopNullify, dpStopNullify, TIMER_FLAG_NO_MAPCHANGE);
		dpStopNullify.WriteCell(GetClientUserId(survivor));
		dpStopNullify.WriteCell(GetClientUserId(tank));
		dpStopNullify.WriteCell(message);

		char sNullifyEffect[4];
		sNullifyEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sNullifyEffect[ST_TankType(tank)] : g_sNullifyEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sNullifyEffect, mode);

		if (iNullifyMessage(tank) == message || iNullifyMessage(tank) == 3)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Nullify", sTankName, survivor);
		}
	}
}

static void vRemoveNullify()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bNullify[iSurvivor])
		{
			g_bNullify[iSurvivor] = false;
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bNullify[iPlayer] = false;
		}
	}
}

static float flNullifyChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flNullifyChance[ST_TankType(tank)] : g_flNullifyChance2[ST_TankType(tank)];
}

static int iNullifyAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iNullifyAbility[ST_TankType(tank)] : g_iNullifyAbility2[ST_TankType(tank)];
}

static int iNullifyHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iNullifyHit[ST_TankType(tank)] : g_iNullifyHit2[ST_TankType(tank)];
}

static int iNullifyHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iNullifyHitMode[ST_TankType(tank)] : g_iNullifyHitMode2[ST_TankType(tank)];
}

static int iNullifyMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iNullifyMessage[ST_TankType(tank)] : g_iNullifyMessage2[ST_TankType(tank)];
}

public Action tTimerStopNullify(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bNullify[iSurvivor])
	{
		g_bNullify[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iNullifyChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bNullify[iSurvivor] = false;

		return Plugin_Stop;
	}

	g_bNullify[iSurvivor] = false;

	if (iNullifyMessage(iTank) == iNullifyChat || iNullifyMessage(iTank) == 3)
	{
		PrintToChatAll("%s %t", ST_TAG2, "Nullify2", iSurvivor);
	}

	return Plugin_Continue;
}