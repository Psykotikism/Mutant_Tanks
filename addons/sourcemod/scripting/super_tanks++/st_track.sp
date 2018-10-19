// Super Tanks++: Track Ability
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
	name = "[ST++] Track Ability",
	author = ST_AUTHOR,
	description = "The Super Tank throws a heat-seeking rock that will track down the nearest survivor.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bTankConfig[ST_MAXTYPES + 1];

char g_sTankColors[ST_MAXTYPES + 1][28], g_sTankColors2[ST_MAXTYPES + 1][28];

float g_flTrackChance[ST_MAXTYPES + 1], g_flTrackChance2[ST_MAXTYPES + 1], g_flTrackSpeed[ST_MAXTYPES + 1], g_flTrackSpeed2[ST_MAXTYPES + 1];

int g_iGlowOutline[ST_MAXTYPES + 1], g_iGlowOutline2[ST_MAXTYPES + 1], g_iTrackAbility[ST_MAXTYPES + 1], g_iTrackAbility2[ST_MAXTYPES + 1], g_iTrackMessage[ST_MAXTYPES + 1], g_iTrackMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Track Ability only supports Left 4 Dead 1 & 2.");

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

public void Think(int rock)
{
	if (bIsValidEntity(rock))
	{
		vTrack(rock);
	}
	else
	{
		SDKUnhook(rock, SDKHook_Think, Think);
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
				g_iGlowOutline[iIndex] = kvSuperTanks.GetNum("General/Glow Outline", 1);
				g_iGlowOutline[iIndex] = iClamp(g_iGlowOutline[iIndex], 0, 1);
				g_iTrackAbility[iIndex] = kvSuperTanks.GetNum("Track Ability/Ability Enabled", 0);
				g_iTrackAbility[iIndex] = iClamp(g_iTrackAbility[iIndex], 0, 1);
				g_iTrackMessage[iIndex] = kvSuperTanks.GetNum("Track Ability/Ability Message", 0);
				g_iTrackMessage[iIndex] = iClamp(g_iTrackMessage[iIndex], 0, 1);
				g_flTrackChance[iIndex] = kvSuperTanks.GetFloat("Track Ability/Track Chance", 33.3);
				g_flTrackChance[iIndex] = flClamp(g_flTrackChance[iIndex], 0.1, 100.0);
				g_flTrackSpeed[iIndex] = kvSuperTanks.GetFloat("Track Ability/Track Speed", 500.0);
				g_flTrackSpeed[iIndex] = flClamp(g_flTrackSpeed[iIndex], 0.1, 9999999999.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors2[iIndex], sizeof(g_sTankColors2[]), g_sTankColors[iIndex]);
				g_iGlowOutline2[iIndex] = kvSuperTanks.GetNum("General/Glow Outline", g_iGlowOutline[iIndex]);
				g_iGlowOutline2[iIndex] = iClamp(g_iGlowOutline2[iIndex], 0, 1);
				g_iTrackAbility2[iIndex] = kvSuperTanks.GetNum("Track Ability/Ability Enabled", g_iTrackAbility[iIndex]);
				g_iTrackAbility2[iIndex] = iClamp(g_iTrackAbility2[iIndex], 0, 1);
				g_iTrackMessage2[iIndex] = kvSuperTanks.GetNum("Track Ability/Ability Message", g_iTrackMessage[iIndex]);
				g_iTrackMessage2[iIndex] = iClamp(g_iTrackMessage2[iIndex], 0, 1);
				g_flTrackChance2[iIndex] = kvSuperTanks.GetFloat("Track Ability/Track Chance", g_flTrackChance[iIndex]);
				g_flTrackChance2[iIndex] = flClamp(g_flTrackChance2[iIndex], 0.1, 100.0);
				g_flTrackSpeed2[iIndex] = kvSuperTanks.GetFloat("Track Ability/Track Speed", g_flTrackSpeed[iIndex]);
				g_flTrackSpeed2[iIndex] = flClamp(g_flTrackSpeed2[iIndex], 100.0, 500.0);
			}

			kvSuperTanks.Rewind();
		}
	}

	delete kvSuperTanks;
}

public void ST_RockThrow(int tank, int rock)
{
	float flTrackChance = !g_bTankConfig[ST_TankType(tank)] ? g_flTrackChance[ST_TankType(tank)] : g_flTrackChance2[ST_TankType(tank)];
	if (iTrackAbility(tank) == 1 && GetRandomFloat(0.1, 100.0) <= flTrackChance && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		int iTrackMessage = !g_bTankConfig[ST_TankType(tank)] ? g_iTrackMessage[ST_TankType(tank)] : g_iTrackMessage2[ST_TankType(tank)];

		DataPack dpTrack;
		CreateDataTimer(0.5, tTimerTrack, dpTrack, TIMER_FLAG_NO_MAPCHANGE);
		dpTrack.WriteCell(EntIndexToEntRef(rock));
		dpTrack.WriteCell(GetClientUserId(tank));

		if (iTrackMessage == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Track", sTankName);
		}
	}
}

