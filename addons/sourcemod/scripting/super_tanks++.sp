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

#define MAXTYPES 250
#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_WITCH "models/infected/witch.mdl"
#define MODEL_WITCHBRIDE "models/infected/witch_bride.mdl"
#define MODEL_TANK "models/infected/hulk.mdl"
#define MODEL_TIRES "models/props_vehicles/tire001c_car.mdl"
#define MODEL_SHIELD "models/props_unique/airport/atlas_break_ball.mdl"
#define MODEL_JETPACK "models/props_equipment/oxygentank01.mdl"
#define MODEL_CONCRETE "models/props_debris/concrete_chunk01a.mdl"
#define SPRITE_FIRE "sprites/sprite_fire01.vmt"
#define SPRITE_GLOW "sprites/glow.vmt"
#define PARTICLE_CLOUD "smoker_smokecloud"
#define PARTICLE_ELECTRICITY "electrical_arc_01_system"
#define PARTICLE_SPIT "spitter_projectile"
#define SOUND_INFECTED "npc/infected/action/die/male/death_42.wav"
#define SOUND_INFECTED2 "npc/infected/action/die/male/death_43.wav"
#define SOUND_EXPLOSION "ambient/explosions/exp2.wav"
#define SOUND_LAUNCH "npc/env_headcrabcanister/launch.wav"
#define SOUND_FIRE "weapons/rpg/rocketfire1.wav"
#define SOUND_EXPLOSION2 "ambient/explosions/explode_1.wav"
#define SOUND_EXPLOSION3 "ambient/explosions/explode_2.wav"
#define SOUND_EXPLOSION4 "ambient/explosions/explode_3.wav"
#define ANIMATION_DEBRIS "animation/van_inside_debris.wav"
#define PHYSICS_BULLET "physics/glass/glass_impact_bullet4.wav"

bool g_bAFK[MAXPLAYERS + 1];
bool g_bBlind[MAXPLAYERS + 1];
bool g_bCmdUsed;
bool g_bFlash[MAXTYPES + 1];
bool g_bGhost[MAXTYPES + 1];
bool g_bGravity[MAXTYPES + 1];
bool g_bHeadshot[MAXPLAYERS + 1];
bool g_bHurt[MAXPLAYERS + 1];
bool g_bHypno[MAXPLAYERS + 1];
bool g_bIce[MAXPLAYERS + 1];
bool g_bIdle[MAXPLAYERS + 1];
bool g_bInvert[MAXPLAYERS + 1];
bool g_bLateLoad;
bool g_bMeteor[MAXTYPES + 1];
bool g_bRestartValid;
bool g_bShielded[MAXTYPES + 1];
bool g_bStun[MAXPLAYERS + 1];
char g_sConfigCreate[6];
char g_sConfigExecute[6];
char g_sCustomName[MAXTYPES + 1][33];
char g_sDisabledGameModes[64];
char g_sEnabledGameModes[64];
char g_sLoadout[MAXTYPES + 1][325];
char g_sPropsAttached[MAXTYPES + 1][5];
char g_sPropsChance[MAXTYPES + 1][5];
char g_sSavePath[255];
char g_sShieldColor[MAXTYPES + 1][12];
char g_sTankCharacter[MAXTYPES + 1][2];
char g_sTankColors[MAXTYPES + 1][64];
char g_sTankTypes[65];
char g_sTankWaves[12];
char g_sWeapon[32];
char g_sWeaponSlot[MAXTYPES + 1][6];
ConVar g_cvSTFindConVar[12];
float g_flBlindDuration[MAXTYPES + 1];
float g_flDrugAngles[20] = {0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 20.0, 15.0, 10.0, 5.0, 0.0, -5.0, -10.0, -15.0, -20.0, -25.0, -20.0, -15.0, -10.0, -5.0};
float g_flDrugDuration[MAXTYPES + 1];
float g_flFlashSpeed[MAXTYPES + 1];
float g_flGravityDuration[MAXTYPES + 1];
float g_flGravityForce[MAXTYPES + 1];
float g_flGravityValue[MAXTYPES + 1];
float g_flHealInterval[MAXTYPES + 1];
float g_flHurtDuration[MAXTYPES + 1];
float g_flHypnoDuration[MAXTYPES + 1];
float g_flIce[3];
float g_flInvertDuration[MAXTYPES + 1];
float g_flMeteorDamage[MAXTYPES + 1];
float g_flRunSpeed[MAXTYPES + 1];
float g_flShakeDuration[MAXTYPES + 1];
float g_flShieldDelay[MAXTYPES + 1];
float g_flShoveDuration[MAXTYPES + 1];
float g_flSpamInterval[MAXTYPES + 1];
float g_flSpawnPosition[3];
float g_flStunDuration[MAXTYPES + 1];
float g_flStunSpeed[MAXTYPES + 1];
float g_flThrowInterval[MAXTYPES + 1];
float g_flVisionDuration[MAXTYPES + 1];
float g_flWitchDamage[MAXTYPES + 1];
Handle g_hDrugTimer[MAXPLAYERS + 1];
Handle g_hFlashTimer[MAXTYPES + 1];
Handle g_hHealTimer[MAXTYPES + 1];
Handle g_hSDKAcidPlayer;
Handle g_hSDKFlingPlayer;
Handle g_hSDKHealPlayer;
Handle g_hSDKIdlePlayer;
Handle g_hSDKPukePlayer;
Handle g_hSDKRespawnPlayer;
Handle g_hSDKRevivePlayer;
Handle g_hSDKShovePlayer;
Handle g_hSDKSpecPlayer;
Handle g_hShakeTimer[MAXPLAYERS + 1];
Handle g_hShoveTimer[MAXPLAYERS + 1];
Handle g_hSmokerTimer[MAXPLAYERS + 1];
Handle g_hSpamTimer[MAXPLAYERS + 1];
Handle g_hVisionTimer[MAXPLAYERS + 1];
int g_iAcidChance[MAXTYPES + 1];
int g_iAcidHit[MAXTYPES + 1];
int g_iAcidRock[MAXTYPES + 1];
int g_iAlpha[MAXPLAYERS + 1];
int g_iAmmoChance[MAXTYPES + 1];
int g_iAmmoCount[MAXTYPES + 1];
int g_iAmmoHit[MAXTYPES + 1];
int g_iAnnounceArrival;
int g_iBlindChance[MAXTYPES + 1];
int g_iBlindHit[MAXTYPES + 1];
int g_iBlindIntensity[MAXTYPES + 1];
int g_iBombChance[MAXTYPES + 1];
int g_iBombHit[MAXTYPES + 1];
int g_iBoomerThrow[MAXTYPES + 1];
int g_iChargerThrow[MAXTYPES + 1];
int g_iCloneThrow[MAXTYPES + 1];
int g_iCommonAbility[MAXTYPES + 1];
int g_iCommonAmount[MAXTYPES + 1];
int g_iConfigEnable;
int g_iDisplayHealth;
int g_iDrugChance[MAXTYPES + 1];
int g_iDrugHit[MAXTYPES + 1];
int g_iEnable;
int g_iExplosionSprite = -1;
int g_iExtraHealth[MAXTYPES + 1];
int g_iFinalesOnly;
int g_iFireChance[MAXTYPES + 1];
int g_iFireHit[MAXTYPES + 1];
int g_iFireImmunity[MAXTYPES + 1];
int g_iFireRock[MAXTYPES + 1];
int g_iFlashAbility[MAXTYPES + 1];
int g_iFlashChance[MAXTYPES + 1];
int g_iFlingChance[MAXTYPES + 1];
int g_iFlingHit[MAXTYPES + 1];
int g_iGhostAbility[MAXTYPES + 1];
int g_iGhostChance[MAXTYPES + 1];
int g_iGhostFade[MAXTYPES + 1];
int g_iGhostHit[MAXTYPES + 1];
int g_iGlowEffect[MAXTYPES + 1];
int g_iGravityAbility[MAXTYPES + 1];
int g_iGravityChance[MAXTYPES + 1];
int g_iGravityHit[MAXTYPES + 1];
int g_iHealAbility[MAXTYPES + 1];
int g_iHealChance[MAXTYPES + 1];
int g_iHealCommon[MAXTYPES + 1];
int g_iHealHit[MAXTYPES + 1];
int g_iHealSpecial[MAXTYPES + 1];
int g_iHealTank[MAXTYPES + 1];
int g_iHumanSupport;
int g_iHunterThrow[MAXTYPES + 1];
int g_iHurtAbility[MAXTYPES + 1];
int g_iHurtChance[MAXTYPES + 1];
int g_iHurtDamage[MAXTYPES + 1];
int g_iHypnoChance[MAXTYPES + 1];
int g_iHypnoHit[MAXTYPES + 1];
int g_iIceChance[MAXTYPES + 1];
int g_iIceHit[MAXTYPES + 1];
int g_iIdleChance[MAXTYPES + 1];
int g_iIdleHit[MAXTYPES + 1];
int g_iInfectedThrow[MAXTYPES + 1];
int g_iInvertChance[MAXTYPES + 1];
int g_iInvertHit[MAXTYPES + 1];
int g_iJockeyThrow[MAXTYPES + 1];
int g_iJumperAbility[MAXTYPES + 1];
int g_iJumperChance[MAXTYPES + 1];
int g_iMaxTypes;
int g_iMeteorAbility[MAXTYPES + 1];
int g_iMeteorChance[MAXTYPES + 1];
int g_iPukeChance[MAXTYPES + 1];
int g_iPukeHit[MAXTYPES + 1];
int g_iRestartChance[MAXTYPES + 1];
int g_iRestartHit[MAXTYPES + 1];
int g_iRocket[MAXTYPES + 1];
int g_iRocketChance[MAXTYPES + 1];
int g_iRocketHit[MAXTYPES + 1];
int g_iShakeChance[MAXTYPES + 1];
int g_iShakeHit[MAXTYPES + 1];
int g_iShieldAbility[MAXTYPES + 1];
int g_iShoveChance[MAXTYPES + 1];
int g_iShoveHit[MAXTYPES + 1];
int g_iSlugChance[MAXTYPES + 1];
int g_iSlugHit[MAXTYPES + 1];
int g_iSlugSprite = -1;
int g_iSmokeEffect[MAXTYPES + 1];
int g_iSmokerThrow[MAXTYPES + 1];
int g_iSpamAbility[MAXTYPES + 1];
int g_iSpamAmount[MAXTYPES + 1];
int g_iSpamCount[MAXPLAYERS + 1];
int g_iSpamDamage[MAXTYPES + 1];
int g_iSpawnInterval[MAXPLAYERS + 1];
int g_iSpitterThrow[MAXTYPES + 1];
int g_iStunChance[MAXTYPES + 1];
int g_iStunHit[MAXTYPES + 1];
int g_iTankType[MAXTYPES + 1];
int g_iTankWave;
int g_iType;
int g_iVisionChance[MAXTYPES + 1];
int g_iVisionFOV[MAXTYPES + 1];
int g_iVisionHit[MAXTYPES + 1];
int g_iWarpAbility[MAXTYPES + 1];
int g_iWarpInterval[MAXTYPES + 1];
int g_iWitchAbility[MAXTYPES + 1];
int g_iWitchAmount[MAXTYPES + 1];
UserMsg g_umFadeUserMsgId;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion evEngine = GetEngineVersion();
	if (evEngine != Engine_Left4Dead && evEngine != Engine_Left4Dead2)
	{
		strcopy(error, err_max, "Super Tanks++ only supports Left 4 Dead 1 & 2.");
		return APLRes_SilentFailure;
	}
	g_bLateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart()
{
	CreateDirectory("cfg/sourcemod/super_tanks++/", 511);
	Format(g_sSavePath, sizeof(g_sSavePath), "cfg/sourcemod/super_tanks++/super_tanks++.cfg");
	vLoadConfigs(g_sSavePath, true);
	vMultiTargetFilters(1);
	RegAdminCmd("sm_tank", cmdTank, ADMFLAG_ROOT, "Spawn a Super Tank.");
	CreateConVar("st_pluginversion", ST_VERSION, "Super Tanks++ Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_cvSTFindConVar[0] = FindConVar("z_difficulty");
	g_cvSTFindConVar[1] = FindConVar("mp_gamemode");
	g_cvSTFindConVar[2] = FindConVar("sv_gametypes");
	g_cvSTFindConVar[3] = FindConVar("survivor_max_incapacitated_count");
	bIsL4D2Game() ? (g_cvSTFindConVar[4] = FindConVar("z_smoker_limit")) : (g_cvSTFindConVar[4] = FindConVar("z_gas_limit"));
	bIsL4D2Game() ? (g_cvSTFindConVar[5] = FindConVar("z_boomer_limit")) : (g_cvSTFindConVar[5] = FindConVar("z_exploding_limit"));
	g_cvSTFindConVar[6] = FindConVar("z_hunter_limit");
	if (bIsL4D2Game())
	{
		g_cvSTFindConVar[7] = FindConVar("z_spitter_limit");
		g_cvSTFindConVar[8] = FindConVar("z_jockey_limit");
		g_cvSTFindConVar[9] = FindConVar("z_charger_limit");
	}
	g_cvSTFindConVar[10] = FindConVar("z_max_player_zombies");
	g_cvSTFindConVar[11] = FindConVar("z_tank_throw_force");
	g_cvSTFindConVar[0].AddChangeHook(vSTGameDifficultyCvar);
	HookEvent("ability_use", eEventAbilityUse);
	HookEvent("finale_escape_start", eEventFinaleEscapeStart);
	HookEvent("finale_start", eEventFinaleStart, EventHookMode_Pre);
	HookEvent("finale_vehicle_leaving", eEventFinaleVehicleLeaving);
	HookEvent("finale_vehicle_ready", eEventFinaleVehicleReady);
	HookEvent("player_afk", eEventPlayerAFK, EventHookMode_Pre);
	HookEvent("player_bot_replace", eEventPlayerBotReplace);
	HookEvent("player_death", eEventPlayerDeath);
	HookEvent("round_start", eEventRoundStart);
	HookEvent("tank_spawn", eEventTankSpawn);
	Handle hGameData = LoadGameConfigFile("super_tanks++");
	if (bIsL4D2Game())
	{
		StartPrepSDKCall(SDKCall_Static);
		PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CSpitterProjectile_Create");
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		PrepSDKCall_SetReturnInfo(SDKType_CBaseEntity, SDKPass_Pointer);
		g_hSDKAcidPlayer = EndPrepSDKCall();
		if (g_hSDKAcidPlayer == null)
		{
			PrintToServer("%s Your \"CSpitterProjectile_Create\" signature is outdated.", ST_PREFIX);
		}
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer_Fling");
		PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
		PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
		PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
		PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
		g_hSDKFlingPlayer = EndPrepSDKCall();
		if (g_hSDKFlingPlayer == null)
		{
			PrintToServer("%s Your \"CTerrorPlayer_Fling\" signature is outdated.", ST_PREFIX);
		}
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer_SetHealthBuffer");
	PrepSDKCall_AddParameter(SDKType_Float, SDKPass_Plain);
	g_hSDKHealPlayer = EndPrepSDKCall();
	if (g_hSDKHealPlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_SetHealthBuffer\" signature is outdated.", ST_PREFIX);
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer_OnRevived");
	g_hSDKRevivePlayer = EndPrepSDKCall();
	if (g_hSDKRevivePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnRevived\" signature is outdated.", ST_PREFIX);
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer::GoAwayFromKeyboard");
	g_hSDKIdlePlayer = EndPrepSDKCall();
	if (g_hSDKIdlePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer::GoAwayFromKeyboard\" signature is outdated.", ST_PREFIX);
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "SetHumanSpec");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	g_hSDKSpecPlayer = EndPrepSDKCall();
	if (g_hSDKSpecPlayer == null)
	{
		PrintToServer("%s Your \"SetHumanSpec\" signature is outdated.", ST_PREFIX);
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	g_hSDKPukePlayer = EndPrepSDKCall();
	if (g_hSDKPukePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnVomitedUpon\" signature is outdated.", ST_PREFIX);
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "RoundRespawn");
	g_hSDKRespawnPlayer = EndPrepSDKCall();
	if (g_hSDKRespawnPlayer == null)
	{
		PrintToServer("%s Your \"RoundRespawn\" signature is outdated.", ST_PREFIX);
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CTerrorPlayer_OnStaggered");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_Pointer);
	g_hSDKShovePlayer = EndPrepSDKCall();
	if (g_hSDKShovePlayer == null)
	{
		PrintToServer("%s Your \"CTerrorPlayer_OnStaggered\" signature is outdated.", ST_PREFIX);
	}
	delete hGameData;
	g_umFadeUserMsgId = GetUserMessageId("Fade");
}

public void OnMapStart()
{
	PrecacheModel(MODEL_GASCAN, true);
	PrecacheModel(MODEL_PROPANETANK, true);
	PrecacheModel(MODEL_WITCH, true);
	PrecacheModel(MODEL_WITCHBRIDE, true);
	PrecacheModel(MODEL_TIRES, true);
	PrecacheModel(MODEL_SHIELD, true);
	PrecacheModel(MODEL_JETPACK, true);
	PrecacheModel(MODEL_CONCRETE, true);
	g_iExplosionSprite = PrecacheModel(SPRITE_FIRE, true);
	g_iSlugSprite = PrecacheModel(SPRITE_GLOW);
	vPrecacheParticle(PARTICLE_CLOUD);
	vPrecacheParticle(PARTICLE_ELECTRICITY);
	vPrecacheParticle(PARTICLE_SPIT);
	PrecacheSound(SOUND_INFECTED, true);
	PrecacheSound(SOUND_INFECTED2, true);
	PrecacheSound(SOUND_EXPLOSION, true);
	PrecacheSound(SOUND_LAUNCH, true);
	PrecacheSound(SOUND_FIRE, true);
	PrecacheSound(SOUND_EXPLOSION2, true);
	PrecacheSound(SOUND_EXPLOSION3, true);
	PrecacheSound(SOUND_EXPLOSION4, true);
	PrecacheSound(ANIMATION_DEBRIS, true);
	PrecacheSound(PHYSICS_BULLET, true);
	if (g_bLateLoad)
	{
		vLoadConfigs(g_sSavePath, true);
		for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++ )
		{
			if (bIsValidClient(iPlayer))
			{
				SDKHook(iPlayer, SDKHook_OnTakeDamage, OnTakeDamage);
				SDKHook(iPlayer, SDKHook_TraceAttack, TraceAttack);
			}
		}
	}
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_TraceAttack, TraceAttack);
	vStopTimers(client);
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKUnhook(client, SDKHook_TraceAttack, TraceAttack);
	vStopTimers(client);
}

