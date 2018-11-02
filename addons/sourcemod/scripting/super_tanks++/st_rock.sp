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

// Super Tanks++: Rock Ability
#include <sourcemod>
#include <sdktools>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Rock Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates rock showers.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bRock[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sRockRadius[ST_MAXTYPES + 1][11], g_sRockRadius2[ST_MAXTYPES + 1][11];

float g_flRockChance[ST_MAXTYPES + 1], g_flRockChance2[ST_MAXTYPES + 1], g_flRockDuration[ST_MAXTYPES + 1], g_flRockDuration2[ST_MAXTYPES + 1];

int g_iRockAbility[ST_MAXTYPES + 1], g_iRockAbility2[ST_MAXTYPES + 1], g_iRockDamage[ST_MAXTYPES + 1], g_iRockDamage2[ST_MAXTYPES + 1], g_iRockMessage[ST_MAXTYPES + 1], g_iRockMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Rock Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

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
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	g_bRock[client] = false;
}

public void OnMapEnd()
{
	vReset();
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

				g_iRockAbility[iIndex] = kvSuperTanks.GetNum("Rock Ability/Ability Enabled", 0);
				g_iRockAbility[iIndex] = iClamp(g_iRockAbility[iIndex], 0, 1);
				g_iRockMessage[iIndex] = kvSuperTanks.GetNum("Rock Ability/Ability Message", 0);
				g_iRockMessage[iIndex] = iClamp(g_iRockMessage[iIndex], 0, 1);
				g_flRockChance[iIndex] = kvSuperTanks.GetFloat("Rock Ability/Rock Chance", 33.3);
				g_flRockChance[iIndex] = flClamp(g_flRockChance[iIndex], 0.0, 100.0);
				g_iRockDamage[iIndex] = kvSuperTanks.GetNum("Rock Ability/Rock Damage", 5);
				g_iRockDamage[iIndex] = iClamp(g_iRockDamage[iIndex], 1, 9999999999);
				g_flRockDuration[iIndex] = kvSuperTanks.GetFloat("Rock Ability/Rock Duration", 5.0);
				g_flRockDuration[iIndex] = flClamp(g_flRockDuration[iIndex], 0.1, 9999999999.0);
				kvSuperTanks.GetString("Rock Ability/Rock Radius", g_sRockRadius[iIndex], sizeof(g_sRockRadius[]), "-1.25,1.25");
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iRockAbility2[iIndex] = kvSuperTanks.GetNum("Rock Ability/Ability Enabled", g_iRockAbility[iIndex]);
				g_iRockAbility2[iIndex] = iClamp(g_iRockAbility2[iIndex], 0, 1);
				g_iRockMessage2[iIndex] = kvSuperTanks.GetNum("Rock Ability/Ability Message", g_iRockMessage[iIndex]);
				g_iRockMessage2[iIndex] = iClamp(g_iRockMessage2[iIndex], 0, 1);
				g_flRockChance2[iIndex] = kvSuperTanks.GetFloat("Rock Ability/Rock Chance", g_flRockChance[iIndex]);
				g_flRockChance2[iIndex] = flClamp(g_flRockChance2[iIndex], 0.0, 100.0);
				g_iRockDamage2[iIndex] = kvSuperTanks.GetNum("Rock Ability/Rock Damage", g_iRockDamage[iIndex]);
				g_iRockDamage2[iIndex] = iClamp(g_iRockDamage2[iIndex], 1, 9999999999);
				g_flRockDuration2[iIndex] = kvSuperTanks.GetFloat("Rock Ability/Rock Duration", g_flRockDuration[iIndex]);
				g_flRockDuration2[iIndex] = flClamp(g_flRockDuration2[iIndex], 0.1, 9999999999.0);
				kvSuperTanks.GetString("Rock Ability/Rock Radius", g_sRockRadius2[iIndex], sizeof(g_sRockRadius2[]), g_sRockRadius[iIndex]);
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
	float flRockChance = !g_bTankConfig[ST_TankType(tank)] ? g_flRockChance[ST_TankType(tank)] : g_flRockChance2[ST_TankType(tank)];
	if (iRockAbility(tank) == 1 && GetRandomFloat(0.1, 100.0) <= flRockChance && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank) && !g_bRock[tank])
	{
		int iRock = CreateEntityByName("env_rock_launcher");
		if (!bIsValidEntity(iRock))
		{
			return;
		}

		g_bRock[tank] = true;

		float flPos[3];
		GetClientEyePosition(tank, flPos);
		flPos[2] += 20.0;

		char sDamage[11];
		int iRockDamage = !g_bTankConfig[ST_TankType(tank)] ? g_iRockDamage[ST_TankType(tank)] : g_iRockDamage2[ST_TankType(tank)];
		IntToString(iRockDamage, sDamage, sizeof(sDamage));
		DispatchSpawn(iRock);
		DispatchKeyValue(iRock, "rockdamageoverride", sDamage);

		DataPack dpRockUpdate;
		CreateDataTimer(0.2, tTimerRockUpdate, dpRockUpdate, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpRockUpdate.WriteCell(EntIndexToEntRef(iRock));
		dpRockUpdate.WriteCell(GetClientUserId(tank));
		dpRockUpdate.WriteFloat(flPos[0]);
		dpRockUpdate.WriteFloat(flPos[1]);
		dpRockUpdate.WriteFloat(flPos[2]);
		dpRockUpdate.WriteFloat(GetEngineTime());

		if (iRockMessage(tank) == 1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Rock", sTankName);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bRock[iPlayer] = false;
		}
	}
}

