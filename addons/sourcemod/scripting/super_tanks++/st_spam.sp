// Super Tanks++: Spam Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Spam Ability",
	author = ST_AUTHOR,
	description = "The Super Tank spams rocks at survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bSpam[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flSpamDuration[ST_MAXTYPES + 1], g_flSpamDuration2[ST_MAXTYPES + 1];
int g_iSpamAbility[ST_MAXTYPES + 1], g_iSpamAbility2[ST_MAXTYPES + 1], g_iSpamChance[ST_MAXTYPES + 1], g_iSpamChance2[ST_MAXTYPES + 1], g_iSpamDamage[ST_MAXTYPES + 1], g_iSpamDamage2[ST_MAXTYPES + 1], g_iSpamMessage[ST_MAXTYPES + 1], g_iSpamMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_Left4Dead && !bIsL4D2())
	{
		strcopy(error, err_max, "[ST++] Spam Ability only supports Left 4 Dead 1 & 2.");
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
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	g_bSpam[client] = false;
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
			main ? (g_iSpamAbility[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Enabled", 0)) : (g_iSpamAbility2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Enabled", g_iSpamAbility[iIndex]));
			main ? (g_iSpamAbility[iIndex] = iClamp(g_iSpamAbility[iIndex], 0, 1)) : (g_iSpamAbility2[iIndex] = iClamp(g_iSpamAbility2[iIndex], 0, 1));
			main ? (g_iSpamMessage[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Message", 0)) : (g_iSpamMessage2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Message", g_iSpamMessage[iIndex]));
			main ? (g_iSpamMessage[iIndex] = iClamp(g_iSpamMessage[iIndex], 0, 1)) : (g_iSpamMessage2[iIndex] = iClamp(g_iSpamMessage2[iIndex], 0, 1));
			main ? (g_iSpamChance[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Chance", 4)) : (g_iSpamChance2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Chance", g_iSpamChance[iIndex]));
			main ? (g_iSpamChance[iIndex] = iClamp(g_iSpamChance[iIndex], 1, 9999999999)) : (g_iSpamChance2[iIndex] = iClamp(g_iSpamChance2[iIndex], 1, 9999999999));
			main ? (g_iSpamDamage[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Damage", 5)) : (g_iSpamDamage2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Damage", g_iSpamDamage[iIndex]));
			main ? (g_iSpamDamage[iIndex] = iClamp(g_iSpamDamage[iIndex], 1, 9999999999)) : (g_iSpamDamage2[iIndex] = iClamp(g_iSpamDamage2[iIndex], 1, 9999999999));
			main ? (g_flSpamDuration[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Spam Duration", 5.0)) : (g_flSpamDuration2[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Spam Duration", g_flSpamDuration[iIndex]));
			main ? (g_flSpamDuration[iIndex] = flClamp(g_flSpamDuration[iIndex], 0.1, 9999999999.0)) : (g_flSpamDuration2[iIndex] = flClamp(g_flSpamDuration2[iIndex], 0.1, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	int iSpamChance = !g_bTankConfig[ST_TankType(client)] ? g_iSpamChance[ST_TankType(client)] : g_iSpamChance2[ST_TankType(client)];
	if (iSpamAbility(client) == 1 && GetRandomInt(1, iSpamChance) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client) && !g_bSpam[client])
	{
		g_bSpam[client] = true;
		DataPack dpSpam = new DataPack();
		CreateDataTimer(0.5, tTimerSpam, dpSpam, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpSpam.WriteCell(GetClientUserId(client)), dpSpam.WriteFloat(GetEngineTime());
		if (iSpamMessage(client) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(client, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Spam", sTankName);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bSpam[iPlayer] = false;
		}
	}
}

stock int iSpamAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iSpamAbility[ST_TankType(client)] : g_iSpamAbility2[ST_TankType(client)];
}

stock int iSpamMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iSpamMessage[ST_TankType(client)] : g_iSpamMessage2[ST_TankType(client)];
}

public Action tTimerSpam(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bSpam[iTank] = false;
		return Plugin_Stop;
	}
	float flTime = pack.ReadFloat(),
		flSpamDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flSpamDuration[ST_TankType(iTank)] : g_flSpamDuration2[ST_TankType(iTank)];
	if (iSpamAbility(iTank) == 0 || (flTime + flSpamDuration) < GetEngineTime())
	{
		g_bSpam[iTank] = false;
		if (iSpamMessage(iTank) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(iTank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Spam2", sTankName);
		}
		return Plugin_Stop;
	}
	char sDamage[11];
	int iSpamDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_iSpamDamage[ST_TankType(iTank)] : g_iSpamDamage2[ST_TankType(iTank)];
	IntToString(iSpamDamage, sDamage, sizeof(sDamage));
	float flPos[3], flAngle[3];
	GetClientEyePosition(iTank, flPos);
	GetClientEyeAngles(iTank, flAngle);
	flPos[2] += 80.0;
	int iSpammer = CreateEntityByName("env_rock_launcher");
	if (bIsValidEntity(iSpammer))
	{
		DispatchKeyValue(iSpammer, "rockdamageoverride", sDamage);
		TeleportEntity(iSpammer, flPos, flAngle, NULL_VECTOR);
		DispatchSpawn(iSpammer);
		AcceptEntityInput(iSpammer, "LaunchRock");
		RemoveEntity(iSpammer);
	}
	return Plugin_Continue;
}