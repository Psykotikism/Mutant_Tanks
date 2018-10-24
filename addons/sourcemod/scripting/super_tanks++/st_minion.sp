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

// Super Tanks++: Minion Ability
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
	name = "[ST++] Minion Ability",
	author = ST_AUTHOR,
	description = "The Super Tank spawns minions.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bMinion[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sMinionTypes[ST_MAXTYPES + 1][13], g_sMinionTypes2[ST_MAXTYPES + 1][13];

float g_flMinionChance[ST_MAXTYPES + 1], g_flMinionChance2[ST_MAXTYPES + 1];

int g_iMinionAbility[ST_MAXTYPES + 1], g_iMinionAbility2[ST_MAXTYPES + 1], g_iMinionAmount[ST_MAXTYPES + 1], g_iMinionAmount2[ST_MAXTYPES + 1], g_iMinionCount[MAXPLAYERS + 1], g_iMinionMessage[ST_MAXTYPES + 1], g_iMinionMessage2[ST_MAXTYPES + 1], g_iMinionOwner[MAXPLAYERS + 1], g_iMinionReplace[ST_MAXTYPES + 1], g_iMinionReplace2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Minion Ability only supports Left 4 Dead 1 & 2.");

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

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	g_bMinion[client] = false;
	g_iMinionCount[client] = 0;
	g_iMinionOwner[client] = 0;
}

public void OnMapEnd()
{
	vReset();
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
				g_bTankConfig[iIndex] = false;

				g_iMinionAbility[iIndex] = kvSuperTanks.GetNum("Minion Ability/Ability Enabled", 0);
				g_iMinionAbility[iIndex] = iClamp(g_iMinionAbility[iIndex], 0, 1);
				g_iMinionMessage[iIndex] = kvSuperTanks.GetNum("Minion Ability/Ability Message", 0);
				g_iMinionMessage[iIndex] = iClamp(g_iMinionMessage[iIndex], 0, 1);
				g_iMinionAmount[iIndex] = kvSuperTanks.GetNum("Minion Ability/Minion Amount", 5);
				g_iMinionAmount[iIndex] = iClamp(g_iMinionAmount[iIndex], 1, 25);
				g_flMinionChance[iIndex] = kvSuperTanks.GetFloat("Minion Ability/Minion Chance", 33.3);
				g_flMinionChance[iIndex] = flClamp(g_flMinionChance[iIndex], 0.1, 100.0);
				g_iMinionReplace[iIndex] = kvSuperTanks.GetNum("Minion Ability/Minion Replace", 1);
				g_iMinionReplace[iIndex] = iClamp(g_iMinionReplace[iIndex], 0, 1);
				kvSuperTanks.GetString("Minion Ability/Minion Types", g_sMinionTypes[iIndex], sizeof(g_sMinionTypes[]), "123456");
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iMinionAbility2[iIndex] = kvSuperTanks.GetNum("Minion Ability/Ability Enabled", g_iMinionAbility[iIndex]);
				g_iMinionAbility2[iIndex] = iClamp(g_iMinionAbility2[iIndex], 0, 1);
				g_iMinionMessage2[iIndex] = kvSuperTanks.GetNum("Minion Ability/Ability Message", g_iMinionMessage[iIndex]);
				g_iMinionMessage2[iIndex] = iClamp(g_iMinionMessage2[iIndex], 0, 1);
				g_iMinionAmount2[iIndex] = kvSuperTanks.GetNum("Minion Ability/Minion Amount", g_iMinionAmount[iIndex]);
				g_iMinionAmount2[iIndex] = iClamp(g_iMinionAmount2[iIndex], 1, 25);
				g_flMinionChance2[iIndex] = kvSuperTanks.GetFloat("Minion Ability/Minion Chance", g_flMinionChance[iIndex]);
				g_flMinionChance2[iIndex] = flClamp(g_flMinionChance2[iIndex], 0.1, 100.0);
				g_iMinionReplace2[iIndex] = kvSuperTanks.GetNum("Minion Ability/Minion Replace", g_iMinionReplace[iIndex]);
				g_iMinionReplace2[iIndex] = iClamp(g_iMinionReplace2[iIndex], 0, 1);
				kvSuperTanks.GetString("Minion Ability/Minion Types", g_sMinionTypes2[iIndex], sizeof(g_sMinionTypes2[]), g_sMinionTypes[iIndex]);
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
		int iInfectedId = event.GetInt("userid"), iInfected = GetClientOfUserId(iInfectedId);
		if (iMinionAbility(iInfected) == 1 && ST_TankAllowed(iInfected))
		{
			g_bMinion[iInfected] = false;
			g_iMinionCount[iInfected] = 0;
		}

		if (bIsSpecialInfected(iInfected) && g_bMinion[iInfected])
		{
			for (int iOwner = 1; iOwner <= MaxClients; iOwner++)
			{
				if (g_iMinionOwner[iInfected] == iOwner && ST_TankAllowed(iOwner) && ST_CloneAllowed(iOwner, g_bCloneInstalled))
				{
					int iMinionReplace = !g_bTankConfig[ST_TankType(iOwner)] ? g_iMinionReplace[ST_TankType(iOwner)] : g_iMinionReplace2[ST_TankType(iOwner)];
					if (iMinionReplace == 1)
					{
						g_iMinionOwner[iInfected] = 0;

						if (g_iMinionCount[iOwner] > 0)
						{
							g_iMinionCount[iOwner]--;
						}
						else
						{
							g_iMinionCount[iOwner] = 0;
						}
					}

					break;
				}
			}
		}
	}
}

