// Super Tanks++: Drop Ability
bool g_bDrop[MAXPLAYERS + 1];
char g_sWeaponClass[32][128];
char g_sWeaponModel[32][128];
float g_flDropWeaponScale[ST_MAXTYPES + 1];
float g_flDropWeaponScale2[ST_MAXTYPES + 1];
int g_iDrop[MAXPLAYERS + 1];
int g_iDropAbility[ST_MAXTYPES + 1];
int g_iDropAbility2[ST_MAXTYPES + 1];
int g_iDropChance[ST_MAXTYPES + 1];
int g_iDropChance2[ST_MAXTYPES + 1];
int g_iDropClipChance[ST_MAXTYPES + 1];
int g_iDropClipChance2[ST_MAXTYPES + 1];
int g_iDropWeapon[MAXPLAYERS + 1];

void vDropConfigs(KeyValues keyvalues, int index, bool main)
{
	main ? (g_iDropAbility[index] = keyvalues.GetNum("Drop Ability/Ability Enabled", 0)) : (g_iDropAbility2[index] = keyvalues.GetNum("Drop Ability/Ability Enabled", g_iDropAbility[index]));
	main ? (g_iDropAbility[index] = iSetCellLimit(g_iDropAbility[index], 0, 1)) : (g_iDropAbility2[index] = iSetCellLimit(g_iDropAbility2[index], 0, 1));
	main ? (g_iDropChance[index] = keyvalues.GetNum("Drop Ability/Drop Chance", 4)) : (g_iDropChance2[index] = keyvalues.GetNum("Drop Ability/Drop Chance", g_iDropChance[index]));
	main ? (g_iDropChance[index] = iSetCellLimit(g_iDropChance[index], 1, 9999999999)) : (g_iDropChance2[index] = iSetCellLimit(g_iDropChance2[index], 1, 9999999999));
	main ? (g_iDropClipChance[index] = keyvalues.GetNum("Drop Ability/Drop Clip Chance", 4)) : (g_iDropClipChance2[index] = keyvalues.GetNum("Drop Ability/Drop Clip Chance", g_iDropClipChance[index]));
	main ? (g_iDropClipChance[index] = iSetCellLimit(g_iDropClipChance[index], 1, 9999999999)) : (g_iDropClipChance2[index] = iSetCellLimit(g_iDropClipChance2[index], 1, 9999999999));
	main ? (g_flDropWeaponScale[index] = keyvalues.GetFloat("Drop Ability/Drop Weapon Scale", 1.0)) : (g_flDropWeaponScale2[index] = keyvalues.GetFloat("Drop Ability/Drop Weapon Scale", g_flDropWeaponScale[index]));
	main ? (g_flDropWeaponScale[index] = flSetFloatLimit(g_flDropWeaponScale[index], 1.0, 2.0)) : (g_flDropWeaponScale2[index] = flSetFloatLimit(g_flDropWeaponScale2[index], 1.0, 2.0));
}

