// Super Tanks++: Shield Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Shield Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bShield[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
char g_sShieldColor[ST_MAXTYPES + 1][12];
char g_sShieldColor2[ST_MAXTYPES + 1][12];
ConVar g_cvSTFindConVar;
float g_flShieldDelay[ST_MAXTYPES + 1];
float g_flShieldDelay2[ST_MAXTYPES + 1];
int g_iShieldAbility[ST_MAXTYPES + 1];
int g_iShieldAbility2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Shield Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
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
	vCreateInfoFile("cfg/sourcemod/super_tanks++/", "information/", "st_shield", "st_shield");
	g_cvSTFindConVar = FindConVar("z_tank_throw_force");
}

public void OnMapStart()
{
	PrecacheModel(MODEL_PROPANETANK, true);
	PrecacheModel(MODEL_SHIELD, true);
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bShield[iPlayer] = false;
		}
	}
	if (g_bLateLoad)
	{
		vLateLoad(true);
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bShield[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bShield[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bShield[iPlayer] = false;
		}
	}
}

void vLateLoad(bool late)
{
	if (late)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				SDKHook(iPlayer, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		if (ST_TankAllowed(victim) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (g_bShield[victim])
			{
				if (damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA)
				{
					vShield(victim, false);
				}
				else
				{
					damage = 0.0;
					return Plugin_Handled;
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action SetTransmit(int entity, int client)
{
	int iOwner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (iOwner == client)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
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
			main ? (g_iShieldAbility[iIndex] = kvSuperTanks.GetNum("Shield Ability/Ability Enabled", 0)) : (g_iShieldAbility2[iIndex] = kvSuperTanks.GetNum("Shield Ability/Ability Enabled", g_iShieldAbility[iIndex]));
			main ? (g_iShieldAbility[iIndex] = iSetCellLimit(g_iShieldAbility[iIndex], 0, 1)) : (g_iShieldAbility2[iIndex] = iSetCellLimit(g_iShieldAbility2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("Shield Ability/Shield Color", g_sShieldColor[iIndex], sizeof(g_sShieldColor[]), "255,255,255")) : (kvSuperTanks.GetString("Shield Ability/Shield Color", g_sShieldColor2[iIndex], sizeof(g_sShieldColor2[]), g_sShieldColor[iIndex]));
			main ? (g_flShieldDelay[iIndex] = kvSuperTanks.GetFloat("Shield Ability/Shield Delay", 5.0)) : (g_flShieldDelay2[iIndex] = kvSuperTanks.GetFloat("Shield Ability/Shield Delay", g_flShieldDelay[iIndex]));
			main ? (g_flShieldDelay[iIndex] = flSetFloatLimit(g_flShieldDelay[iIndex], 1.0, 9999999999.0)) : (g_flShieldDelay2[iIndex] = flSetFloatLimit(g_flShieldDelay2[iIndex], 1.0, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "ability_use") == 0)
	{
		int iTankId = event.GetInt("userid");
		int iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank) && IsPlayerAlive(iTank))
		{
			int iProp = -1;
			while ((iProp = FindEntityByClassname(iProp, "prop_dynamic")) != INVALID_ENT_REFERENCE)
			{
				char sModel[128];
				GetEntPropString(iProp, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
				if (strcmp(sModel, MODEL_SHIELD, false) == 0)
				{
					int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
					if (iOwner == iTank)
					{
						SDKUnhook(iProp, SDKHook_SetTransmit, SetTransmit);
						CreateTimer(3.5, tTimerSetTransmit, EntIndexToEntRef(iProp), TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
	}
	else if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid");
		int iTank = GetClientOfUserId(iTankId);
		int iShieldAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iShieldAbility[ST_TankType(iTank)] : g_iShieldAbility2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iShieldAbility == 1)
		{
			int iProp = -1;
			while ((iProp = FindEntityByClassname(iProp, "prop_dynamic")) != INVALID_ENT_REFERENCE)
			{
				char sModel[128];
				GetEntPropString(iProp, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
				if (strcmp(sModel, MODEL_SHIELD, false) == 0)
				{
					int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
					if (iOwner == iTank)
					{
						SDKUnhook(iProp, SDKHook_SetTransmit, SetTransmit);
						AcceptEntityInput(iProp, "Kill");
					}
				}
			}
		}
	}
}

public void ST_Spawn(int client)
{
	int iShieldAbility = !g_bTankConfig[ST_TankType(client)] ? g_iShieldAbility[ST_TankType(client)] : g_iShieldAbility2[ST_TankType(client)];
	if (iShieldAbility == 1 && ST_TankAllowed(client) && IsPlayerAlive(client) && !g_bShield[client])
	{
		vShield(client, true);
	}
}

public void ST_RockThrow(int client, int entity)
{
	int iShieldAbility = !g_bTankConfig[ST_TankType(client)] ? g_iShieldAbility[ST_TankType(client)] : g_iShieldAbility2[ST_TankType(client)];
	if (ST_TankAllowed(client) && IsPlayerAlive(client) && iShieldAbility == 1)
	{
		DataPack dpDataPack = new DataPack();
		CreateDataTimer(0.1, tTimerShieldThrow, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(EntIndexToEntRef(entity));
		dpDataPack.WriteCell(GetClientUserId(client));
	}
}

void vShield(int client, bool shield)
{
	if (shield)
	{
		char sSet[3][4];
		char sShieldColor[12];
		sShieldColor = !g_bTankConfig[ST_TankType(client)] ? g_sShieldColor[ST_TankType(client)] : g_sShieldColor2[ST_TankType(client)];
		TrimString(sShieldColor);
		ExplodeString(sShieldColor, ",", sSet, sizeof(sSet), sizeof(sSet[]));
		TrimString(sSet[0]);
		int iRed = (sSet[0][0] != '\0') ? StringToInt(sSet[0]) : 255;
		TrimString(sSet[1]);
		int iGreen = (sSet[1][0] != '\0') ? StringToInt(sSet[1]) : 255;
		TrimString(sSet[2]);
		int iBlue = (sSet[2][0] != '\0') ? StringToInt(sSet[2]) : 255;
		float flOrigin[3];
		GetClientAbsOrigin(client, flOrigin);
		flOrigin[2] -= 120.0;
		int iShield = CreateEntityByName("prop_dynamic");
		if (bIsValidEntity(iShield))
		{
			SetEntityModel(iShield, MODEL_SHIELD);
			DispatchKeyValueVector(iShield, "origin", flOrigin);
			DispatchSpawn(iShield);
			vSetEntityParent(iShield, client);
			SetEntityRenderMode(iShield, RENDER_TRANSTEXTURE);
			SetEntityRenderColor(iShield, iRed, iGreen, iBlue, 50);
			SetEntProp(iShield, Prop_Send, "m_CollisionGroup", 1);
			SetEntPropEnt(iShield, Prop_Send, "m_hOwnerEntity", client);
			SDKHook(iShield, SDKHook_SetTransmit, SetTransmit);
		}
		g_bShield[client] = true;
	}
	else
	{
		int iShield = -1;
		while ((iShield = FindEntityByClassname(iShield, "prop_dynamic")) != INVALID_ENT_REFERENCE)
		{
			char sModel[128];
			GetEntPropString(iShield, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
			if (strcmp(sModel, MODEL_SHIELD, false) == 0)
			{
				int iOwner = GetEntPropEnt(iShield, Prop_Send, "m_hOwnerEntity");
				if (iOwner == client)
				{
					SDKUnhook(iShield, SDKHook_SetTransmit, SetTransmit);
					AcceptEntityInput(iShield, "Kill");
				}
			}
		}
		float flShieldDelay = !g_bTankConfig[ST_TankType(client)] ? g_flShieldDelay[ST_TankType(client)] : g_flShieldDelay2[ST_TankType(client)];
		CreateTimer(flShieldDelay, tTimerShield, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		g_bShield[client] = false;
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
		fFilename.WriteLine("		// The Super Tank protects itself with a shield and traps survivors inside their own shields.");
		fFilename.WriteLine("		// Requires \"st_shield.smx\" to be installed.");
		fFilename.WriteLine("		\"Shield Ability\"");
		fFilename.WriteLine("		{");
		fFilename.WriteLine("			// Enable this ability.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// This is the Super Tank's shield's color.");
		fFilename.WriteLine("			// 1st number = Red");
		fFilename.WriteLine("			// 2nd number = Green");
		fFilename.WriteLine("			// 3rd number = Blue");
		fFilename.WriteLine("			\"Shield Color\"					\"255,255,255\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank's shield reactivates after this many seconds passes.");
		fFilename.WriteLine("			// Minimum: 1.0");
		fFilename.WriteLine("			// Maximum: 9999999999.0");
		fFilename.WriteLine("			\"Shield Delay\"					\"5.0\"");
		fFilename.WriteLine("		}");
		fFilename.WriteLine("	}");
		fFilename.WriteLine("}");
		delete fFilename;
	}
}

public Action tTimerShield(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || g_bShield[iTank])
	{
		return Plugin_Stop;
	}
	int iShieldAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iShieldAbility[ST_TankType(iTank)] : g_iShieldAbility2[ST_TankType(iTank)];
	if (iShieldAbility == 0)
	{
		return Plugin_Stop;
	}
	vShield(iTank, true);
	return Plugin_Continue;
}

public Action tTimerShieldThrow(Handle timer, DataPack pack)
{
	pack.Reset();
	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iShieldAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iShieldAbility[ST_TankType(iTank)] : g_iShieldAbility2[ST_TankType(iTank)];
	if (iShieldAbility == 0)
	{
		return Plugin_Stop;
	}
	float flVelocity[3];
	GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);
	float flVector = GetVectorLength(flVelocity);
	if (flVector > 500.0)
	{
		int iPropane = CreateEntityByName("prop_physics");
		if (bIsValidEntity(iPropane))
		{
			SetEntityModel(iPropane, MODEL_PROPANETANK);
			float flPos[3];
			GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
			AcceptEntityInput(iRock, "Kill");
			NormalizeVector(flVelocity, flVelocity);
			float flSpeed = g_cvSTFindConVar.FloatValue;
			ScaleVector(flVelocity, flSpeed * 1.4);
			DispatchSpawn(iPropane);
			TeleportEntity(iPropane, flPos, NULL_VECTOR, flVelocity);
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action tTimerSetTransmit(Handle timer, any entity)
{
	if ((entity = EntRefToEntIndex(entity)) == INVALID_ENT_REFERENCE || !bIsValidEntity(entity))
	{
		return Plugin_Stop;
	}
	SDKHook(entity, SDKHook_SetTransmit, SetTransmit);
	return Plugin_Continue;
}