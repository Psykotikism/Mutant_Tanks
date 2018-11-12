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

// Super Tanks++: God Ability
#include <sourcemod>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] God Ability",
	author = ST_AUTHOR,
	description = "The Super Tank gains temporary immunity to all damage.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bGod[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flGodChance[ST_MAXTYPES + 1], g_flGodChance2[ST_MAXTYPES + 1], g_flGodDuration[ST_MAXTYPES + 1], g_flGodDuration2[ST_MAXTYPES + 1];

int g_iGodAbility[ST_MAXTYPES + 1], g_iGodAbility2[ST_MAXTYPES + 1], g_iGodMessage[ST_MAXTYPES + 1], g_iGodMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] God Ability\" only supports Left 4 Dead 1 & 2.");

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
	g_bGod[client] = false;
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
		if (kvSuperTanks.JumpToKey(sTankName))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iGodAbility[iIndex] = kvSuperTanks.GetNum("God Ability/Ability Enabled", 0);
				g_iGodAbility[iIndex] = iClamp(g_iGodAbility[iIndex], 0, 1);
				g_iGodMessage[iIndex] = kvSuperTanks.GetNum("God Ability/Ability Message", 0);
				g_iGodMessage[iIndex] = iClamp(g_iGodMessage[iIndex], 0, 1);
				g_flGodChance[iIndex] = kvSuperTanks.GetFloat("God Ability/God Chance", 33.3);
				g_flGodChance[iIndex] = flClamp(g_flGodChance[iIndex], 0.0, 100.0);
				g_flGodDuration[iIndex] = kvSuperTanks.GetFloat("God Ability/God Duration", 5.0);
				g_flGodDuration[iIndex] = flClamp(g_flGodDuration[iIndex], 0.1, 9999999999.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iGodAbility2[iIndex] = kvSuperTanks.GetNum("God Ability/Ability Enabled", g_iGodAbility[iIndex]);
				g_iGodAbility2[iIndex] = iClamp(g_iGodAbility2[iIndex], 0, 1);
				g_iGodMessage2[iIndex] = kvSuperTanks.GetNum("God Ability/Ability Message", g_iGodMessage[iIndex]);
				g_iGodMessage2[iIndex] = iClamp(g_iGodMessage2[iIndex], 0, 1);
				g_flGodChance2[iIndex] = kvSuperTanks.GetFloat("God Ability/God Chance", g_flGodChance[iIndex]);
				g_flGodChance2[iIndex] = flClamp(g_flGodChance2[iIndex], 0.0, 100.0);
				g_flGodDuration2[iIndex] = kvSuperTanks.GetFloat("God Ability/God Duration", g_flGodDuration[iIndex]);
				g_flGodDuration2[iIndex] = flClamp(g_flGodDuration2[iIndex], 0.1, 9999999999.0);
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
		if (bIsTank(iTank, "234") && g_bGod[iTank])
		{
			SetEntProp(iTank, Prop_Data, "m_takedamage", 2, 1);
		}
	}
}

public void ST_EventHandler(Event event, const char[] name)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iGodAbility(iTank) == 1 && ST_TankAllowed(iTank, "024") && ST_CloneAllowed(iTank, g_bCloneInstalled) && g_bGod[iTank])
		{
			tTimerStopGod(null, GetClientUserId(iTank));
		}
	}
}

public void ST_Ability(int tank)
{
	float flGodChance = !g_bTankConfig[ST_TankType(tank)] ? g_flGodChance[ST_TankType(tank)] : g_flGodChance2[ST_TankType(tank)];
	if (iGodAbility(tank) == 1 && GetRandomFloat(0.1, 100.0) <= flGodChance && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && !g_bGod[tank])
	{
		g_bGod[tank] = true;

		SetEntProp(tank, Prop_Data, "m_takedamage", 0, 1);

		float flGodDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flGodDuration[ST_TankType(tank)] : g_flGodDuration2[ST_TankType(tank)];
		CreateTimer(flGodDuration, tTimerStopGod, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

		if (iGodMessage(tank) == 1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "God", sTankName);
		}
		
	}
}

public void ST_ChangeType(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		g_bGod[tank] = false;

		SetEntProp(tank, Prop_Data, "m_takedamage", 2, 1);
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			g_bGod[iPlayer] = false;
		}
	}
}

static int iGodAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGodAbility[ST_TankType(tank)] : g_iGodAbility2[ST_TankType(tank)];
}

static int iGodMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGodMessage[ST_TankType(tank)] : g_iGodMessage2[ST_TankType(tank)];
}

public Action tTimerStopGod(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bGod[iTank])
	{
		g_bGod[iTank] = false;

		return Plugin_Stop;
	}

	g_bGod[iTank] = false;

	SetEntProp(iTank, Prop_Data, "m_takedamage", 2, 1);

	if (iGodMessage(iTank) == 1)
	{
		char sTankName[33];
		ST_TankName(iTank, sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "God2", sTankName);
	}

	return Plugin_Continue;
}