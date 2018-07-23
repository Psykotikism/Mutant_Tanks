// Super Tanks++: Meteor Ability
bool g_bMeteor[MAXPLAYERS + 1];
char g_sMeteorRadius[ST_MAXTYPES + 1][13];
char g_sMeteorRadius2[ST_MAXTYPES + 1][13];
int g_iMeteorAbility[ST_MAXTYPES + 1];
int g_iMeteorAbility2[ST_MAXTYPES + 1];
int g_iMeteorChance[ST_MAXTYPES + 1];
int g_iMeteorChance2[ST_MAXTYPES + 1];
int g_iMeteorDamage[ST_MAXTYPES + 1];
int g_iMeteorDamage2[ST_MAXTYPES + 1];

void vMeteorConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iMeteorAbility[index] = keyvalues.GetNum("Meteor Ability/Ability Enabled", 0)) : (g_iMeteorAbility2[index] = keyvalues.GetNum("Meteor Ability/Ability Enabled", g_iMeteorAbility[index]));
	main ? (g_iMeteorAbility[index] = iSetCellLimit(g_iMeteorAbility[index], 0, 1)) : (g_iMeteorAbility2[index] = iSetCellLimit(g_iMeteorAbility2[index], 0, 1));
	main ? (g_iMeteorChance[index] = keyvalues.GetNum("Meteor Ability/Meteor Chance", 4)) : (g_iMeteorChance2[index] = keyvalues.GetNum("Meteor Ability/Meteor Chance", g_iMeteorChance[index]));
	main ? (g_iMeteorChance[index] = iSetCellLimit(g_iMeteorChance[index], 1, 9999999999)) : (g_iMeteorChance2[index] = iSetCellLimit(g_iMeteorChance2[index], 1, 9999999999));
	main ? (g_iMeteorDamage[index] = keyvalues.GetNum("Meteor Ability/Meteor Damage", 25)) : (g_iMeteorDamage2[index] = keyvalues.GetNum("Meteor Ability/Meteor Damage", g_iMeteorDamage[index]));
	main ? (g_iMeteorDamage[index] = iSetCellLimit(g_iMeteorDamage[index], 1, 9999999999)) : (g_iMeteorDamage2[index] = iSetCellLimit(g_iMeteorDamage2[index], 1, 9999999999));
	main ? (keyvalues.GetString("Meteor Ability/Meteor Radius", g_sMeteorRadius[index], sizeof(g_sMeteorRadius[]), "-180.0,180.0")) : (keyvalues.GetString("Meteor Ability/Meteor Radius", g_sMeteorRadius2[index], sizeof(g_sMeteorRadius2[]), g_sMeteorRadius[index]));
}

void vMeteor(int entity, int client)
{
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if (bIsValidEntity(entity) && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(client))))
	{
		char sClassname[16];
		GetEntityClassname(entity, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "tank_rock") == 0)
		{
			AcceptEntityInput(entity, "Kill");
			char sDamage[6];
			int iMeteorDamage = !g_bTankConfig[g_iTankType[client]] ? g_iMeteorDamage[g_iTankType[client]] : g_iMeteorDamage2[g_iTankType[client]];
			IntToString(iMeteorDamage, sDamage, sizeof(sDamage));
			float flPos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPos);
			int iPropane = CreateEntityByName("prop_physics");
			if (bIsValidEntity(iPropane))
			{
				SetEntityModel(iPropane, MODEL_PROPANETANK);
				flPos[2] += 50.0;
				TeleportEntity(iPropane, flPos, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(iPropane);
				ActivateEntity(iPropane);
				SetEntPropEnt(iPropane, Prop_Data, "m_hPhysicsAttacker", client);
				SetEntPropFloat(iPropane, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());
				SetEntProp(iPropane, Prop_Send, "m_CollisionGroup", 1);
				SetEntityRenderMode(iPropane, RENDER_TRANSCOLOR);
				SetEntityRenderColor(iPropane, 0, 0, 0, 0);
				AcceptEntityInput(iPropane, "Break");
			}
			int iPointHurt = CreateEntityByName("point_hurt");
			if (bIsValidEntity(iPointHurt))
			{
				SetEntPropEnt(iPointHurt, Prop_Send, "m_hOwnerEntity", client);
				DispatchKeyValue(iPointHurt, "Damage", sDamage);
				DispatchKeyValue(iPointHurt, "DamageType", "2");
				DispatchKeyValue(iPointHurt, "DamageDelay", "0.0");
				DispatchKeyValueFloat(iPointHurt, "DamageRadius", 200.0);
				TeleportEntity(iPointHurt, flPos, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(iPointHurt);
				AcceptEntityInput(iPointHurt, "Hurt", client);
				AcceptEntityInput(iPointHurt, "Kill");
			}
			int iPointPush = CreateEntityByName("point_push");
			if (bIsValidEntity(iPointPush))
			{
				SetEntPropEnt(iPointPush, Prop_Send, "m_hOwnerEntity", client);
				DispatchKeyValueFloat(iPointPush, "magnitude", 600.0);
				DispatchKeyValueFloat(iPointPush, "radius", 200.0 * 1.0);
				DispatchKeyValue(iPointPush, "spawnflags", "8");
				TeleportEntity(iPointPush, flPos, NULL_VECTOR, NULL_VECTOR);
				DispatchSpawn(iPointPush);
				AcceptEntityInput(iPointPush, "Enable");
				iPointPush = EntIndexToEntRef(iPointPush);
				vDeleteEntity(iPointPush, 0.5);
			}
		}
	}
}

