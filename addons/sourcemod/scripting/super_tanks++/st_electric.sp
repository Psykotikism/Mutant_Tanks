// Super Tanks++: Electric Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Electric Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bElectric[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flElectricDuration[ST_MAXTYPES + 1], g_flElectricDuration2[ST_MAXTYPES + 1], g_flElectricInterval[ST_MAXTYPES + 1], g_flElectricInterval2[ST_MAXTYPES + 1],
	g_flElectricRange[ST_MAXTYPES + 1], g_flElectricRange2[ST_MAXTYPES + 1], g_flElectricSpeed[ST_MAXTYPES + 1], g_flElectricSpeed2[ST_MAXTYPES + 1];
int g_iElectricAbility[ST_MAXTYPES + 1], g_iElectricAbility2[ST_MAXTYPES + 1], g_iElectricChance[ST_MAXTYPES + 1], g_iElectricChance2[ST_MAXTYPES + 1], g_iElectricDamage[ST_MAXTYPES + 1],
	g_iElectricDamage2[ST_MAXTYPES + 1], g_iElectricHit[ST_MAXTYPES + 1], g_iElectricHit2[ST_MAXTYPES + 1], g_iElectricRangeChance[ST_MAXTYPES + 1], g_iElectricRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Electric Ability only supports Left 4 Dead 1 & 2.");
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

public void OnMapStart()
{
	vPrecacheParticle(PARTICLE_ELECTRICITY);
	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_ELECTRICITY2, true);
	vReset();
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
	g_bElectric[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		if (ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iElectricChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iElectricChance[ST_TankType(attacker)] : g_iElectricChance2[ST_TankType(attacker)],
					iElectricHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iElectricHit[ST_TankType(attacker)] : g_iElectricHit2[ST_TankType(attacker)];
				vElectricHit(victim, attacker, iElectricChance, iElectricHit);
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
			main ? (g_iElectricAbility[iIndex] = kvSuperTanks.GetNum("Electric Ability/Ability Enabled", 0)) : (g_iElectricAbility2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Ability Enabled", g_iElectricAbility[iIndex]));
			main ? (g_iElectricAbility[iIndex] = iSetCellLimit(g_iElectricAbility[iIndex], 0, 1)) : (g_iElectricAbility2[iIndex] = iSetCellLimit(g_iElectricAbility2[iIndex], 0, 1));
			main ? (g_iElectricChance[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Chance", 4)) : (g_iElectricChance2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Chance", g_iElectricChance[iIndex]));
			main ? (g_iElectricChance[iIndex] = iSetCellLimit(g_iElectricChance[iIndex], 1, 9999999999)) : (g_iElectricChance2[iIndex] = iSetCellLimit(g_iElectricChance2[iIndex], 1, 9999999999));
			main ? (g_iElectricDamage[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Damage", 5)) : (g_iElectricDamage2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Damage", g_iElectricDamage[iIndex]));
			main ? (g_iElectricDamage[iIndex] = iSetCellLimit(g_iElectricDamage[iIndex], 1, 9999999999)) : (g_iElectricDamage2[iIndex] = iSetCellLimit(g_iElectricDamage2[iIndex], 1, 9999999999));
			main ? (g_flElectricDuration[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Duration", 5.0)) : (g_flElectricDuration2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Duration", g_flElectricDuration[iIndex]));
			main ? (g_flElectricDuration[iIndex] = flSetFloatLimit(g_flElectricDuration[iIndex], 0.1, 9999999999.0)) : (g_flElectricDuration2[iIndex] = flSetFloatLimit(g_flElectricDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iElectricHit[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Hit", 0)) : (g_iElectricHit2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Hit", g_iElectricHit[iIndex]));
			main ? (g_iElectricHit[iIndex] = iSetCellLimit(g_iElectricHit[iIndex], 0, 1)) : (g_iElectricHit2[iIndex] = iSetCellLimit(g_iElectricHit2[iIndex], 0, 1));
			main ? (g_flElectricInterval[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Interval", 1.0)) : (g_flElectricInterval2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Interval", g_flElectricInterval[iIndex]));
			main ? (g_flElectricInterval[iIndex] = flSetFloatLimit(g_flElectricInterval[iIndex], 0.1, 9999999999.0)) : (g_flElectricInterval2[iIndex] = flSetFloatLimit(g_flElectricInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_flElectricRange[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Range", 150.0)) : (g_flElectricRange2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Range", g_flElectricRange[iIndex]));
			main ? (g_flElectricRange[iIndex] = flSetFloatLimit(g_flElectricRange[iIndex], 1.0, 9999999999.0)) : (g_flElectricRange2[iIndex] = flSetFloatLimit(g_flElectricRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iElectricRangeChance[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Range Chance", 16)) : (g_iElectricRangeChance2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Range Chance", g_iElectricRangeChance[iIndex]));
			main ? (g_iElectricRangeChance[iIndex] = iSetCellLimit(g_iElectricRangeChance[iIndex], 1, 9999999999)) : (g_iElectricRangeChance2[iIndex] = iSetCellLimit(g_iElectricRangeChance2[iIndex], 1, 9999999999));
			main ? (g_flElectricSpeed[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Speed", 0.75)) : (g_flElectricSpeed2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Speed", g_flElectricSpeed[iIndex]));
			main ? (g_flElectricSpeed[iIndex] = flSetFloatLimit(g_flElectricSpeed[iIndex], 0.1, 0.9)) : (g_flElectricSpeed2[iIndex] = flSetFloatLimit(g_flElectricSpeed2[iIndex], 0.1, 0.9));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId),
			iElectricAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iElectricAbility[ST_TankType(iTank)] : g_iElectricAbility2[ST_TankType(iTank)];
		if (iElectricAbility == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveElectric();
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iElectricAbility = !g_bTankConfig[ST_TankType(client)] ? g_iElectricAbility[ST_TankType(client)] : g_iElectricAbility2[ST_TankType(client)],
			iElectricRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iElectricChance[ST_TankType(client)] : g_iElectricChance2[ST_TankType(client)];
		float flElectricRange = !g_bTankConfig[ST_TankType(client)] ? g_flElectricRange[ST_TankType(client)] : g_flElectricRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flElectricRange)
				{
					vElectricHit(iSurvivor, client, iElectricRangeChance, iElectricAbility);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	int iElectricAbility = !g_bTankConfig[ST_TankType(client)] ? g_iElectricAbility[ST_TankType(client)] : g_iElectricAbility2[ST_TankType(client)];
	if (iElectricAbility == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled))
	{
		vRemoveElectric();
	}
}

void vElectricHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bElectric[client])
	{
		g_bElectric[client] = true;
		float flElectricSpeed = !g_bTankConfig[ST_TankType(owner)] ? g_flElectricSpeed[ST_TankType(owner)] : g_flElectricSpeed2[ST_TankType(owner)],
			flElectricInterval = !g_bTankConfig[ST_TankType(owner)] ? g_flElectricInterval[ST_TankType(owner)] : g_flElectricInterval2[ST_TankType(owner)];
		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", flElectricSpeed);
		DataPack dpElectric = new DataPack();
		CreateDataTimer(flElectricInterval, tTimerElectric, dpElectric, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpElectric.WriteCell(GetClientUserId(client));
		dpElectric.WriteCell(GetClientUserId(owner));
		dpElectric.WriteCell(enabled);
		dpElectric.WriteFloat(GetEngineTime());
		vAttachParticle(client, PARTICLE_ELECTRICITY, 2.0, 30.0);
	}
}

void vRemoveElectric()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bElectric[iSurvivor])
		{
			SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
		}
	}
}

