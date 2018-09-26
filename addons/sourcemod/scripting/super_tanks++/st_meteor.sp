// Super Tanks++: Meteor Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Meteor Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates meteor showers.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bMeteor[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
char g_sMeteorRadius[ST_MAXTYPES + 1][13], g_sMeteorRadius2[ST_MAXTYPES + 1][13], g_sPropsColors[ST_MAXTYPES + 1][80], g_sPropsColors2[ST_MAXTYPES + 1][80];
int g_iMeteorAbility[ST_MAXTYPES + 1], g_iMeteorAbility2[ST_MAXTYPES + 1], g_iMeteorChance[ST_MAXTYPES + 1], g_iMeteorChance2[ST_MAXTYPES + 1], g_iMeteorDamage[ST_MAXTYPES + 1], g_iMeteorDamage2[ST_MAXTYPES + 1], g_iMeteorMessage[ST_MAXTYPES + 1], g_iMeteorMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Meteor Ability only supports Left 4 Dead 1 & 2.");
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
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("super_tanks++.phrases");
}

public void OnMapStart()
{
	PrecacheModel(MODEL_PROPANETANK, true);
	vReset();
}

public void OnClientPutInServer(int client)
{
	g_bMeteor[client] = false;
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
		Format(sName, sizeof(sName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (kvSuperTanks.GetString("Props/Props Colors", g_sPropsColors[iIndex], sizeof(g_sPropsColors[]), "255,255,255,255|255,255,255,255|255,255,255,180|255,255,255,255|255,255,255,255")) : (kvSuperTanks.GetString("Props/Props Colors", g_sPropsColors2[iIndex], sizeof(g_sPropsColors2[]), g_sPropsColors[iIndex]));
			main ? (g_iMeteorAbility[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Ability Enabled", 0)) : (g_iMeteorAbility2[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Ability Enabled", g_iMeteorAbility[iIndex]));
			main ? (g_iMeteorAbility[iIndex] = iClamp(g_iMeteorAbility[iIndex], 0, 1)) : (g_iMeteorAbility2[iIndex] = iClamp(g_iMeteorAbility2[iIndex], 0, 1));
			main ? (g_iMeteorMessage[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Ability Message", 0)) : (g_iMeteorMessage2[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Ability Message", g_iMeteorMessage[iIndex]));
			main ? (g_iMeteorMessage[iIndex] = iClamp(g_iMeteorMessage[iIndex], 0, 1)) : (g_iMeteorMessage2[iIndex] = iClamp(g_iMeteorMessage2[iIndex], 0, 1));
			main ? (g_iMeteorChance[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Meteor Chance", 4)) : (g_iMeteorChance2[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Meteor Chance", g_iMeteorChance[iIndex]));
			main ? (g_iMeteorChance[iIndex] = iClamp(g_iMeteorChance[iIndex], 1, 9999999999)) : (g_iMeteorChance2[iIndex] = iClamp(g_iMeteorChance2[iIndex], 1, 9999999999));
			main ? (g_iMeteorDamage[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Meteor Damage", 5)) : (g_iMeteorDamage2[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Meteor Damage", g_iMeteorDamage[iIndex]));
			main ? (g_iMeteorDamage[iIndex] = iClamp(g_iMeteorDamage[iIndex], 1, 9999999999)) : (g_iMeteorDamage2[iIndex] = iClamp(g_iMeteorDamage2[iIndex], 1, 9999999999));
			main ? (kvSuperTanks.GetString("Meteor Ability/Meteor Radius", g_sMeteorRadius[iIndex], sizeof(g_sMeteorRadius[]), "-180.0,180.0")) : (kvSuperTanks.GetString("Meteor Ability/Meteor Radius", g_sMeteorRadius2[iIndex], sizeof(g_sMeteorRadius2[]), g_sMeteorRadius[iIndex]));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	int iMeteorChance = !g_bTankConfig[ST_TankType(client)] ? g_iMeteorChance[ST_TankType(client)] : g_iMeteorChance2[ST_TankType(client)];
	if (iMeteorAbility(client) == 1 && GetRandomInt(1, iMeteorChance) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client) && !g_bMeteor[client])
	{
		g_bMeteor[client] = true;
		float flPos[3];
		int iMeteorMessage = !g_bTankConfig[ST_TankType(client)] ? g_iMeteorMessage[ST_TankType(client)] : g_iMeteorMessage2[ST_TankType(client)];
		GetClientEyePosition(client, flPos);
		DataPack dpMeteorUpdate = new DataPack();
		CreateDataTimer(0.6, tTimerMeteorUpdate, dpMeteorUpdate, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpMeteorUpdate.WriteCell(GetClientUserId(client)), dpMeteorUpdate.WriteFloat(flPos[0]), dpMeteorUpdate.WriteFloat(flPos[1]), dpMeteorUpdate.WriteFloat(flPos[2]), dpMeteorUpdate.WriteFloat(GetEngineTime());
		if (iMeteorMessage == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(client, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Meteor", sTankName);
		}
	}
}

stock void vMeteor(int client, int entity)
{
	if (!ST_TankAllowed(client) || !IsPlayerAlive(client) || !ST_CloneAllowed(client, g_bCloneInstalled) || !bIsValidEntity(entity))
	{
		return;
	}
	char sClassname[16];
	GetEntityClassname(entity, sClassname, sizeof(sClassname));
	if (StrEqual(sClassname, "tank_rock"))
	{
		RemoveEntity(entity);
		char sDamage[11];
		int iMeteorDamage = !g_bTankConfig[ST_TankType(client)] ? g_iMeteorDamage[ST_TankType(client)] : g_iMeteorDamage2[ST_TankType(client)];
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
			RemoveEntity(iPointHurt);
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

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bMeteor[iPlayer] = false;
		}
	}
}

stock int iMeteorAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iMeteorAbility[ST_TankType(client)] : g_iMeteorAbility2[ST_TankType(client)];
}

public Action tTimerMeteorUpdate(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bMeteor[iTank] = false;
		return Plugin_Stop;
	}
	float flPos[3];
	flPos[0] = pack.ReadFloat(), flPos[1] = pack.ReadFloat(), flPos[2] = pack.ReadFloat();
	float flTime = pack.ReadFloat();
	if (iMeteorAbility(iTank) == 0)
	{
		g_bMeteor[iTank] = false;
		return Plugin_Stop;
	}
	char sRadius[2][7], sMeteorRadius[13], sSet[5][16], sPropsColors[80], sRGB[4][4];
	sMeteorRadius = !g_bTankConfig[ST_TankType(iTank)] ? g_sMeteorRadius[ST_TankType(iTank)] : g_sMeteorRadius2[ST_TankType(iTank)];
	TrimString(sMeteorRadius);
	ExplodeString(sMeteorRadius, ",", sRadius, sizeof(sRadius), sizeof(sRadius[]));
	TrimString(sRadius[0]);
	float flMin = (!StrEqual(sRadius[0], "")) ? StringToFloat(sRadius[0]) : -200.0;
	TrimString(sRadius[1]);
	float flMax = (!StrEqual(sRadius[1], "")) ? StringToFloat(sRadius[1]) : 200.0;
	flMin = flClamp(flMin, -200.0, 0.0), flMax = flClamp(flMax, 0.0, 200.0);
	sPropsColors = !g_bTankConfig[ST_TankType(iTank)] ? g_sPropsColors[ST_TankType(iTank)] : g_sPropsColors2[ST_TankType(iTank)];
	TrimString(sPropsColors);
	ExplodeString(sPropsColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
	ExplodeString(sSet[3], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
	TrimString(sRGB[0]);
	int iRed = (!StrEqual(sRGB[0], "")) ? StringToInt(sRGB[0]) : 255;
	iRed = iClamp(iRed, 0, 255);
	TrimString(sRGB[1]);
	int iGreen = (!StrEqual(sRGB[1], "")) ? StringToInt(sRGB[1]) : 255;
	iGreen = iClamp(iGreen, 0, 255);
	TrimString(sRGB[2]);
	int iBlue = (!StrEqual(sRGB[2], "")) ? StringToInt(sRGB[2]) : 255;
	iBlue = iClamp(iBlue, 0, 255);
	TrimString(sRGB[3]);
	int iAlpha = (!StrEqual(sRGB[3], "")) ? StringToInt(sRGB[3]) : 255;
	iAlpha = iClamp(iAlpha, 0, 255);
	if ((GetEngineTime() - flTime) > 5.0)
	{
		g_bMeteor[iTank] = false;
	}
	int iMeteor = -1;
	if (g_bMeteor[iTank])
	{
		float flAngles[3], flVelocity[3], flHitpos[3], flVector[3];
		flAngles[0] = GetRandomFloat(-20.0, 20.0), flAngles[1] = GetRandomFloat(-20.0, 20.0), flAngles[2] = 60.0;
		GetVectorAngles(flAngles, flAngles);
		iGetRayHitPos(flPos, flAngles, flHitpos, iTank, true, 2);
		float flDistance = GetVectorDistance(flPos, flHitpos);
		if (flDistance > 1600.0)
		{
			flDistance = 1600.0;
		}
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
				SetEntityRenderColor(iRock, iRed, iGreen, iBlue, iAlpha);
				float flAngles2[3];
				flAngles2[0] = GetRandomFloat(flMin, flMax), flAngles2[1] = GetRandomFloat(flMin, flMax), flAngles2[2] = GetRandomFloat(flMin, flMax);
				flVelocity[0] = GetRandomFloat(0.0, 350.0), flVelocity[1] = GetRandomFloat(0.0, 350.0), flVelocity[2] = GetRandomFloat(0.0, 30.0);
				TeleportEntity(iRock, flHitpos, flAngles2, flVelocity);
				DispatchSpawn(iRock);
				ActivateEntity(iRock);
				AcceptEntityInput(iRock, "Ignite");
				SetEntPropEnt(iRock, Prop_Send, "m_hOwnerEntity", iTank);
				iRock = EntIndexToEntRef(iRock);
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
				vMeteor(iOwner, iMeteor);
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
				vMeteor(iOwner, iMeteor);
			}
		}
	}
	return Plugin_Continue;
}