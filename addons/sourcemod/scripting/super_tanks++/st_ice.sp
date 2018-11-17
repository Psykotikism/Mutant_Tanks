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

// Super Tanks++: Ice Ability
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
	name = "[ST++] Ice Ability",
	author = ST_AUTHOR,
	description = "The Super Tank freezes survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define SOUND_BULLET "physics/glass/glass_impact_bullet4.wav"

bool g_bCloneInstalled, g_bIce[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sIceEffect[ST_MAXTYPES + 1][4], g_sIceEffect2[ST_MAXTYPES + 1][4], g_sIceMessage[ST_MAXTYPES + 1][3], g_sIceMessage2[ST_MAXTYPES + 1][3];

float g_flIceChance[ST_MAXTYPES + 1], g_flIceChance2[ST_MAXTYPES + 1], g_flIceDuration[ST_MAXTYPES + 1], g_flIceDuration2[ST_MAXTYPES + 1], g_flIceRange[ST_MAXTYPES + 1], g_flIceRange2[ST_MAXTYPES + 1], g_flIceRangeChance[ST_MAXTYPES + 1], g_flIceRangeChance2[ST_MAXTYPES + 1];

int g_iIceAbility[ST_MAXTYPES + 1], g_iIceAbility2[ST_MAXTYPES + 1], g_iIceHit[ST_MAXTYPES + 1], g_iIceHit2[ST_MAXTYPES + 1], g_iIceHitMode[ST_MAXTYPES + 1], g_iIceHitMode2[ST_MAXTYPES + 1], g_iIceOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Ice Ability\" only supports Left 4 Dead 1 & 2.");

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
	PrecacheSound(SOUND_BULLET, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	g_bIce[client] = false;
	g_iIceOwner[client] = 0;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iIceHitMode(attacker) == 0 || iIceHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vIceHit(victim, attacker, flIceChance(attacker), iIceHit(attacker), "1", "1");
			}
		}
		else if ((iIceHitMode(victim) == 0 || iIceHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vIceHit(attacker, victim, flIceChance(victim), iIceHit(victim), "1", "2");
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

				g_iIceAbility[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ability Enabled", 0);
				g_iIceAbility[iIndex] = iClamp(g_iIceAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Ice Ability/Ability Effect", g_sIceEffect[iIndex], sizeof(g_sIceEffect[]), "0");
				kvSuperTanks.GetString("Ice Ability/Ability Message", g_sIceMessage[iIndex], sizeof(g_sIceMessage[]), "0");
				g_flIceChance[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Chance", 33.3);
				g_flIceChance[iIndex] = flClamp(g_flIceChance[iIndex], 0.0, 100.0);
				g_flIceDuration[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Duration", 5.0);
				g_flIceDuration[iIndex] = flClamp(g_flIceDuration[iIndex], 0.1, 9999999999.0);
				g_iIceHit[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit", 0);
				g_iIceHit[iIndex] = iClamp(g_iIceHit[iIndex], 0, 1);
				g_iIceHitMode[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit Mode", 0);
				g_iIceHitMode[iIndex] = iClamp(g_iIceHitMode[iIndex], 0, 2);
				g_flIceRange[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Range", 150.0);
				g_flIceRange[iIndex] = flClamp(g_flIceRange[iIndex], 1.0, 9999999999.0);
				g_flIceRangeChance[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Range Chance", 15.0);
				g_flIceRangeChance[iIndex] = flClamp(g_flIceRangeChance[iIndex], 0.0, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iIceAbility2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ability Enabled", g_iIceAbility[iIndex]);
				g_iIceAbility2[iIndex] = iClamp(g_iIceAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Ice Ability/Ability Effect", g_sIceEffect2[iIndex], sizeof(g_sIceEffect2[]), g_sIceEffect[iIndex]);
				kvSuperTanks.GetString("Ice Ability/Ability Message", g_sIceMessage2[iIndex], sizeof(g_sIceMessage2[]), g_sIceMessage[iIndex]);
				g_flIceChance2[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Chance", g_flIceChance[iIndex]);
				g_flIceChance2[iIndex] = flClamp(g_flIceChance2[iIndex], 0.0, 100.0);
				g_flIceDuration2[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Duration", g_flIceDuration[iIndex]);
				g_flIceDuration2[iIndex] = flClamp(g_flIceDuration2[iIndex], 0.1, 9999999999.0);
				g_iIceHit2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit", g_iIceHit[iIndex]);
				g_iIceHit2[iIndex] = iClamp(g_iIceHit2[iIndex], 0, 1);
				g_iIceHitMode2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit Mode", g_iIceHitMode[iIndex]);
				g_iIceHitMode2[iIndex] = iClamp(g_iIceHitMode2[iIndex], 0, 2);
				g_flIceRange2[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Range", g_flIceRange[iIndex]);
				g_flIceRange2[iIndex] = flClamp(g_flIceRange2[iIndex], 1.0, 9999999999.0);
				g_flIceRangeChance2[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Range Chance", g_flIceRangeChance[iIndex]);
				g_flIceRangeChance2[iIndex] = flClamp(g_flIceRangeChance2[iIndex], 0.0, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, "234"))
		{
			vRemoveIce(iTank);
		}
	}
}

public void ST_EventHandler(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank, "024") && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveIce(iTank);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		float flIceRange = !g_bTankConfig[ST_TankType(tank)] ? g_flIceRange[ST_TankType(tank)] : g_flIceRange2[ST_TankType(tank)],
			flIceRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flIceRangeChance[ST_TankType(tank)] : g_flIceRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, "234"))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flIceRange)
				{
					vIceHit(iSurvivor, tank, flIceRangeChance, iIceAbility(tank), "2", "3");
				}
			}
		}
	}
}

public void ST_ChangeType(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveIce(tank);
	}
}

static void vIceHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bIce[survivor])
	{
		g_bIce[survivor] = true;
		g_iIceOwner[survivor] = tank;

		float flPos[3];
		GetClientEyePosition(survivor, flPos);

		if (GetEntityMoveType(survivor) != MOVETYPE_NONE)
		{
			SetEntityMoveType(survivor, MOVETYPE_NONE);
		}

		SetEntityRenderColor(survivor, 0, 130, 255, 190);
		EmitAmbientSound(SOUND_BULLET, flPos, survivor, SNDLEVEL_RAIDSIREN);

		float flIceDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flIceDuration[ST_TankType(tank)] : g_flIceDuration2[ST_TankType(tank)];
		DataPack dpStopIce;
		CreateDataTimer(flIceDuration, tTimerStopIce, dpStopIce, TIMER_FLAG_NO_MAPCHANGE);
		dpStopIce.WriteCell(GetClientUserId(survivor));
		dpStopIce.WriteCell(GetClientUserId(tank));
		dpStopIce.WriteString(message);

		char sIceEffect[4];
		sIceEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sIceEffect[ST_TankType(tank)] : g_sIceEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sIceEffect, mode);

		char sIceMessage[3];
		sIceMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sIceMessage[ST_TankType(tank)] : g_sIceMessage2[ST_TankType(tank)];
		if (StrContains(sIceMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Ice", sTankName, survivor);
		}
	}
}

static void vRemoveIce(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "234") && g_bIce[iSurvivor] && g_iIceOwner[iSurvivor] == tank)
		{
			vStopIce(iSurvivor);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			g_bIce[iPlayer] = false;
			g_iIceOwner[iPlayer] = 0;
		}
	}
}

