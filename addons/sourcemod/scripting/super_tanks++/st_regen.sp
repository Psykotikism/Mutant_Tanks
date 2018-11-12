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

// Super Tanks++: Regen Ability
#include <sourcemod>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Regen Ability",
	author = ST_AUTHOR,
	description = "The Super Tank regenerates health.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bRegen[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flRegenChance[ST_MAXTYPES + 1], g_flRegenChance2[ST_MAXTYPES + 1], g_flRegenInterval[ST_MAXTYPES + 1], g_flRegenInterval2[ST_MAXTYPES + 1];

int g_iRegenAbility[ST_MAXTYPES + 1], g_iRegenAbility2[ST_MAXTYPES + 1], g_iRegenHealth[ST_MAXTYPES + 1], g_iRegenHealth2[ST_MAXTYPES + 1], g_iRegenLimit[ST_MAXTYPES + 1], g_iRegenLimit2[ST_MAXTYPES + 1], g_iRegenMessage[ST_MAXTYPES + 1], g_iRegenMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Regen Ability\" only supports Left 4 Dead 1 & 2.");

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
	g_bRegen[client] = false;
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

				g_iRegenAbility[iIndex] = kvSuperTanks.GetNum("Regen Ability/Ability Enabled", 0);
				g_iRegenAbility[iIndex] = iClamp(g_iRegenAbility[iIndex], 0, 1);
				g_iRegenMessage[iIndex] = kvSuperTanks.GetNum("Regen Ability/Ability Message", 0);
				g_iRegenMessage[iIndex] = iClamp(g_iRegenMessage[iIndex], 0, 1);
				g_flRegenChance[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Regen Chance", 33.3);
				g_flRegenChance[iIndex] = flClamp(g_flRegenChance[iIndex], 0.0, 100.0);
				g_iRegenHealth[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Health", 1);
				g_iRegenHealth[iIndex] = iClamp(g_iRegenHealth[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				g_flRegenInterval[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Regen Interval", 1.0);
				g_flRegenInterval[iIndex] = flClamp(g_flRegenInterval[iIndex], 0.1, 9999999999.0);
				g_iRegenLimit[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Limit", ST_MAXHEALTH);
				g_iRegenLimit[iIndex] = iClamp(g_iRegenLimit[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iRegenAbility2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Ability Enabled", g_iRegenAbility[iIndex]);
				g_iRegenAbility2[iIndex] = iClamp(g_iRegenAbility2[iIndex], 0, 1);
				g_iRegenMessage2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Ability Message", g_iRegenMessage[iIndex]);
				g_iRegenMessage2[iIndex] = iClamp(g_iRegenMessage2[iIndex], 0, 1);
				g_flRegenChance2[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Regen Chance", g_flRegenChance[iIndex]);
				g_flRegenChance2[iIndex] = flClamp(g_flRegenChance2[iIndex], 0.0, 100.0);
				g_iRegenHealth2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Health", g_iRegenHealth[iIndex]);
				g_iRegenHealth2[iIndex] = iClamp(g_iRegenHealth2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				g_flRegenInterval2[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Regen Duration", g_flRegenInterval[iIndex]);
				g_flRegenInterval2[iIndex] = flClamp(g_flRegenInterval2[iIndex], 0.1, 9999999999.0);
				g_iRegenLimit2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Limit", g_iRegenLimit[iIndex]);
				g_iRegenLimit2[iIndex] = iClamp(g_iRegenLimit2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_Ability(int tank)
{
	if (iRegenAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && !g_bRegen[tank])
	{
		g_bRegen[tank] = true;

		float flRegenInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flRegenInterval[ST_TankType(tank)] : g_flRegenInterval2[ST_TankType(tank)];
		CreateTimer(flRegenInterval, tTimerRegen, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

		if (iRegenMessage(tank) == 1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Regen", sTankName, flRegenInterval);
		}
	}
}

public void ST_ChangeType(int tank)
{
	g_bRegen[tank] = false;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			g_bRegen[iPlayer] = false;
		}
	}
}

static int iRegenAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRegenAbility[ST_TankType(tank)] : g_iRegenAbility2[ST_TankType(tank)];
}

static int iRegenMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRegenMessage[ST_TankType(tank)] : g_iRegenMessage2[ST_TankType(tank)];
}

public Action tTimerRegen(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || iRegenAbility(iTank) == 0 || !g_bRegen[iTank])
	{
		g_bRegen[iTank] = false;

		if (iRegenMessage(iTank) == 1)
		{
			char sTankName[33];
			ST_TankName(iTank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Regen2", sTankName);
		}

		return Plugin_Stop;
	}

	float flRegenChance = !g_bTankConfig[ST_TankType(iTank)] ? g_flRegenChance[ST_TankType(iTank)] : g_flRegenChance2[ST_TankType(iTank)];
	if (GetRandomFloat(0.1, 100.0) > flRegenChance)
	{
		return Plugin_Continue;
	}

	int iHealth = GetClientHealth(iTank),
		iRegenHealth = !g_bTankConfig[ST_TankType(iTank)] ? (iHealth + g_iRegenHealth[ST_TankType(iTank)]) : (iHealth + g_iRegenHealth2[ST_TankType(iTank)]),
		iRegenLimit = !g_bTankConfig[ST_TankType(iTank)] ? g_iRegenLimit[ST_TankType(iTank)] : g_iRegenLimit2[ST_TankType(iTank)],
		iExtraHealth = (iRegenHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iRegenHealth,
		iExtraHealth2 = (iRegenHealth < iHealth) ? 1 : iRegenHealth,
		iRealHealth = (iRegenHealth >= 0) ? iExtraHealth : iExtraHealth2,
		iLimitHealth = (iRealHealth > iRegenLimit) ? iRegenLimit : iRealHealth,
		iLimitHealth2 = (iRealHealth < iRegenLimit) ? iRegenLimit : iRealHealth,
		iFinalHealth = (iRegenLimit >= 0) ? iLimitHealth : iLimitHealth2;

	SetEntityHealth(iTank, iFinalHealth);

	return Plugin_Continue;
}