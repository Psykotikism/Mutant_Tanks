// Super Tanks++: Regen Ability
bool g_bRegen[MAXPLAYERS + 1];
float g_flRegenInterval[ST_MAXTYPES + 1];
float g_flRegenInterval2[ST_MAXTYPES + 1];
int g_iRegenAbility[ST_MAXTYPES + 1];
int g_iRegenAbility2[ST_MAXTYPES + 1];
int g_iRegenHealth[ST_MAXTYPES + 1];
int g_iRegenHealth2[ST_MAXTYPES + 1];

void vRegenConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iRegenAbility[index] = keyvalues.GetNum("Regen Ability/Ability Enabled", 0)) : (g_iRegenAbility2[index] = keyvalues.GetNum("Regen Ability/Ability Enabled", g_iRegenAbility[index]));
	main ? (g_iRegenAbility[index] = iSetCellLimit(g_iRegenAbility[index], 0, 1)) : (g_iRegenAbility2[index] = iSetCellLimit(g_iRegenAbility2[index], 0, 1));
	main ? (g_iRegenHealth[index] = keyvalues.GetNum("Regen Ability/Regen Health", 1)) : (g_iRegenHealth2[index] = keyvalues.GetNum("Regen Ability/Regen Healtherate", g_iRegenHealth[index]));
	main ? (g_iRegenHealth[index] = iSetCellLimit(g_iRegenHealth[index], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iRegenHealth2[index] = iSetCellLimit(g_iRegenHealth2[index], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
	main ? (g_flRegenInterval[index] = keyvalues.GetFloat("Regen Ability/Regen Interval", 1.0)) : (g_flRegenInterval2[index] = keyvalues.GetFloat("Regen Ability/Regen Duration", g_flRegenInterval[index]));
	main ? (g_flRegenInterval[index] = flSetFloatLimit(g_flRegenInterval[index], 0.1, 9999999999.0)) : (g_flRegenInterval2[index] = flSetFloatLimit(g_flRegenInterval2[index], 0.1, 9999999999.0));
}

void vRegenAbility(int client)
{
	int iRegenAbility = !g_bTankConfig[g_iTankType[client]] ? g_iRegenAbility[g_iTankType[client]] : g_iRegenAbility2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iRegenAbility == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client) && !g_bRegen[client])
	{
		g_bRegen[client] = true;
		float flRegenInterval = !g_bTankConfig[g_iTankType[client]] ? g_flRegenInterval[g_iTankType[client]] : g_flRegenInterval2[g_iTankType[client]];
		CreateTimer(flRegenInterval, tTimerRegen, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

void vResetRegen(int client)
{
	g_bRegen[client] = false;
}

public Action tTimerRegen(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bRegen[iTank] = false;
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		int iHealth = GetClientHealth(iTank);
		int iRegenHealth = !g_bTankConfig[g_iTankType[iTank]] ? (iHealth + g_iRegenHealth[g_iTankType[iTank]]) : (iHealth + g_iRegenHealth2[g_iTankType[iTank]]);
		int iExtraHealth = (iRegenHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iRegenHealth;
		int iExtraHealth2 = (iRegenHealth < iHealth) ? 1 : iRegenHealth;
		int iRealHealth = (iRegenHealth >= 0) ? iExtraHealth : iExtraHealth2;
		SetEntityHealth(iTank, iRealHealth);
	}
	return Plugin_Continue;
}