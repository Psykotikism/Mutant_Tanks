// Super Tanks++: Gravity Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Gravity Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bGravity[MAXPLAYERS + 1], g_bGravity2[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flGravityDuration[ST_MAXTYPES + 1], g_flGravityDuration2[ST_MAXTYPES + 1], g_flGravityForce[ST_MAXTYPES + 1], g_flGravityForce2[ST_MAXTYPES + 1], g_flGravityRange[ST_MAXTYPES + 1], g_flGravityRange2[ST_MAXTYPES + 1], g_flGravityValue[ST_MAXTYPES + 1], g_flGravityValue2[ST_MAXTYPES + 1];
int g_iGravityAbility[ST_MAXTYPES + 1], g_iGravityAbility2[ST_MAXTYPES + 1], g_iGravityChance[ST_MAXTYPES + 1], g_iGravityChance2[ST_MAXTYPES + 1], g_iGravityHit[ST_MAXTYPES + 1], g_iGravityHit2[ST_MAXTYPES + 1], g_iGravityHitMode[ST_MAXTYPES + 1], g_iGravityHitMode2[ST_MAXTYPES + 1], g_iGravityRangeChance[ST_MAXTYPES + 1], g_iGravityRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Gravity Ability only supports Left 4 Dead 1 & 2.");
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
	g_bGravity[client] = false;
	g_bGravity2[client] = false;
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
		if ((iGravityHitMode(attacker) == 0 || iGravityHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vGravityHit(victim, attacker, iGravityChance(attacker), iGravityHit(attacker));
			}
		}
		else if ((iGravityHitMode(victim) == 0 || iGravityHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vGravityHit(attacker, victim, iGravityChance(victim), iGravityHit(victim));
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
		Format(sName, sizeof(sName), "Tank %d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iGravityAbility[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Ability Enabled", 0)) : (g_iGravityAbility2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Ability Enabled", g_iGravityAbility[iIndex]));
			main ? (g_iGravityAbility[iIndex] = iSetCellLimit(g_iGravityAbility[iIndex], 0, 1)) : (g_iGravityAbility2[iIndex] = iSetCellLimit(g_iGravityAbility2[iIndex], 0, 1));
			main ? (g_iGravityChance[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Chance", 4)) : (g_iGravityChance2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Chance", g_iGravityChance[iIndex]));
			main ? (g_iGravityChance[iIndex] = iSetCellLimit(g_iGravityChance[iIndex], 1, 9999999999)) : (g_iGravityChance2[iIndex] = iSetCellLimit(g_iGravityChance2[iIndex], 1, 9999999999));
			main ? (g_flGravityDuration[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Duration", 5.0)) : (g_flGravityDuration2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Duration", g_flGravityDuration[iIndex]));
			main ? (g_flGravityDuration[iIndex] = flSetFloatLimit(g_flGravityDuration[iIndex], 0.1, 9999999999.0)) : (g_flGravityDuration2[iIndex] = flSetFloatLimit(g_flGravityDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_flGravityForce[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Force", -50.0)) : (g_flGravityForce2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Force", g_flGravityForce[iIndex]));
			main ? (g_flGravityForce[iIndex] = flSetFloatLimit(g_flGravityForce[iIndex], -100.0, 100.0)) : (g_flGravityForce2[iIndex] = flSetFloatLimit(g_flGravityForce2[iIndex], -100.0, 100.0));
			main ? (g_iGravityHit[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit", 0)) : (g_iGravityHit2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit", g_iGravityHit[iIndex]));
			main ? (g_iGravityHit[iIndex] = iSetCellLimit(g_iGravityHit[iIndex], 0, 1)) : (g_iGravityHit2[iIndex] = iSetCellLimit(g_iGravityHit2[iIndex], 0, 1));
			main ? (g_iGravityHitMode[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit Mode", 0)) : (g_iGravityHitMode2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit Mode", g_iGravityHitMode[iIndex]));
			main ? (g_iGravityHitMode[iIndex] = iSetCellLimit(g_iGravityHitMode[iIndex], 0, 2)) : (g_iGravityHitMode2[iIndex] = iSetCellLimit(g_iGravityHitMode2[iIndex], 0, 2));
			main ? (g_flGravityRange[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Range", 150.0)) : (g_flGravityRange2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Range", g_flGravityRange[iIndex]));
			main ? (g_flGravityRange[iIndex] = flSetFloatLimit(g_flGravityRange[iIndex], 1.0, 9999999999.0)) : (g_flGravityRange2[iIndex] = flSetFloatLimit(g_flGravityRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iGravityRangeChance[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Range Chance", 16)) : (g_iGravityRangeChance2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Range Chance", g_iGravityRangeChance[iIndex]));
			main ? (g_iGravityRangeChance[iIndex] = iSetCellLimit(g_iGravityRangeChance[iIndex], 1, 9999999999)) : (g_iGravityRangeChance2[iIndex] = iSetCellLimit(g_iGravityRangeChance2[iIndex], 1, 9999999999));
			main ? (g_flGravityValue[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Value", 0.3)) : (g_flGravityValue2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Value", g_flGravityValue[iIndex]));
			main ? (g_flGravityValue[iIndex] = flSetFloatLimit(g_flGravityValue[iIndex], 0.1, 0.99)) : (g_flGravityValue2[iIndex] = flSetFloatLimit(g_flGravityValue2[iIndex], 0.1, 0.99));
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
		if (iGravityAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveGravity(iTank);
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iGravityRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iGravityChance[ST_TankType(client)] : g_iGravityChance2[ST_TankType(client)];
		float flGravityRange = !g_bTankConfig[ST_TankType(client)] ? g_flGravityRange[ST_TankType(client)] : g_flGravityRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flGravityRange)
				{
					vGravityHit(iSurvivor, client, iGravityRangeChance, iGravityAbility(client));
				}
			}
		}
		if (iGravityAbility(client) == 1 && !g_bGravity[client])
		{
			g_bGravity[client] = true;
			float flGravityForce = !g_bTankConfig[ST_TankType(client)] ? g_flGravityForce[ST_TankType(client)] : g_flGravityForce2[ST_TankType(client)];
			int iBlackhole = CreateEntityByName("point_push");
			if (bIsValidEntity(iBlackhole))
			{
				float flOrigin[3], flAngles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
				flAngles[0] += -90.0;
				DispatchKeyValueVector(iBlackhole, "origin", flOrigin);
				DispatchKeyValueVector(iBlackhole, "angles", flAngles);
				DispatchKeyValue(iBlackhole, "radius", "750");
				DispatchKeyValueFloat(iBlackhole, "magnitude", flGravityForce);
				DispatchKeyValue(iBlackhole, "spawnflags", "8");
				vSetEntityParent(iBlackhole, client);
				AcceptEntityInput(iBlackhole, "Enable");
				SetEntPropEnt(iBlackhole, Prop_Send, "m_hOwnerEntity", client);
				if (bIsL4D2Game())
				{
					SetEntProp(iBlackhole, Prop_Send, "m_glowColorOverride", client);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	if (iGravityAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled))
	{
		vRemoveGravity(client);
	}
}

stock void vGravityHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bGravity2[client])
	{
		g_bGravity2[client] = true;
		float flGravityValue = !g_bTankConfig[ST_TankType(owner)] ? g_flGravityValue[ST_TankType(owner)] : g_flGravityValue2[ST_TankType(owner)],
			flGravityDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flGravityDuration[ST_TankType(owner)] : g_flGravityDuration2[ST_TankType(owner)];
		SetEntityGravity(client, flGravityValue);
		DataPack dpStopGravity = new DataPack();
		CreateDataTimer(flGravityDuration, tTimerStopGravity, dpStopGravity, TIMER_FLAG_NO_MAPCHANGE);
		dpStopGravity.WriteCell(GetClientUserId(client)), dpStopGravity.WriteCell(GetClientUserId(owner)), dpStopGravity.WriteCell(enabled);
	}
}

stock void vRemoveGravity(int client)
{
	int iProp = -1;
	while ((iProp = FindEntityByClassname(iProp, "point_push")) != INVALID_ENT_REFERENCE)
	{
		if (bIsL4D2Game())
		{
			int iOwner = GetEntProp(iProp, Prop_Send, "m_glowColorOverride");
			if (iOwner == client)
			{
				AcceptEntityInput(iProp, "Kill");
			}
		}
		int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iOwner == client)
		{
			AcceptEntityInput(iProp, "Kill");
		}
	}
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bGravity2[iSurvivor])
		{
			DataPack dpStopGravity = new DataPack();
			CreateDataTimer(0.1, tTimerStopGravity, dpStopGravity, TIMER_FLAG_NO_MAPCHANGE);
			dpStopGravity.WriteCell(GetClientUserId(iSurvivor)), dpStopGravity.WriteCell(GetClientUserId(client)), dpStopGravity.WriteCell(1);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bGravity[iPlayer] = false;
			g_bGravity2[iPlayer] = false;
		}
	}
}

stock int iGravityAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iGravityAbility[ST_TankType(client)] : g_iGravityAbility2[ST_TankType(client)];
}

stock int iGravityChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iGravityChance[ST_TankType(client)] : g_iGravityChance2[ST_TankType(client)];
}

stock int iGravityHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iGravityHit[ST_TankType(client)] : g_iGravityHit2[ST_TankType(client)];
}

stock int iGravityHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iGravityHitMode[ST_TankType(client)] : g_iGravityHitMode2[ST_TankType(client)];
}

public Action tTimerStopGravity(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bGravity2[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bGravity2[iSurvivor] = false;
		SetEntityGravity(iSurvivor, 1.0);
		return Plugin_Stop;
	}
	int iGravityEnabled = pack.ReadCell();
	if (iGravityEnabled == 0)
	{
		g_bGravity2[iSurvivor] = false;
		SetEntityGravity(iSurvivor, 1.0);
		return Plugin_Stop;
	}
	g_bGravity2[iSurvivor] = false;
	SetEntityGravity(iSurvivor, 1.0);
	return Plugin_Continue;
}