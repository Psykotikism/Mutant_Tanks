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

#define SOUND_DEBRIS "animation/van_inside_debris.wav"
#define SOUND_EXPLOSION2 "ambient/explosions/explode_1.wav"
#define SOUND_EXPLOSION3 "ambient/explosions/explode_2.wav"
#define SOUND_EXPLOSION4 "ambient/explosions/explode_3.wav"

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
int g_iBombPower[ST_MAXTYPES + 1];
int g_iBombPower2[ST_MAXTYPES + 1];
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
	PrecacheSound(SOUND_DEBRIS, true);
	PrecacheSound(SOUND_EXPLOSION2, true);
	PrecacheSound(SOUND_EXPLOSION3, true);
	PrecacheSound(SOUND_EXPLOSION4, true);
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
				int iBombHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iBombHit[ST_TankType(attacker)] : g_iBombHit2[ST_TankType(attacker)];
				vBombHit(victim, attacker, iBombHit);
			}
		}
		else if (bIsSurvivor(attacker) && bIsTank(victim))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				int iBombHit = !g_bTankConfig[ST_TankType(victim)] ? g_iBombHit[ST_TankType(victim)] : g_iBombHit2[ST_TankType(victim)];
				vBombHit(attacker, victim, iBombHit);
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
		float flPosition[3];
		GetClientAbsOrigin(iPlayer, flPosition);
		vBomb(iPlayer, flPosition);
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
			main ? (g_iBombPower[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Power", 75)) : (g_iBombPower2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Power", g_iBombPower[iIndex]));
			main ? (g_iBombPower[iIndex] = iSetCellLimit(g_iBombPower[iIndex], 1, 9999999999)) : (g_iBombPower2[iIndex] = iSetCellLimit(g_iBombPower2[iIndex], 1, 9999999999));
			main ? (g_flBombRange[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Range", 150.0)) : (g_flBombRange2[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Range", g_flBombRange[iIndex]));
			main ? (g_flBombRange[iIndex] = flSetFloatLimit(g_flBombRange[iIndex], 1.0, 9999999999.0)) : (g_flBombRange2[iIndex] = flSetFloatLimit(g_flBombRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iBombRock[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Rock Break", 0)) : (g_iBombRock2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Rock Break", g_iBombRock[iIndex]));
			main ? (g_iBombRock[iIndex] = iSetCellLimit(g_iBombRock[iIndex], 0, 1)) : (g_iBombRock2[iIndex] = iSetCellLimit(g_iBombRock2[iIndex], 0, 1));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (bIsTank(client))
	{
		int iBombAbility = !g_bTankConfig[ST_TankType(client)] ? g_iBombAbility[ST_TankType(client)] : g_iBombAbility2[ST_TankType(client)];
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
					vBombHit(iSurvivor, client, iBombAbility);
				}
			}
		}
	}
}

public void ST_RockBreak(int client, int entity)
{
	int iBombRock = !g_bTankConfig[ST_TankType(client)] ? g_iBombRock[ST_TankType(client)] : g_iBombRock2[ST_TankType(client)];
	if (iBombRock == 1 && bIsTank(client))
	{
		float flPosition[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPosition);
		vBomb(client, flPosition);
	}
}

