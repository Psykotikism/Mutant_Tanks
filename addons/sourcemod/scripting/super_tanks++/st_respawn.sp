// Super Tanks++: Respawn Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Respawn Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1];
int g_iFinaleTank[ST_MAXTYPES + 1], g_iFinaleTank2[ST_MAXTYPES + 1], g_iRespawnAbility[ST_MAXTYPES + 1], g_iRespawnAbility2[ST_MAXTYPES + 1], g_iRespawnAmount[ST_MAXTYPES + 1], g_iRespawnAmount2[ST_MAXTYPES + 1], g_iRespawnChance[ST_MAXTYPES + 1], g_iRespawnChance2[ST_MAXTYPES + 1], g_iRespawnCount[MAXPLAYERS + 1], g_iRespawnMessage[ST_MAXTYPES + 1], g_iRespawnMessage2[ST_MAXTYPES + 1], g_iRespawnRandom[ST_MAXTYPES + 1], g_iRespawnRandom2[ST_MAXTYPES + 1], g_iTankEnabled[ST_MAXTYPES + 1], g_iTankEnabled2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Respawn Ability only supports Left 4 Dead 1 & 2.");
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

public void OnPluginStart()
{
	LoadTranslations("super_tanks++.phrases");
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
			main ? (g_iTankEnabled[iIndex] = kvSuperTanks.GetNum("General/Tank Enabled", 0)) : (g_iTankEnabled2[iIndex] = kvSuperTanks.GetNum("General/Tank Enabled", g_iTankEnabled[iIndex]));
			main ? (g_iTankEnabled[iIndex] = iSetCellLimit(g_iTankEnabled[iIndex], 0, 1)) : (g_iTankEnabled2[iIndex] = iSetCellLimit(g_iTankEnabled2[iIndex], 0, 1));
			main ? (g_iFinaleTank[iIndex] = kvSuperTanks.GetNum("General/Finale Tank", 0)) : (g_iFinaleTank2[iIndex] = kvSuperTanks.GetNum("General/Finale Tank", g_iFinaleTank[iIndex]));
			main ? (g_iFinaleTank[iIndex] = iSetCellLimit(g_iFinaleTank[iIndex], 0, 1)) : (g_iFinaleTank2[iIndex] = iSetCellLimit(g_iFinaleTank2[iIndex], 0, 1));
			main ? (g_iRespawnAbility[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Ability Enabled", 0)) : (g_iRespawnAbility2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Ability Enabled", g_iRespawnAbility[iIndex]));
			main ? (g_iRespawnAbility[iIndex] = iSetCellLimit(g_iRespawnAbility[iIndex], 0, 1)) : (g_iRespawnAbility2[iIndex] = iSetCellLimit(g_iRespawnAbility2[iIndex], 0, 1));
			main ? (g_iRespawnMessage[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Ability Message", 0)) : (g_iRespawnMessage2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Ability Message", g_iRespawnMessage[iIndex]));
			main ? (g_iRespawnMessage[iIndex] = iSetCellLimit(g_iRespawnMessage[iIndex], 0, 1)) : (g_iRespawnMessage2[iIndex] = iSetCellLimit(g_iRespawnMessage2[iIndex], 0, 1));
			main ? (g_iRespawnAmount[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Amount", 1)) : (g_iRespawnAmount2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Amount", g_iRespawnAmount[iIndex]));
			main ? (g_iRespawnAmount[iIndex] = iSetCellLimit(g_iRespawnAmount[iIndex], 1, 9999999999)) : (g_iRespawnAmount2[iIndex] = iSetCellLimit(g_iRespawnAmount2[iIndex], 1, 9999999999));
			main ? (g_iRespawnChance[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Chance", 4)) : (g_iRespawnChance2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Chance", g_iRespawnChance[iIndex]));
			main ? (g_iRespawnChance[iIndex] = iSetCellLimit(g_iRespawnChance[iIndex], 1, 9999999999)) : (g_iRespawnChance2[iIndex] = iSetCellLimit(g_iRespawnChance2[iIndex], 1, 9999999999));
			main ? (g_iRespawnRandom[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Random", 0)) : (g_iRespawnRandom2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Respawn Random", g_iRespawnRandom[iIndex]));
			main ? (g_iRespawnRandom[iIndex] = iSetCellLimit(g_iRespawnRandom[iIndex], 0, 1)) : (g_iRespawnRandom2[iIndex] = iSetCellLimit(g_iRespawnRandom2[iIndex], 0, 1));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_incapacitated") == 0)
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId),
			iRespawnChance = !g_bTankConfig[ST_TankType(iTank)] ? g_iRespawnChance[ST_TankType(iTank)] : g_iRespawnChance2[ST_TankType(iTank)];
		if (iRespawnAbility(iTank) == 1 && GetRandomInt(1, iRespawnChance) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			float flPos[3], flAngles[3];
			int iFlags = GetEntProp(iTank, Prop_Send, "m_fFlags"), iSequence = GetEntProp(iTank, Prop_Data, "m_nSequence");
			GetEntPropVector(iTank, Prop_Send, "m_vecOrigin", flPos);
			GetEntPropVector(iTank, Prop_Send, "m_angRotation", flAngles);
			DataPack dpRespawn = new DataPack();
			CreateDataTimer(0.4, tTimerRespawn, dpRespawn, TIMER_FLAG_NO_MAPCHANGE);
			dpRespawn.WriteCell(GetClientUserId(iTank)), dpRespawn.WriteCell(iFlags), dpRespawn.WriteCell(iSequence), dpRespawn.WriteFloat(flPos[0]), dpRespawn.WriteFloat(flPos[1]), dpRespawn.WriteFloat(flPos[2]), dpRespawn.WriteFloat(flAngles[0]), dpRespawn.WriteFloat(flAngles[1]), dpRespawn.WriteFloat(flAngles[2]);
		}
	}
}