static void vStopIce(int survivor)
{
	g_bIce[survivor] = false;
	g_iIceOwner[survivor] = 0;

	float flPos[3];
	GetClientEyePosition(survivor, flPos);

	if (GetEntityMoveType(survivor) == MOVETYPE_NONE)
	{
		SetEntityMoveType(survivor, MOVETYPE_WALK);
	}

	TeleportEntity(survivor, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
	SetEntityRenderColor(survivor, 255, 255, 255, 255);
	EmitAmbientSound(SOUND_BULLET, flPos, survivor, SNDLEVEL_RAIDSIREN);
}

static float flIceChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flIceChance[ST_TankType(tank)] : g_flIceChance2[ST_TankType(tank)];
}

static int iIceAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iIceAbility[ST_TankType(tank)] : g_iIceAbility2[ST_TankType(tank)];
}

static int iIceHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iIceHit[ST_TankType(tank)] : g_iIceHit2[ST_TankType(tank)];
}

static int iIceHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iIceHitMode[ST_TankType(tank)] : g_iIceHitMode2[ST_TankType(tank)];
}

public Action tTimerStopIce(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bIce[iSurvivor] = false;
		g_iIceOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bIce[iSurvivor])
	{
		vStopIce(iSurvivor);

		return Plugin_Stop;
	}

	vStopIce(iSurvivor);

	char sIceMessage[3], sMessage[3];
	sIceMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sIceMessage[ST_TankType(iTank)] : g_sIceMessage2[ST_TankType(iTank)];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (StrContains(sIceMessage, sMessage) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Ice2", iSurvivor);
	}

	return Plugin_Continue;
}