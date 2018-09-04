// Super Tanks++
#include <super_tanks++>
#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo =
{
	name = ST_NAME,
	author = ST_AUTHOR,
	description = ST_DESCRIPTION,
	version = ST_VERSION,
	url = ST_URL
};

bool g_bBoss[MAXPLAYERS + 1], g_bGeneralConfig, g_bLateLoad, g_bPluginEnabled, g_bRandomized[MAXPLAYERS + 1], g_bSpawned[MAXPLAYERS + 1], g_bTankConfig[ST_MAXTYPES + 1];
char g_sBossHealthStages[ST_MAXTYPES + 1][34], g_sBossHealthStages2[ST_MAXTYPES + 1][34], g_sConfigCreate[6], g_sConfigExecute[6], g_sCustomName[ST_MAXTYPES + 1][MAX_NAME_LENGTH + 1], g_sCustomName2[ST_MAXTYPES + 1][MAX_NAME_LENGTH + 1], g_sDisabledGameModes[513], g_sEnabledGameModes[513],
	g_sParticleEffects[ST_MAXTYPES + 1][8], g_sParticleEffects2[ST_MAXTYPES + 1][8], g_sPropsAttached[ST_MAXTYPES + 1][7], g_sPropsAttached2[ST_MAXTYPES + 1][7], g_sPropsChance[ST_MAXTYPES + 1][12], g_sPropsChance2[ST_MAXTYPES + 1][12], g_sPropsColors[ST_MAXTYPES + 1][80],
	g_sPropsColors2[ST_MAXTYPES + 1][80], g_sRockEffects[ST_MAXTYPES + 1][5], g_sRockEffects2[ST_MAXTYPES + 1][5], g_sSavePath[255], g_sTankColors[ST_MAXTYPES + 1][28], g_sTankColors2[ST_MAXTYPES + 1][28], g_sTankWaves[12], g_sTankWaves2[12], g_sTypeRange[10], g_sTypeRange2[10];
ConVar g_cvSTEnable, g_cvSTDifficulty, g_cvSTGameMode, g_cvSTGameTypes, g_cvSTMaxPlayerZombies;
float g_flClawDamage[ST_MAXTYPES + 1], g_flClawDamage2[ST_MAXTYPES + 1], g_flRandomInterval[ST_MAXTYPES + 1], g_flRandomInterval2[ST_MAXTYPES + 1], g_flRockDamage[ST_MAXTYPES + 1], g_flRockDamage2[ST_MAXTYPES + 1], g_flRunSpeed[ST_MAXTYPES + 1], g_flRunSpeed2[ST_MAXTYPES + 1], g_flThrowInterval[ST_MAXTYPES + 1], g_flThrowInterval2[ST_MAXTYPES + 1];
Handle g_hAbilityForward, g_hBossStageForward, g_hConfigsForward, g_hEventForward, g_hRockBreakForward, g_hRockThrowForward, g_hSpawnForward;
int g_iAnnounceArrival, g_iAnnounceArrival2, g_iAnnounceDeath, g_iAnnounceDeath2, g_iBossStageCount[MAXPLAYERS + 1], g_iBossStages[ST_MAXTYPES + 1], g_iBossStages2[ST_MAXTYPES + 1], g_iBossTypes[MAXPLAYERS + 1][5], g_iBulletImmunity[ST_MAXTYPES + 1], g_iBulletImmunity2[ST_MAXTYPES + 1],
	g_iConfigEnable, g_iDisplayHealth, g_iDisplayHealth2, g_iExplosiveImmunity[ST_MAXTYPES + 1], g_iExplosiveImmunity2[ST_MAXTYPES + 1], g_iExtraHealth[ST_MAXTYPES + 1], g_iExtraHealth2[ST_MAXTYPES + 1], g_iFileTimeOld[7], g_iFileTimeNew[7], g_iFinalesOnly, g_iFinalesOnly2,
	g_iFireImmunity[ST_MAXTYPES + 1], g_iFireImmunity2[ST_MAXTYPES + 1], g_iGameModeTypes, g_iGlowEffect[ST_MAXTYPES + 1], g_iGlowEffect2[ST_MAXTYPES + 1], g_iMeleeImmunity[ST_MAXTYPES + 1], g_iMeleeImmunity2[ST_MAXTYPES + 1], g_iMultiHealth, g_iMultiHealth2,
	g_iParticleEffect[ST_MAXTYPES + 1], g_iParticleEffect2[ST_MAXTYPES + 1], g_iPluginEnabled, g_iPluginEnabled2, g_iRockEffect[ST_MAXTYPES + 1], g_iRockEffect2[ST_MAXTYPES + 1], g_iSpawnMode[ST_MAXTYPES + 1], g_iSpawnMode2[ST_MAXTYPES + 1], g_iTankEnabled[ST_MAXTYPES + 1],
	g_iTankEnabled2[ST_MAXTYPES + 1], g_iTankHealth[MAXPLAYERS + 1], g_iTankType[MAXPLAYERS + 1], g_iTankWave, g_iType;
TopMenu g_tmSTMenu;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "Super Tanks++ only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	CreateNative("ST_MaxType", iNative_MaxType);
	CreateNative("ST_MinType", iNative_MinType);
	CreateNative("ST_PluginEnabled", iNative_PluginEnabled);
	CreateNative("ST_SpawnTank", iNative_SpawnTank);
	CreateNative("ST_TankAllowed", iNative_TankAllowed);
	CreateNative("ST_TankType", iNative_TankType);
	RegPluginLibrary("super_tanks++");
	g_bLateLoad = late;
	return APLRes_Success;
}

public int iNative_MaxType(Handle plugin, int numParams)
{
	char sTypeRange[10], sRange[2][5];
	sTypeRange = !g_bGeneralConfig ? g_sTypeRange : g_sTypeRange2;
	ExplodeString(sTypeRange, "-", sRange, sizeof(sRange), sizeof(sRange[]));
	int iMaxType = sRange[1][0] != '\0' ? StringToInt(sRange[1]) : ST_MAXTYPES;
	iMaxType = iSetCellLimit(iMaxType, 1, ST_MAXTYPES);
	return iMaxType;
}

public int iNative_MinType(Handle plugin, int numParams)
{
	char sTypeRange[10], sRange[2][5];
	sTypeRange = !g_bGeneralConfig ? g_sTypeRange : g_sTypeRange2;
	ExplodeString(sTypeRange, "-", sRange, sizeof(sRange), sizeof(sRange[]));
	int iMinType = sRange[0][0] != '\0' ? StringToInt(sRange[0]) : 1;
	iMinType = iSetCellLimit(iMinType, 1, ST_MAXTYPES);
	return iMinType;
}

public int iNative_PluginEnabled(Handle plugin, int numParams)
{
	int iPluginEnabled = !g_bGeneralConfig ? g_iPluginEnabled : g_iPluginEnabled2;
	if (iPluginEnabled == 1 && g_bPluginEnabled)
	{
		return true;
	}
	return false;
}

public int iNative_SpawnTank(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1), iType = GetNativeCell(2);
	if (bIsValidClient(iTank))
	{
		vTank(iTank, iType);
	}
}

public int iNative_TankAllowed(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTankAllowed(iTank))
	{
		return true;
	}
	return false;
}

public int iNative_TankType(Handle plugin, int numParams)
{
	int iTank = GetNativeCell(1);
	if (bIsTank(iTank))
	{
		return g_iTankType[iTank];
	}
	return 0;
}

