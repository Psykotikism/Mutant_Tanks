/**
 * Super Tanks++: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2018  Alfred "Crasher_3637/Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

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

char g_sGhostEffect[ST_MAXTYPES + 1][4], g_sGhostEffect2[ST_MAXTYPES + 1][4], g_sGhostMessage[ST_MAXTYPES + 1][4], g_sGhostMessage2[ST_MAXTYPES + 1][4], g_sGhostWeaponSlots[ST_MAXTYPES + 1][6], g_sGhostWeaponSlots2[ST_MAXTYPES + 1][6];

float g_flGhostChance[ST_MAXTYPES + 1], g_flGhostChance2[ST_MAXTYPES + 1], g_flGhostFadeDelay[ST_MAXTYPES + 1], g_flGhostFadeDelay2[ST_MAXTYPES + 1], g_flGhostFadeRate[ST_MAXTYPES + 1], g_flGhostFadeRate2[ST_MAXTYPES + 1], g_flGhostRange[ST_MAXTYPES + 1], g_flGhostRange2[ST_MAXTYPES + 1], g_flGhostRangeChance[ST_MAXTYPES + 1], g_flGhostRangeChance2[ST_MAXTYPES + 1];

int g_iGhostAbility[ST_MAXTYPES + 1], g_iGhostAbility2[ST_MAXTYPES + 1], g_iGhostAlpha[MAXPLAYERS + 1], g_iGhostFadeAlpha[ST_MAXTYPES + 1], g_iGhostFadeAlpha2[ST_MAXTYPES + 1], g_iGhostFadeLimit[ST_MAXTYPES + 1], g_iGhostFadeLimit2[ST_MAXTYPES + 1], g_iGhostHit[ST_MAXTYPES + 1], g_iGhostHit2[ST_MAXTYPES + 1], g_iGhostHitMode[ST_MAXTYPES + 1], g_iGhostHitMode2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "\"[ST++] Ghost Ability\" only supports Left 4 Dead 1 & 2.");

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
			if (bIsValidClient(iPlayer, "24"))
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
	if (ST_PluginEnabled() && bIsValidClient(victim, "0234") && damage > 0.0)
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));

		if ((iGhostHitMode(attacker) == 0 || iGhostHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vGhostHit(victim, attacker, flGhostChance(attacker), iGhostHit(attacker), "1", "1");
			}
		}
		else if ((iGhostHitMode(victim) == 0 || iGhostHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vGhostHit(attacker, victim, flGhostChance(victim), iGhostHit(victim), "1", "2");
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
		char sTankName[33];
		Format(sTankName, sizeof(sTankName), "Tank #%i", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iGhostAbility[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ability Enabled", 0);
				g_iGhostAbility[iIndex] = iClamp(g_iGhostAbility[iIndex], 0, 3);
				kvSuperTanks.GetString("Ghost Ability/Ability Effect", g_sGhostEffect[iIndex], sizeof(g_sGhostEffect[]), "0");
				kvSuperTanks.GetString("Ghost Ability/Ability Message", g_sGhostMessage[iIndex], sizeof(g_sGhostMessage[]), "0");
				g_flGhostChance[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Chance", 33.3);
				g_flGhostChance[iIndex] = flClamp(g_flGhostChance[iIndex], 0.0, 100.0);
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
				g_flGhostRangeChance[iIndex] = flClamp(g_flGhostRangeChance[iIndex], 0.0, 100.0);
				kvSuperTanks.GetString("Ghost Ability/Ghost Weapon Slots", g_sGhostWeaponSlots[iIndex], sizeof(g_sGhostWeaponSlots[]), "12345");
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iGhostAbility2[iIndex] = kvSuperTanks.GetNum("Ghost Ability/Ability Enabled", g_iGhostAbility[iIndex]);
				g_iGhostAbility2[iIndex] = iClamp(g_iGhostAbility2[iIndex], 0, 3);
				kvSuperTanks.GetString("Ghost Ability/Ability Effect", g_sGhostEffect2[iIndex], sizeof(g_sGhostEffect2[]), g_sGhostEffect[iIndex]);
				kvSuperTanks.GetString("Ghost Ability/Ability Message", g_sGhostMessage2[iIndex], sizeof(g_sGhostMessage2[]), g_sGhostMessage[iIndex]);
				g_flGhostChance2[iIndex] = kvSuperTanks.GetFloat("Ghost Ability/Ghost Chance", g_flGhostChance[iIndex]);
				g_flGhostChance2[iIndex] = flClamp(g_flGhostChance2[iIndex], 0.0, 100.0);
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
				g_flGhostRangeChance2[iIndex] = flClamp(g_flGhostRangeChance2[iIndex], 0.0, 100.0);
				kvSuperTanks.GetString("Ghost Ability/Ghost Weapon Slots", g_sGhostWeaponSlots2[iIndex], sizeof(g_sGhostWeaponSlots2[]), g_sGhostWeaponSlots[iIndex]);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		float flGhostRange = !g_bTankConfig[ST_TankType(tank)] ? g_flGhostRange[ST_TankType(tank)] : g_flGhostRange2[ST_TankType(tank)],
			flGhostRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flGhostRangeChance[ST_TankType(tank)] : g_flGhostRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor, "234"))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flGhostRange)
				{
					vGhostHit(iSurvivor, tank, flGhostRangeChance, iGhostAbility(tank), "2", "3");
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

			char sGhostMessage[4];
			sGhostMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sGhostMessage[ST_TankType(tank)] : g_sGhostMessage2[ST_TankType(tank)];
			if (StrContains(sGhostMessage, "3") != -1)
			{
				char sTankName[33];
				ST_TankName(tank, sTankName);
				ST_PrintToChatAll("%s %t", ST_TAG2, "Ghost2", sTankName);
			}
		}
	}
}

public void ST_ChangeType(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		g_bGhost[tank] = false;
		g_bGhost2[tank] = false;
		g_iGhostAlpha[tank] = 255;
	}
}

static void vDropWeapon(int survivor, const char[] slots, const char[] number, int slot)
{
	if (StrContains(slots, number) != -1)
	{
		if (bIsSurvivor(survivor) && GetPlayerWeaponSlot(survivor, slot) > 0)
		{
			SDKHooks_DropWeapon(survivor, GetPlayerWeaponSlot(survivor, slot), NULL_VECTOR, NULL_VECTOR);
		}
	}
}

static void vGhostHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
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

		char sGhostMessage[4];
		sGhostMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sGhostMessage[ST_TankType(tank)] : g_sGhostMessage2[ST_TankType(tank)];
		if (StrContains(sGhostMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			ST_PrintToChatAll("%s %t", ST_TAG2, "Ghost", sTankName, survivor);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer, "24"))
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

public Action tTimerGhost(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);

	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || (iGhostAbility(iTank) != 2 && iGhostAbility(iTank) != 3) || !g_bGhost[iTank])
	{
		g_bGhost[iTank] = false;
		g_iGhostAlpha[iTank] = 255;

		return Plugin_Stop;
	}

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

	int iSkinRed, iSkinGreen, iSkinBlue, iSkinAlpha;
	ST_TankColors(iTank, 1, iSkinRed, iSkinGreen, iSkinBlue, iSkinAlpha);

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
					int iJetpackRed, iJetpackGreen, iJetpackBlue, iJetpackAlpha;
					ST_PropsColors(iTank, 2, iJetpackRed, iJetpackGreen, iJetpackBlue, iJetpackAlpha);
					SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iProp, iJetpackRed, iJetpackGreen, iJetpackBlue, g_iGhostAlpha[iTank]);
				}

				if (StrEqual(sModel, MODEL_CONCRETE, false))
				{
					int iRockRed, iRockGreen, iRockBlue, iRockAlpha;
					ST_PropsColors(iTank, 4, iRockRed, iRockGreen, iRockBlue, iRockAlpha);
					SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iProp, iRockRed, iRockGreen, iRockBlue, g_iGhostAlpha[iTank]);
				}

				if (StrEqual(sModel, MODEL_TIRES, false))
				{
					int iTireRed, iTireGreen, iTireBlue, iTireAlpha;
					ST_PropsColors(iTank, 5, iTireRed, iTireGreen, iTireBlue, iTireAlpha);
					SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iProp, iTireRed, iTireGreen, iTireBlue, g_iGhostAlpha[iTank]);
				}

				if (StrEqual(sModel, MODEL_TANK, false))
				{
					SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iProp, iSkinRed, iSkinGreen, iSkinBlue, g_iGhostAlpha[iTank]);
				}
			}
		}
	}

	while ((iProp = FindEntityByClassname(iProp, "beam_spotlight")) != INVALID_ENT_REFERENCE)
	{
		int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iOwner == iTank)
		{
			int iLightRed, iLightGreen, iLightBlue, iLightAlpha;
			ST_PropsColors(iTank, 1, iLightRed, iLightGreen, iLightBlue, iLightAlpha);
			SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
			SetEntityRenderColor(iProp, iLightRed, iLightGreen, iLightBlue, g_iGhostAlpha[iTank]);
		}
	}

	while ((iProp = FindEntityByClassname(iProp, "env_steam")) != INVALID_ENT_REFERENCE)
	{
		int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iOwner == iTank)
		{
			int iFlameRed, iFlameGreen, iFlameBlue, iFlameAlpha;
			ST_PropsColors(iTank, 3, iFlameRed, iFlameGreen, iFlameBlue, iFlameAlpha);
			SetEntityRenderMode(iProp, RENDER_TRANSCOLOR);
			SetEntityRenderColor(iProp, iFlameRed, iFlameGreen, iFlameBlue, g_iGhostAlpha[iTank]);
		}
	}

	SetEntityRenderMode(iTank, RENDER_TRANSCOLOR);
	SetEntityRenderColor(iTank, iSkinRed, iSkinGreen, iSkinBlue, g_iGhostAlpha[iTank]);

	return Plugin_Continue;
}

public Action tTimerStopGhost(Handle timer, int userid)
{
	int iTank = GetClientOfUserId(userid);

	if (!ST_TankAllowed(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bGhost2[iTank])
	{
		g_bGhost2[iTank] = false;
		g_iGhostAlpha[iTank] = 255;

		return Plugin_Stop;
	}

	g_bGhost2[iTank] = false;
	g_iGhostAlpha[iTank] = 255;

	char sGhostMessage[4];
	sGhostMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sGhostMessage[ST_TankType(iTank)] : g_sGhostMessage2[ST_TankType(iTank)];
	if (StrContains(sGhostMessage, "3") != -1)
	{
		char sTankName[33];
		ST_TankName(iTank, sTankName);
		ST_PrintToChatAll("%s %t", ST_TAG2, "Ghost3", sTankName);
	}

	return Plugin_Continue;
}