// Super Tanks++: Ghost Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Ghost Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bGhost[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
char g_sGhostWeaponSlots[ST_MAXTYPES + 1][6], g_sGhostWeaponSlots2[ST_MAXTYPES + 1][6], g_sPropsColors[ST_MAXTYPES + 1][80], g_sPropsColors2[ST_MAXTYPES + 1][80], g_sTankColors[ST_MAXTYPES + 1][28], g_sTankColors2[ST_MAXTYPES + 1][28];
float g_flGhostRange[ST_MAXTYPES + 1], g_flGhostRange2[ST_MAXTYPES + 1];
int g_iGhostAbility[ST_MAXTYPES + 1], g_iGhostAbility2[ST_MAXTYPES + 1], g_iGhostAlpha[MAXPLAYERS + 1], g_iGhostChance[ST_MAXTYPES + 1], g_iGhostChance2[ST_MAXTYPES + 1], g_iGhostFade[ST_MAXTYPES + 1], g_iGhostFade2[ST_MAXTYPES + 1], g_iGhostHit[ST_MAXTYPES + 1], g_iGhostHit2[ST_MAXTYPES + 1], g_iGhostHitMode[ST_MAXTYPES + 1], g_iGhostHitMode2[ST_MAXTYPES + 1], g_iGhostMessage[ST_MAXTYPES + 1], g_iGhostMessage2[ST_MAXTYPES + 1], g_iGhostRangeChance[ST_MAXTYPES + 1], g_iGhostRangeChance2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Ghost Ability only supports Left 4 Dead 1 & 2.");
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