void vDropDeath(int client)
{
	int iDropChance = !g_bTankConfig[g_iTankType[client]] ? g_iDropChance[g_iTankType[client]] : g_iDropChance2[g_iTankType[client]];
	if (bIsValidEntity(g_iDrop[client]) && GetRandomInt(1, iDropChance) == 1)
	{
		float flDropWeaponScale = !g_bTankConfig[g_iTankType[client]] ? g_flDropWeaponScale[g_iTankType[client]] : g_flDropWeaponScale[g_iTankType[client]];
		float flPos[3];
		float flAngle[3];
		GetClientEyePosition(client, flPos);
		GetClientAbsAngles(client, flAngle);
		if (StrContains(g_sWeaponClass[g_iDropWeapon[client]], "weapon") != -1)
		{
			int iDrop = CreateEntityByName(g_sWeaponClass[g_iDropWeapon[client]]);
			if (bIsValidEntity(iDrop))
			{
				TeleportEntity(iDrop, flPos, flAngle, NULL_VECTOR);
				DispatchSpawn(iDrop);
				if (bIsL4D2Game())
				{
					SetEntPropFloat(iDrop , Prop_Send,"m_flModelScale", flDropWeaponScale);
				}
			}
			int iAmmo;
			int iClip;
			if (strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_autoshotgun") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_shotgun_spas") == 0)
			{
				iAmmo = g_cvSTFindConVar[6].IntValue;
			}
			else if (strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_pumpshotgun") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_shotgun_chrome") == 0)
			{
				iAmmo = g_cvSTFindConVar[7].IntValue;
			}
			else if (strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_hunting_rifle") == 0)
			{
				iAmmo = g_cvSTFindConVar[8].IntValue;
			}
			else if (strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_rifle") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_rifle_ak47") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_rifle_desert") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_rifle_sg552") == 0)
			{
				iAmmo = g_cvSTFindConVar[9].IntValue;
			}
			else if (strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_grenade_launcher") == 0)
			{
				iAmmo = g_cvSTFindConVar[10].IntValue;
			}
			else if (strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_smg") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_smg_silenced") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_smg_mp5") == 0)
			{
				iAmmo = g_cvSTFindConVar[11].IntValue;
			}
			else if (strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_sniper_scout") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_sniper_military") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[client]], "weapon_sniper_awp") == 0)
			{
				iAmmo = g_cvSTFindConVar[12].IntValue;
			}
			int iDropClipChance = !g_bTankConfig[g_iTankType[client]] ? g_iDropClipChance[g_iTankType[client]] : g_iDropClipChance2[g_iTankType[client]];
			if (GetRandomInt(1, iDropClipChance) == 1)
			{
				iClip = iAmmo; 
			}
			if (iClip > 0)
			{
				SetEntProp(iDrop, Prop_Send, "m_iClip1", iClip);
			}
			if (iAmmo > 0)
			{
				SetEntProp(iDrop, Prop_Send, "m_iExtraPrimaryAmmo", iAmmo);
			}
		}
		else
		{
			int iDrop = CreateEntityByName("weapon_melee");
			if (bIsValidEntity(iDrop))
			{
				DispatchKeyValue(iDrop, "melee_script_name", g_sWeaponClass[g_iDropWeapon[client]]);
				TeleportEntity(iDrop, flPos, flAngle, NULL_VECTOR);
				DispatchSpawn(iDrop);
				if (bIsL4D2Game())
				{
					SetEntPropFloat(iDrop, Prop_Send,"m_flModelScale", flDropWeaponScale);
				}
			}
		}
	}
	vDeleteDrop(client);
}

