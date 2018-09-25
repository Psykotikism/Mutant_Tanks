// Super Tanks++: Warp Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Warp Ability",
	author = ST_AUTHOR,
	description = "The Super Tank warps to survivors and warps survivors back to teammates.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1], g_bWarp[MAXPLAYERS + 1];
char g_sParticleEffects[ST_MAXTYPES + 1][8], g_sParticleEffects2[ST_MAXTYPES + 1][8];
float g_flWarpInterval[ST_MAXTYPES + 1], g_flWarpInterval2[ST_MAXTYPES + 1], g_flWarpRange[ST_MAXTYPES + 1], g_flWarpRange2[ST_MAXTYPES + 1];
int g_iParticleEffect[ST_MAXTYPES + 1], g_iParticleEffect2[ST_MAXTYPES + 1], g_iWarpAbility[ST_MAXTYPES + 1], g_iWarpAbility2[ST_MAXTYPES + 1], g_iWarpChance[ST_MAXTYPES + 1], g_iWarpChance2[ST_MAXTYPES + 1], g_iWarpHit[ST_MAXTYPES + 1], g_iWarpHit2[ST_MAXTYPES + 1], g_iWarpHitMode[ST_MAXTYPES + 1], g_iWarpHitMode2[ST_MAXTYPES + 1], g_iWarpMessage[ST_MAXTYPES + 1], g_iWarpMessage2[ST_MAXTYPES + 1], g_iWarpMode[ST_MAXTYPES + 1], g_iWarpMode2[ST_MAXTYPES + 1], g_iWarpRangeChance[ST_MAXTYPES + 1], g_iWarpRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Warp Ability only supports Left 4 Dead 1 & 2.");
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
	vPrecacheParticle(PARTICLE_ELECTRICITY);
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bWarp[client] = false;
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
		if ((iWarpHitMode(attacker) == 0 || iWarpHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vWarpHit(victim, attacker, iWarpChance(attacker), iWarpHit(attacker), 1);
			}
		}
		else if ((iWarpHitMode(victim) == 0 || iWarpHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vWarpHit(attacker, victim, iWarpChance(victim), iWarpHit(victim), 1);
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
			main ? (g_iParticleEffect[iIndex] = kvSuperTanks.GetNum("Particles/Body Particle", 0)) : (g_iParticleEffect2[iIndex] = kvSuperTanks.GetNum("Particles/Body Particle", g_iParticleEffect[iIndex]));
			main ? (g_iParticleEffect[iIndex] = iClamp(g_iParticleEffect[iIndex], 0, 1)) : (g_iParticleEffect2[iIndex] = iClamp(g_iParticleEffect2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("Particles/Body Effects", g_sParticleEffects[iIndex], sizeof(g_sParticleEffects[]), "1234567")) : (kvSuperTanks.GetString("Particles/Body Effects", g_sParticleEffects2[iIndex], sizeof(g_sParticleEffects2[]), g_sParticleEffects[iIndex]));
			main ? (g_iWarpAbility[iIndex] = kvSuperTanks.GetNum("Warp Ability/Ability Enabled", 0)) : (g_iWarpAbility2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Ability Enabled", g_iWarpAbility[iIndex]));
			main ? (g_iWarpAbility[iIndex] = iClamp(g_iWarpAbility[iIndex], 0, 3)) : (g_iWarpAbility2[iIndex] = iClamp(g_iWarpAbility2[iIndex], 0, 3));
			main ? (g_iWarpMessage[iIndex] = kvSuperTanks.GetNum("Warp Ability/Ability Message", 0)) : (g_iWarpMessage2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Ability Message", g_iWarpMessage[iIndex]));
			main ? (g_iWarpMessage[iIndex] = iClamp(g_iWarpMessage[iIndex], 0, 7)) : (g_iWarpMessage2[iIndex] = iClamp(g_iWarpMessage2[iIndex], 0, 7));
			main ? (g_iWarpChance[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Chance", 4)) : (g_iWarpChance2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Chance", g_iWarpChance[iIndex]));
			main ? (g_iWarpChance[iIndex] = iClamp(g_iWarpChance[iIndex], 1, 9999999999)) : (g_iWarpChance2[iIndex] = iClamp(g_iWarpChance2[iIndex], 1, 9999999999));
			main ? (g_iWarpHit[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Hit", 0)) : (g_iWarpHit2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Hit", g_iWarpHit[iIndex]));
			main ? (g_iWarpHit[iIndex] = iClamp(g_iWarpHit[iIndex], 0, 1)) : (g_iWarpHit2[iIndex] = iClamp(g_iWarpHit2[iIndex], 0, 1));
			main ? (g_iWarpHitMode[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Hit Mode", 0)) : (g_iWarpHitMode2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Hit Mode", g_iWarpHitMode[iIndex]));
			main ? (g_iWarpHitMode[iIndex] = iClamp(g_iWarpHitMode[iIndex], 0, 2)) : (g_iWarpHitMode2[iIndex] = iClamp(g_iWarpHitMode2[iIndex], 0, 2));
			main ? (g_iWarpMode[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Mode", 0)) : (g_iWarpMode2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Mode", g_iWarpMode[iIndex]));
			main ? (g_iWarpMode[iIndex] = iClamp(g_iWarpMode[iIndex], 0, 1)) : (g_iWarpMode2[iIndex] = iClamp(g_iWarpMode2[iIndex], 0, 1));
			main ? (g_flWarpInterval[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Interval", 5.0)) : (g_flWarpInterval2[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Interval", g_flWarpInterval[iIndex]));
			main ? (g_flWarpInterval[iIndex] = flClamp(g_flWarpInterval[iIndex], 0.1, 9999999999.0)) : (g_flWarpInterval2[iIndex] = flClamp(g_flWarpInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_flWarpRange[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Range", 150.0)) : (g_flWarpRange2[iIndex] = kvSuperTanks.GetFloat("Warp Ability/Warp Range", g_flWarpRange[iIndex]));
			main ? (g_flWarpRange[iIndex] = flClamp(g_flWarpRange[iIndex], 1.0, 9999999999.0)) : (g_flWarpRange2[iIndex] = flClamp(g_flWarpRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iWarpRangeChance[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Range Chance", 16)) : (g_iWarpRangeChance2[iIndex] = kvSuperTanks.GetNum("Warp Ability/Warp Range Chance", g_iWarpRangeChance[iIndex]));
			main ? (g_iWarpRangeChance[iIndex] = iClamp(g_iWarpRangeChance[iIndex], 1, 9999999999)) : (g_iWarpRangeChance2[iIndex] = iClamp(g_iWarpRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iWarpRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iWarpChance[ST_TankType(client)] : g_iWarpChance2[ST_TankType(client)];
		float flWarpRange = !g_bTankConfig[ST_TankType(client)] ? g_flWarpRange[ST_TankType(client)] : g_flWarpRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flWarpRange)
				{
					vWarpHit(iSurvivor, client, iWarpRangeChance, iWarpAbility(client), 2);
				}
			}
		}
		if ((iWarpAbility(client) == 2 || iWarpAbility(client) == 3) && !g_bWarp[client])
		{
			g_bWarp[client] = true;
			float flWarpInterval = !g_bTankConfig[ST_TankType(client)] ? g_flWarpInterval[ST_TankType(client)] : g_flWarpInterval2[ST_TankType(client)];
			CreateTimer(flWarpInterval, tTimerWarp, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bWarp[iPlayer] = false;
		}
	}
}

stock void vWarpHit(int client, int owner, int chance, int enabled, int message)
{
	if ((enabled == 1 || enabled == 3) && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		float flCurrentOrigin[3];
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsSurvivor(iPlayer) && !bIsPlayerIncapacitated(iPlayer) && iPlayer != client)
			{
				GetClientAbsOrigin(iPlayer, flCurrentOrigin);
				TeleportEntity(client, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);
				if (iWarpMessage(owner) == message || iWarpMessage(owner) == 4 || iWarpMessage(owner) == 5 || iWarpMessage(owner) == 6 || iWarpMessage(owner) == 7)
				{
					char sTankName[MAX_NAME_LENGTH + 1];
					ST_TankName(owner, sTankName);
					PrintToChatAll("%s %t", ST_PREFIX2, "Warp", sTankName, client, iPlayer);
				}
				break;
			}
		}
	}
}

stock int iWarpAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iWarpAbility[ST_TankType(client)] : g_iWarpAbility2[ST_TankType(client)];
}

stock int iWarpChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iWarpChance[ST_TankType(client)] : g_iWarpChance2[ST_TankType(client)];
}

stock int iWarpHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iWarpHit[ST_TankType(client)] : g_iWarpHit2[ST_TankType(client)];
}

stock int iWarpHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iWarpHitMode[ST_TankType(client)] : g_iWarpHitMode2[ST_TankType(client)];
}

stock int iWarpMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iWarpMessage[ST_TankType(client)] : g_iWarpMessage2[ST_TankType(client)];
}

public Action tTimerWarp(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bWarp[iTank] = false;
		return Plugin_Stop;
	}
	if (iWarpAbility(iTank) != 2 && iWarpAbility(iTank) != 3)
	{
		g_bWarp[iTank] = false;
		return Plugin_Stop;
	}
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[ST_TankType(iTank)] ? g_sParticleEffects[ST_TankType(iTank)] : g_sParticleEffects2[ST_TankType(iTank)];
	int iParticleEffect = !g_bTankConfig[ST_TankType(iTank)] ? g_iParticleEffect[ST_TankType(iTank)] : g_iParticleEffect2[ST_TankType(iTank)],
		iWarpMode = !g_bTankConfig[ST_TankType(iTank)] ? g_iWarpMode[ST_TankType(iTank)] : g_iWarpMode2[ST_TankType(iTank)],
		iSurvivor = iGetRandomSurvivor(iTank);
	if (iSurvivor > 0)
	{
		float flTankOrigin[3], flTankAngles[3], flSurvivorOrigin[3], flSurvivorAngles[3];
		GetClientAbsOrigin(iTank, flTankOrigin);
		GetClientAbsAngles(iTank, flTankAngles);
		GetClientAbsOrigin(iSurvivor, flSurvivorOrigin);
		GetClientAbsAngles(iSurvivor, flSurvivorAngles);
		if (iParticleEffect == 1 && StrContains(sParticleEffects, "2") != -1)
		{
			vCreateParticle(iTank, PARTICLE_ELECTRICITY, 1.0, 0.0);
			EmitSoundToAll(SOUND_ELECTRICITY, iTank);
			if (iWarpMode == 1)
			{
				vCreateParticle(iSurvivor, PARTICLE_ELECTRICITY, 1.0, 0.0);
				EmitSoundToAll(SOUND_ELECTRICITY2, iSurvivor);
			}
		}
		TeleportEntity(iTank, flSurvivorOrigin, flSurvivorAngles, NULL_VECTOR);
		if (iWarpMode == 1)
		{
			TeleportEntity(iSurvivor, flTankOrigin, flTankAngles, NULL_VECTOR);
		}
		switch (iWarpMessage(iTank))
		{
			case 3, 5, 6, 7:
			{
				char sTankName[MAX_NAME_LENGTH + 1];
				ST_TankName(iTank, sTankName);
				PrintToChatAll("%s %t", ST_PREFIX2, "Warp2", sTankName);
			}
		}
	}
	return Plugin_Continue;
}