/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2018  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Super Tanks++: Fling Ability
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
	name = "[ST++] Fling Ability",
	author = ST_AUTHOR,
	description = "The Super Tank flings survivors high into the air.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sFlingEffect[ST_MAXTYPES + 1][4], g_sFlingEffect2[ST_MAXTYPES + 1][4];

float g_flFlingChance[ST_MAXTYPES + 1], g_flFlingChance2[ST_MAXTYPES + 1], g_flFlingRange[ST_MAXTYPES + 1], g_flFlingRange2[ST_MAXTYPES + 1], g_flFlingRangeChance[ST_MAXTYPES + 1], g_flFlingRangeChance2[ST_MAXTYPES + 1];

Handle g_hSDKFlingPlayer, g_hSDKPukePlayer;

int g_iFlingAbility[ST_MAXTYPES + 1], g_iFlingAbility2[ST_MAXTYPES + 1], g_iFlingHit[ST_MAXTYPES + 1], g_iFlingHit2[ST_MAXTYPES + 1], g_iFlingHitMode[ST_MAXTYPES + 1], g_iFlingHitMode2[ST_MAXTYPES + 1], g_iFlingMessage[ST_MAXTYPES + 1], g_iFlingMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Fling Ability only supports Left 4 Dead 1 & 2.");

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

	if (bIsValidGame())
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "CTerrorPlayer_Fling");
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		g_hSDKFlingPlayer = EndPrepSDKCall();

		if (g_hSDKFlingPlayer == null)
		{
			PrintToServer("%s Your \"CTerrorPlayer_Fling\" signature is outdated.", ST_TAG);
		}
	}
	else
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		g_hSDKPukePlayer = EndPrepSDKCall();

		if (g_hSDKPukePlayer == null)
		{
			PrintToServer("%s Your \"CTerrorPlayer_OnVomitedUpon\" signature is outdated.", ST_TAG);
		}
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

		if ((iFlingHitMode(attacker) == 0 || iFlingHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vFlingHit(victim, attacker, flFlingChance(attacker), iFlingHit(attacker), 1, "1");
			}
		}
		else if ((iFlingHitMode(victim) == 0 || iFlingHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vFlingHit(attacker, victim, flFlingChance(victim), iFlingHit(victim), 1, "2");
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
		if (kvSuperTanks.JumpToKey(sTankName, true))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;g_bTankConfig[iIndex] = true;

				g_iFlingAbility[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Enabled", 0);
				g_iFlingAbility[iIndex] = iClamp(g_iFlingAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Fling Ability/Ability Effect", g_sFlingEffect[iIndex], sizeof(g_sFlingEffect[]), "123");
				g_iFlingMessage[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Message", 0);
				g_iFlingMessage[iIndex] = iClamp(g_iFlingMessage[iIndex], 0, 3);
				g_flFlingChance[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Chance", 33.3);
				g_flFlingChance[iIndex] = flClamp(g_flFlingChance[iIndex], 0.1, 100.0);
				g_iFlingHit[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit", 0);
				g_iFlingHit[iIndex] = iClamp(g_iFlingHit[iIndex], 0, 1);
				g_iFlingHitMode[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit Mode", 0);
				g_iFlingHitMode[iIndex] = iClamp(g_iFlingHitMode[iIndex], 0, 2);
				g_flFlingRange[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range", 150.0);
				g_flFlingRange[iIndex] = flClamp(g_flFlingRange[iIndex], 1.0, 9999999999.0);
				g_flFlingRangeChance[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range Chance", 15.0);
				g_flFlingRangeChance[iIndex] = flClamp(g_flFlingRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = false;g_bTankConfig[iIndex] = true;

				g_iFlingAbility2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Enabled", g_iFlingAbility[iIndex]);
				g_iFlingAbility2[iIndex] = iClamp(g_iFlingAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Fling Ability/Ability Effect", g_sFlingEffect2[iIndex], sizeof(g_sFlingEffect2[]), g_sFlingEffect[iIndex]);
				g_iFlingMessage2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Message", g_iFlingMessage[iIndex]);
				g_iFlingMessage2[iIndex] = iClamp(g_iFlingMessage2[iIndex], 0, 3);
				g_flFlingChance2[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Chance", g_flFlingChance[iIndex]);
				g_flFlingChance2[iIndex] = flClamp(g_flFlingChance2[iIndex], 0.1, 100.0);
				g_iFlingHit2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit", g_iFlingHit[iIndex]);
				g_iFlingHit2[iIndex] = iClamp(g_iFlingHit2[iIndex], 0, 1);
				g_iFlingHitMode2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit Mode", g_iFlingHitMode[iIndex]);
				g_iFlingHitMode2[iIndex] = iClamp(g_iFlingHitMode2[iIndex], 0, 2);
				g_flFlingRange2[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range", g_flFlingRange[iIndex]);
				g_flFlingRange2[iIndex] = flClamp(g_flFlingRange2[iIndex], 1.0, 9999999999.0);
				g_flFlingRangeChance2[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range Chance", g_flFlingRangeChance[iIndex]);
				g_flFlingRangeChance2[iIndex] = flClamp(g_flFlingRangeChance2[iIndex], 0.1, 100.0);
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
		int iFlingAbility = !g_bTankConfig[ST_TankType(tank)] ? g_iFlingAbility[ST_TankType(tank)] : g_iFlingAbility2[ST_TankType(tank)];

		float flFlingRange = !g_bTankConfig[ST_TankType(tank)] ? g_flFlingRange[ST_TankType(tank)] : g_flFlingRange2[ST_TankType(tank)],
			flFlingRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flFlingRangeChance[ST_TankType(tank)] : g_flFlingRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flFlingRange)
				{
					vFlingHit(iSurvivor, tank, flFlingRangeChance, iFlingAbility, 2, "3");
				}
			}
		}
	}
}

static void vFlingHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor))
	{
		char sTankName[33];
		ST_TankName(tank, sTankName);

		int iFlingMessage = !g_bTankConfig[ST_TankType(tank)] ? g_iFlingMessage[ST_TankType(tank)] : g_iFlingMessage2[ST_TankType(tank)];

		if (bIsValidGame())
		{
			float flSurvivorPos[3], flSurvivorVelocity[3], flTankPos[3], flDistance[3], flRatio[3], flVelocity[3];
			GetClientAbsOrigin(survivor, flSurvivorPos);
			GetClientAbsOrigin(tank, flTankPos);

			flDistance[0] = (flTankPos[0] - flSurvivorPos[0]);
			flDistance[1] = (flTankPos[1] - flSurvivorPos[1]);
			flDistance[2] = (flTankPos[2] - flSurvivorPos[2]);
			GetEntPropVector(survivor, Prop_Data, "m_vecVelocity", flSurvivorVelocity);
			flRatio[0] = flDistance[0] / (SquareRoot((flDistance[1] * flDistance[1]) + (flDistance[0] * flDistance[0])));
			flRatio[1] = flDistance[1] / (SquareRoot((flDistance[1] * flDistance[1]) + (flDistance[0] * flDistance[0])));
			flVelocity[0] = (flRatio[0] * -1) * 500.0;
			flVelocity[1] = (flRatio[1] * -1) * 500.0;
			flVelocity[2] = 500.0;

			SDKCall(g_hSDKFlingPlayer, survivor, flVelocity, 76, tank, 7.0);

			if (iFlingMessage == message || iFlingMessage == 3)
			{
				PrintToChatAll("%s %t", ST_TAG2, "Fling", sTankName, survivor);
			}
		}
		else
		{
			SDKCall(g_hSDKPukePlayer, survivor, tank, true);

			if (iFlingMessage == message || iFlingMessage == 3)
			{
				PrintToChatAll("%s %t", ST_TAG2, "Puke", sTankName, survivor);
			}
		}

		char sFlingEffect[4];
		sFlingEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sFlingEffect[ST_TankType(tank)] : g_sFlingEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sFlingEffect, mode);
	}
}

static float flFlingChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flFlingChance[ST_TankType(tank)] : g_flFlingChance2[ST_TankType(tank)];
}

static int iFlingHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iFlingHit[ST_TankType(tank)] : g_iFlingHit2[ST_TankType(tank)];
}

static int iFlingHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iFlingHitMode[ST_TankType(tank)] : g_iFlingHitMode2[ST_TankType(tank)];
}