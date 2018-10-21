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

// Super Tanks++: Fragile Ability
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
	name = "[ST++] Fragile Ability",
	author = ST_AUTHOR,
	description = "The Super Tank takes more damage.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bFragile[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

float g_flFragileBulletMultiplier[ST_MAXTYPES + 1], g_flFragileBulletMultiplier2[ST_MAXTYPES + 1], g_flFragileChance[ST_MAXTYPES + 1], g_flFragileChance2[ST_MAXTYPES + 1], g_flFragileDuration[ST_MAXTYPES + 1], g_flFragileDuration2[ST_MAXTYPES + 1], g_flFragileExplosiveMultiplier[ST_MAXTYPES + 1], g_flFragileExplosiveMultiplier2[ST_MAXTYPES + 1], g_flFragileFireMultiplier[ST_MAXTYPES + 1], g_flFragileFireMultiplier2[ST_MAXTYPES + 1], g_flFragileMeleeMultiplier[ST_MAXTYPES + 1], g_flFragileMeleeMultiplier2[ST_MAXTYPES + 1];

int g_iFragileAbility[ST_MAXTYPES + 1], g_iFragileAbility2[ST_MAXTYPES + 1], g_iFragileMessage[ST_MAXTYPES + 1], g_iFragileMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Fragile Ability only supports Left 4 Dead 1 & 2.");

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

	g_bFragile[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && g_bFragile[victim])
		{
			float flFragileBulletMultiplier = !g_bTankConfig[ST_TankType(victim)] ? g_flFragileBulletMultiplier[ST_TankType(victim)] : g_flFragileBulletMultiplier2[ST_TankType(victim)],
				flFragileExplosiveMultiplier = !g_bTankConfig[ST_TankType(victim)] ? g_flFragileExplosiveMultiplier[ST_TankType(victim)] : g_flFragileExplosiveMultiplier2[ST_TankType(victim)],
				flFragileFireMultiplier = !g_bTankConfig[ST_TankType(victim)] ? g_flFragileFireMultiplier[ST_TankType(victim)] : g_flFragileFireMultiplier2[ST_TankType(victim)],
				flFragileMeleeMultiplier = !g_bTankConfig[ST_TankType(victim)] ? g_flFragileMeleeMultiplier[ST_TankType(victim)] : g_flFragileMeleeMultiplier2[ST_TankType(victim)];
			if (damagetype & DMG_BULLET)
			{
				damage *= flFragileBulletMultiplier;
			}
			else if (damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA)
			{
				damage *= flFragileExplosiveMultiplier;
			}
			else if (damagetype & DMG_BURN || damagetype & (DMG_BURN|DMG_PREVENT_PHYSICS_FORCE) || damagetype & (DMG_BURN|DMG_DIRECT))
			{
				damage *= flFragileFireMultiplier;
			}
			else if (damagetype & DMG_SLASH || damagetype & DMG_CLUB)
			{
				damage *= flFragileMeleeMultiplier;
			}

			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
}

