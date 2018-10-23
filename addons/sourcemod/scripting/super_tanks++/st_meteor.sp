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

// Super Tanks++: Meteor Ability
#include <sourcemod>
#include <sdktools>

#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Meteor Ability",
	author = ST_AUTHOR,
	description = "The Super Tank creates meteor showers.",
	version = ST_VERSION,
	url = ST_URL
};

#define MODEL_CONCRETE "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"

bool g_bCloneInstalled, g_bMeteor[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];

char g_sMeteorRadius[ST_MAXTYPES + 1][13], g_sMeteorRadius2[ST_MAXTYPES + 1][13], g_sPropsColors[ST_MAXTYPES + 1][80], g_sPropsColors2[ST_MAXTYPES + 1][80];

float g_flMeteorChance[ST_MAXTYPES + 1], g_flMeteorChance2[ST_MAXTYPES + 1];

int g_iMeteorAbility[ST_MAXTYPES + 1], g_iMeteorAbility2[ST_MAXTYPES + 1], g_iMeteorMessage[ST_MAXTYPES + 1], g_iMeteorMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Meteor Ability only supports Left 4 Dead 1 & 2.");

		return APLRes_SilentFailure;
	}

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
}

public void OnMapStart()
{
	PrecacheModel(MODEL_GASCAN, true);
	PrecacheModel(MODEL_PROPANETANK, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	g_bMeteor[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public void ST_Configs(const char[] savepath, bool main)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	for (int iIndex = ST_MinType(); iIndex <= ST_MaxType(); iIndex++)
	{
		char sTankName[33];
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName, true))
		{
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				kvSuperTanks.GetString("Props/Props Colors", g_sPropsColors[iIndex], sizeof(g_sPropsColors[]), "255,255,255,255|255,255,255,255|255,255,255,180|255,255,255,255|255,255,255,255");
				g_iMeteorAbility[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Ability Enabled", 0);
				g_iMeteorAbility[iIndex] = iClamp(g_iMeteorAbility[iIndex], 0, 1);
				g_iMeteorMessage[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Ability Message", 0);
				g_iMeteorMessage[iIndex] = iClamp(g_iMeteorMessage[iIndex], 0, 1);
				g_flMeteorChance[iIndex] = kvSuperTanks.GetFloat("Meteor Ability/Meteor Chance", 33.3);
				g_flMeteorChance[iIndex] = flClamp(g_flMeteorChance[iIndex], 0.1, 100.0);
				kvSuperTanks.GetString("Meteor Ability/Meteor Radius", g_sMeteorRadius[iIndex], sizeof(g_sMeteorRadius[]), "-180.0,180.0");
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				kvSuperTanks.GetString("Props/Props Colors", g_sPropsColors2[iIndex], sizeof(g_sPropsColors2[]), g_sPropsColors[iIndex]);
				g_iMeteorAbility2[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Ability Enabled", g_iMeteorAbility[iIndex]);
				g_iMeteorAbility2[iIndex] = iClamp(g_iMeteorAbility2[iIndex], 0, 1);
				g_iMeteorMessage2[iIndex] = kvSuperTanks.GetNum("Meteor Ability/Ability Message", g_iMeteorMessage[iIndex]);
				g_iMeteorMessage2[iIndex] = iClamp(g_iMeteorMessage2[iIndex], 0, 1);
				g_flMeteorChance2[iIndex] = kvSuperTanks.GetFloat("Meteor Ability/Meteor Chance", g_flMeteorChance[iIndex]);
				g_flMeteorChance2[iIndex] = flClamp(g_flMeteorChance2[iIndex], 0.1, 100.0);
				kvSuperTanks.GetString("Meteor Ability/Meteor Radius", g_sMeteorRadius2[iIndex], sizeof(g_sMeteorRadius2[]), g_sMeteorRadius[iIndex]);
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
	float flMeteorChance = !g_bTankConfig[ST_TankType(tank)] ? g_flMeteorChance[ST_TankType(tank)] : g_flMeteorChance2[ST_TankType(tank)];
	if (iMeteorAbility(tank) == 1 && GetRandomFloat(0.1, 100.0) <= flMeteorChance && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank) && !g_bMeteor[tank])
	{
		g_bMeteor[tank] = true;

		float flPos[3];
		GetClientEyePosition(tank, flPos);

		DataPack dpMeteorUpdate;
		CreateDataTimer(0.6, tTimerMeteorUpdate, dpMeteorUpdate, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpMeteorUpdate.WriteCell(GetClientUserId(tank));
		dpMeteorUpdate.WriteFloat(flPos[0]);
		dpMeteorUpdate.WriteFloat(flPos[1]);
		dpMeteorUpdate.WriteFloat(flPos[2]);
		dpMeteorUpdate.WriteFloat(GetEngineTime());

		int iMeteorMessage = !g_bTankConfig[ST_TankType(tank)] ? g_iMeteorMessage[ST_TankType(tank)] : g_iMeteorMessage2[ST_TankType(tank)];
		if (iMeteorMessage == 1)
		{
			char sTankName[33];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_TAG2, "Meteor", sTankName);
		}
	}
}

static void vMeteor(int tank, int rock)
{
	if (!ST_TankAllowed(tank) || !IsPlayerAlive(tank) || !ST_CloneAllowed(tank, g_bCloneInstalled) || !bIsValidEntity(rock))
	{
		return;
	}

	char sClassname[16];
	GetEntityClassname(rock, sClassname, sizeof(sClassname));
	if (StrEqual(sClassname, "tank_rock"))
	{
		RemoveEntity(rock);

		float flRockPos[3];
		GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flRockPos);

		vSpecialAttack(tank, flRockPos, 50.0, MODEL_GASCAN);
		vSpecialAttack(tank, flRockPos, 50.0, MODEL_PROPANETANK);
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bMeteor[iPlayer] = false;
		}
	}
}

static int iMeteorAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iMeteorAbility[ST_TankType(tank)] : g_iMeteorAbility2[ST_TankType(tank)];
}

public Action tTimerMeteorUpdate(Handle timer, DataPack pack)
{
	pack.Reset();

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || !g_bMeteor[iTank])
	{
		g_bMeteor[iTank] = false;

		return Plugin_Stop;
	}

	float flPos[3];
	flPos[0] = pack.ReadFloat(), flPos[1] = pack.ReadFloat(), flPos[2] = pack.ReadFloat();
	float flTime = pack.ReadFloat();

	if (iMeteorAbility(iTank) == 0)
	{
		g_bMeteor[iTank] = false;

		return Plugin_Stop;
	}

	char sRadius[2][7], sMeteorRadius[13], sSet[5][16], sPropsColors[80], sRGB[4][4];
	sMeteorRadius = !g_bTankConfig[ST_TankType(iTank)] ? g_sMeteorRadius[ST_TankType(iTank)] : g_sMeteorRadius2[ST_TankType(iTank)];
	TrimString(sMeteorRadius);
	ExplodeString(sMeteorRadius, ",", sRadius, sizeof(sRadius), sizeof(sRadius[]));

	TrimString(sRadius[0]);
	float flMin = (sRadius[0][0] != '\0') ? StringToFloat(sRadius[0]) : -200.0;

	TrimString(sRadius[1]);
	float flMax = (sRadius[1][0] != '\0') ? StringToFloat(sRadius[1]) : 200.0;

	flMin = flClamp(flMin, -200.0, 0.0);
	flMax = flClamp(flMax, 0.0, 200.0);

	sPropsColors = !g_bTankConfig[ST_TankType(iTank)] ? g_sPropsColors[ST_TankType(iTank)] : g_sPropsColors2[ST_TankType(iTank)];
	TrimString(sPropsColors);
	ExplodeString(sPropsColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));

	ExplodeString(sSet[3], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));

	TrimString(sRGB[0]);
	int iRed = (sRGB[0][0] != '\0') ? StringToInt(sRGB[0]) : 255;
	iRed = iClamp(iRed, 0, 255);

	TrimString(sRGB[1]);
	int iGreen = (sRGB[1][0] != '\0') ? StringToInt(sRGB[1]) : 255;
	iGreen = iClamp(iGreen, 0, 255);

	TrimString(sRGB[2]);
	int iBlue = (sRGB[2][0] != '\0') ? StringToInt(sRGB[2]) : 255;
	iBlue = iClamp(iBlue, 0, 255);

	TrimString(sRGB[3]);
	int iAlpha = (sRGB[3][0] != '\0') ? StringToInt(sRGB[3]) : 255;
	iAlpha = iClamp(iAlpha, 0, 255);

	if ((GetEngineTime() - flTime) > 5.0)
	{
		g_bMeteor[iTank] = false;
	}

	int iMeteor = -1;
	if (g_bMeteor[iTank])
	{
		float flAngles[3], flVelocity[3], flHitpos[3], flVector[3];

		flAngles[0] = GetRandomFloat(-20.0, 20.0);
		flAngles[1] = GetRandomFloat(-20.0, 20.0);
		flAngles[2] = 60.0;

		GetVectorAngles(flAngles, flAngles);
		iGetRayHitPos(flPos, flAngles, flHitpos, iTank, true, 2);

		float flDistance = GetVectorDistance(flPos, flHitpos);
		if (flDistance > 1600.0)
		{
			flDistance = 1600.0;
		}

		MakeVectorFromPoints(flPos, flHitpos, flVector);
		NormalizeVector(flVector, flVector);
		ScaleVector(flVector, flDistance - 40.0);
		AddVectors(flPos, flVector, flHitpos);

		if (flDistance > 100.0)
		{
			int iRock = CreateEntityByName("tank_rock");
			if (bIsValidEntity(iRock))
			{
				SetEntityModel(iRock, MODEL_CONCRETE);
				SetEntityRenderColor(iRock, iRed, iGreen, iBlue, iAlpha);

				float flAngles2[3];

				flAngles2[0] = GetRandomFloat(flMin, flMax);
				flAngles2[1] = GetRandomFloat(flMin, flMax);
				flAngles2[2] = GetRandomFloat(flMin, flMax);

				flVelocity[0] = GetRandomFloat(0.0, 350.0);
				flVelocity[1] = GetRandomFloat(0.0, 350.0);
				flVelocity[2] = GetRandomFloat(0.0, 30.0);

				TeleportEntity(iRock, flHitpos, flAngles2, flVelocity);

				DispatchSpawn(iRock);
				ActivateEntity(iRock);
				AcceptEntityInput(iRock, "Ignite");

				SetEntPropEnt(iRock, Prop_Send, "m_hOwnerEntity", iTank);
				iRock = EntIndexToEntRef(iRock);
				vDeleteEntity(iRock, 30.0);
			}
		}
	}
	else
	{
		while ((iMeteor = FindEntityByClassname(iMeteor, "tank_rock")) != INVALID_ENT_REFERENCE)
		{
			int iOwner = GetEntPropEnt(iMeteor, Prop_Send, "m_hOwnerEntity");
			if (iTank == iOwner)
			{
				vMeteor(iOwner, iMeteor);
			}
		}

		return Plugin_Stop;
	}

	while ((iMeteor = FindEntityByClassname(iMeteor, "tank_rock")) != INVALID_ENT_REFERENCE)
	{
		int iOwner = GetEntPropEnt(iMeteor, Prop_Send, "m_hOwnerEntity");
		if (iTank == iOwner)
		{
			if (flGetGroundUnits(iMeteor) < 200.0)
			{
				vMeteor(iOwner, iMeteor);
			}
		}
	}

	return Plugin_Continue;
}