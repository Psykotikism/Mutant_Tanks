// Super Tanks++: Airborne Ability
bool g_bAirborne[MAXPLAYERS + 1];
float g_flAirborneDuration[ST_MAXTYPES + 1];
float g_flAirborneDuration2[ST_MAXTYPES + 1];
float g_flAirborneSpeed[ST_MAXTYPES + 1];
float g_flAirborneSpeed2[ST_MAXTYPES + 1];
float g_flAirborneTime[MAXPLAYERS + 1];
float g_flAirborneVelocity[MAXPLAYERS + 1][3];
int g_iAirborneAbility[ST_MAXTYPES + 1];
int g_iAirborneAbility2[ST_MAXTYPES + 1];
int g_iAirborneButton[MAXPLAYERS + 1];
int g_iAirborneChance[ST_MAXTYPES + 1];
int g_iAirborneChance2[ST_MAXTYPES + 1];
int g_iAirborneTarget[MAXPLAYERS + 1];

public void AirborneThink(int client)
{
	if (bIsTank(client))
	{
		float flTime = GetEngineTime();
		int iLastButton = GetClientButtons(client);
		vAirborne(client, iLastButton, flTime);
		g_iAirborneButton[client] = iLastButton;
	}
	else
	{
		SDKUnhook(client, SDKHook_PreThink, AirborneThink);
	}
}

public void AirborneTouch(int entity, int other)
{
	vStopAirborne(entity);
}

void vAirborneConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iAirborneAbility[index] = keyvalues.GetNum("Airborne Ability/Ability Enabled", 0)) : (g_iAirborneAbility2[index] = keyvalues.GetNum("Airborne Ability/Ability Enabled", g_iAirborneAbility[index]));
	main ? (g_iAirborneAbility[index] = iSetCellLimit(g_iAirborneAbility[index], 0, 1)) : (g_iAirborneAbility2[index] = iSetCellLimit(g_iAirborneAbility2[index], 0, 1));
	main ? (g_iAirborneChance[index] = keyvalues.GetNum("Airborne Ability/Airborne Chance", 4)) : (g_iAirborneChance2[index] = keyvalues.GetNum("Airborne Ability/Airborne Chance", g_iAirborneChance[index]));
	main ? (g_iAirborneChance[index] = iSetCellLimit(g_iAirborneChance[index], 1, 9999999999)) : (g_iAirborneChance2[index] = iSetCellLimit(g_iAirborneChance2[index], 1, 9999999999));
	main ? (g_flAirborneDuration[index] = keyvalues.GetFloat("Airborne Ability/Airborne Duration", 5.0)) : (g_flAirborneDuration2[index] = keyvalues.GetFloat("Airborne Ability/Airborne Duration", g_flAirborneDuration[index]));
	main ? (g_flAirborneDuration[index] = flSetFloatLimit(g_flAirborneDuration[index], 0.1, 9999999999.0)) : (g_flAirborneDuration2[index] = flSetFloatLimit(g_flAirborneDuration2[index], 0.1, 9999999999.0));
	main ? (g_flAirborneSpeed[index] = keyvalues.GetFloat("Airborne Ability/Airborne Speed", 300.0)) : (g_flAirborneSpeed2[index] = keyvalues.GetFloat("Airborne Ability/Airborne Speed", g_flAirborneSpeed[index]));
	main ? (g_flAirborneSpeed[index] = flSetFloatLimit(g_flAirborneSpeed[index], 100.0, 500.0)) : (g_flAirborneSpeed2[index] = flSetFloatLimit(g_flAirborneSpeed2[index], 100.0, 500.0));
}

