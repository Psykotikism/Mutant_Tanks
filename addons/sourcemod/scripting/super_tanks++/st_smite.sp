// Super Tanks++: Smite Ability
float g_flSmiteRange[ST_MAXTYPES + 1];
float g_flSmiteRange2[ST_MAXTYPES + 1];
int g_iSmiteAbility[ST_MAXTYPES + 1];
int g_iSmiteAbility2[ST_MAXTYPES + 1];
int g_iSmiteChance[ST_MAXTYPES + 1];
int g_iSmiteChance2[ST_MAXTYPES + 1];
int g_iSmiteHit[ST_MAXTYPES + 1];
int g_iSmiteHit2[ST_MAXTYPES + 1];
int g_iSmiteSprite = -1;

void vSmiteConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iSmiteAbility[index] = keyvalues.GetNum("Smite Ability/Ability Enabled", 0)) : (g_iSmiteAbility2[index] = keyvalues.GetNum("Smite Ability/Ability Enabled", g_iSmiteAbility[index]));
	main ? (g_iSmiteAbility[index] = iSetCellLimit(g_iSmiteAbility[index], 0, 1)) : (g_iSmiteAbility2[index] = iSetCellLimit(g_iSmiteAbility2[index], 0, 1));
	main ? (g_iSmiteChance[index] = keyvalues.GetNum("Smite Ability/Smite Chance", 4)) : (g_iSmiteChance2[index] = keyvalues.GetNum("Smite Ability/Smite Chance", g_iSmiteChance[index]));
	main ? (g_iSmiteChance[index] = iSetCellLimit(g_iSmiteChance[index], 1, 9999999999)) : (g_iSmiteChance2[index] = iSetCellLimit(g_iSmiteChance2[index], 1, 9999999999));
	main ? (g_iSmiteHit[index] = keyvalues.GetNum("Smite Ability/Smite Hit", 0)) : (g_iSmiteHit2[index] = keyvalues.GetNum("Smite Ability/Smite Hit", g_iSmiteHit[index]));
	main ? (g_iSmiteHit[index] = iSetCellLimit(g_iSmiteHit[index], 0, 1)) : (g_iSmiteHit2[index] = iSetCellLimit(g_iSmiteHit2[index], 0, 1));
	main ? (g_flSmiteRange[index] = keyvalues.GetFloat("Smite Ability/Smite Range", 150.0)) : (g_flSmiteRange2[index] = keyvalues.GetFloat("Smite Ability/Smite Range", g_flSmiteRange[index]));
	main ? (g_flSmiteRange[index] = flSetFloatLimit(g_flSmiteRange[index], 1.0, 9999999999.0)) : (g_flSmiteRange2[index] = flSetFloatLimit(g_flSmiteRange2[index], 1.0, 9999999999.0));
}

void vSmiteHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iSmiteAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iSmiteAbility[g_iTankType[owner]] : g_iSmiteAbility2[g_iTankType[owner]];
	int iSmiteChance = !g_bTankConfig[g_iTankType[owner]] ? g_iSmiteChance[g_iTankType[owner]] : g_iSmiteChance2[g_iTankType[owner]];
	int iSmiteHit = !g_bTankConfig[g_iTankType[owner]] ? g_iSmiteHit[g_iTankType[owner]] : g_iSmiteHit2[g_iTankType[owner]];
	float flSmiteRange = !g_bTankConfig[g_iTankType[owner]] ? g_flSmiteRange[g_iTankType[owner]] : g_flSmiteRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flSmiteRange) || toggle == 2) && ((toggle == 1 && iSmiteAbility == 1) || (toggle == 2 && iSmiteHit == 1)) && GetRandomInt(1, iSmiteChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client))
	{
		float flPosition[3];
		GetClientAbsOrigin(client, flPosition);
		flPosition[2] -= 26;
		float flStartPosition[3];
		flStartPosition[0] = flPosition[0] + GetRandomInt(-500, 500);
		flStartPosition[1] = flPosition[1] + GetRandomInt(-500, 500);
		flStartPosition[2] = flPosition[2] + 800;
		int iColor[4] = {255, 255, 255, 255};
		float flDirection[3] = {0.0, 0.0, 0.0};
		TE_SetupBeamPoints(flStartPosition, flPosition, g_iSmiteSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, iColor, 3);
		TE_SendToAll();
		TE_SetupSparks(flPosition, flDirection, 5000, 1000);
		TE_SendToAll();
		TE_SetupEnergySplash(flPosition, flDirection, false);
		TE_SendToAll();
		EmitAmbientSound(SOUND_EXPLOSION3, flStartPosition, client, SNDLEVEL_RAIDSIREN);
		ForcePlayerSuicide(client);
	}
}