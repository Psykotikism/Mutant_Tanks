// Super Tanks++: Drug Ability
bool g_bDrug[MAXPLAYERS + 1];
float g_flDrugAngles[20] = {0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 20.0, 15.0, 10.0, 5.0, 0.0, -5.0, -10.0, -15.0, -20.0, -25.0, -20.0, -15.0, -10.0, -5.0};
float g_flDrugDuration[ST_MAXTYPES + 1];
float g_flDrugDuration2[ST_MAXTYPES + 1];
float g_flDrugRange[ST_MAXTYPES + 1];
float g_flDrugRange2[ST_MAXTYPES + 1];
int g_iDrugAbility[ST_MAXTYPES + 1];
int g_iDrugAbility2[ST_MAXTYPES + 1];
int g_iDrugChance[ST_MAXTYPES + 1];
int g_iDrugChance2[ST_MAXTYPES + 1];
int g_iDrugHit[ST_MAXTYPES + 1];
int g_iDrugHit2[ST_MAXTYPES + 1];

void vDrugConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iDrugAbility[index] = keyvalues.GetNum("Drug Ability/Ability Enabled", 0)) : (g_iDrugAbility2[index] = keyvalues.GetNum("Drug Ability/Ability Enabled", g_iDrugAbility[index]));
	main ? (g_iDrugAbility[index] = iSetCellLimit(g_iDrugAbility[index], 0, 1)) : (g_iDrugAbility2[index] = iSetCellLimit(g_iDrugAbility2[index], 0, 1));
	main ? (g_iDrugChance[index] = keyvalues.GetNum("Drug Ability/Drug Chance", 4)) : (g_iDrugChance2[index] = keyvalues.GetNum("Drug Ability/Drug Chance", g_iDrugChance[index]));
	main ? (g_iDrugChance[index] = iSetCellLimit(g_iDrugChance[index], 1, 9999999999)) : (g_iDrugChance2[index] = iSetCellLimit(g_iDrugChance2[index], 1, 9999999999));
	main ? (g_flDrugDuration[index] = keyvalues.GetFloat("Drug Ability/Drug Duration", 5.0)) : (g_flDrugDuration2[index] = keyvalues.GetFloat("Drug Ability/Drug Duration", g_flDrugDuration[index]));
	main ? (g_flDrugDuration[index] = flSetFloatLimit(g_flDrugDuration[index], 0.1, 9999999999.0)) : (g_flDrugDuration2[index] = flSetFloatLimit(g_flDrugDuration2[index], 0.1, 9999999999.0));
	main ? (g_iDrugHit[index] = keyvalues.GetNum("Drug Ability/Drug Hit", 0)) : (g_iDrugHit2[index] = keyvalues.GetNum("Drug Ability/Drug Hit", g_iDrugHit[index]));
	main ? (g_iDrugHit[index] = iSetCellLimit(g_iDrugHit[index], 0, 1)) : (g_iDrugHit2[index] = iSetCellLimit(g_iDrugHit2[index], 0, 1));
	main ? (g_flDrugRange[index] = keyvalues.GetFloat("Drug Ability/Drug Range", 150.0)) : (g_flDrugRange2[index] = keyvalues.GetFloat("Drug Ability/Drug Range", g_flDrugRange[index]));
	main ? (g_flDrugRange[index] = flSetFloatLimit(g_flDrugRange[index], 1.0, 9999999999.0)) : (g_flDrugRange2[index] = flSetFloatLimit(g_flDrugRange2[index], 1.0, 9999999999.0));
}

void vDrug(int client, bool toggle, UserMsg message, float angles[20])
{
	float flAngles[3];
	GetClientEyeAngles(client, flAngles);
	flAngles[2] = toggle ? angles[GetRandomInt(0, 100) % 20] : 0.0;
	TeleportEntity(client, NULL_VECTOR, flAngles, NULL_VECTOR);
	int iClients[2];
	iClients[0] = client;
	int iFlags = toggle ? 0x0002 : (0x0001|0x0010);
	int iColor[4] = {0, 0, 0, 128};
	int iColor2[4] = {0, 0, 0, 0};
	if (toggle)
	{
		iColor[0] = GetRandomInt(0, 255);
		iColor[1] = GetRandomInt(0, 255);
		iColor[2] = GetRandomInt(0, 255);
	}
	Handle hDrugTarget = StartMessageEx(message, iClients, 1);
	if (GetUserMessageType() == UM_Protobuf)
	{
		Protobuf pbSet = UserMessageToProtobuf(hDrugTarget);
		pbSet.SetInt("duration", toggle ? 255: 1536);
		pbSet.SetInt("hold_time", toggle ? 255 : 1536);
		pbSet.SetInt("flags", iFlags);
		pbSet.SetColor("clr", toggle ? iColor : iColor2);
	}
	else
	{
		BfWrite bfWrite = UserMessageToBfWrite(hDrugTarget);
		bfWrite.WriteShort(toggle ? 255 : 1536);
		bfWrite.WriteShort(toggle ? 255 : 1536);
		bfWrite.WriteShort(iFlags);
		bfWrite.WriteByte(toggle ? iColor[0] : iColor2[0]);
		bfWrite.WriteByte(toggle ? iColor[1] : iColor2[1]);
		bfWrite.WriteByte(toggle ? iColor[2] : iColor2[2]);
		bfWrite.WriteByte(toggle ? iColor[3] : iColor2[3]);
	}
	EndMessage();
}

void vDrugHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iDrugAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iDrugAbility[g_iTankType[owner]] : g_iDrugAbility2[g_iTankType[owner]];
	int iDrugChance = !g_bTankConfig[g_iTankType[owner]] ? g_iDrugChance[g_iTankType[owner]] : g_iDrugChance2[g_iTankType[owner]];
	int iDrugHit = !g_bTankConfig[g_iTankType[owner]] ? g_iDrugHit[g_iTankType[owner]] : g_iDrugHit2[g_iTankType[owner]];
	float flDrugRange = !g_bTankConfig[g_iTankType[owner]] ? g_flDrugRange[g_iTankType[owner]] : g_flDrugRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flDrugRange) || toggle == 2) && ((toggle == 1 && iDrugAbility == 1) || (toggle == 2 && iDrugHit == 1)) && GetRandomInt(1, iDrugChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && !g_bDrug[client])
	{
		g_bDrug[client] = true;
		DataPack dpDataPack;
		CreateDataTimer(1.0, tTimerDrug, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
		dpDataPack.WriteFloat(GetEngineTime());
	}
}

void vResetDrug(int client)
{
	g_bDrug[client] = false;
}

public Action tTimerDrug(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	float flTime = pack.ReadFloat();
	float flDrugDuration = !g_bTankConfig[g_iTankType[iTank]] ? g_flDrugDuration[g_iTankType[iTank]] : g_flDrugDuration2[g_iTankType[iTank]];
	if (iTank == 0 || iSurvivor == 0 || !IsClientInGame(iTank) || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iTank) || !IsPlayerAlive(iSurvivor) || (flTime + flDrugDuration) < GetEngineTime())
	{
		g_bDrug[iSurvivor] = false;
		if (bIsSurvivor(iSurvivor))
		{
			vDrug(iSurvivor, false, g_umFadeUserMsgId, g_flDrugAngles);
		}
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		vDrug(iSurvivor, true, g_umFadeUserMsgId, g_flDrugAngles);
	}
	return Plugin_Handled;
}