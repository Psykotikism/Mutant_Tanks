// Super Tanks++: Ice Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Ice Ability",
	author = ST_AUTHOR,
	description = "The Super Tank freezes survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define SOUND_BULLET "physics/glass/glass_impact_bullet4.wav"

bool g_bCloneInstalled, g_bIce[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sIceEffect[ST_MAXTYPES + 1][4], g_sIceEffect2[ST_MAXTYPES + 1][4];

float g_flIceChance[ST_MAXTYPES + 1], g_flIceChance2[ST_MAXTYPES + 1], g_flIceDuration[ST_MAXTYPES + 1], g_flIceDuration2[ST_MAXTYPES + 1], g_flIceRange[ST_MAXTYPES + 1], g_flIceRange2[ST_MAXTYPES + 1], g_flIceRangeChance[ST_MAXTYPES + 1], g_flIceRangeChance2[ST_MAXTYPES + 1];

int g_iIceAbility[ST_MAXTYPES + 1], g_iIceAbility2[ST_MAXTYPES + 1], g_iIceHit[ST_MAXTYPES + 1], g_iIceHit2[ST_MAXTYPES + 1], g_iIceHitMode[ST_MAXTYPES + 1], g_iIceHitMode2[ST_MAXTYPES + 1], g_iIceMessage[ST_MAXTYPES + 1], g_iIceMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Ice Ability only supports Left 4 Dead 1 & 2.");

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
	PrecacheSound(SOUND_BULLET, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	g_bIce[client] = false;
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

		if ((iIceHitMode(attacker) == 0 || iIceHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vIceHit(victim, attacker, flIceChance(attacker), iIceHit(attacker), 1, "1");
			}
		}
		else if ((iIceHitMode(victim) == 0 || iIceHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vIceHit(attacker, victim, flIceChance(victim), iIceHit(victim), 1, "2");
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
		char sTankName[MAX_NAME_LENGTH + 1];
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName, true))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iIceAbility[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ability Enabled", 0);
				g_iIceAbility[iIndex] = iClamp(g_iIceAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Ice Ability/Ability Effect", g_sIceEffect[iIndex], sizeof(g_sIceEffect[]), "123");
				g_iIceMessage[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ability Message", 0);
				g_iIceMessage[iIndex] = iClamp(g_iIceMessage[iIndex], 0, 3);
				g_flIceChance[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Chance", 33.3);
				g_flIceChance[iIndex] = flClamp(g_flIceChance[iIndex], 0.1, 100.0);
				g_flIceDuration[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Duration", 5.0);
				g_flIceDuration[iIndex] = flClamp(g_flIceDuration[iIndex], 0.1, 9999999999.0);
				g_iIceHit[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit", 0);
				g_iIceHit[iIndex] = iClamp(g_iIceHit[iIndex], 0, 1);
				g_iIceHitMode[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit Mode", 0);
				g_iIceHitMode[iIndex] = iClamp(g_iIceHitMode[iIndex], 0, 2);
				g_flIceRange[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Range", 150.0);
				g_flIceRange[iIndex] = flClamp(g_flIceRange[iIndex], 1.0, 9999999999.0);
				g_flIceRangeChance[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Range Chance", 15.0);
				g_flIceRangeChance[iIndex] = flClamp(g_flIceRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iIceAbility2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ability Enabled", g_iIceAbility[iIndex]);
				g_iIceAbility2[iIndex] = iClamp(g_iIceAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Ice Ability/Ability Effect", g_sIceEffect2[iIndex], sizeof(g_sIceEffect2[]), g_sIceEffect[iIndex]);
				g_iIceMessage2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ability Message", g_iIceMessage[iIndex]);
				g_iIceMessage2[iIndex] = iClamp(g_iIceMessage2[iIndex], 0, 3);
				g_flIceChance2[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Chance", g_flIceChance[iIndex]);
				g_flIceChance2[iIndex] = flClamp(g_flIceChance2[iIndex], 0.1, 100.0);
				g_flIceDuration2[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Duration", g_flIceDuration[iIndex]);
				g_flIceDuration2[iIndex] = flClamp(g_flIceDuration2[iIndex], 0.1, 9999999999.0);
				g_iIceHit2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit", g_iIceHit[iIndex]);
				g_iIceHit2[iIndex] = iClamp(g_iIceHit2[iIndex], 0, 1);
				g_iIceHitMode2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit Mode", g_iIceHitMode[iIndex]);
				g_iIceHitMode2[iIndex] = iClamp(g_iIceHitMode2[iIndex], 0, 2);
				g_flIceRange2[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Range", g_flIceRange[iIndex]);
				g_flIceRange2[iIndex] = flClamp(g_flIceRange2[iIndex], 1.0, 9999999999.0);
				g_flIceRangeChance2[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Range Chance", g_flIceRangeChance[iIndex]);
				g_flIceRangeChance2[iIndex] = flClamp(g_flIceRangeChance2[iIndex], 0.1, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			vRemoveIce(iPlayer);
		}
	}

	vReset();
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveIce(iTank);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flIceRange = !g_bTankConfig[ST_TankType(tank)] ? g_flIceRange[ST_TankType(tank)] : g_flIceRange2[ST_TankType(tank)],
			flIceRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flIceRangeChance[ST_TankType(tank)] : g_flIceRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flIceRange)
				{
					vIceHit(iSurvivor, tank, flIceRangeChance, iIceAbility(tank), 2, "3");
				}
			}
		}
	}
}

public void ST_BossStage(int tank)
{
	if (iIceAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveIce(tank);
	}
}

static void vIceHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor) && !g_bIce[survivor])
	{
		g_bIce[survivor] = true;

		float flPos[3];
		GetClientEyePosition(survivor, flPos);

		if (GetEntityMoveType(survivor) != MOVETYPE_NONE)
		{
			SetEntityMoveType(survivor, MOVETYPE_NONE);
		}

		SetEntityRenderColor(survivor, 0, 130, 255, 190);
		EmitAmbientSound(SOUND_BULLET, flPos, survivor, SNDLEVEL_RAIDSIREN);

		float flIceDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flIceDuration[ST_TankType(tank)] : g_flIceDuration2[ST_TankType(tank)];
		DataPack dpStopIce;
		CreateDataTimer(flIceDuration, tTimerStopIce, dpStopIce, TIMER_FLAG_NO_MAPCHANGE);
		dpStopIce.WriteCell(GetClientUserId(survivor));
		dpStopIce.WriteCell(GetClientUserId(tank));
		dpStopIce.WriteCell(message);

		char sIceEffect[4];
		sIceEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sIceEffect[ST_TankType(tank)] : g_sIceEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sIceEffect, mode);

		if (iIceMessage(tank) == message || iIceMessage(tank) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Ice", sTankName, survivor);
		}
	}
}

static void vRemoveIce(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bIce[iSurvivor])
		{
			DataPack dpStopIce;
			CreateDataTimer(0.1, tTimerStopIce, dpStopIce, TIMER_FLAG_NO_MAPCHANGE);
			dpStopIce.WriteCell(GetClientUserId(iSurvivor));
			dpStopIce.WriteCell(GetClientUserId(tank));
			dpStopIce.WriteCell(0);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bIce[iPlayer] = false;
		}
	}
}

static void vStopIce(int survivor)
{
	g_bIce[survivor] = false;

	float flPos[3], flVelocity[3] = {0.0, 0.0, 0.0};
	GetClientEyePosition(survivor, flPos);

	if (GetEntityMoveType(survivor) == MOVETYPE_NONE)
	{
		SetEntityMoveType(survivor, MOVETYPE_WALK);
	}

	TeleportEntity(survivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
	SetEntityRenderColor(survivor, 255, 255, 255, 255);
	EmitAmbientSound(SOUND_BULLET, flPos, survivor, SNDLEVEL_RAIDSIREN);
}

static float flIceChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flIceChance[ST_TankType(tank)] : g_flIceChance2[ST_TankType(tank)];
}

static int iIceAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iIceAbility[ST_TankType(tank)] : g_iIceAbility2[ST_TankType(tank)];
}

static int iIceHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iIceHit[ST_TankType(tank)] : g_iIceHit2[ST_TankType(tank)];
}

static int iIceHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iIceHitMode[ST_TankType(tank)] : g_iIceHitMode2[ST_TankType(tank)];
}

static int iIceMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iIceMessage[ST_TankType(tank)] : g_iIceMessage2[ST_TankType(tank)];
}

public Action tTimerStopIce(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bIce[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iIceChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bIce[iSurvivor])
	{
		vStopIce(iSurvivor);

		return Plugin_Stop;
	}

	vStopIce(iSurvivor);

	if (iIceMessage(iTank) == iIceChat || iIceMessage(iTank) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Ice2", iSurvivor);
	}

	return Plugin_Continue;
}