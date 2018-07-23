// Super Tanks++: Restart Ability
bool g_bRestartValid;
char g_sRestartLoadout[ST_MAXTYPES + 1][325];
char g_sRestartLoadout2[ST_MAXTYPES + 1][325];
float g_flRestartPosition[3];
float g_flRestartRange[ST_MAXTYPES + 1];
float g_flRestartRange2[ST_MAXTYPES + 1];
Handle g_hSDKRespawnPlayer;
int g_iRestartAbility[ST_MAXTYPES + 1];
int g_iRestartAbility2[ST_MAXTYPES + 1];
int g_iRestartChance[ST_MAXTYPES + 1];
int g_iRestartChance2[ST_MAXTYPES + 1];
int g_iRestartHit[ST_MAXTYPES + 1];
int g_iRestartHit2[ST_MAXTYPES + 1];

void vRestartSDKCall(Handle gamedata)
{
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(gamedata, SDKConf_Signature, "RoundRespawn");
	g_hSDKRespawnPlayer = EndPrepSDKCall();
	if (g_hSDKRespawnPlayer == null)
	{
		PrintToServer("%s Your \"RoundRespawn\" signature is outdated.", ST_PREFIX);
	}
}

void vRestartConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iRestartAbility[index] = keyvalues.GetNum("Restart Ability/Ability Enabled", 0)) : (g_iRestartAbility2[index] = keyvalues.GetNum("Restart Ability/Ability Enabled", g_iRestartAbility[index]));
	main ? (g_iRestartAbility[index] = iSetCellLimit(g_iRestartAbility[index], 0, 1)) : (g_iRestartAbility2[index] = iSetCellLimit(g_iRestartAbility2[index], 0, 1));
	main ? (g_iRestartChance[index] = keyvalues.GetNum("Restart Ability/Restart Chance", 4)) : (g_iRestartChance2[index] = keyvalues.GetNum("Restart Ability/Restart Chance", g_iRestartChance[index]));
	main ? (g_iRestartChance[index] = iSetCellLimit(g_iRestartChance[index], 1, 9999999999)) : (g_iRestartChance2[index] = iSetCellLimit(g_iRestartChance2[index], 1, 9999999999));
	main ? (g_iRestartHit[index] = keyvalues.GetNum("Restart Ability/Restart Hit", 0)) : (g_iRestartHit2[index] = keyvalues.GetNum("Restart Ability/Restart Hit", g_iRestartHit[index]));
	main ? (g_iRestartHit[index] = iSetCellLimit(g_iRestartHit[index], 0, 1)) : (g_iRestartHit2[index] = iSetCellLimit(g_iRestartHit2[index], 0, 1));
	main ? (keyvalues.GetString("Restart Ability/Restart Loadout", g_sRestartLoadout[index], sizeof(g_sRestartLoadout[]), "smg,pistol,pain_pills")) : (keyvalues.GetString("Restart Ability/Restart Loadout", g_sRestartLoadout2[index], sizeof(g_sRestartLoadout2[]), g_sRestartLoadout[index]));
	main ? (g_flRestartRange[index] = keyvalues.GetFloat("Restart Ability/Restart Range", 150.0)) : (g_flRestartRange2[index] = keyvalues.GetFloat("Restart Ability/Restart Range", g_flRestartRange[index]));
	main ? (g_flRestartRange[index] = flSetFloatLimit(g_flRestartRange[index], 1.0, 9999999999.0)) : (g_flRestartRange2[index] = flSetFloatLimit(g_flRestartRange2[index], 1.0, 9999999999.0));
}

void vRestartHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iRestartAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iRestartAbility[g_iTankType[owner]] : g_iRestartAbility2[g_iTankType[owner]];
	int iRestartChance = !g_bTankConfig[g_iTankType[owner]] ? g_iRestartChance[g_iTankType[owner]] : g_iRestartChance2[g_iTankType[owner]];
	int iRestartHit = !g_bTankConfig[g_iTankType[owner]] ? g_iRestartHit[g_iTankType[owner]] : g_iRestartHit2[g_iTankType[owner]];
	float flRestartRange = !g_bTankConfig[g_iTankType[owner]] ? g_flRestartRange[g_iTankType[owner]] : g_flRestartRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flRestartRange) || toggle == 2) && ((toggle == 1 && iRestartAbility == 1) || (toggle == 2 && iRestartHit == 1)) && GetRandomInt(1, iRestartChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client))
	{
		SDKCall(g_hSDKRespawnPlayer, client);
		char sRestartLoadout[325];
		sRestartLoadout = !g_bTankConfig[g_iTankType[owner]] ? g_sRestartLoadout[g_iTankType[owner]] : g_sRestartLoadout2[g_iTankType[owner]];
		vGiveItem(client, sRestartLoadout);
		g_bRestartValid ? TeleportEntity(client, g_flRestartPosition, NULL_VECTOR, NULL_VECTOR) : vIdleWarp(client);
	}
}

public Action tTimerRestartCoordinates(Handle timer)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor))
		{
			g_bRestartValid = true;
			g_flRestartPosition[0] = 0.0;
			g_flRestartPosition[1] = 0.0;
			g_flRestartPosition[2] = 0.0;
			GetClientAbsOrigin(iSurvivor, g_flRestartPosition);
			break;
		}
	}
}