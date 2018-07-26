// Super Tanks++: Respawn Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Respawn Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bTankConfig[ST_MAXTYPES + 1];
int g_iRespawnAbility[ST_MAXTYPES + 1];
int g_iRespawnAbility2[ST_MAXTYPES + 1];
int g_iRespawnAmount[ST_MAXTYPES + 1];
int g_iRespawnAmount2[ST_MAXTYPES + 1];
int g_iRespawnChance[ST_MAXTYPES + 1];
int g_iRespawnChance2[ST_MAXTYPES + 1];
int g_iRespawnCount[MAXPLAYERS + 1];
int g_iRespawnRandom[ST_MAXTYPES + 1];
int g_iRespawnRandom2[ST_MAXTYPES + 1];

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
	if (!LibraryExists("super_tanks++"))
	{
		SetFailState("No Super Tanks++ library found.");
	}
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
			main ? (g_iRespawnAbility[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Ability Enabled", 0)) : (g_iRespawnAbility2[iIndex] = kvSuperTanks.GetNum("Respawn Ability/Ability Enabled", g_iRespawnAbility[iIndex]));
			main ? (g_iRespawnAbility[iIndex] = iSetCellLimit(g_iRespawnAbility[iIndex], 0, 1)) : (g_iRespawnAbility2[iIndex] = iSetCellLimit(g_iRespawnAbility2[iIndex], 0, 1));
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

public void ST_Incap(int client)
{
	int iRespawnAbility = !g_bTankConfig[ST_TankType(client)] ? g_iRespawnAbility[ST_TankType(client)] : g_iRespawnAbility2[ST_TankType(client)];
	int iRespawnChance = !g_bTankConfig[ST_TankType(client)] ? g_iRespawnChance[ST_TankType(client)] : g_iRespawnChance2[ST_TankType(client)];
	if (iRespawnAbility == 1 && GetRandomInt(1, iRespawnChance) == 1 && bIsTank(client))
	{
		float flPos[3];
		float flAngles[3];
		int iFlags = GetEntProp(client, Prop_Send, "m_fFlags");
		int iSequence = GetEntProp(client, Prop_Data, "m_nSequence");
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPos);
		GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
		DataPack dpDataPack;
		CreateDataTimer(2.9, tTimerRespawn, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(iFlags);
		dpDataPack.WriteCell(iSequence);
		dpDataPack.WriteFloat(flPos[0]);
		dpDataPack.WriteFloat(flPos[1]);
		dpDataPack.WriteFloat(flPos[2]);
		dpDataPack.WriteFloat(flAngles[0]);
		dpDataPack.WriteFloat(flAngles[1]);
		dpDataPack.WriteFloat(flAngles[2]);
	}
}

int iRespawn(int client, int count)
{
	int iTank;
	bool bExists[MAXPLAYERS+1];
	for (int iNewTank = 1; iNewTank <= MaxClients; iNewTank++)
	{
		bExists[iNewTank] = false;
		if (bIsTank(iNewTank))
		{
			bExists[iNewTank] = true;
		}
	}
	int iRespawnRandom = !g_bTankConfig[ST_TankType(client)] ? g_iRespawnRandom[ST_TankType(client)] : g_iRespawnRandom2[ST_TankType(client)];
	switch (iRespawnRandom)
	{
		case 0: ST_SpawnTank(client, ST_TankType(client));
		case 1:
		{
			char sCommand[32] = "z_spawn";
			int iCmdFlags = GetCommandFlags(sCommand);
			SetCommandFlags(sCommand, iCmdFlags & ~FCVAR_CHEAT);
			FakeClientCommand(client, "%s tank", sCommand);
			SetCommandFlags(sCommand, iCmdFlags|FCVAR_CHEAT);
		}
	}
	for (int iNewTank = 1; iNewTank <= MaxClients; iNewTank++)
	{
		if (bIsTank(iNewTank))
		{
			if (!bExists[iNewTank])
			{
				iTank = iNewTank;
				g_iRespawnCount[iTank] = count;
				break;
			}
		}
	}
	return iTank;
}

bool bIsPlayerIncapacitated(int client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1))
	{
		return true;
	}
	return false;
}

public Action tTimerRespawn(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iFlags = pack.ReadCell();
	int iSequence = pack.ReadCell();
	float flPos[3];
	float flAngles[3];
	flPos[0] = pack.ReadFloat();
	flPos[1] = pack.ReadFloat();
	flPos[2] = pack.ReadFloat();
	flAngles[0] = pack.ReadFloat();
	flAngles[1] = pack.ReadFloat();
	flAngles[2] = pack.ReadFloat();
	if (iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_iRespawnCount[iTank] = 0;
		return Plugin_Stop;
	}
	if (bIsTank(iTank) && bIsPlayerIncapacitated(iTank))
	{
		int iRespawnAmount = !g_bTankConfig[ST_TankType(iTank)] ? g_iRespawnAmount[ST_TankType(iTank)] : g_iRespawnAmount2[ST_TankType(iTank)];
		if (g_iRespawnCount[iTank] < iRespawnAmount)
		{
			g_iRespawnCount[iTank]++;
			int iNewTank = iRespawn(iTank, g_iRespawnCount[iTank]);
			if (bIsTank(iNewTank))
			{
				SetEntProp(iNewTank, Prop_Send, "m_fFlags", iFlags);
				SetEntProp(iNewTank, Prop_Data, "m_nSequence", iSequence);
				TeleportEntity(iNewTank, flPos, flAngles, NULL_VECTOR);
			}
		}
		else
		{
			g_iRespawnCount[iTank] = 0;
		}
	}
	return Plugin_Continue;
}