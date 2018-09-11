// Super Tanks++: Clone Ability
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#undef REQUIRE_PLUGIN
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Clone Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloned[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
int g_iCloneAbility[ST_MAXTYPES + 1], g_iCloneAbility2[ST_MAXTYPES + 1], g_iCloneAmount[ST_MAXTYPES + 1], g_iCloneAmount2[ST_MAXTYPES + 1], g_iCloneChance[ST_MAXTYPES + 1], g_iCloneChance2[ST_MAXTYPES + 1], g_iCloneCount[MAXPLAYERS + 1], g_iCloneHealth[ST_MAXTYPES + 1], g_iCloneHealth2[ST_MAXTYPES + 1], g_iCloneMode[ST_MAXTYPES + 1], g_iCloneMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Clone Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	CreateNative("ST_CloneAllowed", iNative_CloneAllowed);
	RegPluginLibrary("st_clone");
	return APLRes_Success;
}

public int iNative_CloneAllowed(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	bool bCloneInstalled = GetNativeCell(2);
	if (ST_TankAllowed(iTank) && bIsCloneAllowed(iTank, bCloneInstalled))
	{
		return true;
	}
	return false;
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPostAdminCheck(int client)
{
	g_bCloned[client] = false;
	g_iCloneCount[client] = 0;
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
			main ? (g_iCloneMode[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Mode", 0)) : (g_iCloneMode2[iIndex] = kvSuperTanks.GetNum("Clone Ability/Clone Mode", g_iCloneMode[iIndex]));
			main ? (g_iCloneMode[iIndex] = iSetCellLimit(g_iCloneMode[iIndex], 0, 1)) : (g_iCloneMode2[iIndex] = iSetCellLimit(g_iCloneMode2[iIndex], 0, 1));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iCloneAbility(iTank) == 1 && ST_TankAllowed(iTank))
		{
			g_iCloneCount[iTank] = 0;
		}
	}
}

public void ST_Ability(int client)
{
	int iCloneChance = !g_bTankConfig[ST_TankType(client)] ? g_iCloneChance[ST_TankType(client)] : g_iCloneChance2[ST_TankType(client)];
	if (iCloneAbility(client) == 1 && GetRandomInt(1, iCloneChance) == 1 && ST_TankAllowed(client) && IsPlayerAlive(client) && !g_bCloned[client])
	{
		int iCloneAmount = !g_bTankConfig[ST_TankType(client)] ? g_iCloneAmount[ST_TankType(client)] : g_iCloneAmount2[ST_TankType(client)];
		if (g_iCloneCount[client] < iCloneAmount)
		{
			float flHitPosition[3], flPosition[3], flAngle[3], flVector[3];
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
				float flDistance = GetVectorDistance(flHitPosition, flPosition);
				if (flDistance < 200.0 && flDistance > 40.0)
				{
					bool bTankBoss[MAXPLAYERS + 1];
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						bTankBoss[iPlayer] = false;
						if (ST_TankAllowed(iPlayer) && IsPlayerAlive(iPlayer))
						{
							bTankBoss[iPlayer] = true;
						}
					}
					ST_SpawnTank(client, ST_TankType(client));
					int iSelectedType;
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						if (ST_TankAllowed(iPlayer) && IsPlayerAlive(iPlayer) && !bTankBoss[iPlayer])
						{
							iSelectedType = iPlayer;
							break;
						}
					}
					if (iSelectedType > 0)
					{
						TeleportEntity(iSelectedType, flHitPosition, NULL_VECTOR, NULL_VECTOR);
						g_bCloned[iSelectedType] = true;
						int iCloneHealth = !g_bTankConfig[ST_TankType(client)] ? g_iCloneHealth[ST_TankType(client)] : g_iCloneHealth2[ST_TankType(client)],
							iNewHealth = (iCloneHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iCloneHealth;
						SetEntityHealth(iSelectedType, iNewHealth);
						g_iCloneCount[client]++;
					}
				}
			}
			delete hTrace;
		}
	}
}

public void ST_BossStage(int client)
{
	if (iCloneAbility(client) == 1 && ST_TankAllowed(client) && !g_bCloned[client])
	{
		g_iCloneCount[client] = 0;
	}
}

stock void vReset()
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

stock bool bIsCloneAllowed(int client, bool clone)
{
	int iCloneMode = !g_bTankConfig[ST_TankType(client)] ? g_iCloneMode[ST_TankType(client)] : g_iCloneMode2[ST_TankType(client)];
	if (clone && iCloneMode == 0 && g_bCloned[client])
	{
		return false;
	}
	return true;
}

stock int iCloneAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iCloneAbility[ST_TankType(client)] : g_iCloneAbility2[ST_TankType(client)];
}