// Super Tanks++: Ammo Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Ammo Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
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
int g_iAmmoRangeChance[ST_MAXTYPES + 1];
int g_iAmmoRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Ammo Ability only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnAllPluginsLoaded()
{
	if (!LibraryExists("super_tanks++"))
	{
		SetFailState("No Super Tanks++ library found.");
	}
}

public void OnMapStart()
{
	if (g_bLateLoad)
	{
		vLateLoad(true);
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

void vLateLoad(bool late)
{
	if (late)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				SDKHook(iPlayer, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		if (bIsTank(attacker) && bIsSurvivor(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iAmmoChance = !g_bTankConfig[ST_TankType(attacker)] ? g_iAmmoChance[ST_TankType(attacker)] : g_iAmmoChance2[ST_TankType(attacker)];
				int iAmmoHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iAmmoHit[ST_TankType(attacker)] : g_iAmmoHit2[ST_TankType(attacker)];
				vAmmoHit(victim, attacker, iAmmoChance, iAmmoHit);
			}
		}
	}
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
			main ? (g_iAmmoAbility[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ability Enabled", 0)) : (g_iAmmoAbility2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ability Enabled", g_iAmmoAbility[iIndex]));
			main ? (g_iAmmoAbility[iIndex] = iSetCellLimit(g_iAmmoAbility[iIndex], 0, 1)) : (g_iAmmoAbility2[iIndex] = iSetCellLimit(g_iAmmoAbility2[iIndex], 0, 1));
			main ? (g_iAmmoChance[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Chance", 4)) : (g_iAmmoChance2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Chance", g_iAmmoChance[iIndex]));
			main ? (g_iAmmoChance[iIndex] = iSetCellLimit(g_iAmmoChance[iIndex], 1, 9999999999)) : (g_iAmmoChance2[iIndex] = iSetCellLimit(g_iAmmoChance2[iIndex], 1, 9999999999));
			main ? (g_iAmmoCount[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Count", 0)) : (g_iAmmoCount2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Count", g_iAmmoCount[iIndex]));
			main ? (g_iAmmoCount[iIndex] = iSetCellLimit(g_iAmmoCount[iIndex], 0, 25)) : (g_iAmmoCount2[iIndex] = iSetCellLimit(g_iAmmoCount2[iIndex], 0, 25));
			main ? (g_iAmmoHit[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Hit", 0)) : (g_iAmmoHit2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Hit", g_iAmmoHit[iIndex]));
			main ? (g_iAmmoHit[iIndex] = iSetCellLimit(g_iAmmoHit[iIndex], 0, 1)) : (g_iAmmoHit2[iIndex] = iSetCellLimit(g_iAmmoHit2[iIndex], 0, 1));
			main ? (g_flAmmoRange[iIndex] = kvSuperTanks.GetFloat("Ammo Ability/Ammo Range", 150.0)) : (g_flAmmoRange2[iIndex] = kvSuperTanks.GetFloat("Ammo Ability/Ammo Range", g_flAmmoRange[iIndex]));
			main ? (g_flAmmoRange[iIndex] = flSetFloatLimit(g_flAmmoRange[iIndex], 1.0, 9999999999.0)) : (g_flAmmoRange2[iIndex] = flSetFloatLimit(g_flAmmoRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iAmmoRangeChance[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Range Chance", 16)) : (g_iAmmoRangeChance2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Range Chance", g_iAmmoRangeChance[iIndex]));
			main ? (g_iAmmoRangeChance[iIndex] = iSetCellLimit(g_iAmmoRangeChance[iIndex], 1, 9999999999)) : (g_iAmmoRangeChance2[iIndex] = iSetCellLimit(g_iAmmoRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (bIsTank(client))
	{
		int iAmmoAbility = !g_bTankConfig[ST_TankType(client)] ? g_iAmmoAbility[ST_TankType(client)] : g_iAmmoAbility2[ST_TankType(client)];
		int iAmmoRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iAmmoChance[ST_TankType(client)] : g_iAmmoChance2[ST_TankType(client)];
		float flAmmoRange = !g_bTankConfig[ST_TankType(client)] ? g_flAmmoRange[ST_TankType(client)] : g_flAmmoRange2[ST_TankType(client)];
		float flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flAmmoRange)
				{
					vAmmoHit(iSurvivor, client, iAmmoRangeChance, iAmmoAbility);
				}
			}
		}
	}
}

void vAmmoHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && GetPlayerWeaponSlot(client, 0) > 0)
	{
		char sWeapon[32];
		int iActiveWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		int iAmmo = !g_bTankConfig[ST_TankType(owner)] ? g_iAmmoCount[ST_TankType(owner)] : g_iAmmoCount2[ST_TankType(owner)];
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

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

bool bIsValidEntity(int entity)
{
	return entity > 0 && entity <= 2048 && IsValidEntity(entity);
}