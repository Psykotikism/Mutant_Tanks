// Super Tanks++: Medic Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Medic Ability",
	author = ST_AUTHOR,
	description = "The Super Tank heals special infected upon death.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1];
char g_sMedicHealth[ST_MAXTYPES + 1][36], g_sMedicHealth2[ST_MAXTYPES + 1][36], g_sMedicMaxHealth[ST_MAXTYPES + 1][36], g_sMedicMaxHealth2[ST_MAXTYPES + 1][36];
float g_flMedicRange[ST_MAXTYPES + 1], g_flMedicRange2[ST_MAXTYPES + 1];
int g_iMedicAbility[ST_MAXTYPES + 1], g_iMedicAbility2[ST_MAXTYPES + 1], g_iMedicChance[ST_MAXTYPES + 1], g_iMedicChance2[ST_MAXTYPES + 1], g_iMedicMessage[ST_MAXTYPES + 1], g_iMedicMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_Left4Dead && !bIsL4D2())
	{
		strcopy(error, err_max, "[ST++] Medic Ability only supports Left 4 Dead 1 & 2.");
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

public void OnPluginStart()
{
	LoadTranslations("super_tanks++.phrases");
}

public void ST_Configs(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sName[MAX_NAME_LENGTH + 1];
		Format(sName, sizeof(sName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iMedicAbility[iIndex] = kvSuperTanks.GetNum("Medic Ability/Ability Enabled", 0)) : (g_iMedicAbility2[iIndex] = kvSuperTanks.GetNum("Medic Ability/Ability Enabled", g_iMedicAbility[iIndex]));
			main ? (g_iMedicAbility[iIndex] = iClamp(g_iMedicAbility[iIndex], 0, 1)) : (g_iMedicAbility2[iIndex] = iClamp(g_iMedicAbility2[iIndex], 0, 1));
			main ? (g_iMedicMessage[iIndex] = kvSuperTanks.GetNum("Medic Ability/Ability Message", 0)) : (g_iMedicMessage2[iIndex] = kvSuperTanks.GetNum("Medic Ability/Ability Message", g_iMedicMessage[iIndex]));
			main ? (g_iMedicMessage[iIndex] = iClamp(g_iMedicMessage[iIndex], 0, 1)) : (g_iMedicMessage2[iIndex] = iClamp(g_iMedicMessage2[iIndex], 0, 1));
			main ? (g_iMedicChance[iIndex] = kvSuperTanks.GetNum("Medic Ability/Medic Chance", 4)) : (g_iMedicChance2[iIndex] = kvSuperTanks.GetNum("Medic Ability/Medic Chance", g_iMedicChance[iIndex]));
			main ? (g_iMedicChance[iIndex] = iClamp(g_iMedicChance[iIndex], 1, 9999999999)) : (g_iMedicChance2[iIndex] = iClamp(g_iMedicChance2[iIndex], 1, 9999999999));
			main ? (kvSuperTanks.GetString("Medic Ability/Medic Health", g_sMedicHealth[iIndex], sizeof(g_sMedicHealth[]), "25,25,25,25,25,25")) : (kvSuperTanks.GetString("Medic Ability/Medic Health", g_sMedicHealth2[iIndex], sizeof(g_sMedicHealth2[]), g_sMedicHealth[iIndex]));
			main ? (kvSuperTanks.GetString("Medic Ability/Medic Max Health", g_sMedicMaxHealth[iIndex], sizeof(g_sMedicMaxHealth[]), "250,50,250,100,325,600")) : (kvSuperTanks.GetString("Medic Ability/Medic Max Health", g_sMedicMaxHealth2[iIndex], sizeof(g_sMedicMaxHealth2[]), g_sMedicMaxHealth[iIndex]));
			main ? (g_flMedicRange[iIndex] = kvSuperTanks.GetFloat("Medic Ability/Medic Range", 500.0)) : (g_flMedicRange2[iIndex] = kvSuperTanks.GetFloat("Medic Ability/Medic Range", g_flMedicRange[iIndex]));
			main ? (g_flMedicRange[iIndex] = flClamp(g_flMedicRange[iIndex], 1.0, 9999999999.0)) : (g_flMedicRange2[iIndex] = flClamp(g_flMedicRange2[iIndex], 1.0, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iMedicAbility(iTank) == 1 && GetRandomInt(1, iMedicChance(iTank)) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vMedic(iTank);
		}
	}
}

public void ST_BossStage(int client)
{
	if (iMedicAbility(client) == 1 && GetRandomInt(1, iMedicChance(client)) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled))
	{
		vMedic(client);
	}
}

stock void vMedic(int client)
{
	float flMedicRange = !g_bTankConfig[ST_TankType(client)] ? g_flMedicRange[ST_TankType(client)] : g_flMedicRange2[ST_TankType(client)],
		flTankPos[3];
	int iMedicMessage = !g_bTankConfig[ST_TankType(client)] ? g_iMedicMessage[ST_TankType(client)] : g_iMedicMessage2[ST_TankType(client)];
	GetClientAbsOrigin(client, flTankPos);
	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (bIsSpecialInfected(iInfected) && IsPlayerAlive(iInfected))
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
					iSmokerHealth = (strcmp(sHealth[0], "") == 1) ? StringToInt(sHealth[0]) : 25,
					iSmokerMaxHealth = (strcmp(sMaxHealth[0], "") == 1) ? StringToInt(sMaxHealth[0]) : 250,
					iBoomerHealth = (strcmp(sHealth[1], "") == 1) ? StringToInt(sHealth[1]) : 25,
					iBoomerMaxHealth = (strcmp(sMaxHealth[1], "") == 1) ? StringToInt(sMaxHealth[1]) : 50,
					iHunterHealth = (strcmp(sHealth[2], "") == 1) ? StringToInt(sHealth[2]) : 25,
					iHunterMaxHealth = (strcmp(sMaxHealth[2], "") == 1) ? StringToInt(sMaxHealth[2]) : 250,
					iSpitterHealth = (strcmp(sHealth[3], "") == 1) ? StringToInt(sHealth[3]) : 25,
					iSpitterMaxHealth = (strcmp(sMaxHealth[3], "") == 1) ? StringToInt(sMaxHealth[3]) : 100,
					iJockeyHealth = (strcmp(sHealth[4], "") == 1) ? StringToInt(sHealth[4]) : 25,
					iJockeyMaxHealth = (strcmp(sMaxHealth[4], "") == 1) ? StringToInt(sMaxHealth[4]) : 325,
					iChargerHealth = (strcmp(sHealth[5], "") == 1) ? StringToInt(sHealth[5]) : 25,
					iChargerMaxHealth = (strcmp(sMaxHealth[5], "") == 1) ? StringToInt(sMaxHealth[5]) : 600;
				iSmokerHealth = iClamp(iSmokerHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				iSmokerMaxHealth = iClamp(iSmokerMaxHealth, 1, ST_MAXHEALTH);
				iBoomerHealth = iClamp(iBoomerHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				iBoomerMaxHealth = iClamp(iBoomerMaxHealth, 1, ST_MAXHEALTH);
				iHunterHealth = iClamp(iHunterHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				iHunterMaxHealth = iClamp(iHunterMaxHealth, 1, ST_MAXHEALTH);
				iSpitterHealth = iClamp(iSpitterHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				iSpitterMaxHealth = iClamp(iSpitterMaxHealth, 1, ST_MAXHEALTH);
				iJockeyHealth = iClamp(iJockeyHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				iJockeyMaxHealth = iClamp(iJockeyMaxHealth, 1, ST_MAXHEALTH);
				iChargerHealth = iClamp(iChargerHealth, ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH);
				iChargerMaxHealth = iClamp(iChargerMaxHealth, 1, ST_MAXHEALTH);
				switch (GetEntProp(client, Prop_Send, "m_zombieClass"))
				{
					case 1: vHeal(iInfected, iHealth, iHealth + iSmokerHealth, iSmokerMaxHealth);
					case 2: vHeal(iInfected, iHealth, iHealth + iBoomerHealth, iBoomerMaxHealth);
					case 3: vHeal(iInfected, iHealth, iHealth + iHunterHealth, iHunterMaxHealth);
					case 4: vHeal(iInfected, iHealth, iHealth + iSpitterHealth, iSpitterMaxHealth);
					case 5: vHeal(iInfected, iHealth, iHealth + iJockeyHealth, iJockeyMaxHealth);
					case 6: vHeal(iInfected, iHealth, iHealth + iChargerHealth, iChargerMaxHealth);
				}
			}
		}
	}
	if (iMedicMessage == 1)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		ST_TankName(client, sTankName);
		PrintToChatAll("%s %t", ST_PREFIX2, "Medic", sTankName);
	}
}

stock int iMedicAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iMedicAbility[ST_TankType(client)] : g_iMedicAbility2[ST_TankType(client)];
}

stock int iMedicChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iMedicChance[ST_TankType(client)] : g_iMedicChance2[ST_TankType(client)];
}