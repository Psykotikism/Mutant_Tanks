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

// Super Tanks++: Choke Ability
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
	name = "[ST++] Choke Ability",
	author = ST_AUTHOR,
	description = "The Super Tank sends survivors into space.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bChoke[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sChokeEffect[ST_MAXTYPES + 1][4], g_sChokeEffect2[ST_MAXTYPES + 1][4], g_sChokeMessage[ST_MAXTYPES + 1][3], g_sChokeMessage2[ST_MAXTYPES + 1][3];

float g_flChokeAngle[MAXPLAYERS + 1][3], g_flChokeChance[ST_MAXTYPES + 1], g_flChokeChance2[ST_MAXTYPES + 1], g_flChokeDamage[ST_MAXTYPES + 1], g_flChokeDamage2[ST_MAXTYPES + 1], g_flChokeDelay[ST_MAXTYPES + 1], g_flChokeDelay2[ST_MAXTYPES + 1], g_flChokeDuration[ST_MAXTYPES + 1], g_flChokeDuration2[ST_MAXTYPES + 1], g_flChokeHeight[ST_MAXTYPES + 1], g_flChokeHeight2[ST_MAXTYPES + 1], g_flChokeRange[ST_MAXTYPES + 1], g_flChokeRange2[ST_MAXTYPES + 1], g_flChokeRangeChance[ST_MAXTYPES + 1], g_flChokeRangeChance2[ST_MAXTYPES + 1];

