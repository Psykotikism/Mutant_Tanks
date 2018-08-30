// Super Tanks++: Absorb Ability
#define REQUIRE_PLUGIN
#include <super_tanks++>
#undef REQUIRE_PLUGIN
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Absorb Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bAbsorb[MAXPLAYERS + 1], g_bLateLoad, g_bPluginEnabled, g_bTankConfig[ST_MAXTYPES + 1];
float g_flAbsorbBulletDamage[ST_MAXTYPES + 1], g_flAbsorbBulletDamage2[ST_MAXTYPES + 1],
	g_flAbsorbDuration[ST_MAXTYPES + 1], g_flAbsorbDuration2[ST_MAXTYPES + 1],
	g_flAbsorbExplosiveDamage[ST_MAXTYPES + 1], g_flAbsorbExplosiveDamage2[ST_MAXTYPES + 1],
	g_flAbsorbFireDamage[ST_MAXTYPES + 1], g_flAbsorbFireDamage2[ST_MAXTYPES + 1],
	g_flAbsorbMeleeDamage[ST_MAXTYPES + 1], g_flAbsorbMeleeDamage2[ST_MAXTYPES + 1];
int g_iAbsorbAbility[ST_MAXTYPES + 1], g_iAbsorbAbility2[ST_MAXTYPES + 1],
	g_iAbsorbChance[ST_MAXTYPES + 1], g_iAbsorbChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Absorb Ability only supports Left 4 Dead 1 & 2.");
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
	g_bAbsorb[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_bPluginEnabled && ST_PluginEnabled() && damage > 0.0)
	{
		if (ST_TankAllowed(victim) && IsPlayerAlive(victim) && g_bAbsorb[victim])
		{
			float flAbsorbBulletDamage = !g_bTankConfig[ST_TankType(victim)] ? g_flAbsorbBulletDamage[ST_TankType(victim)] : g_flAbsorbBulletDamage2[ST_TankType(victim)];
			float flAbsorbExplosiveDamage = !g_bTankConfig[ST_TankType(victim)] ? g_flAbsorbExplosiveDamage[ST_TankType(victim)] : g_flAbsorbExplosiveDamage2[ST_TankType(victim)];
			float flAbsorbFireDamage = !g_bTankConfig[ST_TankType(victim)] ? g_flAbsorbFireDamage[ST_TankType(victim)] : g_flAbsorbFireDamage2[ST_TankType(victim)];
			float flAbsorbMeleeDamage = !g_bTankConfig[ST_TankType(victim)] ? g_flAbsorbMeleeDamage[ST_TankType(victim)] : g_flAbsorbMeleeDamage2[ST_TankType(victim)];
			switch (damagetype)
			{
				case DMG_BULLET: damage = damage / flAbsorbBulletDamage;
				case DMG_BLAST, DMG_BLAST_SURFACE, DMG_AIRBOAT, DMG_PLASMA: damage = damage / flAbsorbExplosiveDamage;
				case DMG_BURN: damage = damage / flAbsorbFireDamage;
				case DMG_SLASH, DMG_CLUB: damage = damage / flAbsorbMeleeDamage;
			}
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
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
			main ? (g_iAbsorbAbility[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Ability Enabled", 0)) : (g_iAbsorbAbility2[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Ability Enabled", g_iAbsorbAbility[iIndex]));
			main ? (g_iAbsorbAbility[iIndex] = iSetCellLimit(g_iAbsorbAbility[iIndex], 0, 1)) : (g_iAbsorbAbility2[iIndex] = iSetCellLimit(g_iAbsorbAbility2[iIndex], 0, 1));
			main ? (g_flAbsorbBulletDamage[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Bullet Damage", 20.0)) : (g_flAbsorbBulletDamage2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Bullet Damage", g_flAbsorbBulletDamage[iIndex]));
			main ? (g_flAbsorbBulletDamage[iIndex] = flSetFloatLimit(g_flAbsorbBulletDamage[iIndex], 0.1, 9999999999.0)) : (g_flAbsorbBulletDamage2[iIndex] = flSetFloatLimit(g_flAbsorbBulletDamage2[iIndex], 0.1, 9999999999.0));
			main ? (g_iAbsorbChance[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Absorb Chance", 4)) : (g_iAbsorbChance2[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Absorb Chance", g_iAbsorbChance[iIndex]));
			main ? (g_iAbsorbChance[iIndex] = iSetCellLimit(g_iAbsorbChance[iIndex], 1, 9999999999)) : (g_iAbsorbChance2[iIndex] = iSetCellLimit(g_iAbsorbChance2[iIndex], 1, 9999999999));
			main ? (g_flAbsorbDuration[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Duration", 5.0)) : (g_flAbsorbDuration2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Duration", g_flAbsorbDuration[iIndex]));
			main ? (g_flAbsorbDuration[iIndex] = flSetFloatLimit(g_flAbsorbDuration[iIndex], 0.1, 9999999999.0)) : (g_flAbsorbDuration2[iIndex] = flSetFloatLimit(g_flAbsorbDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_flAbsorbExplosiveDamage[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Explosive Damage", 20.0)) : (g_flAbsorbExplosiveDamage2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Explosive Damage", g_flAbsorbExplosiveDamage[iIndex]));
			main ? (g_flAbsorbExplosiveDamage[iIndex] = flSetFloatLimit(g_flAbsorbExplosiveDamage[iIndex], 0.1, 9999999999.0)) : (g_flAbsorbExplosiveDamage2[iIndex] = flSetFloatLimit(g_flAbsorbExplosiveDamage2[iIndex], 0.1, 9999999999.0));
			main ? (g_flAbsorbFireDamage[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Fire Damage", 200.0)) : (g_flAbsorbFireDamage2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Fire Damage", g_flAbsorbFireDamage[iIndex]));
			main ? (g_flAbsorbFireDamage[iIndex] = flSetFloatLimit(g_flAbsorbFireDamage[iIndex], 0.1, 9999999999.0)) : (g_flAbsorbFireDamage2[iIndex] = flSetFloatLimit(g_flAbsorbFireDamage2[iIndex], 0.1, 9999999999.0));
			main ? (g_flAbsorbMeleeDamage[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Melee Damage", 200.0)) : (g_flAbsorbMeleeDamage2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Melee Damage", g_flAbsorbMeleeDamage[iIndex]));
			main ? (g_flAbsorbMeleeDamage[iIndex] = flSetFloatLimit(g_flAbsorbMeleeDamage[iIndex], 0.1, 9999999999.0)) : (g_flAbsorbMeleeDamage2[iIndex] = flSetFloatLimit(g_flAbsorbMeleeDamage2[iIndex], 0.1, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_incapacitated") == 0)
	{
		int iTankId = event.GetInt("userid");
		int iTank = GetClientOfUserId(iTankId);
		int iAbsorbAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iAbsorbAbility[ST_TankType(iTank)] : g_iAbsorbAbility2[ST_TankType(iTank)];
		if (iAbsorbAbility == 1 && ST_TankAllowed(iTank))
		{
			if (g_bAbsorb[iTank])
			{
				tTimerStopAbsorb(null, GetClientUserId(iTank));
			}
		}
	}
}

public void ST_Ability(int client)
{
	int iAbsorbAbility = !g_bTankConfig[ST_TankType(client)] ? g_iAbsorbAbility[ST_TankType(client)] : g_iAbsorbAbility2[ST_TankType(client)];
	int iAbsorbChance = !g_bTankConfig[ST_TankType(client)] ? g_iAbsorbChance[ST_TankType(client)] : g_iAbsorbChance2[ST_TankType(client)];
	if (g_bPluginEnabled && iAbsorbAbility == 1 && GetRandomInt(1, iAbsorbChance) == 1 && ST_TankAllowed(client) && IsPlayerAlive(client) && !g_bAbsorb[client])
	{
		g_bAbsorb[client] = true;
		float flAbsorbDuration = !g_bTankConfig[ST_TankType(client)] ? g_flAbsorbDuration[ST_TankType(client)] : g_flAbsorbDuration2[ST_TankType(client)];
		CreateTimer(flAbsorbDuration, tTimerStopAbsorb, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bAbsorb[iPlayer] = false;
		}
	}
}

public Action tTimerStopAbsorb(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!g_bPluginEnabled || !ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		g_bAbsorb[iTank] = false;
		return Plugin_Stop;
	}
	int iAbsorbAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iAbsorbAbility[ST_TankType(iTank)] : g_iAbsorbAbility2[ST_TankType(iTank)];
	if (iAbsorbAbility == 0)
	{
		g_bAbsorb[iTank] = false;
		return Plugin_Stop;
	}
	g_bAbsorb[iTank] = false;
	return Plugin_Continue;
}