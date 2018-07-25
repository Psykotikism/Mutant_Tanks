// Super Tanks++: Medic Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Medic Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bTankConfig[ST_MAXTYPES + 1];
char g_sMedicHealth[ST_MAXTYPES + 1][36];
char g_sMedicHealth2[ST_MAXTYPES + 1][36];
char g_sMedicMaxHealth[ST_MAXTYPES + 1][36];
char g_sMedicMaxHealth2[ST_MAXTYPES + 1][36];
float g_flMedicRange[ST_MAXTYPES + 1];
float g_flMedicRange2[ST_MAXTYPES + 1];
int g_iMedicAbility[ST_MAXTYPES + 1];
int g_iMedicAbility2[ST_MAXTYPES + 1];
int g_iMedicChance[ST_MAXTYPES + 1];
int g_iMedicChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Medic Ability only supports Left 4 Dead 1 & 2.");
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
	int iMedicAbility = !g_bTankConfig[ST_TankType(iPlayer)] ? g_iMedicAbility[ST_TankType(iPlayer)] : g_iMedicAbility2[ST_TankType(iPlayer)];
	int iMedicChance = !g_bTankConfig[ST_TankType(iPlayer)] ? g_iMedicChance[ST_TankType(iPlayer)] : g_iMedicChance2[ST_TankType(iPlayer)];
	if (iMedicAbility == 1 && GetRandomInt(1, iMedicChance) == 1)
	{
		float flMedicRange = !g_bTankConfig[ST_TankType(iPlayer)] ? g_flMedicRange[ST_TankType(iPlayer)] : g_flMedicRange2[ST_TankType(iPlayer)];
		float flTankPos[3];
		GetClientAbsOrigin(iPlayer, flTankPos);
		for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
		{
			if (bIsSpecialInfected(iInfected))
			{
				float flInfectedPos[3];
				GetClientAbsOrigin(iInfected, flInfectedPos);
				float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
				if (flDistance <= flMedicRange)
				{
					char sHealth[6][6];
					char sMedicHealth[36];
					sMedicHealth = !g_bTankConfig[ST_TankType(iPlayer)] ? g_sMedicHealth[ST_TankType(iPlayer)] : g_sMedicHealth2[ST_TankType(iPlayer)];
					TrimString(sMedicHealth);
					ExplodeString(sMedicHealth, ",", sHealth, sizeof(sHealth), sizeof(sHealth[]));
					char sMaxHealth[6][6];
					char sMedicMaxHealth[36];
					sMedicMaxHealth = !g_bTankConfig[ST_TankType(iPlayer)] ? g_sMedicMaxHealth[ST_TankType(iPlayer)] : g_sMedicMaxHealth2[ST_TankType(iPlayer)];
					TrimString(sMedicMaxHealth);
					ExplodeString(sMedicMaxHealth, ",", sMaxHealth, sizeof(sMaxHealth), sizeof(sMaxHealth[]));
					int iHealth = GetClientHealth(iInfected);
					int iSmokerHealth = (sHealth[0][0] != '\0') ? StringToInt(sHealth[0]) : 25;
					iSmokerHealth = iSetCellLimit(iSmokerHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
					int iSmokerMaxHealth = (sMaxHealth[0][0] != '\0') ? StringToInt(sMaxHealth[0]) : 250;
					int iBoomerHealth = (sHealth[1][0] != '\0') ? StringToInt(sHealth[1]) : 25;
					iBoomerHealth = iSetCellLimit(iBoomerHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
					int iBoomerMaxHealth = (sMaxHealth[1][0] != '\0') ? StringToInt(sMaxHealth[1]) : 50;
					int iHunterHealth = (sHealth[2][0] != '\0') ? StringToInt(sHealth[2]) : 25;
					iHunterHealth = iSetCellLimit(iHunterHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
					int iHunterMaxHealth = (sMaxHealth[2][0] != '\0') ? StringToInt(sMaxHealth[2]) : 250;
					int iSpitterHealth = (sHealth[3][0] != '\0') ? StringToInt(sHealth[3]) : 25;
					iSpitterHealth = iSetCellLimit(iSpitterHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
					int iSpitterMaxHealth = (sMaxHealth[3][0] != '\0') ? StringToInt(sMaxHealth[3]) : 100;
					int iJockeyHealth = (sHealth[4][0] != '\0') ? StringToInt(sHealth[4]) : 25;
					iJockeyHealth = iSetCellLimit(iJockeyHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
					int iJockeyMaxHealth = (sMaxHealth[4][0] != '\0') ? StringToInt(sMaxHealth[4]) : 325;
					int iChargerHealth = (sHealth[5][0] != '\0') ? StringToInt(sHealth[5]) : 25;
					iChargerHealth = iSetCellLimit(iChargerHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
					int iChargerMaxHealth = (sMaxHealth[5][0] != '\0') ? StringToInt(sMaxHealth[5]) : 600;
					if (bIsSmoker(iInfected))
					{
						vMedic(iInfected, iHealth, iHealth + iSmokerHealth, iSmokerMaxHealth);
					}
					else if (bIsBoomer(iInfected))
					{
						vMedic(iInfected, iHealth, iHealth + iBoomerHealth, iBoomerMaxHealth);
					}
					else if (bIsHunter(iInfected))
					{
						vMedic(iInfected, iHealth, iHealth + iHunterHealth, iHunterMaxHealth);
					}
					else if (bIsSpitter(iInfected))
					{
						vMedic(iInfected, iHealth, iHealth + iSpitterHealth, iSpitterMaxHealth);
					}
					else if (bIsJockey(iInfected))
					{
						vMedic(iInfected, iHealth, iHealth + iJockeyHealth, iJockeyMaxHealth);
					}
					else if (bIsCharger(iInfected))
					{
						vMedic(iInfected, iHealth, iHealth + iChargerHealth, iChargerMaxHealth);
					}
				}
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
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iMedicAbility[iIndex] = kvSuperTanks.GetNum("Medic Ability/Ability Enabled", 0)) : (g_iMedicAbility2[iIndex] = kvSuperTanks.GetNum("Medic Ability/Ability Enabled", g_iMedicAbility[iIndex]));
			main ? (g_iMedicAbility[iIndex] = iSetCellLimit(g_iMedicAbility[iIndex], 0, 1)) : (g_iMedicAbility2[iIndex] = iSetCellLimit(g_iMedicAbility2[iIndex], 0, 1));
			main ? (g_iMedicChance[iIndex] = kvSuperTanks.GetNum("Medic Ability/Medic Chance", 4)) : (g_iMedicChance2[iIndex] = kvSuperTanks.GetNum("Medic Ability/Medic Chance", g_iMedicChance[iIndex]));
			main ? (g_iMedicChance[iIndex] = iSetCellLimit(g_iMedicChance[iIndex], 1, 9999999999)) : (g_iMedicChance2[iIndex] = iSetCellLimit(g_iMedicChance2[iIndex], 1, 9999999999));
			main ? (kvSuperTanks.GetString("Medic Ability/Medic Health", g_sMedicHealth[iIndex], sizeof(g_sMedicHealth[]), "25,25,25,25,25,25")) : (kvSuperTanks.GetString("Medic Ability/Medic Health", g_sMedicHealth2[iIndex], sizeof(g_sMedicHealth2[]), g_sMedicHealth[iIndex]));
			main ? (kvSuperTanks.GetString("Medic Ability/Medic Max Health", g_sMedicMaxHealth[iIndex], sizeof(g_sMedicMaxHealth[]), "250,50,250,100,325,600")) : (kvSuperTanks.GetString("Medic Ability/Medic Max Health", g_sMedicMaxHealth2[iIndex], sizeof(g_sMedicMaxHealth2[]), g_sMedicMaxHealth[iIndex]));
			main ? (g_flMedicRange[iIndex] = kvSuperTanks.GetFloat("Medic Ability/Medic Range", 500.0)) : (g_flMedicRange2[iIndex] = kvSuperTanks.GetFloat("Medic Ability/Medic Range", g_flMedicRange[iIndex]));
			main ? (g_flMedicRange[iIndex] = flSetFloatLimit(g_flMedicRange[iIndex], 1.0, 9999999999.0)) : (g_flMedicRange2[iIndex] = flSetFloatLimit(g_flMedicRange2[iIndex], 1.0, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

void vMedic(int client, int health, int extrahealth, int maxhealth)
{
	maxhealth = iSetCellLimit(maxhealth, 1, ST_MAXHEALTH);
	int iExtraHealth = (extrahealth > maxhealth) ? maxhealth : extrahealth;
	int iExtraHealth2 = (extrahealth < health) ? 1 : extrahealth;
	int iRealHealth = (extrahealth >= 0) ? iExtraHealth : iExtraHealth2;
	SetEntityHealth(client, iRealHealth);
}