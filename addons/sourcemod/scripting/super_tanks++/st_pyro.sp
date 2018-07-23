// Super Tanks++: Pyro Ability
bool g_bPyro[MAXPLAYERS + 1];
float g_flPyroBoost[ST_MAXTYPES + 1];
float g_flPyroBoost2[ST_MAXTYPES + 1];
int g_iPyroAbility[ST_MAXTYPES + 1];
int g_iPyroAbility2[ST_MAXTYPES + 1];

void vPyroConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iPyroAbility[index] = keyvalues.GetNum("Pyro Ability/Ability Enabled", 0)) : (g_iPyroAbility2[index] = keyvalues.GetNum("Pyro Ability/Ability Enabled", g_iPyroAbility[index]));
	main ? (g_iPyroAbility[index] = iSetCellLimit(g_iPyroAbility[index], 0, 1)) : (g_iPyroAbility2[index] = iSetCellLimit(g_iPyroAbility2[index], 0, 1));
	main ? (g_flPyroBoost[index] = keyvalues.GetFloat("Pyro Ability/Pyro Boost", 1.0)) : (g_flPyroBoost2[index] = keyvalues.GetFloat("Pyro Ability/Pyro Boost", g_flPyroBoost[index]));
	main ? (g_flPyroBoost[index] = flSetFloatLimit(g_flPyroBoost[index], 0.1, 3.0)) : (g_flPyroBoost2[index] = flSetFloatLimit(g_flPyroBoost2[index], 0.1, 3.0));
}

void vResetPyro(int client)
{
	g_bPyro[client] = false;
}

public Action tTimerPyro(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	int iPyroAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iPyroAbility[g_iTankType[iTank]] : g_iPyroAbility2[g_iTankType[iTank]];
	if (iPyroAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bPyro[iTank] = false;
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		float flPyroBoost = !g_bTankConfig[g_iTankType[iTank]] ? g_flPyroBoost[g_iTankType[iTank]] : g_flPyroBoost2[g_iTankType[iTank]];
		if (bIsPlayerFired(iTank) && !g_bPyro[iTank])
		{
			g_bPyro[iTank] = true;
			float flCurrentSpeed = GetEntPropFloat(iTank, Prop_Data, "m_flLaggedMovementValue");
			SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", flCurrentSpeed + flPyroBoost);
		}
		else if (g_bPyro[iTank])
		{
			g_bPyro[iTank] = false;
			float flCurrentSpeed = GetEntPropFloat(iTank, Prop_Data, "m_flLaggedMovementValue");
			SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", flCurrentSpeed - flPyroBoost);
		}
	}
	return Plugin_Continue;
}