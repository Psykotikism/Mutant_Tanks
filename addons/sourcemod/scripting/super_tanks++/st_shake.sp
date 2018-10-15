// Super Tanks++: Shake Ability
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
	name = "[ST++] Shake Ability",
	author = ST_AUTHOR,
	description = "The Super Tank shakes the survivors' screens.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bShake[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sShakeEffect[ST_MAXTYPES + 1][4], g_sShakeEffect2[ST_MAXTYPES + 1][4];

float g_flShakeChance[ST_MAXTYPES + 1], g_flShakeChance2[ST_MAXTYPES + 1], g_flShakeDuration[ST_MAXTYPES + 1], g_flShakeDuration2[ST_MAXTYPES + 1], g_flShakeInterval[ST_MAXTYPES + 1], g_flShakeInterval2[ST_MAXTYPES + 1], g_flShakeRange[ST_MAXTYPES + 1], g_flShakeRange2[ST_MAXTYPES + 1], g_flShakeRangeChance[ST_MAXTYPES + 1], g_flShakeRangeChance2[ST_MAXTYPES + 1];

int g_iShakeAbility[ST_MAXTYPES + 1], g_iShakeAbility2[ST_MAXTYPES + 1], g_iShakeHit[ST_MAXTYPES + 1], g_iShakeHit2[ST_MAXTYPES + 1], g_iShakeHitMode[ST_MAXTYPES + 1], g_iShakeHitMode2[ST_MAXTYPES + 1], g_iShakeMessage[ST_MAXTYPES + 1], g_iShakeMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Shake Ability only supports Left 4 Dead 1 & 2.");

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

	g_bShake[client] = false;
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

		if ((iShakeHitMode(attacker) == 0 || iShakeHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsHumanSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vShakeHit(victim, attacker, flShakeChance(attacker), iShakeHit(attacker), 1, "1");
			}
		}
		else if ((iShakeHitMode(victim) == 0 || iShakeHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vShakeHit(attacker, victim, flShakeChance(victim), iShakeHit(victim), 1, "2");
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
		char sTankName[MAX_NAME_LENGTH + 1];
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName, true))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iShakeAbility[iIndex] = kvSuperTanks.GetNum("Shake Ability/Ability Enabled", 0);
				g_iShakeAbility[iIndex] = iClamp(g_iShakeAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Shake Ability/Ability Effect", g_sShakeEffect[iIndex], sizeof(g_sShakeEffect[]), "123");
				g_iShakeMessage[iIndex] = kvSuperTanks.GetNum("Shake Ability/Ability Message", 0);
				g_iShakeMessage[iIndex] = iClamp(g_iShakeMessage[iIndex], 0, 3);
				g_flShakeChance[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Chance", 33.3);
				g_flShakeChance[iIndex] = flClamp(g_flShakeChance[iIndex], 0.1, 100.0);
				g_flShakeDuration[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Duration", 5.0);
				g_flShakeDuration[iIndex] = flClamp(g_flShakeDuration[iIndex], 0.1, 9999999999.0);
				g_iShakeHit[iIndex] = kvSuperTanks.GetNum("Shake Ability/Shake Hit", 0);
				g_iShakeHit[iIndex] = iClamp(g_iShakeHit[iIndex], 0, 1);
				g_iShakeHitMode[iIndex] = kvSuperTanks.GetNum("Shake Ability/Shake Hit Mode", 0);
				g_iShakeHitMode[iIndex] = iClamp(g_iShakeHitMode[iIndex], 0, 2);
				g_flShakeInterval[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Interval", 1.0);
				g_flShakeInterval[iIndex] = flClamp(g_flShakeInterval[iIndex], 0.1, 9999999999.0);
				g_flShakeRange[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Range", 150.0);
				g_flShakeRange[iIndex] = flClamp(g_flShakeRange[iIndex], 1.0, 9999999999.0);
				g_flShakeRangeChance[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Range Chance", 15.0);
				g_flShakeRangeChance[iIndex] = flClamp(g_flShakeRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iShakeAbility2[iIndex] = kvSuperTanks.GetNum("Shake Ability/Ability Enabled", g_iShakeAbility[iIndex]);
				g_iShakeAbility2[iIndex] = iClamp(g_iShakeAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Shake Ability/Ability Effect", g_sShakeEffect2[iIndex], sizeof(g_sShakeEffect2[]), g_sShakeEffect[iIndex]);
				g_iShakeMessage2[iIndex] = kvSuperTanks.GetNum("Shake Ability/Ability Message", g_iShakeMessage[iIndex]);
				g_iShakeMessage2[iIndex] = iClamp(g_iShakeMessage2[iIndex], 0, 3);
				g_flShakeChance2[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Chance", g_flShakeChance[iIndex]);
				g_flShakeChance2[iIndex] = flClamp(g_flShakeChance2[iIndex], 0.1, 100.0);
				g_flShakeDuration2[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Duration", g_flShakeDuration[iIndex]);
				g_flShakeDuration2[iIndex] = flClamp(g_flShakeDuration2[iIndex], 0.1, 9999999999.0);
				g_iShakeHit2[iIndex] = kvSuperTanks.GetNum("Shake Ability/Shake Hit", g_iShakeHit[iIndex]);
				g_iShakeHit2[iIndex] = iClamp(g_iShakeHit2[iIndex], 0, 1);
				g_iShakeHitMode2[iIndex] = kvSuperTanks.GetNum("Shake Ability/Shake Hit Mode", g_iShakeHitMode[iIndex]);
				g_iShakeHitMode2[iIndex] = iClamp(g_iShakeHitMode2[iIndex], 0, 2);
				g_flShakeInterval2[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Interval", g_flShakeInterval[iIndex]);
				g_flShakeInterval2[iIndex] = flClamp(g_flShakeInterval2[iIndex], 0.1, 9999999999.0);
				g_flShakeRange2[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Range", g_flShakeRange[iIndex]);
				g_flShakeRange2[iIndex] = flClamp(g_flShakeRange2[iIndex], 1.0, 9999999999.0);
				g_flShakeRangeChance2[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Range Chance", g_flShakeRangeChance[iIndex]);
				g_flShakeRangeChance2[iIndex] = flClamp(g_flShakeRangeChance2[iIndex], 0.1, 100.0);
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
		int iShakeAbility = !g_bTankConfig[ST_TankType(tank)] ? g_iShakeAbility[ST_TankType(tank)] : g_iShakeAbility2[ST_TankType(tank)];

		float flShakeRange = !g_bTankConfig[ST_TankType(tank)] ? g_flShakeRange[ST_TankType(tank)] : g_flShakeRange2[ST_TankType(tank)],
			flShakeRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flShakeRangeChance[ST_TankType(tank)] : g_flShakeRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flShakeRange)
				{
					vShakeHit(iSurvivor, tank, flShakeRangeChance, iShakeAbility, 2, "3");
				}
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
			g_bShake[iPlayer] = false;
		}
	}
}

static void vReset2(int survivor, int tank, int message)
{
	g_bShake[survivor] = false;

	if (iShakeMessage(tank) == message || iShakeMessage(tank) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Shake2", survivor);
	}
}

static void vShakeHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsHumanSurvivor(survivor) && !g_bShake[survivor])
	{
		g_bShake[survivor] = true;

		float flShakeInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flShakeInterval[ST_TankType(tank)] : g_flShakeInterval2[ST_TankType(tank)];
		DataPack dpShake;
		CreateDataTimer(flShakeInterval, tTimerShake, dpShake, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpShake.WriteCell(GetClientUserId(survivor));
		dpShake.WriteCell(GetClientUserId(tank));
		dpShake.WriteCell(message);
		dpShake.WriteCell(enabled);
		dpShake.WriteFloat(GetEngineTime());

		char sShakeEffect[4];
		sShakeEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sShakeEffect[ST_TankType(tank)] : g_sShakeEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sShakeEffect, mode);

		if (iShakeMessage(tank) == message || iShakeMessage(tank) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Shake", sTankName, survivor);
		}
	}
}

static float flShakeChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flShakeChance[ST_TankType(tank)] : g_flShakeChance2[ST_TankType(tank)];
}

static int iShakeHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iShakeHit[ST_TankType(tank)] : g_iShakeHit2[ST_TankType(tank)];
}

static int iShakeHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iShakeHitMode[ST_TankType(tank)] : g_iShakeHitMode2[ST_TankType(tank)];
}

static int iShakeMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iShakeMessage[ST_TankType(tank)] : g_iShakeMessage2[ST_TankType(tank)];
}

public Action tTimerShake(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsHumanSurvivor(iSurvivor) || !g_bShake[iSurvivor])
	{
		g_bShake[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iShakeChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank, iShakeChat);

		return Plugin_Stop;
	}

	int iShakeAbility = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flShakeDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flShakeDuration[ST_TankType(iTank)] : g_flShakeDuration2[ST_TankType(iTank)];

	if (iShakeAbility == 0 || (flTime + flShakeDuration) < GetEngineTime())
	{
		vReset2(iSurvivor, iTank, iShakeChat);

		return Plugin_Stop;
	}

	vShake(iSurvivor);

	return Plugin_Continue;
}