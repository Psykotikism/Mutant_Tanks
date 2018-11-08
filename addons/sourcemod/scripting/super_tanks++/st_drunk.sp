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

// Super Tanks++: Drunk Ability
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
	name = "[ST++] Drunk Ability",
	author = ST_AUTHOR,
	description = "The Super Tank makes survivors drunk.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bDrunk[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sDrunkEffect[ST_MAXTYPES + 1][4], g_sDrunkEffect2[ST_MAXTYPES + 1][4], g_sDrunkMessage[ST_MAXTYPES + 1][3], g_sDrunkMessage2[ST_MAXTYPES + 1][3];

float g_flDrunkChance[ST_MAXTYPES + 1], g_flDrunkChance2[ST_MAXTYPES + 1], g_flDrunkDuration[ST_MAXTYPES + 1], g_flDrunkDuration2[ST_MAXTYPES + 1], g_flDrunkRange[ST_MAXTYPES + 1], g_flDrunkRange2[ST_MAXTYPES + 1], g_flDrunkRangeChance[ST_MAXTYPES + 1], g_flDrunkRangeChance2[ST_MAXTYPES + 1], g_flDrunkSpeedInterval[ST_MAXTYPES + 1], g_flDrunkSpeedInterval2[ST_MAXTYPES + 1], g_flDrunkTurnInterval[ST_MAXTYPES + 1], g_flDrunkTurnInterval2[ST_MAXTYPES + 1];

