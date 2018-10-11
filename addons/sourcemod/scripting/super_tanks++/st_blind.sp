// Super Tanks++: Blind Ability
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

char g_sBlindEffect[ST_MAXTYPES + 1][4], g_sBlindEffect2[ST_MAXTYPES + 1][4];

float g_flBlindDuration[ST_MAXTYPES + 1], g_flBlindDuration2[ST_MAXTYPES + 1], g_flBlindRange[ST_MAXTYPES + 1], g_flBlindRange2[ST_MAXTYPES + 1];

int g_iBlindAbility[ST_MAXTYPES + 1], g_iBlindAbility2[ST_MAXTYPES + 1], g_iBlindChance[ST_MAXTYPES + 1], g_iBlindChance2[ST_MAXTYPES + 1], g_iBlindHit[ST_MAXTYPES + 1], g_iBlindHit2[ST_MAXTYPES + 1], g_iBlindHitMode[ST_MAXTYPES + 1], g_iBlindHitMode2[ST_MAXTYPES + 1], g_iBlindIntensity[ST_MAXTYPES + 1], g_iBlindIntensity2[ST_MAXTYPES + 1], g_iBlindMessage[ST_MAXTYPES + 1], g_iBlindMessage2[ST_MAXTYPES + 1], g_iBlindRangeChance[ST_MAXTYPES + 1], g_iBlindRangeChance2[ST_MAXTYPES + 1];

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
				vBlindHit(victim, attacker, iBlindChance(attacker), iBlindHit(attacker), 1, "1");
			}
		}
		else if ((iBlindHitMode(victim) == 0 || iBlindHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsHumanSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vBlindHit(attacker, victim, iBlindChance(victim), iBlindHit(victim), 1, "2");
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

				g_iBlindAbility[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Enabled", 0);
				g_iBlindAbility[iIndex] = iClamp(g_iBlindAbility[iIndex], 0, 1);
				kvSuperTanks.GetString("Blind Ability/Ability Effect", g_sBlindEffect[iIndex], sizeof(g_sBlindEffect[]), "123");
				g_iBlindMessage[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Message", 0);
				g_iBlindMessage[iIndex] = iClamp(g_iBlindMessage[iIndex], 0, 3);
				g_iBlindChance[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Chance", 4);
				g_iBlindChance[iIndex] = iClamp(g_iBlindChance[iIndex], 1, 9999999999);
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
				g_iBlindRangeChance[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Range Chance", 16);
				g_iBlindRangeChance[iIndex] = iClamp(g_iBlindRangeChance[iIndex], 1, 9999999999);
			}
			else
			{
				g_bTankConfig[iIndex] = true;

				g_iBlindAbility2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Enabled", g_iBlindAbility[iIndex]);
				g_iBlindAbility2[iIndex] = iClamp(g_iBlindAbility2[iIndex], 0, 1);
				kvSuperTanks.GetString("Blind Ability/Ability Effect", g_sBlindEffect2[iIndex], sizeof(g_sBlindEffect2[]), g_sBlindEffect[iIndex]);
				g_iBlindMessage2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Ability Message", g_iBlindMessage[iIndex]);
				g_iBlindMessage2[iIndex] = iClamp(g_iBlindMessage2[iIndex], 0, 3);
				g_iBlindChance2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Chance", g_iBlindChance[iIndex]);
				g_iBlindChance2[iIndex] = iClamp(g_iBlindChance2[iIndex], 1, 9999999999);
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
				g_iBlindRangeChance2[iIndex] = kvSuperTanks.GetNum("Blind Ability/Blind Range Chance", g_iBlindRangeChance[iIndex]);
				g_iBlindRangeChance2[iIndex] = iClamp(g_iBlindRangeChance2[iIndex], 1, 9999999999);
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
		int iBlindRangeChance = !g_bTankConfig[ST_TankType(tank)] ? g_iBlindChance[ST_TankType(tank)] : g_iBlindChance2[ST_TankType(tank)];

		float flBlindRange = !g_bTankConfig[ST_TankType(tank)] ? g_flBlindRange[ST_TankType(tank)] : g_flBlindRange2[ST_TankType(tank)],
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
					vBlindHit(iSurvivor, tank, iBlindRangeChance, iBlindAbility(tank), 2, "3");
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

static void vBlindHit(int survivor, int tank, int chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsHumanSurvivor(survivor) && !g_bBlind[survivor])
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
		dpStopBlindness.WriteCell(message);

		char sBlindEffect[4];
		sBlindEffect = !g_bTankConfig[ST_TankType(tank)] ? g_sBlindEffect[ST_TankType(tank)] : g_sBlindEffect2[ST_TankType(tank)];
		vEffect(survivor, tank, sBlindEffect, mode);

		if (iBlindMessage(tank) == message || iBlindMessage(tank) == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Blind", sTankName, survivor);
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
			dpStopBlindness.WriteCell(0);
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

static int iBlindAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBlindAbility[ST_TankType(tank)] : g_iBlindAbility2[ST_TankType(tank)];
}

static int iBlindChance(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBlindChance[ST_TankType(tank)] : g_iBlindChance2[ST_TankType(tank)];
}

static int iBlindHit(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBlindHit[ST_TankType(tank)] : g_iBlindHit2[ST_TankType(tank)];
}

static int iBlindHitMode(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBlindHitMode[ST_TankType(tank)] : g_iBlindHitMode2[ST_TankType(tank)];
}

static int iBlindMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iBlindMessage[ST_TankType(tank)] : g_iBlindMessage2[ST_TankType(tank)];
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

	int iTank = GetClientOfUserId(pack.ReadCell()), iBlindChat = pack.ReadCell();
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		g_bBlind[iSurvivor] = false;

		vBlind(iSurvivor, 0);

		return Plugin_Stop;
	}

	g_bBlind[iSurvivor] = false;

	vBlind(iSurvivor, 0);

	if (iBlindMessage(iTank) == iBlindChat || iBlindMessage(iTank) == 3)
	{
		PrintToChatAll("%s %t", ST_PREFIX2, "Blind2", iSurvivor);
	}

	return Plugin_Continue;
}