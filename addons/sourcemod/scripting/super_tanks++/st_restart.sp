// Super Tanks++: Restart Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Restart Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bRestartValid;
bool g_bTankConfig[ST_MAXTYPES + 1];
char g_sRestartLoadout[ST_MAXTYPES + 1][325];
char g_sRestartLoadout2[ST_MAXTYPES + 1][325];
float g_flRestartPosition[3];
float g_flRestartRange[ST_MAXTYPES + 1];
float g_flRestartRange2[ST_MAXTYPES + 1];
Handle g_hSDKRespawnPlayer;
int g_iRestartAbility[ST_MAXTYPES + 1];
int g_iRestartAbility2[ST_MAXTYPES + 1];
int g_iRestartChance[ST_MAXTYPES + 1];
int g_iRestartChance2[ST_MAXTYPES + 1];
int g_iRestartHit[ST_MAXTYPES + 1];
int g_iRestartHit2[ST_MAXTYPES + 1];
int g_iRestartRangeChance[ST_MAXTYPES + 1];
int g_iRestartRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Restart Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
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
	Handle hGameData = LoadGameConfigFile("super_tanks++");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "RoundRespawn");
	g_hSDKRespawnPlayer = EndPrepSDKCall();
	if (g_hSDKRespawnPlayer == null)
	{
		PrintToServer("%s Your \"RoundRespawn\" signature is outdated.", ST_PREFIX);
	}
}

public void OnMapStart()
{
	if (g_bLateLoad)
	{
		vLateLoad(true);
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnMapEnd()
{
	g_bRestartValid = false;
}

void vLateLoad(bool late)
{
	if (late)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				SDKHook(iPlayer, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		if (ST_TankAllowed(attacker) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iRestartChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iRestartChance[ST_TankType(attacker)] : g_iRestartChance2[ST_TankType(attacker)];
				int iRestartHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iRestartHit[ST_TankType(attacker)] : g_iRestartHit2[ST_TankType(attacker)];
				vRestartHit(victim, attacker, iRestartChance, iRestartHit);
			}
		}
	}
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
			main ? (g_iRestartAbility[iIndex] = kvSuperTanks.GetNum("Restart Ability/Ability Enabled", 0)) : (g_iRestartAbility2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Ability Enabled", g_iRestartAbility[iIndex]));
			main ? (g_iRestartAbility[iIndex] = iSetCellLimit(g_iRestartAbility[iIndex], 0, 1)) : (g_iRestartAbility2[iIndex] = iSetCellLimit(g_iRestartAbility2[iIndex], 0, 1));
			main ? (g_iRestartChance[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Chance", 4)) : (g_iRestartChance2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Chance", g_iRestartChance[iIndex]));
			main ? (g_iRestartChance[iIndex] = iSetCellLimit(g_iRestartChance[iIndex], 1, 9999999999)) : (g_iRestartChance2[iIndex] = iSetCellLimit(g_iRestartChance2[iIndex], 1, 9999999999));
			main ? (g_iRestartHit[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Hit", 0)) : (g_iRestartHit2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Hit", g_iRestartHit[iIndex]));
			main ? (g_iRestartHit[iIndex] = iSetCellLimit(g_iRestartHit[iIndex], 0, 1)) : (g_iRestartHit2[iIndex] = iSetCellLimit(g_iRestartHit2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("Restart Ability/Restart Loadout", g_sRestartLoadout[iIndex], sizeof(g_sRestartLoadout[]), "smg,pistol,pain_pills")) : (kvSuperTanks.GetString("Restart Ability/Restart Loadout", g_sRestartLoadout2[iIndex], sizeof(g_sRestartLoadout2[]), g_sRestartLoadout[iIndex]));
			main ? (g_flRestartRange[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Range", 150.0)) : (g_flRestartRange2[iIndex] = kvSuperTanks.GetFloat("Restart Ability/Restart Range", g_flRestartRange[iIndex]));
			main ? (g_flRestartRange[iIndex] = flSetFloatLimit(g_flRestartRange[iIndex], 1.0, 9999999999.0)) : (g_flRestartRange2[iIndex] = flSetFloatLimit(g_flRestartRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iRestartRangeChance[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Range Chance", 16)) : (g_iRestartRangeChance2[iIndex] = kvSuperTanks.GetNum("Restart Ability/Restart Range Chance", g_iRestartRangeChance[iIndex]));
			main ? (g_iRestartRangeChance[iIndex] = iSetCellLimit(g_iRestartRangeChance[iIndex], 1, 9999999999)) : (g_iRestartRangeChance2[iIndex] = iSetCellLimit(g_iRestartRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_RoundStart()
{
	CreateTimer(10.0, tTimerRestartCoordinates, _, TIMER_FLAG_NO_MAPCHANGE);
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iRestartAbility = !g_bTankConfig[ST_TankType(client)] ? g_iRestartAbility[ST_TankType(client)] : g_iRestartAbility2[ST_TankType(client)];
		int iRestartRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iRestartChance[ST_TankType(client)] : g_iRestartChance2[ST_TankType(client)];
		float flRestartRange = !g_bTankConfig[ST_TankType(client)] ? g_flRestartRange[ST_TankType(client)] : g_flRestartRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flRestartRange)
				{
					vRestartHit(iSurvivor, client, iRestartRangeChance, iRestartAbility);
				}
			}
		}
	}
}

void vRestartHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		SDKCall(g_hSDKRespawnPlayer, client);
		char sRestartLoadout[325];
		sRestartLoadout = !g_bTankConfig[ST_TankType(owner)] ? g_sRestartLoadout[ST_TankType(owner)] : g_sRestartLoadout2[ST_TankType(owner)];
		char sItems[5][64];
		ExplodeString(sRestartLoadout, ",", sItems, sizeof(sItems), sizeof(sItems[]));
		for (int iItem = 0; iItem < sizeof(sItems); iItem++)
		{
			if (StrContains(sRestartLoadout, sItems[iItem]) != -1 && sItems[iItem][0] != '\0')
			{
				char sCommand[32] = "give";
				int iCmdFlags = GetCommandFlags(sCommand);
				SetCommandFlags(sCommand, iCmdFlags & ~FCVAR_CHEAT);
				FakeClientCommand(client, "%s %s", sCommand, sItems[iItem]);
				SetCommandFlags(sCommand, iCmdFlags|FCVAR_CHEAT);
			}
		}
		if (g_bRestartValid)
		{
			TeleportEntity(client, g_flRestartPosition, NULL_VECTOR, NULL_VECTOR);
		}
		else
		{
			float flCurrentOrigin[3];
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (!bIsSurvivor(iPlayer) || iPlayer == client)
				{
					continue;
				}
				GetClientAbsOrigin(iPlayer, flCurrentOrigin);
				TeleportEntity(client, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);
			}
		}
	}
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

public Action tTimerRestartCoordinates(Handle timer)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor))
		{
			g_bRestartValid = true;
			g_flRestartPosition[0] = 0.0;
			g_flRestartPosition[1] = 0.0;
			g_flRestartPosition[2] = 0.0;
			GetClientAbsOrigin(iSurvivor, g_flRestartPosition);
			break;
		}
	}
}