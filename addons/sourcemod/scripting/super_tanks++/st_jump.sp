// Super Tanks++: Jump Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Jump Ability",
	author = ST_AUTHOR,
	description = "The Super Tank jumps periodically.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bJump[MAXPLAYERS + 1], g_bJump2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
float g_flJumpDuration[ST_MAXTYPES + 1], g_flJumpDuration2[ST_MAXTYPES + 1], g_flJumpHeight[ST_MAXTYPES + 1], g_flJumpHeight2[ST_MAXTYPES + 1], g_flJumpInterval[ST_MAXTYPES + 1], g_flJumpInterval2[ST_MAXTYPES + 1], g_flJumpRange[ST_MAXTYPES + 1], g_flJumpRange2[ST_MAXTYPES + 1];
int g_iJumpAbility[ST_MAXTYPES + 1], g_iJumpAbility2[ST_MAXTYPES + 1], g_iJumpChance[ST_MAXTYPES + 1], g_iJumpChance2[ST_MAXTYPES + 1], g_iJumpHit[ST_MAXTYPES + 1], g_iJumpHit2[ST_MAXTYPES + 1], g_iJumpHitMode[ST_MAXTYPES + 1], g_iJumpHitMode2[ST_MAXTYPES + 1], g_iJumpMessage[ST_MAXTYPES + 1], g_iJumpMessage2[ST_MAXTYPES + 1], g_iJumpRangeChance[ST_MAXTYPES + 1], g_iJumpRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Jump Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
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
}

