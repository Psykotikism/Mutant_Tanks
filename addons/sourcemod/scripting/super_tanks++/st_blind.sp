// Super Tanks++: Blind Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Blind Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bBlind[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flBlindDuration[ST_MAXTYPES + 1], g_flBlindDuration2[ST_MAXTYPES + 1], g_flBlindRange[ST_MAXTYPES + 1], g_flBlindRange2[ST_MAXTYPES + 1];
int g_iBlindAbility[ST_MAXTYPES + 1], g_iBlindAbility2[ST_MAXTYPES + 1], g_iBlindChance[ST_MAXTYPES + 1], g_iBlindChance2[ST_MAXTYPES + 1], g_iBlindHit[ST_MAXTYPES + 1], g_iBlindHit2[ST_MAXTYPES + 1], g_iBlindHitMode[ST_MAXTYPES + 1], g_iBlindHitMode2[ST_MAXTYPES + 1], g_iBlindIntensity[ST_MAXTYPES + 1], g_iBlindIntensity2[ST_MAXTYPES + 1], g_iBlindMessage[ST_MAXTYPES + 1], g_iBlindMessage2[ST_MAXTYPES + 1], g_iBlindRangeChance[ST_MAXTYPES + 1], g_iBlindRangeChance2[ST_MAXTYPES + 1];
UserMsg g_umFadeUserMsgId;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Blind Ability only supports Left 4 Dead 1 & 2.");
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
	g_bBlind[client] = false;
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
		if ((iBlindHitMode(attacker) == 0 || iBlindHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vBlindHit(victim, attacker, iBlindChance(attacker), iBlindHit(attacker), 1);
			}
		}
		else if ((iBlindHitMode(victim) == 0 || iBlindHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vBlindHit(attacker, victim, iBlindChance(victim), iBlindHit(victim), 1);
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
			main ? (g_iBlindAbility[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Enabled", 0)) : (g_iBlindAbility2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Enabled", g_iBlindAbility[iIndex]));
			main ? (g_iBlindAbility[iIndex] = iClamp(g_iBlindAbility[iIndex], 0, 1)) : (g_iBlindAbility2[iIndex] = iClamp(g_iBlindAbility2[iIndex], 0, 1));
			main ? (g_iBlindMessage[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Message", 0)) : (g_iBlindMessage2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Message", g_iBlindMessage[iIndex]));
			main ? (g_iBlindMessage[iIndex] = iClamp(g_iBlindMessage[iIndex], 0, 3)) : (g_iBlindMessage2[iIndex] = iClamp(g_iBlindMessage2[iIndex], 0, 3));
			main ? (g_iBlindChance[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Chance", 4)) : (g_iBlindChance2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Chance", g_iBlindChance[iIndex]));
			main ? (g_iBlindChance[iIndex] = iClamp(g_iBlindChance[iIndex], 1, 9999999999)) : (g_iBlindChance2[iIndex] = iClamp(g_iBlindChance2[iIndex], 1, 9999999999));
			main ? (g_flBlindDuration[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Duration", 5.0)) : (g_flBlindDuration2[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Duration", g_flBlindDuration[iIndex]));
			main ? (g_flBlindDuration[iIndex] = flClamp(g_flBlindDuration[iIndex], 0.1, 9999999999.0)) : (g_flBlindDuration2[iIndex] = flClamp(g_flBlindDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iBlindHit[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Hit", 0)) : (g_iBlindHit2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Hit", g_iBlindHit[iIndex]));
			main ? (g_iBlindHit[iIndex] = iClamp(g_iBlindHit[iIndex], 0, 1)) : (g_iBlindHit2[iIndex] = iClamp(g_iBlindHit2[iIndex], 0, 1));
			main ? (g_iBlindHitMode[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Hit Mode", 0)) : (g_iBlindHitMode2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Hit Mode", g_iBlindHitMode[iIndex]));
			main ? (g_iBlindHitMode[iIndex] = iClamp(g_iBlindHitMode[iIndex], 0, 2)) : (g_iBlindHitMode2[iIndex] = iClamp(g_iBlindHitMode2[iIndex], 0, 2));
			main ? (g_iBlindIntensity[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Intensity", 255)) : (g_iBlindIntensity2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Intensity", g_iBlindIntensity[iIndex]));
			main ? (g_iBlindIntensity[iIndex] = iClamp(g_iBlindIntensity[iIndex], 0, 255)) : (g_iBlindIntensity2[iIndex] = iClamp(g_iBlindIntensity2[iIndex], 0, 255));
			main ? (g_flBlindRange[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Range", 150.0)) : (g_flBlindRange2[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Range", g_flBlindRange[iIndex]));
			main ? (g_flBlindRange[iIndex] = flClamp(g_flBlindRange[iIndex], 1.0, 9999999999.0)) : (g_flBlindRange2[iIndex] = flClamp(g_flBlindRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iBlindRangeChance[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Range Chance", 16)) : (g_iBlindRangeChance2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Range Chance", g_iBlindRangeChance[iIndex]));
			main ? (g_iBlindRangeChance[iIndex] = iClamp(g_iBlindRangeChance[iIndex], 1, 9999999999)) : (g_iBlindRangeChance2[iIndex] = iClamp(g_iBlindRangeChance2[iIndex], 1, 9999999999));
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
		if (iBlindAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveBlind(iTank);
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iBlindRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iBlindChance[ST_TankType(client)] : g_iBlindChance2[ST_TankType(client)];
		float flBlindRange = !g_bTankConfig[ST_TankType(client)] ? g_flBlindRange[ST_TankType(client)] : g_flBlindRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flBlindRange)
				{
					vBlindHit(iSurvivor, client, iBlindRangeChance, iBlindAbility(client), 2);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	if (iBlindAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled))
	{
		vRemoveBlind(client);
	}
}

stock void vBlind(int client, int owner, int intensity)
{
	int iTargets[2], iFlags, iColor[4] = {0, 0, 0, 0};
	iTargets[0] = client;
	intensity == 0 ? (iFlags = (0x0001|0x0010)) : (iFlags = (0x0002|0x0008));
	iColor[3] = intensity;
	Handle hBlindTarget = StartMessageEx(g_umFadeUserMsgId, iTargets, 1);
	if (GetUserMessageType() == UM_Protobuf)
	{
		Protobuf pbSet = UserMessageToProtobuf(hBlindTarget);
		pbSet.SetInt("duration", 1536), pbSet.SetInt("hold_time", 1536), pbSet.SetInt("flags", iFlags);
		pbSet.SetColor("clr", iColor);
	}
	else
	{
		BfWrite bfWrite = UserMessageToBfWrite(hBlindTarget);
		bfWrite.WriteShort(1536), bfWrite.WriteShort(1536), bfWrite.WriteShort(iFlags);
		bfWrite.WriteByte(iColor[0]), bfWrite.WriteByte(iColor[1]), bfWrite.WriteByte(iColor[2]), bfWrite.WriteByte(iColor[3]);
	}
	EndMessage();
}

stock void vBlindHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bBlind[client])
	{
		g_bBlind[client] = true;
		int iBlindIntensity = !g_bTankConfig[ST_TankType(owner)] ? g_iBlindIntensity[ST_TankType(owner)] : g_iBlindIntensity2[ST_TankType(owner)];
		vBlind(client, owner, iBlindIntensity);
		float flBlindDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flBlindDuration[ST_TankType(owner)] : g_flBlindDuration2[ST_TankType(owner)];
		DataPack dpStopBlindness = new DataPack();
		CreateDataTimer(flBlindDuration, tTimerStopBlindness, dpStopBlindness, TIMER_FLAG_NO_MAPCHANGE);
		dpStopBlindness.WriteCell(GetClientUserId(client)), dpStopBlindness.WriteCell(GetClientUserId(owner)), dpStopBlindness.WriteCell(message), dpStopBlindness.WriteCell(enabled);
		if (iBlindMessage(owner) == message || iBlindMessage(owner) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Blind", sTankName, client);
		}
	}
}

stock void vRemoveBlind(int client)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bBlind[iSurvivor])
		{
			DataPack dpStopBlindness = new DataPack();
			CreateDataTimer(0.1, tTimerStopBlindness, dpStopBlindness, TIMER_FLAG_NO_MAPCHANGE);
			dpStopBlindness.WriteCell(GetClientUserId(iSurvivor)), dpStopBlindness.WriteCell(GetClientUserId(client)), dpStopBlindness.WriteCell(0), dpStopBlindness.WriteCell(1);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bBlind[iPlayer] = false;
		}
	}
}

