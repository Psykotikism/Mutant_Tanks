// Super Tanks++: God Ability
bool g_bGod[MAXPLAYERS + 1];
float g_flGodDuration[ST_MAXTYPES + 1];
float g_flGodDuration2[ST_MAXTYPES + 1];
int g_iGodAbility[ST_MAXTYPES + 1];
int g_iGodAbility2[ST_MAXTYPES + 1];
int g_iGodChance[ST_MAXTYPES + 1];
int g_iGodChance2[ST_MAXTYPES + 1];

void vGodConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iGodAbility[index] = keyvalues.GetNum("God Ability/Ability Enabled", 0)) : (g_iGodAbility2[index] = keyvalues.GetNum("God Ability/Ability Enabled", g_iGodAbility[index]));
	main ? (g_iGodAbility[index] = iSetCellLimit(g_iGodAbility[index], 0, 1)) : (g_iGodAbility2[index] = iSetCellLimit(g_iGodAbility2[index], 0, 1));
	main ? (g_iGodChance[index] = keyvalues.GetNum("God Ability/God Chance", 4)) : (g_iGodChance2[index] = keyvalues.GetNum("God Ability/God Chance", g_iGodChance[index]));
	main ? (g_iGodChance[index] = iSetCellLimit(g_iGodChance[index], 1, 9999999999)) : (g_iGodChance2[index] = iSetCellLimit(g_iGodChance2[index], 1, 9999999999));
	main ? (g_flGodDuration[index] = keyvalues.GetFloat("God Ability/God Duration", 5.0)) : (g_flGodDuration2[index] = keyvalues.GetFloat("God Ability/God Duration", g_flGodDuration[index]));
	main ? (g_flGodDuration[index] = flSetFloatLimit(g_flGodDuration[index], 0.1, 9999999999.0)) : (g_flGodDuration2[index] = flSetFloatLimit(g_flGodDuration2[index], 0.1, 9999999999.0));
}

void vGodAbility(int client)
{
	int iGodAbility = !g_bTankConfig[g_iTankType[client]] ? g_iGodAbility[g_iTankType[client]] : g_iGodAbility2[g_iTankType[client]];
	int iGodChance = !g_bTankConfig[g_iTankType[client]] ? g_iGodChance[g_iTankType[client]] : g_iGodChance2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iGodAbility == 1 && GetRandomInt(1, iGodChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client) && !g_bGod[client])
	{
		g_bGod[client] = true;
		SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
		float flGodDuration = !g_bTankConfig[g_iTankType[client]] ? g_flGodDuration[g_iTankType[client]] : g_flGodDuration2[g_iTankType[client]];
		CreateTimer(flGodDuration, tTimerStopGod, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vResetGod(int client)
{
	g_bGod[client] = false;
}

public Action tTimerStopGod(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bGod[iTank] = false;
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		g_bGod[iTank] = false;
		SetEntProp(iTank, Prop_Data, "m_takedamage", 2, 1);
	}
	return Plugin_Continue;
}