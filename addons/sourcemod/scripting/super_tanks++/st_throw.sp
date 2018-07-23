// Super Tanks++: Throw Ability
char g_sThrowCarOptions[ST_MAXTYPES + 1][7];
char g_sThrowCarOptions2[ST_MAXTYPES + 1][7];
char g_sThrowInfectedOptions[ST_MAXTYPES + 1][15];
char g_sThrowInfectedOptions2[ST_MAXTYPES + 1][15];
int g_iThrowAbility[ST_MAXTYPES + 1];
int g_iThrowAbility2[ST_MAXTYPES + 1];

void vThrowConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iThrowAbility[index] = keyvalues.GetNum("Throw Ability/Ability Enabled", 0)) : (g_iThrowAbility2[index] = keyvalues.GetNum("Throw Ability/Ability Enabled", g_iThrowAbility[index]));
	main ? (g_iThrowAbility[index] = iSetCellLimit(g_iThrowAbility[index], 0, 3)) : (g_iThrowAbility2[index] = iSetCellLimit(g_iThrowAbility2[index], 0, 3));
	main ? (keyvalues.GetString("Throw Ability/Throw Car Options", g_sThrowCarOptions[index], sizeof(g_sThrowCarOptions[]), "123")) : (keyvalues.GetString("Throw Ability/Throw Car Options", g_sThrowCarOptions2[index], sizeof(g_sThrowCarOptions2[]), g_sThrowCarOptions[index]));
	main ? (keyvalues.GetString("Throw Ability/Throw Infected Options", g_sThrowInfectedOptions[index], sizeof(g_sThrowInfectedOptions[]), "1234567")) : (keyvalues.GetString("Throw Ability/Throw Infected Options", g_sThrowInfectedOptions2[index], sizeof(g_sThrowInfectedOptions2[]), g_sThrowInfectedOptions[index]));
}

