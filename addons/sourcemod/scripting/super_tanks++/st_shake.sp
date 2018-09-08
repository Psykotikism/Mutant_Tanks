// Super Tanks++: Shake Ability
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
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bShake[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flShakeDuration[ST_MAXTYPES + 1], g_flShakeDuration2[ST_MAXTYPES + 1], g_flShakeRange[ST_MAXTYPES + 1], g_flShakeRange2[ST_MAXTYPES + 1];
int g_iShakeAbility[ST_MAXTYPES + 1], g_iShakeAbility2[ST_MAXTYPES + 1], g_iShakeChance[ST_MAXTYPES + 1], g_iShakeChance2[ST_MAXTYPES + 1], g_iShakeHit[ST_MAXTYPES + 1], g_iShakeHit2[ST_MAXTYPES + 1], g_iShakeRangeChance[ST_MAXTYPES + 1], g_iShakeRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
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

public void OnMapStart()
{
	vReset();
	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				SDKHook(iPlayer, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
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
		if (ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iShakeChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iShakeChance[ST_TankType(attacker)] : g_iShakeChance2[ST_TankType(attacker)],
					iShakeHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iShakeHit[ST_TankType(attacker)] : g_iShakeHit2[ST_TankType(attacker)];
				vShakeHit(victim, attacker, iShakeChance, iShakeHit);
			}
		}
	}
}

public void ST_Configs(char[] savepath, bool main)
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
			main ? (g_iShakeAbility[iIndex] = kvSuperTanks.GetNum("Shake Ability/Ability Enabled", 0)) : (g_iShakeAbility2[iIndex] = kvSuperTanks.GetNum("Shake Ability/Ability Enabled", g_iShakeAbility[iIndex]));
			main ? (g_iShakeAbility[iIndex] = iSetCellLimit(g_iShakeAbility[iIndex], 0, 1)) : (g_iShakeAbility2[iIndex] = iSetCellLimit(g_iShakeAbility2[iIndex], 0, 1));
			main ? (g_iShakeChance[iIndex] = kvSuperTanks.GetNum("Shake Ability/Shake Chance", 4)) : (g_iShakeChance2[iIndex] = kvSuperTanks.GetNum("Shake Ability/Shake Chance", g_iShakeChance[iIndex]));
			main ? (g_iShakeChance[iIndex] = iSetCellLimit(g_iShakeChance[iIndex], 1, 9999999999)) : (g_iShakeChance2[iIndex] = iSetCellLimit(g_iShakeChance2[iIndex], 1, 9999999999));
			main ? (g_flShakeDuration[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Duration", 5.0)) : (g_flShakeDuration2[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Duration", g_flShakeDuration[iIndex]));
			main ? (g_flShakeDuration[iIndex] = flSetFloatLimit(g_flShakeDuration[iIndex], 0.1, 9999999999.0)) : (g_flShakeDuration2[iIndex] = flSetFloatLimit(g_flShakeDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iShakeHit[iIndex] = kvSuperTanks.GetNum("Shake Ability/Shake Hit", 0)) : (g_iShakeHit2[iIndex] = kvSuperTanks.GetNum("Shake Ability/Shake Hit", g_iShakeHit[iIndex]));
			main ? (g_iShakeHit[iIndex] = iSetCellLimit(g_iShakeHit[iIndex], 0, 1)) : (g_iShakeHit2[iIndex] = iSetCellLimit(g_iShakeHit2[iIndex], 0, 1));
			main ? (g_flShakeRange[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Range", 150.0)) : (g_flShakeRange2[iIndex] = kvSuperTanks.GetFloat("Shake Ability/Shake Range", g_flShakeRange[iIndex]));
			main ? (g_flShakeRange[iIndex] = flSetFloatLimit(g_flShakeRange[iIndex], 1.0, 9999999999.0)) : (g_flShakeRange2[iIndex] = flSetFloatLimit(g_flShakeRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iShakeRangeChance[iIndex] = kvSuperTanks.GetNum("Shake Ability/Shake Range Chance", 16)) : (g_iShakeRangeChance2[iIndex] = kvSuperTanks.GetNum("Shake Ability/Shake Range Chance", g_iShakeRangeChance[iIndex]));
			main ? (g_iShakeRangeChance[iIndex] = iSetCellLimit(g_iShakeRangeChance[iIndex], 1, 9999999999)) : (g_iShakeRangeChance2[iIndex] = iSetCellLimit(g_iShakeRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iShakeAbility = !g_bTankConfig[ST_TankType(client)] ? g_iShakeAbility[ST_TankType(client)] : g_iShakeAbility2[ST_TankType(client)],
			iShakeRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iShakeChance[ST_TankType(client)] : g_iShakeChance2[ST_TankType(client)];
		float flShakeRange = !g_bTankConfig[ST_TankType(client)] ? g_flShakeRange[ST_TankType(client)] : g_flShakeRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flShakeRange)
				{
					vShakeHit(iSurvivor, client, iShakeRangeChance, iShakeAbility);
				}
			}
		}
	}
}

void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bShake[iPlayer] = false;
		}
	}
}

void vShakeHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bShake[client])
	{
		g_bShake[client] = true;
		DataPack dpShake = new DataPack();
		CreateDataTimer(1.0, tTimerShake, dpShake, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpShake.WriteCell(GetClientUserId(client));
		dpShake.WriteCell(GetClientUserId(owner));
		dpShake.WriteCell(enabled);
		dpShake.WriteFloat(GetEngineTime());
	}
}

public Action tTimerShake(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bShake[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bShake[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iShakeAbility = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flShakeDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flShakeDuration[ST_TankType(iTank)] : g_flShakeDuration2[ST_TankType(iTank)];
	if (iShakeAbility == 0 || (flTime + flShakeDuration) < GetEngineTime())
	{
		g_bShake[iSurvivor] = false;
		return Plugin_Stop;
	}
	vShake(iSurvivor);
	return Plugin_Continue;
}