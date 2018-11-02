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

// Super Tanks++: Jump Ability
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
	name = "[ST++] Jump Ability",
	author = ST_AUTHOR,
	description = "The Super Tank jumps periodically and makes survivors jump uncontrollably.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bJump[MAXPLAYERS + 1], g_bJump2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sJumpEffect[ST_MAXTYPES + 1][4], g_sJumpEffect2[ST_MAXTYPES + 1][4], g_sJumpMessage[ST_MAXTYPES + 1][4], g_sJumpMessage2[ST_MAXTYPES + 1][4];

float g_flJumpChance[ST_MAXTYPES + 1], g_flJumpChance2[ST_MAXTYPES + 1], g_flJumpDuration[ST_MAXTYPES + 1], g_flJumpDuration2[ST_MAXTYPES + 1], g_flJumpHeight[ST_MAXTYPES + 1], g_flJumpHeight2[ST_MAXTYPES + 1], g_flJumpInterval[ST_MAXTYPES + 1], g_flJumpInterval2[ST_MAXTYPES + 1], g_flJumpRange[ST_MAXTYPES + 1], g_flJumpRange2[ST_MAXTYPES + 1], g_flJumpRangeChance[ST_MAXTYPES + 1], g_flJumpRangeChance2[ST_MAXTYPES + 1], g_flJumpSporadicChance[ST_MAXTYPES + 1], g_flJumpSporadicChance2[ST_MAXTYPES + 1], g_flJumpSporadicHeight[ST_MAXTYPES + 1], g_flJumpSporadicHeight2[ST_MAXTYPES + 1];

