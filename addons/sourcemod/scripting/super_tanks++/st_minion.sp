// Super Tanks++: Minion Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Minion Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bMinion[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
char g_sMinionTypes[ST_MAXTYPES + 1][13];
char g_sMinionTypes2[ST_MAXTYPES + 1][13];
int g_iMinionAbility[ST_MAXTYPES + 1];
int g_iMinionAbility2[ST_MAXTYPES + 1];
int g_iMinionAmount[ST_MAXTYPES + 1];
int g_iMinionAmount2[ST_MAXTYPES + 1];
int g_iMinionChance[ST_MAXTYPES + 1];
int g_iMinionChance2[ST_MAXTYPES + 1];
int g_iMinionCount[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if ((evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2) || !IsDedicatedServer())
	{
		strcopy(error, err_max, "[ST++] Minion Ability only supports Left 4 Dead 1 & 2 Dedicated Servers.");
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
			g_bMinion[iPlayer] = false;
			g_iMinionCount[iPlayer] = 0;
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
	g_bMinion[client] = false;
	g_iMinionCount[client] = 0;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bMinion[iPlayer] = false;
			g_iMinionCount[iPlayer] = 0;
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
			main ? (g_iMinionAbility[iIndex] = kvSuperTanks.GetNum("Minion Ability/Ability Enabled", 0)) : (g_iMinionAbility2[iIndex] = kvSuperTanks.GetNum("Minion Ability/Ability Enabled", g_iMinionAbility[iIndex]));
			main ? (g_iMinionAbility[iIndex] = iSetCellLimit(g_iMinionAbility[iIndex], 0, 1)) : (g_iMinionAbility2[iIndex] = iSetCellLimit(g_iMinionAbility2[iIndex], 0, 1));
			main ? (g_iMinionAmount[iIndex] = kvSuperTanks.GetNum("Minion Ability/Minion Amount", 5)) : (g_iMinionAmount2[iIndex] = kvSuperTanks.GetNum("Minion Ability/Minion Amount", g_iMinionAmount[iIndex]));
			main ? (g_iMinionAmount[iIndex] = iSetCellLimit(g_iMinionAmount[iIndex], 1, 25)) : (g_iMinionAmount2[iIndex] = iSetCellLimit(g_iMinionAmount2[iIndex], 1, 25));
			main ? (g_iMinionChance[iIndex] = kvSuperTanks.GetNum("Minion Ability/Minion Chance", 4)) : (g_iMinionChance2[iIndex] = kvSuperTanks.GetNum("Minion Ability/Minion Chance", g_iMinionChance[iIndex]));
			main ? (g_iMinionChance[iIndex] = iSetCellLimit(g_iMinionChance[iIndex], 1, 9999999999)) : (g_iMinionChance2[iIndex] = iSetCellLimit(g_iMinionChance2[iIndex], 1, 9999999999));
			main ? (kvSuperTanks.GetString("Minion Ability/Minion Types", g_sMinionTypes[iIndex], sizeof(g_sMinionTypes[]), "123456")) : (kvSuperTanks.GetString("Minion Ability/Minion Types", g_sMinionTypes2[iIndex], sizeof(g_sMinionTypes2[]), g_sMinionTypes[iIndex]));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid");
		int iTank = GetClientOfUserId(iTankId);
		int iMinionAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iMinionAbility[ST_TankType(iTank)] : g_iMinionAbility2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iMinionAbility == 1)
		{
			g_bMinion[iTank] = false;
			g_iMinionCount[iTank] = 0;
		}
	}
}

public void ST_Ability(int client)
{
	int iMinionAbility = !g_bTankConfig[ST_TankType(client)] ? g_iMinionAbility[ST_TankType(client)] : g_iMinionAbility2[ST_TankType(client)];
	int iMinionChance = !g_bTankConfig[ST_TankType(client)] ? g_iMinionChance[ST_TankType(client)] : g_iMinionChance2[ST_TankType(client)];
	if (iMinionAbility == 1 && GetRandomInt(1, iMinionChance) == 1 && ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iMinionAmount = !g_bTankConfig[ST_TankType(client)] ? g_iMinionAmount[ST_TankType(client)] : g_iMinionAmount2[ST_TankType(client)];
		if (g_iMinionCount[client] < iMinionAmount)
		{
			char sInfectedName[MAX_NAME_LENGTH + 1];
			char sNumbers = !g_bTankConfig[ST_TankType(client)] ? g_sMinionTypes[ST_TankType(client)][GetRandomInt(0, strlen(g_sMinionTypes[ST_TankType(client)]) - 1)] : g_sMinionTypes2[ST_TankType(client)][GetRandomInt(0, strlen(g_sMinionTypes2[ST_TankType(client)]) - 1)];
			switch (sNumbers)
			{
				case '1': sInfectedName = "smoker";
				case '2': sInfectedName = "boomer";
				case '3': sInfectedName = "hunter";
				case '4': sInfectedName = bIsL4D2Game() ? "spitter" : "boomer";
				case '5': sInfectedName = bIsL4D2Game() ? "jockey" : "hunter";
				case '6': sInfectedName = bIsL4D2Game() ? "charger" : "smoker";
				default: sInfectedName = "hunter";
			}
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
					bool bSpecialInfected[MAXPLAYERS + 1];
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						bSpecialInfected[iPlayer] = false;
						if (bIsInfected(iPlayer))
						{
							bSpecialInfected[iPlayer] = true;
						}
					}
					vCheatCommand(client, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", sInfectedName);
					int iSelectedType;
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						if (bIsInfected(iPlayer))
						{
							if (!bSpecialInfected[iPlayer])
							{
								iSelectedType = iPlayer;
								break;
							}
						}
					}
					if (iSelectedType > 0)
					{
						TeleportEntity(iSelectedType, flHitPosition, NULL_VECTOR, NULL_VECTOR);
						g_bMinion[iSelectedType] = true;
						g_iMinionCount[client]++;
					}
				}
			}
			delete hTrace;
		}
	}
}

public void ST_BossStage(int client)
{
	int iMinionAbility = !g_bTankConfig[ST_TankType(client)] ? g_iMinionAbility[ST_TankType(client)] : g_iMinionAbility2[ST_TankType(client)];
	if (ST_TankAllowed(client) && iMinionAbility == 1)
	{
		g_bMinion[client] = false;
		g_iMinionCount[client] = 0;
	}
}