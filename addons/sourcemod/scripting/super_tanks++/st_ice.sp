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

bool g_bCloneInstalled, g_bIce[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flIceDuration[ST_MAXTYPES + 1], g_flIceDuration2[ST_MAXTYPES + 1], g_flIceRange[ST_MAXTYPES + 1], g_flIceRange2[ST_MAXTYPES + 1];
int g_iIceAbility[ST_MAXTYPES + 1], g_iIceAbility2[ST_MAXTYPES + 1], g_iIceChance[ST_MAXTYPES + 1], g_iIceChance2[ST_MAXTYPES + 1], g_iIceHit[ST_MAXTYPES + 1], g_iIceHit2[ST_MAXTYPES + 1], g_iIceHitMode[ST_MAXTYPES + 1], g_iIceHitMode2[ST_MAXTYPES + 1], g_iIceMessage[ST_MAXTYPES + 1], g_iIceMessage2[ST_MAXTYPES + 1], g_iIceRangeChance[ST_MAXTYPES + 1], g_iIceRangeChance2[ST_MAXTYPES + 1];

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
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vIceHit(victim, attacker, iIceChance(attacker), iIceHit(attacker), 1);
			}
		}
		else if ((iIceHitMode(victim) == 0 || iIceHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vIceHit(attacker, victim, iIceChance(victim), iIceHit(victim), 1);
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
			main ? (g_iIceAbility[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ability Enabled", 0)) : (g_iIceAbility2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ability Enabled", g_iIceAbility[iIndex]));
			main ? (g_iIceAbility[iIndex] = iClamp(g_iIceAbility[iIndex], 0, 1)) : (g_iIceAbility2[iIndex] = iClamp(g_iIceAbility2[iIndex], 0, 1));
			main ? (g_iIceMessage[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ability Message", 0)) : (g_iIceMessage2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ability Message", g_iIceMessage[iIndex]));
			main ? (g_iIceMessage[iIndex] = iClamp(g_iIceMessage[iIndex], 0, 3)) : (g_iIceMessage2[iIndex] = iClamp(g_iIceMessage2[iIndex], 0, 3));
			main ? (g_iIceChance[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Chance", 4)) : (g_iIceChance2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Chance", g_iIceChance[iIndex]));
			main ? (g_iIceChance[iIndex] = iClamp(g_iIceChance[iIndex], 1, 9999999999)) : (g_iIceChance2[iIndex] = iClamp(g_iIceChance2[iIndex], 1, 9999999999));
			main ? (g_flIceDuration[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Duration", 5.0)) : (g_flIceDuration2[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Duration", g_flIceDuration[iIndex]));
			main ? (g_flIceDuration[iIndex] = flClamp(g_flIceDuration[iIndex], 0.1, 9999999999.0)) : (g_flIceDuration2[iIndex] = flClamp(g_flIceDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iIceHit[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit", 0)) : (g_iIceHit2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit", g_iIceHit[iIndex]));
			main ? (g_iIceHit[iIndex] = iClamp(g_iIceHit[iIndex], 0, 1)) : (g_iIceHit2[iIndex] = iClamp(g_iIceHit2[iIndex], 0, 1));
			main ? (g_iIceHitMode[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit Mode", 0)) : (g_iIceHitMode2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Hit Mode", g_iIceHitMode[iIndex]));
			main ? (g_iIceHitMode[iIndex] = iClamp(g_iIceHitMode[iIndex], 0, 2)) : (g_iIceHitMode2[iIndex] = iClamp(g_iIceHitMode2[iIndex], 0, 2));
			main ? (g_flIceRange[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Range", 150.0)) : (g_flIceRange2[iIndex] = kvSuperTanks.GetFloat("Ice Ability/Ice Range", g_flIceRange[iIndex]));
			main ? (g_flIceRange[iIndex] = flClamp(g_flIceRange[iIndex], 1.0, 9999999999.0)) : (g_flIceRange2[iIndex] = flClamp(g_flIceRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iIceRangeChance[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Range Chance", 16)) : (g_iIceRangeChance2[iIndex] = kvSuperTanks.GetNum("Ice Ability/Ice Range Chance", g_iIceRangeChance[iIndex]));
			main ? (g_iIceRangeChance[iIndex] = iClamp(g_iIceRangeChance[iIndex], 1, 9999999999)) : (g_iIceRangeChance2[iIndex] = iClamp(g_iIceRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveIce(iTank);
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iIceRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iIceChance[ST_TankType(client)] : g_iIceChance2[ST_TankType(client)];
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
					vIceHit(iSurvivor, client, iIceRangeChance, iIceAbility(client), 2);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	if (iIceAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled))
	{
		vRemoveIce(client);
	}
}

stock void vIceHit(int client, int owner, int chance, int enabled, int message)
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
		DataPack dpStopIce = new DataPack();
		CreateDataTimer(flIceDuration, tTimerStopIce, dpStopIce, TIMER_FLAG_NO_MAPCHANGE);
		dpStopIce.WriteCell(GetClientUserId(client)), dpStopIce.WriteCell(GetClientUserId(owner)), dpStopIce.WriteCell(message), dpStopIce.WriteCell(enabled);
		if (iIceMessage(owner) == message || iIceMessage(owner) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Ice", sTankName, client);
		}
	}
}

stock void vRemoveIce(int client)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bIce[iSurvivor])
		{
			DataPack dpStopIce = new DataPack();
			CreateDataTimer(0.1, tTimerStopIce, dpStopIce, TIMER_FLAG_NO_MAPCHANGE);
			dpStopIce.WriteCell(GetClientUserId(iSurvivor)), dpStopIce.WriteCell(GetClientUserId(client)), dpStopIce.WriteCell(0), dpStopIce.WriteCell(1);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bIce[iPlayer] = false;
		}
	}
}

stock void vStopIce(int client, int owner, int message)
{
	if (g_bIce[client])
	{
		g_bIce[client] = false;
		float flPos[3], flVelocity[3] = {0.0, 0.0, 0.0};
		GetClientEyePosition(client, flPos);
		if (GetEntityMoveType(client) == MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
		}
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, flVelocity);
		SetEntityRenderColor(client, 255, 255, 255, 255);
		EmitAmbientSound(SOUND_BULLET, flPos, client, SNDLEVEL_RAIDSIREN);
		if (iIceMessage(owner) == message || iIceMessage(owner) == 3)
		{
			PrintToChatAll("%s %t", ST_PREFIX2, "Ice2", client);
		}
	}
}

stock int iIceAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iIceAbility[ST_TankType(client)] : g_iIceAbility2[ST_TankType(client)];
}

stock int iIceChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iIceChance[ST_TankType(client)] : g_iIceChance2[ST_TankType(client)];
}

stock int iIceHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iIceHit[ST_TankType(client)] : g_iIceHit2[ST_TankType(client)];
}

stock int iIceHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iIceHitMode[ST_TankType(client)] : g_iIceHitMode2[ST_TankType(client)];
}

stock int iIceMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iIceMessage[ST_TankType(client)] : g_iIceMessage2[ST_TankType(client)];
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
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vStopIce(iSurvivor, iTank, iIceChat);
		return Plugin_Stop;
	}
	int iIceEnabled = pack.ReadCell();
	if (iIceEnabled == 0)
	{
		vStopIce(iSurvivor, iTank, iIceChat);
		return Plugin_Stop;
	}
	vStopIce(iSurvivor, iTank, iIceChat);
	return Plugin_Continue;
}