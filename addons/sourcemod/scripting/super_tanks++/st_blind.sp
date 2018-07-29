// Super Tanks++: Blind Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Blind Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bBlind[MAXPLAYERS + 1];
bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
float g_flBlindDuration[ST_MAXTYPES + 1];
float g_flBlindDuration2[ST_MAXTYPES + 1];
float g_flBlindRange[ST_MAXTYPES + 1];
float g_flBlindRange2[ST_MAXTYPES + 1];
int g_iBlindAbility[ST_MAXTYPES + 1];
int g_iBlindAbility2[ST_MAXTYPES + 1];
int g_iBlindChance[ST_MAXTYPES + 1];
int g_iBlindChance2[ST_MAXTYPES + 1];
int g_iBlindHit[ST_MAXTYPES + 1];
int g_iBlindHit2[ST_MAXTYPES + 1];
int g_iBlindIntensity[ST_MAXTYPES + 1];
int g_iBlindIntensity2[ST_MAXTYPES + 1];
int g_iBlindRangeChance[ST_MAXTYPES + 1];
int g_iBlindRangeChance2[ST_MAXTYPES + 1];
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
	if (!LibraryExists("super_tanks++"))
	{
		SetFailState("No Super Tanks++ library found.");
	}
}

public void OnPluginStart()
{
	g_umFadeUserMsgId = GetUserMessageId("Fade");
}

public void OnMapStart()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bBlind[iPlayer] = false;
		}
	}
	if (g_bLateLoad)
	{
		vLateLoad(true);
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bBlind[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bBlind[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bBlind[iPlayer] = false;
		}
	}
}

void vLateLoad(bool late)
{
	if (late)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				SDKHook(iPlayer, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
	}
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
				int iBlindChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iBlindChance[ST_TankType(attacker)] : g_iBlindChance2[ST_TankType(attacker)];
				int iBlindHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iBlindHit[ST_TankType(attacker)] : g_iBlindHit2[ST_TankType(attacker)];
				vBlindHit(victim, attacker, iBlindChance, iBlindHit);
			}
		}
	}
}