void vBomb(int client, float pos[3])
{
	int iBombPower = !g_bTankConfig[ST_TankType(client)] ? g_iBombPower[ST_TankType(client)] : g_iBombPower2[ST_TankType(client)];
	char sDamage[6];
	IntToString(iBombPower, sDamage, sizeof(sDamage));
	int iParticle = CreateEntityByName("info_particle_system");
	int iParticle2 = CreateEntityByName("info_particle_system");
	int iParticle3 = CreateEntityByName("info_particle_system");
	int iTrace = CreateEntityByName("info_particle_system");
	int iPhysics = CreateEntityByName("env_physexplosion");
	int iHurt = CreateEntityByName("point_hurt");
	int iExplosion = CreateEntityByName("env_explosion");
	DispatchKeyValue(iParticle, "effect_name", "FluidExplosion_fps");
	TeleportEntity(iParticle, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iParticle);
	ActivateEntity(iParticle);
	DispatchKeyValue(iParticle2, "effect_name", "weapon_grenade_explosion");
	TeleportEntity(iParticle2, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iParticle2);
	ActivateEntity(iParticle2);
	DispatchKeyValue(iParticle3, "effect_name", "explosion_huge_b");
	TeleportEntity(iParticle3, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iParticle3);
	ActivateEntity(iParticle3);
	DispatchKeyValue(iTrace, "effect_name", "gas_explosion_ground_fire");
	TeleportEntity(iTrace, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iTrace);
	ActivateEntity(iTrace);
	SetEntPropEnt(iExplosion, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValue(iExplosion, "fireballsprite", "sprites/muzzleflash4.vmt");
	DispatchKeyValue(iExplosion, "iMagnitude", sDamage);
	DispatchKeyValue(iExplosion, "iRadiusOverride", sDamage);
	DispatchKeyValue(iExplosion, "spawnflags", "828");
	TeleportEntity(iExplosion, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iExplosion);
	SetEntPropEnt(iPhysics, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValue(iPhysics, "radius", sDamage);
	DispatchKeyValue(iPhysics, "magnitude", sDamage);
	TeleportEntity(iPhysics, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iPhysics);
	SetEntPropEnt(iHurt, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValue(iHurt, "DamageRadius", sDamage);
	DispatchKeyValue(iHurt, "DamageDelay", "0.5");
	DispatchKeyValue(iHurt, "Damage", "5");
	DispatchKeyValue(iHurt, "DamageType", "8");
	TeleportEntity(iHurt, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iHurt);
	switch (GetRandomInt(1, 3))
	{
		case 1: EmitSoundToAll(SOUND_EXPLOSION2, client);
		case 2: EmitSoundToAll(SOUND_EXPLOSION3, client);
		case 3: EmitSoundToAll(SOUND_EXPLOSION4, client);
	}
	EmitSoundToAll(SOUND_DEBRIS, client);
	AcceptEntityInput(iParticle, "Start");
	AcceptEntityInput(iParticle2, "Start");
	AcceptEntityInput(iParticle3, "Start");
	AcceptEntityInput(iTrace, "Start");
	AcceptEntityInput(iExplosion, "Explode");
	AcceptEntityInput(iPhysics, "Explode");
	AcceptEntityInput(iHurt, "TurnOn");
	iParticle = EntIndexToEntRef(iParticle);
	vDeleteEntity(iParticle, 16.5);
	iParticle2 = EntIndexToEntRef(iParticle2);
	vDeleteEntity(iParticle2, 16.5);
	iParticle3 = EntIndexToEntRef(iParticle3);
	vDeleteEntity(iParticle3, 16.5);
	iTrace = EntIndexToEntRef(iTrace);
	vDeleteEntity(iTrace, 16.5);
	vDeleteParticle(iTrace, 16.5, "Stop");
	iExplosion = EntIndexToEntRef(iExplosion);
	vDeleteEntity(iExplosion, 16.5);
	iPhysics = EntIndexToEntRef(iPhysics);
	vDeleteEntity(iPhysics, 16.5);
	iHurt = EntIndexToEntRef(iHurt);
	vDeleteEntity(iHurt, 16.5);
	vDeleteParticle(iHurt, 15.0, "TurnOff");
}

void vBombHit(int client, int owner, int enabled)
{
	int iBombChance = !g_bTankConfig[ST_TankType(owner)] ? g_iBombChance[ST_TankType(owner)] : g_iBombChance2[ST_TankType(owner)];
	if (enabled == 1 && GetRandomInt(1, iBombChance) == 1 && bIsSurvivor(client))
	{
		float flPosition[3];
		GetClientAbsOrigin(client, flPosition);
		vBomb(owner, flPosition);
	}
}