static void vTrack(int rock)
{
	int iTank = GetEntPropEnt(rock, Prop_Data, "m_hThrower");
	float flTrackSpeed = !g_bTankConfig[ST_TankType(iTank)] ? g_flTrackSpeed[ST_TankType(iTank)] : g_flTrackSpeed2[ST_TankType(iTank)],
		flPos[3], flVelocity[3];

	GetEntPropVector(rock, Prop_Send, "m_vecOrigin", flPos);
	GetEntPropVector(rock, Prop_Data, "m_vecVelocity", flVelocity);

	if (GetVectorLength(flVelocity) < 50.0)
	{
		return;
	}

	NormalizeVector(flVelocity, flVelocity);

	int iTarget = iGetRandomTarget(flPos, flVelocity);
	float flVelocity2[3], flVector[3], flAngles[3], flDistance = 1000.0;

	flVector[0] = flVector[1] = flVector[2] = 0.0;

	bool bVisible;

	if (iTarget > 0)
	{
		float flPos2[3];
		GetClientEyePosition(iTarget, flPos2);
		flDistance = GetVectorDistance(flPos, flPos2);
		bVisible = bVisiblePosition(flPos, flPos2, rock, 1);

		GetEntPropVector(iTarget, Prop_Data, "m_vecVelocity", flVelocity2);
		AddVectors(flPos2, flVelocity2, flPos2);
		MakeVectorFromPoints(flPos, flPos2, flVector);
	}

	GetVectorAngles(flVelocity, flAngles);

	float flLeft[3], flRight[3], flUp[3], flDown[3], flFront[3], flVector1[3], flVector2[3], flVector3[3], flVector4[3],
		flVector5[3], flVector6[3], flVector7[3], flVector8[3], flVector9, flFactor1 = 0.2, flFactor2 = 0.5, flBase = 1500.0;

	flFront[0] = flFront[1] = flFront[2] = 0.0;

	if (bVisible)
	{
		flBase = 80.0;

		float flFront2 = flGetDistance(flPos, flAngles, 0.0, 0.0, flFront, rock, 3),
			flDown2 = flGetDistance(flPos, flAngles, 90.0, 0.0, flDown, rock, 3),
			flUp2 = flGetDistance(flPos, flAngles, -90.0, 0.0, flUp, rock, 3),
			flLeft2 = flGetDistance(flPos, flAngles, 0.0, 90.0, flLeft, rock, 3),
			flRight2 = flGetDistance(flPos, flAngles, 0.0, -90.0, flRight, rock, 3),
			flDistance2 = flGetDistance(flPos, flAngles, 30.0, 0.0, flVector1, rock, 3),
			flDistance3 = flGetDistance(flPos, flAngles, 30.0, 45.0, flVector2, rock, 3),
			flDistance4 = flGetDistance(flPos, flAngles, 0.0, 45.0, flVector3, rock, 3),
			flDistance5 = flGetDistance(flPos, flAngles, -30.0, 45.0, flVector4, rock, 3),
			flDistance6 = flGetDistance(flPos, flAngles, -30.0, 0.0, flVector5, rock, 3),
			flDistance7 = flGetDistance(flPos, flAngles, -30.0, -45.0, flVector6, rock, 3),
			flDistance8 = flGetDistance(flPos, flAngles, 0.0, -45.0, flVector7, rock, 3),
			flDistance9 = flGetDistance(flPos, flAngles, 30.0, -45.0, flVector8, rock, 3);

		NormalizeVector(flFront, flFront);
		NormalizeVector(flUp, flUp);
		NormalizeVector(flDown, flDown);
		NormalizeVector(flLeft, flLeft);
		NormalizeVector(flRight, flRight);
		NormalizeVector(flVector, flVector);
		NormalizeVector(flVector1, flVector1);
		NormalizeVector(flVector2, flVector2);
		NormalizeVector(flVector3, flVector3);
		NormalizeVector(flVector4, flVector4);
		NormalizeVector(flVector5, flVector5);
		NormalizeVector(flVector6, flVector6);
		NormalizeVector(flVector7, flVector7);
		NormalizeVector(flVector8, flVector8);

		if (flFront2 > flBase)
		{
			flFront2 = flBase;
		}

		if (flUp2 > flBase)
		{
			flUp2 = flBase;
		}

		if (flDown2 > flBase)
		{
			flDown2 = flBase;
		}

		if (flLeft2 > flBase)
		{
			flLeft2 = flBase;
		}

		if (flRight2 > flBase)
		{
			flRight2 = flBase;
		}

		if (flDistance2 > flBase)
		{
			flDistance2 = flBase;
		}

		if (flDistance3 > flBase)
		{
			flDistance3 = flBase;
		}

		if (flDistance4 > flBase)
		{
			flDistance4 = flBase;
		}

		if (flDistance5 > flBase)
		{
			flDistance5 = flBase;
		}

		if (flDistance6 > flBase)
		{
			flDistance6 = flBase;
		}

		if (flDistance7 > flBase)
		{
			flDistance7 = flBase;
		}

		if (flDistance8 > flBase)
		{
			flDistance8 = flBase;
		}

		if (flDistance9 > flBase)
		{
			flDistance9 = flBase;
		}

		flVector9 =- 1.0 * flFactor1 * (flBase - flFront2) / flBase;
		ScaleVector(flFront, flVector9);

		flVector9 =- 1.0 * flFactor1 * (flBase - flUp2) / flBase;
		ScaleVector(flUp, flVector9);

		flVector9 =- 1.0 * flFactor1 * (flBase - flDown2) / flBase;
		ScaleVector(flDown, flVector9);

		flVector9 =- 1.0 * flFactor1 * (flBase - flLeft2) / flBase;
		ScaleVector(flLeft, flVector9);

		flVector9 =- 1.0 * flFactor1 * (flBase - flRight2) / flBase;
		ScaleVector(flRight, flVector9);

		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance2) / flDistance2;
		ScaleVector(flVector1, flVector9);

		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance3) / flDistance3;
		ScaleVector(flVector2, flVector9);

		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance4) / flDistance4;
		ScaleVector(flVector3, flVector9);

		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance5) / flDistance5;
		ScaleVector(flVector4, flVector9);

		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance6) / flDistance6;
		ScaleVector(flVector5, flVector9);

		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance7) / flDistance7;
		ScaleVector(flVector6, flVector9);

		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance8) / flDistance8;
		ScaleVector(flVector7, flVector9);

		flVector9 =- 1.0 * flFactor1 * (flBase - flDistance9) / flDistance9;
		ScaleVector(flVector8, flVector9);

		if (flDistance >= 500.0)
		{
			flDistance = 500.0;
		}

		flVector9 = 1.0 * flFactor2 * (1000.0 - flDistance) / 500.0;
		ScaleVector(flVector, flVector9);

		AddVectors(flFront, flUp, flFront);
		AddVectors(flFront, flDown, flFront);
		AddVectors(flFront, flLeft, flFront);
		AddVectors(flFront, flRight, flFront);
		AddVectors(flFront, flVector1, flFront);
		AddVectors(flFront, flVector2, flFront);
		AddVectors(flFront, flVector3, flFront);
		AddVectors(flFront, flVector4, flFront);
		AddVectors(flFront, flVector5, flFront);
		AddVectors(flFront, flVector6, flFront);
		AddVectors(flFront, flVector7, flFront);
		AddVectors(flFront, flVector8, flFront);
		AddVectors(flFront, flVector, flFront);

		NormalizeVector(flFront, flFront);
	}

	float flAngles2 = flGetAngle(flFront, flVelocity), flVelocity3[3];
	ScaleVector(flFront, flAngles2);
	AddVectors(flVelocity, flFront, flVelocity3);
	NormalizeVector(flVelocity3, flVelocity3);
	ScaleVector(flVelocity3, flTrackSpeed);

	SetEntityGravity(rock, 0.01);
	TeleportEntity(rock, NULL_VECTOR, NULL_VECTOR, flVelocity3);

	char sSet[2][16], sTankColors[28], sGlow[3][4];
	sTankColors = !g_bTankConfig[ST_TankType(iTank)] ? g_sTankColors[ST_TankType(iTank)] : g_sTankColors2[ST_TankType(iTank)];
	TrimString(sTankColors);
	ExplodeString(sTankColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));

	ExplodeString(sSet[1], ",", sGlow, sizeof(sGlow), sizeof(sGlow[]));

	TrimString(sGlow[0]);
	int iRed = (sGlow[0][0] != '\0') ? StringToInt(sGlow[0]) : 255;
	iRed = iClamp(iRed, 0, 255);

	TrimString(sGlow[1]);
	int iGreen = (sGlow[1][0] != '\0') ? StringToInt(sGlow[1]) : 255;
	iGreen = iClamp(iGreen, 0, 255);

	TrimString(sGlow[2]);
	int iBlue = (sGlow[2][0] != '\0') ? StringToInt(sGlow[2]) : 255;
	iBlue = iClamp(iBlue, 0, 255);

	int iGlowOutline = !g_bTankConfig[ST_TankType(iTank)] ? g_iGlowOutline[ST_TankType(iTank)] : g_iGlowOutline2[ST_TankType(iTank)];
	if (iGlowOutline == 1 && bIsValidGame())
	{
		SetEntProp(rock, Prop_Send, "m_iGlowType", 3);
		SetEntProp(rock, Prop_Send, "m_nGlowRange", 0);
		SetEntProp(rock, Prop_Send, "m_glowColorOverride", iGetRGBColor(iRed, iGreen, iBlue));
	}
}

static int iTrackAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iTrackAbility[ST_TankType(tank)] : g_iTrackAbility2[ST_TankType(tank)];
}

public Action tTimerTrack(Handle timer, DataPack pack)
{
	pack.Reset();

	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		return Plugin_Stop;
	}

	if (iTrackAbility(iTank) == 0)
	{
		return Plugin_Stop;
	}

	SDKUnhook(iRock, SDKHook_Think, Think);
	SDKHook(iRock, SDKHook_Think, Think);

	return Plugin_Continue;
}