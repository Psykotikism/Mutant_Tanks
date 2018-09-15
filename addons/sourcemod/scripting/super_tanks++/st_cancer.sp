// Super Tanks++: Cancer Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Cancer Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
char g_sTankColors[ST_MAXTYPES + 1][28], g_sTankColors2[ST_MAXTYPES + 1][28];
ConVar g_cvSTMaxIncapCount;
float g_flCancerRange[ST_MAXTYPES + 1], g_flCancerRange2[ST_MAXTYPES + 1];
int g_iCancerAbility[ST_MAXTYPES + 1], g_iCancerAbility2[ST_MAXTYPES + 1], g_iCancerChance[ST_MAXTYPES + 1], g_iCancerChance2[ST_MAXTYPES + 1], g_iCancerHit[ST_MAXTYPES + 1], g_iCancerHit2[ST_MAXTYPES + 1], g_iCancerHitMode[ST_MAXTYPES + 1], g_iCancerHitMode2[ST_MAXTYPES + 1], g_iCancerMessage[ST_MAXTYPES + 1], g_iCancerMessage2[ST_MAXTYPES + 1], g_iCancerRangeChance[ST_MAXTYPES + 1], g_iCancerRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Cancer Ability only supports Left 4 Dead 1 & 2.");
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
	g_cvSTMaxIncapCount = FindConVar("survivor_max_incapacitated_count");
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
		if ((iCancerHitMode(attacker) == 0 || iCancerHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vCancerHit(victim, attacker, iCancerChance(attacker), iCancerHit(attacker));
			}
		}
		else if ((iCancerHitMode(victim) == 0 || iCancerHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vCancerHit(attacker, victim, iCancerChance(victim), iCancerHit(victim));
			}
		}
	}
	return Plugin_Continue;
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
			main ? (kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors[iIndex], sizeof(g_sTankColors[]), "255,255,255,255|255,255,255")) : (kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors2[iIndex], sizeof(g_sTankColors2[]), g_sTankColors[iIndex]));
			main ? (g_iCancerAbility[iIndex] = kvSuperTanks.GetNum("Cancer Ability/Ability Enabled", 0)) : (g_iCancerAbility2[iIndex] = kvSuperTanks.GetNum("Cancer Ability/Ability Enabled", g_iCancerAbility[iIndex]));
			main ? (g_iCancerAbility[iIndex] = iSetCellLimit(g_iCancerAbility[iIndex], 0, 1)) : (g_iCancerAbility2[iIndex] = iSetCellLimit(g_iCancerAbility2[iIndex], 0, 1));
			main ? (g_iCancerMessage[iIndex] = kvSuperTanks.GetNum("Cancer Ability/Ability Message", 0)) : (g_iCancerMessage2[iIndex] = kvSuperTanks.GetNum("Cancer Ability/Ability Message", g_iCancerMessage[iIndex]));
			main ? (g_iCancerMessage[iIndex] = iSetCellLimit(g_iCancerMessage[iIndex], 0, 1)) : (g_iCancerMessage2[iIndex] = iSetCellLimit(g_iCancerMessage2[iIndex], 0, 1));
			main ? (g_iCancerChance[iIndex] = kvSuperTanks.GetNum("Cancer Ability/Cancer Chance", 4)) : (g_iCancerChance2[iIndex] = kvSuperTanks.GetNum("Cancer Ability/Cancer Chance", g_iCancerChance[iIndex]));
			main ? (g_iCancerChance[iIndex] = iSetCellLimit(g_iCancerChance[iIndex], 1, 9999999999)) : (g_iCancerChance2[iIndex] = iSetCellLimit(g_iCancerChance2[iIndex], 1, 9999999999));
			main ? (g_iCancerHit[iIndex] = kvSuperTanks.GetNum("Cancer Ability/Cancer Hit", 0)) : (g_iCancerHit2[iIndex] = kvSuperTanks.GetNum("Cancer Ability/Cancer Hit", g_iCancerHit[iIndex]));
			main ? (g_iCancerHit[iIndex] = iSetCellLimit(g_iCancerHit[iIndex], 0, 1)) : (g_iCancerHit2[iIndex] = iSetCellLimit(g_iCancerHit2[iIndex], 0, 1));
			main ? (g_iCancerHitMode[iIndex] = kvSuperTanks.GetNum("Cancer Ability/Cancer Hit Mode", 0)) : (g_iCancerHitMode2[iIndex] = kvSuperTanks.GetNum("Cancer Ability/Cancer Hit Mode", g_iCancerHitMode[iIndex]));
			main ? (g_iCancerHitMode[iIndex] = iSetCellLimit(g_iCancerHitMode[iIndex], 0, 2)) : (g_iCancerHitMode2[iIndex] = iSetCellLimit(g_iCancerHitMode2[iIndex], 0, 2));
			main ? (g_flCancerRange[iIndex] = kvSuperTanks.GetFloat("Cancer Ability/Cancer Range", 150.0)) : (g_flCancerRange2[iIndex] = kvSuperTanks.GetFloat("Cancer Ability/Cancer Range", g_flCancerRange[iIndex]));
			main ? (g_flCancerRange[iIndex] = flSetFloatLimit(g_flCancerRange[iIndex], 1.0, 9999999999.0)) : (g_flCancerRange2[iIndex] = flSetFloatLimit(g_flCancerRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iCancerRangeChance[iIndex] = kvSuperTanks.GetNum("Cancer Ability/Cancer Range Chance", 16)) : (g_iCancerRangeChance2[iIndex] = kvSuperTanks.GetNum("Cancer Ability/Cancer Range Chance", g_iCancerRangeChance[iIndex]));
			main ? (g_iCancerRangeChance[iIndex] = iSetCellLimit(g_iCancerRangeChance[iIndex], 1, 9999999999)) : (g_iCancerRangeChance2[iIndex] = iSetCellLimit(g_iCancerRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iCancerAbility = !g_bTankConfig[ST_TankType(client)] ? g_iCancerAbility[ST_TankType(client)] : g_iCancerAbility2[ST_TankType(client)],
			iCancerRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iCancerChance[ST_TankType(client)] : g_iCancerChance2[ST_TankType(client)];
		float flCancerRange = !g_bTankConfig[ST_TankType(client)] ? g_flCancerRange[ST_TankType(client)] : g_flCancerRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flCancerRange)
				{
					vCancerHit(iSurvivor, client, iCancerRangeChance, iCancerAbility);
				}
			}
		}
	}
}

