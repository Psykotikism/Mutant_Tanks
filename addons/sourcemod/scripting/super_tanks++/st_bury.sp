// Super Tanks++: Bury Ability
bool g_bBury[MAXPLAYERS + 1];
float g_flBuryDuration[ST_MAXTYPES + 1];
float g_flBuryDuration2[ST_MAXTYPES + 1];
float g_flBuryHeight[ST_MAXTYPES + 1];
float g_flBuryHeight2[ST_MAXTYPES + 1];
float g_flBuryRange[ST_MAXTYPES + 1];
float g_flBuryRange2[ST_MAXTYPES + 1];
int g_iBuryAbility[ST_MAXTYPES + 1];
int g_iBuryAbility2[ST_MAXTYPES + 1];
int g_iBuryChance[ST_MAXTYPES + 1];
int g_iBuryChance2[ST_MAXTYPES + 1];
int g_iBuryHit[ST_MAXTYPES + 1];
int g_iBuryHit2[ST_MAXTYPES + 1];

void vBuryConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iBuryAbility[index] = keyvalues.GetNum("Bury Ability/Ability Enabled", 0)) : (g_iBuryAbility2[index] = keyvalues.GetNum("Bury Ability/Ability Enabled", g_iBuryAbility[index]));
	main ? (g_iBuryAbility[index] = iSetCellLimit(g_iBuryAbility[index], 0, 1)) : (g_iBuryAbility2[index] = iSetCellLimit(g_iBuryAbility2[index], 0, 1));
	main ? (g_iBuryChance[index] = keyvalues.GetNum("Bury Ability/Bury Chance", 4)) : (g_iBuryChance2[index] = keyvalues.GetNum("Bury Ability/Bury Chance", g_iBuryChance[index]));
	main ? (g_iBuryChance[index] = iSetCellLimit(g_iBuryChance[index], 1, 9999999999)) : (g_iBuryChance2[index] = iSetCellLimit(g_iBuryChance2[index], 1, 9999999999));
	main ? (g_flBuryDuration[index] = keyvalues.GetFloat("Bury Ability/Bury Duration", 5.0)) : (g_flBuryDuration2[index] = keyvalues.GetFloat("Bury Ability/Bury Duration", g_flBuryDuration[index]));
	main ? (g_flBuryDuration[index] = flSetFloatLimit(g_flBuryDuration[index], 0.1, 9999999999.0)) : (g_flBuryDuration2[index] = flSetFloatLimit(g_flBuryDuration2[index], 0.1, 9999999999.0));
	main ? (g_flBuryHeight[index] = keyvalues.GetFloat("Bury Ability/Bury Height", 50.0)) : (g_flBuryHeight2[index] = keyvalues.GetFloat("Bury Ability/Bury Height", g_flBuryHeight[index]));
	main ? (g_flBuryHeight[index] = flSetFloatLimit(g_flBuryHeight[index], 0.1, 9999999999.0)) : (g_flBuryHeight2[index] = flSetFloatLimit(g_flBuryHeight2[index], 0.1, 9999999999.0));
	main ? (g_iBuryHit[index] = keyvalues.GetNum("Bury Ability/Bury Hit", 0)) : (g_iBuryHit2[index] = keyvalues.GetNum("Bury Ability/Bury Hit", g_iBuryHit[index]));
	main ? (g_iBuryHit[index] = iSetCellLimit(g_iBuryHit[index], 0, 1)) : (g_iBuryHit2[index] = iSetCellLimit(g_iBuryHit2[index], 0, 1));
	main ? (g_flBuryRange[index] = keyvalues.GetFloat("Bury Ability/Bury Range", 150.0)) : (g_flBuryRange2[index] = keyvalues.GetFloat("Bury Ability/Bury Range", g_flBuryRange[index]));
	main ? (g_flBuryRange[index] = flSetFloatLimit(g_flBuryRange[index], 1.0, 9999999999.0)) : (g_flBuryRange2[index] = flSetFloatLimit(g_flBuryRange2[index], 1.0, 9999999999.0));
}

void vBuryDeath(int client)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bBury[iSurvivor])
		{
			DataPack dpDataPack;
			CreateDataTimer(0.1, tTimerStopBury, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
			dpDataPack.WriteCell(GetClientUserId(iSurvivor));
			dpDataPack.WriteCell(GetClientUserId(client));
		}
	}
}

void vBuryHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iBuryAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iBuryAbility[g_iTankType[owner]] : g_iBuryAbility2[g_iTankType[owner]];
	int iBuryChance = !g_bTankConfig[g_iTankType[owner]] ? g_iBuryChance[g_iTankType[owner]] : g_iBuryChance2[g_iTankType[owner]];
	int iBuryHit = !g_bTankConfig[g_iTankType[owner]] ? g_iBuryHit[g_iTankType[owner]] : g_iBuryHit2[g_iTankType[owner]];
	float flBuryRange = !g_bTankConfig[g_iTankType[owner]] ? g_flBuryRange[g_iTankType[owner]] : g_flBuryRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flBuryRange) || toggle == 2) && ((toggle == 1 && iBuryAbility == 1) || (toggle == 2 && iBuryHit == 1)) && GetRandomInt(1, iBuryChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && !g_bBury[client] && bIsPlayerGrounded(client))
	{
		g_bBury[client] = true;
		float flOrigin[3];
		float flBuryHeight = !g_bTankConfig[g_iTankType[owner]] ? g_flBuryHeight[g_iTankType[owner]] : g_flBuryHeight2[g_iTankType[owner]];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		flOrigin[2] = flOrigin[2] - flBuryHeight;
		SetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		if (!bIsPlayerIncapacitated(client))
		{
			SetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
			SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
		}
		float flPos[3];
		GetClientEyePosition(client, flPos);
		if (GetEntityMoveType(client) != MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_NONE);
		}
		float flBuryDuration = !g_bTankConfig[g_iTankType[owner]] ? g_flBuryDuration[g_iTankType[owner]] : g_flBuryDuration2[g_iTankType[owner]];
		DataPack dpDataPack;
		CreateDataTimer(flBuryDuration, tTimerStopBury, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
	}
}

void vStopBury(int client, int owner)
{
	if (g_bBury[client])
	{
		g_bBury[client] = false;
		float flOrigin[3];
		float flBuryHeight = !g_bTankConfig[g_iTankType[owner]] ? g_flBuryHeight[g_iTankType[owner]] : g_flBuryHeight2[g_iTankType[owner]];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		flOrigin[2] = flOrigin[2] + flBuryHeight;
		SetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		vWarpEntity(client, true);
		if (bIsPlayerIncapacitated(client))
		{
			SDKCall(g_hSDKRevivePlayer, client);
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
		}
		if (GetEntityMoveType(client) == MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
		}
	}
}

void vResetBury(int client)
{
	g_bBury[client] = false;
}

public Action tTimerStopBury(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (iTank == 0 || iSurvivor == 0 || !IsClientInGame(iTank) || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iTank) || !IsPlayerAlive(iSurvivor))
	{
		if (bIsSurvivor(iSurvivor))
		{
			vStopBury(iSurvivor, iTank);
		}
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		vStopBury(iSurvivor, iTank);
	}
	return Plugin_Continue;
}