// Super Tanks++: Fling Ability
float g_flFlingRange[ST_MAXTYPES + 1];
float g_flFlingRange2[ST_MAXTYPES + 1];
Handle g_hSDKFlingPlayer;
int g_iFlingAbility[ST_MAXTYPES + 1];
int g_iFlingAbility2[ST_MAXTYPES + 1];
int g_iFlingChance[ST_MAXTYPES + 1];
int g_iFlingChance2[ST_MAXTYPES + 1];
int g_iFlingHit[ST_MAXTYPES + 1];
int g_iFlingHit2[ST_MAXTYPES + 1];

void vFlingSDKCall(Handle gamedata)
{
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTerrorPlayer_Fling");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	g_hSDKFlingPlayer = EndPrepSDKCall();
	if (g_hSDKFlingPlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_Fling\" signature is outdated.", ST_PREFIX);
	}
}

void vFlingConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iFlingAbility[index] = keyvalues.GetNum("Fling Ability/Ability Enabled", 0)) : (g_iFlingAbility2[index] = keyvalues.GetNum("Fling Ability/Ability Enabled", g_iFlingAbility[index]));
	main ? (g_iFlingAbility[index] = iSetCellLimit(g_iFlingAbility[index], 0, 1)) : (g_iFlingAbility2[index] = iSetCellLimit(g_iFlingAbility2[index], 0, 1));
	main ? (g_iFlingChance[index] = keyvalues.GetNum("Fling Ability/Fling Chance", 4)) : (g_iFlingChance2[index] = keyvalues.GetNum("Fling Ability/Fling Chance", g_iFlingChance[index]));
	main ? (g_iFlingChance[index] = iSetCellLimit(g_iFlingChance[index], 1, 9999999999)) : (g_iFlingChance2[index] = iSetCellLimit(g_iFlingChance2[index], 1, 9999999999));
	main ? (g_iFlingHit[index] = keyvalues.GetNum("Fling Ability/Fling Hit", 0)) : (g_iFlingHit2[index] = keyvalues.GetNum("Fling Ability/Fling Hit", g_iFlingHit[index]));
	main ? (g_iFlingHit[index] = iSetCellLimit(g_iFlingHit[index], 0, 1)) : (g_iFlingHit2[index] = iSetCellLimit(g_iFlingHit2[index], 0, 1));
	main ? (g_flFlingRange[index] = keyvalues.GetFloat("Fling Ability/Fling Range", 150.0)) : (g_flFlingRange2[index] = keyvalues.GetFloat("Fling Ability/Fling Range", g_flFlingRange[index]));
	main ? (g_flFlingRange[index] = flSetFloatLimit(g_flFlingRange[index], 1.0, 9999999999.0)) : (g_flFlingRange2[index] = flSetFloatLimit(g_flFlingRange2[index], 1.0, 9999999999.0));
}

void vFlingHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iFlingAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iFlingAbility[g_iTankType[owner]] : g_iFlingAbility2[g_iTankType[owner]];
	int iFlingChance = !g_bTankConfig[g_iTankType[owner]] ? g_iFlingChance[g_iTankType[owner]] : g_iFlingChance2[g_iTankType[owner]];
	int iFlingHit = !g_bTankConfig[g_iTankType[owner]] ? g_iFlingHit[g_iTankType[owner]] : g_iFlingHit2[g_iTankType[owner]];
	float flFlingRange = !g_bTankConfig[g_iTankType[owner]] ? g_flFlingRange[g_iTankType[owner]] : g_flFlingRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flFlingRange) || toggle == 2) && ((toggle == 1 && iFlingAbility == 1) || (toggle == 2 && iFlingHit == 1)) && GetRandomInt(1, iFlingChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client))
	{
		if (bIsL4D2Game())
		{
			float flTpos[3];
			float flSpos[3];
			float flDistance[3];
			float flRatio[3];
			float flAddVel[3];
			float flTvec[3];
			GetClientAbsOrigin(client, flTpos);
			GetClientAbsOrigin(owner, flSpos);
			flDistance[0] = (flSpos[0] - flTpos[0]);
			flDistance[1] = (flSpos[1] - flTpos[1]);
			flDistance[2] = (flSpos[2] - flTpos[2]);
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", flTvec);
			flRatio[0] =  FloatDiv(flDistance[0], SquareRoot(flDistance[1] * flDistance[1] + flDistance[0] * flDistance[0]));
			flRatio[1] =  FloatDiv(flDistance[1], SquareRoot(flDistance[1] * flDistance[1] + flDistance[0] * flDistance[0]));
			flAddVel[0] = FloatMul(flRatio[0] * -1, 500.0);
			flAddVel[1] = FloatMul(flRatio[1] * -1, 500.0);
			flAddVel[2] = 500.0;
			SDKCall(g_hSDKFlingPlayer, client, flAddVel, 76, owner, 7.0);
		}
		else
		{
			SDKCall(g_hSDKPukePlayer, client, owner, true);
		}
	}
}