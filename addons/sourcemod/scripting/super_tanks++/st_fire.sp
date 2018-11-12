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

// Super Tanks++: Fire Ability
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
	name = "[ST++] Fire Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates fires.",
	version = ST_VERSION,
	url = ST_URL
};

#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sFireEffect[ST_MAXTYPES + 1][4], g_sFireEffect2[ST_MAXTYPES + 1][4], g_sFireMessage[ST_MAXTYPES + 1][4], g_sFireMessage2[ST_MAXTYPES + 1][4];

float g_flFireChance[ST_MAXTYPES + 1], g_flFireChance2[ST_MAXTYPES + 1], g_flFireRange[ST_MAXTYPES + 1], g_flFireRange2[ST_MAXTYPES + 1], g_flFireRangeChance[ST_MAXTYPES + 1], g_flFireRangeChance2[ST_MAXTYPES + 1];

int g_iFireAbility[ST_MAXTYPES + 1], g_iFireAbility2[ST_MAXTYPES + 1], g_iFireHit[ST_MAXTYPES + 1], g_iFireHit2[ST_MAXTYPES + 1], g_iFireHitMode[ST_MAXTYPES + 1], g_iFireHitMode2[ST_MAXTYPES + 1], g_iFireRock[ST_MAXTYPES + 1], g_iFireRock2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Fire Ability\" only supports Left 4 Dead 1 & 2.");

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
	PrecacheModel(MODEL_GASCAN, true);
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

		if ((iFireHitMode(attacker) == 0 || iFireHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vFireHit(victim, attacker, flFireChance(attacker), iFireHit(attacker), "1", "1");
			}
		}
		else if ((iFireHitMode(victim) == 0 || iFireHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vFireHit(attacker, victim, flFireChance(victim), iFireHit(victim), "1", "2");
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

				g_iFireAbility[iIndex] = kvSuperTanks.GetNum("Fire Ability/Ability Enabled", 0);
				g_iFireAbility[iIndex] = iClamp(g_iFireAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Fire Ability/Ability Effect", g_sFireEffect[iIndex], sizeof(g_sFireEffect[]), "0");
				kvSuperTanks.GetString("Fire Ability/Ability Message", g_sFireMessage[iIndex], sizeof(g_sFireMessage[]), "0");
				g_flFireChance[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Chance", 33.3);
				g_flFireChance[iIndex] = flClamp(g_flFireChance[iIndex], 0.0, 100.0);
				g_iFireHit[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Hit", 0);
				g_iFireHit[iIndex] = iClamp(g_iFireHit[iIndex], 0, 1);
				g_iFireHitMode[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Hit Mode", 0);
				g_iFireHitMode[iIndex] = iClamp(g_iFireHitMode[iIndex], 0, 2);
				g_flFireRange[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Range", 150.0);
				g_flFireRange[iIndex] = flClamp(g_flFireRange[iIndex], 1.0, 9999999999.0);
				g_flFireRangeChance[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Range Chance", 15.0);
				g_flFireRangeChance[iIndex] = flClamp(g_flFireRangeChance[iIndex], 0.0, 100.0);
				g_iFireRock[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Rock Break", 0);
				g_iFireRock[iIndex] = iClamp(g_iFireRock[iIndex], 0, 1);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iFireAbility2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Ability Enabled", g_iFireAbility[iIndex]);
				g_iFireAbility2[iIndex] = iClamp(g_iFireAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Fire Ability/Ability Effect", g_sFireEffect2[iIndex], sizeof(g_sFireEffect2[]), g_sFireEffect[iIndex]);
				kvSuperTanks.GetString("Fire Ability/Ability Message", g_sFireMessage2[iIndex], sizeof(g_sFireMessage2[]), g_sFireMessage[iIndex]);
				g_flFireChance2[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Chance", g_flFireChance[iIndex]);
				g_flFireChance2[iIndex] = flClamp(g_flFireChance2[iIndex], 0.0, 100.0);
				g_iFireHit2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Hit", g_iFireHit[iIndex]);
				g_iFireHit2[iIndex] = iClamp(g_iFireHit2[iIndex], 0, 1);
				g_iFireHitMode2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Hit Mode", g_iFireHitMode[iIndex]);
				g_iFireHitMode2[iIndex] = iClamp(g_iFireHitMode2[iIndex], 0, 2);
				g_flFireRange2[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Range", g_flFireRange[iIndex]);
				g_flFireRange2[iIndex] = flClamp(g_flFireRange2[iIndex], 1.0, 9999999999.0);
				g_flFireRangeChance2[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Range Chance", g_flFireRangeChance[iIndex]);
				g_flFireRangeChance2[iIndex] = flClamp(g_flFireRangeChance2[iIndex], 0.0, 100.0);
				g_iFireRock2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Rock Break", g_iFireRock[iIndex]);
				g_iFireRock2[iIndex] = iClamp(g_iFireRock2[iIndex], 0, 1);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_EventHandler(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iFireAbility(iTank) == 1 && ST_TankAllowed(iTank, "024") && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			float flPos[3];
			GetClientAbsOrigin(iTank, flPos);
			vSpecialAttack(iTank, flPos, 10.0, MODEL_GASCAN);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		float flFireRange = !g_bTankConfig[ST_TankType(tank)] ? g_flFireRange[ST_TankType(tank)] : g_flFireRange2[ST_TankType(tank)],
			flFireRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flFireRangeChance[ST_TankType(tank)] : g_flFireRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, "234"))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flFireRange)
				{
					vFireHit(iSurvivor, tank, flFireRangeChance, iFireAbility(tank), "2", "3");
				}
			}
		}
	}
}

public void ST_ChangeType(int tank)
{
	if (iFireAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		float flPos[3];
		GetClientAbsOrigin(tank, flPos);
		vSpecialAttack(tank, flPos, 10.0, MODEL_GASCAN);
	}
}

public void ST_RockBreak(int tank, int rock)
{
	int iFireRock = !g_bTankConfig[ST_TankType(tank)] ? g_iFireRock[ST_TankType(tank)] : g_iFireRock2[ST_TankType(tank)];
	if (iFireRock == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		float flPos[3];
		GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flPos);
		vSpecialAttack(tank, flPos, 10.0, MODEL_GASCAN);

		char sFireMessage[4];
		sFireMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sFireMessage[ST_TankType(tank)] : g_sFireMessage2[ST_TankType(tank)];
		if (StrContains(sFireMessage, "3") != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Fire2", sTankName);
		}
	}
}

static void vFireHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor))
	{
		float flPos[3];
		GetClientAbsOrigin(survivor, flPos);
		vSpecialAttack(tank, flPos, 10.0, MODEL_GASCAN);

		char sFireEffect[4];
		sFireEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sFireEffect[ST_TankType(tank)] : g_sFireEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sFireEffect, mode);

		char sFireMessage[4];
		sFireMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sFireMessage[ST_TankType(tank)] : g_sFireMessage2[ST_TankType(tank)];
		if (StrContains(sFireMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Fire", sTankName, survivor);
		}
	}
}

static float flFireChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flFireChance[ST_TankType(tank)] : g_flFireChance2[ST_TankType(tank)];
}

static int iFireAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iFireAbility[ST_TankType(tank)] : g_iFireAbility2[ST_TankType(tank)];
}

static int iFireHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iFireHit[ST_TankType(tank)] : g_iFireHit2[ST_TankType(tank)];
}

static int iFireHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iFireHitMode[ST_TankType(tank)] : g_iFireHitMode2[ST_TankType(tank)];
}