public void OnMapStart()
{
	PrecacheSound(SOUND_INFECTED, true);
	PrecacheSound(SOUND_INFECTED2, true);
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bGhost[client] = false;
	g_iGhostAlpha[client] = 255;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if ((iGhostHitMode(attacker) == 0 || iGhostHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				vGhostHit(victim, attacker, iGhostChance(attacker), iGhostHit(attacker));
			}
		}
		else if ((iGhostHitMode(victim) == 0 || iGhostHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				vGhostHit(attacker, victim, iGhostChance(victim), iGhostHit(victim));
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
			main ? (kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors[iIndex], sizeof(g_sTankColors[]), "255,255,255,255|255,255,255")) : (kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors2[iIndex], sizeof(g_sTankColors2[]), g_sTankColors[iIndex]));
			main ? (kvSuperTanks.GetString("General/Props Colors", g_sPropsColors[iIndex], sizeof(g_sPropsColors[]), "255,255,255,255|255,255,255,255|255,255,255,180|255,255,255,255|255,255,255,255")) : (kvSuperTanks.GetString("General/Props Colors", g_sPropsColors2[iIndex], sizeof(g_sPropsColors2[]), g_sPropsColors[iIndex]));
			main ? (g_iGhostAbility[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ability Enabled", 0)) : (g_iGhostAbility2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ability Enabled", g_iGhostAbility[iIndex]));
			main ? (g_iGhostAbility[iIndex] = iSetCellLimit(g_iGhostAbility[iIndex], 0, 3)) : (g_iGhostAbility2[iIndex] = iSetCellLimit(g_iGhostAbility2[iIndex], 0, 3));
			main ? (g_iGhostMessage[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ability Message", 0)) : (g_iGhostMessage2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ability Message", g_iGhostMessage[iIndex]));
			main ? (g_iGhostMessage[iIndex] = iSetCellLimit(g_iGhostMessage[iIndex], 0, 1)) : (g_iGhostMessage2[iIndex] = iSetCellLimit(g_iGhostMessage2[iIndex], 0, 1));
			main ? (g_iGhostChance[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Chance", 4)) : (g_iGhostChance2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Chance", g_iGhostChance[iIndex]));
			main ? (g_iGhostChance[iIndex] = iSetCellLimit(g_iGhostChance[iIndex], 1, 9999999999)) : (g_iGhostChance2[iIndex] = iSetCellLimit(g_iGhostChance2[iIndex], 1, 9999999999));
			main ? (g_iGhostFade[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Fade Limit", 0)) : (g_iGhostFade2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Fade Limit", g_iGhostFade[iIndex]));
			main ? (g_iGhostFade[iIndex] = iSetCellLimit(g_iGhostFade[iIndex], 0, 255)) : (g_iGhostFade2[iIndex] = iSetCellLimit(g_iGhostFade2[iIndex], 0, 255));
			main ? (g_iGhostHit[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Hit", 0)) : (g_iGhostHit2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Hit", g_iGhostHit[iIndex]));
			main ? (g_iGhostHit[iIndex] = iSetCellLimit(g_iGhostHit[iIndex], 0, 1)) : (g_iGhostHit2[iIndex] = iSetCellLimit(g_iGhostHit2[iIndex], 0, 1));
			main ? (g_iGhostHitMode[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Hit Mode", 0)) : (g_iGhostHitMode2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Hit Mode", g_iGhostHitMode[iIndex]));
			main ? (g_iGhostHitMode[iIndex] = iSetCellLimit(g_iGhostHitMode[iIndex], 0, 2)) : (g_iGhostHitMode2[iIndex] = iSetCellLimit(g_iGhostHitMode2[iIndex], 0, 2));
			main ? (g_flGhostRange[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Range", 150.0)) : (g_flGhostRange2[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Range", g_flGhostRange[iIndex]));
			main ? (g_flGhostRange[iIndex] = flSetFloatLimit(g_flGhostRange[iIndex], 1.0, 9999999999.0)) : (g_flGhostRange2[iIndex] = flSetFloatLimit(g_flGhostRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iGhostRangeChance[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Range Chance", 16)) : (g_iGhostRangeChance2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Range Chance", g_iGhostRangeChance[iIndex]));
			main ? (g_iGhostRangeChance[iIndex] = iSetCellLimit(g_iGhostRangeChance[iIndex], 1, 9999999999)) : (g_iGhostRangeChance2[iIndex] = iSetCellLimit(g_iGhostRangeChance2[iIndex], 1, 9999999999));
			main ? (kvSuperTanks.GetString("Ghost Ability/Ghost Weapon Slots", g_sGhostWeaponSlots[iIndex], sizeof(g_sGhostWeaponSlots[]), "12345")) : (kvSuperTanks.GetString("Ghost Ability/Ghost Weapon Slots", g_sGhostWeaponSlots2[iIndex], sizeof(g_sGhostWeaponSlots2[]), g_sGhostWeaponSlots[iIndex]));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iGhostRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iGhostChance[ST_TankType(client)] : g_iGhostChance2[ST_TankType(client)];
		float flGhostRange = !g_bTankConfig[ST_TankType(client)] ? g_flGhostRange[ST_TankType(client)] : g_flGhostRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flGhostRange)
				{
					vGhostHit(iSurvivor, client, iGhostRangeChance, iGhostAbility(client));
				}
			}
		}
		if ((iGhostAbility(client) == 2 || iGhostAbility(client) == 3) && !g_bGhost[client])
		{
			g_bGhost[client] = true;
			g_iGhostAlpha[client] = 255;
			CreateTimer(0.1, tTimerGhost, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			SetEntityRenderMode(client, RENDER_TRANSCOLOR);
			if (iGhostMessage(client) == 1)
			{
				char sTankName[MAX_NAME_LENGTH + 1];
				ST_TankName(client, sTankName);
				PrintToChatAll("%s %t", ST_PREFIX2, "Ghost2", sTankName);
			}
		}
	}
}

stock void vGhostHit(int client, int owner, int chance, int enabled)
{
	if ((enabled == 1 || enabled == 3) && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		char sGhostWeaponSlots[6];
		sGhostWeaponSlots = !g_bTankConfig[ST_TankType(owner)] ? g_sGhostWeaponSlots[ST_TankType(owner)] : g_sGhostWeaponSlots2[ST_TankType(owner)];
		vGhostDrop(client, sGhostWeaponSlots, "1", 0);
		vGhostDrop(client, sGhostWeaponSlots, "2", 1);
		vGhostDrop(client, sGhostWeaponSlots, "3", 2);
		vGhostDrop(client, sGhostWeaponSlots, "4", 3);
		vGhostDrop(client, sGhostWeaponSlots, "5", 4);
		switch (GetRandomInt(1, 2))
		{
			case 1: EmitSoundToClient(client, SOUND_INFECTED, owner);
			case 2: EmitSoundToClient(client, SOUND_INFECTED2, owner);
		}
		if (iGhostMessage(client) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Ghost", sTankName, client);
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bGhost[iPlayer] = false;
			g_iGhostAlpha[iPlayer] = 255;
		}
	}
}