public void OnConfigsExecuted()
{
	vLoadConfigs(g_sSavePath, true);
	g_bCmdUsed = false;
	g_bRestartValid = false;
	CreateTimer(0.1, tTimerTankHealthUpdate, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(1.0, tTimerTankTypeUpdate, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	CreateTimer(1.0, tTimerUpdatePlayerCount, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
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
		char sDifficulty[11];
		char sDifficultyConfig[512];
		g_cvSTFindConVar[0].GetString(sDifficulty, sizeof(sDifficulty));
		Format(sDifficultyConfig, sizeof(sDifficultyConfig), "cfg/sourcemod/super_tanks++/difficulty_configs/%s.cfg", sDifficulty);
		vLoadConfigs(sDifficultyConfig);
	}
	if (StrContains(g_sConfigExecute, "2") != -1 && g_iConfigEnable == 1)
	{
		char sMap[64];
		char sMapConfig[512];
		GetCurrentMap(sMap, sizeof(sMap));
		Format(sMapConfig, sizeof(sMapConfig), (bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_map_configs/%s.cfg" : "cfg/sourcemod/super_tanks++/l4d_map_configs/%s.cfg"), sMap);
		vLoadConfigs(sMapConfig);
	}
	if (StrContains(g_sConfigExecute, "3") != -1 && g_iConfigEnable == 1)
	{
		char sMode[64];
		char sModeConfig[512];
		g_cvSTFindConVar[1].GetString(sMode, sizeof(sMode));
		Format(sModeConfig, sizeof(sModeConfig), (bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_gamemode_configs/%s.cfg" : "cfg/sourcemod/super_tanks++/l4d_gamemode_configs/%s.cfg"), sMode);
		vLoadConfigs(sModeConfig);
	}
	if (StrContains(g_sConfigExecute, "4") != -1 && g_iConfigEnable == 1)
	{
		char sDay[9];
		char sDayConfig[512];
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
		Format(sDayConfig, sizeof(sDayConfig), "cfg/sourcemod/super_tanks++/daily_configs/%s.cfg", sDay);
		vLoadConfigs(sDayConfig);
	}
	if (StrContains(g_sConfigExecute, "5") != -1 && g_iConfigEnable == 1)
	{
		char sCountConfig[512];
		Format(sCountConfig, sizeof(sCountConfig), "cfg/sourcemod/super_tanks++/playercount_configs/%d.cfg", iGetPlayerCount());
		vLoadConfigs(sCountConfig);
	}
}

public void OnMapEnd()
{
	g_bCmdUsed = false;
	g_bRestartValid = false;
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		vStopTimers(iPlayer);
	}
}

public void OnPluginEnd()
{
	vMultiTargetFilters(0);
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if (g_iEnable == 1 && bIsSystemValid(g_cvSTFindConVar[1], g_sEnabledGameModes, g_sDisabledGameModes))
	{
		if (strcmp(classname, "tank_rock") == 0)
		{
			CreateTimer(0.1, tTimerRockThrow, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public void OnEntityDestroyed(int entity)
{
	if (g_iEnable == 1 && bIsSystemValid(g_cvSTFindConVar[1], g_sEnabledGameModes, g_sDisabledGameModes))
	{
		if (IsValidEntity(entity))
		{
			char sClassname[32];
			GetEntityClassname(entity, sClassname, sizeof(sClassname));
			if (strcmp(sClassname, "tank_rock") == 0)
			{
				int iThrower = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
				if (iThrower > 0 && bIsTank(iThrower) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(iThrower))))
				{
					vAcidRock(entity, iThrower, g_iAcidRock[g_iTankType[iThrower]]);
					vFireRock(entity, iThrower, g_iFireRock[g_iTankType[iThrower]]);
				}
			}
		}
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (g_iEnable == 0 || !bIsSystemValid(g_cvSTFindConVar[1], g_sEnabledGameModes, g_sDisabledGameModes))
	{
		return Plugin_Continue;
	}
	if (g_bInvert[client])
	{
		vel[1] = -vel[1];
		if (buttons & IN_MOVELEFT)
		{
			buttons &= ~IN_MOVELEFT;
			buttons |= IN_MOVERIGHT;
		}
		else if (buttons & IN_MOVERIGHT)
		{
			buttons &= ~IN_MOVERIGHT;
			buttons |= IN_MOVELEFT;
		}
		vel[0] = -vel[0];
		if (buttons & IN_FORWARD)
		{
			buttons &= ~IN_FORWARD;
			buttons |= IN_BACK;
		}
		else if (buttons & IN_BACK)
		{
			buttons &= ~IN_BACK;
			buttons |= IN_FORWARD;
		}
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (g_iEnable == 1 && bIsSystemValid(g_cvSTFindConVar[1], g_sEnabledGameModes, g_sDisabledGameModes))
	{
		if (damage > 0.0 && bIsValidClient(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (bIsSurvivor(victim))
			{
				if (bIsWitch(attacker))
				{
					int iOwner = GetEntPropEnt(attacker, Prop_Send, "m_hOwnerEntity");
					if (bIsTank(iOwner))
					{
						damage = g_flWitchDamage[g_iTankType[iOwner]];
					}
				}
				else if (bIsTank(attacker) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(attacker))) && damagetype != 2)
				{
					if (strcmp(sClassname, "weapon_tank_claw") == 0 || strcmp(sClassname, "tank_rock") == 0)
					{
						vAcidHit(victim, attacker, g_iAcidHit[g_iTankType[attacker]]);
						vAmmoHit(victim, attacker, g_iAmmoHit[g_iTankType[attacker]]);
						vBlindHit(victim, attacker, g_iBlindHit[g_iTankType[attacker]]);
						vBombHit(victim, attacker, g_iBombHit[g_iTankType[attacker]]);
						vCommonAbility(attacker, g_iCommonAbility[g_iTankType[attacker]]);
						vDrugHit(victim, attacker, g_iDrugHit[g_iTankType[attacker]]);
						vFireHit(victim, attacker, g_iFireHit[g_iTankType[attacker]]);
						vFlingHit(victim, attacker, g_iFlingHit[g_iTankType[attacker]]);
						vGhostHit(victim, attacker, g_iGhostHit[g_iTankType[attacker]]);
						vGravityHit(victim, attacker, g_iGravityHit[g_iTankType[attacker]]);
						vHealHit(victim, attacker, g_iHealHit[g_iTankType[attacker]]);
						vHurtHit(victim, attacker, g_iHurtAbility[g_iTankType[attacker]]);
						vHypnoHit(victim, attacker, g_iHypnoHit[g_iTankType[attacker]]);
						vIceHit(victim, attacker, g_iIceHit[g_iTankType[attacker]]);
						vIdleHit(victim, attacker, g_iIdleHit[g_iTankType[attacker]]);
						vInvertHit(victim, attacker, g_iInvertHit[g_iTankType[attacker]]);
						vPukeHit(victim, attacker, g_iPukeHit[g_iTankType[attacker]]);
						vRestartHit(victim, attacker, g_iRestartHit[g_iTankType[attacker]]);
						vRocketHit(victim, attacker, g_iRocketHit[g_iTankType[attacker]]);
						vShakeHit(victim, attacker, g_iShakeHit[g_iTankType[attacker]]);
						vShoveHit(victim, attacker, g_iShoveHit[g_iTankType[attacker]]);
						vSlugHit(victim, attacker, g_iSlugHit[g_iTankType[attacker]]);
						vStunHit(victim, attacker, g_iStunHit[g_iTankType[attacker]]);
						vVisualHit(victim, attacker, g_iVisionHit[g_iTankType[attacker]]);
					}
				}
			}
			else if (bIsInfected(victim))
			{
				if (bIsTank(victim) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(victim))))
				{
					if (damagetype & DMG_BURN)
					{
						if (g_iFireImmunity[g_iTankType[victim]] == 1 || attacker == victim)
						{
							damage = 0.0;
							return Plugin_Handled;
						}
					}
					if (damagetype & DMG_BLAST && victim == attacker)
					{
						damage = 0.0;
						return Plugin_Handled;
					}
					if (bIsSurvivor(attacker))
					{
						if (strcmp(sClassname, "weapon_melee") == 0)
						{
							vAcidHit(attacker, victim, g_iAcidHit[g_iTankType[victim]]);
							vFireHit(attacker, victim, g_iFireHit[g_iTankType[victim]]);
							vGhostHit(attacker, victim, g_iGhostHit[g_iTankType[victim]]);
							vHurtHit(attacker, victim, g_iHurtAbility[g_iTankType[victim]]);
							vMeteorAbility(victim, g_iMeteorAbility[g_iTankType[victim]]);
						}
						if (damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA)
						{
							if (g_bShielded[victim])
							{
								vShieldAbility(victim, false, g_iShieldAbility[g_iTankType[victim]]);
							}
						}
						else
						{
							if (g_bShielded[victim])
							{
								return Plugin_Handled;
							}
						}
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

public Action TraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if (bIsSurvivor(attacker))
	{
		if (g_bHypno[attacker] && attacker != victim)
		{
			int iDamage = RoundFloat(damage);
			if (!IsClientConnected(attacker))
			{
				iDamage = 0;
				return Plugin_Changed;
			}
			int iHealth = GetClientHealth(attacker);
			if (iHealth > 0 && iHealth > iDamage)
			{
				SetEntityHealth(attacker, iHealth - iDamage);
				iDamage = 0;
				return Plugin_Changed;
			}
			else
			{
				GetEntityClassname(inflictor, g_sWeapon, sizeof(g_sWeapon));
				if (StrContains(g_sWeapon, "_projectile") > 0)
				{
					ReplaceString(g_sWeapon, sizeof(g_sWeapon), "_projectile", "", false);
					SetEntityHealth(attacker, 1);
					iDamage = 0;
					return Plugin_Changed;
				}
				else
				{
					GetClientWeapon(attacker, g_sWeapon, sizeof(g_sWeapon));
					ReplaceString(g_sWeapon, sizeof(g_sWeapon), "weapon_", "", false);
					hitgroup == 1 ? (g_bHeadshot[attacker] = true) : (g_bHeadshot[attacker] = false);
					SetEntityHealth(attacker, 1);
					iDamage = 0;
					return Plugin_Changed;
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action eEventAbilityUse(Event event, const char[] name, bool dontBroadcast)
{
	int iUserId = event.GetInt("userid");
	int iTank = GetClientOfUserId(iUserId);
	if (g_iEnable == 1 && bIsSystemValid(g_cvSTFindConVar[1], g_sEnabledGameModes, g_sDisabledGameModes))
	{
		if (bIsTank(iTank))
		{
			int iEntity = -1;
			while ((iEntity = FindEntityByClassname(iEntity, "prop_dynamic")) != INVALID_ENT_REFERENCE)
			{
				char sModel[128];
				GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
				if (strcmp(sModel, MODEL_CONCRETE) == 0 || strcmp(sModel, MODEL_JETPACK) == 0 || strcmp(sModel, MODEL_SHIELD) == 0 || strcmp(sModel, MODEL_TIRES) == 0 || strcmp(sModel, MODEL_TANK) == 0)
				{
					int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
					if (iOwner == iTank)
					{
						SDKUnhook(iEntity, SDKHook_SetTransmit, SetTransmit);
						CreateTimer(3.5, tTimerSetTransmit, EntIndexToEntRef(iEntity), TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
			while ((iEntity = FindEntityByClassname(iEntity, "beam_spotlight")) != INVALID_ENT_REFERENCE)
			{
				int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
				if (iOwner == iTank)
				{
					SDKUnhook(iEntity, SDKHook_SetTransmit, SetTransmit);
					CreateTimer(3.5, tTimerSetTransmit, EntIndexToEntRef(iEntity), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			while ((iEntity = FindEntityByClassname(iEntity, "env_steam")) != INVALID_ENT_REFERENCE)
			{
				int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
				if (iOwner == iTank)
				{
					SDKUnhook(iEntity, SDKHook_SetTransmit, SetTransmit);
					CreateTimer(3.5, tTimerSetTransmit, EntIndexToEntRef(iEntity), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
			vThrowInterval(iTank, g_flThrowInterval[g_iTankType[iTank]]);
		}
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

public Action eEventPlayerAFK(Event event, const char[] name, bool dontBroadcast)
{
	int iIdler = GetClientOfUserId(event.GetInt("player"));
	g_bAFK[iIdler] = true;
}

public Action eEventPlayerBotReplace(Event event, const char[] name, bool dontBroadcast)
{
	int iSurvivorId = event.GetInt("player");
	int iSurvivor = GetClientOfUserId(iSurvivorId);
	int iBotId = event.GetInt("bot");
	int iBot = GetClientOfUserId(iBotId);
	if (g_iEnable == 1 && bIsSystemValid(g_cvSTFindConVar[1], g_sEnabledGameModes, g_sDisabledGameModes) && bIsIdlePlayer(iBot, iSurvivor)) 
	{
		DataPack dpDataPack;
		CreateDataTimer(0.2, tTimerIdleFix, dpDataPack, TIMER_FLAG_NO_MAPCHANGE);
		dpDataPack.WriteCell(iSurvivorId);
		dpDataPack.WriteCell(iBotId);
		if (g_bIdle[iSurvivor])
		{
			g_bIdle[iSurvivor] = false;
			vIdleWarp(iBot);
		}
	}
}

public Action eEventPlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	int iAttackerId = event.GetInt("userid");
	int iAttacker = GetClientOfUserId(iAttackerId);
	int iUserId = event.GetInt("userid");
	int iTank = GetClientOfUserId(iUserId);
	if (g_iEnable == 1 && bIsSystemValid(g_cvSTFindConVar[1], g_sEnabledGameModes, g_sDisabledGameModes))
	{
		if (bIsValidClient(iTank))
		{
			SetEntityGravity(iTank, 1.0);
			if (g_iGlowEffect[g_iTankType[iTank]] == 1 && bIsL4D2Game())
			{
				SetEntProp(iTank, Prop_Send, "m_iGlowType", 0);
				SetEntProp(iTank, Prop_Send, "m_glowColorOverride", 0);
			}
			if (bIsTank(iTank, false) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(iTank))))
			{
				if (g_bHypno[iAttacker] && iTank > 0 && iAttacker != iTank)
				{
					event.SetInt("attacker", GetClientOfUserId(iTank));
					event.SetString("weapon", g_sWeapon);
					event.SetInt("userid", GetClientOfUserId(iAttacker));
					if (g_bHeadshot[iAttacker])
					{
						event.SetBool("headshot", true);
					}
					SetEntProp(iTank, Prop_Data, "m_iFrags", GetClientFrags(iTank) + 1);
					SetEntProp(iAttacker, Prop_Data, "m_iFrags", GetClientFrags(iAttacker) + 1);
				}
				if (g_iBlindHit[g_iTankType[iTank]])
				{
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor) && g_bBlind[iSurvivor])
						{
							tTimerStopBlindness(null, GetClientUserId(iSurvivor));
						}
					}
				}
				if (g_iDrugHit[g_iTankType[iTank]])
				{
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor) && g_hDrugTimer[iSurvivor] != null)
						{
							KillTimer(g_hDrugTimer[iSurvivor]);
							g_hDrugTimer[iSurvivor] = null;
						}
					}
				}
				vStopFlash(iTank, 1);
				if (g_iGravityHit[g_iTankType[iTank]])
				{
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor) && g_bGravity[iSurvivor])
						{
							tTimerStopGravity(null, GetClientUserId(iSurvivor));
						}
					}
				}
				g_bGhost[iTank] = false;
				g_iAlpha[iTank] = 255;
				vStopHeal(iTank, 1);
				if (g_iHypnoHit[g_iTankType[iTank]])
				{
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor))
						{
							g_bHypno[iSurvivor] = false;
						}
					}
				}
				if (g_iIceHit[g_iTankType[iTank]])
				{
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor) && g_bIce[iSurvivor])
						{
							tTimerStopIce(null, GetClientUserId(iSurvivor));
						}
					}
				}
				if (g_iInvertHit[g_iTankType[iTank]])
				{
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor))
						{
							g_bInvert[iSurvivor] = false;
						}
					}
				}
				if (g_iShakeHit[g_iTankType[iTank]])
				{
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor) && g_hShakeTimer[iSurvivor] != null)
						{
							KillTimer(g_hShakeTimer[iSurvivor]);
							g_hShakeTimer[iSurvivor] = null;
						}
					}
				}
				if (g_iShoveHit[g_iTankType[iTank]])
				{
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor) && g_hShoveTimer[iSurvivor] != null)
						{
							KillTimer(g_hShoveTimer[iSurvivor]);
							g_hShoveTimer[iSurvivor] = null;
						}
					}
				}
				if (g_iSlugHit[g_iTankType[iTank]])
				{
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor))
						{
							SetEntPropFloat(iSurvivor, Prop_Data, "m_flLaggedMovementValue", 1.0);
						}
					}
				}
				vStopSmoker(iTank, 1);
				vStopSpam(iTank, 1);
				if (g_iVisionHit[g_iTankType[iTank]])
				{
					for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
					{
						if (bIsSurvivor(iSurvivor) && g_hVisionTimer[iSurvivor] != null)
						{
							KillTimer(g_hVisionTimer[iSurvivor]);
							g_hVisionTimer[iSurvivor] = null;
						}
					}
				}
				int iEntity = -1;
				while ((iEntity = FindEntityByClassname(iEntity, "prop_dynamic")) != INVALID_ENT_REFERENCE)
				{
					char sModel[128];
					GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
					if (strcmp(sModel, MODEL_CONCRETE) == 0 || strcmp(sModel, MODEL_JETPACK) == 0 || strcmp(sModel, MODEL_SHIELD) == 0 || strcmp(sModel, MODEL_TIRES) == 0 || strcmp(sModel, MODEL_TANK) == 0)
					{
						int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
						if (iOwner == iTank)
						{
							AcceptEntityInput(iEntity, "Kill");
							SDKUnhook(iEntity, SDKHook_SetTransmit, SetTransmit);
						}
					}
				}
				while ((iEntity = FindEntityByClassname(iEntity, "beam_spotlight")) != INVALID_ENT_REFERENCE)
				{
					int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
					if (iOwner == iTank)
					{
						AcceptEntityInput(iEntity, "Kill");
						SDKUnhook(iEntity, SDKHook_SetTransmit, SetTransmit);
					}
				}
				while ((iEntity = FindEntityByClassname(iEntity, "point_push")) != INVALID_ENT_REFERENCE)
				{
					if (bIsL4D2Game())
					{
						int iOwner = GetEntProp(iEntity, Prop_Send, "m_glowColorOverride");
						if (iOwner == iTank)
						{
							AcceptEntityInput(iEntity, "Kill");
						}
					}
					int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
					if (iOwner == iTank)
					{
						AcceptEntityInput(iEntity, "Kill");
					}
				}
				switch (g_iTankWave)
				{
					case 1: CreateTimer(5.0, tTimerTankWave2, _, TIMER_FLAG_NO_MAPCHANGE);
					case 2: CreateTimer(5.0, tTimerTankWave3, _, TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
}

public Action eEventRoundStart(Event event, const char[] name, bool dontBroadcast)
{
	if (g_iEnable == 1 && bIsSystemValid(g_cvSTFindConVar[1], g_sEnabledGameModes, g_sDisabledGameModes))
	{
		g_iTankWave = 0;
		g_sWeapon[0] = '\0';
		for (int iPlayer= 1; iPlayer <= MaxClients; iPlayer++)
		{
			g_bHeadshot[iPlayer] = false;
			g_bHypno[iPlayer] = false;
		}
		CreateTimer(10.0, tTimerRestartCoordinates, _, TIMER_FLAG_NO_MAPCHANGE);
		g_cvSTFindConVar[4].SetString("32");
		g_cvSTFindConVar[5].SetString("32");
		g_cvSTFindConVar[6].SetString("32");
		if (bIsL4D2Game())
		{
			g_cvSTFindConVar[7].SetString("32");
			g_cvSTFindConVar[8].SetString("32");
			g_cvSTFindConVar[9].SetString("32");
		}
	}
}

public Action eEventTankSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int iUserId = event.GetInt("userid");
	int iTank = GetClientOfUserId(iUserId);
	if (g_iEnable == 1 && bIsSystemValid(g_cvSTFindConVar[1], g_sEnabledGameModes, g_sDisabledGameModes))
	{
		if (bIsTank(iTank) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(iTank))))
		{
			if (g_bCmdUsed)
			{
				vSetColor(iTank, g_iType);
				g_bCmdUsed = false;
			}
			else
			{
				g_iTankType[iTank] = 0;
				if (g_iFinalesOnly == 0 || (g_iFinalesOnly == 1 && (bIsFinaleMap() || g_iTankWave > 0)))
				{
					char sCharacters = g_sTankTypes[GetRandomInt(0, strlen(g_sTankTypes) - 1)];
					for (int iIndex = 1; iIndex <= g_iMaxTypes; iIndex++)
					{
						if (sCharacters == g_sTankCharacter[iIndex][0])
						{
							vSetColor(iTank, iIndex);
						}
					}
					char sNumbers[3][4];
					ExplodeString(g_sTankWaves, ",", sNumbers, sizeof(sNumbers), sizeof(sNumbers[]));
					int iWave1 = StringToInt(sNumbers[0]);
					int iWave2 = StringToInt(sNumbers[1]);
					int iWave3 = StringToInt(sNumbers[2]);
					switch (g_iTankWave)
					{
						case 1: vTankCountCheck(iTank, iWave1);
						case 2: vTankCountCheck(iTank, iWave2);
						case 3: vTankCountCheck(iTank, iWave3);
					}
				}
			}
			CreateTimer(0.1, tTimerTankSpawn, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action cmdTank(int client, int args)
{
	if (g_iEnable == 0)
	{
		ReplyToCommand(client, "\x04%s\x01 Super Tanks++ is disabled.", ST_PREFIX);
		return Plugin_Handled;
	}
	if (!bIsValidHumanClient(client))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", ST_PREFIX);
		return Plugin_Handled;
	}
	if (!bIsSystemValid(g_cvSTFindConVar[1], g_sEnabledGameModes, g_sDisabledGameModes))
	{
		ReplyToCommand(client, "\x04%s\x01 Game mode not supported.", ST_PREFIX);
		return Plugin_Handled;
	}
	char tank[32];
	GetCmdArg(1, tank, sizeof(tank));
	int type = StringToInt(tank);
	if (args < 1)
	{
		IsVoteInProgress() ? ReplyToCommand(client, "\x04%s\x01 %t", ST_PREFIX, "Vote in Progress") : vTankMenu(client, 0);
		return Plugin_Handled;
	}
	else if (type > g_iMaxTypes || args > 1)
	{
		ReplyToCommand(client, "\x04%s\x01 Usage: sm_tank <type 1-%d>", ST_PREFIX, g_iMaxTypes);
		return Plugin_Handled;
	}
	if (StrContains(g_sTankTypes, g_sTankCharacter[type]) == -1)
	{
		ReplyToCommand(client, "\x04%s\x01 %s (Tank #%d) is disabled.", ST_PREFIX, g_sCustomName[type], type);
		return Plugin_Handled;
	}
	vTank(client, type);
	return Plugin_Handled;
}

void vTank(int client, int type)
{
	g_bCmdUsed = true;
	g_iType = type;
	bIsL4D2Game() ? vCheatCommand(client, "z_spawn_old", "tank") : vCheatCommand(client, "z_spawn", "tank");
}

void vTankMenu(int client, int item)
{
	Menu mTankMenu = new Menu(iTankMenuHandler);
	mTankMenu.SetTitle("Super Tanks++ Menu");
	for (int iIndex = 1; iIndex <= g_iMaxTypes; iIndex++)
	{
		if (StrContains(g_sTankTypes, g_sTankCharacter[iIndex]) == -1)
		{
			continue;
		}
		mTankMenu.AddItem(g_sCustomName[iIndex], g_sCustomName[iIndex]);
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
			char sInfo[33];
			menu.GetItem(param2, sInfo, sizeof(sInfo));
			for (int iIndex = 1; iIndex <= g_iMaxTypes; iIndex++)
			{
				if (strcmp(sInfo, g_sCustomName[iIndex]) == 0)
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

float flSetFloatLimit(float value, float min, float max)
{
	if (value < min)
	{
		value = min;
	}
	else if (value > max)
	{
		value = max;
	}
	return value;
}

int iSetCellLimit(int value, int min, int max)
{
	if (value < min)
	{
		value = min;
	}
	else if (value > max)
	{
		value = max;
	}
	return value;
}

void vLoadConfigs(char[] savepath, bool main = false)
{
	if (!FileExists(savepath))
	{
		if (main)
		{
			SetFailState("Missing \"%s\" config file.", savepath);
		}
		return;
	}
	KeyValues kvSuperTanks = new KeyValues("Super Tanks++");
	if (!kvSuperTanks.ImportFromFile(savepath))
	{
		if (main)
		{
			SetFailState("Error reading from \"%s\" config file.", savepath);
		}
		delete kvSuperTanks;
		return;
	}
	if (kvSuperTanks.JumpToKey("General"))
	{
		g_iEnable = kvSuperTanks.GetNum("Plugin Enabled", 1);
		g_iEnable = iSetCellLimit(g_iEnable, 0, 1);
		if (main)
		{
			kvSuperTanks.GetString("Enabled Game Modes", g_sEnabledGameModes, sizeof(g_sEnabledGameModes), "coop");
			kvSuperTanks.GetString("Disabled Game Modes", g_sDisabledGameModes, sizeof(g_sDisabledGameModes), "mutation1");
			g_iConfigEnable = kvSuperTanks.GetNum("Enable Custom Configs", 0);
			g_iConfigEnable = iSetCellLimit(g_iConfigEnable, 0, 1);
			kvSuperTanks.GetString("Create Config Types", g_sConfigCreate, sizeof(g_sConfigCreate), "12345");
			kvSuperTanks.GetString("Execute Config Types", g_sConfigExecute, sizeof(g_sConfigExecute), "1");
		}
		g_iAnnounceArrival = kvSuperTanks.GetNum("Announce Arrival", 1);
		g_iAnnounceArrival = iSetCellLimit(g_iAnnounceArrival, 0, 1);
		g_iDisplayHealth = kvSuperTanks.GetNum("Display Health", 3);
		g_iDisplayHealth = iSetCellLimit(g_iDisplayHealth, 0, 3);
		g_iFinalesOnly = kvSuperTanks.GetNum("Finales Only", 0);
		g_iFinalesOnly = iSetCellLimit(g_iFinalesOnly, 0, 1);
		g_iHumanSupport = kvSuperTanks.GetNum("Human Super Tanks", 1);
		g_iHumanSupport = iSetCellLimit(g_iHumanSupport, 0, 1);
		g_iMaxTypes = kvSuperTanks.GetNum("Maximum Types", MAXTYPES);
		g_iMaxTypes = iSetCellLimit(g_iMaxTypes, 1, MAXTYPES);
		kvSuperTanks.GetString("Tank Types", g_sTankTypes, sizeof(g_sTankTypes), "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz");
		kvSuperTanks.GetString("Tank Waves", g_sTankWaves, sizeof(g_sTankWaves), "1,2,3");
		kvSuperTanks.Rewind();
	}
	for (int iIndex = 1; iIndex <= g_iMaxTypes; iIndex++)
	{
		char sName[33];
		Format(sName, sizeof(sName), "Tank %d", iIndex);
		if (kvSuperTanks.JumpToKey(sName))
		{
			kvSuperTanks.GetString("Tank Name", g_sCustomName[iIndex], sizeof(g_sCustomName[]), sName);
			kvSuperTanks.GetString("Tank Character", g_sTankCharacter[iIndex], sizeof(g_sTankCharacter[]), "NULL");
			kvSuperTanks.GetString("Skin-Prop-Glow Colors", g_sTankColors[iIndex], sizeof(g_sTankColors[]), "255,255,255,255|255,255,255,255|255,255,255");
			kvSuperTanks.GetString("Props Attached", g_sPropsAttached[iIndex], sizeof(g_sPropsAttached[]), "1234");
			kvSuperTanks.GetString("Props Chance", g_sPropsChance[iIndex], sizeof(g_sPropsChance[]), "3,3,3,3");
			g_iGlowEffect[iIndex] = kvSuperTanks.GetNum("Glow Effect", 1);
			g_iGlowEffect[iIndex] = iSetCellLimit(g_iGlowEffect[iIndex], 0, 1);
			g_iAcidChance[iIndex] = kvSuperTanks.GetNum("Acid Chance", 4);
			g_iAcidChance[iIndex] = iSetCellLimit(g_iAcidChance[iIndex], 1, 99999);
			g_iAcidHit[iIndex] = kvSuperTanks.GetNum("Acid Claw-Rock", 0);
			g_iAcidHit[iIndex] = iSetCellLimit(g_iAcidHit[iIndex], 0, 1);
			g_iAcidRock[iIndex] = kvSuperTanks.GetNum("Acid Rock Break", 0);
			g_iAcidRock[iIndex] = iSetCellLimit(g_iAcidRock[iIndex], 0, 1);
			g_iAmmoChance[iIndex] = kvSuperTanks.GetNum("Ammo Chance", 4);
			g_iAmmoChance[iIndex] = iSetCellLimit(g_iAmmoChance[iIndex], 1, 99999);
			g_iAmmoCount[iIndex] = kvSuperTanks.GetNum("Ammo Count", 0);
			g_iAmmoCount[iIndex] = iSetCellLimit(g_iAmmoCount[iIndex], 0, 25);
			g_iAmmoHit[iIndex] = kvSuperTanks.GetNum("Ammo Claw-Rock", 0);
			g_iAmmoHit[iIndex] = iSetCellLimit(g_iAmmoHit[iIndex], 0, 1);
			g_iBlindChance[iIndex] = kvSuperTanks.GetNum("Blind Chance", 4);
			g_iBlindChance[iIndex] = iSetCellLimit(g_iBlindChance[iIndex], 1, 99999);
			g_flBlindDuration[iIndex] = kvSuperTanks.GetFloat("Blind Duration", 5.0);
			g_flBlindDuration[iIndex] = flSetFloatLimit(g_flBlindDuration[iIndex], 0.1, 99999.0);
			g_iBlindHit[iIndex] = kvSuperTanks.GetNum("Blind Claw-Rock", 0);
			g_iBlindHit[iIndex] = iSetCellLimit(g_iBlindHit[iIndex], 0, 1);
			g_iBlindIntensity[iIndex] = kvSuperTanks.GetNum("Blind Intensity", 255);
			g_iBlindIntensity[iIndex] = iSetCellLimit(g_iBlindIntensity[iIndex], 0, 255);
			g_iBombChance[iIndex] = kvSuperTanks.GetNum("Bomb Chance", 4);
			g_iBombChance[iIndex] = iSetCellLimit(g_iBombChance[iIndex], 1, 99999);
			g_iBombHit[iIndex] = kvSuperTanks.GetNum("Bomb Claw-Rock", 0);
			g_iBombHit[iIndex] = iSetCellLimit(g_iBombHit[iIndex], 0, 1);
			g_iBoomerThrow[iIndex] = kvSuperTanks.GetNum("Boomer Throw", 0);
			g_iBoomerThrow[iIndex] = iSetCellLimit(g_iBoomerThrow[iIndex], 0, 1);
			g_iChargerThrow[iIndex] = kvSuperTanks.GetNum("Charger Throw", 0);
			g_iChargerThrow[iIndex] = iSetCellLimit(g_iChargerThrow[iIndex], 0, 1);
			g_iCloneThrow[iIndex] = kvSuperTanks.GetNum("Clone Throw", 0);
			g_iCloneThrow[iIndex] = iSetCellLimit(g_iCloneThrow[iIndex], 0, 1);
			g_iCommonAbility[iIndex] = kvSuperTanks.GetNum("Common Ability", 0);
			g_iCommonAbility[iIndex] = iSetCellLimit(g_iCommonAbility[iIndex], 0, 1);
			g_iCommonAmount[iIndex] = kvSuperTanks.GetNum("Common Amount", 10);
			g_iCommonAmount[iIndex] = iSetCellLimit(g_iCommonAmount[iIndex], 1, 100);
			g_iDrugChance[iIndex] = kvSuperTanks.GetNum("Drug Chance", 4);
			g_iDrugChance[iIndex] = iSetCellLimit(g_iDrugChance[iIndex], 1, 99999);
			g_flDrugDuration[iIndex] = kvSuperTanks.GetFloat("Drug Duration", 5.0);
			g_flDrugDuration[iIndex] = flSetFloatLimit(g_flDrugDuration[iIndex], 0.1, 99999.0);
			g_iDrugHit[iIndex] = kvSuperTanks.GetNum("Drug Claw-Rock", 0);
			g_iDrugHit[iIndex] = iSetCellLimit(g_iDrugHit[iIndex], 0, 1);
			g_iExtraHealth[iIndex] = kvSuperTanks.GetNum("Extra Health", 0);
			g_iExtraHealth[iIndex] = iSetCellLimit(g_iExtraHealth[iIndex], 0, 62400);
			g_iFireChance[iIndex] = kvSuperTanks.GetNum("Fire Chance", 4);
			g_iFireChance[iIndex] = iSetCellLimit(g_iFireChance[iIndex], 1, 99999);
			g_iFireHit[iIndex] = kvSuperTanks.GetNum("Fire Claw-Rock", 0);
			g_iFireHit[iIndex] = iSetCellLimit(g_iFireHit[iIndex], 0, 1);
			g_iFireImmunity[iIndex] = kvSuperTanks.GetNum("Fire Immunity", 0);
			g_iFireImmunity[iIndex] = iSetCellLimit(g_iFireImmunity[iIndex], 0, 1);
			g_iFireRock[iIndex] = kvSuperTanks.GetNum("Fire Rock Break", 0);
			g_iFireRock[iIndex] = iSetCellLimit(g_iFireRock[iIndex], 0, 1);
			g_iFlashAbility[iIndex] = kvSuperTanks.GetNum("Flash Ability", 0);
			g_iFlashAbility[iIndex] = iSetCellLimit(g_iFlashAbility[iIndex], 0, 1);
			g_iFlashChance[iIndex] = kvSuperTanks.GetNum("Flash Chance", 4);
			g_iFlashChance[iIndex] = iSetCellLimit(g_iFlashChance[iIndex], 1, 99999);
			g_flFlashSpeed[iIndex] = kvSuperTanks.GetFloat("Flash Speed", 5.0);
			g_flFlashSpeed[iIndex] = flSetFloatLimit(g_flFlashSpeed[iIndex], 3.0, 8.0);
			g_iFlingChance[iIndex] = kvSuperTanks.GetNum("Fling Chance", 4);
			g_iFlingChance[iIndex] = iSetCellLimit(g_iFlingChance[iIndex], 1, 99999);
			g_iFlingHit[iIndex] = kvSuperTanks.GetNum("Fling Claw-Rock", 0);
			g_iFlingHit[iIndex] = iSetCellLimit(g_iFlingHit[iIndex], 0, 1);
			g_iGhostAbility[iIndex] = kvSuperTanks.GetNum("Ghost Ability", 0);
			g_iGhostAbility[iIndex] = iSetCellLimit(g_iGhostAbility[iIndex], 0, 1);
			g_iGhostChance[iIndex] = kvSuperTanks.GetNum("Ghost Chance", 4);
			g_iGhostChance[iIndex] = iSetCellLimit(g_iGhostChance[iIndex], 1, 99999);
			g_iGhostFade[iIndex] = kvSuperTanks.GetNum("Ghost Fade Limit", 255);
			g_iGhostFade[iIndex] = iSetCellLimit(g_iGhostFade[iIndex], 0, 255);
			g_iGhostHit[iIndex] = kvSuperTanks.GetNum("Ghost Claw-Rock", 0);
			g_iGhostHit[iIndex] = iSetCellLimit(g_iGhostHit[iIndex], 0, 1);
			kvSuperTanks.GetString("Ghost Weapon Slots", g_sWeaponSlot[iIndex], sizeof(g_sWeaponSlot[]), "12345");
			g_iGravityAbility[iIndex] = kvSuperTanks.GetNum("Gravity Ability", 0);
			g_iGravityAbility[iIndex] = iSetCellLimit(g_iGravityAbility[iIndex], 0, 1);
			g_iGravityChance[iIndex] = kvSuperTanks.GetNum("Gravity Chance", 4);
			g_iGravityChance[iIndex] = iSetCellLimit(g_iGravityChance[iIndex], 1, 99999);
			g_flGravityDuration[iIndex] = kvSuperTanks.GetFloat("Gravity Duration", 5.0);
			g_flGravityDuration[iIndex] = flSetFloatLimit(g_flGravityDuration[iIndex], 0.1, 99999.0);
			g_flGravityForce[iIndex] = kvSuperTanks.GetFloat("Gravity Force", -50.0);
			g_flGravityForce[iIndex] = flSetFloatLimit(g_flGravityForce[iIndex], -100.0, 100.0);
			g_iGravityHit[iIndex] = kvSuperTanks.GetNum("Gravity Claw-Rock", 0);
			g_iGravityHit[iIndex] = iSetCellLimit(g_iGravityHit[iIndex], 0, 1);
			g_flGravityValue[iIndex] = kvSuperTanks.GetFloat("Gravity Value", 0.3);
			g_flGravityValue[iIndex] = flSetFloatLimit(g_flGravityValue[iIndex], 0.1, 0.99);
			g_iHealAbility[iIndex] = kvSuperTanks.GetNum("Heal Ability", 0);
			g_iHealAbility[iIndex] = iSetCellLimit(g_iHealAbility[iIndex], 0, 1);
			g_iHealChance[iIndex] = kvSuperTanks.GetNum("Heal Chance", 4);
			g_iHealChance[iIndex] = iSetCellLimit(g_iHealChance[iIndex], 1, 99999);
			g_iHealCommon[iIndex] = kvSuperTanks.GetNum("Health From Commons", 50);
			g_iHealCommon[iIndex] = iSetCellLimit(g_iHealCommon[iIndex], 0, 62400);
			g_iHealHit[iIndex] = kvSuperTanks.GetNum("Heal Claw-Rock", 0);
			g_iHealHit[iIndex] = iSetCellLimit(g_iHealHit[iIndex], 0, 1);
			g_flHealInterval[iIndex] = kvSuperTanks.GetFloat("Heal Interval", 5.0);
			g_flHealInterval[iIndex] = flSetFloatLimit(g_flHealInterval[iIndex], 0.1, 99999.0);
			g_iHealSpecial[iIndex] = kvSuperTanks.GetNum("Health From Specials", 100);
			g_iHealSpecial[iIndex] = iSetCellLimit(g_iHealSpecial[iIndex], 0, 62400);
			g_iHealTank[iIndex] = kvSuperTanks.GetNum("Health From Tanks", 500);
			g_iHealTank[iIndex] = iSetCellLimit(g_iHealTank[iIndex], 0, 62400);
			g_iHunterThrow[iIndex] = kvSuperTanks.GetNum("Hunter Throw", 0);
			g_iHunterThrow[iIndex] = iSetCellLimit(g_iHunterThrow[iIndex], 0, 1);
			g_iHurtAbility[iIndex] = kvSuperTanks.GetNum("Hurt Ability", 0);
			g_iHurtAbility[iIndex] = iSetCellLimit(g_iHurtAbility[iIndex], 0, 1);
			g_iHurtChance[iIndex] = kvSuperTanks.GetNum("Hurt Chance", 4);
			g_iHurtChance[iIndex] = iSetCellLimit(g_iHurtChance[iIndex], 1, 99999);
			g_iHurtDamage[iIndex] = kvSuperTanks.GetNum("Hurt Damage", 1);
			g_iHurtDamage[iIndex] = iSetCellLimit(g_iHurtDamage[iIndex], 1, 99999);
			g_flHurtDuration[iIndex] = kvSuperTanks.GetFloat("Hurt Duration", 5.0);
			g_flHurtDuration[iIndex] = flSetFloatLimit(g_flHurtDuration[iIndex], 0.1, 99999.0);
			g_iHypnoChance[iIndex] = kvSuperTanks.GetNum("Hypno Chance", 4);
			g_iHypnoChance[iIndex] = iSetCellLimit(g_iHypnoChance[iIndex], 1, 99999);
			g_flHypnoDuration[iIndex] = kvSuperTanks.GetFloat("Hypno Duration", 5.0);
			g_flHypnoDuration[iIndex] = flSetFloatLimit(g_flHypnoDuration[iIndex], 0.1, 99999.0);
			g_iHypnoHit[iIndex] = kvSuperTanks.GetNum("Hypno Claw-Rock", 0);
			g_iHypnoHit[iIndex] = iSetCellLimit(g_iHypnoHit[iIndex], 0, 1);
			g_iIceChance[iIndex] = kvSuperTanks.GetNum("Ice Chance", 4);
			g_iIceChance[iIndex] = iSetCellLimit(g_iIceChance[iIndex], 1, 99999);
			g_iIceHit[iIndex] = kvSuperTanks.GetNum("Ice Claw-Rock", 0);
			g_iIceHit[iIndex] = iSetCellLimit(g_iIceHit[iIndex], 0, 1);
			g_iIdleChance[iIndex] = kvSuperTanks.GetNum("Idle Chance", 4);
			g_iIdleChance[iIndex] = iSetCellLimit(g_iIdleChance[iIndex], 1, 99999);
			g_iIdleHit[iIndex] = kvSuperTanks.GetNum("Idle Claw-Rock", 0);
			g_iIdleHit[iIndex] = iSetCellLimit(g_iIdleHit[iIndex], 0, 1);
			g_iInfectedThrow[iIndex] = kvSuperTanks.GetNum("Infected Throw Ability", 0);
			g_iInfectedThrow[iIndex] = iSetCellLimit(g_iInfectedThrow[iIndex], 0, 1);
			g_iInvertChance[iIndex] = kvSuperTanks.GetNum("Invert Chance", 4);
			g_iInvertChance[iIndex] = iSetCellLimit(g_iInvertChance[iIndex], 1, 99999);
			g_flInvertDuration[iIndex] = kvSuperTanks.GetFloat("Invert Duration", 5.0);
			g_flInvertDuration[iIndex] = flSetFloatLimit(g_flInvertDuration[iIndex], 0.1, 99999.0);
			g_iInvertHit[iIndex] = kvSuperTanks.GetNum("Invert Claw-Rock", 0);
			g_iInvertHit[iIndex] = iSetCellLimit(g_iInvertHit[iIndex], 0, 1);
			g_iJockeyThrow[iIndex] = kvSuperTanks.GetNum("Jockey Throw", 0);
			g_iJockeyThrow[iIndex] = iSetCellLimit(g_iJockeyThrow[iIndex], 0, 1);
			g_iJumperAbility[iIndex] = kvSuperTanks.GetNum("Jump Ability", 0);
			g_iJumperAbility[iIndex] = iSetCellLimit(g_iJumperAbility[iIndex], 0, 1);
			g_iJumperChance[iIndex] = kvSuperTanks.GetNum("Jump Chance", 4);
			g_iJumperChance[iIndex] = iSetCellLimit(g_iJumperChance[iIndex], 1, 99999);
			g_iMeteorAbility[iIndex] = kvSuperTanks.GetNum("Meteor Ability", 0);
			g_iMeteorAbility[iIndex] = iSetCellLimit(g_iMeteorAbility[iIndex], 0, 1);
			g_iMeteorChance[iIndex] = kvSuperTanks.GetNum("Meteor Chance", 4);
			g_iMeteorChance[iIndex] = iSetCellLimit(g_iMeteorChance[iIndex], 1, 99999);
			g_flMeteorDamage[iIndex] = kvSuperTanks.GetFloat("Meteor Damage", 25.0);
			g_flMeteorDamage[iIndex] = flSetFloatLimit(g_flMeteorDamage[iIndex], 1.0, 99999.0);
			g_iPukeChance[iIndex] = kvSuperTanks.GetNum("Puke Chance", 4);
			g_iPukeChance[iIndex] = iSetCellLimit(g_iPukeChance[iIndex], 1, 99999);
			g_iPukeHit[iIndex] = kvSuperTanks.GetNum("Puke Claw-Rock", 0);
			g_iPukeHit[iIndex] = iSetCellLimit(g_iPukeHit[iIndex], 0, 1);
			g_iRestartChance[iIndex] = kvSuperTanks.GetNum("Restart Chance", 4);
			g_iRestartChance[iIndex] = iSetCellLimit(g_iRestartChance[iIndex], 1, 99999);
			g_iRestartHit[iIndex] = kvSuperTanks.GetNum("Restart Claw-Rock", 0);
			g_iRestartHit[iIndex] = iSetCellLimit(g_iRestartHit[iIndex], 0, 1);
			kvSuperTanks.GetString("Restart Loadout", g_sLoadout[iIndex], sizeof(g_sLoadout[]), "smg,pistol,pain_pills");
			g_iRocketChance[iIndex] = kvSuperTanks.GetNum("Rocket Chance", 4);
			g_iRocketChance[iIndex] = iSetCellLimit(g_iRocketChance[iIndex], 1, 99999);
			g_iRocketHit[iIndex] = kvSuperTanks.GetNum("Rocket Claw-Rock", 0);
			g_iRocketHit[iIndex] = iSetCellLimit(g_iRocketHit[iIndex], 0, 1);
			g_flRunSpeed[iIndex] = kvSuperTanks.GetFloat("Run Speed", 1.0);
			g_flRunSpeed[iIndex] = flSetFloatLimit(g_flRunSpeed[iIndex], 0.1, 3.0);
			g_iShakeChance[iIndex] = kvSuperTanks.GetNum("Shake Chance", 4);
			g_iShakeChance[iIndex] = iSetCellLimit(g_iShakeChance[iIndex], 1, 99999);
			g_flShakeDuration[iIndex] = kvSuperTanks.GetFloat("Shake Duration", 5.0);
			g_flShakeDuration[iIndex] = flSetFloatLimit(g_flShakeDuration[iIndex], 0.1, 99999.0);
			g_iShakeHit[iIndex] = kvSuperTanks.GetNum("Shake Claw-Rock", 0);
			g_iShakeHit[iIndex] = iSetCellLimit(g_iShakeHit[iIndex], 0, 1);
			g_iShieldAbility[iIndex] = kvSuperTanks.GetNum("Shield Ability", 0);
			g_iShieldAbility[iIndex] = iSetCellLimit(g_iShieldAbility[iIndex], 0, 1);
			kvSuperTanks.GetString("Shield Color", g_sShieldColor[iIndex], sizeof(g_sShieldColor[]), "255,255,255");
			g_flShieldDelay[iIndex] = kvSuperTanks.GetFloat("Shield Delay", 5.0);
			g_flShieldDelay[iIndex] = flSetFloatLimit(g_flShieldDelay[iIndex], 1.0, 99999.0);
			g_iShoveChance[iIndex] = kvSuperTanks.GetNum("Shove Chance", 4);
			g_iShoveChance[iIndex] = iSetCellLimit(g_iShoveChance[iIndex], 1, 99999);
			g_flShoveDuration[iIndex] = kvSuperTanks.GetFloat("Shove Duration", 5.0);
			g_flShoveDuration[iIndex] = flSetFloatLimit(g_flShoveDuration[iIndex], 0.1, 99999.0);
			g_iShoveHit[iIndex] = kvSuperTanks.GetNum("Shove Claw-Rock", 0);
			g_iShoveHit[iIndex] = iSetCellLimit(g_iShoveHit[iIndex], 0, 1);
			g_iSlugChance[iIndex] = kvSuperTanks.GetNum("Slug Chance", 4);
			g_iSlugChance[iIndex] = iSetCellLimit(g_iSlugChance[iIndex], 1, 99999);
			g_iSlugHit[iIndex] = kvSuperTanks.GetNum("Slug Claw-Rock", 0);
			g_iSlugHit[iIndex] = iSetCellLimit(g_iSlugHit[iIndex], 0, 1);
			g_iSmokeEffect[iIndex] = kvSuperTanks.GetNum("Smoke Effect", 0);
			g_iSmokeEffect[iIndex] = iSetCellLimit(g_iSmokeEffect[iIndex], 0, 1);
			g_iSmokerThrow[iIndex] = kvSuperTanks.GetNum("Smoker Throw", 0);
			g_iSmokerThrow[iIndex] = iSetCellLimit(g_iSmokerThrow[iIndex], 0, 1);
			g_iSpamAbility[iIndex] = kvSuperTanks.GetNum("Spam Ability", 0);
			g_iSpamAbility[iIndex] = iSetCellLimit(g_iSpamAbility[iIndex], 0, 1);
			g_iSpamAmount[iIndex] = kvSuperTanks.GetNum("Spam Amount", 5);
			g_iSpamAmount[iIndex] = iSetCellLimit(g_iSpamAmount[iIndex], 1, 99999);
			g_iSpamDamage[iIndex] = kvSuperTanks.GetNum("Spam Damage", 5);
			g_iSpamDamage[iIndex] = iSetCellLimit(g_iSpamDamage[iIndex], 1, 99999);
			g_flSpamInterval[iIndex] = kvSuperTanks.GetFloat("Spam Interval", 5.0);
			g_flSpamInterval[iIndex] = flSetFloatLimit(g_flSpamInterval[iIndex], 0.1, 99999.0);
			g_iSpitterThrow[iIndex] = kvSuperTanks.GetNum("Spitter Throw", 0);
			g_iSpitterThrow[iIndex] = iSetCellLimit(g_iSpitterThrow[iIndex], 0, 1);
			g_iStunChance[iIndex] = kvSuperTanks.GetNum("Stun Chance", 4);
			g_iStunChance[iIndex] = iSetCellLimit(g_iStunChance[iIndex], 1, 99999);
			g_flStunDuration[iIndex] = kvSuperTanks.GetFloat("Stun Duration", 5.0);
			g_flStunDuration[iIndex] = flSetFloatLimit(g_flStunDuration[iIndex], 0.1, 99999.0);
			g_iStunHit[iIndex] = kvSuperTanks.GetNum("Stun Claw-Rock", 0);
			g_iStunHit[iIndex] = iSetCellLimit(g_iStunHit[iIndex], 0, 1);
			g_flStunSpeed[iIndex] = kvSuperTanks.GetFloat("Stun Speed", 0.25);
			g_flStunSpeed[iIndex] = flSetFloatLimit(g_flStunSpeed[iIndex], 0.1, 0.9);
			g_flThrowInterval[iIndex] = kvSuperTanks.GetFloat("Throw Interval", 5.0);
			g_flThrowInterval[iIndex] = flSetFloatLimit(g_flThrowInterval[iIndex], 0.1, 99999.0);
			g_iVisionChance[iIndex] = kvSuperTanks.GetNum("Vision Chance", 4);
			g_iVisionChance[iIndex] = iSetCellLimit(g_iVisionChance[iIndex], 1, 99999);
			g_flVisionDuration[iIndex] = kvSuperTanks.GetFloat("Vision Duration", 5.0);
			g_flVisionDuration[iIndex] = flSetFloatLimit(g_flVisionDuration[iIndex], 0.1, 99999.0);
			g_iVisionFOV[iIndex] = kvSuperTanks.GetNum("Vision FOV", 160);
			g_iVisionFOV[iIndex] = iSetCellLimit(g_iVisionHit[iIndex], 1, 160);
			g_iVisionHit[iIndex] = kvSuperTanks.GetNum("Vision Claw-Rock", 0);
			g_iVisionHit[iIndex] = iSetCellLimit(g_iVisionHit[iIndex], 0, 1);
			g_iWarpAbility[iIndex] = kvSuperTanks.GetNum("Warp Ability", 0);
			g_iWarpAbility[iIndex] = iSetCellLimit(g_iWarpAbility[iIndex], 0, 1);
			g_iWarpInterval[iIndex] = kvSuperTanks.GetNum("Warp Interval", 5);
			g_iWarpInterval[iIndex] = iSetCellLimit(g_iWarpInterval[iIndex], 0, 99999);
			g_iWitchAbility[iIndex] = kvSuperTanks.GetNum("Witch Ability", 0);
			g_iWitchAbility[iIndex] = iSetCellLimit(g_iWitchAbility[iIndex], 0, 1);
			g_iWitchAmount[iIndex] = kvSuperTanks.GetNum("Witch Amount", 3);
			g_iWitchAmount[iIndex] = iSetCellLimit(g_iWitchAmount[iIndex], 1, 25);
			g_flWitchDamage[iIndex] = kvSuperTanks.GetFloat("Witch Minion Damage", 10.0);
			g_flWitchDamage[iIndex] = flSetFloatLimit(g_flWitchDamage[iIndex], 1.0, 99999.0);
			kvSuperTanks.Rewind();
		}
	}
	delete kvSuperTanks;
}

void vAcidHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iAcidChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client) && bIsL4D2Game())
	{
		float flOrigin[3];
		float flAngles[3];
		GetClientAbsOrigin(client, flOrigin);
		GetClientAbsAngles(client, flAngles);
		SDKCall(g_hSDKAcidPlayer, flOrigin, flAngles, flAngles, flAngles, owner, 2.0);
	}
}

void vAcidRock(int entity, int client, int enabled)
{
	if (bIsL4D2Game() && enabled)
	{
		float flVector[3];
		float flAngles[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flVector);
		flVector[2] += 40.0;
		SDKCall(g_hSDKAcidPlayer, flVector, flAngles, flAngles, flAngles, client, 2.0);
	}
}

void vAmmoHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iAmmoChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client) && GetPlayerWeaponSlot(client, 0) > 0)
	{
		char sWeapon[32];
		int iActiveWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		GetEntityClassname(iActiveWeapon, sWeapon, sizeof(sWeapon));
		if (IsValidEntity(iActiveWeapon))
		{
			if (strcmp(sWeapon, "weapon_rifle") == 0 || strcmp(sWeapon, "weapon_rifle_desert") == 0 || strcmp(sWeapon, "weapon_rifle_ak47") == 0 || strcmp(sWeapon, "weapon_rifle_sg552") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", g_iAmmoCount[g_iTankType[owner]], _, 3);
			}
			else if (strcmp(sWeapon, "weapon_smg") == 0 || strcmp(sWeapon, "weapon_smg_silenced") == 0 || strcmp(sWeapon, "weapon_smg_mp5") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", g_iAmmoCount[g_iTankType[owner]], _, 5);
			}
			else if (strcmp(sWeapon, "weapon_pumpshotgun") == 0)
			{
				bIsL4D2Game() ? SetEntProp(client, Prop_Data, "m_iAmmo", g_iAmmoCount[g_iTankType[owner]], _, 7) : SetEntProp(client, Prop_Data, "m_iAmmo", g_iAmmoCount[g_iTankType[owner]], _, 6);
			}
			else if (strcmp(sWeapon, "weapon_shotgun_chrome") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", g_iAmmoCount[g_iTankType[owner]], _, 7);
			}
			else if (strcmp(sWeapon, "weapon_autoshotgun") == 0)
			{
				bIsL4D2Game() ? SetEntProp(client, Prop_Data, "m_iAmmo", g_iAmmoCount[g_iTankType[owner]], _, 8) : SetEntProp(client, Prop_Data, "m_iAmmo", g_iAmmoCount[g_iTankType[owner]], _, 6);
			}
			else if (strcmp(sWeapon, "weapon_shotgun_spas") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", g_iAmmoCount[g_iTankType[owner]], _, 8);
			}
			else if (strcmp(sWeapon, "weapon_hunting_rifle") == 0)
			{
				bIsL4D2Game() ? SetEntProp(client, Prop_Data, "m_iAmmo", g_iAmmoCount[g_iTankType[owner]], _, 9) : SetEntProp(client, Prop_Data, "m_iAmmo", g_iAmmoCount[g_iTankType[owner]], _, 2);
			}
			else if (strcmp(sWeapon, "weapon_sniper_scout") == 0 || strcmp(sWeapon, "weapon_sniper_military") == 0 || strcmp(sWeapon, "weapon_sniper_awp") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", g_iAmmoCount[g_iTankType[owner]], _, 10);
			}
			else if (strcmp(sWeapon, "weapon_grenade_launcher") == 0)
			{
				SetEntProp(client, Prop_Data, "m_iAmmo", g_iAmmoCount[g_iTankType[owner]], _, 17);
			}
		}
		SetEntProp(GetPlayerWeaponSlot(client, 0), Prop_Data, "m_iClip1", g_iAmmoCount[g_iTankType[owner]], 1);
	}
}