void vDrop()
{
	if (bIsL4D2Game())
	{
		g_sWeaponModel[1] = WEAPON2_AK47_W;
		g_sWeaponModel[2] = WEAPON2_AUTO_W;
		g_sWeaponModel[3] = WEAPON2_AWP_W;
		g_sWeaponModel[4] = WEAPON2_CHROME_W;
		g_sWeaponModel[5] = WEAPON2_DESERT_W;
		g_sWeaponModel[6] = WEAPON2_GRENADE_W;
		g_sWeaponModel[7] = WEAPON2_HUNT_W;
		g_sWeaponModel[8] = WEAPON2_M16_W;
		g_sWeaponModel[9] = WEAPON2_M60_W;
		g_sWeaponModel[10] = WEAPON2_MAGNUM_W;
		g_sWeaponModel[11] = WEAPON2_MILITARY_W;
		g_sWeaponModel[12] = WEAPON2_MP5_W;
		g_sWeaponModel[13] = WEAPON2_PUMP_W;
		g_sWeaponModel[14] = WEAPON2_PUMP_W;
		g_sWeaponModel[15] = WEAPON2_SCOUT_W;
		g_sWeaponModel[16] = WEAPON2_SG552_W;
		g_sWeaponModel[17] = WEAPON2_SILENCED_W;
		g_sWeaponModel[18] = WEAPON2_SMG_W;
		g_sWeaponModel[19] = WEAPON2_SPAS_W;
		g_sWeaponModel[20] = MELEE_AXE_W;
		g_sWeaponModel[21] = MELEE_BAT_W;
		g_sWeaponModel[22] = MELEE_CHAINSAW_W;
		g_sWeaponModel[23] = MELEE_CRICKET_W;
		g_sWeaponModel[24] = MELEE_CROWBAR_W;
		g_sWeaponModel[25] = MELEE_GOLFCLUB_W;
		g_sWeaponModel[26] = MELEE_GUITAR_W;
		g_sWeaponModel[27] = MELEE_KATANA_W;
		g_sWeaponModel[28] = MELEE_KNIFE_W;
		g_sWeaponModel[29] = MELEE_MACHETE_W;
		g_sWeaponModel[30] = MELEE_PAN_W;
		g_sWeaponModel[31] = MELEE_TONFA_W;
		g_sWeaponClass[1] = "weapon_rifle_ak47";
		g_sWeaponClass[2] = "weapon_autoshotgun";
		g_sWeaponClass[3] = "weapon_sniper_awp";
		g_sWeaponClass[4] = "weapon_shotgun_chrome";
		g_sWeaponClass[5] = "weapon_rifle_desert";
		g_sWeaponClass[6] = "weapon_grenade_launcher";
		g_sWeaponClass[7] = "weapon_hunting_rifle";
		g_sWeaponClass[8] = "weapon_rifle";
		g_sWeaponClass[9] = "weapon_rifle_m60";
		g_sWeaponClass[10] = "weapon_pistol_magnum";
		g_sWeaponClass[11] = "weapon_sniper_military";
		g_sWeaponClass[12] = "weapon_smg_mp5";
		g_sWeaponClass[13] = "weapon_pistol";
		g_sWeaponClass[14] = "weapon_pumpshotgun";
		g_sWeaponClass[15] = "weapon_sniper_scout";
		g_sWeaponClass[16] = "weapon_rifle_sg552";
		g_sWeaponClass[17] = "weapon_smg_silenced";
		g_sWeaponClass[18] = "weapon_smg";
		g_sWeaponClass[19] = "weapon_shotgun_spas";
		g_sWeaponClass[20] = "fireaxe";
		g_sWeaponClass[21] = "baseball_bat";
		g_sWeaponClass[22] = "weapon_chainsaw";
		g_sWeaponClass[23] = "cricket_bat";
		g_sWeaponClass[24] = "crowbar";
		g_sWeaponClass[25] = "golfclub";
		g_sWeaponClass[26] = "electric_guitar";
		g_sWeaponClass[27] = "katana";
		g_sWeaponClass[28] = "knife";
		g_sWeaponClass[29] = "machete";
		g_sWeaponClass[30] = "frying_pan";
		g_sWeaponClass[31] = "tonfa";
	}
	else
	{
		g_sWeaponModel[1] = WEAPON_AUTO_W;
		g_sWeaponModel[2] = WEAPON_HUNT_W;
		g_sWeaponModel[3] = WEAPON_M16_W;
		g_sWeaponModel[4] = WEAPON_PISTOL_W;
		g_sWeaponModel[5] = WEAPON_PUMP_W;
		g_sWeaponModel[6] = WEAPON_SMG_W;
		g_sWeaponClass[1] = "weapon_autoshotgun";
		g_sWeaponClass[2] = "weapon_hunting_rifle";
		g_sWeaponClass[3] = "weapon_rifle";
		g_sWeaponClass[4] = "weapon_pistol";
		g_sWeaponClass[5] = "weapon_pumpshotgun";
		g_sWeaponClass[6] = "weapon_smg";
	}
}

