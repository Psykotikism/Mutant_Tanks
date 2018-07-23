// Super Tanks++: Invert Ability
bool g_bInvert[MAXPLAYERS + 1];
float g_flInvertDuration[ST_MAXTYPES + 1];
float g_flInvertDuration2[ST_MAXTYPES + 1];
float g_flInvertRange[ST_MAXTYPES + 1];
float g_flInvertRange2[ST_MAXTYPES + 1];
int g_iInvertAbility[ST_MAXTYPES + 1];
int g_iInvertAbility2[ST_MAXTYPES + 1];
int g_iInvertChance[ST_MAXTYPES + 1];
int g_iInvertChance2[ST_MAXTYPES + 1];
int g_iInvertHit[ST_MAXTYPES + 1];
int g_iInvertHit2[ST_MAXTYPES + 1];

void vInvertConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iInvertAbility[index] = keyvalues.GetNum("Invert Ability/Ability Enabled", 0)) : (g_iInvertAbility2[index] = keyvalues.GetNum("Invert Ability/Ability Enabled", g_iInvertAbility[index]));
	main ? (g_iInvertAbility[index] = iSetCellLimit(g_iInvertAbility[index], 0, 1)) : (g_iInvertAbility2[index] = iSetCellLimit(g_iInvertAbility2[index], 0, 1));
	main ? (g_iInvertChance[index] = keyvalues.GetNum("Invert Ability/Invert Chance", 4)) : (g_iInvertChance2[index] = keyvalues.GetNum("Invert Ability/Invert Chance", g_iInvertChance[index]));
	main ? (g_iInvertChance[index] = iSetCellLimit(g_iInvertChance[index], 1, 9999999999)) : (g_iInvertChance2[index] = iSetCellLimit(g_iInvertChance2[index], 1, 9999999999));
	main ? (g_flInvertDuration[index] = keyvalues.GetFloat("Invert Ability/Invert Duration", 5.0)) : (g_flInvertDuration2[index] = keyvalues.GetFloat("Invert Ability/Invert Duration", g_flInvertDuration[index]));
	main ? (g_flInvertDuration[index] = flSetFloatLimit(g_flInvertDuration[index], 0.1, 9999999999.0)) : (g_flInvertDuration2[index] = flSetFloatLimit(g_flInvertDuration2[index], 0.1, 9999999999.0));
	main ? (g_iInvertHit[index] = keyvalues.GetNum("Invert Ability/Invert Hit", 0)) : (g_iInvertHit2[index] = keyvalues.GetNum("Invert Ability/Invert Hit", g_iInvertHit[index]));
	main ? (g_iInvertHit[index] = iSetCellLimit(g_iInvertHit[index], 0, 1)) : (g_iInvertHit2[index] = iSetCellLimit(g_iInvertHit2[index], 0, 1));
	main ? (g_flInvertRange[index] = keyvalues.GetFloat("Invert Ability/Invert Range", 150.0)) : (g_flInvertRange2[index] = keyvalues.GetFloat("Invert Ability/Invert Range", g_flInvertRange[index]));
	main ? (g_flInvertRange[index] = flSetFloatLimit(g_flInvertRange[index], 1.0, 9999999999.0)) : (g_flInvertRange2[index] = flSetFloatLimit(g_flInvertRange2[index], 1.0, 9999999999.0));
}

void vInvertDeath()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bInvert[iSurvivor])
		{
			g_bInvert[iSurvivor] = false;
		}
	}
}

void vInvertHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iInvertAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iInvertAbility[g_iTankType[owner]] : g_iInvertAbility2[g_iTankType[owner]];
	int iInvertChance = !g_bTankConfig[g_iTankType[owner]] ? g_iInvertChance[g_iTankType[owner]] : g_iInvertChance2[g_iTankType[owner]];
	int iInvertHit = !g_bTankConfig[g_iTankType[owner]] ? g_iInvertHit[g_iTankType[owner]] : g_iInvertHit2[g_iTankType[owner]];
	float flInvertRange = !g_bTankConfig[g_iTankType[owner]] ? g_flInvertRange[g_iTankType[owner]] : g_flInvertRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flInvertRange) || toggle == 2) && ((toggle == 1 && iInvertAbility == 1) || (toggle == 2 && iInvertHit == 1)) && GetRandomInt(1, iInvertChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && !g_bInvert[client])
	{
		g_bInvert[client] = true;
		float flInvertDuration = !g_bTankConfig[g_iTankType[owner]] ? g_flInvertDuration[g_iTankType[owner]] : g_flInvertDuration2[g_iTankType[owner]];
		CreateTimer(flInvertDuration, tTimerStopInvert, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vResetInvert(int client)
{
	g_bInvert[client] = false;
}

public Action tTimerStopInvert(Handle timer, any userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (iSurvivor == 0 || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iSurvivor))
	{
		g_bInvert[iSurvivor] = false;
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		g_bInvert[iSurvivor] = false;
	}
	return Plugin_Continue;
}