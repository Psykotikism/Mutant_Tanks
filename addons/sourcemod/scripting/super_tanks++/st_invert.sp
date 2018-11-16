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

// Super Tanks++: Invert Ability
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
	name = "[ST++] Invert Ability",
	author = ST_AUTHOR,
	description = "The Super Tank inverts the survivors' movement keys.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bInvert[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sInvertEffect[ST_MAXTYPES + 1][4], g_sInvertEffect2[ST_MAXTYPES + 1][4], g_sInvertMessage[ST_MAXTYPES + 1][3], g_sInvertMessage2[ST_MAXTYPES + 1][3];

float g_flInvertChance[ST_MAXTYPES + 1], g_flInvertChance2[ST_MAXTYPES + 1], g_flInvertDuration[ST_MAXTYPES + 1], g_flInvertDuration2[ST_MAXTYPES + 1], g_flInvertRange[ST_MAXTYPES + 1], g_flInvertRange2[ST_MAXTYPES + 1], g_flInvertRangeChance[ST_MAXTYPES + 1], g_flInvertRangeChance2[ST_MAXTYPES + 1];

int g_iInvertAbility[ST_MAXTYPES + 1], g_iInvertAbility2[ST_MAXTYPES + 1], g_iInvertHit[ST_MAXTYPES + 1], g_iInvertHit2[ST_MAXTYPES + 1], g_iInvertHitMode[ST_MAXTYPES + 1], g_iInvertHitMode2[ST_MAXTYPES + 1], g_iInvertOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Invert Ability\" only supports Left 4 Dead 1 & 2.");

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
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	g_bInvert[client] = false;
	g_iInvertOwner[client] = 0;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!ST_PluginEnabled())
	{
		return Plugin_Continue;
	}

	if (g_bInvert[client])
	{
		vel[0] = -vel[0];
		if (buttons & IN_FORWARD)
		{
			buttons &= ~IN_FORWARD;
			buttons |= IN_BACK;
		}
		else if (buttons & IN_BACK)
		{
			buttons &= ~IN_BACK;
			buttons |= IN_FORWARD;
		}

		vel[1] = -vel[1];
		if (buttons & IN_MOVELEFT)
		{
			buttons &= ~IN_MOVELEFT;
			buttons |= IN_MOVERIGHT;
		}
		else if (buttons & IN_MOVERIGHT)
		{
			buttons &= ~IN_MOVERIGHT;
			buttons |= IN_MOVELEFT;
		}

		return Plugin_Changed;
	}

	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iInvertHitMode(attacker) == 0 || iInvertHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vInvertHit(victim, attacker, flInvertChance(attacker), iInvertHit(attacker), "1", "1");
			}
		}
		else if ((iInvertHitMode(victim) == 0 || iInvertHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vInvertHit(attacker, victim, flInvertChance(victim), iInvertHit(victim), "1", "2");
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

				g_iInvertAbility[iIndex] = kvSuperTanks.GetNum("Invert Ability/Ability Enabled", 0);
				g_iInvertAbility[iIndex] = iClamp(g_iInvertAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Invert Ability/Ability Effect", g_sInvertEffect[iIndex], sizeof(g_sInvertEffect[]), "0");
				kvSuperTanks.GetString("Invert Ability/Ability Message", g_sInvertMessage[iIndex], sizeof(g_sInvertMessage[]), "0");
				g_flInvertChance[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Chance", 33.3);
				g_flInvertChance[iIndex] = flClamp(g_flInvertChance[iIndex], 0.0, 100.0);
				g_flInvertDuration[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Duration", 5.0);
				g_flInvertDuration[iIndex] = flClamp(g_flInvertDuration[iIndex], 0.1, 9999999999.0);
				g_iInvertHit[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Hit", 0);
				g_iInvertHit[iIndex] = iClamp(g_iInvertHit[iIndex], 0, 1);
				g_iInvertHitMode[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Hit Mode", 0);
				g_iInvertHitMode[iIndex] = iClamp(g_iInvertHitMode[iIndex], 0, 2);
				g_flInvertRange[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Range", 150.0);
				g_flInvertRange[iIndex] = flClamp(g_flInvertRange[iIndex], 1.0, 9999999999.0);
				g_flInvertRangeChance[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Range Chance", 15.0);
				g_flInvertRangeChance[iIndex] = flClamp(g_flInvertRangeChance[iIndex], 0.0, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iInvertAbility2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Ability Enabled", g_iInvertAbility[iIndex]);
				g_iInvertAbility2[iIndex] = iClamp(g_iInvertAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Invert Ability/Ability Effect", g_sInvertEffect2[iIndex], sizeof(g_sInvertEffect2[]), g_sInvertEffect[iIndex]);
				kvSuperTanks.GetString("Invert Ability/Ability Message", g_sInvertMessage2[iIndex], sizeof(g_sInvertMessage2[]), g_sInvertMessage[iIndex]);
				g_flInvertChance2[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Chance", g_flInvertChance[iIndex]);
				g_flInvertChance2[iIndex] = flClamp(g_flInvertChance2[iIndex], 0.0, 100.0);
				g_flInvertDuration2[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Duration", g_flInvertDuration[iIndex]);
				g_flInvertDuration2[iIndex] = flClamp(g_flInvertDuration2[iIndex], 0.1, 9999999999.0);
				g_iInvertHit2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Hit", g_iInvertHit[iIndex]);
				g_iInvertHit2[iIndex] = iClamp(g_iInvertHit2[iIndex], 0, 1);
				g_iInvertHitMode2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Hit Mode", g_iInvertHitMode[iIndex]);
				g_iInvertHitMode2[iIndex] = iClamp(g_iInvertHitMode2[iIndex], 0, 2);
				g_flInvertRange2[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Range", g_flInvertRange[iIndex]);
				g_flInvertRange2[iIndex] = flClamp(g_flInvertRange2[iIndex], 1.0, 9999999999.0);
				g_flInvertRangeChance2[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Range Chance", g_flInvertRangeChance[iIndex]);
				g_flInvertRangeChance2[iIndex] = flClamp(g_flInvertRangeChance2[iIndex], 0.0, 100.0);
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
		if (ST_TankAllowed(iTank, "024") && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveInvert(iTank);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		float flInvertRange = !g_bTankConfig[ST_TankType(tank)] ? g_flInvertRange[ST_TankType(tank)] : g_flInvertRange2[ST_TankType(tank)],
			flInvertRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flInvertRangeChance[ST_TankType(tank)] : g_flInvertRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, "234"))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flInvertRange)
				{
					vInvertHit(iSurvivor, tank, flInvertRangeChance, iInvertAbility(tank), "2", "3");
				}
			}
		}
	}
}

public void ST_ChangeType(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveInvert(tank);
	}
}

static void vInvertHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bInvert[survivor])
	{
		g_bInvert[survivor] = true;
		g_iInvertOwner[survivor] = tank;

		float flInvertDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flInvertDuration[ST_TankType(tank)] : g_flInvertDuration2[ST_TankType(tank)];
		DataPack dpStopInvert;
		CreateDataTimer(flInvertDuration, tTimerStopInvert, dpStopInvert, TIMER_FLAG_NO_MAPCHANGE);
		dpStopInvert.WriteCell(GetClientUserId(survivor));
		dpStopInvert.WriteCell(GetClientUserId(tank));
		dpStopInvert.WriteString(message);

		char sInvertEffect[4];
		sInvertEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sInvertEffect[ST_TankType(tank)] : g_sInvertEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sInvertEffect, mode);

		char sInvertMessage[3];
		sInvertMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sInvertMessage[ST_TankType(tank)] : g_sInvertMessage2[ST_TankType(tank)];
		if (StrContains(sInvertMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Invert", sTankName, survivor);
		}
	}
}

static void vRemoveInvert(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "24") && g_bInvert[iSurvivor] && g_iInvertOwner[iSurvivor] == tank)
		{
			g_bInvert[iSurvivor] = false;
			g_iInvertOwner[iSurvivor] = 0;
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			g_bInvert[iPlayer] = false;
			g_iInvertOwner[iPlayer] = 0;
		}
	}
}

static float flInvertChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flInvertChance[ST_TankType(tank)] : g_flInvertChance2[ST_TankType(tank)];
}

static int iInvertAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iInvertAbility[ST_TankType(tank)] : g_iInvertAbility2[ST_TankType(tank)];
}

static int iInvertHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iInvertHit[ST_TankType(tank)] : g_iInvertHit2[ST_TankType(tank)];
}

static int iInvertHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iInvertHitMode[ST_TankType(tank)] : g_iInvertHitMode2[ST_TankType(tank)];
}

public Action tTimerStopInvert(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bInvert[iSurvivor])
	{
		g_bInvert[iSurvivor] = false;
		g_iInvertOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bInvert[iSurvivor] = false;
		g_iInvertOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	g_bInvert[iSurvivor] = false;
	g_iInvertOwner[iSurvivor] = 0;

	char sInvertMessage[3], sMessage[3];
	sInvertMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sInvertMessage[ST_TankType(iTank)] : g_sInvertMessage2[ST_TankType(iTank)];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (StrContains(sInvertMessage, sMessage) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Invert2", iSurvivor);
	}

	return Plugin_Continue;
}