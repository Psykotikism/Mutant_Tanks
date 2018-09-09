// Super Tanks++: Jump Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Jump Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1];
float g_flJumpRange[ST_MAXTYPES + 1], g_flJumpRange2[ST_MAXTYPES + 1];
int g_iJumpAbility[ST_MAXTYPES + 1], g_iJumpAbility2[ST_MAXTYPES + 1], g_iJumpChance[ST_MAXTYPES + 1], g_iJumpChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Jump Ability only supports Left 4 Dead 1 & 2.");
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
			main ? (g_iJumpAbility[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Enabled", 0)) : (g_iJumpAbility2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Enabled", g_iJumpAbility[iIndex]));
			main ? (g_iJumpAbility[iIndex] = iSetCellLimit(g_iJumpAbility[iIndex], 0, 1)) : (g_iJumpAbility2[iIndex] = iSetCellLimit(g_iJumpAbility2[iIndex], 0, 1));
			main ? (g_iJumpChance[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Chance", 4)) : (g_iJumpChance2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Chance", g_iJumpChance[iIndex]));
			main ? (g_iJumpChance[iIndex] = iSetCellLimit(g_iJumpChance[iIndex], 1, 9999999999)) : (g_iJumpChance2[iIndex] = iSetCellLimit(g_iJumpChance2[iIndex], 1, 9999999999));
			main ? (g_flJumpRange[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Range", 500.0)) : (g_flJumpRange2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Range", g_flJumpRange[iIndex]));
			main ? (g_flJumpRange[iIndex] = flSetFloatLimit(g_flJumpRange[iIndex], 1.0, 9999999999.0)) : (g_flJumpRange2[iIndex] = flSetFloatLimit(g_flJumpRange2[iIndex], 1.0, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_incapacitated") == 0)
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iJumpAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && IsPlayerAlive(iTank))
		{
			vJump(iTank);
		}
	}
}

public void ST_Ability(int client)
{
	int iJumpChance = !g_bTankConfig[ST_TankType(client)] ? g_iJumpChance[ST_TankType(client)] : g_iJumpChance2[ST_TankType(client)];
	if (iJumpAbility(client) == 1 && GetRandomInt(1, iJumpChance) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		vJump(client);
	}
}

stock void vJump(int client)
{
	float flJumpRange = !g_bTankConfig[ST_TankType(client)] ? g_flJumpRange[ST_TankType(client)] : g_flJumpRange2[ST_TankType(client)],
		flTankPos[3];
	GetClientAbsOrigin(client, flTankPos);
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor))
		{
			float flSurvivorPos[3];
			GetClientAbsOrigin(iSurvivor, flSurvivorPos);
			float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
			if (flDistance <= flJumpRange)
			{
				float flVelocity[3];
				GetEntPropVector(client, Prop_Data, "m_vecVelocity", flVelocity);
				if (flVelocity[0] > 0.0 && flVelocity[0] < 500.0)
				{
					flVelocity[0] += 500.0;
				}
				else if (flVelocity[0] < 0.0 && flVelocity[0] > -500.0)
				{
					flVelocity[0] += -500.0;
				}
				if (flVelocity[1] > 0.0 && flVelocity[1] < 500.0)
				{
					flVelocity[1] += 500.0;
				}
				else if (flVelocity[1] < 0.0 && flVelocity[1] > -500.0)
				{
					flVelocity[1] += -500.0;
				}
				flVelocity[2] += 750.0;
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, flVelocity);
			}
		}
	}
}

stock int iJumpAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iJumpAbility[ST_TankType(client)] : g_iJumpAbility2[ST_TankType(client)];
}