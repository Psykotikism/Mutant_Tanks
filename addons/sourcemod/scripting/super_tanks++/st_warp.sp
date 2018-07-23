// Super Tanks++: Warp Ability
bool g_bWarp[MAXPLAYERS + 1];
float g_flWarpInterval[ST_MAXTYPES + 1];
float g_flWarpInterval2[ST_MAXTYPES + 1];
int g_iWarpAbility[ST_MAXTYPES + 1];
int g_iWarpAbility2[ST_MAXTYPES + 1];
int g_iWarpChance[ST_MAXTYPES + 1];
int g_iWarpChance2[ST_MAXTYPES + 1];
int g_iWarpHit[ST_MAXTYPES + 1];
int g_iWarpHit2[ST_MAXTYPES + 1];

void vWarpConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iWarpAbility[index] = keyvalues.GetNum("Warp Ability/Ability Enabled", 0)) : (g_iWarpAbility2[index] = keyvalues.GetNum("Warp Ability/Ability Enabled", g_iWarpAbility[index]));
	main ? (g_iWarpAbility[index] = iSetCellLimit(g_iWarpAbility[index], 0, 1)) : (g_iWarpAbility2[index] = iSetCellLimit(g_iWarpAbility2[index], 0, 1));
	main ? (g_iWarpChance[index] = keyvalues.GetNum("Warp Ability/Warp Chance", 4)) : (g_iWarpChance2[index] = keyvalues.GetNum("Warp Ability/Warp Chance", g_iWarpChance[index]));
	main ? (g_iWarpChance[index] = iSetCellLimit(g_iWarpChance[index], 1, 9999999999)) : (g_iWarpChance2[index] = iSetCellLimit(g_iWarpChance2[index], 1, 9999999999));
	main ? (g_iWarpHit[index] = keyvalues.GetNum("Warp Ability/Warp Hit", 0)) : (g_iWarpHit2[index] = keyvalues.GetNum("Warp Ability/Warp Hit", g_iWarpHit[index]));
	main ? (g_iWarpHit[index] = iSetCellLimit(g_iWarpHit[index], 0, 1)) : (g_iWarpHit2[index] = iSetCellLimit(g_iWarpHit2[index], 0, 1));
	main ? (g_flWarpInterval[index] = keyvalues.GetFloat("Warp Ability/Warp Interval", 5.0)) : (g_flWarpInterval2[index] = keyvalues.GetFloat("Warp Ability/Warp Interval", g_flWarpInterval[index]));
	main ? (g_flWarpInterval[index] = flSetFloatLimit(g_flWarpInterval[index], 0.1, 9999999999.0)) : (g_flWarpInterval2[index] = flSetFloatLimit(g_flWarpInterval2[index], 0.1, 9999999999.0));
}

void vWarpAbility(int client)
{
	int iWarpAbility = !g_bTankConfig[g_iTankType[client]] ? g_iWarpAbility[g_iTankType[client]] : g_iWarpAbility2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iWarpAbility == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client) && !g_bWarp[client])
	{
		g_bWarp[client] = true;
		float flWarpInterval = !g_bTankConfig[g_iTankType[client]] ? g_flWarpInterval[g_iTankType[client]] : g_flWarpInterval2[g_iTankType[client]];
		CreateTimer(flWarpInterval, tTimerWarp, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

void vWarpHit(int client, int owner)
{
	int iWarpChance = !g_bTankConfig[g_iTankType[owner]] ? g_iWarpChance[g_iTankType[owner]] : g_iWarpChance2[g_iTankType[owner]];
	int iWarpHit = !g_bTankConfig[g_iTankType[owner]] ? g_iWarpHit[g_iTankType[owner]] : g_iWarpHit2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (iWarpHit == 1 && GetRandomInt(1, iWarpChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client))
	{
		float flCurrentOrigin[3];
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsSurvivor(iPlayer) && iPlayer != client)
			{
				GetClientAbsOrigin(iPlayer, flCurrentOrigin);
				TeleportEntity(client, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);
				break;
			}
		}
	}
}

void vResetWarp(int client)
{
	g_bWarp[client] = false;
}

public Action tTimerWarp(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	int iWarpAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iWarpAbility[g_iTankType[iTank]] : g_iWarpAbility2[g_iTankType[iTank]];
	if (iWarpAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		vWarpEntity(iTank, false, true);
	}
	return Plugin_Continue;
}