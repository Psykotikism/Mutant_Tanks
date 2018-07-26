// Super Tanks++
#pragma semicolon 1
#pragma newdecls required
#include <super_tanks++>

public Plugin myinfo =
{
	name = ST_NAME,
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

#define MODEL_CONCRETE "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_JETPACK "models/props_equipment/oxygentank01.mdl"
#define MODEL_TANK "models/infected/hulk.mdl"
#define MODEL_TIRES "models/props_vehicles/tire001c_car.mdl"
#define MODEL_WITCH "models/infected/witch.mdl"
#define MODEL_WITCHBRIDE "models/infected/witch_bride.mdl"
#define PARTICLE_BLOOD "boomer_explode_D"
#define PARTICLE_ELECTRICITY "electrical_arc_01_system"
#define PARTICLE_FIRE "aircraft_destroy_fastFireTrail"
#define PARTICLE_ICE "steam_manhole"
#define PARTICLE_METEOR "smoke_medium_01"
#define PARTICLE_SMOKE "smoker_smokecloud"
#define PARTICLE_SPIT "spitter_projectile"

bool g_bCmdUsed;
bool g_bGeneralConfig;
bool g_bLateLoad;
bool g_bPluginEnabled;
bool g_bTankConfig[ST_MAXTYPES + 1];
char g_sConfigCreate[6];
char g_sConfigExecute[6];
char g_sCustomName[ST_MAXTYPES + 1][MAX_NAME_LENGTH + 1];
char g_sCustomName2[ST_MAXTYPES + 1][MAX_NAME_LENGTH + 1];
char g_sDisabledGameModes[2112];
char g_sEnabledGameModes[2112];
char g_sParticleEffects[ST_MAXTYPES + 1][8];
char g_sParticleEffects2[ST_MAXTYPES + 1][8];
char g_sPropsAttached[ST_MAXTYPES + 1][7];
char g_sPropsAttached2[ST_MAXTYPES + 1][7];
char g_sPropsChance[ST_MAXTYPES + 1][12];
char g_sPropsChance2[ST_MAXTYPES + 1][12];
char g_sPropsColors[ST_MAXTYPES + 1][80];
char g_sPropsColors2[ST_MAXTYPES + 1][80];
char g_sRockEffects[ST_MAXTYPES + 1][5];
char g_sRockEffects2[ST_MAXTYPES + 1][5];
char g_sSavePath[255];
char g_sTankColors[ST_MAXTYPES + 1][28];
char g_sTankColors2[ST_MAXTYPES + 1][28];
char g_sTankWaves[12];
char g_sTankWaves2[12];
ConVar g_cvSTFindConVar[4];
float g_flRunSpeed[ST_MAXTYPES + 1];
float g_flRunSpeed2[ST_MAXTYPES + 1];
float g_flThrowInterval[ST_MAXTYPES + 1];
float g_flThrowInterval2[ST_MAXTYPES + 1];
Handle g_hAbility;
Handle g_hConfigs;
Handle g_hRockBreak;
Handle g_hRockThrow;
Handle g_hSpawn;
int g_iAnnounceArrival;
int g_iAnnounceArrival2;
int g_iAnnounceDeath;
int g_iAnnounceDeath2;
int g_iBulletImmunity[ST_MAXTYPES + 1];
int g_iBulletImmunity2[ST_MAXTYPES + 1];
int g_iConfigEnable;
int g_iCreateBackup;
int g_iCurrentMode;
int g_iDisplayHealth;
int g_iDisplayHealth2;
int g_iExplosiveImmunity[ST_MAXTYPES + 1];
int g_iExplosiveImmunity2[ST_MAXTYPES + 1];
int g_iExtraHealth[ST_MAXTYPES + 1];
int g_iExtraHealth2[ST_MAXTYPES + 1];
int g_iFileTimeOld[7];
int g_iFileTimeNew[7];
int g_iFinalesOnly;
int g_iFinalesOnly2;
int g_iFireImmunity[ST_MAXTYPES + 1];
int g_iFireImmunity2[ST_MAXTYPES + 1];
int g_iGameModeTypes;
int g_iGlowEffect[ST_MAXTYPES + 1];
int g_iGlowEffect2[ST_MAXTYPES + 1];
int g_iHumanSupport;
int g_iHumanSupport2;
int g_iMaxTypes;
int g_iMaxTypes2;
int g_iMeleeImmunity[ST_MAXTYPES + 1];
int g_iMeleeImmunity2[ST_MAXTYPES + 1];
int g_iMultiHealth;
int g_iMultiHealth2;
int g_iParticleEffect[ST_MAXTYPES + 1];
int g_iParticleEffect2[ST_MAXTYPES + 1];
int g_iPluginEnabled;
int g_iPluginEnabled2;
int g_iRockEffect[ST_MAXTYPES + 1];
int g_iRockEffect2[ST_MAXTYPES + 1];
int g_iTankEnabled[ST_MAXTYPES + 1];
int g_iTankEnabled2[ST_MAXTYPES + 1];
int g_iTankType[ST_MAXTYPES + 1];
int g_iTankWave;
int g_iType;
TopMenu g_tmSTMenu;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "Super Tanks++ only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	CreateNative("ST_PluginEnabled", iNative_PluginEnabled);
	CreateNative("ST_SpawnTank", iNative_SpawnTank);
	CreateNative("ST_TankType", iNative_TankType);
	RegPluginLibrary("super_tanks++");
	g_bLateLoad = late;
	return APLRes_Success;
}

public int iNative_PluginEnabled(Handle plugin, int numParams)
{
	if (g_bPluginEnabled)
	{
		return true;
	}
	return false;
}

public int iNative_SpawnTank(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	int iType = GetNativeCell(2);
	if (bIsTank(iTank))
	{
		vTank(iTank, iType);
	}
}

public int iNative_TankType(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	int iType;
	if (bIsTank(iTank))
	{
		iType = g_iTankType[iTank];
	}
	return iType;
}