public void OnMapStart()
{
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bJump[client] = false;
	g_bJump2[client] = false;
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
		if ((iJumpHitMode(attacker) == 0 || iJumpHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vJumpHit(victim, attacker, iJumpChance(attacker), iJumpHit(attacker), 1);
			}
		}
		else if ((iJumpHitMode(victim) == 0 || iJumpHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vJumpHit(attacker, victim, iJumpChance(victim), iJumpHit(victim), 1);
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
			main ? (g_iJumpAbility[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Enabled", 0)) : (g_iJumpAbility2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Enabled", g_iJumpAbility[iIndex]));
			main ? (g_iJumpAbility[iIndex] = iClamp(g_iJumpAbility[iIndex], 0, 3)) : (g_iJumpAbility2[iIndex] = iClamp(g_iJumpAbility2[iIndex], 0, 3));
			main ? (g_iJumpMessage[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Message", 0)) : (g_iJumpMessage2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Ability Message", g_iJumpMessage[iIndex]));
			main ? (g_iJumpMessage[iIndex] = iClamp(g_iJumpMessage[iIndex], 0, 7)) : (g_iJumpMessage2[iIndex] = iClamp(g_iJumpMessage2[iIndex], 0, 7));
			main ? (g_iJumpChance[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Chance", 4)) : (g_iJumpChance2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Chance", g_iJumpChance[iIndex]));
			main ? (g_iJumpChance[iIndex] = iClamp(g_iJumpChance[iIndex], 1, 9999999999)) : (g_iJumpChance2[iIndex] = iClamp(g_iJumpChance2[iIndex], 1, 9999999999));
			main ? (g_flJumpDuration[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Duration", 5.0)) : (g_flJumpDuration2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Duration", g_flJumpDuration[iIndex]));
			main ? (g_flJumpDuration[iIndex] = flClamp(g_flJumpDuration[iIndex], 0.1, 9999999999.0)) : (g_flJumpDuration2[iIndex] = flClamp(g_flJumpDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_flJumpHeight[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Height", 300.0)) : (g_flJumpHeight2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Height", g_flJumpHeight[iIndex]));
			main ? (g_flJumpHeight[iIndex] = flClamp(g_flJumpHeight[iIndex], 0.1, 9999999999.0)) : (g_flJumpHeight2[iIndex] = flClamp(g_flJumpHeight2[iIndex], 0.1, 9999999999.0));
			main ? (g_iJumpHit[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Hit", 0)) : (g_iJumpHit2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Hit", g_iJumpHit[iIndex]));
			main ? (g_iJumpHit[iIndex] = iClamp(g_iJumpHit[iIndex], 0, 1)) : (g_iJumpHit2[iIndex] = iClamp(g_iJumpHit2[iIndex], 0, 1));
			main ? (g_iJumpHitMode[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Hit Mode", 0)) : (g_iJumpHitMode2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Hit Mode", g_iJumpHitMode[iIndex]));
			main ? (g_iJumpHitMode[iIndex] = iClamp(g_iJumpHitMode[iIndex], 0, 2)) : (g_iJumpHitMode2[iIndex] = iClamp(g_iJumpHitMode2[iIndex], 0, 2));
			main ? (g_flJumpInterval[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Interval", 1.0)) : (g_flJumpInterval2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Interval", g_flJumpInterval[iIndex]));
			main ? (g_flJumpInterval[iIndex] = flClamp(g_flJumpInterval[iIndex], 0.1, 9999999999.0)) : (g_flJumpInterval2[iIndex] = flClamp(g_flJumpInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_flJumpRange[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Range", 150.0)) : (g_flJumpRange2[iIndex] = kvSuperTanks.GetFloat("Jump Ability/Jump Range", g_flJumpRange[iIndex]));
			main ? (g_flJumpRange[iIndex] = flClamp(g_flJumpRange[iIndex], 1.0, 9999999999.0)) : (g_flJumpRange2[iIndex] = flClamp(g_flJumpRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iJumpRangeChance[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Range Chance", 16)) : (g_iJumpRangeChance2[iIndex] = kvSuperTanks.GetNum("Jump Ability/Jump Range Chance", g_iJumpRangeChance[iIndex]));
			main ? (g_iJumpRangeChance[iIndex] = iClamp(g_iJumpRangeChance[iIndex], 1, 9999999999)) : (g_iJumpRangeChance2[iIndex] = iClamp(g_iJumpRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iJumpRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iJumpChance[ST_TankType(client)] : g_iJumpChance2[ST_TankType(client)];
		float flJumpRange = !g_bTankConfig[ST_TankType(client)] ? g_flJumpRange[ST_TankType(client)] : g_flJumpRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flJumpRange)
				{
					vJumpHit(iSurvivor, client, iJumpRangeChance, iJumpAbility(client), 2);
				}
			}
		}
		if ((iJumpAbility(client) == 2 || iJumpAbility(client) == 3) && !g_bJump[client])
		{
			g_bJump[client] = true;
			float flJumpInterval = !g_bTankConfig[ST_TankType(client)] ? g_flJumpInterval[ST_TankType(client)] : g_flJumpInterval2[ST_TankType(client)];
			CreateTimer(flJumpInterval, tTimerJump, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			switch (iJumpMessage(client))
			{
				case 3, 5, 6, 7:
				{
					char sTankName[MAX_NAME_LENGTH + 1];
					ST_TankName(client, sTankName);
					PrintToChatAll("%s %t", ST_PREFIX2, "Jump3", sTankName);
				}
			}
		}
	}
}

stock void vJump(int client, int owner)
{
	float flJumpHeight = !g_bTankConfig[ST_TankType(owner)] ? g_flJumpHeight[ST_TankType(owner)] : g_flJumpHeight2[ST_TankType(owner)],
		flVelocity[3];
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", flVelocity);
	flVelocity[2] += flJumpHeight;
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, flVelocity);
}

stock void vJumpHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bJump2[client])
	{
		g_bJump2[client] = true;
		DataPack dpJump = new DataPack();
		CreateDataTimer(0.25, tTimerJump2, dpJump, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpJump.WriteCell(GetClientUserId(client)), dpJump.WriteCell(GetClientUserId(owner)), dpJump.WriteCell(message), dpJump.WriteCell(enabled), dpJump.WriteFloat(GetEngineTime());
		char sRGB[4][4];
		ST_TankColors(owner, sRGB[0], sRGB[1], sRGB[2]);
		int iRed = (!StrEqual(sRGB[0], "")) ? StringToInt(sRGB[0]) : 255;
		iRed = iClamp(iRed, 0, 255);
		int iGreen = (!StrEqual(sRGB[1], "")) ? StringToInt(sRGB[1]) : 255;
		iGreen = iClamp(iGreen, 0, 255);
		int iBlue = (!StrEqual(sRGB[2], "")) ? StringToInt(sRGB[2]) : 255;
		iBlue = iClamp(iBlue, 0, 255);
		vFade(client, 800, 300, iRed, iGreen, iBlue);
		if (iJumpMessage(owner) == message || iJumpMessage(owner) == 4 || iJumpMessage(owner) == 5 || iJumpMessage(owner) == 6 || iJumpMessage(owner) == 7)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Jump", sTankName, client);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bJump[iPlayer] = false;
			g_bJump2[iPlayer] = false;
		}
	}
}

stock void vReset2(int client, int owner, int message)
{
	g_bJump2[client] = false;
	if (iJumpMessage(owner) == message || iJumpMessage(owner) == 4 || iJumpMessage(owner) == 5 || iJumpMessage(owner) == 6 || iJumpMessage(owner) == 7)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Jump2", client);
	}
}

stock int iJumpAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iJumpAbility[ST_TankType(client)] : g_iJumpAbility2[ST_TankType(client)];
}

stock int iJumpChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iJumpChance[ST_TankType(client)] : g_iJumpChance2[ST_TankType(client)];
}

stock int iJumpHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iJumpHit[ST_TankType(client)] : g_iJumpHit2[ST_TankType(client)];
}

stock int iJumpHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iJumpHitMode[ST_TankType(client)] : g_iJumpHitMode2[ST_TankType(client)];
}

stock int iJumpMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iJumpMessage[ST_TankType(client)] : g_iJumpMessage2[ST_TankType(client)];
}

public Action tTimerJump(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bJump[iTank] = false;
		return Plugin_Stop;
	}
	if (iJumpAbility(iTank) != 2 && iJumpAbility(iTank) != 3)
	{
		g_bJump[iTank] = false;
		return Plugin_Stop;
	}
	if (GetEntPropEnt(iTank, Prop_Send, "m_hGroundEntity") == -1)
	{
		return Plugin_Continue;
	}
	vJump(iTank, iTank);
	return Plugin_Continue;
}

public Action tTimerJump2(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bJump2[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell()), iJumpChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank, iJumpChat);
		return Plugin_Stop;
	}
	int iJumpEnabled = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flJumpDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flJumpDuration[ST_TankType(iTank)] : g_flJumpDuration2[ST_TankType(iTank)];
	if ((iJumpEnabled != 1 && iJumpEnabled != 3) || (flTime + flJumpDuration < GetEngineTime()))
	{
		vReset2(iSurvivor, iTank, iJumpChat);
		return Plugin_Stop;
	}
	if (GetEntPropEnt(iSurvivor, Prop_Send, "m_hGroundEntity") == -1)
	{
		return Plugin_Continue;
	}
	vJump(iSurvivor, iTank);
	return Plugin_Continue;
}