void vAirborne(int entity, int button, float time)
{
	float flAirborneSpeed = !g_bTankConfig[g_iTankType[entity]] ? g_flAirborneSpeed[g_iTankType[entity]] : g_flAirborneSpeed2[g_iTankType[entity]];
	float flPos[3];
	float flVelocity[3];
	GetClientAbsOrigin(entity, flPos);
	flPos[2]+=30.0;
	GetEntPropVector(entity, Prop_Data, "m_vecVelocity", flVelocity);
	if (!IsFakeClient(entity) && (button & IN_JUMP) && !(g_iAirborneButton[entity] & IN_JUMP))
	{
		GetClientEyeAngles(entity, flVelocity);
		GetAngleVectors(flVelocity, flVelocity, NULL_VECTOR, NULL_VECTOR);
		flVelocity[2] = 0.0;
		NormalizeVector(flVelocity, flVelocity);
		ScaleVector(flVelocity, 310.0);
		flVelocity[2] = 150.0;
		TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, flVelocity);
		vStopAirborne(entity);
		return;
	}
	vCopyVector(g_flAirborneVelocity[entity], flVelocity);
	if (GetVectorLength(flVelocity) < 10.0)
	{
		return ;
	}
	NormalizeVector(flVelocity, flVelocity);
	int iTarget = g_iAirborneTarget[entity];
	if (g_flAirborneTime[entity] + 1.0 <= time)
	{
		g_flAirborneTime[entity] = time;
		if (IsFakeClient(entity))
		{
			iTarget = iGetRandomTarget(flPos, flVelocity);
		}
		else 
		{
			float flDirection[3];
			GetClientEyeAngles(entity, flDirection);
			GetAngleVectors(flDirection, flDirection, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(flDirection, flDirection);
			iTarget = iGetRandomTarget(flPos, flDirection);
		}
	}
	bIsValidClient(iTarget) ? (g_iAirborneTarget[entity] = iTarget) : (g_iAirborneTarget[entity] = 0);
	iTarget = iGetRandomTarget(flPos, flVelocity);
	float flVelocity2[3];
	float flVector[3];
	flVector[0] = flVector[1] = flVector[2] = 0.0;
	bool bVisible;
	float flAngle[3];
	float flDistance = 1000.0;
	if (iTarget > 0)
	{
		float flPos2[3];
		GetClientEyePosition(iTarget, flPos2);
		flDistance = GetVectorDistance(flPos, flPos2);
		bVisible = bVisiblePosition(flPos, flPos2, entity, 1);
		GetEntPropVector(iTarget, Prop_Data, "m_vecVelocity", flVelocity2);
		AddVectors(flPos2, flVelocity2, flPos2);
		MakeVectorFromPoints(flPos, flPos2, flVector);
	}
	GetVectorAngles(flVelocity, flAngle);
	float flLeft[3];
	float flRight[3];
	float flUp[3];
	float flDown[3];
	float flFront[3];
	float flVector1[3];
	float flVector2[3];
	float flVector3[3];
	float flVector4[3];
	float flVector5[3];
	float flVector6[3];
	float flVector7[3];
	float flVector8[3];
	flFront[0] = flFront[1] = flFront[2] = 0.0;
	float flFactor1 = 0.2;
	float flFactor2 = 0.5;
	float flVector9;
	float flBase = 1500.0;
	if (bVisible)
	{
		flBase = 80.0;
		float flFront2 = flGetDistance(flPos, flAngle, 0.0, 0.0, flFront, entity, 3);
		float flDown2 = flGetDistance(flPos, flAngle, 90.0, 0.0, flDown, entity, 3);
		float flUp2 = flGetDistance(flPos, flAngle, -90.0, 0.0, flUp, entity, 3);
		float flLeft2 = flGetDistance(flPos, flAngle, 0.0, 90.0, flLeft, entity, 3);
		float flRight2 = flGetDistance(flPos, flAngle, 0.0, -90.0, flRight, entity, 3);
		float flDistance2 = flGetDistance(flPos, flAngle, 30.0, 0.0, flVector1, entity, 3);
		float flDistance3 = flGetDistance(flPos, flAngle, 30.0, 45.0, flVector2, entity, 3);
		float flDistance4 = flGetDistance(flPos, flAngle, 0.0, 45.0, flVector3, entity, 3);
		float flDistance5 = flGetDistance(flPos, flAngle, -30.0, 45.0, flVector4, entity, 3);
		float flDistance6 = flGetDistance(flPos, flAngle, -30.0, 0.0, flVector5, entity, 3);
		float flDistance7 = flGetDistance(flPos, flAngle, -30.0, -45.0, flVector6, entity, 3);
		float flDistance8 = flGetDistance(flPos, flAngle, 0.0, -45.0, flVector7, entity, 3);
		float flDistance9 = flGetDistance(flPos, flAngle, 30.0, -45.0, flVector8, entity, 3);
		NormalizeVector(flFront, flFront);
		NormalizeVector(flUp, flUp);
		NormalizeVector(flDown, flDown);
		NormalizeVector(flLeft, flLeft);
		NormalizeVector(flRight, flRight);
		NormalizeVector(flVector, flVector);
		NormalizeVector(flVector1, flVector1);
		NormalizeVector(flVector2, flVector2);
		NormalizeVector(flVector3, flVector3);
		NormalizeVector(flVector4, flVector4);
		NormalizeVector(flVector5, flVector5);
		NormalizeVector(flVector6, flVector6);
		NormalizeVector(flVector7, flVector7);
		NormalizeVector(flVector8, flVector8);
		if (flFront2 > flBase)
		{
			flFront2 = flBase;
		}
		if (flUp2 > flBase)
		{
			flUp2 = flBase;
		}
		if (flDown2 > flBase)
		{
			flDown2 = flBase;
		}
		if (flLeft2 > flBase)
		{
			flLeft2 = flBase;
		}
		if (flRight2 > flBase)
		{
			flRight2 = flBase;
		}
		if (flDistance2 > flBase)
		{
			flDistance2 = flBase;
		}
		if (flDistance3 > flBase)
		{
			flDistance3 = flBase;
		}
		if (flDistance4 > flBase)
		{
			flDistance4 = flBase;
		}
		if (flDistance5 > flBase)
		{
			flDistance5 = flBase;
		}
		if (flDistance6 > flBase)
		{
			flDistance6 = flBase;
		}
		if (flDistance7 > flBase)
		{
			flDistance7 = flBase;
		}
		if (flDistance8 > flBase)
		{
			flDistance8 = flBase;
		}
		if (flDistance9 > flBase)
		{
			flDistance9 = flBase;
		}
		float flBase2 = 10.0;
		if (flFront2 < flBase2)
		{
			flFront2 = flBase2;
		}
		if (flUp2 < flBase2)
		{
			flUp2 = flBase2;
		}
		if (flDown2 < flBase2)
		{
			flDown2 = flBase2;
		}
		if (flLeft2 < flBase2)
		{
			flLeft2 = flBase2;
		}
		if (flRight2 < flBase2)
		{
			flRight2 = flBase2;
		}
		if (flDistance2 < flBase2)
		{
			flDistance2 = flBase2;
		}
		if (flDistance3 < flBase2)
		{
			flDistance3 = flBase2;
		}
		if (flDistance4 < flBase2)
		{
			flDistance4 = flBase2;
		}
		if (flDistance5 < flBase2)
		{
			flDistance5 = flBase2;
		}
		if (flDistance6 < flBase2)
		{
			flDistance6 = flBase2;
		}
		if (flDistance7 < flBase2)
		{
			flDistance7 = flBase2;
		}
		if (flDistance8 < flBase2)
		{
			flDistance8 = flBase2;
		}
		if (flDistance9 < flBase2)
		{
			flDistance9 = flBase2;
		}
		flVector9 =- 1.0 * flFactor1 * (flBase - flFront2) / flBase;
		ScaleVector(flFront, flVector9);
		flVector9 =- 1.0 * flFactor1 * (flBase - flUp2) / flBase;
		ScaleVector(flUp, flVector9);
		flVector9 =- 1.0 * flFactor1 * (flBase - flDown2) / flBase;
		ScaleVector(flDown, flVector9);
		flVector9 =- 1.0 * flFactor1 * (flBase - flLeft2) / flBase;
		ScaleVector(flLeft, flVector9);
		flVector9 =- 1.0 * flFactor1 * (flBase - flRight2) / flBase;
		ScaleVector(flRight, flVector9);
		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance2) / flDistance2;
		ScaleVector(flVector1, flVector9);
		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance3) / flDistance3;
		ScaleVector(flVector2, flVector9);
		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance4) / flDistance4;
		ScaleVector(flVector3, flVector9);
		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance5) / flDistance5;
		ScaleVector(flVector4, flVector9);
		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance6) / flDistance6;
		ScaleVector(flVector5, flVector9);
		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance7) / flDistance7;
		ScaleVector(flVector6, flVector9);
		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance8) / flDistance8;
		ScaleVector(flVector7, flVector9);
		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance9) / flDistance9;
		ScaleVector(flVector8, flVector9);
		if (flDistance >= 500.0)
		{
			flDistance = 500.0;
		}
		flVector9 = 1.0 * flFactor2 * (1000.0 - flDistance) / 500.0;
		ScaleVector(flVector, flVector9);
		AddVectors(flFront, flUp, flFront);
		AddVectors(flFront, flDown, flFront);
		AddVectors(flFront, flLeft, flFront);
		AddVectors(flFront, flRight, flFront);
		AddVectors(flFront, flVector1, flFront);
		AddVectors(flFront, flVector2, flFront);
		AddVectors(flFront, flVector3, flFront);
		AddVectors(flFront, flVector4, flFront);
		AddVectors(flFront, flVector5, flFront);
		AddVectors(flFront, flVector6, flFront);
		AddVectors(flFront, flVector7, flFront);
		AddVectors(flFront, flVector8, flFront);
		AddVectors(flFront, flVector, flFront);
		NormalizeVector(flFront, flFront);
	}
	float flAngle2 = flGetAngle(flFront, flVelocity);
	ScaleVector(flFront, flAngle2);
	float flVelocity3[3];
	AddVectors(flVelocity, flFront, flVelocity3);
	NormalizeVector(flVelocity3, flVelocity3);
	ScaleVector(flVelocity3, flAirborneSpeed);
	SetEntityGravity(entity, 0.01);
	TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, flVelocity3);
	vCopyVector(flVelocity3, g_flAirborneVelocity[entity]);
}

