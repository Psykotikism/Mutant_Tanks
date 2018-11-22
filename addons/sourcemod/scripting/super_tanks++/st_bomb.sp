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

// Super Tanks++: Bomb Ability
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
	name = "[ST++] Bomb Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates explosions.",
	version = ST_VERSION,
	url = ST_URL
};

#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sBombEffect[ST_MAXTYPES + 1][4], g_sBombEffect2[ST_MAXTYPES + 1][4], g_sBombMessage[ST_MAXTYPES + 1][4], g_sBombMessage2[ST_MAXTYPES + 1][4];

float g_flBombChance[ST_MAXTYPES + 1], g_flBombChance2[ST_MAXTYPES + 1], g_flBombRange[ST_MAXTYPES + 1], g_flBombRange2[ST_MAXTYPES + 1], g_flBombRangeChance[ST_MAXTYPES + 1], g_flBombRangeChance2[ST_MAXTYPES + 1];

int g_iBombAbility[ST_MAXTYPES + 1], g_iBombAbility2[ST_MAXTYPES + 1], g_iBombHit[ST_MAXTYPES + 1], g_iBombHit2[ST_MAXTYPES + 1], g_iBombHitMode[ST_MAXTYPES + 1], g_iBombHitMode2[ST_MAXTYPES + 1], g_iBombRock[ST_MAXTYPES + 1], g_iBombRock2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Bomb Ability\" only supports Left 4 Dead 1 & 2.");

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
	PrecacheModel(MODEL_PROPANETANK, true);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iBombHitMode(attacker) == 0 || iBombHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vBombHit(victim, attacker, flBombChance(attacker), iBombHit(attacker), "1", "1");
			}
		}
		else if ((iBombHitMode(victim) == 0 || iBombHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vBombHit(attacker, victim, flBombChance(victim), iBombHit(victim), "1", "2");
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

				g_iBombAbility[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Ability Enabled", 0);
				g_iBombAbility[iIndex] = iClamp(g_iBombAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Bomb Ability/Ability Effect", g_sBombEffect[iIndex], sizeof(g_sBombEffect[]), "0");
				kvSuperTanks.GetString("Bomb Ability/Ability Message", g_sBombMessage[iIndex], sizeof(g_sBombMessage[]), "0");
				g_flBombChance[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Chance", 33.3);
				g_flBombChance[iIndex] = flClamp(g_flBombChance[iIndex], 0.0, 100.0);
				g_iBombHit[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Hit", 0);
				g_iBombHit[iIndex] = iClamp(g_iBombHit[iIndex], 0, 1);
				g_iBombHitMode[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Hit Mode", 0);
				g_iBombHitMode[iIndex] = iClamp(g_iBombHitMode[iIndex], 0, 2);
				g_flBombRange[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Range", 150.0);
				g_flBombRange[iIndex] = flClamp(g_flBombRange[iIndex], 1.0, 9999999999.0);
				g_flBombRangeChance[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Range Chance", 15.0);
				g_flBombRangeChance[iIndex] = flClamp(g_flBombRangeChance[iIndex], 0.0, 100.0);
				g_iBombRock[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Rock Break", 0);
				g_iBombRock[iIndex] = iClamp(g_iBombRock[iIndex], 0, 1);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iBombAbility2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Ability Enabled", g_iBombAbility[iIndex]);
				g_iBombAbility2[iIndex] = iClamp(g_iBombAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Bomb Ability/Ability Effect", g_sBombEffect2[iIndex], sizeof(g_sBombEffect2[]), g_sBombEffect[iIndex]);
				kvSuperTanks.GetString("Bomb Ability/Ability Message", g_sBombMessage2[iIndex], sizeof(g_sBombMessage2[]), g_sBombMessage[iIndex]);
				g_flBombChance2[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Chance", g_flBombChance[iIndex]);
				g_flBombChance2[iIndex] = flClamp(g_flBombChance2[iIndex], 0.0, 100.0);
				g_iBombHit2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Hit", g_iBombHit[iIndex]);
				g_iBombHit2[iIndex] = iClamp(g_iBombHit2[iIndex], 0, 1);
				g_iBombHitMode2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Hit Mode", g_iBombHitMode[iIndex]);
				g_iBombHitMode2[iIndex] = iClamp(g_iBombHitMode2[iIndex], 0, 2);
				g_flBombRange2[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Range", g_flBombRange[iIndex]);
				g_flBombRange2[iIndex] = flClamp(g_flBombRange2[iIndex], 1.0, 9999999999.0);
				g_flBombRangeChance2[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Range Chance", g_flBombRangeChance[iIndex]);
				g_flBombRangeChance2[iIndex] = flClamp(g_flBombRangeChance2[iIndex], 0.0, 100.0);
				g_iBombRock2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Rock Break", g_iBombRock[iIndex]);
				g_iBombRock2[iIndex] = iClamp(g_iBombRock2[iIndex], 0, 1);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_EventHandler(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iBombAbility(iTank) == 1 && ST_TankAllowed(iTank, "024") && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			float flPos[3];
			GetClientAbsOrigin(iTank, flPos);
			vSpecialAttack(iTank, flPos, 10.0, MODEL_PROPANETANK);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		float flBombRange = !g_bTankConfig[ST_TankType(tank)] ? g_flBombRange[ST_TankType(tank)] : g_flBombRange2[ST_TankType(tank)],
			flBombRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flBombRangeChance[ST_TankType(tank)] : g_flBombRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, "234"))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flBombRange)
				{
					vBombHit(iSurvivor, tank, flBombRangeChance, iBombAbility(tank), "2", "3");
				}
			}
		}
	}
}

public void ST_ChangeType(int tank)
{
	if (iBombAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		float flPos[3];
		GetClientAbsOrigin(tank, flPos);
		vSpecialAttack(tank, flPos, 10.0, MODEL_PROPANETANK);
	}
}

public void ST_RockBreak(int tank, int rock)
{
	int iBombRock = !g_bTankConfig[ST_TankType(tank)] ? g_iBombRock[ST_TankType(tank)] : g_iBombRock2[ST_TankType(tank)];
	if (iBombRock == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		float flPos[3];
		GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flPos);
		vSpecialAttack(tank, flPos, 10.0, MODEL_PROPANETANK);

		char sBombMessage[4];
		sBombMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sBombMessage[ST_TankType(tank)] : g_sBombMessage2[ST_TankType(tank)];
		if (StrContains(sBombMessage, "3") != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Bomb2", sTankName);
		}
	}
}

static void vBombHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor))
	{
		float flPos[3];
		GetClientAbsOrigin(survivor, flPos);
		vSpecialAttack(tank, flPos, 10.0, MODEL_PROPANETANK);

		char sBombEffect[4];
		sBombEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sBombEffect[ST_TankType(tank)] : g_sBombEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sBombEffect, mode);

		char sBombMessage[4];
		sBombMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sBombMessage[ST_TankType(tank)] : g_sBombMessage2[ST_TankType(tank)];
		if (StrContains(sBombMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Bomb", sTankName, survivor);
		}
	}
}

static float flBombChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flBombChance[ST_TankType(tank)] : g_flBombChance2[ST_TankType(tank)];
}

static int iBombAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBombAbility[ST_TankType(tank)] : g_iBombAbility2[ST_TankType(tank)];
}

static int iBombHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBombHit[ST_TankType(tank)] : g_iBombHit2[ST_TankType(tank)];
}

static int iBombHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBombHitMode[ST_TankType(tank)] : g_iBombHitMode2[ST_TankType(tank)];
}