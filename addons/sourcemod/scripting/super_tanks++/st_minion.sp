// Super Tanks++: Minion Ability
bool g_bMinion[MAXPLAYERS + 1];
char g_sMinionTypes[ST_MAXTYPES + 1][13];
char g_sMinionTypes2[ST_MAXTYPES + 1][13];
int g_iMinionAbility[ST_MAXTYPES + 1];
int g_iMinionAbility2[ST_MAXTYPES + 1];
int g_iMinionAmount[ST_MAXTYPES + 1];
int g_iMinionAmount2[ST_MAXTYPES + 1];
int g_iMinionChance[ST_MAXTYPES + 1];
int g_iMinionChance2[ST_MAXTYPES + 1];
int g_iMinionCount[MAXPLAYERS + 1];

void vMinionConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iMinionAbility[index] = keyvalues.GetNum("Minion Ability/Ability Enabled", 0)) : (g_iMinionAbility2[index] = keyvalues.GetNum("Minion Ability/Ability Enabled", g_iMinionAbility[index]));
	main ? (g_iMinionAbility[index] = iSetCellLimit(g_iMinionAbility[index], 0, 1)) : (g_iMinionAbility2[index] = iSetCellLimit(g_iMinionAbility2[index], 0, 1));
	main ? (g_iMinionAmount[index] = keyvalues.GetNum("Minion Ability/Minion Amount", 5)) : (g_iMinionAmount2[index] = keyvalues.GetNum("Minion Ability/Minion Amount", g_iMinionAmount[index]));
	main ? (g_iMinionAmount[index] = iSetCellLimit(g_iMinionAmount[index], 1, 25)) : (g_iMinionAmount2[index] = iSetCellLimit(g_iMinionAmount2[index], 1, 25));
	main ? (g_iMinionChance[index] = keyvalues.GetNum("Minion Ability/Minion Chance", 4)) : (g_iMinionChance2[index] = keyvalues.GetNum("Minion Ability/Minion Chance", g_iMinionChance[index]));
	main ? (g_iMinionChance[index] = iSetCellLimit(g_iMinionChance[index], 1, 9999999999)) : (g_iMinionChance2[index] = iSetCellLimit(g_iMinionChance2[index], 1, 9999999999));
	main ? (keyvalues.GetString("Minion Ability/Minion Types", g_sMinionTypes[index], sizeof(g_sMinionTypes[]), "123456")) : (keyvalues.GetString("Minion Ability/Minion Types", g_sMinionTypes2[index], sizeof(g_sMinionTypes2[]), g_sMinionTypes[index]));
}

void vMinion(int client, char[] type, float pos[3], bool boss = false)
{
	bool bSpecialInfected[MAXPLAYERS + 1];
	bool bTankBoss[MAXPLAYERS + 1];
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		bSpecialInfected[iPlayer] = false;
		bTankBoss[iPlayer] = false;
		if ((!boss && bIsInfected(iPlayer)) || (boss && bIsTank(iPlayer)))
		{
			!boss ? (bSpecialInfected[iPlayer] = true) : (bTankBoss[iPlayer] = true);
		}
	}
	!boss ? vCheatCommand(client, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", type) : vTank(client, g_iTankType[client]);
	int iSelectedType = 0;
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if ((!boss && bIsInfected(iPlayer)) || (boss && bIsTank(iPlayer)))
		{
			if (!boss && !bSpecialInfected[iPlayer])
			{
				iSelectedType = iPlayer;
				break;
			}
			else if (boss && !bTankBoss[iPlayer])
			{
				iSelectedType = iPlayer;
				break;
			}
		}
	}
	if (iSelectedType > 0)
	{
		TeleportEntity(iSelectedType, pos, NULL_VECTOR, NULL_VECTOR);
		if (boss && strcmp(type, "tank") == 0)
		{
			g_bCloned[iSelectedType] = true;
			int iCloneHealth = !g_bTankConfig[g_iTankType[client]] ? g_iCloneHealth[g_iTankType[client]] : g_iCloneHealth2[g_iTankType[client]];
			int iNewHealth = (iCloneHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iCloneHealth;
			SetEntityHealth(iSelectedType, iNewHealth);
		}
		else if (!boss)
		{
			g_bMinion[iSelectedType] = true;
		}
	}
}

void vMinionAbility(int client)
{
	int iMinionAbility = !g_bTankConfig[g_iTankType[client]] ? g_iMinionAbility[g_iTankType[client]] : g_iMinionAbility2[g_iTankType[client]];
	int iMinionChance = !g_bTankConfig[g_iTankType[client]] ? g_iMinionChance[g_iTankType[client]] : g_iMinionChance2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iMinionAbility == 1 && GetRandomInt(1, iMinionChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client))
	{
		int iMinionAmount = !g_bTankConfig[g_iTankType[client]] ? g_iMinionAmount[g_iTankType[client]] : g_iMinionAmount2[g_iTankType[client]];
		if (g_iMinionCount[client] < iMinionAmount)
		{
			char sInfectedName[MAX_NAME_LENGTH + 1];
			char sNumbers = !g_bTankConfig[g_iTankType[client]] ? g_sMinionTypes[g_iTankType[client]][GetRandomInt(0, strlen(g_sMinionTypes[g_iTankType[client]]) - 1)] : g_sMinionTypes2[g_iTankType[client]][GetRandomInt(0, strlen(g_sMinionTypes2[g_iTankType[client]]) - 1)];
			switch (sNumbers)
			{
				case '1': sInfectedName = "smoker";
				case '2': sInfectedName = "boomer";
				case '3': sInfectedName = "hunter";
				case '4': sInfectedName = bIsL4D2Game() ? "spitter" : "boomer";
				case '5': sInfectedName = bIsL4D2Game() ? "jockey" : "hunter";
				case '6': sInfectedName = bIsL4D2Game() ? "charger" : "smoker";
				default: sInfectedName = "hunter";
			}
			vMinionSpawner(client, sInfectedName, iMinionAbility);
			g_iMinionCount[client]++;
		}
	}
}

void vResetMinion(int client)
{
	g_bMinion[client] = false;
	g_iMinionCount[client] = 0;
}