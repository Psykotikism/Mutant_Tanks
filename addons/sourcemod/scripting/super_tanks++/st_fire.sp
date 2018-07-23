// Super Tanks++: Fire Ability
float g_flFireRange[ST_MAXTYPES + 1];
float g_flFireRange2[ST_MAXTYPES + 1];
int g_iFireAbility[ST_MAXTYPES + 1];
int g_iFireAbility2[ST_MAXTYPES + 1];
int g_iFireChance[ST_MAXTYPES + 1];
int g_iFireChance2[ST_MAXTYPES + 1];
int g_iFireHit[ST_MAXTYPES + 1];
int g_iFireHit2[ST_MAXTYPES + 1];
int g_iFireRock[ST_MAXTYPES + 1];
int g_iFireRock2[ST_MAXTYPES + 1];

void vFireConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iFireAbility[index] = keyvalues.GetNum("Fire Ability/Ability Enabled", 0)) : (g_iFireAbility2[index] = keyvalues.GetNum("Fire Ability/Ability Enabled", g_iFireAbility[index]));
	main ? (g_iFireAbility[index] = iSetCellLimit(g_iFireAbility[index], 0, 1)) : (g_iFireAbility2[index] = iSetCellLimit(g_iFireAbility2[index], 0, 1));
	main ? (g_iFireChance[index] = keyvalues.GetNum("Fire Ability/Fire Chance", 4)) : (g_iFireChance2[index] = keyvalues.GetNum("Fire Ability/Fire Chance", g_iFireChance[index]));
	main ? (g_iFireChance[index] = iSetCellLimit(g_iFireChance[index], 1, 9999999999)) : (g_iFireChance2[index] = iSetCellLimit(g_iFireChance2[index], 1, 9999999999));
	main ? (g_iFireHit[index] = keyvalues.GetNum("Fire Ability/Fire Hit", 0)) : (g_iFireHit2[index] = keyvalues.GetNum("Fire Ability/Fire Hit", g_iFireHit[index]));
	main ? (g_iFireHit[index] = iSetCellLimit(g_iFireHit[index], 0, 1)) : (g_iFireHit2[index] = iSetCellLimit(g_iFireHit2[index], 0, 1));
	main ? (g_flFireRange[index] = keyvalues.GetFloat("Fire Ability/Fire Range", 150.0)) : (g_flFireRange2[index] = keyvalues.GetFloat("Fire Ability/Fire Range", g_flFireRange[index]));
	main ? (g_flFireRange[index] = flSetFloatLimit(g_flFireRange[index], 1.0, 9999999999.0)) : (g_flFireRange2[index] = flSetFloatLimit(g_flFireRange2[index], 1.0, 9999999999.0));
	main ? (g_iFireRock[index] = keyvalues.GetNum("Fire Ability/Fire Rock Break", 0)) : (g_iFireRock2[index] = keyvalues.GetNum("Fire Ability/Fire Rock Break", g_iFireRock[index]));
	main ? (g_iFireRock[index] = iSetCellLimit(g_iFireRock[index], 0, 1)) : (g_iFireRock2[index] = iSetCellLimit(g_iFireRock2[index], 0, 1));
}

void vFire(int client, float pos[3])
{
	int iFire = CreateEntityByName("prop_physics");
	if (IsValidEntity(iFire))
	{
		DispatchKeyValue(iFire, "disableshadows", "1");
		SetEntityModel(iFire, MODEL_GASCAN);
		pos[2] += 10.0;
		TeleportEntity(iFire, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iFire);
		SetEntPropEnt(iFire, Prop_Data, "m_hPhysicsAttacker", client);
		SetEntPropFloat(iFire, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());
		SetEntProp(iFire, Prop_Send, "m_CollisionGroup", 1);
		SetEntityRenderMode(iFire, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iFire, 0, 0, 0, 0);
		AcceptEntityInput(iFire, "Break");
	}
}

void vFireHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iFireAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iFireAbility[g_iTankType[owner]] : g_iFireAbility2[g_iTankType[owner]];
	int iFireChance = !g_bTankConfig[g_iTankType[owner]] ? g_iFireChance[g_iTankType[owner]] : g_iFireChance2[g_iTankType[owner]];
	int iFireHit = !g_bTankConfig[g_iTankType[owner]] ? g_iFireHit[g_iTankType[owner]] : g_iFireHit2[g_iTankType[owner]];
	float flFireRange = !g_bTankConfig[g_iTankType[owner]] ? g_flFireRange[g_iTankType[owner]] : g_flFireRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flFireRange) || toggle == 2) && ((toggle == 1 && iFireAbility == 1) || (toggle == 2 && iFireHit == 1)) && GetRandomInt(1, iFireChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client))
	{
		float flPos[3];
		GetClientAbsOrigin(client, flPos);
		vFire(owner, flPos);
	}
}

void vFireRock(int entity, int client)
{
	int iFireRock = !g_bTankConfig[g_iTankType[client]] ? g_iFireRock[g_iTankType[client]] : g_iFireRock2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iFireRock == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client))
	{
		float flPos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPos);
		vFire(client, flPos);
	}
}