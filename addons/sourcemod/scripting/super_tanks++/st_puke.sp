// Super Tanks++: Puke Ability
#define REQUIRE_PLUGIN
#include <super_tanks++>
#undef REQUIRE_PLUGIN
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Puke Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flPukeRange[ST_MAXTYPES + 1], g_flPukeRange2[ST_MAXTYPES + 1];
Handle g_hSDKPukePlayer;
int g_iPukeAbility[ST_MAXTYPES + 1], g_iPukeAbility2[ST_MAXTYPES + 1],
	g_iPukeChance[ST_MAXTYPES + 1], g_iPukeChance2[ST_MAXTYPES + 1], g_iPukeHit[ST_MAXTYPES + 1],
	g_iPukeHit2[ST_MAXTYPES + 1], g_iPukeRangeChance[ST_MAXTYPES + 1],
	g_iPukeRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Puke Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
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
		if (ST_TankAllowed(attacker) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iPukeChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iPukeChance[ST_TankType(attacker)] : g_iPukeChance2[ST_TankType(attacker)];
				int iPukeHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iPukeHit[ST_TankType(attacker)] : g_iPukeHit2[ST_TankType(attacker)];
				vPukeHit(victim, attacker, iPukeChance, iPukeHit);
			}
		}
		else if (ST_TankAllowed(victim) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				int iPukeChance = !g_bTankConfig[ST_TankType(victim)] ? g_iPukeChance[ST_TankType(victim)] : g_iPukeChance2[ST_TankType(victim)];
				int iPukeHit = !g_bTankConfig[ST_TankType(victim)] ? g_iPukeHit[ST_TankType(victim)] : g_iPukeHit2[ST_TankType(victim)];
				vPukeHit(attacker, victim, iPukeChance, iPukeHit);
			}
		}
	}
}

public void ST_Configs(char[] savepath, bool main)
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
			main ? (g_iPukeAbility[iIndex] = iSetCellLimit(g_iPukeAbility[iIndex], 0, 1)) : (g_iPukeAbility2[iIndex] = iSetCellLimit(g_iPukeAbility2[iIndex], 0, 1));
			main ? (g_iPukeChance[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Chance", 4)) : (g_iPukeChance2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Chance", g_iPukeChance[iIndex]));
			main ? (g_iPukeChance[iIndex] = iSetCellLimit(g_iPukeChance[iIndex], 1, 9999999999)) : (g_iPukeChance2[iIndex] = iSetCellLimit(g_iPukeChance2[iIndex], 1, 9999999999));
			main ? (g_iPukeHit[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Hit", 0)) : (g_iPukeHit2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Hit", g_iPukeHit[iIndex]));
			main ? (g_iPukeHit[iIndex] = iSetCellLimit(g_iPukeHit[iIndex], 0, 1)) : (g_iPukeHit2[iIndex] = iSetCellLimit(g_iPukeHit2[iIndex], 0, 1));
			main ? (g_flPukeRange[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Range", 150.0)) : (g_flPukeRange2[iIndex] = kvSuperTanks.GetFloat("Puke Ability/Puke Range", g_flPukeRange[iIndex]));
			main ? (g_flPukeRange[iIndex] = flSetFloatLimit(g_flPukeRange[iIndex], 1.0, 9999999999.0)) : (g_flPukeRange2[iIndex] = flSetFloatLimit(g_flPukeRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iPukeRangeChance[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Range Chance", 16)) : (g_iPukeRangeChance2[iIndex] = kvSuperTanks.GetNum("Puke Ability/Puke Range Chance", g_iPukeRangeChance[iIndex]));
			main ? (g_iPukeRangeChance[iIndex] = iSetCellLimit(g_iPukeRangeChance[iIndex], 1, 9999999999)) : (g_iPukeRangeChance2[iIndex] = iSetCellLimit(g_iPukeRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iPukeAbility = !g_bTankConfig[ST_TankType(client)] ? g_iPukeAbility[ST_TankType(client)] : g_iPukeAbility2[ST_TankType(client)];
		int iPukeRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iPukeChance[ST_TankType(client)] : g_iPukeChance2[ST_TankType(client)];
		float flPukeRange = !g_bTankConfig[ST_TankType(client)] ? g_flPukeRange[ST_TankType(client)] : g_flPukeRange2[ST_TankType(client)];
		float flTankPos[3];
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
					vPukeHit(iSurvivor, client, iPukeRangeChance, iPukeAbility);
				}
			}
		}
	}
}

void vPukeHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		SDKCall(g_hSDKPukePlayer, client, owner, true);
	}
}