static void vReset2(int tank, int rock)
{
	g_bRock[tank] = false;

	RemoveEntity(rock);

	if (iRockMessage(tank) == 1)
	{
		char sTankName[33];
		ST_TankName(tank, sTankName);
		PrintToChatAll("%s %t", ST_TAG2, "Rock2", sTankName);
	}
}

static int iRockAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRockAbility[ST_TankType(tank)] : g_iRockAbility2[ST_TankType(tank)];
}

static int iRockMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRockMessage[ST_TankType(tank)] : g_iRockMessage2[ST_TankType(tank)];
}

public Action tTimerRockUpdate(Handle timer, DataPack pack)
{
	pack.Reset();

	int iRock = EntRefToEntIndex(pack.ReadCell()), iTank = GetClientOfUserId(pack.ReadCell());
	if (iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		g_bRock[iTank] = false;

		return Plugin_Stop;
	}

	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bRock[iTank])
	{
		vReset2(iTank, iRock);

		return Plugin_Stop;
	}

	float flPos[3];
	flPos[0] = pack.ReadFloat();
	flPos[1] = pack.ReadFloat();
	flPos[2] = pack.ReadFloat();

	float flTime = pack.ReadFloat(),
		flRockDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flRockDuration[ST_TankType(iTank)] : g_flRockDuration2[ST_TankType(iTank)];

	if (iRockAbility(iTank) == 0 || (flTime + flRockDuration) < GetEngineTime())
	{
		vReset2(iTank, iRock);

		return Plugin_Stop;
	}

	char sRadius[2][6], sRockRadius[11];
	sRockRadius = !g_bTankConfig[ST_TankType(iTank)] ? g_sRockRadius[ST_TankType(iTank)] : g_sRockRadius2[ST_TankType(iTank)];
	ReplaceString(sRockRadius, sizeof(sRockRadius), " ", "");
	ExplodeString(sRockRadius, ",", sRadius, sizeof(sRadius), sizeof(sRadius[]));

	float flMin = (sRadius[0][0] != '\0') ? StringToFloat(sRadius[0]) : -5.0,
		flMax = (sRadius[1][0] != '\0') ? StringToFloat(sRadius[1]) : 5.0;
	flMin = flClamp(flMin, -5.0, 0.0);
	flMax = flClamp(flMax, 0.0, 5.0);

	float flAngles[3], flHitPos[3];
	flAngles[0] = GetRandomFloat(-1.0, 1.0);
	flAngles[1] = GetRandomFloat(-1.0, 1.0);
	flAngles[2] = 2.0;
	GetVectorAngles(flAngles, flAngles);
	iGetRayHitPos(flPos, flAngles, flHitPos, iTank, true, 2);

	float flDistance = GetVectorDistance(flPos, flHitPos), flVector[3];
	if (flDistance > 800.0)
	{
		flDistance = 800.0;
	}

	MakeVectorFromPoints(flPos, flHitPos, flVector);
	NormalizeVector(flVector, flVector);
	ScaleVector(flVector, flDistance - 40.0);
	AddVectors(flPos, flVector, flHitPos);

	if (flDistance > 300.0)
	{ 
		float flAngles2[3];
		flAngles2[0] = GetRandomFloat(flMin, flMax);
		flAngles2[1] = GetRandomFloat(flMin, flMax);
		flAngles2[2] = -2.0;
		GetVectorAngles(flAngles2, flAngles2);

		TeleportEntity(iRock, flHitPos, flAngles2, NULL_VECTOR);
		AcceptEntityInput(iRock, "LaunchRock");
	}

	return Plugin_Continue;
}