// Super Tanks++: Acid Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Acid Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates acid puddles.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flAcidRange[ST_MAXTYPES + 1], g_flAcidRange2[ST_MAXTYPES + 1];
Handle g_hSDKAcidPlayer, g_hSDKPukePlayer;
int g_iAcidAbility[ST_MAXTYPES + 1], g_iAcidAbility2[ST_MAXTYPES + 1], g_iAcidChance[ST_MAXTYPES + 1], g_iAcidChance2[ST_MAXTYPES + 1], g_iAcidHit[ST_MAXTYPES + 1], g_iAcidHit2[ST_MAXTYPES + 1], g_iAcidHitMode[ST_MAXTYPES + 1], g_iAcidHitMode2[ST_MAXTYPES + 1], g_iAcidMessage[ST_MAXTYPES + 1], g_iAcidMessage2[ST_MAXTYPES + 1], g_iAcidRangeChance[ST_MAXTYPES + 1], g_iAcidRangeChance2[ST_MAXTYPES + 1], g_iAcidRock[ST_MAXTYPES + 1], g_iAcidRock2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Acid Ability only supports Left 4 Dead 1 & 2.");
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
	Handle hGameData = LoadGameConfigFile("super_tanks++");
	if (bIsValidGame())
	{
		StartPrepSDKCall(SDKCall_Static);
		PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CSpitterProjectile_Create");
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
		g_hSDKAcidPlayer = EndPrepSDKCall();
		if (g_hSDKAcidPlayer == null)
		{
			PrintToServer("%s Your \"CSpitterProjectile_Create\" signature is outdated.", ST_PREFIX);
		}
	}
	else
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		g_hSDKPukePlayer = EndPrepSDKCall();
		if (g_hSDKPukePlayer == null)
		{
			PrintToServer("%s Your \"CTerrorPlayer_OnVomitedUpon\" signature is outdated.", ST_PREFIX);
		}
	}
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

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((iAcidHitMode(attacker) == 0 || iAcidHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vAcidHit(victim, attacker, iAcidChance(attacker), iAcidHit(attacker), 1);
			}
		}
		else if ((iAcidHitMode(victim) == 0 || iAcidHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vAcidHit(attacker, victim, iAcidChance(victim), iAcidHit(victim), 1);
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
			main ? (g_iAcidAbility[iIndex] = kvSuperTanks.GetNum("Acid Ability/Ability Enabled", 0)) : (g_iAcidAbility2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Ability Enabled", g_iAcidAbility[iIndex]));
			main ? (g_iAcidAbility[iIndex] = iClamp(g_iAcidAbility[iIndex], 0, 1)) : (g_iAcidAbility2[iIndex] = iClamp(g_iAcidAbility2[iIndex], 0, 1));
			main ? (g_iAcidMessage[iIndex] = kvSuperTanks.GetNum("Acid Ability/Ability Message", 0)) : (g_iAcidMessage2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Ability Message", g_iAcidMessage[iIndex]));
			main ? (g_iAcidMessage[iIndex] = iClamp(g_iAcidMessage[iIndex], 0, 7)) : (g_iAcidMessage2[iIndex] = iClamp(g_iAcidMessage2[iIndex], 0, 7));
			main ? (g_iAcidChance[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Chance", 4)) : (g_iAcidChance2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Chance", g_iAcidChance[iIndex]));
			main ? (g_iAcidChance[iIndex] = iClamp(g_iAcidChance[iIndex], 1, 9999999999)) : (g_iAcidChance2[iIndex] = iClamp(g_iAcidChance2[iIndex], 1, 9999999999));
			main ? (g_iAcidHit[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Hit", 0)) : (g_iAcidHit2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Hit", g_iAcidHit[iIndex]));
			main ? (g_iAcidHit[iIndex] = iClamp(g_iAcidHit[iIndex], 0, 1)) : (g_iAcidHit2[iIndex] = iClamp(g_iAcidHit2[iIndex], 0, 1));
			main ? (g_iAcidHitMode[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Hit Mode", 0)) : (g_iAcidHitMode2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Hit Mode", g_iAcidHitMode[iIndex]));
			main ? (g_iAcidHitMode[iIndex] = iClamp(g_iAcidHitMode[iIndex], 0, 2)) : (g_iAcidHitMode2[iIndex] = iClamp(g_iAcidHitMode2[iIndex], 0, 2));
			main ? (g_flAcidRange[iIndex] = kvSuperTanks.GetFloat("Acid Ability/Acid Range", 150.0)) : (g_flAcidRange2[iIndex] = kvSuperTanks.GetFloat("Acid Ability/Acid Range", g_flAcidRange[iIndex]));
			main ? (g_flAcidRange[iIndex] = flClamp(g_flAcidRange[iIndex], 1.0, 9999999999.0)) : (g_flAcidRange2[iIndex] = flClamp(g_flAcidRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iAcidRangeChance[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Range Chance", 16)) : (g_iAcidRangeChance2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Range Chance", g_iAcidRangeChance[iIndex]));
			main ? (g_iAcidRangeChance[iIndex] = iClamp(g_iAcidRangeChance[iIndex], 1, 9999999999)) : (g_iAcidRangeChance2[iIndex] = iClamp(g_iAcidRangeChance2[iIndex], 1, 9999999999));
			main ? (g_iAcidRock[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Rock Break", 0)) : (g_iAcidRock2[iIndex] = kvSuperTanks.GetNum("Acid Ability/Acid Rock Break", g_iAcidRock[iIndex]));
			main ? (g_iAcidRock[iIndex] = iClamp(g_iAcidRock[iIndex], 0, 1)) : (g_iAcidRock2[iIndex] = iClamp(g_iAcidRock2[iIndex], 0, 1));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iAcidAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && bIsValidGame())
		{
			vAcid(iTank, iTank);
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iAcidRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iAcidChance[ST_TankType(client)] : g_iAcidChance2[ST_TankType(client)];
		float flAcidRange = !g_bTankConfig[ST_TankType(client)] ? g_flAcidRange[ST_TankType(client)] : g_flAcidRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flAcidRange)
				{
					vAcidHit(iSurvivor, client, iAcidRangeChance, iAcidAbility(client), 2);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	if (iAcidAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && bIsValidGame())
	{
		vAcid(client, client);
	}
}

public void ST_RockBreak(int client, int entity)
{
	int iAcidRock = !g_bTankConfig[ST_TankType(client)] ? g_iAcidRock[ST_TankType(client)] : g_iAcidRock2[ST_TankType(client)];
	if (iAcidRock == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client) && bIsValidGame())
	{
		float flOrigin[3], flAngles[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flOrigin);
		flOrigin[2] += 40.0;
		SDKCall(g_hSDKAcidPlayer, flOrigin, flAngles, flAngles, flAngles, client, 2.0);
		switch (iAcidMessage(client))
		{
			case 3, 5, 6, 7:
			{
				char sTankName[MAX_NAME_LENGTH + 1];
				ST_TankName(client, sTankName);
				PrintToChatAll("%s %t", ST_PREFIX2, "Acid2", sTankName);
			}
		}
	}
}

stock void vAcid(int client, int owner)
{
	float flOrigin[3], flAngles[3];
	GetClientAbsOrigin(client, flOrigin);
	GetClientAbsAngles(client, flAngles);
	SDKCall(g_hSDKAcidPlayer, flOrigin, flAngles, flAngles, flAngles, owner, 2.0);
}

stock void vAcidHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		ST_TankName(owner, sTankName);
		if (bIsValidGame())
		{
			vAcid(client, owner);
			if (iAcidMessage(owner) == message || iAcidMessage(client) == 4 || iAcidMessage(client) == 5 || iAcidMessage(client) == 6 || iAcidMessage(client) == 7)
			{
				PrintToChatAll("%s %t", ST_PREFIX2, "Acid", sTankName, client);
			}
		}
		else
		{
			SDKCall(g_hSDKPukePlayer, client, owner, true);
			if (iAcidMessage(owner) == message || iAcidMessage(client) == 4 || iAcidMessage(client) == 5 || iAcidMessage(client) == 6 || iAcidMessage(client) == 7)
			{
				PrintToChatAll("%s %t", ST_PREFIX2, "Puke", sTankName, client);
			}
		}
		char sRGB[4][4];
		ST_TankColors(owner, sRGB[0], sRGB[1], sRGB[2]);
		int iRed = (!StrEqual(sRGB[0], "")) ? StringToInt(sRGB[0]) : 255;
		iRed = iClamp(iRed, 0, 255);
		int iGreen = (!StrEqual(sRGB[1], "")) ? StringToInt(sRGB[1]) : 255;
		iGreen = iClamp(iGreen, 0, 255);
		int iBlue = (!StrEqual(sRGB[2], "")) ? StringToInt(sRGB[2]) : 255;
		iBlue = iClamp(iBlue, 0, 255);
		vFade(client, 800, 300, iRed, iGreen, iBlue);
	}
}

stock int iAcidAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iAcidAbility[ST_TankType(client)] : g_iAcidAbility2[ST_TankType(client)];
}

stock int iAcidChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iAcidChance[ST_TankType(client)] : g_iAcidChance2[ST_TankType(client)];
}

stock int iAcidHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iAcidHit[ST_TankType(client)] : g_iAcidHit2[ST_TankType(client)];
}

stock int iAcidHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iAcidHitMode[ST_TankType(client)] : g_iAcidHitMode2[ST_TankType(client)];
}

stock int iAcidMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iAcidMessage[ST_TankType(client)] : g_iAcidMessage2[ST_TankType(client)];
}