void vApplyBlindness(int client, int amount)
{
	int iTargets[2];
	iTargets[0] = client;
	int iFlags;
	if (bIsSurvivor(client))
	{
		amount == 0 ? (iFlags = (0x0001|0x0010)) : (iFlags = (0x0002|0x0008));
		int iColor[4] = {0, 0, 0, 0};
		iColor[3] = amount;
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
}

void vBlindHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iBlindChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		if (!g_bBlind[client])
		{
			g_bBlind[client] = true;
			vApplyBlindness(client, g_iBlindIntensity[g_iTankType[owner]]);
			CreateTimer(g_flBlindDuration[g_iTankType[owner]], tTimerStopBlindness, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

void vBombHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iBombChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		float flPosition[3];
		GetClientAbsOrigin(client, flPosition);
		int iParticle = CreateEntityByName("info_particle_system");
		int iParticle2 = CreateEntityByName("info_particle_system");
		int iParticle3 = CreateEntityByName("info_particle_system");
		int iTrace = CreateEntityByName("info_particle_system");
		int iPhysics = CreateEntityByName("env_physexplosion");
		int iHurt = CreateEntityByName("point_hurt");
		int iEntity = CreateEntityByName("env_explosion");
		DispatchKeyValue(iParticle, "effect_name", "FluidExplosion_fps");
		TeleportEntity(iParticle, flPosition, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iParticle);
		ActivateEntity(iParticle);
		DispatchKeyValue(iParticle2, "effect_name", "weapon_grenade_explosion");
		TeleportEntity(iParticle2, flPosition, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iParticle2);
		ActivateEntity(iParticle2);
		DispatchKeyValue(iParticle3, "effect_name", "explosion_huge_b");
		TeleportEntity(iParticle3, flPosition, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iParticle3);
		ActivateEntity(iParticle3);
		DispatchKeyValue(iTrace, "effect_name", "gas_explosion_ground_fire");
		TeleportEntity(iTrace, flPosition, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iTrace);
		ActivateEntity(iTrace);
		SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", owner);
		DispatchKeyValue(iEntity, "fireballsprite", "sprites/muzzleflash4.vmt");
		DispatchKeyValue(iEntity, "iMagnitude", "150");
		DispatchKeyValue(iEntity, "iRadiusOverride", "150");
		DispatchKeyValue(iEntity, "spawnflags", "828");
		TeleportEntity(iEntity, flPosition, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iEntity);
		SetEntPropEnt(iPhysics, Prop_Send, "m_hOwnerEntity", owner);
		DispatchKeyValue(iPhysics, "radius", "150");
		DispatchKeyValue(iPhysics, "magnitude", "150");
		TeleportEntity(iPhysics, flPosition, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iPhysics);
		SetEntPropEnt(iHurt, Prop_Send, "m_hOwnerEntity", owner);
		DispatchKeyValue(iHurt, "DamageRadius", "150");
		DispatchKeyValue(iHurt, "DamageDelay", "0.5");
		DispatchKeyValue(iHurt, "Damage", "5");
		DispatchKeyValue(iHurt, "DamageType", "8");
		TeleportEntity(iHurt, flPosition, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iHurt);
		switch (GetRandomInt(1, 3))
		{
			case 1: EmitSoundToAll(SOUND_EXPLOSION2, client);
			case 2: EmitSoundToAll(SOUND_EXPLOSION3, client);
			case 3: EmitSoundToAll(SOUND_EXPLOSION4, client);
		}
		EmitSoundToAll(ANIMATION_DEBRIS, client);
		AcceptEntityInput(iParticle, "Start");
		AcceptEntityInput(iParticle2, "Start");
		AcceptEntityInput(iParticle3, "Start");
		AcceptEntityInput(iTrace, "Start");
		AcceptEntityInput(iEntity, "Explode");
		AcceptEntityInput(iPhysics, "Explode");
		AcceptEntityInput(iHurt, "TurnOn");
		iParticle = EntIndexToEntRef(iParticle);
		vDeleteEntity(iParticle, 16.5);
		iParticle2 = EntIndexToEntRef(iParticle2);
		vDeleteEntity(iParticle2, 16.5);
		iParticle3 = EntIndexToEntRef(iParticle3);
		vDeleteEntity(iParticle3, 16.5);
		iTrace = EntIndexToEntRef(iTrace);
		vDeleteEntity(iTrace, 16.5);
		vDeleteExplosion(iTrace, 15.0, "Stop");
		iEntity = EntIndexToEntRef(iEntity);
		vDeleteEntity(iEntity, 16.5);
		iPhysics = EntIndexToEntRef(iPhysics);
		vDeleteEntity(iPhysics, 16.5);
		iHurt = EntIndexToEntRef(iHurt);
		vDeleteEntity(iHurt, 16.5);
		vDeleteExplosion(iHurt, 15.0, "TurnOff");
	}
}

void vCommonAbility(int client, int enabled)
{
	if (enabled == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		g_iSpawnInterval[client]++;
		if (g_iSpawnInterval[client] >= g_iCommonAmount[g_iTankType[client]])
		{
			for (int iCommon = 1; iCommon <= g_iCommonAmount[g_iTankType[client]]; iCommon++)
			{
				bIsL4D2Game() ? vCheatCommand(client, "z_spawn_old", "zombie area") : vCheatCommand(client, "z_spawn", "zombie area");
			}
			g_iSpawnInterval[client] = 0;
		}
	}
}

void vCreateConfigFile(const char[] filepath, const char[] folder, const char[] filename, const char[] label = "")
{
	char sConfigFilename[128];
	char sConfigLabel[128];
	File fFilename;
	Format(sConfigFilename, sizeof(sConfigFilename), "%s%s%s.cfg", filepath, folder, filename);
	if (FileExists(sConfigFilename))
	{
		return;
	}
	fFilename = OpenFile(sConfigFilename, "w+");
	strlen(label) > 0 ? strcopy(sConfigLabel, sizeof(sConfigLabel), label) : strcopy(sConfigLabel, sizeof(sConfigLabel), sConfigFilename);
	if (fFilename != null)
	{
		fFilename.WriteLine("// This config file was auto-generated by Super Tanks++ v%s (%s)", ST_VERSION, ST_URL);
		fFilename.WriteLine("");
		fFilename.WriteLine("");
		delete fFilename;
	}
}

void vCreateParticle(int client, char[] particlename, float time, float origin)
{
	if (client > 0)
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (IsValidEntity(iParticle))
		{
			float flPos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPos);
			flPos[2] += origin;
			DispatchKeyValue(iParticle, "effect_name", particlename);
			TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iParticle);
			ActivateEntity(iParticle);
			AcceptEntityInput(iParticle, "start");
			SetVariantString("!activator");
			AcceptEntityInput(iParticle, "SetParent", client);
			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, time);
		}
	}
}

