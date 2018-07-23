// Super Tanks++: Stun Ability
bool g_bStun[MAXPLAYERS + 1];
float g_flStunDuration[ST_MAXTYPES + 1];
float g_flStunDuration2[ST_MAXTYPES + 1];
float g_flStunRange[ST_MAXTYPES + 1];
float g_flStunRange2[ST_MAXTYPES + 1];
float g_flStunSpeed[ST_MAXTYPES + 1];
float g_flStunSpeed2[ST_MAXTYPES + 1];
int g_iStunAbility[ST_MAXTYPES + 1];
int g_iStunAbility2[ST_MAXTYPES + 1];
int g_iStunChance[ST_MAXTYPES + 1];
int g_iStunChance2[ST_MAXTYPES + 1];
int g_iStunHit[ST_MAXTYPES + 1];
int g_iStunHit2[ST_MAXTYPES + 1];

void vStunConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iStunAbility[index] = keyvalues.GetNum("Stun Ability/Ability Enabled", 0)) : (g_iStunAbility2[index] = keyvalues.GetNum("Stun Ability/Ability Enabled", g_iStunAbility[index]));
	main ? (g_iStunAbility[index] = iSetCellLimit(g_iStunAbility[index], 0, 1)) : (g_iStunAbility2[index] = iSetCellLimit(g_iStunAbility2[index], 0, 1));
	main ? (g_iStunChance[index] = keyvalues.GetNum("Stun Ability/Stun Chance", 4)) : (g_iStunChance2[index] = keyvalues.GetNum("Stun Ability/Stun Chance", g_iStunChance[index]));
	main ? (g_iStunChance[index] = iSetCellLimit(g_iStunChance[index], 1, 9999999999)) : (g_iStunChance2[index] = iSetCellLimit(g_iStunChance2[index], 1, 9999999999));
	main ? (g_flStunDuration[index] = keyvalues.GetFloat("Stun Ability/Stun Duration", 5.0)) : (g_flStunDuration2[index] = keyvalues.GetFloat("Stun Ability/Stun Duration", g_flStunDuration[index]));
	main ? (g_flStunDuration[index] = flSetFloatLimit(g_flStunDuration[index], 0.1, 9999999999.0)) : (g_flStunDuration2[index] = flSetFloatLimit(g_flStunDuration2[index], 0.1, 9999999999.0));
	main ? (g_iStunHit[index] = keyvalues.GetNum("Stun Ability/Stun Hit", 0)) : (g_iStunHit2[index] = keyvalues.GetNum("Stun Ability/Stun Hit", g_iStunHit[index]));
	main ? (g_iStunHit[index] = iSetCellLimit(g_iStunHit[index], 0, 1)) : (g_iStunHit2[index] = iSetCellLimit(g_iStunHit2[index], 0, 1));
	main ? (g_flStunRange[index] = keyvalues.GetFloat("Stun Ability/Stun Range", 150.0)) : (g_flStunRange2[index] = keyvalues.GetFloat("Stun Ability/Stun Range", g_flStunRange[index]));
	main ? (g_flStunRange[index] = flSetFloatLimit(g_flStunRange[index], 1.0, 9999999999.0)) : (g_flStunRange2[index] = flSetFloatLimit(g_flStunRange2[index], 1.0, 9999999999.0));
	main ? (g_flStunSpeed[index] = keyvalues.GetFloat("Stun Ability/Stun Speed", 0.25)) : (g_flStunSpeed2[index] = keyvalues.GetFloat("Stun Ability/Stun Speed", g_flStunSpeed[index]));
	main ? (g_flStunSpeed[index] = flSetFloatLimit(g_flStunSpeed[index], 0.1, 0.9)) : (g_flStunSpeed2[index] = flSetFloatLimit(g_flStunSpeed2[index], 0.1, 0.9));
}

void vStunDeath(int client)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bStun[iSurvivor])
		{
			DataPack dpDataPack;
			CreateDataTimer(0.1, tTimerStopStun, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
			dpDataPack.WriteCell(GetClientUserId(iSurvivor));
			dpDataPack.WriteCell(GetClientUserId(client));
		}
	}
}

void vStunHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iStunAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iStunAbility[g_iTankType[owner]] : g_iStunAbility2[g_iTankType[owner]];
	int iStunChance = !g_bTankConfig[g_iTankType[owner]] ? g_iStunChance[g_iTankType[owner]] : g_iStunChance2[g_iTankType[owner]];
	int iStunHit = !g_bTankConfig[g_iTankType[owner]] ? g_iStunHit[g_iTankType[owner]] : g_iStunHit2[g_iTankType[owner]];
	float flStunRange = !g_bTankConfig[g_iTankType[owner]] ? g_flStunRange[g_iTankType[owner]] : g_flStunRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flStunRange) || toggle == 2) && ((toggle == 1 && iStunAbility == 1) || (toggle == 2 && iStunHit == 1)) && GetRandomInt(1, iStunChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && !g_bStun[client])
	{
		g_bStun[client] = true;
		float flStunSpeed = !g_bTankConfig[g_iTankType[owner]] ? g_flStunSpeed[g_iTankType[owner]] : g_flStunSpeed2[g_iTankType[owner]];
		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", flStunSpeed);
		float flStunDuration = !g_bTankConfig[g_iTankType[owner]] ? g_flStunDuration[g_iTankType[owner]] : g_flStunDuration2[g_iTankType[owner]];
		DataPack dpDataPack;
		CreateDataTimer(flStunDuration, tTimerStopStun, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
	}
}

void vResetStun(int client)
{
	g_bStun[client] = false;
}

public Action tTimerStopStun(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (iTank == 0 || iSurvivor == 0 || !IsClientInGame(iTank) || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iTank) || !IsPlayerAlive(iSurvivor))
	{
		g_bStun[iSurvivor] = false;
		if (bIsSurvivor(iSurvivor))
		{
			SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
		}
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		g_bStun[iSurvivor] = false;
		SetEntPropFloat(iSurvivor, Prop_Send, "m_flLaggedMovementValue", 1.0);
	}
	return Plugin_Continue;
}