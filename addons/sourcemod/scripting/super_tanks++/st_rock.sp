// Super Tanks++: Rock Ability
bool g_bRock[MAXPLAYERS + 1];
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

void vRockConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iRockAbility[index] = keyvalues.GetNum("Rock Ability/Ability Enabled", 0)) : (g_iRockAbility2[index] = keyvalues.GetNum("Rock Ability/Ability Enabled", g_iRockAbility[index]));
	main ? (g_iRockAbility[index] = iSetCellLimit(g_iRockAbility[index], 0, 1)) : (g_iRockAbility2[index] = iSetCellLimit(g_iRockAbility2[index], 0, 1));
	main ? (g_iRockChance[index] = keyvalues.GetNum("Rock Ability/Rock Chance", 4)) : (g_iRockChance2[index] = keyvalues.GetNum("Rock Ability/Rock Chance", g_iRockChance[index]));
	main ? (g_iRockChance[index] = iSetCellLimit(g_iRockChance[index], 1, 9999999999)) : (g_iRockChance2[index] = iSetCellLimit(g_iRockChance2[index], 1, 9999999999));
	main ? (g_iRockDamage[index] = keyvalues.GetNum("Rock Ability/Rock Damage", 5)) : (g_iRockDamage2[index] = keyvalues.GetNum("Rock Ability/Rock Damage", g_iRockDamage[index]));
	main ? (g_iRockDamage[index] = iSetCellLimit(g_iRockDamage[index], 1, 9999999999)) : (g_iRockDamage2[index] = iSetCellLimit(g_iRockDamage2[index], 1, 9999999999));
	main ? (g_flRockDuration[index] = keyvalues.GetFloat("Rock Ability/Rock Duration", 5.0)) : (g_flRockDuration2[index] = keyvalues.GetFloat("Rock Ability/Rock Duration", g_flRockDuration[index]));
	main ? (g_flRockDuration[index] = flSetFloatLimit(g_flRockDuration[index], 0.1, 9999999999.0)) : (g_flRockDuration2[index] = flSetFloatLimit(g_flRockDuration2[index], 0.1, 9999999999.0));
	main ? (keyvalues.GetString("Rock Ability/Rock Radius", g_sRockRadius[index], sizeof(g_sRockRadius[]), "-1.25,1.25")) : (keyvalues.GetString("Rock Ability/Rock Radius", g_sRockRadius2[index], sizeof(g_sRockRadius2[]), g_sRockRadius[index]));
}

void vRockAbility(int client)
{
	int iRockAbility = !g_bTankConfig[g_iTankType[client]] ? g_iRockAbility[g_iTankType[client]] : g_iRockAbility2[g_iTankType[client]];
	int iRockChance = !g_bTankConfig[g_iTankType[client]] ? g_iRockChance[g_iTankType[client]] : g_iRockChance2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iRockAbility == 1 && GetRandomInt(1, iRockChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client) && !g_bRock[client])
	{
		g_bRock[client] = true;
		float flPos[3];
		GetClientEyePosition(client, flPos);
		flPos[2] += 20.0;
		char sDamage[6];
		int iRockDamage = !g_bTankConfig[g_iTankType[client]] ? g_iRockDamage[g_iTankType[client]] : g_iRockDamage2[g_iTankType[client]];
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

void vResetRock(int client)
{
	g_bRock[client] = false;
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
	int iRockAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iRockAbility[g_iTankType[iTank]] : g_iRockAbility2[g_iTankType[iTank]];
	float flRockDuration = !g_bTankConfig[g_iTankType[iTank]] ? g_flRockDuration[g_iTankType[iTank]] : g_flRockDuration2[g_iTankType[iTank]];
	char sRadius[2][6];
	char sRockRadius[12];
	sRockRadius = !g_bTankConfig[g_iTankType[iTank]] ? g_sRockRadius[g_iTankType[iTank]] : g_sRockRadius2[g_iTankType[iTank]];
	TrimString(sRockRadius);
	ExplodeString(sRockRadius, ",", sRadius, sizeof(sRadius), sizeof(sRadius[]));
	TrimString(sRadius[0]);
	float flMin = (sRadius[0][0] != '\0') ? StringToFloat(sRadius[0]) : -5.0;
	TrimString(sRadius[1]);
	float flMax = (sRadius[1][0] != '\0') ? StringToFloat(sRadius[1]) : 5.0;
	flMin = flSetFloatLimit(flMin, -5.0, 0.0);
	flMax = flSetFloatLimit(flMax, 0.0, 5.0);
	if (iRockAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank) || (flTime + flRockDuration) < GetEngineTime())
	{
		g_bRock[iTank] = false;
		AcceptEntityInput(iRock, "Kill");
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		if (bIsValidEntity(iRock))
		{
			float flAngles[3];
			float flHitPos[3];
			flAngles[0] = GetRandomFloat(-1.0, 1.0);
			flAngles[1] = GetRandomFloat(-1.0, 1.0);
			flAngles[2] = 2.0;
			GetVectorAngles(flAngles, flAngles);
			iGetRayHitPos(flPos, flAngles, flHitPos, iTank, 2, true);
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