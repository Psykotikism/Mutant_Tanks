// Super Tanks++
#include <super_tanks++>
#undef REQUIRE_PLUGIN
#include <st_clone>
#define REQUIRE_PLUGIN
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = "Super Tanks++",
	author = ST_AUTHOR,
	description = "Super Tanks++ makes fighting Tanks great again!",
	version = ST_VERSION,
	url = ST_URL
};

bool g_bBoss[MAXPLAYERS + 1], g_bCloneInstalled, g_bGeneralConfig, g_bLateLoad, g_bPluginEnabled, g_bRandomized[MAXPLAYERS + 1], g_bSpawned[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1], g_bTransformed[MAXPLAYERS + 1];
char g_sBossHealthStages[ST_MAXTYPES + 1][25], g_sBossHealthStages2[ST_MAXTYPES + 1][25], g_sBossTypes[ST_MAXTYPES + 1][20], g_sBossTypes2[ST_MAXTYPES + 1][20], g_sConfigCreate[6], g_sConfigExecute[6], g_sDisabledGameModes[513], g_sEnabledGameModes[513], g_sFinaleWaves[12], g_sFinaleWaves2[12], g_sParticleEffects[ST_MAXTYPES + 1][8], g_sParticleEffects2[ST_MAXTYPES + 1][8],
	g_sPropsAttached[ST_MAXTYPES + 1][7], g_sPropsAttached2[ST_MAXTYPES + 1][7], g_sPropsChance[ST_MAXTYPES + 1][12], g_sPropsChance2[ST_MAXTYPES + 1][12], g_sPropsColors[ST_MAXTYPES + 1][80], g_sPropsColors2[ST_MAXTYPES + 1][80], g_sRockEffects[ST_MAXTYPES + 1][5], g_sRockEffects2[ST_MAXTYPES + 1][5], g_sSavePath[PLATFORM_MAX_PATH], g_sTankColors[ST_MAXTYPES + 1][28],
	g_sTankColors2[ST_MAXTYPES + 1][28], g_sTankName[ST_MAXTYPES + 1][MAX_NAME_LENGTH + 1], g_sTankName2[ST_MAXTYPES + 1][MAX_NAME_LENGTH + 1], g_sTransformTypes[ST_MAXTYPES + 1][80], g_sTransformTypes2[ST_MAXTYPES + 1][80], g_sTypeRange[10], g_sTypeRange2[10];
ConVar g_cvSTEnable, g_cvSTDifficulty, g_cvSTGameMode, g_cvSTGameTypes, g_cvSTMaxPlayerZombies;
float g_flClawDamage[ST_MAXTYPES + 1], g_flClawDamage2[ST_MAXTYPES + 1], g_flRandomInterval[ST_MAXTYPES + 1], g_flRandomInterval2[ST_MAXTYPES + 1], g_flRegularInterval, g_flRegularInterval2, g_flRockDamage[ST_MAXTYPES + 1], g_flRockDamage2[ST_MAXTYPES + 1], g_flRunSpeed[ST_MAXTYPES + 1], g_flRunSpeed2[ST_MAXTYPES + 1], g_flThrowInterval[ST_MAXTYPES + 1], g_flThrowInterval2[ST_MAXTYPES + 1], g_flTransformDelay[ST_MAXTYPES + 1], g_flTransformDelay2[ST_MAXTYPES + 1], g_flTransformDuration[ST_MAXTYPES + 1], g_flTransformDuration2[ST_MAXTYPES + 1];
Handle g_hAbilityForward, g_hBossStageForward, g_hConfigsForward, g_hEventForward, g_hRockBreakForward, g_hRockThrowForward;
int g_iAnnounceArrival, g_iAnnounceArrival2, g_iAnnounceDeath, g_iAnnounceDeath2, g_iBossStageCount[MAXPLAYERS + 1], g_iBossStages[ST_MAXTYPES + 1], g_iBossStages2[ST_MAXTYPES + 1], g_iBulletImmunity[ST_MAXTYPES + 1], g_iBulletImmunity2[ST_MAXTYPES + 1], g_iConfigEnable, g_iDisplayHealth, g_iDisplayHealth2, g_iExplosiveImmunity[ST_MAXTYPES + 1], g_iExplosiveImmunity2[ST_MAXTYPES + 1],
	g_iExtraHealth[ST_MAXTYPES + 1], g_iExtraHealth2[ST_MAXTYPES + 1], g_iFileTimeOld[7], g_iFileTimeNew[7], g_iFinalesOnly, g_iFinalesOnly2, g_iFinaleTank[ST_MAXTYPES + 1], g_iFinaleTank2[ST_MAXTYPES + 1], g_iFireImmunity[ST_MAXTYPES + 1], g_iFireImmunity2[ST_MAXTYPES + 1], g_iGameModeTypes, g_iGlowOutline[ST_MAXTYPES + 1], g_iGlowOutline2[ST_MAXTYPES + 1], g_iMeleeImmunity[ST_MAXTYPES + 1],
	g_iMeleeImmunity2[ST_MAXTYPES + 1], g_iMultiHealth, g_iMultiHealth2, g_iParticleEffect[ST_MAXTYPES + 1], g_iParticleEffect2[ST_MAXTYPES + 1], g_iPluginEnabled, g_iPluginEnabled2, g_iRegularAmount, g_iRegularAmount2, g_iRegularWave, g_iRegularWave2, g_iRockEffect[ST_MAXTYPES + 1], g_iRockEffect2[ST_MAXTYPES + 1], g_iSpawnMode[ST_MAXTYPES + 1], g_iSpawnMode2[ST_MAXTYPES + 1],
	g_iTankEnabled[ST_MAXTYPES + 1], g_iTankEnabled2[ST_MAXTYPES + 1], g_iTankHealth[MAXPLAYERS + 1], g_iTankNote[ST_MAXTYPES + 1], g_iTankNote2[ST_MAXTYPES + 1], g_iTankType[MAXPLAYERS + 1], g_iTankWave, g_iType, g_iTypeLimit[ST_MAXTYPES + 1], g_iTypeLimit2[ST_MAXTYPES + 1];
TopMenu g_tmSTMenu;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	if (!bIsValidGame(false) && !bIsValidGame())
	{
		strcopy(error, err_max, "Super Tanks++ only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	CreateNative("ST_MaxType", aNative_MaxType);
	CreateNative("ST_MinType", aNative_MinType);
	CreateNative("ST_PluginEnabled", aNative_PluginEnabled);
	CreateNative("ST_SpawnTank", aNative_SpawnTank);
	CreateNative("ST_TankAllowed", aNative_TankAllowed);
	CreateNative("ST_TankColors", aNative_TankColors);
	CreateNative("ST_TankName", aNative_TankName);
	CreateNative("ST_TankType", aNative_TankType);
	CreateNative("ST_TankWave", aNative_TankWave);
	RegPluginLibrary("super_tanks++");
	g_bLateLoad = late;
	return APLRes_Success;
}

public any aNative_MaxType(Handle plugin, int numParams)
{
	return iGetMaxType();
}

public any aNative_MinType(Handle plugin, int numParams)
{
	return iGetMinType();
}

public any aNative_PluginEnabled(Handle plugin, int numParams)
{
	if (iPluginEnabled() == 1 && g_bPluginEnabled)
	{
		return true;
	}
	return false;
}

public any aNative_SpawnTank(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = GetNativeCell(2);
	if (bIsValidClient(iTank))
	{
		vTank(iTank, iType);
	}
}

public any aNative_TankAllowed(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTankAllowed(iTank))
	{
		return true;
	}
	return false;
}

public any aNative_TankColors(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank))
	{
		char sSet[2][16], sTankColors[28], sRGB[4][4];
		sTankColors = !g_bTankConfig[g_iTankType[iTank]] ? g_sTankColors[g_iTankType[iTank]] : g_sTankColors2[g_iTankType[iTank]];
		TrimString(sTankColors);
		ExplodeString(sTankColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
		ExplodeString(sSet[0], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
		TrimString(sRGB[0]);
		TrimString(sRGB[1]);
		TrimString(sRGB[2]);
		SetNativeString(2, sRGB[0], sizeof(sRGB[]));
		SetNativeString(3, sRGB[1], sizeof(sRGB[]));
		SetNativeString(4, sRGB[2], sizeof(sRGB[]));
	}
}

public any aNative_TankName(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank))
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		sTankName = !g_bTankConfig[g_iTankType[iTank]] ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[g_iTankType[iTank]];
		SetNativeString(2, sTankName, sizeof(sTankName));
	}
}

public any aNative_TankType(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank))
	{
		return g_iTankType[iTank];
	}
	return 0;
}

public any aNative_TankWave(Handle plugin, int numParams)
{
	return g_iTankWave;
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
	if (StrEqual(name, "adminmenu", false))
	{
		g_tmSTMenu = null;
	}
	else if (StrEqual(name, "st_clone", false))
	{
		g_bCloneInstalled = false;
	}
}

