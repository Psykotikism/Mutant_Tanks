// Super Tanks++: Electric Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

#define PARTICLE_ELECTRICITY "electrical_arc_01_system"
#define SOUND_ELECTRICITY "ambient/energy/zap5.wav"
#define SOUND_ELECTRICITY2 "ambient/energy/zap7.wav"

public Plugin myinfo =
{
	name = "[ST++] Electric Ability",
	author = ST_AUTHOR,
	description = "The Super Tank electrocutes survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bElectric[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
char g_sElectricEffect[ST_MAXTYPES + 1][4], g_sElectricEffect2[ST_MAXTYPES + 1][4];
float g_flElectricDuration[ST_MAXTYPES + 1], g_flElectricDuration2[ST_MAXTYPES + 1], g_flElectricInterval[ST_MAXTYPES + 1], g_flElectricInterval2[ST_MAXTYPES + 1], g_flElectricRange[ST_MAXTYPES + 1], g_flElectricRange2[ST_MAXTYPES + 1], g_flElectricSpeed[ST_MAXTYPES + 1], g_flElectricSpeed2[ST_MAXTYPES + 1];
int g_iElectricAbility[ST_MAXTYPES + 1], g_iElectricAbility2[ST_MAXTYPES + 1], g_iElectricChance[ST_MAXTYPES + 1], g_iElectricChance2[ST_MAXTYPES + 1], g_iElectricDamage[ST_MAXTYPES + 1], g_iElectricDamage2[ST_MAXTYPES + 1], g_iElectricHit[ST_MAXTYPES + 1], g_iElectricHit2[ST_MAXTYPES + 1], g_iElectricHitMode[ST_MAXTYPES + 1], g_iElectricHitMode2[ST_MAXTYPES + 1], g_iElectricMessage[ST_MAXTYPES + 1], g_iElectricMessage2[ST_MAXTYPES + 1], g_iElectricRangeChance[ST_MAXTYPES + 1], g_iElectricRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
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
	vPrecacheParticle(PARTICLE_ELECTRICITY);
	PrecacheSound(SOUND_ELECTRICITY, true);
	PrecacheSound(SOUND_ELECTRICITY2, true);
	vReset();
}