void vThrow(int client, int entity)
{
	int iThrowAbility = !g_bTankConfig[g_iTankType[client]] ? g_iThrowAbility[g_iTankType[client]] : g_iThrowAbility2[g_iTankType[client]];
	if (iThrowAbility == 1)
	{
		DataPack dpDataPack;
		CreateDataTimer(0.1, tTimerCarThrow, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(EntIndexToEntRef(entity));
	}
	if (iThrowAbility == 2)
	{
		DataPack dpDataPack;
		CreateDataTimer(0.1, tTimerInfectedThrow, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(EntIndexToEntRef(entity));
	}
	if (iThrowAbility == 3)
	{
		DataPack dpDataPack;
		CreateDataTimer(0.1, tTimerSelfThrow, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(EntIndexToEntRef(entity));
	}
}

public Action tTimerCarThrow(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iRock = EntRefToEntIndex(pack.ReadCell());
	int iThrowAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iThrowAbility[g_iTankType[iTank]] : g_iThrowAbility2[g_iTankType[iTank]];
	if (iThrowAbility == 0 || iThrowAbility != 1 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank) || iRock == INVALID_ENT_REFERENCE)
	{
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		float flVelocity[3];
		if (bIsValidEntity(iRock))
		{
			GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);
			float flVector = GetVectorLength(flVelocity);
			if (flVector > 500.0)
			{
				int iCar = CreateEntityByName("prop_physics");
				if (bIsValidEntity(iCar))
				{
					char sNumbers = !g_bTankConfig[g_iTankType[iTank]] ? g_sThrowCarOptions[g_iTankType[iTank]][GetRandomInt(0, strlen(g_sThrowCarOptions[g_iTankType[iTank]]) - 1)] : g_sThrowCarOptions2[g_iTankType[iTank]][GetRandomInt(0, strlen(g_sThrowCarOptions2[g_iTankType[iTank]]) - 1)];
					switch (sNumbers)
					{
						case '1': SetEntityModel(iCar, MODEL_CAR);
						case '2': SetEntityModel(iCar, MODEL_CAR2);
						case '3': SetEntityModel(iCar, MODEL_CAR3);
						default: SetEntityModel(iCar, MODEL_CAR);
					}
					int iRed = GetRandomInt(0, 255);
					int iGreen = GetRandomInt(0, 255);
					int iBlue = GetRandomInt(0, 255);
					SetEntityRenderColor(iCar, iRed, iGreen, iBlue, 255);
					float flPos[3];
					GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
					AcceptEntityInput(iRock, "Kill");
					NormalizeVector(flVelocity, flVelocity);
					float flSpeed = g_cvSTFindConVar[5].FloatValue;
					ScaleVector(flVelocity, flSpeed * 1.4);
					DispatchSpawn(iCar);
					TeleportEntity(iCar, flPos, NULL_VECTOR, flVelocity);
					iCar = EntIndexToEntRef(iCar);
					vDeleteEntity(iCar, 10.0);
				}
				return Plugin_Stop;
			}
		}
	}
	return Plugin_Continue;
}

public Action tTimerInfectedThrow(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iRock = EntRefToEntIndex(pack.ReadCell());
	int iThrowAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iThrowAbility[g_iTankType[iTank]] : g_iThrowAbility2[g_iTankType[iTank]];
	if (iThrowAbility == 0 || iThrowAbility != 2 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank) || iRock == INVALID_ENT_REFERENCE)
	{
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		float flVelocity[3];
		if (bIsValidEntity(iRock))
		{
			GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);
			float flVector = GetVectorLength(flVelocity);
			if (flVector > 500.0)
			{
				int iInfected = CreateFakeClient("Infected");
				if (iInfected > 0)
				{
					char sNumbers = !g_bTankConfig[g_iTankType[iTank]] ? g_sThrowInfectedOptions[g_iTankType[iTank]][GetRandomInt(0, strlen(g_sThrowInfectedOptions[g_iTankType[iTank]]) - 1)] : g_sThrowInfectedOptions2[g_iTankType[iTank]][GetRandomInt(0, strlen(g_sThrowInfectedOptions2[g_iTankType[iTank]]) - 1)];
					switch (sNumbers)
					{
						case '1': vSpawnInfected(iInfected, "smoker");
						case '2': vSpawnInfected(iInfected, "boomer");
						case '3': vSpawnInfected(iInfected, "hunter");
						case '4': bIsL4D2Game() ? vSpawnInfected(iInfected, "spitter") : vSpawnInfected(iInfected, "boomer");
						case '5': bIsL4D2Game() ? vSpawnInfected(iInfected, "jockey") : vSpawnInfected(iInfected, "hunter");
						case '6': bIsL4D2Game() ? vSpawnInfected(iInfected, "charger") : vSpawnInfected(iInfected, "smoker");
						case '7': vSpawnInfected(iInfected, "tank");
						default: vSpawnInfected(iInfected, "hunter");
					}
					float flPos[3];
					GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
					AcceptEntityInput(iRock, "Kill");
					NormalizeVector(flVelocity, flVelocity);
					float flSpeed = g_cvSTFindConVar[5].FloatValue;
					ScaleVector(flVelocity, flSpeed * 1.4);
					TeleportEntity(iInfected, flPos, NULL_VECTOR, flVelocity);
				}
				return Plugin_Stop;
			}
		}
	}
	return Plugin_Continue;
}

public Action tTimerSelfThrow(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iRock = EntRefToEntIndex(pack.ReadCell());
	int iThrowAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iThrowAbility[g_iTankType[iTank]] : g_iThrowAbility2[g_iTankType[iTank]];
	if (iThrowAbility == 0 || iThrowAbility != 3 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank) || iRock == INVALID_ENT_REFERENCE)
	{
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		float flVelocity[3];
		if (bIsValidEntity(iRock))
		{
			GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);
			float flVector = GetVectorLength(flVelocity);
			if (flVector > 500.0)
			{
				float flPos[3];
				GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
				AcceptEntityInput(iRock, "Kill");
				NormalizeVector(flVelocity, flVelocity);
				float flSpeed = g_cvSTFindConVar[5].FloatValue;
				ScaleVector(flVelocity, flSpeed * 1.4);
				TeleportEntity(iTank, flPos, NULL_VECTOR, flVelocity);
				return Plugin_Stop;
			}
		}
	}
	return Plugin_Continue;
}