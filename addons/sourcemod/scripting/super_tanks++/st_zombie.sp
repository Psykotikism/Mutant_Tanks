// Super Tanks++: Zombie Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Zombie Ability",
	author = ST_AUTHOR,
	description = "The Super Tank spawns zombies.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1], g_bZombie[MAXPLAYERS + 1];
float g_flZombieInterval[ST_MAXTYPES + 1], g_flZombieInterval2[ST_MAXTYPES + 1], g_flZombieRange[ST_MAXTYPES + 1], g_flZombieRange2[ST_MAXTYPES + 1];
int g_iZombieAbility[ST_MAXTYPES + 1], g_iZombieAbility2[ST_MAXTYPES + 1], g_iZombieAmount[ST_MAXTYPES + 1], g_iZombieAmount2[ST_MAXTYPES + 1], g_iZombieChance[ST_MAXTYPES + 1], g_iZombieChance2[ST_MAXTYPES + 1], g_iZombieHit[ST_MAXTYPES + 1], g_iZombieHit2[ST_MAXTYPES + 1], g_iZombieHitMode[ST_MAXTYPES + 1], g_iZombieHitMode2[ST_MAXTYPES + 1], g_iZombieMessage[ST_MAXTYPES + 1], g_iZombieMessage2[ST_MAXTYPES + 1], g_iZombieRangeChance[ST_MAXTYPES + 1], g_iZombieRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_Left4Dead && !bIsL4D2())
	{
		strcopy(error, err_max, "[ST++] Zombie Ability only supports Left 4 Dead 1 & 2.");
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
	g_bZombie[client] = false;
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
		if ((iZombieHitMode(attacker) == 0 || iZombieHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vZombieHit(attacker, iZombieChance(attacker), iZombieHit(attacker), 1);
			}
		}
		else if ((iZombieHitMode(victim) == 0 || iZombieHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vZombieHit(victim, iZombieChance(victim), iZombieHit(victim), 1);
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
			main ? (g_iZombieAbility[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Ability Enabled", 0)) : (g_iZombieAbility2[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Ability Enabled", g_iZombieAbility[iIndex]));
			main ? (g_iZombieAbility[iIndex] = iClamp(g_iZombieAbility[iIndex], 0, 3)) : (g_iZombieAbility2[iIndex] = iClamp(g_iZombieAbility2[iIndex], 0, 3));
			main ? (g_iZombieMessage[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Ability Message", 0)) : (g_iZombieMessage2[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Ability Message", g_iZombieMessage[iIndex]));
			main ? (g_iZombieMessage[iIndex] = iClamp(g_iZombieMessage[iIndex], 0, 7)) : (g_iZombieMessage2[iIndex] = iClamp(g_iZombieMessage2[iIndex], 0, 7));
			main ? (g_iZombieAmount[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Zombie Amount", 10)) : (g_iZombieAmount2[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Zombie Amount", g_iZombieAmount[iIndex]));
			main ? (g_iZombieAmount[iIndex] = iClamp(g_iZombieAmount[iIndex], 1, 100)) : (g_iZombieAmount2[iIndex] = iClamp(g_iZombieAmount2[iIndex], 1, 100));
			main ? (g_iZombieChance[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Zombie Chance", 4)) : (g_iZombieChance2[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Zombie Chance", g_iZombieChance[iIndex]));
			main ? (g_iZombieChance[iIndex] = iClamp(g_iZombieChance[iIndex], 1, 9999999999)) : (g_iZombieChance2[iIndex] = iClamp(g_iZombieChance2[iIndex], 1, 9999999999));
			main ? (g_iZombieHit[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Zombie Hit", 0)) : (g_iZombieHit2[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Zombie Hit", g_iZombieHit[iIndex]));
			main ? (g_iZombieHit[iIndex] = iClamp(g_iZombieHit[iIndex], 0, 1)) : (g_iZombieHit2[iIndex] = iClamp(g_iZombieHit2[iIndex], 0, 1));
			main ? (g_iZombieHitMode[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Zombie Hit Mode", 0)) : (g_iZombieHitMode2[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Zombie Hit Mode", g_iZombieHitMode[iIndex]));
			main ? (g_iZombieHitMode[iIndex] = iClamp(g_iZombieHitMode[iIndex], 0, 2)) : (g_iZombieHitMode2[iIndex] = iClamp(g_iZombieHitMode2[iIndex], 0, 2));
			main ? (g_flZombieInterval[iIndex] = kvSuperTanks.GetFloat("Zombie Ability/Zombie Interval", 5.0)) : (g_flZombieInterval2[iIndex] = kvSuperTanks.GetFloat("Zombie Ability/Zombie Interval", g_flZombieInterval[iIndex]));
			main ? (g_flZombieInterval[iIndex] = flClamp(g_flZombieInterval[iIndex], 0.1, 9999999999.0)) : (g_flZombieInterval2[iIndex] = flClamp(g_flZombieInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_flZombieRange[iIndex] = kvSuperTanks.GetFloat("Zombie Ability/Zombie Range", 150.0)) : (g_flZombieRange2[iIndex] = kvSuperTanks.GetFloat("Zombie Ability/Zombie Range", g_flZombieRange[iIndex]));
			main ? (g_flZombieRange[iIndex] = flClamp(g_flZombieRange[iIndex], 1.0, 9999999999.0)) : (g_flZombieRange2[iIndex] = flClamp(g_flZombieRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iZombieRangeChance[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Zombie Range Chance", 16)) : (g_iZombieRangeChance2[iIndex] = kvSuperTanks.GetNum("Zombie Ability/Zombie Range Chance", g_iZombieRangeChance[iIndex]));
			main ? (g_iZombieRangeChance[iIndex] = iClamp(g_iZombieRangeChance[iIndex], 1, 9999999999)) : (g_iZombieRangeChance2[iIndex] = iClamp(g_iZombieRangeChance2[iIndex], 1, 9999999999));
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
		if (iZombieAbility(iTank) == 1 && GetRandomInt(1, iZombieChance(iTank)) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vZombie(iTank);
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client) && !g_bZombie[client])
	{
		int iZombieRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iZombieChance[ST_TankType(client)] : g_iZombieChance2[ST_TankType(client)];
		float flZombieRange = !g_bTankConfig[ST_TankType(client)] ? g_flZombieRange[ST_TankType(client)] : g_flZombieRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flZombieRange)
				{
					vZombieHit(client, iZombieRangeChance, iZombieAbility(client), 2);
				}
			}
		}
		if ((iZombieAbility(client) == 2 || iZombieAbility(client) == 3) && !g_bZombie[client])
		{
			g_bZombie[client] = true;
			float flZombieInterval = !g_bTankConfig[ST_TankType(client)] ? g_flZombieInterval[ST_TankType(client)] : g_flZombieInterval2[ST_TankType(client)];
			CreateTimer(flZombieInterval, tTimerZombie, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bZombie[iPlayer] = false;
		}
	}
}

stock void vZombie(int client)
{
	int iZombieAmount = !g_bTankConfig[ST_TankType(client)] ? g_iZombieAmount[ST_TankType(client)] : g_iZombieAmount2[ST_TankType(client)];
	for (int iZombie = 1; iZombie <= iZombieAmount; iZombie++)
	{
		vCheatCommand(client, bIsL4D2() ? "z_spawn_old" : "z_spawn", "zombie area");
	}
}

stock void vZombieHit(int client, int chance, int enabled, int message)
{
	if ((enabled == 1 || enabled == 3) && GetRandomInt(1, chance) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		vZombie(client);
		if (iZombieMessage(client) == message || iZombieMessage(client) == 4 || iZombieMessage(client) == 5 || iZombieMessage(client) == 6 || iZombieMessage(client) == 7)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(client, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Zombie", sTankName);
		}
	}
}

stock int iZombieAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iZombieAbility[ST_TankType(client)] : g_iZombieAbility2[ST_TankType(client)];
}

stock int iZombieChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iZombieChance[ST_TankType(client)] : g_iZombieChance2[ST_TankType(client)];
}

stock int iZombieHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iZombieHit[ST_TankType(client)] : g_iZombieHit2[ST_TankType(client)];
}

stock int iZombieHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iZombieHitMode[ST_TankType(client)] : g_iZombieHitMode2[ST_TankType(client)];
}

stock int iZombieMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iZombieMessage[ST_TankType(client)] : g_iZombieMessage2[ST_TankType(client)];
}

public Action tTimerZombie(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bZombie[iTank] = false;
		return Plugin_Stop;
	}
	if (iZombieAbility(iTank) == 0)
	{
		g_bZombie[iTank] = false;
		return Plugin_Stop;
	}
	vZombie(iTank);
	switch (iZombieMessage(iTank))
	{
		case 3, 5, 6, 7:
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(iTank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Zombie", sTankName);
		}
	}
	return Plugin_Continue;
}