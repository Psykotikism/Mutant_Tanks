// Super Tanks++: Shove Ability
bool g_bShove[MAXPLAYERS + 1];
float g_flShoveDuration[ST_MAXTYPES + 1];
float g_flShoveDuration2[ST_MAXTYPES + 1];
float g_flShoveRange[ST_MAXTYPES + 1];
float g_flShoveRange2[ST_MAXTYPES + 1];
Handle g_hSDKShovePlayer;
int g_iShoveAbility[ST_MAXTYPES + 1];
int g_iShoveAbility2[ST_MAXTYPES + 1];
int g_iShoveChance[ST_MAXTYPES + 1];
int g_iShoveChance2[ST_MAXTYPES + 1];
int g_iShoveHit[ST_MAXTYPES + 1];
int g_iShoveHit2[ST_MAXTYPES + 1];

void vShoveSDKCall(Handle gamedata)
{
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTerrorPlayer_OnStaggered");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	g_hSDKShovePlayer = EndPrepSDKCall();
	if (g_hSDKShovePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnStaggered\" signature is outdated.", ST_PREFIX);
	}
}

void vShoveConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iShoveAbility[index] = keyvalues.GetNum("Shove Ability/Ability Enabled", 0)) : (g_iShoveAbility2[index] = keyvalues.GetNum("Shove Ability/Ability Enabled", g_iShoveAbility[index]));
	main ? (g_iShoveAbility[index] = iSetCellLimit(g_iShoveAbility[index], 0, 1)) : (g_iShoveAbility2[index] = iSetCellLimit(g_iShoveAbility2[index], 0, 1));
	main ? (g_iShoveChance[index] = keyvalues.GetNum("Shove Ability/Shove Chance", 4)) : (g_iShoveChance2[index] = keyvalues.GetNum("Shove Ability/Shove Chance", g_iShoveChance[index]));
	main ? (g_iShoveChance[index] = iSetCellLimit(g_iShoveChance[index], 1, 9999999999)) : (g_iShoveChance2[index] = iSetCellLimit(g_iShoveChance2[index], 1, 9999999999));
	main ? (g_flShoveDuration[index] = keyvalues.GetFloat("Shove Ability/Shove Duration", 5.0)) : (g_flShoveDuration2[index] = keyvalues.GetFloat("Shove Ability/Shove Duration", g_flShoveDuration[index]));
	main ? (g_flShoveDuration[index] = flSetFloatLimit(g_flShoveDuration[index], 0.1, 9999999999.0)) : (g_flShoveDuration2[index] = flSetFloatLimit(g_flShoveDuration2[index], 0.1, 9999999999.0));
	main ? (g_iShoveHit[index] = keyvalues.GetNum("Shove Ability/Shove Hit", 0)) : (g_iShoveHit2[index] = keyvalues.GetNum("Shove Ability/Shove Hit", g_iShoveHit[index]));
	main ? (g_iShoveHit[index] = iSetCellLimit(g_iShoveHit[index], 0, 1)) : (g_iShoveHit2[index] = iSetCellLimit(g_iShoveHit2[index], 0, 1));
	main ? (g_flShoveRange[index] = keyvalues.GetFloat("Shove Ability/Shove Range", 150.0)) : (g_flShoveRange2[index] = keyvalues.GetFloat("Shove Ability/Shove Range", g_flShoveRange[index]));
	main ? (g_flShoveRange[index] = flSetFloatLimit(g_flShoveRange[index], 1.0, 9999999999.0)) : (g_flShoveRange2[index] = flSetFloatLimit(g_flShoveRange2[index], 1.0, 9999999999.0));
}

void vShoveHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iShoveAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iShoveAbility[g_iTankType[owner]] : g_iShoveAbility2[g_iTankType[owner]];
	int iShoveChance = !g_bTankConfig[g_iTankType[owner]] ? g_iShoveChance[g_iTankType[owner]] : g_iShoveChance2[g_iTankType[owner]];
	int iShoveHit = !g_bTankConfig[g_iTankType[owner]] ? g_iShoveHit[g_iTankType[owner]] : g_iShoveHit2[g_iTankType[owner]];
	float flShoveRange = !g_bTankConfig[g_iTankType[owner]] ? g_flShoveRange[g_iTankType[owner]] : g_flShoveRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flShoveRange) || toggle == 2) && ((toggle == 1 && iShoveAbility == 1) || (toggle == 2 && iShoveHit == 1)) && GetRandomInt(1, iShoveChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && !g_bShove[client])
	{
		g_bShove[client] = true;
		DataPack dpDataPack;
		CreateDataTimer(1.0, tTimerShove, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
		dpDataPack.WriteFloat(GetEngineTime());
	}
}

void vResetShove(int client)
{
	g_bShove[client] = false;
}

public Action tTimerShove(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	float flTime = pack.ReadFloat();
	float flShoveDuration = !g_bTankConfig[g_iTankType[iTank]] ? g_flShoveDuration[g_iTankType[iTank]] : g_flShoveDuration2[g_iTankType[iTank]];
	if (iTank == 0 || iSurvivor == 0 || !IsClientInGame(iTank) || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iTank) || !IsPlayerAlive(iSurvivor) || (flTime + flShoveDuration) < GetEngineTime())
	{
		g_bShove[iSurvivor] = false;
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		float flOrigin[3];
		GetClientAbsOrigin(iSurvivor, flOrigin);
		SDKCall(g_hSDKShovePlayer, iSurvivor, iSurvivor, flOrigin);
	}
	return Plugin_Continue;
}