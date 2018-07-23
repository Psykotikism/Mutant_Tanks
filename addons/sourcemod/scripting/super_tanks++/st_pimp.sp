// Super Tanks++: Pimp Ability
bool g_bPimp[MAXPLAYERS + 1];
float g_flPimpRange[ST_MAXTYPES + 1];
float g_flPimpRange2[ST_MAXTYPES + 1];
int g_iPimpAbility[ST_MAXTYPES + 1];
int g_iPimpAbility2[ST_MAXTYPES + 1];
int g_iPimpAmount[ST_MAXTYPES + 1];
int g_iPimpAmount2[ST_MAXTYPES + 1];
int g_iPimpChance[ST_MAXTYPES + 1];
int g_iPimpChance2[ST_MAXTYPES + 1];
int g_iPimpCount[MAXPLAYERS + 1];
int g_iPimpDamage[ST_MAXTYPES + 1];
int g_iPimpDamage2[ST_MAXTYPES + 1];
int g_iPimpHit[ST_MAXTYPES + 1];
int g_iPimpHit2[ST_MAXTYPES + 1];

void vPimpConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iPimpAbility[index] = keyvalues.GetNum("Pimp Ability/Ability Enabled", 0)) : (g_iPimpAbility2[index] = keyvalues.GetNum("Pimp Ability/Ability Enabled", g_iPimpAbility[index]));
	main ? (g_iPimpAbility[index] = iSetCellLimit(g_iPimpAbility[index], 0, 1)) : (g_iPimpAbility2[index] = iSetCellLimit(g_iPimpAbility2[index], 0, 1));
	main ? (g_iPimpAmount[index] = keyvalues.GetNum("Pimp Ability/Pimp Amount", 5)) : (g_iPimpAmount2[index] = keyvalues.GetNum("Pimp Ability/Pimp Amount", g_iPimpAmount[index]));
	main ? (g_iPimpAmount[index] = iSetCellLimit(g_iPimpAmount[index], 1, 9999999999)) : (g_iPimpAmount2[index] = iSetCellLimit(g_iPimpAmount2[index], 1, 9999999999));
	main ? (g_iPimpChance[index] = keyvalues.GetNum("Pimp Ability/Pimp Chance", 4)) : (g_iPimpChance2[index] = keyvalues.GetNum("Pimp Ability/Pimp Chance", g_iPimpChance[index]));
	main ? (g_iPimpChance[index] = iSetCellLimit(g_iPimpChance[index], 1, 9999999999)) : (g_iPimpChance2[index] = iSetCellLimit(g_iPimpChance2[index], 1, 9999999999));
	main ? (g_iPimpDamage[index] = keyvalues.GetNum("Pimp Ability/Pimp Damage", 1)) : (g_iPimpDamage2[index] = keyvalues.GetNum("Pimp Ability/Pimp Damage", g_iPimpDamage[index]));
	main ? (g_iPimpDamage[index] = iSetCellLimit(g_iPimpDamage[index], 1, 9999999999)) : (g_iPimpDamage2[index] = iSetCellLimit(g_iPimpDamage2[index], 1, 9999999999));
	main ? (g_iPimpHit[index] = keyvalues.GetNum("Pimp Ability/Pimp Hit", 0)) : (g_iPimpHit2[index] = keyvalues.GetNum("Pimp Ability/Pimp Hit", g_iPimpHit[index]));
	main ? (g_iPimpHit[index] = iSetCellLimit(g_iPimpHit[index], 0, 1)) : (g_iPimpHit2[index] = iSetCellLimit(g_iPimpHit2[index], 0, 1));
	main ? (g_flPimpRange[index] = keyvalues.GetFloat("Pimp Ability/Pimp Range", 150.0)) : (g_flPimpRange2[index] = keyvalues.GetFloat("Pimp Ability/Pimp Range", g_flPimpRange[index]));
	main ? (g_flPimpRange[index] = flSetFloatLimit(g_flPimpRange[index], 1.0, 9999999999.0)) : (g_flPimpRange2[index] = flSetFloatLimit(g_flPimpRange2[index], 1.0, 9999999999.0));
}

void vPimpHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iPimpAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iPimpAbility[g_iTankType[owner]] : g_iPimpAbility2[g_iTankType[owner]];
	int iPimpChance = !g_bTankConfig[g_iTankType[owner]] ? g_iPimpChance[g_iTankType[owner]] : g_iPimpChance2[g_iTankType[owner]];
	int iPimpHit = !g_bTankConfig[g_iTankType[owner]] ? g_iPimpHit[g_iTankType[owner]] : g_iPimpHit2[g_iTankType[owner]];
	float flPimpRange = !g_bTankConfig[g_iTankType[owner]] ? g_flPimpRange[g_iTankType[owner]] : g_flPimpRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flPimpRange) || toggle == 2) && ((toggle == 1 && iPimpAbility == 1) || (toggle == 2 && iPimpHit == 1)) && GetRandomInt(1, iPimpChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && !g_bPimp[client])
	{
		g_bPimp[client] = true;
		DataPack dpDataPack;
		CreateDataTimer(0.5, tTimerPimp, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
	}
}

void vResetPimp(int client)
{
	g_iPimpCount[client] = 0;
}

public Action tTimerPimp(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iPimpAmount = !g_bTankConfig[g_iTankType[iTank]] ? g_iPimpAmount[g_iTankType[iTank]] : g_iPimpAmount2[g_iTankType[iTank]];
	int iPimpDamage = !g_bTankConfig[g_iTankType[iTank]] ? g_iPimpDamage[g_iTankType[iTank]] : g_iPimpDamage2[g_iTankType[iTank]];
	if (iTank == 0 || iSurvivor == 0 || !IsClientInGame(iTank) || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iTank) || !IsPlayerAlive(iSurvivor) || g_iPimpCount[iSurvivor] >= iPimpAmount)
	{
		g_bPimp[iSurvivor] = false;
		g_iPimpCount[iSurvivor] = 0;
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor) && g_iPimpCount[iSurvivor] < iPimpAmount)
	{
		SlapPlayer(iSurvivor, iPimpDamage, true);
		g_iPimpCount[iSurvivor]++;
	}
	return Plugin_Continue;
}