void vAirborneAbility(int client)
{
	int iAirborneAbility = !g_bTankConfig[g_iTankType[client]] ? g_iAirborneAbility[g_iTankType[client]] : g_iAirborneAbility2[g_iTankType[client]];
	int iAirborneChance = !g_bTankConfig[g_iTankType[client]] ? g_iAirborneChance[g_iTankType[client]] : g_iAirborneChance2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iAirborneAbility == 1 && GetRandomInt(1, iAirborneChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client) && !g_bAirborne[client])
	{
		g_bAirborne[client] = true;
		DataPack dpDataPack;
		CreateDataTimer(3.0, tTimerAirborne, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteFloat(GetEngineTime());
	}
}

void vStopAirborne(int client)
{
	if (bIsTank(client) && g_bAirborne[client])
	{
		g_bAirborne[client] = false;
		SDKUnhook(client, SDKHook_PreThink, AirborneThink);
		SDKUnhook(client, SDKHook_StartTouch, AirborneTouch);
		SetEntityGravity(client, 1.0);
	}
}

void vResetAirborne(int client)
{
	g_bAirborne[client] = false;
	g_flAirborneTime[client] = 0.0;
	g_flAirborneVelocity[client][0] = 0.0;
	g_flAirborneVelocity[client][1] = 0.0;
	g_flAirborneVelocity[client][2] = 0.0;
	g_iAirborneButton[client] = 0;
	g_iAirborneTarget[client] = 0;
	SDKUnhook(client, SDKHook_PreThink, AirborneThink);
	SDKUnhook(client, SDKHook_StartTouch, AirborneTouch);
}

