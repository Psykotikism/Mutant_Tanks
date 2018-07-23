// Super Tanks++: Nullify Ability
bool g_bNullify[MAXPLAYERS + 1];
float g_flNullifyDuration[ST_MAXTYPES + 1];
float g_flNullifyDuration2[ST_MAXTYPES + 1];
float g_flNullifyRange[ST_MAXTYPES + 1];
float g_flNullifyRange2[ST_MAXTYPES + 1];
int g_iNullifyAbility[ST_MAXTYPES + 1];
int g_iNullifyAbility2[ST_MAXTYPES + 1];
int g_iNullifyChance[ST_MAXTYPES + 1];
int g_iNullifyChance2[ST_MAXTYPES + 1];
int g_iNullifyHit[ST_MAXTYPES + 1];
int g_iNullifyHit2[ST_MAXTYPES + 1];

void vNullifyConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iNullifyAbility[index] = keyvalues.GetNum("Nullify Ability/Ability Enabled", 0)) : (g_iNullifyAbility2[index] = keyvalues.GetNum("Nullify Ability/Ability Enabled", g_iNullifyAbility[index]));
	main ? (g_iNullifyAbility[index] = iSetCellLimit(g_iNullifyAbility[index], 0, 1)) : (g_iNullifyAbility2[index] = iSetCellLimit(g_iNullifyAbility2[index], 0, 1));
	main ? (g_iNullifyChance[index] = keyvalues.GetNum("Nullify Ability/Nullify Chance", 4)) : (g_iNullifyChance2[index] = keyvalues.GetNum("Nullify Ability/Nullify Chance", g_iNullifyChance[index]));
	main ? (g_iNullifyChance[index] = iSetCellLimit(g_iNullifyChance[index], 1, 9999999999)) : (g_iNullifyChance2[index] = iSetCellLimit(g_iNullifyChance2[index], 1, 9999999999));
	main ? (g_flNullifyDuration[index] = keyvalues.GetFloat("Nullify Ability/Nullify Duration", 5.0)) : (g_flNullifyDuration2[index] = keyvalues.GetFloat("Nullify Ability/Nullify Duration", g_flNullifyDuration[index]));
	main ? (g_flNullifyDuration[index] = flSetFloatLimit(g_flNullifyDuration[index], 0.1, 9999999999.0)) : (g_flNullifyDuration2[index] = flSetFloatLimit(g_flNullifyDuration2[index], 0.1, 9999999999.0));
	main ? (g_iNullifyHit[index] = keyvalues.GetNum("Nullify Ability/Nullify Hit", 0)) : (g_iNullifyHit2[index] = keyvalues.GetNum("Nullify Ability/Nullify Hit", g_iNullifyHit[index]));
	main ? (g_iNullifyHit[index] = iSetCellLimit(g_iNullifyHit[index], 0, 1)) : (g_iNullifyHit2[index] = iSetCellLimit(g_iNullifyHit2[index], 0, 1));
	main ? (g_flNullifyRange[index] = keyvalues.GetFloat("Nullify Ability/Nullify Range", 150.0)) : (g_flNullifyRange2[index] = keyvalues.GetFloat("Nullify Ability/Nullify Range", g_flNullifyRange[index]));
	main ? (g_flNullifyRange[index] = flSetFloatLimit(g_flNullifyRange[index], 1.0, 9999999999.0)) : (g_flNullifyRange2[index] = flSetFloatLimit(g_flNullifyRange2[index], 1.0, 9999999999.0));
}

void vNullifyDeath()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bNullify[iSurvivor])
		{
			g_bNullify[iSurvivor] = false;
		}
	}
}

void vNullifyHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iNullifyAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iNullifyAbility[g_iTankType[owner]] : g_iNullifyAbility2[g_iTankType[owner]];
	int iNullifyChance = !g_bTankConfig[g_iTankType[owner]] ? g_iNullifyChance[g_iTankType[owner]] : g_iNullifyChance2[g_iTankType[owner]];
	int iNullifyHit = !g_bTankConfig[g_iTankType[owner]] ? g_iNullifyHit[g_iTankType[owner]] : g_iNullifyHit2[g_iTankType[owner]];
	float flNullifyRange = !g_bTankConfig[g_iTankType[owner]] ? g_flNullifyRange[g_iTankType[owner]] : g_flNullifyRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flNullifyRange) || toggle == 2) && ((toggle == 1 && iNullifyAbility == 1) || (toggle == 2 && iNullifyHit == 1)) && GetRandomInt(1, iNullifyChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && !g_bNullify[client])
	{
		g_bNullify[client] = true;
		float flNullifyDuration = !g_bTankConfig[g_iTankType[owner]] ? g_flNullifyDuration[g_iTankType[owner]] : g_flNullifyDuration2[g_iTankType[owner]];
		CreateTimer(flNullifyDuration, tTimerStopNullify, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vResetNullify(int client)
{
	g_bNullify[client] = false;
}

public Action tTimerStopNullify(Handle timer, any userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (iSurvivor == 0 || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iSurvivor))
	{
		g_bNullify[iSurvivor] = false;
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		g_bNullify[iSurvivor] = false;
	}
	return Plugin_Continue;
}