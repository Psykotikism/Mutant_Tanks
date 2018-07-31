// Super Tanks++: Bomb Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Bomb Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"

bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flBombRange[ST_MAXTYPES + 1];
float g_flBombRange2[ST_MAXTYPES + 1];
int g_iBombAbility[ST_MAXTYPES + 1];
int g_iBombAbility2[ST_MAXTYPES + 1];
int g_iBombChance[ST_MAXTYPES + 1];
int g_iBombChance2[ST_MAXTYPES + 1];
int g_iBombHit[ST_MAXTYPES + 1];
int g_iBombHit2[ST_MAXTYPES + 1];
int g_iBombRangeChance[ST_MAXTYPES + 1];
int g_iBombRangeChance2[ST_MAXTYPES + 1];
int g_iBombRock[ST_MAXTYPES + 1];
int g_iBombRock2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Bomb Ability only supports Left 4 Dead 1 & 2.");
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
	PrecacheModel(MODEL_PROPANETANK, true);
	if (g_bLateLoad)
	{
		vLateLoad(true);
		g_bLateLoad = false;
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
		if (ST_TankAllowed(attacker) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iBombChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iBombChance[ST_TankType(attacker)] : g_iBombChance2[ST_TankType(attacker)];
				int iBombHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iBombHit[ST_TankType(attacker)] : g_iBombHit2[ST_TankType(attacker)];
				vBombHit(victim, attacker, iBombChance, iBombHit);
			}
		}
		else if (ST_TankAllowed(victim) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				int iBombChance = !g_bTankConfig[ST_TankType(victim)] ? g_iBombChance[ST_TankType(victim)] : g_iBombChance2[ST_TankType(victim)];
				int iBombHit = !g_bTankConfig[ST_TankType(victim)] ? g_iBombHit[ST_TankType(victim)] : g_iBombHit2[ST_TankType(victim)];
				vBombHit(attacker, victim, iBombChance, iBombHit);
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
			main ? (g_iBombAbility[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Ability Enabled", 0)) : (g_iBombAbility2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Ability Enabled", g_iBombAbility[iIndex]));
			main ? (g_iBombAbility[iIndex] = iSetCellLimit(g_iBombAbility[iIndex], 0, 1)) : (g_iBombAbility2[iIndex] = iSetCellLimit(g_iBombAbility2[iIndex], 0, 1));
			main ? (g_iBombChance[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Chance", 4)) : (g_iBombChance2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Chance", g_iBombChance[iIndex]));
			main ? (g_iBombChance[iIndex] = iSetCellLimit(g_iBombChance[iIndex], 1, 9999999999)) : (g_iBombChance2[iIndex] = iSetCellLimit(g_iBombChance2[iIndex], 1, 9999999999));
			main ? (g_iBombHit[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Hit", 0)) : (g_iBombHit2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Hit", g_iBombHit[iIndex]));
			main ? (g_iBombHit[iIndex] = iSetCellLimit(g_iBombHit[iIndex], 0, 1)) : (g_iBombHit2[iIndex] = iSetCellLimit(g_iBombHit2[iIndex], 0, 1));
			main ? (g_flBombRange[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Range", 150.0)) : (g_flBombRange2[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Range", g_flBombRange[iIndex]));
			main ? (g_flBombRange[iIndex] = flSetFloatLimit(g_flBombRange[iIndex], 1.0, 9999999999.0)) : (g_flBombRange2[iIndex] = flSetFloatLimit(g_flBombRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iBombRangeChance[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Range Chance", 16)) : (g_iBombRangeChance2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Range Chance", g_iBombRangeChance[iIndex]));
			main ? (g_iBombRangeChance[iIndex] = iSetCellLimit(g_iBombRangeChance[iIndex], 1, 9999999999)) : (g_iBombRangeChance2[iIndex] = iSetCellLimit(g_iBombRangeChance2[iIndex], 1, 9999999999));
			main ? (g_iBombRock[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Rock Break", 0)) : (g_iBombRock2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Rock Break", g_iBombRock[iIndex]));
			main ? (g_iBombRock[iIndex] = iSetCellLimit(g_iBombRock[iIndex], 0, 1)) : (g_iBombRock2[iIndex] = iSetCellLimit(g_iBombRock2[iIndex], 0, 1));
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
		int iBombAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iBombAbility[ST_TankType(iTank)] : g_iBombAbility2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iBombAbility == 1 && bIsL4D2Game())
		{
			float flPos[3];
			GetClientAbsOrigin(iTank, flPos);
			vBomb(iTank, flPos);
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iBombAbility = !g_bTankConfig[ST_TankType(client)] ? g_iBombAbility[ST_TankType(client)] : g_iBombAbility2[ST_TankType(client)];
		int iBombRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iBombChance[ST_TankType(client)] : g_iBombChance2[ST_TankType(client)];
		float flBombRange = !g_bTankConfig[ST_TankType(client)] ? g_flBombRange[ST_TankType(client)] : g_flBombRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flBombRange)
				{
					vBombHit(iSurvivor, client, iBombRangeChance, iBombAbility);
				}
			}
		}
	}
}

public void ST_RockBreak(int client, int entity)
{
	int iBombRock = !g_bTankConfig[ST_TankType(client)] ? g_iBombRock[ST_TankType(client)] : g_iBombRock2[ST_TankType(client)];
	if (iBombRock == 1 && ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		float flPos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPos);
		vBomb(client, flPos);
	}
}

void vBomb(int client, float pos[3])
{
	int iBomb = CreateEntityByName("prop_physics");
	if (bIsValidEntity(iBomb))
	{
		DispatchKeyValue(iBomb, "disableshadows", "1");
		SetEntityModel(iBomb, MODEL_PROPANETANK);
		pos[2] += 10.0;
		TeleportEntity(iBomb, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iBomb);
		SetEntPropEnt(iBomb, Prop_Data, "m_hPhysicsAttacker", client);
		SetEntPropFloat(iBomb, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());
		SetEntProp(iBomb, Prop_Send, "m_CollisionGroup", 1);
		SetEntityRenderMode(iBomb, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iBomb, 0, 0, 0, 0);
		AcceptEntityInput(iBomb, "Break");
	}
}

void vBombHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		float flPos[3];
		GetClientAbsOrigin(client, flPos);
		vBomb(owner, flPos);
	}
}