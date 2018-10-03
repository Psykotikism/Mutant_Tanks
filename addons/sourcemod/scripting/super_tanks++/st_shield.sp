// Super Tanks++: Shield Ability
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_SHIELD "models/props_unique/airport/atlas_break_ball.mdl"

public Plugin myinfo =
{
	name = "[ST++] Shield Ability",
	author = ST_AUTHOR,
	description = "The Super Tank protects itself with a shield and throws propane tanks.",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bCloneInstalled, g_bLateLoad, g_bShield[MAXPLAYERS + 1], g_bShield2[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
char g_sShieldColor[ST_MAXTYPES + 1][12], g_sShieldColor2[ST_MAXTYPES + 1][12];
ConVar g_cvSTTankThrowForce;
float g_flShieldDelay[ST_MAXTYPES + 1], g_flShieldDelay2[ST_MAXTYPES + 1];
int g_iShieldAbility[ST_MAXTYPES + 1], g_iShieldAbility2[ST_MAXTYPES + 1], g_iShieldMessage[ST_MAXTYPES + 1], g_iShieldMessage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "[ST++] Shield Ability only supports Left 4 Dead 1 & 2.");
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
	g_cvSTTankThrowForce = FindConVar("z_tank_throw_force");
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
	PrecacheModel(MODEL_PROPANETANK, true);
	PrecacheModel(MODEL_SHIELD, true);
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_bShield[client] = false;
	g_bShield2[client] = false;
}

public void OnMapEnd()
{
	vReset();
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ST_PluginEnabled() && damage > 0.0)
	{
		if (ST_TankAllowed(victim) && ST_CloneAllowed(victim, g_bCloneInstalled) && IsPlayerAlive(victim) && bIsSurvivor(attacker))
		{
			if (g_bShield2[victim])
			{
				if (damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA)
				{
					vShield(victim, false);
				}
				else
				{
					damage = 0.0;
					return Plugin_Handled;
				}
			}
		}
	}
	return Plugin_Continue;
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
			main ? (g_iShieldAbility[iIndex] = kvSuperTanks.GetNum("Shield Ability/Ability Enabled", 0)) : (g_iShieldAbility2[iIndex] = kvSuperTanks.GetNum("Shield Ability/Ability Enabled", g_iShieldAbility[iIndex]));
			main ? (g_iShieldAbility[iIndex] = iClamp(g_iShieldAbility[iIndex], 0, 1)) : (g_iShieldAbility2[iIndex] = iClamp(g_iShieldAbility2[iIndex], 0, 1));
			main ? (g_iShieldMessage[iIndex] = kvSuperTanks.GetNum("Shield Ability/Ability Message", 0)) : (g_iShieldMessage2[iIndex] = kvSuperTanks.GetNum("Shield Ability/Ability Message", g_iShieldMessage[iIndex]));
			main ? (g_iShieldMessage[iIndex] = iClamp(g_iShieldMessage[iIndex], 0, 1)) : (g_iShieldMessage2[iIndex] = iClamp(g_iShieldMessage2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("Shield Ability/Shield Color", g_sShieldColor[iIndex], sizeof(g_sShieldColor[]), "255,255,255")) : (kvSuperTanks.GetString("Shield Ability/Shield Color", g_sShieldColor2[iIndex], sizeof(g_sShieldColor2[]), g_sShieldColor[iIndex]));
			main ? (g_flShieldDelay[iIndex] = kvSuperTanks.GetFloat("Shield Ability/Shield Delay", 5.0)) : (g_flShieldDelay2[iIndex] = kvSuperTanks.GetFloat("Shield Ability/Shield Delay", g_flShieldDelay[iIndex]));
			main ? (g_flShieldDelay[iIndex] = flClamp(g_flShieldDelay[iIndex], 0.1, 9999999999.0)) : (g_flShieldDelay2[iIndex] = flClamp(g_flShieldDelay2[iIndex], 0.1, 9999999999.0));
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
			vRemoveShield(iPlayer);
		}
	}
	vReset();
}

public void ST_Event(Event event, const char[] name)
{
	if (StrEqual(name, "player_death"))
	{
		int iTankId = event.GetInt("userid"), iTank = GetClientOfUserId(iTankId);
		if (iShieldAbility(iTank) == 1 && ST_TankAllowed(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			vRemoveShield(iTank);
		}
	}
}

public void ST_Ability(int tank)
{
	if (iShieldAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank) && !g_bShield[tank])
	{
		vShield(tank, true);
	}
}

public void ST_BossStage(int tank)
{
	if (iShieldAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled))
	{
		vRemoveShield(tank);
	}
}

