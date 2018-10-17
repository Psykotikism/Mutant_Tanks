// Super Tanks++: Ghost Ability
#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

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
	description = "The Super Tank cloaks itself and disarms survivors.",
	version = ST_VERSION,
	url = ST_URL
};

#define MODEL_CONCRETE "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_JETPACK "models/props_equipment/oxygentank01.mdl"
#define MODEL_TANK "models/infected/hulk.mdl"
#define MODEL_TIRES "models/props_vehicles/tire001c_car.mdl"

#define SOUND_INFECTED "npc/infected/action/die/male/death_42.wav"
#define SOUND_INFECTED2 "npc/infected/action/die/male/death_43.wav"

bool g_bCloneInstalled, g_bGhost[MAXPLAYERS + 1], g_bGhost2[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sGhostEffect[ST_MAXTYPES + 1][4], g_sGhostEffect2[ST_MAXTYPES + 1][4], g_sGhostWeaponSlots[ST_MAXTYPES + 1][6], g_sGhostWeaponSlots2[ST_MAXTYPES + 1][6], g_sPropsColors[ST_MAXTYPES + 1][80], g_sPropsColors2[ST_MAXTYPES + 1][80], g_sTankColors[ST_MAXTYPES + 1][28], g_sTankColors2[ST_MAXTYPES + 1][28];

float g_flGhostChance[ST_MAXTYPES + 1], g_flGhostChance2[ST_MAXTYPES + 1], g_flGhostFadeDelay[ST_MAXTYPES + 1], g_flGhostFadeDelay2[ST_MAXTYPES + 1], g_flGhostFadeRate[ST_MAXTYPES + 1], g_flGhostFadeRate2[ST_MAXTYPES + 1], g_flGhostRange[ST_MAXTYPES + 1], g_flGhostRange2[ST_MAXTYPES + 1], g_flGhostRangeChance[ST_MAXTYPES + 1], g_flGhostRangeChance2[ST_MAXTYPES + 1];

int g_iGhostAbility[ST_MAXTYPES + 1], g_iGhostAbility2[ST_MAXTYPES + 1], g_iGhostAlpha[MAXPLAYERS + 1], g_iGhostFadeAlpha[ST_MAXTYPES + 1], g_iGhostFadeAlpha2[ST_MAXTYPES + 1], g_iGhostFadeLimit[ST_MAXTYPES + 1], g_iGhostFadeLimit2[ST_MAXTYPES + 1], g_iGhostHit[ST_MAXTYPES + 1], g_iGhostHit2[ST_MAXTYPES + 1], g_iGhostHitMode[ST_MAXTYPES + 1], g_iGhostHitMode2[ST_MAXTYPES + 1], g_iGhostMessage[ST_MAXTYPES + 1], g_iGhostMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
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
	PrecacheSound(SOUND_INFECTED, true);
	PrecacheSound(SOUND_INFECTED2, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	g_bGhost[client] = false;
	g_bGhost2[client] = false;
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
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vGhostHit(victim, attacker, flGhostChance(attacker), iGhostHit(attacker), 1, "1");
			}
		}
		else if ((iGhostHitMode(victim) == 0 || iGhostHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vGhostHit(attacker, victim, flGhostChance(victim), iGhostHit(victim), 1, "2");
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
		char sTankName[MAX_NAME_LENGTH + 1];
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName, true))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors[iIndex], sizeof(g_sTankColors[]), "255,255,255,255|255,255,255");
				kvSuperTanks.GetString("Props/Props Colors", g_sPropsColors[iIndex], sizeof(g_sPropsColors[]), "255,255,255,255|255,255,255,255|255,255,255,180|255,255,255,255|255,255,255,255");
				g_iGhostAbility[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ability Enabled", 0);
				g_iGhostAbility[iIndex] = iClamp(g_iGhostAbility[iIndex], 0, 3);
				kvSuperTanks.GetString("Ghost Ability/Ability Effect", g_sGhostEffect[iIndex], sizeof(g_sGhostEffect[]), "123");
				g_iGhostMessage[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ability Message", 0);
				g_iGhostMessage[iIndex] = iClamp(g_iGhostMessage[iIndex], 0, 7);
				g_flGhostChance[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Chance", 33.3);
				g_flGhostChance[iIndex] = flClamp(g_flGhostChance[iIndex], 0.1, 100.0);
				g_iGhostFadeAlpha[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Fade Alpha", 2);
				g_iGhostFadeAlpha[iIndex] = iClamp(g_iGhostFadeAlpha[iIndex], 0, 255);
				g_flGhostFadeDelay[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Fade Delay", 5.0);
				g_flGhostFadeDelay[iIndex] = flClamp(g_flGhostFadeDelay[iIndex], 0.1, 9999999999.0);
				g_iGhostFadeLimit[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Fade Limit", 0);
				g_iGhostFadeLimit[iIndex] = iClamp(g_iGhostFadeLimit[iIndex], 0, 255);
				g_flGhostFadeRate[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Fade Rate", 0.1);
				g_flGhostFadeRate[iIndex] = flClamp(g_flGhostFadeRate[iIndex], 0.1, 9999999999.0);
				g_iGhostHit[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Hit", 0);
				g_iGhostHit[iIndex] = iClamp(g_iGhostHit[iIndex], 0, 1);
				g_iGhostHitMode[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Hit Mode", 0);
				g_iGhostHitMode[iIndex] = iClamp(g_iGhostHitMode[iIndex], 0, 2);
				g_flGhostRange[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Range", 150.0);
				g_flGhostRange[iIndex] = flClamp(g_flGhostRange[iIndex], 1.0, 9999999999.0);
				g_flGhostRangeChance[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Range Chance", 15.0);
				g_flGhostRangeChance[iIndex] = flClamp(g_flGhostRangeChance[iIndex], 0.1, 100.0);
				kvSuperTanks.GetString("Ghost Ability/Ghost Weapon Slots", g_sGhostWeaponSlots[iIndex], sizeof(g_sGhostWeaponSlots[]), "12345");
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors2[iIndex], sizeof(g_sTankColors2[]), g_sTankColors[iIndex]);
				kvSuperTanks.GetString("Props/Props Colors", g_sPropsColors2[iIndex], sizeof(g_sPropsColors2[]), g_sPropsColors[iIndex]);
				g_iGhostAbility2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ability Enabled", g_iGhostAbility[iIndex]);
				g_iGhostAbility2[iIndex] = iClamp(g_iGhostAbility2[iIndex], 0, 3);
				kvSuperTanks.GetString("Ghost Ability/Ability Effect", g_sGhostEffect2[iIndex], sizeof(g_sGhostEffect2[]), g_sGhostEffect[iIndex]);
				g_iGhostMessage2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ability Message", g_iGhostMessage[iIndex]);
				g_iGhostMessage2[iIndex] = iClamp(g_iGhostMessage2[iIndex], 0, 7);
				g_flGhostChance2[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Chance", g_flGhostChance[iIndex]);
				g_flGhostChance2[iIndex] = flClamp(g_flGhostChance2[iIndex], 0.1, 100.0);
				g_iGhostFadeAlpha2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Fade Alpha", g_iGhostFadeAlpha[iIndex]);
				g_iGhostFadeAlpha2[iIndex] = iClamp(g_iGhostFadeAlpha2[iIndex], 0, 255);
				g_flGhostFadeDelay2[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Fade Delay", g_flGhostFadeDelay[iIndex]);
				g_flGhostFadeDelay2[iIndex] = flClamp(g_flGhostFadeDelay2[iIndex], 0.1, 9999999999.0);
				g_iGhostFadeLimit2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Fade Limit", g_iGhostFadeLimit[iIndex]);
				g_iGhostFadeLimit2[iIndex] = iClamp(g_iGhostFadeLimit2[iIndex], 0, 255);
				g_flGhostFadeRate2[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Fade Rate", g_flGhostFadeRate[iIndex]);
				g_flGhostFadeRate2[iIndex] = flClamp(g_flGhostFadeRate2[iIndex], 0.1, 9999999999.0);
				g_iGhostHit2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Hit", g_iGhostHit[iIndex]);
				g_iGhostHit2[iIndex] = iClamp(g_iGhostHit2[iIndex], 0, 1);
				g_iGhostHitMode2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ghost Hit Mode", g_iGhostHitMode[iIndex]);
				g_iGhostHitMode2[iIndex] = iClamp(g_iGhostHitMode2[iIndex], 0, 2);
				g_flGhostRange2[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Range", g_flGhostRange[iIndex]);
				g_flGhostRange2[iIndex] = flClamp(g_flGhostRange2[iIndex], 1.0, 9999999999.0);
				g_flGhostRangeChance2[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Range Chance", g_flGhostRangeChance[iIndex]);
				g_flGhostRangeChance2[iIndex] = flClamp(g_flGhostRangeChance2[iIndex], 0.1, 100.0);
				kvSuperTanks.GetString("Ghost Ability/Ghost Weapon Slots", g_sGhostWeaponSlots2[iIndex], sizeof(g_sGhostWeaponSlots2[]), g_sGhostWeaponSlots[iIndex]);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	vReset();
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flGhostRange = !g_bTankConfig[ST_TankType(tank)] ? g_flGhostRange[ST_TankType(tank)] : g_flGhostRange2[ST_TankType(tank)],
			flGhostRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flGhostRangeChance[ST_TankType(tank)] : g_flGhostRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flGhostRange)
				{
					vGhostHit(iSurvivor, tank, flGhostRangeChance, iGhostAbility(tank), 2, "3");
				}
			}
		}

		if ((iGhostAbility(tank) == 2 || iGhostAbility(tank) == 3) && !g_bGhost[tank])
		{
			g_bGhost[tank] = true;
			g_iGhostAlpha[tank] = 255;

			float flGhostFadeRate = !g_bTankConfig[ST_TankType(tank)] ? g_flGhostFadeRate[ST_TankType(tank)] : g_flGhostFadeRate2[ST_TankType(tank)];
			CreateTimer(flGhostFadeRate, tTimerGhost, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);

			SetEntityRenderMode(tank, RENDER_TRANSCOLOR);

			switch (iGhostMessage(tank))
			{
				case 3, 5, 6, 7:
				{
					char sTankName[MAX_NAME_LENGTH + 1];
					ST_TankName(tank, sTankName);
					PrintToChatAll("%s %t", ST_PREFIX2, "Ghost2", sTankName);
				}
			}
		}
	}
}

static void vGhostHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	if ((enabled == 1 || enabled == 3) && GetRandomFloat(0.1, 100.0) <= chance && bIsSurvivor(survivor))
	{
		char sGhostWeaponSlots[6];
		sGhostWeaponSlots = !g_bTankConfig[ST_TankType(tank)] ? g_sGhostWeaponSlots[ST_TankType(tank)] : g_sGhostWeaponSlots2[ST_TankType(tank)];

		vDropWeapon(survivor, sGhostWeaponSlots, "1", 0);
		vDropWeapon(survivor, sGhostWeaponSlots, "2", 1);
		vDropWeapon(survivor, sGhostWeaponSlots, "3", 2);
		vDropWeapon(survivor, sGhostWeaponSlots, "4", 3);
		vDropWeapon(survivor, sGhostWeaponSlots, "5", 4);

		switch (GetRandomInt(1, 2))
		{
			case 1: EmitSoundToClient(survivor, SOUND_INFECTED, tank);
			case 2: EmitSoundToClient(survivor, SOUND_INFECTED2, tank);
		}

		char sGhostEffect[4];
		sGhostEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sGhostEffect[ST_TankType(tank)] : g_sGhostEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sGhostEffect, mode);

		if (iGhostMessage(tank) == message || iGhostMessage(tank) == 4 || iGhostMessage(tank) == 5 || iGhostMessage(tank) == 6 || iGhostMessage(tank) == 7)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Ghost", sTankName, survivor);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bGhost[iPlayer] = false;
			g_bGhost2[iPlayer] = false;
			g_iGhostAlpha[iPlayer] = 255;
		}
	}
}

static float flGhostChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flGhostChance[ST_TankType(tank)] : g_flGhostChance2[ST_TankType(tank)];
}

static int iGhostAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGhostAbility[ST_TankType(tank)] : g_iGhostAbility2[ST_TankType(tank)];
}

static int iGhostHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGhostHit[ST_TankType(tank)] : g_iGhostHit2[ST_TankType(tank)];
}

static int iGhostHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGhostHitMode[ST_TankType(tank)] : g_iGhostHitMode2[ST_TankType(tank)];
}

static int iGhostMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iGhostMessage[ST_TankType(tank)] : g_iGhostMessage2[ST_TankType(tank)];
}

public Action tTimerGhost(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bGhost[iTank])
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
	iRed = iClamp(iRed, 0, 255);

	TrimString(sRGB[1]);
	int iGreen = (sRGB[1][0] != '\0') ? StringToInt(sRGB[1]) : 255;
	iGreen = iClamp(iGreen, 0, 255);

	TrimString(sRGB[2]);
	int iBlue = (sRGB[2][0] != '\0') ? StringToInt(sRGB[2]) : 255;
	iBlue = iClamp(iBlue, 0, 255);

	sPropsColors = !g_bTankConfig[ST_TankType(iTank)] ? g_sPropsColors[ST_TankType(iTank)] : g_sPropsColors2[ST_TankType(iTank)];
	TrimString(sPropsColors);
	ExplodeString(sPropsColors, "|", sSet2, sizeof(sSet2), sizeof(sSet2[]));

	ExplodeString(sSet2[0], ",", sProps, sizeof(sProps), sizeof(sProps[]));

	TrimString(sProps[0]);
	int iRed2 = (sProps[0][0] != '\0') ? StringToInt(sProps[0]) : 255;
	iRed2 = iClamp(iRed2, 0, 255);

	TrimString(sProps[1]);
	int iGreen2 = (sProps[1][0] != '\0') ? StringToInt(sProps[1]) : 255;
	iGreen2 = iClamp(iGreen2, 0, 255);

	TrimString(sProps[2]);
	int iBlue2 = (sProps[2][0] != '\0') ? StringToInt(sProps[2]) : 255;
	iBlue2 = iClamp(iBlue2, 0, 255);

	ExplodeString(sSet2[1], ",", sProps2, sizeof(sProps2), sizeof(sProps2[]));

	TrimString(sProps2[0]);
	int iRed3 = (sProps2[0][0] != '\0') ? StringToInt(sProps2[0]) : 255;
	iRed3 = iClamp(iRed3, 0, 255);

	TrimString(sProps2[1]);
	int iGreen3 = (sProps2[1][0] != '\0') ? StringToInt(sProps2[1]) : 255;
	iGreen3 = iClamp(iGreen3, 0, 255);

	TrimString(sProps2[2]);
	int iBlue3 = (sProps2[2][0] != '\0') ? StringToInt(sProps2[2]) : 255;
	iBlue3 = iClamp(iBlue3, 0, 255);

	ExplodeString(sSet2[2], ",", sProps3, sizeof(sProps3), sizeof(sProps3[]));

	TrimString(sProps3[0]);
	int iRed4 = (sProps3[0][0] != '\0') ? StringToInt(sProps3[0]) : 255;
	iRed4 = iClamp(iRed4, 0, 255);

	TrimString(sProps3[1]);
	int iGreen4 = (sProps3[1][0] != '\0') ? StringToInt(sProps3[1]) : 255;
	iGreen4 = iClamp(iGreen4, 0, 255);

	TrimString(sProps3[2]);
	int iBlue4 = (sProps3[2][0] != '\0') ? StringToInt(sProps3[2]) : 255;
	iBlue4 = iClamp(iBlue4, 0, 255);

	ExplodeString(sSet2[3], ",", sProps4, sizeof(sProps4), sizeof(sProps4[]));

	TrimString(sProps4[0]);
	int iRed5 = (sProps4[0][0] != '\0') ? StringToInt(sProps4[0]) : 255;
	iRed5 = iClamp(iRed5, 0, 255);

	TrimString(sProps4[1]);
	int iGreen5 = (sProps4[1][0] != '\0') ? StringToInt(sProps4[1]) : 255;
	iGreen5 = iClamp(iGreen5, 0, 255);

	TrimString(sProps4[2]);
	int iBlue5 = (sProps4[2][0] != '\0') ? StringToInt(sProps4[2]) : 255;
	iBlue5 = iClamp(iBlue5, 0, 255);

	ExplodeString(sSet2[4], ",", sProps5, sizeof(sProps5), sizeof(sProps5[]));

	TrimString(sProps5[0]);
	int iRed6 = (sProps5[0][0] != '\0') ? StringToInt(sProps5[0]) : 255;
	iRed6 = iClamp(iRed6, 0, 255);

	TrimString(sProps5[1]);
	int iGreen6 = (sProps5[1][0] != '\0') ? StringToInt(sProps5[1]) : 255;
	iGreen6 = iClamp(iGreen6, 0, 255);

	TrimString(sProps5[2]);
	int iBlue6 = (sProps5[2][0] != '\0') ? StringToInt(sProps5[2]) : 255;
	iBlue6 = iClamp(iBlue6, 0, 255);

	int iGhostFadeAlpha = !g_bTankConfig[ST_TankType(iTank)] ? g_iGhostFadeAlpha[ST_TankType(iTank)] : g_iGhostFadeAlpha2[ST_TankType(iTank)],
		iGhostFadeLimit = !g_bTankConfig[ST_TankType(iTank)] ? g_iGhostFadeLimit[ST_TankType(iTank)] : g_iGhostFadeLimit2[ST_TankType(iTank)];
	g_iGhostAlpha[iTank] -= iGhostFadeAlpha;

	if (g_iGhostAlpha[iTank] < iGhostFadeLimit)
	{
		g_iGhostAlpha[iTank] = iGhostFadeLimit;
		if (!g_bGhost2[iTank])
		{
			g_bGhost2[iTank] = true;

			float flGhostFadeDelay = !g_bTankConfig[ST_TankType(iTank)] ? g_flGhostFadeDelay[ST_TankType(iTank)] : g_flGhostFadeDelay2[ST_TankType(iTank)];
			CreateTimer(flGhostFadeDelay, tTimerStopGhost, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
	}

	int iProp = -1;
	while ((iProp = FindEntityByClassname(iProp, "prop_dynamic")) != INVALID_ENT_REFERENCE)
	{
		char sModel[128];
		GetEntPropString(iProp, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		if (StrEqual(sModel, MODEL_JETPACK, false) || StrEqual(sModel, MODEL_CONCRETE, false) || StrEqual(sModel, MODEL_TIRES, false) || StrEqual(sModel, MODEL_TANK, false))
		{
			int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
			if (iOwner == iTank)
			{
				if (StrEqual(sModel, MODEL_JETPACK, false))
				{
					SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iProp, iRed3, iGreen3, iBlue3, g_iGhostAlpha[iTank]);
				}

				if (StrEqual(sModel, MODEL_CONCRETE, false))
				{
					SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iProp, iRed5, iGreen5, iBlue5, g_iGhostAlpha[iTank]);
				}

				if (StrEqual(sModel, MODEL_TIRES, false))
				{
					SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iProp, iRed6, iGreen6, iBlue6, g_iGhostAlpha[iTank]);
				}

				if (StrEqual(sModel, MODEL_TANK, false))
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

public Action tTimerStopGhost(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bGhost2[iTank])
	{
		g_bGhost2[iTank] = false;
		g_iGhostAlpha[iTank] = 255;

		return Plugin_Stop;
	}

	g_bGhost2[iTank] = false;
	g_iGhostAlpha[iTank] = 255;

	switch (iGhostMessage(iTank))
	{
		case 3, 5, 6, 7:
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(iTank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Ghost3", sTankName);
		}
	}

	return Plugin_Continue;
}