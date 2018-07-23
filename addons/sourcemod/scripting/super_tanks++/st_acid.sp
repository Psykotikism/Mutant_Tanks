// Super Tanks++: Acid Ability
float g_flAcidRange[ST_MAXTYPES + 1];
float g_flAcidRange2[ST_MAXTYPES + 1];
Handle g_hSDKAcidPlayer;
int g_iAcidAbility[ST_MAXTYPES + 1];
int g_iAcidAbility2[ST_MAXTYPES + 1];
int g_iAcidChance[ST_MAXTYPES + 1];
int g_iAcidChance2[ST_MAXTYPES + 1];
int g_iAcidHit[ST_MAXTYPES + 1];
int g_iAcidHit2[ST_MAXTYPES + 1];
int g_iAcidRock[ST_MAXTYPES + 1];
int g_iAcidRock2[ST_MAXTYPES + 1];

void vAcidSDKCall(Handle gamedata)
{
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CSpitterProjectile_Create");
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hSDKAcidPlayer = EndPrepSDKCall();
	if (g_hSDKAcidPlayer == null)
	{
		PrintToServer("%s Your \"CSpitterProjectile_Create\" signature is outdated.", ST_PREFIX);
	}
}

void vAcidConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iAcidAbility[index] = keyvalues.GetNum("Acid Ability/Ability Enabled", 0)) : (g_iAcidAbility2[index] = keyvalues.GetNum("Acid Ability/Ability Enabled", g_iAcidAbility[index]));
	main ? (g_iAcidAbility[index] = iSetCellLimit(g_iAcidAbility[index], 0, 1)) : (g_iAcidAbility2[index] = iSetCellLimit(g_iAcidAbility2[index], 0, 1));
	main ? (g_iAcidChance[index] = keyvalues.GetNum("Acid Ability/Acid Chance", 4)) : (g_iAcidChance2[index] = keyvalues.GetNum("Acid Ability/Acid Chance", g_iAcidChance[index]));
	main ? (g_iAcidChance[index] = iSetCellLimit(g_iAcidChance[index], 1, 9999999999)) : (g_iAcidChance2[index] = iSetCellLimit(g_iAcidChance2[index], 1, 9999999999));
	main ? (g_iAcidHit[index] = keyvalues.GetNum("Acid Ability/Acid Hit", 0)) : (g_iAcidHit2[index] = keyvalues.GetNum("Acid Ability/Acid Hit", g_iAcidHit[index]));
	main ? (g_iAcidHit[index] = iSetCellLimit(g_iAcidHit[index], 0, 1)) : (g_iAcidHit2[index] = iSetCellLimit(g_iAcidHit2[index], 0, 1));
	main ? (g_flAcidRange[index] = keyvalues.GetFloat("Acid Ability/Acid Range", 150.0)) : (g_flAcidRange2[index] = keyvalues.GetFloat("Acid Ability/Acid Range", g_flAcidRange[index]));
	main ? (g_flAcidRange[index] = flSetFloatLimit(g_flAcidRange[index], 1.0, 9999999999.0)) : (g_flAcidRange2[index] = flSetFloatLimit(g_flAcidRange2[index], 1.0, 9999999999.0));
	main ? (g_iAcidRock[index] = keyvalues.GetNum("Acid Ability/Acid Rock Break", 0)) : (g_iAcidRock2[index] = keyvalues.GetNum("Acid Ability/Acid Rock Break", g_iAcidRock[index]));
	main ? (g_iAcidRock[index] = iSetCellLimit(g_iAcidRock[index], 0, 1)) : (g_iAcidRock2[index] = iSetCellLimit(g_iAcidRock2[index], 0, 1));
}

void vAcidHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iAcidAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iAcidAbility[g_iTankType[owner]] : g_iAcidAbility2[g_iTankType[owner]];
	int iAcidChance = !g_bTankConfig[g_iTankType[owner]] ? g_iAcidChance[g_iTankType[owner]] : g_iAcidChance2[g_iTankType[owner]];
	int iAcidHit = !g_bTankConfig[g_iTankType[owner]] ? g_iAcidHit[g_iTankType[owner]] : g_iAcidHit2[g_iTankType[owner]];
	float flAcidRange = !g_bTankConfig[g_iTankType[owner]] ? g_flAcidRange[g_iTankType[owner]] : g_flAcidRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flAcidRange) || toggle == 2) && ((toggle == 1 && iAcidAbility == 1) || (toggle == 2 && iAcidHit == 1)) && GetRandomInt(1, iAcidChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client))
	{
		if (bIsL4D2Game())
		{
			float flOrigin[3];
			float flAngles[3];
			GetClientAbsOrigin(client, flOrigin);
			GetClientAbsAngles(client, flAngles);
			SDKCall(g_hSDKAcidPlayer, flOrigin, flAngles, flAngles, flAngles, owner, 2.0);
		}
		else
		{
			SDKCall(g_hSDKPukePlayer, client, owner, true);
		}
	}
}

void vAcidRock(int entity, int client)
{
	int iAcidRock = !g_bTankConfig[g_iTankType[client]] ? g_iAcidRock[g_iTankType[client]] : g_iAcidRock2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iAcidRock == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client) && bIsL4D2Game())
	{
		float flOrigin[3];
		float flAngles[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flOrigin);
		flOrigin[2] += 40.0;
		SDKCall(g_hSDKAcidPlayer, flOrigin, flAngles, flAngles, flAngles, client, 2.0);
	}
}