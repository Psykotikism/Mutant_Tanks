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

// Super Tanks++: Bury Ability
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
	name = "[ST++] Bury Ability",
	author = ST_AUTHOR,
	description = "The Super Tank buries survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bBury[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sBuryEffect[ST_MAXTYPES + 1][4], g_sBuryEffect2[ST_MAXTYPES + 1][4];

float g_flBuryChance[ST_MAXTYPES + 1], g_flBuryChance2[ST_MAXTYPES + 1], g_flBuryDuration[ST_MAXTYPES + 1], g_flBuryDuration2[ST_MAXTYPES + 1], g_flBuryHeight[ST_MAXTYPES + 1], g_flBuryHeight2[ST_MAXTYPES + 1], g_flBuryRange[ST_MAXTYPES + 1], g_flBuryRange2[ST_MAXTYPES + 1], g_flBuryRangeChance[ST_MAXTYPES + 1], g_flBuryRangeChance2[ST_MAXTYPES + 1];

int g_iBuryAbility[ST_MAXTYPES + 1], g_iBuryAbility2[ST_MAXTYPES + 1], g_iBuryHit[ST_MAXTYPES + 1], g_iBuryHit2[ST_MAXTYPES + 1], g_iBuryHitMode[ST_MAXTYPES + 1], g_iBuryHitMode2[ST_MAXTYPES + 1], g_iBuryMessage[ST_MAXTYPES + 1], g_iBuryMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Bury Ability only supports Left 4 Dead 1 & 2.");

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

	g_bBury[client] = false;
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

		if ((iBuryHitMode(attacker) == 0 || iBuryHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vBuryHit(victim, attacker, flBuryChance(attacker), iBuryHit(attacker), 1, "1");
			}
		}
		else if ((iBuryHitMode(victim) == 0 || iBuryHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vBuryHit(attacker, victim, flBuryChance(victim), iBuryHit(victim), 1, "2");
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

				g_iBuryAbility[iIndex] = kvSuperTanks.GetNum("Bury Ability/Ability Enabled", 0);
				g_iBuryAbility[iIndex] = iClamp(g_iBuryAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Bury Ability/Ability Effect", g_sBuryEffect[iIndex], sizeof(g_sBuryEffect[]), "123");
				g_iBuryMessage[iIndex] = kvSuperTanks.GetNum("Bury Ability/Ability Message", 0);
				g_iBuryMessage[iIndex] = iClamp(g_iBuryMessage[iIndex], 0, 3);
				g_flBuryChance[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Chance", 33.3);
				g_flBuryChance[iIndex] = flClamp(g_flBuryChance[iIndex], 0.1, 100.0);
				g_flBuryDuration[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Duration", 5.0);
				g_flBuryDuration[iIndex] = flClamp(g_flBuryDuration[iIndex], 0.1, 9999999999.0);
				g_flBuryHeight[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Height", 50.0);
				g_flBuryHeight[iIndex] = flClamp(g_flBuryHeight[iIndex], 0.1, 9999999999.0);
				g_iBuryHit[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Hit", 0);
				g_iBuryHit[iIndex] = iClamp(g_iBuryHit[iIndex], 0, 1);
				g_iBuryHitMode[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Hit Mode", 0);
				g_iBuryHitMode[iIndex] = iClamp(g_iBuryHitMode[iIndex], 0, 2);
				g_flBuryRange[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Range", 150.0);
				g_flBuryRange[iIndex] = flClamp(g_flBuryRange[iIndex], 1.0, 9999999999.0);
				g_flBuryRangeChance[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Range Chance", 15.0);
				g_flBuryRangeChance[iIndex] = flClamp(g_flBuryRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iBuryAbility2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Ability Enabled", g_iBuryAbility[iIndex]);
				g_iBuryAbility2[iIndex] = iClamp(g_iBuryAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Bury Ability/Ability Effect", g_sBuryEffect2[iIndex], sizeof(g_sBuryEffect2[]), g_sBuryEffect[iIndex]);
				g_iBuryMessage2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Ability Message", g_iBuryMessage[iIndex]);
				g_iBuryMessage2[iIndex] = iClamp(g_iBuryMessage2[iIndex], 0, 3);
				g_flBuryChance2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Chance", g_flBuryChance[iIndex]);
				g_flBuryChance2[iIndex] = flClamp(g_flBuryChance2[iIndex], 0.1, 100.0);
				g_flBuryDuration2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Duration", g_flBuryDuration[iIndex]);
				g_flBuryDuration2[iIndex] = flClamp(g_flBuryDuration2[iIndex], 0.1, 9999999999.0);
				g_flBuryHeight2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Height", g_flBuryHeight[iIndex]);
				g_flBuryHeight2[iIndex] = flClamp(g_flBuryHeight2[iIndex], 0.1, 9999999999.0);
				g_iBuryHit2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Hit", g_iBuryHit[iIndex]);
				g_iBuryHit2[iIndex] = iClamp(g_iBuryHit2[iIndex], 0, 1);
				g_iBuryHitMode2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Hit Mode", g_iBuryHitMode[iIndex]);
				g_iBuryHitMode2[iIndex] = iClamp(g_iBuryHitMode2[iIndex], 0, 2);
				g_flBuryRange2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Range", g_flBuryRange[iIndex]);
				g_flBuryRange2[iIndex] = flClamp(g_flBuryRange2[iIndex], 1.0, 9999999999.0);
				g_flBuryRangeChance2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Range Chance", g_flBuryRangeChance[iIndex]);
				g_flBuryRangeChance2[iIndex] = flClamp(g_flBuryRangeChance2[iIndex], 0.1, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			vRemoveBury(iPlayer);
		}
	}

	vReset();
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveBury(iTank);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flBuryRange = !g_bTankConfig[ST_TankType(tank)] ? g_flBuryRange[ST_TankType(tank)] : g_flBuryRange2[ST_TankType(tank)],
			flBuryRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flBuryRangeChance[ST_TankType(tank)] : g_flBuryRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flBuryRange)
				{
					vBuryHit(iSurvivor, tank, flBuryRangeChance, iBuryAbility(tank), 2, "3");
				}
			}
		}
	}
}

public void ST_BossStage(int tank)
{
	if (iBuryAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveBury(tank);
	}
}

static void vBuryHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && bIsEntityGrounded(survivor) && !g_bBury[survivor])
	{
		g_bBury[survivor] = true;

		float flOrigin[3], flPos[3],
			flBuryDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flBuryDuration[ST_TankType(tank)] : g_flBuryDuration2[ST_TankType(tank)];
		GetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flOrigin);
		flOrigin[2] = flOrigin[2] - flBuryHeight(tank);
		SetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flOrigin);

		if (!bIsPlayerIncapacitated(survivor))
		{
			SetEntProp(survivor, Prop_Send, "m_isIncapacitated", 1);
			SetEntProp(survivor, Prop_Data, "m_takedamage", 0, 1);
		}

		GetClientEyePosition(survivor, flPos);

		if (GetEntityMoveType(survivor) != MOVETYPE_NONE)
		{
			SetEntityMoveType(survivor, MOVETYPE_NONE);
		}

		DataPack dpStopBury;
		CreateDataTimer(flBuryDuration, tTimerStopBury, dpStopBury, TIMER_FLAG_NO_MAPCHANGE);
		dpStopBury.WriteCell(GetClientUserId(survivor));
		dpStopBury.WriteCell(GetClientUserId(tank));
		dpStopBury.WriteCell(message);

		char sBuryEffect[4];
		sBuryEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sBuryEffect[ST_TankType(tank)] : g_sBuryEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sBuryEffect, mode);

		if (iBuryMessage(tank) == message || iBuryMessage(tank) == 3)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Bury", sTankName, survivor, flOrigin);
		}
	}
}

