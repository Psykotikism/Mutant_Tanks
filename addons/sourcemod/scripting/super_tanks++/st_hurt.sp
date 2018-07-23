// Super Tanks++: Hurt Ability
bool g_bHurt[MAXPLAYERS + 1];
float g_flHurtDuration[ST_MAXTYPES + 1];
float g_flHurtDuration2[ST_MAXTYPES + 1];
float g_flHurtRange[ST_MAXTYPES + 1];
float g_flHurtRange2[ST_MAXTYPES + 1];
int g_iHurtAbility[ST_MAXTYPES + 1];
int g_iHurtAbility2[ST_MAXTYPES + 1];
int g_iHurtChance[ST_MAXTYPES + 1];
int g_iHurtChance2[ST_MAXTYPES + 1];
int g_iHurtDamage[ST_MAXTYPES + 1];
int g_iHurtDamage2[ST_MAXTYPES + 1];
int g_iHurtHit[ST_MAXTYPES + 1];
int g_iHurtHit2[ST_MAXTYPES + 1];

void vHurtConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iHurtAbility[index] = keyvalues.GetNum("Hurt Ability/Ability Enabled", 0)) : (g_iHurtAbility2[index] = keyvalues.GetNum("Hurt Ability/Ability Enabled", g_iHurtAbility[index]));
	main ? (g_iHurtAbility[index] = iSetCellLimit(g_iHurtAbility[index], 0, 1)) : (g_iHurtAbility2[index] = iSetCellLimit(g_iHurtAbility2[index], 0, 1));
	main ? (g_iHurtChance[index] = keyvalues.GetNum("Hurt Ability/Hurt Chance", 4)) : (g_iHurtChance2[index] = keyvalues.GetNum("Hurt Ability/Hurt Chance", g_iHurtChance[index]));
	main ? (g_iHurtChance[index] = iSetCellLimit(g_iHurtChance[index], 1, 9999999999)) : (g_iHurtChance2[index] = iSetCellLimit(g_iHurtChance2[index], 1, 9999999999));
	main ? (g_iHurtDamage[index] = keyvalues.GetNum("Hurt Ability/Hurt Damage", 1)) : (g_iHurtDamage2[index] = keyvalues.GetNum("Hurt Ability/Hurt Damage", g_iHurtDamage[index]));
	main ? (g_iHurtDamage[index] = iSetCellLimit(g_iHurtDamage[index], 1, 9999999999)) : (g_iHurtDamage2[index] = iSetCellLimit(g_iHurtDamage2[index], 1, 9999999999));
	main ? (g_flHurtDuration[index] = keyvalues.GetFloat("Hurt Ability/Hurt Duration", 5.0)) : (g_flHurtDuration2[index] = keyvalues.GetFloat("Hurt Ability/Hurt Duration", g_flHurtDuration[index]));
	main ? (g_flHurtDuration[index] = flSetFloatLimit(g_flHurtDuration[index], 0.1, 9999999999.0)) : (g_flHurtDuration2[index] = flSetFloatLimit(g_flHurtDuration2[index], 0.1, 9999999999.0));
	main ? (g_iHurtHit[index] = keyvalues.GetNum("Hurt Ability/Hurt Hit", 0)) : (g_iHurtHit2[index] = keyvalues.GetNum("Hurt Ability/Hurt Hit", g_iHurtHit[index]));
	main ? (g_iHurtHit[index] = iSetCellLimit(g_iHurtHit[index], 0, 1)) : (g_iHurtHit2[index] = iSetCellLimit(g_iHurtHit2[index], 0, 1));
	main ? (g_flHurtRange[index] = keyvalues.GetFloat("Hurt Ability/Hurt Range", 150.0)) : (g_flHurtRange2[index] = keyvalues.GetFloat("Hurt Ability/Hurt Range", g_flHurtRange[index]));
	main ? (g_flHurtRange[index] = flSetFloatLimit(g_flHurtRange[index], 1.0, 9999999999.0)) : (g_flHurtRange2[index] = flSetFloatLimit(g_flHurtRange2[index], 1.0, 9999999999.0));
}

void vHurtHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iHurtAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iHurtAbility[g_iTankType[owner]] : g_iHurtAbility2[g_iTankType[owner]];
	int iHurtChance = !g_bTankConfig[g_iTankType[owner]] ? g_iHurtChance[g_iTankType[owner]] : g_iHurtChance2[g_iTankType[owner]];
	int iHurtHit = !g_bTankConfig[g_iTankType[owner]] ? g_iHurtHit[g_iTankType[owner]] : g_iHurtHit2[g_iTankType[owner]];
	float flHurtRange = !g_bTankConfig[g_iTankType[owner]] ? g_flHurtRange[g_iTankType[owner]] : g_flHurtRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flHurtRange) || toggle == 2) && ((toggle == 1 && iHurtAbility == 1) || (toggle == 2 && iHurtHit == 1)) && GetRandomInt(1, iHurtChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && !g_bHurt[client])
	{
		g_bHurt[client] = true;
		DataPack dpDataPack;
		CreateDataTimer(1.0, tTimerHurt, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
		dpDataPack.WriteFloat(GetEngineTime());
	}
}

void vResetHurt(int client)
{
	g_bHurt[client] = false;
}

public Action tTimerHurt(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	float flTime = pack.ReadFloat();
	float flHurtDuration = !g_bTankConfig[g_iTankType[iTank]] ? g_flHurtDuration[g_iTankType[iTank]] : g_flHurtDuration2[g_iTankType[iTank]];
	if (iTank == 0 || iSurvivor == 0 || !IsClientInGame(iTank) || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iTank) || !IsPlayerAlive(iSurvivor) || (flTime + flHurtDuration) < GetEngineTime())
	{
		g_bHurt[iSurvivor] = false;
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))) && bIsSurvivor(iSurvivor))
	{
		char sDamage[6];
		int iHurtDamage = !g_bTankConfig[g_iTankType[iTank]] ? g_iHurtDamage[g_iTankType[iTank]] : g_iHurtDamage2[g_iTankType[iTank]];
		IntToString(iHurtDamage, sDamage, sizeof(sDamage));
		int iPointHurt = CreateEntityByName("point_hurt");
		if (bIsValidEntity(iPointHurt))
		{
			DispatchKeyValue(iSurvivor, "targetname", "hurtme");
			DispatchKeyValue(iPointHurt, "Damage", sDamage);
			DispatchKeyValue(iPointHurt, "DamageTarget", "hurtme");
			DispatchKeyValue(iPointHurt, "DamageType", "2");
			DispatchSpawn(iPointHurt);
			AcceptEntityInput(iPointHurt, "Hurt", iSurvivor);
			AcceptEntityInput(iPointHurt, "Kill");
			DispatchKeyValue(iSurvivor, "targetname", "donthurtme");
		}
	}
	return Plugin_Continue;
}