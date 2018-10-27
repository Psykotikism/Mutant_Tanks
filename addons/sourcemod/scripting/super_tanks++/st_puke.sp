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

// Super Tanks++: Puke Ability
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
	name = "[ST++] Puke Ability",
	author = ST_AUTHOR,
	description = "The Super Tank pukes on survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sPukeEffect[ST_MAXTYPES + 1][4], g_sPukeEffect2[ST_MAXTYPES + 1][4], g_sPukeMessage[ST_MAXTYPES + 1][3], g_sPukeMessage2[ST_MAXTYPES + 1][3];

float g_flPukeChance[ST_MAXTYPES + 1], g_flPukeChance2[ST_MAXTYPES + 1], g_flPukeRange[ST_MAXTYPES + 1], g_flPukeRange2[ST_MAXTYPES + 1], g_flPukeRangeChance[ST_MAXTYPES + 1], g_flPukeRangeChance2[ST_MAXTYPES + 1];

Handle g_hSDKPukePlayer;

int g_iPukeAbility[ST_MAXTYPES + 1], g_iPukeAbility2[ST_MAXTYPES + 1], g_iPukeHit[ST_MAXTYPES + 1], g_iPukeHit2[ST_MAXTYPES + 1], g_iPukeHitMode[ST_MAXTYPES + 1], g_iPukeHitMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Puke Ability only supports Left 4 Dead 1 & 2.");

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

	GameData gdSuperTanks = new GameData("super_tanks++");

	if (gdSuperTanks == null)
	{
		SetFailState("Unable to load the \"super_tanks++\" gamedata file.");
		return;
	}

	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDKPukePlayer = EndPrepSDKCall();

	if (g_hSDKPukePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnVomitedUpon\" signature is outdated.", ST_TAG);
	}

	delete gdSuperTanks;

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

		if ((iPukeHitMode(attacker) == 0 || iPukeHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vPukeHit(victim, attacker, flPukeChance(attacker), iPukeHit(attacker), "1", "1");
			}
		}
		else if ((iPukeHitMode(victim) == 0 || iPukeHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vPukeHit(attacker, victim, flPukeChance(victim), iPukeHit(victim), "1", "2");
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

				g_iPukeAbility[iIndex] = kvSuperTanks.GetNum("Puke Ability/Ability Enabled", 0);
				g_iPukeAbility[iIndex] = iClamp(g_iPukeAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Puke Ability/Ability Effect", g_sPukeEffect[iIndex], sizeof(g_sPukeEffect[]), "123");
				kvSuperTanks.GetString("Puke Ability/Ability Message", g_sPukeMessage[iIndex], sizeof(g_sPukeMessage[]), "0");
				g_flPukeChance[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Chance", 33.3);
				g_flPukeChance[iIndex] = flClamp(g_flPukeChance[iIndex], 0.1, 100.0);
				g_iPukeHit[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Hit", 0);
				g_iPukeHit[iIndex] = iClamp(g_iPukeHit[iIndex], 0, 1);
				g_iPukeHitMode[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Hit Mode", 0);
				g_iPukeHitMode[iIndex] = iClamp(g_iPukeHitMode[iIndex], 0, 2);
				g_flPukeRange[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Range", 150.0);
				g_flPukeRange[iIndex] = flClamp(g_flPukeRange[iIndex], 1.0, 9999999999.0);
				g_flPukeRangeChance[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Range Chance", 15.0);
				g_flPukeRangeChance[iIndex] = flClamp(g_flPukeRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iPukeAbility2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Ability Enabled", g_iPukeAbility[iIndex]);
				g_iPukeAbility2[iIndex] = iClamp(g_iPukeAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Puke Ability/Ability Effect", g_sPukeEffect2[iIndex], sizeof(g_sPukeEffect2[]), g_sPukeEffect[iIndex]);
				kvSuperTanks.GetString("Puke Ability/Ability Message", g_sPukeMessage2[iIndex], sizeof(g_sPukeMessage2[]), g_sPukeMessage[iIndex]);
				g_flPukeChance2[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Chance", g_flPukeChance[iIndex]);
				g_flPukeChance2[iIndex] = flClamp(g_flPukeChance2[iIndex], 0.1, 100.0);
				g_iPukeHit2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Hit", g_iPukeHit[iIndex]);
				g_iPukeHit2[iIndex] = iClamp(g_iPukeHit2[iIndex], 0, 1);
				g_iPukeHitMode2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Hit Mode", g_iPukeHitMode[iIndex]);
				g_iPukeHitMode2[iIndex] = iClamp(g_iPukeHitMode2[iIndex], 0, 2);
				g_flPukeRange2[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Range", g_flPukeRange[iIndex]);
				g_flPukeRange2[iIndex] = flClamp(g_flPukeRange2[iIndex], 1.0, 9999999999.0);
				g_flPukeRangeChance2[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Range Chance", g_flPukeRangeChance[iIndex]);
				g_flPukeRangeChance2[iIndex] = flClamp(g_flPukeRangeChance2[iIndex], 0.1, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flPukeRange = !g_bTankConfig[ST_TankType(tank)] ? g_flPukeRange[ST_TankType(tank)] : g_flPukeRange2[ST_TankType(tank)],
			flPukeRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flPukeRangeChance[ST_TankType(tank)] : g_flPukeRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flPukeRange)
				{
					vPukeHit(iSurvivor, tank, flPukeRangeChance, iPukeAbility(tank), "2", "3");
				}
			}
		}
	}
}

static void vPukeHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor))
	{
		SDKCall(g_hSDKPukePlayer, survivor, tank, true);

		char sPukeEffect[4];
		sPukeEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sPukeEffect[ST_TankType(tank)] : g_sPukeEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sPukeEffect, mode);

		char sPukeMessage[3];
		sPukeMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sPukeMessage[ST_TankType(tank)] : g_sPukeMessage2[ST_TankType(tank)];
		if (StrContains(sPukeMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Puke", sTankName, survivor);
		}
	}
}

static float flPukeChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flPukeChance[ST_TankType(tank)] : g_flPukeChance2[ST_TankType(tank)];
}

static int iPukeAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPukeAbility[ST_TankType(tank)] : g_iPukeAbility2[ST_TankType(tank)];
}

static int iPukeHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPukeHit[ST_TankType(tank)] : g_iPukeHit2[ST_TankType(tank)];
}

static int iPukeHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPukeHitMode[ST_TankType(tank)] : g_iPukeHitMode2[ST_TankType(tank)];
}