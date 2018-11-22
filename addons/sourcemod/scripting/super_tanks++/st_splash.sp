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

// Super Tanks++: Splash Ability
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
	name = "[ST++] Splash Ability",
	author = ST_AUTHOR,
	description = "The Super Tank constantly deals splash damage to nearby survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bSplash[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flSplashChance[ST_MAXTYPES + 1], g_flSplashChance2[ST_MAXTYPES + 1], g_flSplashDamage[ST_MAXTYPES + 1], g_flSplashDamage2[ST_MAXTYPES + 1], g_flSplashInterval[ST_MAXTYPES + 1], g_flSplashInterval2[ST_MAXTYPES + 1], g_flSplashRange[ST_MAXTYPES + 1], g_flSplashRange2[ST_MAXTYPES + 1];

int g_iSplashAbility[ST_MAXTYPES + 1], g_iSplashAbility2[ST_MAXTYPES + 1], g_iSplashMessage[ST_MAXTYPES + 1], g_iSplashMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Splash Ability\" only supports Left 4 Dead 1 & 2.");

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
	g_bSplash[client] = false;
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

				g_iSplashAbility[iIndex] = kvSuperTanks.GetNum("Splash Ability/Ability Enabled", 0);
				g_iSplashAbility[iIndex] = iClamp(g_iSplashAbility[iIndex], 0, 1);
				g_iSplashMessage[iIndex] = kvSuperTanks.GetNum("Splash Ability/Ability Message", 0);
				g_iSplashMessage[iIndex] = iClamp(g_iSplashMessage[iIndex], 0, 1);
				g_flSplashChance[iIndex] = kvSuperTanks.GetFloat("Splash Ability/Splash Chance", 33.3);
				g_flSplashChance[iIndex] = flClamp(g_flSplashChance[iIndex], 0.0, 100.0);
				g_flSplashDamage[iIndex] = kvSuperTanks.GetFloat("Splash Ability/Splash Damage", 5.0);
				g_flSplashDamage[iIndex] = flClamp(g_flSplashDamage[iIndex], 1.0, 9999999999.0);
				g_flSplashInterval[iIndex] = kvSuperTanks.GetFloat("Splash Ability/Splash Interval", 5.0);
				g_flSplashInterval[iIndex] = flClamp(g_flSplashInterval[iIndex], 0.1, 9999999999.0);
				g_flSplashRange[iIndex] = kvSuperTanks.GetFloat("Splash Ability/Splash Range", 500.0);
				g_flSplashRange[iIndex] = flClamp(g_flSplashRange[iIndex], 1.0, 9999999999.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iSplashAbility2[iIndex] = kvSuperTanks.GetNum("Splash Ability/Ability Enabled", g_iSplashAbility[iIndex]);
				g_iSplashAbility2[iIndex] = iClamp(g_iSplashAbility2[iIndex], 0, 1);
				g_iSplashMessage2[iIndex] = kvSuperTanks.GetNum("Splash Ability/Ability Message", g_iSplashMessage[iIndex]);
				g_iSplashMessage2[iIndex] = iClamp(g_iSplashMessage2[iIndex], 0, 1);
				g_flSplashChance2[iIndex] = kvSuperTanks.GetFloat("Splash Ability/Splash Chance", g_flSplashChance[iIndex]);
				g_flSplashChance2[iIndex] = flClamp(g_flSplashChance2[iIndex], 0.0, 100.0);
				g_flSplashDamage2[iIndex] = kvSuperTanks.GetFloat("Splash Ability/Splash Damage", g_flSplashDamage[iIndex]);
				g_flSplashDamage2[iIndex] = flClamp(g_flSplashDamage2[iIndex], 1.0, 9999999999.0);
				g_flSplashInterval2[iIndex] = kvSuperTanks.GetFloat("Splash Ability/Splash Interval", g_flSplashInterval[iIndex]);
				g_flSplashInterval2[iIndex] = flClamp(g_flSplashInterval2[iIndex], 0.1, 9999999999.0);
				g_flSplashRange2[iIndex] = kvSuperTanks.GetFloat("Splash Ability/Splash Range", g_flSplashRange[iIndex]);
				g_flSplashRange2[iIndex] = flClamp(g_flSplashRange2[iIndex], 1.0, 9999999999.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_EventHandler(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iSplashAbility(iTank) == 1 && GetRandomFloat(0.1, 100.0) <= flSplashChance(iTank) && ST_TankAllowed(iTank, "024") && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			CreateTimer(0.4, tTimerSplash, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public void ST_Ability(int tank)
{
	if (iSplashAbility(tank) == 1 && GetRandomFloat(0.1, 100.0) <= flSplashChance(tank) && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && !g_bSplash[tank])
	{
		g_bSplash[tank] = true;

		float flSplashInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flSplashInterval[ST_TankType(tank)] : g_flSplashInterval2[ST_TankType(tank)];
		CreateTimer(flSplashInterval, tTimerSplash, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

		if (iSplashMessage(tank) == 1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Splash", sTankName);
		}
	}
}

public void ST_ChangeType(int tank)
{
	g_bSplash[tank] = false;
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			g_bSplash[iPlayer] = false;
		}
	}
}

static float flSplashChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flSplashChance[ST_TankType(tank)] : g_flSplashChance2[ST_TankType(tank)];
}

static int iSplashAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iSplashAbility[ST_TankType(tank)] : g_iSplashAbility2[ST_TankType(tank)];
}

static int iSplashMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iSplashMessage[ST_TankType(tank)] : g_iSplashMessage2[ST_TankType(tank)];
}

public Action tTimerSplash(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || iSplashAbility(iTank) == 0 || !g_bSplash[iTank])
	{
		g_bSplash[iTank] = false;

		if (iSplashMessage(iTank) == 1)
		{
			char sTankName[33];
			ST_TankName(iTank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Splash2", sTankName);
		}

		return Plugin_Stop;
	}

	float flSplashRange = !g_bTankConfig[ST_TankType(iTank)] ? g_flSplashRange[ST_TankType(iTank)] : g_flSplashRange2[ST_TankType(iTank)],
		flTankPos[3];

	GetClientAbsOrigin(iTank, flTankPos);

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "234"))
		{
			float flSurvivorPos[3];
			GetClientAbsOrigin(iSurvivor, flSurvivorPos);

			float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
			if (flDistance <= flSplashRange)
			{
				float flSplashDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_flSplashDamage[ST_TankType(iTank)] : g_flSplashDamage2[ST_TankType(iTank)];
				vDamageEntity(iSurvivor, iTank, flSplashDamage, "65536");
			}
		}
	}

	return Plugin_Continue;
}