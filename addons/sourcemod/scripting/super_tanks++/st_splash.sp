// Super Tanks++: Splash Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Splash Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flSplashRange[ST_MAXTYPES + 1];
float g_flSplashRange2[ST_MAXTYPES + 1];
int g_iSplashAbility[ST_MAXTYPES + 1];
int g_iSplashAbility2[ST_MAXTYPES + 1];
int g_iSplashChance[ST_MAXTYPES + 1];
int g_iSplashChance2[ST_MAXTYPES + 1];
int g_iSplashDamage[ST_MAXTYPES + 1];
int g_iSplashDamage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Splash Ability only supports Left 4 Dead 1 & 2.");
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

public void OnConfigsExecuted()
{
	char sMapName[128];
	GetCurrentMap(sMapName, sizeof(sMapName));
	if (IsMapValid(sMapName))
	{
		vIsPluginAllowed();
	}
}

void vIsPluginAllowed()
{
	ST_PluginEnabled() ? vHookEvent(true) : vHookEvent(false);
}

void vHookEvent(bool hook)
{
	static bool hooked;
	if (hook && !hooked)
	{
		HookEvent("player_death", eEventPlayerDeath);
		hooked = true;
	}
	else if (!hook && hooked)
	{
		UnhookEvent("player_death", eEventPlayerDeath);
		hooked = false;
	}
}

public Action eEventPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int iUserId = event.GetInt("userid");
	int iPlayer = GetClientOfUserId(iUserId);
	int iSplashAbility = !g_bTankConfig[ST_TankType(iPlayer)] ? g_iSplashAbility[ST_TankType(iPlayer)] : g_iSplashAbility2[ST_TankType(iPlayer)];
	int iSplashChance = !g_bTankConfig[ST_TankType(iPlayer)] ? g_iSplashChance[ST_TankType(iPlayer)] : g_iSplashChance2[ST_TankType(iPlayer)];
	if (iSplashAbility == 1 && GetRandomInt(1, iSplashChance) == 1 && bIsTank(iPlayer))
	{
		CreateTimer(0.1, tTimerSplash, iUserId, TIMER_FLAG_NO_MAPCHANGE);
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
			main ? (g_iSplashAbility[iIndex] = kvSuperTanks.GetNum("Splash Ability/Ability Enabled", 0)) : (g_iSplashAbility2[iIndex] = kvSuperTanks.GetNum("Splash Ability/Ability Enabled", g_iSplashAbility[iIndex]));
			main ? (g_iSplashAbility[iIndex] = iSetCellLimit(g_iSplashAbility[iIndex], 0, 1)) : (g_iSplashAbility2[iIndex] = iSetCellLimit(g_iSplashAbility2[iIndex], 0, 1));
			main ? (g_iSplashChance[iIndex] = kvSuperTanks.GetNum("Splash Ability/Splash Chance", 4)) : (g_iSplashChance2[iIndex] = kvSuperTanks.GetNum("Splash Ability/Splash Chance", g_iSplashChance[iIndex]));
			main ? (g_iSplashChance[iIndex] = iSetCellLimit(g_iSplashChance[iIndex], 1, 9999999999)) : (g_iSplashChance2[iIndex] = iSetCellLimit(g_iSplashChance2[iIndex], 1, 9999999999));
			main ? (g_iSplashDamage[iIndex] = kvSuperTanks.GetNum("Splash Ability/Splash Damage", 1)) : (g_iSplashDamage2[iIndex] = kvSuperTanks.GetNum("Splash Ability/Splash Damage", g_iSplashDamage[iIndex]));
			main ? (g_iSplashDamage[iIndex] = iSetCellLimit(g_iSplashDamage[iIndex], 1, 9999999999)) : (g_iSplashDamage2[iIndex] = iSetCellLimit(g_iSplashDamage2[iIndex], 1, 9999999999));
			main ? (g_flSplashRange[iIndex] = kvSuperTanks.GetFloat("Splash Ability/Splash Range", 500.0)) : (g_flSplashRange2[iIndex] = kvSuperTanks.GetFloat("Splash Ability/Splash Range", g_flSplashRange[iIndex]));
			main ? (g_flSplashRange[iIndex] = flSetFloatLimit(g_flSplashRange[iIndex], 1.0, 9999999999.0)) : (g_flSplashRange2[iIndex] = flSetFloatLimit(g_flSplashRange2[iIndex], 1.0, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

bool bIsValidEntity(int entity)
{
	return entity > 0 && entity <= 2048 && IsValidEntity(entity);
}

public bool bTraceRayDontHitSelfAndEntity(int entity, int mask)
{
	if (!bIsValidEntity(entity))
	{
		return false;
	}
	return true;
}

bool bVisiblePosition(float pos1[3], float pos2[3])
{
	Handle hTrace = TR_TraceRayFilterEx(pos2, pos1, MASK_SOLID, RayType_EndPoint, bTraceRayDontHitSelfAndEntity);
	if (TR_DidHit(hTrace))
	{
		return false;
	}
	delete hTrace;
	return true;
}

public Action tTimerSplash(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	if (bIsTank(iTank))
	{
		float flSplashRange = !g_bTankConfig[ST_TankType(iTank)] ? g_flSplashRange[ST_TankType(iTank)] : g_flSplashRange2[ST_TankType(iTank)];
		float flTankPos[3];
		GetClientEyePosition(iTank, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientEyePosition(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flSplashRange && bVisiblePosition(flTankPos, flSurvivorPos))
				{
					char sDamage[6];
					int iSplashDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_iSplashDamage[ST_TankType(iTank)] : g_iSplashDamage2[ST_TankType(iTank)];
					IntToString(iSplashDamage, sDamage, sizeof(sDamage));
					int iPointHurt = CreateEntityByName("point_hurt");
					if (bIsValidEntity(iPointHurt))
					{
						DispatchKeyValue(iSurvivor, "targetname", "hurtme");
						DispatchKeyValue(iPointHurt, "Damage", sDamage);
						DispatchKeyValue(iPointHurt, "DamageTarget", "hurtme");
						DispatchKeyValue(iPointHurt, "DamageType", "65536");
						DispatchSpawn(iPointHurt);
						AcceptEntityInput(iPointHurt, "Hurt", iSurvivor);
						AcceptEntityInput(iPointHurt, "Kill");
						DispatchKeyValue(iSurvivor, "targetname", "donthurtme");
					}
				}
			}
		}
	}
	return Plugin_Continue;
}