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
	description = "The Super Tank pulls in or pushes away survivors and any other nearby infected, and changes the survivors' gravity.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bGravity[MAXPLAYERS + 1], g_bGravity2[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
char g_sGravityEffect[ST_MAXTYPES + 1][4], g_sGravityEffect2[ST_MAXTYPES + 1][4];
float g_flGravityDuration[ST_MAXTYPES + 1], g_flGravityDuration2[ST_MAXTYPES + 1], g_flGravityForce[ST_MAXTYPES + 1], g_flGravityForce2[ST_MAXTYPES + 1], g_flGravityRange[ST_MAXTYPES + 1], g_flGravityRange2[ST_MAXTYPES + 1], g_flGravityValue[ST_MAXTYPES + 1], g_flGravityValue2[ST_MAXTYPES + 1];
int g_iGravityAbility[ST_MAXTYPES + 1], g_iGravityAbility2[ST_MAXTYPES + 1], g_iGravityChance[ST_MAXTYPES + 1], g_iGravityChance2[ST_MAXTYPES + 1], g_iGravityHit[ST_MAXTYPES + 1], g_iGravityHit2[ST_MAXTYPES + 1], g_iGravityHitMode[ST_MAXTYPES + 1], g_iGravityHitMode2[ST_MAXTYPES + 1], g_iGravityMessage[ST_MAXTYPES + 1], g_iGravityMessage2[ST_MAXTYPES + 1], g_iGravityRangeChance[ST_MAXTYPES + 1], g_iGravityRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
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
	vReset();
}

