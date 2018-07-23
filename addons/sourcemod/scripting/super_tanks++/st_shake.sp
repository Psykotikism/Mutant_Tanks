// Super Tanks++: Shake Ability
bool g_bShake[MAXPLAYERS + 1];
float g_flShakeDuration[ST_MAXTYPES + 1];
float g_flShakeDuration2[ST_MAXTYPES + 1];
float g_flShakeRange[ST_MAXTYPES + 1];
float g_flShakeRange2[ST_MAXTYPES + 1];
int g_iShakeAbility[ST_MAXTYPES + 1];
int g_iShakeAbility2[ST_MAXTYPES + 1];
int g_iShakeChance[ST_MAXTYPES + 1];
int g_iShakeChance2[ST_MAXTYPES + 1];
int g_iShakeHit[ST_MAXTYPES + 1];
int g_iShakeHit2[ST_MAXTYPES + 1];

void vShakeConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iShakeAbility[index] = keyvalues.GetNum("Shake Ability/Ability Enabled", 0)) : (g_iShakeAbility2[index] = keyvalues.GetNum("Shake Ability/Ability Enabled", g_iShakeAbility[index]));
	main ? (g_iShakeAbility[index] = iSetCellLimit(g_iShakeAbility[index], 0, 1)) : (g_iShakeAbility2[index] = iSetCellLimit(g_iShakeAbility2[index], 0, 1));
	main ? (g_iShakeChance[index] = keyvalues.GetNum("Shake Ability/Shake Chance", 4)) : (g_iShakeChance2[index] = keyvalues.GetNum("Shake Ability/Shake Chance", g_iShakeChance[index]));
	main ? (g_iShakeChance[index] = iSetCellLimit(g_iShakeChance[index], 1, 9999999999)) : (g_iShakeChance2[index] = iSetCellLimit(g_iShakeChance2[index], 1, 9999999999));
	main ? (g_flShakeDuration[index] = keyvalues.GetFloat("Shake Ability/Shake Duration", 5.0)) : (g_flShakeDuration2[index] = keyvalues.GetFloat("Shake Ability/Shake Duration", g_flShakeDuration[index]));
	main ? (g_flShakeDuration[index] = flSetFloatLimit(g_flShakeDuration[index], 0.1, 9999999999.0)) : (g_flShakeDuration2[index] = flSetFloatLimit(g_flShakeDuration2[index], 0.1, 9999999999.0));
	main ? (g_iShakeHit[index] = keyvalues.GetNum("Shake Ability/Shake Hit", 0)) : (g_iShakeHit2[index] = keyvalues.GetNum("Shake Ability/Shake Hit", g_iShakeHit[index]));
	main ? (g_iShakeHit[index] = iSetCellLimit(g_iShakeHit[index], 0, 1)) : (g_iShakeHit2[index] = iSetCellLimit(g_iShakeHit2[index], 0, 1));
	main ? (g_flShakeRange[index] = keyvalues.GetFloat("Shake Ability/Shake Range", 150.0)) : (g_flShakeRange2[index] = keyvalues.GetFloat("Shake Ability/Shake Range", g_flShakeRange[index]));
	main ? (g_flShakeRange[index] = flSetFloatLimit(g_flShakeRange[index], 1.0, 9999999999.0)) : (g_flShakeRange2[index] = flSetFloatLimit(g_flShakeRange2[index], 1.0, 9999999999.0));
}

void vShakeHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iShakeAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iShakeAbility[g_iTankType[owner]] : g_iShakeAbility2[g_iTankType[owner]];
	int iShakeChance = !g_bTankConfig[g_iTankType[owner]] ? g_iShakeChance[g_iTankType[owner]] : g_iShakeChance2[g_iTankType[owner]];
	int iShakeHit = !g_bTankConfig[g_iTankType[owner]] ? g_iShakeHit[g_iTankType[owner]] : g_iShakeHit2[g_iTankType[owner]];
	float flShakeRange = !g_bTankConfig[g_iTankType[owner]] ? g_flShakeRange[g_iTankType[owner]] : g_flShakeRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flShakeRange) || toggle == 2) && ((toggle == 1 && iShakeAbility == 1) || (toggle == 2 && iShakeHit == 1)) && GetRandomInt(1, iShakeChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && !g_bShake[client])
	{
		g_bShake[client] = true;
		DataPack dpDataPack;
		CreateDataTimer(1.0, tTimerShake, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
		dpDataPack.WriteFloat(GetEngineTime());
	}
}

void vResetShake(int client)
{
	g_bShake[client] = false;
}

public Action tTimerShake(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	float flTime = pack.ReadFloat();
	float flShakeDuration = !g_bTankConfig[g_iTankType[iTank]] ? g_flShakeDuration[g_iTankType[iTank]] : g_flShakeDuration2[g_iTankType[iTank]];
	if (iTank == 0 || iSurvivor == 0 || !IsClientInGame(iTank) || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iTank) || !IsPlayerAlive(iSurvivor) || (flTime + flShakeDuration) < GetEngineTime())
	{
		g_bShake[iSurvivor] = false;
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		Handle hShakeTarget = StartMessageOne("Shake", iSurvivor);
		if (hShakeTarget != null)
		{
			BfWrite bfWrite = UserMessageToBfWrite(hShakeTarget);
			bfWrite.WriteByte(0);
			bfWrite.WriteFloat(16.0);
			bfWrite.WriteFloat(0.5);
			bfWrite.WriteFloat(5.0);
			EndMessage();
		}
	}
	return Plugin_Continue;
}