int g_iDrunkAbility[ST_MAXTYPES + 1], g_iDrunkAbility2[ST_MAXTYPES + 1], g_iDrunkHit[ST_MAXTYPES + 1], g_iDrunkHit2[ST_MAXTYPES + 1], g_iDrunkHitMode[ST_MAXTYPES + 1], g_iDrunkHitMode2[ST_MAXTYPES + 1], g_iDrunkOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Drunk Ability\" only supports Left 4 Dead 1 & 2.");

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

	g_bDrunk[client] = false;
	g_iDrunkOwner[client] = 0;
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

		if ((iDrunkHitMode(attacker) == 0 || iDrunkHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vDrunkHit(victim, attacker, flDrunkChance(attacker), iDrunkHit(attacker), "1", "1");
			}
		}
		else if ((iDrunkHitMode(victim) == 0 || iDrunkHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vDrunkHit(attacker, victim, flDrunkChance(victim), iDrunkHit(victim), "1", "2");
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

				g_iDrunkAbility[iIndex] = kvSuperTanks.GetNum("Drunk Ability/Ability Enabled", 0);
				g_iDrunkAbility[iIndex] = iClamp(g_iDrunkAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Drunk Ability/Ability Effect", g_sDrunkEffect[iIndex], sizeof(g_sDrunkEffect[]), "0");
				kvSuperTanks.GetString("Drunk Ability/Ability Message", g_sDrunkMessage[iIndex], sizeof(g_sDrunkMessage[]), "0");
				g_flDrunkChance[iIndex] = kvSuperTanks.GetFloat("Drunk Ability/Drunk Chance", 33.3);
				g_flDrunkChance[iIndex] = flClamp(g_flDrunkChance[iIndex], 0.0, 100.0);
				g_flDrunkDuration[iIndex] = kvSuperTanks.GetFloat("Drunk Ability/Drunk Duration", 5.0);
				g_flDrunkDuration[iIndex] = flClamp(g_flDrunkDuration[iIndex], 0.1, 9999999999.0);
				g_iDrunkHit[iIndex] = kvSuperTanks.GetNum("Drunk Ability/Drunk Hit", 0);
				g_iDrunkHit[iIndex] = iClamp(g_iDrunkHit[iIndex], 0, 1);
				g_iDrunkHitMode[iIndex] = kvSuperTanks.GetNum("Drunk Ability/Drunk Hit Mode", 0);
				g_iDrunkHitMode[iIndex] = iClamp(g_iDrunkHitMode[iIndex], 0, 2);
				g_flDrunkRange[iIndex] = kvSuperTanks.GetFloat("Drunk Ability/Drunk Range", 150.0);
				g_flDrunkRange[iIndex] = flClamp(g_flDrunkRange[iIndex], 1.0, 9999999999.0);
				g_flDrunkRangeChance[iIndex] = kvSuperTanks.GetFloat("Drunk Ability/Drunk Range Chance", 15.0);
				g_flDrunkRangeChance[iIndex] = flClamp(g_flDrunkRangeChance[iIndex], 0.0, 100.0);
				g_flDrunkSpeedInterval[iIndex] = kvSuperTanks.GetFloat("Drunk Ability/Drunk Speed Interval", 1.5);
				g_flDrunkSpeedInterval[iIndex] = flClamp(g_flDrunkSpeedInterval[iIndex], 0.1, 9999999999.0);
				g_flDrunkTurnInterval[iIndex] = kvSuperTanks.GetFloat("Drunk Ability/Drunk Turn Interval", 0.5);
				g_flDrunkTurnInterval[iIndex] = flClamp(g_flDrunkTurnInterval[iIndex], 0.1, 9999999999.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iDrunkAbility2[iIndex] = kvSuperTanks.GetNum("Drunk Ability/Ability Enabled", g_iDrunkAbility[iIndex]);
				g_iDrunkAbility2[iIndex] = iClamp(g_iDrunkAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Drunk Ability/Ability Effect", g_sDrunkEffect2[iIndex], sizeof(g_sDrunkEffect2[]), g_sDrunkEffect[iIndex]);
				kvSuperTanks.GetString("Drunk Ability/Ability Message", g_sDrunkMessage2[iIndex], sizeof(g_sDrunkMessage2[]), g_sDrunkMessage[iIndex]);
				g_flDrunkChance2[iIndex] = kvSuperTanks.GetFloat("Drunk Ability/Drunk Chance", g_flDrunkChance[iIndex]);
				g_flDrunkChance2[iIndex] = flClamp(g_flDrunkChance2[iIndex], 0.0, 100.0);
				g_flDrunkDuration2[iIndex] = kvSuperTanks.GetFloat("Drunk Ability/Drunk Duration", g_flDrunkDuration[iIndex]);
				g_flDrunkDuration2[iIndex] = flClamp(g_flDrunkDuration2[iIndex], 0.1, 9999999999.0);
				g_iDrunkHit2[iIndex] = kvSuperTanks.GetNum("Drunk Ability/Drunk Hit", g_iDrunkHit[iIndex]);
				g_iDrunkHit2[iIndex] = iClamp(g_iDrunkHit2[iIndex], 0, 1);
				g_iDrunkHitMode2[iIndex] = kvSuperTanks.GetNum("Drunk Ability/Drunk Hit Mode", g_iDrunkHitMode[iIndex]);
				g_iDrunkHitMode2[iIndex] = iClamp(g_iDrunkHitMode2[iIndex], 0, 2);
				g_flDrunkRange2[iIndex] = kvSuperTanks.GetFloat("Drunk Ability/Drunk Range", g_flDrunkRange[iIndex]);
				g_flDrunkRange2[iIndex] = flClamp(g_flDrunkRange2[iIndex], 1.0, 9999999999.0);
				g_flDrunkRangeChance2[iIndex] = kvSuperTanks.GetFloat("Drunk Ability/Drunk Range Chance", g_flDrunkRangeChance[iIndex]);
				g_flDrunkRangeChance2[iIndex] = flClamp(g_flDrunkRangeChance2[iIndex], 0.0, 100.0);
				g_flDrunkSpeedInterval2[iIndex] = kvSuperTanks.GetFloat("Drunk Ability/Drunk Speed Interval", g_flDrunkSpeedInterval[iIndex]);
				g_flDrunkSpeedInterval2[iIndex] = flClamp(g_flDrunkSpeedInterval2[iIndex], 0.1, 9999999999.0);
				g_flDrunkTurnInterval2[iIndex] = kvSuperTanks.GetFloat("Drunk Ability/Drunk Turn Interval", g_flDrunkTurnInterval[iIndex]);
				g_flDrunkTurnInterval2[iIndex] = flClamp(g_flDrunkTurnInterval2[iIndex], 0.1, 9999999999.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bDrunk[iSurvivor])
		{
			SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flDrunkRange = !g_bTankConfig[ST_TankType(tank)] ? g_flDrunkRange[ST_TankType(tank)] : g_flDrunkRange2[ST_TankType(tank)],
			flDrunkRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flDrunkRangeChance[ST_TankType(tank)] : g_flDrunkRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flDrunkRange)
				{
					vDrunkHit(iSurvivor, tank, flDrunkRangeChance, iDrunkAbility(tank), "2", "3");
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
			if (bIsSurvivor(iSurvivor) && g_bDrunk[iSurvivor] && g_iDrunkOwner[iSurvivor] == tank)
			{
				g_bDrunk[iSurvivor] = false;
				g_iDrunkOwner[iSurvivor] = 0;
			}
		}
	}
}

static void vDrunkHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bDrunk[survivor])
	{
		g_bDrunk[survivor] = true;
		g_iDrunkOwner[survivor] = tank;

		float flDrunkSpeedInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flDrunkSpeedInterval[ST_TankType(tank)] : g_flDrunkSpeedInterval2[ST_TankType(tank)];
		DataPack dpDrunkSpeed;
		CreateDataTimer(flDrunkSpeedInterval, tTimerDrunkSpeed, dpDrunkSpeed, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDrunkSpeed.WriteCell(GetClientUserId(survivor));
		dpDrunkSpeed.WriteCell(GetClientUserId(tank));
		dpDrunkSpeed.WriteCell(enabled);
		dpDrunkSpeed.WriteFloat(GetEngineTime());

		float flDrunkTurnInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flDrunkTurnInterval[ST_TankType(tank)] : g_flDrunkTurnInterval2[ST_TankType(tank)];
		DataPack dpDrunkTurn;
		CreateDataTimer(flDrunkTurnInterval, tTimerDrunkTurn, dpDrunkTurn, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDrunkTurn.WriteCell(GetClientUserId(survivor));
		dpDrunkTurn.WriteCell(GetClientUserId(tank));
		dpDrunkTurn.WriteString(message);
		dpDrunkTurn.WriteCell(enabled);
		dpDrunkTurn.WriteFloat(GetEngineTime());

		char sDrunkEffect[4];
		sDrunkEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sDrunkEffect[ST_TankType(tank)] : g_sDrunkEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sDrunkEffect, mode);

		char sDrunkMessage[3];
		sDrunkMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sDrunkMessage[ST_TankType(tank)] : g_sDrunkMessage2[ST_TankType(tank)];
		if (StrContains(sDrunkMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Drunk", sTankName, survivor);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bDrunk[iPlayer] = false;
			g_iDrunkOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bDrunk[survivor] = false;
	g_iDrunkOwner[survivor] = 0;

	char sDrunkMessage[3];
	sDrunkMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sDrunkMessage[ST_TankType(tank)] : g_sDrunkMessage2[ST_TankType(tank)];
	if (StrContains(sDrunkMessage, message) != -1)
	{
		PrintToChatAll("%s %t", ST_TAG2, "Drunk2", survivor);
	}
}

static float flDrunkChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flDrunkChance[ST_TankType(tank)] : g_flDrunkChance2[ST_TankType(tank)];
}

static float flDrunkDuration(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flDrunkDuration[ST_TankType(tank)] : g_flDrunkDuration2[ST_TankType(tank)];
}

static int iDrunkAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iDrunkAbility[ST_TankType(tank)] : g_iDrunkAbility2[ST_TankType(tank)];
}

static int iDrunkHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iDrunkHit[ST_TankType(tank)] : g_iDrunkHit2[ST_TankType(tank)];
}

static int iDrunkHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iDrunkHitMode[ST_TankType(tank)] : g_iDrunkHitMode2[ST_TankType(tank)];
}

public Action tTimerDrunkSpeed(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bDrunk[iSurvivor])
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		return Plugin_Stop;
	}

	int iDrunkEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();

	if (iDrunkEnabled == 0 || (flTime + flDrunkDuration(iTank) < GetEngineTime()))
	{
		return Plugin_Stop;
	}

	SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", GetRandomFloat(1.5, 3.0));

	CreateTimer(GetRandomFloat(1.0, 3.0), tTimerStopDrunkSpeed, GetClientUserId(iSurvivor), TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Continue;
}

public Action tTimerDrunkTurn(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bDrunk[iSurvivor] = false;
		g_iDrunkOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bDrunk[iSurvivor])
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iDrunkEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat();

	if (iDrunkEnabled == 0 || (flTime + flDrunkDuration(iTank) < GetEngineTime()))
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	float flAngle = GetRandomFloat(-360.0, 360.0), flPunchAngles[3], flEyeAngles[3];
	GetClientEyeAngles(iSurvivor, flEyeAngles);

	flEyeAngles[1] -= flAngle;
	flPunchAngles[1] += flAngle;

	TeleportEntity(iSurvivor, NULL_VECTOR, flEyeAngles, NULL_VECTOR);
	SetEntPropVector(iSurvivor, Prop_Send, "m_vecPunchAngle", flPunchAngles);

	return Plugin_Continue;
}

public Action tTimerStopDrunkSpeed(Handle timer, int userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (!bIsSurvivor(iSurvivor))
	{
		return Plugin_Stop;
	}

	SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);

	return Plugin_Continue;
}