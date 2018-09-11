// Super Tanks++: Rock Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Rock Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bRock[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
char g_sRockRadius[ST_MAXTYPES + 1][11], g_sRockRadius2[ST_MAXTYPES + 1][11];
float g_flRockDuration[ST_MAXTYPES + 1], g_flRockDuration2[ST_MAXTYPES + 1];
int g_iRockAbility[ST_MAXTYPES + 1], g_iRockAbility2[ST_MAXTYPES + 1], g_iRockChance[ST_MAXTYPES + 1], g_iRockChance2[ST_MAXTYPES + 1], g_iRockDamage[ST_MAXTYPES + 1], g_iRockDamage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Rock Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
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

public void OnMapStart()
{
	vReset();
}

public void OnClientPostAdminCheck(int client)
{
	g_bRock[client] = false;
}

public void OnMapEnd()
{
	vReset();
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
	int iRockChance = !g_bTankConfig[ST_TankType(client)] ? g_iRockChance[ST_TankType(client)] : g_iRockChance2[ST_TankType(client)];
	if (iRockAbility(client) == 1 && GetRandomInt(1, iRockChance) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client) && !g_bRock[client])
	{
		int iRock = CreateEntityByName("env_rock_launcher");
		if (!bIsValidEntity(iRock))
		{
			return;
		}
		g_bRock[client] = true;
		float flPos[3];
		GetClientEyePosition(client, flPos);
		flPos[2] += 20.0;
		char sDamage[6];
		int iRockDamage = !g_bTankConfig[ST_TankType(client)] ? g_iRockDamage[ST_TankType(client)] : g_iRockDamage2[ST_TankType(client)];
		IntToString(iRockDamage, sDamage, sizeof(sDamage));
		DispatchSpawn(iRock);
		DispatchKeyValue(iRock, "rockdamageoverride", sDamage);
		DataPack dpRockUpdate = new DataPack();
		CreateDataTimer(0.2, tTimerRockUpdate, dpRockUpdate, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpRockUpdate.WriteCell(EntIndexToEntRef(iRock)), dpRockUpdate.WriteCell(GetClientUserId(client)), dpRockUpdate.WriteFloat(flPos[0]), dpRockUpdate.WriteFloat(flPos[1]), dpRockUpdate.WriteFloat(flPos[2]), dpRockUpdate.WriteFloat(GetEngineTime());
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bRock[iPlayer] = false;
		}
	}
}

stock int iRockAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iRockAbility[ST_TankType(client)] : g_iRockAbility2[ST_TankType(client)];
}

public Action tTimerRockUpdate(Handle timer, DataPack pack)
{
	pack.Reset();
	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bRock[iTank] = false;
		AcceptEntityInput(iRock, "Kill");
		return Plugin_Stop;
	}
	float flPos[3];
	flPos[0] = pack.ReadFloat(), flPos[1] = pack.ReadFloat(), flPos[2] = pack.ReadFloat();
	float flTime = pack.ReadFloat(),
		flRockDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flRockDuration[ST_TankType(iTank)] : g_flRockDuration2[ST_TankType(iTank)];
	if (iRockAbility(iTank) == 0 || (flTime + flRockDuration) < GetEngineTime())
	{
		g_bRock[iTank] = false;
		AcceptEntityInput(iRock, "Kill");
		return Plugin_Stop;
	}
	char sRadius[2][6], sRockRadius[11];
	sRockRadius = !g_bTankConfig[ST_TankType(iTank)] ? g_sRockRadius[ST_TankType(iTank)] : g_sRockRadius2[ST_TankType(iTank)];
	TrimString(sRockRadius);
	ExplodeString(sRockRadius, ",", sRadius, sizeof(sRadius), sizeof(sRadius[]));
	TrimString(sRadius[0]);
	float flMin = (sRadius[0][0] != '\0') ? StringToFloat(sRadius[0]) : -5.0;
	TrimString(sRadius[1]);
	float flMax = (sRadius[1][0] != '\0') ? StringToFloat(sRadius[1]) : 5.0;
	flMin = flSetFloatLimit(flMin, -5.0, 0.0), flMax = flSetFloatLimit(flMax, 0.0, 5.0);
	float flAngles[3], flHitPos[3];
	flAngles[0] = GetRandomFloat(-1.0, 1.0), flAngles[1] = GetRandomFloat(-1.0, 1.0), flAngles[2] = 2.0;
	GetVectorAngles(flAngles, flAngles);
	iGetRayHitPos(flPos, flAngles, flHitPos, iTank, true, 2);
	float flDistance = GetVectorDistance(flPos, flHitPos), flVector[3];
	if (flDistance > 800.0)
	{
		flDistance = 800.0;
	}
	MakeVectorFromPoints(flPos, flHitPos, flVector);
	NormalizeVector(flVector, flVector);
	ScaleVector(flVector, flDistance - 40.0);
	AddVectors(flPos, flVector, flHitPos);
	if (flDistance > 300.0)
	{ 
		float flAngles2[3];
		flAngles2[0] = GetRandomFloat(flMin, flMax), flAngles2[1] = GetRandomFloat(flMin, flMax), flAngles2[2] = -2.0;
		GetVectorAngles(flAngles2, flAngles2);
		TeleportEntity(iRock, flHitPos, flAngles2, NULL_VECTOR);
		AcceptEntityInput(iRock, "LaunchRock");
	}
	return Plugin_Continue;
}