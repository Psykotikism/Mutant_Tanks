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

// Super Tanks++: Respawn Ability
#include <sourcemod>
#include <sdktools>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Respawn Ability",
	author = ST_AUTHOR,
	description = "The Super Tank respawns upon death.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1];

float g_flRespawnChance[ST_MAXTYPES + 1], g_flRespawnChance2[ST_MAXTYPES + 1];

int g_iFinaleTank[ST_MAXTYPES + 1], g_iFinaleTank2[ST_MAXTYPES + 1], g_iRespawnAbility[ST_MAXTYPES + 1], g_iRespawnAbility2[ST_MAXTYPES + 1], g_iRespawnAmount[ST_MAXTYPES + 1], g_iRespawnAmount2[ST_MAXTYPES + 1], g_iRespawnCount[MAXPLAYERS + 1], g_iRespawnMessage[ST_MAXTYPES + 1], g_iRespawnMessage2[ST_MAXTYPES + 1], g_iRespawnMode[ST_MAXTYPES + 1], g_iRespawnMode2[ST_MAXTYPES + 1], g_iRespawnType[ST_MAXTYPES + 1], g_iRespawnType2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Respawn Ability\" only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

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

				g_iFinaleTank[iIndex] = kvSuperTanks.GetNum("Spawn/Finale Tank", 0);
				g_iFinaleTank[iIndex] = iClamp(g_iFinaleTank[iIndex], 0, 1);
				g_iRespawnAbility[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Ability Enabled", 0);
				g_iRespawnAbility[iIndex] = iClamp(g_iRespawnAbility[iIndex], 0, 1);
				g_iRespawnMessage[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Ability Message", 0);
				g_iRespawnMessage[iIndex] = iClamp(g_iRespawnMessage[iIndex], 0, 1);
				g_iRespawnAmount[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Amount", 1);
				g_iRespawnAmount[iIndex] = iClamp(g_iRespawnAmount[iIndex], 1, 9999999999);
				g_flRespawnChance[iIndex] = kvSuperTanks.GetFloat("Respawn Ability/Respawn Chance", 33.3);
				g_flRespawnChance[iIndex] = flClamp(g_flRespawnChance[iIndex], 0.0, 100.0);
				g_iRespawnMode[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Mode", 0);
				g_iRespawnMode[iIndex] = iClamp(g_iRespawnMode[iIndex], 0, 2);
				g_iRespawnType[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Type", 0);
				g_iRespawnType[iIndex] = iClamp(g_iRespawnType[iIndex], 0, 5000);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iFinaleTank2[iIndex] = kvSuperTanks.GetNum("Spawn/Finale Tank", g_iFinaleTank[iIndex]);
				g_iFinaleTank2[iIndex] = iClamp(g_iFinaleTank2[iIndex], 0, 1);
				g_iRespawnAbility2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Ability Enabled", g_iRespawnAbility[iIndex]);
				g_iRespawnAbility2[iIndex] = iClamp(g_iRespawnAbility2[iIndex], 0, 1);
				g_iRespawnMessage2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Ability Message", g_iRespawnMessage[iIndex]);
				g_iRespawnMessage2[iIndex] = iClamp(g_iRespawnMessage2[iIndex], 0, 1);
				g_iRespawnAmount2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Amount", g_iRespawnAmount[iIndex]);
				g_iRespawnAmount2[iIndex] = iClamp(g_iRespawnAmount2[iIndex], 1, 9999999999);
				g_flRespawnChance2[iIndex] = kvSuperTanks.GetFloat("Respawn Ability/Respawn Chance", g_flRespawnChance[iIndex]);
				g_flRespawnChance2[iIndex] = flClamp(g_flRespawnChance2[iIndex], 0.0, 100.0);
				g_iRespawnMode2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Mode", g_iRespawnMode[iIndex]);
				g_iRespawnMode2[iIndex] = iClamp(g_iRespawnMode2[iIndex], 0, 2);
				g_iRespawnType2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Type", g_iRespawnType[iIndex]);
				g_iRespawnType2[iIndex] = iClamp(g_iRespawnType2[iIndex], 0, 5000);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_EventHandler(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);

		float flRespawnChance = !g_bTankConfig[ST_TankType(iTank)] ? g_flRespawnChance[ST_TankType(iTank)] : g_flRespawnChance2[ST_TankType(iTank)];

		if (iRespawnAbility(iTank) == 1 && GetRandomFloat(0.1, 100.0) <= flRespawnChance && ST_TankAllowed(iTank, "024") && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			float flPos[3], flAngles[3];
			int iFlags = GetEntProp(iTank, Prop_Send, "m_fFlags"), iSequence = GetEntProp(iTank, Prop_Data, "m_nSequence");

			GetEntPropVector(iTank, Prop_Send, "m_vecOrigin", flPos);
			GetEntPropVector(iTank, Prop_Send, "m_angRotation", flAngles);

			DataPack dpRespawn;
			CreateDataTimer(0.4, tTimerRespawn, dpRespawn, TIMER_FLAG_NO_MAPCHANGE);
			dpRespawn.WriteCell(GetClientUserId(iTank));
			dpRespawn.WriteCell(iFlags);
			dpRespawn.WriteCell(iSequence);
			dpRespawn.WriteFloat(flPos[0]);
			dpRespawn.WriteFloat(flPos[1]);
			dpRespawn.WriteFloat(flPos[2]);
			dpRespawn.WriteFloat(flAngles[0]);
			dpRespawn.WriteFloat(flAngles[1]);
			dpRespawn.WriteFloat(flAngles[2]);
		}
	}
}

static void vRandomRespawn(int tank)
{
	int iTypeCount, iTankTypes[ST_MAXTYPES + 1];
	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		int iFinaleTank = !g_bTankConfig[ST_TankType(iIndex)] ? g_iFinaleTank[ST_TankType(iIndex)] : g_iFinaleTank2[ST_TankType(iIndex)];
		if (!ST_TypeEnabled(iIndex) || !ST_SpawnEnabled(iIndex) || (iFinaleTank == 1 && (!bIsFinaleMap() || ST_TankWave() <= 0)) || ST_TankType(tank) == iIndex)
		{
			continue;
		}

		iTankTypes[iTypeCount + 1] = iIndex;
		iTypeCount++;
	}

	if (iTypeCount > 0)
	{
		int iChosen = iTankTypes[GetRandomInt(1, iTypeCount)];
		ST_SpawnTank(tank, iChosen);
	}
}

static int iRespawnAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRespawnAbility[ST_TankType(tank)] : g_iRespawnAbility2[ST_TankType(tank)];
}

public Action tTimerRespawn(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !bIsPlayerIncapacitated(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || iRespawnAbility(iTank) == 0)
	{
		g_iRespawnCount[iTank] = 0;

		return Plugin_Stop;
	}

	int iFlags = pack.ReadCell(), iSequence = pack.ReadCell(),
		iRespawnAmount = !g_bTankConfig[ST_TankType(iTank)] ? g_iRespawnAmount[ST_TankType(iTank)] : g_iRespawnAmount2[ST_TankType(iTank)],
		iRespawnMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_iRespawnMessage[ST_TankType(iTank)] : g_iRespawnMessage2[ST_TankType(iTank)],
		iRespawnMode = !g_bTankConfig[ST_TankType(iTank)] ? g_iRespawnMode[ST_TankType(iTank)] : g_iRespawnMode2[ST_TankType(iTank)],
		iRespawnType = !g_bTankConfig[ST_TankType(iTank)] ? g_iRespawnType[ST_TankType(iTank)] : g_iRespawnType2[ST_TankType(iTank)];

	float flPos[3], flAngles[3];
	flPos[0] = pack.ReadFloat();
	flPos[1] = pack.ReadFloat();
	flPos[2] = pack.ReadFloat();
	flAngles[0] = pack.ReadFloat();
	flAngles[1] = pack.ReadFloat();
	flAngles[2] = pack.ReadFloat();

	if (g_iRespawnCount[iTank] < iRespawnAmount)
	{
		g_iRespawnCount[iTank]++;

		bool bExists[MAXPLAYERS + 1];

		for (int iRespawn = 1; iRespawn <= MaxClients; iRespawn++)
		{
			bExists[iRespawn] = false;
			if (ST_TankAllowed(iRespawn, "234") && ST_CloneAllowed(iRespawn, g_bCloneInstalled))
			{
				bExists[iRespawn] = true;
			}
		}

		switch (iRespawnMode)
		{
			case 0: ST_SpawnTank(iTank, ST_TankType(iTank));
			case 1:
			{
				if (iRespawnType > 0)
				{
					ST_SpawnTank(iTank, iRespawnType);
				}
				else
				{
					vRandomRespawn(iTank);
				}
			}
			case 2: vRandomRespawn(iTank);
		}

		int iNewTank;
		for (int iRespawn = 1; iRespawn <= MaxClients; iRespawn++)
		{
			if (ST_TankAllowed(iRespawn, "234") && ST_CloneAllowed(iRespawn, g_bCloneInstalled) && !bExists[iRespawn])
			{
				iNewTank = iRespawn;
				g_iRespawnCount[iNewTank] = g_iRespawnCount[iTank];
				break;
			}
		}

		if (iNewTank > 0)
		{
			SetEntProp(iNewTank, Prop_Send, "m_fFlags", iFlags);
			SetEntProp(iNewTank, Prop_Data, "m_nSequence", iSequence);
			TeleportEntity(iNewTank, flPos, flAngles, NULL_VECTOR);

			if (iRespawnMessage == 1)
			{
				char sTankName[33];
				ST_TankName(iTank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Respawn", sTankName);
			}
		}
	}
	else
	{
		g_iRespawnCount[iTank] = 0;
	}

	return Plugin_Continue;
}