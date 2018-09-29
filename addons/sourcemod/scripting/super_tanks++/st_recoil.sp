// Super Tanks++: Recoil Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Recoil Ability",
	author = ST_AUTHOR,
	description = "The Super Tank gives survivors strong gun recoil.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bRecoil[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flRecoilDuration[ST_MAXTYPES + 1], g_flRecoilDuration2[ST_MAXTYPES + 1], g_flRecoilRange[ST_MAXTYPES + 1], g_flRecoilRange2[ST_MAXTYPES + 1];
int g_iRecoilAbility[ST_MAXTYPES + 1], g_iRecoilAbility2[ST_MAXTYPES + 1], g_iRecoilChance[ST_MAXTYPES + 1], g_iRecoilChance2[ST_MAXTYPES + 1], g_iRecoilHit[ST_MAXTYPES + 1], g_iRecoilHit2[ST_MAXTYPES + 1], g_iRecoilHitMode[ST_MAXTYPES + 1], g_iRecoilHitMode2[ST_MAXTYPES + 1], g_iRecoilMessage[ST_MAXTYPES + 1], g_iRecoilMessage2[ST_MAXTYPES + 1], g_iRecoilRangeChance[ST_MAXTYPES + 1], g_iRecoilRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Recoil Ability only supports Left 4 Dead 1 & 2.");
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
	g_bRecoil[client] = false;
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
		if ((iRecoilHitMode(attacker) == 0 || iRecoilHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vRecoilHit(victim, attacker, iRecoilChance(attacker), iRecoilHit(attacker), 1);
			}
		}
		else if ((iRecoilHitMode(victim) == 0 || iRecoilHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vRecoilHit(attacker, victim, iRecoilChance(victim), iRecoilHit(victim), 1);
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
			main ? (g_iRecoilAbility[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Ability Enabled", 0)) : (g_iRecoilAbility2[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Ability Enabled", g_iRecoilAbility[iIndex]));
			main ? (g_iRecoilAbility[iIndex] = iClamp(g_iRecoilAbility[iIndex], 0, 1)) : (g_iRecoilAbility2[iIndex] = iClamp(g_iRecoilAbility2[iIndex], 0, 1));
			main ? (g_iRecoilMessage[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Ability Message", 0)) : (g_iRecoilMessage2[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Ability Message", g_iRecoilMessage[iIndex]));
			main ? (g_iRecoilMessage[iIndex] = iClamp(g_iRecoilMessage[iIndex], 0, 3)) : (g_iRecoilMessage2[iIndex] = iClamp(g_iRecoilMessage2[iIndex], 0, 3));
			main ? (g_iRecoilChance[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Chance", 4)) : (g_iRecoilChance2[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Chance", g_iRecoilChance[iIndex]));
			main ? (g_iRecoilChance[iIndex] = iClamp(g_iRecoilChance[iIndex], 1, 9999999999)) : (g_iRecoilChance2[iIndex] = iClamp(g_iRecoilChance2[iIndex], 1, 9999999999));
			main ? (g_flRecoilDuration[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Duration", 5.0)) : (g_flRecoilDuration2[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Duration", g_flRecoilDuration[iIndex]));
			main ? (g_flRecoilDuration[iIndex] = flClamp(g_flRecoilDuration[iIndex], 0.1, 9999999999.0)) : (g_flRecoilDuration2[iIndex] = flClamp(g_flRecoilDuration2[iIndex], 0.1, 9999999999.0));
			main ? (g_iRecoilHit[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Hit", 0)) : (g_iRecoilHit2[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Hit", g_iRecoilHit[iIndex]));
			main ? (g_iRecoilHit[iIndex] = iClamp(g_iRecoilHit[iIndex], 0, 1)) : (g_iRecoilHit2[iIndex] = iClamp(g_iRecoilHit2[iIndex], 0, 1));
			main ? (g_iRecoilHitMode[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Hit Mode", 0)) : (g_iRecoilHitMode2[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Hit Mode", g_iRecoilHitMode[iIndex]));
			main ? (g_iRecoilHitMode[iIndex] = iClamp(g_iRecoilHitMode[iIndex], 0, 2)) : (g_iRecoilHitMode2[iIndex] = iClamp(g_iRecoilHitMode2[iIndex], 0, 2));
			main ? (g_flRecoilRange[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Range", 150.0)) : (g_flRecoilRange2[iIndex] = kvSuperTanks.GetFloat("Recoil Ability/Recoil Range", g_flRecoilRange[iIndex]));
			main ? (g_flRecoilRange[iIndex] = flClamp(g_flRecoilRange[iIndex], 1.0, 9999999999.0)) : (g_flRecoilRange2[iIndex] = flClamp(g_flRecoilRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iRecoilRangeChance[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Range Chance", 16)) : (g_iRecoilRangeChance2[iIndex] = kvSuperTanks.GetNum("Recoil Ability/Recoil Range Chance", g_iRecoilRangeChance[iIndex]));
			main ? (g_iRecoilRangeChance[iIndex] = iClamp(g_iRecoilRangeChance[iIndex], 1, 9999999999)) : (g_iRecoilRangeChance2[iIndex] = iClamp(g_iRecoilRangeChance2[iIndex], 1, 9999999999));
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
			vRemoveRecoil();
		}
	}
	else if (StrEqual(name, "weapon_fire"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId);
		if (bIsSurvivor(iSurvivor) && bIsGunWeapon(iSurvivor) && g_bRecoil[iSurvivor])
		{
			float flRecoil[3];
			flRecoil[0] = GetRandomFloat(-20.0, -80.0), flRecoil[1] = GetRandomFloat(-25.0, 25.0), flRecoil[2] = GetRandomFloat(-25.0, 25.0);
			SetEntPropVector(iSurvivor, Prop_Send, "m_vecPunchAngle", flRecoil);
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iRecoilRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iRecoilChance[ST_TankType(client)] : g_iRecoilChance2[ST_TankType(client)];
		float flRecoilRange = !g_bTankConfig[ST_TankType(client)] ? g_flRecoilRange[ST_TankType(client)] : g_flRecoilRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flRecoilRange)
				{
					vRecoilHit(iSurvivor, client, iRecoilRangeChance, iRecoilAbility(client), 2);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	if (iRecoilAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled))
	{
		vRemoveRecoil();
	}
}

stock void vRecoilHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && !g_bRecoil[client])
	{
		g_bRecoil[client] = true;
		float flRecoilDuration = !g_bTankConfig[ST_TankType(owner)] ? g_flRecoilDuration[ST_TankType(owner)] : g_flRecoilDuration2[ST_TankType(owner)];
		DataPack dpStopRecoil = new DataPack();
		CreateDataTimer(flRecoilDuration, tTimerStopRecoil, dpStopRecoil, TIMER_FLAG_NO_MAPCHANGE);
		dpStopRecoil.WriteCell(GetClientUserId(client)), dpStopRecoil.WriteCell(GetClientUserId(owner)), dpStopRecoil.WriteCell(message), dpStopRecoil.WriteCell(enabled);
		char sRGB[4][4];
		ST_TankColors(owner, sRGB[0], sRGB[1], sRGB[2]);
		int iRed = (!StrEqual(sRGB[0], "")) ? StringToInt(sRGB[0]) : 255;
		iRed = iClamp(iRed, 0, 255);
		int iGreen = (!StrEqual(sRGB[1], "")) ? StringToInt(sRGB[1]) : 255;
		iGreen = iClamp(iGreen, 0, 255);
		int iBlue = (!StrEqual(sRGB[2], "")) ? StringToInt(sRGB[2]) : 255;
		iBlue = iClamp(iBlue, 0, 255);
		vFade(client, 800, 300, iRed, iGreen, iBlue);
		if (iRecoilMessage(owner) == message || iRecoilMessage(owner) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Recoil", sTankName, client);
		}
	}
}

stock void vRemoveRecoil()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bRecoil[iSurvivor])
		{
			g_bRecoil[iSurvivor] = false;
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bRecoil[iPlayer] = false;
		}
	}
}

