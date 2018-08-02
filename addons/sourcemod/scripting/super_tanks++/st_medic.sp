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

public void OnPluginStart()
{
	vCreateInfoFile("cfg/sourcemod/super_tanks++/", "information/", "st_medic", "st_medic");
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

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid");
		int iTank = GetClientOfUserId(iTankId);
		int iMedicAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iMedicAbility[ST_TankType(iTank)] : g_iMedicAbility2[ST_TankType(iTank)];
		int iMedicChance = !g_bTankConfig[ST_TankType(iTank)] ? g_iMedicChance[ST_TankType(iTank)] : g_iMedicChance2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iMedicAbility == 1 && GetRandomInt(1, iMedicChance) == 1)
		{
			float flMedicRange = !g_bTankConfig[ST_TankType(iTank)] ? g_flMedicRange[ST_TankType(iTank)] : g_flMedicRange2[ST_TankType(iTank)];
			float flTankPos[3];
			GetClientAbsOrigin(iTank, flTankPos);
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
						sMedicHealth = !g_bTankConfig[ST_TankType(iTank)] ? g_sMedicHealth[ST_TankType(iTank)] : g_sMedicHealth2[ST_TankType(iTank)];
						TrimString(sMedicHealth);
						ExplodeString(sMedicHealth, ",", sHealth, sizeof(sHealth), sizeof(sHealth[]));
						char sMaxHealth[6][6];
						char sMedicMaxHealth[36];
						sMedicMaxHealth = !g_bTankConfig[ST_TankType(iTank)] ? g_sMedicMaxHealth[ST_TankType(iTank)] : g_sMedicMaxHealth2[ST_TankType(iTank)];
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
	}
}

void vCreateInfoFile(const char[] filepath, const char[] folder, const char[] filename, const char[] label = "")
{
	char sConfigFilename[128];
	char sConfigLabel[128];
	File fFilename;
	Format(sConfigFilename, sizeof(sConfigFilename), "%s%s%s.txt", filepath, folder, filename);
	if (FileExists(sConfigFilename))
	{
		return;
	}
	fFilename = OpenFile(sConfigFilename, "w+");
	strlen(label) > 0 ? strcopy(sConfigLabel, sizeof(sConfigLabel), label) : strcopy(sConfigLabel, sizeof(sConfigLabel), sConfigFilename);
	if (fFilename != null)
	{
		fFilename.WriteLine("// Note: The config will automatically update any changes mid-game. No need to restart the server or reload the plugin.");
		fFilename.WriteLine("\"Super Tanks++\"");
		fFilename.WriteLine("{");
		fFilename.WriteLine("	\"Example\"");
		fFilename.WriteLine("	{");
		fFilename.WriteLine("		// The Super Tank heals special infected upon death.");
		fFilename.WriteLine("		// Requires \"st_medic.smx\" to be installed.");
		fFilename.WriteLine("		\"Medic Ability\"");
		fFilename.WriteLine("		{");
		fFilename.WriteLine("			// Enable this ability.");
		fFilename.WriteLine("			// 0: OFF");
		fFilename.WriteLine("			// 1: ON");
		fFilename.WriteLine("			\"Ability Enabled\"				\"0\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank has 1 out of this many chances to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1 (Greatest chance)");
		fFilename.WriteLine("			// Maximum: 9999999999 (Less chance)");
		fFilename.WriteLine("			\"Medic Chance\"					\"4\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The Super Tank gives special infected this much health each time.");
		fFilename.WriteLine("			// 1st number = Health given to Smokers.");
		fFilename.WriteLine("			// 2nd number = Health given to Boomers.");
		fFilename.WriteLine("			// 3rd number = Health given to Hunters.");
		fFilename.WriteLine("			// 4th number = Health given to Spitters.");
		fFilename.WriteLine("			// 5th number = Health given to Jockeys.");
		fFilename.WriteLine("			// 6th number = Health given to Chargers.");
		fFilename.WriteLine("			// Positive numbers: Current health + Medic health");
		fFilename.WriteLine("			// Negative numbers: Current health - Medic health");
		fFilename.WriteLine("			// Minimum: -65535");
		fFilename.WriteLine("			// Maximum: 65535");
		fFilename.WriteLine("			\"Medic Health\"					\"25,25,25,25,25,25\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The special infected's max health.");
		fFilename.WriteLine("			// The Super Tank will not heal special infected if they already have this much health.");
		fFilename.WriteLine("			// 1st number = Smoker's maximum health.");
		fFilename.WriteLine("			// 2nd number = Boomer's maximum health.");
		fFilename.WriteLine("			// 3rd number = Hunter's maximum health.");
		fFilename.WriteLine("			// 4th number = Spitter's maximum health.");
		fFilename.WriteLine("			// 5th number = Jockey's maximum health.");
		fFilename.WriteLine("			// 6th number = Charger's maximum health.");
		fFilename.WriteLine("			// Minimum: 1");
		fFilename.WriteLine("			// Maximum: 65535");
		fFilename.WriteLine("			\"Medic Max Health\"				\"250,50,250,100,325,600\"");
		fFilename.WriteLine("");
		fFilename.WriteLine("			// The distance between a survivor and the Super Tank needed to trigger the ability.");
		fFilename.WriteLine("			// Minimum: 1.0 (Closest)");
		fFilename.WriteLine("			// Maximum: 9999999999.0 (Farthest)");
		fFilename.WriteLine("			\"Medic Range\"					\"500.0\"");
		fFilename.WriteLine("		}");
		fFilename.WriteLine("	}");
		fFilename.WriteLine("}");
		delete fFilename;
	}
}