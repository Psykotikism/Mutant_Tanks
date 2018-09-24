// Super Tanks++: Absorb Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Absorb Ability",
	author = ST_AUTHOR,
	description = "The Super Tank absorbs most of the damage it receives.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bAbsorb[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flAbsorbBulletDamage[ST_MAXTYPES + 1], g_flAbsorbBulletDamage2[ST_MAXTYPES + 1], g_flAbsorbDuration[ST_MAXTYPES + 1], g_flAbsorbDuration2[ST_MAXTYPES + 1],g_flAbsorbExplosiveDamage[ST_MAXTYPES + 1], g_flAbsorbExplosiveDamage2[ST_MAXTYPES + 1], g_flAbsorbFireDamage[ST_MAXTYPES + 1], g_flAbsorbFireDamage2[ST_MAXTYPES + 1], g_flAbsorbMeleeDamage[ST_MAXTYPES + 1], g_flAbsorbMeleeDamage2[ST_MAXTYPES + 1];
int g_iAbsorbAbility[ST_MAXTYPES + 1], g_iAbsorbAbility2[ST_MAXTYPES + 1], g_iAbsorbChance[ST_MAXTYPES + 1], g_iAbsorbChance2[ST_MAXTYPES + 1], g_iAbsorbMessage[ST_MAXTYPES + 1], g_iAbsorbMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_Left4Dead && !bIsL4D2())
	{
		strcopy(error, err_max, "[ST++] Absorb Ability only supports Left 4 Dead 1 & 2.");
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
	vReset();
}