stock void vCancerHit(int client, int owner, int chance, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		char sSet[2][16], sTankColors[28], sRGB[4][4];
		int iCancerMessage = !g_bTankConfig[ST_TankType(owner)] ? g_iCancerMessage[ST_TankType(owner)] : g_iCancerMessage2[ST_TankType(owner)];
		sTankColors = !g_bTankConfig[ST_TankType(owner)] ? g_sTankColors[ST_TankType(owner)] : g_sTankColors2[ST_TankType(owner)];
		TrimString(sTankColors);
		ExplodeString(sTankColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
		ExplodeString(sSet[0], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
		TrimString(sRGB[0]);
		int iRed = (sRGB[0][0] != '\0') ? StringToInt(sRGB[0]) : 255;
		iRed = iSetCellLimit(iRed, 0, 255);
		TrimString(sRGB[1]);
		int iGreen = (sRGB[1][0] != '\0') ? StringToInt(sRGB[1]) : 255;
		iGreen = iSetCellLimit(iGreen, 0, 255);
		TrimString(sRGB[2]);
		int iBlue = (sRGB[2][0] != '\0') ? StringToInt(sRGB[2]) : 255;
		iBlue = iSetCellLimit(iBlue, 0, 255);
		SetEntProp(client, Prop_Send, "m_currentReviveCount", g_cvSTMaxIncapCount.IntValue);
		vFade(client, 800, 300, iRed, iGreen, iBlue);
		if (iCancerMessage == 1)
		{
			PrintToChatAll("%s %t", ST_PREFIX2, "Cancer", owner, client);
		}
	}
}

stock int iCancerChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iCancerChance[ST_TankType(client)] : g_iCancerChance2[ST_TankType(client)];
}

stock int iCancerHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iCancerHit[ST_TankType(client)] : g_iCancerHit2[ST_TankType(client)];
}

stock int iCancerHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iCancerHitMode[ST_TankType(client)] : g_iCancerHitMode2[ST_TankType(client)];
}