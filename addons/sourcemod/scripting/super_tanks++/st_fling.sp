// Super Tanks++: Fling Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Fling Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flFlingRange[ST_MAXTYPES + 1], g_flFlingRange2[ST_MAXTYPES + 1];
Handle g_hSDKFlingPlayer, g_hSDKPukePlayer;
int g_iFlingAbility[ST_MAXTYPES + 1], g_iFlingAbility2[ST_MAXTYPES + 1], g_iFlingChance[ST_MAXTYPES + 1], g_iFlingChance2[ST_MAXTYPES + 1], g_iFlingHit[ST_MAXTYPES + 1], g_iFlingHit2[ST_MAXTYPES + 1], g_iFlingHitMode[ST_MAXTYPES + 1], g_iFlingHitMode2[ST_MAXTYPES + 1], g_iFlingRangeChance[ST_MAXTYPES + 1], g_iFlingRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Fling Ability only supports Left 4 Dead 1 & 2.");
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
	Handle hGameData = LoadGameConfigFile("super_tanks++");
	if (bIsL4D2Game())
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer_Fling");
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		g_hSDKFlingPlayer = EndPrepSDKCall();
		if (g_hSDKFlingPlayer == null)
		{
			PrintToServer("%s Your \"CTerrorPlayer_Fling\" signature is outdated.", ST_PREFIX);
		}
	}
	else
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		g_hSDKPukePlayer = EndPrepSDKCall();
		if (g_hSDKPukePlayer == null)
		{
			PrintToServer("%s Your \"CTerrorPlayer_OnVomitedUpon\" signature is outdated.", ST_PREFIX);
		}
	}
}

public void OnMapStart()
{
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
		if ((iFlingHitMode(attacker) == 0 || iFlingHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vFlingHit(victim, attacker, iFlingChance(attacker), iFlingHit(attacker));
			}
		}
		else if ((iFlingHitMode(victim) == 0 || iFlingHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vFlingHit(attacker, victim, iFlingChance(victim), iFlingHit(victim));
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
			main ? (g_iFlingAbility[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Enabled", 0)) : (g_iFlingAbility2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Enabled", g_iFlingAbility[iIndex]));
			main ? (g_iFlingAbility[iIndex] = iSetCellLimit(g_iFlingAbility[iIndex], 0, 1)) : (g_iFlingAbility2[iIndex] = iSetCellLimit(g_iFlingAbility2[iIndex], 0, 1));
			main ? (g_iFlingChance[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Chance", 4)) : (g_iFlingChance2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Chance", g_iFlingChance[iIndex]));
			main ? (g_iFlingChance[iIndex] = iSetCellLimit(g_iFlingChance[iIndex], 1, 9999999999)) : (g_iFlingChance2[iIndex] = iSetCellLimit(g_iFlingChance2[iIndex], 1, 9999999999));
			main ? (g_iFlingHit[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit", 0)) : (g_iFlingHit2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit", g_iFlingHit[iIndex]));
			main ? (g_iFlingHit[iIndex] = iSetCellLimit(g_iFlingHit[iIndex], 0, 1)) : (g_iFlingHit2[iIndex] = iSetCellLimit(g_iFlingHit2[iIndex], 0, 1));
			main ? (g_iFlingHitMode[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit Mode", 0)) : (g_iFlingHitMode2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit Mode", g_iFlingHitMode[iIndex]));
			main ? (g_iFlingHitMode[iIndex] = iSetCellLimit(g_iFlingHitMode[iIndex], 0, 2)) : (g_iFlingHitMode2[iIndex] = iSetCellLimit(g_iFlingHitMode2[iIndex], 0, 2));
			main ? (g_flFlingRange[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range", 150.0)) : (g_flFlingRange2[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range", g_flFlingRange[iIndex]));
			main ? (g_flFlingRange[iIndex] = flSetFloatLimit(g_flFlingRange[iIndex], 1.0, 9999999999.0)) : (g_flFlingRange2[iIndex] = flSetFloatLimit(g_flFlingRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iFlingRangeChance[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Range Chance", 16)) : (g_iFlingRangeChance2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Range Chance", g_iFlingRangeChance[iIndex]));
			main ? (g_iFlingRangeChance[iIndex] = iSetCellLimit(g_iFlingRangeChance[iIndex], 1, 9999999999)) : (g_iFlingRangeChance2[iIndex] = iSetCellLimit(g_iFlingRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iFlingAbility = !g_bTankConfig[ST_TankType(client)] ? g_iFlingAbility[ST_TankType(client)] : g_iFlingAbility2[ST_TankType(client)],
			iFlingRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iFlingChance[ST_TankType(client)] : g_iFlingChance2[ST_TankType(client)];
		float flFlingRange = !g_bTankConfig[ST_TankType(client)] ? g_flFlingRange[ST_TankType(client)] : g_flFlingRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flFlingRange)
				{
					vFlingHit(iSurvivor, client, iFlingRangeChance, iFlingAbility);
				}
			}
		}
	}
}

stock void vFlingHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		if (bIsL4D2Game())
		{
			float flSurvivorPos[3], flSurvivorVelocity[3], flTankPos[3], flDistance[3], flRatio[3], flVelocity[3];
			GetClientAbsOrigin(client, flSurvivorPos);
			GetClientAbsOrigin(owner, flTankPos);
			flDistance[0] = (flTankPos[0] - flSurvivorPos[0]);
			flDistance[1] = (flTankPos[1] - flSurvivorPos[1]);
			flDistance[2] = (flTankPos[2] - flSurvivorPos[2]);
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", flSurvivorVelocity);
			flRatio[0] = flDistance[0] / (SquareRoot((flDistance[1] * flDistance[1]) + (flDistance[0] * flDistance[0])));
			flRatio[1] = flDistance[1] / (SquareRoot((flDistance[1] * flDistance[1]) + (flDistance[0] * flDistance[0])));
			flVelocity[0] = (flRatio[0] * -1) * 500.0;
			flVelocity[1] = (flRatio[1] * -1) * 500.0;
			flVelocity[2] = 500.0;
			SDKCall(g_hSDKFlingPlayer, client, flVelocity, 76, owner, 7.0);
		}
		else
		{
			SDKCall(g_hSDKPukePlayer, client, owner, true);
		}
	}
}

stock int iFlingChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iFlingChance[ST_TankType(client)] : g_iFlingChance2[ST_TankType(client)];
}

stock int iFlingHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iFlingHit[ST_TankType(client)] : g_iFlingHit2[ST_TankType(client)];
}

stock int iFlingHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iFlingHitMode[ST_TankType(client)] : g_iFlingHitMode2[ST_TankType(client)];
}