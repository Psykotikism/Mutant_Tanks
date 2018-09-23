// Super Tanks++: Heal Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Heal Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bHeal[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
char g_sTankColors[ST_MAXTYPES + 1][28], g_sTankColors2[ST_MAXTYPES + 1][28];
float g_flHealAbsorbRange[ST_MAXTYPES + 1], g_flHealAbsorbRange2[ST_MAXTYPES + 1], g_flHealBuffer[ST_MAXTYPES + 1], g_flHealBuffer2[ST_MAXTYPES + 1], g_flHealInterval[ST_MAXTYPES + 1], g_flHealInterval2[ST_MAXTYPES + 1], g_flHealRange[ST_MAXTYPES + 1], g_flHealRange2[ST_MAXTYPES + 1];
int g_iGlowOutline[ST_MAXTYPES + 1], g_iGlowOutline2[ST_MAXTYPES + 1], g_iHealAbility[ST_MAXTYPES + 1], g_iHealAbility2[ST_MAXTYPES + 1], g_iHealChance[ST_MAXTYPES + 1], g_iHealChance2[ST_MAXTYPES + 1], g_iHealCommon[ST_MAXTYPES + 1], g_iHealCommon2[ST_MAXTYPES + 1], g_iHealHit[ST_MAXTYPES + 1], g_iHealHit2[ST_MAXTYPES + 1], g_iHealHitMode[ST_MAXTYPES + 1], g_iHealHitMode2[ST_MAXTYPES + 1], g_iHealMessage[ST_MAXTYPES + 1], g_iHealMessage2[ST_MAXTYPES + 1], g_iHealRangeChance[ST_MAXTYPES + 1], g_iHealRangeChance2[ST_MAXTYPES + 1], g_iHealSpecial[ST_MAXTYPES + 1], g_iHealSpecial2[ST_MAXTYPES + 1], g_iHealTank[ST_MAXTYPES + 1], g_iHealTank2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Heal Ability only supports Left 4 Dead 1 & 2.");
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
	g_bHeal[client] = false;
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
		if ((iHealHitMode(attacker) == 0 || iHealHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vHealHit(victim, attacker, iHealChance(attacker), iHealHit(attacker), 1);
			}
		}
		else if ((iHealHitMode(victim) == 0 || iHealHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vHealHit(attacker, victim, iHealChance(victim), iHealHit(victim), 1);
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
			main ? (kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors[iIndex], sizeof(g_sTankColors[]), "255,255,255,255|255,255,255")) : (kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors2[iIndex], sizeof(g_sTankColors2[]), g_sTankColors[iIndex]));
			main ? (g_iGlowOutline[iIndex] = kvSuperTanks.GetNum("General/Glow Outline", 1)) : (g_iGlowOutline2[iIndex] = kvSuperTanks.GetNum("General/Glow Outline", g_iGlowOutline[iIndex]));
			main ? (g_iGlowOutline[iIndex] = iClamp(g_iGlowOutline[iIndex], 0, 1)) : (g_iGlowOutline2[iIndex] = iClamp(g_iGlowOutline2[iIndex], 0, 1));
			main ? (g_iHealAbility[iIndex] = kvSuperTanks.GetNum("Heal Ability/Ability Enabled", 0)) : (g_iHealAbility2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Ability Enabled", g_iHealAbility[iIndex]));
			main ? (g_iHealAbility[iIndex] = iClamp(g_iHealAbility[iIndex], 0, 3)) : (g_iHealAbility2[iIndex] = iClamp(g_iHealAbility2[iIndex], 0, 3));
			main ? (g_iHealMessage[iIndex] = kvSuperTanks.GetNum("Heal Ability/Ability Message", 0)) : (g_iHealMessage2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Ability Message", g_iHealMessage[iIndex]));
			main ? (g_iHealMessage[iIndex] = iClamp(g_iHealMessage[iIndex], 0, 7)) : (g_iHealMessage2[iIndex] = iClamp(g_iHealMessage2[iIndex], 0, 7));
			main ? (g_flHealAbsorbRange[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Absorb Range", 500.0)) : (g_flHealAbsorbRange2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Absorb Range", g_flHealAbsorbRange[iIndex]));
			main ? (g_flHealAbsorbRange[iIndex] = flClamp(g_flHealAbsorbRange[iIndex], 1.0, 9999999999.0)) : (g_flHealAbsorbRange2[iIndex] = flClamp(g_flHealAbsorbRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_flHealBuffer[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Buffer", 25.0)) : (g_flHealBuffer2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Buffer", g_flHealBuffer[iIndex]));
			main ? (g_flHealBuffer[iIndex] = flClamp(g_flHealBuffer[iIndex], 1.0, float(ST_MAXHEALTH))) : (g_flHealBuffer2[iIndex] = flClamp(g_flHealBuffer2[iIndex], 1.0, float(ST_MAXHEALTH)));
			main ? (g_iHealChance[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Chance", 4)) : (g_iHealChance2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Chance", g_iHealChance[iIndex]));
			main ? (g_iHealChance[iIndex] = iClamp(g_iHealChance[iIndex], 1, 9999999999)) : (g_iHealChance2[iIndex] = iClamp(g_iHealChance2[iIndex], 1, 9999999999));
			main ? (g_iHealCommon[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Commons", 50)) : (g_iHealCommon2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Commons", g_iHealCommon[iIndex]));
			main ? (g_iHealCommon[iIndex] = iClamp(g_iHealCommon[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iHealCommon2[iIndex] = iClamp(g_iHealCommon2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
			main ? (g_iHealHit[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Hit", 0)) : (g_iHealHit2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Hit", g_iHealHit[iIndex]));
			main ? (g_iHealHit[iIndex] = iClamp(g_iHealHit[iIndex], 0, 1)) : (g_iHealHit2[iIndex] = iClamp(g_iHealHit2[iIndex], 0, 1));
			main ? (g_iHealHitMode[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Hit Mode", 0)) : (g_iHealHitMode2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Hit Mode", g_iHealHitMode[iIndex]));
			main ? (g_iHealHitMode[iIndex] = iClamp(g_iHealHitMode[iIndex], 0, 2)) : (g_iHealHitMode2[iIndex] = iClamp(g_iHealHitMode2[iIndex], 0, 2));
			main ? (g_flHealInterval[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Interval", 5.0)) : (g_flHealInterval2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Interval", g_flHealInterval[iIndex]));
			main ? (g_flHealInterval[iIndex] = flClamp(g_flHealInterval[iIndex], 0.1, 9999999999.0)) : (g_flHealInterval2[iIndex] = flClamp(g_flHealInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_flHealRange[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Range", 150.0)) : (g_flHealRange2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Range", g_flHealRange[iIndex]));
			main ? (g_flHealRange[iIndex] = flClamp(g_flHealRange[iIndex], 1.0, 9999999999.0)) : (g_flHealRange2[iIndex] = flClamp(g_flHealRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iHealRangeChance[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Range Chance", 16)) : (g_iHealRangeChance2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Range Chance", g_iHealRangeChance[iIndex]));
			main ? (g_iHealRangeChance[iIndex] = iClamp(g_iHealRangeChance[iIndex], 1, 9999999999)) : (g_iHealRangeChance2[iIndex] = iClamp(g_iHealRangeChance2[iIndex], 1, 9999999999));
			main ? (g_iHealSpecial[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Specials", 100)) : (g_iHealSpecial2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Specials", g_iHealSpecial[iIndex]));
			main ? (g_iHealSpecial[iIndex] = iClamp(g_iHealSpecial[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iHealSpecial2[iIndex] = iClamp(g_iHealSpecial2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
			main ? (g_iHealTank[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Tanks", 500)) : (g_iHealTank2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Tanks", g_iHealTank[iIndex]));
			main ? (g_iHealTank[iIndex] = iClamp(g_iHealTank[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iHealTank2[iIndex] = iClamp(g_iHealTank2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iHealRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iHealChance[ST_TankType(client)] : g_iHealChance2[ST_TankType(client)];
		float flHealRange = !g_bTankConfig[ST_TankType(client)] ? g_flHealRange[ST_TankType(client)] : g_flHealRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flHealRange)
				{
					vHealHit(iSurvivor, client, iHealRangeChance, iHealAbility(client), 2);
				}
			}
		}
		if ((iHealAbility(client) == 2 || iHealAbility(client) == 3) && !g_bHeal[client])
		{
			g_bHeal[client] = true;
			float flHealInterval = !g_bTankConfig[ST_TankType(client)] ? g_flHealInterval[ST_TankType(client)] : g_flHealInterval2[ST_TankType(client)];
			CreateTimer(flHealInterval, tTimerHeal, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			switch (iHealMessage(client))
			{
				case 3, 5, 6, 7:
				{
					char sTankName[MAX_NAME_LENGTH + 1];
					ST_TankName(client, sTankName);
					PrintToChatAll("%s %t", ST_PREFIX2, "Heal2", sTankName);
				}
			}
		}
	}
}

stock void vHealHit(int client, int owner, int chance, int enabled, int message)
{
	if ((enabled == 1 || enabled == 3) && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		int iHealth = GetClientHealth(client);
		if (iHealth > 0 && !bIsPlayerIncapacitated(client))
		{
			float flHealBuffer = !g_bTankConfig[ST_TankType(owner)] ? g_flHealBuffer[ST_TankType(owner)] : g_flHealBuffer2[ST_TankType(owner)];
			SetEntityHealth(client, 1);
			SetEntPropFloat(client, Prop_Send, "m_healthBufferTime", GetGameTime());
			SetEntPropFloat(client, Prop_Send, "m_healthBuffer", flHealBuffer);
			if (iHealMessage(owner) == message || iHealMessage(owner) == 4 || iHealMessage(owner) == 5 || iHealMessage(owner) == 6 || iHealMessage(owner) == 7)
			{
				char sTankName[MAX_NAME_LENGTH + 1];
				ST_TankName(owner, sTankName);
				PrintToChatAll("%s %t", ST_PREFIX2, "Heal", sTankName, client);
			}
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bHeal[iPlayer] = false;
		}
	}
}

stock int iHealAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iHealAbility[ST_TankType(client)] : g_iHealAbility2[ST_TankType(client)];
}

stock int iHealChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iHealChance[ST_TankType(client)] : g_iHealChance2[ST_TankType(client)];
}

stock int iHealHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iHealHit[ST_TankType(client)] : g_iHealHit2[ST_TankType(client)];
}

stock int iHealHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iHealHitMode[ST_TankType(client)] : g_iHealHitMode2[ST_TankType(client)];
}

stock int iHealMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iHealMessage[ST_TankType(client)] : g_iHealMessage2[ST_TankType(client)];
}

public Action tTimerHeal(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bHeal[iTank] = false;
		return Plugin_Stop;
	}
	if (iHealAbility(iTank) != 2 && iHealAbility(iTank) != 3)
	{
		g_bHeal[iTank] = false;
		switch (iHealMessage(iTank))
		{
			case 3, 5, 6, 7:
			{
				char sTankName[MAX_NAME_LENGTH + 1];
				ST_TankName(iTank, sTankName);
				PrintToChatAll("%s %t", ST_PREFIX2, "Heal3", sTankName);
			}
		}
		return Plugin_Stop;
	}
	int iType, iSpecial = -1;
	float flHealAbsorbRange = !g_bTankConfig[ST_TankType(iTank)] ? g_flHealAbsorbRange[ST_TankType(iTank)] : g_flHealAbsorbRange2[ST_TankType(iTank)];
	while ((iSpecial = FindEntityByClassname(iSpecial, "infected")) != INVALID_ENT_REFERENCE)
	{
		float flTankPos[3], flInfectedPos[3];
		GetClientAbsOrigin(iTank, flTankPos);
		GetEntPropVector(iSpecial, Prop_Send, "m_vecOrigin", flInfectedPos);
		float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
		if (flDistance <= flHealAbsorbRange)
		{
			int iHealth = GetClientHealth(iTank),
				iCommonHealth = !g_bTankConfig[ST_TankType(iTank)] ? (iHealth + g_iHealCommon[ST_TankType(iTank)]) : (iHealth + g_iHealCommon2[ST_TankType(iTank)]),
				iExtraHealth = (iCommonHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iCommonHealth,
				iExtraHealth2 = (iCommonHealth < iHealth) ? 1 : iCommonHealth,
				iRealHealth = (iCommonHealth >= 0) ? iExtraHealth : iExtraHealth2;
			if (iHealth > 500)
			{
				SetEntityHealth(iTank, iRealHealth);
				if (bIsL4D2Game())
				{
					SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
					SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 185, 0));
					SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);
				}
				iType = 1;
			}
		}
	}
	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (bIsSpecialInfected(iInfected))
		{
			float flTankPos[3], flInfectedPos[3];
			GetClientAbsOrigin(iTank, flTankPos);
			GetClientAbsOrigin(iInfected, flInfectedPos);
			float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
			if (flDistance <= flHealAbsorbRange)
			{
				int iHealth = GetClientHealth(iTank),
					iSpecialHealth = !g_bTankConfig[ST_TankType(iTank)] ? (iHealth + g_iHealSpecial[ST_TankType(iTank)]) : (iHealth + g_iHealSpecial2[ST_TankType(iTank)]),
					iExtraHealth = (iSpecialHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iSpecialHealth,
					iExtraHealth2 = (iSpecialHealth < iHealth) ? 1 : iSpecialHealth,
					iRealHealth = (iSpecialHealth >= 0) ? iExtraHealth : iExtraHealth2;
				if (iHealth > 500)
				{
					SetEntityHealth(iTank, iRealHealth);
					if (iType < 2 && bIsL4D2Game())
					{
						SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
						SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 220, 0));
						SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);
						iType = 1;
					}
				}
			}
		}
		else if (ST_TankAllowed(iInfected) && IsPlayerAlive(iInfected) && iInfected != iTank)
		{
			float flTankPos[3], flInfectedPos[3];
			GetClientAbsOrigin(iTank, flTankPos);
			GetClientAbsOrigin(iInfected, flInfectedPos);
			float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
			if (flDistance <= flHealAbsorbRange)
			{
				int iHealth = GetClientHealth(iTank),
					iTankHealth = !g_bTankConfig[ST_TankType(iTank)] ? (iHealth + g_iHealTank[ST_TankType(iTank)]) : (iHealth + g_iHealTank2[ST_TankType(iTank)]),
					iExtraHealth = (iTankHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iTankHealth,
					iExtraHealth2 = (iTankHealth < iHealth) ? 1 : iTankHealth,
					iRealHealth = (iTankHealth >= 0) ? iExtraHealth : iExtraHealth2;
				if (iHealth > 500)
				{
					SetEntityHealth(iTank, iRealHealth);
					if (bIsL4D2Game())
					{
						SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
						SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 255, 0));
						SetEntProp(iTank, Prop_Send, "m_bFlashing", 1);
						iType = 2;
					}
				}
			}
		}
	}
	if (iType == 0 && bIsL4D2Game())
	{
		char sSet[2][16], sTankColors[28], sGlow[3][4];
		sTankColors = !g_bTankConfig[ST_TankType(iTank)] ? g_sTankColors[ST_TankType(iTank)] : g_sTankColors2[ST_TankType(iTank)];
		TrimString(sTankColors);
		ExplodeString(sTankColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
		ExplodeString(sSet[1], ",", sGlow, sizeof(sGlow), sizeof(sGlow[]));
		TrimString(sGlow[0]);
		int iRed = (strcmp(sGlow[0], "") == 1) ? StringToInt(sGlow[0]) : 255;
		iRed = iClamp(iRed, 0, 255);
		TrimString(sGlow[1]);
		int iGreen = (strcmp(sGlow[1], "") == 1) ? StringToInt(sGlow[1]) : 255;
		iGreen = iClamp(iGreen, 0, 255);
		TrimString(sGlow[2]);
		int iBlue = (strcmp(sGlow[2], "") == 1) ? StringToInt(sGlow[2]) : 255;
		iBlue = iClamp(iBlue, 0, 255);
		int iGlowOutline = !g_bTankConfig[ST_TankType(iTank)] ? g_iGlowOutline[ST_TankType(iTank)] : g_iGlowOutline2[ST_TankType(iTank)];
		if (iGlowOutline == 1 && bIsL4D2Game())
		{
			SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
			SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(iRed, iGreen, iBlue));
			SetEntProp(iTank, Prop_Send, "m_bFlashing", 0);
		}
	}
	return Plugin_Continue;
}