void vDropWeapon(int client, int slot)
{
	if (bIsSurvivor(client) && GetPlayerWeaponSlot(client, slot) > 0)
	{
		SDKHooks_DropWeapon(client, GetPlayerWeaponSlot(client, slot), NULL_VECTOR, NULL_VECTOR);
	}
}

void vDrugHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iDrugChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		if (g_hDrugTimer[client] == null)
		{
			g_hDrugTimer[client] = CreateTimer(1.0, tTimerDrug, GetClientUserId(client), TIMER_REPEAT);
			CreateTimer(g_flDrugDuration[g_iTankType[owner]], tTimerStopDrug, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

void vFakeJump(int client, int enabled)
{
	if (enabled == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		float flVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", flVelocity);
		if (flVelocity[0] > 0.0 && flVelocity[0] < 500.0)
		{
			flVelocity[0] += 500.0;
		}
		else if (flVelocity[0] < 0.0 && flVelocity[0] > -500.0)
		{
			flVelocity[0] += -500.0;
		}
		if (flVelocity[1] > 0.0 && flVelocity[1] < 500.0)
		{
			flVelocity[1] += 500.0;
		}
		else if (flVelocity[1] < 0.0 && flVelocity[1] > -500.0)
		{
			flVelocity[1] += -500.0;
		}
		flVelocity[2] += 750.0;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, flVelocity);
	}
}

void vFireHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iFireChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		int iEntity = CreateEntityByName("prop_physics");
		if (IsValidEntity(iEntity))
		{
			DispatchKeyValue(iEntity, "disableshadows", "1");
			SetEntityModel(iEntity, MODEL_GASCAN);
			float flPos[3];
			GetClientAbsOrigin(client, flPos);
			flPos[2] += 10.0;
			TeleportEntity(iEntity, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iEntity);
			SetEntPropEnt(iEntity, Prop_Data, "m_hPhysicsAttacker", owner);
			SetEntPropFloat(iEntity, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());
			SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 1);
			SetEntityRenderMode(iEntity, RENDER_TRANSCOLOR);
			SetEntityRenderColor(iEntity, 0, 0, 0, 0);
			AcceptEntityInput(iEntity, "Break");
		}
	}
}

