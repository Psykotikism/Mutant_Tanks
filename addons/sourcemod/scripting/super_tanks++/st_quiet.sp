// Super Tanks++: Quiet Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Quiet Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bQuiet[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
char g_sTankSounds[12] = "player/tank";
float g_flQuietDuration[ST_MAXTYPES + 1], g_flQuietDuration2[ST_MAXTYPES + 1], g_flQuietRange[ST_MAXTYPES + 1], g_flQuietRange2[ST_MAXTYPES + 1];
int g_iQuietAbility[ST_MAXTYPES + 1], g_iQuietAbility2[ST_MAXTYPES + 1], g_iQuietChance[ST_MAXTYPES + 1], g_iQuietChance2[ST_MAXTYPES + 1], g_iQuietHit[ST_MAXTYPES + 1], g_iQuietHit2[ST_MAXTYPES + 1], g_iQuietHitMode[ST_MAXTYPES + 1], g_iQuietHitMode2[ST_MAXTYPES + 1], g_iQuietMessage[ST_MAXTYPES + 1], g_iQuietMessage2[ST_MAXTYPES + 1], g_iQuietRangeChance[ST_MAXTYPES + 1], g_iQuietRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Quiet Ability only supports Left 4 Dead 1 & 2.");
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
	AddNormalSoundHook(SoundHook);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bQuiet[client] = false;
}

public void OnMapEnd()
{
	vReset();
	RemoveNormalSoundHook(SoundHook);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((iQuietHitMode(attacker) == 0 || iQuietHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vQuietHit(victim, attacker, iQuietChance(attacker), iQuietHit(attacker), 1);
			}
		}
		else if ((iQuietHitMode(victim) == 0 || iQuietHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vQuietHit(attacker, victim, iQuietChance(victim), iQuietHit(victim), 1);
			}
		}
	}
}