int g_iJumpAbility[ST_MAXTYPES + 1], g_iJumpAbility2[ST_MAXTYPES + 1], g_iJumpHit[ST_MAXTYPES + 1], g_iJumpHit2[ST_MAXTYPES + 1], g_iJumpHitMode[ST_MAXTYPES + 1], g_iJumpHitMode2[ST_MAXTYPES + 1], g_iJumpMode[ST_MAXTYPES + 1], g_iJumpMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Jump Ability\" only supports Left 4 Dead 1 & 2.");

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
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	g_bJump[client] = false;
	g_bJump2[client] = false;
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

		if ((iJumpHitMode(attacker) == 0 || iJumpHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vJumpHit(victim, attacker, flJumpChance(attacker), iJumpHit(attacker), "1", "1");
			}
		}
		else if ((iJumpHitMode(victim) == 0 || iJumpHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vJumpHit(attacker, victim, flJumpChance(victim), iJumpHit(victim), "1", "2");
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

				g_iJumpAbility[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Enabled", 0);
				g_iJumpAbility[iIndex] = iClamp(g_iJumpAbility[iIndex], 0, 3);
				kvSuperTanks.GetString("Jump Ability/Ability Effect", g_sJumpEffect[iIndex], sizeof(g_sJumpEffect[]), "0");
				kvSuperTanks.GetString("Jump Ability/Ability Message", g_sJumpMessage[iIndex], sizeof(g_sJumpMessage[]), "0");
				g_flJumpChance[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Chance", 33.3);
				g_flJumpChance[iIndex] = flClamp(g_flJumpChance[iIndex], 0.0, 100.0);
				g_flJumpDuration[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Duration", 5.0);
				g_flJumpDuration[iIndex] = flClamp(g_flJumpDuration[iIndex], 0.1, 9999999999.0);
				g_flJumpHeight[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Height", 300.0);
				g_flJumpHeight[iIndex] = flClamp(g_flJumpHeight[iIndex], 0.1, 9999999999.0);
				g_iJumpHit[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Hit", 0);
				g_iJumpHit[iIndex] = iClamp(g_iJumpHit[iIndex], 0, 1);
				g_iJumpHitMode[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Hit Mode", 0);
				g_iJumpHitMode[iIndex] = iClamp(g_iJumpHitMode[iIndex], 0, 2);
				g_flJumpInterval[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Interval", 1.0);
				g_flJumpInterval[iIndex] = flClamp(g_flJumpInterval[iIndex], 0.1, 9999999999.0);
				g_iJumpMode[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Mode", 0);
				g_iJumpMode[iIndex] = iClamp(g_iJumpMode[iIndex], 0, 1);
				g_flJumpRange[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Range", 150.0);
				g_flJumpRange[iIndex] = flClamp(g_flJumpRange[iIndex], 1.0, 9999999999.0);
				g_flJumpRangeChance[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Range Chance", 15.0);
				g_flJumpRangeChance[iIndex] = flClamp(g_flJumpRangeChance[iIndex], 0.0, 100.0);
				g_flJumpSporadicChance[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Sporadic Chance", 33.3);
				g_flJumpSporadicChance[iIndex] = flClamp(g_flJumpSporadicChance[iIndex], 0.0, 100.0);
				g_flJumpSporadicHeight[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Sporadic Height", 750.0);
				g_flJumpSporadicHeight[iIndex] = flClamp(g_flJumpSporadicHeight[iIndex], 0.1, 9999999999.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iJumpAbility2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Enabled", g_iJumpAbility[iIndex]);
				g_iJumpAbility2[iIndex] = iClamp(g_iJumpAbility2[iIndex], 0, 3);
				kvSuperTanks.GetString("Jump Ability/Ability Effect", g_sJumpEffect2[iIndex], sizeof(g_sJumpEffect2[]), g_sJumpEffect[iIndex]);
				kvSuperTanks.GetString("Jump Ability/Ability Message", g_sJumpMessage2[iIndex], sizeof(g_sJumpMessage2[]), g_sJumpMessage[iIndex]);
				g_flJumpChance2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Chance", g_flJumpChance[iIndex]);
				g_flJumpChance2[iIndex] = flClamp(g_flJumpChance2[iIndex], 0.0, 100.0);
				g_flJumpDuration2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Duration", g_flJumpDuration[iIndex]);
				g_flJumpDuration2[iIndex] = flClamp(g_flJumpDuration2[iIndex], 0.1, 9999999999.0);
				g_flJumpHeight2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Height", g_flJumpHeight[iIndex]);
				g_flJumpHeight2[iIndex] = flClamp(g_flJumpHeight2[iIndex], 0.1, 9999999999.0);
				g_iJumpHit2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Hit", g_iJumpHit[iIndex]);
				g_iJumpHit2[iIndex] = iClamp(g_iJumpHit2[iIndex], 0, 1);
				g_iJumpHitMode2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Hit Mode", g_iJumpHitMode[iIndex]);
				g_iJumpHitMode2[iIndex] = iClamp(g_iJumpHitMode2[iIndex], 0, 2);
				g_flJumpInterval2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Interval", g_flJumpInterval[iIndex]);
				g_flJumpInterval2[iIndex] = flClamp(g_flJumpInterval2[iIndex], 0.1, 9999999999.0);
				g_iJumpMode2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Mode", g_iJumpMode[iIndex]);
				g_iJumpMode2[iIndex] = iClamp(g_iJumpMode2[iIndex], 0, 1);
				g_flJumpRange2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Range", g_flJumpRange[iIndex]);
				g_flJumpRange2[iIndex] = flClamp(g_flJumpRange2[iIndex], 1.0, 9999999999.0);
				g_flJumpRangeChance2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Range Chance", g_flJumpRangeChance[iIndex]);
				g_flJumpRangeChance2[iIndex] = flClamp(g_flJumpRangeChance2[iIndex], 0.0, 100.0);
				g_flJumpSporadicChance2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Sporadic Chance", g_flJumpSporadicChance[iIndex]);
				g_flJumpSporadicChance2[iIndex] = flClamp(g_flJumpSporadicChance2[iIndex], 0.0, 100.0);
				g_flJumpSporadicHeight2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Sporadic Height", g_flJumpSporadicHeight[iIndex]);
				g_flJumpSporadicHeight2[iIndex] = flClamp(g_flJumpSporadicHeight2[iIndex], 0.1, 9999999999.0);
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
		float flJumpRange = !g_bTankConfig[ST_TankType(tank)] ? g_flJumpRange[ST_TankType(tank)] : g_flJumpRange2[ST_TankType(tank)],
			flJumpRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flJumpRangeChance[ST_TankType(tank)] : g_flJumpRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flJumpRange)
				{
					vJumpHit(iSurvivor, tank, flJumpRangeChance, iJumpAbility(tank), "2", "3");
				}
			}
		}

		if ((iJumpAbility(tank) == 2 || iJumpAbility(tank) == 3) && !g_bJump[tank])
		{
			g_bJump[tank] = true;

			int iJumpMode = !g_bTankConfig[ST_TankType(tank)] ? g_iJumpMode[ST_TankType(tank)] : g_iJumpMode2[ST_TankType(tank)];
			switch (iJumpMode)
			{
				case 0:
				{
					float flJumpInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flJumpInterval[ST_TankType(tank)] : g_flJumpInterval2[ST_TankType(tank)];
					CreateTimer(flJumpInterval, tTimerJump, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				}
				case 1: CreateTimer(1.0, tTimerJump2, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			}

			char sJumpMessage[4];
			sJumpMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sJumpMessage[ST_TankType(tank)] : g_sJumpMessage2[ST_TankType(tank)];
			if (StrContains(sJumpMessage, "3") != -1)
			{
				char sTankName[33];
				ST_TankName(tank, sTankName);
				PrintToChatAll("%s %t", ST_TAG2, "Jump3", sTankName);
			}
		}
	}
}

static void vJump(int survivor, int tank)
{
	float flJumpHeight = !g_bTankConfig[ST_TankType(tank)] ? g_flJumpHeight[ST_TankType(tank)] : g_flJumpHeight2[ST_TankType(tank)],
		flVelocity[3];

	GetEntPropVector(survivor, Prop_Data, "m_vecVelocity", flVelocity);
	flVelocity[2] += flJumpHeight;

	TeleportEntity(survivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
}

static void vJumpHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bJump2[survivor])
	{
		g_bJump2[survivor] = true;

		DataPack dpJump;
		CreateDataTimer(0.25, tTimerJump3, dpJump, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpJump.WriteCell(GetClientUserId(survivor));
		dpJump.WriteCell(GetClientUserId(tank));
		dpJump.WriteString(message);
		dpJump.WriteCell(enabled);
		dpJump.WriteFloat(GetEngineTime());

		char sJumpEffect[4];
		sJumpEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sJumpEffect[ST_TankType(tank)] : g_sJumpEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sJumpEffect, mode);

		char sJumpMessage[4];
		sJumpMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sJumpMessage[ST_TankType(tank)] : g_sJumpMessage2[ST_TankType(tank)];
		if (StrContains(sJumpMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Jump", sTankName, survivor);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bJump[iPlayer] = false;
			g_bJump2[iPlayer] = false;
		}
	}
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bJump2[survivor] = false;

	char sJumpMessage[4];
	sJumpMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sJumpMessage[ST_TankType(tank)] : g_sJumpMessage2[ST_TankType(tank)];
	if (StrContains(sJumpMessage, message) != -1)
	{
		PrintToChatAll("%s %t", ST_TAG2, "Jump2", survivor);
	}
}

static float flJumpChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flJumpChance[ST_TankType(tank)] : g_flJumpChance2[ST_TankType(tank)];
}

static int iJumpAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iJumpAbility[ST_TankType(tank)] : g_iJumpAbility2[ST_TankType(tank)];
}

static int iJumpHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iJumpHit[ST_TankType(tank)] : g_iJumpHit2[ST_TankType(tank)];
}

static int iJumpHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iJumpHitMode[ST_TankType(tank)] : g_iJumpHitMode2[ST_TankType(tank)];
}

public Action tTimerJump(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bJump[iTank])
	{
		g_bJump[iTank] = false;

		return Plugin_Stop;
	}

	if (iJumpAbility(iTank) != 2 && iJumpAbility(iTank) != 3)
	{
		g_bJump[iTank] = false;

		return Plugin_Stop;
	}

	if (!bIsEntityGrounded(iTank))
	{
		return Plugin_Continue;
	}

	vJump(iTank, iTank);

	return Plugin_Continue;
}

public Action tTimerJump2(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bJump[iTank])
	{
		g_bJump[iTank] = false;

		return Plugin_Stop;
	}

	if (iJumpAbility(iTank) != 2 && iJumpAbility(iTank) != 3)
	{
		g_bJump[iTank] = false;

		return Plugin_Stop;
	}

	float flJumpSporadicChance = !g_bTankConfig[ST_TankType(iTank)] ? g_flJumpSporadicChance[ST_TankType(iTank)] : g_flJumpSporadicChance2[ST_TankType(iTank)];
	if (GetRandomFloat(0.1, 100.0) > flJumpSporadicChance)
	{
		return Plugin_Continue;
	}

	float flNearestSurvivor = flGetNearestSurvivor(iTank);
	if (flNearestSurvivor > 100.0 && flNearestSurvivor < 1000.0)
	{
		float flVelocity[3];
		GetEntPropVector(iTank, Prop_Data, "m_vecVelocity", flVelocity);

		if (flVelocity[0] > 0.0 && flVelocity[0] < 500.0)
		{
			flVelocity[0] += 500.0;
		}
		else if (flVelocity[0] < 0.0 && flVelocity[0] > -500.0)
		{
			flVelocity[0] += -500.0;
		}
		if (flVelocity[1] > 0.0 && flVelocity[1] < 500.0)
		{
			flVelocity[1] += 500.0;
		}
		else if (flVelocity[1] < 0.0 && flVelocity[1] > -500.0)
		{
			flVelocity[1] += -500.0;
		}

		float flJumpSporadicHeight = !g_bTankConfig[ST_TankType(iTank)] ? g_flJumpSporadicHeight[ST_TankType(iTank)] : g_flJumpSporadicHeight2[ST_TankType(iTank)];
		flVelocity[2] += flJumpSporadicHeight;
		TeleportEntity(iTank, NULL_VECTOR, NULL_VECTOR, flVelocity);
	}

	return Plugin_Continue;
}

public Action tTimerJump3(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bJump2[iSurvivor])
	{
		g_bJump2[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[4];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iJumpEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flJumpDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flJumpDuration[ST_TankType(iTank)] : g_flJumpDuration2[ST_TankType(iTank)];

	if ((iJumpEnabled != 1 && iJumpEnabled != 3) || (flTime + flJumpDuration < GetEngineTime()))
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	if (!bIsEntityGrounded(iSurvivor))
	{
		return Plugin_Continue;
	}

	vJump(iSurvivor, iTank);

	return Plugin_Continue;
}