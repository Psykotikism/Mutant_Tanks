// Super Tanks++: Fragile Ability
bool g_bFragile[MAXPLAYERS + 1];
float g_flFragileDuration[ST_MAXTYPES + 1];
float g_flFragileDuration2[ST_MAXTYPES + 1];
int g_iFragileAbility[ST_MAXTYPES + 1];
int g_iFragileAbility2[ST_MAXTYPES + 1];
int g_iFragileChance[ST_MAXTYPES + 1];
int g_iFragileChance2[ST_MAXTYPES + 1];

void vFragileConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iFragileAbility[index] = keyvalues.GetNum("Fragile Ability/Ability Enabled", 0)) : (g_iFragileAbility2[index] = keyvalues.GetNum("Fragile Ability/Ability Enabled", g_iFragileAbility[index]));
	main ? (g_iFragileAbility[index] = iSetCellLimit(g_iFragileAbility[index], 0, 1)) : (g_iFragileAbility2[index] = iSetCellLimit(g_iFragileAbility2[index], 0, 1));
	main ? (g_iFragileChance[index] = keyvalues.GetNum("Fragile Ability/Fragile Chance", 4)) : (g_iFragileChance2[index] = keyvalues.GetNum("Fragile Ability/Fragile Chance", g_iFragileChance[index]));
	main ? (g_iFragileChance[index] = iSetCellLimit(g_iFragileChance[index], 1, 9999999999)) : (g_iFragileChance2[index] = iSetCellLimit(g_iFragileChance2[index], 1, 9999999999));
	main ? (g_flFragileDuration[index] = keyvalues.GetFloat("Fragile Ability/Fragile Duration", 5.0)) : (g_flFragileDuration2[index] = keyvalues.GetFloat("Fragile Ability/Fragile Duration", g_flFragileDuration[index]));
	main ? (g_flFragileDuration[index] = flSetFloatLimit(g_flFragileDuration[index], 0.1, 9999999999.0)) : (g_flFragileDuration2[index] = flSetFloatLimit(g_flFragileDuration2[index], 0.1, 9999999999.0));
}

void vFragileAbility(int client)
{
	int iFragileAbility = !g_bTankConfig[g_iTankType[client]] ? g_iFragileAbility[g_iTankType[client]] : g_iFragileAbility2[g_iTankType[client]];
	int iFragileChance = !g_bTankConfig[g_iTankType[client]] ? g_iFragileChance[g_iTankType[client]] : g_iFragileChance2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iFragileAbility == 1 && GetRandomInt(1, iFragileChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client) && !g_bFragile[client])
	{
		g_bFragile[client] = true;
		float flFragileDuration = !g_bTankConfig[g_iTankType[client]] ? g_flFragileDuration[g_iTankType[client]] : g_flFragileDuration2[g_iTankType[client]];
		CreateTimer(flFragileDuration, tTimerStopFragile, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vResetFragile(int client)
{
	g_bFragile[client] = false;
}

public Action tTimerStopFragile(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bFragile[iTank] = false;
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		g_bFragile[iTank] = false;
	}
	return Plugin_Continue;
}