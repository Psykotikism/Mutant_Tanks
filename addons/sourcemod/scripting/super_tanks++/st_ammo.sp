// Super Tanks++: Ammo Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Ammo Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flAmmoRange[ST_MAXTYPES + 1], g_flAmmoRange2[ST_MAXTYPES + 1];
int g_iAmmoAbility[ST_MAXTYPES + 1], g_iAmmoAbility2[ST_MAXTYPES + 1], g_iAmmoChance[ST_MAXTYPES + 1], g_iAmmoChance2[ST_MAXTYPES + 1], g_iAmmoCount[ST_MAXTYPES + 1], g_iAmmoCount2[ST_MAXTYPES + 1], g_iAmmoHit[ST_MAXTYPES + 1], g_iAmmoHit2[ST_MAXTYPES + 1], g_iAmmoHitMode[ST_MAXTYPES + 1], g_iAmmoHitMode2[ST_MAXTYPES + 1], g_iAmmoMessage[ST_MAXTYPES + 1], g_iAmmoMessage2[ST_MAXTYPES + 1], g_iAmmoRangeChance[ST_MAXTYPES + 1], g_iAmmoRangeChance2[ST_MAXTYPES + 1];

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
	if (g_bLateLoad)
	{
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				OnClientPutInServer(iPlayer);
			}
		}
		g_bLateLoad = false;
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((iAmmoHitMode(attacker) == 0 || iAmmoHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vAmmoHit(victim, attacker, iAmmoChance(attacker), iAmmoHit(attacker), 1);
			}
		}
		else if ((iAmmoHitMode(victim) == 0 || iAmmoHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vAmmoHit(attacker, victim, iAmmoChance(victim), iAmmoHit(victim), 1);
			}
		}
	}
}

public void ST_Configs(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sName[MAX_NAME_LENGTH + 1];
		Format(sName, sizeof(sName), "Tank %d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iAmmoAbility[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ability Enabled", 0)) : (g_iAmmoAbility2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ability Enabled", g_iAmmoAbility[iIndex]));
			main ? (g_iAmmoAbility[iIndex] = iSetCellLimit(g_iAmmoAbility[iIndex], 0, 1)) : (g_iAmmoAbility2[iIndex] = iSetCellLimit(g_iAmmoAbility2[iIndex], 0, 1));
			main ? (g_iAmmoMessage[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ability Message", 0)) : (g_iAmmoMessage2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ability Message", g_iAmmoMessage[iIndex]));
			main ? (g_iAmmoMessage[iIndex] = iSetCellLimit(g_iAmmoMessage[iIndex], 0, 3)) : (g_iAmmoMessage2[iIndex] = iSetCellLimit(g_iAmmoMessage2[iIndex], 0, 3));
			main ? (g_iAmmoChance[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Chance", 4)) : (g_iAmmoChance2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Chance", g_iAmmoChance[iIndex]));
			main ? (g_iAmmoChance[iIndex] = iSetCellLimit(g_iAmmoChance[iIndex], 1, 9999999999)) : (g_iAmmoChance2[iIndex] = iSetCellLimit(g_iAmmoChance2[iIndex], 1, 9999999999));
			main ? (g_iAmmoCount[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Count", 0)) : (g_iAmmoCount2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Count", g_iAmmoCount[iIndex]));
			main ? (g_iAmmoCount[iIndex] = iSetCellLimit(g_iAmmoCount[iIndex], 0, 25)) : (g_iAmmoCount2[iIndex] = iSetCellLimit(g_iAmmoCount2[iIndex], 0, 25));
			main ? (g_iAmmoHit[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Hit", 0)) : (g_iAmmoHit2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Hit", g_iAmmoHit[iIndex]));
			main ? (g_iAmmoHit[iIndex] = iSetCellLimit(g_iAmmoHit[iIndex], 0, 1)) : (g_iAmmoHit2[iIndex] = iSetCellLimit(g_iAmmoHit2[iIndex], 0, 1));
			main ? (g_iAmmoHitMode[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Hit Mode", 0)) : (g_iAmmoHitMode2[iIndex] = kvSuperTanks.GetNum("Ammo Ability/Ammo Hit Mode", g_iAmmoHitMode[iIndex]));
			main ? (g_iAmmoHitMode[iIndex] = iSetCellLimit(g_iAmmoHitMode[iIndex], 0, 2)) : (g_iAmmoHitMode2[iIndex] = iSetCellLimit(g_iAmmoHitMode2[iIndex], 0, 2));
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
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iAmmoAbility = !g_bTankConfig[ST_TankType(client)] ? g_iAmmoAbility[ST_TankType(client)] : g_iAmmoAbility2[ST_TankType(client)],
			iAmmoRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iAmmoChance[ST_TankType(client)] : g_iAmmoChance2[ST_TankType(client)];
		float flAmmoRange = !g_bTankConfig[ST_TankType(client)] ? g_flAmmoRange[ST_TankType(client)] : g_flAmmoRange2[ST_TankType(client)],
			flTankPos[3];
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
					vAmmoHit(iSurvivor, client, iAmmoRangeChance, iAmmoAbility, 2);
				}
			}
		}
	}
}

