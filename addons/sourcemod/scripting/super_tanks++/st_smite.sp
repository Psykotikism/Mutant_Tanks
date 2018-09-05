// Super Tanks++: Smite Ability
#define REQUIRE_PLUGIN
#include <super_tanks++>
#undef REQUIRE_PLUGIN
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Smite Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flSmiteRange[ST_MAXTYPES + 1], g_flSmiteRange2[ST_MAXTYPES + 1];
int g_iSmiteAbility[ST_MAXTYPES + 1], g_iSmiteAbility2[ST_MAXTYPES + 1], g_iSmiteChance[ST_MAXTYPES + 1], g_iSmiteChance2[ST_MAXTYPES + 1], g_iSmiteHit[ST_MAXTYPES + 1],
	g_iSmiteHit2[ST_MAXTYPES + 1], g_iSmiteRangeChance[ST_MAXTYPES + 1], g_iSmiteRangeChance2[ST_MAXTYPES + 1], g_iSmiteSprite = -1;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Smite Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnMapStart()
{
	g_iSmiteSprite = PrecacheModel(SPRITE_GLOW, true);
	PrecacheSound(SOUND_EXPLOSION2, true);
	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				SDKHook(iPlayer, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
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
				int iSmiteChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iSmiteChance[ST_TankType(attacker)] : g_iSmiteChance2[ST_TankType(attacker)],
					iSmiteHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iSmiteHit[ST_TankType(attacker)] : g_iSmiteHit2[ST_TankType(attacker)];
				vSmiteHit(victim, iSmiteChance, iSmiteHit);
			}
		}
	}
}

public void ST_Configs(char[] savepath, bool main)
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
			main ? (g_iSmiteAbility[iIndex] = kvSuperTanks.GetNum("Smite Ability/Ability Enabled", 0)) : (g_iSmiteAbility2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Ability Enabled", g_iSmiteAbility[iIndex]));
			main ? (g_iSmiteAbility[iIndex] = iSetCellLimit(g_iSmiteAbility[iIndex], 0, 1)) : (g_iSmiteAbility2[iIndex] = iSetCellLimit(g_iSmiteAbility2[iIndex], 0, 1));
			main ? (g_iSmiteChance[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Chance", 4)) : (g_iSmiteChance2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Chance", g_iSmiteChance[iIndex]));
			main ? (g_iSmiteChance[iIndex] = iSetCellLimit(g_iSmiteChance[iIndex], 1, 9999999999)) : (g_iSmiteChance2[iIndex] = iSetCellLimit(g_iSmiteChance2[iIndex], 1, 9999999999));
			main ? (g_iSmiteHit[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Hit", 0)) : (g_iSmiteHit2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Hit", g_iSmiteHit[iIndex]));
			main ? (g_iSmiteHit[iIndex] = iSetCellLimit(g_iSmiteHit[iIndex], 0, 1)) : (g_iSmiteHit2[iIndex] = iSetCellLimit(g_iSmiteHit2[iIndex], 0, 1));
			main ? (g_flSmiteRange[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Range", 150.0)) : (g_flSmiteRange2[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Range", g_flSmiteRange[iIndex]));
			main ? (g_flSmiteRange[iIndex] = flSetFloatLimit(g_flSmiteRange[iIndex], 1.0, 9999999999.0)) : (g_flSmiteRange2[iIndex] = flSetFloatLimit(g_flSmiteRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iSmiteRangeChance[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Range Chance", 16)) : (g_iSmiteRangeChance2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Range Chance", g_iSmiteRangeChance[iIndex]));
			main ? (g_iSmiteRangeChance[iIndex] = iSetCellLimit(g_iSmiteRangeChance[iIndex], 1, 9999999999)) : (g_iSmiteRangeChance2[iIndex] = iSetCellLimit(g_iSmiteRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iSmiteAbility = !g_bTankConfig[ST_TankType(client)] ? g_iSmiteAbility[ST_TankType(client)] : g_iSmiteAbility2[ST_TankType(client)],
			iSmiteRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iSmiteChance[ST_TankType(client)] : g_iSmiteChance2[ST_TankType(client)];
		float flSmiteRange = !g_bTankConfig[ST_TankType(client)] ? g_flSmiteRange[ST_TankType(client)] : g_flSmiteRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flSmiteRange)
				{
					vSmiteHit(iSurvivor, iSmiteRangeChance, iSmiteAbility);
				}
			}
		}
	}
}

void vSmiteHit(int client, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		float flPosition[3], flStartPosition[3], flDirection[3] = {0.0, 0.0, 0.0};
		GetClientAbsOrigin(client, flPosition);
		flPosition[2] -= 26;
		flStartPosition[0] = flPosition[0] + GetRandomInt(-500, 500), flStartPosition[1] = flPosition[1] + GetRandomInt(-500, 500), flStartPosition[2] = flPosition[2] + 800;
		int iColor[4] = {255, 255, 255, 255};
		TE_SetupBeamPoints(flStartPosition, flPosition, g_iSmiteSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, iColor, 3);
		TE_SendToAll();
		TE_SetupSparks(flPosition, flDirection, 5000, 1000);
		TE_SendToAll();
		TE_SetupEnergySplash(flPosition, flDirection, false);
		TE_SendToAll();
		EmitAmbientSound(SOUND_EXPLOSION2, flStartPosition, client, SNDLEVEL_RAIDSIREN);
		ForcePlayerSuicide(client);
	}
}