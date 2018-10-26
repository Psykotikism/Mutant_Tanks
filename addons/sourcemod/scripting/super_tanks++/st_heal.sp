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

// Super Tanks++: Heal Ability
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
	name = "[ST++] Heal Ability",
	author = ST_AUTHOR,
	description = "The Super Tank gains health from other nearby infected and sets survivors to temporary health who will die when they reach 0 HP.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bHeal[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sHealEffect[ST_MAXTYPES + 1][4], g_sHealEffect2[ST_MAXTYPES + 1][4], g_sTankColors[ST_MAXTYPES + 1][28], g_sTankColors2[ST_MAXTYPES + 1][28];

ConVar g_cvSTMaxIncapCount;

float g_flHealAbsorbRange[ST_MAXTYPES + 1], g_flHealAbsorbRange2[ST_MAXTYPES + 1], g_flHealBuffer[ST_MAXTYPES + 1], g_flHealBuffer2[ST_MAXTYPES + 1], g_flHealChance[ST_MAXTYPES + 1], g_flHealChance2[ST_MAXTYPES + 1], g_flHealInterval[ST_MAXTYPES + 1], g_flHealInterval2[ST_MAXTYPES + 1], g_flHealRange[ST_MAXTYPES + 1], g_flHealRange2[ST_MAXTYPES + 1], g_flHealRangeChance[ST_MAXTYPES + 1], g_flHealRangeChance2[ST_MAXTYPES + 1];

