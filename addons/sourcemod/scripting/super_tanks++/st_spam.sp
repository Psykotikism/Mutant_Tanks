// Super Tanks++: Spam Ability
#include <sourcemod>
#include <sdktools>

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

float g_flSpamChance[ST_MAXTYPES + 1], g_flSpamChance2[ST_MAXTYPES + 1], g_flSpamDuration[ST_MAXTYPES + 1], g_flSpamDuration2[ST_MAXTYPES + 1];

int g_iSpamAbility[ST_MAXTYPES + 1], g_iSpamAbility2[ST_MAXTYPES + 1], g_iSpamDamage[ST_MAXTYPES + 1], g_iSpamDamage2[ST_MAXTYPES + 1], g_iSpamMessage[ST_MAXTYPES + 1], g_iSpamMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
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
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
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
		char sTankName[MAX_NAME_LENGTH + 1];
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName, true))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iSpamAbility[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Enabled", 0);
				g_iSpamAbility[iIndex] = iClamp(g_iSpamAbility[iIndex], 0, 1);
				g_iSpamMessage[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Message", 0);
				g_iSpamMessage[iIndex] = iClamp(g_iSpamMessage[iIndex], 0, 1);
				g_flSpamChance[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Spam Chance", 33.3);
				g_flSpamChance[iIndex] = flClamp(g_flSpamChance[iIndex], 0.1, 100.0);
				g_iSpamDamage[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Damage", 5);
				g_iSpamDamage[iIndex] = iClamp(g_iSpamDamage[iIndex], 1, 9999999999);
				g_flSpamDuration[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Spam Duration", 5.0);
				g_flSpamDuration[iIndex] = flClamp(g_flSpamDuration[iIndex], 0.1, 9999999999.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iSpamAbility2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Enabled", g_iSpamAbility[iIndex]);
				g_iSpamAbility2[iIndex] = iClamp(g_iSpamAbility2[iIndex], 0, 1);
				g_iSpamMessage2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Ability Message", g_iSpamMessage[iIndex]);
				g_iSpamMessage2[iIndex] = iClamp(g_iSpamMessage2[iIndex], 0, 1);
				g_flSpamChance2[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Spam Chance", g_flSpamChance[iIndex]);
				g_flSpamChance2[iIndex] = flClamp(g_flSpamChance2[iIndex], 0.1, 100.0);
				g_iSpamDamage2[iIndex] = kvSuperTanks.GetNum("Spam Ability/Spam Damage", g_iSpamDamage[iIndex]);
				g_iSpamDamage2[iIndex] = iClamp(g_iSpamDamage2[iIndex], 1, 9999999999);
				g_flSpamDuration2[iIndex] = kvSuperTanks.GetFloat("Spam Ability/Spam Duration", g_flSpamDuration[iIndex]);
				g_flSpamDuration2[iIndex] = flClamp(g_flSpamDuration2[iIndex], 0.1, 9999999999.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_Ability(int tank)
{
	float flSpamChance = !g_bTankConfig[ST_TankType(tank)] ? g_flSpamChance[ST_TankType(tank)] : g_flSpamChance2[ST_TankType(tank)];
	if (iSpamAbility(tank) == 1 && GetRandomFloat(0.1, 100.0) <= flSpamChance && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank) && !g_bSpam[tank])
	{
		g_bSpam[tank] = true;

		DataPack dpSpam;
		CreateDataTimer(0.5, tTimerSpam, dpSpam, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpSpam.WriteCell(GetClientUserId(tank));
		dpSpam.WriteFloat(GetEngineTime());

		if (iSpamMessage(tank) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Spam", sTankName);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bSpam[iPlayer] = false;
		}
	}
}

static int iSpamAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iSpamAbility[ST_TankType(tank)] : g_iSpamAbility2[ST_TankType(tank)];
}

static int iSpamMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iSpamMessage[ST_TankType(tank)] : g_iSpamMessage2[ST_TankType(tank)];
}

public Action tTimerSpam(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bSpam[iTank])
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
			PrintToChatAll("%s %t", ST_TAG2, "Spam2", sTankName);
		}

		return Plugin_Stop;
	}

	char sDamage[11];
	int iSpamDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_iSpamDamage[ST_TankType(iTank)] : g_iSpamDamage2[ST_TankType(iTank)];
	IntToString(iSpamDamage, sDamage, sizeof(sDamage));

	float flPos[3], flAngles[3];
	GetClientEyePosition(iTank, flPos);
	GetClientEyeAngles(iTank, flAngles);
	flPos[2] += 80.0;

	int iSpammer = CreateEntityByName("env_rock_launcher");
	if (bIsValidEntity(iSpammer))
	{
		DispatchKeyValue(iSpammer, "rockdamageoverride", sDamage);
		TeleportEntity(iSpammer, flPos, flAngles, NULL_VECTOR);
		DispatchSpawn(iSpammer);

		AcceptEntityInput(iSpammer, "LaunchRock");
		RemoveEntity(iSpammer);
	}

	return Plugin_Continue;
}