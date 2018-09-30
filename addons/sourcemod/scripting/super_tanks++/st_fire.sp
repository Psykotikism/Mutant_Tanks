// Super Tanks++: Fire Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"

public Plugin myinfo =
{
	name = "[ST++] Fire Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates fires.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
float g_flFireRange[ST_MAXTYPES + 1], g_flFireRange2[ST_MAXTYPES + 1];
int g_iFireAbility[ST_MAXTYPES + 1], g_iFireAbility2[ST_MAXTYPES + 1], g_iFireChance[ST_MAXTYPES + 1], g_iFireChance2[ST_MAXTYPES + 1], g_iFireHit[ST_MAXTYPES + 1], g_iFireHit2[ST_MAXTYPES + 1], g_iFireHitMode[ST_MAXTYPES + 1], g_iFireHitMode2[ST_MAXTYPES + 1], g_iFireMessage[ST_MAXTYPES + 1], g_iFireMessage2[ST_MAXTYPES + 1], g_iFireRangeChance[ST_MAXTYPES + 1], g_iFireRangeChance2[ST_MAXTYPES + 1], g_iFireRock[ST_MAXTYPES + 1], g_iFireRock2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Fire Ability only supports Left 4 Dead 1 & 2.");
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
	if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = true;
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "st_clone", false))
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

