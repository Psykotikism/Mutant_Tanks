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

// Super Tanks++: Shove Ability
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
	name = "[ST++] Shove Ability",
	author = ST_AUTHOR,
	description = "The Super Tank shoves survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bShove[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sShoveEffect[ST_MAXTYPES + 1][4], g_sShoveEffect2[ST_MAXTYPES + 1][4], g_sShoveMessage[ST_MAXTYPES + 1][3], g_sShoveMessage2[ST_MAXTYPES + 1][3];

float g_flShoveChance[ST_MAXTYPES + 1], g_flShoveChance2[ST_MAXTYPES + 1], g_flShoveDuration[ST_MAXTYPES + 1], g_flShoveDuration2[ST_MAXTYPES + 1], g_flShoveInterval[ST_MAXTYPES + 1], g_flShoveInterval2[ST_MAXTYPES + 1], g_flShoveRange[ST_MAXTYPES + 1], g_flShoveRange2[ST_MAXTYPES + 1], g_flShoveRangeChance[ST_MAXTYPES + 1], g_flShoveRangeChance2[ST_MAXTYPES + 1];

Handle g_hSDKShovePlayer;

int g_iShoveAbility[ST_MAXTYPES + 1], g_iShoveAbility2[ST_MAXTYPES + 1], g_iShoveHit[ST_MAXTYPES + 1], g_iShoveHit2[ST_MAXTYPES + 1], g_iShoveHitMode[ST_MAXTYPES + 1], g_iShoveHitMode2[ST_MAXTYPES + 1], g_iShoveOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Shove Ability\" only supports Left 4 Dead 1 & 2.");

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
	PrepSDKCall_SetFromConf(gdSuperTanks, SDKConf_Signature, "CTerrorPlayer_OnStaggered");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	g_hSDKShovePlayer = EndPrepSDKCall();

	if (g_hSDKShovePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnStaggered\" signature is outdated.", ST_TAG);
	}

	delete gdSuperTanks;

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

	g_bShove[client] = false;
	g_iShoveOwner[client] = 0;
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

		if ((iShoveHitMode(attacker) == 0 || iShoveHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vShoveHit(victim, attacker, flShoveChance(attacker), iShoveHit(attacker), "1", "1");
			}
		}
		else if ((iShoveHitMode(victim) == 0 || iShoveHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vShoveHit(attacker, victim, flShoveChance(victim), iShoveHit(victim), "1", "2");
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

				g_iShoveAbility[iIndex] = kvSuperTanks.GetNum("Shove Ability/Ability Enabled", 0);
				g_iShoveAbility[iIndex] = iClamp(g_iShoveAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Shove Ability/Ability Effect", g_sShoveEffect[iIndex], sizeof(g_sShoveEffect[]), "0");
				kvSuperTanks.GetString("Shove Ability/Ability Message", g_sShoveMessage[iIndex], sizeof(g_sShoveMessage[]), "0");
				g_flShoveChance[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Chance", 33.3);
				g_flShoveChance[iIndex] = flClamp(g_flShoveChance[iIndex], 0.0, 100.0);
				g_flShoveDuration[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Duration", 5.0);
				g_flShoveDuration[iIndex] = flClamp(g_flShoveDuration[iIndex], 0.1, 9999999999.0);
				g_iShoveHit[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit", 0);
				g_iShoveHit[iIndex] = iClamp(g_iShoveHit[iIndex], 0, 1);
				g_iShoveHitMode[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit Mode", 0);
				g_iShoveHitMode[iIndex] = iClamp(g_iShoveHitMode[iIndex], 0, 2);
				g_flShoveInterval[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Interval", 1.0);
				g_flShoveInterval[iIndex] = flClamp(g_flShoveInterval[iIndex], 0.1, 9999999999.0);
				g_flShoveRange[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Range", 150.0);
				g_flShoveRange[iIndex] = flClamp(g_flShoveRange[iIndex], 1.0, 9999999999.0);
				g_flShoveRangeChance[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Range Chance", 15.0);
				g_flShoveRangeChance[iIndex] = flClamp(g_flShoveRangeChance[iIndex], 0.0, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iShoveAbility2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Ability Enabled", g_iShoveAbility[iIndex]);
				g_iShoveAbility2[iIndex] = iClamp(g_iShoveAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Shove Ability/Ability Effect", g_sShoveEffect2[iIndex], sizeof(g_sShoveEffect2[]), g_sShoveEffect[iIndex]);
				kvSuperTanks.GetString("Shove Ability/Ability Message", g_sShoveMessage2[iIndex], sizeof(g_sShoveMessage2[]), g_sShoveMessage[iIndex]);
				g_flShoveChance2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Chance", g_flShoveChance[iIndex]);
				g_flShoveChance2[iIndex] = flClamp(g_flShoveChance2[iIndex], 0.0, 100.0);
				g_flShoveDuration2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Duration", g_flShoveDuration[iIndex]);
				g_flShoveDuration2[iIndex] = flClamp(g_flShoveDuration2[iIndex], 0.1, 9999999999.0);
				g_iShoveHit2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit", g_iShoveHit[iIndex]);
				g_iShoveHit2[iIndex] = iClamp(g_iShoveHit2[iIndex], 0, 1);
				g_iShoveHitMode2[iIndex] = kvSuperTanks.GetNum("Shove Ability/Shove Hit Mode", g_iShoveHitMode[iIndex]);
				g_iShoveHitMode2[iIndex] = iClamp(g_iShoveHitMode2[iIndex], 0, 2);
				g_flShoveInterval2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Interval", g_flShoveInterval[iIndex]);
				g_flShoveInterval2[iIndex] = flClamp(g_flShoveInterval2[iIndex], 0.1, 9999999999.0);
				g_flShoveRange2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Range", g_flShoveRange[iIndex]);
				g_flShoveRange2[iIndex] = flClamp(g_flShoveRange2[iIndex], 1.0, 9999999999.0);
				g_flShoveRangeChance2[iIndex] = kvSuperTanks.GetFloat("Shove Ability/Shove Range Chance", g_flShoveRangeChance[iIndex]);
				g_flShoveRangeChance2[iIndex] = flClamp(g_flShoveRangeChance2[iIndex], 0.0, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		int iShoveAbility = !g_bTankConfig[ST_TankType(tank)] ? g_iShoveAbility[ST_TankType(tank)] : g_iShoveAbility2[ST_TankType(tank)];

		float flShoveRange = !g_bTankConfig[ST_TankType(tank)] ? g_flShoveRange[ST_TankType(tank)] : g_flShoveRange2[ST_TankType(tank)],
			flShoveRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flShoveRangeChance[ST_TankType(tank)] : g_flShoveRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, "234"))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flShoveRange)
				{
					vShoveHit(iSurvivor, tank, flShoveRangeChance, iShoveAbility, "2", "3");
				}
			}
		}
	}
}

public void ST_ChangeType(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, "24") && g_bShove[iSurvivor] && g_iShoveOwner[iSurvivor] == tank)
			{
				g_bShove[iSurvivor] = false;
				g_iShoveOwner[iSurvivor] = 0;
			}
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			g_bShove[iPlayer] = false;
			g_iShoveOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bShove[survivor] = false;
	g_iShoveOwner[survivor] = 0;

	char sShoveMessage[3];
	sShoveMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sShoveMessage[ST_TankType(tank)] : g_sShoveMessage2[ST_TankType(tank)];
	if (StrContains(sShoveMessage, message) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Shove2", survivor);
	}
}

static void vShoveHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bShove[survivor])
	{
		g_bShove[survivor] = true;
		g_iShoveOwner[survivor] = tank;

		float flShoveInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flShoveInterval[ST_TankType(tank)] : g_flShoveInterval2[ST_TankType(tank)];
		DataPack dpShove;
		CreateDataTimer(flShoveInterval, tTimerShove, dpShove, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpShove.WriteCell(GetClientUserId(survivor));
		dpShove.WriteCell(GetClientUserId(tank));
		dpShove.WriteString(message);
		dpShove.WriteCell(enabled);
		dpShove.WriteFloat(GetEngineTime());

		char sShoveEffect[4];
		sShoveEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sShoveEffect[ST_TankType(tank)] : g_sShoveEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sShoveEffect, mode);

		char sShoveMessage[3];
		sShoveMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sShoveMessage[ST_TankType(tank)] : g_sShoveMessage2[ST_TankType(tank)];
		if (StrContains(sShoveMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Shove", sTankName, survivor);
		}
	}
}

static float flShoveChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flShoveChance[ST_TankType(tank)] : g_flShoveChance2[ST_TankType(tank)];
}

static int iShoveHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iShoveHit[ST_TankType(tank)] : g_iShoveHit2[ST_TankType(tank)];
}

static int iShoveHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iShoveHitMode[ST_TankType(tank)] : g_iShoveHitMode2[ST_TankType(tank)];
}

public Action tTimerShove(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bShove[iSurvivor] = false;
		g_iShoveOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bShove[iSurvivor])
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iShoveAbility = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flShoveDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flShoveDuration[ST_TankType(iTank)] : g_flShoveDuration2[ST_TankType(iTank)];

	if (iShoveAbility == 0 || (flTime + flShoveDuration) < GetEngineTime())
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	float flOrigin[3];
	GetClientAbsOrigin(iSurvivor, flOrigin);

	SDKCall(g_hSDKShovePlayer, iSurvivor, iSurvivor, flOrigin);

	return Plugin_Continue;
}