public void ST_Configs(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName, true))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iFragileAbility[iIndex] = kvSuperTanks.GetNum("Fragile Ability/Ability Enabled", 0);
				g_iFragileAbility[iIndex] = iClamp(g_iFragileAbility[iIndex], 0, 1);
				g_iFragileMessage[iIndex] = kvSuperTanks.GetNum("Fragile Ability/Ability Message", 0);
				g_iFragileMessage[iIndex] = iClamp(g_iFragileMessage[iIndex], 0, 1);
				g_flFragileBulletMultiplier[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Bullet Multiplier", 5.0);
				g_flFragileBulletMultiplier[iIndex] = flClamp(g_flFragileBulletMultiplier[iIndex], 0.1, 9999999999.0);
				g_flFragileChance[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Chance", 33.3);
				g_flFragileChance[iIndex] = flClamp(g_flFragileChance[iIndex], 0.1, 100.0);
				g_flFragileDuration[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Duration", 5.0);
				g_flFragileDuration[iIndex] = flClamp(g_flFragileDuration[iIndex], 0.1, 9999999999.0);
				g_flFragileExplosiveMultiplier[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Explosive Multiplier", 5.0);
				g_flFragileExplosiveMultiplier[iIndex] = flClamp(g_flFragileExplosiveMultiplier[iIndex], 0.1, 9999999999.0);
				g_flFragileFireMultiplier[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Fire Multiplier", 3.0);
				g_flFragileFireMultiplier[iIndex] = flClamp(g_flFragileFireMultiplier[iIndex], 0.1, 9999999999.0);
				g_flFragileMeleeMultiplier[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Melee Multiplier", 1.5);
				g_flFragileMeleeMultiplier[iIndex] = flClamp(g_flFragileMeleeMultiplier[iIndex], 0.1, 9999999999.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iFragileAbility2[iIndex] = kvSuperTanks.GetNum("Fragile Ability/Ability Enabled", g_iFragileAbility[iIndex]);
				g_iFragileAbility2[iIndex] = iClamp(g_iFragileAbility2[iIndex], 0, 1);
				g_iFragileMessage2[iIndex] = kvSuperTanks.GetNum("Fragile Ability/Ability Message", g_iFragileMessage[iIndex]);
				g_iFragileMessage2[iIndex] = iClamp(g_iFragileMessage2[iIndex], 0, 1);
				g_flFragileBulletMultiplier2[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Bullet Multiplier", g_flFragileBulletMultiplier[iIndex]);
				g_flFragileBulletMultiplier2[iIndex] = flClamp(g_flFragileBulletMultiplier2[iIndex], 0.1, 9999999999.0);
				g_flFragileChance2[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Chance", g_flFragileChance[iIndex]);
				g_flFragileChance2[iIndex] = flClamp(g_flFragileChance2[iIndex], 0.1, 100.0);
				g_flFragileDuration2[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Duration", g_flFragileDuration[iIndex]);
				g_flFragileDuration2[iIndex] = flClamp(g_flFragileDuration2[iIndex], 0.1, 9999999999.0);
				g_flFragileExplosiveMultiplier2[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Explosive Multiplier", g_flFragileExplosiveMultiplier[iIndex]);
				g_flFragileExplosiveMultiplier2[iIndex] = flClamp(g_flFragileExplosiveMultiplier2[iIndex], 0.1, 9999999999.0);
				g_flFragileFireMultiplier2[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Fire Multiplier", g_flFragileFireMultiplier[iIndex]);
				g_flFragileFireMultiplier2[iIndex] = flClamp(g_flFragileFireMultiplier2[iIndex], 0.1, 9999999999.0);
				g_flFragileMeleeMultiplier2[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Melee Multiplier", g_flFragileMeleeMultiplier[iIndex]);
				g_flFragileMeleeMultiplier2[iIndex] = flClamp(g_flFragileMeleeMultiplier2[iIndex], 0.1, 9999999999.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vReset();
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_incapacitated"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iFragileAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && g_bFragile[iTank])
		{
			tTimerStopFragile(null, GetClientUserId(iTank));
		}
	}
}

public void ST_Ability(int tank)
{
	float flFragileChance = !g_bTankConfig[ST_TankType(tank)] ? g_flFragileChance[ST_TankType(tank)] : g_flFragileChance2[ST_TankType(tank)];
	if (iFragileAbility(tank) == 1 && GetRandomFloat(0.1, 100.0) <= flFragileChance && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank) && !g_bFragile[tank])
	{
		g_bFragile[tank] = true;

		float flFragileDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flFragileDuration[ST_TankType(tank)] : g_flFragileDuration2[ST_TankType(tank)];
		CreateTimer(flFragileDuration, tTimerStopFragile, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);

		if (iFragileMessage(tank) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Fragile", sTankName);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bFragile[iPlayer] = false;
		}
	}
}

static int iFragileAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iFragileAbility[ST_TankType(tank)] : g_iFragileAbility2[ST_TankType(tank)];
}

static int iFragileMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iFragileMessage[ST_TankType(tank)] : g_iFragileMessage2[ST_TankType(tank)];
}

public Action tTimerStopFragile(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bFragile[iTank])
	{
		g_bFragile[iTank] = false;

		return Plugin_Stop;
	}

	g_bFragile[iTank] = false;

	if (iFragileMessage(iTank) == 1)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		ST_TankName(iTank, sTankName);
		PrintToChatAll("%s %t", ST_TAG2, "Fragile2", sTankName);
	}

	return Plugin_Continue;
}