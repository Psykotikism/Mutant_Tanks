// Super Tanks++: Heal Ability
bool g_bHeal[MAXPLAYERS + 1];
float g_flHealInterval[ST_MAXTYPES + 1];
float g_flHealInterval2[ST_MAXTYPES + 1];
float g_flHealRange[ST_MAXTYPES + 1];
float g_flHealRange2[ST_MAXTYPES + 1];
Handle g_hSDKHealPlayer;
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

void vHealSDKCalls(Handle gamedata)
{
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTerrorPlayer_SetHealthBuffer");
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	g_hSDKHealPlayer = EndPrepSDKCall();
	if (g_hSDKHealPlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_SetHealthBuffer\" signature is outdated.", ST_PREFIX);
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTerrorPlayer_OnRevived");
	g_hSDKRevivePlayer = EndPrepSDKCall();
	if (g_hSDKRevivePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnRevived\" signature is outdated.", ST_PREFIX);
	}
}

void vHealConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iHealAbility[index] = keyvalues.GetNum("Heal Ability/Ability Enabled", 0)) : (g_iHealAbility2[index] = keyvalues.GetNum("Heal Ability/Ability Enabled", g_iHealAbility[index]));
	main ? (g_iHealAbility[index] = iSetCellLimit(g_iHealAbility[index], 0, 1)) : (g_iHealAbility2[index] = iSetCellLimit(g_iHealAbility2[index], 0, 1));
	main ? (g_iHealChance[index] = keyvalues.GetNum("Heal Ability/Heal Chance", 4)) : (g_iHealChance2[index] = keyvalues.GetNum("Heal Ability/Heal Chance", g_iHealChance[index]));
	main ? (g_iHealChance[index] = iSetCellLimit(g_iHealChance[index], 1, 9999999999)) : (g_iHealChance2[index] = iSetCellLimit(g_iHealChance2[index], 1, 9999999999));
	main ? (g_iHealCommon[index] = keyvalues.GetNum("Heal Ability/Health From Commons", 50)) : (g_iHealCommon2[index] = keyvalues.GetNum("Heal Ability/Health From Commons", g_iHealCommon[index]));
	main ? (g_iHealCommon[index] = iSetCellLimit(g_iHealCommon[index], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iHealCommon2[index] = iSetCellLimit(g_iHealCommon2[index], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
	main ? (g_iHealHit[index] = keyvalues.GetNum("Heal Ability/Heal Hit", 0)) : (g_iHealHit2[index] = keyvalues.GetNum("Heal Ability/Heal Hit", g_iHealHit[index]));
	main ? (g_iHealHit[index] = iSetCellLimit(g_iHealHit[index], 0, 1)) : (g_iHealHit2[index] = iSetCellLimit(g_iHealHit2[index], 0, 1));
	main ? (g_flHealInterval[index] = keyvalues.GetFloat("Heal Ability/Heal Interval", 5.0)) : (g_flHealInterval2[index] = keyvalues.GetFloat("Heal Ability/Heal Interval", g_flHealInterval[index]));
	main ? (g_flHealInterval[index] = flSetFloatLimit(g_flHealInterval[index], 0.1, 9999999999.0)) : (g_flHealInterval2[index] = flSetFloatLimit(g_flHealInterval2[index], 0.1, 9999999999.0));
	main ? (g_flHealRange[index] = keyvalues.GetFloat("Heal Ability/Heal Range", 500.0)) : (g_flHealRange2[index] = keyvalues.GetFloat("Heal Ability/Heal Range", g_flHealRange[index]));
	main ? (g_flHealRange[index] = flSetFloatLimit(g_flHealRange[index], 1.0, 9999999999.0)) : (g_flHealRange2[index] = flSetFloatLimit(g_flHealRange2[index], 1.0, 9999999999.0));
	main ? (g_iHealSpecial[index] = keyvalues.GetNum("Heal Ability/Health From Specials", 100)) : (g_iHealSpecial2[index] = keyvalues.GetNum("Heal Ability/Health From Specials", g_iHealSpecial[index]));
	main ? (g_iHealSpecial[index] = iSetCellLimit(g_iHealSpecial[index], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iHealSpecial2[index] = iSetCellLimit(g_iHealSpecial2[index], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
	main ? (g_iHealTank[index] = keyvalues.GetNum("Heal Ability/Health From Tanks", 500)) : (g_iHealTank2[index] = keyvalues.GetNum("Heal Ability/Health From Tanks", g_iHealTank[index]));
	main ? (g_iHealTank[index] = iSetCellLimit(g_iHealTank[index], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iHealTank2[index] = iSetCellLimit(g_iHealTank2[index], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
}

void vHealAbility(int client)
{
	int iHealAbility = !g_bTankConfig[g_iTankType[client]] ? g_iHealAbility[g_iTankType[client]] : g_iHealAbility2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iHealAbility == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client) && !g_bHeal[client])
	{
		g_bHeal[client] = true;
		float flHealInterval = !g_bTankConfig[g_iTankType[client]] ? g_flHealInterval[g_iTankType[client]] : g_flHealInterval2[g_iTankType[client]];
		CreateTimer(flHealInterval, tTimerHeal, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

void vHealHit(int client, int owner)
{
	int iHealChance = !g_bTankConfig[g_iTankType[owner]] ? g_iHealChance[g_iTankType[owner]] : g_iHealChance2[g_iTankType[owner]];
	int iHealHit = !g_bTankConfig[g_iTankType[owner]] ? g_iHealHit[g_iTankType[owner]] : g_iHealHit2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (iHealHit == 1 && GetRandomInt(1, iHealChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client))
	{
		SetEntProp(client, Prop_Send, "m_currentReviveCount", g_cvSTFindConVar[3].IntValue - 1);
		SetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
		SDKCall(g_hSDKRevivePlayer, client);
		SetEntityHealth(client, 1);
		SDKCall(g_hSDKHealPlayer, client, 50.0);
	}
}

void vResetHeal(int client)
{
	g_bHeal[client] = false;
}

public Action tTimerHeal(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	int iHealAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iHealAbility[g_iTankType[iTank]] : g_iHealAbility2[g_iTankType[iTank]];
	if (iHealAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bHeal[iTank] = false;
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		int iType;
		int iSpecial = -1;
		float flHealRange = !g_bTankConfig[g_iTankType[iTank]] ? g_flHealRange[g_iTankType[iTank]] : g_flHealRange2[g_iTankType[iTank]];
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
				int iCommonHealth = !g_bTankConfig[g_iTankType[iTank]] ? (iHealth + g_iHealCommon[g_iTankType[iTank]]) : (iHealth + g_iHealCommon2[g_iTankType[iTank]]);
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
					int iSpecialHealth = !g_bTankConfig[g_iTankType[iTank]] ? (iHealth + g_iHealSpecial[g_iTankType[iTank]]) : (iHealth + g_iHealSpecial2[g_iTankType[iTank]]);
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
					int iTankHealth = !g_bTankConfig[g_iTankType[iTank]] ? (iHealth + g_iHealTank[g_iTankType[iTank]]) : (iHealth + g_iHealTank2[g_iTankType[iTank]]);
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
			sTankColors = !g_bTankConfig[g_iTankType[iTank]] ? g_sTankColors[g_iTankType[iTank]] : g_sTankColors2[g_iTankType[iTank]];
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
			SetEntProp(iTank, Prop_Send, "m_iGlowType", 3);
			SetEntProp(iTank, Prop_Send, "m_glowColorOverride", iGetRGBColor(iRed, iGreen, iBlue));
			SetEntProp(iTank, Prop_Send, "m_bFlashing", 0);
		}
	}
	return Plugin_Continue;
}