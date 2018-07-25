// Super Tanks++: Ghost Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Ghost Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

#define SOUND_INFECTED "npc/infected/action/die/male/death_42.wav"
#define SOUND_INFECTED2 "npc/infected/action/die/male/death_43.wav"

bool g_bGhost[MAXPLAYERS + 1];
bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
char g_sGhostSlot[ST_MAXTYPES + 1][6];
char g_sGhostSlot2[ST_MAXTYPES + 1][6];
char g_sPropsColors[ST_MAXTYPES + 1][80];
char g_sPropsColors2[ST_MAXTYPES + 1][80];
char g_sTankColors[ST_MAXTYPES + 1][28];
char g_sTankColors2[ST_MAXTYPES + 1][28];
float g_flGhostRange[ST_MAXTYPES + 1];
float g_flGhostRange2[ST_MAXTYPES + 1];
int g_iGhostAbility[ST_MAXTYPES + 1];
int g_iGhostAbility2[ST_MAXTYPES + 1];
int g_iGhostAlpha[MAXPLAYERS + 1];
int g_iGhostChance[ST_MAXTYPES + 1];
int g_iGhostChance2[ST_MAXTYPES + 1];
int g_iGhostFade[ST_MAXTYPES + 1];
int g_iGhostFade2[ST_MAXTYPES + 1];
int g_iGhostHit[ST_MAXTYPES + 1];
int g_iGhostHit2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Heal Ability only supports Left 4 Dead 1 & 2.");
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
	PrecacheSound(SOUND_INFECTED, true);
	PrecacheSound(SOUND_INFECTED2, true);
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bGhost[iPlayer] = false;
			g_iGhostAlpha[iPlayer] = 255;
		}
	}
	if (g_bLateLoad)
	{
		vLateLoad(true);
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bGhost[client] = false;
	g_iGhostAlpha[client] = 255;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bGhost[client] = false;
	g_iGhostAlpha[client] = 255;
}