public void OnClientPutInServer(int client)
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
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((iElectricHitMode(attacker) == 0 || iElectricHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vElectricHit(victim, attacker, iElectricChance(attacker), iElectricHit(attacker), 1, "1");
			}
		}
		else if ((iElectricHitMode(victim) == 0 || iElectricHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vElectricHit(attacker, victim, iElectricChance(victim), iElectricHit(victim), 1, "2");
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
			main ? (g_iElectricAbility[iIndex] = kvSuperTanks.GetNum("Electric Ability/Ability Enabled", 0)) : (g_iElectricAbility2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Ability Enabled", g_iElectricAbility[iIndex]));
			main ? (g_iElectricAbility[iIndex] = iClamp(g_iElectricAbility[iIndex], 0, 1)) : (g_iElectricAbility2[iIndex] = iClamp(g_iElectricAbility2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("Electric Ability/Ability Effect", g_sElectricEffect[iIndex], sizeof(g_sElectricEffect[]), "123")) : (kvSuperTanks.GetString("Electric Ability/Ability Effect", g_sElectricEffect2[iIndex], sizeof(g_sElectricEffect2[]), g_sElectricEffect[iIndex]));
			main ? (g_iElectricMessage[iIndex] = kvSuperTanks.GetNum("Electric Ability/Ability Message", 0)) : (g_iElectricMessage2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Ability Message", g_iElectricMessage[iIndex]));
			main ? (g_iElectricMessage[iIndex] = iClamp(g_iElectricMessage[iIndex], 0, 3)) : (g_iElectricMessage2[iIndex] = iClamp(g_iElectricMessage2[iIndex], 0, 3));
			main ? (g_iElectricChance[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Chance", 4)) : (g_iElectricChance2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Chance", g_iElectricChance[iIndex]));
			main ? (g_iElectricChance[iIndex] = iClamp(g_iElectricChance[iIndex], 1, 9999999999)) : (g_iElectricChance2[iIndex] = iClamp(g_iElectricChance2[iIndex], 1, 9999999999));
			main ? (g_iElectricDamage[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Damage", 5)) : (g_iElectricDamage2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Damage", g_iElectricDamage[iIndex]));
			main ? (g_iElectricDamage[iIndex] = iClamp(g_iElectricDamage[iIndex], 1, 9999999999)) : (g_iElectricDamage2[iIndex] = iClamp(g_iElectricDamage2[iIndex], 1, 9999999999));
			main ? (g_flElectricDuration[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Duration", 5.0)) : (g_flElectricDuration2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Duration", g_flElectricDuration[iIndex]));
			main ? (g_flElectricDuration[iIndex] = flClamp(g_flElectricDuration[iIndex], 0.1, 9999999999.0)) : (g_flElectricDuration2[iIndex] = flClamp(g_flElectricDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iElectricHit[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Hit", 0)) : (g_iElectricHit2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Hit", g_iElectricHit[iIndex]));
			main ? (g_iElectricHit[iIndex] = iClamp(g_iElectricHit[iIndex], 0, 1)) : (g_iElectricHit2[iIndex] = iClamp(g_iElectricHit2[iIndex], 0, 1));
			main ? (g_iElectricHitMode[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Hit Mode", 0)) : (g_iElectricHitMode2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Hit Mode", g_iElectricHitMode[iIndex]));
			main ? (g_iElectricHitMode[iIndex] = iClamp(g_iElectricHitMode[iIndex], 0, 2)) : (g_iElectricHitMode2[iIndex] = iClamp(g_iElectricHitMode2[iIndex], 0, 2));
			main ? (g_flElectricInterval[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Interval", 1.0)) : (g_flElectricInterval2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Interval", g_flElectricInterval[iIndex]));
			main ? (g_flElectricInterval[iIndex] = flClamp(g_flElectricInterval[iIndex], 0.1, 9999999999.0)) : (g_flElectricInterval2[iIndex] = flClamp(g_flElectricInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_flElectricRange[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Range", 150.0)) : (g_flElectricRange2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Range", g_flElectricRange[iIndex]));
			main ? (g_flElectricRange[iIndex] = flClamp(g_flElectricRange[iIndex], 1.0, 9999999999.0)) : (g_flElectricRange2[iIndex] = flClamp(g_flElectricRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iElectricRangeChance[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Range Chance", 16)) : (g_iElectricRangeChance2[iIndex] = kvSuperTanks.GetNum("Electric Ability/Electric Range Chance", g_iElectricRangeChance[iIndex]));
			main ? (g_iElectricRangeChance[iIndex] = iClamp(g_iElectricRangeChance[iIndex], 1, 9999999999)) : (g_iElectricRangeChance2[iIndex] = iClamp(g_iElectricRangeChance2[iIndex], 1, 9999999999));
			main ? (g_flElectricSpeed[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Speed", 0.75)) : (g_flElectricSpeed2[iIndex] = kvSuperTanks.GetFloat("Electric Ability/Electric Speed", g_flElectricSpeed[iIndex]));
			main ? (g_flElectricSpeed[iIndex] = flClamp(g_flElectricSpeed[iIndex], 0.1, 0.9)) : (g_flElectricSpeed2[iIndex] = flClamp(g_flElectricSpeed2[iIndex], 0.1, 0.9));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vReset();
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		int iElectricRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_iElectricChance[ST_TankType(tank)] : g_iElectricChance2[ST_TankType(tank)];
		float flElectricRange = !g_bTankConfig[ST_TankType(tank)] ? g_flElectricRange[ST_TankType(tank)] : g_flElectricRange2[ST_TankType(tank)],
			flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flElectricRange)
				{
					vElectricHit(iSurvivor, tank, iElectricRangeChance, iElectricAbility(tank), 2, "3");
				}
			}
		}
	}
}

stock void vElectricHit(int survivor, int tank, int chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(survivor) && !g_bElectric[survivor])
	{
		g_bElectric[survivor] = true;
		float flElectricSpeed = !g_bTankConfig[ST_TankType(tank)] ? g_flElectricSpeed[ST_TankType(tank)] : g_flElectricSpeed2[ST_TankType(tank)],
			flElectricInterval = !g_bTankConfig[ST_TankType(tank)] ? g_flElectricInterval[ST_TankType(tank)] : g_flElectricInterval2[ST_TankType(tank)];
		SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", flElectricSpeed);
		DataPack dpElectric = new DataPack();
		CreateDataTimer(flElectricInterval, tTimerElectric, dpElectric, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpElectric.WriteCell(GetClientUserId(survivor)), dpElectric.WriteCell(GetClientUserId(tank)), dpElectric.WriteCell(message), dpElectric.WriteCell(enabled), dpElectric.WriteFloat(GetEngineTime());
		vAttachParticle(survivor, PARTICLE_ELECTRICITY, 2.0, 30.0);
		char sElectricEffect[4];
		sElectricEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sElectricEffect[ST_TankType(tank)] : g_sElectricEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sElectricEffect, mode);
		if (iElectricMessage(tank) == message || iElectricMessage(tank) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Electric", sTankName, survivor);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bElectric[iPlayer] = false;
		}
	}
}

stock void vReset2(int survivor, int tank, int message)
{
	g_bElectric[survivor] = false;
	SetEntPropFloat(survivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
	if (iElectricMessage(tank) == message || iElectricMessage(tank) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Electric2", survivor);
	}
}

stock int iElectricAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iElectricAbility[ST_TankType(tank)] : g_iElectricAbility2[ST_TankType(tank)];
}

stock int iElectricChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iElectricChance[ST_TankType(tank)] : g_iElectricChance2[ST_TankType(tank)];
}

stock int iElectricHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iElectricHit[ST_TankType(tank)] : g_iElectricHit2[ST_TankType(tank)];
}

stock int iElectricHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iElectricHitMode[ST_TankType(tank)] : g_iElectricHitMode2[ST_TankType(tank)];
}

stock int iElectricMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iElectricMessage[ST_TankType(tank)] : g_iElectricMessage2[ST_TankType(tank)];
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
	int iTank = GetClientOfUserId(pack.ReadCell()), iElectricChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bElectric[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iElectricChat);
		return Plugin_Stop;
	}
	int iElectricEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flElectricDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flElectricDuration[ST_TankType(iTank)] : g_flElectricDuration2[ST_TankType(iTank)];
	if (iElectricEnabled == 0 || (flTime + flElectricDuration) < GetEngineTime())
	{
		vReset2(iSurvivor, iTank, iElectricChat);
		return Plugin_Stop;
	}
	char sDamage[11];
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