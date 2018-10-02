// Super Tanks++: Drug Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Drug Ability",
	author = ST_AUTHOR,
	description = "The Super Tank drugs survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bDrug[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
char g_sDrugEffect[ST_MAXTYPES + 1][4], g_sDrugEffect2[ST_MAXTYPES + 1][4];
float g_flDrugAngles[20] = {0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 20.0, 15.0, 10.0, 5.0, 0.0, -5.0, -10.0, -15.0, -20.0, -25.0, -20.0, -15.0, -10.0, -5.0}, g_flDrugDuration[ST_MAXTYPES + 1], g_flDrugDuration2[ST_MAXTYPES + 1], g_flDrugRange[ST_MAXTYPES + 1], g_flDrugRange2[ST_MAXTYPES + 1];
int g_iDrugAbility[ST_MAXTYPES + 1], g_iDrugAbility2[ST_MAXTYPES + 1], g_iDrugChance[ST_MAXTYPES + 1], g_iDrugChance2[ST_MAXTYPES + 1], g_iDrugHit[ST_MAXTYPES + 1], g_iDrugHit2[ST_MAXTYPES + 1], g_iDrugHitMode[ST_MAXTYPES + 1], g_iDrugHitMode2[ST_MAXTYPES + 1], g_iDrugMessage[ST_MAXTYPES + 1], g_iDrugMessage2[ST_MAXTYPES + 1], g_iDrugRangeChance[ST_MAXTYPES + 1], g_iDrugRangeChance2[ST_MAXTYPES + 1];
UserMsg g_umFadeUserMsgId;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Drug Ability only supports Left 4 Dead 1 & 2.");
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
	g_umFadeUserMsgId = GetUserMessageId("Fade");
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
	g_bDrug[client] = false;
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
		if ((iDrugHitMode(attacker) == 0 || iDrugHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vDrugHit(victim, attacker, iDrugChance(attacker), iDrugHit(attacker), 1, "1");
			}
		}
		else if ((iDrugHitMode(victim) == 0 || iDrugHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vDrugHit(attacker, victim, iDrugChance(victim), iDrugHit(victim), 1, "2");
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
			main ? (g_iDrugAbility[iIndex] = kvSuperTanks.GetNum("Drug Ability/Ability Enabled", 0)) : (g_iDrugAbility2[iIndex] = kvSuperTanks.GetNum("Drug Ability/Ability Enabled", g_iDrugAbility[iIndex]));
			main ? (g_iDrugAbility[iIndex] = iClamp(g_iDrugAbility[iIndex], 0, 1)) : (g_iDrugAbility2[iIndex] = iClamp(g_iDrugAbility2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("Drug Ability/Ability Effect", g_sDrugEffect[iIndex], sizeof(g_sDrugEffect[]), "123")) : (kvSuperTanks.GetString("Drug Ability/Ability Effect", g_sDrugEffect2[iIndex], sizeof(g_sDrugEffect2[]), g_sDrugEffect[iIndex]));
			main ? (g_iDrugMessage[iIndex] = kvSuperTanks.GetNum("Drug Ability/Ability Message", 0)) : (g_iDrugMessage2[iIndex] = kvSuperTanks.GetNum("Drug Ability/Ability Message", g_iDrugMessage[iIndex]));
			main ? (g_iDrugMessage[iIndex] = iClamp(g_iDrugMessage[iIndex], 0, 3)) : (g_iDrugMessage2[iIndex] = iClamp(g_iDrugMessage2[iIndex], 0, 3));
			main ? (g_iDrugChance[iIndex] = kvSuperTanks.GetNum("Drug Ability/Drug Chance", 4)) : (g_iDrugChance2[iIndex] = kvSuperTanks.GetNum("Drug Ability/Drug Chance", g_iDrugChance[iIndex]));
			main ? (g_iDrugChance[iIndex] = iClamp(g_iDrugChance[iIndex], 1, 9999999999)) : (g_iDrugChance2[iIndex] = iClamp(g_iDrugChance2[iIndex], 1, 9999999999));
			main ? (g_flDrugDuration[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Drug Duration", 5.0)) : (g_flDrugDuration2[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Drug Duration", g_flDrugDuration[iIndex]));
			main ? (g_flDrugDuration[iIndex] = flClamp(g_flDrugDuration[iIndex], 0.1, 9999999999.0)) : (g_flDrugDuration2[iIndex] = flClamp(g_flDrugDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iDrugHit[iIndex] = kvSuperTanks.GetNum("Drug Ability/Drug Hit", 0)) : (g_iDrugHit2[iIndex] = kvSuperTanks.GetNum("Drug Ability/Drug Hit", g_iDrugHit[iIndex]));
			main ? (g_iDrugHit[iIndex] = iClamp(g_iDrugHit[iIndex], 0, 1)) : (g_iDrugHit2[iIndex] = iClamp(g_iDrugHit2[iIndex], 0, 1));
			main ? (g_iDrugHitMode[iIndex] = kvSuperTanks.GetNum("Drug Ability/Drug Hit Mode", 0)) : (g_iDrugHitMode2[iIndex] = kvSuperTanks.GetNum("Drug Ability/Drug Hit Mode", g_iDrugHitMode[iIndex]));
			main ? (g_iDrugHitMode[iIndex] = iClamp(g_iDrugHitMode[iIndex], 0, 2)) : (g_iDrugHitMode2[iIndex] = iClamp(g_iDrugHitMode2[iIndex], 0, 2));
			main ? (g_flDrugRange[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Drug Range", 150.0)) : (g_flDrugRange2[iIndex] = kvSuperTanks.GetFloat("Drug Ability/Drug Range", g_flDrugRange[iIndex]));
			main ? (g_flDrugRange[iIndex] = flClamp(g_flDrugRange[iIndex], 1.0, 9999999999.0)) : (g_flDrugRange2[iIndex] = flClamp(g_flDrugRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iDrugRangeChance[iIndex] = kvSuperTanks.GetNum("Drug Ability/Drug Range Chance", 16)) : (g_iDrugRangeChance2[iIndex] = kvSuperTanks.GetNum("Drug Ability/Drug Range Chance", g_iDrugRangeChance[iIndex]));
			main ? (g_iDrugRangeChance[iIndex] = iClamp(g_iDrugRangeChance[iIndex], 1, 9999999999)) : (g_iDrugRangeChance2[iIndex] = iClamp(g_iDrugRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vReset();
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iDrugAbility = !g_bTankConfig[ST_TankType(client)] ? g_iDrugAbility[ST_TankType(client)] : g_iDrugAbility2[ST_TankType(client)],
			iDrugRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iDrugChance[ST_TankType(client)] : g_iDrugChance2[ST_TankType(client)];
		float flDrugRange = !g_bTankConfig[ST_TankType(client)] ? g_flDrugRange[ST_TankType(client)] : g_flDrugRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flDrugRange)
				{
					vDrugHit(iSurvivor, client, iDrugRangeChance, iDrugAbility, 2, "3");
				}
			}
		}
	}
}

stock void vDrug(int client, bool toggle, float angles[20])
{
	float flAngles[3];
	GetClientEyeAngles(client, flAngles);
	flAngles[2] = toggle ? angles[GetRandomInt(0, 100) % 20] : 0.0;
	TeleportEntity(client, NULL_VECTOR, flAngles, NULL_VECTOR);
	int iClients[2], iColor[4] = {0, 0, 0, 128}, iColor2[4] = {0, 0, 0, 0}, iFlags = toggle ? 0x0002 : (0x0001|0x0010);
	iClients[0] = client;
	if (toggle)
	{
		iColor[0] = GetRandomInt(0, 255), iColor[1] = GetRandomInt(0, 255), iColor[2] = GetRandomInt(0, 255);
	}
	Handle hDrugTarget = StartMessageEx(g_umFadeUserMsgId, iClients, 1);
	if (GetUserMessageType() == UM_Protobuf)
	{
		Protobuf pbSet = UserMessageToProtobuf(hDrugTarget);
		pbSet.SetInt("duration", toggle ? 255: 1536), pbSet.SetInt("hold_time", toggle ? 255 : 1536), pbSet.SetInt("flags", iFlags);
		pbSet.SetColor("clr", toggle ? iColor : iColor2);
	}
	else
	{
		BfWrite bfWrite = UserMessageToBfWrite(hDrugTarget);
		bfWrite.WriteShort(toggle ? 255 : 1536), bfWrite.WriteShort(toggle ? 255 : 1536), bfWrite.WriteShort(iFlags);
		bfWrite.WriteByte(toggle ? iColor[0] : iColor2[0]), bfWrite.WriteByte(toggle ? iColor[1] : iColor2[1]), bfWrite.WriteByte(toggle ? iColor[2] : iColor2[2]), bfWrite.WriteByte(toggle ? iColor[3] : iColor2[3]);
	}
	EndMessage();
}

stock void vDrugHit(int client, int owner, int chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bDrug[client])
	{
		g_bDrug[client] = true;
		DataPack dpDrug = new DataPack();
		CreateDataTimer(1.0, tTimerDrug, dpDrug, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDrug.WriteCell(GetClientUserId(client)), dpDrug.WriteCell(GetClientUserId(owner)), dpDrug.WriteCell(message), dpDrug.WriteCell(enabled), dpDrug.WriteFloat(GetEngineTime());
		char sDrugEffect[4];
		sDrugEffect = !g_bTankConfig[ST_TankType(owner)] ? g_sDrugEffect[ST_TankType(owner)] : g_sDrugEffect2[ST_TankType(owner)];
		vEffect(client, owner, sDrugEffect, mode);
		if (iDrugMessage(owner) == message || iDrugMessage(owner) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Drug", sTankName, client);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bDrug[iPlayer] = false;
		}
	}
}

stock void vReset2(int client, int owner, int message)
{
	g_bDrug[client] = false;
	vDrug(client, false, g_flDrugAngles);
	if (iDrugMessage(owner) == message || iDrugMessage(owner) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Drug2", client);
	}
}

stock int iDrugChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iDrugChance[ST_TankType(client)] : g_iDrugChance2[ST_TankType(client)];
}

stock int iDrugHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iDrugHit[ST_TankType(client)] : g_iDrugHit2[ST_TankType(client)];
}

stock int iDrugHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iDrugHitMode[ST_TankType(client)] : g_iDrugHitMode2[ST_TankType(client)];
}

stock int iDrugMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iDrugMessage[ST_TankType(client)] : g_iDrugMessage2[ST_TankType(client)];
}

public Action tTimerDrug(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bDrug[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell()), iDrugChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bDrug[iSurvivor])
	{
		vReset2(iSurvivor, iTank, iDrugChat);
		return Plugin_Stop;
	}
	int iDrugAbility = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flDrugDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flDrugDuration[ST_TankType(iTank)] : g_flDrugDuration2[ST_TankType(iTank)];
	if (iDrugAbility == 0 || (flTime + flDrugDuration) < GetEngineTime())
	{
		vReset2(iSurvivor, iTank, iDrugChat);
		return Plugin_Stop;
	}
	vDrug(iSurvivor, true, g_flDrugAngles);
	return Plugin_Handled;
}