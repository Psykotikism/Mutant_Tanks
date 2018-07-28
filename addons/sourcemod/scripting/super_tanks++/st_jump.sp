// Super Tanks++: Jump Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Jump Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bTankConfig[ST_MAXTYPES + 1];
int g_iJumpAbility[ST_MAXTYPES + 1];
int g_iJumpAbility2[ST_MAXTYPES + 1];
int g_iJumpChance[ST_MAXTYPES + 1];
int g_iJumpChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Jump Ability only supports Left 4 Dead 1 & 2.");
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
			main ? (g_iJumpAbility[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Enabled", 0)) : (g_iJumpAbility2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Enabled", g_iJumpAbility[iIndex]));
			main ? (g_iJumpAbility[iIndex] = iSetCellLimit(g_iJumpAbility[iIndex], 0, 1)) : (g_iJumpAbility2[iIndex] = iSetCellLimit(g_iJumpAbility2[iIndex], 0, 1));
			main ? (g_iJumpChance[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Chance", 4)) : (g_iJumpChance2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Chance", g_iJumpChance[iIndex]));
			main ? (g_iJumpChance[iIndex] = iSetCellLimit(g_iJumpChance[iIndex], 1, 9999999999)) : (g_iJumpChance2[iIndex] = iSetCellLimit(g_iJumpChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Spawn(int client)
{
	int iJumpAbility = !g_bTankConfig[ST_TankType(client)] ? g_iJumpAbility[ST_TankType(client)] : g_iJumpAbility2[ST_TankType(client)];
	if (iJumpAbility == 1 && ST_TankAllowed(client))
	{
		CreateTimer(1.0, tTimerJump, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

int iGetNearestSurvivor(int client)
{
	float flDistance = 0.0;
	float flNearest = 0.0;
	float flPlayerPos[3];
	float flTargetPos[3];
	if (bIsValidClient(client))
	{
		GetClientAbsOrigin(client, flPlayerPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				GetClientAbsOrigin(iSurvivor, flTargetPos);
				flDistance = GetVectorDistance(flPlayerPos, flTargetPos);
				if (flNearest == 0.0 || flNearest > flDistance)
				{
					flNearest = flDistance;
				}
			}
		}
	}
	return RoundFloat(flDistance);
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

public Action tTimerJump(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	int iJumpAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iJumpAbility[ST_TankType(iTank)] : g_iJumpAbility2[ST_TankType(iTank)];
	int iJumpChance = !g_bTankConfig[ST_TankType(iTank)] ? g_iJumpChance[ST_TankType(iTank)] : g_iJumpChance2[ST_TankType(iTank)];
	if (iJumpAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	if (GetRandomInt(1, iJumpChance) == 1 && ST_TankAllowed(iTank))
	{
		int iNearestSurvivor = iGetNearestSurvivor(iTank);
		if (iNearestSurvivor > 200 && iNearestSurvivor < 2000)
		{
			float flVelocity[3];
			GetEntPropVector(iTank, Prop_Data, "m_vecVelocity", flVelocity);
			if (flVelocity[0] > 0.0 && flVelocity[0] < 500.0)
			{
				flVelocity[0] += 500.0;
			}
			else if (flVelocity[0] < 0.0 && flVelocity[0] > -500.0)
			{
				flVelocity[0] += -500.0;
			}
			if (flVelocity[1] > 0.0 && flVelocity[1] < 500.0)
			{
				flVelocity[1] += 500.0;
			}
			else if (flVelocity[1] < 0.0 && flVelocity[1] > -500.0)
			{
				flVelocity[1] += -500.0;
			}
			flVelocity[2] += 750.0;
			TeleportEntity(iTank, NULL_VECTOR, NULL_VECTOR, flVelocity);
		}
	}
	return Plugin_Continue;
}