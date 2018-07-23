// Super Tanks++: Witch Ability
float g_flWitchDamage[ST_MAXTYPES + 1];
float g_flWitchDamage2[ST_MAXTYPES + 1];
int g_iWitchAbility[ST_MAXTYPES + 1];
int g_iWitchAbility2[ST_MAXTYPES + 1];
int g_iWitchAmount[ST_MAXTYPES + 1];
int g_iWitchAmount2[ST_MAXTYPES + 1];

void vWitchConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iWitchAbility[index] = keyvalues.GetNum("Witch Ability/Ability Enabled", 0)) : (g_iWitchAbility2[index] = keyvalues.GetNum("Witch Ability/Ability Enabled", g_iWitchAbility[index]));
	main ? (g_iWitchAbility[index] = iSetCellLimit(g_iWitchAbility[index], 0, 1)) : (g_iWitchAbility2[index] = iSetCellLimit(g_iWitchAbility2[index], 0, 1));
	main ? (g_iWitchAmount[index] = keyvalues.GetNum("Witch Ability/Witch Amount", 3)) : (g_iWitchAmount2[index] = keyvalues.GetNum("Witch Ability/Witch Amount", g_iWitchAmount[index]));
	main ? (g_iWitchAmount[index] = iSetCellLimit(g_iWitchAmount[index], 1, 25)) : (g_iWitchAmount2[index] = iSetCellLimit(g_iWitchAmount2[index], 1, 25));
	main ? (g_flWitchDamage[index] = keyvalues.GetFloat("Witch Ability/Witch Minion Damage", 10.0)) : (g_flWitchDamage2[index] = keyvalues.GetFloat("Witch Ability/Witch Minion Damage", g_flWitchDamage[index]));
	main ? (g_flWitchDamage[index] = flSetFloatLimit(g_flWitchDamage[index], 1.0, 9999999999.0)) : (g_flWitchDamage2[index] = flSetFloatLimit(g_flWitchDamage2[index], 1.0, 9999999999.0));
}

void vWitchAbility(int client)
{
	int iWitchAbility = !g_bTankConfig[g_iTankType[client]] ? g_iWitchAbility[g_iTankType[client]] : g_iWitchAbility2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iWitchAbility == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client))
	{
		int iWitchCount;
		int iInfected = -1;
		while ((iInfected = FindEntityByClassname(iInfected, "infected")) != INVALID_ENT_REFERENCE)
		{
			int iWitchAmount = !g_bTankConfig[g_iTankType[client]] ? g_iWitchAmount[g_iTankType[client]] : g_iWitchAmount2[g_iTankType[client]];
			if (iWitchCount < 4 && iGetWitchCount() < iWitchAmount)
			{
				float flTankPos[3];
				float flInfectedPos[3];
				float flInfectedAng[3];
				GetClientAbsOrigin(client, flTankPos);
				GetEntPropVector(iInfected, Prop_Send, "m_vecOrigin", flInfectedPos);
				GetEntPropVector(iInfected, Prop_Send, "m_angRotation", flInfectedAng);
				float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
				if (flDistance <= 100.0)
				{
					AcceptEntityInput(iInfected, "Kill");
					int iWitch = CreateEntityByName("witch");
					if (bIsValidEntity(iWitch))
					{
						TeleportEntity(iWitch, flInfectedPos, flInfectedAng, NULL_VECTOR);
						DispatchSpawn(iWitch);
						ActivateEntity(iWitch);
						SetEntProp(iWitch, Prop_Send, "m_hOwnerEntity", client);
					}
					iWitchCount++;
				}
			}
		}
	}
}

int iGetWitchCount()
{
	int iWitchCount;
	int iWitch = -1;
	while ((iWitch = FindEntityByClassname(iWitch, "witch")) != INVALID_ENT_REFERENCE)
	{
		iWitchCount++;
	}
	return iWitchCount;
}