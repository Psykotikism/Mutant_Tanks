// Super Tanks++: Panic Ability
bool g_bPanic[MAXPLAYERS + 1];
float g_flPanicInterval[ST_MAXTYPES + 1];
float g_flPanicInterval2[ST_MAXTYPES + 1];
int g_iPanicAbility[ST_MAXTYPES + 1];
int g_iPanicAbility2[ST_MAXTYPES + 1];
int g_iPanicChance[ST_MAXTYPES + 1];
int g_iPanicChance2[ST_MAXTYPES + 1];
int g_iPanicHit[ST_MAXTYPES + 1];
int g_iPanicHit2[ST_MAXTYPES + 1];

void vPanicConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iPanicAbility[index] = keyvalues.GetNum("Panic Ability/Ability Enabled", 0)) : (g_iPanicAbility2[index] = keyvalues.GetNum("Panic Ability/Ability Enabled", g_iPanicAbility[index]));
	main ? (g_iPanicAbility[index] = iSetCellLimit(g_iPanicAbility[index], 0, 1)) : (g_iPanicAbility2[index] = iSetCellLimit(g_iPanicAbility2[index], 0, 1));
	main ? (g_iPanicChance[index] = keyvalues.GetNum("Panic Ability/Panic Chance", 4)) : (g_iPanicChance2[index] = keyvalues.GetNum("Panic Ability/Panic Chance", g_iPanicChance[index]));
	main ? (g_iPanicChance[index] = iSetCellLimit(g_iPanicChance[index], 1, 9999999999)) : (g_iPanicChance2[index] = iSetCellLimit(g_iPanicChance2[index], 1, 9999999999));
	main ? (g_iPanicHit[index] = keyvalues.GetNum("Panic Ability/Panic Hit", 0)) : (g_iPanicHit2[index] = keyvalues.GetNum("Panic Ability/Panic Hit", g_iPanicHit[index]));
	main ? (g_iPanicHit[index] = iSetCellLimit(g_iPanicHit[index], 0, 1)) : (g_iPanicHit2[index] = iSetCellLimit(g_iPanicHit2[index], 0, 1));
	main ? (g_flPanicInterval[index] = keyvalues.GetFloat("Panic Ability/Panic Interval", 5.0)) : (g_flPanicInterval2[index] = keyvalues.GetFloat("Panic Ability/Panic Interval", g_flPanicInterval[index]));
	main ? (g_flPanicInterval[index] = flSetFloatLimit(g_flPanicInterval[index], 0.1, 9999999999.0)) : (g_flPanicInterval2[index] = flSetFloatLimit(g_flPanicInterval2[index], 0.1, 9999999999.0));
}

void vPanic()
{
	int iDirector = CreateEntityByName("info_director");
	if (bIsValidEntity(iDirector))
	{
		DispatchSpawn(iDirector);
		AcceptEntityInput(iDirector, "ForcePanicEvent");
		AcceptEntityInput(iDirector, "Kill");
	}
}

void vPanicAbility(int client)
{
	int iPanicAbility = !g_bTankConfig[g_iTankType[client]] ? g_iPanicAbility[g_iTankType[client]] : g_iPanicAbility2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iPanicAbility == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client) && !g_bPanic[client])
	{
		g_bPanic[client] = true;
		float flPanicInterval = !g_bTankConfig[g_iTankType[client]] ? g_flPanicInterval[g_iTankType[client]] : g_flPanicInterval2[g_iTankType[client]];
		CreateTimer(flPanicInterval, tTimerPanic, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

void vPanicHit(int client)
{
	int iPanicChance = !g_bTankConfig[g_iTankType[client]] ? g_iPanicChance[g_iTankType[client]] : g_iPanicChance2[g_iTankType[client]];
	int iPanicHit = !g_bTankConfig[g_iTankType[client]] ? g_iPanicHit[g_iTankType[client]] : g_iPanicHit2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iPanicHit == 1 && GetRandomInt(1, iPanicChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client))
	{
		vPanic();
	}
}

void vResetPanic(int client)
{
	g_bPanic[client] = false;
}

public Action tTimerPanic(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bPanic[iTank] = false;
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		vPanic();
	}
	return Plugin_Continue;
}