int g_iChokeAbility[ST_MAXTYPES + 1], g_iChokeAbility2[ST_MAXTYPES + 1], g_iChokeHit[ST_MAXTYPES + 1], g_iChokeHit2[ST_MAXTYPES + 1], g_iChokeHitMode[ST_MAXTYPES + 1], g_iChokeHitMode2[ST_MAXTYPES + 1], g_iChokeOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Choke Ability\" only supports Left 4 Dead 1 & 2.");

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

	g_bChoke[client] = false;
	g_iChokeOwner[client] = 0;
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

		if ((iChokeHitMode(attacker) == 0 || iChokeHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vChokeHit(victim, attacker, flChokeChance(attacker), iChokeHit(attacker), "1", "1");
			}
		}
		else if ((iChokeHitMode(victim) == 0 || iChokeHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vChokeHit(attacker, victim, flChokeChance(victim), iChokeHit(victim), "1", "2");
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

				g_iChokeAbility[iIndex] = kvSuperTanks.GetNum("Choke Ability/Ability Enabled", 0);
				g_iChokeAbility[iIndex] = iClamp(g_iChokeAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Choke Ability/Ability Effect", g_sChokeEffect[iIndex], sizeof(g_sChokeEffect[]), "0");
				kvSuperTanks.GetString("Choke Ability/Ability Message", g_sChokeMessage[iIndex], sizeof(g_sChokeMessage[]), "0");
				g_flChokeChance[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Chance", 33.3);
				g_flChokeChance[iIndex] = flClamp(g_flChokeChance[iIndex], 0.0, 100.0);
				g_flChokeDamage[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Damage", 5.0);
				g_flChokeDamage[iIndex] = flClamp(g_flChokeDamage[iIndex], 1.0, 9999999999.0);
				g_flChokeDelay[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Delay", 1.0);
				g_flChokeDelay[iIndex] = flClamp(g_flChokeDelay[iIndex], 0.1, 9999999999.0);
				g_flChokeDuration[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Duration", 5.0);
				g_flChokeDuration[iIndex] = flClamp(g_flChokeDuration[iIndex], 0.1, 9999999999.0);
				g_flChokeHeight[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Height", 300.0);
				g_flChokeHeight[iIndex] = flClamp(g_flChokeHeight[iIndex], 0.1, 9999999999.0);
				g_iChokeHit[iIndex] = kvSuperTanks.GetNum("Choke Ability/Choke Hit", 0);
				g_iChokeHit[iIndex] = iClamp(g_iChokeHit[iIndex], 0, 1);
				g_iChokeHitMode[iIndex] = kvSuperTanks.GetNum("Choke Ability/Choke Hit Mode", 0);
				g_iChokeHitMode[iIndex] = iClamp(g_iChokeHitMode[iIndex], 0, 2);
				g_flChokeRange[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Range", 150.0);
				g_flChokeRange[iIndex] = flClamp(g_flChokeRange[iIndex], 1.0, 9999999999.0);
				g_flChokeRangeChance[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Range Chance", 15.0);
				g_flChokeRangeChance[iIndex] = flClamp(g_flChokeRangeChance[iIndex], 0.0, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iChokeAbility2[iIndex] = kvSuperTanks.GetNum("Choke Ability/Ability Enabled", g_iChokeAbility[iIndex]);
				g_iChokeAbility2[iIndex] = iClamp(g_iChokeAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Choke Ability/Ability Effect", g_sChokeEffect2[iIndex], sizeof(g_sChokeEffect2[]), g_sChokeEffect[iIndex]);
				kvSuperTanks.GetString("Choke Ability/Ability Message", g_sChokeMessage2[iIndex], sizeof(g_sChokeMessage2[]), g_sChokeMessage[iIndex]);
				g_flChokeChance2[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Chance", g_flChokeChance[iIndex]);
				g_flChokeChance2[iIndex] = flClamp(g_flChokeChance2[iIndex], 0.0, 100.0);
				g_flChokeDamage2[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Damage", g_flChokeDamage[iIndex]);
				g_flChokeDamage2[iIndex] = flClamp(g_flChokeDamage2[iIndex], 1.0, 9999999999.0);
				g_flChokeDelay2[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Delay", g_flChokeDelay[iIndex]);
				g_flChokeDelay2[iIndex] = flClamp(g_flChokeDelay2[iIndex], 0.1, 9999999999.0);
				g_flChokeDuration2[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Duration", g_flChokeDuration[iIndex]);
				g_flChokeDuration2[iIndex] = flClamp(g_flChokeDuration2[iIndex], 0.1, 9999999999.0);
				g_flChokeHeight2[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Height", g_flChokeHeight[iIndex]);
				g_flChokeHeight2[iIndex] = flClamp(g_flChokeHeight2[iIndex], 0.1, 9999999999.0);
				g_iChokeHit2[iIndex] = kvSuperTanks.GetNum("Choke Ability/Choke Hit", g_iChokeHit[iIndex]);
				g_iChokeHit2[iIndex] = iClamp(g_iChokeHit2[iIndex], 0, 1);
				g_iChokeHitMode2[iIndex] = kvSuperTanks.GetNum("Choke Ability/Choke Hit Mode", g_iChokeHitMode[iIndex]);
				g_iChokeHitMode2[iIndex] = iClamp(g_iChokeHitMode2[iIndex], 0, 2);
				g_flChokeRange2[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Range", g_flChokeRange[iIndex]);
				g_flChokeRange2[iIndex] = flClamp(g_flChokeRange2[iIndex], 1.0, 9999999999.0);
				g_flChokeRangeChance2[iIndex] = kvSuperTanks.GetFloat("Choke Ability/Choke Range Chance", g_flChokeRangeChance[iIndex]);
				g_flChokeRangeChance2[iIndex] = flClamp(g_flChokeRangeChance2[iIndex], 0.0, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "234") && g_bChoke[iSurvivor])
		{
			SetEntityMoveType(iSurvivor, MOVETYPE_WALK);
			SetEntityGravity(iSurvivor, 1.0);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		int iChokeAbility = !g_bTankConfig[ST_TankType(tank)] ? g_iChokeAbility[ST_TankType(tank)] : g_iChokeAbility2[ST_TankType(tank)];

		float flChokeRange = !g_bTankConfig[ST_TankType(tank)] ? g_flChokeRange[ST_TankType(tank)] : g_flChokeRange2[ST_TankType(tank)],
			flChokeRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flChokeRangeChance[ST_TankType(tank)] : g_flChokeRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, "234"))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flChokeRange)
				{
					vChokeHit(iSurvivor, tank, flChokeRangeChance, iChokeAbility, "2", "3");
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
			if (bIsSurvivor(iSurvivor, "24") && g_bChoke[iSurvivor] && g_iChokeOwner[iSurvivor] == tank)
			{
				g_bChoke[iSurvivor] = false;
				g_iChokeOwner[iSurvivor] = 0;
			}
		}
	}
}

static void vChokeHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bChoke[survivor])
	{
		g_bChoke[survivor] = true;
		g_iChokeOwner[survivor] = tank;

		GetClientEyeAngles(survivor, g_flChokeAngle[survivor]);

		float flChokeDelay = !g_bTankConfig[ST_TankType(tank)] ? g_flChokeDelay[ST_TankType(tank)] : g_flChokeDelay2[ST_TankType(tank)];
		DataPack dpChokeLaunch;
		CreateDataTimer(flChokeDelay, tTimerChokeLaunch, dpChokeLaunch, TIMER_FLAG_NO_MAPCHANGE);
		dpChokeLaunch.WriteCell(GetClientUserId(survivor));
		dpChokeLaunch.WriteCell(GetClientUserId(tank));
		dpChokeLaunch.WriteCell(enabled);
		dpChokeLaunch.WriteString(message);

		char sChokeEffect[4];
		sChokeEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sChokeEffect[ST_TankType(tank)] : g_sChokeEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sChokeEffect, mode);

		char sChokeMessage[3];
		sChokeMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sChokeMessage[ST_TankType(tank)] : g_sChokeMessage2[ST_TankType(tank)];
		if (StrContains(sChokeMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Choke", sTankName, survivor);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			g_bChoke[iPlayer] = false;
			g_iChokeOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bChoke[survivor] = false;
	g_iChokeOwner[survivor] = 0;

	SetEntityMoveType(survivor, MOVETYPE_WALK);
	SetEntityGravity(survivor, 1.0);

	char sChokeMessage[3];
	sChokeMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sChokeMessage[ST_TankType(tank)] : g_sChokeMessage2[ST_TankType(tank)];
	if (StrContains(sChokeMessage, message) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Choke2", survivor);
	}
}

static float flChokeChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flChokeChance[ST_TankType(tank)] : g_flChokeChance2[ST_TankType(tank)];
}

static int iChokeHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iChokeHit[ST_TankType(tank)] : g_iChokeHit2[ST_TankType(tank)];
}

static int iChokeHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iChokeHitMode[ST_TankType(tank)] : g_iChokeHitMode2[ST_TankType(tank)];
}

public Action tTimerChokeLaunch(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bChoke[iSurvivor])
	{
		g_bChoke[iSurvivor] = false;
		g_iChokeOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iChokeAbility = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || iChokeAbility == 0)
	{
		g_bChoke[iSurvivor] = false;
		g_iChokeOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));

	float flChokeHeight = !g_bTankConfig[ST_TankType(iTank)] ? g_flChokeHeight[ST_TankType(iTank)] : g_flChokeHeight2[ST_TankType(iTank)],
		flVelocity[3];
	flVelocity[0] = 0.0;
	flVelocity[1] = 0.0;
	flVelocity[2] = flChokeHeight;

	TeleportEntity(iSurvivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
	SetEntityGravity(iSurvivor, 0.1);

	DataPack dpChokeDamage;
	CreateDataTimer(1.0, tTimerChokeDamage, dpChokeDamage, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	dpChokeDamage.WriteCell(GetClientUserId(iSurvivor));
	dpChokeDamage.WriteCell(GetClientUserId(iTank));
	dpChokeDamage.WriteString(sMessage);
	dpChokeDamage.WriteCell(iChokeAbility);
	dpChokeDamage.WriteFloat(GetEngineTime());

	return Plugin_Continue;
}

public Action tTimerChokeDamage(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bChoke[iSurvivor] = false;
		g_iChokeOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bChoke[iSurvivor])
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iChokeAbility = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flChokeDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flChokeDuration[ST_TankType(iTank)] : g_flChokeDuration2[ST_TankType(iTank)];

	if (iChokeAbility == 0 || (flTime + flChokeDuration) < GetEngineTime())
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	TeleportEntity(iSurvivor, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));

	SetEntityMoveType(iSurvivor, MOVETYPE_NONE);
	SetEntityGravity(iSurvivor, 1.0);

	float flChokeDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_flChokeDamage[ST_TankType(iTank)] : g_flChokeDamage2[ST_TankType(iTank)];
	vDamageEntity(iSurvivor, iTank, flChokeDamage, "16384");

	return Plugin_Continue;
}