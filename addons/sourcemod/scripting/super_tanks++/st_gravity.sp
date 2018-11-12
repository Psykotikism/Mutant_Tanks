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

// Super Tanks++: Gravity Ability
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
	name = "[ST++] Gravity Ability",
	author = ST_AUTHOR,
	description = "The Super Tank pulls in or pushes away survivors and any other nearby infected, and changes the survivors' gravity.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bGravity[MAXPLAYERS + 1], g_bGravity2[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sGravityEffect[ST_MAXTYPES + 1][4], g_sGravityEffect2[ST_MAXTYPES + 1][4], g_sGravityMessage[ST_MAXTYPES + 1][4], g_sGravityMessage2[ST_MAXTYPES + 1][4];

float g_flGravityChance[ST_MAXTYPES + 1], g_flGravityChance2[ST_MAXTYPES + 1], g_flGravityDuration[ST_MAXTYPES + 1], g_flGravityDuration2[ST_MAXTYPES + 1], g_flGravityForce[ST_MAXTYPES + 1], g_flGravityForce2[ST_MAXTYPES + 1], g_flGravityRange[ST_MAXTYPES + 1], g_flGravityRange2[ST_MAXTYPES + 1], g_flGravityRangeChance[ST_MAXTYPES + 1], g_flGravityRangeChance2[ST_MAXTYPES + 1], g_flGravityValue[ST_MAXTYPES + 1], g_flGravityValue2[ST_MAXTYPES + 1];