static void vRemoveBury(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bBury[iSurvivor])
		{
			DataPack dpStopBury;
			CreateDataTimer(0.1, tTimerStopBury, dpStopBury, TIMER_FLAG_NO_MAPCHANGE);
			dpStopBury.WriteCell(GetClientUserId(iSurvivor));
			dpStopBury.WriteCell(GetClientUserId(tank));
			dpStopBury.WriteCell(0);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bBury[iPlayer] = false;
		}
	}
}

static void vStopBury(int survivor, int tank)
{
	g_bBury[survivor] = false;

	float flOrigin[3], flCurrentOrigin[3];
	GetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flOrigin);
	flOrigin[2] = flOrigin[2] + flBuryHeight(tank);
	SetEntPropVector(survivor, Prop_Send, "m_vecOrigin", flOrigin);

	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSurvivor(iPlayer) && !g_bBury[iPlayer] && iPlayer != survivor)
		{
			GetClientAbsOrigin(iPlayer, flCurrentOrigin);
			TeleportEntity(survivor, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);
			break;
		}
	}

	if (bIsPlayerIncapacitated(survivor))
	{
		SetEntProp(survivor, Prop_Data, "m_takedamage", 2, 1);
	}

	if (GetEntityMoveType(survivor) == MOVETYPE_NONE)
	{
		SetEntityMoveType(survivor, MOVETYPE_WALK);
	}
}

static float flBuryChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flBuryChance[ST_TankType(tank)] : g_flBuryChance2[ST_TankType(tank)];
}

static float flBuryHeight(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flBuryHeight[ST_TankType(tank)] : g_flBuryHeight2[ST_TankType(tank)];
}

static int iBuryAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBuryAbility[ST_TankType(tank)] : g_iBuryAbility2[ST_TankType(tank)];
}

static int iBuryHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBuryHit[ST_TankType(tank)] : g_iBuryHit2[ST_TankType(tank)];
}

static int iBuryHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBuryHitMode[ST_TankType(tank)] : g_iBuryHitMode2[ST_TankType(tank)];
}

static int iBuryMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBuryMessage[ST_TankType(tank)] : g_iBuryMessage2[ST_TankType(tank)];
}

public Action tTimerStopBury(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bBury[iSurvivor])
	{
		g_bBury[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iBuryChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vStopBury(iSurvivor, iTank);

		return Plugin_Stop;
	}

	vStopBury(iSurvivor, iTank);

	if (iBuryMessage(iTank) == iBuryChat || iBuryMessage(iTank) == 3)
	{
		PrintToChatAll("%s %t", ST_TAG2, "Bury2", iSurvivor);
	}

	return Plugin_Continue;
}