void vDropAbility(int client)
{
	int iDropAbility = !g_bTankConfig[g_iTankType[client]] ? g_iDropAbility[g_iTankType[client]] : g_iDropAbility2[g_iTankType[client]];
	int iCloneMode = !g_bTankConfig[g_iTankType[client]] ? g_iCloneMode[g_iTankType[client]] : g_iCloneMode2[g_iTankType[client]];
	if (iDropAbility == 1 && (iCloneMode == 1 || (iCloneMode == 0 && !g_bCloned[client])) && bIsTank(client) && !g_bDrop[client])
	{
		g_bDrop[client] = true;
		CreateTimer(1.0, tTimerDrop, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vDeleteDrop(int client)
{
	if (bIsValidEntity(g_iDrop[client]))
	{
		vDeleteEntity(g_iDrop[client]);
		SDKUnhook(g_iDrop[client], SDKHook_SetTransmit, ModelSetTransmit);
	}
	g_iDrop[client] = 0;
}

void vGetPosAng(float pos[3], float angle[3], int position, float &scale)
{
	switch (position)
	{
		case 1:
		{
			vSetVector(pos, 1.0, -5.0, 3.0);
			vSetVector(angle, 0.0, -90.0, 90.0);
		}
		case 2:
		{
			vSetVector(pos, 4.0, -5.0, -3.0);
			vSetVector(angle, 0.0, -90.0, 90.0);
		}
	}
}

void vGetPosAng2(int client, int weapon, float pos[3], float angle[3], int position, float &scale)
{
	if (weapon == 22)
	{
		switch (position)
		{
			case 1:
			{
				vSetVector(pos, -23.0, -30.0, -5.0);
				vSetVector(angle, 0.0, 60.0, 180.0);
			}
			case 2:
			{
				vSetVector(pos, -9.0, -32.0, -1.0);
				vSetVector(angle, 0.0, 60.0, 180.0);
			}
		}
	}
	else if (weapon >= 1)
	{
		switch (position)
		{
			case 1:
			{
				vSetVector(pos, 1.0, -5.0, 3.0);
				vSetVector(angle, 0.0, -90.0, 90.0);
			}
			case 2:
			{
				vSetVector(pos, 4.0, -5.0, -3.0);
				vSetVector(angle, 0.0, -90.0, 90.0);
			}
		}
	}	
	else
	{
		switch (position)
		{
			case 1:
			{
				vSetVector(pos, -4.0, 0.0, 3.0);
				vSetVector(angle, 0.0, -11.0, 100.0);
			}
			case 2:
			{
				vSetVector(pos, 4.0, 0.0, -3.0);
				vSetVector(angle, 0.0, -11.0, 100.0);
			}
		}
	}
	scale = 2.5;
	switch (weapon)
	{
		case 22: scale = 2.0;
		case 23: scale = 1.7;
		case 26: scale = 2.3;
		case 27: scale = 3.0;
		case 29: scale = 4.0;
		case 30: scale = 3.5;
	}
	float flDropWeaponScale = !g_bTankConfig[g_iTankType[client]] ? g_flDropWeaponScale[g_iTankType[client]] : g_flDropWeaponScale2[g_iTankType[client]];
	scale = scale * flDropWeaponScale;
}

void vResetDrop(int client)
{
	g_bDrop[client] = false;
	g_iDrop[client] = 0;
	g_iDropWeapon[client] = 0;
}

public Action tTimerDrop(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	if (bIsTank(iTank))
	{
		vDeleteDrop(iTank);
	 	int iWeapon = bIsL4D2Game() ? GetRandomInt(1, 31) : GetRandomInt(1, 6);
		int iPosition;
		switch (GetRandomInt(1, 2))
		{
			case 1: iPosition = 1;
			case 2: iPosition = 2;
		}
		float flScale;
		int iDrop = CreateEntityByName("prop_dynamic_override");
		if (bIsValidEntity(iDrop))
		{
			float flPos[3];
			float flAngle[3];
			char sPosition[32];
			SetEntityModel(iDrop, g_sWeaponModel[iWeapon]);
			TeleportEntity(iDrop, flPos, flAngle, NULL_VECTOR);
			DispatchSpawn(iDrop);
			vSetEntityParent(iDrop, iTank);
			switch (iPosition)
			{
				case 1: sPosition = "rhand";
				case 2: sPosition = "lhand";
			}
			SetVariantString(sPosition);
			AcceptEntityInput(iDrop, "SetParentAttachment");
			bIsL4D2Game() ? vGetPosAng2(iTank, iWeapon, flPos, flAngle, iPosition, flScale) : vGetPosAng(flPos, flAngle, iPosition, flScale);
			SetEntProp(iDrop, Prop_Send, "m_CollisionGroup", 2);
			if (bIsL4D2Game())
			{
				SetEntPropFloat(iDrop , Prop_Send,"m_flModelScale", flScale);
			}
			g_iDrop[iTank] = iDrop;
			g_iDropWeapon[iTank] = iWeapon;
			SDKHook(g_iDrop[iTank], SDKHook_SetTransmit, ModelSetTransmit);
		}
	}
	return Plugin_Continue;
}