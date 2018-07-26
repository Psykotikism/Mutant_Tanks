// Super Tanks++: Clone Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Clone Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloned[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
int g_iCloneAbility[ST_MAXTYPES + 1];
int g_iCloneAbility2[ST_MAXTYPES + 1];
int g_iCloneAmount[ST_MAXTYPES + 1];
int g_iCloneAmount2[ST_MAXTYPES + 1];
int g_iCloneChance[ST_MAXTYPES + 1];
int g_iCloneChance2[ST_MAXTYPES + 1];
int g_iCloneCount[MAXPLAYERS + 1];
int g_iCloneHealth[ST_MAXTYPES + 1];
int g_iCloneHealth2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Clone Ability only supports Left 4 Dead 1 & 2.");
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
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bCloned[iPlayer] = false;
			g_iCloneCount[iPlayer] = 0;
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
	g_bCloned[client] = false;
	g_iCloneCount[client] = 0;
}

public void OnClientDisconnect(int client)
{
	g_bCloned[client] = false;
	g_iCloneCount[client] = 0;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bCloned[iPlayer] = false;
			g_iCloneCount[iPlayer] = 0;
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
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iCloneAbility[iIndex] = kvSuperTanks.GetNum("Clone Ability/Ability Enabled", 0)) : (g_iCloneAbility2[iIndex] = kvSuperTanks.GetNum("Clone Ability/Ability Enabled", g_iCloneAbility[iIndex]));
			main ? (g_iCloneAbility[iIndex] = iSetCellLimit(g_iCloneAbility[iIndex], 0, 1)) : (g_iCloneAbility2[iIndex] = iSetCellLimit(g_iCloneAbility2[iIndex], 0, 1));
			main ? (g_iCloneAmount[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Amount", 2)) : (g_iCloneAmount2[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Amount", g_iCloneAmount[iIndex]));
			main ? (g_iCloneAmount[iIndex] = iSetCellLimit(g_iCloneAmount[iIndex], 1, 25)) : (g_iCloneAmount2[iIndex] = iSetCellLimit(g_iCloneAmount2[iIndex], 1, 25));
			main ? (g_iCloneChance[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Chance", 4)) : (g_iCloneChance2[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Chance", g_iCloneChance[iIndex]));
			main ? (g_iCloneChance[iIndex] = iSetCellLimit(g_iCloneChance[iIndex], 1, 9999999999)) : (g_iCloneChance2[iIndex] = iSetCellLimit(g_iCloneChance2[iIndex], 1, 9999999999));
			main ? (g_iCloneHealth[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Health", 1000)) : (g_iCloneHealth2[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Health", g_iCloneHealth[iIndex]));
			main ? (g_iCloneHealth[iIndex] = iSetCellLimit(g_iCloneHealth[iIndex], 1, ST_MAXHEALTH)) : (g_iCloneHealth2[iIndex] = iSetCellLimit(g_iCloneHealth2[iIndex], 1, ST_MAXHEALTH));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Death(int client)
{
	if (bIsTank(client))
	{
		int iCloneAbility = !g_bTankConfig[ST_TankType(client)] ? g_iCloneAbility[ST_TankType(client)] : g_iCloneAbility2[ST_TankType(client)];
		if (iCloneAbility == 1)
		{
			if (g_bCloned[client])
			{
				g_bCloned[client] = false;
				if (iGetCloneCount() == 0)
				{
					for (int iCloner = 1; iCloner <= MaxClients; iCloner++)
					{
						if (!g_bCloned[iCloner] && bIsTank(iCloner))
						{
							g_iCloneCount[iCloner] = 0;
						}
					}
				}
			}
			else
			{
				g_iCloneCount[client] = 0;
			}
		}
	}
}

public void ST_Ability(int client)
{
	int iCloneAbility = !g_bTankConfig[ST_TankType(client)] ? g_iCloneAbility[ST_TankType(client)] : g_iCloneAbility2[ST_TankType(client)];
	int iCloneChance = !g_bTankConfig[ST_TankType(client)] ? g_iCloneChance[ST_TankType(client)] : g_iCloneChance2[ST_TankType(client)];
	if (iCloneAbility == 1 && GetRandomInt(1, iCloneChance) == 1 && !g_bCloned[client] && bIsTank(client))
	{
		int iCloneAmount = !g_bTankConfig[ST_TankType(client)] ? g_iCloneAmount[ST_TankType(client)] : g_iCloneAmount2[ST_TankType(client)];
		if (g_iCloneCount[client] < iCloneAmount)
		{
			vCloneSpawner(client);
			g_iCloneCount[client]++;
		}
	}
}

void vClone(int client, float pos[3])
{
	bool bTankBoss[MAXPLAYERS + 1];
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		bTankBoss[iPlayer] = false;
		if (bIsTank(iPlayer))
		{
			bTankBoss[iPlayer] = true;
		}
	}
	ST_SpawnTank(client, ST_TankType(client));
	int iSelectedType;
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsTank(iPlayer))
		{
			if (!bTankBoss[iPlayer])
			{
				iSelectedType = iPlayer;
				break;
			}
		}
	}
	if (iSelectedType > 0)
	{
		TeleportEntity(iSelectedType, pos, NULL_VECTOR, NULL_VECTOR);
		g_bCloned[iSelectedType] = true;
		int iCloneHealth = !g_bTankConfig[ST_TankType(client)] ? g_iCloneHealth[ST_TankType(client)] : g_iCloneHealth2[ST_TankType(client)];
		int iNewHealth = (iCloneHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iCloneHealth;
		SetEntityHealth(iSelectedType, iNewHealth);
	}
}

void vCloneSpawner(int client)
{
	float flHitPosition[3];
	float flPosition[3];
	float flAngle[3];
	float flVector[3];
	GetClientEyePosition(client, flPosition);
	GetClientEyeAngles(client, flAngle);
	flAngle[0] = -25.0;
	GetAngleVectors(flAngle, flAngle, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(flAngle, flAngle);
	ScaleVector(flAngle, -1.0);
	vCopyVector(flAngle, flVector);
	GetVectorAngles(flAngle, flAngle);
	Handle hTrace = TR_TraceRayFilterEx(flPosition, flAngle, MASK_SOLID, RayType_Infinite, bTraceRayDontHitSelf, client);
	if (TR_DidHit(hTrace))
	{
		TR_GetEndPosition(flHitPosition, hTrace);
		NormalizeVector(flVector, flVector);
		ScaleVector(flVector, -40.0);
		AddVectors(flHitPosition, flVector, flHitPosition);
		if (GetVectorDistance(flHitPosition, flPosition) < 200.0 && GetVectorDistance(flHitPosition, flPosition) > 40.0)
		{
			vClone(client, flHitPosition);
		}
	}
	delete hTrace;
}

void vCopyVector(float source[3], float target[3])
{
	target[0] = source[0];
	target[1] = source[1];
	target[2] = source[2];
}

int iGetCloneCount()
{
	int iCloneCount;
	for (int iClone = 1; iClone <= MaxClients; iClone++)
	{
		if (g_bCloned[iClone] && bIsTank(iClone))
		{
			iCloneCount++;
		}
	}
	return iCloneCount;
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

public bool bTraceRayDontHitSelf(int entity, int mask, any data)
{
	if (entity == data)
	{
		return false;
	}
	return true;
}