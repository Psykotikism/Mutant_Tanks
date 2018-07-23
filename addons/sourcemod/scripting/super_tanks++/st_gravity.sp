// Super Tanks++: Gravity Ability
bool g_bGravity[MAXPLAYERS + 1];
bool g_bGravity2[MAXPLAYERS + 1];
float g_flGravityDuration[ST_MAXTYPES + 1];
float g_flGravityDuration2[ST_MAXTYPES + 1];
float g_flGravityForce[ST_MAXTYPES + 1];
float g_flGravityForce2[ST_MAXTYPES + 1];
float g_flGravityRange[ST_MAXTYPES + 1];
float g_flGravityRange2[ST_MAXTYPES + 1];
float g_flGravityValue[ST_MAXTYPES + 1];
float g_flGravityValue2[ST_MAXTYPES + 1];
int g_iGravityAbility[ST_MAXTYPES + 1];
int g_iGravityAbility2[ST_MAXTYPES + 1];
int g_iGravityChance[ST_MAXTYPES + 1];
int g_iGravityChance2[ST_MAXTYPES + 1];
int g_iGravityHit[ST_MAXTYPES + 1];
int g_iGravityHit2[ST_MAXTYPES + 1];

void vGravityConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iGravityAbility[index] = keyvalues.GetNum("Gravity Ability/Ability Enabled", 0)) : (g_iGravityAbility2[index] = keyvalues.GetNum("Gravity Ability/Ability Enabled", g_iGravityAbility[index]));
	main ? (g_iGravityAbility[index] = iSetCellLimit(g_iGravityAbility[index], 0, 1)) : (g_iGravityAbility2[index] = iSetCellLimit(g_iGravityAbility2[index], 0, 1));
	main ? (g_iGravityChance[index] = keyvalues.GetNum("Gravity Ability/Gravity Chance", 4)) : (g_iGravityChance2[index] = keyvalues.GetNum("Gravity Ability/Gravity Chance", g_iGravityChance[index]));
	main ? (g_iGravityChance[index] = iSetCellLimit(g_iGravityChance[index], 1, 9999999999)) : (g_iGravityChance2[index] = iSetCellLimit(g_iGravityChance2[index], 1, 9999999999));
	main ? (g_flGravityDuration[index] = keyvalues.GetFloat("Gravity Ability/Gravity Duration", 5.0)) : (g_flGravityDuration2[index] = keyvalues.GetFloat("Gravity Ability/Gravity Duration", g_flGravityDuration[index]));
	main ? (g_flGravityDuration[index] = flSetFloatLimit(g_flGravityDuration[index], 0.1, 9999999999.0)) : (g_flGravityDuration2[index] = flSetFloatLimit(g_flGravityDuration2[index], 0.1, 9999999999.0));
	main ? (g_flGravityForce[index] = keyvalues.GetFloat("Gravity Ability/Gravity Force", -50.0)) : (g_flGravityForce2[index] = keyvalues.GetFloat("Gravity Ability/Gravity Force", g_flGravityForce[index]));
	main ? (g_flGravityForce[index] = flSetFloatLimit(g_flGravityForce[index], -100.0, 100.0)) : (g_flGravityForce2[index] = flSetFloatLimit(g_flGravityForce2[index], -100.0, 100.0));
	main ? (g_iGravityHit[index] = keyvalues.GetNum("Gravity Ability/Gravity Hit", 0)) : (g_iGravityHit2[index] = keyvalues.GetNum("Gravity Ability/Gravity Hit", g_iGravityHit[index]));
	main ? (g_iGravityHit[index] = iSetCellLimit(g_iGravityHit[index], 0, 1)) : (g_iGravityHit2[index] = iSetCellLimit(g_iGravityHit2[index], 0, 1));
	main ? (g_flGravityRange[index] = keyvalues.GetFloat("Gravity Ability/Gravity Range", 150.0)) : (g_flGravityRange2[index] = keyvalues.GetFloat("Gravity Ability/Gravity Range", g_flGravityRange[index]));
	main ? (g_flGravityRange[index] = flSetFloatLimit(g_flGravityRange[index], 1.0, 9999999999.0)) : (g_flGravityRange2[index] = flSetFloatLimit(g_flGravityRange2[index], 1.0, 9999999999.0));
	main ? (g_flGravityValue[index] = keyvalues.GetFloat("Gravity Ability/Gravity Value", 0.3)) : (g_flGravityValue2[index] = keyvalues.GetFloat("Gravity Ability/Gravity Value", g_flGravityValue[index]));
	main ? (g_flGravityValue[index] = flSetFloatLimit(g_flGravityValue[index], 0.1, 0.99)) : (g_flGravityValue2[index] = flSetFloatLimit(g_flGravityValue2[index], 0.1, 0.99));
}

