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
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bPanic[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flPanicInterval[ST_MAXTYPES + 1], g_flPanicInterval2[ST_MAXTYPES + 1], g_flPanicRange[ST_MAXTYPES + 1], g_flPanicRange2[ST_MAXTYPES + 1];
int g_iPanicAbility[ST_MAXTYPES + 1], g_iPanicAbility2[ST_MAXTYPES + 1], g_iPanicChance[ST_MAXTYPES + 1], g_iPanicChance2[ST_MAXTYPES + 1], g_iPanicHit[ST_MAXTYPES + 1], g_iPanicHit2[ST_MAXTYPES + 1], g_iPanicHitMode[ST_MAXTYPES + 1], g_iPanicHitMode2[ST_MAXTYPES + 1], g_iPanicMessage[ST_MAXTYPES + 1], g_iPanicMessage2[ST_MAXTYPES + 1], g_iPanicRangeChance[ST_MAXTYPES + 1], g_iPanicRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
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
	if (strcmp(name, "st_clone", false) == 0)
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (strcmp(name, "st_clone", false) == 0)
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
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vPanicHit(attacker, iPanicChance(attacker), iPanicHit(attacker), 1);
			}
		}
		else if ((iPanicHitMode(victim) == 0 || iPanicHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vPanicHit(victim, iPanicChance(victim), iPanicHit(victim), 1);
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
		Format(sName, sizeof(sName), "Tank %d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iPanicAbility[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Enabled", 0)) : (g_iPanicAbility2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Enabled", g_iPanicAbility[iIndex]));
			main ? (g_iPanicAbility[iIndex] = iSetCellLimit(g_iPanicAbility[iIndex], 0, 3)) : (g_iPanicAbility2[iIndex] = iSetCellLimit(g_iPanicAbility2[iIndex], 0, 3));
			main ? (g_iPanicMessage[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Message", 0)) : (g_iPanicMessage2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Ability Message", g_iPanicMessage[iIndex]));
			main ? (g_iPanicMessage[iIndex] = iSetCellLimit(g_iPanicMessage[iIndex], 0, 7)) : (g_iPanicMessage2[iIndex] = iSetCellLimit(g_iPanicMessage2[iIndex], 0, 7));
			main ? (g_iPanicChance[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Chance", 4)) : (g_iPanicChance2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Chance", g_iPanicChance[iIndex]));
			main ? (g_iPanicChance[iIndex] = iSetCellLimit(g_iPanicChance[iIndex], 1, 9999999999)) : (g_iPanicChance2[iIndex] = iSetCellLimit(g_iPanicChance2[iIndex], 1, 9999999999));
			main ? (g_iPanicHit[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Hit", 0)) : (g_iPanicHit2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Hit", g_iPanicHit[iIndex]));
			main ? (g_iPanicHit[iIndex] = iSetCellLimit(g_iPanicHit[iIndex], 0, 1)) : (g_iPanicHit2[iIndex] = iSetCellLimit(g_iPanicHit2[iIndex], 0, 1));
			main ? (g_iPanicHitMode[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Hit Mode", 0)) : (g_iPanicHitMode2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Hit Mode", g_iPanicHitMode[iIndex]));
			main ? (g_iPanicHitMode[iIndex] = iSetCellLimit(g_iPanicHitMode[iIndex], 0, 2)) : (g_iPanicHitMode2[iIndex] = iSetCellLimit(g_iPanicHitMode2[iIndex], 0, 2));
			main ? (g_flPanicInterval[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Interval", 5.0)) : (g_flPanicInterval2[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Interval", g_flPanicInterval[iIndex]));
			main ? (g_flPanicInterval[iIndex] = flSetFloatLimit(g_flPanicInterval[iIndex], 0.1, 9999999999.0)) : (g_flPanicInterval2[iIndex] = flSetFloatLimit(g_flPanicInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_flPanicRange[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Range", 150.0)) : (g_flPanicRange2[iIndex] = kvSuperTanks.GetFloat("Panic Ability/Panic Range", g_flPanicRange[iIndex]));
			main ? (g_flPanicRange[iIndex] = flSetFloatLimit(g_flPanicRange[iIndex], 1.0, 9999999999.0)) : (g_flPanicRange2[iIndex] = flSetFloatLimit(g_flPanicRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iPanicRangeChance[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Range Chance", 16)) : (g_iPanicRangeChance2[iIndex] = kvSuperTanks.GetNum("Panic Ability/Panic Range Chance", g_iPanicRangeChance[iIndex]));
			main ? (g_iPanicRangeChance[iIndex] = iSetCellLimit(g_iPanicRangeChance[iIndex], 1, 9999999999)) : (g_iPanicRangeChance2[iIndex] = iSetCellLimit(g_iPanicRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iPanicAbility(iTank) == 1 && GetRandomInt(1, iPanicChance(iTank)) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && IsPlayerAlive(iTank))
		{
			vCheatCommand(iTank, "director_force_panic_event");
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iPanicRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iPanicChance[ST_TankType(client)] : g_iPanicChance2[ST_TankType(client)];
		float flPanicRange = !g_bTankConfig[ST_TankType(client)] ? g_flPanicRange[ST_TankType(client)] : g_flPanicRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flPanicRange)
				{
					vPanicHit(client, iPanicRangeChance, iPanicAbility(client), 2);
				}
			}
		}
		if ((iPanicAbility(client) == 2 || iPanicAbility(client) == 3) && !g_bPanic[client])
		{
			g_bPanic[client] = true;
			float flPanicInterval = !g_bTankConfig[ST_TankType(client)] ? g_flPanicInterval[ST_TankType(client)] : g_flPanicInterval2[ST_TankType(client)];
			CreateTimer(flPanicInterval, tTimerPanic, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}

stock void vPanicHit(int client, int chance, int enabled, int message)
{
	if ((enabled == 1 || enabled == 3) && GetRandomInt(1, chance) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		vCheatCommand(client, "director_force_panic_event");
		if (iPanicMessage(client) == message || iPanicMessage(client) == 4 || iPanicMessage(client) == 5 || iPanicMessage(client) == 6 || iPanicMessage(client) == 7)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(client, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Panic", sTankName);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bPanic[iPlayer] = false;
		}
	}
}

stock int iPanicAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPanicAbility[ST_TankType(client)] : g_iPanicAbility2[ST_TankType(client)];
}

stock int iPanicChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPanicChance[ST_TankType(client)] : g_iPanicChance2[ST_TankType(client)];
}

stock int iPanicHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPanicHit[ST_TankType(client)] : g_iPanicHit2[ST_TankType(client)];
}

stock int iPanicHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPanicHitMode[ST_TankType(client)] : g_iPanicHitMode2[ST_TankType(client)];
}

stock int iPanicMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPanicMessage[ST_TankType(client)] : g_iPanicMessage2[ST_TankType(client)];
}

public Action tTimerPanic(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
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