void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bElectric[iPlayer] = false;
		}
	}
}

public Action tTimerElectric(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bElectric[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bElectric[iSurvivor] = false;
		SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
		return Plugin_Stop;
	}
	int iElectricAbility = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flElectricDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flElectricDuration[ST_TankType(iTank)] : g_flElectricDuration2[ST_TankType(iTank)];
	if (iElectricAbility == 0 || (flTime + flElectricDuration) < GetEngineTime())
	{
		g_bElectric[iSurvivor] = false;
		SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
		return Plugin_Stop;
	}
	char sDamage[6];
	int iElectricDamage = !g_bTankConfig[ST_TankType(iTank)] ? g_iElectricDamage[ST_TankType(iTank)] : g_iElectricDamage2[ST_TankType(iTank)];
	IntToString(iElectricDamage, sDamage, sizeof(sDamage));
	vDamage(iSurvivor, sDamage);
	vShake(iSurvivor);
	vAttachParticle(iSurvivor, PARTICLE_ELECTRICITY, 2.0, 30.0);
	switch (GetRandomInt(1, 2)) 
	{
		case 1: EmitSoundToAll(SOUND_ELECTRICITY, iSurvivor);
		case 2: EmitSoundToAll(SOUND_ELECTRICITY2, iSurvivor);
	}
	return Plugin_Continue;
}