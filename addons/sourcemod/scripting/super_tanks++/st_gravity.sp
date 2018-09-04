// Super Tanks++: Gravity Ability
#define REQUIRE_PLUGIN
#include <super_tanks++>
#undef REQUIRE_PLUGIN
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

bool g_bGravity[MAXPLAYERS + 1], g_bGravity2[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flGravityDuration[ST_MAXTYPES + 1], g_flGravityDuration2[ST_MAXTYPES + 1],
	g_flGravityForce[ST_MAXTYPES + 1], g_flGravityForce2[ST_MAXTYPES + 1],
	g_flGravityRange[ST_MAXTYPES + 1], g_flGravityRange2[ST_MAXTYPES + 1],
	g_flGravityValue[ST_MAXTYPES + 1], g_flGravityValue2[ST_MAXTYPES + 1];
int g_iGravityAbility[ST_MAXTYPES + 1], g_iGravityAbility2[ST_MAXTYPES + 1],
	g_iGravityChance[ST_MAXTYPES + 1], g_iGravityChance2[ST_MAXTYPES + 1],
	g_iGravityHit[ST_MAXTYPES + 1], g_iGravityHit2[ST_MAXTYPES + 1],
	g_iGravityRangeChance[ST_MAXTYPES + 1], g_iGravityRangeChance2[ST_MAXTYPES + 1];

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
		if (ST_TankAllowed(attacker) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iGravityChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iGravityChance[ST_TankType(attacker)] : g_iGravityChance2[ST_TankType(attacker)];
				int iGravityHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iGravityHit[ST_TankType(attacker)] : g_iGravityHit2[ST_TankType(attacker)];
				vGravityHit(victim, attacker, iGravityChance, iGravityHit);
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
		int iTankId = event.GetInt("userid");
		int iTank = GetClientOfUserId(iTankId);
		int iGravityAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iGravityAbility[ST_TankType(iTank)] : g_iGravityAbility2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iGravityAbility == 1)
		{
			vRemoveGravity(iTank);
		}
	}
}

public void ST_Ability(int client)
{
	int iGravityAbility = !g_bTankConfig[ST_TankType(client)] ? g_iGravityAbility[ST_TankType(client)] : g_iGravityAbility2[ST_TankType(client)];
	int iGravityRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iGravityChance[ST_TankType(client)] : g_iGravityChance2[ST_TankType(client)];
	if (iGravityAbility == 1 && ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		if (!g_bGravity[client])
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
		float flGravityRange = !g_bTankConfig[ST_TankType(client)] ? g_flGravityRange[ST_TankType(client)] : g_flGravityRange2[ST_TankType(client)];
		float flTankPos[3];
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
					vGravityHit(iSurvivor, client, iGravityRangeChance, iGravityAbility);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	int iGravityAbility = !g_bTankConfig[ST_TankType(client)] ? g_iGravityAbility[ST_TankType(client)] : g_iGravityAbility2[ST_TankType(client)];
	if (ST_TankAllowed(client) && iGravityAbility == 1)
	{
		vRemoveGravity(client);
	}
}

void vGravityHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bGravity2[client])
	{
		g_bGravity2[client] = true;
		float flGravityValue = !g_bTankConfig[ST_TankType(owner)] ? g_flGravityValue[ST_TankType(owner)] : g_flGravityValue2[ST_TankType(owner)];
		SetEntityGravity(client, flGravityValue);
		float flGravityDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flGravityDuration[ST_TankType(owner)] : g_flGravityDuration2[ST_TankType(owner)];
		DataPack dpDataPack = new DataPack();
		CreateDataTimer(flGravityDuration, tTimerStopGravity, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
	}
}

void vRemoveGravity(int client)
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
			DataPack dpDataPack = new DataPack();
			CreateDataTimer(0.1, tTimerStopGravity, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
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
			g_bGravity[iPlayer] = false;
			g_bGravity2[iPlayer] = false;
		}
	}
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
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		g_bGravity2[iSurvivor] = false;
		SetEntityGravity(iSurvivor, 1.0);
		return Plugin_Stop;
	}
	int iGravityAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iGravityAbility[ST_TankType(iTank)] : g_iGravityAbility2[ST_TankType(iTank)];
	if (iGravityAbility == 0)
	{
		g_bGravity2[iSurvivor] = false;
		SetEntityGravity(iSurvivor, 1.0);
		return Plugin_Stop;
	}
	g_bGravity2[iSurvivor] = false;
	SetEntityGravity(iSurvivor, 1.0);
	return Plugin_Continue;
}