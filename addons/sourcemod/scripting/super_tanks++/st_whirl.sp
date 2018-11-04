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

// Super Tanks++: Whirl Ability
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
	name = "[ST++] Whirl Ability",
	author = ST_AUTHOR,
	description = "The Super Tank makes survivors' screens whirl.",
	version = ST_VERSION,
	url = ST_URL
};

#define SPRITE_DOT "sprites/dot.vmt"

bool g_bCloneInstalled, g_bWhirl[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sWhirlAxis[ST_MAXTYPES + 1][7], g_sWhirlAxis2[ST_MAXTYPES + 1][7], g_sWhirlEffect[ST_MAXTYPES + 1][4], g_sWhirlEffect2[ST_MAXTYPES + 1][4], g_sWhirlMessage[ST_MAXTYPES + 1][3], g_sWhirlMessage2[ST_MAXTYPES + 1][3];

float g_flWhirlChance[ST_MAXTYPES + 1], g_flWhirlChance2[ST_MAXTYPES + 1], g_flWhirlDuration[ST_MAXTYPES + 1], g_flWhirlDuration2[ST_MAXTYPES + 1], g_flWhirlRange[ST_MAXTYPES + 1], g_flWhirlRange2[ST_MAXTYPES + 1], g_flWhirlSpeed[ST_MAXTYPES + 1], g_flWhirlSpeed2[ST_MAXTYPES + 1], g_flWhirlRangeChance[ST_MAXTYPES + 1], g_flWhirlRangeChance2[ST_MAXTYPES + 1];

int g_iWhirlAbility[ST_MAXTYPES + 1], g_iWhirlAbility2[ST_MAXTYPES + 1], g_iWhirlHit[ST_MAXTYPES + 1], g_iWhirlHit2[ST_MAXTYPES + 1], g_iWhirlHitMode[ST_MAXTYPES + 1], g_iWhirlHitMode2[ST_MAXTYPES + 1], g_iWhirlOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Whirl Ability\" only supports Left 4 Dead 1 & 2.");

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
	PrecacheModel(SPRITE_DOT, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	g_bWhirl[client] = false;
	g_iWhirlOwner[client] = 0;
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

		if ((iWhirlHitMode(attacker) == 0 || iWhirlHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsHumanSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vWhirlHit(victim, attacker, flWhirlChance(attacker), iWhirlHit(attacker), "1", "1");
			}
		}
		else if ((iWhirlHitMode(victim) == 0 || iWhirlHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vWhirlHit(attacker, victim, flWhirlChance(victim), iWhirlHit(victim), "1", "2");
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

				g_iWhirlAbility[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Ability Enabled", 0);
				g_iWhirlAbility[iIndex] = iClamp(g_iWhirlAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Whirl Ability/Ability Effect", g_sWhirlEffect[iIndex], sizeof(g_sWhirlEffect[]), "0");
				kvSuperTanks.GetString("Whirl Ability/Ability Message", g_sWhirlMessage[iIndex], sizeof(g_sWhirlMessage[]), "0");
				kvSuperTanks.GetString("Whirl Ability/Whirl Axis", g_sWhirlAxis[iIndex], sizeof(g_sWhirlAxis[]), "123");
				g_flWhirlChance[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Chance", 33.3);
				g_flWhirlChance[iIndex] = flClamp(g_flWhirlChance[iIndex], 0.0, 100.0);
				g_flWhirlDuration[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Duration", 5.0);
				g_flWhirlDuration[iIndex] = flClamp(g_flWhirlDuration[iIndex], 0.1, 9999999999.0);
				g_iWhirlHit[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Whirl Hit", 0);
				g_iWhirlHit[iIndex] = iClamp(g_iWhirlHit[iIndex], 0, 1);
				g_iWhirlHitMode[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Whirl Hit Mode", 0);
				g_iWhirlHitMode[iIndex] = iClamp(g_iWhirlHitMode[iIndex], 0, 2);
				g_flWhirlRange[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Range", 150.0);
				g_flWhirlRange[iIndex] = flClamp(g_flWhirlRange[iIndex], 1.0, 9999999999.0);
				g_flWhirlRangeChance[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Range Chance", 15.0);
				g_flWhirlRangeChance[iIndex] = flClamp(g_flWhirlRangeChance[iIndex], 0.0, 100.0);
				g_flWhirlSpeed[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Speed", 500.0);
				g_flWhirlSpeed[iIndex] = flClamp(g_flWhirlSpeed[iIndex], 1.0, 9999999999.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iWhirlAbility2[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Ability Enabled", g_iWhirlAbility[iIndex]);
				g_iWhirlAbility2[iIndex] = iClamp(g_iWhirlAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Whirl Ability/Ability Effect", g_sWhirlEffect2[iIndex], sizeof(g_sWhirlEffect2[]), g_sWhirlEffect[iIndex]);
				kvSuperTanks.GetString("Whirl Ability/Ability Message", g_sWhirlMessage2[iIndex], sizeof(g_sWhirlMessage2[]), g_sWhirlMessage[iIndex]);
				kvSuperTanks.GetString("Whirl Ability/Whirl Axis", g_sWhirlAxis2[iIndex], sizeof(g_sWhirlAxis2[]), g_sWhirlAxis[iIndex]);
				g_flWhirlChance2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Chance", g_flWhirlChance[iIndex]);
				g_flWhirlChance2[iIndex] = flClamp(g_flWhirlChance2[iIndex], 0.0, 100.0);
				g_flWhirlDuration2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Duration", g_flWhirlDuration[iIndex]);
				g_flWhirlDuration2[iIndex] = flClamp(g_flWhirlDuration2[iIndex], 0.1, 9999999999.0);
				g_iWhirlHit2[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Whirl Hit", g_iWhirlHit[iIndex]);
				g_iWhirlHit2[iIndex] = iClamp(g_iWhirlHit2[iIndex], 0, 1);
				g_iWhirlHitMode2[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Whirl Hit Mode", g_iWhirlHitMode[iIndex]);
				g_iWhirlHitMode2[iIndex] = iClamp(g_iWhirlHitMode2[iIndex], 0, 2);
				g_flWhirlRange2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Range", g_flWhirlRange[iIndex]);
				g_flWhirlRange2[iIndex] = flClamp(g_flWhirlRange2[iIndex], 1.0, 9999999999.0);
				g_flWhirlRangeChance2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Range Chance", g_flWhirlRangeChance[iIndex]);
				g_flWhirlRangeChance2[iIndex] = flClamp(g_flWhirlRangeChance2[iIndex], 0.0, 100.0);
				g_flWhirlSpeed2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Speed", g_flWhirlSpeed[iIndex]);
				g_flWhirlSpeed2[iIndex] = flClamp(g_flWhirlSpeed2[iIndex], 1.0, 9999999999.0);
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
		if (bIsHumanSurvivor(iSurvivor) && g_bWhirl[iSurvivor])
		{
			SetClientViewEntity(iSurvivor, iSurvivor);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flWhirlRange = !g_bTankConfig[ST_TankType(tank)] ? g_flWhirlRange[ST_TankType(tank)] : g_flWhirlRange2[ST_TankType(tank)],
			flWhirlRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flWhirlRangeChance[ST_TankType(tank)] : g_flWhirlRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flWhirlRange)
				{
					vWhirlHit(iSurvivor, tank, flWhirlRangeChance, iWhirlAbility(tank), "2", "3");
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
			if (bIsHumanSurvivor(iSurvivor) && g_bWhirl[iSurvivor] && g_iWhirlOwner[iSurvivor] == tank)
			{
				g_bWhirl[iSurvivor] = false;
				g_iWhirlOwner[iSurvivor] = 0;
			}
		}
	}
}

static void vWhirlHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsHumanSurvivor(survivor) && !g_bWhirl[survivor])
	{
		int iWhirl = CreateEntityByName("env_sprite");
		if (!bIsValidEntity(iWhirl))
		{
			return;
		}

		g_bWhirl[survivor] = true;
		g_iWhirlOwner[survivor] = tank;

		float flEyePos[3], flAngles[3];
		GetClientEyePosition(survivor, flEyePos);
		GetClientEyeAngles(survivor, flAngles);

		SetEntityModel(iWhirl, SPRITE_DOT);
		SetEntityRenderMode(iWhirl, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iWhirl, 0, 0, 0, 0);
		DispatchSpawn(iWhirl);

		TeleportEntity(iWhirl, flEyePos, flAngles, NULL_VECTOR);
		TeleportEntity(survivor, NULL_VECTOR, flAngles, NULL_VECTOR);

		vSetEntityParent(iWhirl, survivor);
		SetClientViewEntity(survivor, iWhirl);

		char sNumbers = !g_bTankConfig[ST_TankType(tank)] ? g_sWhirlAxis[ST_TankType(tank)][GetRandomInt(0, strlen(g_sWhirlAxis[ST_TankType(tank)]) - 1)] : g_sWhirlAxis2[ST_TankType(tank)][GetRandomInt(0, strlen(g_sWhirlAxis2[ST_TankType(tank)]) - 1)];
		int iAxis;
		switch (sNumbers)
		{
			case '1': iAxis = 0;
			case '2': iAxis = 1;
			case '3': iAxis = 2;
			default: iAxis = GetRandomInt(0, 2);
		}

		DataPack dpWhirl;
		CreateDataTimer(0.1, tTimerWhirl, dpWhirl, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpWhirl.WriteCell(EntIndexToEntRef(iWhirl));
		dpWhirl.WriteCell(GetClientUserId(survivor));
		dpWhirl.WriteCell(GetClientUserId(tank));
		dpWhirl.WriteString(message);
		dpWhirl.WriteCell(enabled);
		dpWhirl.WriteCell(iAxis);
		dpWhirl.WriteFloat(GetEngineTime());

		char sWhirlEffect[4];
		sWhirlEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sWhirlEffect[ST_TankType(tank)] : g_sWhirlEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sWhirlEffect, mode);

		char sWhirlMessage[3];
		sWhirlMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sWhirlMessage[ST_TankType(tank)] : g_sWhirlMessage2[ST_TankType(tank)];
		if (StrContains(sWhirlMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Whirl", sTankName, survivor);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bWhirl[iPlayer] = false;
			g_iWhirlOwner[iPlayer] = 0;
		}
	}
}

static void vReset2(int survivor, int tank, int entity, const char[] message)
{
	vStopWhirl(survivor, entity);

	SetClientViewEntity(survivor, survivor);

	char sWhirlMessage[3];
	sWhirlMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sWhirlMessage[ST_TankType(tank)] : g_sWhirlMessage2[ST_TankType(tank)];
	if (StrContains(sWhirlMessage, message) != -1)
	{
		PrintToChatAll("%s %t", ST_TAG2, "Whirl2", survivor);
	}
}

static void vStopWhirl(int survivor, int entity)
{
	g_bWhirl[survivor] = false;
	g_iWhirlOwner[survivor] = 0;

	RemoveEntity(entity);
}

static float flWhirlChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flWhirlChance[ST_TankType(tank)] : g_flWhirlChance2[ST_TankType(tank)];
}

static int iWhirlAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWhirlAbility[ST_TankType(tank)] : g_iWhirlAbility2[ST_TankType(tank)];
}

static int iWhirlHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWhirlHit[ST_TankType(tank)] : g_iWhirlHit2[ST_TankType(tank)];
}

static int iWhirlHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWhirlHitMode[ST_TankType(tank)] : g_iWhirlHitMode2[ST_TankType(tank)];
}

public Action tTimerWhirl(Handle timer, DataPack pack)
{
	pack.Reset();

	int iWhirl = EntRefToEntIndex(pack.ReadCell()), iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (iWhirl == INVALID_ENT_REFERENCE || !bIsValidEntity(iWhirl))
	{
		g_bWhirl[iSurvivor] = false;
		g_iWhirlOwner[iSurvivor] = 0;

		SetClientViewEntity(iSurvivor, iSurvivor);

		return Plugin_Stop;
	}

	if (!bIsHumanSurvivor(iSurvivor))
	{
		vStopWhirl(iSurvivor, iWhirl);

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	char sMessage[3];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bWhirl[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iWhirl, sMessage);

		return Plugin_Stop;
	}

	int iWhirlEnabled = pack.ReadCell(), iWhirlAxis = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flWhirlDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flWhirlDuration[ST_TankType(iTank)] : g_flWhirlDuration2[ST_TankType(iTank)];

	if (iWhirlEnabled == 0 || (flTime + flWhirlDuration) < GetEngineTime())
	{
		vReset2(iSurvivor, iTank, iWhirl, sMessage);

		return Plugin_Stop;
	}

	float flWhirlSpeed = !g_bTankConfig[ST_TankType(iTank)] ? g_flWhirlSpeed[ST_TankType(iTank)] : g_flWhirlSpeed2[ST_TankType(iTank)],
		flAngles[3];
	GetEntPropVector(iWhirl, Prop_Send, "m_angRotation", flAngles);

	flAngles[iWhirlAxis] += flWhirlSpeed;
	TeleportEntity(iWhirl, NULL_VECTOR, flAngles, NULL_VECTOR);

	return Plugin_Continue;
}