public Action SoundHook(int clients[MAXPLAYERS], int &numClients, char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level, int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
	if (StrContains(sample, g_sTankSounds, false) != -1)
	{
		for (int iSurvivor = 0; iSurvivor < numClients; iSurvivor++)
		{
			if (bIsSurvivor(clients[iSurvivor]) && g_bQuiet[clients[iSurvivor]])
			{
				for (int iPlayers = iSurvivor; iPlayers < numClients - 1; iPlayers++)
				{
					clients[iPlayers] = clients[iPlayers + 1];
				}
				numClients--;
				iSurvivor--;
			}
		}
		return (numClients > 0) ? Plugin_Changed : Plugin_Stop;
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
			main ? (g_iQuietAbility[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Ability Enabled", 0)) : (g_iQuietAbility2[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Ability Enabled", g_iQuietAbility[iIndex]));
			main ? (g_iQuietAbility[iIndex] = iClamp(g_iQuietAbility[iIndex], 0, 1)) : (g_iQuietAbility2[iIndex] = iClamp(g_iQuietAbility2[iIndex], 0, 1));
			main ? (g_iQuietMessage[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Ability Message", 0)) : (g_iQuietMessage2[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Ability Message", g_iQuietMessage[iIndex]));
			main ? (g_iQuietMessage[iIndex] = iClamp(g_iQuietMessage[iIndex], 0, 3)) : (g_iQuietMessage2[iIndex] = iClamp(g_iQuietMessage2[iIndex], 0, 3));
			main ? (g_iQuietChance[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Quiet Chance", 4)) : (g_iQuietChance2[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Quiet Chance", g_iQuietChance[iIndex]));
			main ? (g_iQuietChance[iIndex] = iClamp(g_iQuietChance[iIndex], 1, 9999999999)) : (g_iQuietChance2[iIndex] = iClamp(g_iQuietChance2[iIndex], 1, 9999999999));
			main ? (g_flQuietDuration[iIndex] = kvSuperTanks.GetFloat("Quiet Ability/Quiet Duration", 5.0)) : (g_flQuietDuration2[iIndex] = kvSuperTanks.GetFloat("Quiet Ability/Quiet Duration", g_flQuietDuration[iIndex]));
			main ? (g_flQuietDuration[iIndex] = flClamp(g_flQuietDuration[iIndex], 0.1, 9999999999.0)) : (g_flQuietDuration2[iIndex] = flClamp(g_flQuietDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iQuietHit[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Quiet Hit", 0)) : (g_iQuietHit2[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Quiet Hit", g_iQuietHit[iIndex]));
			main ? (g_iQuietHit[iIndex] = iClamp(g_iQuietHit[iIndex], 0, 1)) : (g_iQuietHit2[iIndex] = iClamp(g_iQuietHit2[iIndex], 0, 1));
			main ? (g_iQuietHitMode[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Quiet Hit Mode", 0)) : (g_iQuietHitMode2[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Quiet Hit Mode", g_iQuietHitMode[iIndex]));
			main ? (g_iQuietHitMode[iIndex] = iClamp(g_iQuietHitMode[iIndex], 0, 2)) : (g_iQuietHitMode2[iIndex] = iClamp(g_iQuietHitMode2[iIndex], 0, 2));
			main ? (g_flQuietRange[iIndex] = kvSuperTanks.GetFloat("Quiet Ability/Quiet Range", 150.0)) : (g_flQuietRange2[iIndex] = kvSuperTanks.GetFloat("Quiet Ability/Quiet Range", g_flQuietRange[iIndex]));
			main ? (g_flQuietRange[iIndex] = flClamp(g_flQuietRange[iIndex], 1.0, 9999999999.0)) : (g_flQuietRange2[iIndex] = flClamp(g_flQuietRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iQuietRangeChance[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Quiet Range Chance", 16)) : (g_iQuietRangeChance2[iIndex] = kvSuperTanks.GetNum("Quiet Ability/Quiet Range Chance", g_iQuietRangeChance[iIndex]));
			main ? (g_iQuietRangeChance[iIndex] = iClamp(g_iQuietRangeChance[iIndex], 1, 9999999999)) : (g_iQuietRangeChance2[iIndex] = iClamp(g_iQuietRangeChance2[iIndex], 1, 9999999999));
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
		if (iQuietAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveQuiet();
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iQuietRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iQuietChance[ST_TankType(client)] : g_iQuietChance2[ST_TankType(client)];
		float flQuietRange = !g_bTankConfig[ST_TankType(client)] ? g_flQuietRange[ST_TankType(client)] : g_flQuietRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flQuietRange)
				{
					vQuietHit(iSurvivor, client, iQuietRangeChance, iQuietAbility(client), 2);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	if (iQuietAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled))
	{
		vRemoveQuiet();
	}
}

stock void vQuietHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bQuiet[client])
	{
		g_bQuiet[client] = true;
		float flQuietDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flQuietDuration[ST_TankType(owner)] : g_flQuietDuration2[ST_TankType(owner)];
		DataPack dpStopQuiet = new DataPack();
		CreateDataTimer(flQuietDuration, tTimerStopQuiet, dpStopQuiet, TIMER_FLAG_NO_MAPCHANGE);
		dpStopQuiet.WriteCell(GetClientUserId(client)), dpStopQuiet.WriteCell(GetClientUserId(owner)), dpStopQuiet.WriteCell(message), dpStopQuiet.WriteCell(enabled);
		if (iQuietMessage(owner) == message || iQuietMessage(owner) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Quiet", sTankName, client);
		}
	}
}

stock void vRemoveQuiet()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bQuiet[iSurvivor])
		{
			g_bQuiet[iSurvivor] = false;
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bQuiet[iPlayer] = false;
		}
	}
}

stock void vReset2(int client, int owner, int message)
{
	g_bQuiet[client] = false;
	if (iQuietMessage(owner) == message || iQuietMessage(owner) == 3)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		ST_TankName(owner, sTankName);
		PrintToChatAll("%s %t", ST_PREFIX2, "Quiet2", sTankName, client);
	}
}

stock int iQuietAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iQuietAbility[ST_TankType(client)] : g_iQuietAbility2[ST_TankType(client)];
}

stock int iQuietChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iQuietChance[ST_TankType(client)] : g_iQuietChance2[ST_TankType(client)];
}

stock int iQuietHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iQuietHit[ST_TankType(client)] : g_iQuietHit2[ST_TankType(client)];
}

stock int iQuietHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iQuietHitMode[ST_TankType(client)] : g_iQuietHitMode2[ST_TankType(client)];
}

stock int iQuietMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iQuietMessage[ST_TankType(client)] : g_iQuietMessage2[ST_TankType(client)];
}

public Action tTimerStopQuiet(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bQuiet[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell()), iQuietChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank, iQuietChat);
		return Plugin_Stop;
	}
	int iQuietEnabled = pack.ReadCell();
	if (iQuietEnabled == 0)
	{
		vReset2(iSurvivor, iTank, iQuietChat);
		return Plugin_Stop;
	}
	vReset2(iSurvivor, iTank, iQuietChat);
	return Plugin_Continue;
}