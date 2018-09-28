// Super Tanks++: Pyro Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Pyro Ability",
	author = ST_AUTHOR,
	description = "The Super Tank gains a speed boost when on fire.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bPyro[MAXPLAYERS + 1], g_bPyro2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flPyroBoost[ST_MAXTYPES + 1], g_flPyroBoost2[ST_MAXTYPES + 1], g_flPyroDuration[ST_MAXTYPES + 1], g_flPyroDuration2[ST_MAXTYPES + 1], g_flPyroRange[ST_MAXTYPES + 1], g_flPyroRange2[ST_MAXTYPES + 1], g_flRunSpeed[ST_MAXTYPES + 1], g_flRunSpeed2[ST_MAXTYPES + 1];
int g_iPyroAbility[ST_MAXTYPES + 1], g_iPyroAbility2[ST_MAXTYPES + 1], g_iPyroChance[ST_MAXTYPES + 1], g_iPyroChance2[ST_MAXTYPES + 1], g_iPyroHit[ST_MAXTYPES + 1], g_iPyroHit2[ST_MAXTYPES + 1], g_iPyroHitMode[ST_MAXTYPES + 1], g_iPyroHitMode2[ST_MAXTYPES + 1], g_iPyroMessage[ST_MAXTYPES + 1], g_iPyroMessage2[ST_MAXTYPES + 1], g_iPyroMode[ST_MAXTYPES + 1], g_iPyroMode2[ST_MAXTYPES + 1], g_iPyroRangeChance[ST_MAXTYPES + 1], g_iPyroRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Pyro Ability only supports Left 4 Dead 1 & 2.");
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
	g_bPyro[client] = false;
	g_bPyro2[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((iPyroHitMode(attacker) == 0 || iPyroHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vPyroHit(victim, attacker, iPyroChance(attacker), iPyroHit(attacker), 1);
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim))
		{
			if ((iPyroHitMode(victim) == 0 || iPyroHitMode(victim) == 2) && bIsSurvivor(attacker) && StrEqual(sClassname, "weapon_melee"))
			{
				vPyroHit(attacker, victim, iPyroChance(victim), iPyroHit(victim), 1);
			}
			int iPyroMode = !g_bTankConfig[ST_TankType(victim)] ? g_iPyroMode[ST_TankType(victim)] : g_iPyroMode2[ST_TankType(victim)];
			float flPyroBoost = !g_bTankConfig[ST_TankType(victim)] ? g_flPyroBoost[ST_TankType(victim)] : g_flPyroBoost2[ST_TankType(victim)],
				flRunSpeed = !g_bTankConfig[ST_TankType(victim)] ? g_flRunSpeed[ST_TankType(victim)] : g_flRunSpeed2[ST_TankType(victim)];
			if (iPyroAbility(victim) == 1)
			{
				if (damagetype & DMG_BURN)
				{
					switch (iPyroMode)
					{
						case 0: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", flRunSpeed + flPyroBoost);
						case 1: SetEntPropFloat(victim, Prop_Send, "m_flLaggedMovementValue", flPyroBoost);
					}
					if (!g_bPyro2[victim])
					{
						g_bPyro2[victim] = true;
						CreateTimer(1.0, tTimerPyro, GetClientUserId(victim), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						switch (iPyroMessage(victim))
						{
							case 3, 5, 6, 7:
							{
								char sTankName[MAX_NAME_LENGTH + 1];
								ST_TankName(victim, sTankName);
								PrintToChatAll("%s %t", ST_PREFIX2, "Pyro", sTankName);
							}
						}
					}
				}
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
			main ? (g_flRunSpeed[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", 1.0)) : (g_flRunSpeed2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", g_flRunSpeed[iIndex]));
			main ? (g_flRunSpeed[iIndex] = flClamp(g_flRunSpeed[iIndex], 0.1, 3.0)) : (g_flRunSpeed2[iIndex] = flClamp(g_flRunSpeed2[iIndex], 0.1, 3.0));
			main ? (g_iPyroAbility[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Ability Enabled", 0)) : (g_iPyroAbility2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Ability Enabled", g_iPyroAbility[iIndex]));
			main ? (g_iPyroAbility[iIndex] = iClamp(g_iPyroAbility[iIndex], 0, 1)) : (g_iPyroAbility2[iIndex] = iClamp(g_iPyroAbility2[iIndex], 0, 1));
			main ? (g_iPyroMessage[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Ability Message", 0)) : (g_iPyroMessage2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Ability Message", g_iPyroMessage[iIndex]));
			main ? (g_iPyroMessage[iIndex] = iClamp(g_iPyroMessage[iIndex], 0, 7)) : (g_iPyroMessage2[iIndex] = iClamp(g_iPyroMessage2[iIndex], 0, 7));
			main ? (g_flPyroBoost[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Boost", 1.0)) : (g_flPyroBoost2[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Boost", g_flPyroBoost[iIndex]));
			main ? (g_flPyroBoost[iIndex] = flClamp(g_flPyroBoost[iIndex], 0.1, 3.0)) : (g_flPyroBoost2[iIndex] = flClamp(g_flPyroBoost2[iIndex], 0.1, 3.0));
			main ? (g_iPyroChance[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Chance", 4)) : (g_iPyroChance2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Chance", g_iPyroChance[iIndex]));
			main ? (g_iPyroChance[iIndex] = iClamp(g_iPyroChance[iIndex], 1, 9999999999)) : (g_iPyroChance2[iIndex] = iClamp(g_iPyroChance2[iIndex], 1, 9999999999));
			main ? (g_flPyroDuration[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Duration", 5.0)) : (g_flPyroDuration2[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Duration", g_flPyroDuration[iIndex]));
			main ? (g_flPyroDuration[iIndex] = flClamp(g_flPyroDuration[iIndex], 0.1, 9999999999.0)) : (g_flPyroDuration2[iIndex] = flClamp(g_flPyroDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iPyroHit[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Hit", 0)) : (g_iPyroHit2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Hit", g_iPyroHit[iIndex]));
			main ? (g_iPyroHit[iIndex] = iClamp(g_iPyroHit[iIndex], 0, 1)) : (g_iPyroHit2[iIndex] = iClamp(g_iPyroHit2[iIndex], 0, 1));
			main ? (g_iPyroHitMode[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Hit Mode", 0)) : (g_iPyroHitMode2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Hit Mode", g_iPyroHitMode[iIndex]));
			main ? (g_iPyroHitMode[iIndex] = iClamp(g_iPyroHitMode[iIndex], 0, 2)) : (g_iPyroHitMode2[iIndex] = iClamp(g_iPyroHitMode2[iIndex], 0, 2));
			main ? (g_iPyroMode[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Mode", 0)) : (g_iPyroMode2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Mode", g_iPyroMode[iIndex]));
			main ? (g_iPyroMode[iIndex] = iClamp(g_iPyroMode[iIndex], 0, 1)) : (g_iPyroMode2[iIndex] = iClamp(g_iPyroMode2[iIndex], 0, 1));
			main ? (g_flPyroRange[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Range", 150.0)) : (g_flPyroRange2[iIndex] = kvSuperTanks.GetFloat("Pyro Ability/Pyro Range", g_flPyroRange[iIndex]));
			main ? (g_flPyroRange[iIndex] = flClamp(g_flPyroRange[iIndex], 1.0, 9999999999.0)) : (g_flPyroRange2[iIndex] = flClamp(g_flPyroRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iPyroRangeChance[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Range Chance", 16)) : (g_iPyroRangeChance2[iIndex] = kvSuperTanks.GetNum("Pyro Ability/Pyro Range Chance", g_iPyroRangeChance[iIndex]));
			main ? (g_iPyroRangeChance[iIndex] = iClamp(g_iPyroRangeChance[iIndex], 1, 9999999999)) : (g_iPyroRangeChance2[iIndex] = iClamp(g_iPyroRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iPyroRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iPyroChance[ST_TankType(client)] : g_iPyroChance2[ST_TankType(client)];
		float flPyroRange = !g_bTankConfig[ST_TankType(client)] ? g_flPyroRange[ST_TankType(client)] : g_flPyroRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flPyroRange)
				{
					vPyroHit(iSurvivor, client, iPyroRangeChance, iPyroAbility(client), 2);
				}
			}
		}
	}
}

stock void vPyroHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bPyro[client])
	{
		g_bPyro[client] = true;
		float flPyroDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flPyroDuration[ST_TankType(owner)] : g_flPyroDuration2[ST_TankType(owner)];
		IgniteEntity(owner, flPyroDuration, true);
		char sRGB[4][4];
		ST_TankColors(owner, sRGB[0], sRGB[1], sRGB[2]);
		int iRed = (!StrEqual(sRGB[0], "")) ? StringToInt(sRGB[0]) : 255;
		iRed = iClamp(iRed, 0, 255);
		int iGreen = (!StrEqual(sRGB[1], "")) ? StringToInt(sRGB[1]) : 255;
		iGreen = iClamp(iGreen, 0, 255);
		int iBlue = (!StrEqual(sRGB[2], "")) ? StringToInt(sRGB[2]) : 255;
		iBlue = iClamp(iBlue, 0, 255);
		vFade(client, 800, 300, iRed, iGreen, iBlue);
		if (iPyroMessage(owner) == message || iPyroMessage(owner) == 4 || iPyroMessage(owner) == 5 || iPyroMessage(owner) == 6 || iPyroMessage(owner) == 7)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Pyro", sTankName, client);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bPyro[iPlayer] = false;
			g_bPyro2[iPlayer] = false;
		}
	}
}

stock int iPyroAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPyroAbility[ST_TankType(client)] : g_iPyroAbility2[ST_TankType(client)];
}

stock int iPyroChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPyroChance[ST_TankType(client)] : g_iPyroChance2[ST_TankType(client)];
}

stock int iPyroHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPyroHit[ST_TankType(client)] : g_iPyroHit2[ST_TankType(client)];
}

stock int iPyroHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPyroHitMode[ST_TankType(client)] : g_iPyroHitMode2[ST_TankType(client)];
}

stock int iPyroMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iPyroMessage[ST_TankType(client)] : g_iPyroMessage2[ST_TankType(client)];
}

public Action tTimerPyro(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bPyro[iTank] = false;
		g_bPyro2[iTank] = false;
		return Plugin_Stop;
	}
	if (iPyroAbility(iTank) == 0 || !bIsPlayerBurning(iTank))
	{
		g_bPyro[iTank] = false;
		g_bPyro2[iTank] = false;
		switch (iPyroMessage(iTank))
		{
			case 3, 5, 6, 7:
			{
				char sTankName[MAX_NAME_LENGTH + 1];
				ST_TankName(iTank, sTankName);
				PrintToChatAll("%s %t", ST_PREFIX2, "Pyro2", sTankName);
			}
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}