// Super Tanks++: Track Ability
float g_flTrackSpeed[ST_MAXTYPES + 1];
float g_flTrackSpeed2[ST_MAXTYPES + 1];
int g_iTrackAbility[ST_MAXTYPES + 1];
int g_iTrackAbility2[ST_MAXTYPES + 1];
int g_iTrackChance[ST_MAXTYPES + 1];
int g_iTrackChance2[ST_MAXTYPES + 1];
int g_iTrackMode[ST_MAXTYPES + 1];
int g_iTrackMode2[ST_MAXTYPES + 1];

public void TrackThink(int entity)
{
	bIsValidEntity(entity) ? vTrackAbility(entity) : SDKUnhook(entity, SDKHook_Think, TrackThink);
}

void vTrackConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iTrackAbility[index] = keyvalues.GetNum("Track Ability/Ability Enabled", 0)) : (g_iTrackAbility2[index] = keyvalues.GetNum("Track Ability/Ability Enabled", g_iTrackAbility[index]));
	main ? (g_iTrackAbility[index] = iSetCellLimit(g_iTrackAbility[index], 0, 1)) : (g_iTrackAbility2[index] = iSetCellLimit(g_iTrackAbility2[index], 0, 1));
	main ? (g_iTrackChance[index] = keyvalues.GetNum("Track Ability/Track Chance", 4)) : (g_iTrackChance2[index] = keyvalues.GetNum("Track Ability/Track Chance", g_iTrackChance[index]));
	main ? (g_iTrackChance[index] = iSetCellLimit(g_iTrackChance[index], 1, 9999999999)) : (g_iTrackChance2[index] = iSetCellLimit(g_iTrackChance2[index], 1, 9999999999));
	main ? (g_iTrackMode[index] = keyvalues.GetNum("Track Ability/Track Mode", 1)) : (g_iTrackMode2[index] = keyvalues.GetNum("Track Ability/Track Mode", g_iTrackMode[index]));
	main ? (g_iTrackMode[index] = iSetCellLimit(g_iTrackMode[index], 0, 1)) : (g_iTrackMode2[index] = iSetCellLimit(g_iTrackMode2[index], 0, 1));
	main ? (g_flTrackSpeed[index] = keyvalues.GetFloat("Track Ability/Track Speed", 300.0)) : (g_flTrackSpeed2[index] = keyvalues.GetFloat("Track Ability/Track Speed", g_flTrackSpeed[index]));
	main ? (g_flTrackSpeed[index] = flSetFloatLimit(g_flTrackSpeed[index], 100.0, 500.0)) : (g_flTrackSpeed2[index] = flSetFloatLimit(g_flTrackSpeed2[index], 100.0, 500.0));
}