public void OnClientPutInServer(int client)
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
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vGravityHit(victim, attacker, iGravityChance(attacker), iGravityHit(attacker), 1, "1");
			}
		}
		else if ((iGravityHitMode(victim) == 0 || iGravityHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vGravityHit(attacker, victim, iGravityChance(victim), iGravityHit(victim), 1, "2");
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
			main ? (g_iGravityAbility[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Ability Enabled", 0)) : (g_iGravityAbility2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Ability Enabled", g_iGravityAbility[iIndex]));
			main ? (g_iGravityAbility[iIndex] = iClamp(g_iGravityAbility[iIndex], 0, 3)) : (g_iGravityAbility2[iIndex] = iClamp(g_iGravityAbility2[iIndex], 0, 3));
			main ? (kvSuperTanks.GetString("Gravity Ability/Ability Effect", g_sGravityEffect[iIndex], sizeof(g_sGravityEffect[]), "123")) : (kvSuperTanks.GetString("Gravity Ability/Ability Effect", g_sGravityEffect2[iIndex], sizeof(g_sGravityEffect2[]), g_sGravityEffect[iIndex]));
			main ? (g_iGravityMessage[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Ability Message", 0)) : (g_iGravityMessage2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Ability Message", g_iGravityMessage[iIndex]));
			main ? (g_iGravityMessage[iIndex] = iClamp(g_iGravityMessage[iIndex], 0, 7)) : (g_iGravityMessage2[iIndex] = iClamp(g_iGravityMessage2[iIndex], 0, 7));
			main ? (g_iGravityChance[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Chance", 4)) : (g_iGravityChance2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Chance", g_iGravityChance[iIndex]));
			main ? (g_iGravityChance[iIndex] = iClamp(g_iGravityChance[iIndex], 1, 9999999999)) : (g_iGravityChance2[iIndex] = iClamp(g_iGravityChance2[iIndex], 1, 9999999999));
			main ? (g_flGravityDuration[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Duration", 5.0)) : (g_flGravityDuration2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Duration", g_flGravityDuration[iIndex]));
			main ? (g_flGravityDuration[iIndex] = flClamp(g_flGravityDuration[iIndex], 0.1, 9999999999.0)) : (g_flGravityDuration2[iIndex] = flClamp(g_flGravityDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_flGravityForce[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Force", -50.0)) : (g_flGravityForce2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Force", g_flGravityForce[iIndex]));
			main ? (g_flGravityForce[iIndex] = flClamp(g_flGravityForce[iIndex], -100.0, 100.0)) : (g_flGravityForce2[iIndex] = flClamp(g_flGravityForce2[iIndex], -100.0, 100.0));
			main ? (g_iGravityHit[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit", 0)) : (g_iGravityHit2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit", g_iGravityHit[iIndex]));
			main ? (g_iGravityHit[iIndex] = iClamp(g_iGravityHit[iIndex], 0, 1)) : (g_iGravityHit2[iIndex] = iClamp(g_iGravityHit2[iIndex], 0, 1));
			main ? (g_iGravityHitMode[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit Mode", 0)) : (g_iGravityHitMode2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Hit Mode", g_iGravityHitMode[iIndex]));
			main ? (g_iGravityHitMode[iIndex] = iClamp(g_iGravityHitMode[iIndex], 0, 2)) : (g_iGravityHitMode2[iIndex] = iClamp(g_iGravityHitMode2[iIndex], 0, 2));
			main ? (g_flGravityRange[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Range", 150.0)) : (g_flGravityRange2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Range", g_flGravityRange[iIndex]));
			main ? (g_flGravityRange[iIndex] = flClamp(g_flGravityRange[iIndex], 1.0, 9999999999.0)) : (g_flGravityRange2[iIndex] = flClamp(g_flGravityRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iGravityRangeChance[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Range Chance", 16)) : (g_iGravityRangeChance2[iIndex] = kvSuperTanks.GetNum("Gravity Ability/Gravity Range Chance", g_iGravityRangeChance[iIndex]));
			main ? (g_iGravityRangeChance[iIndex] = iClamp(g_iGravityRangeChance[iIndex], 1, 9999999999)) : (g_iGravityRangeChance2[iIndex] = iClamp(g_iGravityRangeChance2[iIndex], 1, 9999999999));
			main ? (g_flGravityValue[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Value", 0.3)) : (g_flGravityValue2[iIndex] = kvSuperTanks.GetFloat("Gravity Ability/Gravity Value", g_flGravityValue[iIndex]));
			main ? (g_flGravityValue[iIndex] = flClamp(g_flGravityValue[iIndex], 0.1, 9999999999.0)) : (g_flGravityValue2[iIndex] = flClamp(g_flGravityValue2[iIndex], 0.1, 9999999999.0));
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
			vRemoveGravity(iPlayer);
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
			vRemoveGravity(iTank);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		int iGravityRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_iGravityChance[ST_TankType(tank)] : g_iGravityChance2[ST_TankType(tank)];
		float flGravityRange = !g_bTankConfig[ST_TankType(tank)] ? g_flGravityRange[ST_TankType(tank)] : g_flGravityRange2[ST_TankType(tank)],
			flTankPos[3];
		GetClientAbsOrigin(tank, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flGravityRange)
				{
					vGravityHit(iSurvivor, tank, iGravityRangeChance, iGravityAbility(tank), 2, "3");
				}
			}
		}
		if ((iGravityAbility(tank) == 2 || iGravityAbility(tank) == 3) && !g_bGravity[tank])
		{
			g_bGravity[tank] = true;
			int iBlackhole = CreateEntityByName("point_push");
			if (bIsValidEntity(iBlackhole))
			{
				float flGravityForce = !g_bTankConfig[ST_TankType(tank)] ? g_flGravityForce[ST_TankType(tank)] : g_flGravityForce2[ST_TankType(tank)],
					flOrigin[3], flAngles[3];
				GetEntPropVector(tank, Prop_Send, "m_vecOrigin", flOrigin);
				GetEntPropVector(tank, Prop_Send, "m_angRotation", flAngles);
				flAngles[0] += -90.0;
				DispatchKeyValueVector(iBlackhole, "origin", flOrigin);
				DispatchKeyValueVector(iBlackhole, "angles", flAngles);
				DispatchKeyValue(iBlackhole, "radius", "750");
				DispatchKeyValueFloat(iBlackhole, "magnitude", flGravityForce);
				DispatchKeyValue(iBlackhole, "spawnflags", "8");
				vSetEntityParent(iBlackhole, tank);
				AcceptEntityInput(iBlackhole, "Enable");
				SetEntPropEnt(iBlackhole, Prop_Send, "m_hOwnerEntity", tank);
				if (bIsValidGame())
				{
					SetEntProp(iBlackhole, Prop_Send, "m_glowColorOverride", tank);
				}
				switch (iGravityMessage(tank))
				{
					case 3, 5, 6, 7:
					{
						char sTankName[MAX_NAME_LENGTH + 1];
						ST_TankName(tank, sTankName);
						PrintToChatAll("%s %t", ST_PREFIX2, "Gravity3", sTankName);
					}
				}
			}
		}
	}
}

public void ST_BossStage(int tank)
{
	if ((iGravityAbility(tank) == 2 || iGravityAbility(tank) == 3) && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveGravity(tank);
	}
}

stock void vGravityHit(int survivor, int tank, int chance, int enabled, int message, const char[] mode)
{
	if ((enabled == 1 || enabled == 3) && GetRandomInt(1, chance) == 1 && bIsSurvivor(survivor) && !g_bGravity2[survivor])
	{
		g_bGravity2[survivor] = true;
		float flGravityValue = !g_bTankConfig[ST_TankType(tank)] ? g_flGravityValue[ST_TankType(tank)] : g_flGravityValue2[ST_TankType(tank)],
			flGravityDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flGravityDuration[ST_TankType(tank)] : g_flGravityDuration2[ST_TankType(tank)];
		SetEntityGravity(survivor, flGravityValue);
		DataPack dpStopGravity = new DataPack();
		CreateDataTimer(flGravityDuration, tTimerStopGravity, dpStopGravity, TIMER_FLAG_NO_MAPCHANGE);
		dpStopGravity.WriteCell(GetClientUserId(survivor)), dpStopGravity.WriteCell(GetClientUserId(tank)), dpStopGravity.WriteCell(message);
		char sGravityEffect[4];
		sGravityEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sGravityEffect[ST_TankType(tank)] : g_sGravityEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sGravityEffect, mode);
		if (iGravityMessage(tank) == message || iGravityMessage(tank) == 4 || iGravityMessage(tank) == 5 || iGravityMessage(tank) == 6 || iGravityMessage(tank) == 7)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Gravity", sTankName, survivor, flGravityValue);
		}
	}
}

stock void vRemoveGravity(int tank)
{
	int iProp = -1;
	while ((iProp = FindEntityByClassname(iProp, "point_push")) != INVALID_ENT_REFERENCE)
	{
		if (bIsValidGame())
		{
			int iOwner = GetEntProp(iProp, Prop_Send, "m_glowColorOverride");
			if (iOwner == tank)
			{
				RemoveEntity(iProp);
			}
		}
		int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iOwner == tank)
		{
			RemoveEntity(iProp);
		}
	}
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bGravity2[iSurvivor])
		{
			DataPack dpStopGravity = new DataPack();
			CreateDataTimer(0.1, tTimerStopGravity, dpStopGravity, TIMER_FLAG_NO_MAPCHANGE);
			dpStopGravity.WriteCell(GetClientUserId(iSurvivor)), dpStopGravity.WriteCell(GetClientUserId(tank)), dpStopGravity.WriteCell(0);
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

stock int iGravityAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGravityAbility[ST_TankType(tank)] : g_iGravityAbility2[ST_TankType(tank)];
}

stock int iGravityChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGravityChance[ST_TankType(tank)] : g_iGravityChance2[ST_TankType(tank)];
}

stock int iGravityHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGravityHit[ST_TankType(tank)] : g_iGravityHit2[ST_TankType(tank)];
}

stock int iGravityMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGravityMessage[ST_TankType(tank)] : g_iGravityMessage2[ST_TankType(tank)];
}

stock int iGravityHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGravityHitMode[ST_TankType(tank)] : g_iGravityHitMode2[ST_TankType(tank)];
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
	int iTank = GetClientOfUserId(pack.ReadCell()), iGravityChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bGravity2[iSurvivor])
	{
		g_bGravity2[iSurvivor] = false;
		SetEntityGravity(iSurvivor, 1.0);
		return Plugin_Stop;
	}
	g_bGravity2[iSurvivor] = false;
	SetEntityGravity(iSurvivor, 1.0);
	if (iGravityMessage(iTank) == iGravityChat || iGravityMessage(iTank) == 4 || iGravityMessage(iTank) == 5 || iGravityMessage(iTank) == 6 || iGravityMessage(iTank) == 7)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Gravity2", iSurvivor);
	}
	return Plugin_Continue;
}