public void OnPluginStart()
{
	g_hAbility = CreateGlobalForward("ST_Ability", ET_Ignore, Param_Cell);
	g_hConfigs = CreateGlobalForward("ST_Configs", ET_Ignore, Param_String, Param_Cell, Param_Cell);
	g_hRockBreak = CreateGlobalForward("ST_RockBreak", ET_Ignore, Param_Cell, Param_Cell);
	g_hRockThrow = CreateGlobalForward("ST_RockThrow", ET_Ignore, Param_Cell, Param_Cell);
	g_hSpawn = CreateGlobalForward("ST_Spawn", ET_Ignore, Param_Cell);
	CreateDirectory("cfg/sourcemod/super_tanks++/", 511);
	vCreateConfigFile("cfg/sourcemod/", "super_tanks++/", "super_tanks++", "super_tanks++", true);
	Format(g_sSavePath, sizeof(g_sSavePath), "cfg/sourcemod/super_tanks++/super_tanks++.cfg");
	vLoadConfigs(g_sSavePath, true);
	g_iFileTimeOld[0] = GetFileTime(g_sSavePath, FileTime_LastChange);
	vMultiTargetFilters(1);
	LoadTranslations("common.phrases");
	RegAdminCmd("sm_tank", cmdTank, ADMFLAG_ROOT, "Spawn a Super Tank.");
	CreateConVar("st_pluginversion", ST_VERSION, "Super Tanks++ Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_cvSTFindConVar[0] = FindConVar("z_difficulty");
	g_cvSTFindConVar[1] = FindConVar("mp_gamemode");
	g_cvSTFindConVar[2] = FindConVar("sv_gametypes");
	g_cvSTFindConVar[3] = FindConVar("z_max_player_zombies");
	g_cvSTFindConVar[0].AddChangeHook(vSTGameDifficultyCvar);
	TopMenu tmAdminMenu;
	if (LibraryExists("adminmenu") && ((tmAdminMenu = GetAdminTopMenu()) != null))
	{
		OnAdminMenuReady(tmAdminMenu);
	}
}

public void OnMapStart()
{
	PrecacheModel(MODEL_CONCRETE, true);
	PrecacheModel(MODEL_JETPACK, true);
	PrecacheModel(MODEL_TIRES, true);
	PrecacheModel(MODEL_WITCH, true);
	PrecacheModel(MODEL_WITCHBRIDE, true);
	vPrecacheParticle(PARTICLE_BLOOD);
	vPrecacheParticle(PARTICLE_ELECTRICITY);
	vPrecacheParticle(PARTICLE_FIRE);
	vPrecacheParticle(PARTICLE_ICE);
	vPrecacheParticle(PARTICLE_METEOR);
	vPrecacheParticle(PARTICLE_SMOKE);
	vPrecacheParticle(PARTICLE_SPIT);
	if (g_bLateLoad)
	{
		vLoadConfigs(g_sSavePath, true);
		vLateLoad(true);
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_iTankType[client] = 0;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_iTankType[client] = 0;
}

public void OnConfigsExecuted()
{
	vLoadConfigs(g_sSavePath, true);
	char sMapName[128];
	GetCurrentMap(sMapName, sizeof(sMapName));
	if (IsMapValid(sMapName))
	{
		vIsPluginAllowed();
		CreateTimer(1.0, tTimerReloadConfigs, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(0.1, tTimerTankHealthUpdate, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerTankTypeUpdate, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerUpdatePlayerCount, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
	g_bCmdUsed = false;
	if (g_iCreateBackup == 1)
	{
		CreateDirectory("cfg/sourcemod/super_tanks++/backup_config/", 511);
		vCreateConfigFile("cfg/sourcemod/super_tanks++/", "backup_config/", "super_tanks++", "super_tanks++", true);
	}
	if (StrContains(g_sConfigCreate, "1") != -1 && g_iConfigEnable == 1)
	{
		CreateDirectory("cfg/sourcemod/super_tanks++/difficulty_configs/", 511);
		char sDifficulty[32];
		for (int iDifficulty = 0; iDifficulty <= 3; iDifficulty++)
		{
			switch (iDifficulty)
			{
				case 0: sDifficulty = "easy";
				case 1: sDifficulty = "normal";
				case 2: sDifficulty = "hard";
				case 3: sDifficulty = "impossible";
			}
			vCreateConfigFile("cfg/sourcemod/super_tanks++/", "difficulty_configs/", sDifficulty, sDifficulty);
		}
	}
	if (StrContains(g_sConfigCreate, "2") != -1 && g_iConfigEnable == 1)
	{
		CreateDirectory((bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_map_configs/" : "cfg/sourcemod/super_tanks++/l4d_map_configs/"), 511);
		char sMapNames[128];
		ArrayList alADTMaps = new ArrayList(16, 0);
		int iSerial = -1;
		ReadMapList(alADTMaps, iSerial, "default", MAPLIST_FLAG_MAPSFOLDER);
		ReadMapList(alADTMaps, iSerial, "allexistingmaps__", MAPLIST_FLAG_MAPSFOLDER|MAPLIST_FLAG_NO_DEFAULT);
		int iMapCount = GetArraySize(alADTMaps);
		if (iMapCount > 0)
		{
			for (int iMap = 0; iMap < iMapCount; iMap++)
			{
				alADTMaps.GetString(iMap, sMapNames, sizeof(sMapNames));
				vCreateConfigFile("cfg/sourcemod/super_tanks++/", (bIsL4D2Game() ? "l4d2_map_configs/" : "l4d_map_configs/"), sMapNames, sMapNames);
			}
		}
		delete alADTMaps;
	}
	if (StrContains(g_sConfigCreate, "3") != -1 && g_iConfigEnable == 1)
	{
		CreateDirectory((bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_gamemode_configs/" : "cfg/sourcemod/super_tanks++/l4d_gamemode_configs/"), 511);
		char sGameType[2049];
		char sTypes[64][32];
		g_cvSTFindConVar[2].GetString(sGameType, sizeof(sGameType));
		TrimString(sGameType);
		ExplodeString(sGameType, ",", sTypes, sizeof(sTypes), sizeof(sTypes[]));
		for (int iMode = 0; iMode < sizeof(sTypes); iMode++)
		{
			if (StrContains(sGameType, sTypes[iMode]) != -1 && sTypes[iMode][0] != '\0')
			{
				vCreateConfigFile("cfg/sourcemod/super_tanks++/", (bIsL4D2Game() ? "l4d2_gamemode_configs/" : "l4d_gamemode_configs/"), sTypes[iMode], sTypes[iMode]);
			}
		}
	}
	if (StrContains(g_sConfigCreate, "4") != -1 && g_iConfigEnable == 1)
	{
		CreateDirectory("cfg/sourcemod/super_tanks++/daily_configs/", 511);
		char sWeekday[32];
		for (int iDay = 0; iDay <= 6; iDay++)
		{
			switch (iDay)
			{
				case 6: sWeekday = "saturday";
				case 5: sWeekday = "friday";
				case 4: sWeekday = "thursday";
				case 3: sWeekday = "wednesday";
				case 2: sWeekday = "tuesday";
				case 1: sWeekday = "monday";
				default: sWeekday = "sunday";
			}
			vCreateConfigFile("cfg/sourcemod/super_tanks++/", "daily_configs/", sWeekday, sWeekday);
		}
	}
	if (StrContains(g_sConfigCreate, "5") != -1 && g_iConfigEnable == 1)
	{
		CreateDirectory("cfg/sourcemod/super_tanks++/playercount_configs/", 511);
		char sPlayerCount[32];
		for (int iCount = 0; iCount <= MAXPLAYERS + 1; iCount++)
		{
			IntToString(iCount, sPlayerCount, sizeof(sPlayerCount));
			vCreateConfigFile("cfg/sourcemod/super_tanks++/", "playercount_configs/", sPlayerCount, sPlayerCount);
		}
	}
	if (StrContains(g_sConfigExecute, "1") != -1 && g_iConfigEnable == 1 && g_cvSTFindConVar[0] != null)
	{
		char sDifficultyConfig[512];
		vGetCurrentDifficulty(g_cvSTFindConVar[0], sDifficultyConfig);
		vLoadConfigs(sDifficultyConfig);
		g_iFileTimeOld[1] = GetFileTime(sDifficultyConfig, FileTime_LastChange);
	}
	if (StrContains(g_sConfigExecute, "2") != -1 && g_iConfigEnable == 1)
	{
		char sMapConfig[512];
		vGetCurrentMap(sMapConfig);
		vLoadConfigs(sMapConfig);
		g_iFileTimeOld[2] = GetFileTime(sMapConfig, FileTime_LastChange);
	}
	if (StrContains(g_sConfigExecute, "3") != -1 && g_iConfigEnable == 1)
	{
		char sModeConfig[512];
		vGetCurrentMode(g_cvSTFindConVar[1], sModeConfig);
		vLoadConfigs(sModeConfig);
		g_iFileTimeOld[3] = GetFileTime(sModeConfig, FileTime_LastChange);
	}
	if (StrContains(g_sConfigExecute, "4") != -1 && g_iConfigEnable == 1)
	{
		char sDayConfig[512];
		vGetCurrentDay(sDayConfig);
		vLoadConfigs(sDayConfig);
		g_iFileTimeOld[4] = GetFileTime(sDayConfig, FileTime_LastChange);
	}
	if (StrContains(g_sConfigExecute, "5") != -1 && g_iConfigEnable == 1)
	{
		char sCountConfig[512];
		vGetCurrentCount(sCountConfig);
		vLoadConfigs(sCountConfig);
		g_iFileTimeOld[5] = GetFileTime(sCountConfig, FileTime_LastChange);
	}
}

public void OnMapEnd()
{
	g_bCmdUsed = false;
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_iTankType[iPlayer] = 0;
		}
	}
}

public void OnPluginEnd()
{
	vMultiTargetFilters(0);
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank))
		{
			int iGlowEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_iGlowEffect[g_iTankType[iTank]] : g_iGlowEffect2[g_iTankType[iTank]];
			if (iGlowEffect == 1 && bIsL4D2Game())
			{
				SetEntProp(iTank, Prop_Send, "m_iGlowType", 0);
				SetEntProp(iTank, Prop_Send, "m_glowColorOverride", 0);
			}
		}
	}
}

public void OnAdminMenuReady(Handle topmenu)
{
	if (topmenu == g_tmSTMenu)
	{
		return;
	}
	g_tmSTMenu = view_as<TopMenu>(topmenu);
	TopMenuObject st_commands = g_tmSTMenu.AddCategory("SuperTanks++", iSTAdminMenuHandler);
	if (st_commands != INVALID_TOPMENUOBJECT)
	{
		g_tmSTMenu.AddItem("sm_tank", vSuperTankMenu, st_commands, "sm_tank", ADMFLAG_ROOT);
	}
}

public int iSTAdminMenuHandler(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayTitle, TopMenuAction_DisplayOption: Format(buffer, maxlength, "Super Tanks++");
	}
}

public void vSuperTankMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: Format(buffer, maxlength, "Super Tanks++ Menu");
		case TopMenuAction_SelectOption: vTankMenu(param, 0);
	}
}

public void OnLibraryRemoved(const char[] name)
{
	if (strcmp(name, "adminmenu", false) == 0)
	{
		g_tmSTMenu = null;
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (g_bPluginEnabled && strcmp(classname, "tank_rock") == 0)
	{
		CreateTimer(0.1, tTimerRockThrow, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void OnEntityDestroyed(int entity)
{
	if (g_bPluginEnabled && bIsValidEntity(entity))
	{
		char sClassname[32];
		GetEntityClassname(entity, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "tank_rock") == 0)
		{
			int iThrower = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
			int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
			if (iThrower > 0 && bIsTank(iThrower) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iThrower))))
			{
				Call_StartForward(g_hRockBreak);
				Call_PushCell(iThrower);
				Call_PushCell(entity);
				Call_Finish();
			}
		}
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_bPluginEnabled && damage > 0.0 && bIsValidClient(victim))
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (bIsInfected(victim))
		{
			int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
			if (bIsTank(victim) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(victim))))
			{
				int iBulletImmunity = !g_bTankConfig[g_iTankType[victim]] ? g_iBulletImmunity[g_iTankType[victim]] : g_iBulletImmunity2[g_iTankType[victim]];
				int iExplosiveImmunity = !g_bTankConfig[g_iTankType[victim]] ? g_iExplosiveImmunity[g_iTankType[victim]] : g_iExplosiveImmunity2[g_iTankType[victim]];
				int iFireImmunity = !g_bTankConfig[g_iTankType[victim]] ? g_iFireImmunity[g_iTankType[victim]] : g_iFireImmunity2[g_iTankType[victim]];
				int iMeleeImmunity = !g_bTankConfig[g_iTankType[victim]] ? g_iMeleeImmunity[g_iTankType[victim]] : g_iMeleeImmunity2[g_iTankType[victim]];
				if ((damagetype & DMG_BULLET && iBulletImmunity == 1) || ((damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA) && iExplosiveImmunity == 1) || (damagetype & DMG_BURN && iFireImmunity == 1) || ((damagetype & DMG_SLASH || damagetype & DMG_CLUB) && iMeleeImmunity == 1))
				{
					damage = 0.0;
					return Plugin_Handled;
				}
			}
			if ((damagetype & DMG_BURN || damagetype & DMG_BLAST) && (attacker == victim || bIsInfected(attacker)))
			{
				damage = 0.0;
				return Plugin_Handled;
			}
			if (inflictor != -1)
			{
				int iOwner = GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity");
				if (iOwner == victim || bIsTank(iOwner) || strcmp(sClassname, "tank_rock") == 0)
				{
					damage = 0.0;
					return Plugin_Changed;
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action SetTransmit(int entity, int client)
{
	int iOwner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if (iOwner == client)
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action eEventAbilityUse(Event event, const char[] name, bool dontBroadcast)
{
	int iUserId = event.GetInt("userid");
	int iTank = GetClientOfUserId(iUserId);
	if (bIsTank(iTank))
	{
		int iProp = -1;
		while ((iProp = FindEntityByClassname(iProp, "prop_dynamic")) != INVALID_ENT_REFERENCE)
		{
			char sModel[128];
			GetEntPropString(iProp, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
			if (strcmp(sModel, MODEL_JETPACK, false) == 0 || strcmp(sModel, MODEL_CONCRETE, false) == 0 || strcmp(sModel, MODEL_TIRES, false) == 0 || strcmp(sModel, MODEL_TANK, false) == 0)
			{
				int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
				if (iOwner == iTank)
				{
					SDKUnhook(iProp, SDKHook_SetTransmit, SetTransmit);
					CreateTimer(3.5, tTimerSetTransmit, EntIndexToEntRef(iProp), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
		while ((iProp = FindEntityByClassname(iProp, "beam_spotlight")) != INVALID_ENT_REFERENCE)
		{
			int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
			if (iOwner == iTank)
			{
				SDKUnhook(iProp, SDKHook_SetTransmit, SetTransmit);
				CreateTimer(3.5, tTimerSetTransmit, EntIndexToEntRef(iProp), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		while ((iProp = FindEntityByClassname(iProp, "env_steam")) != INVALID_ENT_REFERENCE)
		{
			int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
			if (iOwner == iTank)
			{
				SDKUnhook(iProp, SDKHook_SetTransmit, SetTransmit);
				CreateTimer(3.5, tTimerSetTransmit, EntIndexToEntRef(iProp), TIMER_FLAG_NO_MAPCHANGE);
			}
		}
		float flThrowInterval = !g_bTankConfig[g_iTankType[iTank]] ? g_flThrowInterval[g_iTankType[iTank]] : g_flThrowInterval2[g_iTankType[iTank]];
		vThrowInterval(iTank, flThrowInterval);
	}
}

public Action eEventFinaleEscapeStart(Event event, const char[] name, bool dontBroadcast)
{
	g_iTankWave = 3;
}

public Action eEventFinaleStart(Event event, const char[] name, bool dontBroadcast)
{
	g_iTankWave = 1;
}

public Action eEventFinaleVehicleLeaving(Event event, const char[] name, bool dontBroadcast)
{
	g_iTankWave = 4;
}

public Action eEventFinaleVehicleReady(Event event, const char[] name, bool dontBroadcast)
{
	g_iTankWave = 3;
}

public Action eEventPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int iUserId = event.GetInt("userid");
	int iPlayer = GetClientOfUserId(iUserId);
	if (bIsValidClient(iPlayer))
	{
		int iGlowEffect = !g_bTankConfig[g_iTankType[iPlayer]] ? g_iGlowEffect[g_iTankType[iPlayer]] : g_iGlowEffect2[g_iTankType[iPlayer]];
		if (iGlowEffect == 1 && bIsL4D2Game())
		{
			SetEntProp(iPlayer, Prop_Send, "m_iGlowType", 0);
			SetEntProp(iPlayer, Prop_Send, "m_glowColorOverride", 0);
		}
		int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
		if (bIsTank(iPlayer, false) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iPlayer))))
		{
			char sName[MAX_NAME_LENGTH + 1];
			sName = !g_bTankConfig[g_iTankType[iPlayer]] ? g_sCustomName[g_iTankType[iPlayer]] : g_sCustomName2[g_iTankType[iPlayer]];
			int iAnnounceDeath = !g_bGeneralConfig ? g_iAnnounceDeath : g_iAnnounceDeath2;
			if (iAnnounceDeath == 1)
			{
				switch (GetRandomInt(1, 10))
				{
					case 1: PrintToChatAll("\x04%s\x05 %s\x01 is defeated!", ST_PREFIX, sName);
					case 2: PrintToChatAll("\x04%s\x01 The survivors defeated\x05 %s\x01!", ST_PREFIX, sName);
					case 3: PrintToChatAll("\x04%s\x05 %s\x01 goes to hell!", ST_PREFIX, sName);
					case 4: PrintToChatAll("\x04%s\x01 Is\x05 %s\x01 really dead...?", ST_PREFIX, sName);
					case 5: PrintToChatAll("\x04%s\x05 %s\x01 lost the challenge against the survivors!", ST_PREFIX, sName);
					case 6: PrintToChatAll("\x04%s\x01 The\x05 %s\x01 failed to kill the survivors!", ST_PREFIX, sName);
					case 7: PrintToChatAll("\x04%s\x05 %s\x01 has met their demise!", ST_PREFIX, sName);
					case 8: PrintToChatAll("\x04%s\x01 Yay!\x05 %s\x01 is dead!", ST_PREFIX, sName);
					case 9: PrintToChatAll("\x04%s\x05 %s\x01 left the game...", ST_PREFIX, sName);
					case 10: PrintToChatAll("\x04%s\x01 It seems\x05 %s\x01 could not beat the survivors after all...", ST_PREFIX, sName);
				}
			}
			int iProp = -1;
			while ((iProp = FindEntityByClassname(iProp, "prop_dynamic")) != INVALID_ENT_REFERENCE)
			{
				char sModel[128];
				GetEntPropString(iProp, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
				if (strcmp(sModel, MODEL_JETPACK, false) == 0 || strcmp(sModel, MODEL_CONCRETE, false) == 0 || strcmp(sModel, MODEL_TIRES, false) == 0 || strcmp(sModel, MODEL_TANK, false) == 0)
				{
					int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
					if (iOwner == iPlayer)
					{
						SDKUnhook(iProp, SDKHook_SetTransmit, SetTransmit);
						AcceptEntityInput(iProp, "Kill");
					}
				}
			}
			while ((iProp = FindEntityByClassname(iProp, "beam_spotlight")) != INVALID_ENT_REFERENCE)
			{
				int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
				if (iOwner == iPlayer)
				{
					SDKUnhook(iProp, SDKHook_SetTransmit, SetTransmit);
					AcceptEntityInput(iProp, "Kill");
				}
			}
			CreateTimer(5.0, tTimerTankWave, g_iTankWave, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action eEventPlayerIncapacitated(Event event, const char[] name, bool dontBroadcast)
{
	int iUserId = event.GetInt("userid");
	int iTank = GetClientOfUserId(iUserId);
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if (bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		CreateTimer(3.0, tTimerKillStuckTank, iUserId, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action eEventRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	g_iTankWave = 0;
}

public Action eEventTankSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int iUserId = event.GetInt("userid");
	int iTank = GetClientOfUserId(iUserId);
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if (bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		if (g_bCmdUsed)
		{
			vSetColor(iTank, g_iType);
			g_bCmdUsed = false;
		}
		else
		{
			g_iTankType[iTank] = 0;
			int iFinalesOnly = !g_bGeneralConfig ? g_iFinalesOnly : g_iFinalesOnly2;
			if (iFinalesOnly == 0 || (iFinalesOnly == 1 && (bIsFinaleMap() || g_iTankWave > 0)))
			{
				int iTypeCount;
				int iLimit = !g_bGeneralConfig ? g_iMaxTypes : g_iMaxTypes2;
				int iTankTypes[ST_MAXTYPES + 1];
				for (int iIndex = 1; iIndex <= iLimit; iIndex++)
				{
					int iTankEnabled = !g_bTankConfig[iIndex] ? g_iTankEnabled[iIndex] : g_iTankEnabled2[iIndex];
					if (iTankEnabled == 0)
					{
						continue;
					}
					iTankTypes[iTypeCount + 1] = iIndex;
					iTypeCount++;
				}
				if (iTypeCount > 0)
				{
					int iChosen = iTankTypes[GetRandomInt(1, iTypeCount)];
					vSetColor(iTank, iChosen);
				}
				char sNumbers[3][4];
				char sTankWaves[12];
				sTankWaves = !g_bGeneralConfig ? g_sTankWaves : g_sTankWaves2;
				TrimString(sTankWaves);
				ExplodeString(sTankWaves, ",", sNumbers, sizeof(sNumbers), sizeof(sNumbers[]));
				TrimString(sNumbers[0]);
				int iWave1 = (sNumbers[0][0] != '\0') ? StringToInt(sNumbers[0]) : 1;
				TrimString(sNumbers[1]);
				int iWave2 = (sNumbers[1][0] != '\0') ? StringToInt(sNumbers[1]) : 2;
				TrimString(sNumbers[2]);
				int iWave3 = (sNumbers[2][0] != '\0') ? StringToInt(sNumbers[2]) : 3;
				switch (g_iTankWave)
				{
					case 1: vTankCountCheck(iWave1);
					case 2: vTankCountCheck(iWave2);
					case 3: vTankCountCheck(iWave3);
				}
			}
		}
		CreateTimer(0.1, tTimerTankSpawn, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action cmdTank(int client, int args)
{
	if (!g_bPluginEnabled)
	{
		ReplyToCommand(client, "\x04%s\x01 Super Tanks++ is disabled.", ST_PREFIX);
		return Plugin_Handled;
	}
	if (!bIsValidHumanClient(client))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", ST_PREFIX);
		return Plugin_Handled;
	}
	char sType[32];
	GetCmdArg(1, sType, sizeof(sType));
	int iType = StringToInt(sType);
	int iMaxTypes = !g_bGeneralConfig ? g_iMaxTypes : g_iMaxTypes2;
	if (args < 1)
	{
		IsVoteInProgress() ? ReplyToCommand(client, "\x04%s\x01 %t", ST_PREFIX, "Vote in Progress") : vTankMenu(client, 0);
		return Plugin_Handled;
	}
	else if (iType < 1 || iType > iMaxTypes || args > 1)
	{
		int iLimit = !g_bGeneralConfig ? g_iMaxTypes : g_iMaxTypes2;
		ReplyToCommand(client, "\x04%s\x01 Usage: sm_tank <type 1-%d>", ST_PREFIX, iLimit);
		return Plugin_Handled;
	}
	int iTankEnabled = !g_bTankConfig[iType] ? g_iTankEnabled[iType] : g_iTankEnabled2[iType];
	if (iTankEnabled == 0)
	{
		char sName[MAX_NAME_LENGTH + 1];
		sName = !g_bTankConfig[iType] ? g_sCustomName[iType] : g_sCustomName2[iType];
		ReplyToCommand(client, "\x04%s\x05 %s\x04 (Tank #%d)\x01 is disabled.", ST_PREFIX, sName, iType);
		return Plugin_Handled;
	}
	vTank(client, iType);
	return Plugin_Handled;
}

void vTank(int client, int type)
{
	g_bCmdUsed = true;
	g_iType = type;
	char sCommand[32];
	sCommand = bIsL4D2Game() ? "z_spawn_old" : "z_spawn";
	int iCmdFlags = GetCommandFlags(sCommand);
	SetCommandFlags(sCommand, iCmdFlags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s tank", sCommand);
	SetCommandFlags(sCommand, iCmdFlags|FCVAR_CHEAT);
}

void vTankMenu(int client, int item)
{
	Menu mTankMenu = new Menu(iTankMenuHandler);
	mTankMenu.SetTitle("Super Tanks++ Menu");
	int iLimit = !g_bGeneralConfig ? g_iMaxTypes : g_iMaxTypes2;
	for (int iIndex = 1; iIndex <= iLimit; iIndex++)
	{
		int iTankEnabled = !g_bTankConfig[iIndex] ? g_iTankEnabled[iIndex] : g_iTankEnabled2[iIndex];
		if (iTankEnabled == 0)
		{
			continue;
		}
		char sName[MAX_NAME_LENGTH + 1];
		sName = !g_bTankConfig[iIndex] ? g_sCustomName[iIndex] : g_sCustomName2[iIndex];
		mTankMenu.AddItem(sName, sName);
	}
	mTankMenu.DisplayAt(client, item, MENU_TIME_FOREVER);
}

public int iTankMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			char sInfo[MAX_NAME_LENGTH + 1];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			int iLimit = !g_bGeneralConfig ? g_iMaxTypes : g_iMaxTypes2;
			for (int iIndex = 1; iIndex <= iLimit; iIndex++)
			{
				int iTankEnabled = !g_bTankConfig[iIndex] ? g_iTankEnabled[iIndex] : g_iTankEnabled2[iIndex];
				if (iTankEnabled == 0)
				{
					continue;
				}
				char sName[MAX_NAME_LENGTH + 1];
				sName = !g_bTankConfig[iIndex] ? g_sCustomName[iIndex] : g_sCustomName2[iIndex];
				if (strcmp(sInfo, sName) == 0)
				{
					vTank(param1, iIndex);
				}
			}
			if (IsClientInGame(param1) && !IsClientInKickQueue(param1))
			{
				vTankMenu(param1, menu.Selection);
			}
		}
	}
}

void vIsPluginAllowed()
{
	bool bIsPluginAllowed = bIsPluginEnabled(g_cvSTFindConVar[1], g_iGameModeTypes, g_sEnabledGameModes, g_sDisabledGameModes);
	int iPluginEnabled = !g_bGeneralConfig ? g_iPluginEnabled : g_iPluginEnabled2;
	if (iPluginEnabled == 1)
	{
		if (bIsPluginAllowed)
		{
			vHookEvents(true);
			vLateLoad(true);
			g_bPluginEnabled = true;
		}
		else
		{
			vHookEvents(false);
			vLateLoad(false);
			g_bPluginEnabled = false;
		}
	}
}

void vHookEvents(bool hook)
{
	static bool hooked;
	if (hook && !hooked)
	{
		HookEvent("ability_use", eEventAbilityUse);
		HookEvent("finale_escape_start", eEventFinaleEscapeStart);
		HookEvent("finale_start", eEventFinaleStart, EventHookMode_Pre);
		HookEvent("finale_vehicle_leaving", eEventFinaleVehicleLeaving);
		HookEvent("finale_vehicle_ready", eEventFinaleVehicleReady);
		HookEvent("player_death", eEventPlayerDeath);
		HookEvent("player_incapacitated", eEventPlayerIncapacitated);
		HookEvent("round_start", eEventRoundStart);
		HookEvent("tank_spawn", eEventTankSpawn);
		hooked = true;
	}
	else if (!hook && hooked)
	{
		UnhookEvent("ability_use", eEventAbilityUse);
		UnhookEvent("finale_escape_start", eEventFinaleEscapeStart);
		UnhookEvent("finale_start", eEventFinaleStart);
		UnhookEvent("finale_vehicle_leaving", eEventFinaleVehicleLeaving);
		UnhookEvent("finale_vehicle_ready", eEventFinaleVehicleReady);
		UnhookEvent("player_death", eEventPlayerDeath);
		UnhookEvent("player_incapacitated", eEventPlayerIncapacitated);
		UnhookEvent("round_start", eEventRoundStart);
		UnhookEvent("tank_spawn", eEventTankSpawn);
		hooked = false;
	}
}

void vLoadConfigs(char[] savepath, bool main = false)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	if (kvSuperTanks.JumpToKey("Plugin Settings"))
	{
		main ? (g_bGeneralConfig = false) : (g_bGeneralConfig = true);
		main ? (g_iPluginEnabled = kvSuperTanks.GetNum("General/Plugin Enabled", 1)) : (g_iPluginEnabled2 = kvSuperTanks.GetNum("General/Plugin Enabled", g_iPluginEnabled));
		main ? (g_iPluginEnabled = iSetCellLimit(g_iPluginEnabled, 0, 1)) : (g_iPluginEnabled2 = iSetCellLimit(g_iPluginEnabled2, 0, 1));
		if (main)
		{
			g_iCreateBackup = kvSuperTanks.GetNum("General/Create Backup", 0);
			g_iCreateBackup = iSetCellLimit(g_iCreateBackup, 0, 1);
			g_iGameModeTypes = kvSuperTanks.GetNum("General/Game Mode Types", 0);
			g_iGameModeTypes = iSetCellLimit(g_iGameModeTypes, 0, 15);
			kvSuperTanks.GetString("General/Enabled Game Modes", g_sEnabledGameModes, sizeof(g_sEnabledGameModes), "");
			kvSuperTanks.GetString("General/Disabled Game Modes", g_sDisabledGameModes, sizeof(g_sDisabledGameModes), "");
		}
		main ? (g_iAnnounceArrival = kvSuperTanks.GetNum("General/Announce Arrival", 1)) : (g_iAnnounceArrival2 = kvSuperTanks.GetNum("General/Announce Arrival", g_iAnnounceArrival));
		main ? (g_iAnnounceArrival = iSetCellLimit(g_iAnnounceArrival, 0, 1)) : (g_iAnnounceArrival2 = iSetCellLimit(g_iAnnounceArrival2, 0, 1));
		main ? (g_iAnnounceDeath = kvSuperTanks.GetNum("General/Announce Death", 1)) : (g_iAnnounceDeath2 = kvSuperTanks.GetNum("General/Announce Death", g_iAnnounceDeath));
		main ? (g_iAnnounceDeath = iSetCellLimit(g_iAnnounceDeath, 0, 1)) : (g_iAnnounceDeath2 = iSetCellLimit(g_iAnnounceDeath2, 0, 1));
		main ? (g_iDisplayHealth = kvSuperTanks.GetNum("General/Display Health", 3)) : (g_iDisplayHealth2 = kvSuperTanks.GetNum("General/Display Health", g_iDisplayHealth));
		main ? (g_iDisplayHealth = iSetCellLimit(g_iDisplayHealth, 0, 3)) : (g_iDisplayHealth2 = iSetCellLimit(g_iDisplayHealth2, 0, 3));
		main ? (g_iFinalesOnly = kvSuperTanks.GetNum("General/Finales Only", 0)) : (g_iFinalesOnly2 = kvSuperTanks.GetNum("General/Finales Only", g_iFinalesOnly));
		main ? (g_iFinalesOnly = iSetCellLimit(g_iFinalesOnly, 0, 1)) : (g_iFinalesOnly2 = iSetCellLimit(g_iFinalesOnly2, 0, 1));
		main ? (g_iHumanSupport = kvSuperTanks.GetNum("General/Human Super Tanks", 1)) : (g_iHumanSupport2 = kvSuperTanks.GetNum("General/Human Super Tanks", g_iHumanSupport));
		main ? (g_iHumanSupport = iSetCellLimit(g_iHumanSupport, 0, 1)) : (g_iHumanSupport2 = iSetCellLimit(g_iHumanSupport2, 0, 1));
		main ? (g_iMaxTypes = kvSuperTanks.GetNum("General/Maximum Types", ST_MAXTYPES)) : (g_iMaxTypes2 = kvSuperTanks.GetNum("General/Maximum Types", g_iMaxTypes));
		main ? (g_iMaxTypes = iSetCellLimit(g_iMaxTypes, 1, ST_MAXTYPES)) : (g_iMaxTypes2 = iSetCellLimit(g_iMaxTypes2, 1, ST_MAXTYPES));
		main ? (g_iMultiHealth = kvSuperTanks.GetNum("General/Multiply Health", 0)) : (g_iMultiHealth2 = kvSuperTanks.GetNum("General/Multiply Health", g_iMultiHealth));
		main ? (g_iMultiHealth = iSetCellLimit(g_iMultiHealth, 0, 3)) : (g_iMultiHealth2 = iSetCellLimit(g_iMultiHealth2, 0, 3));
		main ? (kvSuperTanks.GetString("General/Tank Waves", g_sTankWaves, sizeof(g_sTankWaves), "2,3,4")) : (kvSuperTanks.GetString("General/Tank Waves", g_sTankWaves2, sizeof(g_sTankWaves2), g_sTankWaves));
		if (main)
		{
			g_iConfigEnable = kvSuperTanks.GetNum("Custom/Enable Custom Configs", 0);
			g_iConfigEnable = iSetCellLimit(g_iConfigEnable, 0, 1);
			kvSuperTanks.GetString("Custom/Create Config Types", g_sConfigCreate, sizeof(g_sConfigCreate), "12345");
			kvSuperTanks.GetString("Custom/Execute Config Types", g_sConfigExecute, sizeof(g_sConfigExecute), "1");
		}
		kvSuperTanks.Rewind();
	}
	int iLimit = main ? g_iMaxTypes : g_iMaxTypes2;
	for (int iIndex = 1; iIndex <= iLimit; iIndex++)
	{
		char sName[MAX_NAME_LENGTH + 1];
		Format(sName, sizeof(sName), "Tank %d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (kvSuperTanks.GetString("General/Tank Name", g_sCustomName[iIndex], sizeof(g_sCustomName[]), sName)) : (kvSuperTanks.GetString("General/Tank Name", g_sCustomName2[iIndex], sizeof(g_sCustomName2[]), g_sCustomName[iIndex]));
			main ? (g_iTankEnabled[iIndex] = kvSuperTanks.GetNum("General/Tank Enabled", 0)) : (g_iTankEnabled2[iIndex] = kvSuperTanks.GetNum("General/Tank Enabled", g_iTankEnabled[iIndex]));
			main ? (g_iTankEnabled[iIndex] = iSetCellLimit(g_iTankEnabled[iIndex], 0, 1)) : (g_iTankEnabled2[iIndex] = iSetCellLimit(g_iTankEnabled2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors[iIndex], sizeof(g_sTankColors[]), "255,255,255,255|255,255,255")) : (kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors2[iIndex], sizeof(g_sTankColors2[]), g_sTankColors[iIndex]));
			main ? (g_iGlowEffect[iIndex] = kvSuperTanks.GetNum("General/Glow Effect", 1)) : (g_iGlowEffect2[iIndex] = kvSuperTanks.GetNum("General/Glow Effect", g_iGlowEffect[iIndex]));
			main ? (g_iGlowEffect[iIndex] = iSetCellLimit(g_iGlowEffect[iIndex], 0, 1)) : (g_iGlowEffect2[iIndex] = iSetCellLimit(g_iGlowEffect2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("General/Props Attached", g_sPropsAttached[iIndex], sizeof(g_sPropsAttached[]), "23456")) : (kvSuperTanks.GetString("General/Props Attached", g_sPropsAttached2[iIndex], sizeof(g_sPropsAttached2[]), g_sPropsAttached[iIndex]));
			main ? (kvSuperTanks.GetString("General/Props Chance", g_sPropsChance[iIndex], sizeof(g_sPropsChance[]), "3,3,3,3,3,3")) : (kvSuperTanks.GetString("General/Props Chance", g_sPropsChance2[iIndex], sizeof(g_sPropsChance2[]), g_sPropsChance[iIndex]));
			main ? (kvSuperTanks.GetString("General/Props Colors", g_sPropsColors[iIndex], sizeof(g_sPropsColors[]), "255,255,255,255|255,255,255,255|255,255,255,180|255,255,255,255|255,255,255,255")) : (kvSuperTanks.GetString("General/Props Colors", g_sPropsColors2[iIndex], sizeof(g_sPropsColors2[]), g_sPropsColors[iIndex]));
			main ? (g_iParticleEffect[iIndex] = kvSuperTanks.GetNum("General/Particle Effect", 0)) : (g_iParticleEffect2[iIndex] = kvSuperTanks.GetNum("General/Particle Effect", g_iParticleEffect[iIndex]));
			main ? (g_iParticleEffect[iIndex] = iSetCellLimit(g_iParticleEffect[iIndex], 0, 1)) : (g_iParticleEffect2[iIndex] = iSetCellLimit(g_iParticleEffect2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("General/Particle Effects", g_sParticleEffects[iIndex], sizeof(g_sParticleEffects[]), "1234567")) : (kvSuperTanks.GetString("General/Particle Effects", g_sParticleEffects2[iIndex], sizeof(g_sParticleEffects2[]), g_sParticleEffects[iIndex]));
			main ? (g_iRockEffect[iIndex] = kvSuperTanks.GetNum("General/Rock Effect", 0)) : (g_iRockEffect2[iIndex] = kvSuperTanks.GetNum("General/Rock Effect", g_iRockEffect[iIndex]));
			main ? (g_iRockEffect[iIndex] = iSetCellLimit(g_iRockEffect[iIndex], 0, 1)) : (g_iRockEffect2[iIndex] = iSetCellLimit(g_iRockEffect2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("General/Rock Effects", g_sRockEffects[iIndex], sizeof(g_sRockEffects[]), "1234")) : (kvSuperTanks.GetString("General/Rock Effects", g_sRockEffects2[iIndex], sizeof(g_sRockEffects2[]), g_sRockEffects[iIndex]));
			main ? (g_iExtraHealth[iIndex] = kvSuperTanks.GetNum("Enhancements/Extra Health", 0)) : (g_iExtraHealth2[iIndex] = kvSuperTanks.GetNum("Enhancements/Extra Health", g_iExtraHealth[iIndex]));
			main ? (g_iExtraHealth[iIndex] = iSetCellLimit(g_iExtraHealth[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iExtraHealth2[iIndex] = iSetCellLimit(g_iExtraHealth2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
			main ? (g_flRunSpeed[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", 1.0)) : (g_flRunSpeed2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", g_flRunSpeed[iIndex]));
			main ? (g_flRunSpeed[iIndex] = flSetFloatLimit(g_flRunSpeed[iIndex], 0.1, 3.0)) : (g_flRunSpeed2[iIndex] = flSetFloatLimit(g_flRunSpeed2[iIndex], 0.1, 3.0));
			main ? (g_flThrowInterval[iIndex] = kvSuperTanks.GetFloat("Enhancements/Throw Interval", 5.0)) : (g_flThrowInterval2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Throw Interval", g_flThrowInterval[iIndex]));
			main ? (g_flThrowInterval[iIndex] = flSetFloatLimit(g_flThrowInterval[iIndex], 0.1, 9999999999.0)) : (g_flThrowInterval2[iIndex] = flSetFloatLimit(g_flThrowInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_iBulletImmunity[iIndex] = kvSuperTanks.GetNum("Immunities/Bullet Immunity", 0)) : (g_iBulletImmunity2[iIndex] = kvSuperTanks.GetNum("Immunities/Bullet Immunity", g_iBulletImmunity[iIndex]));
			main ? (g_iBulletImmunity[iIndex] = iSetCellLimit(g_iBulletImmunity[iIndex], 0, 1)) : (g_iBulletImmunity2[iIndex] = iSetCellLimit(g_iBulletImmunity2[iIndex], 0, 1));
			main ? (g_iExplosiveImmunity[iIndex] = kvSuperTanks.GetNum("Immunities/Explosive Immunity", 0)) : (g_iExplosiveImmunity2[iIndex] = kvSuperTanks.GetNum("Immunities/Explosive Immunity", g_iExplosiveImmunity[iIndex]));
			main ? (g_iExplosiveImmunity[iIndex] = iSetCellLimit(g_iExplosiveImmunity[iIndex], 0, 1)) : (g_iExplosiveImmunity2[iIndex] = iSetCellLimit(g_iExplosiveImmunity2[iIndex], 0, 1));
			main ? (g_iFireImmunity[iIndex] = kvSuperTanks.GetNum("Immunities/Fire Immunity", 0)) : (g_iFireImmunity2[iIndex] = kvSuperTanks.GetNum("Immunities/Fire Immunity", g_iFireImmunity[iIndex]));
			main ? (g_iFireImmunity[iIndex] = iSetCellLimit(g_iFireImmunity[iIndex], 0, 1)) : (g_iFireImmunity2[iIndex] = iSetCellLimit(g_iFireImmunity2[iIndex], 0, 1));
			main ? (g_iMeleeImmunity[iIndex] = kvSuperTanks.GetNum("Immunities/Melee Immunity", 0)) : (g_iMeleeImmunity2[iIndex] = kvSuperTanks.GetNum("Immunities/Melee Immunity", g_iMeleeImmunity[iIndex]));
			main ? (g_iMeleeImmunity[iIndex] = iSetCellLimit(g_iMeleeImmunity[iIndex], 0, 1)) : (g_iMeleeImmunity2[iIndex] = iSetCellLimit(g_iMeleeImmunity2[iIndex], 0, 1));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
	Call_StartForward(g_hConfigs);
	Call_PushString(savepath);
	Call_PushCell(iLimit);
	Call_PushCell(main);
	Call_Finish();
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

void vAttachParticle(int client, char[] particlename, float time = 0.0, float origin = 0.0)
{
	if (bIsValidClient(client))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (IsValidEntity(iParticle))
		{
			float flPos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPos);
			flPos[2] += origin;
			DispatchKeyValue(iParticle, "scale", "");
			DispatchKeyValue(iParticle, "effect_name", particlename);
			TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iParticle);
			ActivateEntity(iParticle);
			AcceptEntityInput(iParticle, "Enable");
			AcceptEntityInput(iParticle, "Start");
			vSetEntityParent(iParticle, client);
			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, time);
		}
	}
}

void vAttachProps(int client, int red, int green, int blue, int alpha, int red2, int green2, int blue2, int alpha2, int red3, int green3, int blue3, int alpha3, int red4, int green4, int blue4, int alpha4, int red5, int green5, int blue5, int alpha5)
{
	char sSet[6][4];
	char sPropsChance[12];
	sPropsChance = !g_bTankConfig[g_iTankType[client]] ? g_sPropsChance[g_iTankType[client]] : g_sPropsChance2[g_iTankType[client]];
	TrimString(sPropsChance);
	ExplodeString(sPropsChance, ",", sSet, sizeof(sSet), sizeof(sSet[]));
	TrimString(sSet[0]);
	int iChance1 = (sSet[0][0] != '\0') ? StringToInt(sSet[0]) : 3;
	TrimString(sSet[1]);
	int iChance2 = (sSet[1][0] != '\0') ? StringToInt(sSet[1]) : 3;
	TrimString(sSet[2]);
	int iChance3 = (sSet[2][0] != '\0') ? StringToInt(sSet[2]) : 3;
	TrimString(sSet[3]);
	int iChance4 = (sSet[3][0] != '\0') ? StringToInt(sSet[3]) : 3;
	TrimString(sSet[4]);
	int iChance5 = (sSet[4][0] != '\0') ? StringToInt(sSet[4]) : 3;
	TrimString(sSet[5]);
	int iChance6 = (sSet[5][0] != '\0') ? StringToInt(sSet[5]) : 3;
	char sPropsAttached[7];
	sPropsAttached = !g_bTankConfig[g_iTankType[client]] ? g_sPropsAttached[g_iTankType[client]] : g_sPropsAttached2[g_iTankType[client]];
	if (GetRandomInt(1, iChance1) == 1 && StrContains(sPropsAttached, "1") != -1)
	{
		CreateTimer(0.25, tTimerBlurEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
	float flOrigin[3];
	float flAngles[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
	GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
	int iBeam[7];
	int iRandom = GetRandomInt(1, 6);
	for (int iLight = 1; iLight <= iRandom; iLight++)
	{
		if (GetRandomInt(1, iChance2) == 1 && StrContains(sPropsAttached, "2") != -1)
		{
			iBeam[iLight] = CreateEntityByName("beam_spotlight");
			if (bIsValidEntity(iBeam[iLight]))
			{
				DispatchKeyValueVector(iBeam[iLight], "origin", flOrigin);
				DispatchKeyValueVector(iBeam[iLight], "angles", flAngles);
				DispatchKeyValue(iBeam[iLight], "spotlightwidth", "10");
				DispatchKeyValue(iBeam[iLight], "spotlightlength", "60");
				DispatchKeyValue(iBeam[iLight], "spawnflags", "3");
				SetEntityRenderColor(iBeam[iLight], red, green, blue, alpha);
				DispatchKeyValue(iBeam[iLight], "maxspeed", "100");
				DispatchKeyValue(iBeam[iLight], "HDRColorScale", "0.7");
				DispatchKeyValue(iBeam[iLight], "fadescale", "1");
				DispatchKeyValue(iBeam[iLight], "fademindist", "-1");
				vSetEntityParent(iBeam[iLight], client);
				switch (iLight)
				{
					case 1, 4:
					{
						SetVariantString("mouth");
						vSetVector(flAngles, -90.0, 0.0, 0.0);
					}
					case 2, 5:
					{
						SetVariantString("rhand");
						vSetVector(flAngles, 90.0, 0.0, 0.0);
					}
					case 3, 6:
					{
						SetVariantString("lhand");
						vSetVector(flAngles, -90.0, 0.0, 0.0);
					}
				}
				AcceptEntityInput(iBeam[iLight], "SetParentAttachment");
				AcceptEntityInput(iBeam[iLight], "Enable");
				AcceptEntityInput(iBeam[iLight], "DisableCollision");
				SetEntPropEnt(iBeam[iLight], Prop_Send, "m_hOwnerEntity", client);
				TeleportEntity(iBeam[iLight], NULL_VECTOR, flAngles, NULL_VECTOR);
				DispatchSpawn(iBeam[iLight]);
				SDKHook(iBeam[iLight], SDKHook_SetTransmit, SetTransmit);
			}
		}
	}
	GetClientEyePosition(client, flOrigin);
	GetClientAbsAngles(client, flAngles);
	int iJetpack[5];
	int iRandom2 = GetRandomInt(1, 4);
	for (int iOzTank = 1; iOzTank <= iRandom2; iOzTank++)
	{
		if (GetRandomInt(1, iChance3) == 1 && StrContains(sPropsAttached, "3") != -1)
		{
			iJetpack[iOzTank] = CreateEntityByName("prop_dynamic_override");
			if (bIsValidEntity(iJetpack[iOzTank]))
			{
				SetEntityModel(iJetpack[iOzTank], MODEL_JETPACK);
				SetEntityRenderColor(iJetpack[iOzTank], red2, green2, blue2, alpha2);
				SetEntProp(iJetpack[iOzTank], Prop_Data, "m_takedamage", 0, 1);
				SetEntProp(iJetpack[iOzTank], Prop_Data, "m_CollisionGroup", 2);
				vSetEntityParent(iJetpack[iOzTank], client);
				switch (iOzTank)
				{
					case 1:
					{
						SetVariantString("rshoulder");
						vSetVector(flOrigin, 0.0, 30.0, 8.0);
					}
					case 2:
					{
						SetVariantString("lshoulder");
						vSetVector(flOrigin, 0.0, 30.0, -8.0);
					}
					case 3:
					{
						SetVariantString("rfoot");
						vSetVector(flOrigin, 0.0, 30.0, 8.0);
					}
					case 4:
					{
						SetVariantString("lfoot");
						vSetVector(flOrigin, 0.0, 30.0, -8.0);
					}
				}
				AcceptEntityInput(iJetpack[iOzTank], "SetParentAttachment");
				float flAngles2[3];
				vSetVector(flAngles2, 0.0, 0.0, 1.0);
				GetVectorAngles(flAngles2, flAngles2);
				vCopyVector(flAngles, flAngles2);
				flAngles2[2] += 90.0;
				DispatchKeyValueVector(iJetpack[iOzTank], "origin", flOrigin);
				DispatchKeyValueVector(iJetpack[iOzTank], "angles", flAngles2);
				AcceptEntityInput(iJetpack[iOzTank], "Enable");
				AcceptEntityInput(iJetpack[iOzTank], "DisableCollision");
				SetEntPropEnt(iJetpack[iOzTank], Prop_Send, "m_hOwnerEntity", client);
				TeleportEntity(iJetpack[iOzTank], flOrigin, NULL_VECTOR, flAngles2);
				DispatchSpawn(iJetpack[iOzTank]);
				if (GetRandomInt(1, iChance4) == 1 && StrContains(sPropsAttached, "4") != -1)
				{
					int iFlame = CreateEntityByName("env_steam");
					if (bIsValidEntity(iFlame))
					{
						SetEntityRenderColor(iFlame, red3, green3, blue3, alpha3);
						DispatchKeyValue(iFlame, "spawnflags", "1");
						DispatchKeyValue(iFlame, "Type", "0");
						DispatchKeyValue(iFlame, "InitialState", "1");
						DispatchKeyValue(iFlame, "Spreadspeed", "1");
						DispatchKeyValue(iFlame, "Speed", "250");
						DispatchKeyValue(iFlame, "Startsize", "6");
						DispatchKeyValue(iFlame, "EndSize", "8");
						DispatchKeyValue(iFlame, "Rate", "555");
						DispatchKeyValue(iFlame, "JetLength", "40");
						vSetEntityParent(iFlame, iJetpack[iOzTank]);
						SetEntPropEnt(iFlame, Prop_Send, "m_hOwnerEntity", client);
						float flOrigin2[3];
						float flAngles3[3];
						vSetVector(flOrigin2, -2.0, 0.0, 26.0);
						vSetVector(flAngles3, 0.0, 0.0, 1.0);
						GetVectorAngles(flAngles3, flAngles3);
						TeleportEntity(iFlame, flOrigin2, flAngles3, NULL_VECTOR);
						DispatchSpawn(iFlame);
						AcceptEntityInput(iFlame, "TurnOn");
						SDKHook(iFlame, SDKHook_SetTransmit, SetTransmit);
					}
				}
				SDKHook(iJetpack[iOzTank], SDKHook_SetTransmit, SetTransmit);
			}
		}
	}
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
	GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
	int iConcrete[41];
	int iRandom3 = GetRandomInt(1, 40);
	for (int iRock = 1; iRock <= iRandom3; iRock++)
	{
		if (GetRandomInt(1, iChance5) == 1 && StrContains(sPropsAttached, "5") != -1)
		{
			iConcrete[iRock] = CreateEntityByName("prop_dynamic_override");
			if (bIsValidEntity(iConcrete[iRock]))
			{
				SetEntityModel(iConcrete[iRock], MODEL_CONCRETE);
				SetEntityRenderColor(iConcrete[iRock], red4, green4, blue4, alpha4);
				DispatchKeyValueVector(iConcrete[iRock], "origin", flOrigin);
				DispatchKeyValueVector(iConcrete[iRock], "angles", flAngles);
				vSetEntityParent(iConcrete[iRock], client);
				switch (iRock)
				{
					case 1, 5, 9, 13, 17, 21, 25, 29, 33, 37: SetVariantString("rshoulder");
					case 2, 6, 10, 14, 18, 22, 26, 30, 34, 38: SetVariantString("lshoulder");
					case 3, 7, 11, 15, 19, 23, 27, 31, 35, 39: SetVariantString("relbow");
					case 4, 8, 12, 16, 20, 24, 28, 32, 36, 40: SetVariantString("lelbow");
				}
				AcceptEntityInput(iConcrete[iRock], "SetParentAttachment");
				AcceptEntityInput(iConcrete[iRock], "Enable");
				AcceptEntityInput(iConcrete[iRock], "DisableCollision");
				if (bIsL4D2Game())
				{
					switch (iRock)
					{
						case 1, 2, 5, 6, 9, 10, 13, 14, 17, 18, 21, 22, 25, 26, 29, 30, 33, 34, 37, 38: SetEntPropFloat(iConcrete[iRock], Prop_Data, "m_flModelScale", 0.4);
						case 3, 4, 7, 8, 11, 12, 15, 16, 19, 20, 23, 24, 27, 28, 31, 32, 35, 36, 39, 40: SetEntPropFloat(iConcrete[iRock], Prop_Data, "m_flModelScale", 0.5);
					}
				}
				SetEntPropEnt(iConcrete[iRock], Prop_Send, "m_hOwnerEntity", client);
				flAngles[0] = flAngles[0] + GetRandomFloat(-90.0, 90.0);
				flAngles[1] = flAngles[1] + GetRandomFloat(-90.0, 90.0);
				flAngles[2] = flAngles[2] + GetRandomFloat(-90.0, 90.0);
				TeleportEntity(iConcrete[iRock], NULL_VECTOR, flAngles, NULL_VECTOR);
				DispatchSpawn(iConcrete[iRock]);
				SDKHook(iConcrete[iRock], SDKHook_SetTransmit, SetTransmit);
			}
		}
	}
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
	GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
	flAngles[0] += 90.0;
	int iWheel[5];
	int iRandom4 = GetRandomInt(1, 4);
	for (int iTire = 1; iTire <= iRandom4; iTire++)
	{
		if (GetRandomInt(1, iChance6) == 1 && StrContains(sPropsAttached, "6") != -1)
		{
			iWheel[iTire] = CreateEntityByName("prop_dynamic_override");
			if (bIsValidEntity(iWheel[iTire]))
			{
				SetEntityModel(iWheel[iTire], MODEL_TIRES);
				SetEntityRenderColor(iWheel[iTire], red5, green5, blue5, alpha5);
				DispatchKeyValueVector(iWheel[iTire], "origin", flOrigin);
				DispatchKeyValueVector(iWheel[iTire], "angles", flAngles);
				vSetEntityParent(iWheel[iTire], client);
				switch (iTire)
				{
					case 1: SetVariantString("relbow");
					case 2: SetVariantString("lelbow");
					case 3: SetVariantString("rfoot");
					case 4: SetVariantString("lfoot");
				}
				AcceptEntityInput(iWheel[iTire], "SetParentAttachment");
				AcceptEntityInput(iWheel[iTire], "Enable");
				AcceptEntityInput(iWheel[iTire], "DisableCollision");
				if (bIsL4D2Game())
				{
					SetEntPropFloat(iWheel[iTire], Prop_Data, "m_flModelScale", 1.5);
				}
				SetEntPropEnt(iWheel[iTire], Prop_Send, "m_hOwnerEntity", client);
				TeleportEntity(iWheel[iTire], NULL_VECTOR, flAngles, NULL_VECTOR);
				DispatchSpawn(iWheel[iTire]);
				SDKHook(iWheel[iTire], SDKHook_SetTransmit, SetTransmit);
			}
		}
	}
}

void vCopyVector(float source[3], float target[3])
{
	target[0] = source[0];
	target[1] = source[1];
	target[2] = source[2];
}

void vDeleteEntity(int entity, float time = 0.1)
{
	if (bIsValidEntRef(entity))
	{
		char sVariant[64];
		Format(sVariant, sizeof(sVariant), "OnUser1 !self:kill::%f:1", time);
		AcceptEntityInput(entity, "ClearParent");
		SetVariantString(sVariant);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");
	}
}

void vGetCurrentCount(char[] config)
{
	int iPlayerCount = iGetPlayerCount();
	Format(config, strlen(config), "cfg/sourcemod/super_tanks++/playercount_configs/%d.cfg", iPlayerCount);
}

void vGetCurrentDay(char[] config)
{
	char sDay[9];
	char sDayNumber[2];
	FormatTime(sDayNumber, sizeof(sDayNumber), "%w", GetTime());
	int iDayNumber = StringToInt(sDayNumber);
	switch (iDayNumber)
	{
		case 6: sDay = "saturday";
		case 5: sDay = "friday";
		case 4: sDay = "thursday";
		case 3: sDay = "wednesday";
		case 2: sDay = "tuesday";
		case 1: sDay = "monday";
		default: sDay = "sunday";
	}
	Format(config, strlen(config), "cfg/sourcemod/super_tanks++/daily_configs/%s.cfg", sDay);
}

void vGetCurrentDifficulty(ConVar convar, char[] config)
{
	char sDifficulty[11];
	convar.GetString(sDifficulty, sizeof(sDifficulty));
	Format(config, strlen(config), "cfg/sourcemod/super_tanks++/difficulty_configs/%s.cfg", sDifficulty);
}

void vGetCurrentMap(char[] config)
{
	char sMap[64];
	GetCurrentMap(sMap, sizeof(sMap));
	Format(config, strlen(config), (bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_map_configs/%s.cfg" : "cfg/sourcemod/super_tanks++/l4d_map_configs/%s.cfg"), sMap);
}

void vGetCurrentMode(ConVar convar, char[] config)
{
	char sMode[64];
	convar.GetString(sMode, sizeof(sMode));
	Format(config, strlen(config), (bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_gamemode_configs/%s.cfg" : "cfg/sourcemod/super_tanks++/l4d_gamemode_configs/%s.cfg"), sMode);
}

void vMultiTargetFilters(int toggle)
{
	switch (toggle)
	{
		case 0:
		{
			RemoveMultiTargetFilter("@smokers", bSmokerFilter);
			RemoveMultiTargetFilter("@boomers", bBoomerFilter);
			RemoveMultiTargetFilter("@hunters", bHunterFilter);
			RemoveMultiTargetFilter("@spitters", bSpitterFilter);
			RemoveMultiTargetFilter("@jockeys", bJockeyFilter);
			RemoveMultiTargetFilter("@chargers", bChargerFilter);
			RemoveMultiTargetFilter("@tanks", bTankFilter);
		}
		case 1:
		{
			AddMultiTargetFilter("@smokers", bSmokerFilter, "all Smokers", false);
			AddMultiTargetFilter("@boomers", bBoomerFilter, "all Boomers", false);
			AddMultiTargetFilter("@hunters", bHunterFilter, "all Hunters", false);
			AddMultiTargetFilter("@spitters", bSpitterFilter, "all Spitters", false);
			AddMultiTargetFilter("@jockeys", bJockeyFilter, "all Jockeys", false);
			AddMultiTargetFilter("@chargers", bChargerFilter, "all Chargers", false);
			AddMultiTargetFilter("@tanks", bTankFilter, "all Tanks", false);
		}
	}
}

void vParticleEffects(int client)
{
	int iParticleEffect = !g_bTankConfig[g_iTankType[client]] ? g_iParticleEffect[g_iTankType[client]] : g_iParticleEffect2[g_iTankType[client]];
	char sEffect[8];
	sEffect = !g_bTankConfig[g_iTankType[client]] ? g_sParticleEffects[g_iTankType[client]] : g_sParticleEffects2[g_iTankType[client]];
	if (iParticleEffect == 1 && bIsTank(client))
	{
		if (StrContains(sEffect, "1") != -1)
		{
			CreateTimer(0.75, tTimerBloodEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		if (StrContains(sEffect, "2") != -1)
		{
			CreateTimer(0.75, tTimerElectricEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		if (StrContains(sEffect, "3") != -1)
		{
			CreateTimer(0.75, tTimerFireEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		if (StrContains(sEffect, "4") != -1)
		{
			CreateTimer(2.0, tTimerIceEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		if (StrContains(sEffect, "5") != -1)
		{
			CreateTimer(6.0, tTimerMeteorEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		if (StrContains(sEffect, "6") != -1)
		{
			CreateTimer(1.5, tTimerSmokeEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		if (StrContains(sEffect, "7") != -1 && bIsL4D2Game())
		{
			CreateTimer(2.0, tTimerSpitEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}

void vPrecacheParticle(char[] particlename)
{
	int iParticle = CreateEntityByName("info_particle_system");
	if (IsValidEntity(iParticle))
	{
		DispatchKeyValue(iParticle, "effect_name", particlename);
		DispatchSpawn(iParticle);
		ActivateEntity(iParticle);
		AcceptEntityInput(iParticle, "Start");
		vSetEntityParent(iParticle, iParticle);
		iParticle = EntIndexToEntRef(iParticle);
		vDeleteEntity(iParticle);
	}
}

void vSetColor(int client, int value)
{
	char sSet[2][16];
	char sTankColors[28];
	sTankColors = !g_bTankConfig[value] ? g_sTankColors[value] : g_sTankColors2[value];
	TrimString(sTankColors);
	ExplodeString(sTankColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
	char sRGB[4][4];
	ExplodeString(sSet[0], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
	TrimString(sRGB[0]);
	int iRed = (sRGB[0][0] != '\0') ? StringToInt(sRGB[0]) : 255;
	TrimString(sRGB[1]);
	int iGreen = (sRGB[1][0] != '\0') ? StringToInt(sRGB[1]) : 255;
	TrimString(sRGB[2]);
	int iBlue = (sRGB[2][0] != '\0') ? StringToInt(sRGB[2]) : 255;
	TrimString(sRGB[3]);
	int iAlpha = (sRGB[3][0] != '\0') ? StringToInt(sRGB[3]) : 255;
	char sGlow[3][4];
	ExplodeString(sSet[1], ",", sGlow, sizeof(sGlow), sizeof(sGlow[]));
	TrimString(sGlow[0]);
	int iRed2 = (sGlow[0][0] != '\0') ? StringToInt(sGlow[0]) : 255;
	TrimString(sGlow[1]);
	int iGreen2 = (sGlow[1][0] != '\0') ? StringToInt(sGlow[1]) : 255;
	TrimString(sGlow[2]);
	int iBlue2 = (sGlow[2][0] != '\0') ? StringToInt(sGlow[2]) : 255;
	int iGlowEffect = !g_bTankConfig[value] ? g_iGlowEffect[value] : g_iGlowEffect2[value];
	if (iGlowEffect == 1 && bIsL4D2Game())
	{
		SetEntProp(client, Prop_Send, "m_iGlowType", 3);
		SetEntProp(client, Prop_Send, "m_glowColorOverride", iGetRGBColor(iRed2, iGreen2, iBlue2));
	}
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, iRed, iGreen, iBlue, iAlpha);
	g_iTankType[client] = value;
}

void vSetEntityParent(int entity, int parent)
{
	SetVariantString("!activator");
	AcceptEntityInput(entity, "SetParent", parent);
}

void vSetName(int client, char[] name = "Tank")
{
	char sSet[5][16];
	char sPropsColors[80];
	sPropsColors = !g_bTankConfig[g_iTankType[client]] ? g_sPropsColors[g_iTankType[client]] : g_sPropsColors2[g_iTankType[client]];
	TrimString(sPropsColors);
	ExplodeString(sPropsColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
	char sRGB[4][4];
	ExplodeString(sSet[0], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
	TrimString(sRGB[0]);
	int iRed = (sRGB[0][0] != '\0') ? StringToInt(sRGB[0]) : 255;
	TrimString(sRGB[1]);
	int iGreen = (sRGB[1][0] != '\0') ? StringToInt(sRGB[1]) : 255;
	TrimString(sRGB[2]);
	int iBlue = (sRGB[2][0] != '\0') ? StringToInt(sRGB[2]) : 255;
	TrimString(sRGB[3]);
	int iAlpha = (sRGB[3][0] != '\0') ? StringToInt(sRGB[3]) : 255;
	char sRGB2[4][4];
	ExplodeString(sSet[1], ",", sRGB2, sizeof(sRGB2), sizeof(sRGB2[]));
	TrimString(sRGB2[0]);
	int iRed2 = (sRGB2[0][0] != '\0') ? StringToInt(sRGB2[0]) : 255;
	TrimString(sRGB2[1]);
	int iGreen2 = (sRGB2[1][0] != '\0') ? StringToInt(sRGB2[1]) : 255;
	TrimString(sRGB2[2]);
	int iBlue2 = (sRGB2[2][0] != '\0') ? StringToInt(sRGB2[2]) : 255;
	TrimString(sRGB2[3]);
	int iAlpha2 = (sRGB2[3][0] != '\0') ? StringToInt(sRGB2[3]) : 255;
	char sRGB3[4][4];
	ExplodeString(sSet[2], ",", sRGB3, sizeof(sRGB3), sizeof(sRGB3[]));
	TrimString(sRGB3[0]);
	int iRed3 = (sRGB3[0][0] != '\0') ? StringToInt(sRGB3[0]) : 255;
	TrimString(sRGB3[1]);
	int iGreen3 = (sRGB3[1][0] != '\0') ? StringToInt(sRGB3[1]) : 255;
	TrimString(sRGB3[2]);
	int iBlue3 = (sRGB3[2][0] != '\0') ? StringToInt(sRGB3[2]) : 255;
	TrimString(sRGB3[3]);
	int iAlpha3 = (sRGB3[3][0] != '\0') ? StringToInt(sRGB3[3]) : 255;
	char sRGB4[4][4];
	ExplodeString(sSet[3], ",", sRGB4, sizeof(sRGB4), sizeof(sRGB4[]));
	TrimString(sRGB4[0]);
	int iRed4 = (sRGB4[0][0] != '\0') ? StringToInt(sRGB4[0]) : 255;
	TrimString(sRGB4[1]);
	int iGreen4 = (sRGB4[1][0] != '\0') ? StringToInt(sRGB4[1]) : 255;
	TrimString(sRGB4[2]);
	int iBlue4 = (sRGB4[2][0] != '\0') ? StringToInt(sRGB4[2]) : 255;
	TrimString(sRGB4[3]);
	int iAlpha4 = (sRGB4[3][0] != '\0') ? StringToInt(sRGB4[3]) : 255;
	char sRGB5[4][4];
	ExplodeString(sSet[4], ",", sRGB5, sizeof(sRGB5), sizeof(sRGB5[]));
	TrimString(sRGB5[0]);
	int iRed5 = (sRGB5[0][0] != '\0') ? StringToInt(sRGB5[0]) : 255;
	TrimString(sRGB5[1]);
	int iGreen5 = (sRGB5[1][0] != '\0') ? StringToInt(sRGB5[1]) : 255;
	TrimString(sRGB5[2]);
	int iBlue5 = (sRGB5[2][0] != '\0') ? StringToInt(sRGB5[2]) : 255;
	TrimString(sRGB5[3]);
	int iAlpha5 = (sRGB5[3][0] != '\0') ? StringToInt(sRGB5[3]) : 255;
	if (bIsTank(client))
	{
		vSetProps(client, iRed, iGreen, iBlue, iAlpha, iRed2, iGreen2, iBlue2, iAlpha2, iRed3, iGreen3, iBlue3, iAlpha3, iRed4, iGreen4, iBlue4, iAlpha4, iRed5, iGreen5, iBlue5, iAlpha5);
		if (IsFakeClient(client))
		{
			SetClientInfo(client, "name", name);
			int iAnnounceArrival = !g_bGeneralConfig ? g_iAnnounceArrival : g_iAnnounceArrival2;
			if (iAnnounceArrival == 1)
			{
				switch (GetRandomInt(1, 10))
				{
					case 1: PrintToChatAll("\x04%s\x05 %s\x01 has appeared!", ST_PREFIX, name);
					case 2: PrintToChatAll("\x04%s\x01 Here comes\x05 %s\x01!", ST_PREFIX, name);
					case 3: PrintToChatAll("\x04%s\x05 %s\x01 is ready to kill!", ST_PREFIX, name);
					case 4: PrintToChatAll("\x04%s\x01 Are you ready to face\x05 %s\x01?", ST_PREFIX, name);
					case 5: PrintToChatAll("\x04%s\x05 %s\x01 came for a challenge!", ST_PREFIX, name);
					case 6: PrintToChatAll("\x04%s\x01 Get ready!\x05 %s\x01 is coming!", ST_PREFIX, name);
					case 7: PrintToChatAll("\x04%s\x05 %s\x01 is here!", ST_PREFIX, name);
					case 8: PrintToChatAll("\x04%s\x01 Oh no!\x05 %s\x01 is nearing!", ST_PREFIX, name);
					case 9: PrintToChatAll("\x04%s\x05 %s\x01 joined the game...", ST_PREFIX, name);
					case 10: PrintToChatAll("\x04%s\x01 It seems\x05 %s\x01 is joining your company...", ST_PREFIX, name);
				}
			}
		}
	}
}

void vSetProps(int client, int red, int green, int blue, int alpha, int red2, int green2, int blue2, int alpha2, int red3, int green3, int blue3, int alpha3, int red4, int green4, int blue4, int alpha4, int red5, int green5, int blue5, int alpha5)
{
	if (bIsTank(client))
	{
		vAttachProps(client, red, green, blue, alpha, red2, green2, blue2, alpha2, red3, green3, blue3, alpha3, red4, green4, blue4, alpha4, red5, green5, blue5, alpha5);
	}
}

void vSetVector(float target[3], float x, float y, float z)
{
	target[0] = x;
	target[1] = y;
	target[2] = z;
}

void vSpawnTank(int wave)
{
	if (iGetTankCount() < wave)
	{
		int iTank = CreateFakeClient("Tank");
		if (iTank > 0)
		{
			ChangeClientTeam(iTank, 3);
			char sCommand[32];
			sCommand = bIsL4D2Game() ? "z_spawn_old" : "z_spawn";
			int iCmdFlags = GetCommandFlags(sCommand);
			SetCommandFlags(sCommand, iCmdFlags & ~FCVAR_CHEAT);
			FakeClientCommand(iTank, "%s tank auto", sCommand);
			SetCommandFlags(sCommand, iCmdFlags|FCVAR_CHEAT);
			KickClient(iTank);
		}
	}
}

void vTankCountCheck(int wave)
{
	if (iGetTankCount() < wave)
	{
		CreateTimer(5.0, tTimerSpawnTanks, wave, TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vThrowInterval(int client, float time)
{
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if (bIsTank(client) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(client))))
	{
		int iAbility = GetEntPropEnt(client, Prop_Send, "m_customAbility");
		if (iAbility > 0)
		{
			SetEntPropFloat(iAbility, Prop_Send, "m_duration", time);
			SetEntPropFloat(iAbility, Prop_Send, "m_timestamp", GetGameTime() + time);
		}
	}
}

int iGetHumanCount()
{
	int iHumanCount;
	for (int iHuman = 1; iHuman <= MaxClients; iHuman++)
	{
		if (bIsHumanSurvivor(iHuman))
		{
			iHumanCount++;
		}
	}
	return iHumanCount;
}

int iGetPlayerCount()
{
	int iPlayerCount;
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidHumanClient(iPlayer))
		{
			iPlayerCount++;
		}
	}
	return iPlayerCount;
}

int iGetRGBColor(int red, int green, int blue) 
{
	return (blue * 65536) + (green * 256) + red;
}

int iGetTankCount()
{
	int iTankCount;
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank))
		{
			iTankCount++;
		}
	}
	return iTankCount;
}

bool bHasIdlePlayer(int client)
{
	int iIdler = GetClientOfUserId(GetEntData(client, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID")));
	if (iIdler)
	{
		if (IsClientInGame(iIdler) && !IsFakeClient(iIdler) && (GetClientTeam(iIdler) != 2))
		{
			return true;
		}
	}
	return false;
}

bool bIsFinaleMap()
{
	return FindEntityByClassname(-1, "trigger_finale") != -1;
}

bool bIsHumanSurvivor(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2 && IsPlayerAlive(client) && !IsClientInKickQueue(client) && !IsFakeClient(client) && !bHasIdlePlayer(client) && !bIsPlayerIdle(client);
}

bool bIsPlayerBurning(int client)
{
	if (GetEntPropFloat(client, Prop_Send, "m_burnPercent") > 0)
	{
		return true;
	}
	return false;
}

bool bIsPlayerIdle(int client)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (!IsClientInGame(iPlayer) || GetClientTeam(iPlayer) != 2 || !IsFakeClient(iPlayer) || !bHasIdlePlayer(iPlayer))
		{
			continue;
		}
		int iIdler = GetClientOfUserId(GetEntData(iPlayer, FindSendPropInfo("SurvivorBot", "m_humanSpectatorUserID")));
		if (iIdler == client)
		{
			return true;
		}
	}
	return false;
}

bool bIsPlayerIncapacitated(int client)
{
	if (GetEntProp(client, Prop_Send, "m_isIncapacitated", 1))
	{
		return true;
	}
	return false;
}

bool bIsPluginEnabled(ConVar convar, int mode, char[] enabled, char[] disabled)
{
	if (convar == null)
	{
		return false;
	}
	if (mode != 0)
	{
		g_iCurrentMode = 0;
		int iGameMode = CreateEntityByName("info_gamemode");
		DispatchSpawn(iGameMode);
		HookSingleEntityOutput(iGameMode, "OnCoop", vGameMode, true);
		HookSingleEntityOutput(iGameMode, "OnSurvival", vGameMode, true);
		HookSingleEntityOutput(iGameMode, "OnVersus", vGameMode, true);
		HookSingleEntityOutput(iGameMode, "OnScavenge", vGameMode, true);
		ActivateEntity(iGameMode);
		AcceptEntityInput(iGameMode, "PostSpawnActivate");
		AcceptEntityInput(iGameMode, "Kill");
		if (g_iCurrentMode == 0 || !(mode & g_iCurrentMode))
		{
			return false;
		}
	}
	char sGameMode[64];
	char sGameModes[64];
	convar.GetString(sGameMode, sizeof(sGameMode));
	Format(sGameMode, sizeof(sGameMode), ",%s,", sGameMode);
	if (strcmp(enabled, ""))
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", enabled);
		if (StrContains(sGameModes, sGameMode, false) == -1)
		{
			return false;
		}
	}
	if (strcmp(disabled, ""))
	{
		Format(sGameModes, sizeof(sGameModes), ",%s,", disabled);
		if (StrContains(sGameModes, sGameMode, false) != -1)
		{
			return false;
		}
	}
	return true;
}

bool bIsValidClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client);
}

bool bIsValidEntity(int entity)
{
	return entity > 0 && entity <= 2048 && IsValidEntity(entity);
}

bool bIsValidEntRef(int entity)
{
	return entity && EntRefToEntIndex(entity) != INVALID_ENT_REFERENCE;
}

bool bIsValidHumanClient(int client)
{
	return client > 0 && client <= MaxClients && IsClientInGame(client) && !IsClientInKickQueue(client) && !IsFakeClient(client);
}

public bool bBoomerFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsBoomer(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bChargerFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsCharger(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bHunterFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsHunter(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bJockeyFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsJockey(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bSmokerFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSmoker(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bSpitterFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsSpitter(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public bool bTankFilter(const char[] pattern, Handle clients)
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsTank(iPlayer))
		{
			PushArrayCell(clients, iPlayer);
		}
	}
	return true;
}

public void vGameMode(const char[] output, int caller, int activator, float delay)
{
	if (strcmp(output, "OnCoop") == 0)
	{
		g_iCurrentMode = 1;
	}
	else if (strcmp(output, "OnVersus") == 0)
	{
		g_iCurrentMode = 2;
	}
	else if (strcmp(output, "OnSurvival") == 0)
	{
		g_iCurrentMode = 4;
	}
	else if (strcmp(output, "OnScavenge") == 0)
	{
		g_iCurrentMode = 8;
	}
}

public void vSTGameDifficultyCvar(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (StrContains(g_sConfigExecute, "1") != -1)
	{
		char sDifficultyConfig[512];
		vGetCurrentDifficulty(g_cvSTFindConVar[0], sDifficultyConfig);
		vLoadConfigs(sDifficultyConfig);
	}
}

public Action tTimerBloodEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	char sEffect[8];
	sEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (StrContains(sEffect, "1") == -1 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if (bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		vAttachParticle(iTank, PARTICLE_BLOOD, 0.75, 30.0);
	}
	return Plugin_Continue;
}

public Action tTimerBlurEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	char sEffect[7];
	sEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_sPropsAttached[g_iTankType[iTank]] : g_sPropsAttached2[g_iTankType[iTank]];
	if (StrContains(sEffect, "1") == -1 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if (bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		char sSet[2][16];
		char sTankColors[28];
		sTankColors = !g_bTankConfig[g_iTankType[iTank]] ? g_sTankColors[g_iTankType[iTank]] : g_sTankColors2[g_iTankType[iTank]];
		TrimString(sTankColors);
		ExplodeString(sTankColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
		char sRGB[4][4];
		ExplodeString(sSet[0], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
		TrimString(sRGB[0]);
		int iRed = (sRGB[0][0] != '\0') ? StringToInt(sRGB[0]) : 255;
		TrimString(sRGB[1]);
		int iGreen = (sRGB[1][0] != '\0') ? StringToInt(sRGB[1]) : 255;
		TrimString(sRGB[2]);
		int iBlue = (sRGB[2][0] != '\0') ? StringToInt(sRGB[2]) : 255;
		TrimString(sRGB[3]);
		int iAlpha = (sRGB[3][0] != '\0') ? StringToInt(sRGB[3]) : 255;
		float flTankPos[3];
		float flTankAng[3];
		GetClientAbsOrigin(iTank, flTankPos);
		GetClientAbsAngles(iTank, flTankAng);
		int iAnim = GetEntProp(iTank, Prop_Send, "m_nSequence");
		int iTankModel = CreateEntityByName("prop_dynamic");
		if (bIsValidEntity(iTankModel))
		{
			SetEntityModel(iTankModel, MODEL_TANK);
			SetEntPropEnt(iTankModel, Prop_Send, "m_hOwnerEntity", iTank);
			DispatchKeyValue(iTankModel, "solid", "6");
			TeleportEntity(iTankModel, flTankPos, flTankAng, NULL_VECTOR);
			DispatchSpawn(iTankModel);
			AcceptEntityInput(iTankModel, "DisableCollision");
			SetEntityRenderColor(iTankModel, iRed, iGreen, iBlue, iAlpha);
			SetEntProp(iTankModel, Prop_Send, "m_nSequence", iAnim);
			SetEntPropFloat(iTankModel, Prop_Send, "m_flPlaybackRate", 5.0);
			iTankModel = EntIndexToEntRef(iTankModel);
			vDeleteEntity(iTankModel, 0.3);
		}
	}
	return Plugin_Continue;
}

public Action tTimerElectricEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	char sEffect[8];
	sEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (StrContains(sEffect, "2") == -1 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if (bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		vAttachParticle(iTank, PARTICLE_ELECTRICITY, 0.75, 30.0);
	}
	return Plugin_Continue;
}

public Action tTimerFireEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	char sEffect[8];
	sEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (StrContains(sEffect, "3") == -1 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if (bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		vAttachParticle(iTank, PARTICLE_FIRE, 0.75);
	}
	return Plugin_Continue;
}

public Action tTimerIceEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	char sEffect[8];
	sEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (StrContains(sEffect, "4") == -1 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if (bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		vAttachParticle(iTank, PARTICLE_ICE, 2.0, 30.0);
	}
	return Plugin_Continue;
}

public Action tTimerKillStuckTank(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	if (bIsTank(iTank) && bIsPlayerIncapacitated(iTank))
	{
		ForcePlayerSuicide(iTank);
	}
	return Plugin_Continue;
}

public Action tTimerMeteorEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	char sEffect[8];
	sEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (StrContains(sEffect, "5") == -1 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if (bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		vAttachParticle(iTank, PARTICLE_METEOR, 6.0, 30.0);
	}
	return Plugin_Continue;
}

public Action tTimerSmokeEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	char sEffect[8];
	sEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (StrContains(sEffect, "6") == -1 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if (bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		vAttachParticle(iTank, PARTICLE_SMOKE, 1.5);
	}
	return Plugin_Continue;
}

public Action tTimerSpitEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	char sEffect[8];
	sEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (StrContains(sEffect, "7") == -1 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if (bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		vAttachParticle(iTank, PARTICLE_SPIT, 2.0, 30.0);
	}
	return Plugin_Continue;
}

public Action tTimerSetTransmit(Handle timer, any entity)
{
	if ((entity = EntRefToEntIndex(entity)) == INVALID_ENT_REFERENCE)
	{
		return Plugin_Stop;
	}
	if (bIsValidEntity(entity))
	{
		SDKHook(entity, SDKHook_SetTransmit, SetTransmit);
	}
	return Plugin_Continue;
}

public Action tTimerUpdatePlayerCount(Handle timer)
{
	if (!g_bPluginEnabled || StrContains(g_sConfigExecute, "5") == -1)
	{
		return Plugin_Continue;
	}
	char sCountConfig[512];
	vGetCurrentCount(sCountConfig);
	vLoadConfigs(sCountConfig);
	return Plugin_Continue;
}

public Action tTimerTankHealthUpdate(Handle timer)
{
	if (!g_bPluginEnabled)
	{
		return Plugin_Continue;
	}
	int iDisplayHealth = !g_bGeneralConfig ? g_iDisplayHealth : g_iDisplayHealth2;
	if (iDisplayHealth > 0)
	{
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(iSurvivor))
			{
				int iTarget = GetClientAimTarget(iSurvivor, false);
				if (bIsValidEntity(iTarget))
				{
					char sClassname[32];
					GetEntityClassname(iTarget, sClassname, sizeof(sClassname));
					if (strcmp(sClassname, "player") == 0)
					{
						int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
						if (bIsTank(iTarget) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTarget))))
						{
							int iHealth = GetClientHealth(iTarget);
							int iDisplay = !g_bGeneralConfig ? g_iDisplayHealth : g_iDisplayHealth2;
							switch (iDisplay)
							{
								case 1: PrintHintText(iSurvivor, "%s %N", ST_PREFIX, iTarget);
								case 2: PrintHintText(iSurvivor, "%s %d HP", ST_PREFIX, iHealth);
								case 3: PrintHintText(iSurvivor, "%s %N (%d HP)", ST_PREFIX, iTarget, iHealth);
							}
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action tTimerTankTypeUpdate(Handle timer)
{
	if (!g_bPluginEnabled)
	{
		return Plugin_Continue;
	}
	g_cvSTFindConVar[3].SetString("32");
	if (iGetTankCount() > 0)
	{
		for (int iTank = 1; iTank <= MaxClients; iTank++)
		{
			int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
			if (bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
			{
				Call_StartForward(g_hAbility);
				Call_PushCell(iTank);
				Call_Finish();
				int iFireImmunity = !g_bTankConfig[g_iTankType[iTank]] ? g_iFireImmunity[g_iTankType[iTank]] : g_iFireImmunity2[g_iTankType[iTank]];
				if (iFireImmunity == 1 && bIsPlayerBurning(iTank))
				{
					ExtinguishEntity(iTank);
					SetEntPropFloat(iTank, Prop_Send, "m_burnPercent", 1.0);
				}
				float flRunSpeed = !g_bTankConfig[g_iTankType[iTank]] ? g_flRunSpeed[g_iTankType[iTank]] : g_flRunSpeed2[g_iTankType[iTank]];
				SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", flRunSpeed);
			}
		}
	}
	return Plugin_Continue;
}

public Action tTimerTankSpawn(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if (bIsTank(iTank) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		Call_StartForward(g_hSpawn);
		Call_PushCell(iTank);
		Call_Finish();
		vParticleEffects(iTank);
		float flThrowInterval = !g_bTankConfig[g_iTankType[iTank]] ? g_flThrowInterval[g_iTankType[iTank]] : g_flThrowInterval2[g_iTankType[iTank]];
		vThrowInterval(iTank, flThrowInterval);
		char sName[MAX_NAME_LENGTH + 1];
		sName = !g_bTankConfig[g_iTankType[iTank]] ? g_sCustomName[g_iTankType[iTank]] : g_sCustomName2[g_iTankType[iTank]];
		vSetName(iTank, sName);
		int iHealth = GetClientHealth(iTank);
		int iMultiHealth = !g_bGeneralConfig ? g_iMultiHealth : g_iMultiHealth2;
		int iExtraHealth = !g_bTankConfig[g_iTankType[iTank]] ? g_iExtraHealth[g_iTankType[iTank]] : g_iExtraHealth2[g_iTankType[iTank]];
		int iExtraHealthNormal = !g_bTankConfig[g_iTankType[iTank]] ? (iHealth + g_iExtraHealth[g_iTankType[iTank]]) : (iHealth + g_iExtraHealth2[g_iTankType[iTank]]);
		int iExtraHealthBoost = (iGetHumanCount() > 1) ? ((iHealth * iGetHumanCount()) + iExtraHealth) : iExtraHealthNormal;
		int iExtraHealthBoost2 = (iGetHumanCount() > 1) ? (iHealth + (iGetHumanCount() * iExtraHealth)) : iExtraHealthNormal;
		int iExtraHealthBoost3 = (iGetHumanCount() > 1) ? (iGetHumanCount() * (iHealth + iExtraHealth)) : iExtraHealthNormal;
		int iNoBoost = (iExtraHealthNormal > ST_MAXHEALTH) ? ST_MAXHEALTH : iExtraHealthNormal;
		int iBoost = (iExtraHealthBoost > ST_MAXHEALTH) ? ST_MAXHEALTH : iExtraHealthBoost;
		int iBoost2 = (iExtraHealthBoost2 > ST_MAXHEALTH) ? ST_MAXHEALTH : iExtraHealthBoost2;
		int iBoost3 = (iExtraHealthBoost3 > ST_MAXHEALTH) ? ST_MAXHEALTH : iExtraHealthBoost3;
		int iNegaNoBoost = (iExtraHealthNormal < iHealth) ? 1 : iExtraHealthNormal;
		int iNegaBoost = (iExtraHealthBoost < iHealth) ? 1 : iExtraHealthBoost;
		int iNegaBoost2 = (iExtraHealthBoost2 < iHealth) ? 1 : iExtraHealthBoost2;
		int iNegaBoost3 = (iExtraHealthBoost3 < iHealth) ? 1 : iExtraHealthBoost3;
		int iFinalNoHealth = (iExtraHealthNormal >= 0) ? iNoBoost : iNegaNoBoost;
		int iFinalHealth = (iExtraHealthNormal >= 0) ? iBoost : iNegaBoost;
		int iFinalHealth2 = (iExtraHealthNormal >= 0) ? iBoost2 : iNegaBoost2;
		int iFinalHealth3 = (iExtraHealthNormal >= 0) ? iBoost3 : iNegaBoost3;
		switch (iMultiHealth)
		{
			case 0: SetEntityHealth(iTank, iFinalNoHealth);
			case 1: SetEntityHealth(iTank, iFinalHealth);
			case 2: SetEntityHealth(iTank, iFinalHealth2);
			case 3: SetEntityHealth(iTank, iFinalHealth3);
		}
	}
	return Plugin_Continue;
}

public Action tTimerRockEffects(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iRock = EntRefToEntIndex(pack.ReadCell());
	char sEffect[5];
	pack.ReadString(sEffect, sizeof(sEffect));
	int iRockEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_iRockEffect[g_iTankType[iTank]] : g_iRockEffect2[g_iTankType[iTank]];
	if (iRockEffect == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	if (bIsValidEntity(iRock))
	{
		char sClassname[32];
		GetEntityClassname(iRock, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "tank_rock") == 0)
		{
			if (StrContains(sEffect, "1") != -1)
			{
				vAttachParticle(iRock, PARTICLE_BLOOD, 0.75);
			}
			if (StrContains(sEffect, "2") != -1)
			{
				vAttachParticle(iRock, PARTICLE_ELECTRICITY, 0.75);
			}
			if (StrContains(sEffect, "3") != -1)
			{
				IgniteEntity(iRock, 100.0);
			}
			if (StrContains(sEffect, "4") != -1)
			{
				vAttachParticle(iRock, PARTICLE_SPIT, 0.75);
			}
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}

public Action tTimerRockThrow(Handle timer, any entity)
{
	if ((entity = EntRefToEntIndex(entity)) == INVALID_ENT_REFERENCE)
	{
		return Plugin_Stop;
	}
	int iThrower = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
	int iHumanSupport = !g_bGeneralConfig ? g_iHumanSupport : g_iHumanSupport2;
	if (iThrower > 0 && bIsTank(iThrower) && (iHumanSupport == 1 || (iHumanSupport == 0 && IsFakeClient(iThrower))))
	{
		char sEffect[5];
		sEffect = !g_bTankConfig[g_iTankType[iThrower]] ? g_sRockEffects[g_iTankType[iThrower]] : g_sRockEffects2[g_iTankType[iThrower]];
		int iRockEffect = !g_bTankConfig[g_iTankType[iThrower]] ? g_iRockEffect[g_iTankType[iThrower]] : g_iRockEffect2[g_iTankType[iThrower]];
		if (iRockEffect == 1 && sEffect[0] != '\0')
		{
			DataPack dpDataPack;
			CreateDataTimer(0.75, tTimerRockEffects, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpDataPack.WriteCell(GetClientUserId(iThrower));
			dpDataPack.WriteCell(EntIndexToEntRef(entity));
			dpDataPack.WriteString(sEffect);
		}
		Call_StartForward(g_hRockThrow);
		Call_PushCell(iThrower);
		Call_PushCell(entity);
		Call_Finish();
	}
	return Plugin_Continue;
}

public Action tTimerSpawnTanks(Handle timer, any wave)
{
	vSpawnTank(wave);
}

public Action tTimerTankWave(Handle timer, any wave)
{
	if (iGetTankCount() == 0)
	{
		switch (wave)
		{
			case 1: g_iTankWave = 2;
			case 2: g_iTankWave = 3;
		}
	}
}

public Action tTimerReloadConfigs(Handle timer)
{
	if (!g_bPluginEnabled)
	{
		return Plugin_Continue;
	}
	g_iFileTimeNew[0] = GetFileTime(g_sSavePath, FileTime_LastChange);
	if (g_iFileTimeOld[0] != g_iFileTimeNew[0])
	{
		PrintToServer("%s Reloading config file (%s)...", ST_PREFIX, g_sSavePath);
		vLoadConfigs(g_sSavePath, true);
		g_iFileTimeOld[0] = g_iFileTimeNew[0];
	}
	if (StrContains(g_sConfigExecute, "1") != -1 && g_iConfigEnable == 1 && g_cvSTFindConVar[0] != null)
	{
		char sDifficultyConfig[512];
		vGetCurrentDifficulty(g_cvSTFindConVar[0], sDifficultyConfig);
		g_iFileTimeNew[1] = GetFileTime(sDifficultyConfig, FileTime_LastChange);
		if (g_iFileTimeOld[1] != g_iFileTimeNew[1])
		{
			PrintToServer("%s Reloading config file (%s)...", ST_PREFIX, sDifficultyConfig);
			vLoadConfigs(sDifficultyConfig);
			g_iFileTimeOld[1] = g_iFileTimeNew[1];
		}
	}
	if (StrContains(g_sConfigExecute, "2") != -1 && g_iConfigEnable == 1)
	{
		char sMapConfig[512];
		vGetCurrentMap(sMapConfig);
		g_iFileTimeNew[2] = GetFileTime(sMapConfig, FileTime_LastChange);
		if (g_iFileTimeOld[2] != g_iFileTimeNew[2])
		{
			PrintToServer("%s Reloading config file (%s)...", ST_PREFIX, sMapConfig);
			vLoadConfigs(sMapConfig);
			g_iFileTimeOld[2] = g_iFileTimeNew[2];
		}
	}
	if (StrContains(g_sConfigExecute, "3") != -1 && g_iConfigEnable == 1)
	{
		char sModeConfig[512];
		vGetCurrentMode(g_cvSTFindConVar[1], sModeConfig);
		g_iFileTimeNew[3] = GetFileTime(sModeConfig, FileTime_LastChange);
		if (g_iFileTimeOld[3] != g_iFileTimeNew[3])
		{
			PrintToServer("%s Reloading config file (%s)...", ST_PREFIX, sModeConfig);
			vLoadConfigs(sModeConfig);
			g_iFileTimeOld[3] = g_iFileTimeNew[3];
		}
	}
	if (StrContains(g_sConfigExecute, "4") != -1 && g_iConfigEnable == 1)
	{
		char sDayConfig[512];
		vGetCurrentDay(sDayConfig);
		g_iFileTimeNew[4] = GetFileTime(sDayConfig, FileTime_LastChange);
		if (g_iFileTimeOld[4] != g_iFileTimeNew[4])
		{
			PrintToServer("%s Reloading config file (%s)...", ST_PREFIX, sDayConfig);
			vLoadConfigs(sDayConfig);
			g_iFileTimeOld[4] = g_iFileTimeNew[4];
		}
	}
	if (StrContains(g_sConfigExecute, "5") != -1 && g_iConfigEnable == 1)
	{
		char sCountConfig[512];
		vGetCurrentCount(sCountConfig);
		g_iFileTimeNew[5] = GetFileTime(sCountConfig, FileTime_LastChange);
		if (g_iFileTimeOld[5] != g_iFileTimeNew[5])
		{
			PrintToServer("%s Reloading config file (%s)...", ST_PREFIX, sCountConfig);
			vLoadConfigs(sCountConfig);
			g_iFileTimeOld[5] = g_iFileTimeNew[5];
		}
	}
	return Plugin_Continue;
}