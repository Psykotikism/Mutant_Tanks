// Super Tanks++: Blind Ability
bool g_bBlind[MAXPLAYERS + 1];
float g_flBlindDuration[ST_MAXTYPES + 1];
float g_flBlindDuration2[ST_MAXTYPES + 1];
float g_flBlindRange[ST_MAXTYPES + 1];
float g_flBlindRange2[ST_MAXTYPES + 1];
int g_iBlindAbility[ST_MAXTYPES + 1];
int g_iBlindAbility2[ST_MAXTYPES + 1];
int g_iBlindChance[ST_MAXTYPES + 1];
int g_iBlindChance2[ST_MAXTYPES + 1];
int g_iBlindHit[ST_MAXTYPES + 1];
int g_iBlindHit2[ST_MAXTYPES + 1];
int g_iBlindIntensity[ST_MAXTYPES + 1];
int g_iBlindIntensity2[ST_MAXTYPES + 1];

void vBlindConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iBlindAbility[index] = keyvalues.GetNum("Blind Ability/Ability Enabled", 0)) : (g_iBlindAbility2[index] = keyvalues.GetNum("Blind Ability/Ability Enabled", g_iBlindAbility[index]));
	main ? (g_iBlindAbility[index] = iSetCellLimit(g_iBlindAbility[index], 0, 1)) : (g_iBlindAbility2[index] = iSetCellLimit(g_iBlindAbility2[index], 0, 1));
	main ? (g_iBlindChance[index] = keyvalues.GetNum("Blind Ability/Blind Chance", 4)) : (g_iBlindChance2[index] = keyvalues.GetNum("Blind Ability/Blind Chance", g_iBlindChance[index]));
	main ? (g_iBlindChance[index] = iSetCellLimit(g_iBlindChance[index], 1, 9999999999)) : (g_iBlindChance2[index] = iSetCellLimit(g_iBlindChance2[index], 1, 9999999999));
	main ? (g_flBlindDuration[index] = keyvalues.GetFloat("Blind Ability/Blind Duration", 5.0)) : (g_flBlindDuration2[index] = keyvalues.GetFloat("Blind Ability/Blind Duration", g_flBlindDuration[index]));
	main ? (g_flBlindDuration[index] = flSetFloatLimit(g_flBlindDuration[index], 0.1, 9999999999.0)) : (g_flBlindDuration2[index] = flSetFloatLimit(g_flBlindDuration2[index], 0.1, 9999999999.0));
	main ? (g_iBlindHit[index] = keyvalues.GetNum("Blind Ability/Blind Hit", 0)) : (g_iBlindHit2[index] = keyvalues.GetNum("Blind Ability/Blind Hit", g_iBlindHit[index]));
	main ? (g_iBlindHit[index] = iSetCellLimit(g_iBlindHit[index], 0, 1)) : (g_iBlindHit2[index] = iSetCellLimit(g_iBlindHit2[index], 0, 1));
	main ? (g_iBlindIntensity[index] = keyvalues.GetNum("Blind Ability/Blind Intensity", 255)) : (g_iBlindIntensity2[index] = keyvalues.GetNum("Blind Ability/Blind Intensity", g_iBlindIntensity[index]));
	main ? (g_iBlindIntensity[index] = iSetCellLimit(g_iBlindIntensity[index], 0, 255)) : (g_iBlindIntensity2[index] = iSetCellLimit(g_iBlindIntensity2[index], 0, 255));
	main ? (g_flBlindRange[index] = keyvalues.GetFloat("Blind Ability/Blind Range", 150.0)) : (g_flBlindRange2[index] = keyvalues.GetFloat("Blind Ability/Blind Range", g_flBlindRange[index]));
	main ? (g_flBlindRange[index] = flSetFloatLimit(g_flBlindRange[index], 1.0, 9999999999.0)) : (g_flBlindRange2[index] = flSetFloatLimit(g_flBlindRange2[index], 1.0, 9999999999.0));
}

void vBlindDeath(int client)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bBlind[iSurvivor])
		{
			DataPack dpDataPack;
			CreateDataTimer(0.1, tTimerStopBlindness, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
			dpDataPack.WriteCell(GetClientUserId(iSurvivor));
			dpDataPack.WriteCell(GetClientUserId(client));
		}
	}
}

void vBlind(int client, int amount, UserMsg message)
{
	int iTargets[2];
	iTargets[0] = client;
	int iFlags;
	if (bIsSurvivor(client))
	{
		amount == 0 ? (iFlags = (0x0001|0x0010)) : (iFlags = (0x0002|0x0008));
		int iColor[4] = {0, 0, 0, 0};
		iColor[3] = amount;
		Handle hBlindTarget = StartMessageEx(message, iTargets, 1);
		if (GetUserMessageType() == UM_Protobuf)
		{
			Protobuf pbSet = UserMessageToProtobuf(hBlindTarget);
			pbSet.SetInt("duration", 1536);
			pbSet.SetInt("hold_time", 1536);
			pbSet.SetInt("flags", iFlags);
			pbSet.SetColor("clr", iColor);
		}
		else
		{
			BfWrite bfWrite = UserMessageToBfWrite(hBlindTarget);
			bfWrite.WriteShort(1536);
			bfWrite.WriteShort(1536);
			bfWrite.WriteShort(iFlags);
			bfWrite.WriteByte(iColor[0]);
			bfWrite.WriteByte(iColor[1]);
			bfWrite.WriteByte(iColor[2]);
			bfWrite.WriteByte(iColor[3]);
		}
		EndMessage();
	}
}

void vBlindHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iBlindAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iBlindAbility[g_iTankType[owner]] : g_iBlindAbility2[g_iTankType[owner]];
	int iBlindChance = !g_bTankConfig[g_iTankType[owner]] ? g_iBlindChance[g_iTankType[owner]] : g_iBlindChance2[g_iTankType[owner]];
	int iBlindHit = !g_bTankConfig[g_iTankType[owner]] ? g_iBlindHit[g_iTankType[owner]] : g_iBlindHit2[g_iTankType[owner]];
	float flBlindRange = !g_bTankConfig[g_iTankType[owner]] ? g_flBlindRange[g_iTankType[owner]] : g_flBlindRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flBlindRange) || toggle == 2) && ((toggle == 1 && iBlindAbility == 1) || (toggle == 2 && iBlindHit == 1)) && GetRandomInt(1, iBlindChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && !g_bBlind[client])
	{
		g_bBlind[client] = true;
		int iBlindToggle = !g_bTankConfig[g_iTankType[owner]] ? g_iBlindIntensity[g_iTankType[owner]] : g_iBlindIntensity2[g_iTankType[owner]];
		vBlind(client, iBlindToggle, g_umFadeUserMsgId);
		float flBlindDuration = !g_bTankConfig[g_iTankType[owner]] ? g_flBlindDuration[g_iTankType[owner]] : g_flBlindDuration2[g_iTankType[owner]];
		DataPack dpDataPack;
		CreateDataTimer(flBlindDuration, tTimerStopBlindness, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
	}
}

void vResetBlind(int client)
{
	g_bBlind[client] = false;
}

public Action tTimerStopBlindness(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (iTank == 0 || iSurvivor == 0 || !IsClientInGame(iTank) || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iTank) || !IsPlayerAlive(iSurvivor))
	{
		g_bBlind[iSurvivor] = false;
		if (bIsSurvivor(iSurvivor))
		{
			vBlind(iSurvivor, 0, g_umFadeUserMsgId);
		}
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		g_bBlind[iSurvivor] = false;
		vBlind(iSurvivor, 0, g_umFadeUserMsgId);
	}
	return Plugin_Continue;
}