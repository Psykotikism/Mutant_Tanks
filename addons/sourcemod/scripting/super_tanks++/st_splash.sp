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
float g_flSplashInterval[ST_MAXTYPES + 1];
float g_flSplashInterval2[ST_MAXTYPES + 1];
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
			main ? (g_iSplashDamage[iIndex] = kvSuperTanks.GetNum("Splash Ability/Splash Damage", 5)) : (g_iSplashDamage2[iIndex] = kvSuperTanks.GetNum("Splash Ability/Splash Damage", g_iSplashDamage[iIndex]));
			main ? (g_iSplashDamage[iIndex] = iSetCellLimit(g_iSplashDamage[iIndex], 1, 9999999999)) : (g_iSplashDamage2[iIndex] = iSetCellLimit(g_iSplashDamage2[iIndex], 1, 9999999999));
			main ? (g_flSplashInterval[iIndex] = kvSuperTanks.GetFloat("Splash Ability/Splash Interval", 5.0)) : (g_flSplashInterval2[iIndex] = kvSuperTanks.GetFloat("Splash Ability/Splash Interval", g_flSplashInterval[iIndex]));
			main ? (g_flSplashInterval[iIndex] = flSetFloatLimit(g_flSplashInterval[iIndex], 0.1, 9999999999.0)) : (g_flSplashInterval2[iIndex] = flSetFloatLimit(g_flSplashInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_flSplashRange[iIndex] = kvSuperTanks.GetFloat("Splash Ability/Splash Range", 500.0)) : (g_flSplashRange2[iIndex] = kvSuperTanks.GetFloat("Splash Ability/Splash Range", g_flSplashRange[iIndex]));
			main ? (g_flSplashRange[iIndex] = flSetFloatLimit(g_flSplashRange[iIndex], 1.0, 9999999999.0)) : (g_flSplashRange2[iIndex] = flSetFloatLimit(g_flSplashRange2[iIndex], 1.0, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_incapacitated") == 0)
	{
		int iTankId = event.GetInt("userid");
		int iTank = GetClientOfUserId(iTankId);
		int iSplashAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iSplashAbility[ST_TankType(iTank)] : g_iSplashAbility2[ST_TankType(iTank)];
		int iSplashChance = !g_bTankConfig[ST_TankType(iTank)] ? g_iSplashChance[ST_TankType(iTank)] : g_iSplashChance2[ST_TankType(iTank)];
		if (iSplashAbility == 1 && GetRandomInt(1, iSplashChance) == 1 && ST_TankAllowed(iTank))
		{
			CreateTimer(0.4, tTimerSplash, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public void ST_Ability(int client)
{
	int iSplashAbility = !g_bTankConfig[ST_TankType(client)] ? g_iSplashAbility[ST_TankType(client)] : g_iSplashAbility2[ST_TankType(client)];
	int iSplashChance = !g_bTankConfig[ST_TankType(client)] ? g_iSplashChance[ST_TankType(client)] : g_iSplashChance2[ST_TankType(client)];
	if (iSplashAbility == 1 && GetRandomInt(1, iSplashChance) == 1 && ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		float flSplashInterval = !g_bTankConfig[ST_TankType(client)] ? g_flSplashInterval[ST_TankType(client)] : g_flSplashInterval2[ST_TankType(client)];
		CreateTimer(flSplashInterval, tTimerSplash, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

public Action tTimerSplash(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iSplashAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iSplashAbility[ST_TankType(iTank)] : g_iSplashAbility2[ST_TankType(iTank)];
	if (iSplashAbility == 0)
	{
		return Plugin_Stop;
	}
	float flSplashRange = !g_bTankConfig[ST_TankType(iTank)] ? g_flSplashRange[ST_TankType(iTank)] : g_flSplashRange2[ST_TankType(iTank)];
	float flTankPos[3];
	GetClientAbsOrigin(iTank, flTankPos);
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor))
		{
			float flSurvivorPos[3];
			GetClientAbsOrigin(iSurvivor, flSurvivorPos);
			float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
			if (flDistance <= flSplashRange)
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
					DispatchKeyValue(iPointHurt, "DamageType", "2");
					DispatchSpawn(iPointHurt);
					AcceptEntityInput(iPointHurt, "Hurt", iSurvivor);
					AcceptEntityInput(iPointHurt, "Kill");
					DispatchKeyValue(iSurvivor, "targetname", "donthurtme");
				}
			}
		}
	}
	return Plugin_Continue;
}