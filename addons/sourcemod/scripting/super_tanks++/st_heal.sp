// Super Tanks++: Heal Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Heal Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bHeal[MAXPLAYERS + 1];
bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
char g_sTankColors[ST_MAXTYPES + 1][28];
char g_sTankColors2[ST_MAXTYPES + 1][28];
ConVar g_cvSTFindConVar;
float g_flHealInterval[ST_MAXTYPES + 1];
float g_flHealInterval2[ST_MAXTYPES + 1];
float g_flHealRange[ST_MAXTYPES + 1];
float g_flHealRange2[ST_MAXTYPES + 1];
Handle g_hSDKHealPlayer;
Handle g_hSDKRevivePlayer;
int g_iGlowEffect[ST_MAXTYPES + 1];
int g_iGlowEffect2[ST_MAXTYPES + 1];
int g_iHealAbility[ST_MAXTYPES + 1];
int g_iHealAbility2[ST_MAXTYPES + 1];
int g_iHealChance[ST_MAXTYPES + 1];
int g_iHealChance2[ST_MAXTYPES + 1];
int g_iHealCommon[ST_MAXTYPES + 1];
int g_iHealCommon2[ST_MAXTYPES + 1];
int g_iHealHit[ST_MAXTYPES + 1];
int g_iHealHit2[ST_MAXTYPES + 1];
int g_iHealSpecial[ST_MAXTYPES + 1];
int g_iHealSpecial2[ST_MAXTYPES + 1];
int g_iHealTank[ST_MAXTYPES + 1];
int g_iHealTank2[ST_MAXTYPES + 1];

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
	if (!LibraryExists("super_tanks++"))
	{
		SetFailState("No Super Tanks++ library found.");
	}
}

public void OnPluginStart()
{
	g_cvSTFindConVar = FindConVar("survivor_max_incapacitated_count");
	Handle hGameData = LoadGameConfigFile("super_tanks++");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer_SetHealthBuffer");
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	g_hSDKHealPlayer = EndPrepSDKCall();
	if (g_hSDKHealPlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_SetHealthBuffer\" signature is outdated.", ST_PREFIX);
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer_OnRevived");
	g_hSDKRevivePlayer = EndPrepSDKCall();
	if (g_hSDKRevivePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnRevived\" signature is outdated.", ST_PREFIX);
	}
}