stock void vAmmoHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client) && GetPlayerWeaponSlot(client, 0) > 0)
	{
		char sWeapon[32];
		int iActiveWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon"),
			iAmmoCount = !g_bTankConfig[ST_TankType(owner)] ? g_iAmmoCount[ST_TankType(owner)] : g_iAmmoCount2[ST_TankType(owner)],
			iAmmoMessage = !g_bTankConfig[ST_TankType(owner)] ? g_iAmmoMessage[ST_TankType(owner)] : g_iAmmoMessage2[ST_TankType(owner)];
		GetEntityClassname(iActiveWeapon, sWeapon, sizeof(sWeapon));
		if (bIsValidEntity(iActiveWeapon))
		{
			if (strcmp(sWeapon, "weapon_rifle") == 0 || strcmp(sWeapon, "weapon_rifle_desert") == 0 || strcmp(sWeapon, "weapon_rifle_ak47") == 0 || strcmp(sWeapon, "weapon_rifle_sg552") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", iAmmoCount, _, 3);
			}
			else if (strcmp(sWeapon, "weapon_smg") == 0 || strcmp(sWeapon, "weapon_smg_silenced") == 0 || strcmp(sWeapon, "weapon_smg_mp5") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", iAmmoCount, _, 5);
			}
			else if (strcmp(sWeapon, "weapon_pumpshotgun") == 0)
			{
				bIsL4D2Game() ? SetEntProp(client, Prop_Data, "m_iAmmo", iAmmoCount, _, 7) : SetEntProp(client, Prop_Data, "m_iAmmo", iAmmoCount, _, 6);
			}
			else if (strcmp(sWeapon, "weapon_shotgun_chrome") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", iAmmoCount, _, 7);
			}
			else if (strcmp(sWeapon, "weapon_autoshotgun") == 0)
			{
				bIsL4D2Game() ? SetEntProp(client, Prop_Data, "m_iAmmo", iAmmoCount, _, 8) : SetEntProp(client, Prop_Data, "m_iAmmo", iAmmoCount, _, 6);
			}
			else if (strcmp(sWeapon, "weapon_shotgun_spas") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", iAmmoCount, _, 8);
			}
			else if (strcmp(sWeapon, "weapon_hunting_rifle") == 0)
			{
				bIsL4D2Game() ? SetEntProp(client, Prop_Data, "m_iAmmo", iAmmoCount, _, 9) : SetEntProp(client, Prop_Data, "m_iAmmo", iAmmoCount, _, 2);
			}
			else if (strcmp(sWeapon, "weapon_sniper_scout") == 0 || strcmp(sWeapon, "weapon_sniper_military") == 0 || strcmp(sWeapon, "weapon_sniper_awp") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", iAmmoCount, _, 10);
			}
			else if (strcmp(sWeapon, "weapon_grenade_launcher") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", iAmmoCount, _, 17);
			}
		}
		SetEntProp(GetPlayerWeaponSlot(client, 0), Prop_Data, "m_iClip1", iAmmoCount, 1);
		if (iAmmoMessage == message || iAmmoMessage == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Ammo", sTankName, client);
		}
	}
}

stock int iAmmoChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iAmmoChance[ST_TankType(client)] : g_iAmmoChance2[ST_TankType(client)];
}

stock int iAmmoHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iAmmoHit[ST_TankType(client)] : g_iAmmoHit2[ST_TankType(client)];
}

stock int iAmmoHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iAmmoHitMode[ST_TankType(client)] : g_iAmmoHitMode2[ST_TankType(client)];
}