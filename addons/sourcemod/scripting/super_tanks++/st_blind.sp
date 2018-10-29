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

// Super Tanks++: Blind Ability
#include <sourcemod>
#include <sdkhooks>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Blind Ability",
	author = ST_AUTHOR,
	description = "The Super Tank blinds survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bBlind[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sBlindEffect[ST_MAXTYPES + 1][4], g_sBlindEffect2[ST_MAXTYPES + 1][4], g_sBlindMessage[ST_MAXTYPES + 1][3], g_sBlindMessage2[ST_MAXTYPES + 1][3];

float g_flBlindChance[ST_MAXTYPES + 1], g_flBlindChance2[ST_MAXTYPES + 1], g_flBlindDuration[ST_MAXTYPES + 1], g_flBlindDuration2[ST_MAXTYPES + 1], g_flBlindRange[ST_MAXTYPES + 1], g_flBlindRange2[ST_MAXTYPES + 1], g_flBlindRangeChance[ST_MAXTYPES + 1], g_flBlindRangeChance2[ST_MAXTYPES + 1];

int g_iBlindAbility[ST_MAXTYPES + 1], g_iBlindAbility2[ST_MAXTYPES + 1], g_iBlindHit[ST_MAXTYPES + 1], g_iBlindHit2[ST_MAXTYPES + 1], g_iBlindHitMode[ST_MAXTYPES + 1], g_iBlindHitMode2[ST_MAXTYPES + 1], g_iBlindIntensity[ST_MAXTYPES + 1], g_iBlindIntensity2[ST_MAXTYPES + 1];