public void OnMapStart()
{
	PrecacheModel(MODEL_GASCAN, true);
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
		if ((iFireHitMode(attacker) == 0 || iFireHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vFireHit(victim, attacker, iFireChance(attacker), iFireHit(attacker), 1);
			}
		}
		else if ((iFireHitMode(victim) == 0 || iFireHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vFireHit(attacker, victim, iFireChance(victim), iFireHit(victim), 1);
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
		Format(sName, sizeof(sName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iFireAbility[iIndex] = kvSuperTanks.GetNum("Fire Ability/Ability Enabled", 0)) : (g_iFireAbility2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Ability Enabled", g_iFireAbility[iIndex]));
			main ? (g_iFireAbility[iIndex] = iClamp(g_iFireAbility[iIndex], 0, 1)) : (g_iFireAbility2[iIndex] = iClamp(g_iFireAbility2[iIndex], 0, 1));
			main ? (g_iFireMessage[iIndex] = kvSuperTanks.GetNum("Fire Ability/Ability Message", 0)) : (g_iFireMessage2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Ability Message", g_iFireMessage[iIndex]));
			main ? (g_iFireMessage[iIndex] = iClamp(g_iFireMessage[iIndex], 0, 7)) : (g_iFireMessage2[iIndex] = iClamp(g_iFireMessage2[iIndex], 0, 7));
			main ? (g_iFireChance[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Chance", 4)) : (g_iFireChance2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Chance", g_iFireChance[iIndex]));
			main ? (g_iFireChance[iIndex] = iClamp(g_iFireChance[iIndex], 1, 9999999999)) : (g_iFireChance2[iIndex] = iClamp(g_iFireChance2[iIndex], 1, 9999999999));
			main ? (g_iFireHit[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Hit", 0)) : (g_iFireHit2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Hit", g_iFireHit[iIndex]));
			main ? (g_iFireHit[iIndex] = iClamp(g_iFireHit[iIndex], 0, 1)) : (g_iFireHit2[iIndex] = iClamp(g_iFireHit2[iIndex], 0, 1));
			main ? (g_iFireHitMode[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Hit Mode", 0)) : (g_iFireHitMode2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Hit Mode", g_iFireHitMode[iIndex]));
			main ? (g_iFireHitMode[iIndex] = iClamp(g_iFireHitMode[iIndex], 0, 2)) : (g_iFireHitMode2[iIndex] = iClamp(g_iFireHitMode2[iIndex], 0, 2));
			main ? (g_flFireRange[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Range", 150.0)) : (g_flFireRange2[iIndex] = kvSuperTanks.GetFloat("Fire Ability/Fire Range", g_flFireRange[iIndex]));
			main ? (g_flFireRange[iIndex] = flClamp(g_flFireRange[iIndex], 1.0, 9999999999.0)) : (g_flFireRange2[iIndex] = flClamp(g_flFireRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iFireRangeChance[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Range Chance", 16)) : (g_iFireRangeChance2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Range Chance", g_iFireRangeChance[iIndex]));
			main ? (g_iFireRangeChance[iIndex] = iClamp(g_iFireRangeChance[iIndex], 1, 9999999999)) : (g_iFireRangeChance2[iIndex] = iClamp(g_iFireRangeChance2[iIndex], 1, 9999999999));
			main ? (g_iFireRock[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Rock Break", 0)) : (g_iFireRock2[iIndex] = kvSuperTanks.GetNum("Fire Ability/Fire Rock Break", g_iFireRock[iIndex]));
			main ? (g_iFireRock[iIndex] = iClamp(g_iFireRock[iIndex], 0, 1)) : (g_iFireRock2[iIndex] = iClamp(g_iFireRock2[iIndex], 0, 1));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iFireAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			float flPos[3];
			GetClientAbsOrigin(iTank, flPos);
			vSpecialAttack(iTank, flPos, MODEL_GASCAN);
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iFireRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iFireChance[ST_TankType(client)] : g_iFireChance2[ST_TankType(client)];
		float flFireRange = !g_bTankConfig[ST_TankType(client)] ? g_flFireRange[ST_TankType(client)] : g_flFireRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flFireRange)
				{
					vFireHit(iSurvivor, client, iFireRangeChance, iFireAbility(client), 2);
				}
			}
		}
	}
}

public void ST_BossStage(int client)
{
	if (iFireAbility(client) == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled))
	{
		float flPos[3];
		GetClientAbsOrigin(client, flPos);
		vSpecialAttack(client, flPos, MODEL_GASCAN);
	}
}

public void ST_RockBreak(int client, int entity)
{
	int iFireRock = !g_bTankConfig[ST_TankType(client)] ? g_iFireRock[ST_TankType(client)] : g_iFireRock2[ST_TankType(client)];
	if (iFireRock == 1 && ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		float flPos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPos);
		vSpecialAttack(client, flPos, MODEL_GASCAN);
		switch (iFireMessage(client))
		{
			case 3, 5, 6, 7:
			{
				char sTankName[MAX_NAME_LENGTH + 1];
				ST_TankName(client, sTankName);
				PrintToChatAll("%s %t", ST_PREFIX2, "Fire2", sTankName);
			}
		}
	}
}

stock void vFireHit(int client, int owner, int chance, int enabled, int message)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		float flPos[3];
		GetClientAbsOrigin(client, flPos);
		vSpecialAttack(owner, flPos, MODEL_GASCAN);
		char sRGB[4][4];
		ST_TankColors(owner, GetRandomInt(1, 2), sRGB[0], sRGB[1], sRGB[2]);
		int iRed = (!StrEqual(sRGB[0], "")) ? StringToInt(sRGB[0]) : 255;
		iRed = iClamp(iRed, 0, 255);
		int iGreen = (!StrEqual(sRGB[1], "")) ? StringToInt(sRGB[1]) : 255;
		iGreen = iClamp(iGreen, 0, 255);
		int iBlue = (!StrEqual(sRGB[2], "")) ? StringToInt(sRGB[2]) : 255;
		iBlue = iClamp(iBlue, 0, 255);
		vFade(client, 800, 300, iRed, iGreen, iBlue);
		if (iFireMessage(owner) == message || iFireMessage(client) == 4 || iFireMessage(client) == 5 || iFireMessage(client) == 6 || iFireMessage(client) == 7)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Fire", sTankName, client);
		}
	}
}

stock int iFireAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iFireAbility[ST_TankType(client)] : g_iFireAbility2[ST_TankType(client)];
}

stock int iFireChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iFireChance[ST_TankType(client)] : g_iFireChance2[ST_TankType(client)];
}

stock int iFireHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iFireHit[ST_TankType(client)] : g_iFireHit2[ST_TankType(client)];
}

stock int iFireHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iFireHitMode[ST_TankType(client)] : g_iFireHitMode2[ST_TankType(client)];
}

stock int iFireMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iFireMessage[ST_TankType(client)] : g_iFireMessage2[ST_TankType(client)];
}