stock void vReset2(int client, int owner, int message)
{
	g_bRecoil[client] = false;
	if (iRecoilMessage(owner) == message || iRecoilMessage(owner) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Recoil2", client);
	}
}

stock int iRecoilAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iRecoilAbility[ST_TankType(client)] : g_iRecoilAbility2[ST_TankType(client)];
}

stock int iRecoilChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iRecoilChance[ST_TankType(client)] : g_iRecoilChance2[ST_TankType(client)];
}

stock int iRecoilHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iRecoilHit[ST_TankType(client)] : g_iRecoilHit2[ST_TankType(client)];
}

stock int iRecoilHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iRecoilHitMode[ST_TankType(client)] : g_iRecoilHitMode2[ST_TankType(client)];
}

stock int iRecoilMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iRecoilMessage[ST_TankType(client)] : g_iRecoilMessage2[ST_TankType(client)];
}

public Action tTimerStopRecoil(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsSurvivor(iSurvivor))
	{
		g_bRecoil[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell()), iRecoilChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank, iRecoilChat);
		return Plugin_Stop;
	}
	int iRecoilEnabled = pack.ReadCell();
	if (iRecoilEnabled == 0)
	{
		vReset2(iSurvivor, iTank, iRecoilChat);
		return Plugin_Stop;
	}
	vReset2(iSurvivor, iTank, iRecoilChat);
	return Plugin_Continue;
}