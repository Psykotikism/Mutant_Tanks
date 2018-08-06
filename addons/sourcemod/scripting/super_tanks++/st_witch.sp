// Super Tanks++: Witch Ability
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = "[ST++] Witch Ability",
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bLateLoad;
bool g_bTankConfig[ST_MAXTYPES + 1];
int g_iWitchAbility[ST_MAXTYPES + 1];
int g_iWitchAbility2[ST_MAXTYPES + 1];
int g_iWitchAmount[ST_MAXTYPES + 1];
int g_iWitchAmount2[ST_MAXTYPES + 1];
int g_iWitchDamage[ST_MAXTYPES + 1];
int g_iWitchDamage2[ST_MAXTYPES + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "[ST++] Witch Ability only supports Left 4 Dead 1 & 2.");
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
	if (g_bLateLoad)
	{
		vLateLoad(true);
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
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
		if (bIsWitch(attacker) && bIsSurvivor(victim))
		{
			int iOwner;
			if (HasEntProp(attacker, Prop_Send, "m_hOwnerEntity"))
			{
				iOwner = GetEntPropEnt(attacker, Prop_Send, "m_hOwnerEntity");
			}
			if (ST_TankAllowed(iOwner))
			{
				int iWitchDamage = !g_bTankConfig[ST_TankType(iOwner)] ? g_iWitchDamage[ST_TankType(iOwner)] : g_iWitchDamage2[ST_TankType(iOwner)];
				damage = float(iWitchDamage);
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
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
			main ? (g_iWitchAbility[iIndex] = kvSuperTanks.GetNum("Witch Ability/Ability Enabled", 0)) : (g_iWitchAbility2[iIndex] = kvSuperTanks.GetNum("Witch Ability/Ability Enabled", g_iWitchAbility[iIndex]));
			main ? (g_iWitchAbility[iIndex] = iSetCellLimit(g_iWitchAbility[iIndex], 0, 1)) : (g_iWitchAbility2[iIndex] = iSetCellLimit(g_iWitchAbility2[iIndex], 0, 1));
			main ? (g_iWitchAmount[iIndex] = kvSuperTanks.GetNum("Witch Ability/Witch Amount", 3)) : (g_iWitchAmount2[iIndex] = kvSuperTanks.GetNum("Witch Ability/Witch Amount", g_iWitchAmount[iIndex]));
			main ? (g_iWitchAmount[iIndex] = iSetCellLimit(g_iWitchAmount[iIndex], 1, 25)) : (g_iWitchAmount2[iIndex] = iSetCellLimit(g_iWitchAmount2[iIndex], 1, 25));
			main ? (g_iWitchDamage[iIndex] = kvSuperTanks.GetNum("Witch Ability/Witch Minion Damage", 5)) : (g_iWitchDamage2[iIndex] = kvSuperTanks.GetNum("Witch Ability/Witch Minion Damage", g_iWitchDamage[iIndex]));
			main ? (g_iWitchDamage[iIndex] = iSetCellLimit(g_iWitchDamage[iIndex], 1, 9999999999)) : (g_iWitchDamage2[iIndex] = iSetCellLimit(g_iWitchDamage2[iIndex], 1, 9999999999));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

public void ST_Ability(int client)
{
	int iWitchAbility = !g_bTankConfig[ST_TankType(client)] ? g_iWitchAbility[ST_TankType(client)] : g_iWitchAbility2[ST_TankType(client)];
	if (iWitchAbility == 1 && ST_TankAllowed(client) && IsPlayerAlive(client))
	{
		int iWitchCount;
		int iInfected = -1;
		while ((iInfected = FindEntityByClassname(iInfected, "infected")) != INVALID_ENT_REFERENCE)
		{
			int iWitchAmount = !g_bTankConfig[ST_TankType(client)] ? g_iWitchAmount[ST_TankType(client)] : g_iWitchAmount2[ST_TankType(client)];
			if (iWitchCount < 4 && iGetWitchCount() < iWitchAmount)
			{
				float flTankPos[3];
				float flInfectedPos[3];
				float flInfectedAng[3];
				GetClientAbsOrigin(client, flTankPos);
				GetEntPropVector(iInfected, Prop_Send, "m_vecOrigin", flInfectedPos);
				GetEntPropVector(iInfected, Prop_Send, "m_angRotation", flInfectedAng);
				float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
				if (flDistance <= 100.0)
				{
					AcceptEntityInput(iInfected, "Kill");
					int iWitch = CreateEntityByName("witch");
					if (bIsValidEntity(iWitch))
					{
						return;
					}
					TeleportEntity(iWitch, flInfectedPos, flInfectedAng, NULL_VECTOR);
					DispatchSpawn(iWitch);
					ActivateEntity(iWitch);
					SetEntProp(iWitch, Prop_Send, "m_hOwnerEntity", client);
					iWitchCount++;
				}
			}
		}
	}
}