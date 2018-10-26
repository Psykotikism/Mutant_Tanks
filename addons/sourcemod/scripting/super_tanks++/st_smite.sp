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

// Super Tanks++: Smite Ability
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
	name = "[ST++] Smite Ability",
	author = ST_AUTHOR,
	description = "The Super Tank smites survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define SPRITE_GLOW "sprites/glow.vmt"

#define SOUND_EXPLOSION "ambient/explosions/explode_2.wav"

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sSmiteEffect[ST_MAXTYPES + 1][4], g_sSmiteEffect2[ST_MAXTYPES + 1][4];

float g_flSmiteChance[ST_MAXTYPES + 1], g_flSmiteChance2[ST_MAXTYPES + 1], g_flSmiteRange[ST_MAXTYPES + 1], g_flSmiteRange2[ST_MAXTYPES + 1], g_flSmiteRangeChance[ST_MAXTYPES + 1], g_flSmiteRangeChance2[ST_MAXTYPES + 1];

int g_iSmiteAbility[ST_MAXTYPES + 1], g_iSmiteAbility2[ST_MAXTYPES + 1], g_iSmiteHit[ST_MAXTYPES + 1], g_iSmiteHit2[ST_MAXTYPES + 1], g_iSmiteHitMode[ST_MAXTYPES + 1], g_iSmiteHitMode2[ST_MAXTYPES + 1], g_iSmiteMessage[ST_MAXTYPES + 1], g_iSmiteMessage2[ST_MAXTYPES + 1], g_iSmiteSprite = -1;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Smite Ability only supports Left 4 Dead 1 & 2.");

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
	g_iSmiteSprite = PrecacheModel(SPRITE_GLOW, true);

	PrecacheSound(SOUND_EXPLOSION, true);
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

		if ((iSmiteHitMode(attacker) == 0 || iSmiteHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vSmiteHit(victim, attacker, flSmiteChance(attacker), iSmiteHit(attacker), 1, "1");
			}
		}
		else if ((iSmiteHitMode(victim) == 0 || iSmiteHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vSmiteHit(attacker, victim, flSmiteChance(victim), iSmiteHit(victim), 1, "2");
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
				g_bTankConfig[iIndex] = false;g_bTankConfig[iIndex] = true;

				g_iSmiteAbility[iIndex] = kvSuperTanks.GetNum("Smite Ability/Ability Enabled", 0);
				g_iSmiteAbility[iIndex] = iClamp(g_iSmiteAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Smite Ability/Ability Effect", g_sSmiteEffect[iIndex], sizeof(g_sSmiteEffect[]), "123");
				g_iSmiteMessage[iIndex] = kvSuperTanks.GetNum("Smite Ability/Ability Message", 0);
				g_iSmiteMessage[iIndex] = iClamp(g_iSmiteMessage[iIndex], 0, 3);
				g_flSmiteChance[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Chance", 33.3);
				g_flSmiteChance[iIndex] = flClamp(g_flSmiteChance[iIndex], 0.1, 100.0);
				g_iSmiteHit[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Hit", 0);
				g_iSmiteHit[iIndex] = iClamp(g_iSmiteHit[iIndex], 0, 1);
				g_iSmiteHitMode[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Hit Mode", 0);
				g_iSmiteHitMode[iIndex] = iClamp(g_iSmiteHitMode[iIndex], 0, 2);
				g_flSmiteRange[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Range", 150.0);
				g_flSmiteRange[iIndex] = flClamp(g_flSmiteRange[iIndex], 1.0, 9999999999.0);
				g_flSmiteRangeChance[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Range Chance", 15.0);
				g_flSmiteRangeChance[iIndex] = flClamp(g_flSmiteRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = false;g_bTankConfig[iIndex] = true;

				g_iSmiteAbility2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Ability Enabled", g_iSmiteAbility[iIndex]);
				g_iSmiteAbility2[iIndex] = iClamp(g_iSmiteAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Smite Ability/Ability Effect", g_sSmiteEffect2[iIndex], sizeof(g_sSmiteEffect2[]), g_sSmiteEffect[iIndex]);
				g_iSmiteMessage2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Ability Message", g_iSmiteMessage[iIndex]);
				g_iSmiteMessage2[iIndex] = iClamp(g_iSmiteMessage2[iIndex], 0, 3);
				g_flSmiteChance2[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Chance", g_flSmiteChance[iIndex]);
				g_flSmiteChance2[iIndex] = flClamp(g_flSmiteChance2[iIndex], 0.1, 100.0);
				g_iSmiteHit2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Hit", g_iSmiteHit[iIndex]);
				g_iSmiteHit2[iIndex] = iClamp(g_iSmiteHit2[iIndex], 0, 1);
				g_iSmiteHitMode2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Hit Mode", g_iSmiteHitMode[iIndex]);
				g_iSmiteHitMode2[iIndex] = iClamp(g_iSmiteHitMode2[iIndex], 0, 2);
				g_flSmiteRange2[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Range", g_flSmiteRange[iIndex]);
				g_flSmiteRange2[iIndex] = flClamp(g_flSmiteRange2[iIndex], 1.0, 9999999999.0);
				g_flSmiteRangeChance2[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Range Chance", g_flSmiteRangeChance[iIndex]);
				g_flSmiteRangeChance2[iIndex] = flClamp(g_flSmiteRangeChance2[iIndex], 0.1, 100.0);
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
		float flSmiteRange = !g_bTankConfig[ST_TankType(tank)] ? g_flSmiteRange[ST_TankType(tank)] : g_flSmiteRange2[ST_TankType(tank)],
			flSmiteRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flSmiteRangeChance[ST_TankType(tank)] : g_flSmiteRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flSmiteRange)
				{
					vSmiteHit(iSurvivor, tank, flSmiteRangeChance, iSmiteAbility(tank), 2, "3");
				}
			}
		}
	}
}

static void vSmiteHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor))
	{
		float flPosition[3], flStartPosition[3];
		int iColor[4] = {255, 255, 255, 255};

		GetClientAbsOrigin(survivor, flPosition);
		flPosition[2] -= 26;
		flStartPosition[0] = flPosition[0] + GetRandomInt(-500, 500), flStartPosition[1] = flPosition[1] + GetRandomInt(-500, 500), flStartPosition[2] = flPosition[2] + 800;

		TE_SetupBeamPoints(flStartPosition, flPosition, g_iSmiteSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, iColor, 3);
		TE_SendToAll();

		TE_SetupSparks(flPosition, view_as<float>({0.0, 0.0, 0.0}), 5000, 1000);
		TE_SendToAll();

		TE_SetupEnergySplash(flPosition, view_as<float>({0.0, 0.0, 0.0}), false);
		TE_SendToAll();

		EmitAmbientSound(SOUND_EXPLOSION, flStartPosition, survivor, SNDLEVEL_RAIDSIREN);
		ForcePlayerSuicide(survivor);

		char sSmiteEffect[4];
		sSmiteEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sSmiteEffect[ST_TankType(tank)] : g_sSmiteEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sSmiteEffect, mode);

		int iSmiteMessage = !g_bTankConfig[ST_TankType(tank)] ? g_iSmiteMessage[ST_TankType(tank)] : g_iSmiteMessage2[ST_TankType(tank)];
		if (iSmiteMessage == message || iSmiteMessage == 3)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Smite", sTankName, survivor);
		}
	}
}

static float flSmiteChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flSmiteChance[ST_TankType(tank)] : g_flSmiteChance2[ST_TankType(tank)];
}

static int iSmiteAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iSmiteAbility[ST_TankType(tank)] : g_iSmiteAbility2[ST_TankType(tank)];
}

static int iSmiteHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iSmiteHit[ST_TankType(tank)] : g_iSmiteHit2[ST_TankType(tank)];
}

static int iSmiteHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iSmiteHitMode[ST_TankType(tank)] : g_iSmiteHitMode2[ST_TankType(tank)];
}