UserMsg g_umFadeUserMsgId;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Blind Ability only supports Left 4 Dead 1 & 2.");

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

	g_umFadeUserMsgId = GetUserMessageId("Fade");

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
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	g_bBlind[client] = false;
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

		if ((iBlindHitMode(attacker) == 0 || iBlindHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsHumanSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vBlindHit(victim, attacker, flBlindChance(attacker), iBlindHit(attacker), "1", "1");
			}
		}
		else if ((iBlindHitMode(victim) == 0 || iBlindHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vBlindHit(attacker, victim, flBlindChance(victim), iBlindHit(victim), "1", "2");
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
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iBlindAbility[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Enabled", 0);
				g_iBlindAbility[iIndex] = iClamp(g_iBlindAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Blind Ability/Ability Effect", g_sBlindEffect[iIndex], sizeof(g_sBlindEffect[]), "123");
				kvSuperTanks.GetString("Blind Ability/Ability Message", g_sBlindMessage[iIndex], sizeof(g_sBlindMessage[]), "0");
				g_flBlindChance[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Chance", 33.3);
				g_flBlindChance[iIndex] = flClamp(g_flBlindChance[iIndex], 0.1, 100.0);
				g_flBlindDuration[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Duration", 5.0);
				g_flBlindDuration[iIndex] = flClamp(g_flBlindDuration[iIndex], 0.1, 9999999999.0);
				g_iBlindHit[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Hit", 0);
				g_iBlindHit[iIndex] = iClamp(g_iBlindHit[iIndex], 0, 1);
				g_iBlindHitMode[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Hit Mode", 0);
				g_iBlindHitMode[iIndex] = iClamp(g_iBlindHitMode[iIndex], 0, 2);
				g_iBlindIntensity[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Intensity", 255);
				g_iBlindIntensity[iIndex] = iClamp(g_iBlindIntensity[iIndex], 0, 255);
				g_flBlindRange[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Range", 150.0);
				g_flBlindRange[iIndex] = flClamp(g_flBlindRange[iIndex], 1.0, 9999999999.0);
				g_flBlindRangeChance[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Range Chance", 15.0);
				g_flBlindRangeChance[iIndex] = flClamp(g_flBlindRangeChance[iIndex], 0.1, 100.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iBlindAbility2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Enabled", g_iBlindAbility[iIndex]);
				g_iBlindAbility2[iIndex] = iClamp(g_iBlindAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Blind Ability/Ability Effect", g_sBlindEffect2[iIndex], sizeof(g_sBlindEffect2[]), g_sBlindEffect[iIndex]);
				kvSuperTanks.GetString("Blind Ability/Ability Message", g_sBlindMessage2[iIndex], sizeof(g_sBlindMessage2[]), g_sBlindMessage[iIndex]);
				g_flBlindChance2[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Chance", g_flBlindChance[iIndex]);
				g_flBlindChance2[iIndex] = flClamp(g_flBlindChance2[iIndex], 0.1, 100.0);
				g_flBlindDuration2[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Duration", g_flBlindDuration[iIndex]);
				g_flBlindDuration2[iIndex] = flClamp(g_flBlindDuration2[iIndex], 0.1, 9999999999.0);
				g_iBlindHit2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Hit", g_iBlindHit[iIndex]);
				g_iBlindHit2[iIndex] = iClamp(g_iBlindHit2[iIndex], 0, 1);
				g_iBlindHitMode2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Hit Mode", g_iBlindHitMode[iIndex]);
				g_iBlindHitMode2[iIndex] = iClamp(g_iBlindHitMode2[iIndex], 0, 2);
				g_iBlindIntensity2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Intensity", g_iBlindIntensity[iIndex]);
				g_iBlindIntensity2[iIndex] = iClamp(g_iBlindIntensity2[iIndex], 0, 255);
				g_flBlindRange2[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Range", g_flBlindRange[iIndex]);
				g_flBlindRange2[iIndex] = flClamp(g_flBlindRange2[iIndex], 1.0, 9999999999.0);
				g_flBlindRangeChance2[iIndex] = kvSuperTanks.GetFloat("Blind Ability/Blind Range Chance", g_flBlindRangeChance[iIndex]);
				g_flBlindRangeChance2[iIndex] = flClamp(g_flBlindRangeChance2[iIndex], 0.1, 100.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_PluginEnd()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			vRemoveBlind(iPlayer);
		}
	}

	vReset();
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveBlind(iTank);
		}
	}
}

public void ST_Ability(int tank)
{
	if (ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		float flBlindRange = !g_bTankConfig[ST_TankType(tank)] ? g_flBlindRange[ST_TankType(tank)] : g_flBlindRange2[ST_TankType(tank)],
			flBlindRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flBlindRangeChance[ST_TankType(tank)] : g_flBlindRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flBlindRange)
				{
					vBlindHit(iSurvivor, tank, flBlindRangeChance, iBlindAbility(tank), "2", "3");
				}
			}
		}
	}
}

public void ST_BossStage(int tank)
{
	if (iBlindAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveBlind(tank);
	}
}

static void vBlind(int survivor, int intensity)
{
	int iTargets[2], iFlags = intensity == 0 ? (0x0001|0x0010) : (0x0002|0x0008), iColor[4] = {0, 0, 0, 0};

	iTargets[0] = survivor;
	iColor[3] = intensity;

	Handle hBlindTarget = StartMessageEx(g_umFadeUserMsgId, iTargets, 1);
	if (GetUserMessageType() == UM_Protobuf)
	{
		Protobuf pbSet = UserMessageToProtobuf(hBlindTarget);
		pbSet.SetInt("duration", 1536);
		pbSet.SetInt("hold_time", 1536);
		pbSet.SetInt("flags", iFlags);
		pbSet.SetColor("clr", iColor);
	}
	else
	{
		BfWrite bfWrite = UserMessageToBfWrite(hBlindTarget);
		bfWrite.WriteShort(1536);
		bfWrite.WriteShort(1536);
		bfWrite.WriteShort(iFlags);
		bfWrite.WriteByte(iColor[0]);
		bfWrite.WriteByte(iColor[1]);
		bfWrite.WriteByte(iColor[2]);
		bfWrite.WriteByte(iColor[3]);
	}

	EndMessage();
}

static void vBlindHit(int survivor, int tank, float chance, int enabled, const char[] message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsHumanSurvivor(survivor) && !g_bBlind[survivor])
	{
		g_bBlind[survivor] = true;

		DataPack dpBlind;
		CreateDataTimer(1.0, tTimerBlind, dpBlind, TIMER_FLAG_NO_MAPCHANGE);
		dpBlind.WriteCell(GetClientUserId(survivor));
		dpBlind.WriteCell(GetClientUserId(tank));
		dpBlind.WriteCell(enabled);

		float flBlindDuration = !g_bTankConfig[ST_TankType(tank)] ? g_flBlindDuration[ST_TankType(tank)] : g_flBlindDuration2[ST_TankType(tank)];
		DataPack dpStopBlindness;
		CreateDataTimer(flBlindDuration + 1.0, tTimerStopBlindness, dpStopBlindness, TIMER_FLAG_NO_MAPCHANGE);
		dpStopBlindness.WriteCell(GetClientUserId(survivor));
		dpStopBlindness.WriteCell(GetClientUserId(tank));
		dpStopBlindness.WriteString(message);

		char sBlindEffect[4];
		sBlindEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sBlindEffect[ST_TankType(tank)] : g_sBlindEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sBlindEffect, mode);

		char sBlindMessage[3];
		sBlindMessage = !g_bTankConfig[ST_TankType(tank)] ? g_sBlindMessage[ST_TankType(tank)] : g_sBlindMessage2[ST_TankType(tank)];
		if (StrContains(sBlindMessage, message) != -1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Blind", sTankName, survivor);
		}
	}
}

static void vRemoveBlind(int tank)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsHumanSurvivor(iSurvivor) && g_bBlind[iSurvivor])
		{
			DataPack dpStopBlindness;
			CreateDataTimer(0.1, tTimerStopBlindness, dpStopBlindness, TIMER_FLAG_NO_MAPCHANGE);
			dpStopBlindness.WriteCell(GetClientUserId(iSurvivor));
			dpStopBlindness.WriteCell(GetClientUserId(tank));
			dpStopBlindness.WriteString("0");
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bBlind[iPlayer] = false;
		}
	}
}

static float flBlindChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flBlindChance[ST_TankType(tank)] : g_flBlindChance2[ST_TankType(tank)];
}

static int iBlindAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBlindAbility[ST_TankType(tank)] : g_iBlindAbility2[ST_TankType(tank)];
}

static int iBlindHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBlindHit[ST_TankType(tank)] : g_iBlindHit2[ST_TankType(tank)];
}

static int iBlindHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBlindHitMode[ST_TankType(tank)] : g_iBlindHitMode2[ST_TankType(tank)];
}

