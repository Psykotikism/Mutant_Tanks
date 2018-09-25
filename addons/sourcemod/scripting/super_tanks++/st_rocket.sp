// Super Tanks++: Rocket Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Rocket Ability",
	author = ST_AUTHOR,
	description = "The Super Tank sends survivors into space.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bRocket[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flRocketDelay[ST_MAXTYPES + 1], g_flRocketDelay2[ST_MAXTYPES + 1], g_flRocketRange[ST_MAXTYPES + 1], g_flRocketRange2[ST_MAXTYPES + 1];
int g_iRocket[ST_MAXTYPES + 1], g_iRocketAbility[ST_MAXTYPES + 1], g_iRocketAbility2[ST_MAXTYPES + 1], g_iRocketChance[ST_MAXTYPES + 1], g_iRocketChance2[ST_MAXTYPES + 1], g_iRocketHit[ST_MAXTYPES + 1], g_iRocketHit2[ST_MAXTYPES + 1], g_iRocketHitMode[ST_MAXTYPES + 1], g_iRocketHitMode2[ST_MAXTYPES + 1], g_iRocketMessage[ST_MAXTYPES + 1], g_iRocketMessage2[ST_MAXTYPES + 1], g_iRocketRangeChance[ST_MAXTYPES + 1], g_iRocketRangeChance2[ST_MAXTYPES + 1], g_iRocketSprite = -1;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_Left4Dead && !bIsL4D2())
	{
		strcopy(error, err_max, "[ST++] Rocket Ability only supports Left 4 Dead 1 & 2.");
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
	g_iRocketSprite = PrecacheModel(SPRITE_FIRE, true);
	PrecacheSound(SOUND_EXPLOSION, true);
	PrecacheSound(SOUND_FIRE, true);
	PrecacheSound(SOUND_LAUNCH, true);
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bRocket[client] = false;
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
		if ((iRocketHitMode(attacker) == 0 || iRocketHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vRocketHit(victim, attacker, iRocketChance(attacker), iRocketHit(attacker), 1);
			}
		}
		else if ((iRocketHitMode(victim) == 0 || iRocketHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vRocketHit(attacker, victim, iRocketChance(victim), iRocketHit(victim), 1);
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
			main ? (g_iRocketAbility[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Ability Enabled", 0)) : (g_iRocketAbility2[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Ability Enabled", g_iRocketAbility[iIndex]));
			main ? (g_iRocketAbility[iIndex] = iClamp(g_iRocketAbility[iIndex], 0, 1)) : (g_iRocketAbility2[iIndex] = iClamp(g_iRocketAbility2[iIndex], 0, 1));
			main ? (g_iRocketMessage[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Ability Message", 0)) : (g_iRocketMessage2[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Ability Message", g_iRocketMessage[iIndex]));
			main ? (g_iRocketMessage[iIndex] = iClamp(g_iRocketMessage[iIndex], 0, 3)) : (g_iRocketMessage2[iIndex] = iClamp(g_iRocketMessage2[iIndex], 0, 3));
			main ? (g_iRocketChance[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Rocket Chance", 4)) : (g_iRocketChance2[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Rocket Chance", g_iRocketChance[iIndex]));
			main ? (g_iRocketChance[iIndex] = iClamp(g_iRocketChance[iIndex], 1, 9999999999)) : (g_iRocketChance2[iIndex] = iClamp(g_iRocketChance2[iIndex], 1, 9999999999));
			main ? (g_flRocketDelay[iIndex] = kvSuperTanks.GetFloat("Rocket Ability/Rocket Delay", 1.0)) : (g_flRocketDelay2[iIndex] = kvSuperTanks.GetFloat("Rocket Ability/Rocket Delay", g_flRocketDelay[iIndex]));
			main ? (g_flRocketDelay[iIndex] = flClamp(g_flRocketDelay[iIndex], 0.1, 9999999999.0)) : (g_flRocketDelay2[iIndex] = flClamp(g_flRocketDelay2[iIndex], 0.1, 9999999999.0));
			main ? (g_iRocketHit[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Rocket Hit", 0)) : (g_iRocketHit2[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Rocket Hit", g_iRocketHit[iIndex]));
			main ? (g_iRocketHit[iIndex] = iClamp(g_iRocketHit[iIndex], 0, 1)) : (g_iRocketHit2[iIndex] = iClamp(g_iRocketHit2[iIndex], 0, 1));
			main ? (g_iRocketHitMode[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Rocket Hit Mode", 0)) : (g_iRocketHitMode2[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Rocket Hit Mode", g_iRocketHitMode[iIndex]));
			main ? (g_iRocketHitMode[iIndex] = iClamp(g_iRocketHitMode[iIndex], 0, 2)) : (g_iRocketHitMode2[iIndex] = iClamp(g_iRocketHitMode2[iIndex], 0, 2));
			main ? (g_flRocketRange[iIndex] = kvSuperTanks.GetFloat("Rocket Ability/Rocket Range", 150.0)) : (g_flRocketRange2[iIndex] = kvSuperTanks.GetFloat("Rocket Ability/Rocket Range", g_flRocketRange[iIndex]));
			main ? (g_flRocketRange[iIndex] = flClamp(g_flRocketRange[iIndex], 1.0, 9999999999.0)) : (g_flRocketRange2[iIndex] = flClamp(g_flRocketRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iRocketRangeChance[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Rocket Range Chance", 16)) : (g_iRocketRangeChance2[iIndex] = kvSuperTanks.GetNum("Rocket Ability/Rocket Range Chance", g_iRocketRangeChance[iIndex]));
			main ? (g_iRocketRangeChance[iIndex] = iClamp(g_iRocketRangeChance[iIndex], 1, 9999999999)) : (g_iRocketRangeChance2[iIndex] = iClamp(g_iRocketRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iRocketAbility = !g_bTankConfig[ST_TankType(client)] ? g_iRocketAbility[ST_TankType(client)] : g_iRocketAbility2[ST_TankType(client)],
			iRocketRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iRocketChance[ST_TankType(client)] : g_iRocketChance2[ST_TankType(client)];
		float flRocketRange = !g_bTankConfig[ST_TankType(client)] ? g_flRocketRange[ST_TankType(client)] : g_flRocketRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flRocketRange)
				{
					vRocketHit(iSurvivor, client, iRocketRangeChance, iRocketAbility, 2);
				}
			}
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bRocket[iPlayer] = false;
		}
	}
}

stock void vRocketHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bRocket[client])
	{
		int iFlame = CreateEntityByName("env_steam");
		if (!bIsValidEntity(iFlame))
		{
			return;
		}
		g_bRocket[client] = true;
		float flRocketDelay = !g_bTankConfig[ST_TankType(owner)] ? g_flRocketDelay[ST_TankType(owner)] : g_flRocketDelay2[ST_TankType(owner)],
			flPosition[3], flAngles[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPosition);
		flPosition[2] += 30.0;
		flAngles[0] = 90.0, flAngles[1] = 0.0, flAngles[2] = 0.0;
		DispatchKeyValue(iFlame, "spawnflags", "1");
		DispatchKeyValue(iFlame, "Type", "0");
		DispatchKeyValue(iFlame, "InitialState", "1");
		DispatchKeyValue(iFlame, "Spreadspeed", "10");
		DispatchKeyValue(iFlame, "Speed", "800");
		DispatchKeyValue(iFlame, "Startsize", "10");
		DispatchKeyValue(iFlame, "EndSize", "250");
		DispatchKeyValue(iFlame, "Rate", "15");
		DispatchKeyValue(iFlame, "JetLength", "400");
		SetEntityRenderColor(iFlame, 180, 70, 10, 180);
		TeleportEntity(iFlame, flPosition, flAngles, NULL_VECTOR);
		DispatchSpawn(iFlame);
		vSetEntityParent(iFlame, client);
		iFlame = EntIndexToEntRef(iFlame);
		vDeleteEntity(iFlame, 3.0);
		g_iRocket[client] = iFlame;
		EmitSoundToAll(SOUND_FIRE, client, _, _, _, 1.0);
		DataPack dpRocketLaunch = new DataPack();
		CreateDataTimer(flRocketDelay, tTimerRocketLaunch, dpRocketLaunch, TIMER_FLAG_NO_MAPCHANGE);
		dpRocketLaunch.WriteCell(GetClientUserId(client)), dpRocketLaunch.WriteCell(GetClientUserId(owner)), dpRocketLaunch.WriteCell(enabled);
		DataPack dpRocketDetonate = new DataPack();
		CreateDataTimer(flRocketDelay + 1.5, tTimerRocketDetonate, dpRocketDetonate, TIMER_FLAG_NO_MAPCHANGE);
		dpRocketDetonate.WriteCell(GetClientUserId(client)), dpRocketDetonate.WriteCell(GetClientUserId(owner)), dpRocketDetonate.WriteCell(message), dpRocketDetonate.WriteCell(enabled);
	}
}

stock int iRocketChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iRocketChance[ST_TankType(client)] : g_iRocketChance2[ST_TankType(client)];
}

