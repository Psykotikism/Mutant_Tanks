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

public void OnConfigsExecuted()
{
	char sMapName[128];
	GetCurrentMap(sMapName, sizeof(sMapName));
	if (IsMapValid(sMapName))
	{
		vIsPluginAllowed();
	}
}

void vIsPluginAllowed()
{
	ST_PluginEnabled() ? vHookEvent(true) : vHookEvent(false);
}

void vHookEvent(bool hook)
{
	static bool hooked;
	if (hook && !hooked)
	{
		HookEvent("player_incapacitated", eEventPlayerIncapacitated);
		hooked = true;
	}
	else if (!hook && hooked)
	{
		UnhookEvent("player_incapacitated", eEventPlayerIncapacitated);
		hooked = false;
	}
}

public Action eEventPlayerIncapacitated(Event event, const char[] name, bool dontBroadcast)
{
	int iUserId = event.GetInt("userid");
	int iTank = GetClientOfUserId(iUserId);
	int iRespawnAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iRespawnAbility[ST_TankType(iTank)] : g_iRespawnAbility2[ST_TankType(iTank)];
	int iRespawnChance = !g_bTankConfig[ST_TankType(iTank)] ? g_iRespawnChance[ST_TankType(iTank)] : g_iRespawnChance2[ST_TankType(iTank)];
	if (iRespawnAbility == 1 && GetRandomInt(1, iRespawnChance) == 1 && bIsTank(iTank))
	{
		float flPos[3];
		float flAngles[3];
		int iFlags = GetEntProp(iTank, Prop_Send, "m_fFlags");
		int iSequence = GetEntProp(iTank, Prop_Data, "m_nSequence");
		GetEntPropVector(iTank, Prop_Send, "m_vecOrigin", flPos);
		GetEntPropVector(iTank, Prop_Send, "m_angRotation", flAngles);
		DataPack dpDataPack;
		CreateDataTimer(3.0, tTimerRespawn, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(iUserId);
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