public Action tTimerAirborne(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	float flTime = pack.ReadFloat();
	int iAirborneAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iAirborneAbility[g_iTankType[iTank]] : g_iAirborneAbility2[g_iTankType[iTank]];
	float flAirborneDuration = !g_bTankConfig[g_iTankType[iTank]] ? g_flAirborneDuration[g_iTankType[iTank]] : g_flAirborneDuration2[g_iTankType[iTank]];
	if (iAirborneAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank) || (flTime + flAirborneDuration) < GetEngineTime())
	{
		vStopAirborne(iTank);
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		float flPos[3];
		float flHitPos[3];
		float flAngle[3];
		flAngle[0] =- 89.0;
		GetClientEyePosition(iTank, flPos);
		Handle hTrace = TR_TraceRayFilterEx(flPos, flAngle, MASK_ALL, RayType_Infinite, bTraceRayDontHitSelf, iTank);
		bool bNarrow;
		if (TR_DidHit(hTrace))
		{
			TR_GetEndPosition(flHitPos, hTrace); 
			if (GetVectorDistance(flHitPos, flPos) < 100.0)
			{ 
				bNarrow = true;
			}
		}
		delete hTrace;
		if (bNarrow)
		{
			g_bAirborne[iTank] = false;
			return Plugin_Stop; 
		}
		float flAngle2[3];
		GetEntPropVector(iTank, Prop_Send, "m_vecOrigin", flPos);
		flPos[2] += 5.0;
		GetClientEyeAngles(iTank, flAngle2);
		GetAngleVectors(flAngle2, flAngle2, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(flAngle2, flAngle2);
		ScaleVector(flAngle2, 55.0);
		flAngle2[2] = 30.0; 
		TeleportEntity(iTank, flPos, NULL_VECTOR, flAngle2);
		vCopyVector(flAngle2, g_flAirborneVelocity[iTank]);
		g_flAirborneTime[iTank] = GetEngineTime() - 0.0;
		g_iAirborneButton[iTank] = IN_JUMP;
		g_iAirborneTarget[iTank] = 0;
		SDKUnhook(iTank, SDKHook_PreThink, AirborneThink);
		SDKHook(iTank, SDKHook_PreThink, AirborneThink);
		SDKUnhook(iTank, SDKHook_StartTouch, AirborneTouch);
		SDKHook(iTank, SDKHook_StartTouch, AirborneTouch);
	}
	return Plugin_Continue;
}