stock int iRocketHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iRocketHit[ST_TankType(client)] : g_iRocketHit2[ST_TankType(client)];
}

stock int iRocketHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iRocketHitMode[ST_TankType(client)] : g_iRocketHitMode2[ST_TankType(client)];
}

public Action tTimerRocketLaunch(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		return Plugin_Stop;
	}
	int iRocketAbility = pack.ReadCell();
	if (iRocketAbility == 0)
	{
		return Plugin_Stop;
	}
	float flVelocity[3];
	flVelocity[0] = 0.0, flVelocity[1] = 0.0, flVelocity[2] = 800.0;
	EmitSoundToAll(SOUND_EXPLOSION, iSurvivor, _, _, _, 1.0);
	EmitSoundToAll(SOUND_LAUNCH, iSurvivor, _, _, _, 1.0);
	TeleportEntity(iSurvivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
	SetEntityGravity(iSurvivor, 0.1);
	return Plugin_Handled;
}

public Action tTimerRocketDetonate(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bRocket[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell()), iRocketChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bRocket[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iRocketAbility = pack.ReadCell();
	if (iRocketAbility == 0)
	{
		g_bRocket[iSurvivor] = false;
		return Plugin_Stop;
	}
	float flPosition[3];
	int iRocketMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_iRocketMessage[ST_TankType(iTank)] : g_iRocketMessage2[ST_TankType(iTank)];
	GetClientAbsOrigin(iSurvivor, flPosition);
	TE_SetupExplosion(flPosition, g_iRocketSprite, 10.0, 1, 0, 600, 5000);
	TE_SendToAll();
	g_iRocket[iSurvivor] = 0;
	ForcePlayerSuicide(iSurvivor);
	SetEntityGravity(iSurvivor, 1.0);
	if (iRocketMessage == iRocketChat || iRocketMessage == 3)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		ST_TankName(iTank, sTankName);
		PrintToChatAll("%s %t", ST_PREFIX2, "Rocket", sTankName, iSurvivor);
	}
	g_bRocket[iSurvivor] = false;
	return Plugin_Handled;
}