int g_iGlowOutline[ST_MAXTYPES + 1], g_iGlowOutline2[ST_MAXTYPES + 1], g_iHealAbility[ST_MAXTYPES + 1], g_iHealAbility2[ST_MAXTYPES + 1], g_iHealCommon[ST_MAXTYPES + 1], g_iHealCommon2[ST_MAXTYPES + 1], g_iHealHit[ST_MAXTYPES + 1], g_iHealHit2[ST_MAXTYPES + 1], g_iHealHitMode[ST_MAXTYPES + 1], g_iHealHitMode2[ST_MAXTYPES + 1], g_iHealMessage[ST_MAXTYPES + 1], g_iHealMessage2[ST_MAXTYPES + 1], g_iHealSpecial[ST_MAXTYPES + 1], g_iHealSpecial2[ST_MAXTYPES + 1], g_iHealTank[ST_MAXTYPES + 1], g_iHealTank2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Heal Ability only supports Left 4 Dead 1 & 2.");

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

	g_cvSTMaxIncapCount = FindConVar("survivor_max_incapacitated_count");

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

	g_bHeal[client] = false;
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

		if ((iHealHitMode(attacker) == 0 || iHealHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vHealHit(victim, attacker, flHealChance(attacker), iHealHit(attacker), 1, "1");
			}
		}
		else if ((iHealHitMode(victim) == 0 || iHealHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vHealHit(attacker, victim, flHealChance(victim), iHealHit(victim), 1, "2");
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

				kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors[iIndex], sizeof(g_sTankColors[]), "255,255,255,255|255,255,255");
				g_iGlowOutline[iIndex] = kvSuperTanks.GetNum("General/Glow Outline", 1);
				g_iGlowOutline[iIndex] = iClamp(g_iGlowOutline[iIndex], 0, 1);
				g_iHealAbility[iIndex] = kvSuperTanks.GetNum("Heal Ability/Ability Enabled", 0);
				g_iHealAbility[iIndex] = iClamp(g_iHealAbility[iIndex], 0, 3);
				kvSuperTanks.GetString("Heal Ability/Ability Effect", g_sHealEffect[iIndex], sizeof(g_sHealEffect[]), "123");
				g_iHealMessage[iIndex] = kvSuperTanks.GetNum("Heal Ability/Ability Message", 0);
				g_iHealMessage[iIndex] = iClamp(g_iHealMessage[iIndex], 0, 7);
				g_flHealAbsorbRange[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Absorb Range", 500.0);
				g_flHealAbsorbRange[iIndex] = flClamp(g_flHealAbsorbRange[iIndex], 1.0, 9999999999.0);
				g_flHealBuffer[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Buffer", 25.0);
				g_flHealBuffer[iIndex] = flClamp(g_flHealBuffer[iIndex], 1.0, float(ST_MAXHEALTH));
				g_flHealChance[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Chance", 33.3);
				g_flHealChance[iIndex] = flClamp(g_flHealChance[iIndex], 0.1, 100.0);
				g_iHealCommon[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Commons", 50);
				g_iHealCommon[iIndex] = iClamp(g_iHealCommon[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				g_iHealHit[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Hit", 0);
				g_iHealHit[iIndex] = iClamp(g_iHealHit[iIndex], 0, 1);
				g_iHealHitMode[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Hit Mode", 0);
				g_iHealHitMode[iIndex] = iClamp(g_iHealHitMode[iIndex], 0, 2);
				g_flHealInterval[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Interval", 5.0);
				g_flHealInterval[iIndex] = flClamp(g_flHealInterval[iIndex], 0.1, 9999999999.0);
				g_flHealRange[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Range", 150.0);
				g_flHealRange[iIndex] = flClamp(g_flHealRange[iIndex], 1.0, 9999999999.0);
				g_flHealRangeChance[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Range Chance", 15.0);
				g_flHealRangeChance[iIndex] = flClamp(g_flHealRangeChance[iIndex], 0.1, 100.0);
				g_iHealSpecial[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Specials", 100);
				g_iHealSpecial[iIndex] = iClamp(g_iHealSpecial[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				g_iHealTank[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Tanks", 500);
				g_iHealTank[iIndex] = iClamp(g_iHealTank[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors2[iIndex], sizeof(g_sTankColors2[]), g_sTankColors[iIndex]);
				g_iGlowOutline2[iIndex] = kvSuperTanks.GetNum("General/Glow Outline", g_iGlowOutline[iIndex]);
				g_iGlowOutline2[iIndex] = iClamp(g_iGlowOutline2[iIndex], 0, 1);
				g_iHealAbility2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Ability Enabled", g_iHealAbility[iIndex]);
				g_iHealAbility2[iIndex] = iClamp(g_iHealAbility2[iIndex], 0, 3);
				kvSuperTanks.GetString("Heal Ability/Ability Effect", g_sHealEffect2[iIndex], sizeof(g_sHealEffect2[]), g_sHealEffect[iIndex]);
				g_iHealMessage2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Ability Message", g_iHealMessage[iIndex]);
				g_iHealMessage2[iIndex] = iClamp(g_iHealMessage2[iIndex], 0, 7);
				g_flHealAbsorbRange2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Absorb Range", g_flHealAbsorbRange[iIndex]);
				g_flHealAbsorbRange2[iIndex] = flClamp(g_flHealAbsorbRange2[iIndex], 1.0, 9999999999.0);
				g_flHealBuffer2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Buffer", g_flHealBuffer[iIndex]);
				g_flHealBuffer2[iIndex] = flClamp(g_flHealBuffer2[iIndex], 1.0, float(ST_MAXHEALTH));
				g_flHealChance2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Chance", g_flHealChance[iIndex]);
				g_flHealChance2[iIndex] = flClamp(g_flHealChance2[iIndex], 0.1, 100.0);
				g_iHealCommon2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Commons", g_iHealCommon[iIndex]);
				g_iHealCommon2[iIndex] = iClamp(g_iHealCommon2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				g_iHealHit2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Hit", g_iHealHit[iIndex]);
				g_iHealHit2[iIndex] = iClamp(g_iHealHit2[iIndex], 0, 1);
				g_iHealHitMode2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Hit Mode", g_iHealHitMode[iIndex]);
				g_iHealHitMode2[iIndex] = iClamp(g_iHealHitMode2[iIndex], 0, 2);
				g_flHealInterval2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Interval", g_flHealInterval[iIndex]);
				g_flHealInterval2[iIndex] = flClamp(g_flHealInterval2[iIndex], 0.1, 9999999999.0);
				g_flHealRange2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Range", g_flHealRange[iIndex]);
				g_flHealRange2[iIndex] = flClamp(g_flHealRange2[iIndex], 1.0, 9999999999.0);
				g_flHealRangeChance2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Range Chance", g_flHealRangeChance[iIndex]);
				g_flHealRangeChance2[iIndex] = flClamp(g_flHealRangeChance2[iIndex], 0.1, 100.0);
				g_iHealSpecial2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Specials", g_iHealSpecial[iIndex]);
				g_iHealSpecial2[iIndex] = iClamp(g_iHealSpecial2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				g_iHealTank2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Tanks", g_iHealTank[iIndex]);
				g_iHealTank2[iIndex] = iClamp(g_iHealTank2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
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

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flHealRange = !g_bTankConfig[ST_TankType(tank)] ? g_flHealRange[ST_TankType(tank)] : g_flHealRange2[ST_TankType(tank)],
			flHealRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flHealRangeChance[ST_TankType(tank)] : g_flHealRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flHealRange)
				{
					vHealHit(iSurvivor, tank, flHealRangeChance, iHealAbility(tank), 2, "3");
				}
			}
		}

		if ((iHealAbility(tank) == 2 || iHealAbility(tank) == 3) && !g_bHeal[tank])
		{
			g_bHeal[tank] = true;

			float flHealInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flHealInterval[ST_TankType(tank)] : g_flHealInterval2[ST_TankType(tank)];
			CreateTimer(flHealInterval, tTimerHeal, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

			switch (iHealMessage(tank))
			{
				case 3, 5, 6, 7:
				{
					char sTankName[33];
					ST_TankName(tank, sTankName);
					PrintToChatAll("%s %t", ST_TAG2, "Heal2", sTankName);
				}
			}
		}
	}
}

static void vHealHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	if ((enabled == 1 || enabled == 3) && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor))
	{
		int iHealth = GetClientHealth(survivor);
		if (iHealth > 0 && !bIsPlayerIncapacitated(survivor))
		{
			float flHealBuffer = !g_bTankConfig[ST_TankType(tank)] ? g_flHealBuffer[ST_TankType(tank)] : g_flHealBuffer2[ST_TankType(tank)];
			SetEntityHealth(survivor, 1);
			SetEntPropFloat(survivor, Prop_Send, "m_healthBufferTime", GetGameTime());
			SetEntPropFloat(survivor, Prop_Send, "m_healthBuffer", flHealBuffer);
			SetEntProp(survivor, Prop_Send, "m_currentReviveCount", g_cvSTMaxIncapCount.IntValue);

			char sHealEffect[4];
			sHealEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sHealEffect[ST_TankType(tank)] : g_sHealEffect2[ST_TankType(tank)];
			vEffect(survivor, tank, sHealEffect, mode);

			if (iHealMessage(tank) == message || iHealMessage(tank) == 4 || iHealMessage(tank) == 5 || iHealMessage(tank) == 6 || iHealMessage(tank) == 7)
			{
				char sTankName[33];
				ST_TankName(tank, sTankName);
				PrintToChatAll("%s %t", ST_TAG2, "Heal", sTankName, survivor);
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
			g_bHeal[iPlayer] = false;
		}
	}
}

static float flHealChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flHealChance[ST_TankType(tank)] : g_flHealChance2[ST_TankType(tank)];
}

static int iHealAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHealAbility[ST_TankType(tank)] : g_iHealAbility2[ST_TankType(tank)];
}

static int iHealHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHealHit[ST_TankType(tank)] : g_iHealHit2[ST_TankType(tank)];
}

static int iHealHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHealHitMode[ST_TankType(tank)] : g_iHealHitMode2[ST_TankType(tank)];
}

static int iHealMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iHealMessage[ST_TankType(tank)] : g_iHealMessage2[ST_TankType(tank)];
}

public Action tTimerHeal(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bHeal[iTank])
	{
		g_bHeal[iTank] = false;

		return Plugin_Stop;
	}

	if (iHealAbility(iTank) != 2 && iHealAbility(iTank) != 3)
	{
		g_bHeal[iTank] = false;

		switch (iHealMessage(iTank))
		{
			case 3, 5, 6, 7:
			{
				char sTankName[33];
				ST_TankName(iTank, sTankName);
				PrintToChatAll("%s %t", ST_TAG2, "Heal3", sTankName);
			}
		}

		return Plugin_Stop;
	}

	int iType, iSpecial = -1;
	float flHealAbsorbRange = !g_bTankConfig[ST_TankType(iTank)] ? g_flHealAbsorbRange[ST_TankType(iTank)] : g_flHealAbsorbRange2[ST_TankType(iTank)];

	while ((iSpecial = FindEntityByClassname(iSpecial, "infected")) != INVALID_ENT_REFERENCE)
	{
		float flTankPos[3], flInfectedPos[3];
		GetClientAbsOrigin(iTank, flTankPos);
		GetEntPropVector(iSpecial, Prop_Send, "m_vecOrigin", flInfectedPos);

		float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
		if (flDistance <= flHealAbsorbRange)
		{
			int iHealth = GetClientHealth(iTank),
				iCommonHealth = !g_bTankConfig[ST_TankType(iTank)] ? (iHealth + g_iHealCommon[ST_TankType(iTank)]) : (iHealth + g_iHealCommon2[ST_TankType(iTank)]),
				iExtraHealth = (iCommonHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iCommonHealth,
				iExtraHealth2 = (iCommonHealth < iHealth) ? 1 : iCommonHealth,
				iRealHealth = (iCommonHealth >= 0) ? iExtraHealth : iExtraHealth2;
			if (iHealth > 500)
			{
				SetEntityHealth(iTank, iRealHealth);

				if (bIsValidGame())
				{
					SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
					SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 185, 0));
					SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);
				}

				iType = 1;
			}
		}
	}

	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (bIsSpecialInfected(iInfected))
		{
			float flTankPos[3], flInfectedPos[3];
			GetClientAbsOrigin(iTank, flTankPos);
			GetClientAbsOrigin(iInfected, flInfectedPos);

			float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
			if (flDistance <= flHealAbsorbRange)
			{
				int iHealth = GetClientHealth(iTank),
					iSpecialHealth = !g_bTankConfig[ST_TankType(iTank)] ? (iHealth + g_iHealSpecial[ST_TankType(iTank)]) : (iHealth + g_iHealSpecial2[ST_TankType(iTank)]),
					iExtraHealth = (iSpecialHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iSpecialHealth,
					iExtraHealth2 = (iSpecialHealth < iHealth) ? 1 : iSpecialHealth,
					iRealHealth = (iSpecialHealth >= 0) ? iExtraHealth : iExtraHealth2;
				if (iHealth > 500)
				{
					SetEntityHealth(iTank, iRealHealth);

					if (iType < 2 && bIsValidGame())
					{
						SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
						SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 220, 0));
						SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);

						iType = 1;
					}
				}
			}
		}
		else if (ST_TankAllowed(iInfected) && IsPlayerAlive(iInfected) && iInfected != iTank)
		{
			float flTankPos[3], flInfectedPos[3];
			GetClientAbsOrigin(iTank, flTankPos);
			GetClientAbsOrigin(iInfected, flInfectedPos);

			float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
			if (flDistance <= flHealAbsorbRange)
			{
				int iHealth = GetClientHealth(iTank),
					iTankHealth = !g_bTankConfig[ST_TankType(iTank)] ? (iHealth + g_iHealTank[ST_TankType(iTank)]) : (iHealth + g_iHealTank2[ST_TankType(iTank)]),
					iExtraHealth = (iTankHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iTankHealth,
					iExtraHealth2 = (iTankHealth < iHealth) ? 1 : iTankHealth,
					iRealHealth = (iTankHealth >= 0) ? iExtraHealth : iExtraHealth2;
				if (iHealth > 500)
				{
					SetEntityHealth(iTank, iRealHealth);

					if (bIsValidGame())
					{
						SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
						SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 255, 0));
						SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);

						iType = 2;
					}
				}
			}
		}
	}

	if (iType == 0 && bIsValidGame())
	{
		char sSet[2][16], sTankColors[28], sGlow[3][4];
		sTankColors = !g_bTankConfig[ST_TankType(iTank)] ? g_sTankColors[ST_TankType(iTank)] : g_sTankColors2[ST_TankType(iTank)];
		ReplaceString(sTankColors, sizeof(sTankColors), " ", "");
		ExplodeString(sTankColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));

		ExplodeString(sSet[1], ",", sGlow, sizeof(sGlow), sizeof(sGlow[]));

		int iRed = (sGlow[0][0] != '\0') ? StringToInt(sGlow[0]) : 255;
		iRed = iClamp(iRed, 0, 255);

		int iGreen = (sGlow[1][0] != '\0') ? StringToInt(sGlow[1]) : 255;
		iGreen = iClamp(iGreen, 0, 255);

		int iBlue = (sGlow[2][0] != '\0') ? StringToInt(sGlow[2]) : 255;
		iBlue = iClamp(iBlue, 0, 255);

		int iGlowOutline = !g_bTankConfig[ST_TankType(iTank)] ? g_iGlowOutline[ST_TankType(iTank)] : g_iGlowOutline2[ST_TankType(iTank)];
		if (iGlowOutline == 1 && bIsValidGame())
		{
			SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
			SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(iRed, iGreen, iBlue));
			SetEntProp(iTank, Prop_Send, "m_bFlashing", 0);
		}
	}

	return Plugin_Continue;
}