public Action tTimerBlind(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsHumanSurvivor(iSurvivor))
	{
		g_bBlind[iSurvivor] = false;
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bBlind[iSurvivor])
	{
		g_bBlind[iSurvivor] = false;
		return Plugin_Stop;
	}

	int iBlindEnabled = pack.ReadCell();
	if (iBlindEnabled == 0)
	{
		g_bBlind[iSurvivor] = false;
		return Plugin_Stop;
	}

	int iBlindIntensity = !g_bTankConfig[ST_TankType(iTank)] ? g_iBlindIntensity[ST_TankType(iTank)] : g_iBlindIntensity2[ST_TankType(iTank)];
	vBlind(iSurvivor, iBlindIntensity);

	return Plugin_Continue;
}

public Action tTimerStopBlindness(Handle timer, DataPack pack)
{
	pack.Reset();

	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (!bIsHumanSurvivor(iSurvivor) || !g_bBlind[iSurvivor])
	{
		g_bBlind[iSurvivor] = false;

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bBlind[iSurvivor] = false;

		vBlind(iSurvivor, 0);

		return Plugin_Stop;
	}

	g_bBlind[iSurvivor] = false;

	vBlind(iSurvivor, 0);

	char sBlindMessage[3], sMessage[3];
	sBlindMessage = !g_bTankConfig[ST_TankType(iTank)] ? g_sBlindMessage[ST_TankType(iTank)] : g_sBlindMessage2[ST_TankType(iTank)];
	pack.ReadString(sMessage, sizeof(sMessage));
	if (StrContains(sBlindMessage, sMessage) != -1)
	{
		PrintToChatAll("%s %t", ST_TAG2, "Blind2", iSurvivor);
	}

	return Plugin_Continue;
}