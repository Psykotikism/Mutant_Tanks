// Super Tanks++: Idle Ability
bool g_bIdle[MAXPLAYERS + 1];
bool g_bIdled[MAXPLAYERS + 1];
float g_flIdleRange[ST_MAXTYPES + 1];
float g_flIdleRange2[ST_MAXTYPES + 1];
Handle g_hSDKIdlePlayer;
Handle g_hSDKSpecPlayer;
int g_iIdleAbility[ST_MAXTYPES + 1];
int g_iIdleAbility2[ST_MAXTYPES + 1];
int g_iIdleChance[ST_MAXTYPES + 1];
int g_iIdleChance2[ST_MAXTYPES + 1];
int g_iIdleHit[ST_MAXTYPES + 1];
int g_iIdleHit2[ST_MAXTYPES + 1];

void vIdleSDKCalls(Handle gamedata)
{
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "CTerrorPlayer::GoAwayFromKeyboard");
	g_hSDKIdlePlayer = EndPrepSDKCall();
	if (g_hSDKIdlePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer::GoAwayFromKeyboard\" signature is outdated.", ST_PREFIX);
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "SetHumanSpec");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	g_hSDKSpecPlayer = EndPrepSDKCall();
	if (g_hSDKSpecPlayer == null)
	{
		PrintToServer("%s Your \"SetHumanSpec\" signature is outdated.", ST_PREFIX);
	}
}

void vIdleConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iIdleAbility[index] = keyvalues.GetNum("Idle Ability/Ability Enabled", 0)) : (g_iIdleAbility2[index] = keyvalues.GetNum("Idle Ability/Ability Enabled", g_iIdleAbility[index]));
	main ? (g_iIdleAbility[index] = iSetCellLimit(g_iIdleAbility[index], 0, 1)) : (g_iIdleAbility2[index] = iSetCellLimit(g_iIdleAbility2[index], 0, 1));
	main ? (g_iIdleChance[index] = keyvalues.GetNum("Idle Ability/Idle Chance", 4)) : (g_iIdleChance2[index] = keyvalues.GetNum("Idle Ability/Idle Chance", g_iIdleChance[index]));
	main ? (g_iIdleChance[index] = iSetCellLimit(g_iIdleChance[index], 1, 9999999999)) : (g_iIdleChance2[index] = iSetCellLimit(g_iIdleChance2[index], 1, 9999999999));
	main ? (g_iIdleHit[index] = keyvalues.GetNum("Idle Ability/Idle Hit", 0)) : (g_iIdleHit2[index] = keyvalues.GetNum("Idle Ability/Idle Hit", g_iIdleHit[index]));
	main ? (g_iIdleHit[index] = iSetCellLimit(g_iIdleHit[index], 0, 1)) : (g_iIdleHit2[index] = iSetCellLimit(g_iIdleHit2[index], 0, 1));
	main ? (g_flIdleRange[index] = keyvalues.GetFloat("Idle Ability/Idle Range", 150.0)) : (g_flIdleRange2[index] = keyvalues.GetFloat("Idle Ability/Idle Range", g_flIdleRange[index]));
	main ? (g_flIdleRange[index] = flSetFloatLimit(g_flIdleRange[index], 1.0, 9999999999.0)) : (g_flIdleRange2[index] = flSetFloatLimit(g_flIdleRange2[index], 1.0, 9999999999.0));
}

void vIdle(int client, int bot)
{
	DataPack dpDataPack;
	CreateDataTimer(0.2, tTimerIdleFix, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
	dpDataPack.WriteCell(GetClientUserId(client));
	dpDataPack.WriteCell(GetClientUserId(bot));
	if (g_bIdle[client])
	{
		g_bIdle[client] = false;
		vIdleWarp(bot);
	}
}

void vIdleHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iIdleAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iIdleAbility[g_iTankType[owner]] : g_iIdleAbility2[g_iTankType[owner]];
	int iIdleChance = !g_bTankConfig[g_iTankType[owner]] ? g_iIdleChance[g_iTankType[owner]] : g_iIdleChance2[g_iTankType[owner]];
	int iIdleHit = !g_bTankConfig[g_iTankType[owner]] ? g_iIdleHit[g_iTankType[owner]] : g_iIdleHit2[g_iTankType[owner]];
	float flIdleRange = !g_bTankConfig[g_iTankType[owner]] ? g_flIdleRange[g_iTankType[owner]] : g_flIdleRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flIdleRange) || toggle == 2) && ((toggle == 1 && iIdleAbility == 1) || (toggle == 2 && iIdleHit == 1)) && GetRandomInt(1, iIdleChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsHumanSurvivor(client) && !g_bIdle[client])
	{
		if (iGetHumanCount() > 1)
		{
			FakeClientCommand(client, "go_away_from_keyboard");
		}
		else
		{
			vIdleWarp(client);
			SDKCall(g_hSDKIdlePlayer, client);
		}
		if (bIsBotIdle(client))
		{
			g_bIdled[client] = true;
			g_bIdle[client] = true;
		}
	}
}

void vIdleWarp(int client)
{
	float flCurrentOrigin[3];
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (!bIsSurvivor(iPlayer) || iPlayer == client)
		{
			continue;
		}
		GetClientAbsOrigin(iPlayer, flCurrentOrigin);
		TeleportEntity(client, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);
	}
}

void vResetIdle(int client)
{
	g_bIdle[client] = false;
	g_bIdled[client] = false;
}

int iGetBotSurvivor()
{
	for (int iBot = MaxClients; iBot >= 1; iBot--)
	{
		if (bIsBotSurvivor(iBot))
		{
			return iBot;
		}
	}
	return -1;
}

int iGetIdleBot(int client)
{
	for (int iBot = 1; iBot <= MaxClients; iBot++)
	{
		if (iGetIdlePlayer(iBot) == client)
		{
			return iBot;
		}
	}
	return 0;
}

int iGetIdlePlayer(int client)
{
	if (bIsBotSurvivor(client))
	{
		char sClassname[12];
		GetEntityNetClass(client, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "SurvivorBot") == 0)
		{
			int iIdler = GetClientOfUserId(GetEntProp(client, Prop_Send, "m_humanSpectatorUserID"));
			if (iIdler > 0 && IsClientInGame(iIdler) && GetClientTeam(iIdler) == 1)
			{
				return iIdler;
			}
		}
	}
	return 0;
}

public Action tTimerIdleFix(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iBot = GetClientOfUserId(pack.ReadCell());
	if (iSurvivor == 0 || iBot == 0 || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iSurvivor) || !IsClientInGame(iBot) || !IsPlayerAlive(iSurvivor))
	{
		return Plugin_Stop;
	}
	if (GetClientTeam(iSurvivor) != 1 || iGetIdleBot(iSurvivor) || IsFakeClient(iSurvivor))
	{
		g_bIdled[iSurvivor] = false;
	}
	if (!bIsBotIdleSurvivor(iBot) || GetClientTeam(iBot) != 2)
	{
		iBot = iGetBotSurvivor();
	}
	if (iBot < 1)
	{
		g_bIdled[iSurvivor] = false;
	}
	if (g_bIdled[iSurvivor])
	{
		g_bIdled[iSurvivor] = false;
		SDKCall(g_hSDKSpecPlayer, iBot, iSurvivor);
		SetEntProp(iSurvivor, Prop_Send, "m_iObserverMode", 5);
	}
	return Plugin_Continue;
}