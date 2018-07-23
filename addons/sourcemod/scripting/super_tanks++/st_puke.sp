// Super Tanks++: Puke Ability
float g_flPukeRange[ST_MAXTYPES + 1];
float g_flPukeRange2[ST_MAXTYPES + 1];
int g_iPukeAbility[ST_MAXTYPES + 1];
int g_iPukeAbility2[ST_MAXTYPES + 1];
int g_iPukeChance[ST_MAXTYPES + 1];
int g_iPukeChance2[ST_MAXTYPES + 1];
int g_iPukeHit[ST_MAXTYPES + 1];
int g_iPukeHit2[ST_MAXTYPES + 1];

void vPukeSDKCall(Handle gamedata)
{
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDKPukePlayer = EndPrepSDKCall();
	if (g_hSDKPukePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnVomitedUpon\" signature is outdated.", ST_PREFIX);
	}
}

void vPukeConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iPukeAbility[index] = keyvalues.GetNum("Puke Ability/Ability Enabled", 0)) : (g_iPukeAbility2[index] = keyvalues.GetNum("Puke Ability/Ability Enabled", g_iPukeAbility[index]));
	main ? (g_iPukeAbility[index] = iSetCellLimit(g_iPukeAbility[index], 0, 1)) : (g_iPukeAbility2[index] = iSetCellLimit(g_iPukeAbility2[index], 0, 1));
	main ? (g_iPukeChance[index] = keyvalues.GetNum("Puke Ability/Puke Chance", 4)) : (g_iPukeChance2[index] = keyvalues.GetNum("Puke Ability/Puke Chance", g_iPukeChance[index]));
	main ? (g_iPukeChance[index] = iSetCellLimit(g_iPukeChance[index], 1, 9999999999)) : (g_iPukeChance2[index] = iSetCellLimit(g_iPukeChance2[index], 1, 9999999999));
	main ? (g_iPukeHit[index] = keyvalues.GetNum("Puke Ability/Puke Hit", 0)) : (g_iPukeHit2[index] = keyvalues.GetNum("Puke Ability/Puke Hit", g_iPukeHit[index]));
	main ? (g_iPukeHit[index] = iSetCellLimit(g_iPukeHit[index], 0, 1)) : (g_iPukeHit2[index] = iSetCellLimit(g_iPukeHit2[index], 0, 1));
	main ? (g_flPukeRange[index] = keyvalues.GetFloat("Puke Ability/Puke Range", 150.0)) : (g_flPukeRange2[index] = keyvalues.GetFloat("Puke Ability/Puke Range", g_flPukeRange[index]));
	main ? (g_flPukeRange[index] = flSetFloatLimit(g_flPukeRange[index], 1.0, 9999999999.0)) : (g_flPukeRange2[index] = flSetFloatLimit(g_flPukeRange2[index], 1.0, 9999999999.0));
}

void vPukeHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iPukeAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iPukeAbility[g_iTankType[owner]] : g_iPukeAbility2[g_iTankType[owner]];
	int iPukeChance = !g_bTankConfig[g_iTankType[owner]] ? g_iPukeChance[g_iTankType[owner]] : g_iPukeChance2[g_iTankType[owner]];
	int iPukeHit = !g_bTankConfig[g_iTankType[owner]] ? g_iPukeHit[g_iTankType[owner]] : g_iPukeHit2[g_iTankType[owner]];
	float flPukeRange = !g_bTankConfig[g_iTankType[owner]] ? g_flPukeRange[g_iTankType[owner]] : g_flPukeRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flPukeRange) || toggle == 2) && ((toggle == 1 && iPukeAbility == 1) || (toggle == 2 && iPukeHit == 1)) && GetRandomInt(1, iPukeChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client))
	{
		SDKCall(g_hSDKPukePlayer, client, owner, true);
	}
}