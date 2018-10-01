// Super Tanks++: Smash Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

#define PARTICLE_BLOOD "boomer_explode_D"
#define SOUND_GROWL "player/tank/voice/growl/tank_climb_01.wav"
#define SOUND_SMASH "player/charger/hit/charger_smash_02.wav"

public Plugin myinfo =
{
	name = "[ST++] Smash Ability",
	author = ST_AUTHOR,
	description = "The Super Tank smashes survivors to death.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
char g_sSmashEffect[ST_MAXTYPES + 1][4], g_sSmashEffect2[ST_MAXTYPES + 1][4];
float g_flSmashRange[ST_MAXTYPES + 1], g_flSmashRange2[ST_MAXTYPES + 1];
int g_iSmashAbility[ST_MAXTYPES + 1], g_iSmashAbility2[ST_MAXTYPES + 1], g_iSmashChance[ST_MAXTYPES + 1], g_iSmashChance2[ST_MAXTYPES + 1], g_iSmashHit[ST_MAXTYPES + 1], g_iSmashHit2[ST_MAXTYPES + 1], g_iSmashHitMode[ST_MAXTYPES + 1], g_iSmashHitMode2[ST_MAXTYPES + 1], g_iSmashMessage[ST_MAXTYPES + 1], g_iSmashMessage2[ST_MAXTYPES + 1], g_iSmashRangeChance[ST_MAXTYPES + 1], g_iSmashRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Smash Ability only supports Left 4 Dead 1 & 2.");
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
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
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
	vPrecacheParticle(PARTICLE_BLOOD);
	PrecacheSound(SOUND_GROWL, true);
	PrecacheSound(SOUND_SMASH, true);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((iSmashHitMode(attacker) == 0 || iSmashHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vSmashHit(victim, attacker, iSmashChance(attacker), iSmashHit(attacker), 1, "1");
			}
		}
		else if ((iSmashHitMode(victim) == 0 || iSmashHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vSmashHit(attacker, victim, iSmashChance(victim), iSmashHit(victim), 1, "2");
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
			main ? (g_iSmashAbility[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Enabled", 0)) : (g_iSmashAbility2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Enabled", g_iSmashAbility[iIndex]));
			main ? (g_iSmashAbility[iIndex] = iClamp(g_iSmashAbility[iIndex], 0, 1)) : (g_iSmashAbility2[iIndex] = iClamp(g_iSmashAbility2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("Smash Ability/Ability Effect", g_sSmashEffect[iIndex], sizeof(g_sSmashEffect[]), "123")) : (kvSuperTanks.GetString("Smash Ability/Ability Effect", g_sSmashEffect2[iIndex], sizeof(g_sSmashEffect2[]), g_sSmashEffect[iIndex]));
			main ? (g_iSmashMessage[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Message", 0)) : (g_iSmashMessage2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Ability Message", g_iSmashMessage[iIndex]));
			main ? (g_iSmashMessage[iIndex] = iClamp(g_iSmashMessage[iIndex], 0, 3)) : (g_iSmashMessage2[iIndex] = iClamp(g_iSmashMessage2[iIndex], 0, 3));
			main ? (g_iSmashChance[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Chance", 4)) : (g_iSmashChance2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Chance", g_iSmashChance[iIndex]));
			main ? (g_iSmashChance[iIndex] = iClamp(g_iSmashChance[iIndex], 1, 9999999999)) : (g_iSmashChance2[iIndex] = iClamp(g_iSmashChance2[iIndex], 1, 9999999999));
			main ? (g_iSmashHit[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit", 0)) : (g_iSmashHit2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit", g_iSmashHit[iIndex]));
			main ? (g_iSmashHit[iIndex] = iClamp(g_iSmashHit[iIndex], 0, 1)) : (g_iSmashHit2[iIndex] = iClamp(g_iSmashHit2[iIndex], 0, 1));
			main ? (g_iSmashHitMode[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit Mode", 0)) : (g_iSmashHitMode2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Hit Mode", g_iSmashHitMode[iIndex]));
			main ? (g_iSmashHitMode[iIndex] = iClamp(g_iSmashHitMode[iIndex], 0, 2)) : (g_iSmashHitMode2[iIndex] = iClamp(g_iSmashHitMode2[iIndex], 0, 2));
			main ? (g_flSmashRange[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range", 150.0)) : (g_flSmashRange2[iIndex] = kvSuperTanks.GetFloat("Smash Ability/Smash Range", g_flSmashRange[iIndex]));
			main ? (g_flSmashRange[iIndex] = flClamp(g_flSmashRange[iIndex], 1.0, 9999999999.0)) : (g_flSmashRange2[iIndex] = flClamp(g_flSmashRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iSmashRangeChance[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Range Chance", 16)) : (g_iSmashRangeChance2[iIndex] = kvSuperTanks.GetNum("Smash Ability/Smash Range Chance", g_iSmashRangeChance[iIndex]));
			main ? (g_iSmashRangeChance[iIndex] = iClamp(g_iSmashRangeChance[iIndex], 1, 9999999999)) : (g_iSmashRangeChance2[iIndex] = iClamp(g_iSmashRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iTankId = event.GetInt("attacker"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && bIsSurvivor(iSurvivor))
		{
			int iCorpse = -1;
			while ((iCorpse = FindEntityByClassname(iCorpse, "survivor_death_model")) != INVALID_ENT_REFERENCE)
			{
				int iOwner = GetEntPropEnt(iCorpse, Prop_Send, "m_hOwnerEntity");
				if (iSurvivor == iOwner)
				{
					RemoveEntity(iCorpse);
				}
			}
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iSmashRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iSmashChance[ST_TankType(client)] : g_iSmashChance2[ST_TankType(client)];
		float flSmashRange = !g_bTankConfig[ST_TankType(client)] ? g_flSmashRange[ST_TankType(client)] : g_flSmashRange2[ST_TankType(client)],
			flTankPos[3];
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
					vSmashHit(iSurvivor, client, iSmashRangeChance, iSmashAbility(client), 2, "3");
				}
			}
		}
	}
}

stock void vSmashHit(int client, int owner, int chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		int iSmashMessage = !g_bTankConfig[ST_TankType(owner)] ? g_iSmashMessage[ST_TankType(owner)] : g_iSmashMessage2[ST_TankType(owner)];
		EmitSoundToAll(SOUND_SMASH, client);
		EmitSoundToAll(SOUND_GROWL, owner);
		vAttachParticle(client, PARTICLE_BLOOD, 0.1, 0.0);
		ForcePlayerSuicide(client);
		char sSmashEffect[4];
		sSmashEffect = !g_bTankConfig[ST_TankType(owner)] ? g_sSmashEffect[ST_TankType(owner)] : g_sSmashEffect2[ST_TankType(owner)];
		vEffect(client, owner, sSmashEffect, mode);
		if (iSmashMessage == message || iSmashMessage == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Smash", sTankName, client);
		}
	}
}

stock int iSmashAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iSmashAbility[ST_TankType(client)] : g_iSmashAbility2[ST_TankType(client)];
}

stock int iSmashChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iSmashChance[ST_TankType(client)] : g_iSmashChance2[ST_TankType(client)];
}

stock int iSmashHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iSmashHit[ST_TankType(client)] : g_iSmashHit2[ST_TankType(client)];
}

stock int iSmashHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iSmashHitMode[ST_TankType(client)] : g_iSmashHitMode2[ST_TankType(client)];
}