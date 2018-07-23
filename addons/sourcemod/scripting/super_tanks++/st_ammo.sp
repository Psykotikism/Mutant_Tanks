// Super Tanks++: Ammo Ability
float g_flAmmoRange[ST_MAXTYPES + 1];
float g_flAmmoRange2[ST_MAXTYPES + 1];
int g_iAmmoAbility[ST_MAXTYPES + 1];
int g_iAmmoAbility2[ST_MAXTYPES + 1];
int g_iAmmoChance[ST_MAXTYPES + 1];
int g_iAmmoChance2[ST_MAXTYPES + 1];
int g_iAmmoCount[ST_MAXTYPES + 1];
int g_iAmmoCount2[ST_MAXTYPES + 1];
int g_iAmmoHit[ST_MAXTYPES + 1];
int g_iAmmoHit2[ST_MAXTYPES + 1];

void vAmmoConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iAmmoAbility[index] = keyvalues.GetNum("Ammo Ability/Ability Enabled", 0)) : (g_iAmmoAbility2[index] = keyvalues.GetNum("Ammo Ability/Ability Enabled", g_iAmmoAbility[index]));
	main ? (g_iAmmoAbility[index] = iSetCellLimit(g_iAmmoAbility[index], 0, 1)) : (g_iAmmoAbility2[index] = iSetCellLimit(g_iAmmoAbility2[index], 0, 1));
	main ? (g_iAmmoChance[index] = keyvalues.GetNum("Ammo Ability/Ammo Chance", 4)) : (g_iAmmoChance2[index] = keyvalues.GetNum("Ammo Ability/Ammo Chance", g_iAmmoChance[index]));
	main ? (g_iAmmoChance[index] = iSetCellLimit(g_iAmmoChance[index], 1, 9999999999)) : (g_iAmmoChance2[index] = iSetCellLimit(g_iAmmoChance2[index], 1, 9999999999));
	main ? (g_iAmmoCount[index] = keyvalues.GetNum("Ammo Ability/Ammo Count", 0)) : (g_iAmmoCount2[index] = keyvalues.GetNum("Ammo Ability/Ammo Count", g_iAmmoCount[index]));
	main ? (g_iAmmoCount[index] = iSetCellLimit(g_iAmmoCount[index], 0, 25)) : (g_iAmmoCount2[index] = iSetCellLimit(g_iAmmoCount2[index], 0, 25));
	main ? (g_iAmmoHit[index] = keyvalues.GetNum("Ammo Ability/Ammo Hit", 0)) : (g_iAmmoHit2[index] = keyvalues.GetNum("Ammo Ability/Ammo Hit", g_iAmmoHit[index]));
	main ? (g_iAmmoHit[index] = iSetCellLimit(g_iAmmoHit[index], 0, 1)) : (g_iAmmoHit2[index] = iSetCellLimit(g_iAmmoHit2[index], 0, 1));
	main ? (g_flAmmoRange[index] = keyvalues.GetFloat("Ammo Ability/Ammo Range", 150.0)) : (g_flAmmoRange2[index] = keyvalues.GetFloat("Ammo Ability/Ammo Range", g_flAmmoRange[index]));
	main ? (g_flAmmoRange[index] = flSetFloatLimit(g_flAmmoRange[index], 1.0, 9999999999.0)) : (g_flAmmoRange2[index] = flSetFloatLimit(g_flAmmoRange2[index], 1.0, 9999999999.0));
}

void vAmmoHit(int client, int owner, int toggle, float distance = 0.0)
{
	int iAmmoAbility = !g_bTankConfig[g_iTankType[owner]] ? g_iAmmoAbility[g_iTankType[owner]] : g_iAmmoAbility2[g_iTankType[owner]];
	int iAmmoChance = !g_bTankConfig[g_iTankType[owner]] ? g_iAmmoChance[g_iTankType[owner]] : g_iAmmoChance2[g_iTankType[owner]];
	int iAmmoHit = !g_bTankConfig[g_iTankType[owner]] ? g_iAmmoHit[g_iTankType[owner]] : g_iAmmoHit2[g_iTankType[owner]];
	float flAmmoRange = !g_bTankConfig[g_iTankType[owner]] ? g_flAmmoRange[g_iTankType[owner]] : g_flAmmoRange2[g_iTankType[owner]];
	int iCloneMode = !g_bTankConfig[g_iTankType[owner]] ? g_iCloneMode[g_iTankType[owner]] : g_iCloneMode2[g_iTankType[owner]];
	if (((toggle == 1 && distance <= flAmmoRange) || toggle == 2) && ((toggle == 1 && iAmmoAbility == 1) || (toggle == 2 && iAmmoHit == 1)) && GetRandomInt(1, iAmmoChance) == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[owner])) && bIsSurvivor(client) && GetPlayerWeaponSlot(client, 0) > 0)
	{
		char sWeapon[32];
		int iActiveWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		int iAmmo = !g_bTankConfig[g_iTankType[owner]] ? g_iAmmoCount[g_iTankType[owner]] : g_iAmmoCount2[g_iTankType[owner]];
		GetEntityClassname(iActiveWeapon, sWeapon, sizeof(sWeapon));
		if (bIsValidEntity(iActiveWeapon))
		{
			if (strcmp(sWeapon, "weapon_rifle") == 0 || strcmp(sWeapon, "weapon_rifle_desert") == 0 || strcmp(sWeapon, "weapon_rifle_ak47") == 0 || strcmp(sWeapon, "weapon_rifle_sg552") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", iAmmo, _, 3);
			}
			else if (strcmp(sWeapon, "weapon_smg") == 0 || strcmp(sWeapon, "weapon_smg_silenced") == 0 || strcmp(sWeapon, "weapon_smg_mp5") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", iAmmo, _, 5);
			}
			else if (strcmp(sWeapon, "weapon_pumpshotgun") == 0)
			{
				bIsL4D2Game() ? SetEntProp(client, Prop_Data, "m_iAmmo", iAmmo, _, 7) : SetEntProp(client, Prop_Data, "m_iAmmo", iAmmo, _, 6);
			}
			else if (strcmp(sWeapon, "weapon_shotgun_chrome") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", iAmmo, _, 7);
			}
			else if (strcmp(sWeapon, "weapon_autoshotgun") == 0)
			{
				bIsL4D2Game() ? SetEntProp(client, Prop_Data, "m_iAmmo", iAmmo, _, 8) : SetEntProp(client, Prop_Data, "m_iAmmo", iAmmo, _, 6);
			}
			else if (strcmp(sWeapon, "weapon_shotgun_spas") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", iAmmo, _, 8);
			}
			else if (strcmp(sWeapon, "weapon_hunting_rifle") == 0)
			{
				bIsL4D2Game() ? SetEntProp(client, Prop_Data, "m_iAmmo", iAmmo, _, 9) : SetEntProp(client, Prop_Data, "m_iAmmo", iAmmo, _, 2);
			}
			else if (strcmp(sWeapon, "weapon_sniper_scout") == 0 || strcmp(sWeapon, "weapon_sniper_military") == 0 || strcmp(sWeapon, "weapon_sniper_awp") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", iAmmo, _, 10);
			}
			else if (strcmp(sWeapon, "weapon_grenade_launcher") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", iAmmo, _, 17);
			}
		}
		SetEntProp(GetPlayerWeaponSlot(client, 0), Prop_Data, "m_iClip1", iAmmo, 1);
	}
}