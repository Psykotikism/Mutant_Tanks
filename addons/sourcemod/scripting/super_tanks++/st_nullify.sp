// Super Tanks++: Nullify Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Nullify Ability",
	author = ST_AUTHOR,
	description = "The Super Tank nullifies all of the survivors' damage.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bNullify[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sNullifyEffect[ST_MAXTYPES + 1][4], g_sNullifyEffect2[ST_MAXTYPES + 1][4];

float g_flNullifyDuration[ST_MAXTYPES + 1], g_flNullifyDuration2[ST_MAXTYPES + 1], g_flNullifyRange[ST_MAXTYPES + 1], g_flNullifyRange2[ST_MAXTYPES + 1];

int g_iNullifyAbility[ST_MAXTYPES + 1], g_iNullifyAbility2[ST_MAXTYPES + 1], g_iNullifyChance[ST_MAXTYPES + 1], g_iNullifyChance2[ST_MAXTYPES + 1], g_iNullifyHit[ST_MAXTYPES + 1], g_iNullifyHit2[ST_MAXTYPES + 1], g_iNullifyHitMode[ST_MAXTYPES + 1], g_iNullifyHitMode2[ST_MAXTYPES + 1], g_iNullifyMessage[ST_MAXTYPES + 1], g_iNullifyMessage2[ST_MAXTYPES + 1], g_iNullifyRangeChance[ST_MAXTYPES + 1], g_iNullifyRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Nullify Ability only supports Left 4 Dead 1 & 2.");

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

	g_bNullify[client] = false;
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

		if ((iNullifyHitMode(attacker) == 0 || iNullifyHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vNullifyHit(victim, attacker, iNullifyChance(attacker), iNullifyHit(attacker), 1, "1");
			}
		}
		else if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if ((iNullifyHitMode(victim) == 0 || iNullifyHitMode(victim) == 2) && StrEqual(sClassname, "weapon_melee"))
			{
				vNullifyHit(attacker, victim, iNullifyChance(victim), iNullifyHit(victim), 1, "2");
			}

			if (g_bNullify[attacker])
			{
				return Plugin_Handled;
			}
		}
	}

	return Plugin_Continue;
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
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iNullifyAbility[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Ability Enabled", 0);
				g_iNullifyAbility[iIndex] = iClamp(g_iNullifyAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Nullify Ability/Ability Effect", g_sNullifyEffect[iIndex], sizeof(g_sNullifyEffect[]), "123");
				g_iNullifyMessage[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Ability Message", 0);
				g_iNullifyMessage[iIndex] = iClamp(g_iNullifyMessage[iIndex], 0, 3);
				g_iNullifyChance[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Chance", 4);
				g_iNullifyChance[iIndex] = iClamp(g_iNullifyChance[iIndex], 1, 9999999999);
				g_flNullifyDuration[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Duration", 5.0);
				g_flNullifyDuration[iIndex] = flClamp(g_flNullifyDuration[iIndex], 0.1, 9999999999.0);
				g_iNullifyHit[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit", 0);
				g_iNullifyHit[iIndex] = iClamp(g_iNullifyHit[iIndex], 0, 1);
				g_iNullifyHitMode[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit Mode", 0);
				g_iNullifyHitMode[iIndex] = iClamp(g_iNullifyHitMode[iIndex], 0, 2);
				g_flNullifyRange[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Range", 150.0);
				g_flNullifyRange[iIndex] = flClamp(g_flNullifyRange[iIndex], 1.0, 9999999999.0);
				g_iNullifyRangeChance[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Range Chance", 16);
				g_iNullifyRangeChance[iIndex] = iClamp(g_iNullifyRangeChance[iIndex], 1, 9999999999);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iNullifyAbility2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Ability Enabled", g_iNullifyAbility[iIndex]);
				g_iNullifyAbility2[iIndex] = iClamp(g_iNullifyAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Nullify Ability/Ability Effect", g_sNullifyEffect2[iIndex], sizeof(g_sNullifyEffect2[]), g_sNullifyEffect[iIndex]);
				g_iNullifyMessage2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Ability Message", g_iNullifyMessage[iIndex]);
				g_iNullifyMessage2[iIndex] = iClamp(g_iNullifyMessage2[iIndex], 0, 3);
				g_iNullifyChance2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Chance", g_iNullifyChance[iIndex]);
				g_iNullifyChance2[iIndex] = iClamp(g_iNullifyChance2[iIndex], 1, 9999999999);
				g_flNullifyDuration2[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Duration", g_flNullifyDuration[iIndex]);
				g_flNullifyDuration2[iIndex] = flClamp(g_flNullifyDuration2[iIndex], 0.1, 9999999999.0);
				g_iNullifyHit2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit", g_iNullifyHit[iIndex]);
				g_iNullifyHit2[iIndex] = iClamp(g_iNullifyHit2[iIndex], 0, 1);
				g_iNullifyHitMode2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Hit Mode", g_iNullifyHitMode[iIndex]);
				g_iNullifyHitMode2[iIndex] = iClamp(g_iNullifyHitMode2[iIndex], 0, 2);
				g_flNullifyRange2[iIndex] = kvSuperTanks.GetFloat("Nullify Ability/Nullify Range", g_flNullifyRange[iIndex]);
				g_flNullifyRange2[iIndex] = flClamp(g_flNullifyRange2[iIndex], 1.0, 9999999999.0);
				g_iNullifyRangeChance2[iIndex] = kvSuperTanks.GetNum("Nullify Ability/Nullify Range Chance", g_iNullifyRangeChance[iIndex]);
				g_iNullifyRangeChance2[iIndex] = iClamp(g_iNullifyRangeChance2[iIndex], 1, 9999999999);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vRemoveNullify();
	vReset();
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveNullify();
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		int iNullifyRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_iNullifyChance[ST_TankType(tank)] : g_iNullifyChance2[ST_TankType(tank)];

		float flNullifyRange = !g_bTankConfig[ST_TankType(tank)] ? g_flNullifyRange[ST_TankType(tank)] : g_flNullifyRange2[ST_TankType(tank)],
			flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flNullifyRange)
				{
					vNullifyHit(iSurvivor, tank, iNullifyRangeChance, iNullifyAbility(tank), 2, "3");
				}
			}
		}
	}
}

public void ST_BossStage(int tank)
{
	if (iNullifyAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveNullify();
	}
}

static void vNullifyHit(int survivor, int tank, int chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(survivor) && !g_bNullify[survivor])
	{
		g_bNullify[survivor] = true;

		float flNullifyDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flNullifyDuration[ST_TankType(tank)] : g_flNullifyDuration2[ST_TankType(tank)];
		DataPack dpStopNullify;
		CreateDataTimer(flNullifyDuration, tTimerStopNullify, dpStopNullify, TIMER_FLAG_NO_MAPCHANGE);
		dpStopNullify.WriteCell(GetClientUserId(survivor));
		dpStopNullify.WriteCell(GetClientUserId(tank));
		dpStopNullify.WriteCell(message);

		char sNullifyEffect[4];
		sNullifyEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sNullifyEffect[ST_TankType(tank)] : g_sNullifyEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sNullifyEffect, mode);

		if (iNullifyMessage(tank) == message || iNullifyMessage(tank) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Nullify", sTankName, survivor);
		}
	}
}

static void vRemoveNullify()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bNullify[iSurvivor])
		{
			g_bNullify[iSurvivor] = false;
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bNullify[iPlayer] = false;
		}
	}
}

static int iNullifyAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iNullifyAbility[ST_TankType(tank)] : g_iNullifyAbility2[ST_TankType(tank)];
}

static int iNullifyChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iNullifyChance[ST_TankType(tank)] : g_iNullifyChance2[ST_TankType(tank)];
}

static int iNullifyHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iNullifyHit[ST_TankType(tank)] : g_iNullifyHit2[ST_TankType(tank)];
}

static int iNullifyHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iNullifyHitMode[ST_TankType(tank)] : g_iNullifyHitMode2[ST_TankType(tank)];
}

static int iNullifyMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iNullifyMessage[ST_TankType(tank)] : g_iNullifyMessage2[ST_TankType(tank)];
}

public Action tTimerStopNullify(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor) || !g_bNullify[iSurvivor])
	{
		g_bNullify[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iNullifyChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bNullify[iSurvivor] = false;

		return Plugin_Stop;
	}

	g_bNullify[iSurvivor] = false;

	if (iNullifyMessage(iTank) == iNullifyChat || iNullifyMessage(iTank) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Nullify2", iSurvivor);
	}

	return Plugin_Continue;
}