stock int iRespawnAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iRespawnAbility[ST_TankType(client)] : g_iRespawnAbility2[ST_TankType(client)];
}

public Action tTimerRespawn(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !bIsPlayerIncapacitated(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_iRespawnCount[iTank] = 0;
		return Plugin_Stop;
	}
	if (iRespawnAbility(iTank) == 0)
	{
		g_iRespawnCount[iTank] = 0;
		return Plugin_Stop;
	}
	int iFlags = pack.ReadCell(), iSequence = pack.ReadCell();
	float flPos[3], flAngles[3];
	flPos[0] = pack.ReadFloat(), flPos[1] = pack.ReadFloat(), flPos[2] = pack.ReadFloat(), flAngles[0] = pack.ReadFloat(), flAngles[1] = pack.ReadFloat(), flAngles[2] = pack.ReadFloat();
	int iRespawnAmount = !g_bTankConfig[ST_TankType(iTank)] ? g_iRespawnAmount[ST_TankType(iTank)] : g_iRespawnAmount2[ST_TankType(iTank)],
		iRespawnMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_iRespawnMessage[ST_TankType(iTank)] : g_iRespawnMessage2[ST_TankType(iTank)],
		iRespawnRandom = !g_bTankConfig[ST_TankType(iTank)] ? g_iRespawnRandom[ST_TankType(iTank)] : g_iRespawnRandom2[ST_TankType(iTank)];
	if (g_iRespawnCount[iTank] < iRespawnAmount)
	{
		g_iRespawnCount[iTank]++;
		bool bExists[MAXPLAYERS + 1];
		for (int iRespawn = 1; iRespawn <= MaxClients; iRespawn++)
		{
			bExists[iRespawn] = false;
			if (ST_TankAllowed(iRespawn) && ST_CloneAllowed(iRespawn, g_bCloneInstalled) && IsPlayerAlive(iRespawn))
			{
				bExists[iRespawn] = true;
			}
		}
		switch (iRespawnRandom)
		{
			case 0: ST_SpawnTank(iTank, ST_TankType(iTank));
			case 1:
			{
				int iTypeCount, iTankTypes[ST_MAXTYPES + 1];
				for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
				{
					int iTankEnabled = !g_bTankConfig[iIndex] ? g_iTankEnabled[iIndex] : g_iTankEnabled2[iIndex],
						iFinaleTank = !g_bTankConfig[iIndex] ? g_iFinaleTank[iIndex] : g_iFinaleTank2[iIndex];
					if (iTankEnabled == 0 || (iFinaleTank == 1 && (!bIsFinaleMap() || ST_TankWave() <= 0)) || ST_TankType(iTank) == iIndex)
					{
						continue;
					}
					iTankTypes[iTypeCount + 1] = iIndex;
					iTypeCount++;
				}
				if (iTypeCount > 0)
				{
					int iChosen = iTankTypes[GetRandomInt(1, iTypeCount)];
					ST_SpawnTank(iTank, iChosen);
				}
			}
		}
		int iNewTank;
		for (int iRespawn = 1; iRespawn <= MaxClients; iRespawn++)
		{
			if (ST_TankAllowed(iRespawn) && ST_CloneAllowed(iRespawn, g_bCloneInstalled) && IsPlayerAlive(iRespawn) && !bExists[iRespawn])
			{
				iNewTank = iRespawn;
				g_iRespawnCount[iNewTank] = g_iRespawnCount[iTank];
				break;
			}
		}
		if (iNewTank > 0)
		{
			SetEntProp(iNewTank, Prop_Send, "m_fFlags", iFlags);
			SetEntProp(iNewTank, Prop_Data, "m_nSequence", iSequence);
			TeleportEntity(iNewTank, flPos, flAngles, NULL_VECTOR);
			if (iRespawnMessage == 1)
			{
				char sTankName[MAX_NAME_LENGTH + 1];
				ST_TankName(iTank, sTankName);
				PrintToChatAll("%s %t", ST_PREFIX2, "Respawn", sTankName);
			}
		}
	}
	else
	{
		g_iRespawnCount[iTank] = 0;
	}
	return Plugin_Continue;
}