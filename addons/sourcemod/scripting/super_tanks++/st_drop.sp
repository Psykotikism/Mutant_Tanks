// Super Tanks++: Drop Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Drop Ability",
	author = ST_AUTHOR,
	description = "The Super Tank drops weapons upon death.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bDrop[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
char g_sWeaponClass[32][128], g_sWeaponModel[32][128];
ConVar g_cvSTAssaultRifleAmmo, g_cvSTAutoShotgunAmmo, g_cvSTGrenadeLauncherAmmo, g_cvSTHuntingRifleAmmo, g_cvSTShotgunAmmo, g_cvSTSMGAmmo, g_cvSTSniperRifleAmmo;
float g_flDropWeaponScale[ST_MAXTYPES + 1], g_flDropWeaponScale2[ST_MAXTYPES + 1];
int g_iDrop[MAXPLAYERS + 1], g_iDropAbility[ST_MAXTYPES + 1], g_iDropAbility2[ST_MAXTYPES + 1], g_iDropChance[ST_MAXTYPES + 1], g_iDropChance2[ST_MAXTYPES + 1], g_iDropClipChance[ST_MAXTYPES + 1], g_iDropClipChance2[ST_MAXTYPES + 1], g_iDropMessage[ST_MAXTYPES + 1], g_iDropMessage2[ST_MAXTYPES + 1], g_iDropMode[ST_MAXTYPES + 1], g_iDropMode2[ST_MAXTYPES + 1], g_iDropWeapon[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (GetEngineVersion() != Engine_Left4Dead && !bIsL4D2())
	{
		strcopy(error, err_max, "[ST++] Drop Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	g_bCloneInstalled = LibraryExists("st_clone");
}

public void OnLibraryAdded(const char[] name)
{
	if (strcmp(name, "st_clone", false) == 0)
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (strcmp(name, "st_clone", false) == 0)
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	LoadTranslations("super_tanks++.phrases");
	g_cvSTAssaultRifleAmmo = FindConVar("ammo_assaultrifle_max");
	g_cvSTAutoShotgunAmmo = bIsL4D2() ? FindConVar("ammo_autoshotgun_max") : FindConVar("ammo_buckshot_max");
	g_cvSTGrenadeLauncherAmmo = FindConVar("ammo_grenadelauncher_max");
	g_cvSTHuntingRifleAmmo = FindConVar("ammo_huntingrifle_max");
	g_cvSTShotgunAmmo = bIsL4D2() ? FindConVar("ammo_shotgun_max") : FindConVar("ammo_buckshot_max");
	g_cvSTSMGAmmo = FindConVar("ammo_smg_max");
	g_cvSTSniperRifleAmmo = FindConVar("ammo_sniperrifle_max");
}

public void OnMapStart()
{
	vReset();
	PrecacheModel(MELEE_AXE_V, true);
	PrecacheModel(MELEE_AXE_W, true);
	PrecacheModel(MELEE_CHAINSAW_V, true);
	PrecacheModel(MELEE_CHAINSAW_W, true);
	PrecacheModel(MELEE_CRICKET_V, true);
	PrecacheModel(MELEE_CRICKET_W, true);
	PrecacheModel(MELEE_CROWBAR_V, true);
	PrecacheModel(MELEE_CROWBAR_W, true);
	PrecacheModel(MELEE_GOLFCLUB_V, true);
	PrecacheModel(MELEE_GOLFCLUB_W, true);
	PrecacheModel(MELEE_GUITAR_V, true);
	PrecacheModel(MELEE_GUITAR_W, true);
	PrecacheModel(MELEE_KATANA_V, true);
	PrecacheModel(MELEE_KATANA_W, true);
	PrecacheModel(MELEE_KNIFE_V, true);
	PrecacheModel(MELEE_KNIFE_W, true);
	PrecacheModel(MELEE_MACHETE_V, true);
	PrecacheModel(MELEE_MACHETE_W, true);
	PrecacheModel(MELEE_PAN_V, true);
	PrecacheModel(MELEE_PAN_W, true);
	PrecacheModel(MELEE_TONFA_V, true);
	PrecacheModel(MELEE_TONFA_W, true);
	PrecacheGeneric(SCRIPT_AXE, true);
	PrecacheGeneric(SCRIPT_BAT, true);
	PrecacheGeneric(SCRIPT_CRICKET, true);
	PrecacheGeneric(SCRIPT_CROWBAR, true);
	PrecacheGeneric(SCRIPT_GOLFCLUB, true);
	PrecacheGeneric(SCRIPT_GUITAR, true);
	PrecacheGeneric(SCRIPT_KATANA, true);
	PrecacheGeneric(SCRIPT_KNIFE, true);
	PrecacheGeneric(SCRIPT_MACHETE, true);
	PrecacheGeneric(SCRIPT_PAN, true);
	PrecacheGeneric(SCRIPT_TONFA, true);
	PrecacheModel(WEAPON2_AWP_V, true);
	PrecacheModel(WEAPON2_AWP_W, true);
	PrecacheModel(WEAPON2_GRENADE_V, true);
	PrecacheModel(WEAPON2_GRENADE_W, true);
	PrecacheModel(WEAPON2_M60_V, true);
	PrecacheModel(WEAPON2_M60_W, true);
	PrecacheModel(WEAPON2_MP5_V, true);
	PrecacheModel(WEAPON2_MP5_W, true);
	PrecacheModel(WEAPON2_SCOUT_V, true);
	PrecacheModel(WEAPON2_SCOUT_W, true);
	PrecacheModel(WEAPON2_SG552_V, true);
	PrecacheModel(WEAPON2_SG552_W, true);
	if (bIsL4D2())
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

public void OnClientPutInServer(int client)
{
	vResetDrop(client);
}

public void OnMapEnd()
{
	vReset();
}

public void ST_Configs(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sName[MAX_NAME_LENGTH + 1];
		Format(sName, sizeof(sName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iDropAbility[iIndex] = kvSuperTanks.GetNum("Drop Ability/Ability Enabled", 0)) : (g_iDropAbility2[iIndex] = kvSuperTanks.GetNum("Drop Ability/Ability Enabled", g_iDropAbility[iIndex]));
			main ? (g_iDropAbility[iIndex] = iClamp(g_iDropAbility[iIndex], 0, 1)) : (g_iDropAbility2[iIndex] = iClamp(g_iDropAbility2[iIndex], 0, 1));
			main ? (g_iDropMessage[iIndex] = kvSuperTanks.GetNum("Drop Ability/Ability Message", 0)) : (g_iDropMessage2[iIndex] = kvSuperTanks.GetNum("Drop Ability/Ability Message", g_iDropMessage[iIndex]));
			main ? (g_iDropMessage[iIndex] = iClamp(g_iDropMessage[iIndex], 0, 1)) : (g_iDropMessage2[iIndex] = iClamp(g_iDropMessage2[iIndex], 0, 1));
			main ? (g_iDropChance[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Chance", 4)) : (g_iDropChance2[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Chance", g_iDropChance[iIndex]));
			main ? (g_iDropChance[iIndex] = iClamp(g_iDropChance[iIndex], 1, 9999999999)) : (g_iDropChance2[iIndex] = iClamp(g_iDropChance2[iIndex], 1, 9999999999));
			main ? (g_iDropClipChance[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Clip Chance", 4)) : (g_iDropClipChance2[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Clip Chance", g_iDropClipChance[iIndex]));
			main ? (g_iDropClipChance[iIndex] = iClamp(g_iDropClipChance[iIndex], 1, 9999999999)) : (g_iDropClipChance2[iIndex] = iClamp(g_iDropClipChance2[iIndex], 1, 9999999999));
			main ? (g_iDropMode[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Mode", 0)) : (g_iDropMode2[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Mode", g_iDropMode[iIndex]));
			main ? (g_iDropMode[iIndex] = iClamp(g_iDropMode[iIndex], 0, 2)) : (g_iDropMode2[iIndex] = iClamp(g_iDropMode2[iIndex], 0, 2));
			main ? (g_flDropWeaponScale[iIndex] = kvSuperTanks.GetFloat("Drop Ability/Drop Weapon Scale", 1.0)) : (g_flDropWeaponScale2[iIndex] = kvSuperTanks.GetFloat("Drop Ability/Drop Weapon Scale", g_flDropWeaponScale[iIndex]));
			main ? (g_flDropWeaponScale[iIndex] = flClamp(g_flDropWeaponScale[iIndex], 1.0, 2.0)) : (g_flDropWeaponScale2[iIndex] = flClamp(g_flDropWeaponScale2[iIndex], 1.0, 2.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId),
			iDropChance = !g_bTankConfig[ST_TankType(iTank)] ? g_iDropChance[ST_TankType(iTank)] : g_iDropChance2[ST_TankType(iTank)];
		if (iDropAbility(iTank) == 1 && GetRandomInt(1, iDropChance) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && bIsValidEntity(g_iDrop[iTank]))
		{
			float flPos[3], flAngles[3];
			int iDropMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_iDropMessage[ST_TankType(iTank)] : g_iDropMessage2[ST_TankType(iTank)];
			GetClientEyePosition(iTank, flPos);
			GetClientAbsAngles(iTank, flAngles);
			if (iDropMode(iTank) != 2 && StrContains(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon") != -1)
			{
				int iDrop = CreateEntityByName(g_sWeaponClass[g_iDropWeapon[iTank]]);
				if (bIsValidEntity(iDrop))
				{
					TeleportEntity(iDrop, flPos, flAngles, NULL_VECTOR);
					DispatchSpawn(iDrop);
					if (bIsL4D2())
					{
						SetEntPropFloat(iDrop , Prop_Send,"m_flModelScale", flDropWeaponScale(iTank));
					}
					int iAmmo, iClip;
					if (strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_rifle") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_rifle_ak47") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_rifle_desert") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_rifle_sg552") == 0)
					{
						iAmmo = g_cvSTAssaultRifleAmmo.IntValue;
					}
					else if (strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_autoshotgun") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_shotgun_spas") == 0)
					{
						iAmmo = g_cvSTAutoShotgunAmmo.IntValue;
					}
					else if (strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_grenade_launcher") == 0)
					{
						iAmmo = g_cvSTGrenadeLauncherAmmo.IntValue;
					}
					else if (strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_hunting_rifle") == 0)
					{
						iAmmo = g_cvSTHuntingRifleAmmo.IntValue;
					}
					else if (strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_pumpshotgun") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_shotgun_chrome") == 0)
					{
						iAmmo = g_cvSTShotgunAmmo.IntValue;
					}
					else if (strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_smg") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_smg_silenced") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_smg_mp5") == 0)
					{
						iAmmo = g_cvSTSMGAmmo.IntValue;
					}
					else if (strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_sniper_scout") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_sniper_military") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_sniper_awp") == 0)
					{
						iAmmo = g_cvSTSniperRifleAmmo.IntValue;
					}
					int iDropClipChance = !g_bTankConfig[ST_TankType(iTank)] ? g_iDropClipChance[ST_TankType(iTank)] : g_iDropClipChance2[ST_TankType(iTank)];
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
					if (iDropMessage == 1)
					{
						char sTankName[MAX_NAME_LENGTH + 1];
						ST_TankName(iTank, sTankName);
						PrintToChatAll("%s %t", ST_PREFIX2, "Drop", sTankName);
					}
				}
			}
			else if (iDropMode(iTank) != 1 && bIsL4D2())
			{
				int iDrop = CreateEntityByName("weapon_melee");
				if (bIsValidEntity(iDrop))
				{
					DispatchKeyValue(iDrop, "melee_script_name", g_sWeaponClass[g_iDropWeapon[iTank]]);
					TeleportEntity(iDrop, flPos, flAngles, NULL_VECTOR);
					DispatchSpawn(iDrop);
					SetEntPropFloat(iDrop, Prop_Send,"m_flModelScale", flDropWeaponScale(iTank));
					if (iDropMessage == 1)
					{
						char sTankName[MAX_NAME_LENGTH + 1];
						ST_TankName(iTank, sTankName);
						PrintToChatAll("%s %t", ST_PREFIX2, "Drop2", sTankName);
					}
				}
			}
		}
		vDeleteDrop(iTank);
	}
}

public void ST_BossStage(int client)
{
	vDeleteDrop(client);
}

public void ST_Ability(int client)
{
	if (iDropAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client) && !g_bDrop[client])
	{
		g_bDrop[client] = true;
		CreateTimer(1.0, tTimerDrop, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

stock void vDeleteDrop(int client)
{
	if (bIsValidEntity(g_iDrop[client]))
	{
		RemoveEntity(g_iDrop[client]);
	}
	g_iDrop[client] = 0;
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			vResetDrop(iPlayer);
		}
	}
}

stock void vResetDrop(int client)
{
	g_bDrop[client] = false;
	g_iDrop[client] = 0;
	g_iDropWeapon[client] = 0;
}

stock float flDropWeaponScale(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_flDropWeaponScale[ST_TankType(client)] : g_flDropWeaponScale2[ST_TankType(client)];
}

stock int iDropAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iDropAbility[ST_TankType(client)] : g_iDropAbility2[ST_TankType(client)];
}

stock int iDropMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iDropMode[ST_TankType(client)] : g_iDropMode2[ST_TankType(client)];
}

public Action tTimerDrop(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bDrop[iTank] = false;
		return Plugin_Stop;
	}
	if (iDropAbility(iTank) == 0)
	{
		g_bDrop[iTank] = false;
		return Plugin_Stop;
	}
	vDeleteDrop(iTank);
	int iDropValue, iPosition;
	switch (iDropMode(iTank))
	{
		case 0: iDropValue = GetRandomInt(1, 31);
		case 1: iDropValue = GetRandomInt(1, 19);
		case 2: iDropValue = GetRandomInt(20, 31);
	}
	int iWeapon = bIsL4D2() ? iDropValue : GetRandomInt(1, 6);
	switch (GetRandomInt(1, 2))
	{
		case 1: iPosition = 1;
		case 2: iPosition = 2;
	}
	float flScale;
	int iDrop = CreateEntityByName("prop_dynamic_override");
	if (bIsValidEntity(iDrop))
	{
		float flPos[3], flAngles[3];
		char sPosition[32];
		SetEntityModel(iDrop, g_sWeaponModel[iWeapon]);
		TeleportEntity(iDrop, flPos, flAngles, NULL_VECTOR);
		DispatchSpawn(iDrop);
		vSetEntityParent(iDrop, iTank);
		switch (iPosition)
		{
			case 1: sPosition = "rhand";
			case 2: sPosition = "lhand";
		}
		SetVariantString(sPosition);
		AcceptEntityInput(iDrop, "SetParentAttachment");
		if (bIsL4D2())
		{
			if (iWeapon == 22)
			{
				switch (iPosition)
				{
					case 1:
					{
						vSetVector(flPos, -23.0, -30.0, -5.0);
						vSetVector(flAngles, 0.0, 60.0, 180.0);
					}
					case 2:
					{
						vSetVector(flPos, -9.0, -32.0, -1.0);
						vSetVector(flAngles, 0.0, 60.0, 180.0);
					}
				}
			}
			else if (iWeapon >= 1)
			{
				switch (iPosition)
				{
					case 1:
					{
						vSetVector(flPos, 1.0, -5.0, 3.0);
						vSetVector(flAngles, 0.0, -90.0, 90.0);
					}
					case 2:
					{
						vSetVector(flPos, 4.0, -5.0, -3.0);
						vSetVector(flAngles, 0.0, -90.0, 90.0);
					}
				}
			}
			else
			{
				switch (iPosition)
				{
					case 1:
					{
						vSetVector(flPos, -4.0, 0.0, 3.0);
						vSetVector(flAngles, 0.0, -11.0, 100.0);
					}
					case 2:
					{
						vSetVector(flPos, 4.0, 0.0, -3.0);
						vSetVector(flAngles, 0.0, -11.0, 100.0);
					}
				}
			}
			flScale = 2.5;
			switch (iWeapon)
			{
				case 29: flScale = 2.0;
				case 21: flScale = 1.7;
				case 30: flScale = 2.3;
				case 26: flScale = 3.0;
				case 22: flScale = 4.0;
				case 27: flScale = 3.5;
			}
			flScale = flScale * flDropWeaponScale(iTank);
		}
		else
		{
			switch (iPosition)
			{
				case 1:
				{
					vSetVector(flPos, 1.0, -5.0, 3.0);
					vSetVector(flAngles, 0.0, -90.0, 90.0);
				}
				case 2:
				{
					vSetVector(flPos, 4.0, -5.0, -3.0);
					vSetVector(flAngles, 0.0, -90.0, 90.0);
				}
			}
		}
		SetEntProp(iDrop, Prop_Send, "m_CollisionGroup", 2);
		if (bIsL4D2())
		{
			SetEntPropFloat(iDrop , Prop_Send,"m_flModelScale", flScale);
		}
		g_iDrop[iTank] = iDrop;
		g_iDropWeapon[iTank] = iWeapon;
	}
	return Plugin_Continue;
}