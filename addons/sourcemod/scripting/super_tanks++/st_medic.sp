// Super Tanks++: Medic Ability
#define REQUIRE_PLUGIN
#include <super_tanks++>
#undef REQUIRE_PLUGIN
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Medic Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bTankConfig[ST_MAXTYPES + 1];
char g_sMedicHealth[ST_MAXTYPES + 1][36], g_sMedicHealth2[ST_MAXTYPES + 1][36], g_sMedicMaxHealth[ST_MAXTYPES + 1][36], g_sMedicMaxHealth2[ST_MAXTYPES + 1][36];
float g_flMedicRange[ST_MAXTYPES + 1], g_flMedicRange2[ST_MAXTYPES + 1];
int g_iMedicAbility[ST_MAXTYPES + 1], g_iMedicAbility2[ST_MAXTYPES + 1], g_iMedicChance[ST_MAXTYPES + 1], g_iMedicChance2[ST_MAXTYPES + 1];

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

public void ST_Configs(char[] savepath, bool main)
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

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId),
			iMedicAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iMedicAbility[ST_TankType(iTank)] : g_iMedicAbility2[ST_TankType(iTank)],
			iMedicChance = !g_bTankConfig[ST_TankType(iTank)] ? g_iMedicChance[ST_TankType(iTank)] : g_iMedicChance2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iMedicAbility == 1 && GetRandomInt(1, iMedicChance) == 1)
		{
			vMedic(iTank);
		}
	}
}

public void ST_BossStage(int client)
{
	int iMedicAbility = !g_bTankConfig[ST_TankType(client)] ? g_iMedicAbility[ST_TankType(client)] : g_iMedicAbility2[ST_TankType(client)],
		iMedicChance = !g_bTankConfig[ST_TankType(client)] ? g_iMedicChance[ST_TankType(client)] : g_iMedicChance2[ST_TankType(client)];
	if (ST_TankAllowed(client) && iMedicAbility == 1 && GetRandomInt(1, iMedicChance) == 1)
	{
		vMedic(client);
	}
}

void vMedic(int client)
{
	float flMedicRange = !g_bTankConfig[ST_TankType(client)] ? g_flMedicRange[ST_TankType(client)] : g_flMedicRange2[ST_TankType(client)],
		flTankPos[3];
	GetClientAbsOrigin(client, flTankPos);
	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (bIsSpecialInfected(iInfected))
		{
			float flInfectedPos[3];
			GetClientAbsOrigin(iInfected, flInfectedPos);
			float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
			if (flDistance <= flMedicRange)
			{
				char sHealth[6][6], sMedicHealth[36], sMaxHealth[6][6], sMedicMaxHealth[36];
				sMedicHealth = !g_bTankConfig[ST_TankType(client)] ? g_sMedicHealth[ST_TankType(client)] : g_sMedicHealth2[ST_TankType(client)];
				TrimString(sMedicHealth);
				ExplodeString(sMedicHealth, ",", sHealth, sizeof(sHealth), sizeof(sHealth[]));
				sMedicMaxHealth = !g_bTankConfig[ST_TankType(client)] ? g_sMedicMaxHealth[ST_TankType(client)] : g_sMedicMaxHealth2[ST_TankType(client)];
				TrimString(sMedicMaxHealth);
				ExplodeString(sMedicMaxHealth, ",", sMaxHealth, sizeof(sMaxHealth), sizeof(sMaxHealth[]));
				int iHealth = GetClientHealth(iInfected),
					iSmokerHealth = (sHealth[0][0] != '\0') ? StringToInt(sHealth[0]) : 25,
					iSmokerMaxHealth = (sMaxHealth[0][0] != '\0') ? StringToInt(sMaxHealth[0]) : 250,
					iBoomerHealth = (sHealth[1][0] != '\0') ? StringToInt(sHealth[1]) : 25,
					iBoomerMaxHealth = (sMaxHealth[1][0] != '\0') ? StringToInt(sMaxHealth[1]) : 50,
					iHunterHealth = (sHealth[2][0] != '\0') ? StringToInt(sHealth[2]) : 25,
					iHunterMaxHealth = (sMaxHealth[2][0] != '\0') ? StringToInt(sMaxHealth[2]) : 250,
					iSpitterHealth = (sHealth[3][0] != '\0') ? StringToInt(sHealth[3]) : 25,
					iSpitterMaxHealth = (sMaxHealth[3][0] != '\0') ? StringToInt(sMaxHealth[3]) : 100,
					iJockeyHealth = (sHealth[4][0] != '\0') ? StringToInt(sHealth[4]) : 25,
					iJockeyMaxHealth = (sMaxHealth[4][0] != '\0') ? StringToInt(sMaxHealth[4]) : 325,
					iChargerHealth = (sHealth[5][0] != '\0') ? StringToInt(sHealth[5]) : 25,
					iChargerMaxHealth = (sMaxHealth[5][0] != '\0') ? StringToInt(sMaxHealth[5]) : 600;
				iSmokerHealth = iSetCellLimit(iSmokerHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				iSmokerMaxHealth = iSetCellLimit(iSmokerMaxHealth, 1, ST_MAXHEALTH);
				iBoomerHealth = iSetCellLimit(iBoomerHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				iBoomerMaxHealth = iSetCellLimit(iBoomerMaxHealth, 1, ST_MAXHEALTH);
				iHunterHealth = iSetCellLimit(iHunterHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				iHunterMaxHealth = iSetCellLimit(iHunterMaxHealth, 1, ST_MAXHEALTH);
				iSpitterHealth = iSetCellLimit(iSpitterHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				iSpitterMaxHealth = iSetCellLimit(iSpitterMaxHealth, 1, ST_MAXHEALTH);
				iJockeyHealth = iSetCellLimit(iJockeyHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				iJockeyMaxHealth = iSetCellLimit(iJockeyMaxHealth, 1, ST_MAXHEALTH);
				iChargerHealth = iSetCellLimit(iChargerHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				iChargerMaxHealth = iSetCellLimit(iChargerMaxHealth, 1, ST_MAXHEALTH);
				if (bIsSmoker(iInfected) && IsPlayerAlive(iInfected))
				{
					vHeal(iInfected, iHealth, iHealth + iSmokerHealth, iSmokerMaxHealth);
				}
				else if (bIsBoomer(iInfected) && IsPlayerAlive(iInfected))
				{
					vHeal(iInfected, iHealth, iHealth + iBoomerHealth, iBoomerMaxHealth);
				}
				else if (bIsHunter(iInfected) && IsPlayerAlive(iInfected))
				{
					vHeal(iInfected, iHealth, iHealth + iHunterHealth, iHunterMaxHealth);
				}
				else if (bIsSpitter(iInfected) && IsPlayerAlive(iInfected))
				{
					vHeal(iInfected, iHealth, iHealth + iSpitterHealth, iSpitterMaxHealth);
				}
				else if (bIsJockey(iInfected) && IsPlayerAlive(iInfected))
				{
					vHeal(iInfected, iHealth, iHealth + iJockeyHealth, iJockeyMaxHealth);
				}
				else if (bIsCharger(iInfected) && IsPlayerAlive(iInfected))
				{
					vHeal(iInfected, iHealth, iHealth + iChargerHealth, iChargerMaxHealth);
				}
			}
		}
	}
}