// Super Tanks++: Smite Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

#define SPRITE_GLOW "sprites/glow.vmt"
#define SOUND_EXPLOSION "ambient/explosions/explode_2.wav"

public Plugin myinfo =
{
	name = "[ST++] Smite Ability",
	author = ST_AUTHOR,
	description = "The Super Tank smites survivors.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bTankConfig[ST_MAXTYPES + 1];
char g_sSmiteEffect[ST_MAXTYPES + 1][4], g_sSmiteEffect2[ST_MAXTYPES + 1][4];
float g_flSmiteRange[ST_MAXTYPES + 1], g_flSmiteRange2[ST_MAXTYPES + 1];
int g_iSmiteAbility[ST_MAXTYPES + 1], g_iSmiteAbility2[ST_MAXTYPES + 1], g_iSmiteChance[ST_MAXTYPES + 1], g_iSmiteChance2[ST_MAXTYPES + 1], g_iSmiteHit[ST_MAXTYPES + 1], g_iSmiteHit2[ST_MAXTYPES + 1], g_iSmiteHitMode[ST_MAXTYPES + 1], g_iSmiteHitMode2[ST_MAXTYPES + 1], g_iSmiteMessage[ST_MAXTYPES + 1], g_iSmiteMessage2[ST_MAXTYPES + 1], g_iSmiteRangeChance[ST_MAXTYPES + 1], g_iSmiteRangeChance2[ST_MAXTYPES + 1], g_iSmiteSprite = -1;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Smite Ability only supports Left 4 Dead 1 & 2.");
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
	g_iSmiteSprite = PrecacheModel(SPRITE_GLOW, true);
	PrecacheSound(SOUND_EXPLOSION, true);
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
		if ((iSmiteHitMode(attacker) == 0 || iSmiteHitMode(attacker) == 1) && ST_TankAllowed(attacker) && ST_CloneAllowed(attacker, g_bCloneInstalled) && IsPlayerAlive(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw") || StrEqual(sClassname, "tank_rock"))
			{
				vSmiteHit(victim, attacker, iSmiteChance(attacker), iSmiteHit(attacker), 1, "1");
			}
		}
		else if ((iSmiteHitMode(victim) == 0 || iSmiteHitMode(victim) == 2) && ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (StrEqual(sClassname, "weapon_melee"))
			{
				vSmiteHit(attacker, victim, iSmiteChance(victim), iSmiteHit(victim), 1, "2");
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
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (g_iSmiteAbility[iIndex] = kvSuperTanks.GetNum("Smite Ability/Ability Enabled", 0)) : (g_iSmiteAbility2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Ability Enabled", g_iSmiteAbility[iIndex]));
			main ? (g_iSmiteAbility[iIndex] = iClamp(g_iSmiteAbility[iIndex], 0, 1)) : (g_iSmiteAbility2[iIndex] = iClamp(g_iSmiteAbility2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("Smite Ability/Ability Effect", g_sSmiteEffect[iIndex], sizeof(g_sSmiteEffect[]), "123")) : (kvSuperTanks.GetString("Smite Ability/Ability Effect", g_sSmiteEffect2[iIndex], sizeof(g_sSmiteEffect2[]), g_sSmiteEffect[iIndex]));
			main ? (g_iSmiteMessage[iIndex] = kvSuperTanks.GetNum("Smite Ability/Ability Message", 0)) : (g_iSmiteMessage2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Ability Message", g_iSmiteMessage[iIndex]));
			main ? (g_iSmiteMessage[iIndex] = iClamp(g_iSmiteMessage[iIndex], 0, 3)) : (g_iSmiteMessage2[iIndex] = iClamp(g_iSmiteMessage2[iIndex], 0, 3));
			main ? (g_iSmiteChance[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Chance", 4)) : (g_iSmiteChance2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Chance", g_iSmiteChance[iIndex]));
			main ? (g_iSmiteChance[iIndex] = iClamp(g_iSmiteChance[iIndex], 1, 9999999999)) : (g_iSmiteChance2[iIndex] = iClamp(g_iSmiteChance2[iIndex], 1, 9999999999));
			main ? (g_iSmiteHit[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Hit", 0)) : (g_iSmiteHit2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Hit", g_iSmiteHit[iIndex]));
			main ? (g_iSmiteHit[iIndex] = iClamp(g_iSmiteHit[iIndex], 0, 1)) : (g_iSmiteHit2[iIndex] = iClamp(g_iSmiteHit2[iIndex], 0, 1));
			main ? (g_iSmiteHitMode[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Hit Mode", 0)) : (g_iSmiteHitMode2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Hit Mode", g_iSmiteHitMode[iIndex]));
			main ? (g_iSmiteHitMode[iIndex] = iClamp(g_iSmiteHitMode[iIndex], 0, 2)) : (g_iSmiteHitMode2[iIndex] = iClamp(g_iSmiteHitMode2[iIndex], 0, 2));
			main ? (g_flSmiteRange[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Range", 150.0)) : (g_flSmiteRange2[iIndex] = kvSuperTanks.GetFloat("Smite Ability/Smite Range", g_flSmiteRange[iIndex]));
			main ? (g_flSmiteRange[iIndex] = flClamp(g_flSmiteRange[iIndex], 1.0, 9999999999.0)) : (g_flSmiteRange2[iIndex] = flClamp(g_flSmiteRange2[iIndex], 1.0, 9999999999.0));
			main ? (g_iSmiteRangeChance[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Range Chance", 16)) : (g_iSmiteRangeChance2[iIndex] = kvSuperTanks.GetNum("Smite Ability/Smite Range Chance", g_iSmiteRangeChance[iIndex]));
			main ? (g_iSmiteRangeChance[iIndex] = iClamp(g_iSmiteRangeChance[iIndex], 1, 9999999999)) : (g_iSmiteRangeChance2[iIndex] = iClamp(g_iSmiteRangeChance2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iSurvivorId = event.GetInt("userid"), iSurvivor = GetClientOfUserId(iSurvivorId),
			iTankId = event.GetInt("attacker"), iTank = GetClientOfUserId(iTankId);
		if (ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && bIsSurvivor(iSurvivor))
		{
			int iCorpse = -1;
			while ((iCorpse = FindEntityByClassname(iCorpse, "survivor_death_model")) != INVALID_ENT_REFERENCE)
			{
				int iOwner = GetEntPropEnt(iCorpse, Prop_Send, "m_hOwnerEntity");
				if (iSurvivor == iOwner)
				{
					RemoveEntity(iCorpse);
				}
			}
		}
	}
}

public void ST_Ability(int client)
{
	if (ST_TankAllowed(client) && ST_CloneAllowed(client, g_bCloneInstalled) && IsPlayerAlive(client))
	{
		int iSmiteRangeChance = !g_bTankConfig[ST_TankType(client)] ? g_iSmiteChance[ST_TankType(client)] : g_iSmiteChance2[ST_TankType(client)];
		float flSmiteRange = !g_bTankConfig[ST_TankType(client)] ? g_flSmiteRange[ST_TankType(client)] : g_flSmiteRange2[ST_TankType(client)],
			flTankPos[3];
		GetClientAbsOrigin(client, flTankPos);
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsSurvivor(iSurvivor))
			{
				float flSurvivorPos[3];
				GetClientAbsOrigin(iSurvivor, flSurvivorPos);
				float flDistance = GetVectorDistance(flTankPos, flSurvivorPos);
				if (flDistance <= flSmiteRange)
				{
					vSmiteHit(iSurvivor, client, iSmiteRangeChance, iSmiteAbility(client), 2, "3");
				}
			}
		}
	}
}

stock void vSmiteHit(int client, int owner, int chance, int enabled, int message, const char[] mode)
{
	if (enabled == 1 && GetRandomInt(1, chance) == 1 && bIsSurvivor(client))
	{
		float flPosition[3], flStartPosition[3], flDirection[3] = {0.0, 0.0, 0.0};
		int iSmiteMessage = !g_bTankConfig[ST_TankType(owner)] ? g_iSmiteMessage[ST_TankType(owner)] : g_iSmiteMessage2[ST_TankType(owner)];
		GetClientAbsOrigin(client, flPosition);
		flPosition[2] -= 26;
		flStartPosition[0] = flPosition[0] + GetRandomInt(-500, 500), flStartPosition[1] = flPosition[1] + GetRandomInt(-500, 500), flStartPosition[2] = flPosition[2] + 800;
		int iColor[4] = {255, 255, 255, 255};
		TE_SetupBeamPoints(flStartPosition, flPosition, g_iSmiteSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, iColor, 3);
		TE_SendToAll();
		TE_SetupSparks(flPosition, flDirection, 5000, 1000);
		TE_SendToAll();
		TE_SetupEnergySplash(flPosition, flDirection, false);
		TE_SendToAll();
		EmitAmbientSound(SOUND_EXPLOSION, flStartPosition, client, SNDLEVEL_RAIDSIREN);
		ForcePlayerSuicide(client);
		char sSmiteEffect[4];
		sSmiteEffect = !g_bTankConfig[ST_TankType(owner)] ? g_sSmiteEffect[ST_TankType(owner)] : g_sSmiteEffect2[ST_TankType(owner)];
		vEffect(client, owner, sSmiteEffect, mode);
		if (iSmiteMessage == message || iSmiteMessage == 3)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(owner, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Smite", sTankName, client);
		}
	}
}

stock int iSmiteAbility(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iSmiteAbility[ST_TankType(client)] : g_iSmiteAbility2[ST_TankType(client)];
}

stock int iSmiteChance(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iSmiteChance[ST_TankType(client)] : g_iSmiteChance2[ST_TankType(client)];
}

stock int iSmiteHit(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iSmiteHit[ST_TankType(client)] : g_iSmiteHit2[ST_TankType(client)];
}

stock int iSmiteHitMode(int client)
{
	return !g_bTankConfig[ST_TankType(client)] ? g_iSmiteHitMode[ST_TankType(client)] : g_iSmiteHitMode2[ST_TankType(client)];
}