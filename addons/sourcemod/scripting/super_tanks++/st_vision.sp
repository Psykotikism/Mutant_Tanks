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

// Super Tanks++: Vision Ability
#include <sourcemod>
#include <sdkhooks>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Vision Ability",
	author = ST_AUTHOR,
	description = "The Super Tank changes the survivors' vision.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1], g_bVision[MAXPLAYERS + 1];

char g_sVisionEffect[ST_MAXTYPES + 1][4], g_sVisionEffect2[ST_MAXTYPES + 1][4], g_sVisionMessage[ST_MAXTYPES + 1][3], g_sVisionMessage2[ST_MAXTYPES + 1][3];

float g_flVisionChance[ST_MAXTYPES + 1], g_flVisionChance2[ST_MAXTYPES + 1], g_flVisionDuration[ST_MAXTYPES + 1], g_flVisionDuration2[ST_MAXTYPES + 1], g_flVisionRange[ST_MAXTYPES + 1], g_flVisionRange2[ST_MAXTYPES + 1], g_flVisionRangeChance[ST_MAXTYPES + 1], g_flVisionRangeChance2[ST_MAXTYPES + 1];

int g_iVisionAbility[ST_MAXTYPES + 1], g_iVisionAbility2[ST_MAXTYPES + 1], g_iVisionFOV[ST_MAXTYPES + 1], g_iVisionFOV2[ST_MAXTYPES + 1], g_iVisionHit[ST_MAXTYPES + 1], g_iVisionHit2[ST_MAXTYPES + 1], g_iVisionHitMode[ST_MAXTYPES + 1], g_iVisionHitMode2[ST_MAXTYPES + 1], g_iVisionOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Vision Ability\" only supports Left 4 Dead 1 & 2.");

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

	g_bVision[client] = false;
	g_iVisionOwner[client] = 0;
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

		if ((iVisionHitMode(attacker) == 0 || iVisionHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsHumanSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vVisionHit(victim, attacker, flVisionChance(attacker), iVisionHit(attacker), "1", "1");
			}
		}
		else if ((iVisionHitMode(victim) == 0 || iVisionHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vVisionHit(attacker, victim, flVisionChance(victim), iVisionHit(victim), "1", "2");
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

				g_iVisionAbility[iIndex] = kvSuperTanks.GetNum("Vision Ability/Ability Enabled", 0);
				g_iVisionAbility[iIndex] = iClamp(g_iVisionAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Vision Ability/Ability Effect", g_sVisionEffect[iIndex], sizeof(g_sVisionEffect[]), "0");
				kvSuperTanks.GetString("Vision Ability/Ability Message", g_sVisionMessage[iIndex], sizeof(g_sVisionMessage[]), "0");
				g_flVisionChance[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Chance", 33.3);
				g_flVisionChance[iIndex] = flClamp(g_flVisionChance[iIndex], 0.0, 100.0);
				g_flVisionDuration[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Duration", 5.0);
				g_flVisionDuration[iIndex] = flClamp(g_flVisionDuration[iIndex], 0.1, 9999999999.0);
				g_iVisionFOV[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision FOV", 160);
				g_iVisionFOV[iIndex] = iClamp(g_iVisionFOV[iIndex], 1, 160);
				g_iVisionHit[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Hit", 0);
				g_iVisionHit[iIndex] = iClamp(g_iVisionHit[iIndex], 0, 1);
				g_iVisionHitMode[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Hit Mode", 0);
				g_iVisionHitMode[iIndex] = iClamp(g_iVisionHitMode[iIndex], 0, 2);
				g_flVisionRange[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Range", 150.0);
				g_flVisionRange[iIndex] = flClamp(g_flVisionRange[iIndex], 1.0, 9999999999.0);
				g_flVisionRangeChance[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Range Chance", 15.0);
				g_flVisionRangeChance[iIndex] = flClamp(g_flVisionRangeChance[iIndex], 0.0, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iVisionAbility2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Ability Enabled", g_iVisionAbility[iIndex]);
				g_iVisionAbility2[iIndex] = iClamp(g_iVisionAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Vision Ability/Ability Effect", g_sVisionEffect2[iIndex], sizeof(g_sVisionEffect2[]), g_sVisionEffect[iIndex]);
				kvSuperTanks.GetString("Vision Ability/Ability Message", g_sVisionMessage2[iIndex], sizeof(g_sVisionMessage2[]), g_sVisionMessage[iIndex]);
				g_flVisionChance2[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Chance", g_flVisionChance[iIndex]);
				g_flVisionChance2[iIndex] = flClamp(g_flVisionChance2[iIndex], 0.0, 100.0);
				g_flVisionDuration2[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Duration", g_flVisionDuration[iIndex]);
				g_flVisionDuration2[iIndex] = flClamp(g_flVisionDuration2[iIndex], 0.1, 9999999999.0);
				g_iVisionFOV2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision FOV", g_iVisionFOV[iIndex]);
				g_iVisionFOV2[iIndex] = iClamp(g_iVisionFOV2[iIndex], 1, 160);
				g_iVisionHit2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Hit", g_iVisionHit[iIndex]);
				g_iVisionHit2[iIndex] = iClamp(g_iVisionHit2[iIndex], 0, 1);
				g_iVisionHitMode2[iIndex] = kvSuperTanks.GetNum("Vision Ability/Vision Hit Mode", g_iVisionHitMode[iIndex]);
				g_iVisionHitMode2[iIndex] = iClamp(g_iVisionHitMode2[iIndex], 0, 2);
				g_flVisionRange2[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Range", g_flVisionRange[iIndex]);
				g_flVisionRange2[iIndex] = flClamp(g_flVisionRange2[iIndex], 1.0, 9999999999.0);
				g_flVisionRangeChance2[iIndex] = kvSuperTanks.GetFloat("Vision Ability/Vision Range Chance", g_flVisionRangeChance[iIndex]);
				g_flVisionRangeChance2[iIndex] = flClamp(g_flVisionRangeChance2[iIndex], 0.0, 100.0);
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
		if (bIsHumanSurvivor(iSurvivor) && g_bVision[iSurvivor])
		{
			SetEntProp(iSurvivor, Prop_Send, "m_iFOV", 90);
			SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", 90);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		int iVisionAbility = !g_bTankConfig[ST_TankType(tank)] ? g_iVisionAbility[ST_TankType(tank)] : g_iVisionAbility2[ST_TankType(tank)];

		float flVisionRange = !g_bTankConfig[ST_TankType(tank)] ? g_flVisionRange[ST_TankType(tank)] : g_flVisionRange2[ST_TankType(tank)],
			flVisionRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flVisionRangeChance[ST_TankType(tank)] : g_flVisionRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flVisionRange)
				{
					vVisionHit(iSurvivor, tank, flVisionRangeChance, iVisionAbility, "2", "3");
				}
			}
		}
	}
}

public void ST_BossStage(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(iSurvivor) && g_bVision[iSurvivor] && g_iVisionOwner[iSurvivor] == tank)
			{
				g_bVision[iSurvivor] = false;
				g_iVisionOwner[iSurvivor] = 0;
			}
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bVision[iPlayer] = false;
			g_iVisionOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, const char[] message)
{
	g_bVision[survivor] = false;
	g_iVisionOwner[survivor] = 0;

	SetEntProp(survivor, Prop_Send, "m_iFOV", 90);
	SetEntProp(survivor, Prop_Send, "m_iDefaultFOV", 90);

	char sVisionMessage[3];
	sVisionMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sVisionMessage[ST_TankType(tank)] : g_sVisionMessage2[ST_TankType(tank)];
	if (StrContains(sVisionMessage, message) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Vision2", survivor, 90);
	}
}

static void vVisionHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsHumanSurvivor(survivor) && !g_bVision[survivor])
	{
		g_bVision[survivor] = true;
		g_iVisionOwner[survivor] = tank;

		DataPack dpVision;
		CreateDataTimer(0.1, tTimerVision, dpVision, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpVision.WriteCell(GetClientUserId(survivor));
		dpVision.WriteCell(GetClientUserId(tank));
		dpVision.WriteString(message);
		dpVision.WriteCell(enabled);
		dpVision.WriteFloat(GetEngineTime());

		char sVisionEffect[4];
		sVisionEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sVisionEffect[ST_TankType(tank)] : g_sVisionEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sVisionEffect, mode);

		char sVisionMessage[3];
		sVisionMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sVisionMessage[ST_TankType(tank)] : g_sVisionMessage2[ST_TankType(tank)];
		if (StrContains(sVisionMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Vision", sTankName, survivor, iVisionFOV(tank));
		}
	}
}

static float flVisionChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flVisionChance[ST_TankType(tank)] : g_flVisionChance2[ST_TankType(tank)];
}

static int iVisionFOV(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iVisionFOV[ST_TankType(tank)] : g_iVisionFOV2[ST_TankType(tank)];
}

static int iVisionHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iVisionHit[ST_TankType(tank)] : g_iVisionHit2[ST_TankType(tank)];
}

static int iVisionHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iVisionHitMode[ST_TankType(tank)] : g_iVisionHitMode2[ST_TankType(tank)];
}

public Action tTimerVision(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsHumanSurvivor(iSurvivor))
	{
		g_bVision[iSurvivor] = false;
		g_iVisionOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bVision[iSurvivor])
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	int iVisionAbility = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flVisionDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flVisionDuration[ST_TankType(iTank)] : g_flVisionDuration2[ST_TankType(iTank)];

	if (iVisionAbility == 0 || (flTime + flVisionDuration) < GetEngineTime())
	{
		vReset2(iSurvivor, iTank, sMessage);

		return Plugin_Stop;
	}

	SetEntProp(iSurvivor, Prop_Send, "m_iFOV", iVisionFOV(iTank));
	SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", iVisionFOV(iTank));

	return Plugin_Continue;
}