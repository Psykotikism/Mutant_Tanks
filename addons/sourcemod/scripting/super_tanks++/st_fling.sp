// Super Tanks++: Fling Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Fling Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flFlingRange[ST_MAXTYPES + 1];
float g_flFlingRange2[ST_MAXTYPES + 1];
Handle g_hSDKFlingPlayer;
Handle g_hSDKPukePlayer;
int g_iFlingAbility[ST_MAXTYPES + 1];
int g_iFlingAbility2[ST_MAXTYPES + 1];
int g_iFlingChance[ST_MAXTYPES + 1];
int g_iFlingChance2[ST_MAXTYPES + 1];
int g_iFlingHit[ST_MAXTYPES + 1];
int g_iFlingHit2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Fling Ability only supports Left 4 Dead 1 & 2.");
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
	Handle hGameData = LoadGameConfigFile("super_tanks++");
	if (bIsL4D2Game())
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer_Fling");
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		g_hSDKFlingPlayer = EndPrepSDKCall();
		if (g_hSDKFlingPlayer == null)
		{
			PrintToServer("%s Your \"CTerrorPlayer_Fling\" signature is outdated.", ST_PREFIX);
		}
	}
	else
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		g_hSDKPukePlayer = EndPrepSDKCall();
		if (g_hSDKPukePlayer == null)
		{
			PrintToServer("%s Your \"CTerrorPlayer_OnVomitedUpon\" signature is outdated.", ST_PREFIX);
		}
	}
}

public void OnMapStart()
{
	if (g_bLateLoad)
	{
		vLateLoad(true);
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
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
		if (bIsTank(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iFlingHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iFlingHit[ST_TankType(attacker)] : g_iFlingHit2[ST_TankType(attacker)];
				vFlingHit(victim, attacker, iFlingHit);
			}
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
			main ? (g_iFlingAbility[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Enabled", 0)) : (g_iFlingAbility2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Ability Enabled", g_iFlingAbility[iIndex]));
			main ? (g_iFlingAbility[iIndex] = iSetCellLimit(g_iFlingAbility[iIndex], 0, 1)) : (g_iFlingAbility2[iIndex] = iSetCellLimit(g_iFlingAbility2[iIndex], 0, 1));
			main ? (g_iFlingChance[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Chance", 4)) : (g_iFlingChance2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Chance", g_iFlingChance[iIndex]));
			main ? (g_iFlingChance[iIndex] = iSetCellLimit(g_iFlingChance[iIndex], 1, 9999999999)) : (g_iFlingChance2[iIndex] = iSetCellLimit(g_iFlingChance2[iIndex], 1, 9999999999));
			main ? (g_iFlingHit[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit", 0)) : (g_iFlingHit2[iIndex] = kvSuperTanks.GetNum("Fling Ability/Fling Hit", g_iFlingHit[iIndex]));
			main ? (g_iFlingHit[iIndex] = iSetCellLimit(g_iFlingHit[iIndex], 0, 1)) : (g_iFlingHit2[iIndex] = iSetCellLimit(g_iFlingHit2[iIndex], 0, 1));
			main ? (g_flFlingRange[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range", 150.0)) : (g_flFlingRange2[iIndex] = kvSuperTanks.GetFloat("Fling Ability/Fling Range", g_flFlingRange[iIndex]));
			main ? (g_flFlingRange[iIndex] = flSetFloatLimit(g_flFlingRange[iIndex], 1.0, 9999999999.0)) : (g_flFlingRange2[iIndex] = flSetFloatLimit(g_flFlingRange2[iIndex], 1.0, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (bIsTank(client))
	{
		int iFlingAbility = !g_bTankConfig[ST_TankType(client)] ? g_iFlingAbility[ST_TankType(client)] : g_iFlingAbility2[ST_TankType(client)];
		float flFlingRange = !g_bTankConfig[ST_TankType(client)] ? g_flFlingRange[ST_TankType(client)] : g_flFlingRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flFlingRange)
				{
					vFlingHit(iSurvivor, client, iFlingAbility);
				}
			}
		}
	}
}

void vFlingHit(int client, int owner, int enabled)
{
	int iFlingChance = !g_bTankConfig[ST_TankType(owner)] ? g_iFlingChance[ST_TankType(owner)] : g_iFlingChance2[ST_TankType(owner)];
	if (enabled == 1 && GetRandomInt(1, iFlingChance) == 1 && bIsSurvivor(client))
	{
		if (bIsL4D2Game())
		{
			float flTpos[3];
			float flSpos[3];
			float flDistance[3];
			float flRatio[3];
			float flAddVel[3];
			float flTvec[3];
			GetClientAbsOrigin(client, flTpos);
			GetClientAbsOrigin(owner, flSpos);
			flDistance[0] = (flSpos[0] - flTpos[0]);
			flDistance[1] = (flSpos[1] - flTpos[1]);
			flDistance[2] = (flSpos[2] - flTpos[2]);
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", flTvec);
			flRatio[0] =  FloatDiv(flDistance[0], SquareRoot(flDistance[1] * flDistance[1] + flDistance[0] * flDistance[0]));
			flRatio[1] =  FloatDiv(flDistance[1], SquareRoot(flDistance[1] * flDistance[1] + flDistance[0] * flDistance[0]));
			flAddVel[0] = FloatMul(flRatio[0] * -1, 500.0);
			flAddVel[1] = FloatMul(flRatio[1] * -1, 500.0);
			flAddVel[2] = 500.0;
			SDKCall(g_hSDKFlingPlayer, client, flAddVel, 76, owner, 7.0);
		}
		else
		{
			SDKCall(g_hSDKPukePlayer, client, owner, true);
		}
	}
}