int g_iGravityAbility[ST_MAXTYPES + 1], g_iGravityAbility2[ST_MAXTYPES + 1], g_iGravityHit[ST_MAXTYPES + 1], g_iGravityHit2[ST_MAXTYPES + 1], g_iGravityHitMode[ST_MAXTYPES + 1], g_iGravityHitMode2[ST_MAXTYPES + 1], g_iGravityOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Gravity Ability\" only supports Left 4 Dead 1 & 2.");

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

	g_bGravity[client] = false;
	g_bGravity2[client] = false;
	g_iGravityOwner[client] = 0;
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

		if ((iGravityHitMode(attacker) == 0 || iGravityHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vGravityHit(victim, attacker, flGravityChance(attacker), iGravityHit(attacker), "1", "1");
			}
		}
		else if ((iGravityHitMode(victim) == 0 || iGravityHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vGravityHit(attacker, victim, flGravityChance(victim), iGravityHit(victim), "1", "2");
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

				g_iGravityAbility[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Ability Enabled", 0);
				g_iGravityAbility[iIndex] = iClamp(g_iGravityAbility[iIndex], 0, 3);
				kvSuperTanks.GetString("Gravity Ability/Ability Effect", g_sGravityEffect[iIndex], sizeof(g_sGravityEffect[]), "0");
				kvSuperTanks.GetString("Gravity Ability/Ability Message", g_sGravityMessage[iIndex], sizeof(g_sGravityMessage[]), "0");
				g_flGravityChance[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Chance", 33.3);
				g_flGravityChance[iIndex] = flClamp(g_flGravityChance[iIndex], 0.0, 100.0);
				g_flGravityDuration[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Duration", 5.0);
				g_flGravityDuration[iIndex] = flClamp(g_flGravityDuration[iIndex], 0.1, 9999999999.0);
				g_flGravityForce[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Force", -50.0);
				g_flGravityForce[iIndex] = flClamp(g_flGravityForce[iIndex], -100.0, 100.0);
				g_iGravityHit[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit", 0);
				g_iGravityHit[iIndex] = iClamp(g_iGravityHit[iIndex], 0, 1);
				g_iGravityHitMode[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit Mode", 0);
				g_iGravityHitMode[iIndex] = iClamp(g_iGravityHitMode[iIndex], 0, 2);
				g_flGravityRange[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Range", 150.0);
				g_flGravityRange[iIndex] = flClamp(g_flGravityRange[iIndex], 1.0, 9999999999.0);
				g_flGravityRangeChance[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Range Chance", 15.0);
				g_flGravityRangeChance[iIndex] = flClamp(g_flGravityRangeChance[iIndex], 0.0, 100.0);
				g_flGravityValue[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Value", 0.3);
				g_flGravityValue[iIndex] = flClamp(g_flGravityValue[iIndex], 0.1, 9999999999.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iGravityAbility2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Ability Enabled", g_iGravityAbility[iIndex]);
				g_iGravityAbility2[iIndex] = iClamp(g_iGravityAbility2[iIndex], 0, 3);
				kvSuperTanks.GetString("Gravity Ability/Ability Effect", g_sGravityEffect2[iIndex], sizeof(g_sGravityEffect2[]), g_sGravityEffect[iIndex]);
				kvSuperTanks.GetString("Gravity Ability/Ability Message", g_sGravityMessage2[iIndex], sizeof(g_sGravityMessage2[]), g_sGravityMessage[iIndex]);
				g_flGravityChance2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Chance", g_flGravityChance[iIndex]);
				g_flGravityChance2[iIndex] = flClamp(g_flGravityChance2[iIndex], 0.0, 100.0);
				g_flGravityDuration2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Duration", g_flGravityDuration[iIndex]);
				g_flGravityDuration2[iIndex] = flClamp(g_flGravityDuration2[iIndex], 0.1, 9999999999.0);
				g_flGravityForce2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Force", g_flGravityForce[iIndex]);
				g_flGravityForce2[iIndex] = flClamp(g_flGravityForce2[iIndex], -100.0, 100.0);
				g_iGravityHit2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit", g_iGravityHit[iIndex]);
				g_iGravityHit2[iIndex] = iClamp(g_iGravityHit2[iIndex], 0, 1);
				g_iGravityHitMode2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit Mode", g_iGravityHitMode[iIndex]);
				g_iGravityHitMode2[iIndex] = iClamp(g_iGravityHitMode2[iIndex], 0, 2);
				g_flGravityRange2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Range", g_flGravityRange[iIndex]);
				g_flGravityRange2[iIndex] = flClamp(g_flGravityRange2[iIndex], 1.0, 9999999999.0);
				g_flGravityRangeChance2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Range Chance", g_flGravityRangeChance[iIndex]);
				g_flGravityRangeChance2[iIndex] = flClamp(g_flGravityRangeChance2[iIndex], 0.0, 100.0);
				g_flGravityValue2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Value", g_flGravityValue[iIndex]);
				g_flGravityValue2[iIndex] = flClamp(g_flGravityValue2[iIndex], 0.1, 9999999999.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank, "234"))
		{
			vRemoveGravity(iTank);
		}
	}
}

public void ST_EventHandler(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank, "024") && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveGravity(iTank);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		float flGravityRange = !g_bTankConfig[ST_TankType(tank)] ? g_flGravityRange[ST_TankType(tank)] : g_flGravityRange2[ST_TankType(tank)],
			flGravityRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flGravityRangeChance[ST_TankType(tank)] : g_flGravityRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, "234"))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flGravityRange)
				{
					vGravityHit(iSurvivor, tank, flGravityRangeChance, iGravityAbility(tank), "2", "3");
				}
			}
		}

		if ((iGravityAbility(tank) == 2 || iGravityAbility(tank) == 3) && !g_bGravity[tank])
		{
			g_bGravity[tank] = true;

			int iBlackhole = CreateEntityByName("point_push");
			if (bIsValidEntity(iBlackhole))
			{
				float flGravityForce = !g_bTankConfig[ST_TankType(tank)] ? g_flGravityForce[ST_TankType(tank)] : g_flGravityForce2[ST_TankType(tank)],
					flOrigin[3], flAngles[3];
				GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
				GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);
				flAngles[0] += -90.0;

				DispatchKeyValueVector(iBlackhole, "origin", flOrigin);
				DispatchKeyValueVector(iBlackhole, "angles", flAngles);
				DispatchKeyValue(iBlackhole, "radius", "750");
				DispatchKeyValueFloat(iBlackhole, "magnitude", flGravityForce);
				DispatchKeyValue(iBlackhole, "spawnflags", "8");
				vSetEntityParent(iBlackhole, tank);
				AcceptEntityInput(iBlackhole, "Enable");
				SetEntPropEnt(iBlackhole, Prop_Send, "m_hOwnerEntity", tank);

				if (bIsValidGame())
				{
					SetEntProp(iBlackhole, Prop_Send, "m_glowColorOverride", tank);
				}

				char sGravityMessage[4];
				sGravityMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sGravityMessage[ST_TankType(tank)] : g_sGravityMessage2[ST_TankType(tank)];
				if (StrContains(sGravityMessage, "3") != -1)
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					ST_PrintToChatAll("%s %t", ST_TAG2, "Gravity3", sTankName);
				}
			}
		}
	}
}

