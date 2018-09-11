// Super Tanks++: Kamikaze Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Kamikaze Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flKamikazeRange[ST_MAXTYPES + 1], g_flKamikazeRange2[ST_MAXTYPES + 1];
int g_iKamikazeAbility[ST_MAXTYPES + 1], g_iKamikazeAbility2[ST_MAXTYPES + 1], g_iKamikazeChance[ST_MAXTYPES + 1], g_iKamikazeChance2[ST_MAXTYPES + 1], g_iKamikazeHit[ST_MAXTYPES + 1], g_iKamikazeHit2[ST_MAXTYPES + 1], g_iKamikazeHitMode[ST_MAXTYPES + 1], g_iKamikazeHitMode2[ST_MAXTYPES + 1], g_iKamikazeRangeChance[ST_MAXTYPES + 1], g_iKamikazeRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Kamikaze Ability only supports Left 4 Dead 1 & 2.");
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
	vPrecacheParticle(PARTICLE_BLOOD);
	PrecacheSound(SOUND_GROWL, true);
	PrecacheSound(SOUND_SMASH, true);
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
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((iKamikazeHitMode(attacker) == 0 || iKamikazeHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vKamikazeHit(victim, attacker, iKamikazeChance(attacker), iKamikazeHit(attacker));
			}
		}
		else if ((iKamikazeHitMode(victim) == 0 || iKamikazeHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vKamikazeHit(attacker, victim, iKamikazeChance(victim), iKamikazeHit(victim));
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
			main ? (g_iKamikazeAbility[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Ability Enabled", 0)) : (g_iKamikazeAbility2[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Ability Enabled", g_iKamikazeAbility[iIndex]));
			main ? (g_iKamikazeAbility[iIndex] = iSetCellLimit(g_iKamikazeAbility[iIndex], 0, 1)) : (g_iKamikazeAbility2[iIndex] = iSetCellLimit(g_iKamikazeAbility2[iIndex], 0, 1));
			main ? (g_iKamikazeChance[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Chance", 4)) : (g_iKamikazeChance2[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Chance", g_iKamikazeChance[iIndex]));
			main ? (g_iKamikazeChance[iIndex] = iSetCellLimit(g_iKamikazeChance[iIndex], 1, 9999999999)) : (g_iKamikazeChance2[iIndex] = iSetCellLimit(g_iKamikazeChance2[iIndex], 1, 9999999999));
			main ? (g_iKamikazeHit[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Hit", 0)) : (g_iKamikazeHit2[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Hit", g_iKamikazeHit[iIndex]));
			main ? (g_iKamikazeHit[iIndex] = iSetCellLimit(g_iKamikazeHit[iIndex], 0, 1)) : (g_iKamikazeHit2[iIndex] = iSetCellLimit(g_iKamikazeHit2[iIndex], 0, 1));
			main ? (g_iKamikazeHitMode[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Hit Mode", 0)) : (g_iKamikazeHitMode2[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Hit Mode", g_iKamikazeHitMode[iIndex]));
			main ? (g_iKamikazeHitMode[iIndex] = iSetCellLimit(g_iKamikazeHitMode[iIndex], 0, 2)) : (g_iKamikazeHitMode2[iIndex] = iSetCellLimit(g_iKamikazeHitMode2[iIndex], 0, 2));
			main ? (g_flKamikazeRange[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Kamikaze Range", 150.0)) : (g_flKamikazeRange2[iIndex] = kvSuperTanks.GetFloat("Kamikaze Ability/Kamikaze Range", g_flKamikazeRange[iIndex]));
			main ? (g_flKamikazeRange[iIndex] = flSetFloatLimit(g_flKamikazeRange[iIndex], 1.0, 9999999999.0)) : (g_flKamikazeRange2[iIndex] = flSetFloatLimit(g_flKamikazeRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iKamikazeRangeChance[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Range Chance", 16)) : (g_iKamikazeRangeChance2[iIndex] = kvSuperTanks.GetNum("Kamikaze Ability/Kamikaze Range Chance", g_iKamikazeRangeChance[iIndex]));
			main ? (g_iKamikazeRangeChance[iIndex] = iSetCellLimit(g_iKamikazeRangeChance[iIndex], 1, 9999999999)) : (g_iKamikazeRangeChance2[iIndex] = iSetCellLimit(g_iKamikazeRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iTankId = event.GetInt("attacker"), iTank = GetClientOfUserId(iTankId);
		if (iKamikazeAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && bIsSurvivor(iSurvivor))
		{
			int iCorpse = -1;
			while ((iCorpse = FindEntityByClassname(iCorpse, "survivor_death_model")) != INVALID_ENT_REFERENCE)
			{
				int iOwner = GetEntPropEnt(iCorpse, Prop_Send, "m_hOwnerEntity");
				if (iSurvivor == iOwner)
				{
					AcceptEntityInput(iCorpse, "Kill");
				}
			}
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iKamikazeRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iKamikazeChance[ST_TankType(client)] : g_iKamikazeChance2[ST_TankType(client)];
		float flKamikazeRange = !g_bTankConfig[ST_TankType(client)] ? g_flKamikazeRange[ST_TankType(client)] : g_flKamikazeRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flKamikazeRange)
				{
					vKamikazeHit(iSurvivor, client, iKamikazeRangeChance, iKamikazeAbility(client));
				}
			}
		}
	}
}

stock void vKamikazeHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		EmitSoundToAll(SOUND_SMASH, client);
		vAttachParticle(client, PARTICLE_BLOOD, 0.1, 0.0);
		ForcePlayerSuicide(client);
		vAttachParticle(owner, PARTICLE_BLOOD, 0.1, 0.0);
		ForcePlayerSuicide(owner);
	}
}

stock int iKamikazeAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iKamikazeAbility[ST_TankType(client)] : g_iKamikazeAbility2[ST_TankType(client)];
}

stock int iKamikazeChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iKamikazeChance[ST_TankType(client)] : g_iKamikazeChance2[ST_TankType(client)];
}

stock int iKamikazeHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iKamikazeHit[ST_TankType(client)] : g_iKamikazeHit2[ST_TankType(client)];
}

stock int iKamikazeHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iKamikazeHitMode[ST_TankType(client)] : g_iKamikazeHitMode2[ST_TankType(client)];
}