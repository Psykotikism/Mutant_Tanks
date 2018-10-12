// Super Tanks++: Whirl Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN

#include <super_tanks++>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "[ST++] Whirl Ability",
	author = ST_AUTHOR,
	description = "The Super Tank makes survivors whirl.",
	version = ST_VERSION,
	url = ST_URL
};

#define SPRITE_DOT "sprites/dot.vmt"

bool g_bCloneInstalled, g_bWhirl[MAXPLAYERS + 1], g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];

char g_sWhirlEffect[ST_MAXTYPES + 1][4], g_sWhirlEffect2[ST_MAXTYPES + 1][4];

float g_flWhirlChance[ST_MAXTYPES + 1], g_flWhirlChance2[ST_MAXTYPES + 1], g_flWhirlDuration[ST_MAXTYPES + 1], g_flWhirlDuration2[ST_MAXTYPES + 1], g_flWhirlRange[ST_MAXTYPES + 1], g_flWhirlRange2[ST_MAXTYPES + 1], g_flWhirlSpeed[ST_MAXTYPES + 1], g_flWhirlSpeed2[ST_MAXTYPES + 1], g_flWhirlRangeChance[ST_MAXTYPES + 1], g_flWhirlRangeChance2[ST_MAXTYPES + 1];

int g_iWhirlAbility[ST_MAXTYPES + 1], g_iWhirlAbility2[ST_MAXTYPES + 1], g_iWhirlAxis[ST_MAXTYPES + 1], g_iWhirlAxis2[ST_MAXTYPES + 1], g_iWhirlHit[ST_MAXTYPES + 1], g_iWhirlHit2[ST_MAXTYPES + 1], g_iWhirlHitMode[ST_MAXTYPES + 1], g_iWhirlHitMode2[ST_MAXTYPES + 1], g_iWhirlMessage[ST_MAXTYPES + 1], g_iWhirlMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Whirl Ability only supports Left 4 Dead 1 & 2.");

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
	PrecacheModel(SPRITE_DOT, true);

	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

	g_bWhirl[client] = false;
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

		if ((iWhirlHitMode(attacker) == 0 || iWhirlHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsHumanSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vWhirlHit(victim, attacker, flWhirlChance(attacker), iWhirlHit(attacker), 1, "1");
			}
		}
		else if ((iWhirlHitMode(victim) == 0 || iWhirlHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vWhirlHit(attacker, victim, flWhirlChance(victim), iWhirlHit(victim), 1, "2");
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
			if (main)
			{
				g_bTankConfig[iIndex] = false;

				g_iWhirlAbility[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Ability Enabled", 0);
				g_iWhirlAbility[iIndex] = iClamp(g_iWhirlAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Whirl Ability/Ability Effect", g_sWhirlEffect[iIndex], sizeof(g_sWhirlEffect[]), "123");
				g_iWhirlMessage[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Ability Message", 0);
				g_iWhirlMessage[iIndex] = iClamp(g_iWhirlMessage[iIndex], 0, 3);
				g_iWhirlAxis[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Whirl Axis", 7);
				g_iWhirlAxis[iIndex] = iClamp(g_iWhirlAxis[iIndex], 1, 7);
				g_flWhirlChance[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Chance", 33.3);
				g_flWhirlChance[iIndex] = flClamp(g_flWhirlChance[iIndex], 0.1, 100.0);
				g_flWhirlDuration[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Duration", 5.0);
				g_flWhirlDuration[iIndex] = flClamp(g_flWhirlDuration[iIndex], 0.1, 9999999999.0);
				g_iWhirlHit[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Whirl Hit", 0);
				g_iWhirlHit[iIndex] = iClamp(g_iWhirlHit[iIndex], 0, 1);
				g_iWhirlHitMode[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Whirl Hit Mode", 0);
				g_iWhirlHitMode[iIndex] = iClamp(g_iWhirlHitMode[iIndex], 0, 2);
				g_flWhirlRange[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Range", 150.0);
				g_flWhirlRange[iIndex] = flClamp(g_flWhirlRange[iIndex], 1.0, 9999999999.0);
				g_flWhirlRangeChance[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Range Chance", 15.0);
				g_flWhirlRangeChance[iIndex] = flClamp(g_flWhirlRangeChance[iIndex], 0.1, 100.0);
				g_flWhirlSpeed[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Speed", 500.0);
				g_flWhirlSpeed[iIndex] = flClamp(g_flWhirlSpeed[iIndex], 1.0, 9999999999.0);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iWhirlAbility2[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Ability Enabled", g_iWhirlAbility[iIndex]);
				g_iWhirlAbility2[iIndex] = iClamp(g_iWhirlAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Whirl Ability/Ability Effect", g_sWhirlEffect2[iIndex], sizeof(g_sWhirlEffect2[]), g_sWhirlEffect[iIndex]);
				g_iWhirlMessage2[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Ability Message", g_iWhirlMessage[iIndex]);
				g_iWhirlMessage2[iIndex] = iClamp(g_iWhirlMessage2[iIndex], 0, 3);
				g_iWhirlAxis2[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Whirl Axis", g_iWhirlAxis[iIndex]);
				g_iWhirlAxis2[iIndex] = iClamp(g_iWhirlAxis2[iIndex], 1, 7);
				g_flWhirlChance2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Chance", g_flWhirlChance[iIndex]);
				g_flWhirlChance2[iIndex] = flClamp(g_flWhirlChance2[iIndex], 0.1, 100.0);
				g_flWhirlDuration2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Duration", g_flWhirlDuration[iIndex]);
				g_flWhirlDuration2[iIndex] = flClamp(g_flWhirlDuration2[iIndex], 0.1, 9999999999.0);
				g_iWhirlHit2[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Whirl Hit", g_iWhirlHit[iIndex]);
				g_iWhirlHit2[iIndex] = iClamp(g_iWhirlHit2[iIndex], 0, 1);
				g_iWhirlHitMode2[iIndex] = kvSuperTanks.GetNum("Whirl Ability/Whirl Hit Mode", g_iWhirlHitMode[iIndex]);
				g_iWhirlHitMode2[iIndex] = iClamp(g_iWhirlHitMode2[iIndex], 0, 2);
				g_flWhirlRange2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Range", g_flWhirlRange[iIndex]);
				g_flWhirlRange2[iIndex] = flClamp(g_flWhirlRange2[iIndex], 1.0, 9999999999.0);
				g_flWhirlRangeChance2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Range Chance", g_flWhirlRangeChance[iIndex]);
				g_flWhirlRangeChance2[iIndex] = flClamp(g_flWhirlRangeChance2[iIndex], 0.1, 100.0);
				g_flWhirlSpeed2[iIndex] = kvSuperTanks.GetFloat("Whirl Ability/Whirl Speed", g_flWhirlSpeed[iIndex]);
				g_flWhirlSpeed2[iIndex] = flClamp(g_flWhirlSpeed2[iIndex], 1.0, 9999999999.0);
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
		float flWhirlRange = !g_bTankConfig[ST_TankType(tank)] ? g_flWhirlRange[ST_TankType(tank)] : g_flWhirlRange2[ST_TankType(tank)],
			flWhirlRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_flWhirlRangeChance[ST_TankType(tank)] : g_flWhirlRangeChance2[ST_TankType(tank)],
			flTankPos[3];

		GetClientAbsOrigin(tank, flTankPos);

		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);

				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flWhirlRange)
				{
					vWhirlHit(iSurvivor, tank, flWhirlRangeChance, iWhirlAbility(tank), 2, "3");
				}
			}
		}
	}
}

static void vWhirlHit(int survivor, int tank, float chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomFloat(0.1, 100.0) <= chance && bIsHumanSurvivor(survivor) && !g_bWhirl[survivor])
	{
		int iWhirl = CreateEntityByName("env_sprite");
		if (!bIsValidEntity(iWhirl))
		{
			return;
		}

		g_bWhirl[survivor] = true;

		float flEyePos[3], flAngles[3];
		GetClientEyePosition(survivor, flEyePos);
		GetClientEyeAngles(survivor, flAngles);

		SetEntityModel(iWhirl, SPRITE_DOT);
		SetEntityRenderMode(iWhirl, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iWhirl, 0, 0, 0, 0);
		DispatchSpawn(iWhirl);

		TeleportEntity(iWhirl, flEyePos, flAngles, NULL_VECTOR);
		TeleportEntity(survivor, NULL_VECTOR, flAngles, NULL_VECTOR);

		vSetEntityParent(iWhirl, survivor);
		SetClientViewEntity(survivor, iWhirl);

		int iWhirlAxis = !g_bTankConfig[ST_TankType(tank)] ? g_iWhirlAxis[ST_TankType(tank)] : g_iWhirlAxis2[ST_TankType(tank)],
			iAxis;

		switch (iWhirlAxis)
		{
			case 1: iAxis = 0;
			case 2: iAxis = 1;
			case 3: iAxis = 2;
			case 4: iAxis = GetRandomInt(0, 1);
			case 5:
			{
				int iNumberCount, iNumbers[3];
				for (int iNumber = 0; iNumber <= 2; iNumber++)
				{
					if (iNumber == 1)
					{
						continue;
					}

					iNumbers[iNumberCount + 1] = iNumber;
					iNumberCount++;
				}

				iAxis = iNumbers[GetRandomInt(0, iNumberCount)];
			}
			case 6: iAxis = GetRandomInt(1, 2);
			case 7: iAxis = GetRandomInt(0, 2);
		}

		DataPack dpWhirl;
		CreateDataTimer(0.1, tTimerWhirl, dpWhirl, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpWhirl.WriteCell(EntIndexToEntRef(iWhirl));
		dpWhirl.WriteCell(GetClientUserId(survivor));
		dpWhirl.WriteCell(GetClientUserId(tank));
		dpWhirl.WriteCell(message);
		dpWhirl.WriteCell(enabled);
		dpWhirl.WriteCell(iAxis);
		dpWhirl.WriteFloat(GetEngineTime());

		char sWhirlEffect[4];
		sWhirlEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sWhirlEffect[ST_TankType(tank)] : g_sWhirlEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sWhirlEffect, mode);

		if (iWhirlMessage(tank) == message || iWhirlMessage(tank) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Whirl", sTankName, survivor);
		}
	}
}

static void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bWhirl[iPlayer] = false;
		}
	}
}

static void vReset2(int survivor, int tank, int entity, int message)
{
	vStopWhirl(survivor, entity);

	SetClientViewEntity(survivor, survivor);

	if (iWhirlMessage(tank) == message || iWhirlMessage(tank) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Whirl2", survivor);
	}
}

static void vStopWhirl(int survivor, int entity)
{
	g_bWhirl[survivor] = false;

	RemoveEntity(entity);
}

static float flWhirlChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_flWhirlChance[ST_TankType(tank)] : g_flWhirlChance2[ST_TankType(tank)];
}

static int iWhirlAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWhirlAbility[ST_TankType(tank)] : g_iWhirlAbility2[ST_TankType(tank)];
}

static int iWhirlHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWhirlHit[ST_TankType(tank)] : g_iWhirlHit2[ST_TankType(tank)];
}

static int iWhirlHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWhirlHitMode[ST_TankType(tank)] : g_iWhirlHitMode2[ST_TankType(tank)];
}

static int iWhirlMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iWhirlMessage[ST_TankType(tank)] : g_iWhirlMessage2[ST_TankType(tank)];
}

public Action tTimerWhirl(Handle timer, DataPack pack)
{
	pack.Reset();

	int iWhirl = EntRefToEntIndex(pack.ReadCell()), iSurvivor = GetClientOfUserId(pack.ReadCell());
	if (iWhirl == INVALID_ENT_REFERENCE || !bIsValidEntity(iWhirl))
	{
		g_bWhirl[iSurvivor] = false;

		SetClientViewEntity(iSurvivor, iSurvivor);

		return Plugin_Stop;
	}

	if (!bIsSurvivor(iSurvivor) || !g_bWhirl[iSurvivor])
	{
		vStopWhirl(iSurvivor, iWhirl);

		return Plugin_Stop;
	}

	int iTank = GetClientOfUserId(pack.ReadCell()), iWhirlChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !ST_TypeEnabled(ST_TankType(iTank)) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vReset2(iSurvivor, iTank, iWhirl, iWhirlChat);

		return Plugin_Stop;
	}

	int iWhirlEnabled = pack.ReadCell(), iWhirlAxis = pack.ReadCell();
	float flTime = pack.ReadFloat(),
		flWhirlDuration = !g_bTankConfig[ST_TankType(iTank)] ? g_flWhirlDuration[ST_TankType(iTank)] : g_flWhirlDuration2[ST_TankType(iTank)];

	if (iWhirlEnabled == 0 || (flTime + flWhirlDuration) < GetEngineTime())
	{
		vReset2(iSurvivor, iTank, iWhirl, iWhirlChat);

		return Plugin_Stop;
	}

	float flWhirlSpeed = !g_bTankConfig[ST_TankType(iTank)] ? g_flWhirlSpeed[ST_TankType(iTank)] : g_flWhirlSpeed2[ST_TankType(iTank)],
		flAngles[3];
	GetEntPropVector(iWhirl, Prop_Send, "m_angRotation", flAngles);

	flAngles[iWhirlAxis] += flWhirlSpeed;
	TeleportEntity(iWhirl, NULL_VECTOR, flAngles, NULL_VECTOR);

	return Plugin_Continue;
}