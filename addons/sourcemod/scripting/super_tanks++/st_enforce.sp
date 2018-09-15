// Super Tanks++: Enforce Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Enforce Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bEnforce[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
char g_sEnforceSlot[ST_MAXTYPES + 1][6], g_sEnforceSlot2[ST_MAXTYPES + 1][6];
float g_flEnforceDuration[ST_MAXTYPES + 1], g_flEnforceDuration2[ST_MAXTYPES + 1], g_flEnforceRange[ST_MAXTYPES + 1], g_flEnforceRange2[ST_MAXTYPES + 1];
int g_iEnforceAbility[ST_MAXTYPES + 1], g_iEnforceAbility2[ST_MAXTYPES + 1], g_iEnforceChance[ST_MAXTYPES + 1], g_iEnforceChance2[ST_MAXTYPES + 1], g_iEnforceHit[ST_MAXTYPES + 1], g_iEnforceHit2[ST_MAXTYPES + 1], g_iEnforceHitMode[ST_MAXTYPES + 1], g_iEnforceHitMode2[ST_MAXTYPES + 1], g_iEnforceMessage[ST_MAXTYPES + 1], g_iEnforceMessage2[ST_MAXTYPES + 1], g_iEnforceRangeChance[ST_MAXTYPES + 1], g_iEnforceRangeChance2[ST_MAXTYPES + 1], g_iEnforceSlot[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Enforce Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
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
	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				OnClientPutInServer(iPlayer);
			}
		}
		g_bLateLoad = false;
	}
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bEnforce[client] = false;
	g_iEnforceSlot[client] = -1;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!ST_PluginEnabled())
	{
		return Plugin_Continue;
	}
	if (bIsSurvivor(client) && g_bEnforce[client])
	{
		int iActiveWeapon = GetPlayerWeaponSlot(client, g_iEnforceSlot[client]);
		weapon = iActiveWeapon;
	}
	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((iEnforceHitMode(attacker) == 0 || iEnforceHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vEnforceHit(victim, attacker, iEnforceChance(attacker), iEnforceHit(attacker));
			}
		}
		else if ((iEnforceHitMode(victim) == 0 || iEnforceHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vEnforceHit(attacker, victim, iEnforceChance(victim), iEnforceHit(victim));
			}
		}
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
			main ? (g_iEnforceAbility[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Ability Enabled", 0)) : (g_iEnforceAbility2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Ability Enabled", g_iEnforceAbility[iIndex]));
			main ? (g_iEnforceAbility[iIndex] = iSetCellLimit(g_iEnforceAbility[iIndex], 0, 1)) : (g_iEnforceAbility2[iIndex] = iSetCellLimit(g_iEnforceAbility2[iIndex], 0, 1));
			main ? (g_iEnforceMessage[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Ability Message", 0)) : (g_iEnforceMessage2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Ability Message", g_iEnforceMessage[iIndex]));
			main ? (g_iEnforceMessage[iIndex] = iSetCellLimit(g_iEnforceMessage[iIndex], 0, 1)) : (g_iEnforceMessage2[iIndex] = iSetCellLimit(g_iEnforceMessage2[iIndex], 0, 1));
			main ? (g_iEnforceChance[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Chance", 4)) : (g_iEnforceChance2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Chance", g_iEnforceChance[iIndex]));
			main ? (g_iEnforceChance[iIndex] = iSetCellLimit(g_iEnforceChance[iIndex], 1, 9999999999)) : (g_iEnforceChance2[iIndex] = iSetCellLimit(g_iEnforceChance2[iIndex], 1, 9999999999));
			main ? (g_flEnforceDuration[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Duration", 5.0)) : (g_flEnforceDuration2[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Duration", g_flEnforceDuration[iIndex]));
			main ? (g_flEnforceDuration[iIndex] = flSetFloatLimit(g_flEnforceDuration[iIndex], 0.1, 9999999999.0)) : (g_flEnforceDuration2[iIndex] = flSetFloatLimit(g_flEnforceDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iEnforceHit[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Hit", 0)) : (g_iEnforceHit2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Hit", g_iEnforceHit[iIndex]));
			main ? (g_iEnforceHit[iIndex] = iSetCellLimit(g_iEnforceHit[iIndex], 0, 1)) : (g_iEnforceHit2[iIndex] = iSetCellLimit(g_iEnforceHit2[iIndex], 0, 1));
			main ? (g_iEnforceHitMode[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Hit Mode", 0)) : (g_iEnforceHitMode2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Hit Mode", g_iEnforceHitMode[iIndex]));
			main ? (g_iEnforceHitMode[iIndex] = iSetCellLimit(g_iEnforceHitMode[iIndex], 0, 2)) : (g_iEnforceHitMode2[iIndex] = iSetCellLimit(g_iEnforceHitMode2[iIndex], 0, 2));
			main ? (g_flEnforceRange[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Range", 150.0)) : (g_flEnforceRange2[iIndex] = kvSuperTanks.GetFloat("Enforce Ability/Enforce Range", g_flEnforceRange[iIndex]));
			main ? (g_flEnforceRange[iIndex] = flSetFloatLimit(g_flEnforceRange[iIndex], 1.0, 9999999999.0)) : (g_flEnforceRange2[iIndex] = flSetFloatLimit(g_flEnforceRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iEnforceRangeChance[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Range Chance", 16)) : (g_iEnforceRangeChance2[iIndex] = kvSuperTanks.GetNum("Enforce Ability/Enforce Range Chance", g_iEnforceRangeChance[iIndex]));
			main ? (g_iEnforceRangeChance[iIndex] = iSetCellLimit(g_iEnforceRangeChance[iIndex], 1, 9999999999)) : (g_iEnforceRangeChance2[iIndex] = iSetCellLimit(g_iEnforceRangeChance2[iIndex], 1, 9999999999));
			main ? (kvSuperTanks.GetString("Enforce Ability/Enforce Weapon Slots", g_sEnforceSlot[iIndex], sizeof(g_sEnforceSlot[]), "12345")) : (kvSuperTanks.GetString("Enforce Ability/Enforce Weapon Slots", g_sEnforceSlot2[iIndex], sizeof(g_sEnforceSlot2[]), g_sEnforceSlot[iIndex]));
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
		if (iEnforceAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveEnforce();
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iEnforceRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iEnforceChance[ST_TankType(client)] : g_iEnforceChance2[ST_TankType(client)];
		float flEnforceRange = !g_bTankConfig[ST_TankType(client)] ? g_flEnforceRange[ST_TankType(client)] : g_flEnforceRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flEnforceRange)
				{
					vEnforceHit(iSurvivor, client, iEnforceRangeChance, iEnforceAbility(client));
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	if (iEnforceAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled))
	{
		vRemoveEnforce();
	}
}

stock void vEnforceHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bEnforce[client])
	{
		g_bEnforce[client] = true;
		char sNumbers = !g_bTankConfig[ST_TankType(owner)] ? g_sEnforceSlot[ST_TankType(owner)][GetRandomInt(0, strlen(g_sEnforceSlot[ST_TankType(owner)]) - 1)] : g_sEnforceSlot2[ST_TankType(owner)][GetRandomInt(0, strlen(g_sEnforceSlot2[ST_TankType(owner)]) - 1)],
			sSlotNumber[32];
		switch (sNumbers)
		{
			case '1':
			{
				sSlotNumber = "1st";
				g_iEnforceSlot[client] = 0;
			}
			case '2':
			{
				sSlotNumber = "2nd";
				g_iEnforceSlot[client] = 1;
			}
			case '3':
			{
				sSlotNumber = "3rd";
				g_iEnforceSlot[client] = 2;
			}
			case '4':
			{
				sSlotNumber = "4th";
				g_iEnforceSlot[client] = 3;
			}
			case '5':
			{
				sSlotNumber = "5th";
				g_iEnforceSlot[client] = 4;
			}
		}
		float flEnforceDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flEnforceDuration[ST_TankType(owner)] : g_flEnforceDuration2[ST_TankType(owner)];
		DataPack dpStopEnforce = new DataPack();
		CreateDataTimer(flEnforceDuration, tTimerStopEnforce, dpStopEnforce, TIMER_FLAG_NO_MAPCHANGE);
		dpStopEnforce.WriteCell(GetClientUserId(client)), dpStopEnforce.WriteCell(GetClientUserId(owner)), dpStopEnforce.WriteCell(enabled);
		if (iEnforceMessage(owner) == 1)
		{
			PrintToChatAll("%s %t", ST_PREFIX2, "Enforce", owner, client, sSlotNumber);
		}
	}
}

stock void vRemoveEnforce()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bEnforce[iSurvivor])
		{
			g_bEnforce[iSurvivor] = false;
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bEnforce[iPlayer] = false;
			g_iEnforceSlot[iPlayer] = -1;
		}
	}
}

stock void vReset2(int client, int owner)
{
	g_bEnforce[client] = false;
	g_iEnforceSlot[client] = -1;
	if (iEnforceMessage(owner) == 1)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Enforce2", client);
	}
}

stock int iEnforceAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iEnforceAbility[ST_TankType(client)] : g_iEnforceAbility2[ST_TankType(client)];
}

stock int iEnforceChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iEnforceChance[ST_TankType(client)] : g_iEnforceChance2[ST_TankType(client)];
}

stock int iEnforceHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iEnforceHit[ST_TankType(client)] : g_iEnforceHit2[ST_TankType(client)];
}

stock int iEnforceHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iEnforceHitMode[ST_TankType(client)] : g_iEnforceHitMode2[ST_TankType(client)];
}

stock int iEnforceMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iEnforceMessage[ST_TankType(client)] : g_iEnforceMessage2[ST_TankType(client)];
}

public Action tTimerStopEnforce(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bEnforce[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank);
		return Plugin_Stop;
	}
	int iEnforceEnabled = pack.ReadCell();
	if (iEnforceEnabled == 0)
	{
		vReset2(iSurvivor, iTank);
		return Plugin_Stop;
	}
	vReset2(iSurvivor, iTank);
	return Plugin_Continue;
}