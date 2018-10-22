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

// Super Tanks++: Smash Ability
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
	name = "[ST++] Smash Ability",
	author = ST_AUTHOR,
	description = "The Super Tank smashes survivors to death.",
	version = ST_VERSION,
	url = ST_URL
};

#define PARTICLE_BLOOD "boomer_explode_D"

#define SOUND_GROWL "player/tank/voice/growl/tank_climb_01.wav"
#define SOUND_SMASH "player/charger/hit/charger_smash_02.wav"

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sSmashEffect[ST_MAXTYPES + 1][4], g_sSmashEffect2[ST_MAXTYPES + 1][4];

float g_flSmashChance[ST_MAXTYPES + 1], g_flSmashChance2[ST_MAXTYPES + 1], g_flSmashRange[ST_MAXTYPES + 1], g_flSmashRange2[ST_MAXTYPES + 1], g_flSmashRangeChance[ST_MAXTYPES + 1], g_flSmashRangeChance2[ST_MAXTYPES + 1];

int g_iSmashAbility[ST_MAXTYPES + 1], g_iSmashAbility2[ST_MAXTYPES + 1], g_iSmashHit[ST_MAXTYPES + 1], g_iSmashHit2[ST_MAXTYPES + 1], g_iSmashHitMode[ST_MAXTYPES + 1], g_iSmashHitMode2[ST_MAXTYPES + 1], g_iSmashMessage[ST_MAXTYPES + 1], g_iSmashMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Smash Ability only supports Left 4 Dead 1 & 2.");

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
	vPrecacheParticle(PARTICLE_BLOOD);

	PrecacheSound(SOUND_GROWL, true);
	PrecacheSound(SOUND_SMASH, true);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iSmashHitMode(attacker) == 0 || iSmashHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vSmashHit(victim, attacker, flSmashChance(attacker), iSmashHit(attacker), 1, "1");
			}
		}
		else if ((iSmashHitMode(victim) == 0 || iSmashHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vSmashHit(attacker, victim, flSmashChance(victim), iSmashHit(victim), 1, "2");
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
		char sTankName[MAX_NAME_LENGTH + 1];
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName, true))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iSmashAbility[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Enabled", 0);
				g_iSmashAbility[iIndex] = iClamp(g_iSmashAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Smash Ability/Ability Effect", g_sSmashEffect[iIndex], sizeof(g_sSmashEffect[]), "123");
				g_iSmashMessage[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Message", 0);
				g_iSmashMessage[iIndex] = iClamp(g_iSmashMessage[iIndex], 0, 3);
				g_flSmashChance[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Chance", 33.3);
				g_flSmashChance[iIndex] = flClamp(g_flSmashChance[iIndex], 0.1, 100.0);
				g_iSmashHit[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit", 0);
				g_iSmashHit[iIndex] = iClamp(g_iSmashHit[iIndex], 0, 1);
				g_iSmashHitMode[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit Mode", 0);
				g_iSmashHitMode[iIndex] = iClamp(g_iSmashHitMode[iIndex], 0, 2);
				g_flSmashRange[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range", 150.0);
				g_flSmashRange[iIndex] = flClamp(g_flSmashRange[iIndex], 1.0, 9999999999.0);
				g_flSmashRangeChance[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range Chance", 15.0);
				g_flSmashRangeChance[iIndex] = flClamp(g_flSmashRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iSmashAbility2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Enabled", g_iSmashAbility[iIndex]);
				g_iSmashAbility2[iIndex] = iClamp(g_iSmashAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Smash Ability/Ability Effect", g_sSmashEffect2[iIndex], sizeof(g_sSmashEffect2[]), g_sSmashEffect[iIndex]);
				g_iSmashMessage2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Message", g_iSmashMessage[iIndex]);
				g_iSmashMessage2[iIndex] = iClamp(g_iSmashMessage2[iIndex], 0, 3);
				g_flSmashChance2[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Chance", g_flSmashChance[iIndex]);
				g_flSmashChance2[iIndex] = flClamp(g_flSmashChance2[iIndex], 0.1, 100.0);
				g_iSmashHit2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit", g_iSmashHit[iIndex]);
				g_iSmashHit2[iIndex] = iClamp(g_iSmashHit2[iIndex], 0, 1);
				g_iSmashHitMode2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit Mode", g_iSmashHitMode[iIndex]);
				g_iSmashHitMode2[iIndex] = iClamp(g_iSmashHitMode2[iIndex], 0, 2);
				g_flSmashRange2[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range", g_flSmashRange[iIndex]);
				g_flSmashRange2[iIndex] = flClamp(g_flSmashRange2[iIndex], 1.0, 9999999999.0);
				g_flSmashRangeChance2[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range Chance", g_flSmashRangeChance[iIndex]);
				g_flSmashRangeChance2[iIndex] = flClamp(g_flSmashRangeChance2[iIndex], 0.1, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iTankId = event.GetInt("attacker"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && bIsSurvivor(iSurvivor))
		{
			int iCorpse = -1;
			while ((iCorpse = FindEntityByClassname(iCorpse, "survivor_death_model")) != INVALID_ENT_REFERENCE)
			{
				int iOwner = GetEntPropEnt(iCorpse, Prop_Send, "m_hOwnerEntity");
				if (iSurvivor == iOwner)
				{
					RemoveEntity(iCorpse);
				}
			}
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flSmashRange = !g_bTankConfig[ST_TankType(tank)] ? g_flSmashRange[ST_TankType(tank)] : g_flSmashRange2[ST_TankType(tank)],
			flSmashRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flSmashRangeChance[ST_TankType(tank)] : g_flSmashRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flSmashRange)
				{
					vSmashHit(iSurvivor, tank, flSmashRangeChance, iSmashAbility(tank), 2, "3");
				}
			}
		}
	}
}

static void vSmashHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor))
	{
		EmitSoundToAll(SOUND_SMASH, survivor);
		EmitSoundToAll(SOUND_GROWL, tank);

		vAttachParticle(survivor, PARTICLE_BLOOD, 0.1, 0.0);
		ForcePlayerSuicide(survivor);

		char sSmashEffect[4];
		sSmashEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sSmashEffect[ST_TankType(tank)] : g_sSmashEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sSmashEffect, mode);

		int iSmashMessage = !g_bTankConfig[ST_TankType(tank)] ? g_iSmashMessage[ST_TankType(tank)] : g_iSmashMessage2[ST_TankType(tank)];
		if (iSmashMessage == message || iSmashMessage == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Smash", sTankName, survivor);
		}
	}
}

static float flSmashChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flSmashChance[ST_TankType(tank)] : g_flSmashChance2[ST_TankType(tank)];
}

static int iSmashAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iSmashAbility[ST_TankType(tank)] : g_iSmashAbility2[ST_TankType(tank)];
}

static int iSmashHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iSmashHit[ST_TankType(tank)] : g_iSmashHit2[ST_TankType(tank)];
}

static int iSmashHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iSmashHitMode[ST_TankType(tank)] : g_iSmashHitMode2[ST_TankType(tank)];
}