void vTrack(int client, int entity)
{
	int iTrackAbility = !g_bTankConfig[g_iTankType[client]] ? g_iTrackAbility[g_iTankType[client]] : g_iTrackAbility2[g_iTankType[client]];
	int iTrackChance = !g_bTankConfig[g_iTankType[client]] ? g_iTrackChance[g_iTankType[client]] : g_iTrackChance2[g_iTankType[client]];
	if (iTrackAbility == 1 && GetRandomInt(1, iTrackChance) == 1)
	{
		DataPack dpDataPack;
		CreateDataTimer(0.5, tTimerTrack, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(EntIndexToEntRef(entity));
	}
}

void vTrackAbility(int entity)
{
	int client = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
	int iTrackMode = !g_bTankConfig[g_iTankType[client]] ? g_iTrackMode[g_iTankType[client]] : g_iTrackMode2[g_iTankType[client]];
	float flTrackSpeed = !g_bTankConfig[g_iTankType[client]] ? g_flTrackSpeed[g_iTankType[client]] : g_flTrackSpeed2[g_iTankType[client]];
	switch (iTrackMode)
	{
		case 0:
		{
			float flPos[3];
			float flVelocity[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPos);
			GetEntPropVector(entity, Prop_Data, "m_vecVelocity", flVelocity);
			float flVector = GetVectorLength(flVelocity);
			if (flVector < 100.0)
			{
				return;
			}
			NormalizeVector(flVelocity, flVelocity);
			int iTarget = iGetRandomTarget(flPos, flVelocity);
			if (iTarget > 0)
			{
				float flPos2[3];
				float flVelocity2[3];
				GetClientEyePosition(iTarget, flPos2);
				GetEntPropVector(iTarget, Prop_Data, "m_vecVelocity", flVelocity2);
				bool bVisible = bVisiblePosition(flPos, flPos2, entity, 2);
				float flDistance = GetVectorDistance(flPos, flPos2);
				if (!bVisible || flDistance > 500.0)
				{
					return;
				}
				SetEntityGravity(entity, 0.01);
				float flDirection[3];
				float flVelocity3[3];
				SubtractVectors(flPos2, flPos, flDirection);
				NormalizeVector(flDirection, flDirection);
				ScaleVector(flDirection, 0.5);
				AddVectors(flVelocity, flDirection, flVelocity3);
				NormalizeVector(flVelocity3, flVelocity3);
				ScaleVector(flVelocity3, flVector);
				TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, flVelocity3);
			}
		}
		case 1:
		{
			float flPos[3];
			float flVelocity[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPos);
			GetEntPropVector(entity, Prop_Data, "m_vecVelocity", flVelocity);
			if (GetVectorLength(flVelocity) < 50.0)
			{
				return;
			}
			NormalizeVector(flVelocity, flVelocity);
			int iTarget = iGetRandomTarget(flPos, flVelocity);
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
			ScaleVector(flVelocity3, flTrackSpeed);
			SetEntityGravity(entity, 0.01);
			TeleportEntity(entity, NULL_VECTOR, NULL_VECTOR, flVelocity3);
			char sSet[2][16];
			char sTankColors[28];
			sTankColors = !g_bTankConfig[g_iTankType[client]] ? g_sTankColors[g_iTankType[client]] : g_sTankColors2[g_iTankType[client]];
			TrimString(sTankColors);
			ExplodeString(sTankColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
			char sGlow[3][4];
			ExplodeString(sSet[1], ",", sGlow, sizeof(sGlow), sizeof(sGlow[]));
			TrimString(sGlow[0]);
			int iRed2 = (sGlow[0][0] != '\0') ? StringToInt(sGlow[0]) : 255;
			TrimString(sGlow[1]);
			int iGreen2 = (sGlow[1][0] != '\0') ? StringToInt(sGlow[1]) : 255;
			TrimString(sGlow[2]);
			int iBlue2 = (sGlow[2][0] != '\0') ? StringToInt(sGlow[2]) : 255;
			int iGlowEffect = !g_bTankConfig[g_iTankType[client]] ? g_iGlowEffect[g_iTankType[client]] : g_iGlowEffect2[g_iTankType[client]];
			if (iGlowEffect == 1 && bIsL4D2Game())
			{
				SetEntProp(entity, Prop_Send, "m_iGlowType", 3);
				SetEntProp(entity, Prop_Send, "m_nGlowRange", 0);
				SetEntProp(entity, Prop_Send, "m_glowColorOverride", iGetRGBColor(iRed2, iGreen2, iBlue2));
			}
		}
	}
}

public Action tTimerTrack(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iRock = EntRefToEntIndex(pack.ReadCell());
	int iTrackAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iTrackAbility[g_iTankType[iTank]] : g_iTrackAbility2[g_iTankType[iTank]];
	if (iTrackAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank) || iRock == INVALID_ENT_REFERENCE)
	{
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		if (bIsValidEntity(iRock))
		{
			SDKUnhook(iRock, SDKHook_Think, TrackThink);
			SDKHook(iRock, SDKHook_Think, TrackThink);
		}
	}
	return Plugin_Continue;
}