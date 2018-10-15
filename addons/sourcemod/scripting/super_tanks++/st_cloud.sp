// Super Tanks++: Cloud Ability
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Cloud Ability",
	author = ST_AUTHOR,
	description = "The Super Tank constantly emits clouds of smoke that damage survivors caught in them.",
	version = ST_VERSION,
	url = ST_URL
};

#define PARTICLE_SMOKE "smoker_smokecloud"

bool g_bCloneInstalled, g_bCloud[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flCloudDamage[ST_MAXTYPES + 1], g_flCloudDamage2[ST_MAXTYPES + 1];

int g_iCloudAbility[ST_MAXTYPES + 1], g_iCloudAbility2[ST_MAXTYPES + 1], g_iCloudMessage[ST_MAXTYPES + 1], g_iCloudMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Cloud Ability only supports Left 4 Dead 1 & 2.");

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
	vPrecacheParticle(PARTICLE_SMOKE);

	vReset();
}

public void OnClientPutInServer(int client)
{
	g_bCloud[client] = false;
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

				g_iCloudAbility[iIndex] = kvSuperTanks.GetNum("Cloud Ability/Ability Enabled", 0);
				g_iCloudAbility[iIndex] = iClamp(g_iCloudAbility[iIndex], 0, 1);
				g_iCloudMessage[iIndex] = kvSuperTanks.GetNum("Cloud Ability/Ability Message", 0);
				g_iCloudMessage[iIndex] = iClamp(g_iCloudMessage[iIndex], 0, 1);
				g_flCloudDamage[iIndex] = kvSuperTanks.GetFloat("Cloud Ability/Cloud Damage", 5.0);
				g_flCloudDamage[iIndex] = flClamp(g_flCloudDamage[iIndex], 1.0, 9999999999.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iCloudAbility2[iIndex] = kvSuperTanks.GetNum("Cloud Ability/Ability Enabled", g_iCloudAbility[iIndex]);
				g_iCloudAbility2[iIndex] = iClamp(g_iCloudAbility2[iIndex], 0, 1);
				g_iCloudMessage2[iIndex] = kvSuperTanks.GetNum("Cloud Ability/Ability Message", g_iCloudMessage[iIndex]);
				g_iCloudMessage2[iIndex] = iClamp(g_iCloudMessage2[iIndex], 0, 1);
				g_flCloudDamage2[iIndex] = kvSuperTanks.GetFloat("Cloud Ability/Cloud Damage", g_flCloudDamage[iIndex]);
				g_flCloudDamage2[iIndex] = flClamp(g_flCloudDamage2[iIndex], 1.0, 9999999999.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vReset();
}

public void ST_Ability(int tank)
{
	if (iCloudAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank) && !g_bCloud[tank])
	{
		g_bCloud[tank] = true;

		CreateTimer(1.5, tTimerCloud, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

		if (iCloudMessage(tank) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Cloud", sTankName);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bCloud[iPlayer] = false;
		}
	}
}

static int iCloudAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iCloudAbility[ST_TankType(tank)] : g_iCloudAbility2[ST_TankType(tank)];
}

static int iCloudMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iCloudMessage[ST_TankType(tank)] : g_iCloudMessage2[ST_TankType(tank)];
}

public Action tTimerCloud(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bCloud[iTank])
	{
		g_bCloud[iTank] = false;

		return Plugin_Stop;
	}

	if (iCloudAbility(iTank) == 0)
	{
		g_bCloud[iTank] = false;

		if (iCloudMessage(iTank) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(iTank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Cloud2", sTankName);
		}

		return Plugin_Stop;
	}

	vAttachParticle(iTank, PARTICLE_SMOKE, 1.5);

	float flTankPos[3];
	GetClientAbsOrigin(iTank, flTankPos);

	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor))
		{
			float flSurvivorPos[3];
			GetClientAbsOrigin(iSurvivor, flSurvivorPos);

			float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
			if (flDistance <= 200.0)
			{
				float flCloudDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_flCloudDamage[ST_TankType(iTank)] : g_flCloudDamage2[ST_TankType(iTank)];
				SDKHooks_TakeDamage(iSurvivor, iTank, iTank, flCloudDamage);
			}
		}
	}

	return Plugin_Continue;
}