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

/* 36 Super Tanks
 * Acid
 * Ammo
 * Blind
 * Bomb
 * Boomer
 * Charger
 * Clone
 * Common
 * Drug
 * Fire
 * Flash
 * Fling
 * Ghost
 * Gravity
 * Heal
 * Hunter
 * Hypno
 * Ice
 * Idle
 * Invert
 * Jockey
 * Jumper
 * Meteor
 * Puke
 * Restart
 * Rocket
 * Shake
 * Shield
 * Shove
 * Slug
 * Smoker
 * Spitter
 * Stun
 * Vision
 * Warp
 * Witch
 */

#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_WITCH "models/infected/witch.mdl"
#define MODEL_WITCHBRIDE "models/infected/witch_bride.mdl"
#define MODEL_TIRES "models/props_vehicles/tire001c_car.mdl"
#define MODEL_SHIELD "models/props_unique/airport/atlas_break_ball.mdl"
#define MODEL_JETPACK "models/props_equipment/oxygentank01.mdl"
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
bool g_bCmdUsed;
bool g_bFlash[MAXPLAYERS + 1];
bool g_bHeadshot[MAXPLAYERS + 1];
bool g_bHypno[MAXPLAYERS + 1];
bool g_bIdle[MAXPLAYERS + 1];
bool g_bInvert[MAXPLAYERS + 1];
bool g_bLateLoad;
bool g_bMeteor[MAXPLAYERS + 1];
bool g_bRestartValid;
bool g_bShielded[MAXPLAYERS + 1];
char g_sWeapon[32];
char g_sConfigOption[6];
ConVar g_cvSTAcidChance;
ConVar g_cvSTAmmoChance;
ConVar g_cvSTAmmoCount;
ConVar g_cvSTAnnounceArrival;
ConVar g_cvSTAttachProps[37];
ConVar g_cvSTBlindChance;
ConVar g_cvSTBlindDuration;
ConVar g_cvSTBombChance;
ConVar g_cvSTBoomerLimit;
ConVar g_cvSTChargerLimit;
ConVar g_cvSTCommonInterval;
ConVar g_cvSTConfigCreate;
ConVar g_cvSTConfigEnable;
ConVar g_cvSTConfigExecute;
ConVar g_cvSTConfigTimeOffset;
ConVar g_cvSTDisabledGameModes;
ConVar g_cvSTDisplayHealth;
ConVar g_cvSTDrugChance;
ConVar g_cvSTDrugDuration;
ConVar g_cvSTEnable;
ConVar g_cvSTEnabledGameModes;
ConVar g_cvSTExtraHealth[37];
ConVar g_cvSTFinalesOnly;
ConVar g_cvSTFireChance;
ConVar g_cvSTFireImmunity[37];
ConVar g_cvSTFlashChance;
ConVar g_cvSTFlashSpeed;
ConVar g_cvSTFlingChance;
ConVar g_cvSTGameDifficulty;
ConVar g_cvSTGameMode;
ConVar g_cvSTGameModeTypes;
ConVar g_cvSTGameTypes;
ConVar g_cvSTGhostChance;
ConVar g_cvSTGhostSlot;
ConVar g_cvSTGravityChance;
ConVar g_cvSTGravityForce;
ConVar g_cvSTHealChance;
ConVar g_cvSTHealCommon;
ConVar g_cvSTHealIncapCount;
ConVar g_cvSTHealInterval;
ConVar g_cvSTHealSpecial;
ConVar g_cvSTHealTank;
ConVar g_cvSTHunterLimit;
ConVar g_cvSTHypnoChance;
ConVar g_cvSTHypnoDuration;
ConVar g_cvSTIceChance;
ConVar g_cvSTIdleChance;
ConVar g_cvSTInvertChance;
ConVar g_cvSTInvertDuration;
ConVar g_cvSTJockeyLimit;
ConVar g_cvSTJumperChance;
ConVar g_cvSTJumperInterval;
ConVar g_cvSTMaxPlayerZombies;
ConVar g_cvSTMeteorChance;
ConVar g_cvSTMeteorDamage;
ConVar g_cvSTPukeChance;
ConVar g_cvSTRestartChance;
ConVar g_cvSTRestartLoadout;
ConVar g_cvSTRocketChance;
ConVar g_cvSTRunSpeed[37];
ConVar g_cvSTShakeChance;
ConVar g_cvSTShakeDuration;
ConVar g_cvSTShieldDelay;
ConVar g_cvSTShoveChance;
ConVar g_cvSTShoveDuration;
ConVar g_cvSTSlugChance;
ConVar g_cvSTSmokerLimit;
ConVar g_cvSTSpitterLimit;
ConVar g_cvSTStunChance;
ConVar g_cvSTStunDuration;
ConVar g_cvSTStunSpeed;
ConVar g_cvSTTankThrowForce;
ConVar g_cvSTTankTypes;
ConVar g_cvSTTankWaves;
ConVar g_cvSTThrowInterval[37];
ConVar g_cvSTVisualChance;
ConVar g_cvSTVisualDuration;
ConVar g_cvSTVisualFOV;
ConVar g_cvSTWarpInterval;
float g_flDrugAngles[20] = {0.0, 5.0, 10.0, 15.0, 20.0, 25.0, 20.0, 15.0, 10.0, 5.0, 0.0, -5.0, -10.0, -15.0, -20.0, -25.0, -20.0, -15.0, -10.0, -5.0};
float g_flIce[3];
float g_flSpawnPosition[3];
Handle g_hCommonTimer[MAXPLAYERS + 1];
Handle g_hDrugTimer[MAXPLAYERS + 1];
Handle g_hFlashTimer[MAXPLAYERS + 1];
Handle g_hHealTimer[MAXPLAYERS + 1];
Handle g_hJumpTimer[MAXPLAYERS + 1];
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
Handle g_hVisionTimer[MAXPLAYERS + 1];
int g_iExplosionSprite = -1;
int g_iInterval;
int g_iRocket[MAXPLAYERS + 1];
int g_iShockSprite = -1;
int g_iTankType[MAXPLAYERS + 1];
int g_iTankWave;
int g_iType;
StringMap g_smConVars;
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
	vMultiTargetFilters(1);
	RegAdminCmd("sm_tank", cmdTank, ADMFLAG_ROOT, "Spawn a Super Tank.");
	g_smConVars = new StringMap();
	vST_CreateConfig(true);
	vST_CreateDirectory(true);
	bST_Config("super_tanks++");
	vCreateConVar(g_cvSTAnnounceArrival, "st_announcearrival", "1", "Announce each Super Tank's arrival?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTDisabledGameModes, "st_disabledgamemodes", "", "Disable Super Tanks++ in these game modes.\nSeparate game modes with commas.\nGame mode limit: 64\nCharacter limit for each game mode: 32\n(Empty: None)\n(Not empty: Disabled only in these game modes.)");
	vCreateConVar(g_cvSTDisplayHealth, "st_displayhealth", "3", "Display Tanks' names and health?\n(0: OFF)\n(1: ON, show names only.)\n(2: ON, show health only.)\n(3: ON, show both names and health.)", _, true, 0.0, true, 3.0);
	vCreateConVar(g_cvSTEnable, "st_enable", "1", "Enable Super Tanks++?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTEnabledGameModes, "st_enabledgamemodes", "", "Enable Super Tanks++ in these game modes.\nSeparate game modes with commas.\nGame mode limit: 64\nCharacter limit for each game mode: 32\n(Empty: All)\n(Not empty: Enabled only in these game modes.)");
	vCreateConVar(g_cvSTFinalesOnly, "st_finalesonly", "0", "Enable Super Tanks++ in finales only?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTGameModeTypes, "st_gamemodetypes", "0", "Enable Super Tanks++ in these game mode types.\nAdd numbers up together.\n(0: All 4 types.)\n(1: Co-Op modes only.)\n(2: Versus modes only.)\n(4: Survival modes only.)\n(8: Scavenge modes only.)", _, true, 0.0, true, 15.0);
	cvST_ConVar("st_pluginversion", ST_VERSION, "Super Tanks++ Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	vCreateConVar(g_cvSTTankTypes, "st_tanktypes", "0123456789abcdefghijklmnopqrstuvwxyz", "Which Super Tank types can be spawned?\nCombine letters and numbers in any order for different results.\nRepeat the same letter or number to increase its chance of being chosen.\nCharacter limit: 52\nView the README.md file for a list of options.");
	vCreateConVar(g_cvSTTankWaves, "st_tankwaves", "2,3,4", "How many Tanks to spawn for each finale wave?\n(1st number = 1st wave)\n(2nd number = 2nd wave)\n(3rd number = 3rd wave)");
	vCreateConVar(g_cvSTAcidChance, "stacid_acidchance", "4", "Acid Tank has 1 out of this many chances to spawn an acid puddle underneath survivors.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[1], "stacid_attachprops", "1234", "Attach props to Acid Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[1], "stacid_extrahealth", "0", "Extra health given to Acid Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[1], "stacid_fireimmunity", "0", "Give Acid Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[1], "stacid_runspeed", "1.0", "Acid Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[1], "stacid_throwinterval", "5.0", "Acid Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAmmoChance, "stammo_ammochance", "4", "Ammo Tank has 1 out of this many chances to take away survivors' ammunition.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAmmoCount, "stammo_ammocount", "0", "Ammo Tanks can set survivors' ammunition count to this number.", _, true, 0.0, true, 100.0);
	vCreateConVar(g_cvSTAttachProps[2], "stammo_attachprops", "1234", "Attach props to Ammo Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[2], "stammo_extrahealth", "0", "Extra health given to Ammo Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[2], "stammo_fireimmunity", "0", "Give Ammo Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[2], "stammo_runspeed", "1.0", "Ammo Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[2], "stammo_throwinterval", "5.0", "Ammo Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[3], "stblind_attachprops", "1234", "Attach props to Blind Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTBlindChance, "stblind_blindchance", "4", "Blind Tank has 1 out of this many chances to make survivors blind.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTBlindDuration, "stblind_duration", "5.0", "Blind Tank's blind effect lasts this long.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTExtraHealth[3], "stblind_extrahealth", "0", "Extra health given to Blind Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[3], "stblind_fireimmunity", "0", "Give Blind Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[3], "stblind_runspeed", "1.0", "Blind Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[3], "stblind_throwinterval", "5.0", "Blind Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[4], "stbomb_attachprops", "1234", "Attach props to Bomb Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTBombChance, "stbomb_bombchance", "4", "Bomb Tank has 1 out of this many chances to cause an explosion.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTExtraHealth[4], "stbomb_extrahealth", "0", "Extra health given to Bomb Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[4], "stbomb_fireimmunity", "0", "Give Bomb Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[4], "stbomb_runspeed", "1.0", "Bomb Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[4], "stbomb_throwinterval", "5.0", "Bomb Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[5], "stboomer_attachprops", "1234", "Attach props to Boomer Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[5], "stboomer_extrahealth", "0", "Extra health given to Boomer Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[5], "stboomer_fireimmunity", "0", "Give Boomer Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[5], "stboomer_runspeed", "1.0", "Boomer Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[5], "stboomer_throwinterval", "5.0", "Boomer Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[6], "stcharger_attachprops", "1234", "Attach props to Charger Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[6], "stcharger_extrahealth", "0", "Extra health given to Charger Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[6], "stcharger_fireimmunity", "0", "Give Charger Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[6], "stcharger_runspeed", "1.0", "Charger Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[6], "stcharger_throwinterval", "5.0", "Charger Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[7], "stclone_attachprops", "1234", "Attach props to Clone Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[7], "stclone_extrahealth", "0", "Extra health given to Clone Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[7], "stclone_fireimmunity", "0", "Give Clone Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[7], "stclone_runspeed", "1.0", "Clone Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[7], "stclone_throwinterval", "5.0", "Clone Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[8], "stcommon_attachprops", "1234", "Attach props to Common Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[8], "stcommon_extrahealth", "0", "Extra health given to Common Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[8], "stcommon_fireimmunity", "0", "Give Common Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[8], "stcommon_runspeed", "1.0", "Common Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTCommonInterval, "stcommon_spawninterval", "15.0", "Common Tank's common infected mob spawn interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTThrowInterval[8], "stcommon_throwinterval", "5.0", "Common Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTConfigCreate, "stconfig_createtype", "31425", "Which type of custom config should Super Tanks++ create?\nCombine numbers in any order for different results.\nCharacter limit: 5\n(1: Difficulties)\n(2: Maps)\n(3: Game modes)\n(4: Days)\n(5: Player count)");
	vCreateConVar(g_cvSTConfigEnable, "stconfig_enable", "1", "Enable Super Tanks++ custom configuration?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTConfigExecute, "stconfig_executetype", "1", "Which type of custom config should Super Tanks++ execute?\nCombine numbers in any order for different results.\nCharacter limit: 5\n(1: Difficulties)\n(2: Maps)\n(3: Game modes)\n(4: Days)\n(5: Player count)");
	vCreateConVar(g_cvSTConfigTimeOffset, "stconfig_timeoffset", "", "What is the time offset of the server?\nHow it works:\nServer time + stconfig_timeoffset\nExample:\nstconfig_timeoffset \"+10\"\n12:00 PM + 10 = 10:00 PM\nstconfig_timeoffset \"-10\"\n12:00 PM - 10 = 2:00 AM");
	vCreateConVar(g_cvSTExtraHealth[0], "stdefault_extrahealth", "0", "Extra health given to Default Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[0], "stdefault_fireimmunity", "0", "Give Default Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[0], "stdefault_runspeed", "1.0", "Default Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[0], "stdefault_throwinterval", "5.0", "Default Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[9], "stdrug_attachprops", "1234", "Attach props to Drug Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTDrugChance, "stdrug_drugchance", "4", "Drug Tank has 1 out of this many chances to drug survivors.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTDrugDuration, "stdrug_duration", "5.0", "Drug Tank's drug effect lasts this long.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTExtraHealth[9], "stdrug_extrahealth", "0", "Extra health given to Drug Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[9], "stdrug_fireimmunity", "0", "Give Drug Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[9], "stdrug_runspeed", "1.0", "Drug Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[9], "stdrug_throwinterval", "5.0", "Drug Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[10], "stfire_attachprops", "1234", "Attach props to Fire Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[10], "stfire_extrahealth", "0", "Extra health given to Fire Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireChance, "stfire_firechance", "4", "Fire Tank has 1 out of this many chances to cause a fire.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[10], "stfire_fireimmunity", "0", "Give Fire Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[10], "stfire_runspeed", "1.0", "Fire Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[10], "stfire_throwinterval", "5.0", "Fire Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[11], "stflash_attachprops", "1234", "Attach props to Flash Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[11], "stflash_extrahealth", "0", "Extra health given to Flash Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[11], "stflash_fireimmunity", "0", "Give Flash Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTFlashChance, "stflash_flashchance", "3", "Flash Tank has 1 out of this many chances to use its special speed.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTRunSpeed[11], "stflash_runspeed", "3.0", "Flash Tank's run speed.", _, true, 0.1, true, 3.0);
	vCreateConVar(g_cvSTFlashSpeed, "stflash_specialspeed", "5.0", "Flash Tank's special speed.", _, true, 3.0, true, 5.0);
	vCreateConVar(g_cvSTThrowInterval[11], "stflash_throwinterval", "5.0", "Flash Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[12], "stfling_attachprops", "1234", "Attach props to Fling Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[12], "stfling_extrahealth", "0", "Extra health given to Fling Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[12], "stfling_fireimmunity", "0", "Give Fling Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTFlingChance, "stfling_flingchance", "4", "Fling Tank has 1 out of this many chances to fling survivors into the air.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTRunSpeed[12], "stfling_runspeed", "1.0", "Fling Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[12], "stfling_throwinterval", "5.0", "Fling Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[13], "stghost_attachprops", "1234", "Attach props to Ghost Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[13], "stghost_extrahealth", "0", "Extra health given to Ghost Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[13], "stghost_fireimmunity", "0", "Give Ghost Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTGhostChance, "stghost_ghostchance", "4", "Ghost Tank has 1 out of this many chances to disarm survivors.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTRunSpeed[13], "stghost_runspeed", "1.0", "Ghost Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[13], "stghost_throwinterval", "5.0", "Ghost Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTGhostSlot, "stghost_weaponslot", "12345", "Which weapon slots can Ghost Tank disarm?\nCombine numbers in any order for different results.\nCharacter limit: 5\n(1: 1st slot only.)\n(2: 2nd slot only.)\n(3: 3rd slot only.)\n(4: 4th slot only.)\n(5: 5th slot only.)");
	vCreateConVar(g_cvSTAttachProps[14], "stgravity_attachprops", "1234", "Attach props to Gravity Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[14], "stgravity_extrahealth", "0", "Extra health given to Gravity Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[14], "stgravity_fireimmunity", "0", "Give Gravity Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTGravityChance, "stgravity_gravitychance", "4", "Gravity Tank has 1 out of this many chances to change survivors' gravity'.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTGravityForce, "stgravity_gravityforce", "-50.0", "Gravity Tank's force.\n(Positive numbers = Push back)\n(Negative numbers = Pull back)", _, true, -100.0, true, 100.0);
	vCreateConVar(g_cvSTRunSpeed[14], "stgravity_runspeed", "1.0", "Gravity Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[14], "stgravity_throwinterval", "5.0", "Gravity Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[15], "stheal_attachprops", "1234", "Attach props to Heal Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTHealCommon, "stheal_commonamount", "100", "Health absorbed from common infected.", _, true, 0.0, true, 1000.0);
	vCreateConVar(g_cvSTExtraHealth[15], "stheal_extrahealth", "0", "Extra health given to Heal Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[15], "stheal_fireimmunity", "0", "Give Heal Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTHealChance, "stheal_healchance", "4", "Heal Tank has 1 out of this many chances to make survivors black and white with temporary health.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTHealInterval, "stheal_healinterval", "5.0", "Heal Tank's heal interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTRunSpeed[15], "stheal_runspeed", "1.0", "Heal Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTHealSpecial, "stheal_specialamount", "500", "Health absorbed from other special infected.", _, true, 0.0, true, 10000.0);
	vCreateConVar(g_cvSTHealTank, "stheal_tankamount", "500", "Health absorbed from other Tanks.", _, true, 0.0, true, 100000.0);
	vCreateConVar(g_cvSTThrowInterval[15], "stheal_throwinterval", "5.0", "Heal Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[16], "sthunter_attachprops", "1234", "Attach props to Hunter Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[16], "sthunter_extrahealth", "0", "Extra health given to Hunter Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[16], "sthunter_fireimmunity", "0", "Give Hunter Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[16], "sthunter_runspeed", "1.0", "Hunter Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[16], "sthunter_throwinterval", "5.0", "Hunter Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[17], "sthypno_attachprops", "1234", "Attach props to Hypno Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTHypnoDuration, "sthypno_duration", "5.0", "Hypno Tank's hypnosis effect lasts this long.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTExtraHealth[17], "sthypno_extrahealth", "0", "Extra health given to Hypno Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[17], "sthypno_fireimmunity", "0", "Give Hypno Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTHypnoChance, "sthypno_hypnochance", "4", "Hypno Tank has 1 out of this many chances to hypnotize survivors.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTRunSpeed[17], "sthypno_runspeed", "1.0", "Hypno Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[17], "sthypno_throwinterval", "5.0", "Hypno Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[18], "stice_attachprops", "1234", "Attach props to Ice Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[18], "stice_extrahealth", "0", "Extra health given to Ice Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[18], "stice_fireimmunity", "0", "Give Ice Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTIceChance, "stice_icechance", "4", "Ice Tank has 1 out of this many chances to freeze survivors.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTRunSpeed[18], "stice_runspeed", "1.0", "Ice Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[18], "stice_throwinterval", "5.0", "Ice Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[19], "stidle_attachprops", "1234", "Attach props to Idle Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[19], "stidle_extrahealth", "0", "Extra health given to Idle Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[19], "stidle_fireimmunity", "0", "Give Idle Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTIdleChance, "stidle_idlechance", "4", "Idle Tank has 1 out of this many chances to make survivors go idle.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTRunSpeed[19], "stidle_runspeed", "1.0", "Idle Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[19], "stidle_throwinterval", "5.0", "Idle Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[20], "stinvert_attachprops", "1234", "Attach props to Invert Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTInvertDuration, "stinvert_duration", "5.0", "Invert Tank's inversion effect lasts this long.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTExtraHealth[20], "stinvert_extrahealth", "0", "Extra health given to Invert Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[20], "stinvert_fireimmunity", "0", "Give Invert Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTInvertChance, "stinvert_invertchance", "4", "Invert Tank has 1 out of this many chances to invert survivors' movement keys.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTRunSpeed[20], "stinvert_runspeed", "1.0", "Invert Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[20], "stinvert_throwinterval", "5.0", "Invert Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[21], "stjockey_attachprops", "1234", "Attach props to Jockey Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[21], "stjockey_extrahealth", "0", "Extra health given to Jockey Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[21], "stjockey_fireimmunity", "0", "Give Jockey Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[21], "stjockey_runspeed", "1.0", "Jockey Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[21], "stjockey_throwinterval", "5.0", "Jockey Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[22], "stjumper_attachprops", "1234", "Attach props to Jumper Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTJumperChance, "stjumper_jumpchance", "3", "Jumper Tank has 1 out of this many chances to jump into the air.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTJumperInterval, "stjumper_jumpinterval", "5.0", "Jumper Tank's jump interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTExtraHealth[22], "stjumper_extrahealth", "0", "Extra health given to Jumper Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[22], "stjumper_fireimmunity", "0", "Give Jumper Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[22], "stjumper_runspeed", "1.0", "Jumper Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[22], "stjumper_throwinterval", "5.0", "Jumper Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[23], "stmeteor_attachprops", "1234", "Attach props to Meteor Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[23], "stmeteor_extrahealth", "0", "Extra health given to Meteor Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[23], "stmeteor_fireimmunity", "0", "Give Meteor Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTMeteorChance, "stmeteor_meteorchance", "4", "Meteor Tank has 1 out of this many chances to start a meteor shower.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTMeteorDamage, "stmeteor_meteordamage", "25.0", "Meteor Tank's meteor shower does this much damage.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTRunSpeed[23], "stmeteor_runspeed", "1.0", "Meteor Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[23], "stmeteor_throwinterval", "5.0", "Meteor Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[24], "stpuke_attachprops", "1234", "Attach props to Puke Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[24], "stpuke_extrahealth", "0", "Extra health given to Puke Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[24], "stpuke_fireimmunity", "0", "Give Puke Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTPukeChance, "stpuke_pukechance", "4", "Puke Tank has 1 out of this many chances to puke on survivors.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTRunSpeed[24], "stpuke_runspeed", "1.0", "Puke Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[24], "stpuke_throwinterval", "5.0", "Puke Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[25], "strestart_attachprops", "1234", "Attach props to Restart Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[25], "strestart_extrahealth", "0", "Extra health given to Restart Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[25], "strestart_fireimmunity", "0", "Give Restart Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRestartLoadout, "strestart_loadout", "smg,pistol,pain_pills", "Restart Tank makes survivors restart with this loadout.\nSeparate items with commas.\nItem limit: 5\nValid formats:\n1. \"rifle,smg,pistol,pain_pills,pipe_bomb\"\n2. \"pain_pills,molotov,first_aid_kit,autoshotgun\"\n3. \"hunting_rifle,rifle,smg\"\n4. \"autoshotgun,pistol\"\n5. \"molotov\"");
	vCreateConVar(g_cvSTRestartChance, "strestart_restartchance", "4", "Restart Tank has 1 out of this many chances to make survivors restart.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTRunSpeed[25], "strestart_runspeed", "1.0", "Restart Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[25], "strestart_throwinterval", "5.0", "Restart Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[26], "strocket_attachprops", "1234", "Attach props to Rocket Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[26], "strocket_extrahealth", "0", "Extra health given to Rocket Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[26], "strocket_fireimmunity", "0", "Give Rocket Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRocketChance, "strocket_rocketchance", "4", "Rocket Tank has 1 out of this many chances to send survivors into space.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTRunSpeed[26], "strocket_runspeed", "1.0", "Rocket Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[26], "strocket_throwinterval", "5.0", "Rocket Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[27], "stshake_attachprops", "1234", "Attach props to Shake Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTShakeDuration, "stshake_duration", "5.0", "Shake Tank's shake effect lasts this long.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTExtraHealth[27], "stshake_extrahealth", "0", "Extra health given to Shake Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[27], "stshake_fireimmunity", "0", "Give Shake Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[27], "stshake_runspeed", "1.0", "Shake Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTShakeChance, "stshake_shakechance", "4", "Shake Tank has 1 out of this many chances to shake survivors' screens.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTThrowInterval[27], "stshake_throwinterval", "5.0", "Shake Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[28], "stshield_attachprops", "1234", "Attach props to Shield Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[28], "stshield_extrahealth", "0", "Extra health given to Shield Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[28], "stshield_fireimmunity", "0", "Give Shield Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[28], "stshield_runspeed", "1.0", "Shield Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTShieldDelay, "stshield_shielddelay", "7.5", "Shield Tank's shield reactivates after this many seconds.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTThrowInterval[28], "stshield_throwinterval", "5.0", "Shield Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[29], "stshove_attachprops", "1234", "Attach props to Shove Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTShoveDuration, "stshove_duration", "5.0", "Shove Tank's shove effect lasts this long.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTExtraHealth[29], "stshove_extrahealth", "0", "Extra health given to Shove Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[29], "stshove_fireimmunity", "0", "Give Shove Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[29], "stshove_runspeed", "1.0", "Shove Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTShoveChance, "stshove_shovechance", "4", "Shove Tank has 1 out of this many chances to shove survivors.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTThrowInterval[29], "stshove_throwinterval", "5.0", "Shove Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[30], "stslug_attachprops", "1234", "Attach props to Slug Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[30], "stslug_extrahealth", "0", "Extra health given to Slug Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[30], "stslug_fireimmunity", "0", "Give Slug Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[30], "stslug_runspeed", "0.5", "Slug Tank's run speed.", _, true, 0.1, true, 0.5);
	vCreateConVar(g_cvSTSlugChance, "stslug_slugchance", "4", "Slug Tank has 1 out of this many chances to smite survivors.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTThrowInterval[30], "stslug_throwinterval", "5.0", "Slug Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[31], "stsmoker_attachprops", "1234", "Attach props to Smoker Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[31], "stsmoker_extrahealth", "0", "Extra health given to Smoker Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[31], "stsmoker_fireimmunity", "0", "Give Smoker Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[31], "stsmoker_runspeed", "1.0", "Smoker Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[31], "stsmoker_throwinterval", "5.0", "Smoker Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[32], "stspitter_attachprops", "1234", "Attach props to Spitter Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[32], "stspitter_extrahealth", "0", "Extra health given to Spitter Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[32], "stspitter_fireimmunity", "0", "Give Spitter Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[32], "stspitter_runspeed", "1.0", "Spitter Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[32], "stspitter_throwinterval", "5.0", "Spitter Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[33], "ststun_attachprops", "1234", "Attach props to Stun Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTStunDuration, "ststun_duration", "5.0", "Stun Tank's stun effect lasts this long.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTExtraHealth[33], "ststun_extrahealth", "0", "Extra health given to Stun Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[33], "ststun_fireimmunity", "0", "Give Stun Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[33], "ststun_runspeed", "1.0", "Stun Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTStunChance, "ststun_stunchance", "4", "Stun Tank has 1 out of this many chances to stun survivors.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTStunSpeed, "ststun_stunspeed", "0.25", "Stun Tank can set survivors' run speed to this amount.", _, true, 0.1, true, 0.99);
	vCreateConVar(g_cvSTThrowInterval[33], "ststun_throwinterval", "5.0", "Stun Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[34], "stvisual_attachprops", "1234", "Attach props to Visual Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTVisualDuration, "stvisual_duration", "5.0", "Visual Tank's visual effect lasts this long.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTExtraHealth[34], "stvisual_extrahealth", "0", "Extra health given to Visual Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[34], "stvisual_fireimmunity", "0", "Give Visual Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTVisualFOV, "stvisual_fov", "160", "Visual Tank can set survivors' field of view to this amount.", _, true, 1.0, true, 160.0);
	vCreateConVar(g_cvSTRunSpeed[34], "stvisual_runspeed", "1.0", "Visual Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[34], "stvisual_throwinterval", "5.0", "Visual Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTVisualChance, "stvisual_visualchance", "4", "Visual Tank has 1 out of this many chances to change survivors' field of views.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[35], "stwarp_attachprops", "1234", "Attach props to Warp Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[35], "stwarp_extrahealth", "0", "Extra health given to Warp Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[35], "stwarp_fireimmunity", "0", "Give Warp Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[35], "stwarp_runspeed", "1.0", "Warp Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[35], "stwarp_throwinterval", "5.0", "Warp Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTWarpInterval, "stwarp_warpinterval", "10", "Warp Tank's warp interval.", _, true, 1.0, true, 99999.0);
	vCreateConVar(g_cvSTAttachProps[36], "stwitch_attachprops", "1234", "Attach props to Witch Tank?\nCombine numbers in any order for different results.\nCharacter limit: 4\n(1: attach lights only.)\n(2: attach oxygen tanks only.)\n(3: attach rocks only.)\n(4: attach tires only.)");
	vCreateConVar(g_cvSTExtraHealth[36], "stwitch_extrahealth", "0", "Extra health given to Witch Tank.", _, true, 0.0, true, 99999.0);
	vCreateConVar(g_cvSTFireImmunity[36], "stwitch_fireimmunity", "0", "Give Witch Tank fire immunity?\n(0: OFF)\n(1: ON)", _, true, 0.0, true, 1.0);
	vCreateConVar(g_cvSTRunSpeed[36], "stwitch_runspeed", "1.0", "Witch Tank's run speed.", _, true, 0.1, true, 2.0);
	vCreateConVar(g_cvSTThrowInterval[36], "stwitch_throwinterval", "5.0", "Witch Tank's rock throw interval.", _, true, 1.0, true, 99999.0);
	vST_ExecConfig();
	iST_Clean();
	g_cvSTGameDifficulty = FindConVar("z_difficulty");
	g_cvSTGameMode = FindConVar("mp_gamemode");
	g_cvSTGameTypes = FindConVar("sv_gametypes");
	g_cvSTHealIncapCount = FindConVar("survivor_max_incapacitated_count");
	g_cvSTMaxPlayerZombies = FindConVar("z_max_player_zombies");
	g_cvSTTankThrowForce = FindConVar("z_tank_throw_force");
	bIsL4D2Game() ? (g_cvSTBoomerLimit = FindConVar("z_boomer_limit")) : (g_cvSTBoomerLimit = FindConVar("z_exploding_limit"));
	g_cvSTHunterLimit = FindConVar("z_hunter_limit");
	bIsL4D2Game() ? (g_cvSTSmokerLimit = FindConVar("z_smoker_limit")) : (g_cvSTSmokerLimit = FindConVar("z_gas_limit"));
	if (bIsL4D2Game())
	{
		g_cvSTChargerLimit = FindConVar("z_charger_limit");
		g_cvSTJockeyLimit = FindConVar("z_jockey_limit");
		g_cvSTSpitterLimit = FindConVar("z_spitter_limit");
	}
	g_cvSTGameDifficulty.AddChangeHook(vSTGameDifficultyCvar);
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
		StartPrepSDKCall(SDKCall_Entity);
		PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "CSpitterProjectile_Detonate");
		g_hSDKAcidPlayer = EndPrepSDKCall();
		if (g_hSDKAcidPlayer == null)
		{
			PrintToServer("%s Your \"CSpitterProjectile_Detonate\" signature is outdated.", ST_PREFIX);
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
	if (g_cvSTEnable.BoolValue && bIsSystemValid(g_cvSTGameMode, g_cvSTEnabledGameModes, g_cvSTDisabledGameModes, g_cvSTGameModeTypes))
	{
		g_bCmdUsed = false;
		g_bRestartValid = false;
		g_iInterval = 0;
		CreateTimer(0.1, tTimerTankHealthUpdate, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerTankTypeUpdate, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		CreateTimer(1.0, tTimerUpdatePlayerCount, _, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		PrecacheModel(MODEL_GASCAN, true);
		PrecacheModel(MODEL_PROPANETANK, true);
		PrecacheModel(MODEL_WITCH, true);
		PrecacheModel(MODEL_WITCHBRIDE, true);
		PrecacheModel(MODEL_TIRES, true);
		PrecacheModel(MODEL_SHIELD, true);
		PrecacheModel(MODEL_JETPACK, true);
		g_iExplosionSprite = PrecacheModel(SPRITE_FIRE, true);
		g_iShockSprite = PrecacheModel(SPRITE_GLOW);
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
	g_bCmdUsed = false;
	g_bRestartValid = false;
	g_cvSTConfigCreate.GetString(g_sConfigOption, sizeof(g_sConfigOption));
	if (StrContains(g_sConfigOption, "1", false) != -1)
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
	if (StrContains(g_sConfigOption, "2", false) != -1)
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
	if (StrContains(g_sConfigOption, "3", false) != -1)
	{
		CreateDirectory((bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_gamemode_configs/" : "cfg/sourcemod/super_tanks++/l4d_gamemode_configs/"), 511);
		char sGameType[2049];
		char sTypes[64][32];
		g_cvSTGameTypes.GetString(sGameType, sizeof(sGameType));
		ExplodeString(sGameType, ",", sTypes, sizeof(sTypes), sizeof(sTypes[]));
		for (int iMode = 0; iMode < sizeof(sTypes); iMode++)
		{
			if (StrContains(sGameType, sTypes[iMode], false) != -1 && sTypes[iMode][0] != '\0')
			{
				vCreateConfigFile("cfg/sourcemod/super_tanks++/", (bIsL4D2Game() ? "l4d2_gamemode_configs/" : "l4d_gamemode_configs/"), sTypes[iMode], sTypes[iMode]);
			}
		}
	}
	if (StrContains(g_sConfigOption, "4", false) != -1)
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
	if (StrContains(g_sConfigOption, "5", false) != -1)
	{
		CreateDirectory("cfg/sourcemod/super_tanks++/playercount_configs/", 511);
		char sPlayerCount[32];
		for (int iCount = 0; iCount <= MAXPLAYERS + 1; iCount++)
		{
			IntToString(iCount, sPlayerCount, sizeof(sPlayerCount));
			vCreateConfigFile("cfg/sourcemod/super_tanks++/", "playercount_configs/", sPlayerCount, sPlayerCount);
		}
	}
	g_cvSTConfigExecute.GetString(g_sConfigOption, sizeof(g_sConfigOption));
	if (StrContains(g_sConfigOption, "1", false) != -1 && g_cvSTGameDifficulty != null)
	{
		char sDifficultyConfig[512];
		g_cvSTGameDifficulty.GetString(sDifficultyConfig, sizeof(sDifficultyConfig));
		Format(sDifficultyConfig, sizeof(sDifficultyConfig), "cfg/sourcemod/super_tanks++/difficulty_configs/%s.cfg", sDifficultyConfig);
		if (FileExists(sDifficultyConfig, true))
		{
			vExecConfigFile("cfg/sourcemod/super_tanks++/", "difficulty_configs/", sDifficultyConfig, sDifficultyConfig);
		}
		else if (!FileExists(sDifficultyConfig, true) && g_cvSTConfigEnable.BoolValue)
		{
			vCreateConfigFile("cfg/sourcemod/super_tanks++/", "difficulty_configs/", sDifficultyConfig, sDifficultyConfig);
		}
	}
	if (StrContains(g_sConfigOption, "2", false) != -1)
	{
		char sMapConfig[512];
		GetCurrentMap(sMapConfig, sizeof(sMapConfig));
		Format(sMapConfig, sizeof(sMapConfig), (bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_map_configs/%s.cfg" : "cfg/sourcemod/super_tanks++/l4d_map_configs/%s.cfg"), sMapConfig);
		if (FileExists(sMapConfig, true))
		{
			vExecConfigFile("cfg/sourcemod/super_tanks++/", (bIsL4D2Game() ? "l4d2_map_configs/" : "l4d_map_configs/"), sMapConfig, sMapConfig);
		}
		else if (!FileExists(sMapConfig, true) && g_cvSTConfigEnable.BoolValue)
		{
			vCreateConfigFile("cfg/sourcemod/super_tanks++/", (bIsL4D2Game() ? "l4d2_map_configs/" : "l4d_map_configs/"), sMapConfig, sMapConfig);
		}
	}
	if (StrContains(g_sConfigOption, "3", false) != -1)
	{
		char sModeConfig[512];
		g_cvSTGameMode.GetString(sModeConfig, sizeof(sModeConfig));
		Format(sModeConfig, sizeof(sModeConfig), (bIsL4D2Game() ? "cfg/sourcemod/super_tanks++/l4d2_gamemode_configs/%s.cfg" : "cfg/sourcemod/super_tanks++/l4d_gamemode_configs/%s.cfg"), sModeConfig);
		if (FileExists(sModeConfig, true))
		{
			vExecConfigFile("cfg/sourcemod/super_tanks++/", (bIsL4D2Game() ? "l4d2_gamemode_configs/" : "l4d_gamemode_configs/"), sModeConfig, sModeConfig);
		}
		else if (!FileExists(sModeConfig, true) && g_cvSTConfigEnable.BoolValue)
		{
			vCreateConfigFile("cfg/sourcemod/super_tanks++/", (bIsL4D2Game() ? "l4d2_gamemode_configs/" : "l4d_gamemode_configs/"), sModeConfig, sModeConfig);
		}
	}
	if (StrContains(g_sConfigOption, "4", false) != -1)
	{
		char sDayConfig[512];
		char sDay[2];
		FormatTime(sDay, sizeof(sDay), "%w", iGetAccurateTime(g_cvSTConfigTimeOffset, true));
		int iDayNum = StringToInt(sDay);
		switch (iDayNum)
		{
			case 6: sDayConfig = "saturday";
			case 5: sDayConfig = "friday";
			case 4: sDayConfig = "thursday";
			case 3: sDayConfig = "wednesday";
			case 2: sDayConfig = "tuesday";
			case 1: sDayConfig = "monday";
			default: sDayConfig = "sunday";
		}
		Format(sDayConfig, sizeof(sDayConfig), "cfg/sourcemod/super_tanks++/daily_configs/%s.cfg", sDayConfig);
		if (FileExists(sDayConfig, true))
		{
			vExecConfigFile("cfg/sourcemod/super_tanks++/", "daily_configs/", sDayConfig, sDayConfig);
		}
		else if (!FileExists(sDayConfig, true) && g_cvSTConfigEnable.BoolValue)
		{
			vCreateConfigFile("cfg/sourcemod/super_tanks++/", "daily_configs/", sDayConfig, sDayConfig);
		}
	}
	if (StrContains(g_sConfigOption, "5", false) != -1)
	{
		char sCountConfig[512];
		Format(sCountConfig, sizeof(sCountConfig), "cfg/sourcemod/super_tanks++/playercount_configs/%d.cfg", iGetPlayerCount());
		if (FileExists(sCountConfig, true))
		{
			vExecConfigFile("cfg/sourcemod/super_tanks++/", "playercount_configs/", sCountConfig, sCountConfig);
		}
		else if (!FileExists(sCountConfig, true) && g_cvSTConfigEnable.BoolValue)
		{
			vCreateConfigFile("cfg/sourcemod/super_tanks++/", "playercount_configs/", sCountConfig, sCountConfig);
		}
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
	if (g_cvSTEnable.BoolValue && bIsSystemValid(g_cvSTGameMode, g_cvSTEnabledGameModes, g_cvSTDisabledGameModes, g_cvSTGameModeTypes))
	{
		if (StrEqual(classname, "tank_rock", true))
		{
			CreateTimer(0.1, tTimerRockThrow, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public void OnEntityDestroyed(int entity)
{
	if (g_cvSTEnable.BoolValue && bIsSystemValid(g_cvSTGameMode, g_cvSTEnabledGameModes, g_cvSTDisabledGameModes, g_cvSTGameModeTypes))
	{
		if (entity > 36 && IsValidEntity(entity))
		{
			char sClassname[32];
			GetEntityClassname(entity, sClassname, sizeof(sClassname));
			if (StrEqual(sClassname, "tank_rock", true))
			{
				for (int iTank = 1; iTank <= MaxClients; iTank++)
				{
					switch (g_iTankType[iTank])
					{
						case 1:
						{
							if (bIsL4D2Game())
							{
								int iSpitter = CreateFakeClient("Spitter");
								if (iSpitter > 0)
								{
									float flPos[3];
									GetEntPropVector(entity, Prop_Send, "m_vecOrigin", flPos);
									TeleportEntity(iSpitter, flPos, NULL_VECTOR, NULL_VECTOR);
									SDKCall(g_hSDKAcidPlayer, iSpitter);
									KickClient(iSpitter);
								}
							}
						}
						case 10:
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
								SetEntPropEnt(iProp, Prop_Data, "m_hPhysicsAttacker", iTank);
								SetEntPropFloat(iProp, Prop_Data, "m_flLastPhysicsInfluenceTime", GetGameTime());
								SetEntProp(iProp, Prop_Send, "m_CollisionGroup", 1);
								SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
								SetEntityRenderColor(entity, 0, 0, 0, 0);
								AcceptEntityInput(iProp, "Break");
							}
						}
					}
				}
			}
		}
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon)
{
	if (!g_cvSTEnable.BoolValue || !bIsSystemValid(g_cvSTGameMode, g_cvSTEnabledGameModes, g_cvSTDisabledGameModes, g_cvSTGameModeTypes))
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
	if (g_cvSTEnable.BoolValue && bIsSystemValid(g_cvSTGameMode, g_cvSTEnabledGameModes, g_cvSTDisabledGameModes, g_cvSTGameModeTypes))
	{
		if (damage > 0.0 && bIsValidClient(victim))
		{
			char sClassname[32];
			GetEntityClassname(inflictor, sClassname, sizeof(sClassname));
			if (bIsSurvivor(victim))
			{
				if (bIsTank(attacker) && IsFakeClient(attacker) && damagetype != 2)
				{
					if (StrEqual(sClassname, "weapon_tank_claw", false) || StrEqual(sClassname, "tank_rock", false))
					{
						switch (g_iTankType[attacker])
						{
							case 1: vAcidHit(victim);
							case 2: vAmmoHit(victim);
							case 3: vBlindHit(victim);
							case 4: vBombHit(victim, attacker);
							case 8: vCommonHit(victim);
							case 9: vDrugHit(victim);
							case 10: vFireHit(victim, attacker);
							case 12: vFlingHit(victim);
							case 13: vGhostHit(victim, attacker);
							case 14: vGravityHit(victim);
							case 15: vHealHit(victim);
							case 17: vHypnoHit(victim);
							case 18: vIceHit(victim);
							case 19: vIdleHit(victim);
							case 20: vInvertHit(victim);
							case 24: vPukeHit(victim);
							case 25: vRestartHit(victim);
							case 26: vRocketHit(victim);
							case 27: vShakeHit(victim);
							case 29: vShoveHit(victim);
							case 30: vSlugHit(victim);
							case 33: vStunHit(victim);
							case 34: vVisualHit(victim);
						}
					}
				}
			}
			else if (bIsBotInfected(victim))
			{
				if (bIsTank(victim))
				{
					if (damagetype & DMG_BURN)
					{
						if (g_cvSTFireImmunity[g_iTankType[victim]].BoolValue || attacker == victim)
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
						if (StrEqual(sClassname, "weapon_melee", false))
						{
							switch (g_iTankType[victim])
							{
								case 1: vAcidHit(attacker);
								case 10: vFireHit(attacker, victim);
								case 13: vGhostHit(attacker, victim);
								case 23: vMeteorAbility(victim);
							}
						}
						if (g_iTankType[victim] == 28)
						{
							if (damagetype & DMG_BLAST || damagetype & DMG_BLAST_SURFACE || damagetype & DMG_AIRBOAT || damagetype & DMG_PLASMA)
							{
								if (g_bShielded[victim])
								{
									vShieldAbility(victim, false);
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
				}
				if ((damagetype & DMG_BURN || damagetype & DMG_BLAST) && (attacker == victim || bIsInfected(attacker)))
				{
					damage = 0.0;
					return Plugin_Handled;
				}
				if (inflictor != -1)
				{
					int iOwner = GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity");
					if (iOwner == victim || bIsTank(iOwner))
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
	if (g_cvSTEnable.BoolValue && bIsSystemValid(g_cvSTGameMode, g_cvSTEnabledGameModes, g_cvSTDisabledGameModes, g_cvSTGameModeTypes))
	{
		vThrowInterval(iTank, g_cvSTThrowInterval[g_iTankType[iTank]].FloatValue);
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
	if (g_cvSTEnable.BoolValue && bIsSystemValid(g_cvSTGameMode, g_cvSTEnabledGameModes, g_cvSTDisabledGameModes, g_cvSTGameModeTypes) && bIsIdlePlayer(iBot, iSurvivor)) 
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
	if (g_cvSTEnable.BoolValue && bIsSystemValid(g_cvSTGameMode, g_cvSTEnabledGameModes, g_cvSTDisabledGameModes, g_cvSTGameModeTypes))
	{
		if (bIsValidClient(iTank))
		{
			SetEntityGravity(iTank, 1.0);
			if (bIsL4D2Game())
			{
				SetEntProp(iTank, Prop_Send, "m_iGlowType", 0);
				SetEntProp(iTank, Prop_Send, "m_glowColorOverride", 0);
			}
			if (bIsTank(iTank, false))
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
				switch (g_iTankType[iTank])
				{
					case 3:
					{
						for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
						{
							if (bIsSurvivor(iSurvivor))
							{
								tTimerStopBlindness(null, GetClientUserId(iSurvivor));
							}
						}
					}
					case 8: vStopCommon(iTank);
					case 9:
					{
						for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
						{
							if (bIsSurvivor(iSurvivor))
							{
								delete g_hDrugTimer[iSurvivor];
							}
						}
					}
					case 11: vStopFlash(iTank);
					case 14: tTimerStopGravity(null, iUserId);
					case 15: vStopHeal(iTank);
					case 17:
					{
						for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
						{
							if (bIsSurvivor(iSurvivor))
							{
								g_bHypno[iSurvivor] = false;
							}
						}
					}
					case 18:
					{
						for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
						{
							if (bIsSurvivor(iSurvivor))
							{
								tTimerStopIce(null, GetClientUserId(iSurvivor));
							}
						}
					}
					case 20:
					{
						for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
						{
							if (bIsSurvivor(iSurvivor))
							{
								g_bInvert[iSurvivor] = false;
							}
						}
					}
					case 22: vStopJump(iTank);
					case 27:
					{
						for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
						{
							if (bIsSurvivor(iSurvivor))
							{
								delete g_hShakeTimer[iSurvivor];
							}
						}
					}
					case 29:
					{
						for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
						{
							if (bIsSurvivor(iSurvivor))
							{
								delete g_hShoveTimer[iSurvivor];
							}
						}
					}
					case 31: vStopSmoker(iTank);
					case 33:
					{
						for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
						{
							if (bIsSurvivor(iSurvivor))
							{
								SetEntPropFloat(iSurvivor, Prop_Data, "m_flLaggedMovementValue", 1.0);
							}
						}
					}
					case 34:
					{
						for (int iSurvivor = 1; iSurvivor <= MaxClients; iSurvivor++)
						{
							if (bIsSurvivor(iSurvivor))
							{
								delete g_hVisionTimer[iSurvivor];
							}
						}
					}
				}
				int iEntity = -1;
				while ((iEntity = FindEntityByClassname(iEntity, "prop_dynamic")) != INVALID_ENT_REFERENCE)
				{
					char sModel[128];
					GetEntPropString(iEntity, Prop_Data, "m_ModelName", sModel, sizeof(sModel));
					if (StrEqual(sModel, "models/props_debris/concrete_chunk01a.mdl"))
					{
						int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
						if (iOwner == iTank)
						{
							AcceptEntityInput(iEntity, "Kill");
						}
					}
					else if (StrEqual(sModel, MODEL_TIRES))
					{
						int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
						if (iOwner == iTank)
						{
							AcceptEntityInput(iEntity, "Kill");
						}
					}
					else if (StrEqual(sModel, MODEL_SHIELD))
					{
						int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
						if (iOwner == iTank)
						{
							AcceptEntityInput(iEntity, "Kill");
						}
					}
				}
				while ((iEntity = FindEntityByClassname(iEntity, "beam_spotlight")) != INVALID_ENT_REFERENCE)
				{
					int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
					if (iOwner == iTank)
					{
						AcceptEntityInput(iEntity, "Kill");
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
	if (g_cvSTEnable.BoolValue && bIsSystemValid(g_cvSTGameMode, g_cvSTEnabledGameModes, g_cvSTDisabledGameModes, g_cvSTGameModeTypes))
	{
		g_iTankWave = 0;
		int iCvarFlags = g_cvSTMaxPlayerZombies.Flags;
		g_cvSTMaxPlayerZombies.SetBounds(ConVarBound_Upper, false);
		g_cvSTMaxPlayerZombies.Flags = iCvarFlags & ~FCVAR_NOTIFY;
		g_cvSTSmokerLimit.SetInt(32);
		g_cvSTBoomerLimit.SetInt(32);
		g_cvSTHunterLimit.SetInt(32);
		if (bIsL4D2Game())
		{
			g_cvSTSpitterLimit.SetInt(32);
			g_cvSTJockeyLimit.SetInt(32);
			g_cvSTChargerLimit.SetInt(32);
		}
		g_sWeapon[0] = '\0';
		for (int iPlayer= 1; iPlayer <= MaxClients; iPlayer++)
		{
			g_bHeadshot[iPlayer] = false;
			g_bHypno[iPlayer] = false;
		}
		CreateTimer(10.0, tTimerRestartCoordinates, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action eEventTankSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int iUserId = event.GetInt("userid");
	int iTank = GetClientOfUserId(iUserId);
	if (g_cvSTEnable.BoolValue && bIsSystemValid(g_cvSTGameMode, g_cvSTEnabledGameModes, g_cvSTDisabledGameModes, g_cvSTGameModeTypes))
	{
		if (bIsValidClient(iTank))
		{
			if (g_bCmdUsed)
			{
				switch (g_iType)
				{
					case 1: bIsL4D2Game() ? vSetColor(iTank, 1, 0, 255, 125) : vSetColor(iTank, 24, 170, 180, 45);
					case 2: vSetColor(iTank, 2, 170, 200, 210);
					case 3: vSetColor(iTank, 3, 5, 0, 105);
					case 4: vSetColor(iTank, 4, 75, 0, 0);
					case 5: vSetColor(iTank, 5, 65, 105, 0);
					case 6: bIsL4D2Game() ? vSetColor(iTank, 6, 95, 140, 80) : vSetColor(iTank, 31, 150, 0, 150);
					case 7: vSetColor(iTank, 7, 10, 25, 205);
					case 8: vSetColor(iTank, 8, 165, 205, 175);
					case 9: vSetColor(iTank, 9, 255, 245, 0);
					case 10: vSetColor(iTank, 10, 150, 0, 0);
					case 11: vSetColor(iTank, 11, 255, 0, 0, 150, RENDER_TRANSTEXTURE);
					case 12: bIsL4D2Game() ? vSetColor(iTank, 12, 160, 225, 65) : vSetColor(iTank, 22, 225, 215, 0);
					case 13: vSetColor(iTank, 13, 50, 50, 50, 150, RENDER_TRANSTEXTURE);
					case 14: vSetColor(iTank, 14, 25, 25, 25);
					case 15: vSetColor(iTank, 15, 75, 200, 75);
					case 16: vSetColor(iTank, 16, 0, 80, 140);
					case 17: vSetColor(iTank, 17, 110, 0, 130);
					case 18: vSetColor(iTank, 18, 0, 155, 255, 200, RENDER_TRANSTEXTURE);
					case 19: vSetColor(iTank, 19, 225, 235, 255);
					case 20: vSetColor(iTank, 20, 0, 235, 220);
					case 21: bIsL4D2Game() ? vSetColor(iTank, 21, 255, 235, 235) : vSetColor(iTank, 16, 0, 80, 140);
					case 22: vSetColor(iTank, 22, 225, 215, 0);
					case 23: vSetColor(iTank, 23, 120, 20, 10);
					case 24: vSetColor(iTank, 24, 170, 180, 45);
					case 25: vSetColor(iTank, 25, 10, 40, 15);
					case 26: vSetColor(iTank, 26, 250, 110, 0);
					case 27: vSetColor(iTank, 27, 100, 25, 25);
					case 28: vSetColor(iTank, 28, 135, 205);
					case 29: vSetColor(iTank, 29, 10, 100, 0);
					case 30: vSetColor(iTank, 30, 100, 165);
					case 31: vSetColor(iTank, 31, 150, 0, 150);
					case 32: bIsL4D2Game() ? vSetColor(iTank, 32, 0, 200, 0) : vSetColor(iTank, 5, 65, 105, 0);
					case 33: vSetColor(iTank, 33, 80, 130, 255);
					case 34: vSetColor(iTank, 34, 175, 25, 205);
					case 35: vSetColor(iTank, 35, 130, 130);
					case 36: vSetColor(iTank, 36, 255, 145);
					default: vSetColor(iTank);
				}
				g_bCmdUsed = false;
			}
			else
			{
				g_iTankType[iTank] = 0;
				if (!g_cvSTFinalesOnly.BoolValue || (g_cvSTFinalesOnly.BoolValue && (bIsFinaleMap() || g_iTankWave > 0)))
				{
					char sTankType[73];
					g_cvSTTankTypes.GetString(sTankType, sizeof(sTankType));
					char sLetters = sTankType[GetRandomInt(0, strlen(sTankType) - 1)];
					switch (sLetters)
					{
						case '0': bIsL4D2Game() ? vSetColor(iTank, 1, 0, 255, 125) : vSetColor(iTank, 24, 170, 180, 45);
						case '1': vSetColor(iTank, 2, 170, 200, 210);
						case '2': vSetColor(iTank, 3, 5, 0, 105);
						case '3': vSetColor(iTank, 4, 75, 0, 0);
						case '4': vSetColor(iTank, 5, 65, 105, 0);
						case '5': bIsL4D2Game() ? vSetColor(iTank, 6, 95, 140, 80) : vSetColor(iTank, 31, 150, 0, 150);
						case '6': vSetColor(iTank, 7, 10, 25, 205);
						case '7': vSetColor(iTank, 8, 165, 205, 175);
						case '8': vSetColor(iTank, 9, 255, 245, 0);
						case '9': vSetColor(iTank, 10, 150, 0, 0);
						case 'A', 'a': vSetColor(iTank, 11, 255, 0, 0, 150, RENDER_TRANSTEXTURE);
						case 'B', 'b': bIsL4D2Game() ? vSetColor(iTank, 12, 160, 225, 65) : vSetColor(iTank, 22, 225, 215, 0);
						case 'C', 'c': vSetColor(iTank, 13, 50, 50, 50, 150, RENDER_TRANSTEXTURE);
						case 'D', 'd': vSetColor(iTank, 14, 25, 25, 25);
						case 'E', 'e': vSetColor(iTank, 15, 75, 200, 75);
						case 'F', 'f': vSetColor(iTank, 16, 0, 80, 140);
						case 'G', 'g': vSetColor(iTank, 17, 110, 0, 130);
						case 'H', 'h': vSetColor(iTank, 18, 0, 155, 255, 200, RENDER_TRANSTEXTURE);
						case 'I', 'i': vSetColor(iTank, 19, 225, 235, 255);
						case 'J', 'j': vSetColor(iTank, 20, 0, 235, 220);
						case 'K', 'k': bIsL4D2Game() ? vSetColor(iTank, 21, 255, 235, 235) : vSetColor(iTank, 16, 0, 80, 140);
						case 'L', 'l': vSetColor(iTank, 22, 225, 215, 0);
						case 'M', 'm': vSetColor(iTank, 23, 120, 20, 10);
						case 'N', 'n': vSetColor(iTank, 24, 170, 180, 45);
						case 'O', 'o': vSetColor(iTank, 25, 10, 40, 15);
						case 'P', 'p': vSetColor(iTank, 26, 250, 110, 0);
						case 'Q', 'q': vSetColor(iTank, 27, 100, 25, 25);
						case 'R', 'r': vSetColor(iTank, 28, 135, 205);
						case 'S', 's': vSetColor(iTank, 29, 10, 100, 0);
						case 'T', 't': vSetColor(iTank, 30, 100, 165);
						case 'U', 'u': vSetColor(iTank, 31, 150, 0, 150);
						case 'V', 'v': bIsL4D2Game() ? vSetColor(iTank, 32, 0, 200, 0) : vSetColor(iTank, 5, 65, 105, 0);
						case 'W', 'w': vSetColor(iTank, 33, 80, 130, 255);
						case 'X', 'x': vSetColor(iTank, 34, 175, 25, 205);
						case 'Y', 'y': vSetColor(iTank, 35, 130, 130);
						case 'Z', 'z': vSetColor(iTank, 36, 255, 145);
						default: vSetColor(iTank);
					}
					char sTankWave[12];
					char sNumbers[3][4];
					g_cvSTTankWaves.GetString(sTankWave, sizeof(sTankWave));
					ExplodeString(sTankWave, ",", sNumbers, sizeof(sNumbers), sizeof(sNumbers[]));
					int iWave1 = StringToInt(sNumbers[0]);
					int iWave2 = StringToInt(sNumbers[1]);
					int iWave3 = StringToInt(sNumbers[2]);
					switch (g_iTankWave)
					{
						case 1:
						{
							if (iGetTankCount() < iWave1)
							{
								CreateTimer(5.0, tTimerSpawnTanks, _, TIMER_FLAG_NO_MAPCHANGE);
							}
							else if (iGetTankCount() > iWave1 && bIsTank(iTank))
							{
								vKickFakeClient(iTank);
							}
						}
						case 2:
						{
							if (iGetTankCount() < iWave2)
							{
								CreateTimer(5.0, tTimerSpawnTanks, _, TIMER_FLAG_NO_MAPCHANGE);
							}
							else if (iGetTankCount() > iWave2 && bIsTank(iTank))
							{
								vKickFakeClient(iTank);
							}
						}
						case 3:
						{
							if (iGetTankCount() < iWave3)
							{
								CreateTimer(5.0, tTimerSpawnTanks, _, TIMER_FLAG_NO_MAPCHANGE);
							}
							else if (iGetTankCount() > iWave3 && bIsTank(iTank))
							{
								vKickFakeClient(iTank);
							}
						}
					}
				}
			}
			CreateTimer(0.1, tTimerTankSpawn, GetClientUserId(iTank), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public Action cmdTank(int client, int args)
{
	if (!g_cvSTEnable.BoolValue)
	{
		ReplyToCommand(client, "\x04%s\x01 Super Tanks++ is disabled.", ST_PREFIX);
		return Plugin_Handled;
	}
	if (!bIsValidHumanClient(client))
	{
		ReplyToCommand(client, "%s This command is to be used only in-game.", ST_PREFIX);
		return Plugin_Handled;
	}
	if (!bIsSystemValid(g_cvSTGameMode, g_cvSTEnabledGameModes, g_cvSTDisabledGameModes, g_cvSTGameModeTypes))
	{
		ReplyToCommand(client, "\x04%s\x01 Game mode not supported.", ST_PREFIX);
		return Plugin_Handled;
	}
	char tank[32];
	GetCmdArg(1, tank, sizeof(tank));
	int type = StringToInt(tank);
	if (args < 1)
	{
		IsVoteInProgress() ? ReplyToCommand(client, "\x04%s\x01 %t", ST_PREFIX, "Vote in Progress") : vTankMenu(client);
		return Plugin_Handled;
	}
	else if (type > 36 || args > 1)
	{
		ReplyToCommand(client, "\x04%s\x01 Usage: sm_tank <type 1-36>", ST_PREFIX);
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

void vTankMenu(int client)
{
	Menu mTankMenu = new Menu(iTankMenuHandler);
	mTankMenu.SetTitle("Super Tanks++ Menu");
	mTankMenu.AddItem("Acid Tank", "Acid Tank");
	mTankMenu.AddItem("Ammo Tank", "Ammo Tank");
	mTankMenu.AddItem("Blind Tank", "Blind Tank");
	mTankMenu.AddItem("Bomb Tank", "Bomb Tank");
	mTankMenu.AddItem("Boomer Tank", "Boomer Tank");
	mTankMenu.AddItem("Charger Tank", "Charger Tank");
	mTankMenu.AddItem("Clone Tank", "Clone Tank");
	mTankMenu.AddItem("Common Tank", "Common Tank");
	mTankMenu.AddItem("Drug Tank", "Drug Tank");
	mTankMenu.AddItem("Fire Tank", "Fire Tank");
	mTankMenu.AddItem("Flash Tank", "Flash Tank");
	mTankMenu.AddItem("Fling Tank", "Fling Tank");
	mTankMenu.AddItem("Ghost Tank", "Ghost Tank");
	mTankMenu.AddItem("Gravity Tank", "Gravity Tank");
	mTankMenu.AddItem("Heal Tank", "Heal Tank");
	mTankMenu.AddItem("Hunter Tank", "Hunter Tank");
	mTankMenu.AddItem("Hypno Tank", "Hypno Tank");
	mTankMenu.AddItem("Ice Tank", "Ice Tank");
	mTankMenu.AddItem("Idle Tank", "Idle Tank");
	mTankMenu.AddItem("Invert Tank", "Invert Tank");
	mTankMenu.AddItem("Jockey Tank", "Jockey Tank");
	mTankMenu.AddItem("Jumper Tank", "Jumper Tank");
	mTankMenu.AddItem("Meteor Tank", "Meteor Tank");
	mTankMenu.AddItem("Puke Tank", "Puke Tank");
	mTankMenu.AddItem("Restart Tank", "Restart Tank");
	mTankMenu.AddItem("Rocket Tank", "Rocket Tank");
	mTankMenu.AddItem("Shake Tank", "Shake Tank");
	mTankMenu.AddItem("Shield Tank", "Shield Tank");
	mTankMenu.AddItem("Shove Tank", "Shove Tank");
	mTankMenu.AddItem("Slug Tank", "Slug Tank");
	mTankMenu.AddItem("Smoker Tank", "Smoker Tank");
	mTankMenu.AddItem("Spitter Tank", "Spitter Tank");
	mTankMenu.AddItem("Stun Tank", "Stun Tank");
	mTankMenu.AddItem("Visual Tank", "Visual Tank");
	mTankMenu.AddItem("Warp Tank", "Warp Tank");
	mTankMenu.AddItem("Witch Tank", "Witch Tank");
	mTankMenu.Display(client, MENU_TIME_FOREVER);
}

public int iTankMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_End: delete menu;
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: vTank(param1, 1);
				case 1: vTank(param1, 2);
				case 2: vTank(param1, 3);
				case 3: vTank(param1, 4);
				case 4: vTank(param1, 5);
				case 5: vTank(param1, 6);
				case 6: vTank(param1, 7);
				case 7: vTank(param1, 8);
				case 8: vTank(param1, 9);
				case 9: vTank(param1, 10);
				case 10: vTank(param1, 11);
				case 11: vTank(param1, 12);
				case 12: vTank(param1, 13);
				case 13: vTank(param1, 14);
				case 14: vTank(param1, 15);
				case 15: vTank(param1, 16);
				case 16: vTank(param1, 17);
				case 17: vTank(param1, 18);
				case 18: vTank(param1, 19);
				case 19: vTank(param1, 20);
				case 20: vTank(param1, 21);
				case 21: vTank(param1, 22);
				case 22: vTank(param1, 23);
				case 23: vTank(param1, 24);
				case 24: vTank(param1, 25);
				case 25: vTank(param1, 26);
				case 26: vTank(param1, 27);
				case 27: vTank(param1, 28);
				case 28: vTank(param1, 29);
				case 29: vTank(param1, 30);
				case 30: vTank(param1, 31);
				case 31: vTank(param1, 32);
				case 32: vTank(param1, 33);
				case 33: vTank(param1, 34);
				case 34: vTank(param1, 35);
				case 35: vTank(param1, 36);
			}
			if (IsClientInGame(param1) && !IsClientInKickQueue(param1))
			{
				vTankMenu(param1);
			}
		}
	}
}

void vAcidHit(int client)
{
	if (GetRandomInt(1, g_cvSTAcidChance.IntValue) == 1 && bIsSurvivor(client) && bIsL4D2Game())
	{
		int iSpitter = CreateFakeClient("Spitter");
		if (iSpitter > 0)
		{
			float flPos[3];
			GetClientAbsOrigin(client, flPos);
			TeleportEntity(iSpitter, flPos, NULL_VECTOR, NULL_VECTOR);
			SDKCall(g_hSDKAcidPlayer, iSpitter);
			KickClient(iSpitter);
		}
	}
}

void vAmmoHit(int client)
{
	if (GetRandomInt(1, g_cvSTAmmoChance.IntValue) == 1 && bIsSurvivor(client) && GetPlayerWeaponSlot(client, 0) > 0)
	{
		char sWeapon[32];
		int iActiveWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		int iAmmo = FindDataMapInfo(client, "m_iAmmo");
		GetEntityClassname(iActiveWeapon, sWeapon, sizeof(sWeapon));
		if (IsValidEntity(iActiveWeapon))
		{
			if (StrEqual(sWeapon, "weapon_rifle", false))
			{
				bIsL4D2Game() ? SetEntData(client, iAmmo + 12, g_cvSTAmmoCount.IntValue) : SetEntData(client, iAmmo + 12, g_cvSTAmmoCount.IntValue);
			}
			else if (StrEqual(sWeapon, "weapon_rifle_desert", false) || StrEqual(sWeapon, "weapon_rifle_ak47", false) || StrEqual(sWeapon, "weapon_rifle_sg552", false))
			{
				SetEntData(client, iAmmo + 12, g_cvSTAmmoCount.IntValue);
			}
			else if (StrEqual(sWeapon, "weapon_smg", false))
			{
				bIsL4D2Game() ? SetEntData(client, iAmmo + 20, g_cvSTAmmoCount.IntValue) : SetEntData(client, iAmmo + 20, g_cvSTAmmoCount.IntValue);
			}
			else if (StrEqual(sWeapon, "weapon_smg_silenced", false) || StrEqual(sWeapon, "weapon_smg_mp5", false))
			{
				SetEntData(client, iAmmo + 20, g_cvSTAmmoCount.IntValue);
			}
			else if (StrEqual(sWeapon, "weapon_pumpshotgun", false))
			{
				bIsL4D2Game() ? SetEntData(client, iAmmo + 28, g_cvSTAmmoCount.IntValue) : SetEntData(client, iAmmo + 24, g_cvSTAmmoCount.IntValue);
			}
			else if (StrEqual(sWeapon, "weapon_shotgun_chrome", false))
			{
				SetEntData(client, iAmmo + 28, g_cvSTAmmoCount.IntValue);
			}
			else if (StrEqual(sWeapon, "weapon_autoshotgun", false))
			{
				bIsL4D2Game() ? SetEntData(client, iAmmo + 32, g_cvSTAmmoCount.IntValue) : SetEntData(client, iAmmo + 24, g_cvSTAmmoCount.IntValue);
			}
			else if (StrEqual(sWeapon, "weapon_shotgun_spas", false))
			{
				SetEntData(client, iAmmo + 32, g_cvSTAmmoCount.IntValue);
			}
			else if (StrEqual(sWeapon, "weapon_hunting_rifle", false))
			{
				bIsL4D2Game() ? SetEntData(client, iAmmo + 36, g_cvSTAmmoCount.IntValue) : SetEntData(client, iAmmo + 8, g_cvSTAmmoCount.IntValue);
			}
			else if (StrEqual(sWeapon, "weapon_sniper_scout", false))
			{
				SetEntData(client, iAmmo + 36, g_cvSTAmmoCount.IntValue);
			}
			else if (StrEqual(sWeapon, "weapon_sniper_military", false) || StrEqual(sWeapon, "weapon_sniper_awp", false))
			{
				SetEntData(client, iAmmo + 40, g_cvSTAmmoCount.IntValue);
			}
			else if (StrEqual(sWeapon, "weapon_grenade_launcher", false))
			{
				SetEntData(client, iAmmo + 68, g_cvSTAmmoCount.IntValue);
			}
		}
		SetEntProp(GetPlayerWeaponSlot(client, 0), Prop_Data, "m_iClip1", g_cvSTAmmoCount.IntValue, 1);
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

void vAttachParticle(int client, char[] particlename, float time, float origin)
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
			AcceptEntityInput(iParticle, "start");
			SetVariantString("!activator");
			AcceptEntityInput(iParticle, "SetParent", client);
			iParticle = EntIndexToEntRef(iParticle);
			vDeleteEntity(iParticle, time);
		}
	}
}

void vBlindHit(int client)
{
	if (GetRandomInt(1, g_cvSTBlindChance.IntValue) == 1 && bIsSurvivor(client))
	{
		vApplyBlindness(client, 255);
		CreateTimer(g_cvSTBlindDuration.FloatValue, tTimerStopBlindness, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vBombHit(int client, int owner)
{
	if (GetRandomInt(1, g_cvSTBombChance.IntValue) == 1 && bIsSurvivor(client))
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

void vCommonAbility(int client)
{
	if (g_iTankType[client] == 8 && bIsValidClient(client))
	{
		vCommonHit(client);
	}
}

void vCommonHit(int client)
{
	if (g_iTankType[client] == 8 && bIsValidClient(client))
	{
		g_iInterval++;
		if (g_iInterval >= g_cvSTCommonInterval.IntValue)
		{
			for (int iCommon = 1; iCommon <= g_cvSTCommonInterval.IntValue; iCommon++)
			{
				bIsL4D2Game() ? vCheatCommand(client, "z_spawn_old", "zombie area") : vCheatCommand(client, "z_spawn", "zombie area");
			}
			g_iInterval = 0;
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

void vCreateConVar(ConVar &convar, const char[] name, const char[] defaultValue, const char[] description = "", int flags = 0, bool hasMin = false, float min = 0.0, bool hasMax = false, float max = 0.0)
{
	convar = cvST_ConVar(name, defaultValue, description, flags, hasMin, min, hasMax, max);
	convar.AddChangeHook(vSwitchCvars);
	vSwitchCvars(convar, defaultValue, defaultValue);
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

void vDrugHit(int client)
{
	if (GetRandomInt(1, g_cvSTDrugChance.IntValue) == 1 && bIsSurvivor(client))
	{
		if (g_hDrugTimer[client] == null)
		{
			g_hDrugTimer[client] = CreateTimer(1.0, tTimerDrug, GetClientUserId(client), TIMER_REPEAT);
		}
		CreateTimer(g_cvSTDrugDuration.FloatValue, tTimerStopDrug, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vExecConfigFile(const char[] filepath, const char[] folder, const char[] filename, const char[] label = "")
{
	char sConfigFilename[128];
	char sConfigLabel[128];
	Format(sConfigFilename, sizeof(sConfigFilename), "%s%s%s.cfg", filepath, folder, filename);
	if (!FileExists(sConfigFilename))
	{
		return;
	}
	strlen(label) > 0 ? strcopy(sConfigLabel, sizeof(sConfigLabel), label) : strcopy(sConfigLabel, sizeof(sConfigLabel), sConfigFilename);
	strcopy(sConfigFilename, sizeof(sConfigFilename), sConfigFilename[4]);
	ServerCommand("exec \"%s\"", sConfigFilename);
}

void vFakeJump(int client)
{
	float flVelocity[3];
	if (g_iTankType[client] == 22 && bIsValidClient(client))
	{
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

void vFireHit(int client, int owner)
{
	if (GetRandomInt(1, g_cvSTFireChance.IntValue) == 1 && bIsSurvivor(client))
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

void vFlashAbility(int client)
{
	if (g_iTankType[client] == 11 && bIsValidClient(client))
	{
		if (!g_bFlash[client])
		{
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
			if (GetRandomInt(1, g_cvSTFlashChance.IntValue) == 1)
			{
				g_bFlash[client] = true;
				if (g_hFlashTimer[client] == null)
				{
					g_hFlashTimer[client] = CreateTimer(0.25, tTimerFlashEffect, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
				}
			}
		}
		else
		{
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", g_cvSTFlashSpeed.FloatValue);
		}
	}
}

void vFlingHit(int client)
{
	if (GetRandomInt(1, g_cvSTFlingChance.IntValue) == 1 && bIsSurvivor(client) && bIsL4D2Game())
	{
		int iCharger = CreateFakeClient("Charger");
		if (iCharger > 0)
		{
			float flTpos[3];
			float flSpos[3];
			float flDistance[3];
			float flRatio[3];
			float flAddVel[3];
			float flTvec[3];
			GetClientAbsOrigin(client, flTpos);
			GetClientAbsOrigin(iCharger, flSpos);
			flDistance[0] = (flSpos[0] - flTpos[0]);
			flDistance[1] = (flSpos[1] - flTpos[1]);
			flDistance[2] = (flSpos[2] - flTpos[2]);
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", flTvec);
			flRatio[0] =  FloatDiv(flDistance[0], SquareRoot(flDistance[1] * flDistance[1] + flDistance[0] * flDistance[0]));
			flRatio[1] =  FloatDiv(flDistance[1], SquareRoot(flDistance[1] * flDistance[1] + flDistance[0] * flDistance[0]));
			flAddVel[0] = FloatMul(flRatio[0] * -1, 500.0);
			flAddVel[1] = FloatMul(flRatio[1] * -1, 500.0);
			flAddVel[2] = 500.0;
			SDKCall(g_hSDKFlingPlayer, client, flAddVel, 76, iCharger, 7.0);
			KickClient(iCharger);
		}
	}
}

void vGhostAbility(int client)
{
	for (int iInfected = 1; iInfected <= MaxClients; iInfected++)
	{
		if (g_iTankType[client] == 13 && bIsValidClient(client) && bIsSpecialInfected(iInfected))
		{
			float flTankPos[3];
			float flInfectedPos[3];
			GetClientAbsOrigin(client, flTankPos);
			GetClientAbsOrigin(iInfected, flInfectedPos);
			float flDistance = GetVectorDistance(flTankPos, flInfectedPos);
			if (flDistance < 500)
			{
				SetEntityRenderMode(iInfected, RENDER_TRANSTEXTURE);
				SetEntityRenderColor(iInfected, 255, 255, 255, 50);
			}
			else
			{
				SetEntityRenderMode(iInfected, RENDER_TRANSTEXTURE);
				SetEntityRenderColor(iInfected, 255, 255, 255, 255);
			}
		}
	}
	if (iGetSurvivorRange(client) == iGetSurvivorCount())
	{
		SetEntityRenderMode(client, RENDER_TRANSTEXTURE);
		SetEntityRenderColor(client, 100, 100, 100, 50);
		EmitSoundToAll(SOUND_INFECTED2, client);
	}
	else
	{
		SetEntityRenderMode(client, RENDER_TRANSTEXTURE);
		SetEntityRenderColor(client, 100, 100, 100, 150);
		EmitSoundToAll(SOUND_INFECTED, client);
	}
}

void vGhostHit(int target, int client)
{
	if (g_iTankType[client] == 13 && GetRandomInt(1, g_cvSTGhostChance.IntValue) && bIsSurvivor(target) && bIsValidClient(client))
	{
		char sWeapon[6];
		g_cvSTGhostSlot.GetString(sWeapon, sizeof(sWeapon));
		if (StrContains(sWeapon, "1") != -1)
		{
			vDropWeapon(target, 0);
		}
		if (StrContains(sWeapon, "2") != -1)
		{
			vDropWeapon(target, 1);
		}
		if (StrContains(sWeapon, "3") != -1)
		{
			vDropWeapon(target, 2);
		}
		if (StrContains(sWeapon, "4") != -1)
		{
			vDropWeapon(target, 3);
		}
		if (StrContains(sWeapon, "5") != -1)
		{
			vDropWeapon(target, 4);
		}
		EmitSoundToClient(target, SOUND_INFECTED, client);
	}
}

void vGravityAbility(int client)
{
	int iBlackhole = CreateEntityByName("point_push");
	if (g_iTankType[client] == 14 && bIsValidClient(client) && IsValidEntity(iBlackhole))
	{
		float flOrigin[3];
		float flAngles[3];
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
		GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
		flAngles[0] += -90.0;
		DispatchKeyValueVector(iBlackhole, "origin", flOrigin);
		DispatchKeyValueVector(iBlackhole, "angles", flAngles);
		DispatchKeyValue(iBlackhole, "radius", "750");
		DispatchKeyValueFloat(iBlackhole, "magnitude", g_cvSTGravityForce.FloatValue);
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

void vGravityHit(int client)
{
	if (GetRandomInt(1, g_cvSTGravityChance.IntValue) == 1 && bIsSurvivor(client))
	{
		SetEntityGravity(client, 0.3);
		CreateTimer(2.0, tTimerStopGravity, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vHealAbility(int client)
{
	if (g_iTankType[client] == 15 && bIsValidClient(client))
	{
		if (g_hHealTimer[client] == null)
		{
			g_hHealTimer[client] = CreateTimer(g_cvSTHealInterval.FloatValue, tTimerHeal, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		}
	}
}

void vHealHit(int client)
{
	if (GetRandomInt(1, g_cvSTHealChance.IntValue) == 1 && bIsSurvivor(client))
	{
		SetEntProp(client, Prop_Send, "m_currentReviveCount", g_cvSTHealIncapCount.IntValue - 1);
		SetEntProp(client, Prop_Send, "m_isIncapacitated", 1);
		SDKCall(g_hSDKRevivePlayer, client);
		SetEntityHealth(client, 1);
		SDKCall(g_hSDKHealPlayer, client, 50.0);
	}
}

void vHypnoHit(int client)
{
	if (GetRandomInt(1, g_cvSTHypnoChance.IntValue) == 1 && bIsSurvivor(client))
	{
		g_bHypno[client] = true;
		CreateTimer(g_cvSTHypnoDuration.FloatValue, tTimerStopHypnosis, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vIceHit(int client)
{
	if (GetRandomInt(1, g_cvSTIceChance.IntValue) == 1 && bIsSurvivor(client))
	{
		GetClientEyePosition(client, g_flIce);
		if (GetEntityMoveType(client) != MOVETYPE_NONE)
		{
			SetEntityMoveType(client, MOVETYPE_NONE);
			SetEntityRenderColor(client, 0, 128, 255, 192);
			EmitAmbientSound(PHYSICS_BULLET, g_flIce, client, SNDLEVEL_RAIDSIREN);
		}
		CreateTimer(5.0, tTimerStopIce, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vIdleHit(int client)
{
	if (GetRandomInt(1, g_cvSTIdleChance.IntValue) == 1 && bIsHumanSurvivor(client))
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

void vInvertHit(int client)
{
	if (GetRandomInt(1, g_cvSTInvertChance.IntValue) == 1 && bIsSurvivor(client))
	{
		g_bInvert[client] = true;
		CreateTimer(g_cvSTInvertDuration.FloatValue, tTimerStopInversion, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vJumperEffect(int client)
{
	if (g_iTankType[client] == 22 && bIsValidClient(client))
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
		if (!StrEqual(sClassname, "tank_rock", true))
		{
			return;
		}
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
		DispatchKeyValueFloat(iPointHurt, "Damage", g_cvSTMeteorDamage.FloatValue);
		DispatchKeyValue(iPointHurt, "DamageType", "2");
		DispatchKeyValue(iPointHurt, "DamageDelay", "0.0");
		DispatchKeyValueFloat(iPointHurt, "DamageRadius", 200.0);
		TeleportEntity(iPointHurt, flPos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(iPointHurt);
		if (IsValidEntity(client) && bIsTank(client))
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

void vMeteorAbility(int client)
{
	if (g_iTankType[client] == 23 && GetRandomInt(1, g_cvSTMeteorChance.IntValue) == 1 && bIsValidClient(client) && !g_bMeteor[client])
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

void vPukeHit(int client)
{
	if (GetRandomInt(1, g_cvSTPukeChance.IntValue) == 1 && bIsSurvivor(client))
	{
		int iBoomer = CreateFakeClient("Boomer");
		if (iBoomer > 0)
		{
			SDKCall(g_hSDKPukePlayer, client, iBoomer, true);
			KickClient(iBoomer);
		}
	}
}

void vRestartHit(int client)
{
	if (GetRandomInt(1, g_cvSTRestartChance.IntValue) == 1 && bIsSurvivor(client))
	{
		SDKCall(g_hSDKRespawnPlayer, client);
		char sLoadout[512];
		char sItems[5][64];
		g_cvSTRestartLoadout.GetString(sLoadout, sizeof(sLoadout));
		ExplodeString(sLoadout, ",", sItems, sizeof(sItems), sizeof(sItems[]));
		for (int iItem = 0; iItem < sizeof(sItems); iItem++)
		{
			if (StrContains(sLoadout, sItems[iItem], false) != -1 && sItems[iItem][0] != '\0')
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

void vRocketHit(int client)
{
	if (GetRandomInt(1, g_cvSTRocketChance.IntValue) == 1 && bIsSurvivor(client))
	{
		int iFlame = CreateEntityByName("env_steam");
		if (IsValidEntity(iFlame))
		{
			float flPosition[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flPosition);
			flPosition[2] += 30;
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
			SetEntityRenderColor(iFlame, 180, 71, 8, 180);
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

void vSetColor(int client, int value = 0, int red = 255, int green = 255, int blue = 255, int alpha = 255, RenderMode mode = RENDER_NORMAL)
{
	g_iTankType[client] = value;
	if (bIsL4D2Game())
	{
		SetEntProp(client, Prop_Send, "m_iGlowType", 3);
		SetEntProp(client, Prop_Send, "m_glowColorOverride", iGetRGBColor(red, green, blue));
	}
	SetEntityRenderMode(client, mode);
	SetEntityRenderColor(client, red, green, blue, alpha);
}

void vSetName(int client, char[] name = "Default Tank", int red = 255, int green = 255, int blue = 255, int alpha = 255, RenderMode mode = RENDER_NORMAL)
{
	if (bIsBotInfected(client))
	{
		vSetProps(client, red, green, blue, alpha, mode);
		SetClientInfo(client, "name", name);
		if (g_cvSTAnnounceArrival.BoolValue)
		{
			PrintToChatAll("\x04%s\x05 %s\x01 has appeared!", ST_PREFIX, name);
		}
	}
}

void vSetProps(int client, int red, int green, int blue, int alpha, RenderMode mode)
{
	if (bIsValidClient(client))
	{
		char sProps[5];
		g_cvSTAttachProps[g_iTankType[client]].GetString(sProps, sizeof(sProps));
		if (GetRandomInt(1, 3) == 1 && StrContains(sProps, "1", false) != -1)
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
					SetEntityRenderMode(iEntity[iOzTank], mode);
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
						SetEntityRenderColor(iFlame, red, green, blue, 180);
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
						float flOrigin2[3];
						float flAngles3[3];
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
		if (GetRandomInt(1, 3) == 1 && StrContains(sProps, "2", false) != -1)
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
				TeleportEntity(iEntity, NULL_VECTOR, flAngles, NULL_VECTOR);
				DispatchSpawn(iEntity);
				SetVariantString("!activator");
				AcceptEntityInput(iEntity, "SetParent", client);
				SetVariantString("mouth");
				AcceptEntityInput(iEntity, "SetParentAttachment");
				AcceptEntityInput(iEntity, "Enable");
				AcceptEntityInput(iEntity, "DisableCollision");
				SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", client);
			}
		}
		if (GetRandomInt(1, 3) == 1 && StrContains(sProps, "3", false) != -1)
		{
			float flOrigin[3];
			float flAngles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
			int iEntity[5];
			for (int iSpike = 1; iSpike <= 4; iSpike++)
			{
				iEntity[iSpike] = CreateEntityByName("prop_dynamic_override");
				if (IsValidEntity(iEntity[iSpike]))
				{
					SetEntityModel(iEntity[iSpike], "models/props_debris/concrete_chunk01a.mdl");
					SetEntityRenderMode(iEntity[iSpike], mode);
					SetEntityRenderColor(iEntity[iSpike], red, green, blue, alpha);
					DispatchKeyValueVector(iEntity[iSpike], "origin", flOrigin);
					DispatchKeyValueVector(iEntity[iSpike], "angles", flAngles);
					SetVariantString("!activator");
					AcceptEntityInput(iEntity[iSpike], "SetParent", client);
					switch (iSpike)
					{
						case 1: SetVariantString("relbow");
						case 2: SetVariantString("lelbow");
						case 3: SetVariantString("rshoulder");
						case 4: SetVariantString("lshoulder");
					}
					AcceptEntityInput(iEntity[iSpike], "SetParentAttachment");
					AcceptEntityInput(iEntity[iSpike], "Enable");
					AcceptEntityInput(iEntity[iSpike], "DisableCollision");
					if (bIsL4D2Game())
					{
						switch (iSpike)
						{
							case 1, 2: SetEntPropFloat(iEntity[iSpike], Prop_Data, "m_flModelScale", 0.4);
							case 3, 4: SetEntPropFloat(iEntity[iSpike], Prop_Data, "m_flModelScale", 0.5);
						}
					}
					SetEntPropEnt(iEntity[iSpike], Prop_Send, "m_hOwnerEntity", client);
					flAngles[0] = flAngles[0] + GetRandomFloat(-90.0, 90.0);
					flAngles[1] = flAngles[1] + GetRandomFloat(-90.0, 90.0);
					flAngles[2] = flAngles[2] + GetRandomFloat(-90.0, 90.0);
					TeleportEntity(iEntity[iSpike], NULL_VECTOR, flAngles, NULL_VECTOR);
					DispatchSpawn(iEntity[iSpike]);
				}
			}
		}
		if (GetRandomInt(1, 3) == 1 && StrContains(sProps, "4", false) != -1)
		{
			float flOrigin[3];
			float flAngles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", flOrigin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", flAngles);
			int iEntity[3];
			for (int iTire = 1; iTire <= 2; iTire++)
			{
				iEntity[iTire] = CreateEntityByName("prop_dynamic_override");
				if (IsValidEntity(iEntity[iTire]))
				{
					SetEntityModel(iEntity[iTire], MODEL_TIRES);
					SetEntityRenderMode(iEntity[iTire], mode);
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
					SetEntPropEnt(iEntity[iTire], Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(iEntity[iTire], NULL_VECTOR, flAngles, NULL_VECTOR);
					DispatchSpawn(iEntity[iTire]);
				}
			}
		}
	}
}

void vShakeHit(int client)
{
	if (GetRandomInt(1, g_cvSTShakeChance.IntValue) == 1 && bIsSurvivor(client))
	{
		if (g_hShakeTimer[client] == null)
		{
			g_hShakeTimer[client] = CreateTimer(5.0, tTimerShake, GetClientUserId(client), TIMER_REPEAT);
		}
		CreateTimer(g_cvSTShakeDuration.FloatValue, tTimerStopShake, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vShieldAbility(int client, bool shield)
{
	if (g_iTankType[client] == 28 && bIsValidClient(client))
	{
		if (shield)
		{
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
				SetEntityRenderColor(iEntity, 25, 125, 125, 50);
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
				if (StrEqual(sModel, MODEL_SHIELD))
				{
					int iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
					if (iOwner == client)
					{
						AcceptEntityInput(iEntity, "Kill");
					}
				}
			}
			CreateTimer(g_cvSTShieldDelay.FloatValue, tTimerShield, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			g_bShielded[client] = false;
		}
	}
}

void vShoveHit(int client)
{
	if (GetRandomInt(1, g_cvSTShoveChance.IntValue) == 1 && bIsSurvivor(client))
	{
		if (g_hShoveTimer[client] == null)
		{
			g_hShoveTimer[client] = CreateTimer(1.0, tTimerShove, GetClientUserId(client), TIMER_REPEAT);
		}
		CreateTimer(g_cvSTShoveDuration.FloatValue, tTimerStopShove, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vSlugHit(int client)
{
	if (GetRandomInt(1, g_cvSTSlugChance.IntValue) == 1 && bIsSurvivor(client))
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
		TE_SetupBeamPoints(flStartPosition, flPosition, g_iShockSprite, 0, 0, 0, 0.2, 20.0, 10.0, 0, 1.0, iColor, 3);
		TE_SendToAll();
		TE_SetupSparks(flPosition, flDirection, 5000, 1000);
		TE_SendToAll();
		TE_SetupEnergySplash(flPosition, flDirection, false);
		TE_SendToAll();
		EmitAmbientSound(SOUND_EXPLOSION3, flStartPosition, client, SNDLEVEL_RAIDSIREN);
		ForcePlayerSuicide(client);
	}
}

void vSmokerEffect(int client)
{
	if (g_iTankType[client] == 31 && bIsValidClient(client))
	{
		if (g_hSmokerTimer[client] == null)
		{
			g_hSmokerTimer[client] = CreateTimer(1.5, tTimerSmoker, GetClientUserId(client), TIMER_REPEAT);
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
			vSpawnInfected(iTank, 8, true);
		}
	}
}

void vStopCommon(int client)
{
	if (g_iTankType[client] == 8 && bIsValidClient(client))
	{
		delete g_hCommonTimer[client];
	}
}

void vStopFlash(int client)
{
	if (g_iTankType[client] == 11 && bIsValidClient(client))
	{
		delete g_hFlashTimer[client];
	}
}

void vStopHeal(int client)
{
	if (g_iTankType[client] == 15 && bIsValidClient(client))
	{
		delete g_hHealTimer[client];
	}
}

void vStopJump(int client)
{
	if (g_iTankType[client] == 22 && bIsValidClient(client))
	{
		delete g_hJumpTimer[client];
	}
}

void vStopSmoker(int client)
{
	if (g_iTankType[client] == 31 && bIsValidClient(client))
	{
		delete g_hSmokerTimer[client];
	}
}

void vStopTimers(int client)
{
	if (bIsValidClient(client))
	{
		g_bAFK[client] = false;
		g_bFlash[client] = false;
		g_bHeadshot[client] = false;
		g_bHypno[client] = false;
		g_bIdle[client] = false;
		g_bInvert[client] = false;
		g_bMeteor[client] = false;
		g_bShielded[client] = false;
		g_iTankType[client] = 0;
		tTimerStopBlindness(null, GetClientUserId(client));
		tTimerStopDrug(null, GetClientUserId(client));
		tTimerStopGravity(null, GetClientUserId(client));
		tTimerStopHypnosis(null, GetClientUserId(client));
		tTimerStopIce(null, GetClientUserId(client));
		tTimerStopInversion(null, GetClientUserId(client));
		tTimerStopShake(null, GetClientUserId(client));
		tTimerStopShove(null, GetClientUserId(client));
		tTimerStopStun(null, GetClientUserId(client));
		tTimerStopVision(null, GetClientUserId(client));
		vStopCommon(client);
		vStopFlash(client);
		vStopHeal(client);
		vStopJump(client);
		vStopSmoker(client);
	}
}

void vStunHit(int client)
{
	if (GetRandomInt(1, g_cvSTStunChance.IntValue) == 1 && bIsSurvivor(client))
	{
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", g_cvSTStunSpeed.FloatValue);
		CreateTimer(g_cvSTStunDuration.FloatValue, tTimerStopStun, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vThrowInterval(int client, float time)
{
	if (bIsBotInfected(client))
	{
		int iAbility = GetEntPropEnt(client, Prop_Send, "m_customAbility");
		if (iAbility > 0)
		{
			SetEntPropFloat(iAbility, Prop_Send, "m_duration", time);
			SetEntPropFloat(iAbility, Prop_Send, "m_timestamp", GetGameTime() + time);
		}
	}
}

void vVisualHit(int client)
{
	if (GetRandomInt(1, g_cvSTVisualChance.IntValue) == 1 && bIsSurvivor(client))
	{
		if (g_hVisionTimer[client] == null)
		{
			g_hVisionTimer[client] = CreateTimer(0.1, tTimerVision, GetClientUserId(client), TIMER_REPEAT);
		}
		CreateTimer(g_cvSTVisualDuration.FloatValue, tTimerStopVision, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	}
}

void vWarpAbility(int client)
{
	if (g_iTankType[client] == 35 && GetRandomInt(1, g_cvSTWarpInterval.IntValue) == 1 && bIsValidClient(client))
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

public void vSTGameDifficultyCvar(ConVar convar, const char[] oldValue, const char[] newValue)
{
	g_cvSTConfigExecute.GetString(g_sConfigOption, sizeof(g_sConfigOption));
	if (StrContains(g_sConfigOption, "1", false) != -1)
	{
		char sDifficultyConfig[512];
		g_cvSTGameDifficulty.GetString(sDifficultyConfig, sizeof(sDifficultyConfig));
		Format(sDifficultyConfig, sizeof(sDifficultyConfig), "cfg/sourcemod/super_tanks++/difficulty_configs/%s.cfg", sDifficultyConfig);
		if (FileExists(sDifficultyConfig, true))
		{
			vExecConfigFile("cfg/sourcemod/super_tanks++/", "difficulty_configs/", sDifficultyConfig, sDifficultyConfig);
		}
	}
}

public void vSwitchCvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	char sConVars[64];
	convar.GetName(sConVars, sizeof(sConVars));
	char sName[64];
	char sValue[2049];
	Format(sName, sizeof(sName), sConVars);
	Format(sValue, sizeof(sValue), "%s", newValue);
	TrimString(sValue);
	if (StrContains(newValue, ST_LOCK) == 0)
	{
		strcopy(sValue, sizeof(sValue), sValue[2]);
		TrimString(sValue);
		g_smConVars.SetString(sName, sValue, true);
	}
	else if (StrContains(newValue, ST_UNLOCK) == 0)
	{
		strcopy(sValue, sizeof(sValue), sValue[2]);
		TrimString(sValue);
		g_smConVars.Remove(sName);
	}
	g_smConVars.GetString(sName, sValue, sizeof(sValue));
	if (!StrEqual(newValue, sValue))
	{
		convar.SetString(sValue);
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
	if (bIsSurvivor(client))
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
		delete g_hDrugTimer[client];
	}
	return Plugin_Continue;
}

public Action tTimerFlashEffect(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (g_iTankType[client] == 11 && bIsValidClient(client))
	{
		float flTankPos[3];
		float flTankAng[3];
		GetClientAbsOrigin(client, flTankPos);
		GetClientAbsAngles(client, flTankAng);
		int iAnim = GetEntProp(client, Prop_Send, "m_nSequence");
		int iEntity = CreateEntityByName("prop_dynamic");
		if (IsValidEntity(iEntity))
		{
			SetEntityModel(iEntity, "models/infected/hulk.mdl");
			DispatchKeyValue(iEntity, "solid", "6");
			TeleportEntity(iEntity, flTankPos, flTankAng, NULL_VECTOR);
			DispatchSpawn(iEntity);
			AcceptEntityInput(iEntity, "DisableCollision");
			SetEntityRenderColor(iEntity, 255, 0, 0, 50);
			SetEntProp(iEntity, Prop_Send, "m_nSequence", iAnim);
			SetEntPropFloat(iEntity, Prop_Send, "m_flPlaybackRate", 5.0);
			iEntity = EntIndexToEntRef(iEntity);
			vDeleteEntity(iEntity, 0.3);
		}		
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
		SetEntityGravity(client, 1.0);
	}
	return Plugin_Continue;
}

public Action tTimerHeal(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (g_iTankType[client] == 15 && bIsValidClient(client))
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
			if (flDistance < 500)
			{
				int iHealth = GetClientHealth(client);
				if (iHealth > 500)
				{
					SetEntityHealth(client, iHealth + g_cvSTHealCommon.IntValue);
					if (bIsL4D2Game())
					{
						SetEntProp(client, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 185, 0));
						SetEntProp(client, Prop_Send, "m_iGlowType", 3);
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
				if (flDistance < 500)
				{
					int iHealth = GetClientHealth(client);
					if (iHealth > 500)
					{
						SetEntityHealth(client, iHealth + g_cvSTHealSpecial.IntValue);
						if (iType < 2 && bIsL4D2Game())
						{
							SetEntProp(client, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 220, 0));
							SetEntProp(client, Prop_Send, "m_iGlowType", 3);
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
				if (flDistance < 500)
				{
					int iHealth = GetClientHealth(client);
					if (iHealth > 500)
					{
						SetEntityHealth(client, iHealth + g_cvSTHealTank.IntValue);
						if (bIsL4D2Game())
						{
							SetEntProp(client, Prop_Send, "m_glowColorOverride", iGetRGBColor(0, 255, 0));
							SetEntProp(client, Prop_Send, "m_iGlowType", 3);
							SetEntProp(client, Prop_Send, "m_bFlashing", 1);
							iType = 2;
						}
					}
				}
			}
		}
		if (iType == 0 && bIsL4D2Game())
		{
			SetEntProp(client, Prop_Send, "m_glowColorOverride", 0);
			SetEntProp(client, Prop_Send, "m_iGlowType", 0);
			SetEntProp(client, Prop_Send, "m_bFlashing", 0);
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
	if (!IsClientInGame(iSurvivor) || GetClientTeam(iSurvivor) != 1 || iGetIdleBot(iSurvivor) || IsFakeClient(iSurvivor))
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
	if ((g_iTankType[iTank] != 5 && g_iTankType[iTank] != 6 && g_iTankType[iTank] != 7 && g_iTankType[iTank] != 16 && g_iTankType[iTank] != 21 && g_iTankType[iTank] != 31 && g_iTankType[iTank] != 32 && g_iTankType[iTank] != 36) || iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank) || (iRock = EntRefToEntIndex(iRock)) == INVALID_ENT_REFERENCE)
	{
		return Plugin_Stop;
	}
	if (bIsValidClient(iTank))
	{
		float flVelocity[3];
		if (IsValidEntity(iRock))
		{
			GetEntPropVector(iRock, Prop_Data, "m_vecVelocity", flVelocity);
			float flVector = GetVectorLength(flVelocity);
			if (flVector > 500.0)
			{
				int iInfected = CreateFakeClient("Minion");
				if (iInfected > 0)
				{
					switch (g_iTankType[iTank])
					{
						case 5: vSpawnInfected(iInfected, 2, false);
						case 6: vSpawnInfected(iInfected, 6, false);
						case 7: vSpawnInfected(iInfected, 8, false);
						case 16: vSpawnInfected(iInfected, 3, false);
						case 21: vSpawnInfected(iInfected, 5, false);
						case 31: vSpawnInfected(iInfected, 1, false);
						case 32: vSpawnInfected(iInfected, 4, false);
						case 36: vSpawnInfected(iInfected, 7, false);
					}
					float flPos[3];
					GetEntPropVector(iRock, Prop_Send, "m_vecOrigin", flPos);
					AcceptEntityInput(iRock, "Kill");
					NormalizeVector(flVelocity, flVelocity);
					float flSpeed = g_cvSTTankThrowForce.FloatValue;
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
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (g_iTankType[client] == 22 && GetRandomInt(1, g_cvSTJumperChance.IntValue) == 1 && bIsValidClient(client))
	{
		if (iGetNearestSurvivor(client) > 200 && iGetNearestSurvivor(client) < 2000)
		{
			vFakeJump(client);
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
	if (iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank))
	{
		return Plugin_Stop;
	}
	if (g_iTankType[iTank] == 23 && bIsValidClient(iTank))
	{
		if ((GetEngineTime() - flTime) > 5.0)
		{
			g_bMeteor[iTank] = false;
		}
		int iEntity = -1;
		if (bIsTank(iTank) && g_bMeteor[iTank])
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
					SetEntityModel(iRock, "models/props_debris/concrete_chunk01a.mdl");
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
	if (bIsSurvivor(client))
	{
		delete g_hShakeTimer[client];
	}
	return Plugin_Continue;
}

public Action tTimerShield(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (g_iTankType[client] == 28 && bIsValidClient(client) && !g_bShielded[client])
	{
		vShieldAbility(client, true);
	}
	return Plugin_Continue;
}

public Action tTimerPropaneThrow(Handle timer, DataPack pack)
{
	pack.Reset();
	int iTank = GetClientOfUserId(pack.ReadCell());
	int iRock = EntRefToEntIndex(pack.ReadCell());
	if (iTank == 0 || !IsClientInGame(iTank) || !IsPlayerAlive(iTank) || (iRock = EntRefToEntIndex(iRock)) == INVALID_ENT_REFERENCE)
	{
		return Plugin_Stop;
	}
	if (g_iTankType[iTank] == 28 && bIsValidClient(iTank))
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
					float flSpeed = g_cvSTTankThrowForce.FloatValue;
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
	int iShover = CreateFakeClient("Shover");
	if (bIsSurvivor(client) && iShover > 0)
	{
		float flOrigin[3];
		GetClientAbsOrigin(iShover, flOrigin);
		SDKCall(g_hSDKShovePlayer, client, iShover, flOrigin);
		KickClient(iShover);
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
	if (bIsSurvivor(client))
	{
		delete g_hShoveTimer[client];
	}
	return Plugin_Continue;
}

public Action tTimerSmoker(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0 || !IsClientInGame(client) || !IsPlayerAlive(client))
	{
		return Plugin_Stop;
	}
	if (g_iTankType[client] == 31 && bIsValidClient(client))
	{
		vAttachParticle(client, PARTICLE_CLOUD, 1.2, 0.0);
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
		SetEntProp(client, Prop_Send, "m_iFOV", g_cvSTVisualFOV.IntValue);
		SetEntProp(client, Prop_Send, "m_iDefaultFOV", g_cvSTVisualFOV.IntValue);
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
	if (bIsSurvivor(client))
	{
		SetEntProp(client, Prop_Send, "m_iFOV", 90);
		SetEntProp(client, Prop_Send, "m_iDefaultFOV", 90);
		delete g_hVisionTimer[client];
	}
	return Plugin_Continue;
}

public Action tTimerUpdatePlayerCount(Handle timer)
{
	g_cvSTConfigExecute.GetString(g_sConfigOption, sizeof(g_sConfigOption));
	if (!g_cvSTEnable.BoolValue || !bIsSystemValid(g_cvSTGameMode, g_cvSTEnabledGameModes, g_cvSTDisabledGameModes, g_cvSTGameModeTypes) || StrContains(g_sConfigOption, "5", false) == -1)
	{
		return Plugin_Continue;
	}
	char sCountConfig[512];
	Format(sCountConfig, sizeof(sCountConfig), "cfg/sourcemod/super_tanks++/playercount_configs/%d.cfg", iGetPlayerCount());
	if (FileExists(sCountConfig, true))
	{
		strcopy(sCountConfig, sizeof(sCountConfig), sCountConfig[4]);
		ServerCommand("exec \"%s\"", sCountConfig);
	}
	return Plugin_Continue;
}

public Action tTimerTankHealthUpdate(Handle timer)
{
	if (!g_cvSTEnable.BoolValue || !bIsSystemValid(g_cvSTGameMode, g_cvSTEnabledGameModes, g_cvSTDisabledGameModes, g_cvSTGameModeTypes))
	{
		return Plugin_Continue;
	}
	if (g_cvSTDisplayHealth.IntValue > 0)
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
					if (StrEqual(sClassname, "player", false))
					{
						if (bIsTank(iTarget))
						{
							if (g_cvSTDisplayHealth.IntValue == 3)
							{
								int iHealth = GetClientHealth(iTarget);
								PrintHintText(iSurvivor, "%s %N (%d HP)", ST_PREFIX, iTarget, iHealth);
							}
							else if (g_cvSTDisplayHealth.IntValue == 2)
							{
								int iHealth = GetClientHealth(iTarget);
								PrintHintText(iSurvivor, "%s %d HP", ST_PREFIX, iHealth);
							}
							else if (g_cvSTDisplayHealth.IntValue == 1)
							{
								PrintHintText(iSurvivor, "%s %N", ST_PREFIX, iTarget);
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
	if (!g_cvSTEnable.BoolValue || !bIsSystemValid(g_cvSTGameMode, g_cvSTEnabledGameModes, g_cvSTDisabledGameModes, g_cvSTGameModeTypes))
	{
		return Plugin_Continue;
	}
	g_cvSTMaxPlayerZombies.SetInt(32);
	if (iGetTankCount() > 0)
	{
		for (int iTank = 1; iTank <= MaxClients; iTank++)
		{
			if (bIsTank(iTank) && IsFakeClient(iTank))
			{
				switch (g_iTankType[iTank])
				{
					case 8: vCommonAbility(iTank);
					case 11: vFlashAbility(iTank);
					case 13: vGhostAbility(iTank);
					case 14: vGravityAbility(iTank);
					case 15: vHealAbility(iTank);
					case 23: vMeteorAbility(iTank);
					case 35: vWarpAbility(iTank);
				}
				if (g_cvSTFireImmunity[g_iTankType[iTank]].BoolValue && bIsPlayerBurning(iTank))
				{
					ExtinguishEntity(iTank);
					SetEntPropFloat(iTank, Prop_Send, "m_burnPercent", 1.0);
				}
				SetEntPropFloat(iTank, Prop_Data, "m_flLaggedMovementValue", g_cvSTRunSpeed[g_iTankType[iTank]].FloatValue);
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
	if (bIsTank(client) && IsFakeClient(client))
	{
		switch (g_iTankType[client])
		{
			case 0: vSetName(client);
			case 1: vSetName(client, "Acidic Tank", 255, 0, 0, 255);
			case 2: vSetName(client, "Ammo Tank", 5, 20, 35, 255);
			case 3: vSetName(client, "Blind Tank", 30, 20, 0, 255);
			case 4: vSetName(client, "Bomber Tank", 15, 15, 15, 255);
			case 5: vSetName(client, "Boomer Tank", 0, 0, 65, 255);
			case 6: vSetName(client, "Charger Tank", 25, 255, 115, 255);
			case 7: vSetName(client, "Clone Tank", 140, 40, 255, 255);
			case 8: vSetName(client, "Common Tank", 190, 255, 250, 255);
			case 9: vSetName(client, "Drug Tank", 55, 205, 65, 255);
			case 10: vSetName(client, "Fire Tank", 255, 135, 0, 255);
			case 11: vSetName(client, "Flash Tank", 255, 255, 0, 150, RENDER_TRANSTEXTURE);
			case 12: vSetName(client, "Flinger Tank", 25, 40, 130, 255);
			case 13: vSetName(client, "Ghost Tank", 150, 150, 150, 150, RENDER_TRANSTEXTURE);
			case 14: vSetName(client, "Gravity Tank", 255, 0, 0, 255);
			case 15: vSetName(client, "Healer Tank", 255, 255, 255, 255);
			case 16: vSetName(client, "Hunter Tank", 200, 200, 200, 255);
			case 17: vSetName(client, "Hypnotizer Tank", 255, 250, 45, 255);
			case 18: vSetName(client, "Ice Tank", 170, 240, 255, 200, RENDER_TRANSTEXTURE);
			case 19: vSetName(client, "Idler Tank", 10, 40, 15, 255);
			case 20: vSetName(client, "Inverter Tank", 250, 65, 255, 255);
			case 21: vSetName(client, "Jockey Tank", 130, 0, 0, 255);
			case 22:
			{
				vJumperEffect(client);
				vSetName(client, "Jumper Tank", 225, 0, 205, 255);
			}
			case 23: vSetName(client, "Meteor Tank", 200, 200, 200, 255);
			case 24: vSetName(client, "Puke Tank", 140, 0, 0, 255);
			case 25: vSetName(client, "Restarter Tank", 225, 235, 0, 255);
			case 26: vSetName(client, "Rocketeer Tank", 255, 180, 50, 255);
			case 27: vSetName(client, "Shake Tank", 0, 170, 255, 255);
			case 28:
			{
				if (!g_bShielded[client])
				{
					vShieldAbility(client, true);
				}
				vSetName(client, "Shield Tank", 25, 125, 125, 255);
			}
			case 29: vSetName(client, "Shove Tank", 25, 10, 0, 255);
			case 30: vSetName(client, "Slugger Tank", 0, 0, 50, 255);
			case 31:
			{
				vSmokerEffect(client);
				vSetName(client, "Smoker Tank", 200, 100, 145, 255);
			}
			case 32: vSetName(client, "Spitter Tank", 255, 80, 150, 255);
			case 33: vSetName(client, "Stun Tank", 255, 185, 45, 255);
			case 34: vSetName(client, "Visual Tank", 255, 40, 10, 255);
			case 35: vSetName(client, "Warp Tank", 225, 100, 0, 255);
			case 36: vSetName(client, "Witch Tank", 255, 210, 80, 255);
		}
		if (g_cvSTExtraHealth[g_iTankType[client]].IntValue > 0)
		{
			int iHealth = GetClientHealth(client);
			int iExtraHealth = (iGetHumanCount() > 1) ? ((g_cvSTExtraHealth[g_iTankType[client]].IntValue * iGetHumanCount()) + iHealth) : (g_cvSTExtraHealth[g_iTankType[client]].IntValue + iHealth);
			SetEntityHealth(client, (iExtraHealth > 62400) ? 62400 : iExtraHealth);
		}
		vThrowInterval(client, g_cvSTThrowInterval[g_iTankType[client]].FloatValue);
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
	if (iThrower > 0 && bIsTank(iThrower) && IsFakeClient(iThrower))
	{
		DataPack dpDataPack;
		CreateDataTimer(0.1, tTimerInfectedThrow, dpDataPack, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
		dpDataPack.WriteCell(GetClientUserId(iThrower));
		dpDataPack.WriteCell(EntIndexToEntRef(entity));
		if (g_iTankType[iThrower] == 28)
		{
			DataPack dpDataPack2;
			CreateDataTimer(0.1, tTimerPropaneThrow, dpDataPack2, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
			dpDataPack2.WriteCell(GetClientUserId(iThrower));
			dpDataPack2.WriteCell(EntIndexToEntRef(entity));
		}
	}
	return Plugin_Continue;
}

public Action tTimerSpawnTanks(Handle timer)
{
	char sTankWave[12];
	char sNumbers[3][4];
	g_cvSTTankWaves.GetString(sTankWave, sizeof(sTankWave));
	ExplodeString(sTankWave, ",", sNumbers, sizeof(sNumbers), sizeof(sNumbers[]));
	int iWave1 = StringToInt(sNumbers[0]);
	int iWave2 = StringToInt(sNumbers[1]);
	int iWave3 = StringToInt(sNumbers[2]);
	if (g_iTankWave == 1)
	{
		vSpawnTank(iWave1);
	}
	else if (g_iTankWave == 2)
	{
		vSpawnTank(iWave2);
	}
	else if (g_iTankWave == 3)
	{
		vSpawnTank(iWave3);
	}
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