stock int iGhostAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iGhostAbility[ST_TankType(client)] : g_iGhostAbility2[ST_TankType(client)];
}

stock int iGhostChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iGhostChance[ST_TankType(client)] : g_iGhostChance2[ST_TankType(client)];
}

stock int iGhostHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iGhostHit[ST_TankType(client)] : g_iGhostHit2[ST_TankType(client)];
}

stock int iGhostHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iGhostHitMode[ST_TankType(client)] : g_iGhostHitMode2[ST_TankType(client)];
}

stock int iGhostMessage(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iGhostMessage[ST_TankType(client)] : g_iGhostMessage2[ST_TankType(client)];
}

public Action tTimerGhost(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bGhost[iTank] = false;
		return Plugin_Stop;
	}
	if (iGhostAbility(iTank) != 2 && iGhostAbility(iTank) != 3)
	{
		g_bGhost[iTank] = false;
		return Plugin_Stop;
	}
	char sSet[2][16], sTankColors[28], sRGB[4][4], sSet2[5][16], sPropsColors[80], sProps[4][4],
		sProps2[4][4], sProps3[4][4], sProps4[4][4], sProps5[4][4];
	sTankColors = !g_bTankConfig[ST_TankType(iTank)] ? g_sTankColors[ST_TankType(iTank)] : g_sTankColors2[ST_TankType(iTank)];
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
	sPropsColors = !g_bTankConfig[ST_TankType(iTank)] ? g_sPropsColors[ST_TankType(iTank)] : g_sPropsColors2[ST_TankType(iTank)];
	TrimString(sPropsColors);
	ExplodeString(sPropsColors, "|", sSet2, sizeof(sSet2), sizeof(sSet2[]));
	ExplodeString(sSet2[0], ",", sProps, sizeof(sProps), sizeof(sProps[]));
	TrimString(sProps[0]);
	int iRed2 = (sProps[0][0] != '\0') ? StringToInt(sProps[0]) : 255;
	iRed2 = iSetCellLimit(iRed2, 0, 255);
	TrimString(sProps[1]);
	int iGreen2 = (sProps[1][0] != '\0') ? StringToInt(sProps[1]) : 255;
	iGreen2 = iSetCellLimit(iGreen2, 0, 255);
	TrimString(sProps[2]);
	int iBlue2 = (sProps[2][0] != '\0') ? StringToInt(sProps[2]) : 255;
	iBlue2 = iSetCellLimit(iBlue2, 0, 255);
	ExplodeString(sSet2[1], ",", sProps2, sizeof(sProps2), sizeof(sProps2[]));
	TrimString(sProps2[0]);
	int iRed3 = (sProps2[0][0] != '\0') ? StringToInt(sProps2[0]) : 255;
	iRed3 = iSetCellLimit(iRed3, 0, 255);
	TrimString(sProps2[1]);
	int iGreen3 = (sProps2[0][0] != '\0') ? StringToInt(sProps2[1]) : 255;
	iGreen3 = iSetCellLimit(iGreen3, 0, 255);
	TrimString(sProps2[2]);
	int iBlue3 = (sProps2[0][0] != '\0') ? StringToInt(sProps2[2]) : 255;
	iBlue3 = iSetCellLimit(iBlue3, 0, 255);
	ExplodeString(sSet2[2], ",", sProps3, sizeof(sProps3), sizeof(sProps3[]));
	TrimString(sProps3[0]);
	int iRed4 = (sProps3[0][0] != '\0') ? StringToInt(sProps3[0]) : 255;
	iRed4 = iSetCellLimit(iRed4, 0, 255);
	TrimString(sProps3[1]);
	int iGreen4 = (sProps3[0][0] != '\0') ? StringToInt(sProps3[1]) : 255;
	iGreen4 = iSetCellLimit(iGreen4, 0, 255);
	TrimString(sProps3[2]);
	int iBlue4 = (sProps3[0][0] != '\0') ? StringToInt(sProps3[2]) : 255;
	iBlue4 = iSetCellLimit(iBlue4, 0, 255);
	ExplodeString(sSet2[3], ",", sProps4, sizeof(sProps4), sizeof(sProps4[]));
	TrimString(sProps4[0]);
	int iRed5 = (sProps4[0][0] != '\0') ? StringToInt(sProps4[0]) : 255;
	iRed5 = iSetCellLimit(iRed5, 0, 255);
	TrimString(sProps4[1]);
	int iGreen5 = (sProps4[0][0] != '\0') ? StringToInt(sProps4[1]) : 255;
	iGreen5 = iSetCellLimit(iGreen5, 0, 255);
	TrimString(sProps4[2]);
	int iBlue5 = (sProps4[0][0] != '\0') ? StringToInt(sProps4[2]) : 255;
	iBlue5 = iSetCellLimit(iBlue5, 0, 255);
	ExplodeString(sSet2[4], ",", sProps5, sizeof(sProps5), sizeof(sProps5[]));
	TrimString(sProps5[0]);
	int iRed6 = (sProps5[0][0] != '\0') ? StringToInt(sProps5[0]) : 255;
	iRed6 = iSetCellLimit(iRed6, 0, 255);
	TrimString(sProps5[1]);
	int iGreen6 = (sProps5[0][0] != '\0') ? StringToInt(sProps5[1]) : 255;
	iGreen6 = iSetCellLimit(iGreen6, 0, 255);
	TrimString(sProps5[2]);
	int iBlue6 = (sProps5[0][0] != '\0') ? StringToInt(sProps5[2]) : 255;
	iBlue6 = iSetCellLimit(iBlue6, 0, 255);
	int iGhostFade = !g_bTankConfig[ST_TankType(iTank)] ? g_iGhostFade[ST_TankType(iTank)] : g_iGhostFade2[ST_TankType(iTank)];
	g_iGhostAlpha[iTank] -= 2;
	if (g_iGhostAlpha[iTank] < iGhostFade)
	{
		g_iGhostAlpha[iTank] = iGhostFade;
	}
	int iProp = -1;
	while ((iProp = FindEntityByClassname(iProp, "prop_dynamic")) != INVALID_ENT_REFERENCE)
	{
		char sModel[128];
		GetEntPropString(iProp, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		if (strcmp(sModel, MODEL_JETPACK, false) == 0 || strcmp(sModel, MODEL_CONCRETE, false) == 0 || strcmp(sModel, MODEL_TIRES, false) == 0 || strcmp(sModel, MODEL_TANK, false) == 0)
		{
			int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
			if (iOwner == iTank)
			{
				if (strcmp(sModel, MODEL_JETPACK, false) == 0)
				{
					SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iProp, iRed3, iGreen3, iBlue3, g_iGhostAlpha[iTank]);
				}
				if (strcmp(sModel, MODEL_CONCRETE, false) == 0)
				{
					SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iProp, iRed5, iGreen5, iBlue5, g_iGhostAlpha[iTank]);
				}
				if (strcmp(sModel, MODEL_TIRES, false) == 0)
				{
					SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iProp, iRed6, iGreen6, iBlue6, g_iGhostAlpha[iTank]);
				}
				if (strcmp(sModel, MODEL_TANK, false) == 0)
				{
					SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iProp, iRed, iGreen, iBlue, g_iGhostAlpha[iTank]);
				}
			}
		}
	}
	while ((iProp = FindEntityByClassname(iProp, "beam_spotlight")) != INVALID_ENT_REFERENCE)
	{
		int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iOwner == iTank)
		{
			SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
			SetEntityRenderColor(iProp, iRed2, iGreen2, iBlue2, g_iGhostAlpha[iTank]);
		}
	}
	while ((iProp = FindEntityByClassname(iProp, "env_steam")) != INVALID_ENT_REFERENCE)
	{
		int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iOwner == iTank)
		{
			SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
			SetEntityRenderColor(iProp, iRed4, iGreen4, iBlue4, g_iGhostAlpha[iTank]);
		}
	}
	SetEntityRenderMode(iTank, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iTank, iRed, iGreen, iBlue, g_iGhostAlpha[iTank]);
	return Plugin_Continue;
}