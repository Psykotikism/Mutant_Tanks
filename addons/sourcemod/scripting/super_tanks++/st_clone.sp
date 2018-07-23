// Super Tanks++: Clone Ability
bool g_bCloned[MAXPLAYERS + 1];
int g_iCloneAbility[ST_MAXTYPES + 1];
int g_iCloneAbility2[ST_MAXTYPES + 1];
int g_iCloneAmount[ST_MAXTYPES + 1];
int g_iCloneAmount2[ST_MAXTYPES + 1];
int g_iCloneChance[ST_MAXTYPES + 1];
int g_iCloneChance2[ST_MAXTYPES + 1];
int g_iCloneCount[MAXPLAYERS + 1];
int g_iCloneHealth[ST_MAXTYPES + 1];
int g_iCloneHealth2[ST_MAXTYPES + 1];
int g_iCloneMode[ST_MAXTYPES + 1];
int g_iCloneMode2[ST_MAXTYPES + 1];

void vCloneConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iCloneAbility[index] = keyvalues.GetNum("Clone Ability/Ability Enabled", 0)) : (g_iCloneAbility2[index] = keyvalues.GetNum("Clone Ability/Ability Enabled", g_iCloneAbility[index]));
	main ? (g_iCloneAbility[index] = iSetCellLimit(g_iCloneAbility[index], 0, 1)) : (g_iCloneAbility2[index] = iSetCellLimit(g_iCloneAbility2[index], 0, 1));
	main ? (g_iCloneAmount[index] = keyvalues.GetNum("Clone Ability/Clone Amount", 2)) : (g_iCloneAmount2[index] = keyvalues.GetNum("Clone Ability/Clone Amount", g_iCloneAmount[index]));
	main ? (g_iCloneAmount[index] = iSetCellLimit(g_iCloneAmount[index], 1, 25)) : (g_iCloneAmount2[index] = iSetCellLimit(g_iCloneAmount2[index], 1, 25));
	main ? (g_iCloneChance[index] = keyvalues.GetNum("Clone Ability/Clone Chance", 4)) : (g_iCloneChance2[index] = keyvalues.GetNum("Clone Ability/Clone Chance", g_iCloneChance[index]));
	main ? (g_iCloneChance[index] = iSetCellLimit(g_iCloneChance[index], 1, 9999999999)) : (g_iCloneChance2[index] = iSetCellLimit(g_iCloneChance2[index], 1, 9999999999));
	main ? (g_iCloneHealth[index] = keyvalues.GetNum("Clone Ability/Clone Health", 1000)) : (g_iCloneHealth2[index] = keyvalues.GetNum("Clone Ability/Clone Health", g_iCloneHealth[index]));
	main ? (g_iCloneHealth[index] = iSetCellLimit(g_iCloneHealth[index], 1, ST_MAXHEALTH)) : (g_iCloneHealth2[index] = iSetCellLimit(g_iCloneHealth2[index], 1, ST_MAXHEALTH));
	main ? (g_iCloneMode[index] = keyvalues.GetNum("Clone Ability/Clone Mode", 0)) : (g_iCloneMode2[index] = keyvalues.GetNum("Clone Ability/Clone Mode", g_iCloneMode[index]));
	main ? (g_iCloneMode[index] = iSetCellLimit(g_iCloneMode[index], 0, 1)) : (g_iCloneMode2[index] = iSetCellLimit(g_iCloneMode2[index], 0, 1));
}

void vCloneDeath(int client)
{
	int iCloneAbility = !g_bTankConfig[g_iTankType[client]] ? g_iCloneAbility[g_iTankType[client]] : g_iCloneAbility2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iCloneAbility == 1)
	{
		if (g_bCloned[client])
		{
			g_bCloned[client] = false;
			if (iGetCloneCount() == 0)
			{
				for (int iCloner = 1; iCloner <= MaxClients; iCloner++)
				{
					if ((iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[iCloner])) && bIsTank(iCloner))
					{
						g_iCloneCount[iCloner] = 0;
					}
				}
			}
		}
		else
		{
			g_iCloneCount[client] = 0;
		}
	}
}

void vCloneAbility(int client)
{
	int iCloneAbility = !g_bTankConfig[g_iTankType[client]] ? g_iCloneAbility[g_iTankType[client]] : g_iCloneAbility2[g_iTankType[client]];
	int iCloneChance = !g_bTankConfig[g_iTankType[client]] ? g_iCloneChance[g_iTankType[client]] : g_iCloneChance2[g_iTankType[client]];
	if (iCloneAbility == 1 && GetRandomInt(1, iCloneChance) == 1 && !g_bCloned[client] && bIsTank(client))
	{
		int iCloneAmount = !g_bTankConfig[g_iTankType[client]] ? g_iCloneAmount[g_iTankType[client]] : g_iCloneAmount2[g_iTankType[client]];
		if (g_iCloneCount[client] < iCloneAmount)
		{
			vMinionSpawner(client, "tank", iCloneAbility, true);
			g_iCloneCount[client]++;
		}
	}
}

void vResetClone(int client)
{
	g_bCloned[client] = false;
	g_iCloneCount[client] = 0;
}

int iGetCloneCount()
{
	int iCloneCount;
	for (int iClone = 1; iClone <= MaxClients; iClone++)
	{
		if (g_bCloned[iClone] && bIsTank(iClone))
		{
			iCloneCount++;
		}
	}
	return iCloneCount;
}