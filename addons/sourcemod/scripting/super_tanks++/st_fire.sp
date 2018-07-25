// Super Tanks++: Fire Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Fire Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"

bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flFireRange[ST_MAXTYPES + 1];
float g_flFireRange2[ST_MAXTYPES + 1];
int g_iFireAbility[ST_MAXTYPES + 1];
int g_iFireAbility2[ST_MAXTYPES + 1];
int g_iFireChance[ST_MAXTYPES + 1];
int g_iFireChance2[ST_MAXTYPES + 1];
int g_iFireHit[ST_MAXTYPES + 1];
int g_iFireHit2[ST_MAXTYPES + 1];
int g_iFireRock[ST_MAXTYPES + 1];
int g_iFireRock2[ST_MAXTYPES + 1];

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
	if (!LibraryExists("super_tanks++"))
	{
		SetFailState("No Super Tanks++ library found.");
	}
}

public void OnMapStart()
{
	PrecacheModel(MODEL_GASCAN, true);
	if (g_bLateLoad)
	{
		vLateLoad(true);
		g_bLateLoad = false;
	}
}

public void OnConfigsExecuted()
{
	char sMapName[128];
	GetCurrentMap(sMapName, sizeof(sMapName));
	if (IsMapValid(sMapName))
	{
		vIsPluginAllowed();
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

void vIsPluginAllowed()
{
	ST_PluginEnabled() ? vHookEvent(true) : vHookEvent(false);
}

void vHookEvent(bool hook)
{
	static bool hooked;
	if (hook && !hooked)
	{
		HookEvent("player_death", eEventPlayerDeath);
		hooked = true;
	}
	else if (!hook && hooked)
	{
		UnhookEvent("player_death", eEventPlayerDeath);
		hooked = false;
	}
}

void vLateLoad(bool late)
{
	if (late)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				SDKHook(iPlayer, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (bIsTank(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iFireHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iFireHit[ST_TankType(attacker)] : g_iFireHit2[ST_TankType(attacker)];
				vFireHit(victim, attacker, iFireHit);
			}
		}
		else if (bIsSurvivor(attacker) && bIsTank(victim))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				int iFireHit = !g_bTankConfig[ST_TankType(victim)] ? g_iFireHit[ST_TankType(victim)] : g_iFireHit2[ST_TankType(victim)];
				vFireHit(attacker, victim, iFireHit);
			}
		}
	}
}

public Action eEventPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int iUserId = event.GetInt("userid");
	int iPlayer = GetClientOfUserId(iUserId);
	if (bIsTank(iPlayer) && bIsL4D2Game())
	{
		float flPos[3];
		GetClientAbsOrigin(iPlayer, flPos);
		vFire(iPlayer, flPos);
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
			main ? (g_iFireRock[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Rock Break", 0)) : (g_iFireRock2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Rock Break", g_iFireRock[iIndex]));
			main ? (g_iFireRock[iIndex] = iSetCellLimit(g_iFireRock[iIndex], 0, 1)) : (g_iFireRock2[iIndex] = iSetCellLimit(g_iFireRock2[iIndex], 0, 1));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (bIsTank(client))
	{
		int iFireAbility = !g_bTankConfig[ST_TankType(client)] ? g_iFireAbility[ST_TankType(client)] : g_iFireAbility2[ST_TankType(client)];
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
					vFireHit(iSurvivor, client, iFireAbility);
				}
			}
		}
	}
}

public void ST_RockBreak(int client, int entity)
{
	int iFireRock = !g_bTankConfig[ST_TankType(client)] ? g_iFireRock[ST_TankType(client)] : g_iFireRock2[ST_TankType(client)];
	if (iFireRock == 1 && bIsTank(client))
	{
		float flPos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPos);
		vFire(client, flPos);
	}
}

void vFire(int client, float pos[3])
{
	int iFire = CreateEntityByName("prop_physics");
	if (IsValidEntity(iFire))
	{
		DispatchKeyValue(iFire, "disableshadows", "1");
		SetEntityModel(iFire, MODEL_GASCAN);
		pos[2] += 10.0;
		TeleportEntity(iFire, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iFire);
		SetEntPropEnt(iFire, Prop_Data, "m_hPhysicsAttacker", client);
		SetEntPropFloat(iFire, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());
		SetEntProp(iFire, Prop_Send, "m_CollisionGroup", 1);
		SetEntityRenderMode(iFire, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iFire, 0, 0, 0, 0);
		AcceptEntityInput(iFire, "Break");
	}
}

void vFireHit(int client, int owner, int enabled)
{
	int iFireChance = !g_bTankConfig[ST_TankType(owner)] ? g_iFireChance[ST_TankType(owner)] : g_iFireChance2[ST_TankType(owner)];
	if (enabled == 1 && GetRandomInt(1, iFireChance) == 1 && bIsSurvivor(client))
	{
		float flPos[3];
		GetClientAbsOrigin(client, flPos);
		vFire(owner, flPos);
	}
}