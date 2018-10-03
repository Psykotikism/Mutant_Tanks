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
char g_sInvertEffect[ST_MAXTYPES + 1][4], g_sInvertEffect2[ST_MAXTYPES + 1][4];
float g_flInvertDuration[ST_MAXTYPES + 1], g_flInvertDuration2[ST_MAXTYPES + 1], g_flInvertRange[ST_MAXTYPES + 1], g_flInvertRange2[ST_MAXTYPES + 1];
int g_iInvertAbility[ST_MAXTYPES + 1], g_iInvertAbility2[ST_MAXTYPES + 1], g_iInvertChance[ST_MAXTYPES + 1], g_iInvertChance2[ST_MAXTYPES + 1], g_iInvertHit[ST_MAXTYPES + 1], g_iInvertHit2[ST_MAXTYPES + 1], g_iInvertHitMode[ST_MAXTYPES + 1], g_iInvertHitMode2[ST_MAXTYPES + 1], g_iInvertMessage[ST_MAXTYPES + 1], g_iInvertMessage2[ST_MAXTYPES + 1], g_iInvertRangeChance[ST_MAXTYPES + 1], g_iInvertRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
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
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
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
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vInvertHit(victim, attacker, iInvertChance(attacker), iInvertHit(attacker), 1, "1");
			}
		}
		else if ((iInvertHitMode(victim) == 0 || iInvertHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vInvertHit(attacker, victim, iInvertChance(victim), iInvertHit(victim), 1, "2");
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
		Format(sName, sizeof(sName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iInvertAbility[iIndex] = kvSuperTanks.GetNum("Invert Ability/Ability Enabled", 0)) : (g_iInvertAbility2[iIndex] = kvSuperTanks.GetNum("Invert Ability/Ability Enabled", g_iInvertAbility[iIndex]));
			main ? (g_iInvertAbility[iIndex] = iClamp(g_iInvertAbility[iIndex], 0, 1)) : (g_iInvertAbility2[iIndex] = iClamp(g_iInvertAbility2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("Invert Ability/Ability Effect", g_sInvertEffect[iIndex], sizeof(g_sInvertEffect[]), "123")) : (kvSuperTanks.GetString("Invert Ability/Ability Effect", g_sInvertEffect2[iIndex], sizeof(g_sInvertEffect2[]), g_sInvertEffect[iIndex]));
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

public void ST_PluginEnd()
{
	vRemoveInvert();
	vReset();
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveInvert();
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		int iInvertRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_iInvertChance[ST_TankType(tank)] : g_iInvertChance2[ST_TankType(tank)];
		float flInvertRange = !g_bTankConfig[ST_TankType(tank)] ? g_flInvertRange[ST_TankType(tank)] : g_flInvertRange2[ST_TankType(tank)],
			flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flInvertRange)
				{
					vInvertHit(iSurvivor, tank, iInvertRangeChance, iInvertAbility(tank), 2, "3");
				}
			}
		}
	}
}

public void ST_BossStage(int tank)
{
	if (iInvertAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveInvert();
	}
}

stock void vInvertHit(int survivor, int tank, int chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(survivor) && !g_bInvert[survivor])
	{
		g_bInvert[survivor] = true;
		float flInvertDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flInvertDuration[ST_TankType(tank)] : g_flInvertDuration2[ST_TankType(tank)];
		DataPack dpStopInvert = new DataPack();
		CreateDataTimer(flInvertDuration, tTimerStopInvert, dpStopInvert, TIMER_FLAG_NO_MAPCHANGE);
		dpStopInvert.WriteCell(GetClientUserId(survivor)), dpStopInvert.WriteCell(GetClientUserId(tank)), dpStopInvert.WriteCell(message);
		char sInvertEffect[4];
		sInvertEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sInvertEffect[ST_TankType(tank)] : g_sInvertEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sInvertEffect, mode);
		if (iInvertMessage(tank) == message || iInvertMessage(tank) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Invert", sTankName, survivor);
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

stock int iInvertAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iInvertAbility[ST_TankType(tank)] : g_iInvertAbility2[ST_TankType(tank)];
}

stock int iInvertChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iInvertChance[ST_TankType(tank)] : g_iInvertChance2[ST_TankType(tank)];
}

stock int iInvertHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iInvertHit[ST_TankType(tank)] : g_iInvertHit2[ST_TankType(tank)];
}

stock int iInvertHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iInvertHitMode[ST_TankType(tank)] : g_iInvertHitMode2[ST_TankType(tank)];
}

stock int iInvertMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iInvertMessage[ST_TankType(tank)] : g_iInvertMessage2[ST_TankType(tank)];
}

public Action tTimerStopInvert(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bInvert[iSurvivor])
	{
		g_bInvert[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell()), iInvertChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bInvert[iSurvivor] = false;
		return Plugin_Stop;
	}
	g_bInvert[iSurvivor] = false;
	if (iInvertMessage(iTank) == iInvertChat || iInvertMessage(iTank) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Invert2", iSurvivor);
	}
	return Plugin_Continue;
}