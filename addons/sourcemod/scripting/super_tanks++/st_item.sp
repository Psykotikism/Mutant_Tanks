// Super Tanks++: Item Ability
char g_sItemLoadout[ST_MAXTYPES + 1][325];
char g_sItemLoadout2[ST_MAXTYPES + 1][325];
int g_iItemAbility[ST_MAXTYPES + 1];
int g_iItemAbility2[ST_MAXTYPES + 1];
int g_iItemChance[ST_MAXTYPES + 1];
int g_iItemChance2[ST_MAXTYPES + 1];
int g_iItemMode[ST_MAXTYPES + 1];
int g_iItemMode2[ST_MAXTYPES + 1];

void vItemConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iItemAbility[index] = keyvalues.GetNum("Item Ability/Ability Enabled", 0)) : (g_iItemAbility2[index] = keyvalues.GetNum("Item Ability/Ability Enabled", g_iItemAbility[index]));
	main ? (g_iItemAbility[index] = iSetCellLimit(g_iItemAbility[index], 0, 1)) : (g_iItemAbility2[index] = iSetCellLimit(g_iItemAbility2[index], 0, 1));
	main ? (g_iItemChance[index] = keyvalues.GetNum("Item Ability/Item Chance", 4)) : (g_iItemChance2[index] = keyvalues.GetNum("Item Ability/Item Chance", g_iItemChance[index]));
	main ? (g_iItemChance[index] = iSetCellLimit(g_iItemChance[index], 1, 9999999999)) : (g_iItemChance2[index] = iSetCellLimit(g_iItemChance2[index], 1, 9999999999));
	main ? (keyvalues.GetString("Item Ability/Item Loadout", g_sItemLoadout[index], sizeof(g_sItemLoadout[]), "rifle,pistol,first_aid_kit,pain_pills")) : (keyvalues.GetString("Item Ability/Item Loadout", g_sItemLoadout2[index], sizeof(g_sItemLoadout2[]), g_sItemLoadout[index]));
	main ? (g_iItemMode[index] = keyvalues.GetNum("Item Ability/Item Mode", 0)) : (g_iItemMode2[index] = keyvalues.GetNum("Item Ability/Item Mode", g_iItemMode[index]));
	main ? (g_iItemMode[index] = iSetCellLimit(g_iItemMode[index], 0, 1)) : (g_iItemMode2[index] = iSetCellLimit(g_iItemMode2[index], 0, 1));
}

void vItemDeath(int client)
{
	int iItemAbility = !g_bTankConfig[g_iTankType[client]] ? g_iItemAbility[g_iTankType[client]] : g_iItemAbility2[g_iTankType[client]];
	int iItemChance = !g_bTankConfig[g_iTankType[client]] ? g_iItemChance[g_iTankType[client]] : g_iItemChance2[g_iTankType[client]];
	int iItemMode = !g_bTankConfig[g_iTankType[client]] ? g_iItemMode[g_iTankType[client]] : g_iItemMode2[g_iTankType[client]];
	if (iItemAbility == 1 && GetRandomInt(1, iItemChance) == 1)
	{
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				switch (iItemMode)
				{
					case 0:
					{
						char sItems[5][64];
						char sItemLoadout[325];
						sItemLoadout = !g_bTankConfig[g_iTankType[client]] ? g_sItemLoadout[g_iTankType[client]] : g_sItemLoadout2[g_iTankType[client]];
						TrimString(sItemLoadout);
						ExplodeString(sItemLoadout, ",", sItems, sizeof(sItems), sizeof(sItems[]));
						switch (GetRandomInt(1, 5))
						{
							case 1: vCheatCommand(iSurvivor, "give", sItems[0]);
							case 2: vCheatCommand(iSurvivor, "give", sItems[1]);
							case 3: vCheatCommand(iSurvivor, "give", sItems[2]);
							case 4: vCheatCommand(iSurvivor, "give", sItems[3]);
							case 5: vCheatCommand(iSurvivor, "give", sItems[4]);
						}
					}
					case 1:
					{
						char sItemLoadout[325];
						sItemLoadout = !g_bTankConfig[g_iTankType[client]] ? g_sItemLoadout[g_iTankType[client]] : g_sItemLoadout2[g_iTankType[client]];
						TrimString(sItemLoadout);
						vGiveItem(iSurvivor, sItemLoadout);
					}
				}
			}
		}
	}
}