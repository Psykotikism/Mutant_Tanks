// Super Tanks++: Bomb Ability
float g_flBombRange[ST_MAXTYPES + 1];
float g_flBombRange2[ST_MAXTYPES + 1];
int g_iBombAbility[ST_MAXTYPES + 1];
int g_iBombAbility2[ST_MAXTYPES + 1];
int g_iBombChance[ST_MAXTYPES + 1];
int g_iBombChance2[ST_MAXTYPES + 1];
int g_iBombHit[ST_MAXTYPES + 1];
int g_iBombHit2[ST_MAXTYPES + 1];
int g_iBombPower[ST_MAXTYPES + 1];
int g_iBombPower2[ST_MAXTYPES + 1];
int g_iBombRock[ST_MAXTYPES + 1];
int g_iBombRock2[ST_MAXTYPES + 1];

void vBombConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iBombAbility[index] = keyvalues.GetNum("Bomb Ability/Ability Enabled", 0)) : (g_iBombAbility2[index] = keyvalues.GetNum("Bomb Ability/Ability Enabled", g_iBombAbility[index]));
	main ? (g_iBombAbility[index] = iSetCellLimit(g_iBombAbility[index], 0, 1)) : (g_iBombAbility2[index] = iSetCellLimit(g_iBombAbility2[index], 0, 1));
	main ? (g_iBombChance[index] = keyvalues.GetNum("Bomb Ability/Bomb Chance", 4)) : (g_iBombChance2[index] = keyvalues.GetNum("Bomb Ability/Bomb Chance", g_iBombChance[index]));
	main ? (g_iBombChance[index] = iSetCellLimit(g_iBombChance[index], 1, 9999999999)) : (g_iBombChance2[index] = iSetCellLimit(g_iBombChance2[index], 1, 9999999999));
	main ? (g_iBombHit[index] = keyvalues.GetNum("Bomb Ability/Bomb Hit", 0)) : (g_iBombHit2[index] = keyvalues.GetNum("Bomb Ability/Bomb Hit", g_iBombHit[index]));
	main ? (g_iBombHit[index] = iSetCellLimit(g_iBombHit[index], 0, 1)) : (g_iBombHit2[index] = iSetCellLimit(g_iBombHit2[index], 0, 1));
	main ? (g_iBombPower[index] = keyvalues.GetNum("Bomb Ability/Bomb Power", 75)) : (g_iBombPower2[index] = keyvalues.GetNum("Bomb Ability/Bomb Power", g_iBombPower[index]));
	main ? (g_iBombPower[index] = iSetCellLimit(g_iBombPower[index], 1, 9999999999)) : (g_iBombPower2[index] = iSetCellLimit(g_iBombPower2[index], 1, 9999999999));
	main ? (g_flBombRange[index] = keyvalues.GetFloat("Bomb Ability/Bomb Range", 150.0)) : (g_flBombRange2[index] = keyvalues.GetFloat("Bomb Ability/Bomb Range", g_flBombRange[index]));
	main ? (g_flBombRange[index] = flSetFloatLimit(g_flBombRange[index], 1.0, 9999999999.0)) : (g_flBombRange2[index] = flSetFloatLimit(g_flBombRange2[index], 1.0, 9999999999.0));
	main ? (g_iBombRock[index] = keyvalues.GetNum("Bomb Ability/Bomb Rock Break", 0)) : (g_iBombRock2[index] = keyvalues.GetNum("Bomb Ability/Bomb Rock Break", g_iBombRock[index]));
	main ? (g_iBombRock[index] = iSetCellLimit(g_iBombRock[index], 0, 1)) : (g_iBombRock2[index] = iSetCellLimit(g_iBombRock2[index], 0, 1));
}

