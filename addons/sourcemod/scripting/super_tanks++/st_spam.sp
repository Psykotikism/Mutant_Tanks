// Super Tanks++: Spam Ability
bool g_bSpam[MAXPLAYERS + 1];
float g_flSpamDuration[ST_MAXTYPES + 1];
float g_flSpamDuration2[ST_MAXTYPES + 1];
int g_iSpamAbility[ST_MAXTYPES + 1];
int g_iSpamAbility2[ST_MAXTYPES + 1];
int g_iSpamChance[ST_MAXTYPES + 1];
int g_iSpamChance2[ST_MAXTYPES + 1];
int g_iSpamDamage[ST_MAXTYPES + 1];
int g_iSpamDamage2[ST_MAXTYPES + 1];

void vSpamConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iSpamAbility[index] = keyvalues.GetNum("Spam Ability/Ability Enabled", 0)) : (g_iSpamAbility2[index] = keyvalues.GetNum("Spam Ability/Ability Enabled", g_iSpamAbility[index]));
	main ? (g_iSpamAbility[index] = iSetCellLimit(g_iSpamAbility[index], 0, 1)) : (g_iSpamAbility2[index] = iSetCellLimit(g_iSpamAbility2[index], 0, 1));
	main ? (g_iSpamChance[index] = keyvalues.GetNum("Spam Ability/Spam Chance", 4)) : (g_iSpamChance2[index] = keyvalues.GetNum("Spam Ability/Spam Chance", g_iSpamChance[index]));
	main ? (g_iSpamChance[index] = iSetCellLimit(g_iSpamChance[index], 1, 9999999999)) : (g_iSpamChance2[index] = iSetCellLimit(g_iSpamChance2[index], 1, 9999999999));
	main ? (g_iSpamDamage[index] = keyvalues.GetNum("Spam Ability/Spam Damage", 5)) : (g_iSpamDamage2[index] = keyvalues.GetNum("Spam Ability/Spam Damage", g_iSpamDamage[index]));
	main ? (g_iSpamDamage[index] = iSetCellLimit(g_iSpamDamage[index], 1, 9999999999)) : (g_iSpamDamage2[index] = iSetCellLimit(g_iSpamDamage2[index], 1, 9999999999));
	main ? (g_flSpamDuration[index] = keyvalues.GetFloat("Spam Ability/Spam Duration", 5.0)) : (g_flSpamDuration2[index] = keyvalues.GetFloat("Spam Ability/Spam Duration", g_flSpamDuration[index]));
	main ? (g_flSpamDuration[index] = flSetFloatLimit(g_flSpamDuration[index], 0.1, 9999999999.0)) : (g_flSpamDuration2[index] = flSetFloatLimit(g_flSpamDuration2[index], 0.1, 9999999999.0));
}

void vSpamAbility(int client)
{
	int iSpamAbility = !g_bTankConfig[g_iTankType[client]] ? g_iSpamAbility[g_iTankType[client]] : g_iSpamAbility2[g_iTankType[client]];
	int iSpamChance = !g_bTankConfig[g_iTankType[client]] ? g_iSpamChance[g_iTankType[client]] : g_iSpamChance2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iSpamAbility == 1 && GetRandomInt(1, iSpamChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client) && !g_bSpam[client])
	{
		g_bSpam[client] = true;
		DataPack dpDataPack;
		CreateDataTimer(0.5, tTimerSpam, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteFloat(GetEngineTime());
	}
}

void vResetSpam(int client)
{
	g_bSpam[client] = false;
}

public Action tTimerSpam(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	float flTime = pack.ReadFloat();
	int iSpamAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iSpamAbility[g_iTankType[iTank]] : g_iSpamAbility2[g_iTankType[iTank]];
	float flSpamDuration = !g_bTankConfig[g_iTankType[iTank]] ? g_flSpamDuration[g_iTankType[iTank]] : g_flSpamDuration2[g_iTankType[iTank]];
	if (iSpamAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank) || (flTime + flSpamDuration) < GetEngineTime())
	{
		g_bSpam[iTank] = false;
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		char sDamage[6];
		int iSpamDamage = !g_bTankConfig[g_iTankType[iTank]] ? g_iSpamDamage[g_iTankType[iTank]] : g_iSpamDamage2[g_iTankType[iTank]];
		IntToString(iSpamDamage, sDamage, sizeof(sDamage));
		float flPos[3];
		float flAng[3];
		GetClientEyePosition(iTank, flPos);
		GetClientEyeAngles(iTank, flAng);
		flPos[2] += 80.0;
		int iSpammer = CreateEntityByName("env_rock_launcher");
		if (bIsValidEntity(iSpammer))
		{
			DispatchKeyValue(iSpammer, "rockdamageoverride", sDamage);
			TeleportEntity(iSpammer, flPos, flAng, NULL_VECTOR);
			DispatchSpawn(iSpammer);
			AcceptEntityInput(iSpammer, "LaunchRock");
			AcceptEntityInput(iSpammer, "Kill");
		}
	}
	return Plugin_Continue;
}