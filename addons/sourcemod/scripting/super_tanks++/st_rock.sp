// Super Tanks++: Rock Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Rock Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bRock[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
char g_sRockRadius[ST_MAXTYPES + 1][6];
char g_sRockRadius2[ST_MAXTYPES + 1][6];
float g_flRockDuration[ST_MAXTYPES + 1];
float g_flRockDuration2[ST_MAXTYPES + 1];
int g_iRockAbility[ST_MAXTYPES + 1];
int g_iRockAbility2[ST_MAXTYPES + 1];
int g_iRockChance[ST_MAXTYPES + 1];
int g_iRockChance2[ST_MAXTYPES + 1];
int g_iRockDamage[ST_MAXTYPES + 1];
int g_iRockDamage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Rock Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	if (!LibraryExists("super_tanks++"))
	{
		SetFailState("No Super Tanks++ library found.");
	}
}

public void OnMapStart()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bRock[iPlayer] = false;
		}
	}
	if (g_bLateLoad)
	{
		vLateLoad(true);
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bRock[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bRock[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bRock[iPlayer] = false;
		}
	}
}

void vLateLoad(bool late)
{
	if (late)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				SDKHook(iPlayer, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		if (bIsInfected(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (inflictor != -1)
			{
				int iOwner;
				if (HasEntProp(inflictor, Prop_Send, "m_hOwnerEntity"))
				{
					iOwner = GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity");
				}
				int iThrower;
				if (HasEntProp(inflictor, Prop_Data, "m_hThrower"))
				{
					iThrower = GetEntPropEnt(inflictor, Prop_Data, "m_hThrower");
				}
				if ((iOwner > 0 && iOwner == victim) || (iThrower > 0 && iThrower == victim) || ST_TankAllowed(iOwner) || strcmp(sClassname, "tank_rock") == 0)
				{
					damage = 0.0;
					return Plugin_Changed;
				}
			}
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
			main ? (g_iRockAbility[iIndex] = kvSuperTanks.GetNum("Rock Ability/Ability Enabled", 0)) : (g_iRockAbility2[iIndex] = kvSuperTanks.GetNum("Rock Ability/Ability Enabled", g_iRockAbility[iIndex]));
			main ? (g_iRockAbility[iIndex] = iSetCellLimit(g_iRockAbility[iIndex], 0, 1)) : (g_iRockAbility2[iIndex] = iSetCellLimit(g_iRockAbility2[iIndex], 0, 1));
			main ? (g_iRockChance[iIndex] = kvSuperTanks.GetNum("Rock Ability/Rock Chance", 4)) : (g_iRockChance2[iIndex] = kvSuperTanks.GetNum("Rock Ability/Rock Chance", g_iRockChance[iIndex]));
			main ? (g_iRockChance[iIndex] = iSetCellLimit(g_iRockChance[iIndex], 1, 9999999999)) : (g_iRockChance2[iIndex] = iSetCellLimit(g_iRockChance2[iIndex], 1, 9999999999));
			main ? (g_iRockDamage[iIndex] = kvSuperTanks.GetNum("Rock Ability/Rock Damage", 5)) : (g_iRockDamage2[iIndex] = kvSuperTanks.GetNum("Rock Ability/Rock Damage", g_iRockDamage[iIndex]));
			main ? (g_iRockDamage[iIndex] = iSetCellLimit(g_iRockDamage[iIndex], 1, 9999999999)) : (g_iRockDamage2[iIndex] = iSetCellLimit(g_iRockDamage2[iIndex], 1, 9999999999));
			main ? (g_flRockDuration[iIndex] = kvSuperTanks.GetFloat("Rock Ability/Rock Duration", 5.0)) : (g_flRockDuration2[iIndex] = kvSuperTanks.GetFloat("Rock Ability/Rock Duration", g_flRockDuration[iIndex]));
			main ? (g_flRockDuration[iIndex] = flSetFloatLimit(g_flRockDuration[iIndex], 0.1, 9999999999.0)) : (g_flRockDuration2[iIndex] = flSetFloatLimit(g_flRockDuration2[iIndex], 0.1, 9999999999.0));
			main ? (kvSuperTanks.GetString("Rock Ability/Rock Radius", g_sRockRadius[iIndex], sizeof(g_sRockRadius[]), "-1.25,1.25")) : (kvSuperTanks.GetString("Rock Ability/Rock Radius", g_sRockRadius2[iIndex], sizeof(g_sRockRadius2[]), g_sRockRadius[iIndex]));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	int iRockAbility = !g_bTankConfig[ST_TankType(client)] ? g_iRockAbility[ST_TankType(client)] : g_iRockAbility2[ST_TankType(client)];
	int iRockChance = !g_bTankConfig[ST_TankType(client)] ? g_iRockChance[ST_TankType(client)] : g_iRockChance2[ST_TankType(client)];
	if (iRockAbility == 1 && GetRandomInt(1, iRockChance) == 1 && ST_TankAllowed(client) && IsPlayerAlive(client) && !g_bRock[client])
	{
		g_bRock[client] = true;
		float flPos[3];
		GetClientEyePosition(client, flPos);
		flPos[2] += 20.0;
		char sDamage[6];
		int iRockDamage = !g_bTankConfig[ST_TankType(client)] ? g_iRockDamage[ST_TankType(client)] : g_iRockDamage2[ST_TankType(client)];
		IntToString(iRockDamage, sDamage, sizeof(sDamage));
		int iRock = CreateEntityByName("env_rock_launcher");
		if (bIsValidEntity(iRock))
		{
			DispatchSpawn(iRock);
			DispatchKeyValue(iRock, "rockdamageoverride", sDamage);
		}
		DataPack dpDataPack;
		CreateDataTimer(0.2, tTimerRockUpdate, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(iRock);
		dpDataPack.WriteFloat(flPos[0]);
		dpDataPack.WriteFloat(flPos[1]);
		dpDataPack.WriteFloat(flPos[2]);
		dpDataPack.WriteFloat(GetEngineTime());
	}
}

int iGetRayHitPos(float pos[3], float angle[3], float hitpos[3], int entity = 0, bool offset = false)
{
	int iHit = 0;
	Handle hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndPlayer, entity);
	if (TR_DidHit(hTrace))
	{
		TR_GetEndPosition(hitpos, hTrace);
		iHit = TR_GetEntityIndex(hTrace);
	}
	delete hTrace;
	if (offset)
	{
		float flVector[3];
		MakeVectorFromPoints(hitpos, pos, flVector);
		NormalizeVector(flVector, flVector);
		ScaleVector(flVector, 15.0);
		AddVectors(hitpos, flVector, hitpos);
	}
	return iHit;
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

bool bIsValidEntity(int entity)
{
	return entity > 0 && entity <= 2048 && IsValidEntity(entity);
}

public bool bTraceRayDontHitSelfAndPlayer(int entity, int mask, any data)
{
	if (entity == data || bIsValidClient(entity))
	{
		return false;
	}
	return true;
}

public Action tTimerRockUpdate(Handle timer, DataPack pack)
{
	pack.Reset();
	float flPos[3];
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iRock = pack.ReadCell();
	flPos[0] = pack.ReadFloat();
	flPos[1] = pack.ReadFloat();
	flPos[2] = pack.ReadFloat();
	float flTime = pack.ReadFloat();
	int iRockAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iRockAbility[ST_TankType(iTank)] : g_iRockAbility2[ST_TankType(iTank)];
	float flRockDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flRockDuration[ST_TankType(iTank)] : g_flRockDuration2[ST_TankType(iTank)];
	char sRadius[2][6];
	char sRockRadius[12];
	sRockRadius = !g_bTankConfig[ST_TankType(iTank)] ? g_sRockRadius[ST_TankType(iTank)] : g_sRockRadius2[ST_TankType(iTank)];
	TrimString(sRockRadius);
	ExplodeString(sRockRadius, ",", sRadius, sizeof(sRadius), sizeof(sRadius[]));
	TrimString(sRadius[0]);
	float flMin = (sRadius[0][0] != '\0') ? StringToFloat(sRadius[0]) : -5.0;
	TrimString(sRadius[1]);
	float flMax = (sRadius[1][0] != '\0') ? StringToFloat(sRadius[1]) : 5.0;
	flMin = flSetFloatLimit(flMin, -5.0, 0.0);
	flMax = flSetFloatLimit(flMax, 0.0, 5.0);
	if (iRockAbility == 0 || !bIsTank(iTank) || !IsPlayerAlive(iTank) || (flTime + flRockDuration) < GetEngineTime())
	{
		g_bRock[iTank] = false;
		AcceptEntityInput(iRock, "Kill");
		return Plugin_Stop;
	}
	if (ST_TankAllowed(iTank))
	{
		if (bIsValidEntity(iRock))
		{
			float flAngles[3];
			float flHitPos[3];
			flAngles[0] = GetRandomFloat(-1.0, 1.0);
			flAngles[1] = GetRandomFloat(-1.0, 1.0);
			flAngles[2] = 2.0;
			GetVectorAngles(flAngles, flAngles);
			iGetRayHitPos(flPos, flAngles, flHitPos, iTank, true);
			float flDistance = GetVectorDistance(flPos, flHitPos);
			if (flDistance > 800.0)
			{
				flDistance = 800.0;
			}
			float flVector[3];
			MakeVectorFromPoints(flPos, flHitPos, flVector);
			NormalizeVector(flVector, flVector);
			ScaleVector(flVector, flDistance - 40.0);
			AddVectors(flPos, flVector, flHitPos);
			if (flDistance > 300.0)
			{ 
				float flAngles2[3];
				flAngles2[0] = GetRandomFloat(flMin, flMax);
				flAngles2[1] = GetRandomFloat(flMin, flMax);
				flAngles2[2] = -2.0;
				GetVectorAngles(flAngles2, flAngles2);
				TeleportEntity(iRock, flHitPos, flAngles2, NULL_VECTOR);
				AcceptEntityInput(iRock, "LaunchRock");
			}
		}
	}
	return Plugin_Continue;
}