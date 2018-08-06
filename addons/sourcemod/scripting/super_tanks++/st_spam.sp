// Super Tanks++: Spam Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Spam Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bSpam[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flSpamDuration[ST_MAXTYPES + 1];
float g_flSpamDuration2[ST_MAXTYPES + 1];
int g_iSpamAbility[ST_MAXTYPES + 1];
int g_iSpamAbility2[ST_MAXTYPES + 1];
int g_iSpamChance[ST_MAXTYPES + 1];
int g_iSpamChance2[ST_MAXTYPES + 1];
int g_iSpamDamage[ST_MAXTYPES + 1];
int g_iSpamDamage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Spam Ability only supports Left 4 Dead 1 & 2.");
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
			g_bSpam[iPlayer] = false;
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
	g_bSpam[client] = false;
}

public void OnClientDisconnect(int client)
{
	g_bSpam[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bSpam[iPlayer] = false;
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
			main ? (g_iSpamAbility[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Enabled", 0)) : (g_iSpamAbility2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Enabled", g_iSpamAbility[iIndex]));
			main ? (g_iSpamAbility[iIndex] = iSetCellLimit(g_iSpamAbility[iIndex], 0, 1)) : (g_iSpamAbility2[iIndex] = iSetCellLimit(g_iSpamAbility2[iIndex], 0, 1));
			main ? (g_iSpamChance[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Chance", 4)) : (g_iSpamChance2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Chance", g_iSpamChance[iIndex]));
			main ? (g_iSpamChance[iIndex] = iSetCellLimit(g_iSpamChance[iIndex], 1, 9999999999)) : (g_iSpamChance2[iIndex] = iSetCellLimit(g_iSpamChance2[iIndex], 1, 9999999999));
			main ? (g_iSpamDamage[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Damage", 5)) : (g_iSpamDamage2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Damage", g_iSpamDamage[iIndex]));
			main ? (g_iSpamDamage[iIndex] = iSetCellLimit(g_iSpamDamage[iIndex], 1, 9999999999)) : (g_iSpamDamage2[iIndex] = iSetCellLimit(g_iSpamDamage2[iIndex], 1, 9999999999));
			main ? (g_flSpamDuration[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Spam Duration", 5.0)) : (g_flSpamDuration2[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Spam Duration", g_flSpamDuration[iIndex]));
			main ? (g_flSpamDuration[iIndex] = flSetFloatLimit(g_flSpamDuration[iIndex], 0.1, 9999999999.0)) : (g_flSpamDuration2[iIndex] = flSetFloatLimit(g_flSpamDuration2[iIndex], 0.1, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	int iSpamAbility = !g_bTankConfig[ST_TankType(client)] ? g_iSpamAbility[ST_TankType(client)] : g_iSpamAbility2[ST_TankType(client)];
	int iSpamChance = !g_bTankConfig[ST_TankType(client)] ? g_iSpamChance[ST_TankType(client)] : g_iSpamChance2[ST_TankType(client)];
	if (iSpamAbility == 1 && GetRandomInt(1, iSpamChance) == 1 && ST_TankAllowed(client) && IsPlayerAlive(client) && !g_bSpam[client])
	{
		g_bSpam[client] = true;
		DataPack dpDataPack = new DataPack();
		CreateDataTimer(0.5, tTimerSpam, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteFloat(GetEngineTime());
	}
}

public Action tTimerSpam(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		g_bSpam[iTank] = false;
		return Plugin_Stop;
	}
	float flTime = pack.ReadFloat();
	int iSpamAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iSpamAbility[ST_TankType(iTank)] : g_iSpamAbility2[ST_TankType(iTank)];
	float flSpamDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flSpamDuration[ST_TankType(iTank)] : g_flSpamDuration2[ST_TankType(iTank)];
	if (iSpamAbility == 0 || (flTime + flSpamDuration) < GetEngineTime())
	{
		g_bSpam[iTank] = false;
		return Plugin_Stop;
	}
	char sDamage[6];
	int iSpamDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_iSpamDamage[ST_TankType(iTank)] : g_iSpamDamage2[ST_TankType(iTank)];
	IntToString(iSpamDamage, sDamage, sizeof(sDamage));
	float flPos[3];
	float flAng[3];
	GetClientEyePosition(iTank, flPos);
	GetClientEyeAngles(iTank, flAng);
	flPos[2] += 80.0;
	int iSpammer = CreateEntityByName("env_rock_launcher");
	if (bIsValidEntity(iSpammer))
	{
		DispatchKeyValue(iSpammer, "rockdamageoverride", sDamage);
		TeleportEntity(iSpammer, flPos, flAng, NULL_VECTOR);
		DispatchSpawn(iSpammer);
		AcceptEntityInput(iSpammer, "LaunchRock");
		AcceptEntityInput(iSpammer, "Kill");
	}
	return Plugin_Continue;
}