// Super Tanks++: Meteor Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Meteor Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

#define MODEL_CONCRETE "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"

bool g_bMeteor[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
char g_sMeteorRadius[ST_MAXTYPES + 1][13];
char g_sMeteorRadius2[ST_MAXTYPES + 1][13];
int g_iMeteorAbility[ST_MAXTYPES + 1];
int g_iMeteorAbility2[ST_MAXTYPES + 1];
int g_iMeteorChance[ST_MAXTYPES + 1];
int g_iMeteorChance2[ST_MAXTYPES + 1];
int g_iMeteorDamage[ST_MAXTYPES + 1];
int g_iMeteorDamage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Meteor Ability only supports Left 4 Dead 1 & 2.");
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

public void OnMapStart()
{
	PrecacheModel(MODEL_PROPANETANK, true);
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bMeteor[iPlayer] = false;
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
	g_bMeteor[client] = false;
}

public void OnClientDisconnect(int client)
{
	g_bMeteor[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bMeteor[iPlayer] = false;
		}
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
			main ? (g_iMeteorAbility[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Ability Enabled", 0)) : (g_iMeteorAbility2[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Ability Enabled", g_iMeteorAbility[iIndex]));
			main ? (g_iMeteorAbility[iIndex] = iSetCellLimit(g_iMeteorAbility[iIndex], 0, 1)) : (g_iMeteorAbility2[iIndex] = iSetCellLimit(g_iMeteorAbility2[iIndex], 0, 1));
			main ? (g_iMeteorChance[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Meteor Chance", 4)) : (g_iMeteorChance2[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Meteor Chance", g_iMeteorChance[iIndex]));
			main ? (g_iMeteorChance[iIndex] = iSetCellLimit(g_iMeteorChance[iIndex], 1, 9999999999)) : (g_iMeteorChance2[iIndex] = iSetCellLimit(g_iMeteorChance2[iIndex], 1, 9999999999));
			main ? (g_iMeteorDamage[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Meteor Damage", 5)) : (g_iMeteorDamage2[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Meteor Damage", g_iMeteorDamage[iIndex]));
			main ? (g_iMeteorDamage[iIndex] = iSetCellLimit(g_iMeteorDamage[iIndex], 1, 9999999999)) : (g_iMeteorDamage2[iIndex] = iSetCellLimit(g_iMeteorDamage2[iIndex], 1, 9999999999));
			main ? (kvSuperTanks.GetString("Meteor Ability/Meteor Radius", g_sMeteorRadius[iIndex], sizeof(g_sMeteorRadius[]), "-180.0,180.0")) : (kvSuperTanks.GetString("Meteor Ability/Meteor Radius", g_sMeteorRadius2[iIndex], sizeof(g_sMeteorRadius2[]), g_sMeteorRadius[iIndex]));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	int iMeteorAbility = !g_bTankConfig[ST_TankType(client)] ? g_iMeteorAbility[ST_TankType(client)] : g_iMeteorAbility2[ST_TankType(client)];
	int iMeteorChance = !g_bTankConfig[ST_TankType(client)] ? g_iMeteorChance[ST_TankType(client)] : g_iMeteorChance2[ST_TankType(client)];
	if (iMeteorAbility == 1 && GetRandomInt(1, iMeteorChance) == 1 && ST_TankAllowed(client) && IsPlayerAlive(client) && !g_bMeteor[client])
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

void vMeteor(int client, int entity)
{
	if (ST_TankAllowed(client) && IsPlayerAlive(client) && bIsValidEntity(entity))
	{
		char sClassname[16];
		GetEntityClassname(entity, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "tank_rock") == 0)
		{
			AcceptEntityInput(entity, "Kill");
			char sDamage[6];
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

void vDeleteEntity(int entity, float time = 0.1)
{
	if (bIsValidEntRef(entity))
	{
		char sVariant[64];
		Format(sVariant, sizeof(sVariant), "OnUser1 !self:kill::%f:1", time);
		AcceptEntityInput(entity, "ClearParent");
		SetVariantString(sVariant);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");
	}
}

float flGetGroundUnits(int entity)
{
	if (!(GetEntityFlags(entity) & FL_ONGROUND))
	{ 
		Handle hTrace;
		float flOrigin[3];
		float flPosition[3];
		float flDown[3] = {90.0, 0.0, 0.0};
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flOrigin);
		hTrace = TR_TraceRayFilterEx(flOrigin, flDown, CONTENTS_SOLID|CONTENTS_MOVEABLE, RayType_Infinite, bTraceRayDontHitSelf, entity);
		if (TR_DidHit(hTrace))
		{
			float flUnits;
			TR_GetEndPosition(flPosition, hTrace);
			flUnits = flOrigin[2] - flPosition[2];
			delete hTrace;
			return flUnits;
		}
		delete hTrace;
	}
	return 0.0;
}

int iGetRayHitPos(float pos[3], float angle[3], float hitpos[3], int entity = 0, bool offset = false)
{
	int iHit = 0;
	Handle hTrace = TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelfAndPlayer, entity);
	if (TR_DidHit(hTrace))
	{
		TR_GetEndPosition(hitpos, hTrace);
		iHit = TR_GetEntityIndex(hTrace);
	}
	delete hTrace;
	if (offset)
	{
		float flVector[3];
		MakeVectorFromPoints(hitpos, pos, flVector);
		NormalizeVector(flVector, flVector);
		ScaleVector(flVector, 15.0);
		AddVectors(hitpos, flVector, hitpos);
	}
	return iHit;
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

bool bIsValidEntity(int entity)
{
	return entity > 0 && entity <= 2048 && IsValidEntity(entity);
}

bool bIsValidEntRef(int entity)
{
	return entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE;
}

public bool bTraceRayDontHitSelf(int entity, int mask, any data)
{
	if (entity == data)
	{
		return false;
	}
	return true;
}

public bool bTraceRayDontHitSelfAndPlayer(int entity, int mask, any data)
{
	if (entity == data || bIsValidClient(entity))
	{
		return false;
	}
	return true;
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
	int iMeteorAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iMeteorAbility[ST_TankType(iTank)] : g_iMeteorAbility2[ST_TankType(iTank)];
	char sRadius[2][7];
	char sMeteorRadius[13];
	sMeteorRadius = !g_bTankConfig[ST_TankType(iTank)] ? g_sMeteorRadius[ST_TankType(iTank)] : g_sMeteorRadius2[ST_TankType(iTank)];
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
	if (ST_TankAllowed(iTank))
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
			iGetRayHitPos(flPos, flAngles, flHitpos, iTank, true);
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
	}
	return Plugin_Continue;
}