public void OnMapEnd()
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
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (bIsTank(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
			{
				int iGhostHit = !g_bTankConfig[ST_TankType(attacker)] ? g_iGhostHit[ST_TankType(attacker)] : g_iGhostHit2[ST_TankType(attacker)];
				vGhostHit(victim, attacker, iGhostHit);
			}
		}
		else if (bIsSurvivor(attacker) && bIsTank(victim))
		{
			if (strcmp(sClassname, "weapon_melee") == 0)
			{
				int iGhostHit = !g_bTankConfig[ST_TankType(victim)] ? g_iGhostHit[ST_TankType(victim)] : g_iGhostHit2[ST_TankType(victim)];
				vGhostHit(attacker, victim, iGhostHit);
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
			main ? (kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors[iIndex], sizeof(g_sTankColors[]), "255,255,255,255|255,255,255")) : (kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors2[iIndex], sizeof(g_sTankColors2[]), g_sTankColors[iIndex]));
			main ? (kvSuperTanks.GetString("General/Props Colors", g_sPropsColors[iIndex], sizeof(g_sPropsColors[]), "255,255,255,255|255,255,255,255|255,255,255,180|255,255,255,255|255,255,255,255")) : (kvSuperTanks.GetString("General/Props Colors", g_sPropsColors2[iIndex], sizeof(g_sPropsColors2[]), g_sPropsColors[iIndex]));
			main ? (g_iGhostAbility[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ability Enabled", 0)) : (g_iGhostAbility2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ability Enabled", g_iGhostAbility[iIndex]));
			main ? (g_iGhostAbility[iIndex] = iSetCellLimit(g_iGhostAbility[iIndex], 0, 1)) : (g_iGhostAbility2[iIndex] = iSetCellLimit(g_iGhostAbility2[iIndex], 0, 1));
			main ? (g_iGhostChance[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Chance", 4)) : (g_iGhostChance2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Chance", g_iGhostChance[iIndex]));
			main ? (g_iGhostChance[iIndex] = iSetCellLimit(g_iGhostChance[iIndex], 1, 9999999999)) : (g_iGhostChance2[iIndex] = iSetCellLimit(g_iGhostChance2[iIndex], 1, 9999999999));
			main ? (g_iGhostFade[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Fade Limit", 255)) : (g_iGhostFade2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Fade Limit", g_iGhostFade[iIndex]));
			main ? (g_iGhostFade[iIndex] = iSetCellLimit(g_iGhostFade[iIndex], 0, 255)) : (g_iGhostFade2[iIndex] = iSetCellLimit(g_iGhostFade2[iIndex], 0, 255));
			main ? (g_iGhostHit[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Hit", 0)) : (g_iGhostHit2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Hit", g_iGhostHit[iIndex]));
			main ? (g_iGhostHit[iIndex] = iSetCellLimit(g_iGhostHit[iIndex], 0, 1)) : (g_iGhostHit2[iIndex] = iSetCellLimit(g_iGhostHit2[iIndex], 0, 1));
			main ? (g_flGhostRange[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Range", 150.0)) : (g_flGhostRange2[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Range", g_flGhostRange[iIndex]));
			main ? (g_flGhostRange[iIndex] = flSetFloatLimit(g_flGhostRange[iIndex], 1.0, 9999999999.0)) : (g_flGhostRange2[iIndex] = flSetFloatLimit(g_flGhostRange2[iIndex], 1.0, 9999999999.0));
			main ? (kvSuperTanks.GetString("Ghost Ability/Ghost Weapon Slots", g_sGhostSlot[iIndex], sizeof(g_sGhostSlot[]), "12345")) : (kvSuperTanks.GetString("Ghost Ability/Ghost Weapon Slots", g_sGhostSlot2[iIndex], sizeof(g_sGhostSlot2[]), g_sGhostSlot[iIndex]));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	char sSet[2][16];
	char sTankColors[28];
	sTankColors = !g_bTankConfig[ST_TankType(client)] ? g_sTankColors[ST_TankType(client)] : g_sTankColors2[ST_TankType(client)];
	TrimString(sTankColors);
	ExplodeString(sTankColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
	char sRGB[4][4];
	ExplodeString(sSet[0], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
	TrimString(sRGB[0]);
	int iRed = (sRGB[0][0] != '\0') ? StringToInt(sRGB[0]) : 255;
	TrimString(sRGB[1]);
	int iGreen = (sRGB[1][0] != '\0') ? StringToInt(sRGB[1]) : 255;
	TrimString(sRGB[2]);
	int iBlue = (sRGB[2][0] != '\0') ? StringToInt(sRGB[2]) : 255;
	char sSet2[5][16];
	char sPropsColors[80];
	sPropsColors = !g_bTankConfig[ST_TankType(client)] ? g_sPropsColors[ST_TankType(client)] : g_sPropsColors2[ST_TankType(client)];
	TrimString(sPropsColors);
	ExplodeString(sPropsColors, "|", sSet2, sizeof(sSet2), sizeof(sSet2[]));
	char sProps[4][4];
	ExplodeString(sSet2[0], ",", sProps, sizeof(sProps), sizeof(sProps[]));
	TrimString(sProps[0]);
	int iRed2 = (sProps[0][0] != '\0') ? StringToInt(sProps[0]) : 255;
	TrimString(sProps[1]);
	int iGreen2 = (sProps[1][0] != '\0') ? StringToInt(sProps[1]) : 255;
	TrimString(sProps[2]);
	int iBlue2 = (sProps[2][0] != '\0') ? StringToInt(sProps[2]) : 255;
	char sProps2[4][4];
	ExplodeString(sSet2[1], ",", sProps2, sizeof(sProps2), sizeof(sProps2[]));
	TrimString(sProps2[0]);
	int iRed3 = (sProps2[0][0] != '\0') ? StringToInt(sProps2[0]) : 255;
	TrimString(sProps2[1]);
	int iGreen3 = (sProps2[0][0] != '\0') ? StringToInt(sProps2[1]) : 255;
	TrimString(sProps2[2]);
	int iBlue3 = (sProps2[0][0] != '\0') ? StringToInt(sProps2[2]) : 255;
	char sProps3[4][4];
	ExplodeString(sSet2[2], ",", sProps3, sizeof(sProps3), sizeof(sProps3[]));
	TrimString(sProps3[0]);
	int iRed4 = (sProps3[0][0] != '\0') ? StringToInt(sProps3[0]) : 255;
	TrimString(sProps3[1]);
	int iGreen4 = (sProps3[0][0] != '\0') ? StringToInt(sProps3[1]) : 255;
	TrimString(sProps3[2]);
	int iBlue4 = (sProps3[0][0] != '\0') ? StringToInt(sProps3[2]) : 255;
	char sProps4[4][4];
	ExplodeString(sSet2[3], ",", sProps4, sizeof(sProps4), sizeof(sProps4[]));
	TrimString(sProps4[0]);
	int iRed5 = (sProps4[0][0] != '\0') ? StringToInt(sProps4[0]) : 255;
	TrimString(sProps4[1]);
	int iGreen5 = (sProps4[0][0] != '\0') ? StringToInt(sProps4[1]) : 255;
	TrimString(sProps4[2]);
	int iBlue5 = (sProps4[0][0] != '\0') ? StringToInt(sProps4[2]) : 255;
	char sProps5[4][4];
	ExplodeString(sSet2[4], ",", sProps5, sizeof(sProps5), sizeof(sProps5[]));
	TrimString(sProps5[0]);
	int iRed6 = (sProps5[0][0] != '\0') ? StringToInt(sProps5[0]) : 255;
	TrimString(sProps5[1]);
	int iGreen6 = (sProps5[0][0] != '\0') ? StringToInt(sProps5[1]) : 255;
	TrimString(sProps5[2]);
	int iBlue6 = (sProps5[0][0] != '\0') ? StringToInt(sProps5[2]) : 255;
	int iGhostAbility = !g_bTankConfig[ST_TankType(client)] ? g_iGhostAbility[ST_TankType(client)] : g_iGhostAbility2[ST_TankType(client)];
	if (iGhostAbility == 1 && bIsTank(client))
	{
		for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
		{
			if (bIsSpecialInfected(iInfected))
			{
				float flTankPos[3];
				float flInfectedPos[3];
				GetClientAbsOrigin(client, flTankPos);
				GetClientAbsOrigin(iInfected, flInfectedPos);
				float flGhostRange = !g_bTankConfig[ST_TankType(client)] ? g_flGhostRange[ST_TankType(client)] : g_flGhostRange2[ST_TankType(client)];
				float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
				if (flDistance <= flGhostRange)
				{
					SetEntityRenderMode(iInfected, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iInfected, 255, 255, 255, 50);
				}
				else
				{
					SetEntityRenderMode(iInfected, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iInfected, 255, 255, 255, 255);
				}
			}
		}
		if (!g_bGhost[client])
		{
			g_iGhostAlpha[client] = 255;
			g_bGhost[client] = true;
			DataPack dpDataPack;
			CreateDataTimer(0.1, tTimerGhost, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpDataPack.WriteCell(GetClientUserId(client));
			dpDataPack.WriteCell(iRed);
			dpDataPack.WriteCell(iGreen);
			dpDataPack.WriteCell(iBlue);
			dpDataPack.WriteCell(iRed2);
			dpDataPack.WriteCell(iGreen2);
			dpDataPack.WriteCell(iBlue2);
			dpDataPack.WriteCell(iRed3);
			dpDataPack.WriteCell(iGreen3);
			dpDataPack.WriteCell(iBlue3);
			dpDataPack.WriteCell(iRed4);
			dpDataPack.WriteCell(iGreen4);
			dpDataPack.WriteCell(iBlue4);
			dpDataPack.WriteCell(iRed5);
			dpDataPack.WriteCell(iGreen5);
			dpDataPack.WriteCell(iBlue5);
			dpDataPack.WriteCell(iRed6);
			dpDataPack.WriteCell(iGreen6);
			dpDataPack.WriteCell(iBlue6);
			SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		}
	}
}

void vGhostDrop(int client, char[] slots, char[] number, int slot)
{
	if (StrContains(slots, number) != -1)
	{
		vDropWeapon(client, slot);
	}
}

void vDropWeapon(int client, int slot)
{
	if (bIsSurvivor(client) && GetPlayerWeaponSlot(client, slot) > 0)
	{
		SDKHooks_DropWeapon(client, GetPlayerWeaponSlot(client, slot), NULL_VECTOR, NULL_VECTOR);
	}
}

void vGhostHit(int client, int owner, int enabled)
{
	int iGhostChance = !g_bTankConfig[ST_TankType(owner)] ? g_iGhostChance[ST_TankType(owner)] : g_iGhostChance2[ST_TankType(owner)];
	if (enabled == 1 && GetRandomInt(1, iGhostChance) == 1 && bIsSurvivor(client))
	{
		char sGhostSlot[6];
		sGhostSlot = !g_bTankConfig[ST_TankType(owner)] ? g_sGhostSlot[ST_TankType(owner)] : g_sGhostSlot2[ST_TankType(owner)];
		vGhostDrop(client, sGhostSlot, "1", 0);
		vGhostDrop(client, sGhostSlot, "2", 1);
		vGhostDrop(client, sGhostSlot, "3", 2);
		vGhostDrop(client, sGhostSlot, "4", 3);
		vGhostDrop(client, sGhostSlot, "5", 4);
		switch (GetRandomInt(1, 2))
		{
			case 1: EmitSoundToClient(client, SOUND_INFECTED, owner);
			case 2: EmitSoundToClient(client, SOUND_INFECTED2, owner);
		}
	}
}

public Action tTimerGhost(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iRed = pack.ReadCell();
	int iGreen = pack.ReadCell();
	int iBlue = pack.ReadCell();
	int iRed2 = pack.ReadCell();
	int iGreen2 = pack.ReadCell();
	int iBlue2 = pack.ReadCell();
	int iRed3 = pack.ReadCell();
	int iGreen3 = pack.ReadCell();
	int iBlue3 = pack.ReadCell();
	int iRed4 = pack.ReadCell();
	int iGreen4 = pack.ReadCell();
	int iBlue4 = pack.ReadCell();
	int iRed5 = pack.ReadCell();
	int iGreen5 = pack.ReadCell();
	int iBlue5 = pack.ReadCell();
	int iRed6 = pack.ReadCell();
	int iGreen6 = pack.ReadCell();
	int iBlue6 = pack.ReadCell();
	int iGhostAbility = !g_bTankConfig[ST_TankType(iTank)] ? g_iGhostAbility[ST_TankType(iTank)] : g_iGhostAbility2[ST_TankType(iTank)];
	if (iGhostAbility == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bGhost[iTank] = false;
		return Plugin_Stop;
	}
	if (bIsTank(iTank))
	{
		g_iGhostAlpha[iTank] -= 2;
		int iGhostFade = !g_bTankConfig[ST_TankType(iTank)] ? g_iGhostFade[ST_TankType(iTank)] : g_iGhostFade2[ST_TankType(iTank)];
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
	}
	return Plugin_Continue;
}