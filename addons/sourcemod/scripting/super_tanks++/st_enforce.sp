// Super Tanks++: Enforce Ability
bool g_bEnforce[MAXPLAYERS + 1];
char g_sEnforceSlot[ST_MAXTYPES + 1][6];
char g_sEnforceSlot2[ST_MAXTYPES + 1][6];
float g_flEnforceDuration[ST_MAXTYPES + 1];
float g_flEnforceDuration2[ST_MAXTYPES + 1];
float g_flEnforceRange[ST_MAXTYPES + 1];
float g_flEnforceRange2[ST_MAXTYPES + 1];
int g_iEnforceAbility[ST_MAXTYPES + 1];
int g_iEnforceAbility2[ST_MAXTYPES + 1];
int g_iEnforceChance[ST_MAXTYPES + 1];
int g_iEnforceChance2[ST_MAXTYPES + 1];
int g_iEnforceHit[ST_MAXTYPES + 1];
int g_iEnforceHit2[ST_MAXTYPES + 1];
int g_iEnforceSlot[MAXPLAYERS + 1];

void vEnforceConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iEnforceAbility[index] = keyvalues.GetNum("Enforce Ability/Ability Enabled", 0)) : (g_iEnforceAbility2[index] = keyvalues.GetNum("Enforce Ability/Ability Enabled", g_iEnforceAbility[index]));
	main ? (g_iEnforceAbility[index] = iSetCellLimit(g_iEnforceAbility[index], 0, 1)) : (g_iEnforceAbility2[index] = iSetCellLimit(g_iEnforceAbility2[index], 0, 1));
	main ? (g_iEnforceChance[index] = keyvalues.GetNum("Enforce Ability/Enforce Chance", 4)) : (g_iEnforceChance2[index] = keyvalues.GetNum("Enforce Ability/Enforce Chance", g_iEnforceChance[index]));
	main ? (g_iEnforceChance[index] = iSetCellLimit(g_iEnforceChance[index], 1, 9999999999)) : (g_iEnforceChance2[index] = iSetCellLimit(g_iEnforceChance2[index], 1, 9999999999));
	main ? (g_flEnforceDuration[index] = keyvalues.GetFloat("Enforce Ability/Enforce Duration", 5.0)) : (g_flEnforceDuration2[index] = keyvalues.GetFloat("Enforce Ability/Enforce Duration", g_flEnforceDuration[index]));
	main ? (g_flEnforceDuration[index] = flSetFloatLimit(g_flEnforceDuration[index], 0.1, 9999999999.0)) : (g_flEnforceDuration2[index] = flSetFloatLimit(g_flEnforceDuration2[index], 0.1, 9999999999.0));
	main ? (g_iEnforceHit[index] = keyvalues.GetNum("Enforce Ability/Enforce Hit", 0)) : (g_iEnforceHit2[index] = keyvalues.GetNum("Enforce Ability/Enforce Hit", g_iEnforceHit[index]));
	main ? (g_iEnforceHit[index] = iSetCellLimit(g_iEnforceHit[index], 0, 1)) : (g_iEnforceHit2[index] = iSetCellLimit(g_iEnforceHit2[index], 0, 1));
	main ? (g_flEnforceRange[index] = keyvalues.GetFloat("Enforce Ability/Enforce Range", 150.0)) : (g_flEnforceRange2[index] = keyvalues.GetFloat("Enforce Ability/Enforce Range", g_flEnforceRange[index]));
	main ? (g_flEnforceRange[index] = flSetFloatLimit(g_flEnforceRange[index], 1.0, 9999999999.0)) : (g_flEnforceRange2[index] = flSetFloatLimit(g_flEnforceRange2[index], 1.0, 9999999999.0));
	main ? (keyvalues.GetString("Enforce Ability/Enforce Weapon Slots", g_sEnforceSlot[index], sizeof(g_sEnforceSlot[]), "12345")) : (keyvalues.GetString("Enforce Ability/Enforce Weapon Slots", g_sEnforceSlot2[index], sizeof(g_sEnforceSlot2[]), g_sEnforceSlot[index]));
}

void vEnforceDeath()
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bEnforce[iSurvivor])
		{
			g_bEnforce[iSurvivor] = false;
		}
	}
}

void vEnforceHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iEnforceAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iEnforceAbility[g_iTankType[owner]] : g_iEnforceAbility2[g_iTankType[owner]];
	int iEnforceChance = !g_bTankConfig[g_iTankType[owner]] ? g_iEnforceChance[g_iTankType[owner]] : g_iEnforceChance2[g_iTankType[owner]];
	int iEnforceHit = !g_bTankConfig[g_iTankType[owner]] ? g_iEnforceHit[g_iTankType[owner]] : g_iEnforceHit2[g_iTankType[owner]];
	float flEnforceRange = !g_bTankConfig[g_iTankType[owner]] ? g_flEnforceRange[g_iTankType[owner]] : g_flEnforceRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flEnforceRange) || toggle == 2) && ((toggle == 1 && iEnforceAbility == 1) || (toggle == 2 && iEnforceHit == 1)) && GetRandomInt(1, iEnforceChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && !g_bEnforce[client])
	{
		g_bEnforce[client] = true;
		char sNumbers = !g_bTankConfig[g_iTankType[owner]] ? g_sEnforceSlot[g_iTankType[owner]][GetRandomInt(0, strlen(g_sEnforceSlot[g_iTankType[owner]]) - 1)] : g_sEnforceSlot2[g_iTankType[owner]][GetRandomInt(0, strlen(g_sEnforceSlot2[g_iTankType[owner]]) - 1)];
		switch (sNumbers)
		{
			case '1': g_iEnforceSlot[client] = 0;
			case '2': g_iEnforceSlot[client] = 1;
			case '3': g_iEnforceSlot[client] = 2;
			case '4': g_iEnforceSlot[client] = 3;
			case '5': g_iEnforceSlot[client] = 4;
		}
		float flEnforceDuration = !g_bTankConfig[g_iTankType[owner]] ? g_flEnforceDuration[g_iTankType[owner]] : g_flEnforceDuration2[g_iTankType[owner]];
		CreateTimer(flEnforceDuration, tTimerStopEnforce, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vResetEnforce(int client)
{
	g_bEnforce[client] = false;
	g_iEnforceSlot[client] = -1;
}

public Action tTimerStopEnforce(Handle timer, any userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (iSurvivor == 0 || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iSurvivor))
	{
		g_bEnforce[iSurvivor] = false;
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		g_bEnforce[iSurvivor] = false;
	}
	return Plugin_Continue;
}