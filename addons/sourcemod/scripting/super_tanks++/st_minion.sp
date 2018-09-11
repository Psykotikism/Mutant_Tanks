// Super Tanks++: Minion Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Minion Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bMinion[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
char g_sMinionTypes[ST_MAXTYPES + 1][13], g_sMinionTypes2[ST_MAXTYPES + 1][13];
int g_iMinionAbility[ST_MAXTYPES + 1], g_iMinionAbility2[ST_MAXTYPES + 1], g_iMinionAmount[ST_MAXTYPES + 1], g_iMinionAmount2[ST_MAXTYPES + 1], g_iMinionChance[ST_MAXTYPES + 1], g_iMinionChance2[ST_MAXTYPES + 1], g_iMinionCount[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Minion Ability only supports Left 4 Dead 1 & 2.");
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
	if (strcmp(name, "st_clone", false) == 0)
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (strcmp(name, "st_clone", false) == 0)
	{
		g_bCloneInstalled = false;
	}
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPostAdminCheck(int client)
{
	g_bMinion[client] = false;
	g_iMinionCount[client] = 0;
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
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iMinionAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			g_bMinion[iTank] = false;
			g_iMinionCount[iTank] = 0;
		}
	}
}

public void ST_Ability(int client)
{
	int iMinionChance = !g_bTankConfig[ST_TankType(client)] ? g_iMinionChance[ST_TankType(client)] : g_iMinionChance2[ST_TankType(client)];
	if (iMinionAbility(client) == 1 && GetRandomInt(1, iMinionChance) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iMinionAmount = !g_bTankConfig[ST_TankType(client)] ? g_iMinionAmount[ST_TankType(client)] : g_iMinionAmount2[ST_TankType(client)];
		if (g_iMinionCount[client] < iMinionAmount)
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
					char sNumbers = !g_bTankConfig[ST_TankType(client)] ? g_sMinionTypes[ST_TankType(client)][GetRandomInt(0, strlen(g_sMinionTypes[ST_TankType(client)]) - 1)] : g_sMinionTypes2[ST_TankType(client)][GetRandomInt(0, strlen(g_sMinionTypes2[ST_TankType(client)]) - 1)];
					switch (sNumbers)
					{
						case '1': vCheatCommand(client, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", "smoker");
						case '2': vCheatCommand(client, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", "boomer");
						case '3': vCheatCommand(client, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", "hunter");
						case '4': vCheatCommand(client, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", bIsL4D2Game() ? "spitter" : "boomer");
						case '5': vCheatCommand(client, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", bIsL4D2Game() ? "jockey" : "hunter");
						case '6': vCheatCommand(client, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", bIsL4D2Game() ? "charger" : "smoker");
						default: vCheatCommand(client, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", "hunter");
					}
					int iSelectedType;
					for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
					{
						if (bIsInfected(iPlayer) && !bSpecialInfected[iPlayer])
						{
							iSelectedType = iPlayer;
							break;
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
	if (iMinionAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled))
	{
		g_bMinion[client] = false;
		g_iMinionCount[client] = 0;
	}
}

stock void vReset()
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

stock int iMinionAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iMinionAbility[ST_TankType(client)] : g_iMinionAbility2[ST_TankType(client)];
}