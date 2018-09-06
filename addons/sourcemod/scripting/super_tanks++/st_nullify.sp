// Super Tanks++: Nullify Ability
#define REQUIRE_PLUGIN
#include <super_tanks++>
#undef REQUIRE_PLUGIN
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Nullify Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad, g_bNullify[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flNullifyDuration[ST_MAXTYPES + 1], g_flNullifyDuration2[ST_MAXTYPES + 1], g_flNullifyRange[ST_MAXTYPES + 1], g_flNullifyRange2[ST_MAXTYPES + 1];
int g_iNullifyAbility[ST_MAXTYPES + 1], g_iNullifyAbility2[ST_MAXTYPES + 1], g_iNullifyChance[ST_MAXTYPES + 1], g_iNullifyChance2[ST_MAXTYPES + 1], g_iNullifyHit[ST_MAXTYPES + 1], g_iNullifyHit2[ST_MAXTYPES + 1], g_iNullifyRangeChance[ST_MAXTYPES + 1], g_iNullifyRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Nullify Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
	return APLRes_Success;
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
	g_bNullify[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		if (ST_TankAllowed(attacker) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iNullifyChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iNullifyChance[ST_TankType(attacker)] : g_iNullifyChance2[ST_TankType(attacker)],
					iNullifyHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iNullifyHit[ST_TankType(attacker)] : g_iNullifyHit2[ST_TankType(attacker)];
				vNullifyHit(victim, attacker, iNullifyChance, iNullifyHit);
			}
		}
		else if (ST_TankAllowed(victim) && IsPlayerAlive(victim) && bIsSurvivor(attacker) && g_bNullify[attacker])
		{
			damage = 0.0;
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
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
			main ? (g_iNullifyAbility[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Ability Enabled", 0)) : (g_iNullifyAbility2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Ability Enabled", g_iNullifyAbility[iIndex]));
			main ? (g_iNullifyAbility[iIndex] = iSetCellLimit(g_iNullifyAbility[iIndex], 0, 1)) : (g_iNullifyAbility2[iIndex] = iSetCellLimit(g_iNullifyAbility2[iIndex], 0, 1));
			main ? (g_iNullifyChance[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Chance", 4)) : (g_iNullifyChance2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Chance", g_iNullifyChance[iIndex]));
			main ? (g_iNullifyChance[iIndex] = iSetCellLimit(g_iNullifyChance[iIndex], 1, 9999999999)) : (g_iNullifyChance2[iIndex] = iSetCellLimit(g_iNullifyChance2[iIndex], 1, 9999999999));
			main ? (g_flNullifyDuration[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Duration", 5.0)) : (g_flNullifyDuration2[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Duration", g_flNullifyDuration[iIndex]));
			main ? (g_flNullifyDuration[iIndex] = flSetFloatLimit(g_flNullifyDuration[iIndex], 0.1, 9999999999.0)) : (g_flNullifyDuration2[iIndex] = flSetFloatLimit(g_flNullifyDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iNullifyHit[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit", 0)) : (g_iNullifyHit2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit", g_iNullifyHit[iIndex]));
			main ? (g_iNullifyHit[iIndex] = iSetCellLimit(g_iNullifyHit[iIndex], 0, 1)) : (g_iNullifyHit2[iIndex] = iSetCellLimit(g_iNullifyHit2[iIndex], 0, 1));
			main ? (g_flNullifyRange[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Range", 150.0)) : (g_flNullifyRange2[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Range", g_flNullifyRange[iIndex]));
			main ? (g_flNullifyRange[iIndex] = flSetFloatLimit(g_flNullifyRange[iIndex], 1.0, 9999999999.0)) : (g_flNullifyRange2[iIndex] = flSetFloatLimit(g_flNullifyRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iNullifyRangeChance[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Range Chance", 16)) : (g_iNullifyRangeChance2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Range Chance", g_iNullifyRangeChance[iIndex]));
			main ? (g_iNullifyRangeChance[iIndex] = iSetCellLimit(g_iNullifyRangeChance[iIndex], 1, 9999999999)) : (g_iNullifyRangeChance2[iIndex] = iSetCellLimit(g_iNullifyRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId),
			iNullifyAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iNullifyAbility[ST_TankType(iTank)] : g_iNullifyAbility2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iNullifyAbility == 1)
		{
			vRemoveNullify();
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iNullifyAbility = !g_bTankConfig[ST_TankType(client)] ? g_iNullifyAbility[ST_TankType(client)] : g_iNullifyAbility2[ST_TankType(client)],
			iNullifyRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iNullifyChance[ST_TankType(client)] : g_iNullifyChance2[ST_TankType(client)];
		float flNullifyRange = !g_bTankConfig[ST_TankType(client)] ? g_flNullifyRange[ST_TankType(client)] : g_flNullifyRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flNullifyRange)
				{
					vNullifyHit(iSurvivor, client, iNullifyRangeChance, iNullifyAbility);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	int iNullifyAbility = !g_bTankConfig[ST_TankType(client)] ? g_iNullifyAbility[ST_TankType(client)] : g_iNullifyAbility2[ST_TankType(client)];
	if (ST_TankAllowed(client) && iNullifyAbility == 1)
	{
		vRemoveNullify();
	}
}

void vNullifyHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bNullify[client])
	{
		g_bNullify[client] = true;
		float flNullifyDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flNullifyDuration[ST_TankType(owner)] : g_flNullifyDuration2[ST_TankType(owner)];
		DataPack dpStopNullify = new DataPack();
		CreateDataTimer(flNullifyDuration, tTimerStopNullify, dpStopNullify, TIMER_FLAG_NO_MAPCHANGE);
		dpStopNullify.WriteCell(GetClientUserId(client));
		dpStopNullify.WriteCell(GetClientUserId(owner));
	}
}

void vRemoveNullify()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bNullify[iSurvivor])
		{
			g_bNullify[iSurvivor] = false;
		}
	}
}

void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bNullify[iPlayer] = false;
		}
	}
}

public Action tTimerStopNullify(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bNullify[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		g_bNullify[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iNullifyAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iNullifyAbility[ST_TankType(iTank)] : g_iNullifyAbility2[ST_TankType(iTank)];
	if (iNullifyAbility == 0)
	{
		g_bNullify[iSurvivor] = false;
		return Plugin_Stop;
	}
	g_bNullify[iSurvivor] = false;
	return Plugin_Continue;
}