// Super Tanks++: Acid Ability
#define REQUIRE_PLUGIN
#include <super_tanks++>
#undef REQUIRE_PLUGIN
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Acid Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flAcidRange[ST_MAXTYPES + 1], g_flAcidRange2[ST_MAXTYPES + 1];
Handle g_hSDKAcidPlayer, g_hSDKPukePlayer;
int g_iAcidAbility[ST_MAXTYPES + 1], g_iAcidAbility2[ST_MAXTYPES + 1], g_iAcidChance[ST_MAXTYPES + 1], g_iAcidChance2[ST_MAXTYPES + 1], g_iAcidHit[ST_MAXTYPES + 1],
	g_iAcidHit2[ST_MAXTYPES + 1], g_iAcidRangeChance[ST_MAXTYPES + 1], g_iAcidRangeChance2[ST_MAXTYPES + 1], g_iAcidRock[ST_MAXTYPES + 1], g_iAcidRock2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Acid Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	Handle hGameData = LoadGameConfigFile("super_tanks++");
	if (bIsL4D2Game())
	{
		StartPrepSDKCall(SDKCall_Static);
		PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CSpitterProjectile_Create");
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
		g_hSDKAcidPlayer = EndPrepSDKCall();
		if (g_hSDKAcidPlayer == null)
		{
			PrintToServer("%s Your \"CSpitterProjectile_Create\" signature is outdated.", ST_PREFIX);
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
		if (ST_TankAllowed(attacker) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iAcidChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iAcidChance[ST_TankType(attacker)] : g_iAcidChance2[ST_TankType(attacker)],
					iAcidHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iAcidHit[ST_TankType(attacker)] : g_iAcidHit2[ST_TankType(attacker)];
				vAcidHit(victim, attacker, iAcidChance, iAcidHit);
			}
		}
		else if (ST_TankAllowed(victim) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				int iAcidChance = !g_bTankConfig[ST_TankType(victim)] ? g_iAcidChance[ST_TankType(victim)] : g_iAcidChance2[ST_TankType(victim)],
					iAcidHit = !g_bTankConfig[ST_TankType(victim)] ? g_iAcidHit[ST_TankType(victim)] : g_iAcidHit2[ST_TankType(victim)];
				vAcidHit(attacker, victim, iAcidChance, iAcidHit);
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
			main ? (g_iAcidAbility[iIndex] = kvSuperTanks.GetNum("Acid Ability/Ability Enabled", 0)) : (g_iAcidAbility2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Ability Enabled", g_iAcidAbility[iIndex]));
			main ? (g_iAcidAbility[iIndex] = iSetCellLimit(g_iAcidAbility[iIndex], 0, 1)) : (g_iAcidAbility2[iIndex] = iSetCellLimit(g_iAcidAbility2[iIndex], 0, 1));
			main ? (g_iAcidChance[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Chance", 4)) : (g_iAcidChance2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Chance", g_iAcidChance[iIndex]));
			main ? (g_iAcidChance[iIndex] = iSetCellLimit(g_iAcidChance[iIndex], 1, 9999999999)) : (g_iAcidChance2[iIndex] = iSetCellLimit(g_iAcidChance2[iIndex], 1, 9999999999));
			main ? (g_iAcidHit[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Hit", 0)) : (g_iAcidHit2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Hit", g_iAcidHit[iIndex]));
			main ? (g_iAcidHit[iIndex] = iSetCellLimit(g_iAcidHit[iIndex], 0, 1)) : (g_iAcidHit2[iIndex] = iSetCellLimit(g_iAcidHit2[iIndex], 0, 1));
			main ? (g_flAcidRange[iIndex] = kvSuperTanks.GetFloat("Acid Ability/Acid Range", 150.0)) : (g_flAcidRange2[iIndex] = kvSuperTanks.GetFloat("Acid Ability/Acid Range", g_flAcidRange[iIndex]));
			main ? (g_flAcidRange[iIndex] = flSetFloatLimit(g_flAcidRange[iIndex], 1.0, 9999999999.0)) : (g_flAcidRange2[iIndex] = flSetFloatLimit(g_flAcidRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iAcidRangeChance[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Range Chance", 16)) : (g_iAcidRangeChance2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Range Chance", g_iAcidRangeChance[iIndex]));
			main ? (g_iAcidRangeChance[iIndex] = iSetCellLimit(g_iAcidRangeChance[iIndex], 1, 9999999999)) : (g_iAcidRangeChance2[iIndex] = iSetCellLimit(g_iAcidRangeChance2[iIndex], 1, 9999999999));
			main ? (g_iAcidRock[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Rock Break", 0)) : (g_iAcidRock2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Rock Break", g_iAcidRock[iIndex]));
			main ? (g_iAcidRock[iIndex] = iSetCellLimit(g_iAcidRock[iIndex], 0, 1)) : (g_iAcidRock2[iIndex] = iSetCellLimit(g_iAcidRock2[iIndex], 0, 1));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId),
			iAcidAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iAcidAbility[ST_TankType(iTank)] : g_iAcidAbility2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iAcidAbility == 1 && bIsL4D2Game())
		{
			vAcid(iTank, iTank);
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iAcidAbility = !g_bTankConfig[ST_TankType(client)] ? g_iAcidAbility[ST_TankType(client)] : g_iAcidAbility2[ST_TankType(client)],
			iAcidRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iAcidChance[ST_TankType(client)] : g_iAcidChance2[ST_TankType(client)];
		float flAcidRange = !g_bTankConfig[ST_TankType(client)] ? g_flAcidRange[ST_TankType(client)] : g_flAcidRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flAcidRange)
				{
					vAcidHit(iSurvivor, client, iAcidRangeChance, iAcidAbility);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	int iAcidAbility = !g_bTankConfig[ST_TankType(client)] ? g_iAcidAbility[ST_TankType(client)] : g_iAcidAbility2[ST_TankType(client)];
	if (ST_TankAllowed(client) && iAcidAbility == 1 && bIsL4D2Game())
	{
		vAcid(client, client);
	}
}

public void ST_RockBreak(int client, int entity)
{
	int iAcidRock = !g_bTankConfig[ST_TankType(client)] ? g_iAcidRock[ST_TankType(client)] : g_iAcidRock2[ST_TankType(client)];
	if (iAcidRock == 1 && ST_TankAllowed(client) && IsPlayerAlive(client) && bIsL4D2Game())
	{
		float flOrigin[3], flAngles[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flOrigin);
		flOrigin[2] += 40.0;
		SDKCall(g_hSDKAcidPlayer, flOrigin, flAngles, flAngles, flAngles, client, 2.0);
	}
}

void vAcid(int client, int owner)
{
	float flOrigin[3], flAngles[3];
	GetClientAbsOrigin(client, flOrigin);
	GetClientAbsAngles(client, flAngles);
	SDKCall(g_hSDKAcidPlayer, flOrigin, flAngles, flAngles, flAngles, owner, 2.0);
}

void vAcidHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		bIsL4D2Game() ? vAcid(client, owner) : SDKCall(g_hSDKPukePlayer, client, owner, true);
	}
}