public void ST_RockThrow(int tank, int rock)
{
	if (iShieldAbility(tank) == 1 && ST_TankAllowed(tank) && ST_CloneAllowed(tank, g_bCloneInstalled) && IsPlayerAlive(tank))
	{
		DataPack dpShieldThrow = new DataPack();
		CreateDataTimer(0.1, tTimerShieldThrow, dpShieldThrow, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpShieldThrow.WriteCell(EntIndexToEntRef(rock)), dpShieldThrow.WriteCell(GetClientUserId(tank));
	}
}

stock void vRemoveShield(int tank)
{
	int iShield = -1;
	while ((iShield = FindEntityByClassname(iShield, "prop_dynamic")) != INVALID_ENT_REFERENCE)
	{
		char sModel[128];
		GetEntPropString(iShield, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		if (StrEqual(sModel, MODEL_SHIELD, false))
		{
			int iOwner = GetEntPropEnt(iShield, Prop_Send, "m_hOwnerEntity");
			if (iOwner == tank)
			{
				RemoveEntity(iShield);
			}
		}
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_bShield[iPlayer] = false;
			g_bShield2[iPlayer] = false;
		}
	}
}

stock void vShield(int tank, bool shield)
{
	if (shield)
	{
		char sSet[3][4], sShieldColor[12];
		sShieldColor = !g_bTankConfig[ST_TankType(tank)] ? g_sShieldColor[ST_TankType(tank)] : g_sShieldColor2[ST_TankType(tank)];
		TrimString(sShieldColor);
		ExplodeString(sShieldColor, ",", sSet, sizeof(sSet), sizeof(sSet[]));
		TrimString(sSet[0]);
		int iRed = (!StrEqual(sSet[0], "")) ? StringToInt(sSet[0]) : 255;
		iRed = iClamp(iRed, 0, 255);
		TrimString(sSet[1]);
		int iGreen = (!StrEqual(sSet[1], "")) ? StringToInt(sSet[1]) : 255;
		iGreen = iClamp(iGreen, 0, 255);
		TrimString(sSet[2]);
		int iBlue = (!StrEqual(sSet[2], "")) ? StringToInt(sSet[2]) : 255;
		iBlue = iClamp(iBlue, 0, 255);
		float flOrigin[3];
		GetClientAbsOrigin(tank, flOrigin);
		flOrigin[2] -= 120.0;
		int iShield = CreateEntityByName("prop_dynamic");
		if (bIsValidEntity(iShield))
		{
			SetEntityModel(iShield, MODEL_SHIELD);
			DispatchKeyValueVector(iShield, "origin", flOrigin);
			DispatchSpawn(iShield);
			vSetEntityParent(iShield, tank);
			SetEntityRenderMode(iShield, RENDER_TRANSTEXTURE);
			SetEntityRenderColor(iShield, iRed, iGreen, iBlue, 50);
			SetEntProp(iShield, Prop_Send, "m_CollisionGroup", 1);
			SetEntPropEnt(iShield, Prop_Send, "m_hOwnerEntity", tank);
		}
		g_bShield[tank] = true;
		g_bShield2[tank] = true;
		if (iShieldMessage(tank) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Shield", sTankName);
		}
	}
	else
	{
		vRemoveShield(tank);
		float flShieldDelay = !g_bTankConfig[ST_TankType(tank)] ? g_flShieldDelay[ST_TankType(tank)] : g_flShieldDelay2[ST_TankType(tank)];
		CreateTimer(flShieldDelay, tTimerShield, GetClientUserId(tank), TIMER_FLAG_NO_MAPCHANGE);
		g_bShield2[tank] = false;
		if (iShieldMessage(tank) == 1)
		{
			char sTankName[MAX_NAME_LENGTH + 1];
			ST_TankName(tank, sTankName);
			PrintToChatAll("%s %t", ST_PREFIX2, "Shield2", sTankName);
		}
	}
}

stock int iShieldAbility(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iShieldAbility[ST_TankType(tank)] : g_iShieldAbility2[ST_TankType(tank)];
}

stock int iShieldMessage(int tank)
{
	return !g_bTankConfig[ST_TankType(tank)] ? g_iShieldMessage[ST_TankType(tank)] : g_iShieldMessage2[ST_TankType(tank)];
}

public Action tTimerShield(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || g_bShield2[iTank] || (!g_bShield[iTank] && !g_bShield2[iTank]))
	{
		return Plugin_Stop;
	}
	if (iShieldAbility(iTank) == 0)
	{
		g_bShield[iTank] = false;
		g_bShield2[iTank] = false;
		return Plugin_Stop;
	}
	vShield(iTank, true);
	return Plugin_Continue;
}

public Action tTimerShieldThrow(Handle timer, DataPack pack)
{
	pack.Reset();
	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!ST_TankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled) || (!g_bShield[iTank] && !g_bShield2[iTank]))
	{
		return Plugin_Stop;
	}
	if (iShieldAbility(iTank) == 0)
	{
		g_bShield[iTank] = false;
		g_bShield2[iTank] = false;
		return Plugin_Stop;
	}
	float flVelocity[3];
	GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);
	float flVector = GetVectorLength(flVelocity);
	if (flVector > 500.0)
	{
		int iPropane = CreateEntityByName("prop_physics");
		if (bIsValidEntity(iPropane))
		{
			SetEntityModel(iPropane, MODEL_PROPANETANK);
			float flPos[3];
			GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
			RemoveEntity(iRock);
			NormalizeVector(flVelocity, flVelocity);
			ScaleVector(flVelocity, g_cvSTTankThrowForce.FloatValue * 1.4);
			DispatchSpawn(iPropane);
			TeleportEntity(iPropane, flPos, NULL_VECTOR, flVelocity);
		}
		return Plugin_Stop;
	}
	return Plugin_Continue;
}