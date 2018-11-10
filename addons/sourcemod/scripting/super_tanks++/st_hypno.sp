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

// Super Tanks++: Hypno Ability
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
	name = "[ST++] Hypno Ability",
	author = ST_AUTHOR,
	description = "The Super Tank hypnotizes survivors to damage themselves or teammates.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bHypno[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sHypnoEffect[ST_MAXTYPES + 1][4], g_sHypnoEffect2[ST_MAXTYPES + 1][4], g_sHypnoMessage[ST_MAXTYPES + 1][3], g_sHypnoMessage2[ST_MAXTYPES + 1][3];

float g_flHypnoBulletDivisor[ST_MAXTYPES + 1], g_flHypnoBulletDivisor2[ST_MAXTYPES + 1], g_flHypnoChance[ST_MAXTYPES + 1], g_flHypnoChance2[ST_MAXTYPES + 1], g_flHypnoDuration[ST_MAXTYPES + 1], g_flHypnoDuration2[ST_MAXTYPES + 1], g_flHypnoExplosiveDivisor[ST_MAXTYPES + 1], g_flHypnoExplosiveDivisor2[ST_MAXTYPES + 1], g_flHypnoFireDivisor[ST_MAXTYPES + 1], g_flHypnoFireDivisor2[ST_MAXTYPES + 1], g_flHypnoMeleeDivisor[ST_MAXTYPES + 1], g_flHypnoMeleeDivisor2[ST_MAXTYPES + 1], g_flHypnoRange[ST_MAXTYPES + 1], g_flHypnoRange2[ST_MAXTYPES + 1], g_flHypnoRangeChance[ST_MAXTYPES + 1], g_flHypnoRangeChance2[ST_MAXTYPES + 1];

