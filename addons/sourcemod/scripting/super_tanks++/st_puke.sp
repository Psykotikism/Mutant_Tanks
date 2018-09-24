// Super Tanks++: Puke Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Puke Ability",
	author = ST_AUTHOR,
	description = "The Super Tank pukes on survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flPukeRange[ST_MAXTYPES + 1], g_flPukeRange2[ST_MAXTYPES + 1];
Handle g_hSDKPukePlayer;
int g_iPukeAbility[ST_MAXTYPES + 1], g_iPukeAbility2[ST_MAXTYPES + 1], g_iPukeChance[ST_MAXTYPES + 1], g_iPukeChance2[ST_MAXTYPES + 1], g_iPukeHit[ST_MAXTYPES + 1], g_iPukeHit2[ST_MAXTYPES + 1], g_iPukeHitMode[ST_MAXTYPES + 1], g_iPukeHitMode2[ST_MAXTYPES + 1], g_iPukeMessage[ST_MAXTYPES + 1], g_iPukeMessage2[ST_MAXTYPES + 1], g_iPukeRangeChance[ST_MAXTYPES + 1], g_iPukeRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_Left4Dead && !bIsL4D2())
	{
		strcopy(error, err_max, "[ST++] Puke Ability only supports Left 4 Dead 1 & 2.");
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
	Handle hGameData = LoadGameConfigFile("super_tanks++");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDKPukePlayer = EndPrepSDKCall();
	if (g_hSDKPukePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnVomitedUpon\" signature is outdated.", ST_PREFIX);
	}
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
		if ((iPukeHitMode(attacker) == 0 || iPukeHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vPukeHit(victim, attacker, iPukeChance(attacker), iPukeHit(attacker), 1);
			}
		}
		else if ((iPukeHitMode(victim) == 0 || iPukeHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vPukeHit(attacker, victim, iPukeChance(victim), iPukeHit(victim), 1);
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
			main ? (g_iPukeAbility[iIndex] = kvSuperTanks.GetNum("Puke Ability/Ability Enabled", 0)) : (g_iPukeAbility2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Ability Enabled", g_iPukeAbility[iIndex]));
			main ? (g_iPukeAbility[iIndex] = iClamp(g_iPukeAbility[iIndex], 0, 1)) : (g_iPukeAbility2[iIndex] = iClamp(g_iPukeAbility2[iIndex], 0, 1));
			main ? (g_iPukeMessage[iIndex] = kvSuperTanks.GetNum("Puke Ability/Ability Message", 0)) : (g_iPukeMessage2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Ability Message", g_iPukeMessage[iIndex]));
			main ? (g_iPukeMessage[iIndex] = iClamp(g_iPukeMessage[iIndex], 0, 3)) : (g_iPukeMessage2[iIndex] = iClamp(g_iPukeMessage2[iIndex], 0, 3));
			main ? (g_iPukeChance[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Chance", 4)) : (g_iPukeChance2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Chance", g_iPukeChance[iIndex]));
			main ? (g_iPukeChance[iIndex] = iClamp(g_iPukeChance[iIndex], 1, 9999999999)) : (g_iPukeChance2[iIndex] = iClamp(g_iPukeChance2[iIndex], 1, 9999999999));
			main ? (g_iPukeHit[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Hit", 0)) : (g_iPukeHit2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Hit", g_iPukeHit[iIndex]));
			main ? (g_iPukeHit[iIndex] = iClamp(g_iPukeHit[iIndex], 0, 1)) : (g_iPukeHit2[iIndex] = iClamp(g_iPukeHit2[iIndex], 0, 1));
			main ? (g_iPukeHitMode[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Hit Mode", 0)) : (g_iPukeHitMode2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Hit Mode", g_iPukeHitMode[iIndex]));
			main ? (g_iPukeHitMode[iIndex] = iClamp(g_iPukeHitMode[iIndex], 0, 2)) : (g_iPukeHitMode2[iIndex] = iClamp(g_iPukeHitMode2[iIndex], 0, 2));
			main ? (g_flPukeRange[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Range", 150.0)) : (g_flPukeRange2[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Range", g_flPukeRange[iIndex]));
			main ? (g_flPukeRange[iIndex] = flClamp(g_flPukeRange[iIndex], 1.0, 9999999999.0)) : (g_flPukeRange2[iIndex] = flClamp(g_flPukeRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iPukeRangeChance[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Range Chance", 16)) : (g_iPukeRangeChance2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Range Chance", g_iPukeRangeChance[iIndex]));
			main ? (g_iPukeRangeChance[iIndex] = iClamp(g_iPukeRangeChance[iIndex], 1, 9999999999)) : (g_iPukeRangeChance2[iIndex] = iClamp(g_iPukeRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iPukeRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iPukeChance[ST_TankType(client)] : g_iPukeChance2[ST_TankType(client)];
		float flPukeRange = !g_bTankConfig[ST_TankType(client)] ? g_flPukeRange[ST_TankType(client)] : g_flPukeRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flPukeRange)
				{
					vPukeHit(iSurvivor, client, iPukeRangeChance, iPukeAbility(client), 2);
				}
			}
		}
	}
}

stock void vPukeHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		int iPukeMessage = !g_bTankConfig[ST_TankType(owner)] ? g_iPukeMessage[ST_TankType(owner)] : g_iPukeMessage2[ST_TankType(owner)];
		SDKCall(g_hSDKPukePlayer, client, owner, true);
		if (iPukeMessage == message, iPukeMessage == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Puke", sTankName, client);
		}
	}
}

stock int iPukeAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPukeAbility[ST_TankType(client)] : g_iPukeAbility2[ST_TankType(client)];
}

stock int iPukeChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPukeChance[ST_TankType(client)] : g_iPukeChance2[ST_TankType(client)];
}

stock int iPukeHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPukeHit[ST_TankType(client)] : g_iPukeHit2[ST_TankType(client)];
}

stock int iPukeHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPukeHitMode[ST_TankType(client)] : g_iPukeHitMode2[ST_TankType(client)];
}