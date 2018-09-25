// Super Tanks++: Throw Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Throw Ability",
	author = ST_AUTHOR,
	description = "The Super Tank throws things.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1];
char g_sThrowCarOptions[ST_MAXTYPES + 1][7], g_sThrowCarOptions2[ST_MAXTYPES + 1][7], g_sThrowInfectedOptions[ST_MAXTYPES + 1][15], g_sThrowInfectedOptions2[ST_MAXTYPES + 1][15];
ConVar g_cvSTTankThrowForce;
int g_iThrowAbility[ST_MAXTYPES + 1], g_iThrowAbility2[ST_MAXTYPES + 1], g_iThrowMessage[ST_MAXTYPES + 1], g_iThrowMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_Left4Dead && !bIsL4D2())
	{
		strcopy(error, err_max, "[ST++] Throw Ability only supports Left 4 Dead 1 & 2.");
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

public void OnPluginStart()
{
	LoadTranslations("super_tanks++.phrases");
	g_cvSTTankThrowForce = FindConVar("z_tank_throw_force");
}

public void OnMapStart()
{
	PrecacheModel(MODEL_CAR, true);
	PrecacheModel(MODEL_CAR2, true);
	PrecacheModel(MODEL_CAR3, true);
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
			main ? (g_iThrowAbility[iIndex] = kvSuperTanks.GetNum("Throw Ability/Ability Enabled", 0)) : (g_iThrowAbility2[iIndex] = kvSuperTanks.GetNum("Throw Ability/Ability Enabled", g_iThrowAbility[iIndex]));
			main ? (g_iThrowAbility[iIndex] = iClamp(g_iThrowAbility[iIndex], 0, 3)) : (g_iThrowAbility2[iIndex] = iClamp(g_iThrowAbility2[iIndex], 0, 3));
			main ? (g_iThrowMessage[iIndex] = kvSuperTanks.GetNum("Throw Ability/Ability Message", 0)) : (g_iThrowMessage2[iIndex] = kvSuperTanks.GetNum("Throw Ability/Ability Message", g_iThrowMessage[iIndex]));
			main ? (g_iThrowMessage[iIndex] = iClamp(g_iThrowMessage[iIndex], 0, 7)) : (g_iThrowMessage2[iIndex] = iClamp(g_iThrowMessage2[iIndex], 0, 7));
			main ? (kvSuperTanks.GetString("Throw Ability/Throw Car Options", g_sThrowCarOptions[iIndex], sizeof(g_sThrowCarOptions[]), "123")) : (kvSuperTanks.GetString("Throw Ability/Throw Car Options", g_sThrowCarOptions2[iIndex], sizeof(g_sThrowCarOptions2[]), g_sThrowCarOptions[iIndex]));
			main ? (kvSuperTanks.GetString("Throw Ability/Throw Infected Options", g_sThrowInfectedOptions[iIndex], sizeof(g_sThrowInfectedOptions[]), "1234567")) : (kvSuperTanks.GetString("Throw Ability/Throw Infected Options", g_sThrowInfectedOptions2[iIndex], sizeof(g_sThrowInfectedOptions2[]), g_sThrowInfectedOptions[iIndex]));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_RockThrow(int client, int entity)
{
	if (iThrowAbility(client) == 1)
	{
		DataPack dpCarThrow = new DataPack();
		CreateDataTimer(0.1, tTimerCarThrow, dpCarThrow, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpCarThrow.WriteCell(EntIndexToEntRef(entity)), dpCarThrow.WriteCell(GetClientUserId(client));
	}
	else if (iThrowAbility(client) == 2)
	{
		DataPack dpInfectedThrow = new DataPack();
		CreateDataTimer(0.1, tTimerInfectedThrow, dpInfectedThrow, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpInfectedThrow.WriteCell(EntIndexToEntRef(entity)), dpInfectedThrow.WriteCell(GetClientUserId(client));
	}
	else if (iThrowAbility(client) == 3)
	{
		DataPack dpSelfThrow = new DataPack();
		CreateDataTimer(0.1, tTimerSelfThrow, dpSelfThrow, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpSelfThrow.WriteCell(EntIndexToEntRef(entity)), dpSelfThrow.WriteCell(GetClientUserId(client));
	}
}

stock int iThrowAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iThrowAbility[ST_TankType(client)] : g_iThrowAbility2[ST_TankType(client)];
}

stock int iThrowMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iThrowMessage[ST_TankType(client)] : g_iThrowMessage2[ST_TankType(client)];
}

public Action tTimerCarThrow(Handle timer, DataPack pack)
{
	pack.Reset();
	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		return Plugin_Stop;
	}
	if (iThrowAbility(iTank) != 1)
	{
		return Plugin_Stop;
	}
	float flVelocity[3];
	GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);
	float flVector = GetVectorLength(flVelocity);
	if (flVector > 500.0)
	{
		int iCar = CreateEntityByName("prop_physics");
		if (bIsValidEntity(iCar))
		{
			char sNumbers = !g_bTankConfig[ST_TankType(iTank)] ? g_sThrowCarOptions[ST_TankType(iTank)][GetRandomInt(0, strlen(g_sThrowCarOptions[ST_TankType(iTank)]) - 1)] : g_sThrowCarOptions2[ST_TankType(iTank)][GetRandomInt(0, strlen(g_sThrowCarOptions2[ST_TankType(iTank)]) - 1)];
			switch (sNumbers)
			{
				case '1': SetEntityModel(iCar, MODEL_CAR);
				case '2': SetEntityModel(iCar, MODEL_CAR2);
				case '3': SetEntityModel(iCar, MODEL_CAR3);
				default: SetEntityModel(iCar, MODEL_CAR);
			}
			int iRed = GetRandomInt(0, 255), iGreen = GetRandomInt(0, 255), iBlue = GetRandomInt(0, 255);
			SetEntityRenderColor(iCar, iRed, iGreen, iBlue, 255);
			float flPos[3];
			GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
			RemoveEntity(iRock);
			NormalizeVector(flVelocity, flVelocity);
			ScaleVector(flVelocity, g_cvSTTankThrowForce.FloatValue * 1.4);
			DispatchSpawn(iCar);
			TeleportEntity(iCar, flPos, NULL_VECTOR, flVelocity);
			iCar = EntIndexToEntRef(iCar);
			vDeleteEntity(iCar, 10.0);
			switch (iThrowMessage(iTank))
			{
				case 1, 4, 5, 7:
				{
					char sTankName[MAX_NAME_LENGTH + 1];
					ST_TankName(iTank, sTankName);
					PrintToChatAll("%s %t", ST_PREFIX2, "Throw", sTankName);
				}
			}
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action tTimerInfectedThrow(Handle timer, DataPack pack)
{
	pack.Reset();
	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		return Plugin_Stop;
	}
	if (iThrowAbility(iTank) != 2)
	{
		return Plugin_Stop;
	}
	float flVelocity[3];
	GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);
	float flVector = GetVectorLength(flVelocity);
	if (flVector > 500.0)
	{
		int iInfected = CreateFakeClient("Infected");
		if (iInfected > 0)
		{
			char sNumbers = !g_bTankConfig[ST_TankType(iTank)] ? g_sThrowInfectedOptions[ST_TankType(iTank)][GetRandomInt(0, strlen(g_sThrowInfectedOptions[ST_TankType(iTank)]) - 1)] : g_sThrowInfectedOptions2[ST_TankType(iTank)][GetRandomInt(0, strlen(g_sThrowInfectedOptions2[ST_TankType(iTank)]) - 1)];
			switch (sNumbers)
			{
				case '1': vSpawnInfected(iInfected, "smoker");
				case '2': vSpawnInfected(iInfected, "boomer");
				case '3': vSpawnInfected(iInfected, "hunter");
				case '4': bIsL4D2() ? vSpawnInfected(iInfected, "spitter") : vSpawnInfected(iInfected, "boomer");
				case '5': bIsL4D2() ? vSpawnInfected(iInfected, "jockey") : vSpawnInfected(iInfected, "hunter");
				case '6': bIsL4D2() ? vSpawnInfected(iInfected, "charger") : vSpawnInfected(iInfected, "smoker");
				case '7': vSpawnInfected(iInfected, "tank");
				default: vSpawnInfected(iInfected, "hunter");
			}
			float flPos[3];
			GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
			RemoveEntity(iRock);
			NormalizeVector(flVelocity, flVelocity);
			ScaleVector(flVelocity, g_cvSTTankThrowForce.FloatValue * 1.4);
			TeleportEntity(iInfected, flPos, NULL_VECTOR, flVelocity);
			switch (iThrowMessage(iTank))
			{
				case 2, 4, 6, 7:
				{
					char sTankName[MAX_NAME_LENGTH + 1];
					ST_TankName(iTank, sTankName);
					PrintToChatAll("%s %t", ST_PREFIX2, "Throw2", sTankName);
				}
			}
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action tTimerSelfThrow(Handle timer, DataPack pack)
{
	pack.Reset();
	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		return Plugin_Stop;
	}
	if (iThrowAbility(iTank) != 3)
	{
		return Plugin_Stop;
	}
	float flVelocity[3];
	GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);
	float flVector = GetVectorLength(flVelocity);
	if (flVector > 500.0)
	{
		float flPos[3];
		GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
		RemoveEntity(iRock);
		NormalizeVector(flVelocity, flVelocity);
		ScaleVector(flVelocity, g_cvSTTankThrowForce.FloatValue * 1.4);
		TeleportEntity(iTank, flPos, NULL_VECTOR, flVelocity);
		switch (iThrowMessage(iTank))
		{
			case 3, 5, 6, 7:
			{
				char sTankName[MAX_NAME_LENGTH + 1];
				ST_TankName(iTank, sTankName);
				PrintToChatAll("%s %t", ST_PREFIX2, "Throw3", sTankName);
			}
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}