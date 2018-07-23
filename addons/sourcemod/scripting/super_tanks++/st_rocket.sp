// Super Tanks++: Rocket Ability
float g_flRocketRange[ST_MAXTYPES + 1];
float g_flRocketRange2[ST_MAXTYPES + 1];
int g_iRocket[ST_MAXTYPES + 1];
int g_iRocketAbility[ST_MAXTYPES + 1];
int g_iRocketAbility2[ST_MAXTYPES + 1];
int g_iRocketChance[ST_MAXTYPES + 1];
int g_iRocketChance2[ST_MAXTYPES + 1];
int g_iRocketHit[ST_MAXTYPES + 1];
int g_iRocketHit2[ST_MAXTYPES + 1];

void vRocketConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iRocketAbility[index] = keyvalues.GetNum("Rocket Ability/Ability Enabled", 0)) : (g_iRocketAbility2[index] = keyvalues.GetNum("Rocket Ability/Ability Enabled", g_iRocketAbility[index]));
	main ? (g_iRocketAbility[index] = iSetCellLimit(g_iRocketAbility[index], 0, 1)) : (g_iRocketAbility2[index] = iSetCellLimit(g_iRocketAbility2[index], 0, 1));
	main ? (g_iRocketChance[index] = keyvalues.GetNum("Rocket Ability/Rocket Chance", 4)) : (g_iRocketChance2[index] = keyvalues.GetNum("Rocket Ability/Rocket Chance", g_iRocketChance[index]));
	main ? (g_iRocketChance[index] = iSetCellLimit(g_iRocketChance[index], 1, 9999999999)) : (g_iRocketChance2[index] = iSetCellLimit(g_iRocketChance2[index], 1, 9999999999));
	main ? (g_iRocketHit[index] = keyvalues.GetNum("Rocket Ability/Rocket Hit", 0)) : (g_iRocketHit2[index] = keyvalues.GetNum("Rocket Ability/Rocket Hit", g_iRocketHit[index]));
	main ? (g_iRocketHit[index] = iSetCellLimit(g_iRocketHit[index], 0, 1)) : (g_iRocketHit2[index] = iSetCellLimit(g_iRocketHit2[index], 0, 1));
	main ? (g_flRocketRange[index] = keyvalues.GetFloat("Rocket Ability/Rocket Range", 150.0)) : (g_flRocketRange2[index] = keyvalues.GetFloat("Rocket Ability/Rocket Range", g_flRocketRange[index]));
	main ? (g_flRocketRange[index] = flSetFloatLimit(g_flRocketRange[index], 1.0, 9999999999.0)) : (g_flRocketRange2[index] = flSetFloatLimit(g_flRocketRange2[index], 1.0, 9999999999.0));
}

void vRocketHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iRocketAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iRocketAbility[g_iTankType[owner]] : g_iRocketAbility2[g_iTankType[owner]];
	int iRocketChance = !g_bTankConfig[g_iTankType[owner]] ? g_iRocketChance[g_iTankType[owner]] : g_iRocketChance2[g_iTankType[owner]];
	int iRocketHit = !g_bTankConfig[g_iTankType[owner]] ? g_iRocketHit[g_iTankType[owner]] : g_iRocketHit2[g_iTankType[owner]];
	float flRocketRange = !g_bTankConfig[g_iTankType[owner]] ? g_flRocketRange[g_iTankType[owner]] : g_flRocketRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flRocketRange) || toggle == 2) && ((toggle == 1 && iRocketAbility == 1) || (toggle == 2 && iRocketHit == 1)) && GetRandomInt(1, iRocketChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client))
	{
		int iFlame = CreateEntityByName("env_steam");
		if (bIsValidEntity(iFlame))
		{
			float flPosition[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPosition);
			flPosition[2] += 30.0;
			float flAngles[3];
			flAngles[0] = 90.0;
			flAngles[1] = 0.0;
			flAngles[2] = 0.0;
			DispatchKeyValue(iFlame, "spawnflags", "1");
			DispatchKeyValue(iFlame, "Type", "0");
			DispatchKeyValue(iFlame, "InitialState", "1");
			DispatchKeyValue(iFlame, "Spreadspeed", "10");
			DispatchKeyValue(iFlame, "Speed", "800");
			DispatchKeyValue(iFlame, "Startsize", "10");
			DispatchKeyValue(iFlame, "EndSize", "250");
			DispatchKeyValue(iFlame, "Rate", "15");
			DispatchKeyValue(iFlame, "JetLength", "400");
			SetEntityRenderColor(iFlame, 180, 70, 10, 180);
			TeleportEntity(iFlame, flPosition, flAngles, NULL_VECTOR);
			DispatchSpawn(iFlame);
			vSetEntityParent(iFlame, client);
			iFlame = EntIndexToEntRef(iFlame);
			vDeleteEntity(iFlame, 3.0);
			g_iRocket[client] = iFlame;
		}
		EmitSoundToAll(SOUND_FIRE, client, _, _, _, 1.0);
		CreateTimer(2.0, tTimerRocketLaunch, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(3.5, tTimerRocketDetonate, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action tTimerRocketLaunch(Handle timer, any userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (iSurvivor == 0 || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iSurvivor))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		float flVelocity[3];
		flVelocity[0] = 0.0;
		flVelocity[1] = 0.0;
		flVelocity[2] = 800.0;
		EmitSoundToAll(SOUND_EXPLOSION, iSurvivor, _, _, _, 1.0);
		EmitSoundToAll(SOUND_LAUNCH, iSurvivor, _, _, _, 1.0);
		TeleportEntity(iSurvivor, NULL_VECTOR, NULL_VECTOR, flVelocity);
		SetEntityGravity(iSurvivor, 0.1);
	}
	return Plugin_Handled;
}

public Action tTimerRocketDetonate(Handle timer, any userid)
{
	int iSurvivor = GetClientOfUserId(userid);
	if (iSurvivor == 0 || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iSurvivor))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(iSurvivor))
	{
		float flPosition[3];
		GetClientAbsOrigin(iSurvivor, flPosition);
		TE_SetupExplosion(flPosition, g_iExplosionSprite, 10.0, 1, 0, 600, 5000);
		TE_SendToAll();
		g_iRocket[iSurvivor] = 0;
		ForcePlayerSuicide(iSurvivor);
		SetEntityGravity(iSurvivor, 1.0);
	}
	return Plugin_Handled;
}