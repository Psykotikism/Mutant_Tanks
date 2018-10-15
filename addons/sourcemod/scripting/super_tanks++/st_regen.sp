// Super Tanks++: Regen Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Regen Ability",
	author = ST_AUTHOR,
	description = "The Super Tank regenerates health.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bRegen[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

float g_flRegenInterval[ST_MAXTYPES + 1], g_flRegenInterval2[ST_MAXTYPES + 1];

int g_iRegenAbility[ST_MAXTYPES + 1], g_iRegenAbility2[ST_MAXTYPES + 1], g_iRegenHealth[ST_MAXTYPES + 1], g_iRegenHealth2[ST_MAXTYPES + 1], g_iRegenLimit[ST_MAXTYPES + 1], g_iRegenLimit2[ST_MAXTYPES + 1], g_iRegenMessage[ST_MAXTYPES + 1], g_iRegenMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Regen Ability only supports Left 4 Dead 1 & 2.");

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
	g_bRegen[client] = false;
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

				g_iRegenAbility[iIndex] = kvSuperTanks.GetNum("Regen Ability/Ability Enabled", 0);
				g_iRegenAbility[iIndex] = iClamp(g_iRegenAbility[iIndex], 0, 1);
				g_iRegenMessage[iIndex] = kvSuperTanks.GetNum("Regen Ability/Ability Message", 0);
				g_iRegenMessage[iIndex] = iClamp(g_iRegenMessage[iIndex], 0, 1);
				g_iRegenHealth[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Health", 1);
				g_iRegenHealth[iIndex] = iClamp(g_iRegenHealth[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				g_flRegenInterval[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Regen Interval", 1.0);
				g_flRegenInterval[iIndex] = flClamp(g_flRegenInterval[iIndex], 0.1, 9999999999.0);
				g_iRegenLimit[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Limit", ST_MAXHEALTH);
				g_iRegenLimit[iIndex] = iClamp(g_iRegenLimit[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iRegenAbility2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Ability Enabled", g_iRegenAbility[iIndex]);
				g_iRegenAbility2[iIndex] = iClamp(g_iRegenAbility2[iIndex], 0, 1);
				g_iRegenMessage2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Ability Message", g_iRegenMessage[iIndex]);
				g_iRegenMessage2[iIndex] = iClamp(g_iRegenMessage2[iIndex], 0, 1);
				g_iRegenHealth2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Health", g_iRegenHealth[iIndex]);
				g_iRegenHealth2[iIndex] = iClamp(g_iRegenHealth2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				g_flRegenInterval2[iIndex] = kvSuperTanks.GetFloat("Regen Ability/Regen Duration", g_flRegenInterval[iIndex]);
				g_flRegenInterval2[iIndex] = flClamp(g_flRegenInterval2[iIndex], 0.1, 9999999999.0);
				g_iRegenLimit2[iIndex] = kvSuperTanks.GetNum("Regen Ability/Regen Limit", g_iRegenLimit[iIndex]);
				g_iRegenLimit2[iIndex] = iClamp(g_iRegenLimit2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
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
	if (iRegenAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank) && !g_bRegen[tank])
	{
		g_bRegen[tank] = true;

		float flRegenInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flRegenInterval[ST_TankType(tank)] : g_flRegenInterval2[ST_TankType(tank)];
		CreateTimer(flRegenInterval, tTimerRegen, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

		if (iRegenMessage(tank) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Regen", sTankName, flRegenInterval);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bRegen[iPlayer] = false;
		}
	}
}

static int iRegenAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRegenAbility[ST_TankType(tank)] : g_iRegenAbility2[ST_TankType(tank)];
}

static int iRegenMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRegenMessage[ST_TankType(tank)] : g_iRegenMessage2[ST_TankType(tank)];
}

public Action tTimerRegen(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bRegen[iTank])
	{
		g_bRegen[iTank] = false;

		return Plugin_Stop;
	}

	if (iRegenAbility(iTank) == 0)
	{
		g_bRegen[iTank] = false;

		if (iRegenMessage(iTank) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(iTank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Regen2", sTankName);
		}

		return Plugin_Stop;
	}

	int iHealth = GetClientHealth(iTank),
		iRegenHealth = !g_bTankConfig[ST_TankType(iTank)] ? (iHealth + g_iRegenHealth[ST_TankType(iTank)]) : (iHealth + g_iRegenHealth2[ST_TankType(iTank)]),
		iRegenLimit = !g_bTankConfig[ST_TankType(iTank)] ? g_iRegenLimit[ST_TankType(iTank)] : g_iRegenLimit2[ST_TankType(iTank)],
		iExtraHealth = (iRegenHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iRegenHealth,
		iExtraHealth2 = (iRegenHealth < iHealth) ? 1 : iRegenHealth,
		iRealHealth = (iRegenHealth >= 0) ? iExtraHealth : iExtraHealth2,
		iLimitHealth = (iRealHealth > iRegenLimit) ? iRegenLimit : iRealHealth,
		iLimitHealth2 = (iRealHealth < iRegenLimit) ? iRegenLimit : iRealHealth,
		iFinalHealth = (iRegenLimit >= 0) ? iLimitHealth : iLimitHealth2;
	SetEntityHealth(iTank, iFinalHealth);

	return Plugin_Continue;
}