int g_iHypnoAbility[ST_MAXTYPES + 1], g_iHypnoAbility2[ST_MAXTYPES + 1], g_iHypnoHit[ST_MAXTYPES + 1], g_iHypnoHit2[ST_MAXTYPES + 1], g_iHypnoHitMode[ST_MAXTYPES + 1], g_iHypnoHitMode2[ST_MAXTYPES + 1], g_iHypnoMode[ST_MAXTYPES + 1], g_iHypnoMode2[ST_MAXTYPES + 1], g_iHypnoOwner[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Hypno Ability\" only supports Left 4 Dead 1 & 2.");

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

	g_bHypno[client] = false;
	g_iHypnoOwner[client] = 0;
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

		if ((iHypnoHitMode(attacker) == 0 || iHypnoHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHypnoHit(victim, attacker, flHypnoChance(attacker), iHypnoHit(attacker), "1", "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if ((iHypnoHitMode(victim) == 0 || iHypnoHitMode(victim) == 2) && StrEqual(sClassname, "weapon_melee"))
			{
				vHypnoHit(attacker, victim, flHypnoChance(victim), iHypnoHit(victim), "1", "2");
			}

			if (g_bHypno[attacker])
			{
				float flHypnoBulletDivisor = !g_bTankConfig[ST_TankType(victim)] ? g_flHypnoBulletDivisor[ST_TankType(victim)] : g_flHypnoBulletDivisor2[ST_TankType(victim)],
					flHypnoExplosiveDivisor = !g_bTankConfig[ST_TankType(victim)] ? g_flHypnoExplosiveDivisor[ST_TankType(victim)] : g_flHypnoExplosiveDivisor2[ST_TankType(victim)],
					flHypnoFireDivisor = !g_bTankConfig[ST_TankType(victim)] ? g_flHypnoFireDivisor[ST_TankType(victim)] : g_flHypnoFireDivisor2[ST_TankType(victim)],
					flHypnoMeleeDivisor = !g_bTankConfig[ST_TankType(victim)] ? g_flHypnoMeleeDivisor[ST_TankType(victim)] : g_flHypnoMeleeDivisor2[ST_TankType(victim)];
				if (damagetype & DMG_BULLET)
				{
					damage /= flHypnoBulletDivisor;
				}
				else if (damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA)
				{
					damage /= flHypnoExplosiveDivisor;
				}
				else if (damagetype & DMG_BURN || damagetype & (DMG_BURN|DMG_PREVENT_PHYSICS_FORCE) || damagetype & (DMG_BURN|DMG_DIRECT))
				{
					damage /= flHypnoFireDivisor;
				}
				else if (damagetype & DMG_SLASH || damagetype & DMG_CLUB)
				{
					damage /= flHypnoMeleeDivisor;
				}

				int iHypnoMode = !g_bTankConfig[ST_TankType(victim)] ? g_iHypnoMode[ST_TankType(victim)] : g_iHypnoMode2[ST_TankType(victim)],
					iHealth = GetClientHealth(attacker), iTarget = iGetRandomSurvivor(attacker);
				if (iHealth > damage)
				{
					if (iHypnoMode == 1 && iTarget > 0)
					{
						SetEntityHealth(iTarget, iHealth - RoundToNearest(damage));
					}
					else
					{
						SetEntityHealth(attacker, iHealth - RoundToNearest(damage));
					}
				}
				else
				{
					if (iHypnoMode == 1 && iTarget > 0)
					{
						SetEntProp(iTarget, Prop_Send, "m_isIncapacitated", 1);
					}
					else
					{
						SetEntProp(attacker, Prop_Send, "m_isIncapacitated", 1);
					}
				}

				return Plugin_Changed;
			}
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
		char sTankName[33];
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iHypnoAbility[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Ability Enabled", 0);
				g_iHypnoAbility[iIndex] = iClamp(g_iHypnoAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Hypno Ability/Ability Effect", g_sHypnoEffect[iIndex], sizeof(g_sHypnoEffect[]), "0");
				kvSuperTanks.GetString("Hypno Ability/Ability Message", g_sHypnoMessage[iIndex], sizeof(g_sHypnoMessage[]), "0");
				g_flHypnoBulletDivisor[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Bullet Divisor", 20.0);
				g_flHypnoBulletDivisor[iIndex] = flClamp(g_flHypnoBulletDivisor[iIndex], 0.1, 9999999999.0);
				g_flHypnoChance[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Chance", 33.3);
				g_flHypnoChance[iIndex] = flClamp(g_flHypnoChance[iIndex], 0.0, 100.0);
				g_flHypnoDuration[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Duration", 5.0);
				g_flHypnoDuration[iIndex] = flClamp(g_flHypnoDuration[iIndex], 0.1, 9999999999.0);
				g_flHypnoExplosiveDivisor[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Explosive Divisor", 20.0);
				g_flHypnoExplosiveDivisor[iIndex] = flClamp(g_flHypnoExplosiveDivisor[iIndex], 0.1, 9999999999.0);
				g_flHypnoFireDivisor[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Fire Divisor", 200.0);
				g_flHypnoFireDivisor[iIndex] = flClamp(g_flHypnoFireDivisor[iIndex], 0.1, 9999999999.0);
				g_iHypnoHit[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Hit", 0);
				g_iHypnoHit[iIndex] = iClamp(g_iHypnoHit[iIndex], 0, 1);
				g_iHypnoHitMode[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Hit Mode", 0);
				g_iHypnoHitMode[iIndex] = iClamp(g_iHypnoHitMode[iIndex], 0, 2);
				g_flHypnoMeleeDivisor[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Melee Divisor", 200.0);
				g_flHypnoMeleeDivisor[iIndex] = flClamp(g_flHypnoMeleeDivisor[iIndex], 0.1, 9999999999.0);
				g_iHypnoMode[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Mode", 0);
				g_iHypnoMode[iIndex] = iClamp(g_iHypnoMode[iIndex], 0, 1);
				g_flHypnoRange[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Range", 150.0);
				g_flHypnoRange[iIndex] = flClamp(g_flHypnoRange[iIndex], 1.0, 9999999999.0);
				g_flHypnoRangeChance[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Range Chance", 15.0);
				g_flHypnoRangeChance[iIndex] = flClamp(g_flHypnoRangeChance[iIndex], 0.0, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iHypnoAbility2[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Ability Enabled", g_iHypnoAbility[iIndex]);
				g_iHypnoAbility2[iIndex] = iClamp(g_iHypnoAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Hypno Ability/Ability Effect", g_sHypnoEffect2[iIndex], sizeof(g_sHypnoEffect2[]), g_sHypnoEffect[iIndex]);
				kvSuperTanks.GetString("Hypno Ability/Ability Message", g_sHypnoMessage2[iIndex], sizeof(g_sHypnoMessage2[]), g_sHypnoMessage[iIndex]);
				g_flHypnoBulletDivisor2[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Bullet Divisor", g_flHypnoBulletDivisor[iIndex]);
				g_flHypnoBulletDivisor2[iIndex] = flClamp(g_flHypnoBulletDivisor2[iIndex], 0.1, 9999999999.0);
				g_flHypnoChance2[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Chance", g_flHypnoChance[iIndex]);
				g_flHypnoChance2[iIndex] = flClamp(g_flHypnoChance2[iIndex], 0.0, 100.0);
				g_flHypnoDuration2[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Duration", g_flHypnoDuration[iIndex]);
				g_flHypnoDuration2[iIndex] = flClamp(g_flHypnoDuration2[iIndex], 0.1, 9999999999.0);
				g_flHypnoExplosiveDivisor2[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Explosive Divisor", g_flHypnoExplosiveDivisor[iIndex]);
				g_flHypnoExplosiveDivisor2[iIndex] = flClamp(g_flHypnoExplosiveDivisor2[iIndex], 0.1, 9999999999.0);
				g_flHypnoFireDivisor2[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Fire Divisor", g_flHypnoFireDivisor[iIndex]);
				g_flHypnoFireDivisor2[iIndex] = flClamp(g_flHypnoFireDivisor2[iIndex], 0.1, 9999999999.0);
				g_iHypnoHit2[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Hit", g_iHypnoHit[iIndex]);
				g_iHypnoHit2[iIndex] = iClamp(g_iHypnoHit2[iIndex], 0, 1);
				g_iHypnoHitMode2[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Hit Mode", g_iHypnoHitMode[iIndex]);
				g_iHypnoHitMode2[iIndex] = iClamp(g_iHypnoHitMode2[iIndex], 0, 2);
				g_flHypnoMeleeDivisor2[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Melee Divisor", g_flHypnoMeleeDivisor[iIndex]);
				g_flHypnoMeleeDivisor2[iIndex] = flClamp(g_flHypnoMeleeDivisor2[iIndex], 0.1, 9999999999.0);
				g_iHypnoMode2[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Mode", g_iHypnoMode[iIndex]);
				g_iHypnoMode2[iIndex] = iClamp(g_iHypnoMode2[iIndex], 0, 1);
				g_flHypnoRange2[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Range", g_flHypnoRange[iIndex]);
				g_flHypnoRange2[iIndex] = flClamp(g_flHypnoRange2[iIndex], 1.0, 9999999999.0);
				g_flHypnoRangeChance2[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Range Chance", g_flHypnoRangeChance[iIndex]);
				g_flHypnoRangeChance2[iIndex] = flClamp(g_flHypnoRangeChance2[iIndex], 0.0, 100.0);
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
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank, "024") && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveHypno(iTank);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		float flHypnoRange = !g_bTankConfig[ST_TankType(tank)] ? g_flHypnoRange[ST_TankType(tank)] : g_flHypnoRange2[ST_TankType(tank)],
			flHypnoRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flHypnoRangeChance[ST_TankType(tank)] : g_flHypnoRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, "234"))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flHypnoRange)
				{
					vHypnoHit(iSurvivor, tank, flHypnoRangeChance, iHypnoAbility(tank), "2", "3");
				}
			}
		}
	}
}

public void ST_BossStage(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveHypno(tank);
	}
}

static void vHypnoHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bHypno[survivor])
	{
		g_bHypno[survivor] = true;
		g_iHypnoOwner[survivor] = tank;

		float flHypnoDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flHypnoDuration[ST_TankType(tank)] : g_flHypnoDuration2[ST_TankType(tank)];
		DataPack dpStopHypno;
		CreateDataTimer(flHypnoDuration, tTimerStopHypno, dpStopHypno, TIMER_FLAG_NO_MAPCHANGE);
		dpStopHypno.WriteCell(GetClientUserId(survivor));
		dpStopHypno.WriteCell(GetClientUserId(tank));
		dpStopHypno.WriteString(message);

		char sHypnoEffect[4];
		sHypnoEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sHypnoEffect[ST_TankType(tank)] : g_sHypnoEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sHypnoEffect, mode);

		char sHypnoMessage[3];
		sHypnoMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sHypnoMessage[ST_TankType(tank)] : g_sHypnoMessage2[ST_TankType(tank)];
		if (StrContains(sHypnoMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Hypno", sTankName, survivor);
		}
	}
}

static void vRemoveHypno(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor, "24") && g_bHypno[iSurvivor] && g_iHypnoOwner[iSurvivor] == tank)
		{
			g_bHypno[iSurvivor] = false;
			g_iHypnoOwner[iSurvivor] = 0;
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
		{
			g_bHypno[iPlayer] = false;
			g_iHypnoOwner[iPlayer] = 0;
		}
	}
}

static float flHypnoChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHypnoChance[ST_TankType(tank)] : g_flHypnoChance2[ST_TankType(tank)];
}

static int iHypnoAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHypnoAbility[ST_TankType(tank)] : g_iHypnoAbility2[ST_TankType(tank)];
}

static int iHypnoHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHypnoHit[ST_TankType(tank)] : g_iHypnoHit2[ST_TankType(tank)];
}

static int iHypnoHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHypnoHitMode[ST_TankType(tank)] : g_iHypnoHitMode2[ST_TankType(tank)];
}

public Action tTimerStopHypno(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bHypno[iSurvivor] = false;
		g_iHypnoOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bHypno[iSurvivor])
	{
		g_bHypno[iSurvivor] = false;
		g_iHypnoOwner[iSurvivor] = 0;

		return Plugin_Stop;
	}

	g_bHypno[iSurvivor] = false;
	g_iHypnoOwner[iSurvivor] = 0;

	char sHypnoMessage[3], sMessage[3];
	sHypnoMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sHypnoMessage[ST_TankType(iTank)] : g_sHypnoMessage2[ST_TankType(iTank)];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (StrContains(sHypnoMessage, "3") != -1)
	{
		ST_PrintToChatAll("%s %t", ST_TAG2, "Hypno2", iSurvivor);
	}

	return Plugin_Continue;
}