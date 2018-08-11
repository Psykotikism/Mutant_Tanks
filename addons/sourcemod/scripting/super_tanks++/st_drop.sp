// Super Tanks++: Drop Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Drop Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bDrop[MAXPLAYERS + 1];
bool g_bTankConfig[ST_MAXTYPES + 1];
char g_sWeaponClass[32][128];
char g_sWeaponModel[32][128];
ConVar g_cvSTFindConVar[7];
float g_flDropWeaponScale[ST_MAXTYPES + 1];
float g_flDropWeaponScale2[ST_MAXTYPES + 1];
int g_iDrop[MAXPLAYERS + 1];
int g_iDropAbility[ST_MAXTYPES + 1];
int g_iDropAbility2[ST_MAXTYPES + 1];
int g_iDropChance[ST_MAXTYPES + 1];
int g_iDropChance2[ST_MAXTYPES + 1];
int g_iDropClipChance[ST_MAXTYPES + 1];
int g_iDropClipChance2[ST_MAXTYPES + 1];
int g_iDropMode[ST_MAXTYPES + 1];
int g_iDropMode2[ST_MAXTYPES + 1];
int g_iDropWeapon[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Drop Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	if (!LibraryExists("super_tanks++"))
	{
		SetFailState("No Super Tanks++ library found.");
	}
}

public void OnPluginStart()
{
	g_cvSTFindConVar[0] = bIsL4D2Game() ? FindConVar("ammo_autoshotgun_max") : FindConVar("ammo_buckshot_max");
	g_cvSTFindConVar[1] = bIsL4D2Game() ? FindConVar("ammo_shotgun_max") : FindConVar("ammo_buckshot_max");
	g_cvSTFindConVar[2] = FindConVar("ammo_huntingrifle_max");
	g_cvSTFindConVar[3] = FindConVar("ammo_assaultrifle_max");
	g_cvSTFindConVar[4] = FindConVar("ammo_grenadelauncher_max");
	g_cvSTFindConVar[5] = FindConVar("ammo_smg_max");
	g_cvSTFindConVar[6] = FindConVar("ammo_sniperrifle_max");
}

public void OnMapStart()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			vReset(iPlayer);
		}
	}
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

public void OnClientPostAdminCheck(int client)
{
	vReset(client);
}

public void OnClientDisconnect(int client)
{
	vReset(client);
}

public void OnMapEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			vReset(iPlayer);
		}
	}
}