void vFireRock(int entity, int client, int enabled)
{
	if (enabled)
	{
		int iProp = CreateEntityByName("prop_physics");
		if (IsValidEntity(iProp))
		{
			DispatchKeyValue(iProp, "disableshadows", "1");
			SetEntityModel(iProp, MODEL_GASCAN);
			float flPos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPos);
			flPos[2] += 10.0;
			TeleportEntity(iProp, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iProp);
			SetEntPropEnt(iProp, Prop_Data, "m_hPhysicsAttacker", client);
			SetEntPropFloat(iProp, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());
			SetEntProp(iProp, Prop_Send, "m_CollisionGroup", 1);
			SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
			SetEntityRenderColor(entity, 0, 0, 0, 0);
			AcceptEntityInput(iProp, "Break");
		}
	}
}

void vFlashAbility(int client, int enabled)
{
	if (enabled == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		if (!g_bFlash[client])
		{
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
			if (GetRandomInt(1, g_iFlashChance[g_iTankType[client]]) == 1)
			{
				g_bFlash[client] = true;
				if (g_hFlashTimer[client] == null)
				{
					g_hFlashTimer[client] = CreateTimer(0.25, tTimerFlashEffect, GetClientUserId(client), TIMER_REPEAT);
				}
			}
		}
		else
		{
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", g_flFlashSpeed[g_iTankType[client]]);
		}
	}
}

void vFlingHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iFlingChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client) && bIsL4D2Game())
	{
		float flTpos[3];
		float flSpos[3];
		float flDistance[3];
		float flRatio[3];
		float flAddVel[3];
		float flTvec[3];
		GetClientAbsOrigin(client, flTpos);
		GetClientAbsOrigin(owner, flSpos);
		flDistance[0] = (flSpos[0] - flTpos[0]);
		flDistance[1] = (flSpos[1] - flTpos[1]);
		flDistance[2] = (flSpos[2] - flTpos[2]);
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", flTvec);
		flRatio[0] =  FloatDiv(flDistance[0], SquareRoot(flDistance[1] * flDistance[1] + flDistance[0] * flDistance[0]));
		flRatio[1] =  FloatDiv(flDistance[1], SquareRoot(flDistance[1] * flDistance[1] + flDistance[0] * flDistance[0]));
		flAddVel[0] = FloatMul(flRatio[0] * -1, 500.0);
		flAddVel[1] = FloatMul(flRatio[1] * -1, 500.0);
		flAddVel[2] = 500.0;
		SDKCall(g_hSDKFlingPlayer, client, flAddVel, 76, owner, 7.0);
	}
}

void vGhostAbility(int client, int enabled)
{
	char sSet[3][12];
	ExplodeString(g_sTankColors[g_iTankType[client]], "|", sSet, sizeof(sSet), sizeof(sSet[]));
	char sRGB[4][4];
	ExplodeString(sSet[0], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
	int iRed = StringToInt(sRGB[0]);
	int iGreen = StringToInt(sRGB[1]);
	int iBlue = StringToInt(sRGB[2]);
	char sProps[4][4];
	ExplodeString(sSet[1], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
	int iRed2 = StringToInt(sProps[0]);
	int iGreen2 = StringToInt(sProps[1]);
	int iBlue2 = StringToInt(sProps[2]);
	if (enabled == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
		{
			if (bIsSpecialInfected(iInfected))
			{
				float flTankPos[3];
				float flInfectedPos[3];
				GetClientAbsOrigin(client, flTankPos);
				GetClientAbsOrigin(iInfected, flInfectedPos);
				float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
				if (flDistance < 500.0)
				{
					SetEntityRenderMode(iInfected, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iInfected, 255, 255, 255, 50);
				}
				else
				{
					SetEntityRenderMode(iInfected, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iInfected, 255, 255, 255, 255);
				}
			}
		}
		if (!g_bGhost[client])
		{
			g_iAlpha[client] = 255;
			g_bGhost[client] = true;
			DataPack dpDataPack;
			CreateDataTimer(0.1, tTimerGhost, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpDataPack.WriteCell(GetClientUserId(client));
			dpDataPack.WriteCell(iRed);
			dpDataPack.WriteCell(iGreen);
			dpDataPack.WriteCell(iBlue);
			dpDataPack.WriteCell(iRed2);
			dpDataPack.WriteCell(iGreen2);
			dpDataPack.WriteCell(iBlue2);
			SetEntityRenderMode(client, RENDER_TRANSCOLOR);
		}
	}
}

void vGhostHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iGhostChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client) && bIsTank(owner) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(owner))))
	{
		if (StrContains(g_sWeaponSlot[g_iTankType[owner]], "1") != -1)
		{
			vDropWeapon(client, 0);
		}
		if (StrContains(g_sWeaponSlot[g_iTankType[owner]], "2") != -1)
		{
			vDropWeapon(client, 1);
		}
		if (StrContains(g_sWeaponSlot[g_iTankType[owner]], "3") != -1)
		{
			vDropWeapon(client, 2);
		}
		if (StrContains(g_sWeaponSlot[g_iTankType[owner]], "4") != -1)
		{
			vDropWeapon(client, 3);
		}
		if (StrContains(g_sWeaponSlot[g_iTankType[owner]], "5") != -1)
		{
			vDropWeapon(client, 4);
		}
		EmitSoundToClient(client, SOUND_INFECTED, owner);
	}
}

void vGravityAbility(int client, int enabled)
{
	if (enabled == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		int iBlackhole = CreateEntityByName("point_push");
		if (IsValidEntity(iBlackhole))
		{
			float flOrigin[3];
			float flAngles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
			flAngles[0] += -90.0;
			DispatchKeyValueVector(iBlackhole, "origin", flOrigin);
			DispatchKeyValueVector(iBlackhole, "angles", flAngles);
			DispatchKeyValue(iBlackhole, "radius", "750");
			DispatchKeyValueFloat(iBlackhole, "magnitude", g_flGravityForce[g_iTankType[client]]);
			DispatchKeyValue(iBlackhole, "spawnflags", "8");
			SetVariantString("!activator");
			AcceptEntityInput(iBlackhole, "SetParent", client);
			AcceptEntityInput(iBlackhole, "Enable");
			SetEntPropEnt(iBlackhole, Prop_Send, "m_hOwnerEntity", client);
			if (bIsL4D2Game())
			{
				SetEntProp(iBlackhole, Prop_Send, "m_glowColorOverride", client);
			}
		}
	}
}

void vGravityHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iGravityChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		if (!g_bGravity[client])
		{
			g_bGravity[client] = true;
			SetEntityGravity(client, g_flGravityValue[g_iTankType[owner]]);
			CreateTimer(g_flGravityDuration[g_iTankType[owner]], tTimerStopGravity, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

void vHealAbility(int client, int enabled)
{
	if (enabled == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		if (g_hHealTimer[client] == null)
		{
			g_hHealTimer[client] = CreateTimer(g_flHealInterval[g_iTankType[client]], tTimerHeal, GetClientUserId(client), TIMER_REPEAT);
		}
	}
}

void vHealHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iHealChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		SetEntProp(client, Prop_Send, "m_currentReviveCount", g_cvSTFindConVar[3].IntValue - 1);
		SetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
		SDKCall(g_hSDKRevivePlayer, client);
		SetEntityHealth(client, 1);
		SDKCall(g_hSDKHealPlayer, client, 50.0);
	}
}

void vHurtHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iHurtChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		if (!g_bHurt[client])
		{
			g_bHurt[client] = true;
			DataPack dpDataPack;
			CreateDataTimer(1.0, tTimerHurt, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpDataPack.WriteCell(GetClientUserId(client));
			dpDataPack.WriteCell(GetClientUserId(owner));
			dpDataPack.WriteFloat(GetEngineTime());
		}
	}
}

void vHypnoHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iHypnoChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		if (!g_bHypno[client])
		{
			g_bHypno[client] = true;
			CreateTimer(g_flHypnoDuration[g_iTankType[owner]], tTimerStopHypnosis, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

void vIceHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iIceChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		if (!g_bIce[client])
		{
			g_bIce[client] = true;
			GetClientEyePosition(client, g_flIce);
			if (GetEntityMoveType(client) != MOVETYPE_NONE)
			{
				SetEntityMoveType(client, MOVETYPE_NONE);
				SetEntityRenderColor(client, 0, 130, 255, 190);
				EmitAmbientSound(PHYSICS_BULLET, g_flIce, client, SNDLEVEL_RAIDSIREN);
			}
			CreateTimer(5.0, tTimerStopIce, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

void vIdleHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iIdleChance[g_iTankType[owner]]) == 1 && bIsHumanSurvivor(client))
	{
		if (!g_bIdle[client])
		{
			if (iGetHumanCount() > 1)
			{
				FakeClientCommand(client, "go_away_from_keyboard");
			}
			else
			{
				vIdleWarp(client);
				SDKCall(g_hSDKIdlePlayer, client);
			}
			if (bIsBotIdle(client))
			{
				g_bAFK[client] = true;
				g_bIdle[client] = true;
			}
		}
	}
}

void vIdleWarp(int client)
{
	float flCurrentOrigin[3] = {0.0, 0.0, 0.0};
	for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
	{
		if (!bIsSurvivor(iPlayer) || iPlayer == client)
		{
			continue;
		}
		GetClientAbsOrigin(iPlayer, flCurrentOrigin);
		TeleportEntity(client, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);
	}
}

void vInvertHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iInvertChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		if (!g_bInvert[client])
		{
			g_bInvert[client] = true;
			CreateTimer(g_flInvertDuration[g_iTankType[owner]], tTimerStopInversion, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

void vJumperAbility(int client, int enabled)
{
	if (enabled == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		CreateTimer(1.0, tTimerJump, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
}

void vMeteor(int entity, int client)
{
	if (IsValidEntity(entity))
	{
		char sClassname[16];
		GetEntityClassname(entity, sClassname, sizeof(sClassname));
		if (strcmp(sClassname, "tank_rock") == 0)
		{
			AcceptEntityInput(entity, "Kill");
			int iEntity = CreateEntityByName("prop_physics");
			SetEntityModel(iEntity, MODEL_PROPANETANK);
			float flPos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPos);
			flPos[2] += 50.0;
			TeleportEntity(iEntity, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iEntity);
			ActivateEntity(iEntity);
			SetEntPropEnt(iEntity, Prop_Data, "m_hPhysicsAttacker", client);
			SetEntPropFloat(iEntity, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());
			SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 1);
			SetEntityRenderMode(iEntity, RENDER_TRANSCOLOR);
			SetEntityRenderColor(iEntity, 0, 0, 0, 0);
			AcceptEntityInput(iEntity, "Break");
			int iPointHurt = CreateEntityByName("point_hurt");
			SetEntPropEnt(iPointHurt, Prop_Send, "m_hOwnerEntity", client);
			DispatchKeyValueFloat(iPointHurt, "Damage", g_flMeteorDamage[g_iTankType[client]]);
			DispatchKeyValue(iPointHurt, "DamageType", "2");
			DispatchKeyValue(iPointHurt, "DamageDelay", "0.0");
			DispatchKeyValueFloat(iPointHurt, "DamageRadius", 200.0);
			TeleportEntity(iPointHurt, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iPointHurt);
			if (IsValidEntity(client) && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
			{
				AcceptEntityInput(iPointHurt, "Hurt", client);
			}
			iPointHurt = EntIndexToEntRef(iPointHurt);
			vDeleteEntity(iPointHurt, 0.1);
			int iPointPush = CreateEntityByName("point_push");
			SetEntPropEnt(iPointPush, Prop_Send, "m_hOwnerEntity", client);
			DispatchKeyValueFloat(iPointPush, "magnitude", 600.0);
			DispatchKeyValueFloat(iPointPush, "radius", 200.0 * 1.0);
	  		DispatchKeyValue(iPointPush, "spawnflags", "8");
			TeleportEntity(iPointPush, flPos, NULL_VECTOR, NULL_VECTOR);
	 		DispatchSpawn(iPointPush);
	 		AcceptEntityInput(iPointPush, "Enable", -1, -1);
			iPointPush = EntIndexToEntRef(iPointPush);
			vDeleteEntity(iPointPush, 0.5);
		}
	}
}

void vMeteorAbility(int client, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iMeteorChance[g_iTankType[client]]) == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))) && !g_bMeteor[client])
	{
		g_bMeteor[client] = true;
		float flPos[3];
		GetClientEyePosition(client, flPos);
		DataPack dpDataPack;
		CreateDataTimer(0.6, tTimerUpdateMeteor, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(client));
		dpDataPack.WriteFloat(flPos[0]);
		dpDataPack.WriteFloat(flPos[1]);
		dpDataPack.WriteFloat(flPos[2]);
		dpDataPack.WriteFloat(GetEngineTime());
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
		AcceptEntityInput(iParticle, "start");
		SetVariantString("!activator");
		AcceptEntityInput(iParticle, "SetParent", iParticle);
		iParticle = EntIndexToEntRef(iParticle);
		vDeleteEntity(iParticle, 0.1);
	}
}

