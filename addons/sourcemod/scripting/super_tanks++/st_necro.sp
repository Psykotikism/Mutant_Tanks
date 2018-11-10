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

// Super Tanks++: Necro Ability
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
	name = "[ST++] Necro Ability",
	author = ST_AUTHOR,
	description = "The Super Tank resurrects nearby special infected that die.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1];

float g_flNecroChance[ST_MAXTYPES + 1], g_flNecroChance2[ST_MAXTYPES + 1], g_flNecroRange[ST_MAXTYPES + 1], g_flNecroRange2[ST_MAXTYPES + 1];

int g_iNecroAbility[ST_MAXTYPES + 1], g_iNecroAbility2[ST_MAXTYPES + 1], g_iNecroMessage[ST_MAXTYPES + 1], g_iNecroMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Necro Ability\" only supports Left 4 Dead 1 & 2.");

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
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iNecroAbility[iIndex] = kvSuperTanks.GetNum("Necro Ability/Ability Enabled", 0);
				g_iNecroAbility[iIndex] = iClamp(g_iNecroAbility[iIndex], 0, 1);
				g_iNecroMessage[iIndex] = kvSuperTanks.GetNum("Necro Ability/Ability Message", 0);
				g_iNecroMessage[iIndex] = iClamp(g_iNecroMessage[iIndex], 0, 1);
				g_flNecroChance[iIndex] = kvSuperTanks.GetFloat("Necro Ability/Necro Chance", 33.3);
				g_flNecroChance[iIndex] = flClamp(g_flNecroChance[iIndex], 0.0, 100.0);
				g_flNecroRange[iIndex] = kvSuperTanks.GetFloat("Necro Ability/Necro Range", 500.0);
				g_flNecroRange[iIndex] = flClamp(g_flNecroRange[iIndex], 1.0, 9999999999.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iNecroAbility2[iIndex] = kvSuperTanks.GetNum("Necro Ability/Ability Enabled", g_iNecroAbility[iIndex]);
				g_iNecroAbility2[iIndex] = iClamp(g_iNecroAbility2[iIndex], 0, 1);
				g_iNecroMessage2[iIndex] = kvSuperTanks.GetNum("Necro Ability/Ability Message", g_iNecroMessage[iIndex]);
				g_iNecroMessage2[iIndex] = iClamp(g_iNecroMessage2[iIndex], 0, 1);
				g_flNecroChance2[iIndex] = kvSuperTanks.GetFloat("Necro Ability/Necro Chance", g_flNecroChance[iIndex]);
				g_flNecroChance2[iIndex] = flClamp(g_flNecroChance2[iIndex], 0.0, 100.0);
				g_flNecroRange2[iIndex] = kvSuperTanks.GetFloat("Necro Ability/Necro Range", g_flNecroRange[iIndex]);
				g_flNecroRange2[iIndex] = flClamp(g_flNecroRange2[iIndex], 1.0, 9999999999.0);
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

		float flInfectedPos[3];

		if (bIsSpecialInfected(iInfected, "024"))
		{
			GetClientAbsOrigin(iInfected, flInfectedPos);
			for (int iTank = 1; iTank <= MaxClients; iTank++)
			{
				if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
				{
					int iNecroAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iNecroAbility[ST_TankType(iTank)] : g_iNecroAbility2[ST_TankType(iTank)];

					float flNecroChance = !g_bTankConfig[ST_TankType(iTank)] ? g_flNecroChance[ST_TankType(iTank)] : g_flNecroChance2[ST_TankType(iTank)];

					if (iNecroAbility == 1 && GetRandomFloat(0.1, 100.0) <= flNecroChance)
					{
						float flNecroRange = !g_bTankConfig[ST_TankType(iTank)] ? g_flNecroRange[ST_TankType(iTank)] : g_flNecroRange2[ST_TankType(iTank)],
							flTankPos[3];
						GetClientAbsOrigin(iTank, flTankPos);

						float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
						if (flDistance <= flNecroRange)
						{
							switch (GetEntProp(iInfected, Prop_Send, "m_zombieClass"))
							{
								case 1: vNecro(iTank, flInfectedPos, "smoker");
								case 2: vNecro(iTank, flInfectedPos, "boomer");
								case 3: vNecro(iTank, flInfectedPos, "hunter");
								case 4: vNecro(iTank, flInfectedPos, "spitter");
								case 5: vNecro(iTank, flInfectedPos, "jockey");
								case 6: vNecro(iTank, flInfectedPos, "charger");
							}
						}
					}
				}
			}
		}
	}
}

static void vNecro(int tank, float pos[3], const char[] type)
{
	int iNecroMessage = !g_bTankConfig[ST_TankType(tank)] ? g_iNecroMessage[ST_TankType(tank)] : g_iNecroMessage2[ST_TankType(tank)];
	bool bExists[MAXPLAYERS + 1];

	for (int iNecro = 1; iNecro <= MaxClients; iNecro++)
	{
		bExists[iNecro] = false;
		if (bIsSpecialInfected(iNecro, "24"))
		{
			bExists[iNecro] = true;
		}
	}

	vCheatCommand(tank, bIsValidGame() ? "z_spawn_old" : "z_spawn", type);

	int iInfected;
	for (int iNecro = 1; iNecro <= MaxClients; iNecro++)
	{
		if (bIsSpecialInfected(iNecro, "24") && !bExists[iNecro])
		{
			iInfected = iNecro;
			break;
		}
	}

	if (iInfected > 0)
	{
		TeleportEntity(iInfected, pos, NULL_VECTOR, NULL_VECTOR);

		if (iNecroMessage == 1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Necro", sTankName);
		}
	}
}