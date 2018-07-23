// Super Tanks++: Respawn Ability
int g_iRespawnAbility[ST_MAXTYPES + 1];
int g_iRespawnAbility2[ST_MAXTYPES + 1];
int g_iRespawnAmount[ST_MAXTYPES + 1];
int g_iRespawnAmount2[ST_MAXTYPES + 1];
int g_iRespawnChance[ST_MAXTYPES + 1];
int g_iRespawnChance2[ST_MAXTYPES + 1];
int g_iRespawnCount[MAXPLAYERS + 1];
int g_iRespawnRandom[ST_MAXTYPES + 1];
int g_iRespawnRandom2[ST_MAXTYPES + 1];

void vRespawnConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iRespawnAbility[index] = keyvalues.GetNum("Respawn Ability/Ability Enabled", 0)) : (g_iRespawnAbility2[index] = keyvalues.GetNum("Respawn Ability/Ability Enabled", g_iRespawnAbility[index]));
	main ? (g_iRespawnAbility[index] = iSetCellLimit(g_iRespawnAbility[index], 0, 1)) : (g_iRespawnAbility2[index] = iSetCellLimit(g_iRespawnAbility2[index], 0, 1));
	main ? (g_iRespawnAmount[index] = keyvalues.GetNum("Respawn Ability/Respawn Amount", 1)) : (g_iRespawnAmount2[index] = keyvalues.GetNum("Respawn Ability/Respawn Amount", g_iRespawnAmount[index]));
	main ? (g_iRespawnAmount[index] = iSetCellLimit(g_iRespawnAmount[index], 1, 9999999999)) : (g_iRespawnAmount2[index] = iSetCellLimit(g_iRespawnAmount2[index], 1, 9999999999));
	main ? (g_iRespawnChance[index] = keyvalues.GetNum("Respawn Ability/Respawn Chance", 4)) : (g_iRespawnChance2[index] = keyvalues.GetNum("Respawn Ability/Respawn Chance", g_iRespawnChance[index]));
	main ? (g_iRespawnChance[index] = iSetCellLimit(g_iRespawnChance[index], 1, 9999999999)) : (g_iRespawnChance2[index] = iSetCellLimit(g_iRespawnChance2[index], 1, 9999999999));
	main ? (g_iRespawnRandom[index] = keyvalues.GetNum("Respawn Ability/Respawn Random", 0)) : (g_iRespawnRandom2[index] = keyvalues.GetNum("Respawn Ability/Respawn Random", g_iRespawnRandom[index]));
	main ? (g_iRespawnRandom[index] = iSetCellLimit(g_iRespawnRandom[index], 0, 1)) : (g_iRespawnRandom2[index] = iSetCellLimit(g_iRespawnRandom2[index], 0, 1));
}

void vRespawnDeath(int client)
{
	int iRespawnAbility = !g_bTankConfig[g_iTankType[client]] ? g_iRespawnAbility[g_iTankType[client]] : g_iRespawnAbility2[g_iTankType[client]];
	int iRespawnChance = !g_bTankConfig[g_iTankType[client]] ? g_iRespawnChance[g_iTankType[client]] : g_iRespawnChance2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iRespawnAbility == 1 && GetRandomInt(1, iRespawnChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client))
	{
		float flPos[3];
		float flAngles[3];
		int iFlags = GetEntProp(client, Prop_Send, "m_fFlags");
		int iSequence = GetEntProp(client, Prop_Data, "m_nSequence");
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPos);
		GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
		DataPack dpDataPack;
		CreateDataTimer(3.0, tTimerRespawn, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
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
	int iRespawnRandom = !g_bTankConfig[g_iTankType[client]] ? g_iRespawnRandom[g_iTankType[client]] : g_iRespawnRandom2[g_iTankType[client]];
	switch (iRespawnRandom)
	{
		case 0: vTank(client, g_iTankType[client]);
		case 1: vCheatCommand(client, "z_spawn", "tank");
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
		ForcePlayerSuicide(iTank);
		int iRespawnAmount = !g_bTankConfig[g_iTankType[iTank]] ? g_iRespawnAmount[g_iTankType[iTank]] : g_iRespawnAmount2[g_iTankType[iTank]];
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