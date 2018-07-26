// Super Tanks++: Smash Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Smash Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

#define PARTICLE_BLOOD "boomer_explode_D"
#define SOUND_GROWL "player/tank/voice/growl/tank_climb_01.wav"
#define SOUND_SMASH "player/charger/hit/charger_smash_02.wav"

bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flSmashRange[ST_MAXTYPES + 1];
float g_flSmashRange2[ST_MAXTYPES + 1];
int g_iSmashAbility[ST_MAXTYPES + 1];
int g_iSmashAbility2[ST_MAXTYPES + 1];
int g_iSmashChance[ST_MAXTYPES + 1];
int g_iSmashChance2[ST_MAXTYPES + 1];
int g_iSmashDamage[ST_MAXTYPES + 1];
int g_iSmashDamage2[ST_MAXTYPES + 1];
int g_iSmashHit[ST_MAXTYPES + 1];
int g_iSmashHit2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Smash Ability only supports Left 4 Dead 1 & 2.");
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
	vPrecacheParticle(PARTICLE_BLOOD);
	PrecacheSound(SOUND_GROWL, true);
	PrecacheSound(SOUND_SMASH, true);
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
		if (bIsTank(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vSmashHit2(victim, attacker);
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
			main ? (g_iSmashAbility[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Enabled", 0)) : (g_iSmashAbility2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Enabled", g_iSmashAbility[iIndex]));
			main ? (g_iSmashAbility[iIndex] = iSetCellLimit(g_iSmashAbility[iIndex], 0, 1)) : (g_iSmashAbility2[iIndex] = iSetCellLimit(g_iSmashAbility2[iIndex], 0, 1));
			main ? (g_iSmashChance[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Chance", 4)) : (g_iSmashChance2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Chance", g_iSmashChance[iIndex]));
			main ? (g_iSmashChance[iIndex] = iSetCellLimit(g_iSmashChance[iIndex], 1, 9999999999)) : (g_iSmashChance2[iIndex] = iSetCellLimit(g_iSmashChance2[iIndex], 1, 9999999999));
			main ? (g_iSmashDamage[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Damage", 5)) : (g_iSmashDamage2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Damage", g_iSmashDamage[iIndex]));
			main ? (g_iSmashDamage[iIndex] = iSetCellLimit(g_iSmashDamage[iIndex], 1, 9999999999)) : (g_iSmashDamage2[iIndex] = iSetCellLimit(g_iSmashDamage2[iIndex], 1, 9999999999));
			main ? (g_iSmashHit[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit", 0)) : (g_iSmashHit2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit", g_iSmashHit[iIndex]));
			main ? (g_iSmashHit[iIndex] = iSetCellLimit(g_iSmashHit[iIndex], 0, 1)) : (g_iSmashHit2[iIndex] = iSetCellLimit(g_iSmashHit2[iIndex], 0, 1));
			main ? (g_flSmashRange[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range", 150.0)) : (g_flSmashRange2[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range", g_flSmashRange[iIndex]));
			main ? (g_flSmashRange[iIndex] = flSetFloatLimit(g_flSmashRange[iIndex], 1.0, 9999999999.0)) : (g_flSmashRange2[iIndex] = flSetFloatLimit(g_flSmashRange2[iIndex], 1.0, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Death(int client)
{
	if (bIsSurvivor(client))
	{
		int iCorpse = -1;
		while ((iCorpse = FindEntityByClassname(iCorpse, "survivor_death_model")) != INVALID_ENT_REFERENCE)
		{
			int iOwner = GetEntPropEnt(iCorpse, Prop_Send, "m_hOwnerEntity");
			if (client == iOwner)
			{
				AcceptEntityInput(iCorpse, "Kill");
			}
		}
	}
}

public void ST_Ability(int client)
{
	if (bIsTank(client))
	{
		float flSmashRange = !g_bTankConfig[ST_TankType(client)] ? g_flSmashRange[ST_TankType(client)] : g_flSmashRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flSmashRange)
				{
					vSmashHit(iSurvivor, client);
				}
			}
		}
	}
}

void vSmashHit(int client, int owner)
{
	int iSmashAbility = !g_bTankConfig[ST_TankType(owner)] ? g_iSmashAbility[ST_TankType(owner)] : g_iSmashAbility2[ST_TankType(owner)];
	int iSmashChance = !g_bTankConfig[ST_TankType(owner)] ? g_iSmashChance[ST_TankType(owner)] : g_iSmashChance2[ST_TankType(owner)];
	if (iSmashAbility == 1 && GetRandomInt(1, iSmashChance) == 1 && bIsSurvivor(client))
	{
		EmitSoundToAll(SOUND_GROWL, owner);
		char sDamage[6];
		int iSmashDamage = !g_bTankConfig[ST_TankType(owner)] ? g_iSmashDamage[ST_TankType(owner)] : g_iSmashDamage2[ST_TankType(owner)];
		IntToString(iSmashDamage, sDamage, sizeof(sDamage));
		int iPointHurt = CreateEntityByName("point_hurt");
		if (bIsValidEntity(iPointHurt))
		{
			DispatchKeyValue(client, "targetname", "hurtme");
			DispatchKeyValue(iPointHurt, "Damage", sDamage);
			DispatchKeyValue(iPointHurt, "DamageTarget", "hurtme");
			DispatchKeyValue(iPointHurt, "DamageType", "2");
			DispatchSpawn(iPointHurt);
			AcceptEntityInput(iPointHurt, "Hurt", client);
			AcceptEntityInput(iPointHurt, "Kill");
			DispatchKeyValue(client, "targetname", "donthurtme");
		}
	}
}

void vSmashHit2(int client, int owner)
{
	int iSmashChance = !g_bTankConfig[ST_TankType(owner)] ? g_iSmashChance[ST_TankType(owner)] : g_iSmashChance2[ST_TankType(owner)];
	int iSmashHit = !g_bTankConfig[ST_TankType(owner)] ? g_iSmashHit[ST_TankType(owner)] : g_iSmashHit2[ST_TankType(owner)];
	if (iSmashHit == 1 && GetRandomInt(1, iSmashChance) == 1 && bIsSurvivor(client))
	{
		EmitSoundToAll(SOUND_SMASH, client);
		vAttachParticle(client, PARTICLE_BLOOD, 0.1, 0.0);
		ForcePlayerSuicide(client);
	}
}

void vAttachParticle(int client, char[] particlename, float time = 0.0, float origin = 0.0)
{
	if (bIsValidClient(client))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (IsValidEntity(iParticle))
		{
			float flPos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPos);
			flPos[2] += origin;
			DispatchKeyValue(iParticle, "scale", "");
			DispatchKeyValue(iParticle, "effect_name", particlename);
			TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iParticle);
			ActivateEntity(iParticle);
			AcceptEntityInput(iParticle, "Enable");
			AcceptEntityInput(iParticle, "Start");
			vSetEntityParent(iParticle, client);
			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, time);
		}
	}
}

void vDeleteEntity(int entity, float time = 0.1)
{
	if (bIsValidEntRef(entity))
	{
		char sVariant[64];
		Format(sVariant, sizeof(sVariant), "OnUser1 !self:kill::%f:1", time);
		AcceptEntityInput(entity, "ClearParent");
		SetVariantString(sVariant);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");
	}
}

void vPrecacheParticle(char[] particlename)
{
	int iParticle = CreateEntityByName("info_particle_system");
	if (IsValidEntity(iParticle))
	{
		DispatchKeyValue(iParticle, "effect_name", particlename);
		DispatchSpawn(iParticle);
		ActivateEntity(iParticle);
		AcceptEntityInput(iParticle, "Start");
		vSetEntityParent(iParticle, iParticle);
		iParticle = EntIndexToEntRef(iParticle);
		vDeleteEntity(iParticle);
	}
}

void vSetEntityParent(int entity, int parent)
{
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", parent);
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

bool bIsValidEntity(int entity)
{
	return entity > 0 && entity <= 2048 && IsValidEntity(entity);
}

bool bIsValidEntRef(int entity)
{
	return entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE;
}