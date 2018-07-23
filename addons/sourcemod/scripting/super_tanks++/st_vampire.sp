// Super Tanks++: Vampire Ability
float g_flVampireRange[ST_MAXTYPES + 1];
float g_flVampireRange2[ST_MAXTYPES + 1];
int g_iVampireAbility[ST_MAXTYPES + 1];
int g_iVampireAbility2[ST_MAXTYPES + 1];
int g_iVampireChance[ST_MAXTYPES + 1];
int g_iVampireChance2[ST_MAXTYPES + 1];
int g_iVampireHealth[ST_MAXTYPES + 1];
int g_iVampireHealth2[ST_MAXTYPES + 1];
int g_iVampireHit[ST_MAXTYPES + 1];
int g_iVampireHit2[ST_MAXTYPES + 1];

void vVampireConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iVampireAbility[index] = keyvalues.GetNum("Vampire Ability/Ability Enabled", 0)) : (g_iVampireAbility2[index] = keyvalues.GetNum("Vampire Ability/Ability Enabled", g_iVampireAbility[index]));
	main ? (g_iVampireAbility[index] = iSetCellLimit(g_iVampireAbility[index], 0, 1)) : (g_iVampireAbility2[index] = iSetCellLimit(g_iVampireAbility2[index], 0, 1));
	main ? (g_iVampireChance[index] = keyvalues.GetNum("Vampire Ability/Vampire Chance", 4)) : (g_iVampireChance2[index] = keyvalues.GetNum("Vampire Ability/Vampire Chance", g_iVampireChance[index]));
	main ? (g_iVampireChance[index] = iSetCellLimit(g_iVampireChance[index], 1, 9999999999)) : (g_iVampireChance2[index] = iSetCellLimit(g_iVampireChance2[index], 1, 9999999999));
	main ? (g_iVampireHealth[index] = keyvalues.GetNum("Vampire Ability/Vampire Health", 100)) : (g_iVampireHealth2[index] = keyvalues.GetNum("Vampire Ability/Vampire Health", g_iVampireHealth[index]));
	main ? (g_iVampireHealth[index] = iSetCellLimit(g_iVampireHealth[index], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iVampireHealth2[index] = iSetCellLimit(g_iVampireHealth2[index], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
	main ? (g_iVampireHit[index] = keyvalues.GetNum("Vampire Ability/Vampire Hit", 0)) : (g_iVampireHit2[index] = keyvalues.GetNum("Vampire Ability/Vampire Hit", g_iVampireHit[index]));
	main ? (g_iVampireHit[index] = iSetCellLimit(g_iVampireHit[index], 0, 1)) : (g_iVampireHit2[index] = iSetCellLimit(g_iVampireHit2[index], 0, 1));
	main ? (g_flVampireRange[index] = keyvalues.GetFloat("Vampire Ability/Vampire Range", 500.0)) : (g_flVampireRange2[index] = keyvalues.GetFloat("Vampire Ability/Vampire Range", g_flVampireRange[index]));
	main ? (g_flVampireRange[index] = flSetFloatLimit(g_flVampireRange[index], 1.0, 9999999999.0)) : (g_flVampireRange2[index] = flSetFloatLimit(g_flVampireRange2[index], 1.0, 9999999999.0));
}

void vVampireAbility(int client)
{
	int iVampireAbility = !g_bTankConfig[g_iTankType[client]] ? g_iVampireAbility[g_iTankType[client]] : g_iVampireAbility2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iVampireAbility == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client))
	{
		int iVampireCount;
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		float flVampireRange = !g_bTankConfig[g_iTankType[client]] ? g_flVampireRange[g_iTankType[client]] : g_flVampireRange2[g_iTankType[client]];
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flVampireRange)
				{
					iVampireCount++;
				}
			}
		}
		if (iVampireCount > 0)
		{
			vVampireHit(client, 1);
		}
	}
}

void vVampireHit(int client, int toggle = 2)
{
	int iVampireAbility = !g_bTankConfig[g_iTankType[client]] ? g_iVampireAbility[g_iTankType[client]] : g_iVampireAbility2[g_iTankType[client]];
	int iVampireChance = !g_bTankConfig[g_iTankType[client]] ? g_iVampireChance[g_iTankType[client]] : g_iVampireChance2[g_iTankType[client]];
	int iVampireHit = !g_bTankConfig[g_iTankType[client]] ? g_iVampireHit[g_iTankType[client]] : g_iVampireHit2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (((toggle == 1 && iVampireAbility == 1) || (toggle == 2 && iVampireHit == 1)) && GetRandomInt(1, iVampireChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client))
	{
		int iHealth = GetClientHealth(client);
		int iVampireHealth = !g_bTankConfig[g_iTankType[client]] ? (iHealth + g_iVampireHealth[g_iTankType[client]]) : (iHealth + g_iVampireHealth2[g_iTankType[client]]);
		int iExtraHealth = (iVampireHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iVampireHealth;
		int iExtraHealth2 = (iVampireHealth < iHealth) ? 1 : iVampireHealth;
		int iRealHealth = (iVampireHealth >= 0) ? iExtraHealth : iExtraHealth2;
		SetEntityHealth(client, iRealHealth);
	}
}