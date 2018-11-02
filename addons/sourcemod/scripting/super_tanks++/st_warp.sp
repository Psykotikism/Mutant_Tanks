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

// Super Tanks++: Warp Ability
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
	name = "[ST++] Warp Ability",
	author = ST_AUTHOR,
	description = "The Super Tank warps to survivors and warps survivors to random teammates.",
	version = ST_VERSION,
	url = ST_URL
};

#define PARTICLE_ELECTRICITY "electrical_arc_01_system"

#define SOUND_ELECTRICITY "ambient/energy/zap5.wav"
#define SOUND_ELECTRICITY2 "ambient/energy/zap7.wav"

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1], g_bWarp[MAXPLAYERS + 1];

char g_sParticleEffects[ST_MAXTYPES + 1][8], g_sParticleEffects2[ST_MAXTYPES + 1][8], g_sWarpEffect[ST_MAXTYPES + 1][4], g_sWarpEffect2[ST_MAXTYPES + 1][4], g_sWarpMessage[ST_MAXTYPES + 1][4], g_sWarpMessage2[ST_MAXTYPES + 1][4];

float g_flWarpChance[ST_MAXTYPES + 1], g_flWarpChance2[ST_MAXTYPES + 1], g_flWarpInterval[ST_MAXTYPES + 1], g_flWarpInterval2[ST_MAXTYPES + 1], g_flWarpRange[ST_MAXTYPES + 1], g_flWarpRange2[ST_MAXTYPES + 1], g_flWarpRangeChance[ST_MAXTYPES + 1], g_flWarpRangeChance2[ST_MAXTYPES + 1];