void vBomb(int client, float pos[3])
{
	int iBombPower = !g_bTankConfig[g_iTankType[client]] ? g_iBombPower[g_iTankType[client]] : g_iBombPower2[g_iTankType[client]];
	char sDamage[6];
	IntToString(iBombPower, sDamage, sizeof(sDamage));
	int iParticle = CreateEntityByName("info_particle_system");
	int iParticle2 = CreateEntityByName("info_particle_system");
	int iParticle3 = CreateEntityByName("info_particle_system");
	int iTrace = CreateEntityByName("info_particle_system");
	int iPhysics = CreateEntityByName("env_physexplosion");
	int iHurt = CreateEntityByName("point_hurt");
	int iExplosion = CreateEntityByName("env_explosion");
	DispatchKeyValue(iParticle, "effect_name", "FluidExplosion_fps");
	TeleportEntity(iParticle, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iParticle);
	ActivateEntity(iParticle);
	DispatchKeyValue(iParticle2, "effect_name", "weapon_grenade_explosion");
	TeleportEntity(iParticle2, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iParticle2);
	ActivateEntity(iParticle2);
	DispatchKeyValue(iParticle3, "effect_name", "explosion_huge_b");
	TeleportEntity(iParticle3, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iParticle3);
	ActivateEntity(iParticle3);
	DispatchKeyValue(iTrace, "effect_name", "gas_explosion_ground_fire");
	TeleportEntity(iTrace, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iTrace);
	ActivateEntity(iTrace);
	SetEntPropEnt(iExplosion, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValue(iExplosion, "fireballsprite", "sprites/muzzleflash4.vmt");
	DispatchKeyValue(iExplosion, "iMagnitude", sDamage);
	DispatchKeyValue(iExplosion, "iRadiusOverride", sDamage);
	DispatchKeyValue(iExplosion, "spawnflags", "828");
	TeleportEntity(iExplosion, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iExplosion);
	SetEntPropEnt(iPhysics, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValue(iPhysics, "radius", sDamage);
	DispatchKeyValue(iPhysics, "magnitude", sDamage);
	TeleportEntity(iPhysics, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iPhysics);
	SetEntPropEnt(iHurt, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValue(iHurt, "DamageRadius", sDamage);
	DispatchKeyValue(iHurt, "DamageDelay", "0.5");
	DispatchKeyValue(iHurt, "Damage", "5");
	DispatchKeyValue(iHurt, "DamageType", "8");
	TeleportEntity(iHurt, pos, NULL_VECTOR, NULL_VECTOR);
	DispatchSpawn(iHurt);
	switch (GetRandomInt(1, 3))
	{
		case 1: EmitSoundToAll(SOUND_EXPLOSION2, client);
		case 2: EmitSoundToAll(SOUND_EXPLOSION3, client);
		case 3: EmitSoundToAll(SOUND_EXPLOSION4, client);
	}
	EmitSoundToAll(SOUND_DEBRIS, client);
	AcceptEntityInput(iParticle, "Start");
	AcceptEntityInput(iParticle2, "Start");
	AcceptEntityInput(iParticle3, "Start");
	AcceptEntityInput(iTrace, "Start");
	AcceptEntityInput(iExplosion, "Explode");
	AcceptEntityInput(iPhysics, "Explode");
	AcceptEntityInput(iHurt, "TurnOn");
	iParticle = EntIndexToEntRef(iParticle);
	vDeleteEntity(iParticle, 16.5);
	iParticle2 = EntIndexToEntRef(iParticle2);
	vDeleteEntity(iParticle2, 16.5);
	iParticle3 = EntIndexToEntRef(iParticle3);
	vDeleteEntity(iParticle3, 16.5);
	iTrace = EntIndexToEntRef(iTrace);
	vDeleteEntity(iTrace, 16.5);
	vDeleteParticle(iTrace, 16.5, "Stop");
	iExplosion = EntIndexToEntRef(iExplosion);
	vDeleteEntity(iExplosion, 16.5);
	iPhysics = EntIndexToEntRef(iPhysics);
	vDeleteEntity(iPhysics, 16.5);
	iHurt = EntIndexToEntRef(iHurt);
	vDeleteEntity(iHurt, 16.5);
	vDeleteParticle(iHurt, 15.0, "TurnOff");
}

void vBombHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iBombAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iBombAbility[g_iTankType[owner]] : g_iBombAbility2[g_iTankType[owner]];
	int iBombChance = !g_bTankConfig[g_iTankType[owner]] ? g_iBombChance[g_iTankType[owner]] : g_iBombChance2[g_iTankType[owner]];
	int iBombHit = !g_bTankConfig[g_iTankType[owner]] ? g_iBombHit[g_iTankType[owner]] : g_iBombHit2[g_iTankType[owner]];
	float flBombRange = !g_bTankConfig[g_iTankType[owner]] ? g_flBombRange[g_iTankType[owner]] : g_flBombRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flBombRange) || toggle == 2) && ((toggle == 1 && iBombAbility == 1) || (toggle == 2 && iBombHit == 1)) && GetRandomInt(1, iBombChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client))
	{
		float flPosition[3];
		GetClientAbsOrigin(client, flPosition);
		vBomb(owner, flPosition);
	}
}

void vBombRock(int entity, int client)
{
	int iBombRock = !g_bTankConfig[g_iTankType[client]] ? g_iBombRock[g_iTankType[client]] : g_iBombRock2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iBombRock == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client))
	{
		float flPosition[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPosition);
		vBomb(client, flPosition);
	}
}