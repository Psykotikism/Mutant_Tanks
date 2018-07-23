// Super Tanks++: Hypno Ability
bool g_bHypno[MAXPLAYERS + 1];
float g_flHypnoDuration[ST_MAXTYPES + 1];
float g_flHypnoDuration2[ST_MAXTYPES + 1];
float g_flHypnoRange[ST_MAXTYPES + 1];
float g_flHypnoRange2[ST_MAXTYPES + 1];
int g_iHypnoAbility[ST_MAXTYPES + 1];
int g_iHypnoAbility2[ST_MAXTYPES + 1];
int g_iHypnoChance[ST_MAXTYPES + 1];
int g_iHypnoChance2[ST_MAXTYPES + 1];
int g_iHypnoHit[ST_MAXTYPES + 1];
int g_iHypnoHit2[ST_MAXTYPES + 1];
int g_iHypnoMode[ST_MAXTYPES + 1];
int g_iHypnoMode2[ST_MAXTYPES + 1];

void vHypnoConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iHypnoAbility[index] = keyvalues.GetNum("Hypno Ability/Ability Enabled", 0)) : (g_iHypnoAbility2[index] = keyvalues.GetNum("Hypno Ability/Ability Enabled", g_iHypnoAbility[index]));
	main ? (g_iHypnoAbility[index] = iSetCellLimit(g_iHypnoAbility[index], 0, 1)) : (g_iHypnoAbility2[index] = iSetCellLimit(g_iHypnoAbility2[index], 0, 1));
	main ? (g_iHypnoChance[index] = keyvalues.GetNum("Hypno Ability/Hypno Chance", 4)) : (g_iHypnoChance2[index] = keyvalues.GetNum("Hypno Ability/Hypno Chance", g_iHypnoChance[index]));
	main ? (g_iHypnoChance[index] = iSetCellLimit(g_iHypnoChance[index], 1, 9999999999)) : (g_iHypnoChance2[index] = iSetCellLimit(g_iHypnoChance2[index], 1, 9999999999));
	main ? (g_flHypnoDuration[index] = keyvalues.GetFloat("Hypno Ability/Hypno Duration", 5.0)) : (g_flHypnoDuration2[index] = keyvalues.GetFloat("Hypno Ability/Hypno Duration", g_flHypnoDuration[index]));
	main ? (g_flHypnoDuration[index] = flSetFloatLimit(g_flHypnoDuration[index], 0.1, 9999999999.0)) : (g_flHypnoDuration2[index] = flSetFloatLimit(g_flHypnoDuration2[index], 0.1, 9999999999.0));
	main ? (g_iHypnoHit[index] = keyvalues.GetNum("Hypno Ability/Hypno Hit", 0)) : (g_iHypnoHit2[index] = keyvalues.GetNum("Hypno Ability/Hypno Hit", g_iHypnoHit[index]));
	main ? (g_iHypnoHit[index] = iSetCellLimit(g_iHypnoHit[index], 0, 1)) : (g_iHypnoHit2[index] = iSetCellLimit(g_iHypnoHit2[index], 0, 1));
	main ? (g_iHypnoMode[index] = keyvalues.GetNum("Hypno Ability/Hypno Mode", 0)) : (g_iHypnoMode2[index] = keyvalues.GetNum("Hypno Ability/Hypno Mode", g_iHypnoMode[index]));
	main ? (g_iHypnoMode[index] = iSetCellLimit(g_iHypnoMode[index], 0, 1)) : (g_iHypnoMode2[index] = iSetCellLimit(g_iHypnoMode2[index], 0, 1));
	main ? (g_flHypnoRange[index] = keyvalues.GetFloat("Hypno Ability/Hypno Range", 150.0)) : (g_flHypnoRange2[index] = keyvalues.GetFloat("Hypno Ability/Hypno Range", g_flHypnoRange[index]));
	main ? (g_flHypnoRange[index] = flSetFloatLimit(g_flHypnoRange[index], 1.0, 9999999999.0)) : (g_flHypnoRange2[index] = flSetFloatLimit(g_flHypnoRange2[index], 1.0, 9999999999.0));
}

void vHypnoDeath()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bHypno[iSurvivor])
		{
			g_bHypno[iSurvivor] = false;
		}
	}
}

void vHypnoHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iHypnoAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iHypnoAbility[g_iTankType[owner]] : g_iHypnoAbility2[g_iTankType[owner]];
	int iHypnoChance = !g_bTankConfig[g_iTankType[owner]] ? g_iHypnoChance[g_iTankType[owner]] : g_iHypnoChance2[g_iTankType[owner]];
	int iHypnoHit = !g_bTankConfig[g_iTankType[owner]] ? g_iHypnoHit[g_iTankType[owner]] : g_iHypnoHit2[g_iTankType[owner]];
	float flHypnoRange = !g_bTankConfig[g_iTankType[owner]] ? g_flHypnoRange[g_iTankType[owner]] : g_flHypnoRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flHypnoRange) || toggle == 2) && ((toggle == 1 && iHypnoAbility == 1) || (toggle == 2 && iHypnoHit == 1)) && GetRandomInt(1, iHypnoChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && !g_bHypno[client])
	{
		g_bHypno[client] = true;
		float flHypnoDuration = !g_bTankConfig[g_iTankType[owner]] ? g_flHypnoDuration[g_iTankType[owner]] : g_flHypnoDuration2[g_iTankType[owner]];
		CreateTimer(flHypnoDuration, tTimerStopHypno, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vResetHypno(int client)
{
	g_bHypno[client] = false;
}

public Action tTimerStopHypno(Handle timer, any userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (iSurvivor == 0 || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iSurvivor))
	{
		g_bHypno[iSurvivor] = false;
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		g_bHypno[iSurvivor] = false;
	}
	return Plugin_Continue;
}