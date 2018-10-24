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

// Super Tanks++: Hurt Ability
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
	name = "[ST++] Hurt Ability",
	author = ST_AUTHOR,
	description = "The Super Tank hurts survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bHurt[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sHurtEffect[ST_MAXTYPES + 1][4], g_sHurtEffect2[ST_MAXTYPES + 1][4];

float g_flHurtChance[ST_MAXTYPES + 1], g_flHurtChance2[ST_MAXTYPES + 1], g_flHurtDamage[ST_MAXTYPES + 1], g_flHurtDamage2[ST_MAXTYPES + 1], g_flHurtDuration[ST_MAXTYPES + 1], g_flHurtDuration2[ST_MAXTYPES + 1], g_flHurtInterval[ST_MAXTYPES + 1], g_flHurtInterval2[ST_MAXTYPES + 1], g_flHurtRange[ST_MAXTYPES + 1], g_flHurtRange2[ST_MAXTYPES + 1], g_flHurtRangeChance[ST_MAXTYPES + 1], g_flHurtRangeChance2[ST_MAXTYPES + 1];

int g_iHurtAbility[ST_MAXTYPES + 1], g_iHurtAbility2[ST_MAXTYPES + 1], g_iHurtHit[ST_MAXTYPES + 1], g_iHurtHit2[ST_MAXTYPES + 1], g_iHurtHitMode[ST_MAXTYPES + 1], g_iHurtHitMode2[ST_MAXTYPES + 1], g_iHurtMessage[ST_MAXTYPES + 1], g_iHurtMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Hurt Ability only supports Left 4 Dead 1 & 2.");

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

	g_bHurt[client] = false;
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

		if ((iHurtHitMode(attacker) == 0 || iHurtHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHurtHit(victim, attacker, flHurtChance(attacker), iHurtHit(attacker), 1, "1");
			}
		}
		else if ((iHurtHitMode(victim) == 0 || iHurtHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vHurtHit(attacker, victim, flHurtChance(victim), iHurtHit(victim), 1, "2");
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
		if (kvSuperTanks.JumpToKey(sTankName, true))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iHurtAbility[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Ability Enabled", 0);
				g_iHurtAbility[iIndex] = iClamp(g_iHurtAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Hurt Ability/Ability Effect", g_sHurtEffect[iIndex], sizeof(g_sHurtEffect[]), "123");
				g_iHurtMessage[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Ability Message", 0);
				g_iHurtMessage[iIndex] = iClamp(g_iHurtMessage[iIndex], 0, 3);
				g_flHurtChance[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Chance", 33.3);
				g_flHurtChance[iIndex] = flClamp(g_flHurtChance[iIndex], 0.1, 100.0);
				g_flHurtDamage[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Damage", 5.0);
				g_flHurtDamage[iIndex] = flClamp(g_flHurtDamage[iIndex], 1.0, 9999999999.0);
				g_flHurtDuration[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Duration", 5.0);
				g_flHurtDuration[iIndex] = flClamp(g_flHurtDuration[iIndex], 0.1, 9999999999.0);
				g_iHurtHit[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Hit", 0);
				g_iHurtHit[iIndex] = iClamp(g_iHurtHit[iIndex], 0, 1);
				g_iHurtHitMode[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Hit Mode", 0);
				g_iHurtHitMode[iIndex] = iClamp(g_iHurtHitMode[iIndex], 0, 2);
				g_flHurtInterval[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Interval", 1.0);
				g_flHurtInterval[iIndex] = flClamp(g_flHurtInterval[iIndex], 0.1, 9999999999.0);
				g_flHurtRange[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Range", 150.0);
				g_flHurtRange[iIndex] = flClamp(g_flHurtRange[iIndex], 1.0, 9999999999.0);
				g_flHurtRangeChance[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Range Chance", 15.0);
				g_flHurtRangeChance[iIndex] = flClamp(g_flHurtRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iHurtAbility2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Ability Enabled", g_iHurtAbility[iIndex]);
				g_iHurtAbility2[iIndex] = iClamp(g_iHurtAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Hurt Ability/Ability Effect", g_sHurtEffect2[iIndex], sizeof(g_sHurtEffect2[]), g_sHurtEffect[iIndex]);
				g_iHurtMessage2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Ability Message", g_iHurtMessage[iIndex]);
				g_iHurtMessage2[iIndex] = iClamp(g_iHurtMessage2[iIndex], 0, 3);
				g_flHurtChance2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Chance", g_flHurtChance[iIndex]);
				g_flHurtChance2[iIndex] = flClamp(g_flHurtChance2[iIndex], 0.1, 100.0);
				g_flHurtDamage2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Damage", g_flHurtDamage[iIndex]);
				g_flHurtDamage2[iIndex] = flClamp(g_flHurtDamage2[iIndex], 1.0, 9999999999.0);
				g_flHurtDuration2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Duration", g_flHurtDuration[iIndex]);
				g_flHurtDuration2[iIndex] = flClamp(g_flHurtDuration2[iIndex], 0.1, 9999999999.0);
				g_iHurtHit2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Hit", g_iHurtHit[iIndex]);
				g_iHurtHit2[iIndex] = iClamp(g_iHurtHit2[iIndex], 0, 1);
				g_iHurtHitMode2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Hit Mode", g_iHurtHitMode[iIndex]);
				g_iHurtHitMode2[iIndex] = iClamp(g_iHurtHitMode2[iIndex], 0, 2);
				g_flHurtInterval2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Interval", g_flHurtInterval[iIndex]);
				g_flHurtInterval2[iIndex] = flClamp(g_flHurtInterval2[iIndex], 0.1, 9999999999.0);
				g_flHurtRange2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Range", g_flHurtRange[iIndex]);
				g_flHurtRange2[iIndex] = flClamp(g_flHurtRange2[iIndex], 1.0, 9999999999.0);
				g_flHurtRangeChance2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Range Chance", g_flHurtRangeChance[iIndex]);
				g_flHurtRangeChance2[iIndex] = flClamp(g_flHurtRangeChance2[iIndex], 0.1, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vReset();
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		int iHurtAbility = !g_bTankConfig[ST_TankType(tank)] ? g_iHurtAbility[ST_TankType(tank)] : g_iHurtAbility2[ST_TankType(tank)];

		float flHurtRange = !g_bTankConfig[ST_TankType(tank)] ? g_flHurtRange[ST_TankType(tank)] : g_flHurtRange2[ST_TankType(tank)],
			flHurtRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flHurtRangeChance[ST_TankType(tank)] : g_flHurtRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flHurtRange)
				{
					vHurtHit(iSurvivor, tank, flHurtRangeChance, iHurtAbility, 2, "3");
				}
			}
		}
	}
}

static void vHurtHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bHurt[survivor])
	{
		g_bHurt[survivor] = true;

		float flHurtInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flHurtInterval[ST_TankType(tank)] : g_flHurtInterval2[ST_TankType(tank)];
		DataPack dpHurt;
		CreateDataTimer(flHurtInterval, tTimerHurt, dpHurt, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpHurt.WriteCell(GetClientUserId(survivor));
		dpHurt.WriteCell(GetClientUserId(tank));
		dpHurt.WriteCell(message);
		dpHurt.WriteCell(enabled);
		dpHurt.WriteFloat(GetEngineTime());

		char sHurtEffect[4];
		sHurtEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sHurtEffect[ST_TankType(tank)] : g_sHurtEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sHurtEffect, mode);

		if (iHurtMessage(tank) == message || iHurtMessage(tank) == 3)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Hurt", sTankName, survivor);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bHurt[iPlayer] = false;
		}
	}
}

static void vReset2(int survivor, int tank, int message)
{
	g_bHurt[survivor] = false;

	if (iHurtMessage(tank) == message || iHurtMessage(tank) == 3)
	{
		PrintToChatAll("%s %t", ST_TAG2, "Hurt2", survivor);
	}
}

static float flHurtChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHurtChance[ST_TankType(tank)] : g_flHurtChance2[ST_TankType(tank)];
}

static int iHurtHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHurtHit[ST_TankType(tank)] : g_iHurtHit2[ST_TankType(tank)];
}

static int iHurtHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHurtHitMode[ST_TankType(tank)] : g_iHurtHitMode2[ST_TankType(tank)];
}

static int iHurtMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHurtMessage[ST_TankType(tank)] : g_iHurtMessage2[ST_TankType(tank)];
}

public Action tTimerHurt(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bHurt[iSurvivor])
	{
		g_bHurt[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iHurtChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank, iHurtChat);

		return Plugin_Stop;
	}

	int iHurtAbility = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flHurtDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flHurtDuration[ST_TankType(iTank)] : g_flHurtDuration2[ST_TankType(iTank)];

	if (iHurtAbility == 0 || (flTime + flHurtDuration) < GetEngineTime())
	{
		vReset2(iSurvivor, iTank, iHurtChat);

		return Plugin_Stop;
	}

	float flHurtDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_flHurtDamage[ST_TankType(iTank)] : g_flHurtDamage2[ST_TankType(iTank)];
	SDKHooks_TakeDamage(iSurvivor, iTank, iTank, flHurtDamage);

	return Plugin_Continue;
}