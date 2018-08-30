// Super Tanks++: Fire Ability
#define REQUIRE_PLUGIN
#include <super_tanks++>
#undef REQUIRE_PLUGIN
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Fire Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad, g_bPluginEnabled, g_bTankConfig[ST_MAXTYPES + 1];
float g_flFireRange[ST_MAXTYPES + 1], g_flFireRange2[ST_MAXTYPES + 1];
int g_iFireAbility[ST_MAXTYPES + 1], g_iFireAbility2[ST_MAXTYPES + 1],
	g_iFireChance[ST_MAXTYPES + 1], g_iFireChance2[ST_MAXTYPES + 1], g_iFireHit[ST_MAXTYPES + 1],
	g_iFireHit2[ST_MAXTYPES + 1], g_iFireRangeChance[ST_MAXTYPES + 1],
	g_iFireRangeChance2[ST_MAXTYPES + 1], g_iFireRock[ST_MAXTYPES + 1],
	g_iFireRock2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Fire Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	LibraryExists("super_tanks++") ? (g_bPluginEnabled = true) : (g_bPluginEnabled = false);
}

public void OnLibraryAdded(const char[] name)
{
	if (strcmp(name, "super_tanks++") == 0)
	{
		g_bPluginEnabled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (strcmp(name, "super_tanks++") == 0)
	{
		g_bPluginEnabled = false;
	}
}

public void OnMapStart()
{
	PrecacheModel(MODEL_GASCAN, true);
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
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_bPluginEnabled && ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (ST_TankAllowed(attacker) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iFireChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iFireChance[ST_TankType(attacker)] : g_iFireChance2[ST_TankType(attacker)];
				int iFireHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iFireHit[ST_TankType(attacker)] : g_iFireHit2[ST_TankType(attacker)];
				vFireHit(victim, attacker, iFireChance, iFireHit);
			}
		}
		else if (ST_TankAllowed(victim) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				int iFireChance = !g_bTankConfig[ST_TankType(victim)] ? g_iFireChance[ST_TankType(victim)] : g_iFireChance2[ST_TankType(victim)];
				int iFireHit = !g_bTankConfig[ST_TankType(victim)] ? g_iFireHit[ST_TankType(victim)] : g_iFireHit2[ST_TankType(victim)];
				vFireHit(attacker, victim, iFireChance, iFireHit);
			}
		}
	}
}

public void ST_Configs(char[] savepath, int limit, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = 1; iIndex <= limit; iIndex++)
	{
		char sName[MAX_NAME_LENGTH + 1];
		Format(sName, sizeof(sName), "Tank %d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iFireAbility[iIndex] = kvSuperTanks.GetNum("Fire Ability/Ability Enabled", 0)) : (g_iFireAbility2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Ability Enabled", g_iFireAbility[iIndex]));
			main ? (g_iFireAbility[iIndex] = iSetCellLimit(g_iFireAbility[iIndex], 0, 1)) : (g_iFireAbility2[iIndex] = iSetCellLimit(g_iFireAbility2[iIndex], 0, 1));
			main ? (g_iFireChance[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Chance", 4)) : (g_iFireChance2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Chance", g_iFireChance[iIndex]));
			main ? (g_iFireChance[iIndex] = iSetCellLimit(g_iFireChance[iIndex], 1, 9999999999)) : (g_iFireChance2[iIndex] = iSetCellLimit(g_iFireChance2[iIndex], 1, 9999999999));
			main ? (g_iFireHit[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Hit", 0)) : (g_iFireHit2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Hit", g_iFireHit[iIndex]));
			main ? (g_iFireHit[iIndex] = iSetCellLimit(g_iFireHit[iIndex], 0, 1)) : (g_iFireHit2[iIndex] = iSetCellLimit(g_iFireHit2[iIndex], 0, 1));
			main ? (g_flFireRange[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Range", 150.0)) : (g_flFireRange2[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Range", g_flFireRange[iIndex]));
			main ? (g_flFireRange[iIndex] = flSetFloatLimit(g_flFireRange[iIndex], 1.0, 9999999999.0)) : (g_flFireRange2[iIndex] = flSetFloatLimit(g_flFireRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iFireRangeChance[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Range Chance", 16)) : (g_iFireRangeChance2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Range Chance", g_iFireRangeChance[iIndex]));
			main ? (g_iFireRangeChance[iIndex] = iSetCellLimit(g_iFireRangeChance[iIndex], 1, 9999999999)) : (g_iFireRangeChance2[iIndex] = iSetCellLimit(g_iFireRangeChance2[iIndex], 1, 9999999999));
			main ? (g_iFireRock[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Rock Break", 0)) : (g_iFireRock2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Rock Break", g_iFireRock[iIndex]));
			main ? (g_iFireRock[iIndex] = iSetCellLimit(g_iFireRock[iIndex], 0, 1)) : (g_iFireRock2[iIndex] = iSetCellLimit(g_iFireRock2[iIndex], 0, 1));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid");
		int iTank = GetClientOfUserId(iTankId);
		int iFireAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iFireAbility[ST_TankType(iTank)] : g_iFireAbility2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iFireAbility == 1 && bIsL4D2Game())
		{
			float flPos[3];
			GetClientAbsOrigin(iTank, flPos);
			vSpecialAttack(iTank, flPos, MODEL_GASCAN);
		}
	}
}

public void ST_Ability(int client)
{
	if (g_bPluginEnabled && ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iFireAbility = !g_bTankConfig[ST_TankType(client)] ? g_iFireAbility[ST_TankType(client)] : g_iFireAbility2[ST_TankType(client)];
		int iFireRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iFireChance[ST_TankType(client)] : g_iFireChance2[ST_TankType(client)];
		float flFireRange = !g_bTankConfig[ST_TankType(client)] ? g_flFireRange[ST_TankType(client)] : g_flFireRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flFireRange)
				{
					vFireHit(iSurvivor, client, iFireRangeChance, iFireAbility);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	int iFireAbility = !g_bTankConfig[ST_TankType(client)] ? g_iFireAbility[ST_TankType(client)] : g_iFireAbility2[ST_TankType(client)];
	if (g_bPluginEnabled && ST_TankAllowed(client) && iFireAbility == 1 && bIsL4D2Game())
	{
		float flPos[3];
		GetClientAbsOrigin(client, flPos);
		vSpecialAttack(client, flPos, MODEL_PROPANETANK);
	}
}

public void ST_RockBreak(int client, int entity)
{
	int iFireRock = !g_bTankConfig[ST_TankType(client)] ? g_iFireRock[ST_TankType(client)] : g_iFireRock2[ST_TankType(client)];
	if (g_bPluginEnabled && iFireRock == 1 && ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		float flPos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPos);
		vSpecialAttack(client, flPos, MODEL_GASCAN);
	}
}

void vFireHit(int client, int owner, int chance, int enabled)
{
	if (g_bPluginEnabled && enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		float flPos[3];
		GetClientAbsOrigin(client, flPos);
		vSpecialAttack(owner, flPos, MODEL_GASCAN);
	}
}