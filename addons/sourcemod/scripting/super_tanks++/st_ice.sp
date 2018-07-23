// Super Tanks++: Ice Ability
bool g_bIce[MAXPLAYERS + 1];
float g_flIceDuration[ST_MAXTYPES + 1];
float g_flIceDuration2[ST_MAXTYPES + 1];
float g_flIceRange[ST_MAXTYPES + 1];
float g_flIceRange2[ST_MAXTYPES + 1];
int g_iIceAbility[ST_MAXTYPES + 1];
int g_iIceAbility2[ST_MAXTYPES + 1];
int g_iIceChance[ST_MAXTYPES + 1];
int g_iIceChance2[ST_MAXTYPES + 1];
int g_iIceHit[ST_MAXTYPES + 1];
int g_iIceHit2[ST_MAXTYPES + 1];

void vIceConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iIceAbility[index] = keyvalues.GetNum("Ice Ability/Ability Enabled", 0)) : (g_iIceAbility2[index] = keyvalues.GetNum("Ice Ability/Ability Enabled", g_iIceAbility[index]));
	main ? (g_iIceAbility[index] = iSetCellLimit(g_iIceAbility[index], 0, 1)) : (g_iIceAbility2[index] = iSetCellLimit(g_iIceAbility2[index], 0, 1));
	main ? (g_iIceChance[index] = keyvalues.GetNum("Ice Ability/Ice Chance", 4)) : (g_iIceChance2[index] = keyvalues.GetNum("Ice Ability/Ice Chance", g_iIceChance[index]));
	main ? (g_iIceChance[index] = iSetCellLimit(g_iIceChance[index], 1, 9999999999)) : (g_iIceChance2[index] = iSetCellLimit(g_iIceChance2[index], 1, 9999999999));
	main ? (g_flIceDuration[index] = keyvalues.GetFloat("Ice Ability/Ice Duration", 5.0)) : (g_flIceDuration2[index] = keyvalues.GetFloat("Ice Ability/Ice Duration", g_flIceDuration[index]));
	main ? (g_flIceDuration[index] = flSetFloatLimit(g_flIceDuration[index], 0.1, 9999999999.0)) : (g_flIceDuration2[index] = flSetFloatLimit(g_flIceDuration2[index], 0.1, 9999999999.0));
	main ? (g_iIceHit[index] = keyvalues.GetNum("Ice Ability/Ice Hit", 0)) : (g_iIceHit2[index] = keyvalues.GetNum("Ice Ability/Ice Hit", g_iIceHit[index]));
	main ? (g_iIceHit[index] = iSetCellLimit(g_iIceHit[index], 0, 1)) : (g_iIceHit2[index] = iSetCellLimit(g_iIceHit2[index], 0, 1));
	main ? (g_flIceRange[index] = keyvalues.GetFloat("Ice Ability/Ice Range", 150.0)) : (g_flIceRange2[index] = keyvalues.GetFloat("Ice Ability/Ice Range", g_flIceRange[index]));
	main ? (g_flIceRange[index] = flSetFloatLimit(g_flIceRange[index], 1.0, 9999999999.0)) : (g_flIceRange2[index] = flSetFloatLimit(g_flIceRange2[index], 1.0, 9999999999.0));
}

void vIceDeath(int client)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bIce[iSurvivor])
		{
			DataPack dpDataPack;
			CreateDataTimer(0.1, tTimerStopIce, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
			dpDataPack.WriteCell(GetClientUserId(iSurvivor));
			dpDataPack.WriteCell(GetClientUserId(client));
		}
	}
}

void vIceHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iIceAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iIceAbility[g_iTankType[owner]] : g_iIceAbility2[g_iTankType[owner]];
	int iIceChance = !g_bTankConfig[g_iTankType[owner]] ? g_iIceChance[g_iTankType[owner]] : g_iIceChance2[g_iTankType[owner]];
	int iIceHit = !g_bTankConfig[g_iTankType[owner]] ? g_iIceHit[g_iTankType[owner]] : g_iIceHit2[g_iTankType[owner]];
	float flIceRange = !g_bTankConfig[g_iTankType[owner]] ? g_flIceRange[g_iTankType[owner]] : g_flIceRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flIceRange) || toggle == 2) && ((toggle == 1 && iIceAbility == 1) || (toggle == 2 && iIceHit == 1)) && GetRandomInt(1, iIceChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && !g_bIce[client])
	{
		g_bIce[client] = true;
		float flPos[3];
		GetClientEyePosition(client, flPos);
		if (GetEntityMoveType(client) != MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_NONE);
		}
		SetEntityRenderColor(client, 0, 130, 255, 190);
		EmitAmbientSound(SOUND_BULLET, flPos, client, SNDLEVEL_RAIDSIREN);
		float flIceDuration = !g_bTankConfig[g_iTankType[owner]] ? g_flIceDuration[g_iTankType[owner]] : g_flIceDuration2[g_iTankType[owner]];
		DataPack dpDataPack;
		CreateDataTimer(flIceDuration, tTimerStopIce, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
	}
}

void vStopIce(int client)
{
	if (g_bIce[client])
	{
		g_bIce[client] = false;
		float flPos[3];
		GetClientEyePosition(client, flPos);
		if (GetEntityMoveType(client) == MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
		}
		SetEntityRenderColor(client, 255, 255, 255, 255);
		EmitAmbientSound(SOUND_BULLET, flPos, client, SNDLEVEL_RAIDSIREN);
	}
}

void vResetIce(int client)
{
	g_bIce[client] = false;
}

public Action tTimerStopIce(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (iTank == 0 || iSurvivor == 0 || !IsClientInGame(iTank) || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iTank) || !IsPlayerAlive(iSurvivor))
	{
		if (bIsSurvivor(iSurvivor))
		{
			vStopIce(iSurvivor);
		}
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		vStopIce(iSurvivor);
	}
	return Plugin_Continue;
}