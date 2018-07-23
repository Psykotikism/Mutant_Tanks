// Super Tanks++: Jump Ability
int g_iJumpAbility[ST_MAXTYPES + 1];
int g_iJumpAbility2[ST_MAXTYPES + 1];
int g_iJumpChance[ST_MAXTYPES + 1];
int g_iJumpChance2[ST_MAXTYPES + 1];

void vJumpConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iJumpAbility[index] = keyvalues.GetNum("Jump Ability/Ability Enabled", 0)) : (g_iJumpAbility2[index] = keyvalues.GetNum("Jump Ability/Ability Enabled", g_iJumpAbility[index]));
	main ? (g_iJumpAbility[index] = iSetCellLimit(g_iJumpAbility[index], 0, 1)) : (g_iJumpAbility2[index] = iSetCellLimit(g_iJumpAbility2[index], 0, 1));
	main ? (g_iJumpChance[index] = keyvalues.GetNum("Jump Ability/Jump Chance", 4)) : (g_iJumpChance2[index] = keyvalues.GetNum("Jump Ability/Jump Chance", g_iJumpChance[index]));
	main ? (g_iJumpChance[index] = iSetCellLimit(g_iJumpChance[index], 1, 9999999999)) : (g_iJumpChance2[index] = iSetCellLimit(g_iJumpChance2[index], 1, 9999999999));
}

void vJumpAbility(int client)
{
	int iJumpAbility = !g_bTankConfig[g_iTankType[client]] ? g_iJumpAbility[g_iTankType[client]] : g_iJumpAbility2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iJumpAbility == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client))
	{
		CreateTimer(1.0, tTimerJump, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

public Action tTimerJump(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	int iJumpAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iJumpAbility[g_iTankType[iTank]] : g_iJumpAbility2[g_iTankType[iTank]];
	if (iJumpAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	int iJumpChance = !g_bTankConfig[g_iTankType[iTank]] ? g_iJumpChance[g_iTankType[iTank]] : g_iJumpChance2[g_iTankType[iTank]];
	if (GetRandomInt(1, iJumpChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		int iNearestSurvivor = iGetNearestSurvivor(iTank);
		if (iNearestSurvivor > 200 && iNearestSurvivor < 2000)
		{
			float flVelocity[3];
			GetEntPropVector(iTank, Prop_Data, "m_vecVelocity", flVelocity);
			if (flVelocity[0] > 0.0 && flVelocity[0] < 500.0)
			{
				flVelocity[0] += 500.0;
			}
			else if (flVelocity[0] < 0.0 && flVelocity[0] > -500.0)
			{
				flVelocity[0] += -500.0;
			}
			if (flVelocity[1] > 0.0 && flVelocity[1] < 500.0)
			{
				flVelocity[1] += 500.0;
			}
			else if (flVelocity[1] < 0.0 && flVelocity[1] > -500.0)
			{
				flVelocity[1] += -500.0;
			}
			flVelocity[2] += 750.0;
			TeleportEntity(iTank, NULL_VECTOR, NULL_VECTOR, flVelocity);
		}
	}
	return Plugin_Continue;
}