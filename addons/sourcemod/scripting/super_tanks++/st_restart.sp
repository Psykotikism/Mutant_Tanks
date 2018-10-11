// Super Tanks++: Restart Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Restart Ability",
	author = ST_AUTHOR,
	description = "The Super Tank forces survivors to restart at the beginning of the map or near a teammate with a new loadout.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bRestartValid, g_bTankConfig[ST_MAXTYPES + 1];

char g_sRestartEffect[ST_MAXTYPES + 1][4], g_sRestartEffect2[ST_MAXTYPES + 1][4], g_sRestartLoadout[ST_MAXTYPES + 1][325], g_sRestartLoadout2[ST_MAXTYPES + 1][325];

float g_flRestartPosition[3], g_flRestartRange[ST_MAXTYPES + 1], g_flRestartRange2[ST_MAXTYPES + 1];

Handle g_hSDKRespawnPlayer;

int g_iRestartAbility[ST_MAXTYPES + 1], g_iRestartAbility2[ST_MAXTYPES + 1], g_iRestartChance[ST_MAXTYPES + 1], g_iRestartChance2[ST_MAXTYPES + 1], g_iRestartHit[ST_MAXTYPES + 1], g_iRestartHit2[ST_MAXTYPES + 1], g_iRestartHitMode[ST_MAXTYPES + 1], g_iRestartHitMode2[ST_MAXTYPES + 1], g_iRestartMessage[ST_MAXTYPES + 1], g_iRestartMessage2[ST_MAXTYPES + 1], g_iRestartMode[ST_MAXTYPES + 1], g_iRestartMode2[ST_MAXTYPES + 1], g_iRestartRangeChance[ST_MAXTYPES + 1], g_iRestartRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Restart Ability only supports Left 4 Dead 1 & 2.");

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

	Handle hGameData = LoadGameConfigFile("super_tanks++");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "RoundRespawn");
	g_hSDKRespawnPlayer = EndPrepSDKCall();

	if (g_hSDKRespawnPlayer == null)
	{
		PrintToServer("%s Your \"RoundRespawn\" signature is outdated.", ST_PREFIX);
	}

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

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iRestartHitMode(attacker) == 0 || iRestartHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRestartHit(victim, attacker, iRestartChance(attacker), iRestartHit(attacker), 1, "1");
			}
		}
		else if ((iRestartHitMode(victim) == 0 || iRestartHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vRestartHit(attacker, victim, iRestartChance(victim), iRestartHit(victim), 1, "2");
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
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iRestartAbility[iIndex] = kvSuperTanks.GetNum("Restart Ability/Ability Enabled", 0);
				g_iRestartAbility[iIndex] = iClamp(g_iRestartAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Restart Ability/Ability Effect", g_sRestartEffect[iIndex], sizeof(g_sRestartEffect[]), "123");
				g_iRestartMessage[iIndex] = kvSuperTanks.GetNum("Restart Ability/Ability Message", 0);
				g_iRestartMessage[iIndex] = iClamp(g_iRestartMessage[iIndex], 0, 3);
				g_iRestartChance[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Chance", 4);
				g_iRestartChance[iIndex] = iClamp(g_iRestartChance[iIndex], 1, 9999999999);
				g_iRestartHit[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Hit", 0);
				g_iRestartHit[iIndex] = iClamp(g_iRestartHit[iIndex], 0, 1);
				g_iRestartHitMode[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Hit Mode", 0);
				g_iRestartHitMode[iIndex] = iClamp(g_iRestartHitMode[iIndex], 0, 2);
				kvSuperTanks.GetString("Restart Ability/Restart Loadout", g_sRestartLoadout[iIndex], sizeof(g_sRestartLoadout[]), "smg,pistol,pain_pills");
				g_iRestartMode[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Mode", 1);
				g_iRestartMode[iIndex] = iClamp(g_iRestartMode[iIndex], 0, 1);
				g_flRestartRange[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Range", 150.0);
				g_flRestartRange[iIndex] = flClamp(g_flRestartRange[iIndex], 1.0, 9999999999.0);
				g_iRestartRangeChance[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Range Chance", 16);
				g_iRestartRangeChance[iIndex] = iClamp(g_iRestartRangeChance[iIndex], 1, 9999999999);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iRestartAbility2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Ability Enabled", g_iRestartAbility[iIndex]);
				g_iRestartAbility2[iIndex] = iClamp(g_iRestartAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Restart Ability/Ability Effect", g_sRestartEffect2[iIndex], sizeof(g_sRestartEffect2[]), g_sRestartEffect[iIndex]);
				g_iRestartMessage2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Ability Message", g_iRestartMessage[iIndex]);
				g_iRestartMessage2[iIndex] = iClamp(g_iRestartMessage2[iIndex], 0, 3);
				g_iRestartChance2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Chance", g_iRestartChance[iIndex]);
				g_iRestartChance2[iIndex] = iClamp(g_iRestartChance2[iIndex], 1, 9999999999);
				g_iRestartHit2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Hit", g_iRestartHit[iIndex]);
				g_iRestartHit2[iIndex] = iClamp(g_iRestartHit2[iIndex], 0, 1);
				g_iRestartHitMode2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Hit Mode", g_iRestartHitMode[iIndex]);
				g_iRestartHitMode2[iIndex] = iClamp(g_iRestartHitMode2[iIndex], 0, 2);
				kvSuperTanks.GetString("Restart Ability/Restart Loadout", g_sRestartLoadout2[iIndex], sizeof(g_sRestartLoadout2[]), g_sRestartLoadout[iIndex]);
				g_iRestartMode2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Mode", g_iRestartMode[iIndex]);
				g_iRestartMode2[iIndex] = iClamp(g_iRestartMode2[iIndex], 0, 1);
				g_flRestartRange2[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Range", g_flRestartRange[iIndex]);
				g_flRestartRange2[iIndex] = flClamp(g_flRestartRange2[iIndex], 1.0, 9999999999.0);
				g_iRestartRangeChance2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Range Chance", g_iRestartRangeChance[iIndex]);
				g_iRestartRangeChance2[iIndex] = iClamp(g_iRestartRangeChance2[iIndex], 1, 9999999999);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "round_start"))
	{
		CreateTimer(10.0, tTimerRestartCoordinates, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		int iRestartAbility = !g_bTankConfig[ST_TankType(tank)] ? g_iRestartAbility[ST_TankType(tank)] : g_iRestartAbility2[ST_TankType(tank)],
			iRestartRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_iRestartChance[ST_TankType(tank)] : g_iRestartChance2[ST_TankType(tank)];

		float flRestartRange = !g_bTankConfig[ST_TankType(tank)] ? g_flRestartRange[ST_TankType(tank)] : g_flRestartRange2[ST_TankType(tank)],
			flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flRestartRange)
				{
					vRestartHit(iSurvivor, tank, iRestartRangeChance, iRestartAbility, 2, "3");
				}
			}
		}
	}
}

static void vRestartHit(int survivor, int tank, int chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(survivor))
	{
		SDKCall(g_hSDKRespawnPlayer, survivor);

		char sRestartLoadout[325], sItems[5][64];
		int iRestartMessage = !g_bTankConfig[ST_TankType(tank)] ? g_iRestartMessage[ST_TankType(tank)] : g_iRestartMessage2[ST_TankType(tank)],
			iRestartMode = !g_bTankConfig[ST_TankType(tank)] ? g_iRestartMode[ST_TankType(tank)] : g_iRestartMode2[ST_TankType(tank)];
		sRestartLoadout = !g_bTankConfig[ST_TankType(tank)] ? g_sRestartLoadout[ST_TankType(tank)] : g_sRestartLoadout2[ST_TankType(tank)];

		ExplodeString(sRestartLoadout, ",", sItems, sizeof(sItems), sizeof(sItems[]));
		vRemoveWeapon(survivor, 0);
		vRemoveWeapon(survivor, 1);
		vRemoveWeapon(survivor, 2);
		vRemoveWeapon(survivor, 3);
		vRemoveWeapon(survivor, 4);

		for (int iItem = 0; iItem < sizeof(sItems); iItem++)
		{
			if (StrContains(sRestartLoadout, sItems[iItem]) != -1 && sItems[iItem][0] != '\0')
			{
				vCheatCommand(survivor, "give", sItems[iItem]);
			}
		}

		if (g_bRestartValid && iRestartMode == 0)
		{
			TeleportEntity(survivor, g_flRestartPosition, NULL_VECTOR, NULL_VECTOR);
		}
		else
		{
			float flCurrentOrigin[3];
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (!bIsSurvivor(iPlayer) || bIsPlayerIncapacitated(iPlayer) || iPlayer == survivor)
				{
					continue;
				}

				GetClientAbsOrigin(iPlayer, flCurrentOrigin);
				TeleportEntity(survivor, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);
				break;
			}
		}

		char sRestartEffect[4];
		sRestartEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sRestartEffect[ST_TankType(tank)] : g_sRestartEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sRestartEffect, mode);

		if (iRestartMessage == message || iRestartMessage == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Restart", sTankName, survivor);
		}
	}
}

static int iRestartChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRestartChance[ST_TankType(tank)] : g_iRestartChance2[ST_TankType(tank)];
}

static int iRestartHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRestartHit[ST_TankType(tank)] : g_iRestartHit2[ST_TankType(tank)];
}

static int iRestartHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iRestartHitMode[ST_TankType(tank)] : g_iRestartHitMode2[ST_TankType(tank)];
}

public Action tTimerRestartCoordinates(Handle timer)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor))
		{
			g_bRestartValid = true;
			GetClientAbsOrigin(iSurvivor, g_flRestartPosition);
			break;
		}
	}

	if (g_flRestartPosition[0] == 0.0 && g_flRestartPosition[1] == 0.0 && g_flRestartPosition[2] == 0.0)
	{
		g_bRestartValid = false;
	}
}