// Super Tanks++: Hypno Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Hypno Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bHypno[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flHypnoDuration[ST_MAXTYPES + 1], g_flHypnoDuration2[ST_MAXTYPES + 1], g_flHypnoRange[ST_MAXTYPES + 1], g_flHypnoRange2[ST_MAXTYPES + 1];
int g_iHypnoAbility[ST_MAXTYPES + 1], g_iHypnoAbility2[ST_MAXTYPES + 1], g_iHypnoChance[ST_MAXTYPES + 1], g_iHypnoChance2[ST_MAXTYPES + 1], g_iHypnoHit[ST_MAXTYPES + 1], g_iHypnoHit2[ST_MAXTYPES + 1], g_iHypnoHitMode[ST_MAXTYPES + 1], g_iHypnoHitMode2[ST_MAXTYPES + 1], g_iHypnoMode[ST_MAXTYPES + 1], g_iHypnoMode2[ST_MAXTYPES + 1], g_iHypnoMessage[ST_MAXTYPES + 1], g_iHypnoMessage2[ST_MAXTYPES + 1], g_iHypnoRangeChance[ST_MAXTYPES + 1], g_iHypnoRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Hypno Ability only supports Left 4 Dead 1 & 2.");
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
	g_bHypno[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((iHypnoHitMode(attacker) == 0 || iHypnoHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vHypnoHit(victim, attacker, iHypnoChance(attacker), iHypnoHit(attacker), 1);
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if ((iHypnoHitMode(victim) == 0 || iHypnoHitMode(victim) == 2) && strcmp(sClassname, "weapon_melee") == 0)
			{
				vHypnoHit(attacker, victim, iHypnoChance(victim), iHypnoHit(victim), 1);
			}
			if (g_bHypno[attacker])
			{
				int iHypnoMode = !g_bTankConfig[ST_TankType(victim)] ? g_iHypnoMode[ST_TankType(victim)] : g_iHypnoMode2[ST_TankType(victim)],
					iHealth = GetClientHealth(attacker), iTarget = iGetRandomSurvivor(attacker);
				switch (damagetype)
				{
					case DMG_BULLET: damage = damage / 20.0;
					case DMG_BLAST, DMG_BLAST_SURFACE, DMG_AIRBOAT, DMG_PLASMA: damage = damage / 20.0;
					case DMG_BURN: damage = damage / 200.0;
					case DMG_SLASH, DMG_CLUB: damage = damage / 200.0;
				}
				(iHealth > damage) ? ((iHypnoMode == 1 && iTarget > 0) ? SetEntityHealth(iTarget, iHealth - RoundToNearest(damage)) : SetEntityHealth(attacker, iHealth - RoundToNearest(damage))) : ((iHypnoMode == 1 && iTarget > 0) ? SetEntProp(iTarget, Prop_Send, "m_isIncapacitated", 1) : SetEntProp(attacker, Prop_Send, "m_isIncapacitated", 1));
				damage = 0.0;
				return Plugin_Changed;
			}
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
			main ? (g_iHypnoAbility[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Ability Enabled", 0)) : (g_iHypnoAbility2[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Ability Enabled", g_iHypnoAbility[iIndex]));
			main ? (g_iHypnoAbility[iIndex] = iClamp(g_iHypnoAbility[iIndex], 0, 1)) : (g_iHypnoAbility2[iIndex] = iClamp(g_iHypnoAbility2[iIndex], 0, 1));
			main ? (g_iHypnoMessage[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Ability Message", 0)) : (g_iHypnoMessage2[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Ability Message", g_iHypnoMessage[iIndex]));
			main ? (g_iHypnoMessage[iIndex] = iClamp(g_iHypnoMessage[iIndex], 0, 3)) : (g_iHypnoMessage2[iIndex] = iClamp(g_iHypnoMessage2[iIndex], 0, 3));
			main ? (g_iHypnoChance[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Chance", 4)) : (g_iHypnoChance2[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Chance", g_iHypnoChance[iIndex]));
			main ? (g_iHypnoChance[iIndex] = iClamp(g_iHypnoChance[iIndex], 1, 9999999999)) : (g_iHypnoChance2[iIndex] = iClamp(g_iHypnoChance2[iIndex], 1, 9999999999));
			main ? (g_flHypnoDuration[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Duration", 5.0)) : (g_flHypnoDuration2[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Duration", g_flHypnoDuration[iIndex]));
			main ? (g_flHypnoDuration[iIndex] = flClamp(g_flHypnoDuration[iIndex], 0.1, 9999999999.0)) : (g_flHypnoDuration2[iIndex] = flClamp(g_flHypnoDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iHypnoHit[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Hit", 0)) : (g_iHypnoHit2[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Hit", g_iHypnoHit[iIndex]));
			main ? (g_iHypnoHit[iIndex] = iClamp(g_iHypnoHit[iIndex], 0, 1)) : (g_iHypnoHit2[iIndex] = iClamp(g_iHypnoHit2[iIndex], 0, 1));
			main ? (g_iHypnoHitMode[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Hit Mode", 0)) : (g_iHypnoHitMode2[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Hit Mode", g_iHypnoHitMode[iIndex]));
			main ? (g_iHypnoHitMode[iIndex] = iClamp(g_iHypnoHitMode[iIndex], 0, 2)) : (g_iHypnoHitMode2[iIndex] = iClamp(g_iHypnoHitMode2[iIndex], 0, 2));
			main ? (g_iHypnoMode[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Mode", 0)) : (g_iHypnoMode2[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Mode", g_iHypnoMode[iIndex]));
			main ? (g_iHypnoMode[iIndex] = iClamp(g_iHypnoMode[iIndex], 0, 1)) : (g_iHypnoMode2[iIndex] = iClamp(g_iHypnoMode2[iIndex], 0, 1));
			main ? (g_flHypnoRange[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Range", 150.0)) : (g_flHypnoRange2[iIndex] = kvSuperTanks.GetFloat("Hypno Ability/Hypno Range", g_flHypnoRange[iIndex]));
			main ? (g_flHypnoRange[iIndex] = flClamp(g_flHypnoRange[iIndex], 1.0, 9999999999.0)) : (g_flHypnoRange2[iIndex] = flClamp(g_flHypnoRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iHypnoRangeChance[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Range Chance", 16)) : (g_iHypnoRangeChance2[iIndex] = kvSuperTanks.GetNum("Hypno Ability/Hypno Range Chance", g_iHypnoRangeChance[iIndex]));
			main ? (g_iHypnoRangeChance[iIndex] = iClamp(g_iHypnoRangeChance[iIndex], 1, 9999999999)) : (g_iHypnoRangeChance2[iIndex] = iClamp(g_iHypnoRangeChance2[iIndex], 1, 9999999999));
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
		if (iHypnoAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveHypno();
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iHypnoRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iHypnoChance[ST_TankType(client)] : g_iHypnoChance2[ST_TankType(client)];
		float flHypnoRange = !g_bTankConfig[ST_TankType(client)] ? g_flHypnoRange[ST_TankType(client)] : g_flHypnoRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flHypnoRange)
				{
					vHypnoHit(iSurvivor, client, iHypnoRangeChance, iHypnoAbility(client), 2);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	if (iHypnoAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled))
	{
		vRemoveHypno();
	}
}

stock void vHypnoHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bHypno[client])
	{
		g_bHypno[client] = true;
		float flHypnoDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flHypnoDuration[ST_TankType(owner)] : g_flHypnoDuration2[ST_TankType(owner)];
		DataPack dpStopHypno = new DataPack();
		CreateDataTimer(flHypnoDuration, tTimerStopHypno, dpStopHypno, TIMER_FLAG_NO_MAPCHANGE);
		dpStopHypno.WriteCell(GetClientUserId(client)), dpStopHypno.WriteCell(GetClientUserId(owner)), dpStopHypno.WriteCell(message), dpStopHypno.WriteCell(enabled);
		if (iHypnoMessage(owner) == message || iHypnoMessage(owner) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Hypno", sTankName, client);
		}
	}
}

stock void vRemoveHypno()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bHypno[iSurvivor])
		{
			g_bHypno[iSurvivor] = false;
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bHypno[iPlayer] = false;
		}
	}
}

stock void vReset2(int client, int owner, int message)
{
	g_bHypno[client] = false;
	if (iHypnoMessage(owner) == message || iHypnoMessage(owner) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Hypno2", client);
	}
}

stock int iHypnoAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iHypnoAbility[ST_TankType(client)] : g_iHypnoAbility2[ST_TankType(client)];
}

stock int iHypnoChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iHypnoChance[ST_TankType(client)] : g_iHypnoChance2[ST_TankType(client)];
}

stock int iHypnoHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iHypnoHit[ST_TankType(client)] : g_iHypnoHit2[ST_TankType(client)];
}

stock int iHypnoHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iHypnoHitMode[ST_TankType(client)] : g_iHypnoHitMode2[ST_TankType(client)];
}

stock int iHypnoMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iHypnoMessage[ST_TankType(client)] : g_iHypnoMessage2[ST_TankType(client)];
}

public Action tTimerStopHypno(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bHypno[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell()), iHypnoChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank, iHypnoChat);
		return Plugin_Stop;
	}
	int iHypnoEnabled = pack.ReadCell();
	if (iHypnoEnabled == 0)
	{
		vReset2(iSurvivor, iTank, iHypnoChat);
		return Plugin_Stop;
	}
	vReset2(iSurvivor, iTank, iHypnoChat);
	return Plugin_Continue;
}