int g_iParticleEffect[ST_MAXTYPES + 1], g_iParticleEffect2[ST_MAXTYPES + 1], g_iWarpAbility[ST_MAXTYPES + 1], g_iWarpAbility2[ST_MAXTYPES + 1], g_iWarpHit[ST_MAXTYPES + 1], g_iWarpHit2[ST_MAXTYPES + 1], g_iWarpHitMode[ST_MAXTYPES + 1], g_iWarpHitMode2[ST_MAXTYPES + 1], g_iWarpMode[ST_MAXTYPES + 1], g_iWarpMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Warp Ability\" only supports Left 4 Dead 1 & 2.");

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
	vPrecacheParticle(PARTICLE_ELECTRICITY);

	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_ELECTRICITY2, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	g_bWarp[client] = false;
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

		if ((iWarpHitMode(attacker) == 0 || iWarpHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vWarpHit(victim, attacker, flWarpChance(attacker), iWarpHit(attacker), "1", "1");
			}
		}
		else if ((iWarpHitMode(victim) == 0 || iWarpHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vWarpHit(attacker, victim, flWarpChance(victim), iWarpHit(victim), "1", "2");
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

				g_iParticleEffect[iIndex] = kvSuperTanks.GetNum("Particles/Body Particle", 0);
				g_iParticleEffect[iIndex] = iClamp(g_iParticleEffect[iIndex], 0, 1);
				kvSuperTanks.GetString("Particles/Body Effects", g_sParticleEffects[iIndex], sizeof(g_sParticleEffects[]), "1234567");
				g_iWarpAbility[iIndex] = kvSuperTanks.GetNum("Warp Ability/Ability Enabled", 0);
				g_iWarpAbility[iIndex] = iClamp(g_iWarpAbility[iIndex], 0, 3);
				kvSuperTanks.GetString("Warp Ability/Ability Effect", g_sWarpEffect[iIndex], sizeof(g_sWarpEffect[]), "0");
				kvSuperTanks.GetString("Warp Ability/Ability Message", g_sWarpMessage[iIndex], sizeof(g_sWarpMessage[]), "0");
				g_flWarpChance[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Chance", 33.3);
				g_flWarpChance[iIndex] = flClamp(g_flWarpChance[iIndex], 0.0, 100.0);
				g_iWarpHit[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Hit", 0);
				g_iWarpHit[iIndex] = iClamp(g_iWarpHit[iIndex], 0, 1);
				g_iWarpHitMode[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Hit Mode", 0);
				g_iWarpHitMode[iIndex] = iClamp(g_iWarpHitMode[iIndex], 0, 2);
				g_iWarpMode[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Mode", 0);
				g_iWarpMode[iIndex] = iClamp(g_iWarpMode[iIndex], 0, 1);
				g_flWarpInterval[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Interval", 5.0);
				g_flWarpInterval[iIndex] = flClamp(g_flWarpInterval[iIndex], 0.1, 9999999999.0);
				g_flWarpRange[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Range", 150.0);
				g_flWarpRange[iIndex] = flClamp(g_flWarpRange[iIndex], 1.0, 9999999999.0);
				g_flWarpRangeChance[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Range Chance", 15.0);
				g_flWarpRangeChance[iIndex] = flClamp(g_flWarpRangeChance[iIndex], 0.0, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iParticleEffect2[iIndex] = kvSuperTanks.GetNum("Particles/Body Particle", g_iParticleEffect[iIndex]);
				g_iParticleEffect2[iIndex] = iClamp(g_iParticleEffect2[iIndex], 0, 1);
				kvSuperTanks.GetString("Particles/Body Effects", g_sParticleEffects2[iIndex], sizeof(g_sParticleEffects2[]), g_sParticleEffects[iIndex]);
				g_iWarpAbility2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Ability Enabled", g_iWarpAbility[iIndex]);
				g_iWarpAbility2[iIndex] = iClamp(g_iWarpAbility2[iIndex], 0, 3);
				kvSuperTanks.GetString("Warp Ability/Ability Effect", g_sWarpEffect2[iIndex], sizeof(g_sWarpEffect2[]), g_sWarpEffect[iIndex]);
				kvSuperTanks.GetString("Warp Ability/Ability Message", g_sWarpMessage2[iIndex], sizeof(g_sWarpMessage2[]), g_sWarpMessage[iIndex]);
				g_flWarpChance2[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Chance", g_flWarpChance[iIndex]);
				g_flWarpChance2[iIndex] = flClamp(g_flWarpChance2[iIndex], 0.0, 100.0);
				g_iWarpHit2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Hit", g_iWarpHit[iIndex]);
				g_iWarpHit2[iIndex] = iClamp(g_iWarpHit2[iIndex], 0, 1);
				g_iWarpHitMode2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Hit Mode", g_iWarpHitMode[iIndex]);
				g_iWarpHitMode2[iIndex] = iClamp(g_iWarpHitMode2[iIndex], 0, 2);
				g_iWarpMode2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Mode", g_iWarpMode[iIndex]);
				g_iWarpMode2[iIndex] = iClamp(g_iWarpMode2[iIndex], 0, 1);
				g_flWarpInterval2[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Interval", g_flWarpInterval[iIndex]);
				g_flWarpInterval2[iIndex] = flClamp(g_flWarpInterval2[iIndex], 0.1, 9999999999.0);
				g_flWarpRange2[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Range", g_flWarpRange[iIndex]);
				g_flWarpRange2[iIndex] = flClamp(g_flWarpRange2[iIndex], 1.0, 9999999999.0);
				g_flWarpRangeChance2[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Range Chance", g_flWarpRangeChance[iIndex]);
				g_flWarpRangeChance2[iIndex] = flClamp(g_flWarpRangeChance2[iIndex], 0.0, 100.0);
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
		float flWarpRange = !g_bTankConfig[ST_TankType(tank)] ? g_flWarpRange[ST_TankType(tank)] : g_flWarpRange2[ST_TankType(tank)],
			flWarpRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flWarpRangeChance[ST_TankType(tank)] : g_flWarpRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flWarpRange)
				{
					vWarpHit(iSurvivor, tank, flWarpRangeChance, iWarpAbility(tank), "2", "3");
				}
			}
		}

		if ((iWarpAbility(tank) == 2 || iWarpAbility(tank) == 3) && !g_bWarp[tank])
		{
			g_bWarp[tank] = true;
			float flWarpInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flWarpInterval[ST_TankType(tank)] : g_flWarpInterval2[ST_TankType(tank)];
			CreateTimer(flWarpInterval, tTimerWarp, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bWarp[iPlayer] = false;
		}
	}
}

static void vWarpHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if ((enabled == 1 || enabled == 3) && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor))
	{
		float flCurrentOrigin[3];
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsSurvivor(iPlayer) && !bIsPlayerIncapacitated(iPlayer) && iPlayer != survivor)
			{
				GetClientAbsOrigin(iPlayer, flCurrentOrigin);
				TeleportEntity(survivor, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);

				char sWarpMessage[4];
				sWarpMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sWarpMessage[ST_TankType(tank)] : g_sWarpMessage2[ST_TankType(tank)];
				if (StrContains(sWarpMessage, message) != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					PrintToChatAll("%s %t", ST_TAG2, "Warp", sTankName, survivor, iPlayer);
				}

				break;
			}
		}

		char sWarpEffect[4];
		sWarpEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sWarpEffect[ST_TankType(tank)] : g_sWarpEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sWarpEffect, mode);
	}
}

static float flWarpChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flWarpChance[ST_TankType(tank)] : g_flWarpChance2[ST_TankType(tank)];
}

static int iWarpAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWarpAbility[ST_TankType(tank)] : g_iWarpAbility2[ST_TankType(tank)];
}

static int iWarpHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWarpHit[ST_TankType(tank)] : g_iWarpHit2[ST_TankType(tank)];
}

static int iWarpHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWarpHitMode[ST_TankType(tank)] : g_iWarpHitMode2[ST_TankType(tank)];
}

public Action tTimerWarp(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bWarp[iTank])
	{
		g_bWarp[iTank] = false;
		return Plugin_Stop;
	}

	if (iWarpAbility(iTank) != 2 && iWarpAbility(iTank) != 3)
	{
		g_bWarp[iTank] = false;
		return Plugin_Stop;
	}

	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[ST_TankType(iTank)] ? g_sParticleEffects[ST_TankType(iTank)] : g_sParticleEffects2[ST_TankType(iTank)];
	int iParticleEffect = !g_bTankConfig[ST_TankType(iTank)] ? g_iParticleEffect[ST_TankType(iTank)] : g_iParticleEffect2[ST_TankType(iTank)],
		iWarpMode = !g_bTankConfig[ST_TankType(iTank)] ? g_iWarpMode[ST_TankType(iTank)] : g_iWarpMode2[ST_TankType(iTank)],
		iSurvivor = iGetRandomSurvivor(iTank);

	if (iSurvivor > 0)
	{
		float flTankOrigin[3], flTankAngles[3], flSurvivorOrigin[3], flSurvivorAngles[3];

		GetClientAbsOrigin(iTank, flTankOrigin);
		GetClientAbsAngles(iTank, flTankAngles);

		GetClientAbsOrigin(iSurvivor, flSurvivorOrigin);
		GetClientAbsAngles(iSurvivor, flSurvivorAngles);

		if (iParticleEffect == 1 && StrContains(sParticleEffects, "2") != -1)
		{
			vCreateParticle(iTank, PARTICLE_ELECTRICITY, 1.0, 0.0);
			EmitSoundToAll(SOUND_ELECTRICITY, iTank);

			if (iWarpMode == 1)
			{
				vCreateParticle(iSurvivor, PARTICLE_ELECTRICITY, 1.0, 0.0);
				EmitSoundToAll(SOUND_ELECTRICITY2, iSurvivor);
			}
		}

		TeleportEntity(iTank, flSurvivorOrigin, flSurvivorAngles, NULL_VECTOR);

		if (iWarpMode == 1)
		{
			TeleportEntity(iSurvivor, flTankOrigin, flTankAngles, NULL_VECTOR);
		}

		char sWarpMessage[4];
		sWarpMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sWarpMessage[ST_TankType(iTank)] : g_sWarpMessage2[ST_TankType(iTank)];
		if (StrContains(sWarpMessage, "3") != -1)
		{
			char sTankName[33];
			ST_TankName(iTank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Warp2", sTankName);
		}
	}

	return Plugin_Continue;
}