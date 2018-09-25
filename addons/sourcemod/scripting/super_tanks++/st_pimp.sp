// Super Tanks++: Pimp Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Pimp Ability",
	author = ST_AUTHOR,
	description = "The Super Tank pimp slaps survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bPimp[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flPimpRange[ST_MAXTYPES + 1], g_flPimpRange2[ST_MAXTYPES + 1];
int g_iPimpAbility[ST_MAXTYPES + 1], g_iPimpAbility2[ST_MAXTYPES + 1], g_iPimpAmount[ST_MAXTYPES + 1], g_iPimpAmount2[ST_MAXTYPES + 1], g_iPimpChance[ST_MAXTYPES + 1], g_iPimpChance2[ST_MAXTYPES + 1], g_iPimpCount[MAXPLAYERS + 1], g_iPimpDamage[ST_MAXTYPES + 1], g_iPimpDamage2[ST_MAXTYPES + 1], g_iPimpHit[ST_MAXTYPES + 1], g_iPimpHit2[ST_MAXTYPES + 1], g_iPimpHitMode[ST_MAXTYPES + 1], g_iPimpHitMode2[ST_MAXTYPES + 1], g_iPimpMessage[ST_MAXTYPES + 1], g_iPimpMessage2[ST_MAXTYPES + 1], g_iPimpRangeChance[ST_MAXTYPES + 1], g_iPimpRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_Left4Dead && !bIsL4D2())
	{
		strcopy(error, err_max, "[ST++] Pimp Ability only supports Left 4 Dead 1 & 2.");
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
	g_bPimp[client] = false;
	g_iPimpCount[client] = 0;
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
		if ((iPimpHitMode(attacker) == 0 || iPimpHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vPimpHit(victim, attacker, iPimpChance(attacker), iPimpHit(attacker), 1);
			}
		}
		else if ((iPimpHitMode(victim) == 0 || iPimpHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vPimpHit(attacker, victim, iPimpChance(victim), iPimpHit(victim), 1);
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
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iPimpAbility[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Ability Enabled", 0)) : (g_iPimpAbility2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Ability Enabled", g_iPimpAbility[iIndex]));
			main ? (g_iPimpAbility[iIndex] = iClamp(g_iPimpAbility[iIndex], 0, 1)) : (g_iPimpAbility2[iIndex] = iClamp(g_iPimpAbility2[iIndex], 0, 1));
			main ? (g_iPimpMessage[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Ability Message", 0)) : (g_iPimpMessage2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Ability Message", g_iPimpMessage[iIndex]));
			main ? (g_iPimpMessage[iIndex] = iClamp(g_iPimpMessage[iIndex], 0, 3)) : (g_iPimpMessage2[iIndex] = iClamp(g_iPimpMessage2[iIndex], 0, 3));
			main ? (g_iPimpAmount[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Amount", 5)) : (g_iPimpAmount2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Amount", g_iPimpAmount[iIndex]));
			main ? (g_iPimpAmount[iIndex] = iClamp(g_iPimpAmount[iIndex], 1, 9999999999)) : (g_iPimpAmount2[iIndex] = iClamp(g_iPimpAmount2[iIndex], 1, 9999999999));
			main ? (g_iPimpChance[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Chance", 4)) : (g_iPimpChance2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Chance", g_iPimpChance[iIndex]));
			main ? (g_iPimpChance[iIndex] = iClamp(g_iPimpChance[iIndex], 1, 9999999999)) : (g_iPimpChance2[iIndex] = iClamp(g_iPimpChance2[iIndex], 1, 9999999999));
			main ? (g_iPimpDamage[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Damage", 1)) : (g_iPimpDamage2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Damage", g_iPimpDamage[iIndex]));
			main ? (g_iPimpDamage[iIndex] = iClamp(g_iPimpDamage[iIndex], 1, 9999999999)) : (g_iPimpDamage2[iIndex] = iClamp(g_iPimpDamage2[iIndex], 1, 9999999999));
			main ? (g_iPimpHit[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Hit", 0)) : (g_iPimpHit2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Hit", g_iPimpHit[iIndex]));
			main ? (g_iPimpHit[iIndex] = iClamp(g_iPimpHit[iIndex], 0, 1)) : (g_iPimpHit2[iIndex] = iClamp(g_iPimpHit2[iIndex], 0, 1));
			main ? (g_iPimpHitMode[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Hit Mode", 0)) : (g_iPimpHitMode2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Hit Mode", g_iPimpHitMode[iIndex]));
			main ? (g_iPimpHitMode[iIndex] = iClamp(g_iPimpHitMode[iIndex], 0, 2)) : (g_iPimpHitMode2[iIndex] = iClamp(g_iPimpHitMode2[iIndex], 0, 2));
			main ? (g_flPimpRange[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Range", 150.0)) : (g_flPimpRange2[iIndex] = kvSuperTanks.GetFloat("Pimp Ability/Pimp Range", g_flPimpRange[iIndex]));
			main ? (g_flPimpRange[iIndex] = flClamp(g_flPimpRange[iIndex], 1.0, 9999999999.0)) : (g_flPimpRange2[iIndex] = flClamp(g_flPimpRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iPimpRangeChance[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Range Chance", 16)) : (g_iPimpRangeChance2[iIndex] = kvSuperTanks.GetNum("Pimp Ability/Pimp Range Chance", g_iPimpRangeChance[iIndex]));
			main ? (g_iPimpRangeChance[iIndex] = iClamp(g_iPimpRangeChance[iIndex], 1, 9999999999)) : (g_iPimpRangeChance2[iIndex] = iClamp(g_iPimpRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iPimpAbility = !g_bTankConfig[ST_TankType(client)] ? g_iPimpAbility[ST_TankType(client)] : g_iPimpAbility2[ST_TankType(client)],
			iPimpRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iPimpChance[ST_TankType(client)] : g_iPimpChance2[ST_TankType(client)];
		float flPimpRange = !g_bTankConfig[ST_TankType(client)] ? g_flPimpRange[ST_TankType(client)] : g_flPimpRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flPimpRange)
				{
					vPimpHit(iSurvivor, client, iPimpRangeChance, iPimpAbility, 2);
				}
			}
		}
	}
}

stock void vPimpHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bPimp[client])
	{
		g_bPimp[client] = true;
		DataPack dpPimp = new DataPack();
		CreateDataTimer(0.5, tTimerPimp, dpPimp, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpPimp.WriteCell(GetClientUserId(client)), dpPimp.WriteCell(GetClientUserId(owner)), dpPimp.WriteCell(message), dpPimp.WriteCell(enabled);
		if (iPimpMessage(owner) == message || iPimpMessage(owner) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Pimp", sTankName, client);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bPimp[iPlayer] = false;
			g_iPimpCount[iPlayer] = 0;
		}
	}
}

stock void vReset2(int client, int owner, int message)
{
	g_bPimp[client] = false;
	g_iPimpCount[client] = 0;
	if (iPimpMessage(owner) == message || iPimpMessage(owner) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Pimp2", client);
	}
}

stock int iPimpChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPimpChance[ST_TankType(client)] : g_iPimpChance2[ST_TankType(client)];
}

stock int iPimpHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPimpHit[ST_TankType(client)] : g_iPimpHit2[ST_TankType(client)];
}

stock int iPimpHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPimpHitMode[ST_TankType(client)] : g_iPimpHitMode2[ST_TankType(client)];
}

stock int iPimpMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPimpMessage[ST_TankType(client)] : g_iPimpMessage2[ST_TankType(client)];
}

public Action tTimerPimp(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bPimp[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell()), iPimpChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank, iPimpChat);
		return Plugin_Stop;
	}
	int iPimpAbility = pack.ReadCell(),
		iPimpAmount = !g_bTankConfig[ST_TankType(iTank)] ? g_iPimpAmount[ST_TankType(iTank)] : g_iPimpAmount2[ST_TankType(iTank)];
	if (iPimpAbility == 0 || g_iPimpCount[iSurvivor] >= iPimpAmount)
	{
		vReset2(iSurvivor, iTank, iPimpChat);
		return Plugin_Stop;
	}
	int iPimpDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_iPimpDamage[ST_TankType(iTank)] : g_iPimpDamage2[ST_TankType(iTank)];
	SlapPlayer(iSurvivor, iPimpDamage, true);
	g_iPimpCount[iSurvivor]++;
	return Plugin_Continue;
}