void vProps(int client, int red, int green, int blue, int alpha)
{
	char sSet[4][4];
	ExplodeString(g_sPropsChance[g_iTankType[client]], ",", sSet, sizeof(sSet), sizeof(sSet[]));
	int iChance1 = StringToInt(sSet[0]);
	int iChance2 = StringToInt(sSet[1]);
	int iChance3 = StringToInt(sSet[2]);
	int iChance4 = StringToInt(sSet[3]);
	if (GetRandomInt(1, iChance1) == 1 && StrContains(g_sPropsAttached[g_iTankType[client]], "1") != -1)
	{
		float flOrigin[3];
		float flAngles[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
		flAngles[0] += -90.0;
		int iEntity = CreateEntityByName("beam_spotlight");
		if (IsValidEntity(iEntity))
		{
			DispatchKeyValueVector(iEntity, "origin", flOrigin);
			DispatchKeyValueVector(iEntity, "angles", flAngles);
			DispatchKeyValue(iEntity, "spotlightwidth", "10");
			DispatchKeyValue(iEntity, "spotlightlength", "60");
			DispatchKeyValue(iEntity, "spawnflags", "3");
			SetEntityRenderColor(iEntity, red, green, blue, 125);
			DispatchKeyValue(iEntity, "maxspeed", "100");
			DispatchKeyValue(iEntity, "HDRColorScale", "0.7");
			DispatchKeyValue(iEntity, "fadescale", "1");
			DispatchKeyValue(iEntity, "fademindist", "-1");
			SetVariantString("!activator");
			AcceptEntityInput(iEntity, "SetParent", client);
			SetVariantString("mouth");
			AcceptEntityInput(iEntity, "SetParentAttachment");
			AcceptEntityInput(iEntity, "Enable");
			AcceptEntityInput(iEntity, "DisableCollision");
			SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", client);
			TeleportEntity(iEntity, NULL_VECTOR, flAngles, NULL_VECTOR);
			DispatchSpawn(iEntity);
			SDKHook(iEntity, SDKHook_SetTransmit, SetTransmit);
		}
	}
	if (GetRandomInt(1, iChance2) == 1 && StrContains(g_sPropsAttached[g_iTankType[client]], "2") != -1)
	{
		float flOrigin[3];
		float flAngles[3];
		GetClientEyePosition(client, flOrigin);
		GetClientAbsAngles(client, flAngles);
		int iEntity[5];
		for (int iOzTank = 1; iOzTank <= 4; iOzTank++)
		{
			iEntity[iOzTank] = CreateEntityByName("prop_dynamic_override");
			if (IsValidEntity(iEntity[iOzTank]))
			{
				SetEntityModel(iEntity[iOzTank], MODEL_JETPACK);
				SetEntityRenderColor(iEntity[iOzTank], red, green, blue, alpha);
				SetEntProp(iEntity[iOzTank], Prop_Data, "m_takedamage", 0, 1);
				SetEntProp(iEntity[iOzTank], Prop_Data, "m_CollisionGroup", 2);
				SetVariantString("!activator");
				AcceptEntityInput(iEntity[iOzTank], "SetParent", client);
				switch (iOzTank)
				{
					case 1:
					{
						SetVariantString("rfoot");
						vSetVector(flOrigin, 0.0, 30.0, 8.0);
					}
					case 2:
					{
						SetVariantString("lfoot");
						vSetVector(flOrigin, 0.0, 30.0, -8.0);
					}
					case 3:
					{
						SetVariantString("rshoulder");
						vSetVector(flOrigin, 0.0, 30.0, 8.0);
					}
					case 4:
					{
						SetVariantString("lshoulder");
						vSetVector(flOrigin, 0.0, 30.0, -8.0);
					}
				}
				AcceptEntityInput(iEntity[iOzTank], "SetParentAttachment");
				float flAngles2[3];
				vSetVector(flAngles2, 0.0, 0.0, 1.0);
				GetVectorAngles(flAngles2, flAngles2);
				vCopyVector(flAngles, flAngles2);
				flAngles2[2] += 90.0;
				DispatchKeyValueVector(iEntity[iOzTank], "origin", flOrigin);
				DispatchKeyValueVector(iEntity[iOzTank], "angles", flAngles2);
				AcceptEntityInput(iEntity[iOzTank], "Enable");
				AcceptEntityInput(iEntity[iOzTank], "DisableCollision");
				SetEntPropEnt(iEntity[iOzTank], Prop_Send, "m_hOwnerEntity", client);
				TeleportEntity(iEntity[iOzTank], flOrigin, NULL_VECTOR, flAngles2);
				DispatchSpawn(iEntity[iOzTank]);
				int iFlame = CreateEntityByName("env_steam");
				if (IsValidEntity(iFlame))
				{
					SetEntityRenderColor(iFlame, red, green, blue, g_iAlpha[client]);
					DispatchKeyValue(iFlame, "spawnflags", "1");
					DispatchKeyValue(iFlame, "Type", "0");
					DispatchKeyValue(iFlame, "InitialState", "1");
					DispatchKeyValue(iFlame, "Spreadspeed", "1");
					DispatchKeyValue(iFlame, "Speed", "250");
					DispatchKeyValue(iFlame, "Startsize", "6");
					DispatchKeyValue(iFlame, "EndSize", "8");
					DispatchKeyValue(iFlame, "Rate", "555");
					DispatchKeyValue(iFlame, "JetLength", "40");
					SetVariantString("!activator");
					AcceptEntityInput(iFlame, "SetParent", iEntity[iOzTank]);
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
				SDKHook(iEntity[iOzTank], SDKHook_SetTransmit, SetTransmit);
			}
		}
	}
	if (GetRandomInt(1, iChance3) == 1 && StrContains(g_sPropsAttached[g_iTankType[client]], "3") != -1)
	{
		float flOrigin[3];
		float flAngles[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
		int iEntity[5];
		for (int iRock = 1; iRock <= 4; iRock++)
		{
			iEntity[iRock] = CreateEntityByName("prop_dynamic_override");
			if (IsValidEntity(iEntity[iRock]))
			{
				SetEntityModel(iEntity[iRock], MODEL_CONCRETE);
				SetEntityRenderColor(iEntity[iRock], red, green, blue, alpha);
				DispatchKeyValueVector(iEntity[iRock], "origin", flOrigin);
				DispatchKeyValueVector(iEntity[iRock], "angles", flAngles);
				SetVariantString("!activator");
				AcceptEntityInput(iEntity[iRock], "SetParent", client);
				switch (iRock)
				{
					case 1: SetVariantString("relbow");
					case 2: SetVariantString("lelbow");
					case 3: SetVariantString("rshoulder");
					case 4: SetVariantString("lshoulder");
				}
				AcceptEntityInput(iEntity[iRock], "SetParentAttachment");
				AcceptEntityInput(iEntity[iRock], "Enable");
				AcceptEntityInput(iEntity[iRock], "DisableCollision");
				if (bIsL4D2Game())
				{
					switch (iRock)
					{
						case 1, 2: SetEntPropFloat(iEntity[iRock], Prop_Data, "m_flModelScale", 0.4);
						case 3, 4: SetEntPropFloat(iEntity[iRock], Prop_Data, "m_flModelScale", 0.5);
					}
				}
				SetEntPropEnt(iEntity[iRock], Prop_Send, "m_hOwnerEntity", client);
				flAngles[0] = flAngles[0] + GetRandomFloat(-90.0, 90.0);
				flAngles[1] = flAngles[1] + GetRandomFloat(-90.0, 90.0);
				flAngles[2] = flAngles[2] + GetRandomFloat(-90.0, 90.0);
				TeleportEntity(iEntity[iRock], NULL_VECTOR, flAngles, NULL_VECTOR);
				DispatchSpawn(iEntity[iRock]);
				SDKHook(iEntity[iRock], SDKHook_SetTransmit, SetTransmit);
			}
		}
	}
	if (GetRandomInt(1, iChance4) == 1 && StrContains(g_sPropsAttached[g_iTankType[client]], "4") != -1)
	{
		float flOrigin[3];
		float flAngles[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
		flAngles[0] += 90.0;
		int iEntity[3];
		for (int iTire = 1; iTire <= 2; iTire++)
		{
			iEntity[iTire] = CreateEntityByName("prop_dynamic_override");
			if (IsValidEntity(iEntity[iTire]))
			{
				SetEntityModel(iEntity[iTire], MODEL_TIRES);
				SetEntityRenderColor(iEntity[iTire], red, green, blue, alpha);
				DispatchKeyValueVector(iEntity[iTire], "origin", flOrigin);
				DispatchKeyValueVector(iEntity[iTire], "angles", flAngles);
				SetVariantString("!activator");
				AcceptEntityInput(iEntity[iTire], "SetParent", client);
				switch (iTire)
				{
					case 1: SetVariantString("rfoot");
					case 2: SetVariantString("lfoot");
				}
				AcceptEntityInput(iEntity[iTire], "SetParentAttachment");
				AcceptEntityInput(iEntity[iTire], "Enable");
				AcceptEntityInput(iEntity[iTire], "DisableCollision");
				if (bIsL4D2Game())
				{
					SetEntPropFloat(iEntity[iTire], Prop_Data, "m_flModelScale", 1.5);
				}
				SetEntPropEnt(iEntity[iTire], Prop_Send, "m_hOwnerEntity", client);
				TeleportEntity(iEntity[iTire], NULL_VECTOR, flAngles, NULL_VECTOR);
				DispatchSpawn(iEntity[iTire]);
				SDKHook(iEntity[iTire], SDKHook_SetTransmit, SetTransmit);
			}
		}
	}
}

void vPukeHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iPukeChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		SDKCall(g_hSDKPukePlayer, client, owner, true);
	}
}

void vRestartHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iRestartChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		SDKCall(g_hSDKRespawnPlayer, client);
		char sItems[5][64];
		ExplodeString(g_sLoadout[g_iTankType[owner]], ",", sItems, sizeof(sItems), sizeof(sItems[]));
		for (int iItem = 0; iItem < sizeof(sItems); iItem++)
		{
			if (StrContains(g_sLoadout[g_iTankType[owner]], sItems[iItem]) != -1 && sItems[iItem][0] != '\0')
			{
				vCheatCommand(client, "give", sItems[iItem]);
			}
		}
		if (g_bRestartValid)
		{
			TeleportEntity(client, g_flSpawnPosition, NULL_VECTOR, NULL_VECTOR);
		}
		else
		{
			float flCurrentOrigin[3] = {0.0, 0.0, 0.0};
			for (int iPlayer = 1; iPlayer <= MaxClients; iPlayer++)
			{
				if (bIsSurvivor(iPlayer) && iPlayer != client)
				{
					GetClientAbsOrigin(iPlayer, flCurrentOrigin);
					TeleportEntity(client, flCurrentOrigin, NULL_VECTOR, NULL_VECTOR);
					break;
				}
			}
		}
	}
}

void vRocketHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iRocketChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		int iFlame = CreateEntityByName("env_steam");
		if (IsValidEntity(iFlame))
		{
			float flPosition[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPosition);
			flPosition[2] += 30.0;
			float flAngles[3];
			flAngles[0] = 90.0;
			flAngles[1] = 0.0;
			flAngles[2] = 0.0;
			DispatchKeyValue(iFlame, "spawnflags", "1");
			DispatchKeyValue(iFlame, "Type", "0");
			DispatchKeyValue(iFlame, "InitialState", "1");
			DispatchKeyValue(iFlame, "Spreadspeed", "10");
			DispatchKeyValue(iFlame, "Speed", "800");
			DispatchKeyValue(iFlame, "Startsize", "10");
			DispatchKeyValue(iFlame, "EndSize", "250");
			DispatchKeyValue(iFlame, "Rate", "15");
			DispatchKeyValue(iFlame, "JetLength", "400");
			SetEntityRenderColor(iFlame, 180, 70, 10, 180);
			TeleportEntity(iFlame, flPosition, flAngles, NULL_VECTOR);
			DispatchSpawn(iFlame);
			SetVariantString("!activator");
			AcceptEntityInput(iFlame, "SetParent", client);
			iFlame = EntIndexToEntRef(iFlame);
			vDeleteEntity(iFlame, 3.0);
			g_iRocket[client] = iFlame;
		}
		EmitSoundToAll(SOUND_FIRE, client, _, _, _, 0.8);
		CreateTimer(2.0, tTimerRocketLaunch, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(3.5, tTimerRocketDetonate, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vSetColor(int client, int value = 0)
{
	char sSet[3][12];
	ExplodeString(g_sTankColors[value], "|", sSet, sizeof(sSet), sizeof(sSet[]));
	char sRGB[4][4];
	ExplodeString(sSet[0], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
	int iRed = StringToInt(sRGB[0]);
	int iGreen = StringToInt(sRGB[1]);
	int iBlue = StringToInt(sRGB[2]);
	int iAlpha = StringToInt(sRGB[3]);
	char sGlow[3][4];
	ExplodeString(sSet[2], ",", sGlow, sizeof(sGlow), sizeof(sGlow[]));
	int iRed2 = StringToInt(sGlow[0]);
	int iGreen2 = StringToInt(sGlow[1]);
	int iBlue2 = StringToInt(sGlow[2]);
	if (g_iGlowEffect[value] == 1 && bIsL4D2Game())
	{
		SetEntProp(client, Prop_Send, "m_iGlowType", 3);
		SetEntProp(client, Prop_Send, "m_glowColorOverride", iGetRGBColor(iRed2, iGreen2, iBlue2));
	}
	SetEntityRenderMode(client, RENDER_NORMAL);
	SetEntityRenderColor(client, iRed, iGreen, iBlue, iAlpha);
	g_iTankType[client] = value;
}

void vSetHealth(int client, int value)
{
	int iHealth = GetClientHealth(client);
	int iExtraHealth = (iGetHumanCount() > 1) ? ((value * iGetHumanCount()) + iHealth) : (value + iHealth);
	SetEntityHealth(client, (iExtraHealth > 62400) ? 62400 : iExtraHealth);
}

void vSetName(int client, char[] name = "Default Tank")
{
	char sSet[3][12];
	ExplodeString(g_sTankColors[g_iTankType[client]], "|", sSet, sizeof(sSet), sizeof(sSet[]));
	char sRGB[4][4];
	ExplodeString(sSet[1], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
	int iRed = StringToInt(sRGB[0]);
	int iGreen = StringToInt(sRGB[1]);
	int iBlue = StringToInt(sRGB[2]);
	int iAlpha = StringToInt(sRGB[3]);
	if (bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		vSetProps(client, iRed, iGreen, iBlue, iAlpha);
		if (IsFakeClient(client))
		{
			SetClientInfo(client, "name", name);
			if (g_iAnnounceArrival == 1)
			{
				PrintToChatAll("\x04%s\x05 %s\x01 has appeared!", ST_PREFIX, name);
			}
		}
	}
}

void vSetProps(int client, int red, int green, int blue, int alpha)
{
	if (bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		vProps(client, red, green, blue, alpha);
	}
}

void vShakeHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iShakeChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		if (g_hShakeTimer[client] == null)
		{
			g_hShakeTimer[client] = CreateTimer(5.0, tTimerShake, GetClientUserId(client), TIMER_REPEAT);
			CreateTimer(g_flShakeDuration[g_iTankType[owner]], tTimerStopShake, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

void vShieldAbility(int client, bool shield, int enabled)
{
	if (enabled == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		if (shield)
		{
			char sSet[3][4];
			ExplodeString(g_sShieldColor[g_iTankType[client]], ",", sSet, sizeof(sSet), sizeof(sSet[]));
			int iRed = StringToInt(sSet[0]);
			int iGreen = StringToInt(sSet[1]);
			int iBlue = StringToInt(sSet[2]);
			float flOrigin[3];
			GetClientAbsOrigin(client, flOrigin);
			flOrigin[2] -= 120.0;
			int iEntity = CreateEntityByName("prop_dynamic");
			if (IsValidEntity(iEntity))
			{
				SetEntityModel(iEntity, MODEL_SHIELD);
				DispatchKeyValueVector(iEntity, "origin", flOrigin);
				DispatchSpawn(iEntity);
				SetVariantString("!activator");
				AcceptEntityInput(iEntity, "SetParent", client);
				SetEntityRenderMode(iEntity, RENDER_TRANSTEXTURE);
				SetEntityRenderColor(iEntity, iRed, iGreen, iBlue, 50);
				SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 1);
				SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", client);
			}
			g_bShielded[client] = true;
		}
		else
		{
			int iEntity = -1;
			while ((iEntity = FindEntityByClassname(iEntity, "prop_dynamic")) != INVALID_ENT_REFERENCE)
			{
				char sModel[128];
				GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
				if (strcmp(sModel, MODEL_SHIELD) == 0)
				{
					int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
					if (iOwner == client)
					{
						AcceptEntityInput(iEntity, "Kill");
					}
				}
			}
			CreateTimer(g_flShieldDelay[g_iTankType[client]], tTimerShield, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			g_bShielded[client] = false;
		}
	}
}

void vShoveHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iShoveChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		if (g_hShoveTimer[client] == null)
		{
			g_hShoveTimer[client] = CreateTimer(1.0, tTimerShove, GetClientUserId(client), TIMER_REPEAT);
			CreateTimer(g_flShoveDuration[g_iTankType[owner]], tTimerStopShove, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

void vSlugHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iSlugChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		float flPosition[3];
		GetClientAbsOrigin(client, flPosition);
		flPosition[2] -= 26;
		float flStartPosition[3];
		flStartPosition[0] = flPosition[0] + GetRandomInt(-500, 500);
		flStartPosition[1] = flPosition[1] + GetRandomInt(-500, 500);
		flStartPosition[2] = flPosition[2] + 800;
		int iColor[4] = {255, 255, 255, 255};
		float flDirection[3] = {0.0, 0.0, 0.0};
		TE_SetupBeamPoints(flStartPosition, flPosition, g_iSlugSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, iColor, 3);
		TE_SendToAll();
		TE_SetupSparks(flPosition, flDirection, 5000, 1000);
		TE_SendToAll();
		TE_SetupEnergySplash(flPosition, flDirection, false);
		TE_SendToAll();
		EmitAmbientSound(SOUND_EXPLOSION3, flStartPosition, client, SNDLEVEL_RAIDSIREN);
		ForcePlayerSuicide(client);
	}
}

void vSmokerEffect(int client, int enabled)
{
	if (enabled == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		if (g_hSmokerTimer[client] == null)
		{
			g_hSmokerTimer[client] = CreateTimer(1.5, tTimerSmoker, GetClientUserId(client), TIMER_REPEAT);
		}
	}
}

void vSpamAbility(int client, int enabled)
{
	if (enabled == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		if (g_hSpamTimer[client] == null)
		{
			g_hSpamTimer[client] = CreateTimer(g_flSpamInterval[g_iTankType[client]], tTimerSpam, GetClientUserId(client), TIMER_REPEAT);
		}
	}
}

void vSpawnTank(int wave)
{
	if (iGetTankCount() < wave)
	{
		int iTank = CreateFakeClient("Tank");
		if (iTank > 0)
		{
			vSpawnInfected(iTank, 8, true, 1);
		}
	}
}

void vStopFlash(int client, int enabled)
{
	if (enabled == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		if (g_hFlashTimer[client] != null)
		{
			KillTimer(g_hFlashTimer[client]);
			g_hFlashTimer[client] = null;
		}
	}
}

void vStopHeal(int client, int enabled)
{
	if (enabled == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		if (g_hHealTimer[client] != null)
		{
			KillTimer(g_hHealTimer[client]);
			g_hHealTimer[client] = null;
		}
	}
}

void vStopSmoker(int client, int enabled)
{
	if (enabled == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		if (g_hSmokerTimer[client] != null)
		{
			KillTimer(g_hSmokerTimer[client]);
			g_hSmokerTimer[client] = null;
		}
	}
}

void vStopSpam(int client, int enabled)
{
	if (enabled == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		if (g_hSpamTimer[client] != null)
		{
			KillTimer(g_hSpamTimer[client]);
			g_hSpamTimer[client] = null;
		}
	}
}

void vStopTimers(int client)
{
	if (bIsValidClient(client))
	{
		g_bAFK[client] = false;
		g_bBlind[client] = false;
		g_bFlash[client] = false;
		g_bGhost[client] = false;
		g_bGravity[client] = false;
		g_bHeadshot[client] = false;
		g_bHurt[client] = false;
		g_bHypno[client] = false;
		g_bIce[client] = false;
		g_bIdle[client] = false;
		g_bInvert[client] = false;
		g_bMeteor[client] = false;
		g_bShielded[client] = false;
		g_bStun[client] = false;
		g_iAlpha[client] = 255;
		g_iSpawnInterval[client] = 0;
		g_iTankType[client] = 0;
		vStopFlash(client, 1);
		vStopHeal(client, 1);
		vStopSmoker(client, 1);
		vStopSpam(client, 1);
	}
}

void vStunHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iStunChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		if (!g_bStun[client])
		{
			g_bStun[client] = true;
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", g_flStunSpeed[g_iTankType[owner]]);
			CreateTimer(g_flStunDuration[g_iTankType[owner]], tTimerStopStun, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

void vTankCountCheck(int client, int wave)
{
	if (iGetTankCount() < wave)
	{
		CreateTimer(5.0, tTimerSpawnTanks, wave, TIMER_FLAG_NO_MAPCHANGE);
	}
	else if (iGetTankCount() > wave && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		vKickFakeClient(client);
	}
}

void vThrowInterval(int client, float time)
{
	if (bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		int iAbility = GetEntPropEnt(client, Prop_Send, "m_customAbility");
		if (iAbility > 0)
		{
			SetEntPropFloat(iAbility, Prop_Send, "m_duration", time);
			SetEntPropFloat(iAbility, Prop_Send, "m_timestamp", GetGameTime() + time);
		}
	}
}

void vVisualHit(int client, int owner, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iVisionChance[g_iTankType[owner]]) == 1 && bIsSurvivor(client))
	{
		if (g_hVisionTimer[client] == null)
		{
			g_hVisionTimer[client] = CreateTimer(0.1, tTimerVision, GetClientUserId(client), TIMER_REPEAT);
			CreateTimer(g_flVisionDuration[g_iTankType[owner]], tTimerStopVision, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

void vWarpAbility(int client, int enabled)
{
	if (enabled == 1 && GetRandomInt(1, g_iWarpInterval[g_iTankType[client]]) == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		int iTarget = iGetRandomSurvivor();
		if (iTarget > 0)
		{
			float flOrigin[3];
			float flAngles[3];
			GetClientAbsOrigin(iTarget, flOrigin);
			GetClientAbsAngles(iTarget, flAngles);
			vCreateParticle(client, PARTICLE_ELECTRICITY, 1.0, 0.0);
			TeleportEntity(client, flOrigin, flAngles, NULL_VECTOR);
		}
	}
}

void vWitchAbility(int client, int enabled)
{
	if (enabled == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		int iWitchCount;
		int iEntity = -1;
		while ((iEntity = FindEntityByClassname(iEntity, "infected")) != INVALID_ENT_REFERENCE)
		{
			if (iWitchCount < 4 && iGetWitchCount() < g_iWitchAmount[g_iTankType[client]])
			{
				float flTankPos[3];
				float flInfectedPos[3];
				float flInfectedAng[3];
				GetClientAbsOrigin(client, flTankPos);
				GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", flInfectedPos);
				GetEntPropVector(iEntity, Prop_Send, "m_angRotation", flInfectedAng);
				float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
				if (flDistance < 100.0)
				{
					AcceptEntityInput(iEntity, "Kill");
					int iWitch = CreateEntityByName("witch");
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

public void vSTGameDifficultyCvar(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (StrContains(g_sConfigExecute, "1") != -1)
	{
		char sDifficultyConfig[512];
		g_cvSTFindConVar[0].GetString(sDifficultyConfig, sizeof(sDifficultyConfig));
		Format(sDifficultyConfig, sizeof(sDifficultyConfig), "cfg/sourcemod/super_tanks++/difficulty_configs/%s.cfg", sDifficultyConfig);
		vLoadConfigs(sDifficultyConfig);
	}
}

public Action tTimerStopBlindness(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client))
	{
		g_bBlind[client] = false;
		vApplyBlindness(client, 0);
	}
	return Plugin_Continue;
}

public Action tTimerDrug(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client))
	{
		float flAngles[3];
		GetClientEyeAngles(client, flAngles);
		flAngles[2] = g_flDrugAngles[GetRandomInt(0, 100) % 20];
		TeleportEntity(client, NULL_VECTOR, flAngles, NULL_VECTOR);
		int iClients[2];
		iClients[0] = client;
		int iFlags = 0x0002;
		int iColor[4] = {0, 0, 0, 128};
		iColor[0] = GetRandomInt(0, 255);
		iColor[1] = GetRandomInt(0, 255);
		iColor[2] = GetRandomInt(0, 255);
		Handle hDrugTarget = StartMessageEx(g_umFadeUserMsgId, iClients, 1);
		if (GetUserMessageType() == UM_Protobuf)
		{
			Protobuf pbSet = UserMessageToProtobuf(hDrugTarget);
			pbSet.SetInt("duration", 255);
			pbSet.SetInt("hold_time", 255);
			pbSet.SetInt("flags", iFlags);
			pbSet.SetColor("clr", iColor);
		}
		else
		{
			BfWrite bfWrite = UserMessageToBfWrite(hDrugTarget);
			bfWrite.WriteShort(255);
			bfWrite.WriteShort(255);
			bfWrite.WriteShort(iFlags);
			bfWrite.WriteByte(iColor[0]);
			bfWrite.WriteByte(iColor[1]);
			bfWrite.WriteByte(iColor[2]);
			bfWrite.WriteByte(iColor[3]);
		}
		EndMessage();
	}
	return Plugin_Handled;
}

public Action tTimerStopDrug(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client) && g_hDrugTimer[client] != null)
	{
		float flAngles[3];
		GetClientEyeAngles(client, flAngles);
		flAngles[2] = 0.0;
		TeleportEntity(client, NULL_VECTOR, flAngles, NULL_VECTOR);
		int iClients[2];
		iClients[0] = client;
		int iFlags = (0x0001|0x0010);
		int iColor[4] = {0, 0, 0, 0};
		Handle hDrugTarget = StartMessageEx(g_umFadeUserMsgId, iClients, 1);
		if (GetUserMessageType() == UM_Protobuf)
		{
			Protobuf pbSet = UserMessageToProtobuf(hDrugTarget);
			pbSet.SetInt("duration", 1536);
			pbSet.SetInt("hold_time", 1536);
			pbSet.SetInt("flags", iFlags);
			pbSet.SetColor("clr", iColor);
		}
		else
		{
			BfWrite bfWrite = UserMessageToBfWrite(hDrugTarget);
			bfWrite.WriteShort(1536);
			bfWrite.WriteShort(1536);
			bfWrite.WriteShort(iFlags);
			bfWrite.WriteByte(iColor[0]);
			bfWrite.WriteByte(iColor[1]);
			bfWrite.WriteByte(iColor[2]);
			bfWrite.WriteByte(iColor[3]);
		}
		EndMessage();
		KillTimer(g_hDrugTimer[client]);
		g_hDrugTimer[client] = null;
	}
	return Plugin_Continue;
}

public Action tTimerFlashEffect(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (g_iFlashAbility[g_iTankType[client]] == 0 || client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		g_bFlash[client] = false;
		return Plugin_Stop;
	}
	if (bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		char sSet[3][12];
		ExplodeString(g_sTankColors[g_iTankType[client]], "|", sSet, sizeof(sSet), sizeof(sSet[]));
		char sRGB[4][4];
		ExplodeString(sSet[0], ",", sRGB, sizeof(sRGB), sizeof(sRGB[]));
		int iRed = StringToInt(sRGB[0]);
		int iGreen = StringToInt(sRGB[1]);
		int iBlue = StringToInt(sRGB[2]);
		float flTankPos[3];
		float flTankAng[3];
		GetClientAbsOrigin(client, flTankPos);
		GetClientAbsAngles(client, flTankAng);
		int iAnim = GetEntProp(client, Prop_Send, "m_nSequence");
		int iEntity = CreateEntityByName("prop_dynamic");
		if (IsValidEntity(iEntity))
		{
			SetEntityModel(iEntity, MODEL_TANK);
			SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", client);
			DispatchKeyValue(iEntity, "solid", "6");
			TeleportEntity(iEntity, flTankPos, flTankAng, NULL_VECTOR);
			DispatchSpawn(iEntity);
			AcceptEntityInput(iEntity, "DisableCollision");
			SetEntityRenderColor(iEntity, iRed, iGreen, iBlue, g_iAlpha[client]);
			SetEntProp(iEntity, Prop_Send, "m_nSequence", iAnim);
			SetEntPropFloat(iEntity, Prop_Send, "m_flPlaybackRate", 5.0);
			iEntity = EntIndexToEntRef(iEntity);
			vDeleteEntity(iEntity, 0.3);
		}
	}
	return Plugin_Continue;
}

public Action tTimerGhost(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iRed = pack.ReadCell();
	int iGreen = pack.ReadCell();
	int iBlue = pack.ReadCell();
	int iRed2 = pack.ReadCell();
	int iGreen2 = pack.ReadCell();
	int iBlue2 = pack.ReadCell();
	if (g_iGhostAbility[g_iTankType[iTank]] == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		g_bGhost[iTank] = false;
		return Plugin_Stop;
	}
	if (bIsTank(iTank) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		g_iAlpha[iTank] -= 2;
		if (g_iAlpha[iTank] < g_iGhostFade[g_iTankType[iTank]])
		{
			g_iAlpha[iTank] = g_iGhostFade[g_iTankType[iTank]];
		}
		int iEntity = -1;
		while ((iEntity = FindEntityByClassname(iEntity, "prop_dynamic")) != INVALID_ENT_REFERENCE)
		{
			char sModel[128];
			GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
			if (strcmp(sModel, MODEL_CONCRETE) == 0 || strcmp(sModel, MODEL_JETPACK) == 0 || strcmp(sModel, MODEL_SHIELD) == 0 || strcmp(sModel, MODEL_TIRES) == 0 || strcmp(sModel, MODEL_TANK) == 0)
			{
				int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
				if (iOwner == iTank)
				{
					SetEntityRenderMode(iEntity, RENDER_TRANSCOLOR);
					SetEntityRenderColor(iEntity, iRed2, iGreen2, iBlue2, g_iAlpha[iTank]);
				}
			}
		}
		while ((iEntity = FindEntityByClassname(iEntity, "beam_spotlight")) != INVALID_ENT_REFERENCE)
		{
			int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
			if (iOwner == iTank)
			{
				SetEntityRenderMode(iEntity, RENDER_TRANSCOLOR);
				SetEntityRenderColor(iEntity, iRed2, iGreen2, iBlue2, g_iAlpha[iTank]);
			}
		}
		while ((iEntity = FindEntityByClassname(iEntity, "env_steam")) != INVALID_ENT_REFERENCE)
		{
			int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
			if (iOwner == iTank)
			{
				SetEntityRenderMode(iEntity, RENDER_TRANSCOLOR);
				SetEntityRenderColor(iEntity, iRed2, iGreen2, iBlue2, g_iAlpha[iTank]);
			}
		}
		SetEntityRenderMode(iTank, RENDER_TRANSCOLOR);
		SetEntityRenderColor(iTank, iRed, iGreen, iBlue, g_iAlpha[iTank]);
	}
	return Plugin_Continue;
}

public Action tTimerStopGravity(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client))
	{
		g_bGravity[client] = false;
		SetEntityGravity(client, 1.0);
	}
	return Plugin_Continue;
}

public Action tTimerHeal(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (g_iHealAbility[g_iTankType[client]] == 0 || client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		int iType;
		int iEntity = -1;
		while ((iEntity = FindEntityByClassname(iEntity, "infected")) != INVALID_ENT_REFERENCE)
		{
			float flTankPos[3];
			float flInfectedPos[3];
			GetClientAbsOrigin(client, flTankPos);
			GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", flInfectedPos);
			float flDistance = GetVectorDistance(flInfectedPos, flTankPos);
			if (flDistance < 500.0)
			{
				int iHealth = GetClientHealth(client);
				int iExtraHealth = iHealth + g_iHealCommon[g_iTankType[client]];
				if (iHealth > 500)
				{
					SetEntityHealth(client, (iExtraHealth > 62400) ? 62400 : iExtraHealth);
					if (bIsL4D2Game())
					{
						SetEntProp(client, Prop_Send, "m_iGlowType", 3);
						SetEntProp(client, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 185, 0));
						SetEntProp(client, Prop_Send, "m_bFlashing", 1);
					}
					iType = 1;
				}
			}
		}
		for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
		{
			if (bIsSpecialInfected(iInfected))
			{
				float flTankPos[3];
				float flInfectedPos[3];
				GetClientAbsOrigin(client, flTankPos);
				GetClientAbsOrigin(iInfected, flInfectedPos);
				float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
				if (flDistance < 500.0)
				{
					int iHealth = GetClientHealth(client);
					int iExtraHealth = iHealth + g_iHealSpecial[g_iTankType[client]];
					if (iHealth > 500)
					{
						SetEntityHealth(client, (iExtraHealth > 62400) ? 62400 : iExtraHealth);
						if (iType < 2 && bIsL4D2Game())
						{
							SetEntProp(client, Prop_Send, "m_iGlowType", 3);
							SetEntProp(client, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 220, 0));
							SetEntProp(client, Prop_Send, "m_bFlashing", 1);
							iType = 1;
						}
					}
				}
			}
			else if (bIsTank(iInfected) && iInfected != client)
			{
				float flTankPos[3];
				float flInfectedPos[3];
				GetClientAbsOrigin(client, flTankPos);
				GetClientAbsOrigin(iInfected, flInfectedPos);
				float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
				if (flDistance < 500.0)
				{
					int iHealth = GetClientHealth(client);
					int iExtraHealth = iHealth + g_iHealTank[g_iTankType[client]];
					if (iHealth > 500)
					{
						SetEntityHealth(client, (iExtraHealth > 62400) ? 62400 : iExtraHealth);
						if (bIsL4D2Game())
						{
							SetEntProp(client, Prop_Send, "m_iGlowType", 3);
							SetEntProp(client, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 255, 0));
							SetEntProp(client, Prop_Send, "m_bFlashing", 1);
							iType = 2;
						}
					}
				}
			}
		}
		if (iType == 0 && bIsL4D2Game())
		{
			char sSet[3][12];
			ExplodeString(g_sTankColors[g_iTankType[client]], "|", sSet, sizeof(sSet), sizeof(sSet[]));
			char sGlow[3][4];
			ExplodeString(sSet[2], ",", sGlow, sizeof(sGlow), sizeof(sGlow[]));
			int iRed = StringToInt(sGlow[0]);
			int iGreen = StringToInt(sGlow[1]);
			int iBlue = StringToInt(sGlow[2]);
			SetEntProp(client, Prop_Send, "m_iGlowType", 3);
			SetEntProp(client, Prop_Send, "m_glowColorOverride", iGetRGBColor(iRed, iGreen, iBlue));
			SetEntProp(client, Prop_Send, "m_bFlashing", 0);
		}
	}
	return Plugin_Continue;
}

public Action tTimerHurt(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iTank = GetClientOfUserId(pack.ReadCell());
	float flTime = pack.ReadFloat();
	if (g_iHurtAbility[g_iTankType[iTank]] == 0 || iTank == 0 || iSurvivor == 0 || !IsClientInGame(iTank) || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iTank) || !IsPlayerAlive(iSurvivor) || flTime + g_flHurtDuration[g_iTankType[iTank]] < GetEngineTime())
	{
		g_bHurt[iSurvivor] = false;
		return Plugin_Stop;
	}
	if (bIsTank(iTank) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(iTank))) && bIsSurvivor(iSurvivor))
	{
		char sDamage[16];
		IntToString(g_iHurtDamage[g_iTankType[iTank]], sDamage, sizeof(sDamage));
		int iPointHurt = CreateEntityByName("point_hurt");
		if (iPointHurt > 0)
		{
			DispatchKeyValue(iSurvivor, "targetname", "hurtme");
			DispatchKeyValue(iPointHurt, "Damage", sDamage);
			DispatchKeyValue(iPointHurt, "DamageTarget", "hurtme");
			DispatchKeyValue(iPointHurt, "DamageType", "2");
			DispatchSpawn(iPointHurt);
			AcceptEntityInput(iPointHurt, "Hurt", iTank);
			AcceptEntityInput(iPointHurt, "Kill");
			DispatchKeyValue(iSurvivor, "targetname", "donthurtme");
		}
	}
	return Plugin_Continue;
}

public Action tTimerStopHypnosis(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client))
	{
		g_bHypno[client] = false;
	}
	return Plugin_Continue;
}

