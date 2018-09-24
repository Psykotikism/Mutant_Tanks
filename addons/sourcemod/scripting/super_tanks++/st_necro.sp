// Super Tanks++: Necro Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Necro Ability",
	author = ST_AUTHOR,
	description = "The Super Tank resurrects dead special infected.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1];
float g_flNecroRange[ST_MAXTYPES + 1], g_flNecroRange2[ST_MAXTYPES + 1];
int g_iNecroAbility[ST_MAXTYPES + 1], g_iNecroAbility2[ST_MAXTYPES + 1], g_iNecroChance[ST_MAXTYPES + 1], g_iNecroChance2[ST_MAXTYPES + 1], g_iNecroMessage[ST_MAXTYPES + 1], g_iNecroMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_Left4Dead && !bIsL4D2())
	{
		strcopy(error, err_max, "[ST++] Necro Ability only supports Left 4 Dead 1 & 2.");
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
		Format(sName, sizeof(sName), "Tank %d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iNecroAbility[iIndex] = kvSuperTanks.GetNum("Necro Ability/Ability Enabled", 0)) : (g_iNecroAbility2[iIndex] = kvSuperTanks.GetNum("Necro Ability/Ability Enabled", g_iNecroAbility[iIndex]));
			main ? (g_iNecroAbility[iIndex] = iClamp(g_iNecroAbility[iIndex], 0, 1)) : (g_iNecroAbility2[iIndex] = iClamp(g_iNecroAbility2[iIndex], 0, 1));
			main ? (g_iNecroMessage[iIndex] = kvSuperTanks.GetNum("Necro Ability/Ability Message", 0)) : (g_iNecroMessage2[iIndex] = kvSuperTanks.GetNum("Necro Ability/Ability Message", g_iNecroMessage[iIndex]));
			main ? (g_iNecroMessage[iIndex] = iClamp(g_iNecroMessage[iIndex], 0, 1)) : (g_iNecroMessage2[iIndex] = iClamp(g_iNecroMessage2[iIndex], 0, 1));
			main ? (g_iNecroChance[iIndex] = kvSuperTanks.GetNum("Necro Ability/Necro Chance", 4)) : (g_iNecroChance2[iIndex] = kvSuperTanks.GetNum("Necro Ability/Necro Chance", g_iNecroChance[iIndex]));
			main ? (g_iNecroChance[iIndex] = iClamp(g_iNecroChance[iIndex], 1, 9999999999)) : (g_iNecroChance2[iIndex] = iClamp(g_iNecroChance2[iIndex], 1, 9999999999));
			main ? (g_flNecroRange[iIndex] = kvSuperTanks.GetFloat("Necro Ability/Necro Range", 500.0)) : (g_flNecroRange2[iIndex] = kvSuperTanks.GetFloat("Necro Ability/Necro Range", g_flNecroRange[iIndex]));
			main ? (g_flNecroRange[iIndex] = flClamp(g_flNecroRange[iIndex], 1.0, 9999999999.0)) : (g_flNecroRange2[iIndex] = flClamp(g_flNecroRange2[iIndex], 1.0, 9999999999.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iInfectedId = event.GetInt("userid"), iInfected = GetClientOfUserId(iInfectedId);
		float flInfectedPos[3];
		if (bIsSpecialInfected(iInfected))
		{
			GetClientAbsOrigin(iInfected, flInfectedPos);
			for (int iTank = 1; iTank <= MaxClients; iTank++)
			{
				if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && IsPlayerAlive(iTank))
				{
					int iNecroAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iNecroAbility[ST_TankType(iTank)] : g_iNecroAbility2[ST_TankType(iTank)],
						iNecroChance = !g_bTankConfig[ST_TankType(iTank)] ? g_iNecroChance[ST_TankType(iTank)] : g_iNecroChance2[ST_TankType(iTank)];
					if (iNecroAbility == 1 && GetRandomInt(1, iNecroChance) == 1)
					{
						float flNecroRange = !g_bTankConfig[ST_TankType(iTank)] ? g_flNecroRange[ST_TankType(iTank)] : g_flNecroRange2[ST_TankType(iTank)],
							flTankPos[3];
						GetClientAbsOrigin(iTank, flTankPos);
						float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
						if (flDistance <= flNecroRange)
						{
							switch (GetEntProp(iInfected, Prop_Send, "m_zombieClass"))
							{
								case 1: vNecro(iTank, flInfectedPos, "smoker");
								case 2: vNecro(iTank, flInfectedPos, "boomer");
								case 3: vNecro(iTank, flInfectedPos, "hunter");
								case 4: vNecro(iTank, flInfectedPos, "spitter");
								case 5: vNecro(iTank, flInfectedPos, "jockey");
								case 6: vNecro(iTank, flInfectedPos, "charger");
							}
						}
					}
				}
			}
		}
	}
}

stock void vNecro(int client, float pos[3], const char[] type)
{
	int iNecroMessage = !g_bTankConfig[ST_TankType(client)] ? g_iNecroMessage[ST_TankType(client)] : g_iNecroMessage2[ST_TankType(client)];
	bool bExists[MAXPLAYERS + 1];
	for (int iNecro = 1; iNecro <= MaxClients; iNecro++)
	{
		bExists[iNecro] = false;
		if (bIsSpecialInfected(iNecro))
		{
			bExists[iNecro] = true;
		}
	}
	vCheatCommand(client, bIsL4D2() ? "z_spawn_old" : "z_spawn", type);
	int iInfected;
	for (int iNecro = 1; iNecro <= MaxClients; iNecro++)
	{
		if (bIsSpecialInfected(iNecro) && !bExists[iNecro])
		{
			iInfected = iNecro;
			break;
		}
	}
	if (iInfected > 0)
	{
		TeleportEntity(iInfected, pos, NULL_VECTOR, NULL_VECTOR);
		if (iNecroMessage == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(client, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Necro", sTankName);
		}
	}
}