public void ST_ChangeType(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveGravity(tank);
	}
}

static void vGravityHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if ((enabled == 1 || enabled == 3) && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bGravity2[survivor])
	{
		g_bGravity2[survivor] = true;
		g_iGravityOwner[survivor] = tank;

		float flGravityValue = !g_bTankConfig[ST_TankType(tank)] ? g_flGravityValue[ST_TankType(tank)] : g_flGravityValue2[ST_TankType(tank)],
			flGravityDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flGravityDuration[ST_TankType(tank)] : g_flGravityDuration2[ST_TankType(tank)];

		SetEntityGravity(survivor, flGravityValue);

		DataPack dpStopGravity;
		CreateDataTimer(flGravityDuration, tTimerStopGravity, dpStopGravity, TIMER_FLAG_NO_MAPCHANGE);
		dpStopGravity.WriteCell(GetClientUserId(survivor));
		dpStopGravity.WriteCell(GetClientUserId(tank));
		dpStopGravity.WriteString(message);

		char sGravityEffect[4];
		sGravityEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sGravityEffect[ST_TankType(tank)] : g_sGravityEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sGravityEffect, mode);

		char sGravityMessage[4];
		sGravityMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sGravityMessage[ST_TankType(tank)] : g_sGravityMessage2[ST_TankType(tank)];
		if (StrContains(sGravityMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Gravity", sTankName, survivor, flGravityValue);
		}
	}
}

static void vRemoveGravity(int tank)
{
	int iProp = -1;
	while ((iProp = FindEntityByClassname(iProp, "point_push")) != INVALID_ENT_REFERENCE)
	{
		if (bIsValidGame())
		{
			int iOwner = GetEntProp(iProp, Prop_Send, "m_glowColorOverride");
			if (iOwner == tank)
			{
				RemoveEntity(iProp);
			}
		}

		int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iOwner == tank)
		{
			RemoveEntity(iProp);
		}
	}

	g_bGravity[tank] = false;

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "234") && g_bGravity2[iSurvivor] && g_iGravityOwner[iSurvivor] == tank)
		{
			g_bGravity2[iSurvivor] = false;
			g_iGravityOwner[iSurvivor] = 0;

			SetEntityGravity(iSurvivor, 1.0);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			g_bGravity[iPlayer] = false;
			g_bGravity2[iPlayer] = false;
			g_iGravityOwner[iPlayer] = 0;
		}
	}
}

static float flGravityChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flGravityChance[ST_TankType(tank)] : g_flGravityChance2[ST_TankType(tank)];
}

static int iGravityAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGravityAbility[ST_TankType(tank)] : g_iGravityAbility2[ST_TankType(tank)];
}

static int iGravityHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGravityHit[ST_TankType(tank)] : g_iGravityHit2[ST_TankType(tank)];
}

static int iGravityHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGravityHitMode[ST_TankType(tank)] : g_iGravityHitMode2[ST_TankType(tank)];
}

public Action tTimerStopGravity(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bGravity2[iSurvivor] = false;
		g_iGravityOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bGravity2[iSurvivor])
	{
		g_bGravity2[iSurvivor] = false;
		g_iGravityOwner[iSurvivor] = 0;

		SetEntityGravity(iSurvivor, 1.0);

		return Plugin_Stop;
	}

	g_bGravity2[iSurvivor] = false;
	g_iGravityOwner[iSurvivor] = 0;

	SetEntityGravity(iSurvivor, 1.0);

	char sGravityMessage[4], sMessage[4];
	sGravityMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sGravityMessage[ST_TankType(iTank)] : g_sGravityMessage2[ST_TankType(iTank)];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (StrContains(sGravityMessage, sMessage) != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Gravity2", iSurvivor);
	}

	return Plugin_Continue;
}