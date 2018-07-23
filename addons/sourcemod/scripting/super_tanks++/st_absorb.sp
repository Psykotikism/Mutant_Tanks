// Super Tanks++: Absorb Ability
bool g_bAbsorb[MAXPLAYERS + 1];
float g_flAbsorbDuration[ST_MAXTYPES + 1];
float g_flAbsorbDuration2[ST_MAXTYPES + 1];
int g_iAbsorbAbility[ST_MAXTYPES + 1];
int g_iAbsorbAbility2[ST_MAXTYPES + 1];
int g_iAbsorbChance[ST_MAXTYPES + 1];
int g_iAbsorbChance2[ST_MAXTYPES + 1];

void vAbsorbConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iAbsorbAbility[index] = keyvalues.GetNum("Absorb Ability/Ability Enabled", 0)) : (g_iAbsorbAbility2[index] = keyvalues.GetNum("Absorb Ability/Ability Enabled", g_iAbsorbAbility[index]));
	main ? (g_iAbsorbAbility[index] = iSetCellLimit(g_iAbsorbAbility[index], 0, 1)) : (g_iAbsorbAbility2[index] = iSetCellLimit(g_iAbsorbAbility2[index], 0, 1));
	main ? (g_iAbsorbChance[index] = keyvalues.GetNum("Absorb Ability/Absorb Chance", 4)) : (g_iAbsorbChance2[index] = keyvalues.GetNum("Absorb Ability/Absorb Chance", g_iAbsorbChance[index]));
	main ? (g_iAbsorbChance[index] = iSetCellLimit(g_iAbsorbChance[index], 1, 9999999999)) : (g_iAbsorbChance2[index] = iSetCellLimit(g_iAbsorbChance2[index], 1, 9999999999));
	main ? (g_flAbsorbDuration[index] = keyvalues.GetFloat("Absorb Ability/Absorb Duration", 5.0)) : (g_flAbsorbDuration2[index] = keyvalues.GetFloat("Absorb Ability/Absorb Duration", g_flAbsorbDuration[index]));
	main ? (g_flAbsorbDuration[index] = flSetFloatLimit(g_flAbsorbDuration[index], 0.1, 9999999999.0)) : (g_flAbsorbDuration2[index] = flSetFloatLimit(g_flAbsorbDuration2[index], 0.1, 9999999999.0));
}

void vAbsorbAbility(int client)
{
	int iAbsorbAbility = !g_bTankConfig[g_iTankType[client]] ? g_iAbsorbAbility[g_iTankType[client]] : g_iAbsorbAbility2[g_iTankType[client]];
	int iAbsorbChance = !g_bTankConfig[g_iTankType[client]] ? g_iAbsorbChance[g_iTankType[client]] : g_iAbsorbChance2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iAbsorbAbility == 1 && GetRandomInt(1, iAbsorbChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client) && !g_bAbsorb[client])
	{
		g_bAbsorb[client] = true;
		float flAbsorbDuration = !g_bTankConfig[g_iTankType[client]] ? g_flAbsorbDuration[g_iTankType[client]] : g_flAbsorbDuration2[g_iTankType[client]];
		CreateTimer(flAbsorbDuration, tTimerStopAbsorb, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vResetAbsorb(int client)
{
	g_bAbsorb[client] = false;
}

public Action tTimerStopAbsorb(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bAbsorb[iTank] = false;
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		g_bAbsorb[iTank] = false;
	}
	return Plugin_Continue;
}