// Super Tanks++: Bury Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Bury Ability",
	author = ST_AUTHOR,
	description = "The Super Tank buries survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bBury[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flBuryDuration[ST_MAXTYPES + 1], g_flBuryDuration2[ST_MAXTYPES + 1], g_flBuryHeight[ST_MAXTYPES + 1], g_flBuryHeight2[ST_MAXTYPES + 1], g_flBuryRange[ST_MAXTYPES + 1], g_flBuryRange2[ST_MAXTYPES + 1];
int g_iBuryAbility[ST_MAXTYPES + 1], g_iBuryAbility2[ST_MAXTYPES + 1], g_iBuryChance[ST_MAXTYPES + 1], g_iBuryChance2[ST_MAXTYPES + 1], g_iBuryHit[ST_MAXTYPES + 1], g_iBuryHit2[ST_MAXTYPES + 1], g_iBuryHitMode[ST_MAXTYPES + 1], g_iBuryHitMode2[ST_MAXTYPES + 1], g_iBuryMessage[ST_MAXTYPES + 1], g_iBuryMessage2[ST_MAXTYPES + 1], g_iBuryRangeChance[ST_MAXTYPES + 1], g_iBuryRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Bury Ability only supports Left 4 Dead 1 & 2.");
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
	g_bBury[client] = false;
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
		if ((iBuryHitMode(attacker) == 0 || iBuryHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vBuryHit(victim, attacker, iBuryChance(attacker), iBuryHit(attacker), 1);
			}
		}
		else if ((iBuryHitMode(victim) == 0 || iBuryHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vBuryHit(attacker, victim, iBuryChance(victim), iBuryHit(victim), 1);
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
			main ? (g_iBuryAbility[iIndex] = kvSuperTanks.GetNum("Bury Ability/Ability Enabled", 0)) : (g_iBuryAbility2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Ability Enabled", g_iBuryAbility[iIndex]));
			main ? (g_iBuryAbility[iIndex] = iClamp(g_iBuryAbility[iIndex], 0, 1)) : (g_iBuryAbility2[iIndex] = iClamp(g_iBuryAbility2[iIndex], 0, 1));
			main ? (g_iBuryMessage[iIndex] = kvSuperTanks.GetNum("Bury Ability/Ability Message", 0)) : (g_iBuryMessage2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Ability Message", g_iBuryMessage[iIndex]));
			main ? (g_iBuryMessage[iIndex] = iClamp(g_iBuryMessage[iIndex], 0, 3)) : (g_iBuryMessage2[iIndex] = iClamp(g_iBuryMessage2[iIndex], 0, 3));
			main ? (g_iBuryChance[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Chance", 4)) : (g_iBuryChance2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Chance", g_iBuryChance[iIndex]));
			main ? (g_iBuryChance[iIndex] = iClamp(g_iBuryChance[iIndex], 1, 9999999999)) : (g_iBuryChance2[iIndex] = iClamp(g_iBuryChance2[iIndex], 1, 9999999999));
			main ? (g_flBuryDuration[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Duration", 5.0)) : (g_flBuryDuration2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Duration", g_flBuryDuration[iIndex]));
			main ? (g_flBuryDuration[iIndex] = flClamp(g_flBuryDuration[iIndex], 0.1, 9999999999.0)) : (g_flBuryDuration2[iIndex] = flClamp(g_flBuryDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_flBuryHeight[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Height", 50.0)) : (g_flBuryHeight2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Height", g_flBuryHeight[iIndex]));
			main ? (g_flBuryHeight[iIndex] = flClamp(g_flBuryHeight[iIndex], 0.1, 9999999999.0)) : (g_flBuryHeight2[iIndex] = flClamp(g_flBuryHeight2[iIndex], 0.1, 9999999999.0));
			main ? (g_iBuryHit[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Hit", 0)) : (g_iBuryHit2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Hit", g_iBuryHit[iIndex]));
			main ? (g_iBuryHit[iIndex] = iClamp(g_iBuryHit[iIndex], 0, 1)) : (g_iBuryHit2[iIndex] = iClamp(g_iBuryHit2[iIndex], 0, 1));
			main ? (g_iBuryHitMode[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Hit Mode", 0)) : (g_iBuryHitMode2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Hit Mode", g_iBuryHitMode[iIndex]));
			main ? (g_iBuryHitMode[iIndex] = iClamp(g_iBuryHitMode[iIndex], 0, 2)) : (g_iBuryHitMode2[iIndex] = iClamp(g_iBuryHitMode2[iIndex], 0, 2));
			main ? (g_flBuryRange[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Range", 150.0)) : (g_flBuryRange2[iIndex] = kvSuperTanks.GetFloat("Bury Ability/Bury Range", g_flBuryRange[iIndex]));
			main ? (g_flBuryRange[iIndex] = flClamp(g_flBuryRange[iIndex], 1.0, 9999999999.0)) : (g_flBuryRange2[iIndex] = flClamp(g_flBuryRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iBuryRangeChance[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Range Chance", 16)) : (g_iBuryRangeChance2[iIndex] = kvSuperTanks.GetNum("Bury Ability/Bury Range Chance", g_iBuryRangeChance[iIndex]));
			main ? (g_iBuryRangeChance[iIndex] = iClamp(g_iBuryRangeChance[iIndex], 1, 9999999999)) : (g_iBuryRangeChance2[iIndex] = iClamp(g_iBuryRangeChance2[iIndex], 1, 9999999999));
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
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveBury(iTank);
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iBuryRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iBuryChance[ST_TankType(client)] : g_iBuryChance2[ST_TankType(client)];
		float flBuryRange = !g_bTankConfig[ST_TankType(client)] ? g_flBuryRange[ST_TankType(client)] : g_flBuryRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flBuryRange)
				{
					vBuryHit(iSurvivor, client, iBuryRangeChance, iBuryAbility(client), 2);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	if (iBuryAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled))
	{
		vRemoveBury(client);
	}
}

stock void vBuryHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bBury[client] && bIsPlayerGrounded(client))
	{
		g_bBury[client] = true;
		float flOrigin[3], flPos[3],
			flBuryDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flBuryDuration[ST_TankType(owner)] : g_flBuryDuration2[ST_TankType(owner)];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		flOrigin[2] = flOrigin[2] - flBuryHeight(owner);
		SetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		if (!bIsPlayerIncapacitated(client))
		{
			SetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
			SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
		}
		GetClientEyePosition(client, flPos);
		if (GetEntityMoveType(client) != MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_NONE);
		}
		DataPack dpStopBury = new DataPack();
		CreateDataTimer(flBuryDuration, tTimerStopBury, dpStopBury, TIMER_FLAG_NO_MAPCHANGE);
		dpStopBury.WriteCell(GetClientUserId(client)), dpStopBury.WriteCell(GetClientUserId(owner)), dpStopBury.WriteCell(message), dpStopBury.WriteCell(enabled);
		char sRGB[4][4];
		ST_TankColors(owner, sRGB[0], sRGB[1], sRGB[2]);
		int iRed = (!StrEqual(sRGB[0], "")) ? StringToInt(sRGB[0]) : 255;
		iRed = iClamp(iRed, 0, 255);
		int iGreen = (!StrEqual(sRGB[1], "")) ? StringToInt(sRGB[1]) : 255;
		iGreen = iClamp(iGreen, 0, 255);
		int iBlue = (!StrEqual(sRGB[2], "")) ? StringToInt(sRGB[2]) : 255;
		iBlue = iClamp(iBlue, 0, 255);
		vFade(client, 800, 300, iRed, iGreen, iBlue);
		if (iBuryMessage(owner) == message || iBuryMessage(owner) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Bury", sTankName, client, flOrigin);
		}
	}
}

stock void vRemoveBury(int client)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bBury[iSurvivor])
		{
			DataPack dpDataPack = new DataPack();
			CreateDataTimer(0.1, tTimerStopBury, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
			dpDataPack.WriteCell(GetClientUserId(iSurvivor)), dpDataPack.WriteCell(GetClientUserId(client)), dpDataPack.WriteCell(0), dpDataPack.WriteCell(1);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bBury[iPlayer] = false;
		}
	}
}

stock void vStopBury(int client, int owner, int message)
{
	if (g_bBury[client])
	{
		g_bBury[client] = false;
		float flOrigin[3], flCurrentOrigin[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		flOrigin[2] = flOrigin[2] + flBuryHeight(owner);
		SetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsSurvivor(iPlayer) && !g_bBury[iPlayer] && iPlayer != client)
			{
				GetClientAbsOrigin(iPlayer, flCurrentOrigin);
				TeleportEntity(client, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);
				break;
			}
		}
		if (bIsPlayerIncapacitated(client))
		{
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
		}
		if (GetEntityMoveType(client) == MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
		}
		if (iBuryMessage(owner) == message || iBuryMessage(owner) == 3)
		{
			PrintToChatAll("%s %t", ST_PREFIX2, "Bury2", client);
		}
	}
}

stock float flBuryHeight(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_flBuryHeight[ST_TankType(client)] : g_flBuryHeight2[ST_TankType(client)];
}

stock int iBuryAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iBuryAbility[ST_TankType(client)] : g_iBuryAbility2[ST_TankType(client)];
}

stock int iBuryChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iBuryChance[ST_TankType(client)] : g_iBuryChance2[ST_TankType(client)];
}

stock int iBuryHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iBuryHit[ST_TankType(client)] : g_iBuryHit2[ST_TankType(client)];
}

stock int iBuryHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iBuryHitMode[ST_TankType(client)] : g_iBuryHitMode2[ST_TankType(client)];
}

stock int iBuryMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iBuryMessage[ST_TankType(client)] : g_iBuryMessage2[ST_TankType(client)];
}

public Action tTimerStopBury(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bBury[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell()), iBuryChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vStopBury(iSurvivor, iTank, iBuryChat);
		return Plugin_Stop;
	}
	int iBuryEnabled = pack.ReadCell();
	if (iBuryEnabled == 0)
	{
		vStopBury(iSurvivor, iTank, iBuryChat);
		return Plugin_Stop;
	}
	vStopBury(iSurvivor, iTank, iBuryChat);
	return Plugin_Continue;
}