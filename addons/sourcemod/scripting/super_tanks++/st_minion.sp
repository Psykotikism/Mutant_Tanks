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
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Minion Ability only supports Left 4 Dead 1 & 2.");
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

public void OnPluginStart()
{
	vCreateInfoFile("cfg/sourcemod/super_tanks++/", "information/", "st_minion", "st_minion");
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

public void OnClientDisconnect(int client)
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

void vCreateInfoFile(const char[] filepath, const char[] folder, const char[] filename, const char[] label = "")
{
	char sConfigFilename[128];
	char sConfigLabel[128];
	File fFilename;
	Format(sConfigFilename, sizeof(sConfigFilename), "%s%s%s.txt", filepath, folder, filename);
	if (FileExists(sConfigFilename))
	{
		return;
	}
	fFilename = OpenFile(sConfigFilename, "w+");
	strlen(label) > 0 ? strcopy(sConfigLabel, sizeof(sConfigLabel), label) : strcopy(sConfigLabel, sizeof(sConfigLabel), sConfigFilename);
	if (fFilename != null)
	{
		fFilename.WriteLine("// Note: The config will automatically update any changes mid-game. No need to restart the server or reload the plugin.");
		fFilename.WriteLine("\"Super Tanks++\"");
		fFilename.WriteLine("{");
		fFilename.WriteLine("	\"Example\"");
		fFilename.WriteLine("	{");
		fFilename.WriteLine("		// The Super Tank spawns minions.");
		fFilename.WriteLine("		// Requires \"st_minion.smx\" to be installed.");
		fFilename.WriteLine("		\"Minion Ability\"");
		fFilename.WriteLine("		{");
		fFilename.WriteLine("			// Enable this ability.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The amount of minions the Super Tank can spawn.");
		fFilename.WriteLine("			// Minimum: 1");
		fFilename.WriteLine("			// Maximum: 25");
		fFilename.WriteLine("			\"Minion Amount\"					\"5\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
		fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
		fFilename.WriteLine("			\"Minion Chance\"					\"4\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank can spawn these minions.");
		fFilename.WriteLine("			// Combine numbers in any order for different results.");
		fFilename.WriteLine("			// Repeat the same number to increase its chance of being chosen.");
		fFilename.WriteLine("			// Character limit: 12");
		fFilename.WriteLine("			// 1: Smoker");
		fFilename.WriteLine("			// 2: Boomer");
		fFilename.WriteLine("			// 3: Hunter");
		fFilename.WriteLine("			// 4: Spitter (Switches to Boomer in L4D1.)");
		fFilename.WriteLine("			// 5: Jockey (Switches to Hunter in L4D1.)");
		fFilename.WriteLine("			// 6: Charger (Switches to Smoker in L4D1.)");
		fFilename.WriteLine("			\"Minion Types\"					\"123456\"");
		fFilename.WriteLine("		}");
		fFilename.WriteLine("	}");
		fFilename.WriteLine("}");
		delete fFilename;
	}
}