// Super Tanks++: Panic Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Panic Ability",
	author = ST_AUTHOR,
	description = "The Super Tank starts panic events.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bPanic[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sPanicEffect[ST_MAXTYPES + 1][4], g_sPanicEffect2[ST_MAXTYPES + 1][4];

float g_flPanicInterval[ST_MAXTYPES + 1], g_flPanicInterval2[ST_MAXTYPES + 1], g_flPanicRange[ST_MAXTYPES + 1], g_flPanicRange2[ST_MAXTYPES + 1];

int g_iPanicAbility[ST_MAXTYPES + 1], g_iPanicAbility2[ST_MAXTYPES + 1], g_iPanicChance[ST_MAXTYPES + 1], g_iPanicChance2[ST_MAXTYPES + 1], g_iPanicHit[ST_MAXTYPES + 1], g_iPanicHit2[ST_MAXTYPES + 1], g_iPanicHitMode[ST_MAXTYPES + 1], g_iPanicHitMode2[ST_MAXTYPES + 1], g_iPanicMessage[ST_MAXTYPES + 1], g_iPanicMessage2[ST_MAXTYPES + 1], g_iPanicRangeChance[ST_MAXTYPES + 1], g_iPanicRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Panic Ability only supports Left 4 Dead 1 & 2.");

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

	g_bPanic[client] = false;
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

		if ((iPanicHitMode(attacker) == 0 || iPanicHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vPanicHit(victim, attacker, iPanicChance(attacker), iPanicHit(attacker), 1, "1");
			}
		}
		else if ((iPanicHitMode(victim) == 0 || iPanicHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vPanicHit(attacker, victim, iPanicChance(victim), iPanicHit(victim), 1, "2");
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
		char sName[MAX_NAME_LENGTH + 1];
		Format(sName, sizeof(sName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iPanicAbility[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Enabled", 0);
				g_iPanicAbility[iIndex] = iClamp(g_iPanicAbility[iIndex], 0, 3);
				kvSuperTanks.GetString("Panic Ability/Ability Effect", g_sPanicEffect[iIndex], sizeof(g_sPanicEffect[]), "123");
				g_iPanicMessage[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Message", 0);
				g_iPanicMessage[iIndex] = iClamp(g_iPanicMessage[iIndex], 0, 7);
				g_iPanicChance[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Chance", 4);
				g_iPanicChance[iIndex] = iClamp(g_iPanicChance[iIndex], 1, 9999999999);
				g_iPanicHit[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Hit", 0);
				g_iPanicHit[iIndex] = iClamp(g_iPanicHit[iIndex], 0, 1);
				g_iPanicHitMode[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Hit Mode", 0);
				g_iPanicHitMode[iIndex] = iClamp(g_iPanicHitMode[iIndex], 0, 2);
				g_flPanicInterval[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Interval", 5.0);
				g_flPanicInterval[iIndex] = flClamp(g_flPanicInterval[iIndex], 0.1, 9999999999.0);
				g_flPanicRange[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Range", 150.0);
				g_flPanicRange[iIndex] = flClamp(g_flPanicRange[iIndex], 1.0, 9999999999.0);
				g_iPanicRangeChance[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Range Chance", 16);
				g_iPanicRangeChance[iIndex] = iClamp(g_iPanicRangeChance[iIndex], 1, 9999999999);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iPanicAbility2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Enabled", g_iPanicAbility[iIndex]);
				g_iPanicAbility2[iIndex] = iClamp(g_iPanicAbility2[iIndex], 0, 3);
				kvSuperTanks.GetString("Panic Ability/Ability Effect", g_sPanicEffect2[iIndex], sizeof(g_sPanicEffect2[]), g_sPanicEffect[iIndex]);
				g_iPanicMessage2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Message", g_iPanicMessage[iIndex]);
				g_iPanicMessage2[iIndex] = iClamp(g_iPanicMessage2[iIndex], 0, 7);
				g_iPanicChance2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Chance", g_iPanicChance[iIndex]);
				g_iPanicChance2[iIndex] = iClamp(g_iPanicChance2[iIndex], 1, 9999999999);
				g_iPanicHit2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Hit", g_iPanicHit[iIndex]);
				g_iPanicHit2[iIndex] = iClamp(g_iPanicHit2[iIndex], 0, 1);
				g_iPanicHitMode2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Hit Mode", g_iPanicHitMode[iIndex]);
				g_iPanicHitMode2[iIndex] = iClamp(g_iPanicHitMode2[iIndex], 0, 2);
				g_flPanicInterval2[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Interval", g_flPanicInterval[iIndex]);
				g_flPanicInterval2[iIndex] = flClamp(g_flPanicInterval2[iIndex], 0.1, 9999999999.0);
				g_flPanicRange2[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Range", g_flPanicRange[iIndex]);
				g_flPanicRange2[iIndex] = flClamp(g_flPanicRange2[iIndex], 1.0, 9999999999.0);
				g_iPanicRangeChance2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Range Chance", g_iPanicRangeChance[iIndex]);
				g_iPanicRangeChance2[iIndex] = iClamp(g_iPanicRangeChance2[iIndex], 1, 9999999999);
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
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iPanicAbility(iTank) == 1 && GetRandomInt(1, iPanicChance(iTank)) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vCheatCommand(iTank, "director_force_panic_event");
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		int iPanicRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_iPanicChance[ST_TankType(tank)] : g_iPanicChance2[ST_TankType(tank)];

		float flPanicRange = !g_bTankConfig[ST_TankType(tank)] ? g_flPanicRange[ST_TankType(tank)] : g_flPanicRange2[ST_TankType(tank)],
			flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flPanicRange)
				{
					vPanicHit(iSurvivor, tank, iPanicRangeChance, iPanicAbility(tank), 2, "3");
				}
			}
		}

		if ((iPanicAbility(tank) == 2 || iPanicAbility(tank) == 3) && !g_bPanic[tank])
		{
			g_bPanic[tank] = true;

			float flPanicInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flPanicInterval[ST_TankType(tank)] : g_flPanicInterval2[ST_TankType(tank)];
			CreateTimer(flPanicInterval, tTimerPanic, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}

static void vPanicHit(int survivor, int tank, int chance, int enabled, int message, const char[] mode)
{
	if ((enabled == 1 || enabled == 3) && GetRandomInt(1, chance) == 1 && bIsSurvivor(survivor))
	{
		vCheatCommand(survivor, "director_force_panic_event");

		char sPanicEffect[4];
		sPanicEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sPanicEffect[ST_TankType(tank)] : g_sPanicEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sPanicEffect, mode);

		if (iPanicMessage(tank) == message || iPanicMessage(tank) == 4 || iPanicMessage(tank) == 5 || iPanicMessage(tank) == 6 || iPanicMessage(tank) == 7)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Panic", sTankName);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bPanic[iPlayer] = false;
		}
	}
}

static int iPanicAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPanicAbility[ST_TankType(tank)] : g_iPanicAbility2[ST_TankType(tank)];
}

static int iPanicChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPanicChance[ST_TankType(tank)] : g_iPanicChance2[ST_TankType(tank)];
}

static int iPanicHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPanicHit[ST_TankType(tank)] : g_iPanicHit2[ST_TankType(tank)];
}

static int iPanicHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPanicHitMode[ST_TankType(tank)] : g_iPanicHitMode2[ST_TankType(tank)];
}

static int iPanicMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iPanicMessage[ST_TankType(tank)] : g_iPanicMessage2[ST_TankType(tank)];
}

public Action tTimerPanic(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bPanic[iTank])
	{
		g_bPanic[iTank] = false;

		return Plugin_Stop;
	}

	if (iPanicAbility(iTank) != 2 && iPanicAbility(iTank) != 3)
	{
		g_bPanic[iTank] = false;

		return Plugin_Stop;
	}

	vCheatCommand(iTank, "director_force_panic_event");

	switch (iPanicMessage(iTank))
	{
		case 3, 5, 6, 7:
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(iTank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Panic", sTankName);
		}
	}

	return Plugin_Continue;
}