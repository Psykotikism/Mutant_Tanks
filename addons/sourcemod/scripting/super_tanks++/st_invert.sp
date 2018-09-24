// Super Tanks++: Invert Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Invert Ability",
	author = ST_AUTHOR,
	description = "The Super Tank inverts the survivors' movement keys.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bInvert[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flInvertDuration[ST_MAXTYPES + 1], g_flInvertDuration2[ST_MAXTYPES + 1], g_flInvertRange[ST_MAXTYPES + 1], g_flInvertRange2[ST_MAXTYPES + 1];
int g_iInvertAbility[ST_MAXTYPES + 1], g_iInvertAbility2[ST_MAXTYPES + 1], g_iInvertChance[ST_MAXTYPES + 1], g_iInvertChance2[ST_MAXTYPES + 1], g_iInvertHit[ST_MAXTYPES + 1], g_iInvertHit2[ST_MAXTYPES + 1], g_iInvertHitMode[ST_MAXTYPES + 1], g_iInvertHitMode2[ST_MAXTYPES + 1], g_iInvertMessage[ST_MAXTYPES + 1], g_iInvertMessage2[ST_MAXTYPES + 1], g_iInvertRangeChance[ST_MAXTYPES + 1], g_iInvertRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_Left4Dead && !bIsL4D2())
	{
		strcopy(error, err_max, "[ST++] Invert Ability only supports Left 4 Dead 1 & 2.");
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
	g_bInvert[client] = false;
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
	if (g_bInvert[client])
	{
		vel[0] = -vel[0];
		if (buttons & IN_FORWARD)
		{
			buttons &= ~IN_FORWARD;
			buttons |= IN_BACK;
		}
		else if (buttons & IN_BACK)
		{
			buttons &= ~IN_BACK;
			buttons |= IN_FORWARD;
		}
		vel[1] = -vel[1];
		if (buttons & IN_MOVELEFT)
		{
			buttons &= ~IN_MOVELEFT;
			buttons |= IN_MOVERIGHT;
		}
		else if (buttons & IN_MOVERIGHT)
		{
			buttons &= ~IN_MOVERIGHT;
			buttons |= IN_MOVELEFT;
		}
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((iInvertHitMode(attacker) == 0 || iInvertHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vInvertHit(victim, attacker, iInvertChance(attacker), iInvertHit(attacker), 1);
			}
		}
		else if ((iInvertHitMode(victim) == 0 || iInvertHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vInvertHit(attacker, victim, iInvertChance(victim), iInvertHit(victim), 1);
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
			main ? (g_iInvertAbility[iIndex] = kvSuperTanks.GetNum("Invert Ability/Ability Enabled", 0)) : (g_iInvertAbility2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Ability Enabled", g_iInvertAbility[iIndex]));
			main ? (g_iInvertAbility[iIndex] = iClamp(g_iInvertAbility[iIndex], 0, 1)) : (g_iInvertAbility2[iIndex] = iClamp(g_iInvertAbility2[iIndex], 0, 1));
			main ? (g_iInvertMessage[iIndex] = kvSuperTanks.GetNum("Invert Ability/Ability Message", 0)) : (g_iInvertMessage2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Ability Message", g_iInvertMessage[iIndex]));
			main ? (g_iInvertMessage[iIndex] = iClamp(g_iInvertMessage[iIndex], 0, 3)) : (g_iInvertMessage2[iIndex] = iClamp(g_iInvertMessage2[iIndex], 0, 3));
			main ? (g_iInvertChance[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Chance", 4)) : (g_iInvertChance2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Chance", g_iInvertChance[iIndex]));
			main ? (g_iInvertChance[iIndex] = iClamp(g_iInvertChance[iIndex], 1, 9999999999)) : (g_iInvertChance2[iIndex] = iClamp(g_iInvertChance2[iIndex], 1, 9999999999));
			main ? (g_flInvertDuration[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Duration", 5.0)) : (g_flInvertDuration2[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Duration", g_flInvertDuration[iIndex]));
			main ? (g_flInvertDuration[iIndex] = flClamp(g_flInvertDuration[iIndex], 0.1, 9999999999.0)) : (g_flInvertDuration2[iIndex] = flClamp(g_flInvertDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iInvertHit[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Hit", 0)) : (g_iInvertHit2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Hit", g_iInvertHit[iIndex]));
			main ? (g_iInvertHit[iIndex] = iClamp(g_iInvertHit[iIndex], 0, 1)) : (g_iInvertHit2[iIndex] = iClamp(g_iInvertHit2[iIndex], 0, 1));
			main ? (g_iInvertHitMode[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Hit Mode", 0)) : (g_iInvertHitMode2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Hit Mode", g_iInvertHitMode[iIndex]));
			main ? (g_iInvertHitMode[iIndex] = iClamp(g_iInvertHitMode[iIndex], 0, 2)) : (g_iInvertHitMode2[iIndex] = iClamp(g_iInvertHitMode2[iIndex], 0, 2));
			main ? (g_flInvertRange[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Range", 150.0)) : (g_flInvertRange2[iIndex] = kvSuperTanks.GetFloat("Invert Ability/Invert Range", g_flInvertRange[iIndex]));
			main ? (g_flInvertRange[iIndex] = flClamp(g_flInvertRange[iIndex], 1.0, 9999999999.0)) : (g_flInvertRange2[iIndex] = flClamp(g_flInvertRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iInvertRangeChance[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Range Chance", 16)) : (g_iInvertRangeChance2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Invert Range Chance", g_iInvertRangeChance[iIndex]));
			main ? (g_iInvertRangeChance[iIndex] = iClamp(g_iInvertRangeChance[iIndex], 1, 9999999999)) : (g_iInvertRangeChance2[iIndex] = iClamp(g_iInvertRangeChance2[iIndex], 1, 9999999999));
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
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveInvert();
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iInvertRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iInvertChance[ST_TankType(client)] : g_iInvertChance2[ST_TankType(client)];
		float flInvertRange = !g_bTankConfig[ST_TankType(client)] ? g_flInvertRange[ST_TankType(client)] : g_flInvertRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flInvertRange)
				{
					vInvertHit(iSurvivor, client, iInvertRangeChance, iInvertAbility(client), 2);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	if (iInvertAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled))
	{
		vRemoveInvert();
	}
}

stock void vInvertHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bInvert[client])
	{
		g_bInvert[client] = true;
		float flInvertDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flInvertDuration[ST_TankType(owner)] : g_flInvertDuration2[ST_TankType(owner)];
		DataPack dpStopInvert = new DataPack();
		CreateDataTimer(flInvertDuration, tTimerStopInvert, dpStopInvert, TIMER_FLAG_NO_MAPCHANGE);
		dpStopInvert.WriteCell(GetClientUserId(client)), dpStopInvert.WriteCell(GetClientUserId(owner)), dpStopInvert.WriteCell(message), dpStopInvert.WriteCell(enabled);
		if (iInvertMessage(owner) == message || iInvertMessage(owner) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Invert", sTankName, client);
		}
	}
}

stock void vRemoveInvert()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bInvert[iSurvivor])
		{
			g_bInvert[iSurvivor] = false;
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bInvert[iPlayer] = false;
		}
	}
}

stock void vReset2(int client, int owner, int message)
{
	g_bInvert[client] = false;
	if (iInvertMessage(owner) == message || iInvertMessage(owner) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Invert2", client);
	}
}

stock int iInvertAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iInvertAbility[ST_TankType(client)] : g_iInvertAbility2[ST_TankType(client)];
}

stock int iInvertChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iInvertChance[ST_TankType(client)] : g_iInvertChance2[ST_TankType(client)];
}

stock int iInvertHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iInvertHit[ST_TankType(client)] : g_iInvertHit2[ST_TankType(client)];
}

stock int iInvertHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iInvertHitMode[ST_TankType(client)] : g_iInvertHitMode2[ST_TankType(client)];
}

stock int iInvertMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iInvertMessage[ST_TankType(client)] : g_iInvertMessage2[ST_TankType(client)];
}

public Action tTimerStopInvert(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bInvert[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell()), iInvertChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank, iInvertChat);
		return Plugin_Stop;
	}
	int iInvertEnabled = pack.ReadCell();
	if (iInvertEnabled == 0)
	{
		vReset2(iSurvivor, iTank, iInvertChat);
		return Plugin_Stop;
	}
	vReset2(iSurvivor, iTank, iInvertChat);
	return Plugin_Continue;
}