public void OnClientPutInServer(int client)
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
	if (ST_PluginEnabled() && damage > 0.0)
	{
		if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && g_bAbsorb[victim])
		{
			float flAbsorbBulletDamage = !g_bTankConfig[ST_TankType(victim)] ? g_flAbsorbBulletDamage[ST_TankType(victim)] : g_flAbsorbBulletDamage2[ST_TankType(victim)],
				flAbsorbExplosiveDamage = !g_bTankConfig[ST_TankType(victim)] ? g_flAbsorbExplosiveDamage[ST_TankType(victim)] : g_flAbsorbExplosiveDamage2[ST_TankType(victim)],
				flAbsorbFireDamage = !g_bTankConfig[ST_TankType(victim)] ? g_flAbsorbFireDamage[ST_TankType(victim)] : g_flAbsorbFireDamage2[ST_TankType(victim)],
				flAbsorbMeleeDamage = !g_bTankConfig[ST_TankType(victim)] ? g_flAbsorbMeleeDamage[ST_TankType(victim)] : g_flAbsorbMeleeDamage2[ST_TankType(victim)];
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
			main ? (g_iAbsorbAbility[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Ability Enabled", 0)) : (g_iAbsorbAbility2[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Ability Enabled", g_iAbsorbAbility[iIndex]));
			main ? (g_iAbsorbAbility[iIndex] = iClamp(g_iAbsorbAbility[iIndex], 0, 1)) : (g_iAbsorbAbility2[iIndex] = iClamp(g_iAbsorbAbility2[iIndex], 0, 1));
			main ? (g_iAbsorbMessage[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Ability Message", 0)) : (g_iAbsorbMessage2[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Ability Message", g_iAbsorbMessage[iIndex]));
			main ? (g_iAbsorbMessage[iIndex] = iClamp(g_iAbsorbMessage[iIndex], 0, 1)) : (g_iAbsorbMessage2[iIndex] = iClamp(g_iAbsorbMessage2[iIndex], 0, 1));
			main ? (g_flAbsorbBulletDamage[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Bullet Damage", 20.0)) : (g_flAbsorbBulletDamage2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Bullet Damage", g_flAbsorbBulletDamage[iIndex]));
			main ? (g_flAbsorbBulletDamage[iIndex] = flClamp(g_flAbsorbBulletDamage[iIndex], 0.1, 9999999999.0)) : (g_flAbsorbBulletDamage2[iIndex] = flClamp(g_flAbsorbBulletDamage2[iIndex], 0.1, 9999999999.0));
			main ? (g_iAbsorbChance[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Absorb Chance", 4)) : (g_iAbsorbChance2[iIndex] = kvSuperTanks.GetNum("Absorb Ability/Absorb Chance", g_iAbsorbChance[iIndex]));
			main ? (g_iAbsorbChance[iIndex] = iClamp(g_iAbsorbChance[iIndex], 1, 9999999999)) : (g_iAbsorbChance2[iIndex] = iClamp(g_iAbsorbChance2[iIndex], 1, 9999999999));
			main ? (g_flAbsorbDuration[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Duration", 5.0)) : (g_flAbsorbDuration2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Duration", g_flAbsorbDuration[iIndex]));
			main ? (g_flAbsorbDuration[iIndex] = flClamp(g_flAbsorbDuration[iIndex], 0.1, 9999999999.0)) : (g_flAbsorbDuration2[iIndex] = flClamp(g_flAbsorbDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_flAbsorbExplosiveDamage[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Explosive Damage", 20.0)) : (g_flAbsorbExplosiveDamage2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Explosive Damage", g_flAbsorbExplosiveDamage[iIndex]));
			main ? (g_flAbsorbExplosiveDamage[iIndex] = flClamp(g_flAbsorbExplosiveDamage[iIndex], 0.1, 9999999999.0)) : (g_flAbsorbExplosiveDamage2[iIndex] = flClamp(g_flAbsorbExplosiveDamage2[iIndex], 0.1, 9999999999.0));
			main ? (g_flAbsorbFireDamage[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Fire Damage", 200.0)) : (g_flAbsorbFireDamage2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Fire Damage", g_flAbsorbFireDamage[iIndex]));
			main ? (g_flAbsorbFireDamage[iIndex] = flClamp(g_flAbsorbFireDamage[iIndex], 0.1, 9999999999.0)) : (g_flAbsorbFireDamage2[iIndex] = flClamp(g_flAbsorbFireDamage2[iIndex], 0.1, 9999999999.0));
			main ? (g_flAbsorbMeleeDamage[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Melee Damage", 200.0)) : (g_flAbsorbMeleeDamage2[iIndex] = kvSuperTanks.GetFloat("Absorb Ability/Absorb Melee Damage", g_flAbsorbMeleeDamage[iIndex]));
			main ? (g_flAbsorbMeleeDamage[iIndex] = flClamp(g_flAbsorbMeleeDamage[iIndex], 0.1, 9999999999.0)) : (g_flAbsorbMeleeDamage2[iIndex] = flClamp(g_flAbsorbMeleeDamage2[iIndex], 0.1, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_incapacitated") == 0)
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iAbsorbAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && g_bAbsorb[iTank])
		{
			tTimerStopAbsorb(null, GetClientUserId(iTank));
		}
	}
}

public void ST_Ability(int client)
{
	int iAbsorbChance = !g_bTankConfig[ST_TankType(client)] ? g_iAbsorbChance[ST_TankType(client)] : g_iAbsorbChance2[ST_TankType(client)];
	if (iAbsorbAbility(client) == 1 && GetRandomInt(1, iAbsorbChance) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client) && !g_bAbsorb[client])
	{
		g_bAbsorb[client] = true;
		float flAbsorbDuration = !g_bTankConfig[ST_TankType(client)] ? g_flAbsorbDuration[ST_TankType(client)] : g_flAbsorbDuration2[ST_TankType(client)];
		CreateTimer(flAbsorbDuration, tTimerStopAbsorb, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		if (iAbsorbMessage(client) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(client, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Absorb", sTankName);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bAbsorb[iPlayer] = false;
		}
	}
}

stock void vReset2(int client)
{
	g_bAbsorb[client] = false;
	if (iAbsorbMessage(client) == 1)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		ST_TankName(client, sTankName);
		PrintToChatAll("%s %t", ST_PREFIX2, "Absorb2", sTankName);
	}
}

stock int iAbsorbAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iAbsorbAbility[ST_TankType(client)] : g_iAbsorbAbility2[ST_TankType(client)];
}

stock int iAbsorbMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iAbsorbMessage[ST_TankType(client)] : g_iAbsorbMessage2[ST_TankType(client)];
}

public Action tTimerStopAbsorb(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bAbsorb[iTank] = false;
		return Plugin_Stop;
	}
	if (iAbsorbAbility(iTank) == 0)
	{
		vReset2(iTank);
		return Plugin_Stop;
	}
	vReset2(iTank);
	return Plugin_Continue;
}