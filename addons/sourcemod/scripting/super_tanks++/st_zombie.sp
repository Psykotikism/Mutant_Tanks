// Super Tanks++: Zombie Ability
int g_iZombieAbility[ST_MAXTYPES + 1];
int g_iZombieAbility2[ST_MAXTYPES + 1];
int g_iZombieAmount[ST_MAXTYPES + 1];
int g_iZombieAmount2[ST_MAXTYPES + 1];
int g_iZombieInterval[MAXPLAYERS + 1];

void vZombieConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iZombieAbility[index] = keyvalues.GetNum("Zombie Ability/Ability Enabled", 0)) : (g_iZombieAbility2[index] = keyvalues.GetNum("Zombie Ability/Ability Enabled", g_iZombieAbility[index]));
	main ? (g_iZombieAbility[index] = iSetCellLimit(g_iZombieAbility[index], 0, 1)) : (g_iZombieAbility2[index] = iSetCellLimit(g_iZombieAbility2[index], 0, 1));
	main ? (g_iZombieAmount[index] = keyvalues.GetNum("Zombie Ability/Zombie Amount", 10)) : (g_iZombieAmount2[index] = keyvalues.GetNum("Zombie Ability/Zombie Amount", g_iZombieAmount[index]));
	main ? (g_iZombieAmount[index] = iSetCellLimit(g_iZombieAmount[index], 1, 100)) : (g_iZombieAmount2[index] = iSetCellLimit(g_iZombieAmount2[index], 1, 100));
}

void vZombieAbility(int client)
{
	int iZombieAbility = !g_bTankConfig[g_iTankType[client]] ? g_iZombieAbility[g_iTankType[client]] : g_iZombieAbility2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iZombieAbility == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client))
	{
		g_iZombieInterval[client]++;
		int iZombieAmount = !g_bTankConfig[g_iTankType[client]] ? g_iZombieAmount[g_iTankType[client]] : g_iZombieAmount2[g_iTankType[client]];
		if (g_iZombieInterval[client] >= iZombieAmount)
		{
			for (int iZombie = 1; iZombie <= iZombieAmount; iZombie++)
			{
				vCheatCommand(client, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", "zombie area");
			}
			g_iZombieInterval[client] = 0;
		}
	}
}

void vResetZombie(int client)
{
	g_iZombieInterval[client] = 0;
}