public void OnPluginStart()
{
	g_hAbilityForward = CreateGlobalForward("ST_Ability", ET_Ignore, Param_Cell);
	g_hBossStageForward = CreateGlobalForward("ST_BossStage", ET_Ignore, Param_Cell);
	g_hConfigsForward = CreateGlobalForward("ST_Configs", ET_Ignore, Param_String, Param_Cell);
	g_hEventForward = CreateGlobalForward("ST_Event", ET_Ignore, Param_Cell, Param_String);
	g_hRockBreakForward = CreateGlobalForward("ST_RockBreak", ET_Ignore, Param_Cell, Param_Cell);
	g_hRockThrowForward = CreateGlobalForward("ST_RockThrow", ET_Ignore, Param_Cell, Param_Cell);
	CreateDirectory("addons/sourcemod/data/super_tanks++/", 511);
	BuildPath(Path_SM, g_sSavePath, sizeof(g_sSavePath), "data/super_tanks++/super_tanks++.cfg");
	g_iFileTimeOld[0] = GetFileTime(g_sSavePath, FileTime_LastChange);
	vLoadConfigs(g_sSavePath, true);
	vMultiTargetFilters(1);
	LoadTranslations("common.phrases");
	LoadTranslations("super_tanks++.phrases");
	RegAdminCmd("sm_tank", cmdTank, ADMFLAG_ROOT, "Spawn a Super Tank.");
	RegAdminCmd("sm_tanklist", cmdTankList, ADMFLAG_ROOT, "View the Super Tanks list.");
	g_cvSTEnable = CreateConVar("st_enableplugin", "1", "Enable Super Tanks++.\n0: OFF\n1: ON");
	CreateConVar("st_pluginversion", ST_VERSION, "Super Tanks++ Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_cvSTDifficulty = FindConVar("z_difficulty");
	g_cvSTGameMode = FindConVar("mp_gamemode");
	g_cvSTGameTypes = FindConVar("sv_gametypes");
	g_cvSTMaxPlayerZombies = FindConVar("z_max_player_zombies");
	g_cvSTEnable.AddChangeHook(vSTEnableCvar);
	g_cvSTDifficulty.AddChangeHook(vSTGameDifficultyCvar);
	HookEvent("round_start", vEventHandler);
	TopMenu tmAdminMenu;
	if (LibraryExists("adminmenu") && ((tmAdminMenu = GetAdminTopMenu()) != null))
	{
		OnAdminMenuReady(tmAdminMenu);
	}
	AutoExecConfig(true, "super_tanks++");
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
	PrecacheSound(SOUND_BOSS);
	g_iType = 0;
	vReset();
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	g_iBossStageCount[client] = 0;
	g_iTankType[client] = 0;
	vSpawnModes(client, false);
}

public void OnConfigsExecuted()
{
	g_iType = 0;
	vLoadConfigs(g_sSavePath, true);
	char sMapName[128];
	GetCurrentMap(sMapName, sizeof(sMapName));
	if (IsMapValid(sMapName))
	{
		vPluginStatus();
		float flRegularInterval = !g_bGeneralConfig ? g_flRegularInterval : g_flRegularInterval2;
		CreateTimer(flRegularInterval, tTimerRegularWaves, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerReloadConfigs, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(0.1, tTimerTankHealthUpdate, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerTankTypeUpdate, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerUpdatePlayerCount, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
	if (StrContains(g_sConfigCreate, "1") != -1 && g_iConfigEnable == 1)
	{
		CreateDirectory("addons/sourcemod/data/super_tanks++/difficulty_configs/", 511);
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
			vCreateConfigFile("addons/sourcemod/data/super_tanks++/", "difficulty_configs/", sDifficulty, sDifficulty);
		}
	}
	if (StrContains(g_sConfigCreate, "2") != -1 && g_iConfigEnable == 1)
	{
		CreateDirectory((bIsValidGame() ? "addons/sourcemod/data/super_tanks++/l4d2_map_configs/" : "addons/sourcemod/data/super_tanks++/l4d_map_configs/"), 511);
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
				vCreateConfigFile("addons/sourcemod/data/super_tanks++/", (bIsValidGame() ? "l4d2_map_configs/" : "l4d_map_configs/"), sMapNames, sMapNames);
			}
		}
		delete alADTMaps;
	}
	if (StrContains(g_sConfigCreate, "3") != -1 && g_iConfigEnable == 1)
	{
		CreateDirectory((bIsValidGame() ? "addons/sourcemod/data/super_tanks++/l4d2_gamemode_configs/" : "addons/sourcemod/data/super_tanks++/l4d_gamemode_configs/"), 511);
		char sGameType[2049], sTypes[64][32];
		g_cvSTGameTypes.GetString(sGameType, sizeof(sGameType));
		TrimString(sGameType);
		ExplodeString(sGameType, ",", sTypes, sizeof(sTypes), sizeof(sTypes[]));
		for (int iMode = 0; iMode < sizeof(sTypes); iMode++)
		{
			if (StrContains(sGameType, sTypes[iMode]) != -1 && !StrEqual(sTypes[iMode], ""))
			{
				vCreateConfigFile("addons/sourcemod/data/super_tanks++/", (bIsValidGame() ? "l4d2_gamemode_configs/" : "l4d_gamemode_configs/"), sTypes[iMode], sTypes[iMode]);
			}
		}
	}
	if (StrContains(g_sConfigCreate, "4") != -1 && g_iConfigEnable == 1)
	{
		CreateDirectory("addons/sourcemod/data/super_tanks++/daily_configs/", 511);
		char sWeekday[32];
		for (int iDay = 0; iDay <= 6; iDay++)
		{
			switch (iDay)
			{
				case 1: sWeekday = "monday";
				case 2: sWeekday = "tuesday";
				case 3: sWeekday = "wednesday";
				case 4: sWeekday = "thursday";
				case 5: sWeekday = "friday";
				case 6: sWeekday = "saturday";
				default: sWeekday = "sunday";
			}
			vCreateConfigFile("addons/sourcemod/data/super_tanks++/", "daily_configs/", sWeekday, sWeekday);
		}
	}
	if (StrContains(g_sConfigCreate, "5") != -1 && g_iConfigEnable == 1)
	{
		CreateDirectory("addons/sourcemod/data/super_tanks++/playercount_configs/", 511);
		char sPlayerCount[32];
		for (int iCount = 0; iCount <= MAXPLAYERS + 1; iCount++)
		{
			IntToString(iCount, sPlayerCount, sizeof(sPlayerCount));
			vCreateConfigFile("addons/sourcemod/data/super_tanks++/", "playercount_configs/", sPlayerCount, sPlayerCount);
		}
	}
	if (StrContains(g_sConfigExecute, "1") != -1 && g_iConfigEnable == 1 && g_cvSTDifficulty != null)
	{
		char sDifficulty[11], sDifficultyConfig[PLATFORM_MAX_PATH];
		g_cvSTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));
		BuildPath(Path_SM, sDifficultyConfig, sizeof(sDifficultyConfig), "data/super_tanks++/difficulty_configs/%s.cfg", sDifficulty);
		vLoadConfigs(sDifficultyConfig);
		g_iFileTimeOld[1] = GetFileTime(sDifficultyConfig, FileTime_LastChange);
	}
	if (StrContains(g_sConfigExecute, "2") != -1 && g_iConfigEnable == 1)
	{
		char sMap[64], sMapConfig[PLATFORM_MAX_PATH];
		GetCurrentMap(sMap, sizeof(sMap));
		BuildPath(Path_SM, sMapConfig, sizeof(sMapConfig), (bIsValidGame() ? "data/super_tanks++/l4d2_map_configs/%s.cfg" : "data/super_tanks++/l4d_map_configs/%s.cfg"), sMap);
		vLoadConfigs(sMapConfig);
		g_iFileTimeOld[2] = GetFileTime(sMapConfig, FileTime_LastChange);
	}
	if (StrContains(g_sConfigExecute, "3") != -1 && g_iConfigEnable == 1)
	{
		char sMode[64], sModeConfig[PLATFORM_MAX_PATH];
		g_cvSTGameMode.GetString(sMode, sizeof(sMode));
		BuildPath(Path_SM, sModeConfig, sizeof(sModeConfig), (bIsValidGame() ? "data/super_tanks++/l4d2_gamemode_configs/%s.cfg" : "data/super_tanks++/l4d_gamemode_configs/%s.cfg"), sMode);
		vLoadConfigs(sModeConfig);
		g_iFileTimeOld[3] = GetFileTime(sModeConfig, FileTime_LastChange);
	}
	if (StrContains(g_sConfigExecute, "4") != -1 && g_iConfigEnable == 1)
	{
		char sDay[9], sDayNumber[2], sDayConfig[PLATFORM_MAX_PATH];
		FormatTime(sDayNumber, sizeof(sDayNumber), "%w", GetTime());
		int iDayNumber = StringToInt(sDayNumber);
		switch (iDayNumber)
		{
			case 1: sDay = "monday";
			case 2: sDay = "tuesday";
			case 3: sDay = "wednesday";
			case 4: sDay = "thursday";
			case 5: sDay = "friday";
			case 6: sDay = "saturday";
			default: sDay = "sunday";
		}
		BuildPath(Path_SM, sDayConfig, sizeof(sDayConfig), "data/super_tanks++/daily_configs/%s.cfg", sDay);
		vLoadConfigs(sDayConfig);
		g_iFileTimeOld[4] = GetFileTime(sDayConfig, FileTime_LastChange);
	}
	if (StrContains(g_sConfigExecute, "5") != -1 && g_iConfigEnable == 1)
	{
		char sCountConfig[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/super_tanks++/playercount_configs/%d.cfg", iGetPlayerCount());
		vLoadConfigs(sCountConfig);
		g_iFileTimeOld[5] = GetFileTime(sCountConfig, FileTime_LastChange);
	}
}

public void OnMapEnd()
{
	g_iType = 0;
	vReset();
}

public void OnPluginEnd()
{
	vMultiTargetFilters(0);
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank) && IsPlayerAlive(iTank))
		{
			vRemoveProps(iTank);
		}
	}
}