public Action SetTransmit(int entity, int client)
{
	int iOwner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (iOwner == client)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public void ST_Configs(char[] savepath, int limit, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = 1; iIndex <= limit; iIndex++)
	{
		char sName[MAX_NAME_LENGTH + 1];
		Format(sName, sizeof(sName), "Tank %d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iDropAbility[iIndex] = kvSuperTanks.GetNum("Drop Ability/Ability Enabled", 0)) : (g_iDropAbility2[iIndex] = kvSuperTanks.GetNum("Drop Ability/Ability Enabled", g_iDropAbility[iIndex]));
			main ? (g_iDropAbility[iIndex] = iSetCellLimit(g_iDropAbility[iIndex], 0, 1)) : (g_iDropAbility2[iIndex] = iSetCellLimit(g_iDropAbility2[iIndex], 0, 1));
			main ? (g_iDropChance[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Chance", 4)) : (g_iDropChance2[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Chance", g_iDropChance[iIndex]));
			main ? (g_iDropChance[iIndex] = iSetCellLimit(g_iDropChance[iIndex], 1, 9999999999)) : (g_iDropChance2[iIndex] = iSetCellLimit(g_iDropChance2[iIndex], 1, 9999999999));
			main ? (g_iDropClipChance[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Clip Chance", 4)) : (g_iDropClipChance2[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Clip Chance", g_iDropClipChance[iIndex]));
			main ? (g_iDropClipChance[iIndex] = iSetCellLimit(g_iDropClipChance[iIndex], 1, 9999999999)) : (g_iDropClipChance2[iIndex] = iSetCellLimit(g_iDropClipChance2[iIndex], 1, 9999999999));
			main ? (g_iDropMode[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Mode", 0)) : (g_iDropMode2[iIndex] = kvSuperTanks.GetNum("Drop Ability/Drop Mode", g_iDropMode[iIndex]));
			main ? (g_iDropMode[iIndex] = iSetCellLimit(g_iDropMode[iIndex], 0, 2)) : (g_iDropMode2[iIndex] = iSetCellLimit(g_iDropMode2[iIndex], 0, 2));
			main ? (g_flDropWeaponScale[iIndex] = kvSuperTanks.GetFloat("Drop Ability/Drop Weapon Scale", 1.0)) : (g_flDropWeaponScale2[iIndex] = kvSuperTanks.GetFloat("Drop Ability/Drop Weapon Scale", g_flDropWeaponScale[iIndex]));
			main ? (g_flDropWeaponScale[iIndex] = flSetFloatLimit(g_flDropWeaponScale[iIndex], 1.0, 2.0)) : (g_flDropWeaponScale2[iIndex] = flSetFloatLimit(g_flDropWeaponScale2[iIndex], 1.0, 2.0));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (strcmp(name, "player_death") == 0)
	{
		int iTankId = event.GetInt("userid");
		int iTank = GetClientOfUserId(iTankId);
		int iDropAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iDropAbility[ST_TankType(iTank)] : g_iDropAbility2[ST_TankType(iTank)];
		int iDropChance = !g_bTankConfig[ST_TankType(iTank)] ? g_iDropChance[ST_TankType(iTank)] : g_iDropChance2[ST_TankType(iTank)];
		if (ST_TankAllowed(iTank) && iDropAbility == 1 && GetRandomInt(1, iDropChance) == 1 && bIsValidEntity(g_iDrop[iTank]))
		{
			int iDropMode = !g_bTankConfig[ST_TankType(iTank)] ? g_iDropMode[ST_TankType(iTank)] : g_iDropMode2[ST_TankType(iTank)];
			float flDropWeaponScale = !g_bTankConfig[ST_TankType(iTank)] ? g_flDropWeaponScale[ST_TankType(iTank)] : g_flDropWeaponScale[ST_TankType(iTank)];
			float flPos[3];
			float flAngle[3];
			GetClientEyePosition(iTank, flPos);
			GetClientAbsAngles(iTank, flAngle);
			if (iDropMode != 2 && StrContains(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon") != -1)
			{
				int iDrop = CreateEntityByName(g_sWeaponClass[g_iDropWeapon[iTank]]);
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
				if (strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_autoshotgun") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_shotgun_spas") == 0)
				{
					iAmmo = g_cvSTFindConVar[0].IntValue;
				}
				else if (strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_pumpshotgun") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_shotgun_chrome") == 0)
				{
					iAmmo = g_cvSTFindConVar[1].IntValue;
				}
				else if (strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_hunting_rifle") == 0)
				{
					iAmmo = g_cvSTFindConVar[2].IntValue;
				}
				else if (strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_rifle") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_rifle_ak47") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_rifle_desert") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_rifle_sg552") == 0)
				{
					iAmmo = g_cvSTFindConVar[3].IntValue;
				}
				else if (strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_grenade_launcher") == 0)
				{
					iAmmo = g_cvSTFindConVar[4].IntValue;
				}
				else if (strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_smg") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_smg_silenced") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_smg_mp5") == 0)
				{
					iAmmo = g_cvSTFindConVar[5].IntValue;
				}
				else if (strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_sniper_scout") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_sniper_military") == 0 || strcmp(g_sWeaponClass[g_iDropWeapon[iTank]], "weapon_sniper_awp") == 0)
				{
					iAmmo = g_cvSTFindConVar[6].IntValue;
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
			}
			else if (iDropMode != 1)
			{
				int iDrop = CreateEntityByName("weapon_melee");
				if (bIsValidEntity(iDrop))
				{
					DispatchKeyValue(iDrop, "melee_script_name", g_sWeaponClass[g_iDropWeapon[iTank]]);
					TeleportEntity(iDrop, flPos, flAngle, NULL_VECTOR);
					DispatchSpawn(iDrop);
					if (bIsL4D2Game())
					{
						SetEntPropFloat(iDrop, Prop_Send,"m_flModelScale", flDropWeaponScale);
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

public void ST_Spawn(int client)
{
	int iDropAbility = !g_bTankConfig[ST_TankType(client)] ? g_iDropAbility[ST_TankType(client)] : g_iDropAbility2[ST_TankType(client)];
	if (iDropAbility == 1 && ST_TankAllowed(client) && IsPlayerAlive(client) && !g_bDrop[client])
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
		SDKUnhook(g_iDrop[client], SDKHook_SetTransmit, SetTransmit);
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
	float flDropWeaponScale = !g_bTankConfig[ST_TankType(client)] ? g_flDropWeaponScale[ST_TankType(client)] : g_flDropWeaponScale2[ST_TankType(client)];
	scale = scale * flDropWeaponScale;
}

void vReset(int client)
{
	g_bDrop[client] = false;
	g_iDrop[client] = 0;
	g_iDropWeapon[client] = 0;
}

public Action tTimerDrop(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		g_bDrop[iTank] = false;
		return Plugin_Stop;
	}
	int iDropAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iDropAbility[ST_TankType(iTank)] : g_iDropAbility2[ST_TankType(iTank)];
	if (iDropAbility == 0)
	{
		g_bDrop[iTank] = false;
		return Plugin_Stop;
	}
	vDeleteDrop(iTank);
	int iDropMode = !g_bTankConfig[ST_TankType(iTank)] ? g_iDropMode[ST_TankType(iTank)] : g_iDropMode2[ST_TankType(iTank)];
 	int iDropValue;
	switch (iDropMode)
	{
		case 0: iDropValue = GetRandomInt(1, 31);
		case 1: iDropValue = GetRandomInt(1, 19);
		case 2: iDropValue = GetRandomInt(20, 31);
	}
	int iWeapon = bIsL4D2Game() ? iDropValue : GetRandomInt(1, 6);
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
		SDKHook(g_iDrop[iTank], SDKHook_SetTransmit, SetTransmit);
	}
	return Plugin_Continue;
}