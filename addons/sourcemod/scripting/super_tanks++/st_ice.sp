// Super Tanks++: Ice Ability
#define REQUIRE_PLUGIN
#include <super_tanks++>
#undef REQUIRE_PLUGIN
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Ice Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bIce[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flIceDuration[ST_MAXTYPES + 1], g_flIceDuration2[ST_MAXTYPES + 1],
	g_flIceRange[ST_MAXTYPES + 1], g_flIceRange2[ST_MAXTYPES + 1];
int g_iIceAbility[ST_MAXTYPES + 1], g_iIceAbility2[ST_MAXTYPES + 1],
	g_iIceChance[ST_MAXTYPES + 1], g_iIceChance2[ST_MAXTYPES + 1], g_iIceHit[ST_MAXTYPES + 1],
	g_iIceHit2[ST_MAXTYPES + 1], g_iIceRangeChance[ST_MAXTYPES + 1],
	g_iIceRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Ice Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnMapStart()
{
	PrecacheSound(SOUND_BULLET, true);
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
		if (ST_TankAllowed(attacker) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iIceChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iIceChance[ST_TankType(attacker)] : g_iIceChance2[ST_TankType(attacker)],
					iIceHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iIceHit[ST_TankType(attacker)] : g_iIceHit2[ST_TankType(attacker)];
				vIceHit(victim, attacker, iIceChance, iIceHit);
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
			main ? (g_iIceAbility[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ability Enabled", 0)) : (g_iIceAbility2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ability Enabled", g_iIceAbility[iIndex]));
			main ? (g_iIceAbility[iIndex] = iSetCellLimit(g_iIceAbility[iIndex], 0, 1)) : (g_iIceAbility2[iIndex] = iSetCellLimit(g_iIceAbility2[iIndex], 0, 1));
			main ? (g_iIceChance[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Chance", 4)) : (g_iIceChance2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Chance", g_iIceChance[iIndex]));
			main ? (g_iIceChance[iIndex] = iSetCellLimit(g_iIceChance[iIndex], 1, 9999999999)) : (g_iIceChance2[iIndex] = iSetCellLimit(g_iIceChance2[iIndex], 1, 9999999999));
			main ? (g_flIceDuration[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Duration", 5.0)) : (g_flIceDuration2[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Duration", g_flIceDuration[iIndex]));
			main ? (g_flIceDuration[iIndex] = flSetFloatLimit(g_flIceDuration[iIndex], 0.1, 9999999999.0)) : (g_flIceDuration2[iIndex] = flSetFloatLimit(g_flIceDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iIceHit[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit", 0)) : (g_iIceHit2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit", g_iIceHit[iIndex]));
			main ? (g_iIceHit[iIndex] = iSetCellLimit(g_iIceHit[iIndex], 0, 1)) : (g_iIceHit2[iIndex] = iSetCellLimit(g_iIceHit2[iIndex], 0, 1));
			main ? (g_flIceRange[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Range", 150.0)) : (g_flIceRange2[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Range", g_flIceRange[iIndex]));
			main ? (g_flIceRange[iIndex] = flSetFloatLimit(g_flIceRange[iIndex], 1.0, 9999999999.0)) : (g_flIceRange2[iIndex] = flSetFloatLimit(g_flIceRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iIceRangeChance[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Range Chance", 16)) : (g_iIceRangeChance2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Range Chance", g_iIceRangeChance[iIndex]));
			main ? (g_iIceRangeChance[iIndex] = iSetCellLimit(g_iIceRangeChance[iIndex], 1, 9999999999)) : (g_iIceRangeChance2[iIndex] = iSetCellLimit(g_iIceRangeChance2[iIndex], 1, 9999999999));
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
			iIceAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iIceAbility[ST_TankType(iTank)] : g_iIceAbility2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iIceAbility == 1)
		{
			vRemoveIce(iTank);
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client))
	{
		int iIceAbility = !g_bTankConfig[ST_TankType(client)] ? g_iIceAbility[ST_TankType(client)] : g_iIceAbility2[ST_TankType(client)],
			iIceRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iIceChance[ST_TankType(client)] : g_iIceChance2[ST_TankType(client)];
		float flIceRange = !g_bTankConfig[ST_TankType(client)] ? g_flIceRange[ST_TankType(client)] : g_flIceRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flIceRange)
				{
					vIceHit(iSurvivor, client, iIceRangeChance, iIceAbility);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	int iIceAbility = !g_bTankConfig[ST_TankType(client)] ? g_iIceAbility[ST_TankType(client)] : g_iIceAbility2[ST_TankType(client)];
	if (ST_TankAllowed(client) && iIceAbility == 1)
	{
		vRemoveIce(client);
	}
}

void vIceHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bIce[client])
	{
		g_bIce[client] = true;
		float flPos[3];
		GetClientEyePosition(client, flPos);
		if (GetEntityMoveType(client) != MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_NONE);
		}
		SetEntityRenderColor(client, 0, 130, 255, 190);
		EmitAmbientSound(SOUND_BULLET, flPos, client, SNDLEVEL_RAIDSIREN);
		float flIceDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flIceDuration[ST_TankType(owner)] : g_flIceDuration2[ST_TankType(owner)];
		DataPack dpDataPack = new DataPack();
		CreateDataTimer(flIceDuration, tTimerStopIce, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
	}
}

void vRemoveIce(int client)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bIce[iSurvivor])
		{
			DataPack dpDataPack = new DataPack();
			CreateDataTimer(0.1, tTimerStopIce, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
			dpDataPack.WriteCell(GetClientUserId(iSurvivor));
			dpDataPack.WriteCell(GetClientUserId(client));
		}
	}
}

void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bIce[iPlayer] = false;
		}
	}
}

void vStopIce(int client)
{
	if (g_bIce[client])
	{
		g_bIce[client] = false;
		float flPos[3];
		GetClientEyePosition(client, flPos);
		if (GetEntityMoveType(client) == MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
		}
		SetEntityRenderColor(client, 255, 255, 255, 255);
		EmitAmbientSound(SOUND_BULLET, flPos, client, SNDLEVEL_RAIDSIREN);
	}
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
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		vStopIce(iSurvivor);
		return Plugin_Stop;
	}
	int iIceAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iIceAbility[ST_TankType(iTank)] : g_iIceAbility2[ST_TankType(iTank)];
	if (iIceAbility == 0)
	{
		vStopIce(iSurvivor);
		return Plugin_Stop;
	}
	vStopIce(iSurvivor);
	return Plugin_Continue;
}