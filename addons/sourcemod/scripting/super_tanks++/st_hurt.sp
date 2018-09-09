// Super Tanks++: Hurt Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Hurt Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bHurt[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flHurtDuration[ST_MAXTYPES + 1], g_flHurtDuration2[ST_MAXTYPES + 1], g_flHurtRange[ST_MAXTYPES + 1], g_flHurtRange2[ST_MAXTYPES + 1];
int g_iHurtAbility[ST_MAXTYPES + 1], g_iHurtAbility2[ST_MAXTYPES + 1], g_iHurtChance[ST_MAXTYPES + 1], g_iHurtChance2[ST_MAXTYPES + 1], g_iHurtDamage[ST_MAXTYPES + 1],
	g_iHurtDamage2[ST_MAXTYPES + 1], g_iHurtHit[ST_MAXTYPES + 1], g_iHurtHit2[ST_MAXTYPES + 1], g_iHurtRangeChance[ST_MAXTYPES + 1], g_iHurtRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Hurt Ability only supports Left 4 Dead 1 & 2.");
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
	g_bHurt[client] = false;
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
				int iHurtChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iHurtChance[ST_TankType(attacker)] : g_iHurtChance2[ST_TankType(attacker)],
					iHurtHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iHurtHit[ST_TankType(attacker)] : g_iHurtHit2[ST_TankType(attacker)];
				vHurtHit(victim, attacker, iHurtChance, iHurtHit);
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
			main ? (g_iHurtAbility[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Ability Enabled", 0)) : (g_iHurtAbility2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Ability Enabled", g_iHurtAbility[iIndex]));
			main ? (g_iHurtAbility[iIndex] = iSetCellLimit(g_iHurtAbility[iIndex], 0, 1)) : (g_iHurtAbility2[iIndex] = iSetCellLimit(g_iHurtAbility2[iIndex], 0, 1));
			main ? (g_iHurtChance[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Chance", 4)) : (g_iHurtChance2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Chance", g_iHurtChance[iIndex]));
			main ? (g_iHurtChance[iIndex] = iSetCellLimit(g_iHurtChance[iIndex], 1, 9999999999)) : (g_iHurtChance2[iIndex] = iSetCellLimit(g_iHurtChance2[iIndex], 1, 9999999999));
			main ? (g_iHurtDamage[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Damage", 1)) : (g_iHurtDamage2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Damage", g_iHurtDamage[iIndex]));
			main ? (g_iHurtDamage[iIndex] = iSetCellLimit(g_iHurtDamage[iIndex], 1, 9999999999)) : (g_iHurtDamage2[iIndex] = iSetCellLimit(g_iHurtDamage2[iIndex], 1, 9999999999));
			main ? (g_flHurtDuration[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Duration", 5.0)) : (g_flHurtDuration2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Duration", g_flHurtDuration[iIndex]));
			main ? (g_flHurtDuration[iIndex] = flSetFloatLimit(g_flHurtDuration[iIndex], 0.1, 9999999999.0)) : (g_flHurtDuration2[iIndex] = flSetFloatLimit(g_flHurtDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iHurtHit[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Hit", 0)) : (g_iHurtHit2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Hit", g_iHurtHit[iIndex]));
			main ? (g_iHurtHit[iIndex] = iSetCellLimit(g_iHurtHit[iIndex], 0, 1)) : (g_iHurtHit2[iIndex] = iSetCellLimit(g_iHurtHit2[iIndex], 0, 1));
			main ? (g_flHurtRange[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Range", 150.0)) : (g_flHurtRange2[iIndex] = kvSuperTanks.GetFloat("Hurt Ability/Hurt Range", g_flHurtRange[iIndex]));
			main ? (g_flHurtRange[iIndex] = flSetFloatLimit(g_flHurtRange[iIndex], 1.0, 9999999999.0)) : (g_flHurtRange2[iIndex] = flSetFloatLimit(g_flHurtRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iHurtRangeChance[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Range Chance", 16)) : (g_iHurtRangeChance2[iIndex] = kvSuperTanks.GetNum("Hurt Ability/Hurt Range Chance", g_iHurtRangeChance[iIndex]));
			main ? (g_iHurtRangeChance[iIndex] = iSetCellLimit(g_iHurtRangeChance[iIndex], 1, 9999999999)) : (g_iHurtRangeChance2[iIndex] = iSetCellLimit(g_iHurtRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iHurtAbility = !g_bTankConfig[ST_TankType(client)] ? g_iHurtAbility[ST_TankType(client)] : g_iHurtAbility2[ST_TankType(client)],
			iHurtRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iHurtChance[ST_TankType(client)] : g_iHurtChance2[ST_TankType(client)];
		float flHurtRange = !g_bTankConfig[ST_TankType(client)] ? g_flHurtRange[ST_TankType(client)] : g_flHurtRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flHurtRange)
				{
					vHurtHit(iSurvivor, client, iHurtRangeChance, iHurtAbility);
				}
			}
		}
	}
}

stock void vHurtHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bHurt[client])
	{
		g_bHurt[client] = true;
		DataPack dpHurt = new DataPack();
		CreateDataTimer(1.0, tTimerHurt, dpHurt, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpHurt.WriteCell(GetClientUserId(client)), dpHurt.WriteCell(GetClientUserId(owner)), dpHurt.WriteCell(enabled), dpHurt.WriteFloat(GetEngineTime());
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bHurt[iPlayer] = false;
		}
	}
}

public Action tTimerHurt(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bHurt[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bHurt[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iHurtAbility = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flHurtDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flHurtDuration[ST_TankType(iTank)] : g_flHurtDuration2[ST_TankType(iTank)];
	if (iHurtAbility == 0 || (flTime + flHurtDuration) < GetEngineTime())
	{
		g_bHurt[iSurvivor] = false;
		return Plugin_Stop;
	}
	char sDamage[6];
	int iHurtDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_iHurtDamage[ST_TankType(iTank)] : g_iHurtDamage2[ST_TankType(iTank)];
	IntToString(iHurtDamage, sDamage, sizeof(sDamage));
	vDamage(iSurvivor, sDamage);
	return Plugin_Continue;
}