stock void vReset2(int client, int owner, int message)
{
	g_bBlind[client] = false;
	vBlind(client, owner, 0);
	if (iBlindMessage(owner) == message || iBlindMessage(owner) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Blind2", client);
	}
}

stock int iBlindAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iBlindAbility[ST_TankType(client)] : g_iBlindAbility2[ST_TankType(client)];
}

stock int iBlindChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iBlindChance[ST_TankType(client)] : g_iBlindChance2[ST_TankType(client)];
}

stock int iBlindHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iBlindHit[ST_TankType(client)] : g_iBlindHit2[ST_TankType(client)];
}

stock int iBlindHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iBlindHitMode[ST_TankType(client)] : g_iBlindHitMode2[ST_TankType(client)];
}

stock int iBlindMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iBlindMessage[ST_TankType(client)] : g_iBlindMessage2[ST_TankType(client)];
}

public Action tTimerStopBlindness(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bBlind[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell()), iBlindChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank, iBlindChat);
		return Plugin_Stop;
	}
	int iBlindEnabled = pack.ReadCell();
	if (iBlindEnabled == 0)
	{
		vReset2(iSurvivor, iTank, iBlindChat);
		return Plugin_Stop;
	}
	vReset2(iSurvivor, iTank, iBlindChat);
	return Plugin_Continue;
}