public Action tTimerStopIce(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client))
	{
		g_bIce[client] = false;
		GetClientEyePosition(client, g_flIce);
		if (GetEntityMoveType(client) == MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			EmitAmbientSound(PHYSICS_BULLET, g_flIce, client, SNDLEVEL_RAIDSIREN);
		}
	}
	return Plugin_Continue;
}

public Action tTimerIdleFix(Handle timer, DataPack pack)
{
	pack.Reset();
	int iSurvivor = GetClientOfUserId(pack.ReadCell());
	int iBot = GetClientOfUserId(pack.ReadCell());
	if (iSurvivor == 0 || iBot == 0 || !IsClientInGame(iSurvivor) || !IsPlayerAlive(iSurvivor) || !IsClientInGame(iBot) || !IsPlayerAlive(iSurvivor))
	{
		return Plugin_Stop;
	}
	if (GetClientTeam(iSurvivor) != 1 || iGetIdleBot(iSurvivor) || IsFakeClient(iSurvivor))
	{
		g_bAFK[iSurvivor] = false;
	}
	if (!bIsBotIdleSurvivor(iBot) || GetClientTeam(iBot) != 2)
	{
		iBot = iGetBotSurvivor();
	}
	if (iBot < 1)
	{
		g_bAFK[iSurvivor] = false;
	}
	if (g_bAFK[iSurvivor])
	{
		g_bAFK[iSurvivor] = false;
		SDKCall(g_hSDKSpecPlayer, iBot, iSurvivor);
		SetEntProp(iSurvivor, Prop_Send, "m_iObserverMode", 5);
	}
	return Plugin_Continue;
}

public Action tTimerInfectedThrow(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (g_iInfectedThrow[g_iTankType[iTank]] == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank) || (iRock = EntRefToEntIndex(iRock)) == INVALID_ENT_REFERENCE)
	{
		return Plugin_Stop;
	}
	if (bIsTank(iTank) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		float flVelocity[3];
		if (IsValidEntity(iRock))
		{
			GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);
			float flVector = GetVectorLength(flVelocity);
			if (flVector > 500.0)
			{
				int iInfected = CreateFakeClient("Infected");
				if (iInfected > 0)
				{
					vSpawnInfected(iInfected, 1, false, g_iSmokerThrow[g_iTankType[iTank]]);
					vSpawnInfected(iInfected, 2, false, g_iBoomerThrow[g_iTankType[iTank]]);
					vSpawnInfected(iInfected, 3, false, g_iHunterThrow[g_iTankType[iTank]]);
					vSpawnInfected(iInfected, 4, false, g_iSpitterThrow[g_iTankType[iTank]]);
					vSpawnInfected(iInfected, 5, false, g_iJockeyThrow[g_iTankType[iTank]]);
					vSpawnInfected(iInfected, 6, false, g_iChargerThrow[g_iTankType[iTank]]);
					vSpawnInfected(iInfected, 8, false, g_iCloneThrow[g_iTankType[iTank]]);
					float flPos[3];
					GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
					AcceptEntityInput(iRock, "Kill");
					NormalizeVector(flVelocity, flVelocity);
					float flSpeed = g_cvSTFindConVar[11].FloatValue;
					ScaleVector(flVelocity, flSpeed * 1.4);
					TeleportEntity(iInfected, flPos, NULL_VECTOR, flVelocity);
				}
				return Plugin_Stop;
			}
		}
	}
	return Plugin_Continue;
}

public Action tTimerStopInversion(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client))
	{
		g_bInvert[client] = false;
	}
	return Plugin_Continue;
}

public Action tTimerJump(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (g_iJumperAbility[g_iTankType[client]] == 0 || client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (GetRandomInt(1, g_iJumperChance[g_iTankType[client]]) == 1 && bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		if (iGetNearestSurvivor(client) > 200 && iGetNearestSurvivor(client) < 2000)
		{
			vFakeJump(client, 1);
		}
	}
	return Plugin_Continue;
}

public Action tTimerUpdateMeteor(Handle timer, DataPack pack)
{
	pack.Reset();
	float flPos[3];
	int iTank = GetClientOfUserId(pack.ReadCell());
	flPos[0] = pack.ReadFloat();
	flPos[1] = pack.ReadFloat();
	flPos[2] = pack.ReadFloat();
	float flTime = pack.ReadFloat();
	if (g_iMeteorAbility[g_iTankType[iTank]] == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	if (bIsTank(iTank) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		if ((GetEngineTime() - flTime) > 5.0)
		{
			g_bMeteor[iTank] = false;
		}
		int iEntity = -1;
		if (g_bMeteor[iTank])
		{
			float flAngle[3];
			float flVelocity[3];
			float flHitpos[3];
			flAngle[0] = 0.0 + GetRandomFloat(-20.0, 20.0);
			flAngle[1] = 0.0 + GetRandomFloat(-20.0, 20.0);
			flAngle[2] = 60.0;
			GetVectorAngles(flAngle, flAngle);
			iGetRayHitPos(flPos, flAngle, flHitpos, iTank, true);
			float flDistance = GetVectorDistance(flPos, flHitpos);
			if (GetVectorDistance(flPos, flHitpos) > 2000.0)
			{
				flDistance = 1600.0;
			}
			float flVector[3];
			MakeVectorFromPoints(flPos, flHitpos, flVector);
			NormalizeVector(flVector, flVector);
			ScaleVector(flVector, flDistance - 40.0);
			AddVectors(flPos, flVector, flHitpos);
			if (flDistance > 100.0)
			{
				int iRock = CreateEntityByName("tank_rock");
				if (iRock > 0)
				{
					SetEntityModel(iRock, MODEL_CONCRETE);
					float flAngle2[3];
					flAngle2[0] = GetRandomFloat(-180.0, 180.0);
					flAngle2[1] = GetRandomFloat(-180.0, 180.0);
					flAngle2[2] = GetRandomFloat(-180.0, 180.0);
					flVelocity[0] = GetRandomFloat(0.0, 350.0);
					flVelocity[1] = GetRandomFloat(0.0, 350.0);
					flVelocity[2] = GetRandomFloat(0.0, 30.0);
					TeleportEntity(iRock, flHitpos, flAngle2, flVelocity);
					DispatchSpawn(iRock);
					ActivateEntity(iRock);
					AcceptEntityInput(iRock, "Ignite");
					SetEntPropEnt(iRock, Prop_Send, "m_hOwnerEntity", iTank);
				}
			}
		}
		else if (!g_bMeteor[iTank])
		{
			while ((iEntity = FindEntityByClassname(iEntity, "tank_rock")) != INVALID_ENT_REFERENCE)
			{
				int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
				if (iTank == iOwner)
				{
					vMeteor(iEntity, iOwner);
				}
			}
			return Plugin_Stop;
		}
		while ((iEntity = FindEntityByClassname(iEntity, "tank_rock")) != INVALID_ENT_REFERENCE)
		{
			int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
			if (iTank == iOwner)
			{
				if (flGetGroundUnits(iEntity) < 200.0)
				{
					vMeteor(iEntity, iOwner);
				}
			}
		}
	}
	return Plugin_Continue;
}

public Action tTimerRestartCoordinates(Handle timer)
{
	for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
	{
		if (bIsSurvivor(iSurvivor))
		{
			g_bRestartValid = true;
			g_flSpawnPosition[0] = 0.0;
			g_flSpawnPosition[1] = 0.0;
			g_flSpawnPosition[2] = 0.0;
			GetClientAbsOrigin(iSurvivor, g_flSpawnPosition);
			break;
		}
	}
}

public Action tTimerRocketLaunch(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client))
	{
		float flVelocity[3];
		flVelocity[0] = 0.0;
		flVelocity[1] = 0.0;
		flVelocity[2] = 800.0;
		EmitSoundToAll(SOUND_EXPLOSION, client, _, _, _, 1.0);
		EmitSoundToAll(SOUND_LAUNCH, client, _, _, _, 1.0);
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, flVelocity);
		SetEntityGravity(client, 0.1);
	}
	return Plugin_Handled;
}

public Action tTimerRocketDetonate(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client))
	{
		float flPosition[3];
		GetClientAbsOrigin(client, flPosition);
		TE_SetupExplosion(flPosition, g_iExplosionSprite, 10.0, 1, 0, 600, 5000);
		TE_SendToAll();
		g_iRocket[client] = 0;
		ForcePlayerSuicide(client);
		SetEntityGravity(client, 1.0);
	}
	return Plugin_Handled;
}

public Action tTimerShake(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client))
	{
		Handle hShakeTarget = StartMessageOne("Shake", client);
		if (hShakeTarget != null)
		{
			BfWrite bfWrite = UserMessageToBfWrite(hShakeTarget);
			bfWrite.WriteByte(0);
			bfWrite.WriteFloat(16.0);
			bfWrite.WriteFloat(0.5);
			bfWrite.WriteFloat(5.0);
			EndMessage();
		}
	}
	return Plugin_Continue;
}

public Action tTimerStopShake(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client) && g_hShakeTimer[client] != null)
	{
		KillTimer(g_hShakeTimer[client]);
		g_hShakeTimer[client] = null;
	}
	return Plugin_Continue;
}

public Action tTimerShield(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (g_iShieldAbility[g_iTankType[client]] == 0 || client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))) && !g_bShielded[client])
	{
		vShieldAbility(client, true, g_iShieldAbility[g_iTankType[client]]);
	}
	return Plugin_Continue;
}

public Action tTimerPropaneThrow(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (g_iShieldAbility[g_iTankType[iTank]] == 0 || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank) || (iRock = EntRefToEntIndex(iRock)) == INVALID_ENT_REFERENCE)
	{
		return Plugin_Stop;
	}
	if (bIsTank(iTank) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(iTank))))
	{
		float flVelocity[3];
		if (IsValidEntity(iRock))
		{
			GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);
			float flVector = GetVectorLength(flVelocity);
			if (flVector > 500.0)
			{
				int iPropane = CreateEntityByName("prop_physics");
				if (IsValidEntity(iPropane))
				{
					SetEntityModel(iPropane, MODEL_PROPANETANK);
					float flPos[3];
					GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
					AcceptEntityInput(iRock, "Kill");
					NormalizeVector(flVelocity, flVelocity);
					float flSpeed = g_cvSTFindConVar[11].FloatValue;
					ScaleVector(flVelocity, flSpeed * 1.4);
					DispatchSpawn(iPropane);
					TeleportEntity(iPropane, flPos, NULL_VECTOR, flVelocity);
				}
				return Plugin_Stop;
			}
		}
	}
	return Plugin_Continue;
}

public Action tTimerShove(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client))
	{
		float flOrigin[3];
		GetClientAbsOrigin(client, flOrigin);
		SDKCall(g_hSDKShovePlayer, client, client, flOrigin);
	}
	return Plugin_Continue;
}

public Action tTimerStopShove(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client) && g_hShoveTimer[client] != null)
	{
		KillTimer(g_hShoveTimer[client]);
		g_hShoveTimer[client] = null;
	}
	return Plugin_Continue;
}

public Action tTimerSmoker(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (g_iSmokeEffect[g_iTankType[client]] == 0 || client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		int iParticle = CreateEntityByName("info_particle_system");
		if (IsValidEntity(iParticle))
    	{
			float flPos[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPos);
			DispatchKeyValue(iParticle, "scale", "");
			DispatchKeyValue(iParticle, "effect_name", PARTICLE_CLOUD);
			TeleportEntity(iParticle, flPos, NULL_VECTOR, NULL_VECTOR);
			DispatchSpawn(iParticle);
			ActivateEntity(iParticle);
			AcceptEntityInput(iParticle, "Enable");
			AcceptEntityInput(iParticle, "start");
			SetVariantString("!activator");
			AcceptEntityInput(iParticle, "SetParent", client);
			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, 1.2);
		}
	}
	return Plugin_Continue;
}

public Action tTimerSpam(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (g_iSpamAbility[g_iTankType[client]] == 0 || client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		CreateTimer(0.5, tTimerSpamThrow, userid, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
	}
	return Plugin_Continue;
}

public Action tTimerSpamThrow(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (g_iSpamAbility[g_iTankType[client]] == 0 || g_iSpamCount[client] >= g_iSpamAmount[g_iTankType[client]] || client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		g_iSpamCount[client] = 0;
		return Plugin_Stop;
	}
	if (bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		if (g_iSpamCount[client] < g_iSpamAmount[g_iTankType[client]])
		{
			char sDamage[6];
			IntToString(g_iSpamDamage[g_iTankType[client]], sDamage, sizeof(sDamage));
			float flPos[3];
			float flAng[3];
			GetClientEyePosition(client, flPos);
			GetClientEyeAngles(client, flAng);
			flPos[2] += 80.0;
			int iSpammer = CreateEntityByName("env_rock_launcher");
			if (IsValidEntity(iSpammer))
			{
				DispatchKeyValue(iSpammer, "rockdamageoverride", sDamage);
				TeleportEntity(iSpammer, flPos, flAng, NULL_VECTOR);
				DispatchSpawn(iSpammer);
				AcceptEntityInput(iSpammer, "LaunchRock");
				AcceptEntityInput(iSpammer, "kill");
				g_iSpamCount[client]++;
			}
		}
	}
	return Plugin_Continue;
}

public Action tTimerStopStun(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client))
	{
		g_bStun[client] = false;
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
	}
	return Plugin_Continue;
}

public Action tTimerVision(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client))
	{
		SetEntProp(client, Prop_Send, "m_iFOV", g_iVisionFOV[g_iTankType[client]]);
		SetEntProp(client, Prop_Send, "m_iDefaultFOV", g_iVisionFOV[g_iTankType[client]]);
	}
	return Plugin_Continue;
}

public Action tTimerStopVision(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsSurvivor(client) && g_hVisionTimer[client] != null)
	{
		SetEntProp(client, Prop_Send, "m_iFOV", 90);
		SetEntProp(client, Prop_Send, "m_iDefaultFOV", 90);
		KillTimer(g_hVisionTimer[client]);
		g_hVisionTimer[client] = null;
	}
	return Plugin_Continue;
}

public Action tTimerSetTransmit(Handle timer, any entity)
{
	if ((entity = EntRefToEntIndex(entity)) == INVALID_ENT_REFERENCE)
	{
		return Plugin_Stop;
	}
	if (IsValidEntity(entity))
	{
		SDKHook(entity, SDKHook_SetTransmit, SetTransmit);
	}
	return Plugin_Continue;
}

public Action tTimerUpdatePlayerCount(Handle timer)
{
	if (g_iEnable == 0 || !bIsSystemValid(g_cvSTFindConVar[1], g_sEnabledGameModes, g_sDisabledGameModes) || StrContains(g_sConfigExecute, "5") == -1)
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
	if (g_iEnable == 0 || !bIsSystemValid(g_cvSTFindConVar[1], g_sEnabledGameModes, g_sDisabledGameModes))
	{
		return Plugin_Continue;
	}
	if (g_iDisplayHealth > 0)
	{
		for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
		{
			if (bIsHumanSurvivor(iSurvivor))
			{
				int iTarget = GetClientAimTarget(iSurvivor, false);
				if (IsValidEntity(iTarget))
				{
					char sClassname[32];
					GetEntityClassname(iTarget, sClassname, sizeof(sClassname));
					if (strcmp(sClassname, "player") == 0)
					{
						if (bIsTank(iTarget) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(iTarget))))
						{
							int iHealth = GetClientHealth(iTarget);
							switch (g_iDisplayHealth)
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
	if (g_iEnable == 0 || !bIsSystemValid(g_cvSTFindConVar[1], g_sEnabledGameModes, g_sDisabledGameModes))
	{
		return Plugin_Continue;
	}
	g_cvSTFindConVar[10].SetString("32");
	if (iGetTankCount() > 0)
	{
		for (int iTank = 1; iTank <= MaxClients; iTank++)
		{
			if (bIsTank(iTank) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(iTank))))
			{
				vCommonAbility(iTank, g_iCommonAbility[g_iTankType[iTank]]);
				vFlashAbility(iTank, g_iFlashAbility[g_iTankType[iTank]]);
				vGhostAbility(iTank, g_iGhostAbility[g_iTankType[iTank]]);
				vGravityAbility(iTank, g_iGravityAbility[g_iTankType[iTank]]);
				vHealAbility(iTank, g_iHealAbility[g_iTankType[iTank]]);
				vMeteorAbility(iTank, g_iMeteorAbility[g_iTankType[iTank]]);
				vSpamAbility(iTank, g_iSpamAbility[g_iTankType[iTank]]);
				vWarpAbility(iTank, g_iWarpAbility[g_iTankType[iTank]]);
				vWitchAbility(iTank, g_iWitchAbility[g_iTankType[iTank]]);
				if (g_iFireImmunity[g_iTankType[iTank]] == 1 && bIsPlayerBurning(iTank))
				{
					ExtinguishEntity(iTank);
					SetEntPropFloat(iTank, Prop_Send, "m_burnPercent", 1.0);
				}
				SetEntPropFloat(iTank, Prop_Data, "m_flLaggedMovementValue", g_flRunSpeed[g_iTankType[iTank]]);
			}
		}
	}
	return Plugin_Continue;
}

public Action tTimerTankSpawn(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (bIsTank(client) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(client))))
	{
		vJumperAbility(client, g_iJumperAbility[g_iTankType[client]]);
		if (!g_bShielded[client])
		{
			vShieldAbility(client, true, g_iShieldAbility[g_iTankType[client]]);
		}
		vSmokerEffect(client, g_iSmokeEffect[g_iTankType[client]]);
		vSetName(client, g_sCustomName[g_iTankType[client]]);
		if (g_iExtraHealth[g_iTankType[client]] > 0)
		{
			vSetHealth(client, g_iExtraHealth[g_iTankType[client]]);
		}
		vThrowInterval(client, g_flThrowInterval[g_iTankType[client]]);
	}
	return Plugin_Continue;
}

public Action tTimerRockThrow(Handle timer, any entity)
{
	if ((entity = EntRefToEntIndex(entity)) == INVALID_ENT_REFERENCE)
	{
		return Plugin_Stop;
	}
	int iThrower = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
	if (iThrower > 0 && bIsTank(iThrower) && (g_iHumanSupport == 1 || (g_iHumanSupport == 0 && IsFakeClient(iThrower))))
	{
		if (g_iInfectedThrow[g_iTankType[iThrower]] == 1)
		{
			DataPack dpDataPack;
			CreateDataTimer(0.1, tTimerInfectedThrow, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpDataPack.WriteCell(GetClientUserId(iThrower));
			dpDataPack.WriteCell(EntIndexToEntRef(entity));
		}
		if (g_iShieldAbility[g_iTankType[iThrower]] == 1)
		{
			DataPack dpDataPack;
			CreateDataTimer(0.1, tTimerPropaneThrow, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpDataPack.WriteCell(GetClientUserId(iThrower));
			dpDataPack.WriteCell(EntIndexToEntRef(entity));
		}
	}
	return Plugin_Continue;
}

public Action tTimerSpawnTanks(Handle timer, any wave)
{
	vSpawnTank(wave);
}

public Action tTimerTankWave2(Handle timer)
{
	if (iGetTankCount() == 0)
	{
		g_iTankWave = 2;
	}
}
public Action tTimerTankWave3(Handle timer)
{
	if (iGetTankCount() == 0)
	{
		g_iTankWave = 3;
	}
}