public void ST_Configs(char[] savepath, int limit, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = 1; iIndex <= limit; iIndex++)
	{
		char sName[MAX_NAME_LENGTH + 1];
		Format(sName, sizeof(sName), "Tank %d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iBlindAbility[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Enabled", 0)) : (g_iBlindAbility2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Enabled", g_iBlindAbility[iIndex]));
			main ? (g_iBlindAbility[iIndex] = iSetCellLimit(g_iBlindAbility[iIndex], 0, 1)) : (g_iBlindAbility2[iIndex] = iSetCellLimit(g_iBlindAbility2[iIndex], 0, 1));
			main ? (g_iBlindChance[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Chance", 4)) : (g_iBlindChance2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Chance", g_iBlindChance[iIndex]));
			main ? (g_iBlindChance[iIndex] = iSetCellLimit(g_iBlindChance[iIndex], 1, 9999999999)) : (g_iBlindChance2[iIndex] = iSetCellLimit(g_iBlindChance2[iIndex], 1, 9999999999));
			main ? (g_flBlindDuration[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Duration", 5.0)) : (g_flBlindDuration2[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Duration", g_flBlindDuration[iIndex]));
			main ? (g_flBlindDuration[iIndex] = flSetFloatLimit(g_flBlindDuration[iIndex], 0.1, 9999999999.0)) : (g_flBlindDuration2[iIndex] = flSetFloatLimit(g_flBlindDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iBlindHit[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Hit", 0)) : (g_iBlindHit2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Hit", g_iBlindHit[iIndex]));
			main ? (g_iBlindHit[iIndex] = iSetCellLimit(g_iBlindHit[iIndex], 0, 1)) : (g_iBlindHit2[iIndex] = iSetCellLimit(g_iBlindHit2[iIndex], 0, 1));
			main ? (g_iBlindIntensity[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Intensity", 255)) : (g_iBlindIntensity2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Intensity", g_iBlindIntensity[iIndex]));
			main ? (g_iBlindIntensity[iIndex] = iSetCellLimit(g_iBlindIntensity[iIndex], 0, 255)) : (g_iBlindIntensity2[iIndex] = iSetCellLimit(g_iBlindIntensity2[iIndex], 0, 255));
			main ? (g_flBlindRange[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Range", 150.0)) : (g_flBlindRange2[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Range", g_flBlindRange[iIndex]));
			main ? (g_flBlindRange[iIndex] = flSetFloatLimit(g_flBlindRange[iIndex], 1.0, 9999999999.0)) : (g_flBlindRange2[iIndex] = flSetFloatLimit(g_flBlindRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iBlindRangeChance[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Range Chance", 16)) : (g_iBlindRangeChance2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Range Chance", g_iBlindRangeChance[iIndex]));
			main ? (g_iBlindRangeChance[iIndex] = iSetCellLimit(g_iBlindRangeChance[iIndex], 1, 9999999999)) : (g_iBlindRangeChance2[iIndex] = iSetCellLimit(g_iBlindRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Death(int client)
{
	int iBlindAbility = !g_bTankConfig[ST_TankType(client)] ? g_iBlindAbility[ST_TankType(client)] : g_iBlindAbility2[ST_TankType(client)];
	if (ST_TankAllowed(client) && iBlindAbility == 1)
	{
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor) && g_bBlind[iSurvivor])
			{
				DataPack dpDataPack;
				CreateDataTimer(0.1, tTimerStopBlindness, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
				dpDataPack.WriteCell(GetClientUserId(iSurvivor));
				dpDataPack.WriteCell(GetClientUserId(client));
			}
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iBlindAbility = !g_bTankConfig[ST_TankType(client)] ? g_iBlindAbility[ST_TankType(client)] : g_iBlindAbility2[ST_TankType(client)];
		int iBlindRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iBlindChance[ST_TankType(client)] : g_iBlindChance2[ST_TankType(client)];
		float flBlindRange = !g_bTankConfig[ST_TankType(client)] ? g_flBlindRange[ST_TankType(client)] : g_flBlindRange2[ST_TankType(client)];
		float flTankPos[3];
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
					vBlindHit(iSurvivor, client, iBlindRangeChance, iBlindAbility);
				}
			}
		}
	}
}

void vBlind(int client, int amount, UserMsg message)
{
	int iTargets[2];
	iTargets[0] = client;
	int iFlags;
	if (bIsSurvivor(client))
	{
		amount == 0 ? (iFlags = (0x0001|0x0010)) : (iFlags = (0x0002|0x0008));
		int iColor[4] = {0, 0, 0, 0};
		iColor[3] = amount;
		Handle hBlindTarget = StartMessageEx(message, iTargets, 1);
		if (GetUserMessageType() == UM_Protobuf)
		{
			Protobuf pbSet = UserMessageToProtobuf(hBlindTarget);
			pbSet.SetInt("duration", 1536);
			pbSet.SetInt("hold_time", 1536);
			pbSet.SetInt("flags", iFlags);
			pbSet.SetColor("clr", iColor);
		}
		else
		{
			BfWrite bfWrite = UserMessageToBfWrite(hBlindTarget);
			bfWrite.WriteShort(1536);
			bfWrite.WriteShort(1536);
			bfWrite.WriteShort(iFlags);
			bfWrite.WriteByte(iColor[0]);
			bfWrite.WriteByte(iColor[1]);
			bfWrite.WriteByte(iColor[2]);
			bfWrite.WriteByte(iColor[3]);
		}
		EndMessage();
	}
}

void vBlindHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bBlind[client])
	{
		g_bBlind[client] = true;
		int iBlindIntensity = !g_bTankConfig[ST_TankType(owner)] ? g_iBlindIntensity[ST_TankType(owner)] : g_iBlindIntensity2[ST_TankType(owner)];
		vBlind(client, iBlindIntensity, g_umFadeUserMsgId);
		float flBlindDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flBlindDuration[ST_TankType(owner)] : g_flBlindDuration2[ST_TankType(owner)];
		DataPack dpDataPack;
		CreateDataTimer(flBlindDuration, tTimerStopBlindness, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
	}
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

public Action tTimerStopBlindness(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iBlindAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iBlindAbility[ST_TankType(iTank)] : g_iBlindAbility2[ST_TankType(iTank)];
	if (iBlindAbility == 0 || !bIsTank(iTank) || !IsPlayerAlive(iTank) || !bIsSurvivor(iSurvivor))
	{
		g_bBlind[iSurvivor] = false;
		if (bIsSurvivor(iSurvivor))
		{
			vBlind(iSurvivor, 0, g_umFadeUserMsgId);
		}
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		g_bBlind[iSurvivor] = false;
		vBlind(iSurvivor, 0, g_umFadeUserMsgId);
	}
	return Plugin_Continue;
}