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

// Super Tanks++: Cloud Ability
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
	name = "[ST++] Cloud Ability",
	author = ST_AUTHOR,
	description = "The Super Tank constantly emits clouds of smoke that damage survivors caught in them.",
	version = ST_VERSION,
	url = ST_URL
};

#define PARTICLE_SMOKE "smoker_smokecloud"

bool g_bCloneInstalled, g_bCloud[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flCloudChance[ST_MAXTYPES + 1], g_flCloudChance2[ST_MAXTYPES + 1], g_flCloudDamage[ST_MAXTYPES + 1], g_flCloudDamage2[ST_MAXTYPES + 1];

int g_iCloudAbility[ST_MAXTYPES + 1], g_iCloudAbility2[ST_MAXTYPES + 1], g_iCloudMessage[ST_MAXTYPES + 1], g_iCloudMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Cloud Ability\" only supports Left 4 Dead 1 & 2.");

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
	vPrecacheParticle(PARTICLE_SMOKE);

	vReset();
}

public void OnClientPutInServer(int client)
{
	g_bCloud[client] = false;
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
		Format(sTankName, sizeof(sTankName), "Tank #%i", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iCloudAbility[iIndex] = kvSuperTanks.GetNum("Cloud Ability/Ability Enabled", 0);
				g_iCloudAbility[iIndex] = iClamp(g_iCloudAbility[iIndex], 0, 1);
				g_iCloudMessage[iIndex] = kvSuperTanks.GetNum("Cloud Ability/Ability Message", 0);
				g_iCloudMessage[iIndex] = iClamp(g_iCloudMessage[iIndex], 0, 1);
				g_flCloudChance[iIndex] = kvSuperTanks.GetFloat("Cloud Ability/Cloud Chance", 33.3);
				g_flCloudChance[iIndex] = flClamp(g_flCloudChance[iIndex], 0.0, 100.0);
				g_flCloudDamage[iIndex] = kvSuperTanks.GetFloat("Cloud Ability/Cloud Damage", 5.0);
				g_flCloudDamage[iIndex] = flClamp(g_flCloudDamage[iIndex], 1.0, 9999999999.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iCloudAbility2[iIndex] = kvSuperTanks.GetNum("Cloud Ability/Ability Enabled", g_iCloudAbility[iIndex]);
				g_iCloudAbility2[iIndex] = iClamp(g_iCloudAbility2[iIndex], 0, 1);
				g_iCloudMessage2[iIndex] = kvSuperTanks.GetNum("Cloud Ability/Ability Message", g_iCloudMessage[iIndex]);
				g_iCloudMessage2[iIndex] = iClamp(g_iCloudMessage2[iIndex], 0, 1);
				g_flCloudChance2[iIndex] = kvSuperTanks.GetFloat("Cloud Ability/Cloud Chance", g_flCloudChance[iIndex]);
				g_flCloudChance2[iIndex] = flClamp(g_flCloudChance2[iIndex], 0.0, 100.0);
				g_flCloudDamage2[iIndex] = kvSuperTanks.GetFloat("Cloud Ability/Cloud Damage", g_flCloudDamage[iIndex]);
				g_flCloudDamage2[iIndex] = flClamp(g_flCloudDamage2[iIndex], 1.0, 9999999999.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_Ability(int tank)
{
	if (iCloudAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && !g_bCloud[tank])
	{
		g_bCloud[tank] = true;

		CreateTimer(1.5, tTimerCloud, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

		if (iCloudMessage(tank) == 1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Cloud", sTankName);
		}
	}
}

public void ST_ChangeType(int tank)
{
	g_bCloud[tank] = false;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			g_bCloud[iPlayer] = false;
		}
	}
}

static int iCloudAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iCloudAbility[ST_TankType(tank)] : g_iCloudAbility2[ST_TankType(tank)];
}

static int iCloudMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iCloudMessage[ST_TankType(tank)] : g_iCloudMessage2[ST_TankType(tank)];
}

public Action tTimerCloud(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);

	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || iCloudAbility(iTank) == 0 || !g_bCloud[iTank])
	{
		g_bCloud[iTank] = false;

		if (iCloudMessage(iTank) == 1)
		{
			char sTankName[33];
			ST_TankName(iTank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Cloud2", sTankName);
		}

		return Plugin_Stop;
	}

	float flCloudChance = !g_bTankConfig[ST_TankType(iTank)] ? g_flCloudChance[ST_TankType(iTank)] : g_flCloudChance2[ST_TankType(iTank)];
	if (GetRandomFloat(0.1, 100.0) > flCloudChance)
	{
		return Plugin_Continue;
	}

	vAttachParticle(iTank, PARTICLE_SMOKE, 1.5);

	float flTankPos[3];
	GetClientAbsOrigin(iTank, flTankPos);

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "234"))
		{
			float flSurvivorPos[3];
			GetClientAbsOrigin(iSurvivor, flSurvivorPos);

			float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
			if (flDistance <= 200.0)
			{
				float flCloudDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_flCloudDamage[ST_TankType(iTank)] : g_flCloudDamage2[ST_TankType(iTank)];
				vDamageEntity(iSurvivor, iTank, flCloudDamage, "65536");
			}
		}
	}

	return Plugin_Continue;
}