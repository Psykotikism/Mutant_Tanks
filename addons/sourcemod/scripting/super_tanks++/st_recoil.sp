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

// Super Tanks++: Recoil Ability
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
	name = "[ST++] Recoil Ability",
	author = ST_AUTHOR,
	description = "The Super Tank gives survivors strong gun recoil.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bRecoil[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sRecoilEffect[ST_MAXTYPES + 1][4], g_sRecoilEffect2[ST_MAXTYPES + 1][4], g_sRecoilMessage[ST_MAXTYPES + 1][3], g_sRecoilMessage2[ST_MAXTYPES + 1][3];

float g_flRecoilChance[ST_MAXTYPES + 1], g_flRecoilChance2[ST_MAXTYPES + 1], g_flRecoilDuration[ST_MAXTYPES + 1], g_flRecoilDuration2[ST_MAXTYPES + 1], g_flRecoilRange[ST_MAXTYPES + 1], g_flRecoilRange2[ST_MAXTYPES + 1], g_flRecoilRangeChance[ST_MAXTYPES + 1], g_flRecoilRangeChance2[ST_MAXTYPES + 1];

int g_iRecoilAbility[ST_MAXTYPES + 1], g_iRecoilAbility2[ST_MAXTYPES + 1], g_iRecoilHit[ST_MAXTYPES + 1], g_iRecoilHit2[ST_MAXTYPES + 1], g_iRecoilHitMode[ST_MAXTYPES + 1], g_iRecoilHitMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Recoil Ability\" only supports Left 4 Dead 1 & 2.");

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

	g_bRecoil[client] = false;
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

		if ((iRecoilHitMode(attacker) == 0 || iRecoilHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRecoilHit(victim, attacker, flRecoilChance(attacker), iRecoilHit(attacker), "1", "1");
			}
		}
		else if ((iRecoilHitMode(victim) == 0 || iRecoilHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vRecoilHit(attacker, victim, flRecoilChance(victim), iRecoilHit(victim), "1", "2");
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

				g_iRecoilAbility[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Ability Enabled", 0);
				g_iRecoilAbility[iIndex] = iClamp(g_iRecoilAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Recoil Ability/Ability Effect", g_sRecoilEffect[iIndex], sizeof(g_sRecoilEffect[]), "123");
				kvSuperTanks.GetString("Recoil Ability/Ability Message", g_sRecoilMessage[iIndex], sizeof(g_sRecoilMessage[]), "0");
				g_flRecoilChance[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Chance", 33.3);
				g_flRecoilChance[iIndex] = flClamp(g_flRecoilChance[iIndex], 0.1, 100.0);
				g_flRecoilDuration[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Duration", 5.0);
				g_flRecoilDuration[iIndex] = flClamp(g_flRecoilDuration[iIndex], 0.1, 9999999999.0);
				g_iRecoilHit[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Hit", 0);
				g_iRecoilHit[iIndex] = iClamp(g_iRecoilHit[iIndex], 0, 1);
				g_iRecoilHitMode[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Hit Mode", 0);
				g_iRecoilHitMode[iIndex] = iClamp(g_iRecoilHitMode[iIndex], 0, 2);
				g_flRecoilRange[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Range", 150.0);
				g_flRecoilRange[iIndex] = flClamp(g_flRecoilRange[iIndex], 1.0, 9999999999.0);
				g_flRecoilRangeChance[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Range Chance", 15.0);
				g_flRecoilRangeChance[iIndex] = flClamp(g_flRecoilRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iRecoilAbility2[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Ability Enabled", g_iRecoilAbility[iIndex]);
				g_iRecoilAbility2[iIndex] = iClamp(g_iRecoilAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Recoil Ability/Ability Effect", g_sRecoilEffect2[iIndex], sizeof(g_sRecoilEffect2[]), g_sRecoilEffect[iIndex]);
				kvSuperTanks.GetString("Recoil Ability/Ability Message", g_sRecoilMessage2[iIndex], sizeof(g_sRecoilMessage2[]), g_sRecoilMessage[iIndex]);
				g_flRecoilChance2[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Chance", g_flRecoilChance[iIndex]);
				g_flRecoilChance2[iIndex] = flClamp(g_flRecoilChance2[iIndex], 0.1, 100.0);
				g_flRecoilDuration2[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Duration", g_flRecoilDuration[iIndex]);
				g_flRecoilDuration2[iIndex] = flClamp(g_flRecoilDuration2[iIndex], 0.1, 9999999999.0);
				g_iRecoilHit2[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Hit", g_iRecoilHit[iIndex]);
				g_iRecoilHit2[iIndex] = iClamp(g_iRecoilHit2[iIndex], 0, 1);
				g_iRecoilHitMode2[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Hit Mode", g_iRecoilHitMode[iIndex]);
				g_iRecoilHitMode2[iIndex] = iClamp(g_iRecoilHitMode2[iIndex], 0, 2);
				g_flRecoilRange2[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Range", g_flRecoilRange[iIndex]);
				g_flRecoilRange2[iIndex] = flClamp(g_flRecoilRange2[iIndex], 1.0, 9999999999.0);
				g_flRecoilRangeChance2[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Range Chance", g_flRecoilRangeChance[iIndex]);
				g_flRecoilRangeChance2[iIndex] = flClamp(g_flRecoilRangeChance2[iIndex], 0.1, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vRemoveRecoil();
	vReset();
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveRecoil();
		}
	}
	else if (StrEqual(name, "weapon_fire"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
		if (bIsSurvivor(iSurvivor) && bIsGunWeapon(iSurvivor) && g_bRecoil[iSurvivor])
		{
			float flRecoil[3];
			flRecoil[0] = GetRandomFloat(-20.0, -80.0), flRecoil[1] = GetRandomFloat(-25.0, 25.0), flRecoil[2] = GetRandomFloat(-25.0, 25.0);
			SetEntPropVector(iSurvivor, Prop_Send, "m_vecPunchAngle", flRecoil);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flRecoilRange = !g_bTankConfig[ST_TankType(tank)] ? g_flRecoilRange[ST_TankType(tank)] : g_flRecoilRange2[ST_TankType(tank)],
			flRecoilRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flRecoilRangeChance[ST_TankType(tank)] : g_flRecoilRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flRecoilRange)
				{
					vRecoilHit(iSurvivor, tank, flRecoilRangeChance, iRecoilAbility(tank), "2", "3");
				}
			}
		}
	}
}

public void ST_BossStage(int tank)
{
	if (iRecoilAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveRecoil();
	}
}

static void vRecoilHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bRecoil[survivor])
	{
		g_bRecoil[survivor] = true;

		float flRecoilDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flRecoilDuration[ST_TankType(tank)] : g_flRecoilDuration2[ST_TankType(tank)];
		DataPack dpStopRecoil;
		CreateDataTimer(flRecoilDuration, tTimerStopRecoil, dpStopRecoil, TIMER_FLAG_NO_MAPCHANGE);
		dpStopRecoil.WriteCell(GetClientUserId(survivor));
		dpStopRecoil.WriteCell(GetClientUserId(tank));
		dpStopRecoil.WriteString(message);

		char sRecoilEffect[4];
		sRecoilEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sRecoilEffect[ST_TankType(tank)] : g_sRecoilEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sRecoilEffect, mode);

		char sRecoilMessage[3];
		sRecoilMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sRecoilMessage[ST_TankType(tank)] : g_sRecoilMessage2[ST_TankType(tank)];
		if (StrContains(sRecoilMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Recoil", sTankName, survivor);
		}
	}
}

static void vRemoveRecoil()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bRecoil[iSurvivor])
		{
			g_bRecoil[iSurvivor] = false;
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bRecoil[iPlayer] = false;
		}
	}
}

static float flRecoilChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flRecoilChance[ST_TankType(tank)] : g_flRecoilChance2[ST_TankType(tank)];
}

static int iRecoilAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRecoilAbility[ST_TankType(tank)] : g_iRecoilAbility2[ST_TankType(tank)];
}

static int iRecoilHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRecoilHit[ST_TankType(tank)] : g_iRecoilHit2[ST_TankType(tank)];
}

static int iRecoilHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRecoilHitMode[ST_TankType(tank)] : g_iRecoilHitMode2[ST_TankType(tank)];
}

public Action tTimerStopRecoil(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bRecoil[iSurvivor])
	{
		g_bRecoil[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bRecoil[iSurvivor] = false;

		return Plugin_Stop;
	}

	g_bRecoil[iSurvivor] = false;

	char sRecoilMessage[3], sMessage[3];
	sRecoilMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sRecoilMessage[ST_TankType(iTank)] : g_sRecoilMessage2[ST_TankType(iTank)];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (StrContains(sRecoilMessage, sMessage) != -1)
	{
		PrintToChatAll("%s %t", ST_TAG2, "Recoil2", iSurvivor);
	}

	return Plugin_Continue;
}