public void OnMapStart()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bHeal[iPlayer] = false;
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
	g_bHeal[client] = false;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bHeal[client] = false;
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bHeal[iPlayer] = false;
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
		if (bIsTank(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vHealHit(victim, attacker);
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
			main ? (kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors[iIndex], sizeof(g_sTankColors[]), "255,255,255,255|255,255,255")) : (kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors2[iIndex], sizeof(g_sTankColors2[]), g_sTankColors[iIndex]));
			main ? (g_iGlowEffect[iIndex] = kvSuperTanks.GetNum("General/Glow Effect", 1)) : (g_iGlowEffect2[iIndex] = kvSuperTanks.GetNum("General/Glow Effect", g_iGlowEffect[iIndex]));
			main ? (g_iGlowEffect[iIndex] = iSetCellLimit(g_iGlowEffect[iIndex], 0, 1)) : (g_iGlowEffect2[iIndex] = iSetCellLimit(g_iGlowEffect2[iIndex], 0, 1));
			main ? (g_iHealAbility[iIndex] = kvSuperTanks.GetNum("Heal Ability/Ability Enabled", 0)) : (g_iHealAbility2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Ability Enabled", g_iHealAbility[iIndex]));
			main ? (g_iHealAbility[iIndex] = iSetCellLimit(g_iHealAbility[iIndex], 0, 1)) : (g_iHealAbility2[iIndex] = iSetCellLimit(g_iHealAbility2[iIndex], 0, 1));
			main ? (g_iHealChance[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Chance", 4)) : (g_iHealChance2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Chance", g_iHealChance[iIndex]));
			main ? (g_iHealChance[iIndex] = iSetCellLimit(g_iHealChance[iIndex], 1, 9999999999)) : (g_iHealChance2[iIndex] = iSetCellLimit(g_iHealChance2[iIndex], 1, 9999999999));
			main ? (g_iHealCommon[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Commons", 50)) : (g_iHealCommon2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Commons", g_iHealCommon[iIndex]));
			main ? (g_iHealCommon[iIndex] = iSetCellLimit(g_iHealCommon[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iHealCommon2[iIndex] = iSetCellLimit(g_iHealCommon2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
			main ? (g_iHealHit[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Hit", 0)) : (g_iHealHit2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Heal Hit", g_iHealHit[iIndex]));
			main ? (g_iHealHit[iIndex] = iSetCellLimit(g_iHealHit[iIndex], 0, 1)) : (g_iHealHit2[iIndex] = iSetCellLimit(g_iHealHit2[iIndex], 0, 1));
			main ? (g_flHealInterval[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Interval", 5.0)) : (g_flHealInterval2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Interval", g_flHealInterval[iIndex]));
			main ? (g_flHealInterval[iIndex] = flSetFloatLimit(g_flHealInterval[iIndex], 0.1, 9999999999.0)) : (g_flHealInterval2[iIndex] = flSetFloatLimit(g_flHealInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_flHealRange[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Range", 500.0)) : (g_flHealRange2[iIndex] = kvSuperTanks.GetFloat("Heal Ability/Heal Range", g_flHealRange[iIndex]));
			main ? (g_flHealRange[iIndex] = flSetFloatLimit(g_flHealRange[iIndex], 1.0, 9999999999.0)) : (g_flHealRange2[iIndex] = flSetFloatLimit(g_flHealRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iHealSpecial[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Specials", 100)) : (g_iHealSpecial2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Specials", g_iHealSpecial[iIndex]));
			main ? (g_iHealSpecial[iIndex] = iSetCellLimit(g_iHealSpecial[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iHealSpecial2[iIndex] = iSetCellLimit(g_iHealSpecial2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
			main ? (g_iHealTank[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Tanks", 500)) : (g_iHealTank2[iIndex] = kvSuperTanks.GetNum("Heal Ability/Health From Tanks", g_iHealTank[iIndex]));
			main ? (g_iHealTank[iIndex] = iSetCellLimit(g_iHealTank[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iHealTank2[iIndex] = iSetCellLimit(g_iHealTank2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	int iHealAbility = !g_bTankConfig[ST_TankType(client)] ? g_iHealAbility[ST_TankType(client)] : g_iHealAbility2[ST_TankType(client)];
	if (iHealAbility == 1 && bIsTank(client) && !g_bHeal[client])
	{
		g_bHeal[client] = true;
		float flHealInterval = !g_bTankConfig[ST_TankType(client)] ? g_flHealInterval[ST_TankType(client)] : g_flHealInterval2[ST_TankType(client)];
		CreateTimer(flHealInterval, tTimerHeal, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

void vHealHit(int client, int owner)
{
	int iHealChance = !g_bTankConfig[ST_TankType(owner)] ? g_iHealChance[ST_TankType(owner)] : g_iHealChance2[ST_TankType(owner)];
	int iHealHit = !g_bTankConfig[ST_TankType(owner)] ? g_iHealHit[ST_TankType(owner)] : g_iHealHit2[ST_TankType(owner)];
	if (iHealHit == 1 && GetRandomInt(1, iHealChance) == 1 && bIsSurvivor(client))
	{
		SetEntProp(client, Prop_Send, "m_currentReviveCount", g_cvSTFindConVar.IntValue - 1);
		SetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
		SDKCall(g_hSDKRevivePlayer, client);
		SetEntityHealth(client, 1);
		SDKCall(g_hSDKHealPlayer, client, 50.0);
	}
}

int iGetRGBColor(int red, int green, int blue) 
{
	return (blue * 65536) + (green * 256) + red;
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

public Action tTimerHeal(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	int iHealAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iHealAbility[ST_TankType(iTank)] : g_iHealAbility2[ST_TankType(iTank)];
	if (iHealAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bHeal[iTank] = false;
		return Plugin_Stop;
	}
	if (bIsTank(iTank))
	{
		int iType;
		int iSpecial = -1;
		float flHealRange = !g_bTankConfig[ST_TankType(iTank)] ? g_flHealRange[ST_TankType(iTank)] : g_flHealRange2[ST_TankType(iTank)];
		while ((iSpecial = FindEntityByClassname(iSpecial, "infected")) != INVALID_ENT_REFERENCE)
		{
			float flTankPos[3];
			float flInfectedPos[3];
			GetClientAbsOrigin(iTank, flTankPos);
			GetEntPropVector(iSpecial, Prop_Send, "m_vecOrigin", flInfectedPos);
			float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
			if (flDistance <= flHealRange)
			{
				int iHealth = GetClientHealth(iTank);
				int iCommonHealth = !g_bTankConfig[ST_TankType(iTank)] ? (iHealth + g_iHealCommon[ST_TankType(iTank)]) : (iHealth + g_iHealCommon2[ST_TankType(iTank)]);
				int iExtraHealth = (iCommonHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iCommonHealth;
				int iExtraHealth2 = (iCommonHealth < iHealth) ? 1 : iCommonHealth;
				int iRealHealth = (iCommonHealth >= 0) ? iExtraHealth : iExtraHealth2;
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
				float flTankPos[3];
				float flInfectedPos[3];
				GetClientAbsOrigin(iTank, flTankPos);
				GetClientAbsOrigin(iInfected, flInfectedPos);
				float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
				if (flDistance <= flHealRange)
				{
					int iHealth = GetClientHealth(iTank);
					int iSpecialHealth = !g_bTankConfig[ST_TankType(iTank)] ? (iHealth + g_iHealSpecial[ST_TankType(iTank)]) : (iHealth + g_iHealSpecial2[ST_TankType(iTank)]);
					int iExtraHealth = (iSpecialHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iSpecialHealth;
					int iExtraHealth2 = (iSpecialHealth < iHealth) ? 1 : iSpecialHealth;
					int iRealHealth = (iSpecialHealth >= 0) ? iExtraHealth : iExtraHealth2;
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
			else if (bIsTank(iInfected) && iInfected != iTank)
			{
				float flTankPos[3];
				float flInfectedPos[3];
				GetClientAbsOrigin(iTank, flTankPos);
				GetClientAbsOrigin(iInfected, flInfectedPos);
				float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
				if (flDistance <= flHealRange)
				{
					int iHealth = GetClientHealth(iTank);
					int iTankHealth = !g_bTankConfig[ST_TankType(iTank)] ? (iHealth + g_iHealTank[ST_TankType(iTank)]) : (iHealth + g_iHealTank2[ST_TankType(iTank)]);
					int iExtraHealth = (iTankHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iTankHealth;
					int iExtraHealth2 = (iTankHealth < iHealth) ? 1 : iTankHealth;
					int iRealHealth = (iTankHealth >= 0) ? iExtraHealth : iExtraHealth2;
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
			char sSet[2][16];
			char sTankColors[28];
			sTankColors = !g_bTankConfig[ST_TankType(iTank)] ? g_sTankColors[ST_TankType(iTank)] : g_sTankColors2[ST_TankType(iTank)];
			TrimString(sTankColors);
			ExplodeString(sTankColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
			char sGlow[3][4];
			ExplodeString(sSet[1], ",", sGlow, sizeof(sGlow), sizeof(sGlow[]));
			TrimString(sGlow[0]);
			int iRed = (sGlow[0][0] != '\0') ? StringToInt(sGlow[0]) : 255;
			TrimString(sGlow[1]);
			int iGreen = (sGlow[1][0] != '\0') ? StringToInt(sGlow[1]) : 255;
			TrimString(sGlow[2]);
			int iBlue = (sGlow[2][0] != '\0') ? StringToInt(sGlow[2]) : 255;
			int iGlowEffect = !g_bTankConfig[ST_TankType(iTank)] ? g_iGlowEffect[ST_TankType(iTank)] : g_iGlowEffect2[ST_TankType(iTank)];
			if (iGlowEffect == 1 && bIsL4D2Game())
			{
				SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
				SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(iRed, iGreen, iBlue));
				SetEntProp(iTank, Prop_Send, "m_bFlashing", 0);
			}
		}
	}
	return Plugin_Continue;
}