void vGravityDeath(int client)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor) && g_bGravity2[iSurvivor])
		{
			DataPack dpDataPack;
			CreateDataTimer(0.1, tTimerStopGravity, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
			dpDataPack.WriteCell(GetClientUserId(iSurvivor));
			dpDataPack.WriteCell(GetClientUserId(client));
		}
	}
}

void vGravityAbility(int client)
{
	int iGravityAbility = !g_bTankConfig[g_iTankType[client]] ? g_iGravityAbility[g_iTankType[client]] : g_iGravityAbility2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iGravityAbility == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client) && !g_bGravity[client])
	{
		g_bGravity[client] = true;
		float flGravityForce = !g_bTankConfig[g_iTankType[client]] ? g_flGravityForce[g_iTankType[client]] : g_flGravityForce2[g_iTankType[client]];
		int iBlackhole = CreateEntityByName("point_push");
		if (bIsValidEntity(iBlackhole))
		{
			float flOrigin[3];
			float flAngles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
			flAngles[0] += -90.0;
			DispatchKeyValueVector(iBlackhole, "origin", flOrigin);
			DispatchKeyValueVector(iBlackhole, "angles", flAngles);
			DispatchKeyValue(iBlackhole, "radius", "750");
			DispatchKeyValueFloat(iBlackhole, "magnitude", flGravityForce);
			DispatchKeyValue(iBlackhole, "spawnflags", "8");
			vSetEntityParent(iBlackhole, client);
			AcceptEntityInput(iBlackhole, "Enable");
			SetEntPropEnt(iBlackhole, Prop_Send, "m_hOwnerEntity", client);
			if (bIsL4D2Game())
			{
				SetEntProp(iBlackhole, Prop_Send, "m_glowColorOverride", client);
			}
		}
	}
}

void vGravityHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iGravityAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iGravityAbility[g_iTankType[owner]] : g_iGravityAbility2[g_iTankType[owner]];
	int iGravityChance = !g_bTankConfig[g_iTankType[owner]] ? g_iGravityChance[g_iTankType[owner]] : g_iGravityChance2[g_iTankType[owner]];
	int iGravityHit = !g_bTankConfig[g_iTankType[owner]] ? g_iGravityHit[g_iTankType[owner]] : g_iGravityHit2[g_iTankType[owner]];
	float flGravityRange = !g_bTankConfig[g_iTankType[owner]] ? g_flGravityRange[g_iTankType[owner]] : g_flGravityRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flGravityRange) || toggle == 2) && ((toggle == 1 && iGravityAbility == 1) || (toggle == 2 && iGravityHit == 1)) && GetRandomInt(1, iGravityChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && !g_bGravity2[client])
	{
		g_bGravity2[client] = true;
		float flGravityValue = !g_bTankConfig[g_iTankType[owner]] ? g_flGravityValue[g_iTankType[owner]] : g_flGravityValue2[g_iTankType[owner]];
		SetEntityGravity(client, flGravityValue);
		float flGravityDuration = !g_bTankConfig[g_iTankType[owner]] ? g_flGravityDuration[g_iTankType[owner]] : g_flGravityDuration2[g_iTankType[owner]];
		DataPack dpDataPack;
		CreateDataTimer(flGravityDuration, tTimerStopGravity, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteCell(GetClientUserId(owner));
	}
}

void vResetGravity(int client)
{
	g_bGravity[client] = false;
	g_bGravity2[client] = false;
}

public Action tTimerStopGravity(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (iTank == 0 || iSurvivor == 0 || !IsClientInGame(iTank) || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iTank) || !IsPlayerAlive(iSurvivor))
	{
		g_bGravity2[iSurvivor] = false;
		if (bIsSurvivor(iSurvivor))
		{
			SetEntityGravity(iSurvivor, 1.0);
		}
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		g_bGravity2[iSurvivor] = false;
		SetEntityGravity(iSurvivor, 1.0);
	}
	return Plugin_Continue;
}