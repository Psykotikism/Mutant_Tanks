// Super Tanks++: Vision Ability
bool g_bVision[MAXPLAYERS + 1];
float g_flVisionDuration[ST_MAXTYPES + 1];
float g_flVisionDuration2[ST_MAXTYPES + 1];
float g_flVisionRange[ST_MAXTYPES + 1];
float g_flVisionRange2[ST_MAXTYPES + 1];
int g_iVisionAbility[ST_MAXTYPES + 1];
int g_iVisionAbility2[ST_MAXTYPES + 1];
int g_iVisionChance[ST_MAXTYPES + 1];
int g_iVisionChance2[ST_MAXTYPES + 1];
int g_iVisionFOV[ST_MAXTYPES + 1];
int g_iVisionFOV2[ST_MAXTYPES + 1];
int g_iVisionHit[ST_MAXTYPES + 1];
int g_iVisionHit2[ST_MAXTYPES + 1];

void vVisionConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iVisionAbility[index] = keyvalues.GetNum("Vision Ability/Ability Enabled", 0)) : (g_iVisionAbility2[index] = keyvalues.GetNum("Vision Ability/Ability Enabled", g_iVisionAbility[index]));
	main ? (g_iVisionAbility[index] = iSetCellLimit(g_iVisionAbility[index], 0, 1)) : (g_iVisionAbility2[index] = iSetCellLimit(g_iVisionAbility2[index], 0, 1));
	main ? (g_iVisionChance[index] = keyvalues.GetNum("Vision Ability/Vision Chance", 4)) : (g_iVisionChance2[index] = keyvalues.GetNum("Vision Ability/Vision Chance", g_iVisionChance[index]));
	main ? (g_iVisionChance[index] = iSetCellLimit(g_iVisionChance[index], 1, 9999999999)) : (g_iVisionChance2[index] = iSetCellLimit(g_iVisionChance2[index], 1, 9999999999));
	main ? (g_flVisionDuration[index] = keyvalues.GetFloat("Vision Ability/Vision Duration", 5.0)) : (g_flVisionDuration2[index] = keyvalues.GetFloat("Vision Ability/Vision Duration", g_flVisionDuration[index]));
	main ? (g_flVisionDuration[index] = flSetFloatLimit(g_flVisionDuration[index], 0.1, 9999999999.0)) : (g_flVisionDuration2[index] = flSetFloatLimit(g_flVisionDuration2[index], 0.1, 9999999999.0));
	main ? (g_iVisionFOV[index] = keyvalues.GetNum("Vision Ability/Vision FOV", 160)) : (g_iVisionFOV2[index] = keyvalues.GetNum("Vision Ability/Vision FOV", g_iVisionFOV[index]));
	main ? (g_iVisionFOV[index] = iSetCellLimit(g_iVisionFOV[index], 1, 160)) : (g_iVisionFOV2[index] = iSetCellLimit(g_iVisionFOV2[index], 1, 160));
	main ? (g_iVisionHit[index] = keyvalues.GetNum("Vision Ability/Vision Hit", 0)) : (g_iVisionHit2[index] = keyvalues.GetNum("Vision Ability/Vision Hit", g_iVisionHit[index]));
	main ? (g_iVisionHit[index] = iSetCellLimit(g_iVisionHit[index], 0, 1)) : (g_iVisionHit2[index] = iSetCellLimit(g_iVisionHit2[index], 0, 1));
	main ? (g_flVisionRange[index] = keyvalues.GetFloat("Vision Ability/Vision Range", 150.0)) : (g_flVisionRange2[index] = keyvalues.GetFloat("Vision Ability/Vision Range", g_flVisionRange[index]));
	main ? (g_flVisionRange[index] = flSetFloatLimit(g_flVisionRange[index], 1.0, 9999999999.0)) : (g_flVisionRange2[index] = flSetFloatLimit(g_flVisionRange2[index], 1.0, 9999999999.0));
}

void vResetVision(int client)
{
	g_bVision[client] = false;
}

void vVisionHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iVisionAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iVisionAbility[g_iTankType[owner]] : g_iVisionAbility2[g_iTankType[owner]];
	int iVisionChance = !g_bTankConfig[g_iTankType[owner]] ? g_iVisionChance[g_iTankType[owner]] : g_iVisionChance2[g_iTankType[owner]];
	int iVisionHit = !g_bTankConfig[g_iTankType[owner]] ? g_iVisionHit[g_iTankType[owner]] : g_iVisionHit2[g_iTankType[owner]];
	float flVisionRange = !g_bTankConfig[g_iTankType[owner]] ? g_flVisionRange[g_iTankType[owner]] : g_flVisionRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flVisionRange) || toggle == 2) && ((toggle == 1 && iVisionAbility == 1) || (toggle == 2 && iVisionHit == 1)) && GetRandomInt(1, iVisionChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && !g_bVision[client])
	{
		g_bVision[client] = true;
		DataPack dpDataPack;
		CreateDataTimer(0.1, tTimerVision, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
		dpDataPack.WriteFloat(GetEngineTime());
	}
}

public Action tTimerVision(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	float flTime = pack.ReadFloat();
	float flVisionDuration = !g_bTankConfig[g_iTankType[iTank]] ? g_flVisionDuration[g_iTankType[iTank]] : g_flVisionDuration2[g_iTankType[iTank]];
	if (iTank == 0 || iSurvivor == 0 || !IsClientInGame(iTank) || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iTank) || !IsPlayerAlive(iSurvivor) || (flTime + flVisionDuration) < GetEngineTime())
	{
		g_bVision[iSurvivor] = false;
		if (bIsSurvivor(iSurvivor))
		{
			SetEntProp(iSurvivor, Prop_Send, "m_iFOV", 90);
			SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", 90);
		}
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		int iFov = !g_bTankConfig[g_iTankType[iTank]] ? g_iVisionFOV[g_iTankType[iTank]] : g_iVisionFOV2[g_iTankType[iTank]];
		SetEntProp(iSurvivor, Prop_Send, "m_iFOV", iFov);
		SetEntProp(iSurvivor, Prop_Send, "m_iDefaultFOV", iFov);
	}
	return Plugin_Continue;
}