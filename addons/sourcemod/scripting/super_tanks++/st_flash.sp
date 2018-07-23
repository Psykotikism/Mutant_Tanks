// Super Tanks++: Flash Ability
bool g_bFlash[MAXPLAYERS + 1];
float g_flFlashDuration[ST_MAXTYPES + 1];
float g_flFlashDuration2[ST_MAXTYPES + 1];
float g_flFlashSpeed[ST_MAXTYPES + 1];
float g_flFlashSpeed2[ST_MAXTYPES + 1];
int g_iFlashAbility[ST_MAXTYPES + 1];
int g_iFlashAbility2[ST_MAXTYPES + 1];
int g_iFlashChance[ST_MAXTYPES + 1];
int g_iFlashChance2[ST_MAXTYPES + 1];

void vFlashConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iFlashAbility[index] = keyvalues.GetNum("Flash Ability/Ability Enabled", 0)) : (g_iFlashAbility2[index] = keyvalues.GetNum("Flash Ability/Ability Enabled", g_iFlashAbility[index]));
	main ? (g_iFlashAbility[index] = iSetCellLimit(g_iFlashAbility[index], 0, 1)) : (g_iFlashAbility2[index] = iSetCellLimit(g_iFlashAbility2[index], 0, 1));
	main ? (g_iFlashChance[index] = keyvalues.GetNum("Flash Ability/Flash Chance", 4)) : (g_iFlashChance2[index] = keyvalues.GetNum("Flash Ability/Flash Chance", g_iFlashChance[index]));
	main ? (g_iFlashChance[index] = iSetCellLimit(g_iFlashChance[index], 1, 9999999999)) : (g_iFlashChance2[index] = iSetCellLimit(g_iFlashChance2[index], 1, 9999999999));
	main ? (g_flFlashDuration[index] = keyvalues.GetFloat("Flash Ability/Flash Duration", 5.0)) : (g_flFlashDuration2[index] = keyvalues.GetFloat("Flash Ability/Flash Duration", g_flFlashDuration[index]));
	main ? (g_flFlashDuration[index] = flSetFloatLimit(g_flFlashDuration[index], 0.1, 9999999999.0)) : (g_flFlashDuration2[index] = flSetFloatLimit(g_flFlashDuration2[index], 0.1, 9999999999.0));
	main ? (g_flFlashSpeed[index] = keyvalues.GetFloat("Flash Ability/Flash Speed", 5.0)) : (g_flFlashSpeed2[index] = keyvalues.GetFloat("Flash Ability/Flash Speed", g_flFlashSpeed[index]));
	main ? (g_flFlashSpeed[index] = flSetFloatLimit(g_flFlashSpeed[index], 3.0, 10.0)) : (g_flFlashSpeed2[index] = flSetFloatLimit(g_flFlashSpeed2[index], 3.0, 10.0));
}

void vFlashAbility(int client)
{
	int iFlashAbility = !g_bTankConfig[g_iTankType[client]] ? g_iFlashAbility[g_iTankType[client]] : g_iFlashAbility2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iFlashAbility == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client))
	{
		if (!g_bFlash[client])
		{
			float flRunSpeed = !g_bTankConfig[g_iTankType[client]] ? g_flRunSpeed[g_iTankType[client]] : g_flRunSpeed2[g_iTankType[client]];
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", flRunSpeed);
			int iFlashChance = !g_bTankConfig[g_iTankType[client]] ? g_iFlashChance[g_iTankType[client]] : g_iFlashChance2[g_iTankType[client]];
			if (GetRandomInt(1, iFlashChance) == 1)
			{
				g_bFlash[client] = true;
			}
		}
		else
		{
			float flFlashSpeed = !g_bTankConfig[g_iTankType[client]] ? g_flFlashSpeed[g_iTankType[client]] : g_flFlashSpeed2[g_iTankType[client]];
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", flFlashSpeed);
			float flFlashDuration = !g_bTankConfig[g_iTankType[client]] ? g_flFlashDuration[g_iTankType[client]] : g_flFlashDuration2[g_iTankType[client]];
			CreateTimer(flFlashDuration, tTimerStopFlash, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

void vResetFlash(int client)
{
	g_bFlash[client] = false;
}

public Action tTimerStopFlash(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	int iFlashAbility = !g_bTankConfig[g_iTankType[iTank]] ? g_iFlashAbility[g_iTankType[iTank]] : g_iFlashAbility2[g_iTankType[iTank]];
	if (iFlashAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bFlash[iTank] = false;
		return Plugin_Stop;
	}
	int iCloneMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iCloneMode[g_iTankType[iTank]] : g_iCloneMode2[g_iTankType[iTank]];
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iTank])) && bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		g_bFlash[iTank] = false;
	}
	return Plugin_Continue;
}