void vMeteorAbility(int client)
{
	int iMeteorAbility = !g_bTankConfig[g_iTankType[client]] ? g_iMeteorAbility[g_iTankType[client]] : g_iMeteorAbility2[g_iTankType[client]];
	int iMeteorChance = !g_bTankConfig[g_iTankType[client]] ? g_iMeteorChance[g_iTankType[client]] : g_iMeteorChance2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iMeteorAbility == 1 && GetRandomInt(1, iMeteorChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client) && !g_bMeteor[client])
	{
		g_bMeteor[client] = true;
		float flPos[3];
		GetClientEyePosition(client, flPos);
		DataPack dpDataPack;
		CreateDataTimer(0.6, tTimerMeteorUpdate, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteFloat(flPos[0]);
		dpDataPack.WriteFloat(flPos[1]);
		dpDataPack.WriteFloat(flPos[2]);
		dpDataPack.WriteFloat(GetEngineTime());
	}
}

void vResetMeteor(int client)
{
	g_bMeteor[client] = false;
}

public Action tTimerMeteorUpdate(Handle timer, DataPack pack)
{
	pack.Reset();
	float flPos[3];
	int iTank = GetClientOfUserId(pack.ReadCell());
	flPos[0] = pack.ReadFloat();
	flPos[1] = pack.ReadFloat();
	flPos[2] = pack.ReadFloat();
	float flTime = pack.ReadFloat();
	int iMeteorAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iMeteorAbility[g_iTankType[iTank]] : g_iMeteorAbility2[g_iTankType[iTank]];
	char sRadius[2][7];
	char sMeteorRadius[13];
	sMeteorRadius = !g_bTankConfig[g_iTankType[iTank]] ? g_sMeteorRadius[g_iTankType[iTank]] : g_sMeteorRadius2[g_iTankType[iTank]];
	TrimString(sMeteorRadius);
	ExplodeString(sMeteorRadius, ",", sRadius, sizeof(sRadius), sizeof(sRadius[]));
	TrimString(sRadius[0]);
	float flMin = (sRadius[0][0] != '\0') ? StringToFloat(sRadius[0]) : -200.0;
	TrimString(sRadius[1]);
	float flMax = (sRadius[1][0] != '\0') ? StringToFloat(sRadius[1]) : 200.0;
	flMin = flSetFloatLimit(flMin, -200.0, 0.0);
	flMax = flSetFloatLimit(flMax, 0.0, 200.0);
	if (iMeteorAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bMeteor[iTank] = false;
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		if ((GetEngineTime() - flTime) > 5.0)
		{
			g_bMeteor[iTank] = false;
		}
		int iMeteor = -1;
		if (g_bMeteor[iTank])
		{
			float flAngles[3];
			float flVelocity[3];
			float flHitpos[3];
			flAngles[0] = GetRandomFloat(-20.0, 20.0);
			flAngles[1] = GetRandomFloat(-20.0, 20.0);
			flAngles[2] = 60.0;
			GetVectorAngles(flAngles, flAngles);
			iGetRayHitPos(flPos, flAngles, flHitpos, iTank, 2, true);
			float flDistance = GetVectorDistance(flPos, flHitpos);
			if (flDistance > 1600.0)
			{
				flDistance = 1600.0;
			}
			float flVector[3];
			MakeVectorFromPoints(flPos, flHitpos, flVector);
			NormalizeVector(flVector, flVector);
			ScaleVector(flVector, flDistance - 40.0);
			AddVectors(flPos, flVector, flHitpos);
			if (flDistance > 100.0)
			{
				int iRock = CreateEntityByName("tank_rock");
				if (bIsValidEntity(iRock))
				{
					SetEntityModel(iRock, MODEL_CONCRETE);
					float flAngles2[3];
					flAngles2[0] = GetRandomFloat(flMin, flMax);
					flAngles2[1] = GetRandomFloat(flMin, flMax);
					flAngles2[2] = GetRandomFloat(flMin, flMax);
					flVelocity[0] = GetRandomFloat(0.0, 350.0);
					flVelocity[1] = GetRandomFloat(0.0, 350.0);
					flVelocity[2] = GetRandomFloat(0.0, 30.0);
					TeleportEntity(iRock, flHitpos, flAngles2, flVelocity);
					DispatchSpawn(iRock);
					ActivateEntity(iRock);
					AcceptEntityInput(iRock, "Ignite");
					SetEntPropEnt(iRock, Prop_Send, "m_hOwnerEntity", iTank);
					vDeleteEntity(iRock, 30.0);
				}
			}
		}
		else
		{
			while ((iMeteor = FindEntityByClassname(iMeteor, "tank_rock")) != INVALID_ENT_REFERENCE)
			{
				int iOwner = GetEntPropEnt(iMeteor, Prop_Send, "m_hOwnerEntity");
				if (iTank == iOwner)
				{
					vMeteor(iMeteor, iOwner);
				}
			}
			return Plugin_Stop;
		}
		while ((iMeteor = FindEntityByClassname(iMeteor, "tank_rock")) != INVALID_ENT_REFERENCE)
		{
			int iOwner = GetEntPropEnt(iMeteor, Prop_Send, "m_hOwnerEntity");
			if (iTank == iOwner)
			{
				if (flGetGroundUnits(iMeteor) < 200.0)
				{
					vMeteor(iMeteor, iOwner);
				}
			}
		}
	}
	return Plugin_Continue;
}