public void OnAdminMenuReady(Handle topmenu)
{
	TopMenu tmSTMenu = TopMenu.FromHandle(topmenu);
	if (topmenu == g_tmSTMenu)
	{
		return;
	}
	g_tmSTMenu = tmSTMenu;
	TopMenuObject st_commands = g_tmSTMenu.AddCategory("SuperTanks++", iSTAdminMenuHandler);
	if (st_commands != INVALID_TOPMENUOBJECT)
	{
		g_tmSTMenu.AddItem("sm_tank", vSuperTankMenu, st_commands, "sm_tank", ADMFLAG_ROOT);
		g_tmSTMenu.AddItem("sm_tanklist", vSuperTankListMenu, st_commands, "sm_tanklist", ADMFLAG_ROOT);
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

public void vSuperTankListMenu(TopMenu topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	switch (action)
	{
		case TopMenuAction_DisplayOption: Format(buffer, maxlength, "Super Tanks++ List");
		case TopMenuAction_SelectOption: vTankList(param);
	}
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (iPluginEnabled() == 1 && g_bPluginEnabled && StrEqual(classname, "tank_rock"))
	{
		CreateTimer(0.1, tTimerRockThrow, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void OnEntityDestroyed(int entity)
{
	if (iPluginEnabled() == 1 && g_bPluginEnabled && bIsValidEntity(entity))
	{
		char sClassname[32];
		GetEntityClassname(entity, sClassname, sizeof(sClassname));
		if (StrEqual(sClassname, "tank_rock"))
		{
			int iThrower = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
			if (iThrower == 0 || !bIsTankAllowed(iThrower) || !IsPlayerAlive(iThrower))
			{
				return;
			}
			Call_StartForward(g_hRockBreakForward);
			Call_PushCell(iThrower);
			Call_PushCell(entity);
			Call_Finish();
		}
	}
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (iPluginEnabled() == 1 && g_bPluginEnabled && damage > 0.0 && bIsValidClient(victim))
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (bIsTankAllowed(attacker) && bIsSurvivor(victim))
		{
			if (StrEqual(sClassname, "weapon_tank_claw"))
			{
				float flClawDamage = !g_bTankConfig[g_iTankType[attacker]] ? g_flClawDamage[g_iTankType[attacker]] : g_flClawDamage2[g_iTankType[attacker]];
				damage = flClawDamage;
				return Plugin_Changed;
			}
			else if (StrEqual(sClassname, "tank_rock"))
			{
				float flRockDamage = !g_bTankConfig[g_iTankType[attacker]] ? g_flRockDamage[g_iTankType[attacker]] : g_flRockDamage2[g_iTankType[attacker]];
				damage = flRockDamage;
				return Plugin_Changed;
			}
		}
		else if (bIsInfected(victim))
		{
			if (bIsTankAllowed(victim) && IsPlayerAlive(victim))
			{
				int iBulletImmunity = !g_bTankConfig[g_iTankType[victim]] ? g_iBulletImmunity[g_iTankType[victim]] : g_iBulletImmunity2[g_iTankType[victim]],
					iExplosiveImmunity = !g_bTankConfig[g_iTankType[victim]] ? g_iExplosiveImmunity[g_iTankType[victim]] : g_iExplosiveImmunity2[g_iTankType[victim]],
					iMeleeImmunity = !g_bTankConfig[g_iTankType[victim]] ? g_iMeleeImmunity[g_iTankType[victim]] : g_iMeleeImmunity2[g_iTankType[victim]];
				if ((damagetype & DMG_BULLET && iBulletImmunity == 1) || ((damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA) && iExplosiveImmunity == 1) || ((damagetype & DMG_BURN || damagetype == 2056 || damagetype == 268435464) && iFireImmunity(victim) == 1) || ((damagetype & DMG_SLASH || damagetype & DMG_CLUB) && iMeleeImmunity == 1))
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
				int iOwner, iThrower;
				if (HasEntProp(inflictor, Prop_Send, "m_hOwnerEntity"))
				{
					iOwner = GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity");
				}
				if (HasEntProp(inflictor, Prop_Data, "m_hThrower"))
				{
					iThrower = GetEntPropEnt(inflictor, Prop_Data, "m_hThrower");
				}
				if ((iOwner > 0 && iOwner == victim) || (iThrower > 0 && iThrower == victim) || bIsTank(iOwner) || StrEqual(sClassname, "tank_rock"))
				{
					damage = 0.0;
					return Plugin_Handled;
				}
			}
		}
	}
	return Plugin_Continue;
}

public void vEventHandler(Event event, const char[] name, bool dontBroadcast)
{
	if (StrEqual(name, "ability_use"))
	{
		int iUserId = event.GetInt("userid"), iTank = GetClientOfUserId(iUserId);
		if (bIsTankAllowed(iTank) && IsPlayerAlive(iTank))
		{
			vThrowInterval(iTank, flThrowInterval(iTank));
		}
	}
	else if (StrEqual(name, "finale_escape_start") || StrEqual(name, "finale_vehicle_ready"))
	{
		g_iTankWave = 3;
	}
	else if (StrEqual(name, "finale_start"))
	{
		g_iTankWave = 1;
	}
	else if (StrEqual(name, "finale_vehicle_leaving"))
	{
		g_iTankWave = 4;
	}
	else if (StrEqual(name, "player_death"))
	{
		int iUserId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iUserId);
		if (bIsValidClient(iPlayer))
		{
			if (bIsTankAllowed(iPlayer))
			{
				if (iGlowOutline(g_iTankType[iPlayer]) == 1 && bIsValidGame())
				{
					SetEntProp(iPlayer, Prop_Send, "m_iGlowType", 0);
					SetEntProp(iPlayer, Prop_Send, "m_glowColorOverride", 0);
				}
				char sTankName[MAX_NAME_LENGTH + 1];
				sTankName = !g_bTankConfig[g_iTankType[iPlayer]] ? g_sTankName[g_iTankType[iPlayer]] : g_sTankName2[g_iTankType[iPlayer]];
				int iAnnounceDeath = !g_bGeneralConfig ? g_iAnnounceDeath : g_iAnnounceDeath2;
				if (iAnnounceDeath == 1 && ST_CloneAllowed(iPlayer, g_bCloneInstalled))
				{
					switch (GetRandomInt(1, 10))
					{
						case 1: PrintToChatAll("%s %t", ST_PREFIX2, "Death1", sTankName);
						case 2: PrintToChatAll("%s %t", ST_PREFIX2, "Death2", sTankName);
						case 3: PrintToChatAll("%s %t", ST_PREFIX2, "Death3", sTankName);
						case 4: PrintToChatAll("%s %t", ST_PREFIX2, "Death4", sTankName);
						case 5: PrintToChatAll("%s %t", ST_PREFIX2, "Death5", sTankName);
						case 6: PrintToChatAll("%s %t", ST_PREFIX2, "Death6", sTankName);
						case 7: PrintToChatAll("%s %t", ST_PREFIX2, "Death7", sTankName);
						case 8: PrintToChatAll("%s %t", ST_PREFIX2, "Death8", sTankName);
						case 9: PrintToChatAll("%s %t", ST_PREFIX2, "Death9", sTankName);
						case 10: PrintToChatAll("%s %t", ST_PREFIX2, "Death10", sTankName);
					}
				}
				vRemoveProps(iPlayer);
				CreateTimer(3.0, tTimerTankWave, g_iTankWave, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	else if (StrEqual(name, "player_incapacitated"))
	{
		int iUserId = event.GetInt("userid"), iTank = GetClientOfUserId(iUserId);
		if (bIsTankAllowed(iTank) && IsPlayerAlive(iTank))
		{
			CreateTimer(0.5, tTimerKillStuckTank, iUserId, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else if (StrEqual(name, "player_spawn"))
	{
		int iUserId = event.GetInt("userid"), iTank = GetClientOfUserId(iUserId);
		if (bIsTankAllowed(iTank) && IsPlayerAlive(iTank))
		{
			g_iTankType[iTank] = 0;
			int iFinalesOnly = !g_bGeneralConfig ? g_iFinalesOnly : g_iFinalesOnly2;
			if (iFinalesOnly == 0 || (iFinalesOnly == 1 && (bIsFinaleMap() || g_iTankWave > 0)))
			{
				int iTypeCount, iTankTypes[ST_MAXTYPES + 1];
				for (int iIndex = iGetMinType(); iIndex <= iGetMaxType(); iIndex++)
				{
					if (iTankEnabled(iIndex) == 0 || (iTypeLimit(iIndex) > 0 && iGetTypeCount(iIndex) >= iTypeLimit(iIndex)) || (iFinaleTank(iIndex) == 1 && (!bIsFinaleMap() || g_iTankWave <= 0)) || g_iTankType[iTank] == iIndex)
					{
						continue;
					}
					iTankTypes[iTypeCount + 1] = iIndex;
					iTypeCount++;
				}
				if (iTypeCount > 0)
				{
					int iChosen = iTankTypes[GetRandomInt(1, iTypeCount)];
					vSetColor(iTank, (g_iType <= 0) ? iChosen : g_iType);
					(g_iType > 0) ? (g_bSpawned[iTank] = true) : (g_bSpawned[iTank] = false);
					g_iType = 0;
				}
				char sNumbers[3][4], sFinaleWaves[12];
				sFinaleWaves = !g_bGeneralConfig ? g_sFinaleWaves : g_sFinaleWaves2;
				TrimString(sFinaleWaves);
				ExplodeString(sFinaleWaves, ",", sNumbers, sizeof(sNumbers), sizeof(sNumbers[]));
				TrimString(sNumbers[0]);
				int iWave = (!StrEqual(sNumbers[0], "")) ? StringToInt(sNumbers[0]) : 1;
				iWave = iClamp(iWave, 1, 9999999999);
				TrimString(sNumbers[1]);
				int iWave2 = (!StrEqual(sNumbers[1], "")) ? StringToInt(sNumbers[1]) : 2;
				iWave2 = iClamp(iWave2, 1, 9999999999);
				TrimString(sNumbers[2]);
				int iWave3 = (!StrEqual(sNumbers[2], "")) ? StringToInt(sNumbers[2]) : 3;
				iWave3 = iClamp(iWave3, 1, 9999999999);
				switch (g_iTankWave)
				{
					case 1: vTankCountCheck(iTank, iWave);
					case 2: vTankCountCheck(iTank, iWave2);
					case 3: vTankCountCheck(iTank, iWave3);
				}
				DataPack dpTankSpawn = new DataPack();
				CreateDataTimer(0.1, tTimerTankSpawn, dpTankSpawn, TIMER_FLAG_NO_MAPCHANGE);
				dpTankSpawn.WriteCell(GetClientUserId(iTank)), dpTankSpawn.WriteCell(0);
			}
		}
	}
	else if (StrEqual(name, "round_start"))
	{
		g_iTankWave = 0;
	}
	Call_StartForward(g_hEventForward);
	Call_PushCell(event);
	Call_PushString(name);
	Call_Finish();
}

public Action cmdTank(int client, int args)
{
	if (iPluginEnabled() == 0 || !g_bPluginEnabled)
	{
		ReplyToCommand(client, "%s Super Tanks++\x01 is disabled.", ST_PREFIX4);
		return Plugin_Handled;
	}
	if (!bIsValidHumanClient(client))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", ST_PREFIX);
		return Plugin_Handled;
	}
	char sType[32], sMode[32];
	GetCmdArg(1, sType, sizeof(sType));
	int iType = StringToInt(sType);
	GetCmdArg(2, sMode, sizeof(sMode));
	int iMode = StringToInt(sMode);
	if (args < 1)
	{
		IsVoteInProgress() ? ReplyToCommand(client, "%s %t", ST_PREFIX2, "Vote in Progress") : vTankMenu(client, 0);
		return Plugin_Handled;
	}
	else if (iType < iGetMinType() || iType > iGetMaxType() || iMode < 0 || iMode > 1 || args > 2)
	{
		ReplyToCommand(client, "%s Usage: sm_tank <type %d-%d> <0: spawn at crosshair|1: spawn automatically>", ST_PREFIX2, iGetMinType(), iGetMaxType());
		return Plugin_Handled;
	}
	if (iTankEnabled(iType) == 0)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		sTankName = !g_bTankConfig[iType] ? g_sTankName[iType] : g_sTankName2[iType];
		ReplyToCommand(client, "%s %s\x04 (Tank #%d)\x01 is disabled.", ST_PREFIX4, sTankName, iType);
		return Plugin_Handled;
	}
	vTank(client, iType, iMode);
	return Plugin_Handled;
}

stock void vTank(int client, int type, int mode = 0)
{
	g_iType = type;
	char sParameter[32];
	switch (mode)
	{
		case 0: sParameter = "tank";
		case 1: sParameter = "tank auto";
	}
	vCheatCommand(client, bIsValidGame() ? "z_spawn_old" : "z_spawn", sParameter);
}

stock void vTankMenu(int client, int item)
{
	Menu mTankMenu = new Menu(iTankMenuHandler);
	mTankMenu.SetTitle("Super Tanks++ Menu");
	for (int iIndex = iGetMinType(); iIndex <= iGetMaxType(); iIndex++)
	{
		if (iTankEnabled(iIndex) == 0)
		{
			continue;
		}
		char sTankName[MAX_NAME_LENGTH + 1], sMenuItem[MAX_NAME_LENGTH + 12];
		sTankName = !g_bTankConfig[iIndex] ? g_sTankName[iIndex] : g_sTankName2[iIndex];
		Format(sMenuItem, sizeof(sMenuItem), "%s (Tank #%d)", sTankName, iIndex);
		mTankMenu.AddItem(sTankName, sMenuItem);
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
			for (int iIndex = iGetMinType(); iIndex <= iGetMaxType(); iIndex++)
			{
				if (iTankEnabled(iIndex) == 0)
				{
					continue;
				}
				char sTankName[MAX_NAME_LENGTH + 1];
				sTankName = !g_bTankConfig[iIndex] ? g_sTankName[iIndex] : g_sTankName2[iIndex];
				if (StrEqual(sInfo, sTankName))
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

public Action cmdTankList(int client, int args)
{
	if (iPluginEnabled() == 0 || !g_bPluginEnabled)
	{
		ReplyToCommand(client, "%s Super Tanks++\x01 is disabled.", ST_PREFIX4);
		return Plugin_Handled;
	}
	if (args > 0)
	{
		ReplyToCommand(client, "%s Usage: sm_tanklist", ST_PREFIX2);
		return Plugin_Handled;
	}
	vTankList(client);
	return Plugin_Handled;
}

stock void vTankList(int client)
{
	for (int iIndex = iGetMinType(); iIndex <= iGetMaxType(); iIndex++)
	{
		char sTankName[MAX_NAME_LENGTH + 1], sStatus[32], sMode[32];
		sTankName = !g_bTankConfig[iIndex] ? g_sTankName[iIndex] : g_sTankName2[iIndex];
		switch (iTankEnabled(iIndex))
		{
			case 0: sStatus = "Disabled";
			case 1: sStatus = "Enabled";
		}
		switch (iSpawnMode(iIndex))
		{
			case 0: sMode = "Normal";
			case 1: sMode = "Boss";
			case 2: sMode = "Randomized";
			case 3: sMode = "Transformer";
		}
		PrintToConsole(client, "%d. Name: %s, Status: %s, Mode: %s", iIndex, sTankName, sStatus, sMode);
	}
	if (GetCmdReplySource() == SM_REPLY_TO_CHAT)
	{
		PrintToChat(client, "%s See console for output.", ST_PREFIX2);
	}
}

stock void vPluginStatus()
{
	bool bIsPluginAllowed = bIsPluginEnabled(g_cvSTGameMode, g_iGameModeTypes, g_sEnabledGameModes, g_sDisabledGameModes);
	if (iPluginEnabled() == 1)
	{
		if (g_cvSTEnable.BoolValue && bIsPluginAllowed)
		{
			vHookEvents(true);
			g_bPluginEnabled = true;
		}
		else
		{
			vHookEvents(false);
			g_bPluginEnabled = false;
		}
	}
}

stock void vHookEvents(bool hook)
{
	static bool bHooked;
	if (hook && !bHooked)
	{
		HookEvent("ability_use", vEventHandler);
		HookEvent("finale_escape_start", vEventHandler);
		HookEvent("finale_start", vEventHandler, EventHookMode_Pre);
		HookEvent("finale_vehicle_leaving", vEventHandler);
		HookEvent("finale_vehicle_ready", vEventHandler);
		HookEvent("player_afk", vEventHandler, EventHookMode_Pre);
		HookEvent("player_bot_replace", vEventHandler);
		HookEvent("player_death", vEventHandler);
		HookEvent("player_incapacitated", vEventHandler);
		HookEvent("player_spawn", vEventHandler);
		HookEvent("weapon_fire", vEventHandler);
		bHooked = true;
	}
	else if (!hook && bHooked)
	{
		UnhookEvent("ability_use", vEventHandler);
		UnhookEvent("finale_escape_start", vEventHandler);
		UnhookEvent("finale_start", vEventHandler, EventHookMode_Pre);
		UnhookEvent("finale_vehicle_leaving", vEventHandler);
		UnhookEvent("finale_vehicle_ready", vEventHandler);
		UnhookEvent("player_afk", vEventHandler, EventHookMode_Pre);
		UnhookEvent("player_bot_replace", vEventHandler);
		UnhookEvent("player_death", vEventHandler);
		UnhookEvent("player_incapacitated", vEventHandler);
		UnhookEvent("player_spawn", vEventHandler);
		UnhookEvent("weapon_fire", vEventHandler);
		bHooked = false;
	}
}

stock void vLoadConfigs(const char[] savepath, bool main = false)
{
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	kvSuperTanks.ImportFromFile(savepath);
	if (kvSuperTanks.JumpToKey("Plugin Settings"))
	{
		main ? (g_bGeneralConfig = false) : (g_bGeneralConfig = true);
		main ? (g_iPluginEnabled = kvSuperTanks.GetNum("General/Plugin Enabled", 1)) : (g_iPluginEnabled2 = kvSuperTanks.GetNum("General/Plugin Enabled", g_iPluginEnabled));
		main ? (g_iPluginEnabled = iClamp(g_iPluginEnabled, 0, 1)) : (g_iPluginEnabled2 = iClamp(g_iPluginEnabled2, 0, 1));
		main ? (g_iAnnounceArrival = kvSuperTanks.GetNum("General/Announce Arrival", 1)) : (g_iAnnounceArrival2 = kvSuperTanks.GetNum("General/Announce Arrival", g_iAnnounceArrival));
		main ? (g_iAnnounceArrival = iClamp(g_iAnnounceArrival, 0, 1)) : (g_iAnnounceArrival2 = iClamp(g_iAnnounceArrival2, 0, 1));
		main ? (g_iAnnounceDeath = kvSuperTanks.GetNum("General/Announce Death", 1)) : (g_iAnnounceDeath2 = kvSuperTanks.GetNum("General/Announce Death", g_iAnnounceDeath));
		main ? (g_iAnnounceDeath = iClamp(g_iAnnounceDeath, 0, 1)) : (g_iAnnounceDeath2 = iClamp(g_iAnnounceDeath2, 0, 1));
		main ? (g_iDisplayHealth = kvSuperTanks.GetNum("General/Display Health", 3)) : (g_iDisplayHealth2 = kvSuperTanks.GetNum("General/Display Health", g_iDisplayHealth));
		main ? (g_iDisplayHealth = iClamp(g_iDisplayHealth, 0, 3)) : (g_iDisplayHealth2 = iClamp(g_iDisplayHealth2, 0, 3));
		main ? (g_iFinalesOnly = kvSuperTanks.GetNum("General/Finales Only", 0)) : (g_iFinalesOnly2 = kvSuperTanks.GetNum("General/Finales Only", g_iFinalesOnly));
		main ? (g_iFinalesOnly = iClamp(g_iFinalesOnly, 0, 1)) : (g_iFinalesOnly2 = iClamp(g_iFinalesOnly2, 0, 1));
		main ? (g_iMultiHealth = kvSuperTanks.GetNum("General/Multiply Health", 0)) : (g_iMultiHealth2 = kvSuperTanks.GetNum("General/Multiply Health", g_iMultiHealth));
		main ? (g_iMultiHealth = iClamp(g_iMultiHealth, 0, 3)) : (g_iMultiHealth2 = iClamp(g_iMultiHealth2, 0, 3));
		main ? (kvSuperTanks.GetString("General/Type Range", g_sTypeRange, sizeof(g_sTypeRange), "1-5000")) : (kvSuperTanks.GetString("General/Type Range", g_sTypeRange2, sizeof(g_sTypeRange2), g_sTypeRange));
		main ? (g_iRegularAmount = kvSuperTanks.GetNum("Waves/Regular Amount", 2)) : (g_iRegularAmount2 = kvSuperTanks.GetNum("Waves/Regular Amount", g_iRegularAmount));
		main ? (g_iRegularAmount = iClamp(g_iRegularAmount, 1, 9999999999)) : (g_iRegularAmount2 = iClamp(g_iRegularAmount2, 1, 9999999999));
		main ? (g_flRegularInterval = kvSuperTanks.GetFloat("Waves/Regular Interval", 300.0)) : (g_flRegularInterval2 = kvSuperTanks.GetFloat("Waves/Regular Interval", g_flRegularInterval));
		main ? (g_flRegularInterval = flClamp(g_flRegularInterval, 0.1, 9999999999.0)) : (g_flRegularInterval2 = flClamp(g_flRegularInterval2, 0.1, 9999999999.0));
		main ? (g_iRegularWave = kvSuperTanks.GetNum("Waves/Regular Wave", 0)) : (g_iRegularWave2 = kvSuperTanks.GetNum("Waves/Regular Wave", g_iRegularWave));
		main ? (g_iRegularWave = iClamp(g_iRegularWave, 0, 1)) : (g_iRegularWave2 = iClamp(g_iRegularWave2, 0, 1));
		main ? (kvSuperTanks.GetString("Waves/Finale Waves", g_sFinaleWaves, sizeof(g_sFinaleWaves), "2,3,4")) : (kvSuperTanks.GetString("Waves/Finale Waves", g_sFinaleWaves2, sizeof(g_sFinaleWaves2), g_sFinaleWaves));
		if (main)
		{
			g_iGameModeTypes = kvSuperTanks.GetNum("Game Modes/Game Mode Types", 5);
			g_iGameModeTypes = iClamp(g_iGameModeTypes, 0, 15);
			kvSuperTanks.GetString("Game Modes/Enabled Game Modes", g_sEnabledGameModes, sizeof(g_sEnabledGameModes), "coop,survival");
			kvSuperTanks.GetString("Game Modes/Disabled Game Modes", g_sDisabledGameModes, sizeof(g_sDisabledGameModes), "versus,scavenge");
			g_iConfigEnable = kvSuperTanks.GetNum("Custom/Enable Custom Configs", 0);
			g_iConfigEnable = iClamp(g_iConfigEnable, 0, 1);
			kvSuperTanks.GetString("Custom/Create Config Types", g_sConfigCreate, sizeof(g_sConfigCreate), "12345");
			kvSuperTanks.GetString("Custom/Execute Config Types", g_sConfigExecute, sizeof(g_sConfigExecute), "1");
		}
		kvSuperTanks.Rewind();
	}
	for (int iIndex = iGetMinType(); iIndex <= iGetMaxType(); iIndex++)
	{
		char sTankName[MAX_NAME_LENGTH + 1];
		Format(sTankName, sizeof(sTankName), "Tank #%d", iIndex);
		if (kvSuperTanks.JumpToKey(sTankName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (kvSuperTanks.GetString("General/Tank Name", g_sTankName[iIndex], sizeof(g_sTankName[]), sTankName)) : (kvSuperTanks.GetString("General/Tank Name", g_sTankName2[iIndex], sizeof(g_sTankName2[]), g_sTankName[iIndex]));
			main ? (g_iTankEnabled[iIndex] = kvSuperTanks.GetNum("General/Tank Enabled", 0)) : (g_iTankEnabled2[iIndex] = kvSuperTanks.GetNum("General/Tank Enabled", g_iTankEnabled[iIndex]));
			main ? (g_iTankEnabled[iIndex] = iClamp(g_iTankEnabled[iIndex], 0, 1)) : (g_iTankEnabled2[iIndex] = iClamp(g_iTankEnabled2[iIndex], 0, 1));
			main ? (g_iTankNote[iIndex] = kvSuperTanks.GetNum("General/Tank Note", 0)) : (g_iTankNote2[iIndex] = kvSuperTanks.GetNum("General/Tank Note", g_iTankNote[iIndex]));
			main ? (g_iTankNote[iIndex] = iClamp(g_iTankNote[iIndex], 0, 1)) : (g_iTankNote2[iIndex] = iClamp(g_iTankNote2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors[iIndex], sizeof(g_sTankColors[]), "255,255,255,255|255,255,255")) : (kvSuperTanks.GetString("General/Skin-Glow Colors", g_sTankColors2[iIndex], sizeof(g_sTankColors2[]), g_sTankColors[iIndex]));
			main ? (g_iGlowOutline[iIndex] = kvSuperTanks.GetNum("General/Glow Outline", 1)) : (g_iGlowOutline2[iIndex] = kvSuperTanks.GetNum("General/Glow Outline", g_iGlowOutline[iIndex]));
			main ? (g_iGlowOutline[iIndex] = iClamp(g_iGlowOutline[iIndex], 0, 1)) : (g_iGlowOutline2[iIndex] = iClamp(g_iGlowOutline2[iIndex], 0, 1));
			main ? (g_iTypeLimit[iIndex] = kvSuperTanks.GetNum("Spawn/Type Limit", 32)) : (g_iTypeLimit2[iIndex] = kvSuperTanks.GetNum("Spawn/Type Limit", g_iTypeLimit[iIndex]));
			main ? (g_iTypeLimit[iIndex] = iClamp(g_iTypeLimit[iIndex], 0, 9999999999)) : (g_iTypeLimit2[iIndex] = iClamp(g_iTypeLimit2[iIndex], 0, 9999999999));
			main ? (g_iFinaleTank[iIndex] = kvSuperTanks.GetNum("Spawn/Finale Tank", 0)) : (g_iFinaleTank2[iIndex] = kvSuperTanks.GetNum("Spawn/Finale Tank", g_iFinaleTank[iIndex]));
			main ? (g_iFinaleTank[iIndex] = iClamp(g_iFinaleTank[iIndex], 0, 1)) : (g_iFinaleTank2[iIndex] = iClamp(g_iFinaleTank2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("Spawn/Boss Health Stages", g_sBossHealthStages[iIndex], sizeof(g_sBossHealthStages[]), "5000,2500,1500,1000")) : (kvSuperTanks.GetString("Spawn/Boss Health Stages", g_sBossHealthStages2[iIndex], sizeof(g_sBossHealthStages2[]), g_sBossHealthStages[iIndex]));
			main ? (g_iBossStages[iIndex] = kvSuperTanks.GetNum("Spawn/Boss Stages", 3)) : (g_iBossStages2[iIndex] = kvSuperTanks.GetNum("Spawn/Boss Stages", g_iBossStages[iIndex]));
			main ? (g_iBossStages[iIndex] = iClamp(g_iBossStages[iIndex], 1, 4)) : (g_iBossStages2[iIndex] = iClamp(g_iBossStages2[iIndex], 1, 4));
			main ? (kvSuperTanks.GetString("Spawn/Boss Types", g_sBossTypes[iIndex], sizeof(g_sBossTypes[]), "2,3,4,5")) : (kvSuperTanks.GetString("Spawn/Boss Types", g_sBossTypes2[iIndex], sizeof(g_sBossTypes2[]), g_sBossTypes[iIndex]));
			main ? (g_flRandomInterval[iIndex] = kvSuperTanks.GetFloat("Spawn/Random Interval", 5.0)) : (g_flRandomInterval2[iIndex] = kvSuperTanks.GetFloat("Spawn/Random Interval", g_flRandomInterval[iIndex]));
			main ? (g_flRandomInterval[iIndex] = flClamp(g_flRandomInterval[iIndex], 0.1, 9999999999.0)) : (g_flRandomInterval2[iIndex] = flClamp(g_flRandomInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_flTransformDelay[iIndex] = kvSuperTanks.GetFloat("Spawn/Transform Delay", 10.0)) : (g_flTransformDelay2[iIndex] = kvSuperTanks.GetFloat("Spawn/Transform Delay", g_flTransformDelay[iIndex]));
			main ? (g_flTransformDelay[iIndex] = flClamp(g_flTransformDelay[iIndex], 0.1, 9999999999.0)) : (g_flTransformDelay2[iIndex] = flClamp(g_flTransformDelay2[iIndex], 0.1, 9999999999.0));
			main ? (g_flTransformDuration[iIndex] = kvSuperTanks.GetFloat("Spawn/Transform Duration", 10.0)) : (g_flTransformDuration2[iIndex] = kvSuperTanks.GetFloat("Spawn/Transform Duration", g_flTransformDuration[iIndex]));
			main ? (g_flTransformDuration[iIndex] = flClamp(g_flTransformDuration[iIndex], 0.1, 9999999999.0)) : (g_flTransformDuration2[iIndex] = flClamp(g_flTransformDuration2[iIndex], 0.1, 9999999999.0));
			main ? (kvSuperTanks.GetString("Spawn/Transform Types", g_sTransformTypes[iIndex], sizeof(g_sTransformTypes[]), "1,2,3,4,5,6,7,8,9,10")) : (kvSuperTanks.GetString("Spawn/Transform Types", g_sTransformTypes2[iIndex], sizeof(g_sTransformTypes2[]), g_sTransformTypes[iIndex]));
			main ? (g_iSpawnMode[iIndex] = kvSuperTanks.GetNum("Spawn/Spawn Mode", 0)) : (g_iSpawnMode2[iIndex] = kvSuperTanks.GetNum("Spawn/Spawn Mode", g_iSpawnMode[iIndex]));
			main ? (g_iSpawnMode[iIndex] = iClamp(g_iSpawnMode[iIndex], 0, 3)) : (g_iSpawnMode2[iIndex] = iClamp(g_iSpawnMode2[iIndex], 0, 3));
			main ? (kvSuperTanks.GetString("Props/Props Attached", g_sPropsAttached[iIndex], sizeof(g_sPropsAttached[]), "23456")) : (kvSuperTanks.GetString("Props/Props Attached", g_sPropsAttached2[iIndex], sizeof(g_sPropsAttached2[]), g_sPropsAttached[iIndex]));
			main ? (kvSuperTanks.GetString("Props/Props Chance", g_sPropsChance[iIndex], sizeof(g_sPropsChance[]), "3,3,3,3,3,3")) : (kvSuperTanks.GetString("Props/Props Chance", g_sPropsChance2[iIndex], sizeof(g_sPropsChance2[]), g_sPropsChance[iIndex]));
			main ? (kvSuperTanks.GetString("Props/Props Colors", g_sPropsColors[iIndex], sizeof(g_sPropsColors[]), "255,255,255,255|255,255,255,255|255,255,255,180|255,255,255,255|255,255,255,255")) : (kvSuperTanks.GetString("Props/Props Colors", g_sPropsColors2[iIndex], sizeof(g_sPropsColors2[]), g_sPropsColors[iIndex]));
			main ? (g_iParticleEffect[iIndex] = kvSuperTanks.GetNum("Particles/Body Particle", 0)) : (g_iParticleEffect2[iIndex] = kvSuperTanks.GetNum("Particles/Body Particle", g_iParticleEffect[iIndex]));
			main ? (g_iParticleEffect[iIndex] = iClamp(g_iParticleEffect[iIndex], 0, 1)) : (g_iParticleEffect2[iIndex] = iClamp(g_iParticleEffect2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("Particles/Body Effects", g_sParticleEffects[iIndex], sizeof(g_sParticleEffects[]), "1234567")) : (kvSuperTanks.GetString("Particles/Body Effects", g_sParticleEffects2[iIndex], sizeof(g_sParticleEffects2[]), g_sParticleEffects[iIndex]));
			main ? (g_iRockEffect[iIndex] = kvSuperTanks.GetNum("Particles/Rock Particle", 0)) : (g_iRockEffect2[iIndex] = kvSuperTanks.GetNum("Particles/Rock Particle", g_iRockEffect[iIndex]));
			main ? (g_iRockEffect[iIndex] = iClamp(g_iRockEffect[iIndex], 0, 1)) : (g_iRockEffect2[iIndex] = iClamp(g_iRockEffect2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("Particles/Rock Effects", g_sRockEffects[iIndex], sizeof(g_sRockEffects[]), "1234")) : (kvSuperTanks.GetString("Particles/Rock Effects", g_sRockEffects2[iIndex], sizeof(g_sRockEffects2[]), g_sRockEffects[iIndex]));
			main ? (g_flClawDamage[iIndex] = kvSuperTanks.GetFloat("Enhancements/Claw Damage", 5.0)) : (g_flClawDamage2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Claw Damage", g_flClawDamage[iIndex]));
			main ? (g_flClawDamage[iIndex] = flClamp(g_flClawDamage[iIndex], 0.0, 9999999999.0)) : (g_flClawDamage2[iIndex] = flClamp(g_flClawDamage2[iIndex], 0.0, 9999999999.0));
			main ? (g_iExtraHealth[iIndex] = kvSuperTanks.GetNum("Enhancements/Extra Health", 0)) : (g_iExtraHealth2[iIndex] = kvSuperTanks.GetNum("Enhancements/Extra Health", g_iExtraHealth[iIndex]));
			main ? (g_iExtraHealth[iIndex] = iClamp(g_iExtraHealth[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iExtraHealth2[iIndex] = iClamp(g_iExtraHealth2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
			main ? (g_flRockDamage[iIndex] = kvSuperTanks.GetFloat("Enhancements/Rock Damage", 5.0)) : (g_flRockDamage2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Rock Damage", g_flRockDamage[iIndex]));
			main ? (g_flRockDamage[iIndex] = flClamp(g_flRockDamage[iIndex], 0.0, 9999999999.0)) : (g_flRockDamage2[iIndex] = flClamp(g_flRockDamage2[iIndex], 0.0, 9999999999.0));
			main ? (g_flRunSpeed[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", 1.0)) : (g_flRunSpeed2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Run Speed", g_flRunSpeed[iIndex]));
			main ? (g_flRunSpeed[iIndex] = flClamp(g_flRunSpeed[iIndex], 0.1, 3.0)) : (g_flRunSpeed2[iIndex] = flClamp(g_flRunSpeed2[iIndex], 0.1, 3.0));
			main ? (g_flThrowInterval[iIndex] = kvSuperTanks.GetFloat("Enhancements/Throw Interval", 5.0)) : (g_flThrowInterval2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Throw Interval", g_flThrowInterval[iIndex]));
			main ? (g_flThrowInterval[iIndex] = flClamp(g_flThrowInterval[iIndex], 0.1, 9999999999.0)) : (g_flThrowInterval2[iIndex] = flClamp(g_flThrowInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_iBulletImmunity[iIndex] = kvSuperTanks.GetNum("Immunities/Bullet Immunity", 0)) : (g_iBulletImmunity2[iIndex] = kvSuperTanks.GetNum("Immunities/Bullet Immunity", g_iBulletImmunity[iIndex]));
			main ? (g_iBulletImmunity[iIndex] = iClamp(g_iBulletImmunity[iIndex], 0, 1)) : (g_iBulletImmunity2[iIndex] = iClamp(g_iBulletImmunity2[iIndex], 0, 1));
			main ? (g_iExplosiveImmunity[iIndex] = kvSuperTanks.GetNum("Immunities/Explosive Immunity", 0)) : (g_iExplosiveImmunity2[iIndex] = kvSuperTanks.GetNum("Immunities/Explosive Immunity", g_iExplosiveImmunity[iIndex]));
			main ? (g_iExplosiveImmunity[iIndex] = iClamp(g_iExplosiveImmunity[iIndex], 0, 1)) : (g_iExplosiveImmunity2[iIndex] = iClamp(g_iExplosiveImmunity2[iIndex], 0, 1));
			main ? (g_iFireImmunity[iIndex] = kvSuperTanks.GetNum("Immunities/Fire Immunity", 0)) : (g_iFireImmunity2[iIndex] = kvSuperTanks.GetNum("Immunities/Fire Immunity", g_iFireImmunity[iIndex]));
			main ? (g_iFireImmunity[iIndex] = iClamp(g_iFireImmunity[iIndex], 0, 1)) : (g_iFireImmunity2[iIndex] = iClamp(g_iFireImmunity2[iIndex], 0, 1));
			main ? (g_iMeleeImmunity[iIndex] = kvSuperTanks.GetNum("Immunities/Melee Immunity", 0)) : (g_iMeleeImmunity2[iIndex] = kvSuperTanks.GetNum("Immunities/Melee Immunity", g_iMeleeImmunity[iIndex]));
			main ? (g_iMeleeImmunity[iIndex] = iClamp(g_iMeleeImmunity[iIndex], 0, 1)) : (g_iMeleeImmunity2[iIndex] = iClamp(g_iMeleeImmunity2[iIndex], 0, 1));
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
	Call_StartForward(g_hConfigsForward);
	Call_PushString(savepath);
	Call_PushCell(main);
	Call_Finish();
}

stock void vBoss(int client, int limit, int stages, int type, int stage)
{
	if (stages < stage)
	{
		return;
	}
	int iHealth = GetClientHealth(client);
	if (iHealth <= limit)
	{
		g_iBossStageCount[client] = stage;
		vNewTankSettings(client);
		vSetColor(client, type);
		DataPack dpTankSpawn = new DataPack();
		CreateDataTimer(0.1, tTimerTankSpawn, dpTankSpawn, TIMER_FLAG_NO_MAPCHANGE);
		dpTankSpawn.WriteCell(GetClientUserId(client)), dpTankSpawn.WriteCell(1);
		int iNewHealth = g_iTankHealth[client] + limit, iFinalHealth = (iNewHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iNewHealth;
		SetEntityHealth(client, iFinalHealth);
	}
}

stock void vNewTankSettings(int client)
{
	ExtinguishEntity(client);
	vAttachParticle(client, PARTICLE_ELECTRICITY, 2.0, 30.0);
	EmitSoundToAll(SOUND_BOSS, client);
	vRemoveProps(client);
	Call_StartForward(g_hBossStageForward);
	Call_PushCell(client);
	Call_Finish();
}

stock void vParticleEffects(int client)
{
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[client]] ? g_sParticleEffects[g_iTankType[client]] : g_sParticleEffects2[g_iTankType[client]];
	if (iParticleEffect(client) == 1 && bIsTankAllowed(client) && IsPlayerAlive(client))
	{
		if (StrContains(sParticleEffects, "1") != -1)
		{
			CreateTimer(0.75, tTimerBloodEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		if (StrContains(sParticleEffects, "2") != -1)
		{
			CreateTimer(0.75, tTimerElectricEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		if (StrContains(sParticleEffects, "3") != -1)
		{
			CreateTimer(0.75, tTimerFireEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		if (StrContains(sParticleEffects, "4") != -1)
		{
			CreateTimer(2.0, tTimerIceEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		if (StrContains(sParticleEffects, "5") != -1)
		{
			CreateTimer(6.0, tTimerMeteorEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		if (StrContains(sParticleEffects, "6") != -1)
		{
			CreateTimer(1.5, tTimerSmokeEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		if (StrContains(sParticleEffects, "7") != -1 && bIsValidGame())
		{
			CreateTimer(2.0, tTimerSpitEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}

stock void vRemoveProps(int client)
{
	int iProp = -1;
	while ((iProp = FindEntityByClassname(iProp, "prop_dynamic")) != INVALID_ENT_REFERENCE)
	{
		char sModel[128];
		GetEntPropString(iProp, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		if (StrEqual(sModel, MODEL_JETPACK, false) || StrEqual(sModel, MODEL_CONCRETE, false) || StrEqual(sModel, MODEL_TIRES, false) || StrEqual(sModel, MODEL_TANK, false))
		{
			int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
			if (iOwner == client)
			{
				RemoveEntity(iProp);
			}
		}
	}
	while ((iProp = FindEntityByClassname(iProp, "beam_spotlight")) != INVALID_ENT_REFERENCE)
	{
		int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iOwner == client)
		{
			RemoveEntity(iProp);
		}
	}
	if (bIsValidGame())
	{
		SetEntProp(client, Prop_Send, "m_iGlowType", 0);
		SetEntProp(client, Prop_Send, "m_glowColorOverride", 0);
	}
}

stock void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			g_iBossStageCount[iPlayer] = 0;
			g_iTankType[iPlayer] = 0;
			vSpawnModes(iPlayer, false);
		}
	}
}

stock void vSpawnModes(int client, bool status)
{
	g_bBoss[client] = status;
	g_bRandomized[client] = status;
	g_bTransformed[client] = status;
}

stock void vSetColor(int client, int value)
{
	char sSet[2][16], sTankColors[28], sRGB[4][4], sGlow[3][4];
	sTankColors = !g_bTankConfig[value] ? g_sTankColors[value] : g_sTankColors2[value];
	TrimString(sTankColors);
	ExplodeString(sTankColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
	ExplodeString(sSet[0], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
	TrimString(sRGB[0]);
	int iRed = (!StrEqual(sRGB[0], "")) ? StringToInt(sRGB[0]) : 255;
	iRed = iClamp(iRed, 0, 255);
	TrimString(sRGB[1]);
	int iGreen = (!StrEqual(sRGB[1], "")) ? StringToInt(sRGB[1]) : 255;
	iGreen = iClamp(iGreen, 0, 255);
	TrimString(sRGB[2]);
	int iBlue = (!StrEqual(sRGB[2], "")) ? StringToInt(sRGB[2]) : 255;
	iBlue = iClamp(iBlue, 0, 255);
	TrimString(sRGB[3]);
	int iAlpha = (!StrEqual(sRGB[3], "")) ? StringToInt(sRGB[3]) : 255;
	iAlpha = iClamp(iAlpha, 0, 255);
	ExplodeString(sSet[1], ",", sGlow, sizeof(sGlow), sizeof(sGlow[]));
	TrimString(sGlow[0]);
	int iRed2 = (!StrEqual(sGlow[0], "")) ? StringToInt(sGlow[0]) : 255;
	iRed2 = iClamp(iRed2, 0, 255);
	TrimString(sGlow[1]);
	int iGreen2 = (!StrEqual(sGlow[1], "")) ? StringToInt(sGlow[1]) : 255;
	iGreen2 = iClamp(iGreen2, 0, 255);
	TrimString(sGlow[2]);
	int iBlue2 = (!StrEqual(sGlow[2], "")) ? StringToInt(sGlow[2]) : 255;
	iBlue2 = iClamp(iBlue2, 0, 255);
	if (iGlowOutline(value) == 1 && bIsValidGame())
	{
		SetEntProp(client, Prop_Send, "m_iGlowType", 3);
		SetEntProp(client, Prop_Send, "m_glowColorOverride", iGetRGBColor(iRed2, iGreen2, iBlue2));
	}
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, iRed, iGreen, iBlue, iAlpha);
	g_iTankType[client] = value;
}

stock void vSetName(int client, const char[] oldname, const char[] name, int mode)
{
	if (bIsTankAllowed(client) && IsPlayerAlive(client))
	{
		char sSet[5][16], sPropsColors[80], sRGB[4][4], sRGB2[4][4], sRGB3[4][4], sRGB4[4][4], sRGB5[4][4];
		sPropsColors = !g_bTankConfig[g_iTankType[client]] ? g_sPropsColors[g_iTankType[client]] : g_sPropsColors2[g_iTankType[client]];
		TrimString(sPropsColors);
		ExplodeString(sPropsColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
		ExplodeString(sSet[0], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
		TrimString(sRGB[0]);
		int iRed = (!StrEqual(sRGB[0], "")) ? StringToInt(sRGB[0]) : 255;
		iRed = iClamp(iRed, 0, 255);
		TrimString(sRGB[1]);
		int iGreen = (!StrEqual(sRGB[1], "")) ? StringToInt(sRGB[1]) : 255;
		iGreen = iClamp(iGreen, 0, 255);
		TrimString(sRGB[2]);
		int iBlue = (!StrEqual(sRGB[2], "")) ? StringToInt(sRGB[2]) : 255;
		iBlue = iClamp(iBlue, 0, 255);
		TrimString(sRGB[3]);
		int iAlpha = (!StrEqual(sRGB[3], "")) ? StringToInt(sRGB[3]) : 255;
		iAlpha = iClamp(iAlpha, 0, 255);
		ExplodeString(sSet[1], ",", sRGB2, sizeof(sRGB2), sizeof(sRGB2[]));
		TrimString(sRGB2[0]);
		int iRed2 = (!StrEqual(sRGB2[0], "")) ? StringToInt(sRGB2[0]) : 255;
		iRed2 = iClamp(iRed2, 0, 255);
		TrimString(sRGB2[1]);
		int iGreen2 = (!StrEqual(sRGB2[1], "")) ? StringToInt(sRGB2[1]) : 255;
		iGreen2 = iClamp(iGreen2, 0, 255);
		TrimString(sRGB2[2]);
		int iBlue2 = (!StrEqual(sRGB2[2], "")) ? StringToInt(sRGB2[2]) : 255;
		iBlue2 = iClamp(iBlue2, 0, 255);
		TrimString(sRGB2[3]);
		int iAlpha2 = (!StrEqual(sRGB2[3], "")) ? StringToInt(sRGB2[3]) : 255;
		iAlpha2 = iClamp(iAlpha2, 0, 255);
		ExplodeString(sSet[2], ",", sRGB3, sizeof(sRGB3), sizeof(sRGB3[]));
		TrimString(sRGB3[0]);
		int iRed3 = (!StrEqual(sRGB3[0], "")) ? StringToInt(sRGB3[0]) : 255;
		iRed3 = iClamp(iRed3, 0, 255);
		TrimString(sRGB3[1]);
		int iGreen3 = (!StrEqual(sRGB3[1], "")) ? StringToInt(sRGB3[1]) : 255;
		iGreen3 = iClamp(iGreen3, 0, 255);
		TrimString(sRGB3[2]);
		int iBlue3 = (!StrEqual(sRGB3[2], "")) ? StringToInt(sRGB3[2]) : 255;
		iBlue3 = iClamp(iBlue3, 0, 255);
		TrimString(sRGB3[3]);
		int iAlpha3 = (!StrEqual(sRGB3[3], "")) ? StringToInt(sRGB3[3]) : 255;
		iAlpha3 = iClamp(iAlpha3, 0, 255);
		ExplodeString(sSet[3], ",", sRGB4, sizeof(sRGB4), sizeof(sRGB4[]));
		TrimString(sRGB4[0]);
		int iRed4 = (!StrEqual(sRGB4[0], "")) ? StringToInt(sRGB4[0]) : 255;
		iRed4 = iClamp(iRed4, 0, 255);
		TrimString(sRGB4[1]);
		int iGreen4 = (!StrEqual(sRGB4[1], "")) ? StringToInt(sRGB4[1]) : 255;
		iGreen4 = iClamp(iGreen4, 0, 255);
		TrimString(sRGB4[2]);
		int iBlue4 = (!StrEqual(sRGB4[2], "")) ? StringToInt(sRGB4[2]) : 255;
		iBlue4 = iClamp(iBlue4, 0, 255);
		TrimString(sRGB4[3]);
		int iAlpha4 = (!StrEqual(sRGB4[3], "")) ? StringToInt(sRGB4[3]) : 255;
		iAlpha4 = iClamp(iAlpha4, 0, 255);
		ExplodeString(sSet[4], ",", sRGB5, sizeof(sRGB5), sizeof(sRGB5[]));
		TrimString(sRGB5[0]);
		int iRed5 = (!StrEqual(sRGB5[0], "")) ? StringToInt(sRGB5[0]) : 255;
		iRed5 = iClamp(iRed5, 0, 255);
		TrimString(sRGB5[1]);
		int iGreen5 = (!StrEqual(sRGB5[1], "")) ? StringToInt(sRGB5[1]) : 255;
		iGreen5 = iClamp(iGreen5, 0, 255);
		TrimString(sRGB5[2]);
		int iBlue5 = (!StrEqual(sRGB5[2], "")) ? StringToInt(sRGB5[2]) : 255;
		iBlue5 = iClamp(iBlue5, 0, 255);
		TrimString(sRGB5[3]);
		int iAlpha5 = (!StrEqual(sRGB5[3], "")) ? StringToInt(sRGB5[3]) : 255;
		iAlpha5 = iClamp(iAlpha5, 0, 255);
		char sSet2[6][4], sPropsChance[12], sPropsAttached[7];
		sPropsChance = !g_bTankConfig[g_iTankType[client]] ? g_sPropsChance[g_iTankType[client]] : g_sPropsChance2[g_iTankType[client]];
		TrimString(sPropsChance);
		ExplodeString(sPropsChance, ",", sSet2, sizeof(sSet2), sizeof(sSet2[]));
		TrimString(sSet2[0]);
		int iChance = (!StrEqual(sSet2[0], "")) ? StringToInt(sSet2[0]) : 3;
		iChance = iClamp(iChance, 1, 9999999999);
		TrimString(sSet2[1]);
		int iChance2 = (!StrEqual(sSet2[1], "")) ? StringToInt(sSet2[1]) : 3;
		iChance2 = iClamp(iChance2, 1, 9999999999);
		TrimString(sSet2[2]);
		int iChance3 = (!StrEqual(sSet2[2], "")) ? StringToInt(sSet2[2]) : 3;
		iChance3 = iClamp(iChance3, 1, 9999999999);
		TrimString(sSet2[3]);
		int iChance4 = (!StrEqual(sSet2[3], "")) ? StringToInt(sSet2[3]) : 3;
		iChance4 = iClamp(iChance4, 1, 9999999999);
		TrimString(sSet2[4]);
		int iChance5 = (!StrEqual(sSet2[4], "")) ? StringToInt(sSet2[4]) : 3;
		iChance5 = iClamp(iChance5, 1, 9999999999);
		TrimString(sSet2[5]);
		int iChance6 = (!StrEqual(sSet2[5], "")) ? StringToInt(sSet2[5]) : 3;
		iChance6 = iClamp(iChance6, 1, 9999999999);
		sPropsAttached = !g_bTankConfig[g_iTankType[client]] ? g_sPropsAttached[g_iTankType[client]] : g_sPropsAttached2[g_iTankType[client]];
		if (GetRandomInt(1, iChance) == 1 && StrContains(sPropsAttached, "1") != -1)
		{
			CreateTimer(0.25, tTimerBlurEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
		float flOrigin[3], flAngles[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
		int iBeam[7], iRandom = GetRandomInt(1, 6);
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
					SetEntityRenderColor(iBeam[iLight], iRed, iGreen, iBlue, iAlpha);
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
				}
			}
		}
		GetClientEyePosition(client, flOrigin);
		GetClientAbsAngles(client, flAngles);
		int iJetpack[5], iRandom2 = GetRandomInt(1, 4);
		for (int iOzTank = 1; iOzTank <= iRandom2; iOzTank++)
		{
			if (GetRandomInt(1, iChance3) == 1 && StrContains(sPropsAttached, "3") != -1)
			{
				iJetpack[iOzTank] = CreateEntityByName("prop_dynamic_override");
				if (bIsValidEntity(iJetpack[iOzTank]))
				{
					SetEntityModel(iJetpack[iOzTank], MODEL_JETPACK);
					SetEntityRenderColor(iJetpack[iOzTank], iRed2, iGreen2, iBlue2, iAlpha2);
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
							SetEntityRenderColor(iFlame, iRed3, iGreen3, iBlue3, iAlpha3);
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
							float flOrigin2[3], flAngles3[3];
							vSetVector(flOrigin2, -2.0, 0.0, 26.0);
							vSetVector(flAngles3, 0.0, 0.0, 1.0);
							GetVectorAngles(flAngles3, flAngles3);
							TeleportEntity(iFlame, flOrigin2, flAngles3, NULL_VECTOR);
							DispatchSpawn(iFlame);
							AcceptEntityInput(iFlame, "TurnOn");
						}
					}
				}
			}
		}
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
		int iConcrete[41], iRandom3 = GetRandomInt(1, 40);
		for (int iRock = 1; iRock <= iRandom3; iRock++)
		{
			if (GetRandomInt(1, iChance5) == 1 && StrContains(sPropsAttached, "5") != -1)
			{
				iConcrete[iRock] = CreateEntityByName("prop_dynamic_override");
				if (bIsValidEntity(iConcrete[iRock]))
				{
					SetEntityModel(iConcrete[iRock], MODEL_CONCRETE);
					SetEntityRenderColor(iConcrete[iRock], iRed4, iGreen4, iBlue4, iAlpha4);
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
					if (bIsValidGame())
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
				}
			}
		}
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
		flAngles[0] += 90.0;
		int iWheel[5], iRandom4 = GetRandomInt(1, 4);
		for (int iTire = 1; iTire <= iRandom4; iTire++)
		{
			if (GetRandomInt(1, iChance6) == 1 && StrContains(sPropsAttached, "6") != -1)
			{
				iWheel[iTire] = CreateEntityByName("prop_dynamic_override");
				if (bIsValidEntity(iWheel[iTire]))
				{
					SetEntityModel(iWheel[iTire], MODEL_TIRES);
					SetEntityRenderColor(iWheel[iTire], iRed5, iGreen5, iBlue5, iAlpha5);
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
					if (bIsValidGame())
					{
						SetEntPropFloat(iWheel[iTire], Prop_Data, "m_flModelScale", 1.5);
					}
					SetEntPropEnt(iWheel[iTire], Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(iWheel[iTire], NULL_VECTOR, flAngles, NULL_VECTOR);
					DispatchSpawn(iWheel[iTire]);
				}
			}
		}
		SetClientName(client, name);
		int iAnnounceArrival = !g_bGeneralConfig ? g_iAnnounceArrival : g_iAnnounceArrival2;
		if (iAnnounceArrival == 1)
		{
			switch (mode)
			{
				case 0:
				{
					switch (GetRandomInt(1, 10))
					{
						case 1: PrintToChatAll("%s %t", ST_PREFIX2, "Arrival1", name);
						case 2: PrintToChatAll("%s %t", ST_PREFIX2, "Arrival2", name);
						case 3: PrintToChatAll("%s %t", ST_PREFIX2, "Arrival3", name);
						case 4: PrintToChatAll("%s %t", ST_PREFIX2, "Arrival4", name);
						case 5: PrintToChatAll("%s %t", ST_PREFIX2, "Arrival5", name);
						case 6: PrintToChatAll("%s %t", ST_PREFIX2, "Arrival6", name);
						case 7: PrintToChatAll("%s %t", ST_PREFIX2, "Arrival7", name);
						case 8: PrintToChatAll("%s %t", ST_PREFIX2, "Arrival8", name);
						case 9: PrintToChatAll("%s %t", ST_PREFIX2, "Arrival9", name);
						case 10: PrintToChatAll("%s %t", ST_PREFIX2, "Arrival10", name);
					}
				}
				case 1: PrintToChatAll("%s %t", ST_PREFIX2, "Evolved", oldname, name, g_iBossStageCount[client] + 1);
				case 2: PrintToChatAll("%s %t", ST_PREFIX2, "Randomized", oldname, name);
				case 3: PrintToChatAll("%s %t", ST_PREFIX2, "Transformed", oldname, name);
				case 4: PrintToChatAll("%s %t", ST_PREFIX2, "Untransformed", oldname, name);
			}
			int iTankNote = !g_bTankConfig[g_iTankType[client]] ? g_iTankNote[g_iTankType[client]] : g_iTankNote2[g_iTankType[client]];
			if (iTankNote == 1 && ST_CloneAllowed(client, g_bCloneInstalled))
			{
				char sTankNote[32];
				Format(sTankNote, sizeof(sTankNote), "Tank #%d", g_iTankType[client]);
				TranslationPhraseExists(sTankNote) ? PrintToChatAll("%s %t", ST_PREFIX3, sTankNote) : PrintToChatAll("%s No note found for this Super Tank.", ST_PREFIX3);
			}
		}
	}
}

stock void vTankCountCheck(int client, int wave)
{
	if (iGetTankCount() == wave)
	{
		return;
	}
	if (iGetTankCount() < wave)
	{
		CreateTimer(3.0, tTimerSpawnTanks, wave, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if (iGetTankCount() > wave)
	{
		IsFakeClient(client) ? KickClient(client) : ForcePlayerSuicide(client);
	}
}

stock void vThrowInterval(int client, float time)
{
	if (bIsTankAllowed(client) && IsPlayerAlive(client))
	{
		int iAbility = GetEntPropEnt(client, Prop_Send, "m_customAbility");
		if (iAbility > 0)
		{
			SetEntPropFloat(iAbility, Prop_Send, "m_duration", time);
			SetEntPropFloat(iAbility, Prop_Send, "m_timestamp", GetGameTime() + time);
		}
	}
}

stock bool bIsTankAllowed(int client)
{
	return bIsTank(client) && IsFakeClient(client);
}

stock float flThrowInterval(int client)
{
	return !g_bTankConfig[g_iTankType[client]] ? g_flThrowInterval[g_iTankType[client]] : g_flThrowInterval2[g_iTankType[client]];
}

stock int iFinaleTank(int value)
{
	return !g_bTankConfig[value] ? g_iFinaleTank[value] : g_iFinaleTank2[value];
}

stock int iFireImmunity(int client)
{
	return !g_bTankConfig[g_iTankType[client]] ? g_iFireImmunity[g_iTankType[client]] : g_iFireImmunity2[g_iTankType[client]];
}

stock int iGetMaxType()
{
	char sTypeRange[10], sRange[2][5];
	sTypeRange = !g_bGeneralConfig ? g_sTypeRange : g_sTypeRange2;
	ExplodeString(sTypeRange, "-", sRange, sizeof(sRange), sizeof(sRange[]));
	int iMaxType = (!StrEqual(sRange[1], "")) ? StringToInt(sRange[1]) : ST_MAXTYPES;
	iMaxType = iClamp(iMaxType, 1, ST_MAXTYPES);
	return iMaxType;
}

stock int iGetMinType()
{
	char sTypeRange[10], sRange[2][5];
	sTypeRange = !g_bGeneralConfig ? g_sTypeRange : g_sTypeRange2;
	ExplodeString(sTypeRange, "-", sRange, sizeof(sRange), sizeof(sRange[]));
	int iMinType = (!StrEqual(sRange[0], "")) ? StringToInt(sRange[0]) : 1;
	iMinType = iClamp(iMinType, 1, ST_MAXTYPES);
	return iMinType;
}

stock int iGetTankCount()
{
	int iTankCount;
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTank(iTank) && IsPlayerAlive(iTank) && !g_bSpawned[iTank])
		{
			iTankCount++;
		}
	}
	return iTankCount;
}

stock int iGetTypeCount(int type)
{
	int iType;
	for (int iTank = iGetMinType(); iTank <= iGetMaxType(); iTank++)
	{
		if (bIsTankAllowed(iTank) && IsPlayerAlive(iTank) && ST_CloneAllowed(iTank, g_bCloneInstalled) && g_iTankType[iTank] == type)
		{
			iType++;
		}
	}
	return iType;
}

stock int iGlowOutline(int value)
{
	return !g_bTankConfig[value] ? g_iGlowOutline[value] : g_iGlowOutline2[value];
}

stock int iParticleEffect(int client)
{
	return !g_bTankConfig[g_iTankType[client]] ? g_iParticleEffect[g_iTankType[client]] : g_iParticleEffect2[g_iTankType[client]];
}

stock int iPluginEnabled()
{
	return !g_bGeneralConfig ? g_iPluginEnabled : g_iPluginEnabled2;
}

stock int iRockEffect(int client)
{
	return !g_bTankConfig[g_iTankType[client]] ? g_iRockEffect[g_iTankType[client]] : g_iRockEffect2[g_iTankType[client]];
}

stock int iSpawnMode(int value)
{
	return !g_bTankConfig[value] ? g_iSpawnMode[value] : g_iSpawnMode2[value];
}

stock int iTankEnabled(int value)
{
	return !g_bTankConfig[value] ? g_iTankEnabled[value] : g_iTankEnabled2[value];
}

stock int iTypeLimit(int type)
{
	return !g_bTankConfig[type] ? g_iTypeLimit[type] : g_iTypeLimit2[type];
}

public void vSTEnableCvar(ConVar convar, const char[] oldValue, const char[] newValue)
{
	vPluginStatus();
}

public void vSTGameDifficultyCvar(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (StrContains(g_sConfigExecute, "1") != -1)
	{
		char sDifficulty[11], sDifficultyConfig[PLATFORM_MAX_PATH];
		g_cvSTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));
		BuildPath(Path_SM, sDifficultyConfig, sizeof(sDifficultyConfig), "data/super_tanks++/difficulty_configs/%s.cfg", sDifficulty);
		vLoadConfigs(sDifficultyConfig);
	}
}

public Action tTimerBloodEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (iParticleEffect(iTank) == 0 || StrContains(sParticleEffects, "1") == -1)
	{
		return Plugin_Stop;
	}
	vAttachParticle(iTank, PARTICLE_BLOOD, 0.75, 30.0);
	return Plugin_Continue;
}

public Action tTimerBlurEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	char sPropsAttached[7];
	sPropsAttached = !g_bTankConfig[g_iTankType[iTank]] ? g_sPropsAttached[g_iTankType[iTank]] : g_sPropsAttached2[g_iTankType[iTank]];
	if (StrContains(sPropsAttached, "1") == -1)
	{
		return Plugin_Stop;
	}
	char sSet[2][16], sTankColors[28], sRGB[4][4];
	sTankColors = !g_bTankConfig[g_iTankType[iTank]] ? g_sTankColors[g_iTankType[iTank]] : g_sTankColors2[g_iTankType[iTank]];
	TrimString(sTankColors);
	ExplodeString(sTankColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
	ExplodeString(sSet[0], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
	TrimString(sRGB[0]);
	int iRed = (!StrEqual(sRGB[0], "")) ? StringToInt(sRGB[0]) : 255;
	iRed = iClamp(iRed, 0, 255);
	TrimString(sRGB[1]);
	int iGreen = (!StrEqual(sRGB[1], "")) ? StringToInt(sRGB[1]) : 255;
	iGreen = iClamp(iGreen, 0, 255);
	TrimString(sRGB[2]);
	int iBlue = (!StrEqual(sRGB[2], "")) ? StringToInt(sRGB[2]) : 255;
	iBlue = iClamp(iBlue, 0, 255);
	TrimString(sRGB[3]);
	int iAlpha = (!StrEqual(sRGB[3], "")) ? StringToInt(sRGB[3]) : 255;
	iAlpha = iClamp(iAlpha, 0, 255);
	float flTankPos[3], flTankAng[3];
	GetClientAbsOrigin(iTank, flTankPos);
	GetClientAbsAngles(iTank, flTankAng);
	int iAnim = GetEntProp(iTank, Prop_Send, "m_nSequence"), iTankModel = CreateEntityByName("prop_dynamic");
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
	return Plugin_Continue;
}

public Action tTimerBoss(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vSpawnModes(iTank, false);
		return Plugin_Stop;
	}
	int iBossHealth = pack.ReadCell(), iBossHealth2 = pack.ReadCell(),
		iBossHealth3 = pack.ReadCell(), iBossHealth4 = pack.ReadCell(),
		iBossStages = pack.ReadCell(), iType = pack.ReadCell(),
		iType2 = pack.ReadCell(), iType3 = pack.ReadCell(),
		iType4 = pack.ReadCell();
	switch (g_iBossStageCount[iTank])
	{
		case 0: vBoss(iTank, iBossHealth, iBossStages, iType, 1);
		case 1: vBoss(iTank, iBossHealth2, iBossStages, iType2, 2);
		case 2: vBoss(iTank, iBossHealth3, iBossStages, iType3, 3);
		case 3: vBoss(iTank, iBossHealth4, iBossStages, iType4, 4);
	}
	return Plugin_Continue;
}

public Action tTimerElectricEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (iParticleEffect(iTank) == 0 || StrContains(sParticleEffects, "2") == -1)
	{
		return Plugin_Stop;
	}
	vAttachParticle(iTank, PARTICLE_ELECTRICITY, 0.75, 30.0);
	return Plugin_Continue;
}

public Action tTimerFireEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (iParticleEffect(iTank) == 0 || StrContains(sParticleEffects, "3") == -1)
	{
		return Plugin_Stop;
	}
	vAttachParticle(iTank, PARTICLE_FIRE, 0.75);
	return Plugin_Continue;
}

public Action tTimerIceEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (iParticleEffect(iTank) == 0 || StrContains(sParticleEffects, "4") == -1)
	{
		return Plugin_Stop;
	}
	vAttachParticle(iTank, PARTICLE_ICE, 2.0, 30.0);
	return Plugin_Continue;
}

public Action tTimerKillStuckTank(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank) || !bIsPlayerIncapacitated(iTank))
	{
		return Plugin_Stop;
	}
	ForcePlayerSuicide(iTank);
	return Plugin_Continue;
}

public Action tTimerMeteorEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (iParticleEffect(iTank) == 0 || StrContains(sParticleEffects, "5") == -1)
	{
		return Plugin_Stop;
	}
	vAttachParticle(iTank, PARTICLE_METEOR, 6.0, 30.0);
	return Plugin_Continue;
}

public Action tTimerRandomize(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vSpawnModes(iTank, false);
		return Plugin_Stop;
	}
	vNewTankSettings(iTank);
	int iTypeCount, iTankTypes[ST_MAXTYPES + 1];
	for (int iIndex = iGetMinType(); iIndex <= iGetMaxType(); iIndex++)
	{
		if (iTankEnabled(iIndex) == 0 || (iTypeLimit(iIndex) > 0 && iGetTypeCount(iIndex) >= iTypeLimit(iIndex)) || (iFinaleTank(iIndex) == 1 && (!bIsFinaleMap() || g_iTankWave <= 0)) || g_iTankType[iTank] == iIndex)
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
	DataPack dpTankSpawn = new DataPack();
	CreateDataTimer(0.1, tTimerTankSpawn, dpTankSpawn, TIMER_FLAG_NO_MAPCHANGE);
	dpTankSpawn.WriteCell(GetClientUserId(iTank)), dpTankSpawn.WriteCell(2);
	return Plugin_Continue;
}

public Action tTimerSmokeEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (iParticleEffect(iTank) == 0 || StrContains(sParticleEffects, "6") == -1)
	{
		return Plugin_Stop;
	}
	vAttachParticle(iTank, PARTICLE_SMOKE, 1.5);
	return Plugin_Continue;
}

public Action tTimerSpitEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (iParticleEffect(iTank) == 0 || StrContains(sParticleEffects, "7") == -1)
	{
		return Plugin_Stop;
	}
	vAttachParticle(iTank, PARTICLE_SPIT, 2.0, 30.0);
	return Plugin_Continue;
}

public Action tTimerTransform(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vSpawnModes(iTank, false);
		return Plugin_Stop;
	}
	vNewTankSettings(iTank);
	char sTransform[10][5], sTransformTypes[80];
	sTransformTypes = !g_bTankConfig[g_iTankType[iTank]] ? g_sTransformTypes[g_iTankType[iTank]] : g_sTransformTypes2[g_iTankType[iTank]];
	ExplodeString(sTransformTypes, ",", sTransform, sizeof(sTransform), sizeof(sTransform[]));
	int iTypeCount, iTankTypes[ST_MAXTYPES + 1];
	for (int iTypes = 0; iTypes < sizeof(sTransform); iTypes++)
	{
		if (StrEqual(sTransform[iTypes], ""))
		{
			continue;
		}
		iTankTypes[iTypeCount + 1] = StringToInt(sTransform[iTypes]);
		iTypeCount++;
	}
	if (iTypeCount > 0)
	{
		int iChosen = iTankTypes[GetRandomInt(1, iTypeCount)];
		vSetColor(iTank, iChosen);
	}
	DataPack dpTankSpawn = new DataPack();
	CreateDataTimer(0.1, tTimerTankSpawn, dpTankSpawn, TIMER_FLAG_NO_MAPCHANGE);
	dpTankSpawn.WriteCell(GetClientUserId(iTank)), dpTankSpawn.WriteCell(3);
	return Plugin_Continue;
}

public Action tTimerUntransform(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank) || !ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		vSpawnModes(iTank, false);
		return Plugin_Stop;
	}
	int iTankType = pack.ReadCell();
	vNewTankSettings(iTank);
	vSetColor(iTank, iTankType);
	DataPack dpTankSpawn = new DataPack();
	CreateDataTimer(0.1, tTimerTankSpawn, dpTankSpawn, TIMER_FLAG_NO_MAPCHANGE);
	dpTankSpawn.WriteCell(GetClientUserId(iTank)), dpTankSpawn.WriteCell(4);
	return Plugin_Continue;
}

public Action tTimerUpdatePlayerCount(Handle timer)
{
	if (iPluginEnabled() == 0 || !g_bPluginEnabled || StrContains(g_sConfigExecute, "5") == -1)
	{
		return Plugin_Continue;
	}
	char sCountConfig[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/super_tanks++/playercount_configs/%d.cfg", iGetPlayerCount());
	vLoadConfigs(sCountConfig);
	return Plugin_Continue;
}

public Action tTimerTankHealthUpdate(Handle timer)
{
	if (iPluginEnabled() == 0 || !g_bPluginEnabled)
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
					if (StrEqual(sClassname, "player"))
					{
						if (bIsTankAllowed(iTarget) && IsPlayerAlive(iTarget))
						{
							int iHealth = GetClientHealth(iTarget);
							switch (iDisplayHealth)
							{
								case 1: PrintHintText(iSurvivor, "%N", iTarget);
								case 2: PrintHintText(iSurvivor, "%d HP", iHealth);
								case 3: PrintHintText(iSurvivor, "%N (%d HP)", iTarget, iHealth);
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
	if (iPluginEnabled() == 0 || !g_bPluginEnabled)
	{
		return Plugin_Continue;
	}
	g_cvSTMaxPlayerZombies.SetString("32");
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTankAllowed(iTank) && IsPlayerAlive(iTank) && g_iTankType[iTank] > 0 && ST_CloneAllowed(iTank, g_bCloneInstalled))
		{
			switch (iSpawnMode(g_iTankType[iTank]))
			{
				case 1:
				{
					if (!g_bBoss[iTank])
					{
						vSpawnModes(iTank, true);
						char sSet[4][6], sBossHealthStages[25], sSet2[4][5], sBossTypes[20];
						sBossHealthStages = !g_bTankConfig[g_iTankType[iTank]] ? g_sBossHealthStages[g_iTankType[iTank]] : g_sBossHealthStages2[g_iTankType[iTank]];
						TrimString(sBossHealthStages);
						ExplodeString(sBossHealthStages, ",", sSet, sizeof(sSet), sizeof(sSet[]));
						TrimString(sSet[0]);
						int iBossHealth = (!StrEqual(sSet[0], "")) ? StringToInt(sSet[0]) : 5000;
						iBossHealth = iClamp(iBossHealth, 1, ST_MAXHEALTH);
						TrimString(sSet[1]);
						int iBossHealth2 = (!StrEqual(sSet[1], "")) ? StringToInt(sSet[1]) : 2500;
						iBossHealth2 = iClamp(iBossHealth2, 1, ST_MAXHEALTH);
						TrimString(sSet[2]);
						int iBossHealth3 = (!StrEqual(sSet[2], "")) ? StringToInt(sSet[2]) : 1500;
						iBossHealth3 = iClamp(iBossHealth3, 1, ST_MAXHEALTH);
						TrimString(sSet[3]);
						int iBossHealth4 = (!StrEqual(sSet[3], "")) ? StringToInt(sSet[3]) : 1000;
						iBossHealth4 = iClamp(iBossHealth4, 1, ST_MAXHEALTH);
						int iBossStages = !g_bTankConfig[g_iTankType[iTank]] ? g_iBossStages[g_iTankType[iTank]] : g_iBossStages2[g_iTankType[iTank]];
						sBossTypes = !g_bTankConfig[ST_TankType(iTank)] ? g_sBossTypes[ST_TankType(iTank)] : g_sBossTypes2[ST_TankType(iTank)];
						TrimString(sBossTypes);
						ExplodeString(sBossTypes, ",", sSet2, sizeof(sSet2), sizeof(sSet2[]));
						TrimString(sSet2[0]);
						int iType = (!StrEqual(sSet2[0], "")) ? StringToInt(sSet2[0]) : 2;
						iType = iClamp(iType, 1, 5000);
						TrimString(sSet2[1]);
						int iType2 = (!StrEqual(sSet2[1], "")) ? StringToInt(sSet2[1]) : 3;
						iType2 = iClamp(iType2, 1, 5000);
						TrimString(sSet2[2]);
						int iType3 = (!StrEqual(sSet2[2], "")) ? StringToInt(sSet2[2]) : 4;
						iType3 = iClamp(iType3, 1, 5000);
						TrimString(sSet2[3]);
						int iType4 = (!StrEqual(sSet2[3], "")) ? StringToInt(sSet2[3]) : 5;
						iType4 = iClamp(iType4, 1, 5000);
						DataPack dpBoss = new DataPack();
						CreateDataTimer(1.0, tTimerBoss, dpBoss, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						dpBoss.WriteCell(GetClientUserId(iTank)), dpBoss.WriteCell(iBossHealth), dpBoss.WriteCell(iBossHealth2), dpBoss.WriteCell(iBossHealth3), dpBoss.WriteCell(iBossHealth4), dpBoss.WriteCell(iBossStages), dpBoss.WriteCell(iType), dpBoss.WriteCell(iType2), dpBoss.WriteCell(iType3), dpBoss.WriteCell(iType4);
					}
				}
				case 2:
				{
					if (!g_bRandomized[iTank])
					{
						vSpawnModes(iTank, true);
						float flRandomInterval = !g_bTankConfig[g_iTankType[iTank]] ? g_flRandomInterval[g_iTankType[iTank]] : g_flRandomInterval2[g_iTankType[iTank]];
						CreateTimer(flRandomInterval, tTimerRandomize, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					}
				}
				case 3:
				{
					if (!g_bTransformed[iTank])
					{
						vSpawnModes(iTank, true);
						float flTransformDelay = !g_bTankConfig[g_iTankType[iTank]] ? g_flTransformDelay[g_iTankType[iTank]] : g_flTransformDelay2[g_iTankType[iTank]],
							flTransformDuration = !g_bTankConfig[g_iTankType[iTank]] ? g_flTransformDuration[g_iTankType[iTank]] : g_flTransformDuration2[g_iTankType[iTank]];
						CreateTimer(flTransformDelay, tTimerTransform, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
						DataPack dpUntransform = new DataPack();
						CreateDataTimer(flTransformDuration + flTransformDelay, tTimerUntransform, dpUntransform, TIMER_FLAG_NO_MAPCHANGE);
						dpUntransform.WriteCell(GetClientUserId(iTank)), dpUntransform.WriteCell(g_iTankType[iTank]);
					}
				}
			}
			if (iFireImmunity(iTank) == 1 && bIsPlayerBurning(iTank))
			{
				ExtinguishEntity(iTank);
				SetEntPropFloat(iTank, Prop_Send, "m_burnPercent", 1.0);
			}
			float flRunSpeed = !g_bTankConfig[g_iTankType[iTank]] ? g_flRunSpeed[g_iTankType[iTank]] : g_flRunSpeed2[g_iTankType[iTank]];
			SetEntPropFloat(iTank, Prop_Send, "m_flLaggedMovementValue", flRunSpeed);
			Call_StartForward(g_hAbilityForward);
			Call_PushCell(iTank);
			Call_Finish();
		}
	}
	return Plugin_Continue;
}

public Action tTimerTankSpawn(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iMode = pack.ReadCell();
	vParticleEffects(iTank);
	vThrowInterval(iTank, flThrowInterval(iTank));
	char sCurrentName[MAX_NAME_LENGTH + 1], sTankName[MAX_NAME_LENGTH + 1];
	GetClientName(iTank, sCurrentName, sizeof(sCurrentName));
	if (StrEqual(sCurrentName, ""))
	{
		sCurrentName = "Tank";
	}
	sTankName = !g_bTankConfig[g_iTankType[iTank]] ? g_sTankName[g_iTankType[iTank]] : g_sTankName2[g_iTankType[iTank]];
	if (StrEqual(sTankName, ""))
	{
		sTankName = "Tank";
	}
	vSetName(iTank, sCurrentName, sTankName, iMode);
	if (iMode == 0 && ST_CloneAllowed(iTank, g_bCloneInstalled))
	{
		int iHealth = GetClientHealth(iTank),
			iMultiHealth = !g_bGeneralConfig ? g_iMultiHealth : g_iMultiHealth2,
			iExtraHealth = !g_bTankConfig[g_iTankType[iTank]] ? g_iExtraHealth[g_iTankType[iTank]] : g_iExtraHealth2[g_iTankType[iTank]],
			iExtraHealthNormal = iHealth + iExtraHealth,
			iExtraHealthBoost = (iGetHumanCount() > 1) ? ((iHealth * iGetHumanCount()) + iExtraHealth) : iExtraHealthNormal,
			iExtraHealthBoost2 = (iGetHumanCount() > 1) ? (iHealth + (iGetHumanCount() * iExtraHealth)) : iExtraHealthNormal,
			iExtraHealthBoost3 = (iGetHumanCount() > 1) ? (iGetHumanCount() * (iHealth + iExtraHealth)) : iExtraHealthNormal,
			iNoBoost = (iExtraHealthNormal > ST_MAXHEALTH) ? ST_MAXHEALTH : iExtraHealthNormal,
			iBoost = (iExtraHealthBoost > ST_MAXHEALTH) ? ST_MAXHEALTH : iExtraHealthBoost,
			iBoost2 = (iExtraHealthBoost2 > ST_MAXHEALTH) ? ST_MAXHEALTH : iExtraHealthBoost2,
			iBoost3 = (iExtraHealthBoost3 > ST_MAXHEALTH) ? ST_MAXHEALTH : iExtraHealthBoost3,
			iNegaNoBoost = (iExtraHealthNormal < iHealth) ? 1 : iExtraHealthNormal,
			iNegaBoost = (iExtraHealthBoost < iHealth) ? 1 : iExtraHealthBoost,
			iNegaBoost2 = (iExtraHealthBoost2 < iHealth) ? 1 : iExtraHealthBoost2,
			iNegaBoost3 = (iExtraHealthBoost3 < iHealth) ? 1 : iExtraHealthBoost3,
			iFinalNoHealth = (iExtraHealthNormal >= 0) ? iNoBoost : iNegaNoBoost,
			iFinalHealth = (iExtraHealthNormal >= 0) ? iBoost : iNegaBoost,
			iFinalHealth2 = (iExtraHealthNormal >= 0) ? iBoost2 : iNegaBoost2,
			iFinalHealth3 = (iExtraHealthNormal >= 0) ? iBoost3 : iNegaBoost3;
		switch (iMultiHealth)
		{
			case 0: SetEntityHealth(iTank, iFinalNoHealth);
			case 1: SetEntityHealth(iTank, iFinalHealth);
			case 2: SetEntityHealth(iTank, iFinalHealth2);
			case 3: SetEntityHealth(iTank, iFinalHealth3);
		}
		g_iTankHealth[iTank] = GetClientHealth(iTank);
	}
	return Plugin_Continue;
}

public Action tTimerRockEffects(Handle timer, DataPack pack)
{
	pack.Reset();
	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (iRock == INVALID_ENT_REFERENCE || !bIsValidEntity(iRock))
	{
		return Plugin_Stop;
	}
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	char sRockEffects[5];
	pack.ReadString(sRockEffects, sizeof(sRockEffects));
	if (iRockEffect(iTank) == 0)
	{
		return Plugin_Stop;
	}
	char sClassname[32];
	GetEntityClassname(iRock, sClassname, sizeof(sClassname));
	if (StrEqual(sClassname, "tank_rock"))
	{
		if (StrContains(sRockEffects, "1") != -1)
		{
			vAttachParticle(iRock, PARTICLE_BLOOD, 0.75);
		}
		if (StrContains(sRockEffects, "2") != -1)
		{
			vAttachParticle(iRock, PARTICLE_ELECTRICITY, 0.75);
		}
		if (StrContains(sRockEffects, "3") != -1)
		{
			IgniteEntity(iRock, 100.0);
		}
		if (StrContains(sRockEffects, "4") != -1)
		{
			vAttachParticle(iRock, PARTICLE_SPIT, 0.75);
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

public Action tTimerRockThrow(Handle timer, any entity)
{
	if ((entity = EntRefToEntIndex(entity)) == INVALID_ENT_REFERENCE || !bIsValidEntity(entity))
	{
		return Plugin_Stop;
	}
	int iThrower = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
	if (iThrower == 0 || !bIsTankAllowed(iThrower) || !IsPlayerAlive(iThrower))
	{
		return Plugin_Stop;
	}
	char sSet[5][16], sPropsColors[80], sRGB[4][4], sRockEffects[5];
	sPropsColors = !g_bTankConfig[g_iTankType[iThrower]] ? g_sPropsColors[g_iTankType[iThrower]] : g_sPropsColors2[g_iTankType[iThrower]];
	TrimString(sPropsColors);
	ExplodeString(sPropsColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
	ExplodeString(sSet[3], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
	TrimString(sRGB[0]);
	int iRed = (!StrEqual(sRGB[0], "")) ? StringToInt(sRGB[0]) : 255;
	iRed = iClamp(iRed, 0, 255);
	TrimString(sRGB[1]);
	int iGreen = (!StrEqual(sRGB[1], "")) ? StringToInt(sRGB[1]) : 255;
	iGreen = iClamp(iGreen, 0, 255);
	TrimString(sRGB[2]);
	int iBlue = (!StrEqual(sRGB[2], "")) ? StringToInt(sRGB[2]) : 255;
	iBlue = iClamp(iBlue, 0, 255);
	TrimString(sRGB[3]);
	int iAlpha = (!StrEqual(sRGB[3], "")) ? StringToInt(sRGB[3]) : 255;
	iAlpha = iClamp(iAlpha, 0, 255);
	SetEntityRenderColor(entity, iRed, iGreen, iBlue, iAlpha);
	sRockEffects = !g_bTankConfig[g_iTankType[iThrower]] ? g_sRockEffects[g_iTankType[iThrower]] : g_sRockEffects2[g_iTankType[iThrower]];
	if (iRockEffect(iThrower) == 1 && !StrEqual(sRockEffects, ""))
	{
		DataPack dpRockEffects = new DataPack();
		CreateDataTimer(0.75, tTimerRockEffects, dpRockEffects, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpRockEffects.WriteCell(EntIndexToEntRef(entity)), dpRockEffects.WriteCell(GetClientUserId(iThrower)), dpRockEffects.WriteString(sRockEffects);
	}
	Call_StartForward(g_hRockThrowForward);
	Call_PushCell(iThrower);
	Call_PushCell(entity);
	Call_Finish();
	return Plugin_Continue;
}

public Action tTimerRegularWaves(Handle timer)
{
	int iRegularWave = !g_bGeneralConfig ? g_iRegularWave : g_iRegularWave2;
	if (bIsFinaleMap() || g_iTankWave > 0)
	{
		return Plugin_Stop;
	}
	else if (iRegularWave == 0 || iGetTankCount() > 0)
	{
		return Plugin_Continue;
	}
	int iRegularAmount = !g_bGeneralConfig ? g_iRegularAmount : g_iRegularAmount2;
	for (int iAmount = 1; iAmount <= iRegularAmount; iAmount++)
	{
		for (int iTank = 1; iTank <= MaxClients; iTank++)
		{
			if (bIsValidClient(iTank))
			{
				vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "tank auto");
				break;
			}
		}
	}
	return Plugin_Continue;
}

public Action tTimerSpawnTanks(Handle timer, any wave)
{
	if (iGetTankCount() >= wave)
	{
		return Plugin_Stop;
	}
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsValidClient(iTank))
		{
			vCheatCommand(iTank, bIsValidGame() ? "z_spawn_old" : "z_spawn", "tank auto");
			break;
		}
	}
	return Plugin_Continue;
}

public Action tTimerTankWave(Handle timer, any wave)
{
	if (iGetTankCount() > 0)
	{
		return Plugin_Stop;
	}
	switch (wave)
	{
		case 1: g_iTankWave = 2;
		case 2: g_iTankWave = 3;
	}
	return Plugin_Continue;
}

public Action tTimerReloadConfigs(Handle timer)
{
	g_iFileTimeNew[0] = GetFileTime(g_sSavePath, FileTime_LastChange);
	if (g_iFileTimeOld[0] != g_iFileTimeNew[0])
	{
		PrintToServer("%s Reloading config file (%s)...", ST_PREFIX, g_sSavePath);
		vLoadConfigs(g_sSavePath, true);
		g_iFileTimeOld[0] = g_iFileTimeNew[0];
	}
	if (StrContains(g_sConfigExecute, "1") != -1 && g_iConfigEnable == 1 && g_cvSTDifficulty != null)
	{
		char sDifficulty[11], sDifficultyConfig[PLATFORM_MAX_PATH];
		g_cvSTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));
		BuildPath(Path_SM, sDifficultyConfig, sizeof(sDifficultyConfig), "data/super_tanks++/difficulty_configs/%s.cfg", sDifficulty);
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
		char sMap[64], sMapConfig[PLATFORM_MAX_PATH];
		GetCurrentMap(sMap, sizeof(sMap));
		BuildPath(Path_SM, sMapConfig, sizeof(sMapConfig), (bIsValidGame() ? "data/super_tanks++/l4d2_map_configs/%s.cfg" : "data/super_tanks++/l4d_map_configs/%s.cfg"), sMap);
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
		char sMode[64], sModeConfig[PLATFORM_MAX_PATH];
		g_cvSTGameMode.GetString(sMode, sizeof(sMode));
		BuildPath(Path_SM, sModeConfig, sizeof(sModeConfig), (bIsValidGame() ? "data/super_tanks++/l4d2_gamemode_configs/%s.cfg" : "data/super_tanks++/l4d_gamemode_configs/%s.cfg"), sMode);
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
		char sDay[9], sDayNumber[2], sDayConfig[PLATFORM_MAX_PATH];
		FormatTime(sDayNumber, sizeof(sDayNumber), "%w", GetTime());
		int iDayNumber = StringToInt(sDayNumber);
		switch (iDayNumber)
		{
			case 1: sDay = "monday";
			case 2: sDay = "tuesday";
			case 3: sDay = "wednesday";
			case 4: sDay = "thursday";
			case 5: sDay = "friday";
			case 6: sDay = "saturday";
			default: sDay = "sunday";
		}
		BuildPath(Path_SM, sDayConfig, sizeof(sDayConfig), "data/super_tanks++/daily_configs/%s.cfg", sDay);
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
		char sCountConfig[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, sCountConfig, sizeof(sCountConfig), "data/super_tanks++/playercount_configs/%d.cfg", iGetPlayerCount());
		g_iFileTimeNew[5] = GetFileTime(sCountConfig, FileTime_LastChange);
		if (g_iFileTimeOld[5] != g_iFileTimeNew[5])
		{
			PrintToServer("%s Reloading config file (%s)...", ST_PREFIX, sCountConfig);
			vLoadConfigs(sCountConfig);
			g_iFileTimeOld[5] = g_iFileTimeNew[5];
		}
	}
}