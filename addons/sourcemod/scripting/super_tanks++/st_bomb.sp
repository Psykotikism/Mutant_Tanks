// Super Tanks++: Bomb Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Bomb Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flBombRange[ST_MAXTYPES + 1], g_flBombRange2[ST_MAXTYPES + 1];
int g_iBombAbility[ST_MAXTYPES + 1], g_iBombAbility2[ST_MAXTYPES + 1], g_iBombChance[ST_MAXTYPES + 1], g_iBombChance2[ST_MAXTYPES + 1], g_iBombHit[ST_MAXTYPES + 1], g_iBombHit2[ST_MAXTYPES + 1], g_iBombHitMode[ST_MAXTYPES + 1], g_iBombHitMode2[ST_MAXTYPES + 1], g_iBombMessage[ST_MAXTYPES + 1], g_iBombMessage2[ST_MAXTYPES + 1], g_iBombRangeChance[ST_MAXTYPES + 1], g_iBombRangeChance2[ST_MAXTYPES + 1], g_iBombRock[ST_MAXTYPES + 1], g_iBombRock2[ST_MAXTYPES + 1];

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
	PrecacheModel(MODEL_PROPANETANK, true);
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
		if ((iBombHitMode(attacker) == 0 || iBombHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vBombHit(victim, attacker, iBombChance(attacker), iBombHit(attacker), 1);
			}
		}
		else if ((iBombHitMode(victim) == 0 || iBombHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vBombHit(attacker, victim, iBombChance(victim), iBombHit(victim), 1);
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
			main ? (g_iBombAbility[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Ability Enabled", 0)) : (g_iBombAbility2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Ability Enabled", g_iBombAbility[iIndex]));
			main ? (g_iBombAbility[iIndex] = iClamp(g_iBombAbility[iIndex], 0, 1)) : (g_iBombAbility2[iIndex] = iClamp(g_iBombAbility2[iIndex], 0, 1));
			main ? (g_iBombMessage[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Ability Message", 0)) : (g_iBombMessage2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Ability Message", g_iBombMessage[iIndex]));
			main ? (g_iBombMessage[iIndex] = iClamp(g_iBombMessage[iIndex], 0, 7)) : (g_iBombMessage2[iIndex] = iClamp(g_iBombMessage2[iIndex], 0, 7));
			main ? (g_iBombChance[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Chance", 4)) : (g_iBombChance2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Chance", g_iBombChance[iIndex]));
			main ? (g_iBombChance[iIndex] = iClamp(g_iBombChance[iIndex], 1, 9999999999)) : (g_iBombChance2[iIndex] = iClamp(g_iBombChance2[iIndex], 1, 9999999999));
			main ? (g_iBombHit[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Hit", 0)) : (g_iBombHit2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Hit", g_iBombHit[iIndex]));
			main ? (g_iBombHit[iIndex] = iClamp(g_iBombHit[iIndex], 0, 1)) : (g_iBombHit2[iIndex] = iClamp(g_iBombHit2[iIndex], 0, 1));
			main ? (g_iBombHitMode[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Hit Mode", 0)) : (g_iBombHitMode2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Hit Mode", g_iBombHitMode[iIndex]));
			main ? (g_iBombHitMode[iIndex] = iClamp(g_iBombHitMode[iIndex], 0, 2)) : (g_iBombHitMode2[iIndex] = iClamp(g_iBombHitMode2[iIndex], 0, 2));
			main ? (g_flBombRange[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Range", 150.0)) : (g_flBombRange2[iIndex] = kvSuperTanks.GetFloat("Bomb Ability/Bomb Range", g_flBombRange[iIndex]));
			main ? (g_flBombRange[iIndex] = flClamp(g_flBombRange[iIndex], 1.0, 9999999999.0)) : (g_flBombRange2[iIndex] = flClamp(g_flBombRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iBombRangeChance[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Range Chance", 16)) : (g_iBombRangeChance2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Range Chance", g_iBombRangeChance[iIndex]));
			main ? (g_iBombRangeChance[iIndex] = iClamp(g_iBombRangeChance[iIndex], 1, 9999999999)) : (g_iBombRangeChance2[iIndex] = iClamp(g_iBombRangeChance2[iIndex], 1, 9999999999));
			main ? (g_iBombRock[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Rock Break", 0)) : (g_iBombRock2[iIndex] = kvSuperTanks.GetNum("Bomb Ability/Bomb Rock Break", g_iBombRock[iIndex]));
			main ? (g_iBombRock[iIndex] = iClamp(g_iBombRock[iIndex], 0, 1)) : (g_iBombRock2[iIndex] = iClamp(g_iBombRock2[iIndex], 0, 1));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iBombAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			float flPos[3];
			GetClientAbsOrigin(iTank, flPos);
			vSpecialAttack(iTank, flPos, MODEL_PROPANETANK);
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iBombRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iBombChance[ST_TankType(client)] : g_iBombChance2[ST_TankType(client)];
		float flBombRange = !g_bTankConfig[ST_TankType(client)] ? g_flBombRange[ST_TankType(client)] : g_flBombRange2[ST_TankType(client)],
			flTankPos[3];
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
					vBombHit(iSurvivor, client, iBombRangeChance, iBombAbility(client), 2);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	if (iBombAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled))
	{
		float flPos[3];
		GetClientAbsOrigin(client, flPos);
		vSpecialAttack(client, flPos, MODEL_PROPANETANK);
	}
}

public void ST_RockBreak(int client, int entity)
{
	int iBombRock = !g_bTankConfig[ST_TankType(client)] ? g_iBombRock[ST_TankType(client)] : g_iBombRock2[ST_TankType(client)];
	if (iBombRock == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		float flPos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPos);
		vSpecialAttack(client, flPos, MODEL_PROPANETANK);
		switch (iBombMessage(client))
		{
			case 3, 5, 6, 7:
			{
				char sTankName[MAX_NAME_LENGTH + 1];
				ST_TankName(client, sTankName);
				PrintToChatAll("%s %t", ST_PREFIX2, "Bomb2", sTankName);
			}
		}
	}
}

void vBombHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		float flPos[3];
		GetClientAbsOrigin(client, flPos);
		vSpecialAttack(owner, flPos, MODEL_PROPANETANK);
		if (iBombMessage(owner) == message || iBombMessage(client) == 4 || iBombMessage(client) == 5 || iBombMessage(client) == 6 || iBombMessage(client) == 7)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Bomb", sTankName, client);
		}
	}
}

stock int iBombAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iBombAbility[ST_TankType(client)] : g_iBombAbility2[ST_TankType(client)];
}

stock int iBombChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iBombChance[ST_TankType(client)] : g_iBombChance2[ST_TankType(client)];
}

stock int iBombHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iBombHit[ST_TankType(client)] : g_iBombHit2[ST_TankType(client)];
}

stock int iBombHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iBombHitMode[ST_TankType(client)] : g_iBombHitMode2[ST_TankType(client)];
}

stock int iBombMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iBombMessage[ST_TankType(client)] : g_iBombMessage2[ST_TankType(client)];
}