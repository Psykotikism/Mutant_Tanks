// Super Tanks++: Fragile Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Fragile Ability",
	author = ST_AUTHOR,
	description = "The Super Tank takes more damage.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bFragile[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flFragileBulletDamage[ST_MAXTYPES + 1], g_flFragileBulletDamage2[ST_MAXTYPES + 1], g_flFragileDuration[ST_MAXTYPES + 1], g_flFragileDuration2[ST_MAXTYPES + 1], g_flFragileExplosiveDamage[ST_MAXTYPES + 1], g_flFragileExplosiveDamage2[ST_MAXTYPES + 1], g_flFragileFireDamage[ST_MAXTYPES + 1], g_flFragileFireDamage2[ST_MAXTYPES + 1], g_flFragileMeleeDamage[ST_MAXTYPES + 1], g_flFragileMeleeDamage2[ST_MAXTYPES + 1];
int g_iFragileAbility[ST_MAXTYPES + 1], g_iFragileAbility2[ST_MAXTYPES + 1], g_iFragileChance[ST_MAXTYPES + 1], g_iFragileChance2[ST_MAXTYPES + 1], g_iFragileMessage[ST_MAXTYPES + 1], g_iFragileMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_Left4Dead && !bIsL4D2())
	{
		strcopy(error, err_max, "[ST++] Fragile Ability only supports Left 4 Dead 1 & 2.");
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
	g_bFragile[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && g_bFragile[victim])
		{
			float flFragileBulletDamage = !g_bTankConfig[ST_TankType(victim)] ? g_flFragileBulletDamage[ST_TankType(victim)] : g_flFragileBulletDamage2[ST_TankType(victim)],
				flFragileExplosiveDamage = !g_bTankConfig[ST_TankType(victim)] ? g_flFragileExplosiveDamage[ST_TankType(victim)] : g_flFragileExplosiveDamage2[ST_TankType(victim)],
				flFragileFireDamage = !g_bTankConfig[ST_TankType(victim)] ? g_flFragileFireDamage[ST_TankType(victim)] : g_flFragileFireDamage2[ST_TankType(victim)],
				flFragileMeleeDamage = !g_bTankConfig[ST_TankType(victim)] ? g_flFragileMeleeDamage[ST_TankType(victim)] : g_flFragileMeleeDamage2[ST_TankType(victim)];
			switch (damagetype)
			{
				case DMG_BULLET: damage = damage * flFragileBulletDamage;
				case DMG_BLAST, DMG_BLAST_SURFACE, DMG_AIRBOAT, DMG_PLASMA: damage = damage * flFragileExplosiveDamage;
				case DMG_BURN: damage = damage * flFragileFireDamage;
				case DMG_SLASH, DMG_CLUB: damage = damage * flFragileMeleeDamage;
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
		Format(sName, sizeof(sName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iFragileAbility[iIndex] = kvSuperTanks.GetNum("Fragile Ability/Ability Enabled", 0)) : (g_iFragileAbility2[iIndex] = kvSuperTanks.GetNum("Fragile Ability/Ability Enabled", g_iFragileAbility[iIndex]));
			main ? (g_iFragileAbility[iIndex] = iClamp(g_iFragileAbility[iIndex], 0, 1)) : (g_iFragileAbility2[iIndex] = iClamp(g_iFragileAbility2[iIndex], 0, 1));
			main ? (g_iFragileMessage[iIndex] = kvSuperTanks.GetNum("Fragile Ability/Ability Message", 0)) : (g_iFragileMessage2[iIndex] = kvSuperTanks.GetNum("Fragile Ability/Ability Message", g_iFragileMessage[iIndex]));
			main ? (g_iFragileMessage[iIndex] = iClamp(g_iFragileMessage[iIndex], 0, 1)) : (g_iFragileMessage2[iIndex] = iClamp(g_iFragileMessage2[iIndex], 0, 1));
			main ? (g_flFragileBulletDamage[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Bullet Damage", 5.0)) : (g_flFragileBulletDamage2[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Bullet Damage", g_flFragileBulletDamage[iIndex]));
			main ? (g_flFragileBulletDamage[iIndex] = flClamp(g_flFragileBulletDamage[iIndex], 0.1, 9999999999.0)) : (g_flFragileBulletDamage2[iIndex] = flClamp(g_flFragileBulletDamage2[iIndex], 0.1, 9999999999.0));
			main ? (g_iFragileChance[iIndex] = kvSuperTanks.GetNum("Fragile Ability/Fragile Chance", 4)) : (g_iFragileChance2[iIndex] = kvSuperTanks.GetNum("Fragile Ability/Fragile Chance", g_iFragileChance[iIndex]));
			main ? (g_iFragileChance[iIndex] = iClamp(g_iFragileChance[iIndex], 1, 9999999999)) : (g_iFragileChance2[iIndex] = iClamp(g_iFragileChance2[iIndex], 1, 9999999999));
			main ? (g_flFragileDuration[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Duration", 5.0)) : (g_flFragileDuration2[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Duration", g_flFragileDuration[iIndex]));
			main ? (g_flFragileDuration[iIndex] = flClamp(g_flFragileDuration[iIndex], 0.1, 9999999999.0)) : (g_flFragileDuration2[iIndex] = flClamp(g_flFragileDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_flFragileExplosiveDamage[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Explosive Damage", 5.0)) : (g_flFragileExplosiveDamage2[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Explosive Damage", g_flFragileExplosiveDamage[iIndex]));
			main ? (g_flFragileExplosiveDamage[iIndex] = flClamp(g_flFragileExplosiveDamage[iIndex], 0.1, 9999999999.0)) : (g_flFragileExplosiveDamage2[iIndex] = flClamp(g_flFragileExplosiveDamage2[iIndex], 0.1, 9999999999.0));
			main ? (g_flFragileFireDamage[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Fire Damage", 3.0)) : (g_flFragileFireDamage2[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Fire Damage", g_flFragileFireDamage[iIndex]));
			main ? (g_flFragileFireDamage[iIndex] = flClamp(g_flFragileFireDamage[iIndex], 0.1, 9999999999.0)) : (g_flFragileFireDamage2[iIndex] = flClamp(g_flFragileFireDamage2[iIndex], 0.1, 9999999999.0));
			main ? (g_flFragileMeleeDamage[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Melee Damage", 1.5)) : (g_flFragileMeleeDamage2[iIndex] = kvSuperTanks.GetFloat("Fragile Ability/Fragile Melee Damage", g_flFragileMeleeDamage[iIndex]));
			main ? (g_flFragileMeleeDamage[iIndex] = flClamp(g_flFragileMeleeDamage[iIndex], 0.1, 9999999999.0)) : (g_flFragileMeleeDamage2[iIndex] = flClamp(g_flFragileMeleeDamage2[iIndex], 0.1, 9999999999.0));
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
		if (iFragileAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && g_bFragile[iTank])
		{
			tTimerStopFragile(null, GetClientUserId(iTank));
		}
	}
}

public void ST_Ability(int client)
{
	int iFragileChance = !g_bTankConfig[ST_TankType(client)] ? g_iFragileChance[ST_TankType(client)] : g_iFragileChance2[ST_TankType(client)];
	if (iFragileAbility(client) == 1 && GetRandomInt(1, iFragileChance) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client) && !g_bFragile[client])
	{
		g_bFragile[client] = true;
		float flFragileDuration = !g_bTankConfig[ST_TankType(client)] ? g_flFragileDuration[ST_TankType(client)] : g_flFragileDuration2[ST_TankType(client)];
		CreateTimer(flFragileDuration, tTimerStopFragile, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		if (iFragileMessage(client) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(client, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Fragile", sTankName);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bFragile[iPlayer] = false;
		}
	}
}

stock void vReset2(int client)
{
	g_bFragile[client] = false;
	if (iFragileMessage(client) == 1)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		ST_TankName(client, sTankName);
		PrintToChatAll("%s %t", ST_PREFIX2, "Fragile2", sTankName);
	}
}

stock int iFragileAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iFragileAbility[ST_TankType(client)] : g_iFragileAbility2[ST_TankType(client)];
}

stock int iFragileMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iFragileMessage[ST_TankType(client)] : g_iFragileMessage2[ST_TankType(client)];
}

public Action tTimerStopFragile(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bFragile[iTank] = false;
		return Plugin_Stop;
	}
	if (iFragileAbility(iTank) == 0)
	{
		vReset2(iTank);
		return Plugin_Stop;
	}
	vReset2(iTank);
	return Plugin_Continue;
}