public void ST_Ability(int tank)
{
	float flMinionChance = !g_bTankConfig[ST_TankType(tank)] ? g_flMinionChance[ST_TankType(tank)] : g_flMinionChance2[ST_TankType(tank)];
	if (iMinionAbility(tank) == 1 && GetRandomFloat(0.1, 100.0) <= flMinionChance && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		int iMinionAmount = !g_bTankConfig[ST_TankType(tank)] ? g_iMinionAmount[ST_TankType(tank)] : g_iMinionAmount2[ST_TankType(tank)],
			iMinionMessage = !g_bTankConfig[ST_TankType(tank)] ? g_iMinionMessage[ST_TankType(tank)] : g_iMinionMessage2[ST_TankType(tank)];
		if (g_iMinionCount[tank] < iMinionAmount)
		{
			float flHitPosition[3], flPosition[3], flAngles[3], flVector[3];
			GetClientEyePosition(tank, flPosition);
			GetClientEyeAngles(tank, flAngles);
			flAngles[0] = -25.0;

			GetAngleVectors(flAngles, flAngles, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(flAngles, flAngles);
			ScaleVector(flAngles, -1.0);
			vCopyVector(flAngles, flVector);
			GetVectorAngles(flAngles, flAngles);

			Handle hTrace = TR_TraceRayFilterEx(flPosition, flAngles, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelf, tank);
			if (TR_DidHit(hTrace))
			{
				TR_GetEndPosition(flHitPosition, hTrace);
				NormalizeVector(flVector, flVector);
				ScaleVector(flVector, -40.0);
				AddVectors(flHitPosition, flVector, flHitPosition);

				if (GetVectorDistance(flHitPosition, flPosition) < 200.0 && GetVectorDistance(flHitPosition, flPosition) > 40.0)
				{
					bool bSpecialInfected[MAXPLAYERS + 1];
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						bSpecialInfected[iPlayer] = false;
						if (bIsInfected(iPlayer))
						{
							bSpecialInfected[iPlayer] = true;
						}
					}

					char sNumbers = !g_bTankConfig[ST_TankType(tank)] ? g_sMinionTypes[ST_TankType(tank)][GetRandomInt(0, strlen(g_sMinionTypes[ST_TankType(tank)]) - 1)] : g_sMinionTypes2[ST_TankType(tank)][GetRandomInt(0, strlen(g_sMinionTypes2[ST_TankType(tank)]) - 1)];
					switch (sNumbers)
					{
						case '1': vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "smoker");
						case '2': vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "boomer");
						case '3': vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "hunter");
						case '4': vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "spitter" : "boomer");
						case '5': vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "jockey" : "hunter");
						case '6': vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", bIsValidGame() ? "charger" : "smoker");
						default: vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "hunter");
					}

					int iSelectedType;
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						if (bIsInfected(iPlayer) && !bSpecialInfected[iPlayer])
						{
							iSelectedType = iPlayer;
							break;
						}
					}

					if (iSelectedType > 0)
					{
						TeleportEntity(iSelectedType, flHitPosition, NULL_VECTOR, NULL_VECTOR);

						g_bMinion[iSelectedType] = true;
						g_iMinionCount[tank]++;
						g_iMinionOwner[iSelectedType] = tank;

						if (iMinionMessage == 1)
						{
							char sTankName[33];
							ST_TankName(tank, sTankName);
							PrintToChatAll("%s %t", ST_TAG2, "Minion", sTankName);
						}
					}
				}
			}

			delete hTrace;
		}
	}
}

public void ST_BossStage(int tank)
{
	if (iMinionAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		g_iMinionCount[tank] = 0;

		for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
		{
			if (bIsTank(iInfected) || bIsSpecialInfected(iInfected))
			{
				g_bMinion[iInfected] = false;
				g_iMinionOwner[iInfected] = 0;
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
			g_bMinion[iPlayer] = false;
			g_iMinionCount[iPlayer] = 0;
			g_iMinionOwner[iPlayer] = 0;
		}
	}
}

static int iMinionAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iMinionAbility[ST_TankType(tank)] : g_iMinionAbility2[ST_TankType(tank)];
}