public void OnPluginStart()
{
	g_hAbilityForward = CreateGlobalForward("ST_Ability", ET_Ignore, Param_Cell);
	g_hBossStageForward = CreateGlobalForward("ST_BossStage", ET_Ignore, Param_Cell);
	g_hConfigsForward = CreateGlobalForward("ST_Configs", ET_Ignore, Param_String, Param_Cell);
	g_hEventForward = CreateGlobalForward("ST_Event", ET_Ignore, Param_Cell, Param_String);
	g_hRockBreakForward = CreateGlobalForward("ST_RockBreak", ET_Ignore, Param_Cell, Param_Cell);
	g_hRockThrowForward = CreateGlobalForward("ST_RockThrow", ET_Ignore, Param_Cell, Param_Cell);
	g_hSpawnForward = CreateGlobalForward("ST_Spawn", ET_Ignore, Param_Cell);
	CreateDirectory("cfg/sourcemod/super_tanks++/", 511);
	Format(g_sSavePath, sizeof(g_sSavePath), "cfg/sourcemod/super_tanks++/super_tanks++.cfg");
	g_iFileTimeOld[0] = GetFileTime(g_sSavePath, FileTime_LastChange);
	vLoadConfigs(g_sSavePath, true);
	vMultiTargetFilters(1);
	LoadTranslations("common.phrases");
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
	if (g_bLateLoad)
	{
		vLateLoad(true);
		g_bLateLoad = false;
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	for (int iNumber = 0; iNumber <= 4; iNumber++)
	{
		g_iBossTypes[client][iNumber] = 0;
	}
	g_iBossStageCount[client] = 0;
	g_iTankType[client] = 0;
	g_bBoss[client] = false;
	g_bRandomized[client] = false;
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
		CreateTimer(1.0, tTimerReloadConfigs, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(0.1, tTimerTankHealthUpdate, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerTankTypeUpdate, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerUpdatePlayerCount, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
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
		char sGameType[2049], sTypes[64][32];
		g_cvSTGameTypes.GetString(sGameType, sizeof(sGameType));
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
	if (StrContains(g_sConfigExecute, "1") != -1 && g_iConfigEnable == 1 && g_cvSTDifficulty != null)
	{
		char sDifficulty[11], sDifficultyConfig[512];
		g_cvSTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));
		Format(sDifficultyConfig, sizeof(sDifficultyConfig), "cfg/sourcemod/super_tanks++/difficulty_configs/%s.cfg", sDifficulty);
		vLoadConfigs(sDifficultyConfig);
		g_iFileTimeOld[1] = GetFileTime(sDifficultyConfig, FileTime_LastChange);
	}
	if (StrContains(g_sConfigExecute, "2") != -1 && g_iConfigEnable == 1)
	{
		char sMap[64], sMapConfig[512];
		GetCurrentMap(sMap, sizeof(sMap));
		Format(sMapConfig, sizeof(sMapConfig), (bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_map_configs/%s.cfg" : "cfg/sourcemod/super_tanks++/l4d_map_configs/%s.cfg"), sMap);
		vLoadConfigs(sMapConfig);
		g_iFileTimeOld[2] = GetFileTime(sMapConfig, FileTime_LastChange);
	}
	if (StrContains(g_sConfigExecute, "3") != -1 && g_iConfigEnable == 1)
	{
		char sMode[64], sModeConfig[512];
		g_cvSTGameMode.GetString(sMode, sizeof(sMode));
		Format(sModeConfig, sizeof(sModeConfig), (bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_gamemode_configs/%s.cfg" : "cfg/sourcemod/super_tanks++/l4d_gamemode_configs/%s.cfg"), sMode);
		vLoadConfigs(sModeConfig);
		g_iFileTimeOld[3] = GetFileTime(sModeConfig, FileTime_LastChange);
	}
	if (StrContains(g_sConfigExecute, "4") != -1 && g_iConfigEnable == 1)
	{
		char sDay[9], sDayNumber[2], sDayConfig[512];
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
		Format(sDayConfig, sizeof(sDayConfig), "cfg/sourcemod/super_tanks++/daily_configs/%s.cfg", sDay);
		vLoadConfigs(sDayConfig);
		g_iFileTimeOld[4] = GetFileTime(sDayConfig, FileTime_LastChange);
	}
	if (StrContains(g_sConfigExecute, "5") != -1 && g_iConfigEnable == 1)
	{
		char sCountConfig[512];
		Format(sCountConfig, sizeof(sCountConfig), "cfg/sourcemod/super_tanks++/playercount_configs/%d.cfg", iGetPlayerCount());
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
	int iPluginEnabled = !g_bGeneralConfig ? g_iPluginEnabled : g_iPluginEnabled2;
	if (iPluginEnabled == 1 && g_bPluginEnabled && strcmp(classname, "tank_rock") == 0)
	{
		CreateTimer(0.1, tTimerRockThrow, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
	}
}

public void OnEntityDestroyed(int entity)
{
	int iPluginEnabled = !g_bGeneralConfig ? g_iPluginEnabled : g_iPluginEnabled2;
	if (iPluginEnabled == 1 && g_bPluginEnabled && bIsValidEntity(entity))
	{
		char sClassname[32];
		GetEntityClassname(entity, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "tank_rock") == 0)
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
	int iPluginEnabled = !g_bGeneralConfig ? g_iPluginEnabled : g_iPluginEnabled2;
	if (iPluginEnabled == 1 && g_bPluginEnabled && damage > 0.0 && bIsValidClient(victim))
	{
		char sClassname[32];
		GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
		if (bIsTankAllowed(attacker) && bIsSurvivor(victim))
		{
			if (strcmp(sClassname, "weapon_tank_claw") == 0)
			{
				float flClawDamage = !g_bTankConfig[g_iTankType[attacker]] ? g_flClawDamage[g_iTankType[attacker]] : g_flClawDamage2[g_iTankType[attacker]];
				damage = flClawDamage;
				return Plugin_Changed;
			}
			else if (strcmp(sClassname, "tank_rock") == 0)
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
					iFireImmunity = !g_bTankConfig[g_iTankType[victim]] ? g_iFireImmunity[g_iTankType[victim]] : g_iFireImmunity2[g_iTankType[victim]],
					iMeleeImmunity = !g_bTankConfig[g_iTankType[victim]] ? g_iMeleeImmunity[g_iTankType[victim]] : g_iMeleeImmunity2[g_iTankType[victim]];
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
				int iOwner, iThrower;
				if (HasEntProp(inflictor, Prop_Send, "m_hOwnerEntity"))
				{
					iOwner = GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity");
				}
				if (HasEntProp(inflictor, Prop_Data, "m_hThrower"))
				{
					iThrower = GetEntPropEnt(inflictor, Prop_Data, "m_hThrower");
				}
				if ((iOwner > 0 && iOwner == victim) || (iThrower > 0 && iThrower == victim) || bIsTank(iOwner) || strcmp(sClassname, "tank_rock") == 0)
				{
					damage = 0.0;
					return Plugin_Handled;
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

public void vEventHandler(Event event, const char[] name, bool dontBroadcast)
{
	Call_StartForward(g_hEventForward);
	Call_PushCell(event);
	Call_PushString(name);
	Call_Finish();
	if (strcmp(name, "ability_use") == 0)
	{
		int iUserId = event.GetInt("userid"), iTank = GetClientOfUserId(iUserId);
		if (bIsTankAllowed(iTank) && IsPlayerAlive(iTank))
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
	else if (strcmp(name, "finale_escape_start") == 0 || strcmp(name, "finale_vehicle_ready") == 0)
	{
		g_iTankWave = 3;
	}
	else if (strcmp(name, "finale_start") == 0)
	{
		g_iTankWave = 1;
	}
	else if (strcmp(name, "finale_vehicle_leaving") == 0)
	{
		g_iTankWave = 4;
	}
	else if (strcmp(name, "player_death") == 0)
	{
		int iUserId = event.GetInt("userid"), iPlayer = GetClientOfUserId(iUserId);
		if (bIsValidClient(iPlayer))
		{
			if (bIsTankAllowed(iPlayer))
			{
				int iGlowEffect = !g_bTankConfig[g_iTankType[iPlayer]] ? g_iGlowEffect[g_iTankType[iPlayer]] : g_iGlowEffect2[g_iTankType[iPlayer]];
				if (iGlowEffect == 1 && bIsL4D2Game())
				{
					SetEntProp(iPlayer, Prop_Send, "m_iGlowType", 0);
					SetEntProp(iPlayer, Prop_Send, "m_glowColorOverride", 0);
				}
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
				vRemoveProps(iPlayer);
				CreateTimer(3.0, tTimerTankWave, g_iTankWave, TIMER_FLAG_NO_MAPCHANGE);
			}
		}
	}
	else if (strcmp(name, "player_incapacitated") == 0)
	{
		int iUserId = event.GetInt("userid"), iTank = GetClientOfUserId(iUserId);
		if (bIsTankAllowed(iTank) && IsPlayerAlive(iTank))
		{
			CreateTimer(0.5, tTimerKillStuckTank, iUserId, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else if (strcmp(name, "round_start") == 0)
	{
		g_iTankWave = 0;
	}
	else if (strcmp(name, "tank_spawn") == 0)
	{
		int iUserId = event.GetInt("userid"), iTank = GetClientOfUserId(iUserId);
		if (bIsTankAllowed(iTank) && IsPlayerAlive(iTank))
		{
			g_iTankType[iTank] = 0;
			int iFinalesOnly = !g_bGeneralConfig ? g_iFinalesOnly : g_iFinalesOnly2;
			if (iFinalesOnly == 0 || (iFinalesOnly == 1 && (bIsFinaleMap() || g_iTankWave > 0)))
			{
				int iTypeCount, iTankTypes[ST_MAXTYPES + 1];
				char sTypeRange[10], sRange[2][5];
				sTypeRange = !g_bGeneralConfig ? g_sTypeRange : g_sTypeRange2;
				ExplodeString(sTypeRange, "-", sRange, sizeof(sRange), sizeof(sRange[]));
				int iMinType = sRange[0][0] != '\0' ? StringToInt(sRange[0]) : 1;
				iMinType = iSetCellLimit(iMinType, 1, ST_MAXTYPES);
				int iMaxType = sRange[1][0] != '\0' ? StringToInt(sRange[1]) : ST_MAXTYPES;
				iMaxType = iSetCellLimit(iMaxType, 1, ST_MAXTYPES);
				for (int iIndex = iMinType; iIndex <= iMaxType; iIndex++)
				{
					int iTankEnabled = !g_bTankConfig[iIndex] ? g_iTankEnabled[iIndex] : g_iTankEnabled2[iIndex];
					if (iTankEnabled == 0 || g_iTankType[iTank] == iIndex)
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
				char sNumbers[3][4], sTankWaves[12];
				sTankWaves = !g_bGeneralConfig ? g_sTankWaves : g_sTankWaves2;
				TrimString(sTankWaves);
				ExplodeString(sTankWaves, ",", sNumbers, sizeof(sNumbers), sizeof(sNumbers[]));
				TrimString(sNumbers[0]);
				int iWave = (sNumbers[0][0] != '\0') ? StringToInt(sNumbers[0]) : 1;
				iWave = iSetCellLimit(iWave, 1, 999);
				TrimString(sNumbers[1]);
				int iWave2 = (sNumbers[1][0] != '\0') ? StringToInt(sNumbers[1]) : 2;
				iWave2 = iSetCellLimit(iWave2, 1, 999);
				TrimString(sNumbers[2]);
				int iWave3 = (sNumbers[2][0] != '\0') ? StringToInt(sNumbers[2]) : 3;
				iWave3 = iSetCellLimit(iWave3, 1, 999);
				switch (g_iTankWave)
				{
					case 1: vTankCountCheck(iTank, iWave);
					case 2: vTankCountCheck(iTank, iWave2);
					case 3: vTankCountCheck(iTank, iWave3);
				}
				DataPack dpTankSpawn = new DataPack();
				CreateDataTimer(0.1, tTimerTankSpawn, dpTankSpawn, TIMER_FLAG_NO_MAPCHANGE);
				dpTankSpawn.WriteCell(GetClientUserId(iTank));
				dpTankSpawn.WriteCell(0);
			}
		}
	}
}

public Action cmdTank(int client, int args)
{
	int iPluginEnabled = !g_bGeneralConfig ? g_iPluginEnabled : g_iPluginEnabled2;
	if (iPluginEnabled == 0 || !g_bPluginEnabled)
	{
		ReplyToCommand(client, "\x04%s\x05 Super Tanks++\x01 is disabled.", ST_PREFIX);
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
	char sTypeRange[10], sRange[2][5];
	sTypeRange = !g_bGeneralConfig ? g_sTypeRange : g_sTypeRange2;
	ExplodeString(sTypeRange, "-", sRange, sizeof(sRange), sizeof(sRange[]));
	int iMinType = sRange[0][0] != '\0' ? StringToInt(sRange[0]) : 1;
	iMinType = iSetCellLimit(iMinType, 1, ST_MAXTYPES);
	int iMaxType = sRange[1][0] != '\0' ? StringToInt(sRange[1]) : ST_MAXTYPES;
	iMaxType = iSetCellLimit(iMaxType, 1, ST_MAXTYPES);
	if (args < 1)
	{
		IsVoteInProgress() ? ReplyToCommand(client, "\x04%s\x01 %t", ST_PREFIX, "Vote in Progress") : vTankMenu(client, 0);
		return Plugin_Handled;
	}
	else if (iType < iMinType || iType > iMaxType || iMode < 0 || iMode > 1 || args > 2)
	{
		ReplyToCommand(client, "\x04%s\x01 Usage: sm_tank <type %d-%d> <0: spawn at crosshair|1: spawn automatically>", ST_PREFIX, iMinType, iMaxType);
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
	vTank(client, iType, iMode);
	return Plugin_Handled;
}

void vTank(int client, int type, int mode = 0)
{
	g_iType = type;
	char sParameter[32];
	switch (mode)
	{
		case 0: sParameter = "tank";
		case 1: sParameter = "tank auto";
	}
	vCheatCommand(client, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", sParameter);
}

void vTankMenu(int client, int item)
{
	Menu mTankMenu = new Menu(iTankMenuHandler);
	mTankMenu.SetTitle("Super Tanks++ Menu");
	char sTypeRange[10], sRange[2][5];
	sTypeRange = !g_bGeneralConfig ? g_sTypeRange : g_sTypeRange2;
	ExplodeString(sTypeRange, "-", sRange, sizeof(sRange), sizeof(sRange[]));
	int iMinType = sRange[0][0] != '\0' ? StringToInt(sRange[0]) : 1;
	iMinType = iSetCellLimit(iMinType, 1, ST_MAXTYPES);
	int iMaxType = sRange[1][0] != '\0' ? StringToInt(sRange[1]) : ST_MAXTYPES;
	iMaxType = iSetCellLimit(iMaxType, 1, ST_MAXTYPES);
	for (int iIndex = iMinType; iIndex <= iMaxType; iIndex++)
	{
		int iTankEnabled = !g_bTankConfig[iIndex] ? g_iTankEnabled[iIndex] : g_iTankEnabled2[iIndex];
		if (iTankEnabled == 0)
		{
			continue;
		}
		char sName[MAX_NAME_LENGTH + 1], sMenuItem[MAX_NAME_LENGTH + 12];
		sName = !g_bTankConfig[iIndex] ? g_sCustomName[iIndex] : g_sCustomName2[iIndex];
		Format(sMenuItem, sizeof(sMenuItem), "%s (Tank #%d)", sName, iIndex);
		mTankMenu.AddItem(sName, sMenuItem);
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
			char sInfo[MAX_NAME_LENGTH + 1], sTypeRange[10], sRange[2][5];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			sTypeRange = !g_bGeneralConfig ? g_sTypeRange : g_sTypeRange2;
			ExplodeString(sTypeRange, "-", sRange, sizeof(sRange), sizeof(sRange[]));
			int iMinType = sRange[0][0] != '\0' ? StringToInt(sRange[0]) : 1;
			iMinType = iSetCellLimit(iMinType, 1, ST_MAXTYPES);
			int iMaxType = sRange[1][0] != '\0' ? StringToInt(sRange[1]) : ST_MAXTYPES;
			iMaxType = iSetCellLimit(iMaxType, 1, ST_MAXTYPES);
			for (int iIndex = iMinType; iIndex <= iMaxType; iIndex++)
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

public Action cmdTankList(int client, int args)
{
	int iPluginEnabled = !g_bGeneralConfig ? g_iPluginEnabled : g_iPluginEnabled2;
	if (iPluginEnabled == 0 || !g_bPluginEnabled)
	{
		ReplyToCommand(client, "\x04%s\x05 Super Tanks++\x01 is disabled.", ST_PREFIX);
		return Plugin_Handled;
	}
	if (args > 0)
	{
		ReplyToCommand(client, "\x04%s\x01 Usage: sm_tanklist", ST_PREFIX);
		return Plugin_Handled;
	}
	char sTypeRange[10], sRange[2][5];
	sTypeRange = !g_bGeneralConfig ? g_sTypeRange : g_sTypeRange2;
	ExplodeString(sTypeRange, "-", sRange, sizeof(sRange), sizeof(sRange[]));
	int iMinType = sRange[0][0] != '\0' ? StringToInt(sRange[0]) : 1;
	iMinType = iSetCellLimit(iMinType, 1, ST_MAXTYPES);
	int iMaxType = sRange[1][0] != '\0' ? StringToInt(sRange[1]) : ST_MAXTYPES;
	iMaxType = iSetCellLimit(iMaxType, 1, ST_MAXTYPES);
	for (int iIndex = iMinType; iIndex <= iMaxType; iIndex++)
	{
		int iTankEnabled = !g_bTankConfig[iIndex] ? g_iTankEnabled[iIndex] : g_iTankEnabled2[iIndex];
		char sName[MAX_NAME_LENGTH + 1], sStatus[32], sMode[32];
		sName = !g_bTankConfig[iIndex] ? g_sCustomName[iIndex] : g_sCustomName2[iIndex];
		switch (iTankEnabled)
		{
			case 0: sStatus = "Disabled";
			case 1: sStatus = "Enabled";
		}
		int iSpawnMode = !g_bTankConfig[iIndex] ? g_iSpawnMode[iIndex] : g_iSpawnMode2[iIndex];
		switch (iSpawnMode)
		{
			case 0: sMode = "Normal";
			case 1: sMode = "Boss";
			case 2: sMode = "Randomized";
		}
		PrintToConsole(client, "%d. Name: %s, Status: %s, Mode: %s", iIndex, sName, sStatus, sMode);
	}
	if (GetCmdReplySource() == SM_REPLY_TO_CHAT)
	{
		PrintToChat(client, "\x04%s\x01 See console for output.", ST_PREFIX);
	}
	return Plugin_Handled;
}

void vPluginStatus()
{
	bool bIsPluginAllowed = bIsPluginEnabled(g_cvSTGameMode, g_iGameModeTypes, g_sEnabledGameModes, g_sDisabledGameModes);
	int iPluginEnabled = !g_bGeneralConfig ? g_iPluginEnabled : g_iPluginEnabled2;
	if (iPluginEnabled == 1)
	{
		if (g_cvSTEnable.BoolValue && bIsPluginAllowed)
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
		HookEvent("tank_spawn", vEventHandler);
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
		UnhookEvent("tank_spawn", vEventHandler);
		bHooked = false;
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
			g_iGameModeTypes = kvSuperTanks.GetNum("General/Game Mode Types", 0);
			g_iGameModeTypes = iSetCellLimit(g_iGameModeTypes, 0, 15);
			kvSuperTanks.GetString("General/Enabled Game Modes", g_sEnabledGameModes, sizeof(g_sEnabledGameModes), "");
			kvSuperTanks.GetString("General/Disabled Game Modes", g_sDisabledGameModes, sizeof(g_sDisabledGameModes), "");
			g_iConfigEnable = kvSuperTanks.GetNum("Custom/Enable Custom Configs", 0);
			g_iConfigEnable = iSetCellLimit(g_iConfigEnable, 0, 1);
			kvSuperTanks.GetString("Custom/Create Config Types", g_sConfigCreate, sizeof(g_sConfigCreate), "12345");
			kvSuperTanks.GetString("Custom/Execute Config Types", g_sConfigExecute, sizeof(g_sConfigExecute), "1");
		}
		main ? (g_iAnnounceArrival = kvSuperTanks.GetNum("General/Announce Arrival", 1)) : (g_iAnnounceArrival2 = kvSuperTanks.GetNum("General/Announce Arrival", g_iAnnounceArrival));
		main ? (g_iAnnounceArrival = iSetCellLimit(g_iAnnounceArrival, 0, 1)) : (g_iAnnounceArrival2 = iSetCellLimit(g_iAnnounceArrival2, 0, 1));
		main ? (g_iAnnounceDeath = kvSuperTanks.GetNum("General/Announce Death", 1)) : (g_iAnnounceDeath2 = kvSuperTanks.GetNum("General/Announce Death", g_iAnnounceDeath));
		main ? (g_iAnnounceDeath = iSetCellLimit(g_iAnnounceDeath, 0, 1)) : (g_iAnnounceDeath2 = iSetCellLimit(g_iAnnounceDeath2, 0, 1));
		main ? (g_iDisplayHealth = kvSuperTanks.GetNum("General/Display Health", 3)) : (g_iDisplayHealth2 = kvSuperTanks.GetNum("General/Display Health", g_iDisplayHealth));
		main ? (g_iDisplayHealth = iSetCellLimit(g_iDisplayHealth, 0, 3)) : (g_iDisplayHealth2 = iSetCellLimit(g_iDisplayHealth2, 0, 3));
		main ? (g_iFinalesOnly = kvSuperTanks.GetNum("General/Finales Only", 0)) : (g_iFinalesOnly2 = kvSuperTanks.GetNum("General/Finales Only", g_iFinalesOnly));
		main ? (g_iFinalesOnly = iSetCellLimit(g_iFinalesOnly, 0, 1)) : (g_iFinalesOnly2 = iSetCellLimit(g_iFinalesOnly2, 0, 1));
		main ? (g_iMultiHealth = kvSuperTanks.GetNum("General/Multiply Health", 0)) : (g_iMultiHealth2 = kvSuperTanks.GetNum("General/Multiply Health", g_iMultiHealth));
		main ? (g_iMultiHealth = iSetCellLimit(g_iMultiHealth, 0, 3)) : (g_iMultiHealth2 = iSetCellLimit(g_iMultiHealth2, 0, 3));
		main ? (kvSuperTanks.GetString("General/Tank Waves", g_sTankWaves, sizeof(g_sTankWaves), "2,3,4")) : (kvSuperTanks.GetString("General/Tank Waves", g_sTankWaves2, sizeof(g_sTankWaves2), g_sTankWaves));
		main ? (kvSuperTanks.GetString("General/Type Range", g_sTypeRange, sizeof(g_sTypeRange), "1-5000")) : (kvSuperTanks.GetString("General/Type Range", g_sTypeRange2, sizeof(g_sTypeRange2), g_sTypeRange));
		kvSuperTanks.Rewind();
	}
	char sTypeRange[10], sRange[2][5];
	sTypeRange = main ? g_sTypeRange : g_sTypeRange2;
	ExplodeString(sTypeRange, "-", sRange, sizeof(sRange), sizeof(sRange[]));
	int iMinType = sRange[0][0] != '\0' ? StringToInt(sRange[0]) : 1;
	iMinType = iSetCellLimit(iMinType, 1, ST_MAXTYPES);
	int iMaxType = sRange[1][0] != '\0' ? StringToInt(sRange[1]) : ST_MAXTYPES;
	iMaxType = iSetCellLimit(iMaxType, 1, ST_MAXTYPES);
	for (int iIndex = iMinType; iIndex <= iMaxType; iIndex++)
	{
		char sName[MAX_NAME_LENGTH + 1];
		Format(sName, sizeof(sName), "Tank %d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			main ? (g_bTankConfig[iIndex] = false) : (g_bTankConfig[iIndex] = true);
			main ? (kvSuperTanks.GetString("General/Tank Name", g_sCustomName[iIndex], sizeof(g_sCustomName[]), sName)) : (kvSuperTanks.GetString("General/Tank Name", g_sCustomName2[iIndex], sizeof(g_sCustomName2[]), g_sCustomName[iIndex]));
			main ? (g_iTankEnabled[iIndex] = kvSuperTanks.GetNum("General/Tank Enabled", 0)) : (g_iTankEnabled2[iIndex] = kvSuperTanks.GetNum("General/Tank Enabled", g_iTankEnabled[iIndex]));
			main ? (g_iTankEnabled[iIndex] = iSetCellLimit(g_iTankEnabled[iIndex], 0, 1)) : (g_iTankEnabled2[iIndex] = iSetCellLimit(g_iTankEnabled2[iIndex], 0, 1));
			main ? (kvSuperTanks.GetString("General/Boss Health Stages", g_sBossHealthStages[iIndex], sizeof(g_sBossHealthStages[]), "5000,2500,1500,1000,500")) : (kvSuperTanks.GetString("General/Boss Health Stages", g_sBossHealthStages2[iIndex], sizeof(g_sBossHealthStages2[]), g_sBossHealthStages[iIndex]));
			main ? (g_iBossStages[iIndex] = kvSuperTanks.GetNum("General/Boss Stages", 3)) : (g_iBossStages2[iIndex] = kvSuperTanks.GetNum("General/Boss Stages", g_iBossStages[iIndex]));
			main ? (g_iBossStages[iIndex] = iSetCellLimit(g_iBossStages[iIndex], 1, 5)) : (g_iBossStages2[iIndex] = iSetCellLimit(g_iBossStages2[iIndex], 1, 5));
			main ? (g_flRandomInterval[iIndex] = kvSuperTanks.GetFloat("General/Random Interval", 5.0)) : (g_flRandomInterval2[iIndex] = kvSuperTanks.GetFloat("General/Random Interval", g_flRandomInterval[iIndex]));
			main ? (g_flRandomInterval[iIndex] = flSetFloatLimit(g_flRandomInterval[iIndex], 0.1, 9999999999.0)) : (g_flRandomInterval2[iIndex] = flSetFloatLimit(g_flRandomInterval2[iIndex], 0.1, 9999999999.0));
			main ? (g_iSpawnMode[iIndex] = kvSuperTanks.GetNum("General/Spawn Mode", 0)) : (g_iSpawnMode2[iIndex] = kvSuperTanks.GetNum("General/Spawn Mode", g_iSpawnMode[iIndex]));
			main ? (g_iSpawnMode[iIndex] = iSetCellLimit(g_iSpawnMode[iIndex], 0, 2)) : (g_iSpawnMode2[iIndex] = iSetCellLimit(g_iSpawnMode2[iIndex], 0, 2));
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
			main ? (g_flClawDamage[iIndex] = kvSuperTanks.GetFloat("Enhancements/Claw Damage", 5.0)) : (g_flClawDamage2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Claw Damage", g_flClawDamage[iIndex]));
			main ? (g_flClawDamage[iIndex] = flSetFloatLimit(g_flClawDamage[iIndex], 0.0, 9999999999.0)) : (g_flClawDamage2[iIndex] = flSetFloatLimit(g_flClawDamage2[iIndex], 0.0, 9999999999.0));
			main ? (g_iExtraHealth[iIndex] = kvSuperTanks.GetNum("Enhancements/Extra Health", 0)) : (g_iExtraHealth2[iIndex] = kvSuperTanks.GetNum("Enhancements/Extra Health", g_iExtraHealth[iIndex]));
			main ? (g_iExtraHealth[iIndex] = iSetCellLimit(g_iExtraHealth[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH)) : (g_iExtraHealth2[iIndex] = iSetCellLimit(g_iExtraHealth2[iIndex], ST_MAX_HEALTH_REDUCTION, ST_MAXHEALTH));
			main ? (g_flRockDamage[iIndex] = kvSuperTanks.GetFloat("Enhancements/Rock Damage", 5.0)) : (g_flRockDamage2[iIndex] = kvSuperTanks.GetFloat("Enhancements/Rock Damage", g_flRockDamage[iIndex]));
			main ? (g_flRockDamage[iIndex] = flSetFloatLimit(g_flRockDamage[iIndex], 0.0, 9999999999.0)) : (g_flRockDamage2[iIndex] = flSetFloatLimit(g_flRockDamage2[iIndex], 0.0, 9999999999.0));
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
	Call_StartForward(g_hConfigsForward);
	Call_PushString(savepath);
	Call_PushCell(main);
	Call_Finish();
}

void vLateLoad(bool late)
{
	if (late)
	{
		vLoadConfigs(g_sSavePath, true);
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
		{
			if (bIsValidClient(iPlayer))
			{
				SDKHook(iPlayer, SDKHook_OnTakeDamage, OnTakeDamage);
			}
		}
	}
}

void vBoss(int client, int limit, int stages, int stage)
{
	int iHealth = GetClientHealth(client);
	if (iHealth <= limit && stages >= stage)
	{
		g_iBossTypes[client][stage - 1] = g_iTankType[client];
		g_iBossStageCount[client] = stage;
		vNewTankSettings(client);
		int iTypeCount, iTankTypes[ST_MAXTYPES + 1];
		char sTypeRange[10], sRange[2][5];
		sTypeRange = !g_bGeneralConfig ? g_sTypeRange : g_sTypeRange2;
		ExplodeString(sTypeRange, "-", sRange, sizeof(sRange), sizeof(sRange[]));
		int iMinType = sRange[0][0] != '\0' ? StringToInt(sRange[0]) : 1;
		iMinType = iSetCellLimit(iMinType, 1, ST_MAXTYPES);
		int iMaxType = sRange[1][0] != '\0' ? StringToInt(sRange[1]) : ST_MAXTYPES;
		iMaxType = iSetCellLimit(iMaxType, 1, ST_MAXTYPES);
		for (int iIndex = iMinType; iIndex <= iMaxType; iIndex++)
		{
			int iTankEnabled = !g_bTankConfig[iIndex] ? g_iTankEnabled[iIndex] : g_iTankEnabled2[iIndex];
			if (iTankEnabled == 0 || g_iTankType[client] == iIndex || g_iBossTypes[client][0] == iIndex || g_iBossTypes[client][1] == iIndex || g_iBossTypes[client][2] == iIndex || g_iBossTypes[client][3] == iIndex || g_iBossTypes[client][4] == iIndex)
			{
				continue;
			}
			iTankTypes[iTypeCount + 1] = iIndex;
			iTypeCount++;
		}
		if (iTypeCount > 0)
		{
			int iChosen = iTankTypes[GetRandomInt(1, iTypeCount)];
			vSetColor(client, iChosen);
		}
		DataPack dpTankSpawn = new DataPack();
		CreateDataTimer(0.1, tTimerTankSpawn, dpTankSpawn, TIMER_FLAG_NO_MAPCHANGE);
		dpTankSpawn.WriteCell(GetClientUserId(client));
		dpTankSpawn.WriteCell(1);
		int iNewHealth = g_iTankHealth[client] + limit, iFinalHealth = (iNewHealth > ST_MAXHEALTH) ? ST_MAXHEALTH : iNewHealth;
		SetEntityHealth(client, iFinalHealth);
	}
}

void vNewTankSettings(int client)
{
	ExtinguishEntity(client);
	vAttachParticle(client, PARTICLE_ELECTRICITY, 2.0, 30.0);
	EmitSoundToAll(SOUND_BOSS, client);
	Call_StartForward(g_hBossStageForward);
	Call_PushCell(client);
	Call_Finish();
	vRemoveProps(client);
}

void vParticleEffects(int client)
{
	int iParticleEffect = !g_bTankConfig[g_iTankType[client]] ? g_iParticleEffect[g_iTankType[client]] : g_iParticleEffect2[g_iTankType[client]];
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[client]] ? g_sParticleEffects[g_iTankType[client]] : g_sParticleEffects2[g_iTankType[client]];
	if (iParticleEffect == 1 && bIsTankAllowed(client) && IsPlayerAlive(client))
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
		if (StrContains(sParticleEffects, "7") != -1 && bIsL4D2Game())
		{
			CreateTimer(2.0, tTimerSpitEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}

void vRemoveProps(int client)
{
	int iProp = -1;
	while ((iProp = FindEntityByClassname(iProp, "prop_dynamic")) != INVALID_ENT_REFERENCE)
	{
		char sModel[128];
		GetEntPropString(iProp, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
		if (strcmp(sModel, MODEL_JETPACK, false) == 0 || strcmp(sModel, MODEL_CONCRETE, false) == 0 || strcmp(sModel, MODEL_TIRES, false) == 0 || strcmp(sModel, MODEL_TANK, false) == 0)
		{
			int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
			if (iOwner == client)
			{
				SDKUnhook(iProp, SDKHook_SetTransmit, SetTransmit);
				AcceptEntityInput(iProp, "Kill");
			}
		}
	}
	while ((iProp = FindEntityByClassname(iProp, "beam_spotlight")) != INVALID_ENT_REFERENCE)
	{
		int iOwner = GetEntPropEnt(iProp, Prop_Send, "m_hOwnerEntity");
		if (iOwner == client)
		{
			SDKUnhook(iProp, SDKHook_SetTransmit, SetTransmit);
			AcceptEntityInput(iProp, "Kill");
		}
	}
}

void vReset()
{
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (bIsValidClient(iPlayer))
		{
			for (int iNumber = 0; iNumber <= 4; iNumber++)
			{
				g_iBossTypes[iPlayer][iNumber] = 0;
			}
			g_iBossStageCount[iPlayer] = 0;
			g_iTankType[iPlayer] = 0;
			g_bBoss[iPlayer] = false;
			g_bRandomized[iPlayer] = false;
		}
	}
}

void vSetColor(int client, int value)
{
	char sSet[2][16], sTankColors[28], sRGB[4][4], sGlow[3][4];
	sTankColors = !g_bTankConfig[value] ? g_sTankColors[value] : g_sTankColors2[value];
	TrimString(sTankColors);
	ExplodeString(sTankColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
	ExplodeString(sSet[0], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
	TrimString(sRGB[0]);
	int iRed = (sRGB[0][0] != '\0') ? StringToInt(sRGB[0]) : 255;
	iRed = iSetCellLimit(iRed, 0, 255);
	TrimString(sRGB[1]);
	int iGreen = (sRGB[1][0] != '\0') ? StringToInt(sRGB[1]) : 255;
	iGreen = iSetCellLimit(iGreen, 0, 255);
	TrimString(sRGB[2]);
	int iBlue = (sRGB[2][0] != '\0') ? StringToInt(sRGB[2]) : 255;
	iBlue = iSetCellLimit(iBlue, 0, 255);
	TrimString(sRGB[3]);
	int iAlpha = (sRGB[3][0] != '\0') ? StringToInt(sRGB[3]) : 255;
	iAlpha = iSetCellLimit(iAlpha, 0, 255);
	ExplodeString(sSet[1], ",", sGlow, sizeof(sGlow), sizeof(sGlow[]));
	TrimString(sGlow[0]);
	int iRed2 = (sGlow[0][0] != '\0') ? StringToInt(sGlow[0]) : 255;
	iRed2 = iSetCellLimit(iRed2, 0, 255);
	TrimString(sGlow[1]);
	int iGreen2 = (sGlow[1][0] != '\0') ? StringToInt(sGlow[1]) : 255;
	iGreen2 = iSetCellLimit(iGreen2, 0, 255);
	TrimString(sGlow[2]);
	int iBlue2 = (sGlow[2][0] != '\0') ? StringToInt(sGlow[2]) : 255;
	iBlue2 = iSetCellLimit(iBlue2, 0, 255);
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

void vSetName(int client, char[] oldname = "Tank", char[] name = "Tank", int mode)
{
	char sSet[5][16], sPropsColors[80], sRGB[4][4], sRGB2[4][4], sRGB3[4][4], sRGB4[4][4], sRGB5[4][4];
	sPropsColors = !g_bTankConfig[g_iTankType[client]] ? g_sPropsColors[g_iTankType[client]] : g_sPropsColors2[g_iTankType[client]];
	TrimString(sPropsColors);
	ExplodeString(sPropsColors, "|", sSet, sizeof(sSet), sizeof(sSet[]));
	ExplodeString(sSet[0], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
	TrimString(sRGB[0]);
	int iRed = (sRGB[0][0] != '\0') ? StringToInt(sRGB[0]) : 255;
	iRed = iSetCellLimit(iRed, 0, 255);
	TrimString(sRGB[1]);
	int iGreen = (sRGB[1][0] != '\0') ? StringToInt(sRGB[1]) : 255;
	iGreen = iSetCellLimit(iGreen, 0, 255);
	TrimString(sRGB[2]);
	int iBlue = (sRGB[2][0] != '\0') ? StringToInt(sRGB[2]) : 255;
	iBlue = iSetCellLimit(iBlue, 0, 255);
	TrimString(sRGB[3]);
	int iAlpha = (sRGB[3][0] != '\0') ? StringToInt(sRGB[3]) : 255;
	iAlpha = iSetCellLimit(iAlpha, 0, 255);
	ExplodeString(sSet[1], ",", sRGB2, sizeof(sRGB2), sizeof(sRGB2[]));
	TrimString(sRGB2[0]);
	int iRed2 = (sRGB2[0][0] != '\0') ? StringToInt(sRGB2[0]) : 255;
	iRed2 = iSetCellLimit(iRed2, 0, 255);
	TrimString(sRGB2[1]);
	int iGreen2 = (sRGB2[1][0] != '\0') ? StringToInt(sRGB2[1]) : 255;
	iGreen2 = iSetCellLimit(iGreen2, 0, 255);
	TrimString(sRGB2[2]);
	int iBlue2 = (sRGB2[2][0] != '\0') ? StringToInt(sRGB2[2]) : 255;
	iBlue2 = iSetCellLimit(iBlue2, 0, 255);
	TrimString(sRGB2[3]);
	int iAlpha2 = (sRGB2[3][0] != '\0') ? StringToInt(sRGB2[3]) : 255;
	iAlpha2 = iSetCellLimit(iAlpha2, 0, 255);
	ExplodeString(sSet[2], ",", sRGB3, sizeof(sRGB3), sizeof(sRGB3[]));
	TrimString(sRGB3[0]);
	int iRed3 = (sRGB3[0][0] != '\0') ? StringToInt(sRGB3[0]) : 255;
	iRed3 = iSetCellLimit(iRed3, 0, 255);
	TrimString(sRGB3[1]);
	int iGreen3 = (sRGB3[1][0] != '\0') ? StringToInt(sRGB3[1]) : 255;
	iGreen3 = iSetCellLimit(iGreen3, 0, 255);
	TrimString(sRGB3[2]);
	int iBlue3 = (sRGB3[2][0] != '\0') ? StringToInt(sRGB3[2]) : 255;
	iBlue3 = iSetCellLimit(iBlue3, 0, 255);
	TrimString(sRGB3[3]);
	int iAlpha3 = (sRGB3[3][0] != '\0') ? StringToInt(sRGB3[3]) : 255;
	iAlpha3 = iSetCellLimit(iAlpha3, 0, 255);
	ExplodeString(sSet[3], ",", sRGB4, sizeof(sRGB4), sizeof(sRGB4[]));
	TrimString(sRGB4[0]);
	int iRed4 = (sRGB4[0][0] != '\0') ? StringToInt(sRGB4[0]) : 255;
	iRed4 = iSetCellLimit(iRed4, 0, 255);
	TrimString(sRGB4[1]);
	int iGreen4 = (sRGB4[1][0] != '\0') ? StringToInt(sRGB4[1]) : 255;
	iGreen4 = iSetCellLimit(iGreen4, 0, 255);
	TrimString(sRGB4[2]);
	int iBlue4 = (sRGB4[2][0] != '\0') ? StringToInt(sRGB4[2]) : 255;
	iBlue4 = iSetCellLimit(iBlue4, 0, 255);
	TrimString(sRGB4[3]);
	int iAlpha4 = (sRGB4[3][0] != '\0') ? StringToInt(sRGB4[3]) : 255;
	iAlpha4 = iSetCellLimit(iAlpha4, 0, 255);
	ExplodeString(sSet[4], ",", sRGB5, sizeof(sRGB5), sizeof(sRGB5[]));
	TrimString(sRGB5[0]);
	int iRed5 = (sRGB5[0][0] != '\0') ? StringToInt(sRGB5[0]) : 255;
	iRed5 = iSetCellLimit(iRed5, 0, 255);
	TrimString(sRGB5[1]);
	int iGreen5 = (sRGB5[1][0] != '\0') ? StringToInt(sRGB5[1]) : 255;
	iGreen5 = iSetCellLimit(iGreen5, 0, 255);
	TrimString(sRGB5[2]);
	int iBlue5 = (sRGB5[2][0] != '\0') ? StringToInt(sRGB5[2]) : 255;
	iBlue5 = iSetCellLimit(iBlue5, 0, 255);
	TrimString(sRGB5[3]);
	int iAlpha5 = (sRGB5[3][0] != '\0') ? StringToInt(sRGB5[3]) : 255;
	iAlpha5 = iSetCellLimit(iAlpha5, 0, 255);
	if (bIsTankAllowed(client) && IsPlayerAlive(client))
	{
		char sSet2[6][4], sPropsChance[12], sPropsAttached[7];
		sPropsChance = !g_bTankConfig[g_iTankType[client]] ? g_sPropsChance[g_iTankType[client]] : g_sPropsChance2[g_iTankType[client]];
		TrimString(sPropsChance);
		ExplodeString(sPropsChance, ",", sSet2, sizeof(sSet2), sizeof(sSet2[]));
		TrimString(sSet2[0]);
		int iChance = (sSet2[0][0] != '\0') ? StringToInt(sSet2[0]) : 3;
		iChance = iSetCellLimit(iChance, 1, 999);
		TrimString(sSet2[1]);
		int iChance2 = (sSet2[1][0] != '\0') ? StringToInt(sSet2[1]) : 3;
		iChance2 = iSetCellLimit(iChance2, 1, 999);
		TrimString(sSet2[2]);
		int iChance3 = (sSet2[2][0] != '\0') ? StringToInt(sSet2[2]) : 3;
		iChance3 = iSetCellLimit(iChance3, 1, 999);
		TrimString(sSet2[3]);
		int iChance4 = (sSet2[3][0] != '\0') ? StringToInt(sSet2[3]) : 3;
		iChance4 = iSetCellLimit(iChance4, 1, 999);
		TrimString(sSet2[4]);
		int iChance5 = (sSet2[4][0] != '\0') ? StringToInt(sSet2[4]) : 3;
		iChance5 = iSetCellLimit(iChance5, 1, 999);
		TrimString(sSet2[5]);
		int iChance6 = (sSet2[5][0] != '\0') ? StringToInt(sSet2[5]) : 3;
		iChance6 = iSetCellLimit(iChance6, 1, 999);
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
					SDKHook(iBeam[iLight], SDKHook_SetTransmit, SetTransmit);
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
							SDKHook(iFlame, SDKHook_SetTransmit, SetTransmit);
						}
					}
					SDKHook(iJetpack[iOzTank], SDKHook_SetTransmit, SetTransmit);
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
		if (IsFakeClient(client))
		{
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
					case 1: PrintToChatAll("\x04%s\x05 %s\x03 evolved into\x05 %s\x04 (Stage %d)\x03!", ST_PREFIX, oldname, name, g_iBossStageCount[client]);
					case 2: PrintToChatAll("\x04%s\x05 %s\x03 transformed into\x05 %s\x03!", ST_PREFIX, oldname, name);
				}
			}
		}
	}
}

void vTankCountCheck(int client, int wave)
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

void vThrowInterval(int client, float time)
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

int iGetTankCount()
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

bool bIsTankAllowed(int client)
{
	return bIsTank(client) && IsFakeClient(client);
}

public void vSTEnableCvar(ConVar convar, const char[] oldValue, const char[] newValue)
{
	vPluginStatus();
}

public void vSTGameDifficultyCvar(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (StrContains(g_sConfigExecute, "1") != -1)
	{
		char sDifficulty[11], sDifficultyConfig[512];
		g_cvSTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));
		Format(sDifficultyConfig, sizeof(sDifficultyConfig), "cfg/sourcemod/super_tanks++/difficulty_configs/%s.cfg", sDifficulty);
		vLoadConfigs(sDifficultyConfig);
	}
}

public Action tTimerBoss(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank) || !g_bBoss[iTank])
	{
		g_bBoss[iTank] = false;
		return Plugin_Stop;
	}
	int iBossHealth = pack.ReadCell(), iBossHealth2 = pack.ReadCell(),
		iBossHealth3 = pack.ReadCell(), iBossHealth4 = pack.ReadCell(),
		iBossHealth5 = pack.ReadCell(), iBossStages = pack.ReadCell();
	switch (g_iBossStageCount[iTank])
	{
		case 0: vBoss(iTank, iBossHealth, iBossStages, 1);
		case 1: vBoss(iTank, iBossHealth2, iBossStages, 2);
		case 2: vBoss(iTank, iBossHealth3, iBossStages, 3);
		case 3: vBoss(iTank, iBossHealth4, iBossStages, 4);
		case 4: vBoss(iTank, iBossHealth5, iBossStages, 5);
	}
	return Plugin_Continue;
}

public Action tTimerBloodEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iParticleEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_iParticleEffect[g_iTankType[iTank]] : g_iParticleEffect2[g_iTankType[iTank]];
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (iParticleEffect == 0 || StrContains(sParticleEffects, "1") == -1)
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
	int iRed = (sRGB[0][0] != '\0') ? StringToInt(sRGB[0]) : 255;
	iRed = iSetCellLimit(iRed, 0, 255);
	TrimString(sRGB[1]);
	int iGreen = (sRGB[1][0] != '\0') ? StringToInt(sRGB[1]) : 255;
	iGreen = iSetCellLimit(iGreen, 0, 255);
	TrimString(sRGB[2]);
	int iBlue = (sRGB[2][0] != '\0') ? StringToInt(sRGB[2]) : 255;
	iBlue = iSetCellLimit(iBlue, 0, 255);
	TrimString(sRGB[3]);
	int iAlpha = (sRGB[3][0] != '\0') ? StringToInt(sRGB[3]) : 255;
	iAlpha = iSetCellLimit(iAlpha, 0, 255);
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

public Action tTimerElectricEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iParticleEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_iParticleEffect[g_iTankType[iTank]] : g_iParticleEffect2[g_iTankType[iTank]];
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (iParticleEffect == 0 || StrContains(sParticleEffects, "2") == -1)
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
	int iParticleEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_iParticleEffect[g_iTankType[iTank]] : g_iParticleEffect2[g_iTankType[iTank]];
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (iParticleEffect == 0 || StrContains(sParticleEffects, "3") == -1)
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
	int iParticleEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_iParticleEffect[g_iTankType[iTank]] : g_iParticleEffect2[g_iTankType[iTank]];
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (iParticleEffect == 0 || StrContains(sParticleEffects, "4") == -1)
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
	int iParticleEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_iParticleEffect[g_iTankType[iTank]] : g_iParticleEffect2[g_iTankType[iTank]];
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (iParticleEffect == 0 || StrContains(sParticleEffects, "5") == -1)
	{
		return Plugin_Stop;
	}
	vAttachParticle(iTank, PARTICLE_METEOR, 6.0, 30.0);
	return Plugin_Continue;
}

public Action tTimerRandomize(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank) || !g_bRandomized[iTank])
	{
		g_bRandomized[iTank] = false;
		return Plugin_Stop;
	}
	vNewTankSettings(iTank);
	int iTypeCount, iTankTypes[ST_MAXTYPES + 1];
	char sTypeRange[10], sRange[2][5];
	sTypeRange = !g_bGeneralConfig ? g_sTypeRange : g_sTypeRange2;
	ExplodeString(sTypeRange, "-", sRange, sizeof(sRange), sizeof(sRange[]));
	int iMinType = sRange[0][0] != '\0' ? StringToInt(sRange[0]) : 1;
	iMinType = iSetCellLimit(iMinType, 1, ST_MAXTYPES);
	int iMaxType = sRange[1][0] != '\0' ? StringToInt(sRange[1]) : ST_MAXTYPES;
	iMaxType = iSetCellLimit(iMaxType, 1, ST_MAXTYPES);
	for (int iIndex = iMinType; iIndex <= iMaxType; iIndex++)
	{
		int iTankEnabled = !g_bTankConfig[iIndex] ? g_iTankEnabled[iIndex] : g_iTankEnabled2[iIndex];
		if (iTankEnabled == 0 || g_iTankType[iTank] == iIndex)
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
	dpTankSpawn.WriteCell(GetClientUserId(iTank));
	dpTankSpawn.WriteCell(2);
	return Plugin_Continue;
}

public Action tTimerSmokeEffect(Handle timer, any userid)
{
	int iTank = GetClientOfUserId(userid);
	if (!bIsTankAllowed(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	int iParticleEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_iParticleEffect[g_iTankType[iTank]] : g_iParticleEffect2[g_iTankType[iTank]];
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (iParticleEffect == 0 || StrContains(sParticleEffects, "6") == -1)
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
	int iParticleEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_iParticleEffect[g_iTankType[iTank]] : g_iParticleEffect2[g_iTankType[iTank]];
	char sParticleEffects[8];
	sParticleEffects = !g_bTankConfig[g_iTankType[iTank]] ? g_sParticleEffects[g_iTankType[iTank]] : g_sParticleEffects2[g_iTankType[iTank]];
	if (iParticleEffect == 0 || StrContains(sParticleEffects, "7") == -1)
	{
		return Plugin_Stop;
	}
	vAttachParticle(iTank, PARTICLE_SPIT, 2.0, 30.0);
	return Plugin_Continue;
}

public Action tTimerSetTransmit(Handle timer, any entity)
{
	if ((entity = EntRefToEntIndex(entity)) == INVALID_ENT_REFERENCE || !bIsValidEntity(entity))
	{
		return Plugin_Stop;
	}
	SDKHook(entity, SDKHook_SetTransmit, SetTransmit);
	return Plugin_Continue;
}

public Action tTimerUpdatePlayerCount(Handle timer)
{
	int iPluginEnabled = !g_bGeneralConfig ? g_iPluginEnabled : g_iPluginEnabled2;
	if (iPluginEnabled == 0 || !g_bPluginEnabled || StrContains(g_sConfigExecute, "5") == -1)
	{
		return Plugin_Continue;
	}
	char sCountConfig[512];
	Format(sCountConfig, sizeof(sCountConfig), "cfg/sourcemod/super_tanks++/playercount_configs/%d.cfg", iGetPlayerCount());
	vLoadConfigs(sCountConfig);
	return Plugin_Continue;
}

public Action tTimerTankHealthUpdate(Handle timer)
{
	int iPluginEnabled = !g_bGeneralConfig ? g_iPluginEnabled : g_iPluginEnabled2;
	if (iPluginEnabled == 0 || !g_bPluginEnabled)
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
						if (bIsTankAllowed(iTarget) && IsPlayerAlive(iTarget))
						{
							int iHealth = GetClientHealth(iTarget), iDisplay = !g_bGeneralConfig ? g_iDisplayHealth : g_iDisplayHealth2;
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
	int iPluginEnabled = !g_bGeneralConfig ? g_iPluginEnabled : g_iPluginEnabled2;
	if (iPluginEnabled == 0 || !g_bPluginEnabled)
	{
		return Plugin_Continue;
	}
	g_cvSTMaxPlayerZombies.SetString("32");
	for (int iTank = 1; iTank <= MaxClients; iTank++)
	{
		if (bIsTankAllowed(iTank) && IsPlayerAlive(iTank) && g_iTankType[iTank] > 0)
		{
			int iSpawnMode = !g_bTankConfig[g_iTankType[iTank]] ? g_iSpawnMode[g_iTankType[iTank]] : g_iSpawnMode2[g_iTankType[iTank]];
			switch (iSpawnMode)
			{
				case 1:
				{
					if (!g_bBoss[iTank])
					{
						g_bBoss[iTank] = true;
						g_bRandomized[iTank] = true;
						char sSet[5][6], sBossHealthStages[34];
						sBossHealthStages = !g_bTankConfig[g_iTankType[iTank]] ? g_sBossHealthStages[g_iTankType[iTank]] : g_sBossHealthStages2[g_iTankType[iTank]];
						TrimString(sBossHealthStages);
						ExplodeString(sBossHealthStages, ",", sSet, sizeof(sSet), sizeof(sSet[]));
						TrimString(sSet[0]);
						int iBossHealth = (sSet[0][0] != '\0') ? StringToInt(sSet[0]) : 5000;
						iBossHealth = iSetCellLimit(iBossHealth, 1, ST_MAXHEALTH);
						TrimString(sSet[1]);
						int iBossHealth2 = (sSet[1][0] != '\0') ? StringToInt(sSet[1]) : 2500;
						iBossHealth2 = iSetCellLimit(iBossHealth2, 1, ST_MAXHEALTH);
						TrimString(sSet[2]);
						int iBossHealth3 = (sSet[2][0] != '\0') ? StringToInt(sSet[2]) : 1500;
						iBossHealth3 = iSetCellLimit(iBossHealth3, 1, ST_MAXHEALTH);
						TrimString(sSet[3]);
						int iBossHealth4 = (sSet[3][0] != '\0') ? StringToInt(sSet[3]) : 1000;
						iBossHealth4 = iSetCellLimit(iBossHealth4, 1, ST_MAXHEALTH);
						TrimString(sSet[4]);
						int iBossHealth5 = (sSet[4][0] != '\0') ? StringToInt(sSet[4]) : 500;
						iBossHealth5 = iSetCellLimit(iBossHealth5, 1, ST_MAXHEALTH);
						int iBossStages = !g_bTankConfig[g_iTankType[iTank]] ? g_iBossStages[g_iTankType[iTank]] : g_iBossStages2[g_iTankType[iTank]];
						DataPack dpBoss = new DataPack();
						CreateDataTimer(1.0, tTimerBoss, dpBoss, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
						dpBoss.WriteCell(GetClientUserId(iTank));
						dpBoss.WriteCell(iBossHealth);
						dpBoss.WriteCell(iBossHealth2);
						dpBoss.WriteCell(iBossHealth3);
						dpBoss.WriteCell(iBossHealth4);
						dpBoss.WriteCell(iBossHealth5);
						dpBoss.WriteCell(iBossStages);
					}
				}
				case 2:
				{
					if (!g_bRandomized[iTank])
					{
						g_bBoss[iTank] = true;
						g_bRandomized[iTank] = true;
						float flRandomInterval = !g_bTankConfig[g_iTankType[iTank]] ? g_flRandomInterval[g_iTankType[iTank]] : g_flRandomInterval2[g_iTankType[iTank]];
						CreateTimer(flRandomInterval, tTimerRandomize, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
					}
				}
			}
			Call_StartForward(g_hAbilityForward);
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
	Call_StartForward(g_hSpawnForward);
	Call_PushCell(iTank);
	Call_Finish();
	vParticleEffects(iTank);
	float flThrowInterval = !g_bTankConfig[g_iTankType[iTank]] ? g_flThrowInterval[g_iTankType[iTank]] : g_flThrowInterval2[g_iTankType[iTank]];
	vThrowInterval(iTank, flThrowInterval);
	char sCurrentName[MAX_NAME_LENGTH + 1], sName[MAX_NAME_LENGTH + 1];
	GetClientName(iTank, sCurrentName, sizeof(sCurrentName));
	sName = !g_bTankConfig[g_iTankType[iTank]] ? g_sCustomName[g_iTankType[iTank]] : g_sCustomName2[g_iTankType[iTank]];
	vSetName(iTank, sCurrentName, sName, iMode);
	if (iMode == 0)
	{
		int iHealth = GetClientHealth(iTank),
			iMultiHealth = !g_bGeneralConfig ? g_iMultiHealth : g_iMultiHealth2,
			iExtraHealth = !g_bTankConfig[g_iTankType[iTank]] ? g_iExtraHealth[g_iTankType[iTank]] : g_iExtraHealth2[g_iTankType[iTank]],
			iExtraHealthNormal = !g_bTankConfig[g_iTankType[iTank]] ? (iHealth + g_iExtraHealth[g_iTankType[iTank]]) : (iHealth + g_iExtraHealth2[g_iTankType[iTank]]),
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
	int iRockEffect = !g_bTankConfig[g_iTankType[iTank]] ? g_iRockEffect[g_iTankType[iTank]] : g_iRockEffect2[g_iTankType[iTank]];
	if (iRockEffect == 0)
	{
		return Plugin_Stop;
	}
	char sClassname[32];
	GetEntityClassname(iRock, sClassname, sizeof(sClassname));
	if (strcmp(sClassname, "tank_rock") == 0)
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
	int iRed = (sRGB[0][0] != '\0') ? StringToInt(sRGB[0]) : 255;
	iRed = iSetCellLimit(iRed, 0, 255);
	TrimString(sRGB[1]);
	int iGreen = (sRGB[1][0] != '\0') ? StringToInt(sRGB[1]) : 255;
	iGreen = iSetCellLimit(iGreen, 0, 255);
	TrimString(sRGB[2]);
	int iBlue = (sRGB[2][0] != '\0') ? StringToInt(sRGB[2]) : 255;
	iBlue = iSetCellLimit(iBlue, 0, 255);
	TrimString(sRGB[3]);
	int iAlpha = (sRGB[3][0] != '\0') ? StringToInt(sRGB[3]) : 255;
	iAlpha = iSetCellLimit(iAlpha, 0, 255);
	SetEntityRenderColor(entity, iRed, iGreen, iBlue, iAlpha);
	sRockEffects = !g_bTankConfig[g_iTankType[iThrower]] ? g_sRockEffects[g_iTankType[iThrower]] : g_sRockEffects2[g_iTankType[iThrower]];
	int iRockEffect = !g_bTankConfig[g_iTankType[iThrower]] ? g_iRockEffect[g_iTankType[iThrower]] : g_iRockEffect2[g_iTankType[iThrower]];
	if (iRockEffect == 1 && sRockEffects[0] != '\0')
	{
		DataPack dpRockEffects = new DataPack();
		CreateDataTimer(0.75, tTimerRockEffects, dpRockEffects, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpRockEffects.WriteCell(EntIndexToEntRef(entity));
		dpRockEffects.WriteCell(GetClientUserId(iThrower));
		dpRockEffects.WriteString(sRockEffects);
	}
	Call_StartForward(g_hRockThrowForward);
	Call_PushCell(iThrower);
	Call_PushCell(entity);
	Call_Finish();
	return Plugin_Continue;
}

public Action tTimerSpawnTanks(Handle timer, any wave)
{
	if (iGetTankCount() >= wave)
	{
		return Plugin_Stop;
	}
	int iTank = CreateFakeClient("Tank");
	if (iTank > 0)
	{
		ChangeClientTeam(iTank, 3);
		vCheatCommand(iTank, bIsL4D2Game() ? "z_spawn_old" : "z_spawn", "tank auto");
		KickClient(iTank);
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
		char sDifficulty[11], sDifficultyConfig[512];
		g_cvSTDifficulty.GetString(sDifficulty, sizeof(sDifficulty));
		Format(sDifficultyConfig, sizeof(sDifficultyConfig), "cfg/sourcemod/super_tanks++/difficulty_configs/%s.cfg", sDifficulty);
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
		char sMap[64], sMapConfig[512];
		GetCurrentMap(sMap, sizeof(sMap));
		Format(sMapConfig, sizeof(sMapConfig), (bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_map_configs/%s.cfg" : "cfg/sourcemod/super_tanks++/l4d_map_configs/%s.cfg"), sMap);
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
		char sMode[64], sModeConfig[512];
		g_cvSTGameMode.GetString(sMode, sizeof(sMode));
		Format(sModeConfig, sizeof(sModeConfig), (bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_gamemode_configs/%s.cfg" : "cfg/sourcemod/super_tanks++/l4d_gamemode_configs/%s.cfg"), sMode);
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
		char sDay[9], sDayNumber[2], sDayConfig[512];
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
		Format(sDayConfig, sizeof(sDayConfig), "cfg/sourcemod/super_tanks++/daily_configs/%s.cfg", sDay);
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
		Format(sCountConfig, sizeof(sCountConfig), "cfg/sourcemod/super_tanks++/playercount_configs/%d.cfg", iGetPlayerCount());
		g_iFileTimeNew[5] = GetFileTime(sCountConfig, FileTime_LastChange);
		if (g_iFileTimeOld[5] != g_iFileTimeNew[5])
		{
			PrintToServer("%s Reloading config file (%s)...", ST_PREFIX, sCountConfig);
			vLoadConfigs(sCountConfig);
			g_iFileTimeOld[5] = g_iFileTimeNew[5];
		}
	}
}