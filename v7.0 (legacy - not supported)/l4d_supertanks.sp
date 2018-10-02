#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#define PLUGIN_VERSION		"7.0"
#define PARTICLE_SPAWN		"smoker_smokecloud"
#define PARTICLE_FIRE		"aircraft_destroy_fastFireTrail"
#define PARTICLE_WARP		"electrical_arc_01_system"
#define PARTICLE_ICE		"steam_manhole"
#define PARTICLE_SPIT		"spitter_areaofdenial_glow2"
#define PARTICLE_SPITPROJ	"spitter_projectile"
#define PARTICLE_ELEC		"electrical_arc_01_parent"
#define PARTICLE_BLOOD		"boomer_explode_D"
#define PARTICLE_EXPLODE	"boomer_explode"
#define PARTICLE_METEOR		"smoke_medium_01"

/*Arrays*/
new TankAlive[MAXPLAYERS+1];
new TankAbility[MAXPLAYERS+1];
new Rock[MAXPLAYERS+1];
new ShieldsUp[MAXPLAYERS+1];
new PlayerSpeed[MAXPLAYERS+1];

/*
Super Tanks:
1)Spawn
2)Smasher
3)Warp
4)Meteor
5)Acid
6)Health
7)Fire
8)Ice
9)Jockey
10)Hunter
11)Smoker
12)Boomer
13)Charger
14)Ghost
15)Shock
16)Witch
17)Shield
18)Cobalt
19)Jumper
20)Gravity
21)Flash
22)Reverse Flash
23)Armageddon
24)Hallucination
25)Minion
26)Bitch
27)Trap
28)Distraction
29)Feedback
30)Psychotic
31)Spitter
32)Goliath
33)Psykotik
34)Spykotik
35)Meme
36)Boss
37)Spypsy
38)Sipow
39)Poltergeist
40)Mirage
*/

/*Misc*/
new L4D2Version;
new iTankWave;
new iNumTanks;
new iFrame;
new iTick;

/*Handles*/
new Handle:hSuperTanksEnabled = INVALID_HANDLE;
new Handle:hDisplayHealthCvar = INVALID_HANDLE;
new Handle:hWave1Cvar = INVALID_HANDLE;
new Handle:hWave2Cvar = INVALID_HANDLE;
new Handle:hWave3Cvar = INVALID_HANDLE;
new Handle:hFinaleOnly = INVALID_HANDLE;
new Handle:hDefaultTanks = INVALID_HANDLE;
new Handle:hGamemodeCvar = INVALID_HANDLE;

new Handle:hDefaultOverride = INVALID_HANDLE;
new Handle:hDefaultExtraHealth = INVALID_HANDLE;
new Handle:hDefaultSpeed = INVALID_HANDLE;
new Handle:hDefaultThrow = INVALID_HANDLE;
new Handle:hDefaultFireImmunity = INVALID_HANDLE;

new Handle:hSpawnEnabled = INVALID_HANDLE;
new Handle:hSpawnExtraHealth = INVALID_HANDLE;
new Handle:hSpawnSpeed = INVALID_HANDLE;
new Handle:hSpawnThrow = INVALID_HANDLE;
new Handle:hSpawnFireImmunity = INVALID_HANDLE;
new Handle:hSpawnCommonAmount = INVALID_HANDLE;
new Handle:hSpawnCommonInterval = INVALID_HANDLE;

new Handle:hSmasherEnabled = INVALID_HANDLE;
new Handle:hSmasherExtraHealth = INVALID_HANDLE;
new Handle:hSmasherSpeed = INVALID_HANDLE;
new Handle:hSmasherThrow = INVALID_HANDLE;
new Handle:hSmasherFireImmunity = INVALID_HANDLE;
new Handle:hSmasherMaimDamage = INVALID_HANDLE;
new Handle:hSmasherCrushDamage = INVALID_HANDLE;
new Handle:hSmasherRemoveBody = INVALID_HANDLE;

new Handle:hTrapEnabled = INVALID_HANDLE;
new Handle:hTrapExtraHealth = INVALID_HANDLE;
new Handle:hTrapSpeed = INVALID_HANDLE;
new Handle:hTrapThrow = INVALID_HANDLE;
new Handle:hTrapFireImmunity = INVALID_HANDLE;
new Handle:hTrapMaimDamage = INVALID_HANDLE;
new Handle:hTrapCrushDamage = INVALID_HANDLE;
new Handle:hTrapRemoveBody = INVALID_HANDLE;

new Handle:hWarpEnabled = INVALID_HANDLE;
new Handle:hWarpExtraHealth = INVALID_HANDLE;
new Handle:hWarpSpeed = INVALID_HANDLE;
new Handle:hWarpThrow = INVALID_HANDLE;
new Handle:hWarpFireImmunity = INVALID_HANDLE;
new Handle:hWarpTeleportDelay = INVALID_HANDLE;

new Handle:hFeedbackEnabled = INVALID_HANDLE;
new Handle:hFeedbackExtraHealth = INVALID_HANDLE;
new Handle:hFeedbackSpeed = INVALID_HANDLE;
new Handle:hFeedbackThrow = INVALID_HANDLE;
new Handle:hFeedbackFireImmunity = INVALID_HANDLE;
new Handle:hFeedbackTeleportDelay = INVALID_HANDLE;
new Handle:hFeedbackPushForce = INVALID_HANDLE;
new Handle:hFeedbackStunDamage = INVALID_HANDLE;
new Handle:hFeedbackStunMovement = INVALID_HANDLE;

new Handle:hMeteorEnabled = INVALID_HANDLE;
new Handle:hMeteorExtraHealth = INVALID_HANDLE;
new Handle:hMeteorSpeed = INVALID_HANDLE;
new Handle:hMeteorThrow = INVALID_HANDLE;
new Handle:hMeteorFireImmunity = INVALID_HANDLE;
new Handle:hMeteorStormDelay = INVALID_HANDLE;
new Handle:hMeteorStormDamage = INVALID_HANDLE;

new Handle:hAcidEnabled = INVALID_HANDLE;
new Handle:hAcidExtraHealth = INVALID_HANDLE;
new Handle:hAcidSpeed = INVALID_HANDLE;
new Handle:hAcidThrow = INVALID_HANDLE;
new Handle:hAcidFireImmunity = INVALID_HANDLE;

new Handle:hHealthEnabled = INVALID_HANDLE;
new Handle:hHealthExtraHealth = INVALID_HANDLE;
new Handle:hHealthSpeed = INVALID_HANDLE;
new Handle:hHealthThrow = INVALID_HANDLE;
new Handle:hHealthFireImmunity = INVALID_HANDLE;
new Handle:hHealthHealthCommons = INVALID_HANDLE;
new Handle:hHealthHealthSpecials = INVALID_HANDLE;
new Handle:hHealthHealthTanks = INVALID_HANDLE;

new Handle:hFireEnabled = INVALID_HANDLE;
new Handle:hFireExtraHealth = INVALID_HANDLE;
new Handle:hFireSpeed = INVALID_HANDLE;
new Handle:hFireThrow = INVALID_HANDLE;
new Handle:hFireFireImmunity = INVALID_HANDLE;

new Handle:hIceEnabled = INVALID_HANDLE;
new Handle:hIceExtraHealth = INVALID_HANDLE;
new Handle:hIceSpeed = INVALID_HANDLE;
new Handle:hIceThrow = INVALID_HANDLE;
new Handle:hIceFireImmunity = INVALID_HANDLE;

new Handle:hJockeyEnabled = INVALID_HANDLE;
new Handle:hJockeyExtraHealth = INVALID_HANDLE;
new Handle:hJockeySpeed = INVALID_HANDLE;
new Handle:hJockeyThrow = INVALID_HANDLE;
new Handle:hJockeyFireImmunity = INVALID_HANDLE;

new Handle:hHunterEnabled = INVALID_HANDLE;
new Handle:hHunterExtraHealth = INVALID_HANDLE;
new Handle:hHunterSpeed = INVALID_HANDLE;
new Handle:hHunterThrow = INVALID_HANDLE;
new Handle:hHunterFireImmunity = INVALID_HANDLE;

new Handle:hSmokerEnabled = INVALID_HANDLE;
new Handle:hSmokerExtraHealth = INVALID_HANDLE;
new Handle:hSmokerSpeed = INVALID_HANDLE;
new Handle:hSmokerThrow = INVALID_HANDLE;
new Handle:hSmokerFireImmunity = INVALID_HANDLE;

new Handle:hBoomerEnabled = INVALID_HANDLE;
new Handle:hBoomerExtraHealth = INVALID_HANDLE;
new Handle:hBoomerSpeed = INVALID_HANDLE;
new Handle:hBoomerThrow = INVALID_HANDLE;
new Handle:hBoomerFireImmunity = INVALID_HANDLE;

new Handle:hChargerEnabled = INVALID_HANDLE;
new Handle:hChargerExtraHealth = INVALID_HANDLE;
new Handle:hChargerSpeed = INVALID_HANDLE;
new Handle:hChargerThrow = INVALID_HANDLE;
new Handle:hChargerFireImmunity = INVALID_HANDLE;

new Handle:hGhostEnabled = INVALID_HANDLE;
new Handle:hGhostExtraHealth = INVALID_HANDLE;
new Handle:hGhostSpeed = INVALID_HANDLE;
new Handle:hGhostThrow = INVALID_HANDLE;
new Handle:hGhostFireImmunity = INVALID_HANDLE;
new Handle:hGhostDisarm = INVALID_HANDLE;

new Handle:hShockEnabled = INVALID_HANDLE;
new Handle:hShockExtraHealth = INVALID_HANDLE;
new Handle:hShockSpeed = INVALID_HANDLE;
new Handle:hShockThrow = INVALID_HANDLE;
new Handle:hShockFireImmunity = INVALID_HANDLE;
new Handle:hShockStunDamage = INVALID_HANDLE;
new Handle:hShockStunMovement = INVALID_HANDLE;

new Handle:hWitchEnabled = INVALID_HANDLE;
new Handle:hWitchExtraHealth = INVALID_HANDLE;
new Handle:hWitchSpeed = INVALID_HANDLE;
new Handle:hWitchThrow = INVALID_HANDLE;
new Handle:hWitchFireImmunity = INVALID_HANDLE;
new Handle:hWitchMaxWitches = INVALID_HANDLE;

new Handle:hShieldEnabled = INVALID_HANDLE;
new Handle:hShieldExtraHealth = INVALID_HANDLE;
new Handle:hShieldSpeed = INVALID_HANDLE;
new Handle:hShieldThrow = INVALID_HANDLE;
new Handle:hShieldFireImmunity = INVALID_HANDLE;
new Handle:hShieldShieldsDownInterval = INVALID_HANDLE;

new Handle:hCobaltEnabled = INVALID_HANDLE;
new Handle:hCobaltExtraHealth = INVALID_HANDLE;
new Handle:hCobaltSpeed = INVALID_HANDLE;
new Handle:hCobaltThrow = INVALID_HANDLE;
new Handle:hCobaltFireImmunity = INVALID_HANDLE;
new Handle:hCobaltSpecialSpeed = INVALID_HANDLE;

new Handle:hJumperEnabled = INVALID_HANDLE;
new Handle:hJumperExtraHealth = INVALID_HANDLE;
new Handle:hJumperSpeed = INVALID_HANDLE;
new Handle:hJumperThrow = INVALID_HANDLE;
new Handle:hJumperFireImmunity = INVALID_HANDLE;
new Handle:hJumperJumpDelay = INVALID_HANDLE;

new Handle:hDistractionEnabled = INVALID_HANDLE;
new Handle:hDistractionExtraHealth = INVALID_HANDLE;
new Handle:hDistractionSpeed = INVALID_HANDLE;
new Handle:hDistractionThrow = INVALID_HANDLE;
new Handle:hDistractionFireImmunity = INVALID_HANDLE;
new Handle:hDistractionJumpDelay = INVALID_HANDLE;
new Handle:hDistractionTeleportDelay = INVALID_HANDLE;

new Handle:hGravityEnabled = INVALID_HANDLE;
new Handle:hGravityExtraHealth = INVALID_HANDLE;
new Handle:hGravitySpeed = INVALID_HANDLE;
new Handle:hGravityThrow = INVALID_HANDLE;
new Handle:hGravityFireImmunity = INVALID_HANDLE;
new Handle:hGravityPullForce = INVALID_HANDLE;

new Handle:hFlashEnabled = INVALID_HANDLE;
new Handle:hFlashExtraHealth = INVALID_HANDLE;
new Handle:hFlashSpeed = INVALID_HANDLE;
new Handle:hFlashThrow = INVALID_HANDLE;
new Handle:hFlashFireImmunity = INVALID_HANDLE;
new Handle:hFlashSpecialSpeed = INVALID_HANDLE;
new Handle:hFlashTeleportDelay = INVALID_HANDLE;

new Handle:hReverseFlashEnabled = INVALID_HANDLE;
new Handle:hReverseFlashExtraHealth = INVALID_HANDLE;
new Handle:hReverseFlashSpeed = INVALID_HANDLE;
new Handle:hReverseFlashThrow = INVALID_HANDLE;
new Handle:hReverseFlashFireImmunity = INVALID_HANDLE;
new Handle:hReverseFlashSpecialSpeed = INVALID_HANDLE;
new Handle:hReverseFlashTeleportDelay = INVALID_HANDLE;

new Handle:hArmageddonEnabled = INVALID_HANDLE;
new Handle:hArmageddonExtraHealth = INVALID_HANDLE;
new Handle:hArmageddonSpeed = INVALID_HANDLE;
new Handle:hArmageddonThrow = INVALID_HANDLE;
new Handle:hArmageddonFireImmunity = INVALID_HANDLE;
new Handle:hArmageddonStormDelay = INVALID_HANDLE;
new Handle:hArmageddonStormDamage = INVALID_HANDLE;
new Handle:hArmageddonMaimDamage = INVALID_HANDLE;
new Handle:hArmageddonCrushDamage = INVALID_HANDLE;
new Handle:hArmageddonRemoveBody = INVALID_HANDLE;
new Handle:hArmageddonPullForce = INVALID_HANDLE;

new Handle:hHallucinationEnabled = INVALID_HANDLE;
new Handle:hHallucinationExtraHealth = INVALID_HANDLE;
new Handle:hHallucinationSpeed = INVALID_HANDLE;
new Handle:hHallucinationThrow = INVALID_HANDLE;
new Handle:hHallucinationFireImmunity = INVALID_HANDLE;
new Handle:hHallucinationDisarm = INVALID_HANDLE;
new Handle:hHallucinationTeleportDelay = INVALID_HANDLE;

new Handle:hMinionEnabled = INVALID_HANDLE;
new Handle:hMinionExtraHealth = INVALID_HANDLE;
new Handle:hMinionSpeed = INVALID_HANDLE;
new Handle:hMinionThrow = INVALID_HANDLE;
new Handle:hMinionFireImmunity = INVALID_HANDLE;

new Handle:hBitchEnabled = INVALID_HANDLE;
new Handle:hBitchExtraHealth = INVALID_HANDLE;
new Handle:hBitchSpeed = INVALID_HANDLE;
new Handle:hBitchThrow = INVALID_HANDLE;
new Handle:hBitchFireImmunity = INVALID_HANDLE;

new Handle:hPsychoticEnabled = INVALID_HANDLE;
new Handle:hPsychoticExtraHealth = INVALID_HANDLE;
new Handle:hPsychoticSpeed = INVALID_HANDLE;
new Handle:hPsychoticThrow = INVALID_HANDLE;
new Handle:hPsychoticFireImmunity = INVALID_HANDLE;
new Handle:hPsychoticTeleportDelay = INVALID_HANDLE;
new Handle:hPsychoticHealthCommons = INVALID_HANDLE;
new Handle:hPsychoticHealthSpecials = INVALID_HANDLE;
new Handle:hPsychoticHealthTanks = INVALID_HANDLE;
new Handle:hPsychoticStormDelay = INVALID_HANDLE;
new Handle:hPsychoticStormDamage = INVALID_HANDLE;
new Handle:hPsychoticShieldsDownInterval = INVALID_HANDLE;
new Handle:hPsychoticJumpDelay = INVALID_HANDLE;

new Handle:hSpitterEnabled = INVALID_HANDLE;
new Handle:hSpitterExtraHealth = INVALID_HANDLE;
new Handle:hSpitterSpeed = INVALID_HANDLE;
new Handle:hSpitterThrow = INVALID_HANDLE;
new Handle:hSpitterFireImmunity = INVALID_HANDLE;

new Handle:hGoliathEnabled = INVALID_HANDLE;
new Handle:hGoliathExtraHealth = INVALID_HANDLE;
new Handle:hGoliathSpeed = INVALID_HANDLE;
new Handle:hGoliathThrow = INVALID_HANDLE;
new Handle:hGoliathFireImmunity = INVALID_HANDLE;
new Handle:hGoliathMaimDamage = INVALID_HANDLE;
new Handle:hGoliathCrushDamage = INVALID_HANDLE;
new Handle:hGoliathRemoveBody = INVALID_HANDLE;
new Handle:hGoliathHealthCommons = INVALID_HANDLE;
new Handle:hGoliathHealthSpecials = INVALID_HANDLE;
new Handle:hGoliathHealthTanks = INVALID_HANDLE;
new Handle:hGoliathShieldsDownInterval = INVALID_HANDLE;

new Handle:hPsykotikEnabled = INVALID_HANDLE;
new Handle:hPsykotikExtraHealth = INVALID_HANDLE;
new Handle:hPsykotikSpeed = INVALID_HANDLE;
new Handle:hPsykotikThrow = INVALID_HANDLE;
new Handle:hPsykotikFireImmunity = INVALID_HANDLE;
new Handle:hPsykotikSpecialSpeed = INVALID_HANDLE;
new Handle:hPsykotikTeleportDelay = INVALID_HANDLE;
new Handle:hPsykotikHealthCommons = INVALID_HANDLE;
new Handle:hPsykotikHealthSpecials = INVALID_HANDLE;
new Handle:hPsykotikHealthTanks = INVALID_HANDLE;

new Handle:hSpykotikEnabled = INVALID_HANDLE;
new Handle:hSpykotikExtraHealth = INVALID_HANDLE;
new Handle:hSpykotikSpeed = INVALID_HANDLE;
new Handle:hSpykotikThrow = INVALID_HANDLE;
new Handle:hSpykotikFireImmunity = INVALID_HANDLE;
new Handle:hSpykotikSpecialSpeed = INVALID_HANDLE;
new Handle:hSpykotikTeleportDelay = INVALID_HANDLE;

//Meme Tank
new Handle:hMemeEnabled = INVALID_HANDLE;
new Handle:hMemeExtraHealth = INVALID_HANDLE;
new Handle:hMemeSpeed = INVALID_HANDLE;
new Handle:hMemeThrow = INVALID_HANDLE;
new Handle:hMemeFireImmunity = INVALID_HANDLE;
new Handle:hMemeCommonAmount = INVALID_HANDLE;
new Handle:hMemeCommonInterval = INVALID_HANDLE;
new Handle:hMemeMaimDamage = INVALID_HANDLE;
new Handle:hMemeCrushDamage = INVALID_HANDLE;
new Handle:hMemeRemoveBody = INVALID_HANDLE;
new Handle:hMemeTeleportDelay = INVALID_HANDLE;
new Handle:hMemeStormDelay = INVALID_HANDLE;
new Handle:hMemeStormDamage = INVALID_HANDLE;
new Handle:hMemeDisarm = INVALID_HANDLE;
new Handle:hMemeMaxWitches = INVALID_HANDLE;
new Handle:hMemeSpecialSpeed = INVALID_HANDLE;
new Handle:hMemeJumpDelay = INVALID_HANDLE;
new Handle:hMemePullForce = INVALID_HANDLE;

//Boss Tank
new Handle:hBossEnabled = INVALID_HANDLE;
new Handle:hBossExtraHealth = INVALID_HANDLE;
new Handle:hBossSpeed = INVALID_HANDLE;
new Handle:hBossThrow = INVALID_HANDLE;
new Handle:hBossFireImmunity = INVALID_HANDLE;
new Handle:hBossMaimDamage = INVALID_HANDLE;
new Handle:hBossCrushDamage = INVALID_HANDLE;
new Handle:hBossRemoveBody = INVALID_HANDLE;
new Handle:hBossTeleportDelay = INVALID_HANDLE;
new Handle:hBossStormDelay = INVALID_HANDLE;
new Handle:hBossStormDamage = INVALID_HANDLE;
new Handle:hBossHealthCommons = INVALID_HANDLE;
new Handle:hBossHealthSpecials = INVALID_HANDLE;
new Handle:hBossHealthTanks = INVALID_HANDLE;
new Handle:hBossDisarm = INVALID_HANDLE;
new Handle:hBossMaxWitches = INVALID_HANDLE;
new Handle:hBossShieldsDownInterval = INVALID_HANDLE;
new Handle:hBossSpecialSpeed = INVALID_HANDLE;
new Handle:hBossJumpDelay = INVALID_HANDLE;
new Handle:hBossPullForce = INVALID_HANDLE;

new Handle:hSpypsyEnabled = INVALID_HANDLE;
new Handle:hSpypsyExtraHealth = INVALID_HANDLE;
new Handle:hSpypsySpeed = INVALID_HANDLE;
new Handle:hSpypsyThrow = INVALID_HANDLE;
new Handle:hSpypsyFireImmunity = INVALID_HANDLE;
new Handle:hSpypsySpecialSpeed = INVALID_HANDLE;
new Handle:hSpypsyTeleportDelay = INVALID_HANDLE;

new Handle:hSipowEnabled = INVALID_HANDLE;
new Handle:hSipowExtraHealth = INVALID_HANDLE;
new Handle:hSipowSpeed = INVALID_HANDLE;
new Handle:hSipowThrow = INVALID_HANDLE;
new Handle:hSipowFireImmunity = INVALID_HANDLE;
new Handle:hSipowStormDelay = INVALID_HANDLE;
new Handle:hSipowStormDamage = INVALID_HANDLE;

new Handle:hPoltergeistEnabled = INVALID_HANDLE;
new Handle:hPoltergeistExtraHealth = INVALID_HANDLE;
new Handle:hPoltergeistSpeed = INVALID_HANDLE;
new Handle:hPoltergeistThrow = INVALID_HANDLE;
new Handle:hPoltergeistFireImmunity = INVALID_HANDLE;
new Handle:hPoltergeistDisarm = INVALID_HANDLE;
new Handle:hPoltergeistSpecialSpeed = INVALID_HANDLE;
new Handle:hPoltergeistTeleportDelay = INVALID_HANDLE;

new Handle:hMirageEnabled = INVALID_HANDLE;
new Handle:hMirageExtraHealth = INVALID_HANDLE;
new Handle:hMirageSpeed = INVALID_HANDLE;
new Handle:hMirageThrow = INVALID_HANDLE;
new Handle:hMirageFireImmunity = INVALID_HANDLE;
new Handle:hMirageSpecialSpeed = INVALID_HANDLE;
new Handle:hMirageTeleportDelay = INVALID_HANDLE;

static Handle:SDKSpitBurst 		= INVALID_HANDLE;
static Handle:SDKVomitOnPlayer 		= INVALID_HANDLE;

new bool:bSuperTanksEnabled;
new iWave1Cvar;
new iWave2Cvar;
new iWave3Cvar;
new bool:bFinaleOnly;
new bool:bDisplayHealthCvar;
new bool:bDefaultTanks;

new bool:bTankEnabled[40+1];
new iTankExtraHealth[40+1];
new Float:flTankSpeed[40+1];
new Float:flTankThrow[40+1];
new bool:bTankFireImmunity[40+1];

new bool:bDefaultOverride;
new iSpawnCommonAmount;
new iSpawnCommonInterval;
new iSmasherMaimDamage;
new iSmasherCrushDamage;
new bool:bSmasherRemoveBody;
new iArmageddonMaimDamage;
new iArmageddonCrushDamage;
new bool:bArmageddonRemoveBody;
new iTrapMaimDamage;
new iTrapCrushDamage;
new bool:bTrapRemoveBody;
new iGoliathMaimDamage;
new iGoliathCrushDamage;
new bool:bGoliathRemoveBody;
new iWarpTeleportDelay;
new iPsychoticTeleportDelay;
new iFlashTeleportDelay;
new iReverseFlashTeleportDelay;
new iDistractionTeleportDelay;
new iHallucinationTeleportDelay;
new iFeedbackTeleportDelay;
new iPsykotikTeleportDelay;
new iSpykotikTeleportDelay;
new iSpypsyTeleportDelay;
new iPoltergeistTeleportDelay;
new iMirageTeleportDelay;
new iMeteorStormDelay;
new Float:flMeteorStormDamage;
new iPsychoticStormDelay;
new Float:flPsychoticStormDamage;
new iArmageddonStormDelay;
new Float:flArmageddonStormDamage;
new iSipowStormDelay;
new Float:flSipowStormDamage;
new iHealthHealthCommons;
new iHealthHealthSpecials;
new iHealthHealthTanks;
new iPsychoticHealthCommons;
new iPsychoticHealthSpecials;
new iPsychoticHealthTanks;
new iGoliathHealthCommons;
new iGoliathHealthSpecials;
new iGoliathHealthTanks;
new iPsykotikHealthCommons;
new iPsykotikHealthSpecials;
new iPsykotikHealthTanks;
new bool:bGhostDisarm;
new bool:bHallucinationDisarm;
new bool:bPoltergeistDisarm;
new iShockStunDamage;
new Float:flShockStunMovement;
new iFeedbackStunDamage;
new Float:flFeedbackStunMovement;
new iWitchMaxWitches;
new Float:flShieldShieldsDownInterval;
new Float:flPsychoticShieldsDownInterval;
new Float:flGoliathShieldsDownInterval;
new Float:flCobaltSpecialSpeed;
new Float:flFlashSpecialSpeed;
new Float:flReverseFlashSpecialSpeed;
new Float:flPsykotikSpecialSpeed;
new Float:flSpykotikSpecialSpeed;
new Float:flSpypsySpecialSpeed;
new Float:flPoltergeistSpecialSpeed;
new Float:flMirageSpecialSpeed;
new iJumperJumpDelay;
new iPsychoticJumpDelay;
new iDistractionJumpDelay;
new Float:flGravityPullForce;
new Float:flArmageddonPullForce;
new Float:flFeedbackPushForce;

//Meme Tank
new iMemeCommonAmount;
new iMemeCommonInterval;
new iMemeMaimDamage;
new iMemeCrushDamage;
new bool:bMemeRemoveBody;
new iMemeTeleportDelay;
new iMemeStormDelay;
new Float:flMemeStormDamage;
new bool:bMemeDisarm;
new iMemeMaxWitches;
new Float:flMemeSpecialSpeed;
new iMemeJumpDelay;
new Float:flMemePullForce;

//Boss Tank
new iBossMaimDamage;
new iBossCrushDamage;
new bool:bBossRemoveBody;
new iBossTeleportDelay;
new iBossStormDelay;
new Float:flBossStormDamage;
new iBossHealthCommons;
new iBossHealthSpecials;
new iBossHealthTanks;
new bool:bBossDisarm;
new iBossMaxWitches;
new Float:flBossShieldsDownInterval;
new Float:flBossSpecialSpeed;
new iBossJumpDelay;
new Float:flBossPullForce;

public Plugin:myinfo =
{
	name = "[L4D & L4D2] Super Tanks+",
	author = "Machine and Psykotik",
	description = "Adds 28 (L4D) to 40 (L4D2) unique types of finale Tanks to Coop, Realism, and Survival gamemodes.",
	version = PLUGIN_VERSION,
	url = "http://forums.alliedmods.net/showthread.php?t=302140"
}

public OnPluginStart()
{
	GameCheck();
	CreateConVar("st_version", PLUGIN_VERSION, "Super Tanks Version",FCVAR_DONTRECORD|FCVAR_NOTIFY);
	hSuperTanksEnabled = CreateConVar("st_on", "1.0", "Is Super Tanks enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hDisplayHealthCvar = CreateConVar("st_display_health", "1.0", "Display tanks health in crosshair?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hWave1Cvar = CreateConVar("st_wave1_tanks", "1.0", "Default number of tanks in the 1st wave of finale.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hWave2Cvar = CreateConVar("st_wave2_tanks", "2.0", "Default number of tanks in the 2nd wave of finale.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hWave3Cvar = CreateConVar("st_wave3_tanks", "3.0", "Default number of tanks in the finale escape.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hFinaleOnly = CreateConVar("st_finale_only", "0.0", "Create Super Tanks in finale only?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hDefaultTanks = CreateConVar("st_default_tanks", "0.0", "Only use default tanks?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hGamemodeCvar = FindConVar("mp_gamemode");

	hDefaultOverride = CreateConVar("st_default_override", "0.0", "Setting this to 1 will allow further customization to default tanks.",FCVAR_NOTIFY,true,0.0,true,1.0);
	hDefaultExtraHealth = CreateConVar("st_default_extra_health", "0.0", "Default Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hDefaultSpeed = CreateConVar("st_default_speed", "1.0", "Default Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hDefaultThrow = CreateConVar("st_default_throw", "5.0", "Default Tanks rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hDefaultFireImmunity = CreateConVar("st_default_fire_immunity", "0.0", "Are Default Tanks immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	if(L4D2Version)
	{
		hSpawnEnabled = CreateConVar("st_spawn_enabled", "1.0", "Is Spawn Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hSpawnExtraHealth = CreateConVar("st_spawn_extra_health", "50.0", "Spawn Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
		hSpawnSpeed = CreateConVar("st_spawn_speed", "1.0", "Spawn Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
		hSpawnThrow = CreateConVar("st_spawn_throw", "10.0", "Spawn Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
		hSpawnFireImmunity = CreateConVar("st_spawn_fire_immunity", "0.0", "Is Spawn Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hSpawnCommonAmount = CreateConVar("st_spawn_common_amount", "10.0", "Number of common infected spawned by the Spawn Tank.",FCVAR_NOTIFY,true,1.0,true,50.0);
		hSpawnCommonInterval = CreateConVar("st_spawn_common_interval", "10.0", "Spawn Tanks common infected spawn interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
	}
	hSmasherEnabled = CreateConVar("st_smasher_enabled", "1.0", "Is Smasher Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hSmasherExtraHealth = CreateConVar("st_smasher_extra_health", "4000.0", "Smasher Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hSmasherSpeed = CreateConVar("st_smasher_speed", "0.65", "Smasher Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hSmasherThrow = CreateConVar("st_smasher_throw", "30.0", "Smasher Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hSmasherFireImmunity = CreateConVar("st_smasher_fire_immunity", "0.0", "Is Smasher Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hSmasherMaimDamage = CreateConVar("st_smasher_maim_damage", "1.0", "Smasher Tanks maim attack will set victims health to this amount.",FCVAR_NOTIFY,true,1.0,true,99.0);
	hSmasherCrushDamage = CreateConVar("st_smasher_crush_damage", "50.0", "Smasher Tanks claw attack damage.",FCVAR_NOTIFY,true,0.0,true,1000.0);
	hSmasherRemoveBody = CreateConVar("st_smasher_remove_body", "1.0", "Smasher Tanks crush attack will remove survivors death body?",FCVAR_NOTIFY,true,0.0,true,1.0);

	hTrapEnabled = CreateConVar("st_trap_enabled", "1.0", "Is Trap Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hTrapExtraHealth = CreateConVar("st_trap_extra_health", "6000.0", "Trap Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hTrapSpeed = CreateConVar("st_trap_speed", "0.5", "Trap Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,1.5);
	hTrapThrow = CreateConVar("st_trap_throw", "999.0", "Trap Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hTrapFireImmunity = CreateConVar("st_trap_fire_immunity", "0.0", "Is Trap Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hTrapMaimDamage = CreateConVar("st_trap_maim_damage", "1.0", "Trap Tanks maim attack will set victims health to this amount.",FCVAR_NOTIFY,true,1.0,true,99.0);
	hTrapCrushDamage = CreateConVar("st_trap_crush_damage", "1000.0", "Trap Tanks claw attack damage.",FCVAR_NOTIFY,true,0.0,true,1000.0);
	hTrapRemoveBody = CreateConVar("st_trap_remove_body", "1.0", "Trap Tanks crush attack will remove survivors death body?",FCVAR_NOTIFY,true,0.0,true,1.0);

	hWarpEnabled = CreateConVar("st_warp_enabled", "1.0", "Is Warp Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hWarpExtraHealth = CreateConVar("st_warp_extra_health", "2500.0", "Warp Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hWarpSpeed = CreateConVar("st_warp_speed", "1.0", "Warp Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hWarpThrow = CreateConVar("st_warp_throw", "9.0", "Warp Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hWarpFireImmunity = CreateConVar("st_warp_fire_immunity", "0.0", "Is Warp Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hWarpTeleportDelay = CreateConVar("st_warp_teleport_delay", "20.0", "Warp Tanks Teleport Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);

	hFeedbackEnabled = CreateConVar("st_feedback_enabled", "1.0", "Is Feedback Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hFeedbackExtraHealth = CreateConVar("st_feedback_extra_health", "6000.0", "Feedback Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hFeedbackSpeed = CreateConVar("st_feedback_speed", "1.25", "Feedback Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.5);
	hFeedbackThrow = CreateConVar("st_feedback_throw", "999.0", "Feedback Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hFeedbackFireImmunity = CreateConVar("st_feedback_fire_immunity", "0.0", "Is Feedback Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hFeedbackTeleportDelay = CreateConVar("st_feedback_teleport_delay", "5.0", "Feedback Tanks Teleport Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
	hFeedbackPushForce = CreateConVar("st_feedback_push_force", "50.0", "Feedback Tanks push force value. Higher negative values equals greater push forces.",FCVAR_NOTIFY,true,-200.0,true,200.0);
	hFeedbackStunDamage = CreateConVar("st_feedback_stun_damage", "15.0", "Feedback Tanks stun damage.",FCVAR_NOTIFY,true,0.0,true,1000.0);
	hFeedbackStunMovement = CreateConVar("st_feedback_stun_movement", "0.65", "Feedback Tanks stun reduce survivors speed to this amount.",FCVAR_NOTIFY,true,0.0,true,1.0);

	hMeteorEnabled = CreateConVar("st_meteor_enabled", "1.0", "Is Meteor Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hMeteorExtraHealth = CreateConVar("st_meteor_extra_health", "2500.0", "Meteor Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hMeteorSpeed = CreateConVar("st_meteor_speed", "1.0", "Meteor Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hMeteorThrow = CreateConVar("st_meteor_throw", "10.0", "Meteor Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hMeteorFireImmunity = CreateConVar("st_meteor_fire_immunity", "1.0", "Is Meteor Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hMeteorStormDelay = CreateConVar("st_meteor_storm_delay", "30.0", "Meteor Tanks Meteor Storm Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
	hMeteorStormDamage = CreateConVar("st_meteor_storm_damage", "25.0", "Meteor Tanks falling meteor damage.",FCVAR_NOTIFY,true,0.0,true,1000.0);
	if(L4D2Version)
	{
		hAcidEnabled = CreateConVar("st_acid_enabled", "1.0", "Is Acid Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hAcidExtraHealth = CreateConVar("st_acid_extra_health", "350.0", "Acid Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
		hAcidSpeed = CreateConVar("st_acid_speed", "1.0", "Acid Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
		hAcidThrow = CreateConVar("st_acid_throw", "6.0", "Acid Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
		hAcidFireImmunity = CreateConVar("st_acid_fire_immunity", "0.0", "Is Acid Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	}
	hHealthEnabled = CreateConVar("st_health_enabled", "1.0", "Is Health Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hHealthExtraHealth = CreateConVar("st_health_extra_health", "1500.0", "Health Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hHealthSpeed = CreateConVar("st_health_speed", "1.0", "Health Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hHealthThrow = CreateConVar("st_health_throw", "15.0", "Health Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hHealthFireImmunity = CreateConVar("st_health_fire_immunity", "0.0", "Is Health Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hHealthHealthCommons = CreateConVar("st_health_health_commons", "50.0", "Health Tanks receive this much health per second from being near a common infected.",FCVAR_NOTIFY,true,0.0,true,500.0);
	hHealthHealthSpecials = CreateConVar("st_health_health_specials", "100.0", "Health Tanks receive this much health per second from being near a special infected.",FCVAR_NOTIFY,true,0.0,true,1000.0);
	hHealthHealthTanks = CreateConVar("st_health_health_tanks", "500.0", "Health Tanks receive this much health per second from being near another tank.",FCVAR_NOTIFY,true,0.0,true,5000.0);

	hFireEnabled = CreateConVar("st_fire_enabled", "1.0", "Is Fire Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hFireExtraHealth = CreateConVar("st_fire_extra_health", "2000.0", "Fire Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hFireSpeed = CreateConVar("st_fire_speed", "1.0", "Fire Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hFireThrow = CreateConVar("st_fire_throw", "6.0", "Fire Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hFireFireImmunity = CreateConVar("st_fire_fire_immunity", "1.0", "Is Fire Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	if(L4D2Version)
	{
		hIceEnabled = CreateConVar("st_ice_enabled", "1.0", "Is Ice Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hIceExtraHealth = CreateConVar("st_ice_extra_health", "2000.0", "Ice Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
		hIceSpeed = CreateConVar("st_ice_speed", "1.0", "Ice Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
		hIceThrow = CreateConVar("st_ice_throw", "6.0", "Ice Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
		hIceFireImmunity = CreateConVar("st_ice_fire_immunity", "0.0", "Is Ice Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);

		hJockeyEnabled = CreateConVar("st_jockey_enabled", "1.0", "Is Jockey Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hJockeyExtraHealth = CreateConVar("st_jockey_extra_health", "525.0", "Jockey Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
		hJockeySpeed = CreateConVar("st_jockey_speed", "1.33", "Jockey Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.5);
		hJockeyThrow = CreateConVar("st_jockey_throw", "7.0", "Jockey Tank jockey throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
		hJockeyFireImmunity = CreateConVar("st_jockey_fire_immunity", "0.0", "Is Jockey Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	}
	hHunterEnabled = CreateConVar("st_hunter_enabled", "1.0", "Is Hunter Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hHunterExtraHealth = CreateConVar("st_hunter_extra_health", "450.0", "Hunter Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hHunterSpeed = CreateConVar("st_hunter_speed", "1.33", "Hunter Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.5);
	hHunterThrow = CreateConVar("st_hunter_throw", "7.0", "Hunter Tank hunter throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hHunterFireImmunity = CreateConVar("st_hunter_fire_immunity", "0.0", "Is Hunter Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);

	hSmokerEnabled = CreateConVar("st_smoker_enabled", "1.0", "Is Smoker Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hSmokerExtraHealth = CreateConVar("st_smoker_extra_health", "450.0", "Smoker Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hSmokerSpeed = CreateConVar("st_smoker_speed", "1.33", "Smoker Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.5);
	hSmokerThrow = CreateConVar("st_smoker_throw", "7.0", "Smoker Tank smoker throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hSmokerFireImmunity = CreateConVar("st_smoker_fire_immunity", "0.0", "Is Smoker Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);

	hBoomerEnabled = CreateConVar("st_boomer_enabled", "1.0", "Is Boomer Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hBoomerExtraHealth = CreateConVar("st_boomer_extra_health", "250.0", "Boomer Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hBoomerSpeed = CreateConVar("st_boomer_speed", "1.33", "Boomer Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.5);
	hBoomerThrow = CreateConVar("st_boomer_throw", "7.0", "Boomer Tank boomer throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hBoomerFireImmunity = CreateConVar("st_boomer_fire_immunity", "0.0", "Is Boomer Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	if(L4D2Version)
	{
		hChargerEnabled = CreateConVar("st_charger_enabled", "1.0", "Is Charger Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hChargerExtraHealth = CreateConVar("st_charger_extra_health", "800.0", "Charger Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
		hChargerSpeed = CreateConVar("st_charger_speed", "1.33", "Charger Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.5);
		hChargerThrow = CreateConVar("st_charger_throw", "7.0", "Charger Tank charger throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
		hChargerFireImmunity = CreateConVar("st_charger_fire_immunity", "0.0", "Is Charger Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);

		hGhostEnabled = CreateConVar("st_ghost_enabled", "1.0", "Is Ghost Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hGhostExtraHealth = CreateConVar("st_ghost_extra_health", "3500.0", "Ghost Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
		hGhostSpeed = CreateConVar("st_ghost_speed", "1.0", "Ghost Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
		hGhostThrow = CreateConVar("st_ghost_throw", "15.0", "Ghost Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
		hGhostFireImmunity = CreateConVar("st_ghost_fire_immunity", "1.0", "Is Ghost Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hGhostDisarm = CreateConVar("st_ghost_disarm", "1.0", "Does Ghost Tank have a chance of disarming an attacking melee survivor?",FCVAR_NOTIFY,true,0.0,true,1.0);
	}
	hShockEnabled = CreateConVar("st_shock_enabled", "1.0", "Is Shock Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hShockExtraHealth = CreateConVar("st_shock_extra_health", "2500.0", "Shock Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hShockSpeed = CreateConVar("st_shock_speed", "1.0", "Shock Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hShockThrow = CreateConVar("st_shock_throw", "10.0", "Shock Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hShockFireImmunity = CreateConVar("st_shock_fire_immunity", "0.0", "Is Shock Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hShockStunDamage = CreateConVar("st_shock_stun_damage", "10.0", "Shock Tanks stun damage.",FCVAR_NOTIFY,true,0.0,true,1000.0);
	hShockStunMovement = CreateConVar("st_shock_stun_movement", "0.75", "Shock Tanks stun reduce survivors speed to this amount.",FCVAR_NOTIFY,true,0.0,true,1.0);

	hWitchEnabled = CreateConVar("st_witch_enabled", "1.0", "Is Witch Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hWitchExtraHealth = CreateConVar("st_witch_extra_health", "1000.0", "Witch Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hWitchSpeed = CreateConVar("st_witch_speed", "1.0", "Witch Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hWitchThrow = CreateConVar("st_witch_throw", "7.0", "Witch Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hWitchFireImmunity = CreateConVar("st_witch_fire_immunity", "0.0", "Is Witch Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hWitchMaxWitches = CreateConVar("st_witch_max_witches", "1.0", "Maximum number of witches converted from common infected by the Witch Tank.",FCVAR_NOTIFY,true,0.0,true,100.0);

	hShieldEnabled = CreateConVar("st_shield_enabled", "1.0", "Is Shield Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hShieldExtraHealth = CreateConVar("st_shield_extra_health", "1500.0", "Shield Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hShieldSpeed = CreateConVar("st_shield_speed", "1.0", "Shield Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hShieldThrow = CreateConVar("st_shield_throw", "10.0", "Shield Tank propane throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hShieldFireImmunity = CreateConVar("st_shield_fire_immunity", "1.0", "Is Shield Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hShieldShieldsDownInterval = CreateConVar("st_shield_shields_down_interval", "15.0", "When Shield Tanks shields are disabled, how long before shields activate again.",FCVAR_NOTIFY,true,0.1,true,60.0);

	hCobaltEnabled = CreateConVar("st_cobalt_enabled", "1.0", "Is Cobalt Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hCobaltExtraHealth = CreateConVar("st_cobalt_extra_health", "4000.0", "Cobalt Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hCobaltSpeed = CreateConVar("st_cobalt_speed", "1.0", "Cobalt Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hCobaltThrow = CreateConVar("st_cobalt_throw", "999.0", "Cobalt Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hCobaltFireImmunity = CreateConVar("st_cobalt_fire_immunity", "1.0", "Is Cobalt Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hCobaltSpecialSpeed = CreateConVar("st_cobalt_special_speed", "2.5", "Cobalt Tanks movement value when speeding towards a survivor.",FCVAR_NOTIFY,true,1.0,true,5.0);

	hJumperEnabled = CreateConVar("st_jumper_enabled", "1.0", "Is Jumper Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hJumperExtraHealth = CreateConVar("st_jumper_extra_health", "1500.0", "Jumper Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hJumperSpeed = CreateConVar("st_jumper_speed", "1.20", "Jumper Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.5);
	hJumperThrow = CreateConVar("st_jumper_throw", "999.0", "Jumper Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hJumperFireImmunity = CreateConVar("st_jumper_fire_immunity", "0.0", "Is Jumper Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hJumperJumpDelay = CreateConVar("st_jumper_jump_delay", "5.0", "Jumper Tanks delay interval to jump again.",FCVAR_NOTIFY,true,1.0,true,999.0);

	hDistractionEnabled = CreateConVar("st_distraction_enabled", "1.0", "Is Distraction Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hDistractionExtraHealth = CreateConVar("st_distraction_extra_health", "0.0", "Distraction Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hDistractionSpeed = CreateConVar("st_distraction_speed", "1.20", "Distraction Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.5);
	hDistractionThrow = CreateConVar("st_distraction_throw", "999.0", "Distraction Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hDistractionFireImmunity = CreateConVar("st_distraction_fire_immunity", "0.0", "Is Distraction Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hDistractionJumpDelay = CreateConVar("st_distraction_jump_delay", "1.0", "Distraction Tanks delay interval to jump again.",FCVAR_NOTIFY,true,1.0,true,999.0);
	hDistractionTeleportDelay = CreateConVar("st_distraction_teleport_delay", "1.0", "Distraction Tanks Teleport Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);

	hGravityEnabled = CreateConVar("st_gravity_enabled", "1.0", "Is Gravity Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hGravityExtraHealth = CreateConVar("st_gravity_extra_health", "3000.0", "Gravity Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hGravitySpeed = CreateConVar("st_gravity_speed", "1.0", "Gravity Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hGravityThrow = CreateConVar("st_gravity_throw", "10.0", "Gravity Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hGravityFireImmunity = CreateConVar("st_gravity_fire_immunity", "0.0", "Is Gravity Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hGravityPullForce = CreateConVar("st_gravity_pull_force", "-50.0", "Gravity Tanks pull force value. Higher negative values equals greater pull forces.",FCVAR_NOTIFY,true,-100.0,true,0.0);

	hFlashEnabled = CreateConVar("st_flash_enabled", "1.0", "Is Flash Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hFlashExtraHealth = CreateConVar("st_flash_extra_health", "4500.0", "Flash Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hFlashSpeed = CreateConVar("st_flash_speed", "2.5", "Flash Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,3.5);
	hFlashThrow = CreateConVar("st_flash_throw", "999.0", "Flash Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hFlashFireImmunity = CreateConVar("st_flash_fire_immunity", "1.0", "Is Flash Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hFlashSpecialSpeed = CreateConVar("st_flash_special_speed", "4.0", "Flash Tanks movement value when speeding towards a survivor.",FCVAR_NOTIFY,true,1.0,true,5.0);
	hFlashTeleportDelay = CreateConVar("st_flash_teleport_delay", "15.0", "Flash Tanks Teleport Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);

	hReverseFlashEnabled = CreateConVar("st_reverseflash_enabled", "1.0", "Is Reverse Flash Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hReverseFlashExtraHealth = CreateConVar("st_reverseflash_extra_health", "5000.0", "Reverse Flash Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hReverseFlashSpeed = CreateConVar("st_reverseflash_speed", "3.0", "Reverse Flash Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,4.0);
	hReverseFlashThrow = CreateConVar("st_reverseflash_throw", "999.0", "Reverse Flash Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hReverseFlashFireImmunity = CreateConVar("st_reverseflash_fire_immunity", "1.0", "Is Reverse Flash Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hReverseFlashSpecialSpeed = CreateConVar("st_reverseflash_special_speed", "5.0", "Reverse Flash Tanks movement value when speeding towards a survivor.",FCVAR_NOTIFY,true,1.0,true,6.0);
	hReverseFlashTeleportDelay = CreateConVar("st_reverseflash_teleport_delay", "10.0", "Reverse Flash Tanks Teleport Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);

	hArmageddonEnabled = CreateConVar("st_armageddon_enabled", "1.0", "Is Armageddon Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hArmageddonExtraHealth = CreateConVar("st_armageddon_extra_health", "6000.0", "Armageddon Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hArmageddonSpeed = CreateConVar("st_armageddon_speed", "0.65", "Armageddon Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hArmageddonThrow = CreateConVar("st_armageddon_throw", "30.0", "Armageddon Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hArmageddonFireImmunity = CreateConVar("st_armageddon_fire_immunity", "1.0", "Is Armageddon Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hArmageddonMaimDamage = CreateConVar("st_armageddon_maim_damage", "1.0", "Armageddon Tanks maim attack will set victims health to this amount.",FCVAR_NOTIFY,true,1.0,true,99.0);
	hArmageddonCrushDamage = CreateConVar("st_armageddon_crush_damage", "25.0", "Armageddon Tanks claw attack damage.",FCVAR_NOTIFY,true,0.0,true,100.0);
	hArmageddonRemoveBody = CreateConVar("st_armageddon_remove_body", "1.0", "Armageddon Tanks crush attack will remove survivors death body?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hArmageddonStormDelay = CreateConVar("st_armageddon_storm_delay", "15.0", "Armageddon Tanks Meteor Storm Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
	hArmageddonStormDamage = CreateConVar("st_armageddon_storm_damage", "50.0", "Armageddon Tanks falling meteor damage.",FCVAR_NOTIFY,true,0.0,true,1000.0);
	hArmageddonPullForce = CreateConVar("st_armageddon_pull_force", "-75.0", "Armageddon Tanks pull force value. Higher negative values equals greater pull forces.",FCVAR_NOTIFY,true,-150.0,true,0.0);
	if(L4D2Version)
	{
		hHallucinationEnabled = CreateConVar("st_hallucination_enabled", "1.0", "Is Hallucination Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hHallucinationExtraHealth = CreateConVar("st_hallucination_extra_health", "5500.0", "Hallucination Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
		hHallucinationSpeed = CreateConVar("st_hallucination_speed", "1.0", "Hallucination Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
		hHallucinationThrow = CreateConVar("st_hallucination_throw", "999.0", "Hallucination Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
		hHallucinationFireImmunity = CreateConVar("st_hallucination_fire_immunity", "1.0", "Is Hallucination Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hHallucinationTeleportDelay = CreateConVar("st_hallucination_teleport_delay", "5.0", "Hallucination Tanks Teleport Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
		hHallucinationDisarm = CreateConVar("st_hallucination_disarm", "1.0", "Does Hallucination Tank have a chance of disarming an attacking melee survivor?",FCVAR_NOTIFY,true,0.0,true,1.0);
	}
	hMinionEnabled = CreateConVar("st_minion_enabled", "1.0", "Is Minion Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hMinionExtraHealth = CreateConVar("st_minion_extra_health", "2000.0", "Minion Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hMinionSpeed = CreateConVar("st_minion_speed", "1.33", "Minion Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.5);
	hMinionThrow = CreateConVar("st_minion_throw", "60.0", "Minion Tank tank throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hMinionFireImmunity = CreateConVar("st_minion_fire_immunity", "0.0", "Is Minion Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);

	hBitchEnabled = CreateConVar("st_bitch_enabled", "1.0", "Is Bitch Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hBitchExtraHealth = CreateConVar("st_bitch_extra_health", "1500.0", "Bitch Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hBitchSpeed = CreateConVar("st_bitch_speed", "1.33", "Bitch Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.5);
	hBitchThrow = CreateConVar("st_bitch_throw", "7.0", "Bitch Tank witch throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hBitchFireImmunity = CreateConVar("st_bitch_fire_immunity", "0.0", "Is Bitch Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);

	hPsychoticEnabled = CreateConVar("st_psychotic_enabled", "1.0", "Is Psychotic Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hPsychoticExtraHealth = CreateConVar("st_psychotic_extra_health", "10000.0", "Psychotic Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hPsychoticSpeed = CreateConVar("st_psychotic_speed", "1.0", "Psychotic Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hPsychoticThrow = CreateConVar("st_psychotic_throw", "10.0", "Psychotic Tank propane throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hPsychoticFireImmunity = CreateConVar("st_psychotic_fire_immunity", "1.0", "Is Psychotic Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hPsychoticTeleportDelay = CreateConVar("st_psychotic_teleport_delay", "25.0", "Psychotic Tanks Teleport Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
	hPsychoticHealthCommons = CreateConVar("st_psychotic_health_commons", "10.0", "Psychotic Tanks receive this much health per second from being near a common infected.",FCVAR_NOTIFY,true,0.0,true,100.0);
	hPsychoticHealthSpecials = CreateConVar("st_psychotic_health_specials", "50.0", "Psychotic Tanks receive this much health per second from being near a special infected.",FCVAR_NOTIFY,true,0.0,true,500.0);
	hPsychoticHealthTanks = CreateConVar("st_psychotic_health_tanks", "100.0", "Psychotic Tanks receive this much health per second from being near another tank.",FCVAR_NOTIFY,true,0.0,true,1000.0);
	hPsychoticStormDelay = CreateConVar("st_psychotic_storm_delay", "25.0", "Psychotic Tanks Meteor Storm Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
	hPsychoticStormDamage = CreateConVar("st_psychotic_storm_damage", "25.0", "Psychotic Tanks falling meteor damage.",FCVAR_NOTIFY,true,0.0,true,1000.0);
	hPsychoticShieldsDownInterval = CreateConVar("st_psychotic_shields_down_interval", "10.0", "When Psychotic Tanks shields are disabled, how long before shields activate again.",FCVAR_NOTIFY,true,0.1,true,60.0);
	hPsychoticJumpDelay = CreateConVar("st_psychotic_jump_delay", "25.0", "Psychotic Tanks delay interval to jump again.",FCVAR_NOTIFY,true,1.0,true,999.0);
	if(L4D2Version)
	{
		hSpitterEnabled = CreateConVar("st_spitter_enabled", "1.0", "Is Spitter Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hSpitterExtraHealth = CreateConVar("st_spitter_extra_health", "300.0", "Spitter Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
		hSpitterSpeed = CreateConVar("st_spitter_speed", "1.33", "Spitter Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.5);
		hSpitterThrow = CreateConVar("st_spitter_throw", "7.0", "Spitter Tank spitter throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
		hSpitterFireImmunity = CreateConVar("st_spitter_fire_immunity", "0.0", "Is Spitter Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	}
	hGoliathEnabled = CreateConVar("st_goliath_enabled", "1.0", "Is Goliath Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hGoliathExtraHealth = CreateConVar("st_goliath_extra_health", "10000.0", "Goliath Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hGoliathSpeed = CreateConVar("st_goliath_speed", "0.5", "Goliath Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hGoliathThrow = CreateConVar("st_goliath_throw", "7.5", "Goliath Tank propane throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hGoliathFireImmunity = CreateConVar("st_goliath_fire_immunity", "1.0", "Is Goliath Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hGoliathMaimDamage = CreateConVar("st_goliath_maim_damage", "1.0", "Goliath Tanks maim attack will set victims health to this amount.",FCVAR_NOTIFY,true,1.0,true,99.0);
	hGoliathCrushDamage = CreateConVar("st_goliath_crush_damage", "1000.0", "Goliath Tanks claw attack damage.",FCVAR_NOTIFY,true,0.0,true,1000.0);
	hGoliathRemoveBody = CreateConVar("st_goliath_remove_body", "1.0", "Goliath Tanks crush attack will remove survivors death body?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hGoliathHealthCommons = CreateConVar("st_goliath_health_commons", "100.0", "Goliath Tanks receive this much health per second from being near a common infected.",FCVAR_NOTIFY,true,0.0,true,1000.0);
	hGoliathHealthSpecials = CreateConVar("st_goliath_health_specials", "500.0", "Goliath Tanks receive this much health per second from being near a special infected.",FCVAR_NOTIFY,true,0.0,true,5000.0);
	hGoliathHealthTanks = CreateConVar("st_goliath_health_tanks", "1000.0", "Goliath Tanks receive this much health per second from being near another tank.",FCVAR_NOTIFY,true,0.0,true,10000.0);
	hGoliathShieldsDownInterval = CreateConVar("st_goliath_shields_down_interval", "10.0", "When Goliath Tanks shields are disabled, how long before shields activate again.",FCVAR_NOTIFY,true,0.1,true,60.0);

	hPsykotikEnabled = CreateConVar("st_psykotik_enabled", "1.0", "Is Psykotik Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hPsykotikExtraHealth = CreateConVar("st_psykotik_extra_health", "5500.0", "Psykotik Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hPsykotikSpeed = CreateConVar("st_psykotik_speed", "3.5", "Psykotik Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,5.5);
	hPsykotikThrow = CreateConVar("st_psykotik_throw", "999.0", "Psykotik Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hPsykotikFireImmunity = CreateConVar("st_psykotik_fire_immunity", "1.0", "Is Psykotik Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hPsykotikSpecialSpeed = CreateConVar("st_psykotik_special_speed", "6.0", "Psykotik Tanks movement value when speeding towards a survivor.",FCVAR_NOTIFY,true,1.0,true,7.0);
	hPsykotikTeleportDelay = CreateConVar("st_psykotik_teleport_delay", "5.0", "Psykotik Tanks Teleport Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
	hPsykotikHealthCommons = CreateConVar("st_psykotik_health_commons", "5.0", "Psykotik Tanks receive this much health per second from being near a common infected.",FCVAR_NOTIFY,true,0.0,true,50.0);
	hPsykotikHealthSpecials = CreateConVar("st_psykotik_health_specials", "25.0", "Psykotik Tanks receive this much health per second from being near a special infected.",FCVAR_NOTIFY,true,0.0,true,250.0);
	hPsykotikHealthTanks = CreateConVar("st_psykotik_health_tanks", "50.0", "Psykotik Tanks receive this much health per second from being near another tank.",FCVAR_NOTIFY,true,0.0,true,500.0);

	hSpykotikEnabled = CreateConVar("st_spykotik_enabled", "1.0", "Is Spykotik Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hSpykotikExtraHealth = CreateConVar("st_spykotik_extra_health", "4500.0", "Spykotik Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hSpykotikSpeed = CreateConVar("st_spykotik_speed", "2.0", "Spykotik Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,3.0);
	hSpykotikThrow = CreateConVar("st_spykotik_throw", "999.0", "Spykotik Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hSpykotikFireImmunity = CreateConVar("st_spykotik_fire_immunity", "1.0", "Is Spykotik Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hSpykotikSpecialSpeed = CreateConVar("st_spykotik_special_speed", "3.0", "Spykotik Tanks movement value when speeding towards a survivor.",FCVAR_NOTIFY,true,1.0,true,4.0);
	hSpykotikTeleportDelay = CreateConVar("st_spykotik_teleport_delay", "15.0", "Spykotik Tanks Teleport Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);

	hSpypsyEnabled = CreateConVar("st_spypsy_enabled", "1.0", "Is Spypsy Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hSpypsyExtraHealth = CreateConVar("st_spypsy_extra_health", "3000.0", "Spypsy Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hSpypsySpeed = CreateConVar("st_spypsy_speed", "1.0", "Spypsy Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hSpypsyThrow = CreateConVar("st_spypsy_throw", "999.0", "Spypsy Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hSpypsyFireImmunity = CreateConVar("st_spypsy_fire_immunity", "1.0", "Is Spypsy Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hSpypsySpecialSpeed = CreateConVar("st_spypsy_special_speed", "2.0", "Spypsy Tanks movement value when speeding towards a survivor.",FCVAR_NOTIFY,true,1.0,true,3.0);
	hSpypsyTeleportDelay = CreateConVar("st_spypsy_teleport_delay", "10.0", "Spypsy Tanks Teleport Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
	if(L4D2Version)
	{
		hSipowEnabled = CreateConVar("st_sipow_enabled", "1.0", "Is Sipow Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hSipowExtraHealth = CreateConVar("st_sipow_extra_health", "10000.0", "Sipow Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
		hSipowSpeed = CreateConVar("st_sipow_speed", "1.33", "Sipow Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.5);
		hSipowThrow = CreateConVar("st_sipow_throw", "10.0", "Sipow Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
		hSipowFireImmunity = CreateConVar("st_sipow_fire_immunity", "1.0", "Is Sipow Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hSipowStormDelay = CreateConVar("st_sipow_storm_delay", "25.0", "Sipow Tanks Meteor Storm Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
		hSipowStormDamage = CreateConVar("st_sipow_storm_damage", "50.0", "Sipow Tanks falling meteor damage.",FCVAR_NOTIFY,true,0.0,true,1000.0);

		hPoltergeistEnabled = CreateConVar("st_poltergeist_enabled", "1.0", "Is Poltergeist Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hPoltergeistExtraHealth = CreateConVar("st_poltergeist_extra_health", "2000.0", "Poltergeist Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
		hPoltergeistSpeed = CreateConVar("st_poltergeist_speed", "1.0", "Poltergeist Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
		hPoltergeistThrow = CreateConVar("st_poltergeist_throw", "999.0", "Poltergeist Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
		hPoltergeistFireImmunity = CreateConVar("st_poltergeist_fire_immunity", "1.0", "Is Poltergeist Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hPoltergeistSpecialSpeed = CreateConVar("st_poltergeist_special_speed", "2.0", "Poltergeist Tanks movement value when speeding towards a survivor.",FCVAR_NOTIFY,true,1.0,true,3.0);
		hPoltergeistTeleportDelay = CreateConVar("st_poltergeist_teleport_delay", "7.5", "Poltergeist Tanks Teleport Delay Interval Value.",FCVAR_NOTIFY,true,1.0,true,999.0);
		hPoltergeistDisarm = CreateConVar("st_poltergeist_disarm", "1.0", "Does Poltergeist Tank have a chance of disarming an attacking melee survivor?",FCVAR_NOTIFY,true,0.0,true,1.0);
	}
	hMirageEnabled = CreateConVar("st_mirage_enabled", "1.0", "Is Mirage Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hMirageExtraHealth = CreateConVar("st_mirage_extra_health", "2000.0", "Mirage Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
	hMirageSpeed = CreateConVar("st_mirage_speed", "1.0", "Mirage Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
	hMirageThrow = CreateConVar("st_mirage_throw", "60.0", "Mirage Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
	hMirageFireImmunity = CreateConVar("st_mirage_fire_immunity", "1.0", "Is Mirage Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
	hMirageSpecialSpeed = CreateConVar("st_mirage_special_speed", "3.0", "Mirage Tanks movement value when speeding towards a survivor.",FCVAR_NOTIFY,true,1.0,true,4.0);
	hMirageTeleportDelay = CreateConVar("st_mirage_teleport_delay", "10.0", "Mirage Tanks Teleport Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
	if(L4D2Version)
	{
		//Meme Tank
		hMemeEnabled = CreateConVar("st_meme_enabled", "1.0", "Is Meme Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hMemeExtraHealth = CreateConVar("st_meme_extra_health", "0.0", "Meme Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
		hMemeSpeed = CreateConVar("st_meme_speed", "0.5", "Meme Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,1.5);
		hMemeThrow = CreateConVar("st_meme_throw", "25.0", "Meme Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
		hMemeFireImmunity = CreateConVar("st_meme_fire_immunity", "1.0", "Is Meme Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hMemeCommonAmount = CreateConVar("st_meme_common_amount", "5.0", "Number of common infected spawned by the Meme Tank.",FCVAR_NOTIFY,true,1.0,true,50.0);
		hMemeCommonInterval = CreateConVar("st_meme_common_interval", "25.0", "Meme Tanks common infected spawn interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
		hMemeMaimDamage = CreateConVar("st_meme_maim_damage", "99.0", "Meme Tanks maim attack will set victims health to this amount.",FCVAR_NOTIFY,true,1.0,true,99.0);
		hMemeCrushDamage = CreateConVar("st_meme_crush_damage", "1.0", "Meme Tanks claw attack damage.",FCVAR_NOTIFY,true,0.0,true,1000.0);
		hMemeRemoveBody = CreateConVar("st_meme_remove_body", "1.0", "Meme Tanks crush attack will remove survivors death body?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hMemeTeleportDelay = CreateConVar("st_meme_teleport_delay", "10.0", "Meme Tanks Teleport Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
		hMemeStormDelay = CreateConVar("st_meme_storm_delay", "10.0", "Meme Tanks Meteor Storm Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
		hMemeStormDamage = CreateConVar("st_meme_storm_damage", "1.0", "Meme Tanks falling meteor damage.",FCVAR_NOTIFY,true,0.0,true,1000.0);
		hMemeDisarm = CreateConVar("st_meme_disarm", "1.0", "Does Meme Tank have a chance of disarming an attacking melee survivor?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hMemeMaxWitches = CreateConVar("st_meme_max_witches", "1.0", "Maximum number of witches converted from common infected by the Meme Tank.",FCVAR_NOTIFY,true,0.0,true,100.0);
		hMemeSpecialSpeed = CreateConVar("st_meme_special_speed", "2.0", "Meme Tanks movement value when speeding towards a survivor.",FCVAR_NOTIFY,true,1.0,true,3.0);
		hMemeJumpDelay = CreateConVar("st_meme_jump_delay", "15.0", "Meme Tanks delay interval to jump again.",FCVAR_NOTIFY,true,1.0,true,999.0);
		hMemePullForce = CreateConVar("st_meme_pull_force", "-25.0", "Meme Tanks pull force value. Higher negative values equals greater pull forces.",FCVAR_NOTIFY,true,-50.0,true,0.0);

		//Boss Tank
		hBossEnabled = CreateConVar("st_boss_enabled", "1.0", "Is Boss Tank Enabled?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hBossExtraHealth = CreateConVar("st_boss_extra_health", "20000.0", "Boss Tanks receive this many additional hitpoints.",FCVAR_NOTIFY,true,0.0,true,100000.0);
		hBossSpeed = CreateConVar("st_boss_speed", "1.0", "Boss Tanks default movement speed.",FCVAR_NOTIFY,true,0.0,true,2.0);
		hBossThrow = CreateConVar("st_boss_throw", "5.0", "Boss Tank rock throw ability interval.",FCVAR_NOTIFY,true,0.0,true,999.0);
		hBossFireImmunity = CreateConVar("st_boss_fire_immunity", "1.0", "Is Boss Tank immune to fire?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hBossMaimDamage = CreateConVar("st_boss_maim_damage", "1.0", "Boss Tanks maim attack will set victims health to this amount.",FCVAR_NOTIFY,true,1.0,true,99.0);
		hBossCrushDamage = CreateConVar("st_boss_crush_damage", "75.0", "Boss Tanks claw attack damage.",FCVAR_NOTIFY,true,0.0,true,1000.0);
		hBossRemoveBody = CreateConVar("st_boss_remove_body", "1.0", "Boss Tanks crush attack will remove survivors death body?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hBossTeleportDelay = CreateConVar("st_boss_teleport_delay", "15.0", "Boss Tanks Teleport Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
		hBossStormDelay = CreateConVar("st_boss_storm_delay", "25.0", "Boss Tanks Meteor Storm Delay Interval.",FCVAR_NOTIFY,true,1.0,true,999.0);
		hBossStormDamage = CreateConVar("st_boss_storm_damage", "50.0", "Boss Tanks falling meteor damage.",FCVAR_NOTIFY,true,0.0,true,1000.0);
		hBossHealthCommons = CreateConVar("st_boss_health_commons", "5.0", "Boss Tanks receive this much health per second from being near a common infected.",FCVAR_NOTIFY,true,0.0,true,50.0);
		hBossHealthSpecials = CreateConVar("st_boss_health_specials", "25.0", "Boss Tanks receive this much health per second from being near a special infected.",FCVAR_NOTIFY,true,0.0,true,250.0);
		hBossHealthTanks = CreateConVar("st_boss_health_tanks", "50.0", "Boss Tanks receive this much health per second from being near another tank.",FCVAR_NOTIFY,true,0.0,true,500.0);
		hBossDisarm = CreateConVar("st_boss_disarm", "1.0", "Does Boss Tank have a chance of disarming an attacking melee survivor?",FCVAR_NOTIFY,true,0.0,true,1.0);
		hBossMaxWitches = CreateConVar("st_boss_max_witches", "5.0", "Maximum number of witches converted from common infected by the Boss Tank.",FCVAR_NOTIFY,true,0.0,true,100.0);
		hBossSpecialSpeed = CreateConVar("st_boss_special_speed", "2.0", "Boss Tanks movement value when speeding towards a survivor.",FCVAR_NOTIFY,true,1.0,true,3.0);
		hBossJumpDelay = CreateConVar("st_boss_jump_delay", "25.0", "Boss Tanks delay interval to jump again.",FCVAR_NOTIFY,true,1.0,true,999.0);
		hBossPullForce = CreateConVar("st_boss_pull_force", "-75.0", "Boss Tanks pull force value. Higher negative values equals greater pull forces.",FCVAR_NOTIFY,true,-150.0,true,0.0);
		hBossShieldsDownInterval = CreateConVar("st_boss_shields_down_interval", "25.0", "When Boss Tanks shields are disabled, how long before shields activate again.",FCVAR_NOTIFY,true,0.1,true,60.0);
	}
	bSuperTanksEnabled = GetConVarBool(hSuperTanksEnabled);
	bDisplayHealthCvar = GetConVarBool(hDisplayHealthCvar);
	iWave1Cvar = GetConVarInt(hWave1Cvar);
	iWave2Cvar = GetConVarInt(hWave2Cvar);
	iWave3Cvar = GetConVarInt(hWave3Cvar);
	bFinaleOnly = GetConVarBool(hFinaleOnly);
	bDefaultTanks = GetConVarBool(hDefaultTanks);
	bDefaultOverride = GetConVarBool(hDefaultOverride);
	if(L4D2Version)
	{
		bTankEnabled[1] = GetConVarBool(hSpawnEnabled);
	}
	bTankEnabled[2] = GetConVarBool(hSmasherEnabled);
	bTankEnabled[3] = GetConVarBool(hWarpEnabled);
	bTankEnabled[4] = GetConVarBool(hMeteorEnabled);
	if(L4D2Version)
	{
		bTankEnabled[5] = GetConVarBool(hAcidEnabled);
	}
	bTankEnabled[6] = GetConVarBool(hHealthEnabled);
	bTankEnabled[7] = GetConVarBool(hFireEnabled);
	if(L4D2Version)
	{
		bTankEnabled[8] = GetConVarBool(hIceEnabled);
		bTankEnabled[9] = GetConVarBool(hJockeyEnabled);
	}
	bTankEnabled[10] = GetConVarBool(hHunterEnabled);
	bTankEnabled[11] = GetConVarBool(hSmokerEnabled);
	bTankEnabled[12] = GetConVarBool(hBoomerEnabled);
	if(L4D2Version)
	{
		bTankEnabled[13] = GetConVarBool(hChargerEnabled);
		bTankEnabled[14] = GetConVarBool(hGhostEnabled);
	}
	bTankEnabled[15] = GetConVarBool(hShockEnabled);
	bTankEnabled[16] = GetConVarBool(hWitchEnabled);
	bTankEnabled[17] = GetConVarBool(hShieldEnabled);
	bTankEnabled[18] = GetConVarBool(hCobaltEnabled);
	bTankEnabled[19] = GetConVarBool(hJumperEnabled);
	bTankEnabled[20] = GetConVarBool(hGravityEnabled);
	bTankEnabled[21] = GetConVarBool(hFlashEnabled);
	bTankEnabled[22] = GetConVarBool(hReverseFlashEnabled);
	bTankEnabled[23] = GetConVarBool(hArmageddonEnabled);
	if(L4D2Version)
	{
		bTankEnabled[24] = GetConVarBool(hHallucinationEnabled);
	}
	bTankEnabled[25] = GetConVarBool(hMinionEnabled);
	bTankEnabled[26] = GetConVarBool(hBitchEnabled);
	bTankEnabled[27] = GetConVarBool(hTrapEnabled);
	bTankEnabled[28] = GetConVarBool(hDistractionEnabled);
	bTankEnabled[29] = GetConVarBool(hFeedbackEnabled);
	bTankEnabled[30] = GetConVarBool(hPsychoticEnabled);
	if(L4D2Version)
	{
		bTankEnabled[31] = GetConVarBool(hSpitterEnabled);
	}
	bTankEnabled[32] = GetConVarBool(hGoliathEnabled);
	bTankEnabled[33] = GetConVarBool(hPsykotikEnabled);
	bTankEnabled[34] = GetConVarBool(hSpykotikEnabled);
	if(L4D2Version)
	{
		//Meme Tank
		bTankEnabled[35] = GetConVarBool(hMemeEnabled);

		//Boss Tank
		bTankEnabled[36] = GetConVarBool(hBossEnabled);
	}
	bTankEnabled[37] = GetConVarBool(hSpypsyEnabled);
	if(L4D2Version)
	{
		bTankEnabled[38] = GetConVarBool(hSipowEnabled);
		bTankEnabled[39] = GetConVarBool(hPoltergeistEnabled);
	}
	bTankEnabled[40] = GetConVarBool(hMirageEnabled);

	iTankExtraHealth[0] = GetConVarInt(hDefaultExtraHealth);
	if(L4D2Version)
	{
		iTankExtraHealth[1] = GetConVarInt(hSpawnExtraHealth);
	}
	iTankExtraHealth[2] = GetConVarInt(hSmasherExtraHealth);
	iTankExtraHealth[3] = GetConVarInt(hWarpExtraHealth);
	iTankExtraHealth[4] = GetConVarInt(hMeteorExtraHealth);
	if(L4D2Version)
	{
		iTankExtraHealth[5] = GetConVarInt(hAcidExtraHealth);
	}
	iTankExtraHealth[6] = GetConVarInt(hHealthExtraHealth);
	iTankExtraHealth[7] = GetConVarInt(hFireExtraHealth);
	if(L4D2Version)
	{
		iTankExtraHealth[8] = GetConVarInt(hIceExtraHealth);
		iTankExtraHealth[9] = GetConVarInt(hJockeyExtraHealth);
	}
	iTankExtraHealth[10] = GetConVarInt(hHunterExtraHealth);
	iTankExtraHealth[11] = GetConVarInt(hSmokerExtraHealth);
	iTankExtraHealth[12] = GetConVarInt(hBoomerExtraHealth);
	if(L4D2Version)
	{
		iTankExtraHealth[13] = GetConVarInt(hChargerExtraHealth);
		iTankExtraHealth[14] = GetConVarInt(hGhostExtraHealth);
	}
	iTankExtraHealth[15] = GetConVarInt(hShockExtraHealth);
	iTankExtraHealth[16] = GetConVarInt(hWitchExtraHealth);
	iTankExtraHealth[17] = GetConVarInt(hShieldExtraHealth);
	iTankExtraHealth[18] = GetConVarInt(hCobaltExtraHealth);
	iTankExtraHealth[19] = GetConVarInt(hJumperExtraHealth);
	iTankExtraHealth[20] = GetConVarInt(hGravityExtraHealth);
	iTankExtraHealth[21] = GetConVarInt(hFlashExtraHealth);
	iTankExtraHealth[22] = GetConVarInt(hReverseFlashExtraHealth);
	iTankExtraHealth[23] = GetConVarInt(hArmageddonExtraHealth);
	if(L4D2Version)
	{
		iTankExtraHealth[24] = GetConVarInt(hHallucinationExtraHealth);
	}
	iTankExtraHealth[25] = GetConVarInt(hMinionExtraHealth);
	iTankExtraHealth[26] = GetConVarInt(hBitchExtraHealth);
	iTankExtraHealth[27] = GetConVarInt(hTrapExtraHealth);
	iTankExtraHealth[28] = GetConVarInt(hDistractionExtraHealth);
	iTankExtraHealth[29] = GetConVarInt(hFeedbackExtraHealth);
	iTankExtraHealth[30] = GetConVarInt(hPsychoticExtraHealth);
	if(L4D2Version)
	{
		iTankExtraHealth[31] = GetConVarInt(hSpitterExtraHealth);
	}
	iTankExtraHealth[32] = GetConVarInt(hGoliathExtraHealth);
	iTankExtraHealth[33] = GetConVarInt(hPsykotikExtraHealth);
	iTankExtraHealth[34] = GetConVarInt(hSpykotikExtraHealth);
	if(L4D2Version)
	{
		//Meme Tank
		iTankExtraHealth[35] = GetConVarInt(hMemeExtraHealth);

		//Boss Tank
		iTankExtraHealth[36] = GetConVarInt(hBossExtraHealth);
	}
	iTankExtraHealth[37] = GetConVarInt(hSpypsyExtraHealth);
	if(L4D2Version)
	{
		iTankExtraHealth[38] = GetConVarInt(hSipowExtraHealth);
		iTankExtraHealth[39] = GetConVarInt(hPoltergeistExtraHealth);
	}
	iTankExtraHealth[40] = GetConVarInt(hMirageExtraHealth);

	flTankSpeed[0] = GetConVarFloat(hDefaultSpeed);
	if(L4D2Version)
	{
		flTankSpeed[1] = GetConVarFloat(hSpawnSpeed);
	}
	flTankSpeed[2] = GetConVarFloat(hSmasherSpeed);
	flTankSpeed[3] = GetConVarFloat(hWarpSpeed);
	flTankSpeed[4] = GetConVarFloat(hMeteorSpeed);
	if(L4D2Version)
	{
		flTankSpeed[5] = GetConVarFloat(hAcidSpeed);
	}
	flTankSpeed[6] = GetConVarFloat(hHealthSpeed);
	flTankSpeed[7] = GetConVarFloat(hFireSpeed);
	if(L4D2Version)
	{
		flTankSpeed[8] = GetConVarFloat(hIceSpeed);
		flTankSpeed[9] = GetConVarFloat(hJockeySpeed);
	}
	flTankSpeed[10] = GetConVarFloat(hHunterSpeed);
	flTankSpeed[11] = GetConVarFloat(hSmokerSpeed);
	flTankSpeed[12] = GetConVarFloat(hBoomerSpeed);
	if(L4D2Version)
	{
		flTankSpeed[13] = GetConVarFloat(hChargerSpeed);
		flTankSpeed[14] = GetConVarFloat(hGhostSpeed);
	}
	flTankSpeed[15] = GetConVarFloat(hShockSpeed);
	flTankSpeed[16] = GetConVarFloat(hWitchSpeed);
	flTankSpeed[17] = GetConVarFloat(hShieldSpeed);
	flTankSpeed[18] = GetConVarFloat(hCobaltSpeed);
	flTankSpeed[19] = GetConVarFloat(hJumperSpeed);
	flTankSpeed[20] = GetConVarFloat(hGravitySpeed);
	flTankSpeed[21] = GetConVarFloat(hFlashSpeed);
	flTankSpeed[22] = GetConVarFloat(hReverseFlashSpeed);
	flTankSpeed[23] = GetConVarFloat(hArmageddonSpeed);
	if(L4D2Version)
	{
		flTankSpeed[24] = GetConVarFloat(hHallucinationSpeed);
	}
	flTankSpeed[25] = GetConVarFloat(hMinionSpeed);
	flTankSpeed[26] = GetConVarFloat(hBitchSpeed);
	flTankSpeed[27] = GetConVarFloat(hTrapSpeed);
	flTankSpeed[28] = GetConVarFloat(hDistractionSpeed);
	flTankSpeed[29] = GetConVarFloat(hFeedbackSpeed);
	flTankSpeed[30] = GetConVarFloat(hPsychoticSpeed);
	if(L4D2Version)
	{
		flTankSpeed[31] = GetConVarFloat(hSpitterSpeed);
	}
	flTankSpeed[32] = GetConVarFloat(hGoliathSpeed);
	flTankSpeed[33] = GetConVarFloat(hPsykotikSpeed);
	flTankSpeed[34] = GetConVarFloat(hSpykotikSpeed);
	if(L4D2Version)
	{
		//Meme Tank
		flTankSpeed[35] = GetConVarFloat(hMemeSpeed);

		//Boss Tank
		flTankSpeed[36] = GetConVarFloat(hBossSpeed);
	}
	flTankSpeed[37] = GetConVarFloat(hSpypsySpeed);
	if(L4D2Version)
	{
		flTankSpeed[38] = GetConVarFloat(hSipowSpeed);
		flTankSpeed[39] = GetConVarFloat(hPoltergeistSpeed);
	}
	flTankSpeed[40] = GetConVarFloat(hMirageSpeed);

	flTankThrow[0] = GetConVarFloat(hDefaultThrow);
	if(L4D2Version)
	{
		flTankThrow[1] = GetConVarFloat(hSpawnThrow);
	}
	flTankThrow[2] = GetConVarFloat(hSmasherThrow);
	flTankThrow[3] = GetConVarFloat(hWarpThrow);
	flTankThrow[4] = GetConVarFloat(hMeteorThrow);
	if(L4D2Version)
	{
		flTankThrow[5] = GetConVarFloat(hAcidThrow);
	}
	flTankThrow[6] = GetConVarFloat(hHealthThrow);
	flTankThrow[7] = GetConVarFloat(hFireThrow);
	if(L4D2Version)
	{
		flTankThrow[8] = GetConVarFloat(hIceThrow);
		flTankThrow[9] = GetConVarFloat(hJockeyThrow);
	}
	flTankThrow[10] = GetConVarFloat(hHunterThrow);
	flTankThrow[11] = GetConVarFloat(hSmokerThrow);
	flTankThrow[12] = GetConVarFloat(hBoomerThrow);
	if(L4D2Version)
	{
		flTankThrow[13] = GetConVarFloat(hChargerThrow);
		flTankThrow[14] = GetConVarFloat(hGhostThrow);
	}
	flTankThrow[15] = GetConVarFloat(hShockThrow);
	flTankThrow[16] = GetConVarFloat(hWitchThrow);
	flTankThrow[17] = GetConVarFloat(hShieldThrow);
	flTankThrow[18] = GetConVarFloat(hCobaltThrow);
	flTankThrow[19] = GetConVarFloat(hJumperThrow);
	flTankThrow[20] = GetConVarFloat(hGravityThrow);
	flTankThrow[21] = GetConVarFloat(hFlashThrow);
	flTankThrow[22] = GetConVarFloat(hReverseFlashThrow);
	flTankThrow[23] = GetConVarFloat(hArmageddonThrow);
	if(L4D2Version)
	{
		flTankThrow[24] = GetConVarFloat(hHallucinationThrow);
	}
	flTankThrow[25] = GetConVarFloat(hMinionThrow);
	flTankThrow[26] = GetConVarFloat(hBitchThrow);
	flTankThrow[27] = GetConVarFloat(hTrapThrow);
	flTankThrow[28] = GetConVarFloat(hDistractionThrow);
	flTankThrow[29] = GetConVarFloat(hFeedbackThrow);
	flTankThrow[30] = GetConVarFloat(hPsychoticThrow);
	if(L4D2Version)
	{
		flTankThrow[31] = GetConVarFloat(hSpitterThrow);
	}
	flTankThrow[32] = GetConVarFloat(hGoliathThrow);
	flTankThrow[33] = GetConVarFloat(hPsykotikThrow);
	flTankThrow[34] = GetConVarFloat(hSpykotikThrow);
	if(L4D2Version)
	{
		//Meme Tank
		flTankThrow[35] = GetConVarFloat(hMemeThrow);

		//Boss Tank
		flTankThrow[36] = GetConVarFloat(hBossThrow);
	}
	flTankThrow[37] = GetConVarFloat(hSpypsyThrow);
	if(L4D2Version)
	{
		flTankThrow[38] = GetConVarFloat(hSipowThrow);
		flTankThrow[39] = GetConVarFloat(hPoltergeistThrow);
	}
	flTankThrow[40] = GetConVarFloat(hMirageThrow);

	bTankFireImmunity[0] = GetConVarBool(hDefaultFireImmunity);
	if(L4D2Version)
	{
		bTankFireImmunity[1] = GetConVarBool(hSpawnFireImmunity);
	}
	bTankFireImmunity[2] = GetConVarBool(hSmasherFireImmunity);
	bTankFireImmunity[3] = GetConVarBool(hWarpFireImmunity);
	bTankFireImmunity[4] = GetConVarBool(hMeteorFireImmunity);
	if(L4D2Version)
	{
		bTankFireImmunity[5] = GetConVarBool(hAcidFireImmunity);
	}
	bTankFireImmunity[6] = GetConVarBool(hHealthFireImmunity);
	bTankFireImmunity[7] = GetConVarBool(hFireFireImmunity);
	if(L4D2Version)
	{
		bTankFireImmunity[8] = GetConVarBool(hIceFireImmunity);
		bTankFireImmunity[9] = GetConVarBool(hJockeyFireImmunity);
	}
	bTankFireImmunity[10] = GetConVarBool(hHunterFireImmunity);
	bTankFireImmunity[11] = GetConVarBool(hSmokerFireImmunity);
	bTankFireImmunity[12] = GetConVarBool(hBoomerFireImmunity);
	if(L4D2Version)
	{
		bTankFireImmunity[13] = GetConVarBool(hChargerFireImmunity);
		bTankFireImmunity[14] = GetConVarBool(hGhostFireImmunity);
	}
	bTankFireImmunity[15] = GetConVarBool(hShockFireImmunity);
	bTankFireImmunity[16] = GetConVarBool(hWitchFireImmunity);
	bTankFireImmunity[17] = GetConVarBool(hShieldFireImmunity);
	bTankFireImmunity[18] = GetConVarBool(hCobaltFireImmunity);
	bTankFireImmunity[19] = GetConVarBool(hJumperFireImmunity);
	bTankFireImmunity[20] = GetConVarBool(hGravityFireImmunity);
	bTankFireImmunity[21] = GetConVarBool(hFlashFireImmunity);
	bTankFireImmunity[22] = GetConVarBool(hReverseFlashFireImmunity);
	bTankFireImmunity[23] = GetConVarBool(hArmageddonFireImmunity);
	if(L4D2Version)
	{
		bTankFireImmunity[24] = GetConVarBool(hHallucinationFireImmunity);
	}
	bTankFireImmunity[25] = GetConVarBool(hMinionFireImmunity);
	bTankFireImmunity[26] = GetConVarBool(hBitchFireImmunity);
	bTankFireImmunity[27] = GetConVarBool(hTrapFireImmunity);
	bTankFireImmunity[28] = GetConVarBool(hDistractionFireImmunity);
	bTankFireImmunity[29] = GetConVarBool(hFeedbackFireImmunity);
	bTankFireImmunity[30] = GetConVarBool(hPsychoticFireImmunity);
	if(L4D2Version)
	{
		bTankFireImmunity[31] = GetConVarBool(hSpitterFireImmunity);
	}
	bTankFireImmunity[32] = GetConVarBool(hGoliathFireImmunity);
	bTankFireImmunity[33] = GetConVarBool(hPsykotikFireImmunity);
	bTankFireImmunity[34] = GetConVarBool(hSpykotikFireImmunity);
	if(L4D2Version)
	{
		//Meme Tank
		bTankFireImmunity[35] = GetConVarBool(hMemeFireImmunity);

		//Boss Tank
		bTankFireImmunity[36] = GetConVarBool(hBossFireImmunity);
	}
	bTankFireImmunity[37] = GetConVarBool(hSpypsyFireImmunity);
	if(L4D2Version)
	{
		bTankFireImmunity[38] = GetConVarBool(hSipowFireImmunity);
		bTankFireImmunity[39] = GetConVarBool(hPoltergeistFireImmunity);
	}
	bTankFireImmunity[40] = GetConVarBool(hMirageFireImmunity);

	if(L4D2Version)
	{
		iSpawnCommonAmount = GetConVarInt(hSpawnCommonAmount);
		iSpawnCommonInterval = GetConVarInt(hSpawnCommonInterval);
	}
	iSmasherMaimDamage = GetConVarInt(hSmasherMaimDamage);
	iSmasherCrushDamage = GetConVarInt(hSmasherCrushDamage);
	bSmasherRemoveBody = GetConVarBool(hSmasherRemoveBody);
	iArmageddonMaimDamage = GetConVarInt(hArmageddonMaimDamage);
	iArmageddonCrushDamage = GetConVarInt(hArmageddonCrushDamage);
	bArmageddonRemoveBody = GetConVarBool(hArmageddonRemoveBody);
	iTrapMaimDamage = GetConVarInt(hTrapMaimDamage);
	iTrapCrushDamage = GetConVarInt(hTrapCrushDamage);
	bTrapRemoveBody = GetConVarBool(hTrapRemoveBody);
	iGoliathMaimDamage = GetConVarInt(hGoliathMaimDamage);
	iGoliathCrushDamage = GetConVarInt(hGoliathCrushDamage);
	bGoliathRemoveBody = GetConVarBool(hGoliathRemoveBody);
	iWarpTeleportDelay = GetConVarInt(hWarpTeleportDelay);
	iFeedbackTeleportDelay = GetConVarInt(hFeedbackTeleportDelay);
	iDistractionTeleportDelay = GetConVarInt(hDistractionTeleportDelay);
	iPsychoticTeleportDelay = GetConVarInt(hPsychoticTeleportDelay);
	iFlashTeleportDelay = GetConVarInt(hFlashTeleportDelay);
	iReverseFlashTeleportDelay = GetConVarInt(hReverseFlashTeleportDelay);
	iPsykotikTeleportDelay = GetConVarInt(hPsykotikTeleportDelay);
	iSpykotikTeleportDelay = GetConVarInt(hSpykotikTeleportDelay);
	iSpypsyTeleportDelay = GetConVarInt(hSpypsyTeleportDelay);
	if(L4D2Version)
	{
		iHallucinationTeleportDelay = GetConVarInt(hHallucinationTeleportDelay);
		iPoltergeistTeleportDelay = GetConVarInt(hPoltergeistTeleportDelay);
	}
	iMirageTeleportDelay = GetConVarInt(hMirageTeleportDelay);
	iMeteorStormDelay = GetConVarInt(hMeteorStormDelay);
	flMeteorStormDamage = GetConVarFloat(hMeteorStormDamage);
	iPsychoticStormDelay = GetConVarInt(hPsychoticStormDelay);
	flPsychoticStormDamage = GetConVarFloat(hPsychoticStormDamage);
	iArmageddonStormDelay = GetConVarInt(hArmageddonStormDelay);
	flArmageddonStormDamage = GetConVarFloat(hArmageddonStormDamage);
	if(L4D2Version)
	{
		iSipowStormDelay = GetConVarInt(hSipowStormDelay);
		flSipowStormDamage = GetConVarFloat(hSipowStormDamage);
	}
	iHealthHealthCommons = GetConVarInt(hHealthHealthCommons);
	iHealthHealthSpecials = GetConVarInt(hHealthHealthSpecials);
	iHealthHealthTanks = GetConVarInt(hHealthHealthTanks);
	iPsychoticHealthCommons = GetConVarInt(hPsychoticHealthCommons);
	iPsychoticHealthSpecials = GetConVarInt(hPsychoticHealthSpecials);
	iPsychoticHealthTanks = GetConVarInt(hPsychoticHealthTanks);
	iGoliathHealthCommons = GetConVarInt(hGoliathHealthCommons);
	iGoliathHealthSpecials = GetConVarInt(hGoliathHealthSpecials);
	iGoliathHealthTanks = GetConVarInt(hGoliathHealthTanks);
	iPsykotikHealthCommons = GetConVarInt(hPsykotikHealthCommons);
	iPsykotikHealthSpecials = GetConVarInt(hPsykotikHealthSpecials);
	iPsykotikHealthTanks = GetConVarInt(hPsykotikHealthTanks);
	if(L4D2Version)
	{
		bGhostDisarm = GetConVarBool(hGhostDisarm);
		bHallucinationDisarm = GetConVarBool(hHallucinationDisarm);
		bPoltergeistDisarm = GetConVarBool(hPoltergeistDisarm);
	}
	iShockStunDamage = GetConVarInt(hShockStunDamage);
	flShockStunMovement = GetConVarFloat(hShockStunMovement);
	iFeedbackStunDamage = GetConVarInt(hFeedbackStunDamage);
	flFeedbackStunMovement = GetConVarFloat(hFeedbackStunMovement);
	iWitchMaxWitches = GetConVarInt(hWitchMaxWitches);
	flShieldShieldsDownInterval = GetConVarFloat(hShieldShieldsDownInterval);
	flPsychoticShieldsDownInterval = GetConVarFloat(hPsychoticShieldsDownInterval);
	flGoliathShieldsDownInterval = GetConVarFloat(hGoliathShieldsDownInterval);
	flFlashSpecialSpeed = GetConVarFloat(hFlashSpecialSpeed);
	flReverseFlashSpecialSpeed = GetConVarFloat(hReverseFlashSpecialSpeed);
	flPsykotikSpecialSpeed = GetConVarFloat(hPsykotikSpecialSpeed);
	flSpykotikSpecialSpeed = GetConVarFloat(hSpykotikSpecialSpeed);
	flSpypsySpecialSpeed = GetConVarFloat(hSpypsySpecialSpeed);
	if(L4D2Version)
	{
		flPoltergeistSpecialSpeed = GetConVarFloat(hPoltergeistSpecialSpeed);
	}
	flCobaltSpecialSpeed = GetConVarFloat(hCobaltSpecialSpeed);
	flMirageSpecialSpeed = GetConVarFloat(hMirageSpecialSpeed);
	iJumperJumpDelay = GetConVarInt(hJumperJumpDelay);
	iPsychoticJumpDelay = GetConVarInt(hPsychoticJumpDelay);
	iDistractionJumpDelay = GetConVarInt(hDistractionJumpDelay);
	flGravityPullForce = GetConVarFloat(hGravityPullForce);
	flArmageddonPullForce = GetConVarFloat(hArmageddonPullForce);
	flFeedbackPushForce = GetConVarFloat(hFeedbackPushForce);
	if(L4D2Version)
	{
		//Meme Tank
		iMemeCommonAmount = GetConVarInt(hMemeCommonAmount);
		iMemeCommonInterval = GetConVarInt(hMemeCommonInterval);
		iMemeMaimDamage = GetConVarInt(hMemeMaimDamage);
		iMemeCrushDamage = GetConVarInt(hMemeCrushDamage);
		bMemeRemoveBody = GetConVarBool(hMemeRemoveBody);
		iMemeTeleportDelay = GetConVarInt(hMemeTeleportDelay);
		iMemeStormDelay = GetConVarInt(hMemeStormDelay);
		flMemeStormDamage = GetConVarFloat(hMemeStormDamage);
		bMemeDisarm = GetConVarBool(hMemeDisarm);
		iMemeMaxWitches = GetConVarInt(hMemeMaxWitches);
		flMemeSpecialSpeed = GetConVarFloat(hMemeSpecialSpeed);
		iMemeJumpDelay = GetConVarInt(hMemeJumpDelay);
		flMemePullForce = GetConVarFloat(hMemePullForce);

		//Boss Tank
		iBossMaimDamage = GetConVarInt(hBossMaimDamage);
		iBossCrushDamage = GetConVarInt(hBossCrushDamage);
		bBossRemoveBody = GetConVarBool(hBossRemoveBody);
		iBossTeleportDelay = GetConVarInt(hBossTeleportDelay);
		iBossStormDelay = GetConVarInt(hBossStormDelay);
		flBossStormDamage = GetConVarFloat(hBossStormDamage);
		iBossHealthCommons = GetConVarInt(hBossHealthCommons);
		iBossHealthSpecials = GetConVarInt(hBossHealthSpecials);
		iBossHealthTanks = GetConVarInt(hBossHealthTanks);
		bBossDisarm = GetConVarBool(hBossDisarm);
		iBossMaxWitches = GetConVarInt(hBossMaxWitches);
		flBossShieldsDownInterval = GetConVarFloat(hBossShieldsDownInterval);
		flBossSpecialSpeed = GetConVarFloat(hBossSpecialSpeed);
		iBossJumpDelay = GetConVarInt(hBossJumpDelay);
		flBossPullForce = GetConVarFloat(hBossPullForce);
	}

	HookConVarChange(hSuperTanksEnabled, SuperTanksCvarChanged);
	HookConVarChange(hDisplayHealthCvar, SuperTanksSettingsChanged);
	HookConVarChange(hWave1Cvar, SuperTanksSettingsChanged);
	HookConVarChange(hWave2Cvar, SuperTanksSettingsChanged);
	HookConVarChange(hWave3Cvar, SuperTanksSettingsChanged);
	HookConVarChange(hFinaleOnly, SuperTanksSettingsChanged);
	HookConVarChange(hDefaultTanks, SuperTanksSettingsChanged);
	HookConVarChange(hDefaultOverride, DefaultTanksSettingsChanged);
	HookConVarChange(hGamemodeCvar, GamemodeCvarChanged);
	if(L4D2Version)
	{
		HookConVarChange(hSpawnEnabled, TanksSettingsChanged);
	}
	HookConVarChange(hSmasherEnabled, TanksSettingsChanged);
	HookConVarChange(hWarpEnabled, TanksSettingsChanged);
	HookConVarChange(hMeteorEnabled, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hAcidEnabled, TanksSettingsChanged);
	}
	HookConVarChange(hHealthEnabled, TanksSettingsChanged);
	HookConVarChange(hFireEnabled, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hIceEnabled, TanksSettingsChanged);
		HookConVarChange(hJockeyEnabled, TanksSettingsChanged);
	}
	HookConVarChange(hHunterEnabled, TanksSettingsChanged);
	HookConVarChange(hSmokerEnabled, TanksSettingsChanged);
	HookConVarChange(hBoomerEnabled, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hChargerEnabled, TanksSettingsChanged);
		HookConVarChange(hGhostEnabled, TanksSettingsChanged);
	}
	HookConVarChange(hShockEnabled, TanksSettingsChanged);
	HookConVarChange(hWitchEnabled, TanksSettingsChanged);
	HookConVarChange(hShieldEnabled, TanksSettingsChanged);
	HookConVarChange(hCobaltEnabled, TanksSettingsChanged);
	HookConVarChange(hJumperEnabled, TanksSettingsChanged);
	HookConVarChange(hDistractionEnabled, TanksSettingsChanged);
	HookConVarChange(hGravityEnabled, TanksSettingsChanged);
	HookConVarChange(hFlashEnabled, TanksSettingsChanged);
	HookConVarChange(hReverseFlashEnabled, TanksSettingsChanged);
	HookConVarChange(hArmageddonEnabled, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hHallucinationEnabled, TanksSettingsChanged);
	}
	HookConVarChange(hMinionEnabled, TanksSettingsChanged);
	HookConVarChange(hBitchEnabled, TanksSettingsChanged);
	HookConVarChange(hFeedbackEnabled, TanksSettingsChanged);
	HookConVarChange(hTrapEnabled, TanksSettingsChanged);
	HookConVarChange(hPsychoticEnabled, TanksSettingsChanged);
	HookConVarChange(hGoliathEnabled, TanksSettingsChanged);
	HookConVarChange(hPsykotikEnabled, TanksSettingsChanged);
	HookConVarChange(hSpykotikEnabled, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hSpitterEnabled, TanksSettingsChanged);

		//Meme Tank
		HookConVarChange(hMemeEnabled, TanksSettingsChanged);

		//Boss Tank
		HookConVarChange(hBossEnabled, TanksSettingsChanged);
		HookConVarChange(hSipowEnabled, TanksSettingsChanged);
		HookConVarChange(hPoltergeistEnabled, TanksSettingsChanged);
	}
	HookConVarChange(hSpypsyEnabled, TanksSettingsChanged);
	HookConVarChange(hMirageEnabled, TanksSettingsChanged);

	HookConVarChange(hDefaultExtraHealth, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hSpawnExtraHealth, TanksSettingsChanged);
	}
	HookConVarChange(hSmasherExtraHealth, TanksSettingsChanged);
	HookConVarChange(hWarpExtraHealth, TanksSettingsChanged);
	HookConVarChange(hMeteorExtraHealth, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hAcidExtraHealth, TanksSettingsChanged);
	}
	HookConVarChange(hHealthExtraHealth, TanksSettingsChanged);
	HookConVarChange(hFireExtraHealth, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hIceExtraHealth, TanksSettingsChanged);
		HookConVarChange(hJockeyExtraHealth, TanksSettingsChanged);
	}
	HookConVarChange(hHunterExtraHealth, TanksSettingsChanged);
	HookConVarChange(hSmokerExtraHealth, TanksSettingsChanged);
	HookConVarChange(hBoomerExtraHealth, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hChargerExtraHealth, TanksSettingsChanged);
		HookConVarChange(hGhostExtraHealth, TanksSettingsChanged);
	}
	HookConVarChange(hShockExtraHealth, TanksSettingsChanged);
	HookConVarChange(hWitchExtraHealth, TanksSettingsChanged);
	HookConVarChange(hShieldExtraHealth, TanksSettingsChanged);
	HookConVarChange(hCobaltExtraHealth, TanksSettingsChanged);
	HookConVarChange(hJumperExtraHealth, TanksSettingsChanged);
	HookConVarChange(hDistractionExtraHealth, TanksSettingsChanged);
	HookConVarChange(hGravityExtraHealth, TanksSettingsChanged);
	HookConVarChange(hFlashExtraHealth, TanksSettingsChanged);
	HookConVarChange(hReverseFlashExtraHealth, TanksSettingsChanged);
	HookConVarChange(hArmageddonExtraHealth, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hHallucinationExtraHealth, TanksSettingsChanged);
	}
	HookConVarChange(hMinionExtraHealth, TanksSettingsChanged);
	HookConVarChange(hBitchExtraHealth, TanksSettingsChanged);
	HookConVarChange(hFeedbackExtraHealth, TanksSettingsChanged);
	HookConVarChange(hTrapExtraHealth, TanksSettingsChanged);
	HookConVarChange(hPsychoticExtraHealth, TanksSettingsChanged);
	HookConVarChange(hGoliathExtraHealth, TanksSettingsChanged);
	HookConVarChange(hPsykotikExtraHealth, TanksSettingsChanged);
	HookConVarChange(hSpykotikExtraHealth, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hSpitterExtraHealth, TanksSettingsChanged);

		//Meme Tank
		HookConVarChange(hMemeExtraHealth, TanksSettingsChanged);

		//Boss Tank
		HookConVarChange(hBossExtraHealth, TanksSettingsChanged);
		HookConVarChange(hSipowExtraHealth, TanksSettingsChanged);
		HookConVarChange(hPoltergeistExtraHealth, TanksSettingsChanged);
	}
	HookConVarChange(hSpypsyExtraHealth, TanksSettingsChanged);
	HookConVarChange(hMirageExtraHealth, TanksSettingsChanged);

	HookConVarChange(hDefaultSpeed, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hSpawnSpeed, TanksSettingsChanged);
	}
	HookConVarChange(hSmasherSpeed, TanksSettingsChanged);
	HookConVarChange(hWarpSpeed, TanksSettingsChanged);
	HookConVarChange(hMeteorSpeed, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hAcidSpeed, TanksSettingsChanged);
	}
	HookConVarChange(hHealthSpeed, TanksSettingsChanged);
	HookConVarChange(hFireSpeed, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hIceSpeed, TanksSettingsChanged);
		HookConVarChange(hJockeySpeed, TanksSettingsChanged);
	}
	HookConVarChange(hHunterSpeed, TanksSettingsChanged);
	HookConVarChange(hSmokerSpeed, TanksSettingsChanged);
	HookConVarChange(hBoomerSpeed, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hChargerSpeed, TanksSettingsChanged);
		HookConVarChange(hGhostSpeed, TanksSettingsChanged);
	}
	HookConVarChange(hShockSpeed, TanksSettingsChanged);
	HookConVarChange(hWitchSpeed, TanksSettingsChanged);
	HookConVarChange(hShieldSpeed, TanksSettingsChanged);
	HookConVarChange(hCobaltSpeed, TanksSettingsChanged);
	HookConVarChange(hJumperSpeed, TanksSettingsChanged);
	HookConVarChange(hDistractionSpeed, TanksSettingsChanged);
	HookConVarChange(hGravitySpeed, TanksSettingsChanged);
	HookConVarChange(hFlashSpeed, TanksSettingsChanged);
	HookConVarChange(hReverseFlashSpeed, TanksSettingsChanged);
	HookConVarChange(hArmageddonSpeed, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hHallucinationSpeed, TanksSettingsChanged);
	}
	HookConVarChange(hMinionSpeed, TanksSettingsChanged);
	HookConVarChange(hBitchSpeed, TanksSettingsChanged);
	HookConVarChange(hFeedbackSpeed, TanksSettingsChanged);
	HookConVarChange(hTrapSpeed, TanksSettingsChanged);
	HookConVarChange(hPsychoticSpeed, TanksSettingsChanged);
	HookConVarChange(hGoliathSpeed, TanksSettingsChanged);
	HookConVarChange(hPsykotikSpeed, TanksSettingsChanged);
	HookConVarChange(hSpykotikSpeed, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hSpitterSpeed, TanksSettingsChanged);

		//Meme Tank
		HookConVarChange(hMemeSpeed, TanksSettingsChanged);

		//Boss Tank
		HookConVarChange(hBossSpeed, TanksSettingsChanged);
		HookConVarChange(hSipowSpeed, TanksSettingsChanged);
		HookConVarChange(hPoltergeistSpeed, TanksSettingsChanged);
	}
	HookConVarChange(hSpypsySpeed, TanksSettingsChanged);
	HookConVarChange(hMirageSpeed, TanksSettingsChanged);

	HookConVarChange(hDefaultThrow, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hSpawnThrow, TanksSettingsChanged);
	}
	HookConVarChange(hSmasherThrow, TanksSettingsChanged);
	HookConVarChange(hWarpThrow, TanksSettingsChanged);
	HookConVarChange(hMeteorThrow, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hAcidThrow, TanksSettingsChanged);
	}
	HookConVarChange(hHealthThrow, TanksSettingsChanged);
	HookConVarChange(hFireThrow, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hIceThrow, TanksSettingsChanged);
		HookConVarChange(hJockeyThrow, TanksSettingsChanged);
	}
	HookConVarChange(hHunterThrow, TanksSettingsChanged);
	HookConVarChange(hSmokerThrow, TanksSettingsChanged);
	HookConVarChange(hBoomerThrow, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hChargerThrow, TanksSettingsChanged);
		HookConVarChange(hGhostThrow, TanksSettingsChanged);
	}
	HookConVarChange(hShockThrow, TanksSettingsChanged);
	HookConVarChange(hWitchThrow, TanksSettingsChanged);
	HookConVarChange(hShieldThrow, TanksSettingsChanged);
	HookConVarChange(hCobaltThrow, TanksSettingsChanged);
	HookConVarChange(hJumperThrow, TanksSettingsChanged);
	HookConVarChange(hDistractionThrow, TanksSettingsChanged);
	HookConVarChange(hGravityThrow, TanksSettingsChanged);
	HookConVarChange(hFlashThrow, TanksSettingsChanged);
	HookConVarChange(hReverseFlashThrow, TanksSettingsChanged);
	HookConVarChange(hArmageddonThrow, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hHallucinationThrow, TanksSettingsChanged);
	}
	HookConVarChange(hMinionThrow, TanksSettingsChanged);
	HookConVarChange(hBitchThrow, TanksSettingsChanged);
	HookConVarChange(hFeedbackThrow, TanksSettingsChanged);
	HookConVarChange(hTrapThrow, TanksSettingsChanged);
	HookConVarChange(hPsychoticThrow, TanksSettingsChanged);
	HookConVarChange(hGoliathThrow, TanksSettingsChanged);
	HookConVarChange(hPsykotikThrow, TanksSettingsChanged);
	HookConVarChange(hSpykotikThrow, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hSpitterThrow, TanksSettingsChanged);

		//Meme Tank
		HookConVarChange(hMemeThrow, TanksSettingsChanged);

		//Boss Tank
		HookConVarChange(hBossThrow, TanksSettingsChanged);
		HookConVarChange(hSipowThrow, TanksSettingsChanged);
		HookConVarChange(hPoltergeistThrow, TanksSettingsChanged);
	}
	HookConVarChange(hSpypsyThrow, TanksSettingsChanged);
	HookConVarChange(hMirageThrow, TanksSettingsChanged);

	HookConVarChange(hDefaultFireImmunity, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hSpawnFireImmunity, TanksSettingsChanged);
	}
	HookConVarChange(hSmasherFireImmunity, TanksSettingsChanged);
	HookConVarChange(hWarpFireImmunity, TanksSettingsChanged);
	HookConVarChange(hMeteorFireImmunity, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hAcidFireImmunity, TanksSettingsChanged);
	}
	HookConVarChange(hHealthFireImmunity, TanksSettingsChanged);
	HookConVarChange(hFireFireImmunity, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hIceFireImmunity, TanksSettingsChanged);
		HookConVarChange(hJockeyFireImmunity, TanksSettingsChanged);
	}
	HookConVarChange(hHunterFireImmunity, TanksSettingsChanged);
	HookConVarChange(hSmokerFireImmunity, TanksSettingsChanged);
	HookConVarChange(hBoomerFireImmunity, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hChargerFireImmunity, TanksSettingsChanged);
		HookConVarChange(hGhostFireImmunity, TanksSettingsChanged);
	}
	HookConVarChange(hShockFireImmunity, TanksSettingsChanged);
	HookConVarChange(hWitchFireImmunity, TanksSettingsChanged);
	HookConVarChange(hShieldFireImmunity, TanksSettingsChanged);
	HookConVarChange(hCobaltFireImmunity, TanksSettingsChanged);
	HookConVarChange(hJumperFireImmunity, TanksSettingsChanged);
	HookConVarChange(hDistractionFireImmunity, TanksSettingsChanged);
	HookConVarChange(hGravityFireImmunity, TanksSettingsChanged);
	HookConVarChange(hFlashFireImmunity, TanksSettingsChanged);
	HookConVarChange(hReverseFlashFireImmunity, TanksSettingsChanged);
	HookConVarChange(hArmageddonFireImmunity, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hHallucinationFireImmunity, TanksSettingsChanged);
	}
	HookConVarChange(hMinionFireImmunity, TanksSettingsChanged);
	HookConVarChange(hBitchFireImmunity, TanksSettingsChanged);
	HookConVarChange(hFeedbackFireImmunity, TanksSettingsChanged);
	HookConVarChange(hTrapFireImmunity, TanksSettingsChanged);
	HookConVarChange(hPsychoticFireImmunity, TanksSettingsChanged);
	HookConVarChange(hGoliathFireImmunity, TanksSettingsChanged);
	HookConVarChange(hPsykotikFireImmunity, TanksSettingsChanged);
	HookConVarChange(hSpykotikFireImmunity, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hSpitterFireImmunity, TanksSettingsChanged);

		//Meme Tank
		HookConVarChange(hMemeFireImmunity, TanksSettingsChanged);

		//Boss Tank
		HookConVarChange(hBossFireImmunity, TanksSettingsChanged);
		HookConVarChange(hSpypsyFireImmunity, TanksSettingsChanged);
		HookConVarChange(hSipowFireImmunity, TanksSettingsChanged);
		HookConVarChange(hPoltergeistFireImmunity, TanksSettingsChanged);
	}
	HookConVarChange(hMirageFireImmunity, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hSpawnCommonAmount, TanksSettingsChanged);
		HookConVarChange(hSpawnCommonInterval, TanksSettingsChanged);
	}
	HookConVarChange(hSmasherMaimDamage, TanksSettingsChanged);
	HookConVarChange(hSmasherCrushDamage, TanksSettingsChanged);
	HookConVarChange(hArmageddonMaimDamage, TanksSettingsChanged);
	HookConVarChange(hArmageddonCrushDamage, TanksSettingsChanged);
	HookConVarChange(hTrapMaimDamage, TanksSettingsChanged);
	HookConVarChange(hTrapCrushDamage, TanksSettingsChanged);
	HookConVarChange(hGoliathMaimDamage, TanksSettingsChanged);
	HookConVarChange(hGoliathCrushDamage, TanksSettingsChanged);
	HookConVarChange(hWarpTeleportDelay, TanksSettingsChanged);
	HookConVarChange(hFeedbackTeleportDelay, TanksSettingsChanged);
	HookConVarChange(hDistractionTeleportDelay, TanksSettingsChanged);
	HookConVarChange(hMirageTeleportDelay, TanksSettingsChanged);
	HookConVarChange(hPsychoticTeleportDelay, TanksSettingsChanged);
	HookConVarChange(hFlashTeleportDelay, TanksSettingsChanged);
	HookConVarChange(hReverseFlashTeleportDelay, TanksSettingsChanged);
	HookConVarChange(hPsykotikTeleportDelay, TanksSettingsChanged);
	HookConVarChange(hSpykotikTeleportDelay, TanksSettingsChanged);
	HookConVarChange(hSpypsyTeleportDelay, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hHallucinationTeleportDelay, TanksSettingsChanged);
		HookConVarChange(hPoltergeistTeleportDelay, TanksSettingsChanged);
		HookConVarChange(hSipowStormDelay, TanksSettingsChanged);
		HookConVarChange(hSipowStormDamage, TanksSettingsChanged);
	}
	HookConVarChange(hMeteorStormDelay, TanksSettingsChanged);
	HookConVarChange(hMeteorStormDamage, TanksSettingsChanged);
	HookConVarChange(hPsychoticStormDelay, TanksSettingsChanged);
	HookConVarChange(hPsychoticStormDamage, TanksSettingsChanged);
	HookConVarChange(hArmageddonStormDelay, TanksSettingsChanged);
	HookConVarChange(hArmageddonStormDamage, TanksSettingsChanged);
	HookConVarChange(hHealthHealthCommons, TanksSettingsChanged);
	HookConVarChange(hHealthHealthSpecials, TanksSettingsChanged);
	HookConVarChange(hHealthHealthTanks, TanksSettingsChanged);
	HookConVarChange(hPsychoticHealthCommons, TanksSettingsChanged);
	HookConVarChange(hPsychoticHealthSpecials, TanksSettingsChanged);
	HookConVarChange(hPsychoticHealthTanks, TanksSettingsChanged);
	HookConVarChange(hGoliathHealthCommons, TanksSettingsChanged);
	HookConVarChange(hGoliathHealthSpecials, TanksSettingsChanged);
	HookConVarChange(hGoliathHealthTanks, TanksSettingsChanged);
	HookConVarChange(hPsykotikHealthCommons, TanksSettingsChanged);
	HookConVarChange(hPsykotikHealthSpecials, TanksSettingsChanged);
	HookConVarChange(hPsykotikHealthTanks, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hGhostDisarm, TanksSettingsChanged);
		HookConVarChange(hHallucinationDisarm, TanksSettingsChanged);
		HookConVarChange(hPoltergeistDisarm, TanksSettingsChanged);
	}
	HookConVarChange(hShockStunDamage, TanksSettingsChanged);
	HookConVarChange(hShockStunMovement, TanksSettingsChanged);
	HookConVarChange(hFeedbackStunDamage, TanksSettingsChanged);
	HookConVarChange(hFeedbackStunMovement, TanksSettingsChanged);
	HookConVarChange(hWitchMaxWitches, TanksSettingsChanged);
	HookConVarChange(hShieldShieldsDownInterval, TanksSettingsChanged);
	HookConVarChange(hPsychoticShieldsDownInterval, TanksSettingsChanged);
	HookConVarChange(hGoliathShieldsDownInterval, TanksSettingsChanged);
	HookConVarChange(hFlashSpecialSpeed, TanksSettingsChanged);
	HookConVarChange(hReverseFlashSpecialSpeed, TanksSettingsChanged);
	HookConVarChange(hPsykotikSpecialSpeed, TanksSettingsChanged);
	HookConVarChange(hSpykotikSpecialSpeed, TanksSettingsChanged);
	HookConVarChange(hSpypsySpecialSpeed, TanksSettingsChanged);
	if(L4D2Version)
	{
		HookConVarChange(hPoltergeistSpecialSpeed, TanksSettingsChanged);
	}
	HookConVarChange(hCobaltSpecialSpeed, TanksSettingsChanged);
	HookConVarChange(hMirageSpecialSpeed, TanksSettingsChanged);
	HookConVarChange(hJumperJumpDelay, TanksSettingsChanged);
	HookConVarChange(hDistractionJumpDelay, TanksSettingsChanged);
	HookConVarChange(hGravityPullForce, TanksSettingsChanged);
	HookConVarChange(hFeedbackPushForce, TanksSettingsChanged);
	HookConVarChange(hPsychoticJumpDelay, TanksSettingsChanged);
	HookConVarChange(hArmageddonPullForce, TanksSettingsChanged);

	if(L4D2Version)
	{
		//Meme Tank
		HookConVarChange(hMemeCommonAmount, TanksSettingsChanged);
		HookConVarChange(hMemeCommonInterval, TanksSettingsChanged);
		HookConVarChange(hMemeMaimDamage, TanksSettingsChanged);
		HookConVarChange(hMemeCrushDamage, TanksSettingsChanged);
		HookConVarChange(hMemeTeleportDelay, TanksSettingsChanged);
		HookConVarChange(hMemeStormDelay, TanksSettingsChanged);
		HookConVarChange(hMemeStormDamage, TanksSettingsChanged);
		HookConVarChange(hMemeDisarm, TanksSettingsChanged);
		HookConVarChange(hMemeMaxWitches, TanksSettingsChanged);
		HookConVarChange(hMemeSpecialSpeed, TanksSettingsChanged);
		HookConVarChange(hMemeJumpDelay, TanksSettingsChanged);
		HookConVarChange(hMemePullForce, TanksSettingsChanged);

		//Boss Tank
		HookConVarChange(hBossMaimDamage, TanksSettingsChanged);
		HookConVarChange(hBossCrushDamage, TanksSettingsChanged);
		HookConVarChange(hBossTeleportDelay, TanksSettingsChanged);
		HookConVarChange(hBossStormDelay, TanksSettingsChanged);
		HookConVarChange(hBossStormDamage, TanksSettingsChanged);
		HookConVarChange(hBossHealthCommons, TanksSettingsChanged);
		HookConVarChange(hBossHealthSpecials, TanksSettingsChanged);
		HookConVarChange(hBossHealthTanks, TanksSettingsChanged);
		HookConVarChange(hBossDisarm, TanksSettingsChanged);
		HookConVarChange(hBossMaxWitches, TanksSettingsChanged);
		HookConVarChange(hBossShieldsDownInterval, TanksSettingsChanged);
		HookConVarChange(hBossSpecialSpeed, TanksSettingsChanged);
		HookConVarChange(hBossJumpDelay, TanksSettingsChanged);
		HookConVarChange(hBossPullForce, TanksSettingsChanged);
	}
	HookEvent("ability_use", Ability_Use);
	HookEvent("finale_escape_start", Finale_Escape_Start);
	HookEvent("finale_start", Finale_Start, EventHookMode_Pre);
	HookEvent("finale_vehicle_leaving", Finale_Vehicle_Leaving);
	HookEvent("finale_vehicle_ready", Finale_Vehicle_Ready);
	HookEvent("player_death", Player_Death);
	HookEvent("tank_spawn", Tank_Spawn);
	HookEvent("round_end", Round_End);
	HookEvent("round_start", Round_Start);

	CreateTimer(0.1,TimerUpdate01, _, TIMER_REPEAT);
	CreateTimer(1.0,TimerUpdate1, _, TIMER_REPEAT);
	if(L4D2Version)
	{
		InitSDKCalls();
		InitStartUp();
	}
	AutoExecConfig(true, "l4d_supertanks");
}
//=============================
// StartUp
//=============================
void GameCheck()
{
	char GameName[16];
	GetGameFolderName(GameName, sizeof(GameName));
	if(StrEqual(GameName, "left4dead2", false))
	{
		L4D2Version = true;
	}

	else
	{
		L4D2Version = false;
	}
}
InitSDKCalls()
{
	new Handle:ConfigFile = LoadGameConfigFile("l4d2_supertanks");
	new Handle:MySDKCall = INVALID_HANDLE;

	/////////////
	//SpitBurst//
	/////////////
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "CSpitterProjectile_Detonate");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	MySDKCall = EndPrepSDKCall();
	if(MySDKCall == INVALID_HANDLE)
	{
		SetFailState("Cant initialize CSpitterProjectile_Detonate SDKCall");
	}
	SDKSpitBurst = CloneHandle(MySDKCall, SDKSpitBurst);

	/////////////////
	//VomitOnPlayer//
	/////////////////
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(ConfigFile, SDKConf_Signature, "CTerrorPlayer_OnVomitedUpon");
	PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	MySDKCall = EndPrepSDKCall();
	if(MySDKCall == INVALID_HANDLE)
	{
		SetFailState("Cant initialize CTerrorPlayer_OnVomitedUpon SDKCall");
	}
	SDKVomitOnPlayer = CloneHandle(MySDKCall, SDKVomitOnPlayer);

	CloseHandle(ConfigFile);
	CloseHandle(MySDKCall);
}
stock SDKCallSpitBurst(client)
{
	SDKCall(SDKSpitBurst, client, true);
}
stock SDKCallVomitOnPlayer(victim, attacker)
{
	SDKCall(SDKVomitOnPlayer, victim, attacker, true);
}
InitStartUp()
{
	if(bSuperTanksEnabled)
	{
		decl String:gamemode[24];
		GetConVarString(FindConVar("mp_gamemode"), gamemode, sizeof(gamemode));
       		if(!StrEqual(gamemode, "coop", false) && !StrEqual(gamemode, "realism", false) && !StrEqual(gamemode, "survival", false) && !StrEqual(gamemode, "l4d1coop", false) && !StrEqual(gamemode, "l4d2coop", false) && !StrEqual(gamemode, "realismsurvival", false) && !StrEqual(gamemode, "united", false) && !StrEqual(gamemode, "unitedcoop", false) && !StrEqual(gamemode, "unitedrealism", false))
		{
			PrintToServer("[SuperTanks] This plugin is only compatible in Coop, Realism, and Survival gamemodes.");
			PrintToServer("[SuperTanks] Plugin Disabled.");
			SetConVarBool(hSuperTanksEnabled, false);		
		}
	}
}
//=============================
// Events
//=============================
public GamemodeCvarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if(bSuperTanksEnabled)
	{
		if(convar == hGamemodeCvar)
		{
       		if(StrEqual(oldValue, newValue, false)) return;

       		if(!StrEqual(newValue, "coop", false) && !StrEqual(newValue, "realism", false) && !StrEqual(newValue, "survival", false) && !StrEqual(newValue, "l4d1coop", false) && !StrEqual(newValue, "l4d2coop", false) && !StrEqual(newValue, "realismsurvival", false) && !StrEqual(newValue, "united", false) && !StrEqual(newValue, "unitedcoop", false) && !StrEqual(newValue, "unitedrealism", false))
			{
				PrintToServer("[SuperTanks] This plugin is only compatible in Coop, Realism, and Survival gamemodes.");
				PrintToServer("[SuperTanks] Plugin Disabled.");
				SetConVarBool(hSuperTanksEnabled, false);
			}
		}
	}
}
public SuperTanksCvarChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if(convar == hSuperTanksEnabled)
	{
		new oldval = StringToInt(oldValue);
		new newval = StringToInt(newValue);

		if(newval == oldval) return;

		if(newval == 1)
		{
			decl String:gamemode[24];
			GetConVarString(FindConVar("mp_gamemode"), gamemode, sizeof(gamemode));
       			if(!StrEqual(gamemode, "coop", false) && !StrEqual(gamemode, "realism", false) && !StrEqual(gamemode, "survival", false) && !StrEqual(gamemode, "l4d1coop", false) && !StrEqual(gamemode, "l4d2coop", false) && !StrEqual(gamemode, "realismsurvival", false) && !StrEqual(gamemode, "united", false) && !StrEqual(gamemode, "unitedcoop", false) && !StrEqual(gamemode, "unitedrealism", false))
			{
				PrintToServer("[SuperTanks] This plugin is only compatible in Coop, Realism, and Survival gamemodes.");
				PrintToServer("[SuperTanks] Plugin Disabled.");
				SetConVarBool(hSuperTanksEnabled, false);		
			}	
		}
		bSuperTanksEnabled = GetConVarBool(hSuperTanksEnabled);
	}
}
public SuperTanksSettingsChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	bDisplayHealthCvar = GetConVarBool(hDisplayHealthCvar);
	iWave1Cvar = GetConVarInt(hWave1Cvar);
	iWave2Cvar = GetConVarInt(hWave2Cvar);
	iWave3Cvar = GetConVarInt(hWave3Cvar);
	bFinaleOnly = GetConVarBool(hFinaleOnly);
	bDefaultTanks = GetConVarBool(hDefaultTanks);
}
public DefaultTanksSettingsChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if(convar == hDefaultOverride)
	{
		new oldval = StringToInt(oldValue);
		new newval = StringToInt(newValue);

		if(newval == oldval) return;

		if(newval == 0)
		{
			SetConVarInt(hDefaultExtraHealth, 0);
			SetConVarFloat(hDefaultSpeed, 1.0);
			SetConVarFloat(hDefaultThrow, 5.0);
			SetConVarBool(hDefaultFireImmunity, false);
		}
	}
	bDefaultOverride = GetConVarBool(hDefaultOverride);
}
public TanksSettingsChanged(Handle:convar, const String:oldValue[], const String:newValue[])
{
	if(L4D2Version)
	{
		bTankEnabled[1] = GetConVarBool(hSpawnEnabled);
	}
	bTankEnabled[2] = GetConVarBool(hSmasherEnabled);
	bTankEnabled[3] = GetConVarBool(hWarpEnabled);
	bTankEnabled[4] = GetConVarBool(hMeteorEnabled);
	if(L4D2Version)
	{
		bTankEnabled[5] = GetConVarBool(hAcidEnabled);
	}
	bTankEnabled[6] = GetConVarBool(hHealthEnabled);
	bTankEnabled[7] = GetConVarBool(hFireEnabled);
	if(L4D2Version)
	{
		bTankEnabled[8] = GetConVarBool(hIceEnabled);
		bTankEnabled[9] = GetConVarBool(hJockeyEnabled);
	}
	bTankEnabled[10] = GetConVarBool(hHunterEnabled);
	bTankEnabled[11] = GetConVarBool(hSmokerEnabled);
	bTankEnabled[12] = GetConVarBool(hBoomerEnabled);
	if(L4D2Version)
	{
		bTankEnabled[13] = GetConVarBool(hChargerEnabled);
		bTankEnabled[14] = GetConVarBool(hGhostEnabled);
	}
	bTankEnabled[15] = GetConVarBool(hShockEnabled);
	bTankEnabled[16] = GetConVarBool(hWitchEnabled);
	bTankEnabled[17] = GetConVarBool(hShieldEnabled);
	bTankEnabled[18] = GetConVarBool(hCobaltEnabled);
	bTankEnabled[19] = GetConVarBool(hJumperEnabled);
	bTankEnabled[20] = GetConVarBool(hGravityEnabled);
	bTankEnabled[21] = GetConVarBool(hFlashEnabled);
	bTankEnabled[22] = GetConVarBool(hReverseFlashEnabled);
	bTankEnabled[23] = GetConVarBool(hArmageddonEnabled);
	if(L4D2Version)
	{
		bTankEnabled[24] = GetConVarBool(hHallucinationEnabled);
	}
	bTankEnabled[25] = GetConVarBool(hMinionEnabled);
	bTankEnabled[26] = GetConVarBool(hBitchEnabled);
	bTankEnabled[27] = GetConVarBool(hTrapEnabled);
	bTankEnabled[28] = GetConVarBool(hDistractionEnabled);
	bTankEnabled[29] = GetConVarBool(hFeedbackEnabled);
	bTankEnabled[30] = GetConVarBool(hPsychoticEnabled);
	if(L4D2Version)
	{
		bTankEnabled[31] = GetConVarBool(hSpitterEnabled);
	}
	bTankEnabled[32] = GetConVarBool(hGoliathEnabled);
	bTankEnabled[33] = GetConVarBool(hPsykotikEnabled);
	bTankEnabled[34] = GetConVarBool(hSpykotikEnabled);
	if(L4D2Version)
	{
		//Meme Tank
		bTankEnabled[35] = GetConVarBool(hMemeEnabled);

		//Boss Tank
		bTankEnabled[36] = GetConVarBool(hBossEnabled);
	}
	bTankEnabled[37] = GetConVarBool(hSpypsyEnabled);
	if(L4D2Version)
	{
		bTankEnabled[38] = GetConVarBool(hSipowEnabled);
		bTankEnabled[39] = GetConVarBool(hPoltergeistEnabled);
	}
	bTankEnabled[40] = GetConVarBool(hMirageEnabled);

	iTankExtraHealth[0] = GetConVarInt(hDefaultExtraHealth);
	if(L4D2Version)
	{
		iTankExtraHealth[1] = GetConVarInt(hSpawnExtraHealth);
	}
	iTankExtraHealth[2] = GetConVarInt(hSmasherExtraHealth);
	iTankExtraHealth[3] = GetConVarInt(hWarpExtraHealth);
	iTankExtraHealth[4] = GetConVarInt(hMeteorExtraHealth);
	if(L4D2Version)
	{
		iTankExtraHealth[5] = GetConVarInt(hAcidExtraHealth);
	}
	iTankExtraHealth[6] = GetConVarInt(hHealthExtraHealth);
	iTankExtraHealth[7] = GetConVarInt(hFireExtraHealth);
	if(L4D2Version)
	{
		iTankExtraHealth[8] = GetConVarInt(hIceExtraHealth);
		iTankExtraHealth[9] = GetConVarInt(hJockeyExtraHealth);
	}
	iTankExtraHealth[10] = GetConVarInt(hHunterExtraHealth);
	iTankExtraHealth[11] = GetConVarInt(hSmokerExtraHealth);
	iTankExtraHealth[12] = GetConVarInt(hBoomerExtraHealth);
	if(L4D2Version)
	{
		iTankExtraHealth[13] = GetConVarInt(hChargerExtraHealth);
		iTankExtraHealth[14] = GetConVarInt(hGhostExtraHealth);
	}
	iTankExtraHealth[15] = GetConVarInt(hShockExtraHealth);
	iTankExtraHealth[16] = GetConVarInt(hWitchExtraHealth);
	iTankExtraHealth[17] = GetConVarInt(hShieldExtraHealth);
	iTankExtraHealth[18] = GetConVarInt(hCobaltExtraHealth);
	iTankExtraHealth[19] = GetConVarInt(hJumperExtraHealth);
	iTankExtraHealth[20] = GetConVarInt(hGravityExtraHealth);
	iTankExtraHealth[21] = GetConVarInt(hFlashExtraHealth);
	iTankExtraHealth[22] = GetConVarInt(hReverseFlashExtraHealth);
	iTankExtraHealth[23] = GetConVarInt(hArmageddonExtraHealth);
	if(L4D2Version)
	{
		iTankExtraHealth[24] = GetConVarInt(hHallucinationExtraHealth);
	}
	iTankExtraHealth[25] = GetConVarInt(hMinionExtraHealth);
	iTankExtraHealth[26] = GetConVarInt(hBitchExtraHealth);
	iTankExtraHealth[27] = GetConVarInt(hTrapExtraHealth);
	iTankExtraHealth[28] = GetConVarInt(hDistractionExtraHealth);
	iTankExtraHealth[29] = GetConVarInt(hFeedbackExtraHealth);
	iTankExtraHealth[30] = GetConVarInt(hPsychoticExtraHealth);
	if(L4D2Version)
	{
		iTankExtraHealth[31] = GetConVarInt(hSpitterExtraHealth);
	}
	iTankExtraHealth[32] = GetConVarInt(hGoliathExtraHealth);
	iTankExtraHealth[33] = GetConVarInt(hPsykotikExtraHealth);
	iTankExtraHealth[34] = GetConVarInt(hSpykotikExtraHealth);
	if(L4D2Version)
	{
		//Meme Tank
		iTankExtraHealth[35] = GetConVarInt(hMemeExtraHealth);

		//Boss Tank
		iTankExtraHealth[36] = GetConVarInt(hBossExtraHealth);
	}
	iTankExtraHealth[37] = GetConVarInt(hSpypsyExtraHealth);
	if(L4D2Version)
	{
		iTankExtraHealth[38] = GetConVarInt(hSipowExtraHealth);
		iTankExtraHealth[39] = GetConVarInt(hPoltergeistExtraHealth);
	}
	iTankExtraHealth[40] = GetConVarInt(hMirageExtraHealth);

	flTankSpeed[0] = GetConVarFloat(hDefaultSpeed);
	if(L4D2Version)
	{
		flTankSpeed[1] = GetConVarFloat(hSpawnSpeed);
	}
	flTankSpeed[2] = GetConVarFloat(hSmasherSpeed);
	flTankSpeed[3] = GetConVarFloat(hWarpSpeed);
	flTankSpeed[4] = GetConVarFloat(hMeteorSpeed);
	if(L4D2Version)
	{
		flTankSpeed[5] = GetConVarFloat(hAcidSpeed);
	}
	flTankSpeed[6] = GetConVarFloat(hHealthSpeed);
	flTankSpeed[7] = GetConVarFloat(hFireSpeed);
	if(L4D2Version)
	{
		flTankSpeed[8] = GetConVarFloat(hIceSpeed);
		flTankSpeed[9] = GetConVarFloat(hJockeySpeed);
	}
	flTankSpeed[10] = GetConVarFloat(hHunterSpeed);
	flTankSpeed[11] = GetConVarFloat(hSmokerSpeed);
	flTankSpeed[12] = GetConVarFloat(hBoomerSpeed);
	if(L4D2Version)
	{
		flTankSpeed[13] = GetConVarFloat(hChargerSpeed);
		flTankSpeed[14] = GetConVarFloat(hGhostSpeed);
	}
	flTankSpeed[15] = GetConVarFloat(hShockSpeed);
	flTankSpeed[16] = GetConVarFloat(hWitchSpeed);
	flTankSpeed[17] = GetConVarFloat(hShieldSpeed);
	flTankSpeed[18] = GetConVarFloat(hCobaltSpeed);
	flTankSpeed[19] = GetConVarFloat(hJumperSpeed);
	flTankSpeed[20] = GetConVarFloat(hGravitySpeed);
	flTankSpeed[21] = GetConVarFloat(hFlashSpeed);
	flTankSpeed[22] = GetConVarFloat(hReverseFlashSpeed);
	flTankSpeed[23] = GetConVarFloat(hArmageddonSpeed);
	if(L4D2Version)
	{
		flTankSpeed[24] = GetConVarFloat(hHallucinationSpeed);
	}
	flTankSpeed[25] = GetConVarFloat(hMinionSpeed);
	flTankSpeed[26] = GetConVarFloat(hBitchSpeed);
	flTankSpeed[27] = GetConVarFloat(hTrapSpeed);
	flTankSpeed[28] = GetConVarFloat(hDistractionSpeed);
	flTankSpeed[29] = GetConVarFloat(hFeedbackSpeed);
	flTankSpeed[30] = GetConVarFloat(hPsychoticSpeed);
	if(L4D2Version)
	{
		flTankSpeed[31] = GetConVarFloat(hSpitterSpeed);
	}
	flTankSpeed[32] = GetConVarFloat(hGoliathSpeed);
	flTankSpeed[33] = GetConVarFloat(hPsykotikSpeed);
	flTankSpeed[34] = GetConVarFloat(hSpykotikSpeed);
	if(L4D2Version)
	{
		//Meme Tank
		flTankSpeed[35] = GetConVarFloat(hMemeSpeed);

		//Boss Tank
		flTankSpeed[36] = GetConVarFloat(hBossSpeed);
	}
	flTankSpeed[37] = GetConVarFloat(hSpypsySpeed);
	if(L4D2Version)
	{
		flTankSpeed[38] = GetConVarFloat(hSipowSpeed);
		flTankSpeed[39] = GetConVarFloat(hPoltergeistSpeed);
	}
	flTankSpeed[40] = GetConVarFloat(hMirageSpeed);

	flTankThrow[0] = GetConVarFloat(hDefaultThrow);
	if(L4D2Version)
	{
		flTankThrow[1] = GetConVarFloat(hSpawnThrow);
	}
	flTankThrow[2] = GetConVarFloat(hSmasherThrow);
	flTankThrow[3] = GetConVarFloat(hWarpThrow);
	flTankThrow[4] = GetConVarFloat(hMeteorThrow);
	if(L4D2Version)
	{
		flTankThrow[5] = GetConVarFloat(hAcidThrow);
	}
	flTankThrow[6] = GetConVarFloat(hHealthThrow);
	flTankThrow[7] = GetConVarFloat(hFireThrow);
	if(L4D2Version)
	{
		flTankThrow[8] = GetConVarFloat(hIceThrow);
		flTankThrow[9] = GetConVarFloat(hJockeyThrow);
	}
	flTankThrow[10] = GetConVarFloat(hHunterThrow);
	flTankThrow[11] = GetConVarFloat(hSmokerThrow);
	flTankThrow[12] = GetConVarFloat(hBoomerThrow);
	if(L4D2Version)
	{
		flTankThrow[13] = GetConVarFloat(hChargerThrow);
		flTankThrow[14] = GetConVarFloat(hGhostThrow);
	}
	flTankThrow[15] = GetConVarFloat(hShockThrow);
	flTankThrow[16] = GetConVarFloat(hWitchThrow);
	flTankThrow[17] = GetConVarFloat(hShieldThrow);
	flTankThrow[18] = GetConVarFloat(hCobaltThrow);
	flTankThrow[19] = GetConVarFloat(hJumperThrow);
	flTankThrow[20] = GetConVarFloat(hGravityThrow);
	flTankThrow[21] = GetConVarFloat(hFlashThrow);
	flTankThrow[22] = GetConVarFloat(hReverseFlashThrow);
	flTankThrow[23] = GetConVarFloat(hArmageddonThrow);
	if(L4D2Version)
	{
		flTankThrow[24] = GetConVarFloat(hHallucinationThrow);
	}
	flTankThrow[25] = GetConVarFloat(hMinionThrow);
	flTankThrow[26] = GetConVarFloat(hBitchThrow);
	flTankThrow[27] = GetConVarFloat(hTrapThrow);
	flTankThrow[28] = GetConVarFloat(hDistractionThrow);
	flTankThrow[29] = GetConVarFloat(hFeedbackThrow);
	flTankThrow[30] = GetConVarFloat(hPsychoticThrow);
	if(L4D2Version)
	{
		flTankThrow[31] = GetConVarFloat(hSpitterThrow);
	}
	flTankThrow[32] = GetConVarFloat(hGoliathThrow);
	flTankThrow[33] = GetConVarFloat(hPsykotikThrow);
	flTankThrow[34] = GetConVarFloat(hSpykotikThrow);
	if(L4D2Version)
	{
		//Meme Tank
		flTankThrow[35] = GetConVarFloat(hMemeThrow);

		//Boss Tank
		flTankThrow[36] = GetConVarFloat(hBossThrow);
	}
	flTankThrow[37] = GetConVarFloat(hSpypsyThrow);
	if(L4D2Version)
	{
		flTankThrow[38] = GetConVarFloat(hSipowThrow);
		flTankThrow[39] = GetConVarFloat(hPoltergeistThrow);
	}
	flTankThrow[40] = GetConVarFloat(hMirageThrow);

	bTankFireImmunity[0] = GetConVarBool(hDefaultFireImmunity);
	if(L4D2Version)
	{
		bTankFireImmunity[1] = GetConVarBool(hSpawnFireImmunity);
	}
	bTankFireImmunity[2] = GetConVarBool(hSmasherFireImmunity);
	bTankFireImmunity[3] = GetConVarBool(hWarpFireImmunity);
	bTankFireImmunity[4] = GetConVarBool(hMeteorFireImmunity);
	if(L4D2Version)
	{
		bTankFireImmunity[5] = GetConVarBool(hAcidFireImmunity);
	}
	bTankFireImmunity[6] = GetConVarBool(hHealthFireImmunity);
	bTankFireImmunity[7] = GetConVarBool(hFireFireImmunity);
	if(L4D2Version)
	{
		bTankFireImmunity[8] = GetConVarBool(hIceFireImmunity);
		bTankFireImmunity[9] = GetConVarBool(hJockeyFireImmunity);
	}
	bTankFireImmunity[10] = GetConVarBool(hHunterFireImmunity);
	bTankFireImmunity[11] = GetConVarBool(hSmokerFireImmunity);
	bTankFireImmunity[12] = GetConVarBool(hBoomerFireImmunity);
	if(L4D2Version)
	{
		bTankFireImmunity[13] = GetConVarBool(hChargerFireImmunity);
		bTankFireImmunity[14] = GetConVarBool(hGhostFireImmunity);
	}
	bTankFireImmunity[15] = GetConVarBool(hShockFireImmunity);
	bTankFireImmunity[16] = GetConVarBool(hWitchFireImmunity);
	bTankFireImmunity[17] = GetConVarBool(hShieldFireImmunity);
	bTankFireImmunity[18] = GetConVarBool(hCobaltFireImmunity);
	bTankFireImmunity[19] = GetConVarBool(hJumperFireImmunity);
	bTankFireImmunity[20] = GetConVarBool(hGravityFireImmunity);
	bTankFireImmunity[21] = GetConVarBool(hFlashFireImmunity);
	bTankFireImmunity[22] = GetConVarBool(hReverseFlashFireImmunity);
	bTankFireImmunity[23] = GetConVarBool(hArmageddonFireImmunity);
	if(L4D2Version)
	{
		bTankFireImmunity[24] = GetConVarBool(hHallucinationFireImmunity);
	}
	bTankFireImmunity[25] = GetConVarBool(hMinionFireImmunity);
	bTankFireImmunity[26] = GetConVarBool(hBitchFireImmunity);
	bTankFireImmunity[27] = GetConVarBool(hTrapFireImmunity);
	bTankFireImmunity[28] = GetConVarBool(hDistractionFireImmunity);
	bTankFireImmunity[29] = GetConVarBool(hFeedbackFireImmunity);
	bTankFireImmunity[30] = GetConVarBool(hPsychoticFireImmunity);
	if(L4D2Version)
	{
		bTankFireImmunity[31] = GetConVarBool(hSpitterFireImmunity);
	}
	bTankFireImmunity[32] = GetConVarBool(hGoliathFireImmunity);
	bTankFireImmunity[33] = GetConVarBool(hPsykotikFireImmunity);
	bTankFireImmunity[34] = GetConVarBool(hSpykotikFireImmunity);
	if(L4D2Version)
	{
		//Meme Tank
		bTankFireImmunity[35] = GetConVarBool(hMemeFireImmunity);

		//Boss Tank
		bTankFireImmunity[36] = GetConVarBool(hBossFireImmunity);
	}
	bTankFireImmunity[37] = GetConVarBool(hSpypsyFireImmunity);
	if(L4D2Version)
	{
		bTankFireImmunity[38] = GetConVarBool(hSipowFireImmunity);
		bTankFireImmunity[39] = GetConVarBool(hPoltergeistFireImmunity);
	}
	bTankFireImmunity[40] = GetConVarBool(hMirageFireImmunity);

	if(L4D2Version)
	{
		iSpawnCommonAmount = GetConVarInt(hSpawnCommonAmount);
		iSpawnCommonInterval = GetConVarInt(hSpawnCommonInterval);
	}
	iSmasherMaimDamage = GetConVarInt(hSmasherMaimDamage);
	iSmasherCrushDamage = GetConVarInt(hSmasherCrushDamage);
	bSmasherRemoveBody = GetConVarBool(hSmasherRemoveBody);
	iArmageddonMaimDamage = GetConVarInt(hArmageddonMaimDamage);
	iArmageddonCrushDamage = GetConVarInt(hArmageddonCrushDamage);
	bArmageddonRemoveBody = GetConVarBool(hArmageddonRemoveBody);
	iTrapMaimDamage = GetConVarInt(hTrapMaimDamage);
	iTrapCrushDamage = GetConVarInt(hTrapCrushDamage);
	bTrapRemoveBody = GetConVarBool(hTrapRemoveBody);
	iGoliathMaimDamage = GetConVarInt(hGoliathMaimDamage);
	iGoliathCrushDamage = GetConVarInt(hGoliathCrushDamage);
	bGoliathRemoveBody = GetConVarBool(hGoliathRemoveBody);
	iWarpTeleportDelay = GetConVarInt(hWarpTeleportDelay);
	iPsychoticTeleportDelay = GetConVarInt(hPsychoticTeleportDelay);
	iFeedbackTeleportDelay = GetConVarInt(hFeedbackTeleportDelay);
	iDistractionTeleportDelay = GetConVarInt(hDistractionTeleportDelay);
	iFlashTeleportDelay = GetConVarInt(hFlashTeleportDelay);
	iReverseFlashTeleportDelay = GetConVarInt(hReverseFlashTeleportDelay);
	if(L4D2Version)
	{
		iHallucinationTeleportDelay = GetConVarInt(hHallucinationTeleportDelay);
	}
	iPsykotikTeleportDelay = GetConVarInt(hPsykotikTeleportDelay);
	iSpykotikTeleportDelay = GetConVarInt(hSpykotikTeleportDelay);
	iSpypsyTeleportDelay = GetConVarInt(hSpypsyTeleportDelay);
	if(L4D2Version)
	{
		iPoltergeistTeleportDelay = GetConVarInt(hPoltergeistTeleportDelay);
	}
	iMirageTeleportDelay = GetConVarInt(hMirageTeleportDelay);
	iMeteorStormDelay = GetConVarInt(hMeteorStormDelay);
	flMeteorStormDamage = GetConVarFloat(hMeteorStormDamage);
	iPsychoticStormDelay = GetConVarInt(hPsychoticStormDelay);
	flPsychoticStormDamage = GetConVarFloat(hPsychoticStormDamage);
	iArmageddonStormDelay = GetConVarInt(hArmageddonStormDelay);
	flArmageddonStormDamage = GetConVarFloat(hArmageddonStormDamage);
	if(L4D2Version)
	{
		iSipowStormDelay = GetConVarInt(hSipowStormDelay);
		flSipowStormDamage = GetConVarFloat(hSipowStormDamage);
	}
	iHealthHealthCommons = GetConVarInt(hHealthHealthCommons);
	iHealthHealthSpecials = GetConVarInt(hHealthHealthSpecials);
	iHealthHealthTanks = GetConVarInt(hHealthHealthTanks);
	iPsychoticHealthCommons = GetConVarInt(hPsychoticHealthCommons);
	iPsychoticHealthSpecials = GetConVarInt(hPsychoticHealthSpecials);
	iPsychoticHealthTanks = GetConVarInt(hPsychoticHealthTanks);
	iGoliathHealthCommons = GetConVarInt(hGoliathHealthCommons);
	iGoliathHealthSpecials = GetConVarInt(hGoliathHealthSpecials);
	iGoliathHealthTanks = GetConVarInt(hGoliathHealthTanks);
	iPsykotikHealthCommons = GetConVarInt(hPsykotikHealthCommons);
	iPsykotikHealthSpecials = GetConVarInt(hPsykotikHealthSpecials);
	iPsykotikHealthTanks = GetConVarInt(hPsykotikHealthTanks);
	if(L4D2Version)
	{
		bGhostDisarm = GetConVarBool(hGhostDisarm);
		bHallucinationDisarm = GetConVarBool(hHallucinationDisarm);
		bPoltergeistDisarm = GetConVarBool(hPoltergeistDisarm);
	}
	iShockStunDamage = GetConVarInt(hShockStunDamage);
	flShockStunMovement = GetConVarFloat(hShockStunMovement);
	iFeedbackStunDamage = GetConVarInt(hFeedbackStunDamage);
	flFeedbackStunMovement = GetConVarFloat(hFeedbackStunMovement);
	iWitchMaxWitches = GetConVarInt(hWitchMaxWitches);
	flShieldShieldsDownInterval = GetConVarFloat(hShieldShieldsDownInterval);
	flPsychoticShieldsDownInterval = GetConVarFloat(hPsychoticShieldsDownInterval);
	flGoliathShieldsDownInterval = GetConVarFloat(hGoliathShieldsDownInterval);
	flCobaltSpecialSpeed = GetConVarFloat(hCobaltSpecialSpeed);
	flFlashSpecialSpeed = GetConVarFloat(hFlashSpecialSpeed);
	flReverseFlashSpecialSpeed = GetConVarFloat(hReverseFlashSpecialSpeed);
	flPsykotikSpecialSpeed = GetConVarFloat(hPsykotikSpecialSpeed);
	flSpykotikSpecialSpeed = GetConVarFloat(hSpykotikSpecialSpeed);
	flSpypsySpecialSpeed = GetConVarFloat(hSpypsySpecialSpeed);
	if(L4D2Version)
	{
		flPoltergeistSpecialSpeed = GetConVarFloat(hPoltergeistSpecialSpeed);
	}
	flMirageSpecialSpeed = GetConVarFloat(hMirageSpecialSpeed);
	iJumperJumpDelay = GetConVarInt(hJumperJumpDelay);
	iPsychoticJumpDelay = GetConVarInt(hPsychoticJumpDelay);
	iDistractionJumpDelay = GetConVarInt(hDistractionJumpDelay);
	flGravityPullForce = GetConVarFloat(hGravityPullForce);
	flArmageddonPullForce = GetConVarFloat(hArmageddonPullForce);
	flFeedbackPushForce = GetConVarFloat(hFeedbackPushForce);
	if(L4D2Version)
	{
		//Meme Tank
		iMemeCommonAmount = GetConVarInt(hMemeCommonAmount);
		iMemeCommonInterval = GetConVarInt(hMemeCommonInterval);
		iMemeMaimDamage = GetConVarInt(hMemeMaimDamage);
		iMemeCrushDamage = GetConVarInt(hMemeCrushDamage);
		bMemeRemoveBody = GetConVarBool(hMemeRemoveBody);
		iMemeTeleportDelay = GetConVarInt(hMemeTeleportDelay);
		iMemeStormDelay = GetConVarInt(hMemeStormDelay);
		flMemeStormDamage = GetConVarFloat(hMemeStormDamage);
		bMemeDisarm = GetConVarBool(hMemeDisarm);
		iMemeMaxWitches = GetConVarInt(hMemeMaxWitches);
		flMemeSpecialSpeed = GetConVarFloat(hMemeSpecialSpeed);
		iMemeJumpDelay = GetConVarInt(hMemeJumpDelay);
		flMemePullForce = GetConVarFloat(hMemePullForce);

		//Boss Tank
		iBossMaimDamage = GetConVarInt(hBossMaimDamage);
		iBossCrushDamage = GetConVarInt(hBossCrushDamage);
		bBossRemoveBody = GetConVarBool(hBossRemoveBody);
		iBossTeleportDelay = GetConVarInt(hBossTeleportDelay);
		iBossStormDelay = GetConVarInt(hBossStormDelay);
		flBossStormDamage = GetConVarFloat(hBossStormDamage);
		iBossHealthCommons = GetConVarInt(hBossHealthCommons);
		iBossHealthSpecials = GetConVarInt(hBossHealthSpecials);
		iBossHealthTanks = GetConVarInt(hBossHealthTanks);
		bBossDisarm = GetConVarBool(hBossDisarm);
		iBossMaxWitches = GetConVarInt(hBossMaxWitches);
		flBossShieldsDownInterval = GetConVarFloat(hBossShieldsDownInterval);
		flBossSpecialSpeed = GetConVarFloat(hBossSpecialSpeed);
		iBossJumpDelay = GetConVarInt(hBossJumpDelay);
		flBossPullForce = GetConVarFloat(hBossPullForce);
	}
}
public OnMapStart()
{
	PrecacheParticle(PARTICLE_SPAWN);
	PrecacheParticle(PARTICLE_FIRE);
	PrecacheParticle(PARTICLE_WARP);
	PrecacheParticle(PARTICLE_ICE);
	PrecacheParticle(PARTICLE_SPIT);
	PrecacheParticle(PARTICLE_SPITPROJ);
	PrecacheParticle(PARTICLE_ELEC);
	PrecacheParticle(PARTICLE_BLOOD);
	PrecacheParticle(PARTICLE_EXPLODE);
	PrecacheParticle(PARTICLE_METEOR);
	CheckModelPreCache("models/props_junk/gascan001a.mdl");
	CheckModelPreCache("models/props_junk/propanecanister001a.mdl");
	CheckModelPreCache("models/infected/witch.mdl");
	CheckModelPreCache("models/infected/witch_bride.mdl");
	CheckModelPreCache("models/props_vehicles/tire001c_car.mdl");
	CheckModelPreCache("models/props_unique/airport/atlas_break_ball.mdl");
	CheckSoundPreCache("ambient/fire/gascan_ignite1.wav");
	CheckSoundPreCache("player/charger/hit/charger_smash_02.wav");
	CheckSoundPreCache("npc/infected/action/die/male/death_42.wav");
	CheckSoundPreCache("npc/infected/action/die/male/death_43.wav");
	CheckSoundPreCache("ambient/energy/zap1.wav");
	CheckSoundPreCache("ambient/energy/zap5.wav");
	CheckSoundPreCache("ambient/energy/zap7.wav");
	CheckSoundPreCache("player/spitter/voice/warn/spitter_spit_02.wav");
	CheckSoundPreCache("player/tank/voice/growl/tank_climb_01.wav");
	CheckSoundPreCache("player/tank/voice/growl/tank_climb_02.wav");
	CheckSoundPreCache("player/tank/voice/growl/tank_climb_03.wav");
	CheckSoundPreCache("player/tank/voice/growl/tank_climb_04.wav");
}
stock CheckModelPreCache(const String:Modelfile[])
{
	if(!IsModelPrecached(Modelfile))
	{
		PrecacheModel(Modelfile, true);
		PrintToServer("[Super Tanks]Precaching Model:%s",Modelfile);
	}
}
stock CheckSoundPreCache(const String:Soundfile[])
{
	PrecacheSound(Soundfile, true);
	PrintToServer("[Super Tanks]Precaching Sound:%s",Soundfile);
}
public OnClientPostAdminCheck(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnPlayerTakeDamage);
	TankAbility[client] = 0;
	Rock[client] = 0;
	ShieldsUp[client] = 0;
	PlayerSpeed[client] = 0;
}
public Action:Ability_Use(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event,"userid"));

	if(bSuperTanksEnabled)
	{
		if(client > 0)
		{
			if(IsClientInGame(client))
			{
				if(IsTank(client))
				{
					new index = GetSuperTankByRenderColor(GetEntityRenderColor(client));
					if(index >= 0 && index <= 40)
					{
						if(index != 0 || (index == 0 && bDefaultOverride))
						{
							ResetInfectedAbility(client, flTankThrow[index]);
						}
					}
				}
			}
		}
	}
}
public Action:Finale_Escape_Start(Handle:event, String:event_name[], bool:dontBroadcast)
{
	iTankWave = 3;
}
public Action:Finale_Start(Handle:event, String:event_name[], bool:dontBroadcast)
{
	iTankWave = 1;
}
public Action:Finale_Vehicle_Leaving(Handle:event, String:event_name[], bool:dontBroadcast)
{
	iTankWave = 4;
}
public Action:Finale_Vehicle_Ready(Handle:event, String:event_name[], bool:dontBroadcast)
{
	iTankWave = 3;
}
public Action:Player_Death(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(bSuperTanksEnabled)
	{
		if(client > 0 && IsClientInGame(client))
		{
			SetEntityGravity(client, 1.0);
			if(L4D2Version)
			{
				SetEntProp(client, Prop_Send, "m_iGlowType", 0);
				SetEntProp(client, Prop_Send, "m_glowColorOverride", 0);
			}
			if(IsTank(client))
			{
				ExecTankDeath(client);		
			}	
			else if(GetClientTeam(client) == 2)
			{
				new entity = -1;
				while ((entity = FindEntityByClassname(entity, "survivor_death_model")) != INVALID_ENT_REFERENCE)
				{
					new Float:Origin[3], Float:EOrigin[3];
					GetClientAbsOrigin(client, Origin);
					GetEntPropVector(entity, Prop_Send, "m_vecOrigin", EOrigin);
					if(Origin[0] == EOrigin[0] && Origin[1] == EOrigin[1] && Origin[2] == EOrigin[2])
					{
						SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
					}
				}
			}
		}
	}
}
public Action:Round_End(Handle:event, String:event_name[], bool:dontBroadcast)
{
	if(bSuperTanksEnabled)
	{
		for(new i=1;i<=MaxClients;i++)
		{
			if(IsClientInGame(i) && IsPlayerAlive(i) && IsFakeClient(i) && GetClientTeam(i) == 3 && !IsTank(i))
			{
				if(CountInfectedAll() > 40)
				{
					KickClient(i);
				}
			}
		}
	}
}
public Action:Round_Start(Handle:event, String:event_name[], bool:dontBroadcast)
{
	if(bSuperTanksEnabled)
	{
		iTick = 0;
		iTankWave = 0;
		iNumTanks = 0;

		new flags = GetConVarFlags(FindConVar("z_max_player_zombies"));
		SetConVarBounds(FindConVar("z_max_player_zombies"), ConVarBound_Upper, false);
		SetConVarFlags(FindConVar("z_max_player_zombies"), flags & ~FCVAR_NOTIFY);
		SetConVarInt(FindConVar("z_hunter_limit"), 32);
		if(L4D2Version)
		{
			SetConVarInt(FindConVar("z_smoker_limit"), 32);
			SetConVarInt(FindConVar("z_boomer_limit"), 32);
			SetConVarInt(FindConVar("z_jockey_limit"), 32);
			SetConVarInt(FindConVar("z_charger_limit"), 32);
			SetConVarInt(FindConVar("z_spitter_limit"), 32);
		}
		else
		{
			SetConVarInt(FindConVar("z_gas_limit"), 32);
			SetConVarInt(FindConVar("z_exploding_limit"), 32);
		}
		for(new client=1; client<=MaxClients; client++)
		{
			TankAbility[client] = 0;
			Rock[client] = 0;
			ShieldsUp[client] = 0;
			PlayerSpeed[client] = 0;
		}
	}
}
public Action:Tank_Spawn(Handle:event, String:event_name[], bool:dontBroadcast)
{
	new client =  GetClientOfUserId(GetEventInt(event, "userid"));

	CountTanks();

	if(bSuperTanksEnabled)
	{
		if(client > 0 && IsClientInGame(client))
		{
			TankAlive[client] = 1;
			TankAbility[client] = 0;
			CreateTimer(0.1, TankSpawnTimer, client, TIMER_FLAG_NO_MAPCHANGE);
			if(!bFinaleOnly || (bFinaleOnly && iTankWave > 0))
			{
				RandomizeTank(client);
				switch(iTankWave)
				{
					case 1:
					{
						if(iNumTanks < iWave1Cvar)
						{
							CreateTimer(5.0, SpawnTankTimer, _, TIMER_FLAG_NO_MAPCHANGE);
						}
						else if(iNumTanks > iWave1Cvar)
						{
							if(IsFakeClient(client))
							{
								KickClient(client);
							}
						}
					}
					case 2:
					{
						if(iNumTanks < iWave2Cvar)
						{
							CreateTimer(5.0, SpawnTankTimer, _, TIMER_FLAG_NO_MAPCHANGE);
						}
						else if(iNumTanks > iWave2Cvar)
						{
							if(IsFakeClient(client))
							{
								KickClient(client);
							}
						}
					}
					case 3:
					{
						if(iNumTanks < iWave3Cvar)
						{
							CreateTimer(5.0, SpawnTankTimer, _, TIMER_FLAG_NO_MAPCHANGE);
						}
						else if(iNumTanks > iWave3Cvar)
						{
							if(IsFakeClient(client))
							{
								KickClient(client);
							}
						}
					}
				}
			}
		}
	}
}
//=============================
// TANK CONTROLLER
//=============================
public TankController()
{
	CountTanks();
	if(iNumTanks > 0)
	{
		for(new i=1; i<=MaxClients; i++)
		{
			if(IsTank(i))
			{
				new index = GetSuperTankByRenderColor(GetEntityRenderColor(i));
				if(index >= 0 && index <= 40)
				{
					if(index != 0 || (index == 0 && bDefaultOverride))
					{
						SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", flTankSpeed[index]);
						switch(index)
						{
							case 1:
							{
								iTick += 1;
								if(iTick >= iSpawnCommonInterval)
								{
									for(new count=1; count<=iSpawnCommonAmount; count++)
									{
										CheatCommand(i, "z_spawn_old", "zombie area");
									}
									iTick = 0;
								}
							}
							case 3:
							{
								TeleportTank(i);
							}
							case 4:
							{
								if(TankAbility[i] == 0)
								{
									new random = GetRandomInt(1,iMeteorStormDelay);
									if(random == 1)
									{
										StartMeteorFall(i);
									}
								}
							}
							case 6:
							{
								HealthTank(i);
							}
							case 7:
							{
								IgniteEntity(i, 1.0);
							}
							case 14:
							{
								InfectedCloak(i);
								if(CountSurvRange(i) == CountSurvivorsAliveAll())
								{
									SetEntityRenderMode(i, RenderMode:3);
									SetEntityRenderColor(i, 100, 100, 100, 50);
									EmitSoundToAll("npc/infected/action/die/male/death_43.wav", i);
								}
								else
								{
									SetEntityRenderMode(i, RenderMode:3);
									SetEntityRenderColor(i, 100, 100, 100, 150);
									EmitSoundToAll("npc/infected/action/die/male/death_42.wav", i);
								}
							}
							case 16:
							{
								SpawnWitch(i);
							}
							case 17:
							{
								if(ShieldsUp[i] > 0)
								{
									new glowcolor = RGB_TO_INT(120, 90, 150);
									if(L4D2Version)
									{
										SetEntProp(i, Prop_Send, "m_iGlowType", 2);
										SetEntProp(i, Prop_Send, "m_bFlashing", 2);
										SetEntProp(i, Prop_Send, "m_glowColorOverride", glowcolor);
									}
								}
								else
								{
									new glowcolor = RGB_TO_INT(120, 90, 150);
									if(L4D2Version)
									{
										SetEntProp(i, Prop_Send, "m_iGlowType", 3);
										SetEntProp(i, Prop_Send, "m_bFlashing", 0);
										SetEntProp(i, Prop_Send, "m_glowColorOverride", glowcolor);
									}
								}
							}
							case 18:
							{
								if(TankAbility[i] == 0)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
									new random = GetRandomInt(1,9);
									if(random == 1)
									{
										TankAbility[i] = 1;
										CreateTimer(0.3, BlurEffect, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
									}
								}
								else if(TankAbility[i] == 1)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", flCobaltSpecialSpeed);
								}
							}
							case 20:
							{
								SetEntityGravity(i, 0.5);
							}
							case 21:
							{
								TeleportTank2(i);
								if(TankAbility[i] == 0)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
									new random = GetRandomInt(1,9);
									if(random == 1)
									{
										TankAbility[i] = 1;
										CreateTimer(0.3, BlurEffect2, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
									}
								}
								else if(TankAbility[i] == 1)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", flFlashSpecialSpeed);
								}
							}
							case 22:
							{
								TeleportTank3(i);
								if(TankAbility[i] == 0)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
									new random = GetRandomInt(1,9);
									if(random == 1)
									{
										TankAbility[i] = 1;
										CreateTimer(0.3, BlurEffect3, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
									}
								}
								else if(TankAbility[i] == 1)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", flReverseFlashSpecialSpeed);
								}
							}
							case 23:
							{
								SetEntityGravity(i, 0.5);
								if(TankAbility[i] == 0)
								{
									new random = GetRandomInt(1,iArmageddonStormDelay);
									if(random == 1)
									{
										StartArmageddonFall(i);
									}
								}

							}
							case 24:
							{
								TeleportTank4(i);
								InfectedCloak2(i);
								if(CountSurvRange(i) == CountSurvivorsAliveAll())
								{
									SetEntityRenderMode(i, RenderMode:3);
									SetEntityRenderColor(i, 50, 50, 50, 50);
									EmitSoundToAll("npc/infected/action/die/male/death_43.wav", i);
								}
								else
								{
									SetEntityRenderMode(i, RenderMode:3);
									SetEntityRenderColor(i, 50, 50, 50, 150);
									EmitSoundToAll("npc/infected/action/die/male/death_42.wav", i);
								}
							}
							case 26:
							{
								SetEntityGravity(i, 0.5);
							}
							case 28:
							{
								TeleportTank5(i);
							}
							case 29:
							{
								TeleportTank6(i);
								SetEntityGravity(i, 0.5);
							}
							case 30:
							{
								TeleportTank7(i);
								PsychoticTank(i);
								if(ShieldsUp[i] > 0)
								{
									new glowcolor = RGB_TO_INT(50, 25, 80);
									if(L4D2Version)
									{
										SetEntProp(i, Prop_Send, "m_iGlowType", 2);
										SetEntProp(i, Prop_Send, "m_bFlashing", 2);
										SetEntProp(i, Prop_Send, "m_glowColorOverride", glowcolor);
									}
								}
								else
								{
									new glowcolor = RGB_TO_INT(50, 25, 80);
									if(L4D2Version)
									{
										SetEntProp(i, Prop_Send, "m_iGlowType", 3);
										SetEntProp(i, Prop_Send, "m_bFlashing", 0);
										SetEntProp(i, Prop_Send, "m_glowColorOverride", glowcolor);
									}
								}
								if(TankAbility[i] == 0)
								{
									new random = GetRandomInt(1,iPsychoticStormDelay);
									if(random == 1)
									{
										StartPsychoticFall(i);
									}
								}
							}
							case 32:
							{
								GoliathTank(i);
								if(ShieldsUp[i] > 0)
								{
									new glowcolor = RGB_TO_INT(90, 85, 165);
									if(L4D2Version)
									{
										SetEntProp(i, Prop_Send, "m_iGlowType", 2);
										SetEntProp(i, Prop_Send, "m_bFlashing", 2);
										SetEntProp(i, Prop_Send, "m_glowColorOverride", glowcolor);
									}
								}
								else
								{
									new glowcolor = RGB_TO_INT(90, 85, 165);
									if(L4D2Version)
									{
										SetEntProp(i, Prop_Send, "m_iGlowType", 3);
										SetEntProp(i, Prop_Send, "m_bFlashing", 0);
										SetEntProp(i, Prop_Send, "m_glowColorOverride", glowcolor);
									}
								}
							}
							case 33:
							{
								PsykotikTank(i);
								TeleportTank8(i);
								if(TankAbility[i] == 0)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
									new random = GetRandomInt(1,9);
									if(random == 1)
									{
										TankAbility[i] = 1;
										CreateTimer(0.3, BlurEffect4, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
									}
								}
								else if(TankAbility[i] == 1)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", flPsykotikSpecialSpeed);
								}
							}
							case 34:
							{
								TeleportTank9(i);
								if(TankAbility[i] == 0)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
									new random = GetRandomInt(1,9);
									if(random == 1)
									{
										TankAbility[i] = 1;
										CreateTimer(0.3, BlurEffect5, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
									}
								}
								else if(TankAbility[i] == 1)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", flSpykotikSpecialSpeed);
								}
							}
							//Meme Tank
							case 35:
							{
								TeleportTank10(i);
								SpawnWitch2(i);
								IgniteEntity(i, 1.0);
								SetEntityGravity(i, 0.5);
								iTick += 1;
								if(iTick >= iMemeCommonInterval)
								{
									for(new count=1; count<=iMemeCommonAmount; count++)
									{
										CheatCommand(i, "z_spawn_old", "zombie area");
									}
									iTick = 0;
								}
								if(TankAbility[i] == 0)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
									new random = GetRandomInt(1,9);
									new random2 = GetRandomInt(1,iMemeStormDelay);
									if(random == 1)
									{
										TankAbility[i] = 1;
										CreateTimer(0.3, BlurEffect6, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
									}
									if(random2 == 1)
									{
										StartMemeFall(i);
									}
								}
								else if(TankAbility[i] == 1)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", flMemeSpecialSpeed);
								}
								InfectedCloak3(i);
								if(CountSurvRange(i) == CountSurvivorsAliveAll())
								{
									SetEntityRenderMode(i, RenderMode:3);
									SetEntityRenderColor(i, 0, 255, 0, 50);
									EmitSoundToAll("npc/infected/action/die/male/death_43.wav", i);
								}
								else
								{
									SetEntityRenderMode(i, RenderMode:3);
									SetEntityRenderColor(i, 0, 255, 0, 150);
									EmitSoundToAll("npc/infected/action/die/male/death_42.wav", i);
								}
							}
							//Boss Tank
							case 36:
							{
								TeleportTank11(i);
								BossTank(i);
								SpawnWitch3(i);
								IgniteEntity(i, 1.0);
								SetEntityGravity(i, 0.5);
								if(TankAbility[i] == 0)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
									new random = GetRandomInt(1,9);
									new random2 = GetRandomInt(1,iBossStormDelay);
									if(random == 1)
									{
										TankAbility[i] = 1;
										CreateTimer(0.3, BlurEffect7, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
									}
									if(random2 == 1)
									{
										StartBossFall(i);
									}
								}
								else if(TankAbility[i] == 1)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", flBossSpecialSpeed);
								}
								InfectedCloak4(i);
								if(CountSurvRange(i) == CountSurvivorsAliveAll())
								{
									SetEntityRenderMode(i, RenderMode:3);
									SetEntityRenderColor(i, 0, 0, 50, 50);
									EmitSoundToAll("npc/infected/action/die/male/death_43.wav", i);
								}
								else
								{
									SetEntityRenderMode(i, RenderMode:3);
									SetEntityRenderColor(i, 0, 0, 50, 150);
									EmitSoundToAll("npc/infected/action/die/male/death_42.wav", i);
								}
								if(ShieldsUp[i] > 0)
								{
									new glowcolor = RGB_TO_INT(0, 175, 255);
									SetEntProp(i, Prop_Send, "m_iGlowType", 2);
									SetEntProp(i, Prop_Send, "m_bFlashing", 2);
									SetEntProp(i, Prop_Send, "m_glowColorOverride", glowcolor);
								}
								else
								{
									new glowcolor = RGB_TO_INT(0, 175, 255);
									SetEntProp(i, Prop_Send, "m_iGlowType", 3);
									SetEntProp(i, Prop_Send, "m_bFlashing", 0);
									SetEntProp(i, Prop_Send, "m_glowColorOverride", glowcolor);
								}
							}
							case 37:
							{
								TeleportTank12(i);
								if(TankAbility[i] == 0)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
									new random = GetRandomInt(1,9);
									if(random == 1)
									{
										TankAbility[i] = 1;
										CreateTimer(0.3, BlurEffect8, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
									}
								}
								else if(TankAbility[i] == 1)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", flSpypsySpecialSpeed);
								}
							}
							case 38:
							{
								if(TankAbility[i] == 0)
								{
									new random = GetRandomInt(1,iSipowStormDelay);
									if(random == 1)
									{
										StartSipowFall(i);
									}
								}
							}
							case 39:
							{
								TeleportTank13(i);
								InfectedCloak5(i);
								if(CountSurvRange(i) == CountSurvivorsAliveAll())
								{
									SetEntityRenderMode(i, RenderMode:3);
									SetEntityRenderColor(i, 100, 50, 50, 50);
									EmitSoundToAll("npc/infected/action/die/male/death_43.wav", i);
								}
								else
								{
									SetEntityRenderMode(i, RenderMode:3);
									SetEntityRenderColor(i, 100, 50, 50, 150);
									EmitSoundToAll("npc/infected/action/die/male/death_42.wav", i);
								}
								if(TankAbility[i] == 0)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
									new random = GetRandomInt(1,9);
									if(random == 1)
									{
										TankAbility[i] = 1;
										CreateTimer(0.3, BlurEffect9, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
									}
								}
								else if(TankAbility[i] == 1)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", flPoltergeistSpecialSpeed);
								}
							}
							case 40:
							{
								TeleportTank14(i);
								if(TankAbility[i] == 0)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
									new random = GetRandomInt(1,9);
									if(random == 1)
									{
										TankAbility[i] = 1;
										CreateTimer(0.3, BlurEffect10, i, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
									}
								}
								else if(TankAbility[i] == 1)
								{
									SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", flMirageSpecialSpeed);
								}
							}
						}
						if(bTankFireImmunity[index])
						{
							if(IsPlayerBurning(i))
							{
								ExtinguishEntity(i);
								SetEntPropFloat(i, Prop_Send, "m_burnPercent", 1.0);
							}
						}
					}
				}	
			}
		}
	}
}
public Action:TankSpawnTimer(Handle:timer, any:client)
{
	if(client > 0)
	{
		if(IsTank(client))
		{
			new index = GetSuperTankByRenderColor(GetEntityRenderColor(client));
			if(index >= 0 && index <= 40)
			{
				if(index != 0 || (index == 0 && bDefaultOverride))
				{
					switch(index)
					{
						case 1:
						{
							CreateTimer(1.2, Timer_AttachSPAWN, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Spawn Tank");
							}
						}
						case 2:
						{
							if(L4D2Version)
							{
								SetEntProp(client, Prop_Send, "m_iGlowType", 3);
								new glowcolor = RGB_TO_INT(50, 50, 50);
								SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
							}
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Smasher Tank");
							}
						}
						case 3:
						{
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Warp Tank");
							}
						}
						case 4:
						{
							CreateTimer(0.1, MeteorTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(6.0, Timer_AttachMETEOR, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Meteor Tank");
							}
						}
						case 5:
						{
							CreateTimer(2.0, Timer_AttachSPIT, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Acid Tank");
							}
						}
						case 6:
						{
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Health Tank");
							}
						}
						case 7:
						{
							CreateTimer(0.8, Timer_AttachFIRE,client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Fire Tank");
							}
						}
						case 8:
						{
							CreateTimer(2.0, Timer_AttachICE, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Ice Tank");
							}
						}
						case 9:
						{
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Jockey Tank");
							}
						}
						case 10:
						{
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Hunter Tank");
							}
						}
						case 11:
						{
							CreateTimer(1.2, Timer_AttachSMOKE, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Smoker Tank");
							}
						}
						case 12:
						{
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Boomer Tank");
							}
						}
						case 13:
						{
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Charger Tank");
							}
						}
						case 14:
						{
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Ghost Tank");
							}
						}
						case 15:
						{
							CreateTimer(0.8, Timer_AttachELEC, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Shock Tank");
							}
						}
						case 16:
						{
							CreateTimer(2.0, Timer_AttachBLOOD, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Witch Tank");
							}
						}
						case 17:
						{
							if(ShieldsUp[client] == 0)
							{
								ActivateShield(client);
							}
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Shield Tank");
							}
						}
						case 18:
						{
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Cobalt Tank");
							}
						}
						case 19:
						{
							CreateTimer(0.1, JumperTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(1.0, JumpTimer, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Jumper Tank");
							}
						}
						case 20:
						{
							CreateTimer(0.1, GravityTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Gravity Tank");
							}
						}
						case 21:
						{
							if(L4D2Version)
							{
								SetEntProp(client, Prop_Send, "m_iGlowType", 3);
								new glowcolor = RGB_TO_INT(255, 255, 0);
								SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
							}
							CreateTimer(0.1, FlashTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, FlashTankTimer2, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.8, Timer_AttachELEC2, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Flash Tank");
							}
						}
						case 22:
						{
							if(L4D2Version)
							{
								SetEntProp(client, Prop_Send, "m_iGlowType", 3);
								new glowcolor = RGB_TO_INT(255, 0, 0);
								SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
							}
							CreateTimer(0.1, ReverseFlashTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, ReverseFlashTankTimer2, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.8, Timer_AttachELEC3, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Reverse Flash Tank");
							}
						}
						case 23:
						{
							if(L4D2Version)
							{
								SetEntProp(client, Prop_Send, "m_iGlowType", 3);
								new glowcolor = RGB_TO_INT(150, 0, 0);
								SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
							}
							CreateTimer(0.1, ArmageddonTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(6.0, Timer_AttachARMAGEDDON, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, ArmageddonTankTimer2, client, TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Armageddon Tank");
							}
						}
						case 24:
						{
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Hallucination Tank");
							}
						}
						case 25:
						{
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Minion Tank");
							}
						}
						case 26:
						{
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Bitch Tank");
							}
						}
						case 27:
						{
							CreateTimer(0.1, TrapTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, TrapTankTimer2, client, TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Trap Tank");
							}
						}
						case 28:
						{
							CreateTimer(1.0, DistractionTimer, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Distraction Tank");
							}
						}
						case 29:
						{
							CreateTimer(0.1, FeedbackTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.8, Timer_AttachELEC4, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Feedback Tank");
							}
						}
						case 30:
						{
							CreateTimer(0.1, PsychoticTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, PsychoticTankTimer2, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, PsychoticTankTimer3, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(1.0, PsychoticTimer, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(6.0, Timer_AttachPSYCHOTIC, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.8, Timer_AttachELEC5, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(ShieldsUp[client] == 0)
							{
								ActivateShield2(client);
							}
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Psychotic Tank");
							}
						}
						case 31:
						{
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Spitter Tank");
							}
						}
						case 32:
						{
							CreateTimer(0.1, GoliathTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							if(L4D2Version)
							{
								SetEntProp(client, Prop_Send, "m_iGlowType", 3);
								new glowcolor = RGB_TO_INT(90, 85, 165);
								SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
							}
							if(ShieldsUp[client] == 0)
							{
								ActivateShield3(client);
							}
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Goliath Tank");
							}
						}
						case 33:
						{
							if(L4D2Version)
							{
								SetEntProp(client, Prop_Send, "m_iGlowType", 3);
								new glowcolor = RGB_TO_INT(255, 0, 0);
								SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
							}
							CreateTimer(0.1, PsykotikTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, PsykotikTankTimer2, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.8, Timer_AttachELEC6, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Psykotik Tank");
							}
						}
						case 34:
						{
							if(L4D2Version)
							{
								SetEntProp(client, Prop_Send, "m_iGlowType", 3);
								new glowcolor = RGB_TO_INT(150, 0, 255);
								SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
							}
							CreateTimer(0.1, SpykotikTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, SpykotikTankTimer2, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.8, Timer_AttachELEC7, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Spykotik Tank");
							}
						}
						//Meme Tank
						case 35:
						{
							CreateTimer(0.1, MemeTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, MemeTankTimer2, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, MemeTankTimer3, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(1.0, MemeTimer, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(1.2, Timer_AttachMEME, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(6.0, Timer_AttachMEME2, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(2.0, Timer_AttachICE2, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.8, Timer_AttachFIRE2,client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(2.0, Timer_AttachBLOOD2, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.8, Timer_AttachELEC8, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(L4D2Version)
							{
								SetEntProp(client, Prop_Send, "m_iGlowType", 3);
								new glowcolor = RGB_TO_INT(255, 0, 255);
								SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
							}
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Meme Tank");
							}
						}
						//Boss Tank
						case 36:
						{
							CreateTimer(0.1, BossTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, BossTankTimer2, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, BossTankTimer3, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(1.0, BossTimer, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(1.2, Timer_AttachBOSS, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(6.0, Timer_AttachBOSS2, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(2.0, Timer_AttachICE3, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.8, Timer_AttachFIRE3,client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(2.0, Timer_AttachBLOOD3, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.8, Timer_AttachELEC9, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							SetEntProp(client, Prop_Send, "m_iGlowType", 3);
							new glowcolor = RGB_TO_INT(0, 175, 255);
							SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
							if(ShieldsUp[client] == 0)
							{
								ActivateShield4(client);
							}
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Goliath Tank");
							}
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Boss Tank");
							}
						}
						case 37:
						{
							if(L4D2Version)
							{
								SetEntProp(client, Prop_Send, "m_iGlowType", 3);
								new glowcolor = RGB_TO_INT(255, 100, 0);
								SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
							}
							CreateTimer(0.1, SpypsyTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, SpypsyTankTimer2, client, TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Spypsy Tank");
							}
						}
						case 38:
						{
							SetEntProp(client, Prop_Send, "m_iGlowType", 3);
							new glowcolor = RGB_TO_INT(255, 0, 0);
							SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
							CreateTimer(0.1, SipowTankTimer, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(0.1, SipowTankTimer2, client, TIMER_FLAG_NO_MAPCHANGE);
							CreateTimer(6.0, Timer_AttachSIPOW, client, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Sipow Tank");
							}
						}
						case 39:
						{
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Poltergeist Tank");
							}
						}
						case 40:
						{
							if(IsFakeClient(client))
							{
								SetClientInfo(client, "name", "Mirage Tank");
							}
						}
					}
					if(iTankExtraHealth[index] > 0)
					{
						new health = GetEntProp(client, Prop_Send, "m_iHealth");
						new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
						SetEntProp(client, Prop_Send, "m_iMaxHealth", maxhealth + iTankExtraHealth[index]);
						SetEntProp(client, Prop_Send, "m_iHealth", health + iTankExtraHealth[index]);
					}
					ResetInfectedAbility(client, flTankThrow[index]);
				}
			}
		}
	}
}
//=============================
// Speed on Ground and in Water
//=============================
SpeedRebuild(client)
{
	new Float:value;
	new speed = PlayerSpeed[client];
	if(speed > 0)
	{
		value = flShockStunMovement;
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", value);
	}
	else if(speed == 0)
	{
		value = 1.0;
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", value);
		PlayerSpeed[client] -= 1;
	}
}
SpeedRebuild2(client)
{
	new Float:value;
	new speed = PlayerSpeed[client];
	if(speed > 0)
	{
		value = flFeedbackStunMovement;
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", value);
	}
	else if(speed == 0)
	{
		value = 1.0;
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", value);
		PlayerSpeed[client] -= 1;
	}
}
//=============================
// FUNCTIONS
//=============================
public OnEntityCreated(entity, const String:classname[])
{
	if(bSuperTanksEnabled)
	{
		if(StrEqual(classname, "tank_rock", true))
		{
			CreateTimer(0.1, RockThrowTimer, _, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}
public OnEntityDestroyed(entity)
{
	if(!IsServerProcessing()) return;

	if(bSuperTanksEnabled)
	{
		if(entity > 32 && IsValidEntity(entity))
		{
			new String:classname[32];
			GetEdictClassname(entity, classname, sizeof(classname));
			if(StrEqual(classname, "tank_rock", true))
			{
				new color = GetEntityRenderColor(entity);
				switch(color)
				{
					//Fire
					case 12800:
					{
						new prop = CreateEntityByName("prop_physics");
						if(prop > 32 && IsValidEntity(prop))
						{
							new Float:Pos[3];
							GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);
							Pos[2] += 10.0;
							DispatchKeyValue(prop, "model", "models/props_junk/gascan001a.mdl");
							DispatchSpawn(prop);
							SetEntData(prop, GetEntSendPropOffs(prop, "m_CollisionGroup"), 1, 1, true);
							TeleportEntity(prop, Pos, NULL_VECTOR, NULL_VECTOR);
							AcceptEntityInput(prop, "break");
						}
					}
					//Acid
					case 12115128:
					{
						new x = CreateFakeClient("Spitter");
						if(x > 0)
						{
							new Float:Pos[3];
							GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);
							TeleportEntity(x, Pos, NULL_VECTOR, NULL_VECTOR);	
							SDKCallSpitBurst(x);
							KickClient(x);
						}
					}
					//Sipow
					case 0255125:
					{
						new x = CreateFakeClient("Spitter");
						if(x > 0)
						{
							new Float:Pos[3];
							GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);
							TeleportEntity(x, Pos, NULL_VECTOR, NULL_VECTOR);	
							SDKCallSpitBurst(x);
							KickClient(x);
						}
					}
				}
			}
		}
	}
}
stock Pick()
{
    new count, clients[MaxClients];
    for(new i=1; i<= MaxClients; i++)
    {
        if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
            	clients[count++] = i; 
    }
    return clients[GetRandomInt(0,count-1)];
}
stock bool:IsSpecialInfected(client)
{
	if(client > 0 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3)
	{
		decl String:classname[32];
		GetEntityNetClass(client, classname, sizeof(classname));
		if(StrEqual(classname, "Smoker", false) || StrEqual(classname, "Boomer", false) || StrEqual(classname, "Hunter", false) || StrEqual(classname, "Spitter", false) || StrEqual(classname, "Jockey", false) || StrEqual(classname, "Charger", false))
		{
			return true;
		}
	}
	return false;
}
stock bool:IsTank(client)
{
	if(client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 3 && !IsPlayerIncap(client) && TankAlive[client] == 1)
	{
		decl String:classname[32];
		GetEntityNetClass(client, classname, sizeof(classname));
		if(StrEqual(classname, "Tank", false))
		{
			return true;
		}
	}
	return false;
}
stock bool:IsValidClient(client)
{
	if(client > 0 && client <= MaxClients && IsClientInGame(client))
	{
		return true;
	}
	return false;
}
stock bool:IsSurvivor(client)
{
	if(client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2)
	{
		return true;
	}
	return false;
}
bool:IsWitch(i)
{
	if(IsValidEntity(i))
	{
		decl String: classname[32];
		GetEdictClassname(i, classname, sizeof(classname));
		if(StrEqual(classname, "witch"))
			return true;
		return false;
	}
	return false;
}
stock CountTanks()
{
	iNumTanks = 0;
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsTank(i))
		{
			iNumTanks++;
		}
	}
}
public Action:TankLifeCheck(Handle:timer, any:client)
{
	if(IsClientInGame(client) && IsFakeClient(client) && GetClientTeam(client) == 3)
	{
		new lifestate = GetEntData(client, FindSendPropInfo("CTerrorPlayer", "m_lifeState"));
		if(lifestate == 0)
		{
			new bot = CreateFakeClient("Tank");
			if(bot > 0)
			{
				new Float: Origin[3], Float:Angles[3];
				GetClientAbsOrigin(client, Origin);
				GetClientAbsAngles(client, Angles);
				KickClient(client);
				TeleportEntity(bot, Origin, Angles, NULL_VECTOR);
				SpawnInfected(bot, 8, true);
			}
		}	
	}
}
stock RandomizeTank(client)
{
	if(!bDefaultTanks)
	{
		new count;
		new TempArray[40+1];

		for(new index=1; index<=40; index++)
		{
			if(bTankEnabled[index])
			{
				TempArray[count+1] = index;
				count++;	
			}
		}
		if(count > 0)
		{
			new random = GetRandomInt(1,count);
			new tankpick = TempArray[random];
			switch(tankpick)
			{
				case 1:
				{
					//Spawn
      	 				SetEntityRenderColor(client, 75, 95, 105, 255);
				}
				case 2:
				{
					//Smasher
      	 				SetEntityRenderColor(client, 70, 80, 100, 255);
				}
				case 3:
				{
					//Warp
      	 				SetEntityRenderColor(client, 130, 130, 255, 255);
				}
				case 4:
				{
					//Meteor
      	 				SetEntityRenderColor(client, 100, 25, 25, 255);
				}
				case 5:
				{
					//Acid
      	 				SetEntityRenderColor(client, 12, 115, 128, 255);
				}
				case 6:
				{
					//Health
      	 				SetEntityRenderColor(client, 100, 255, 200, 255);
				}
				case 7:
				{
					//Fire
      	 				SetEntityRenderColor(client, 128, 0, 0, 255);
				}
				case 8:
				{
					//Ice
					SetEntityRenderMode(client, RenderMode:3);
      	 				SetEntityRenderColor(client, 0, 100, 170, 200);
				}
				case 9:
				{
					//Jockey
      	 				SetEntityRenderColor(client, 255, 165, 75, 255);
				}
				case 10:
				{
					//Hunter
      	 				SetEntityRenderColor(client, 25, 90, 185, 255);
				}
				case 11:
				{
					//Smoker
      	 				SetEntityRenderColor(client, 120, 85, 120, 255);
				}
				case 12:
				{
					//Boomer
      	 				SetEntityRenderColor(client, 65, 105, 0, 255);
				}
				case 13:
				{
					//Charger
      	 				SetEntityRenderColor(client, 40, 125, 40, 255);
				}
				case 14:
				{
					//Ghost
					SetEntityRenderMode(client, RenderMode:3);
      	 				SetEntityRenderColor(client, 100, 100, 100, 0);
				}
				case 15:
				{
					//Shock
      	 				SetEntityRenderColor(client, 100, 165, 255, 255);
				}
				case 16:
				{
					//Witch
      	 				SetEntityRenderColor(client, 255, 200, 255, 255);
				}
				case 17:
				{
					//Shield
      	 				SetEntityRenderColor(client, 135, 205, 255, 255);
				}
				case 18:
				{
					//Cobalt
      	 				SetEntityRenderColor(client, 0, 105, 255, 255);
				}
				case 19:
				{
					//Jumper
      	 				SetEntityRenderColor(client, 200, 255, 0, 255);
				}
				case 20:
				{
					//Gravity
      	 				SetEntityRenderColor(client, 33, 34, 35, 255);
				}
				case 21:
				{
					//Flash
      	 				SetEntityRenderColor(client, 255, 0, 0, 255);
				}
				case 22:
				{
					//Reverse Flash
      	 				SetEntityRenderColor(client, 255, 255, 0, 255);
				}
				case 23:
				{
					//Armageddon
      	 				SetEntityRenderColor(client, 75, 0, 0, 255);
				}
				case 24:
				{
					//Hallucination
					SetEntityRenderMode(client, RenderMode:3);
      	 				SetEntityRenderColor(client, 50, 50, 50, 0);
				}
				case 25:
				{
					//Minion
      	 				SetEntityRenderColor(client, 225, 225, 225, 255);
				}
				case 26:
				{
					//Bitch
      	 				SetEntityRenderColor(client, 255, 155, 255, 255);
				}
				case 27:
				{
					//Trap
      	 				SetEntityRenderColor(client, 55, 125, 70, 255);
				}
				case 28:
				{
					//Distraction
      	 				SetEntityRenderColor(client, 225, 225, 0, 255);
				}
				case 29:
				{
					//Feedback
      	 				SetEntityRenderColor(client, 90, 60, 90, 255);
				}
				case 30:
				{
					//Psychotic
      	 				SetEntityRenderColor(client, 0, 0, 0, 255);
				}
				case 31:
				{
					//Spitter
      	 				SetEntityRenderColor(client, 75, 255, 75, 255);
				}
				case 32:
				{
					//Goliath
      	 				SetEntityRenderColor(client, 0, 0, 100, 255);
				}
				case 33:
				{
					//Psykotik
      	 				SetEntityRenderColor(client, 1, 1, 1, 255);
				}
				case 34:
				{
					//Spykotik
      	 				SetEntityRenderColor(client, 255, 100, 255, 255);
				}
				case 35:
				{
					//Meme
      	 				SetEntityRenderColor(client, 0, 255, 0, 255);
				}
				case 36:
				{
					//Boss
      	 				SetEntityRenderColor(client, 0, 0, 50, 255);
				}
				case 37:
				{
					//Spypsy
      	 				SetEntityRenderColor(client, 0, 0, 255, 255);
				}
				case 38:
				{
					//Sipow
      	 				SetEntityRenderColor(client, 0, 255, 125, 255);
				}
				case 39:
				{
					//Poltergeist
      	 				SetEntityRenderColor(client, 100, 50, 50, 0);
				}
				case 40:
				{
					//Mirage
      	 				SetEntityRenderColor(client, 25, 40, 25, 255);
				}
			}
		}
	}
}
stock SpawnInfected(client, Class, bool:bAuto=true)
{
	new bool:resetGhostState[MaxClients+1];
	new bool:resetHallucinationState[MaxClients+1];

	//Meme Tank
	new bool:resetMemeState[MaxClients+1];

	//Boss Tank
	new bool:resetBossState[MaxClients+1];
	new bool:resetPoltergeistState[MaxClients+1];
	new bool:resetIsAlive[MaxClients+1];
	new bool:resetLifeState[MaxClients+1];
	ChangeClientTeam(client, 3);
	new String:g_sBossNames[9+1][10]={"","smoker","boomer","hunter","spitter","jockey","charger","witch","tank","survivor"};
	decl String:options[30];
	if(Class < 1 || Class > 8) return false;
	if(GetClientTeam(client) != 3) return false;
	if(!IsClientInGame(client)) return false;
	if(IsPlayerAlive(client)) return false;
	
	for(new i=1; i<=MaxClients; i++)
	{ 
		if(i == client) continue; //dont disable the chosen one
		if(!IsClientInGame(i)) continue; //not ingame? skip
		if(GetClientTeam(i) != 3) continue; //not infected? skip
		if(IsFakeClient(i)) continue; //a bot? skip
		
		if(IsPlayerGhost(i))
		{
			resetGhostState[i] = true;
			SetPlayerGhostStatus(i, false);
			resetIsAlive[i] = true; 
			SetPlayerIsAlive(i, true);
		}
		if(IsPlayerHallucination(i))
		{
			resetHallucinationState[i] = true;
			SetPlayerHallucinationStatus(i, false);
			resetIsAlive[i] = true; 
			SetPlayerIsAlive(i, true);
		}

		//Meme Tank
		if(IsPlayerMeme(i))
		{
			resetMemeState[i] = true;
			SetPlayerMemeStatus(i, false);
			resetIsAlive[i] = true; 
			SetPlayerIsAlive(i, true);
		}

		//Boss Tank
		if(IsPlayerBoss(i))
		{
			resetBossState[i] = true;
			SetPlayerBossStatus(i, false);
			resetIsAlive[i] = true; 
			SetPlayerIsAlive(i, true);
		}
		if(IsPlayerPoltergeist(i))
		{
			resetPoltergeistState[i] = true;
			SetPlayerPoltergeistStatus(i, false);
			resetIsAlive[i] = true; 
			SetPlayerIsAlive(i, true);
		}
		else if(!IsPlayerAlive(i))
		{
			resetLifeState[i] = true;
			SetPlayerLifeState(i, false);
		}
	}
	Format(options,sizeof(options),"%s%s",g_sBossNames[Class],(bAuto?" auto":""));
	if(L4D2Version)
	{
		CheatCommand(client, "z_spawn_old", options);
	}
	else
	{
		CheatCommand(client, "z_spawn", options);
	}
	if(IsFakeClient(client)) KickClient(client);
	// We restore the player's status
	for(new i=1; i<=MaxClients; i++)
	{
		if(resetGhostState[i]) SetPlayerGhostStatus(i, true);
		if(resetHallucinationState[i]) SetPlayerHallucinationStatus(i, true);

		//Meme Tank
		if(resetMemeState[i]) SetPlayerMemeStatus(i, true);

		//Boss Tank
		if(resetBossState[i]) SetPlayerBossStatus(i, true);
		if(resetPoltergeistState[i]) SetPlayerPoltergeistStatus(i, true);
		if(resetIsAlive[i]) SetPlayerIsAlive(i, false);
		if(resetLifeState[i]) SetPlayerLifeState(i, true);
	}

	return true;
}
stock SetPlayerGhostStatus(client, bool:ghost)
{
	if(ghost)
	{	
		SetEntProp(client, Prop_Send, "m_isGhost", 1, 1);
	}
	else
	{
		SetEntProp(client, Prop_Send, "m_isGhost", 0, 1);
	}
}
stock SetPlayerHallucinationStatus(client, bool:hallucination)
{
	if(hallucination)
	{	
		SetEntProp(client, Prop_Send, "m_isGhost", 1, 1);
	}
	else
	{
		SetEntProp(client, Prop_Send, "m_isGhost", 0, 1);
	}
}

//Meme Tank
stock SetPlayerMemeStatus(client, bool:meme)
{
	if(meme)
	{	
		SetEntProp(client, Prop_Send, "m_isGhost", 1, 1);
	}
	else
	{
		SetEntProp(client, Prop_Send, "m_isGhost", 0, 1);
	}
}

//Boss Tank
stock SetPlayerBossStatus(client, bool:boss)
{
	if(boss)
	{	
		SetEntProp(client, Prop_Send, "m_isGhost", 1, 1);
	}
	else
	{
		SetEntProp(client, Prop_Send, "m_isGhost", 0, 1);
	}
}
stock SetPlayerPoltergeistStatus(client, bool:poltergeist)
{
	if(poltergeist)
	{	
		SetEntProp(client, Prop_Send, "m_isGhost", 1, 1);
	}
	else
	{
		SetEntProp(client, Prop_Send, "m_isGhost", 0, 1);
	}
}
stock SetPlayerIsAlive(client, bool:alive)
{
	new offset = FindSendPropInfo("CTransitioningPlayer", "m_isAlive");
	if(alive) SetEntData(client, offset, 1, 1, true);
	else SetEntData(client, offset, 0, 1, true);
}
stock SetPlayerLifeState(client, bool:ready)
{
	if(ready) SetEntProp(client, Prop_Data, "m_lifeState", 1, 1);
	else SetEntProp(client, Prop_Data, "m_lifeState", 0, 1);
}
stock bool:IsPlayerGhost(client)
{
	if(GetEntProp(client, Prop_Send, "m_isGhost", 1)) return true;
	return false;
}
stock bool:IsPlayerHallucination(client)
{
	if(GetEntProp(client, Prop_Send, "m_isGhost", 1)) return true;
	return false;
}

//Meme Tank
stock bool:IsPlayerMeme(client)
{
	if(GetEntProp(client, Prop_Send, "m_isGhost", 1)) return true;
	return false;
}

//Boss Tank
stock bool:IsPlayerBoss(client)
{
	if(GetEntProp(client, Prop_Send, "m_isGhost", 1)) return true;
	return false;
}
stock bool:IsPlayerPoltergeist(client)
{
	if(GetEntProp(client, Prop_Send, "m_isGhost", 1)) return true;
	return false;
}
stock bool:IsPlayerIncap(client)
{
	if(GetEntProp(client, Prop_Send, "m_isIncapacitated", 1)) return true;
	return false;
}
stock NearestSurvivor(j)
{
	new target, Float:InfectedPos[3], Float:SurvivorPos[3], Float:nearest = 0.0;
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2 && ChaseTarget[i] == 0)
		{
			GetClientAbsOrigin(j, InfectedPos);
			GetClientAbsOrigin(i, SurvivorPos);
			new Float:distance = GetVectorDistance(InfectedPos, SurvivorPos);
			if(nearest == 0.0)
			{
				nearest = distance;
				target = i;
			}
			else if(nearest > distance)
			{
				nearest = distance;
				target = i;
			}
		} 
    }
    	return target;
}
stock CountSurvivorsAliveAll()
{
	new count = 0;
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
		{
			count++;
		}
	}
	return count;
}
stock CountInfectedAll()
{
	new count = 0;
	for(new i=1;i<=MaxClients;i++)
	{
		if(IsClientInGame(i) && GetClientTeam(i) == 3)
		{
			count++;
		}
	}
	return count;
}
bool:IsPlayerBurning(i)
{
	new Float:IsBurning = GetEntPropFloat(i, Prop_Send, "m_burnPercent");
	if(IsBurning > 0) 
		return true;
	return false;
}
public Action:CreateParticle(target, String:particlename[], Float:time, Float:origin)
{
	if(target > 0)
	{
		new particle = CreateEntityByName("info_particle_system");
		if(IsValidEntity(particle))
		{
			new Float:pos[3];
			GetEntPropVector(target, Prop_Send, "m_vecOrigin", pos);
			pos[2] += origin;
			TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(particle, "effect_name", particlename);
			DispatchKeyValue(particle, "targetname", "particle");
			DispatchSpawn(particle);
			ActivateEntity(particle);
			AcceptEntityInput(particle, "start");
			CreateTimer(time, DeleteParticles, particle, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}
public Action:AttachParticle(target, String:particlename[], Float:time, Float:origin)
{
	if(target > 0 && IsValidEntity(target))
	{
		new particle = CreateEntityByName("info_particle_system");
		if(IsValidEntity(particle))
    	{
			new Float:pos[3];
			GetEntPropVector(target, Prop_Send, "m_vecOrigin", pos);
			pos[2] += origin;
			TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
			decl String:tName[64];
			Format(tName, sizeof(tName), "Attach%d", target);
			DispatchKeyValue(target, "targetname", tName);
			GetEntPropString(target, Prop_Data, "m_iName", tName, sizeof(tName));
			DispatchKeyValue(particle, "scale", "");
			DispatchKeyValue(particle, "effect_name", particlename);
			DispatchKeyValue(particle, "parentname", tName);
			DispatchKeyValue(particle, "targetname", "particle");
			DispatchSpawn(particle);
			ActivateEntity(particle);
			SetVariantString(tName);
			AcceptEntityInput(particle, "SetParent", particle, particle);
			AcceptEntityInput(particle, "Enable");
			AcceptEntityInput(particle, "start");
			CreateTimer(time, DeleteParticles, particle, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}
public Action:PrecacheParticle(String:particlename[])
{
	new particle = CreateEntityByName("info_particle_system");
	if(IsValidEntity(particle))
	{
		DispatchKeyValue(particle, "effect_name", particlename);
		DispatchKeyValue(particle, "targetname", "particle");
		DispatchSpawn(particle);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(0.1, DeleteParticles, particle, TIMER_FLAG_NO_MAPCHANGE);
	}  
}
public Action:DeleteParticles(Handle:timer, any:particle)
{
	if(IsValidEntity(particle))
	{
		new String:classname[64];
		GetEdictClassname(particle, classname, sizeof(classname));
		if(StrEqual(classname, "info_particle_system", false))
					AcceptEntityInput(particle, "Kill");
	}
}
public ScreenShake(target, Float:intensity)
{
	new Handle:msg;
	msg = StartMessageOne("Shake", target);
	
	BfWriteByte(msg, 0);
 	BfWriteFloat(msg, intensity);
 	BfWriteFloat(msg, 10.0);
 	BfWriteFloat(msg, 3.0);
	EndMessage();
}
public Action:RockThrowTimer(Handle:timer)
{
	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
	{
		new thrower = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
		if(thrower > 0 && thrower < 40 && IsTank(thrower))
		{
			new color = GetEntityRenderColor(thrower);
			switch(color)
			{
				//Fire Tank
				case 12800:
				{
      	 				SetEntityRenderColor(entity, 128, 0, 0, 255);
					CreateTimer(0.8, Timer_AttachFIRE_Rock, entity, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Ice Tank
				case 0100170:
				{
					SetEntityRenderMode(entity, RenderMode:3);
      	 				SetEntityRenderColor(entity, 0, 100, 170, 180);
				}
				//Jockey Tank
				case 25516575:
				{
					Rock[thrower] = entity;
					CreateTimer(0.1, JockeyThrow, thrower, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Hunter Tank
				case 2590185:
				{
					Rock[thrower] = entity;
					CreateTimer(0.1, HunterThrow, thrower, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Smoker Tank
				case 12085120:
				{
					Rock[thrower] = entity;
					CreateTimer(0.1, SmokerThrow, thrower, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Boomer Tank
				case 651050:
				{
					Rock[thrower] = entity;
					CreateTimer(0.1, BoomerThrow, thrower, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Charger Tank
				case 4012540:
				{
					Rock[thrower] = entity;
					CreateTimer(0.1, ChargerThrow, thrower, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Minion Tank
				case 225225225:
				{
					Rock[thrower] = entity;
					CreateTimer(0.1, MinionThrow, thrower, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Bitch Tank
				case 255155255:
				{
					Rock[thrower] = entity;
					CreateTimer(0.1, BitchThrow, thrower, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Spitter Tank
				case 7525575:
				{
					Rock[thrower] = entity;
					CreateTimer(0.1, SpitterThrow, thrower, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Acid Tank
				case 12115128:
				{
					SetEntityRenderMode(entity, RenderMode:3);
      	 				SetEntityRenderColor(entity, 121, 151, 28, 30);
					CreateTimer(0.8, Timer_SpitSound, thrower, TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(0.8, Timer_AttachSPIT_Rock, entity, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Shock Tank
				case 100165255:
				{
					CreateTimer(0.8, Timer_AttachELEC_Rock, entity, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Shield Tank
				case 135205255:
				{
					Rock[thrower] = entity;
					CreateTimer(0.1, PropaneThrow, thrower, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Feedback Tank
				case 906090:
				{
					CreateTimer(0.8, Timer_AttachELEC_Rock2, entity, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Psychotic Tank
				case 000:
				{
					Rock[thrower] = entity;
					CreateTimer(0.1, PropaneThrow, thrower, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Goliath Tank
				case 00100:
				{
					Rock[thrower] = entity;
					CreateTimer(0.1, PropaneThrow, thrower, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Boss Tank
				case 0050:
				{
					Rock[thrower] = entity;
					CreateTimer(0.1, PropaneThrow, thrower, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
				//Sipow Tank
				case 0255125:
				{
					SetEntityRenderMode(entity, RenderMode:3);
      	 				SetEntityRenderColor(entity, 121, 151, 28, 30);
					CreateTimer(0.8, Timer_SpitSound2, thrower, TIMER_FLAG_NO_MAPCHANGE);
				}
				//Mirage Tank
				case 254025:
				{
					Rock[thrower] = entity;
					CreateTimer(0.1, MirageThrow, thrower, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
	}
}
public Action:PropaneThrow(Handle:timer, any:client)
{
	new Float:velocity[3];
	new entity = Rock[client];
	if(IsValidEntity(entity))
	{
		new g_iVelocity = FindSendPropOffs("CBasePlayer", "m_vecVelocity[0]");	
		GetEntDataVector(entity, g_iVelocity, velocity);
		new Float:v = GetVectorLength(velocity);
		if(v > 500.0)
		{
			new propane = CreateEntityByName("prop_physics");
			if(IsValidEntity(propane))
			{
				DispatchKeyValue(propane, "model", "models/props_junk/propanecanister001a.mdl");
				DispatchSpawn(propane);
				new Float:Pos[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);	
				AcceptEntityInput(entity, "Kill");
				NormalizeVector(velocity, velocity);
				new Float:speed = GetConVarFloat(FindConVar("z_tank_throw_force"));
				ScaleVector(velocity, speed*1.4);
				TeleportEntity(propane, Pos, NULL_VECTOR, velocity);
			}	
			return Plugin_Stop;
		}		
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action:JockeyThrow(Handle:timer, any:client)
{
	new Float:velocity[3];
	new entity = Rock[client];
	if(IsValidEntity(entity))
	{
		new g_iVelocity = FindSendPropOffs("CBasePlayer", "m_vecVelocity[0]");	
		GetEntDataVector(entity, g_iVelocity, velocity);
		new Float:v = GetVectorLength(velocity);
		if(v > 500.0)
		{
			new bot = CreateFakeClient("Jockey");
			if(bot > 0)
			{
				SpawnInfected(bot, 5, true);
				new Float:Pos[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);	
				AcceptEntityInput(entity, "Kill");
				NormalizeVector(velocity, velocity);
				new Float:speed = GetConVarFloat(FindConVar("z_tank_throw_force"));
				ScaleVector(velocity, speed*1.4);
				TeleportEntity(bot, Pos, NULL_VECTOR, velocity);
			}	
			return Plugin_Stop;
		}		
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action:HunterThrow(Handle:timer, any:client)
{
	new Float:velocity[3];
	new entity = Rock[client];
	if(IsValidEntity(entity))
	{
		new g_iVelocity = FindSendPropOffs("CBasePlayer", "m_vecVelocity[0]");	
		GetEntDataVector(entity, g_iVelocity, velocity);
		new Float:v = GetVectorLength(velocity);
		if(v > 500.0)
		{
			new bot = CreateFakeClient("Hunter");
			if(bot > 0)
			{
				SpawnInfected(bot, 3, true);
				new Float:Pos[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);	
				AcceptEntityInput(entity, "Kill");
				NormalizeVector(velocity, velocity);
				new Float:speed = GetConVarFloat(FindConVar("z_tank_throw_force"));
				ScaleVector(velocity, speed*1.4);
				TeleportEntity(bot, Pos, NULL_VECTOR, velocity);
			}	
			return Plugin_Stop;
		}		
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action:SmokerThrow(Handle:timer, any:client)
{
	new Float:velocity[3];
	new entity = Rock[client];
	if(IsValidEntity(entity))
	{
		new g_iVelocity = FindSendPropOffs("CBasePlayer", "m_vecVelocity[0]");	
		GetEntDataVector(entity, g_iVelocity, velocity);
		new Float:v = GetVectorLength(velocity);
		if(v > 500.0)
		{
			new bot = CreateFakeClient("Smoker");
			if(bot > 0)
			{
				SpawnInfected(bot, 1, true);
				new Float:Pos[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);	
				AcceptEntityInput(entity, "Kill");
				NormalizeVector(velocity, velocity);
				new Float:speed = GetConVarFloat(FindConVar("z_tank_throw_force"));
				ScaleVector(velocity, speed*1.4);
				TeleportEntity(bot, Pos, NULL_VECTOR, velocity);
			}	
			return Plugin_Stop;
		}		
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action:BoomerThrow(Handle:timer, any:client)
{
	new Float:velocity[3];
	new entity = Rock[client];
	if(IsValidEntity(entity))
	{
		new g_iVelocity = FindSendPropOffs("CBasePlayer", "m_vecVelocity[0]");	
		GetEntDataVector(entity, g_iVelocity, velocity);
		new Float:v = GetVectorLength(velocity);
		if(v > 500.0)
		{
			new bot = CreateFakeClient("Boomer");
			if(bot > 0)
			{
				SpawnInfected(bot, 2, true);
				new Float:Pos[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);	
				AcceptEntityInput(entity, "Kill");
				NormalizeVector(velocity, velocity);
				new Float:speed = GetConVarFloat(FindConVar("z_tank_throw_force"));
				ScaleVector(velocity, speed*1.4);
				TeleportEntity(bot, Pos, NULL_VECTOR, velocity);
			}	
			return Plugin_Stop;
		}		
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action:ChargerThrow(Handle:timer, any:client)
{
	new Float:velocity[3];
	new entity = Rock[client];
	if(IsValidEntity(entity))
	{
		new g_iVelocity = FindSendPropOffs("CBasePlayer", "m_vecVelocity[0]");	
		GetEntDataVector(entity, g_iVelocity, velocity);
		new Float:v = GetVectorLength(velocity);
		if(v > 500.0)
		{
			new bot = CreateFakeClient("Charger");
			if(bot > 0)
			{
				SpawnInfected(bot, 6, true);
				new Float:Pos[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);	
				AcceptEntityInput(entity, "Kill");
				NormalizeVector(velocity, velocity);
				new Float:speed = GetConVarFloat(FindConVar("z_tank_throw_force"));
				ScaleVector(velocity, speed*1.4);
				TeleportEntity(bot, Pos, NULL_VECTOR, velocity);
			}	
			return Plugin_Stop;
		}		
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action:MinionThrow(Handle:timer, any:client)
{
	new Float:velocity[3];
	new entity = Rock[client];
	if(IsValidEntity(entity))
	{
		new g_iVelocity = FindSendPropOffs("CBasePlayer", "m_vecVelocity[0]");	
		GetEntDataVector(entity, g_iVelocity, velocity);
		new Float:v = GetVectorLength(velocity);
		if(v > 500.0)
		{
			new bot = CreateFakeClient("Tank");
			if(bot > 0)
			{
				SpawnInfected(bot, 8, true);
				new Float:Pos[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);	
				AcceptEntityInput(entity, "Kill");
				NormalizeVector(velocity, velocity);
				new Float:speed = GetConVarFloat(FindConVar("z_tank_throw_force"));
				ScaleVector(velocity, speed*1.4);
				TeleportEntity(bot, Pos, NULL_VECTOR, velocity);
			}	
			return Plugin_Stop;
		}		
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action:BitchThrow(Handle:timer, any:client)
{
	new Float:velocity[3];
	new entity = Rock[client];
	if(IsValidEntity(entity))
	{
		new g_iVelocity = FindSendPropOffs("CBasePlayer", "m_vecVelocity[0]");	
		GetEntDataVector(entity, g_iVelocity, velocity);
		new Float:v = GetVectorLength(velocity);
		if(v > 500.0)
		{
			new bot = CreateFakeClient("Witch");
			if(bot > 0)
			{
				SpawnInfected(bot, 7, true);
				new Float:Pos[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);	
				AcceptEntityInput(entity, "Kill");
				NormalizeVector(velocity, velocity);
				new Float:speed = GetConVarFloat(FindConVar("z_tank_throw_force"));
				ScaleVector(velocity, speed*1.4);
				TeleportEntity(bot, Pos, NULL_VECTOR, velocity);
			}	
			return Plugin_Stop;
		}		
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action:SpitterThrow(Handle:timer, any:client)
{
	new Float:velocity[3];
	new entity = Rock[client];
	if(IsValidEntity(entity))
	{
		new g_iVelocity = FindSendPropOffs("CBasePlayer", "m_vecVelocity[0]");	
		GetEntDataVector(entity, g_iVelocity, velocity);
		new Float:v = GetVectorLength(velocity);
		if(v > 500.0)
		{
			new bot = CreateFakeClient("Spitter");
			if(bot > 0)
			{
				SpawnInfected(bot, 4, true);
				new Float:Pos[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);	
				AcceptEntityInput(entity, "Kill");
				NormalizeVector(velocity, velocity);
				new Float:speed = GetConVarFloat(FindConVar("z_tank_throw_force"));
				ScaleVector(velocity, speed*1.4);
				TeleportEntity(bot, Pos, NULL_VECTOR, velocity);
			}	
			return Plugin_Stop;
		}		
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action:MirageThrow(Handle:timer, any:client)
{
	new Float:velocity[3];
	new entity = Rock[client];
	if(IsValidEntity(entity))
	{
		new g_iVelocity = FindSendPropOffs("CBasePlayer", "m_vecVelocity[0]");	
		GetEntDataVector(entity, g_iVelocity, velocity);
		new Float:v = GetVectorLength(velocity);
		if(v > 500.0)
		{
			new bot = CreateFakeClient("Tank");
			if(bot > 0)
			{
				if(L4D2Version)
				{
					SpawnInfected(bot, 8, true);
				}
				else
				{
					SpawnInfected(bot, 5, true);
				}
				new Float:Pos[3];
				GetEntPropVector(entity, Prop_Send, "m_vecOrigin", Pos);	
				AcceptEntityInput(entity, "Kill");
				NormalizeVector(velocity, velocity);
				new Float:speed = GetConVarFloat(FindConVar("z_tank_throw_force"));
				ScaleVector(velocity, speed*1.4);
				TeleportEntity(bot, Pos, NULL_VECTOR, velocity);
			}	
			return Plugin_Stop;
		}		
	}
	else
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action:JumpTimer(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new flags = GetEntityFlags(client);
		if(flags & FL_ONGROUND)
		{
			new random = GetRandomInt(1,iJumperJumpDelay);
			if(random == 1)
			{
				if(GetNearestSurvivorDist(client) > 200 && GetNearestSurvivorDist(client) < 2000)
				{
					FakeJump(client);
				}
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:PsychoticTimer(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new flags = GetEntityFlags(client);
		if(flags & FL_ONGROUND)
		{
			new random = GetRandomInt(1,iPsychoticJumpDelay);
			if(random == 1)
			{
				if(GetNearestSurvivorDist(client) > 200 && GetNearestSurvivorDist(client) < 2000)
				{
					FakeJump(client);
				}
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:DistractionTimer(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new flags = GetEntityFlags(client);
		if(flags & FL_ONGROUND)
		{
			new random = GetRandomInt(1,iDistractionJumpDelay);
			if(random == 1)
			{
				if(GetNearestSurvivorDist(client) > 200 && GetNearestSurvivorDist(client) < 2000)
				{
					FakeJump(client);
				}
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

//Meme Tank
public Action:MemeTimer(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new flags = GetEntityFlags(client);
		if(flags & FL_ONGROUND)
		{
			new random = GetRandomInt(1,iMemeJumpDelay);
			if(random == 1)
			{
				if(GetNearestSurvivorDist(client) > 200 && GetNearestSurvivorDist(client) < 2000)
				{
					FakeJump(client);
				}
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

//Boss Tank
public Action:BossTimer(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new flags = GetEntityFlags(client);
		if(flags & FL_ONGROUND)
		{
			new random = GetRandomInt(1,iBossJumpDelay);
			if(random == 1)
			{
				if(GetNearestSurvivorDist(client) > 200 && GetNearestSurvivorDist(client) < 2000)
				{
					FakeJump(client);
				}
			}
		}
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public FakeJump(client)
{
	if(client > 0 && IsTank(client))
	{
		new Float:vecVelocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", vecVelocity);
		if(vecVelocity[0] > 0.0 && vecVelocity[0] < 500.0)
		{
			vecVelocity[0] += 500.0;
		}
		else if(vecVelocity[0] < 0.0 && vecVelocity[0] > -500.0)
		{
			vecVelocity[0] += -500.0;
		}
		if(vecVelocity[1] > 0.0 && vecVelocity[1] < 500.0)
		{
			vecVelocity[1] += 500.0;
		}
		else if(vecVelocity[1] < 0.0 && vecVelocity[1] > -500.0)
		{
			vecVelocity[1] += -500.0;
		}
		vecVelocity[2] += 750.0;
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecVelocity);
	}
}
public SkillFlameClaw(target)
{
	if(target > 0)
	{
		if(IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target) == 2)
		{
			IgniteEntity(target, 3.0);
			EmitSoundToAll("ambient/fire/gascan_ignite1.wav", target);
		}
	}
}

public SkillIceClaw(target)
{
	if(target > 0)
	{
		if(IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target) == 2)
		{
			SetEntityRenderMode(target, RenderMode:3);
			SetEntityRenderColor(target, 0, 100, 170, 180);
			SetEntityMoveType(target, MOVETYPE_VPHYSICS);
			CreateTimer(5.0, Timer_UnFreeze, target, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}

public SkillFlameGush(target)
{
	if(target > 0)
	{
		if(IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target) == 3)
		{
			decl Float:pos[3];
			GetClientAbsOrigin(target, pos);
			new entity = CreateEntityByName("prop_physics");
			if(IsValidEntity(entity))
			{
				pos[2] += 10.0;
				DispatchKeyValue(entity, "model", "models/props_junk/gascan001a.mdl");
				DispatchSpawn(entity);
				SetEntData(entity, GetEntSendPropOffs(entity, "m_CollisionGroup"), 1, 1, true);
				TeleportEntity(entity, pos, NULL_VECTOR, NULL_VECTOR);
				AcceptEntityInput(entity, "break");
			}
		}
	}
}
public SkillGravityClaw(target)
{
	if(target > 0)
	{
		if(IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target) == 2)
		{
			SetEntityGravity(target, 0.3);
			CreateTimer(2.0, Timer_ResetGravity, target, TIMER_FLAG_NO_MAPCHANGE);
			ScreenShake(target, 5.0);
		}
	}
}
public Action:MeteorTankTimer(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 1002525)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				new ent[5];
				for(new count=1; count<=4; count++)
				{
					ent[count] = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(ent[count]))
					{
						decl String:tName[64];
						Format(tName, sizeof(tName), "Tank%d", client);
						DispatchKeyValue(client, "targetname", tName);
						GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

						DispatchKeyValue(ent[count], "model", "models/props_debris/concrete_chunk01a.mdl");
						SetEntityRenderColor(ent[count], 255, 255, 255, 255);
						DispatchKeyValue(ent[count], "targetname", "RockEntity");
						DispatchKeyValue(ent[count], "parentname", tName);
						DispatchKeyValueVector(ent[count], "origin", Origin);
						DispatchKeyValueVector(ent[count], "angles", Angles);
						DispatchSpawn(ent[count]);
						SetVariantString(tName);
						AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
						switch(count)
						{
							case 1:SetVariantString("relbow");
							case 2:SetVariantString("lelbow");
							case 3:SetVariantString("rshoulder");
							case 4:SetVariantString("lshoulder");
						}
						AcceptEntityInput(ent[count], "SetParentAttachment");
						AcceptEntityInput(ent[count], "Enable");
						AcceptEntityInput(ent[count], "DisableCollision");
						switch(count)
						{
							case 1,2:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.4);
							case 3,4:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.5);
						}
						SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
						Angles[0] = Angles[0] + GetRandomFloat(-90.0, 90.0);
						Angles[1] = Angles[1] + GetRandomFloat(-90.0, 90.0);
						Angles[2] = Angles[2] + GetRandomFloat(-90.0, 90.0);
						TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
					}
				}
			}
		}
	}
}
public Action:FlashTankTimer(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 25500)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				Angles[0] += -90.0;
				new entity = CreateEntityByName("beam_spotlight");
				if(IsValidEntity(entity))
				{
					decl String:tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(entity, "targetname", "LightEntity");
					DispatchKeyValue(entity, "parentname", tName);
					DispatchKeyValueVector(entity, "origin", Origin);
					DispatchKeyValueVector(entity, "angles", Angles);
					DispatchKeyValue(entity, "spotlightwidth", "10");
					DispatchKeyValue(entity, "spotlightlength", "60");
					DispatchKeyValue(entity, "spawnflags", "3");
					DispatchKeyValue(entity, "rendercolor", "255 255 0");
					DispatchKeyValue(entity, "renderamt", "125");
					DispatchKeyValue(entity, "maxspeed", "100");
					DispatchKeyValue(entity, "HDRColorScale", "0.7");
					DispatchKeyValue(entity, "fadescale", "1");
					DispatchKeyValue(entity, "fademindist", "-1");
					DispatchSpawn(entity);
					SetVariantString(tName);
					AcceptEntityInput(entity, "SetParent", entity, entity);
					SetVariantString("mouth");
					AcceptEntityInput(entity, "SetParentAttachment");
					AcceptEntityInput(entity, "Enable");
					AcceptEntityInput(entity, "DisableCollision");
					SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(entity, NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
		}
	}
}
public Action:FlashTankTimer2(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 25500)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				new ent[5];
				for(new count=1; count<=4; count++)
				{
					ent[count] = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(ent[count]))
					{
						decl String:tName[64];
						Format(tName, sizeof(tName), "Tank%d", client);
						DispatchKeyValue(client, "targetname", tName);
						GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

						DispatchKeyValue(ent[count], "model", "models/props_debris/concrete_chunk01a.mdl");
						SetEntityRenderColor(ent[count], 225, 255, 0, 255);
						DispatchKeyValue(ent[count], "targetname", "RockEntity");
						DispatchKeyValue(ent[count], "parentname", tName);
						DispatchKeyValueVector(ent[count], "origin", Origin);
						DispatchKeyValueVector(ent[count], "angles", Angles);
						DispatchSpawn(ent[count]);
						SetVariantString(tName);
						AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
						switch(count)
						{
							case 1:SetVariantString("relbow");
							case 2:SetVariantString("lelbow");
							case 3:SetVariantString("rshoulder");
							case 4:SetVariantString("lshoulder");
						}
						AcceptEntityInput(ent[count], "SetParentAttachment");
						AcceptEntityInput(ent[count], "Enable");
						AcceptEntityInput(ent[count], "DisableCollision");
						switch(count)
						{
							case 1,2:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.4);
							case 3,4:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.5);
						}
						SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
						Angles[0] = Angles[0] + GetRandomFloat(-90.0, 90.0);
						Angles[1] = Angles[1] + GetRandomFloat(-90.0, 90.0);
						Angles[2] = Angles[2] + GetRandomFloat(-90.0, 90.0);
						TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
					}
				}
			}
		}
	}
}
public Action:ReverseFlashTankTimer(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 2552550)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				Angles[0] += -90.0;
				new entity = CreateEntityByName("beam_spotlight");
				if(IsValidEntity(entity))
				{
					decl String:tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(entity, "targetname", "LightEntity");
					DispatchKeyValue(entity, "parentname", tName);
					DispatchKeyValueVector(entity, "origin", Origin);
					DispatchKeyValueVector(entity, "angles", Angles);
					DispatchKeyValue(entity, "spotlightwidth", "10");
					DispatchKeyValue(entity, "spotlightlength", "60");
					DispatchKeyValue(entity, "spawnflags", "3");
					DispatchKeyValue(entity, "rendercolor", "255 0 0");
					DispatchKeyValue(entity, "renderamt", "125");
					DispatchKeyValue(entity, "maxspeed", "100");
					DispatchKeyValue(entity, "HDRColorScale", "0.7");
					DispatchKeyValue(entity, "fadescale", "1");
					DispatchKeyValue(entity, "fademindist", "-1");
					DispatchSpawn(entity);
					SetVariantString(tName);
					AcceptEntityInput(entity, "SetParent", entity, entity);
					SetVariantString("mouth");
					AcceptEntityInput(entity, "SetParentAttachment");
					AcceptEntityInput(entity, "Enable");
					AcceptEntityInput(entity, "DisableCollision");
					SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(entity, NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
		}
	}
}
public Action:ReverseFlashTankTimer2(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 2552550)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				new ent[5];
				for(new count=1; count<=4; count++)
				{
					ent[count] = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(ent[count]))
					{
						decl String:tName[64];
						Format(tName, sizeof(tName), "Tank%d", client);
						DispatchKeyValue(client, "targetname", tName);
						GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

						DispatchKeyValue(ent[count], "model", "models/props_debris/concrete_chunk01a.mdl");
						SetEntityRenderColor(ent[count], 225, 0, 0, 255);
						DispatchKeyValue(ent[count], "targetname", "RockEntity");
						DispatchKeyValue(ent[count], "parentname", tName);
						DispatchKeyValueVector(ent[count], "origin", Origin);
						DispatchKeyValueVector(ent[count], "angles", Angles);
						DispatchSpawn(ent[count]);
						SetVariantString(tName);
						AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
						switch(count)
						{
							case 1:SetVariantString("relbow");
							case 2:SetVariantString("lelbow");
							case 3:SetVariantString("rshoulder");
							case 4:SetVariantString("lshoulder");
						}
						AcceptEntityInput(ent[count], "SetParentAttachment");
						AcceptEntityInput(ent[count], "Enable");
						AcceptEntityInput(ent[count], "DisableCollision");
						switch(count)
						{
							case 1,2:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.4);
							case 3,4:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.5);
						}
						SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
						Angles[0] = Angles[0] + GetRandomFloat(-90.0, 90.0);
						Angles[1] = Angles[1] + GetRandomFloat(-90.0, 90.0);
						Angles[2] = Angles[2] + GetRandomFloat(-90.0, 90.0);
						TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
					}
				}
			}
		}
	}
}
public Action:PsykotikTankTimer(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 111)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				Angles[0] += -90.0;
				new entity = CreateEntityByName("beam_spotlight");
				if(IsValidEntity(entity))
				{
					decl String:tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(entity, "targetname", "LightEntity");
					DispatchKeyValue(entity, "parentname", tName);
					DispatchKeyValueVector(entity, "origin", Origin);
					DispatchKeyValueVector(entity, "angles", Angles);
					DispatchKeyValue(entity, "spotlightwidth", "10");
					DispatchKeyValue(entity, "spotlightlength", "60");
					DispatchKeyValue(entity, "spawnflags", "3");
					DispatchKeyValue(entity, "rendercolor", "100 200 255");
					DispatchKeyValue(entity, "renderamt", "125");
					DispatchKeyValue(entity, "maxspeed", "100");
					DispatchKeyValue(entity, "HDRColorScale", "0.7");
					DispatchKeyValue(entity, "fadescale", "1");
					DispatchKeyValue(entity, "fademindist", "-1");
					DispatchSpawn(entity);
					SetVariantString(tName);
					AcceptEntityInput(entity, "SetParent", entity, entity);
					SetVariantString("mouth");
					AcceptEntityInput(entity, "SetParentAttachment");
					AcceptEntityInput(entity, "Enable");
					AcceptEntityInput(entity, "DisableCollision");
					SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(entity, NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
		}
	}
}
public Action:PsykotikTankTimer2(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 111)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				new ent[5];
				for(new count=1; count<=4; count++)
				{
					ent[count] = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(ent[count]))
					{
						decl String:tName[64];
						Format(tName, sizeof(tName), "Tank%d", client);
						DispatchKeyValue(client, "targetname", tName);
						GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

						DispatchKeyValue(ent[count], "model", "models/props_debris/concrete_chunk01a.mdl");
						SetEntityRenderColor(ent[count], 225, 0, 0, 255);
						DispatchKeyValue(ent[count], "targetname", "RockEntity");
						DispatchKeyValue(ent[count], "parentname", tName);
						DispatchKeyValueVector(ent[count], "origin", Origin);
						DispatchKeyValueVector(ent[count], "angles", Angles);
						DispatchSpawn(ent[count]);
						SetVariantString(tName);
						AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
						switch(count)
						{
							case 1:SetVariantString("relbow");
							case 2:SetVariantString("lelbow");
							case 3:SetVariantString("rshoulder");
							case 4:SetVariantString("lshoulder");
						}
						AcceptEntityInput(ent[count], "SetParentAttachment");
						AcceptEntityInput(ent[count], "Enable");
						AcceptEntityInput(ent[count], "DisableCollision");
						switch(count)
						{
							case 1,2:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.4);
							case 3,4:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.5);
						}
						SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
						Angles[0] = Angles[0] + GetRandomFloat(-90.0, 90.0);
						Angles[1] = Angles[1] + GetRandomFloat(-90.0, 90.0);
						Angles[2] = Angles[2] + GetRandomFloat(-90.0, 90.0);
						TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
					}
				}
			}
		}
	}
}
public Action:SpykotikTankTimer(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 255100255)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				Angles[0] += -90.0;
				new entity = CreateEntityByName("beam_spotlight");
				if(IsValidEntity(entity))
				{
					decl String:tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(entity, "targetname", "LightEntity");
					DispatchKeyValue(entity, "parentname", tName);
					DispatchKeyValueVector(entity, "origin", Origin);
					DispatchKeyValueVector(entity, "angles", Angles);
					DispatchKeyValue(entity, "spotlightwidth", "10");
					DispatchKeyValue(entity, "spotlightlength", "60");
					DispatchKeyValue(entity, "spawnflags", "3");
					DispatchKeyValue(entity, "rendercolor", "150 0 255");
					DispatchKeyValue(entity, "renderamt", "125");
					DispatchKeyValue(entity, "maxspeed", "100");
					DispatchKeyValue(entity, "HDRColorScale", "0.7");
					DispatchKeyValue(entity, "fadescale", "1");
					DispatchKeyValue(entity, "fademindist", "-1");
					DispatchSpawn(entity);
					SetVariantString(tName);
					AcceptEntityInput(entity, "SetParent", entity, entity);
					SetVariantString("mouth");
					AcceptEntityInput(entity, "SetParentAttachment");
					AcceptEntityInput(entity, "Enable");
					AcceptEntityInput(entity, "DisableCollision");
					SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(entity, NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
		}
	}
}
public Action:SpykotikTankTimer2(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 255100255)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				new ent[5];
				for(new count=1; count<=4; count++)
				{
					ent[count] = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(ent[count]))
					{
						decl String:tName[64];
						Format(tName, sizeof(tName), "Tank%d", client);
						DispatchKeyValue(client, "targetname", tName);
						GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

						DispatchKeyValue(ent[count], "model", "models/props_debris/concrete_chunk01a.mdl");
						SetEntityRenderColor(ent[count], 150, 0, 255, 255);
						DispatchKeyValue(ent[count], "targetname", "RockEntity");
						DispatchKeyValue(ent[count], "parentname", tName);
						DispatchKeyValueVector(ent[count], "origin", Origin);
						DispatchKeyValueVector(ent[count], "angles", Angles);
						DispatchSpawn(ent[count]);
						SetVariantString(tName);
						AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
						switch(count)
						{
							case 1:SetVariantString("relbow");
							case 2:SetVariantString("lelbow");
							case 3:SetVariantString("rshoulder");
							case 4:SetVariantString("lshoulder");
						}
						AcceptEntityInput(ent[count], "SetParentAttachment");
						AcceptEntityInput(ent[count], "Enable");
						AcceptEntityInput(ent[count], "DisableCollision");
						switch(count)
						{
							case 1,2:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.4);
							case 3,4:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.5);
						}
						SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
						Angles[0] = Angles[0] + GetRandomFloat(-90.0, 90.0);
						Angles[1] = Angles[1] + GetRandomFloat(-90.0, 90.0);
						Angles[2] = Angles[2] + GetRandomFloat(-90.0, 90.0);
						TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
					}
				}
			}
		}
	}
}

//Meme Tank
public Action:MemeTankTimer(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new color = GetEntityRenderColor(client);
		if(color == 02550)
		{
			new Float:Origin[3], Float:Angles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
			Angles[0] += -90.0;
			new entity = CreateEntityByName("beam_spotlight");
			if(IsValidEntity(entity))
			{
				decl String:tName[64];
				Format(tName, sizeof(tName), "Tank%d", client);
				DispatchKeyValue(client, "targetname", tName);
				GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

				DispatchKeyValue(entity, "targetname", "LightEntity");
				DispatchKeyValue(entity, "parentname", tName);
				DispatchKeyValueVector(entity, "origin", Origin);
				DispatchKeyValueVector(entity, "angles", Angles);
				DispatchKeyValue(entity, "spotlightwidth", "10");
				DispatchKeyValue(entity, "spotlightlength", "60");
				DispatchKeyValue(entity, "spawnflags", "3");
				DispatchKeyValue(entity, "rendercolor", "255 0 255");
				DispatchKeyValue(entity, "renderamt", "125");
				DispatchKeyValue(entity, "maxspeed", "100");
				DispatchKeyValue(entity, "HDRColorScale", "0.7");
				DispatchKeyValue(entity, "fadescale", "1");
				DispatchKeyValue(entity, "fademindist", "-1");
				DispatchSpawn(entity);
				SetVariantString(tName);
				AcceptEntityInput(entity, "SetParent", entity, entity);
				SetVariantString("mouth");
				AcceptEntityInput(entity, "SetParentAttachment");
				AcceptEntityInput(entity, "Enable");
				AcceptEntityInput(entity, "DisableCollision");
				SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
				TeleportEntity(entity, NULL_VECTOR, Angles, NULL_VECTOR);
			}
		}
	}
}
public Action:MemeTankTimer2(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new color = GetEntityRenderColor(client);
		if(color == 02550)
		{
			new Float:Origin[3], Float:Angles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
			new ent[5];
			for(new count=1; count<=4; count++)
			{
				ent[count] = CreateEntityByName("prop_dynamic_override");
				if(IsValidEntity(ent[count]))
				{
					decl String:tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(ent[count], "model", "models/props_debris/concrete_chunk01a.mdl");
					SetEntityRenderColor(ent[count], 225, 0, 255, 255);
					DispatchKeyValue(ent[count], "targetname", "RockEntity");
					DispatchKeyValue(ent[count], "parentname", tName);
					DispatchKeyValueVector(ent[count], "origin", Origin);
					DispatchKeyValueVector(ent[count], "angles", Angles);
					DispatchSpawn(ent[count]);
					SetVariantString(tName);
					AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
					switch(count)
					{
						case 1:SetVariantString("relbow");
						case 2:SetVariantString("lelbow");
						case 3:SetVariantString("rshoulder");
						case 4:SetVariantString("lshoulder");
					}
					AcceptEntityInput(ent[count], "SetParentAttachment");
					AcceptEntityInput(ent[count], "Enable");
					AcceptEntityInput(ent[count], "DisableCollision");
					switch(count)
					{
						case 1,2:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.4);
						case 3,4:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.5);
					}
					SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
					Angles[0] = Angles[0] + GetRandomFloat(-90.0, 90.0);
					Angles[1] = Angles[1] + GetRandomFloat(-90.0, 90.0);
					Angles[2] = Angles[2] + GetRandomFloat(-90.0, 90.0);
					TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
		}
	}
}

//Boss Tank
public Action:BossTankTimer(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new color = GetEntityRenderColor(client);
		if(color == 0050)
		{
			new Float:Origin[3], Float:Angles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
			Angles[0] += -90.0;
			new entity = CreateEntityByName("beam_spotlight");
			if(IsValidEntity(entity))
			{
				decl String:tName[64];
				Format(tName, sizeof(tName), "Tank%d", client);
				DispatchKeyValue(client, "targetname", tName);
				GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

				DispatchKeyValue(entity, "targetname", "LightEntity");
				DispatchKeyValue(entity, "parentname", tName);
				DispatchKeyValueVector(entity, "origin", Origin);
				DispatchKeyValueVector(entity, "angles", Angles);
				DispatchKeyValue(entity, "spotlightwidth", "10");
				DispatchKeyValue(entity, "spotlightlength", "60");
				DispatchKeyValue(entity, "spawnflags", "3");
				DispatchKeyValue(entity, "rendercolor", "0 175 255");
				DispatchKeyValue(entity, "renderamt", "125");
				DispatchKeyValue(entity, "maxspeed", "100");
				DispatchKeyValue(entity, "HDRColorScale", "0.7");
				DispatchKeyValue(entity, "fadescale", "1");
				DispatchKeyValue(entity, "fademindist", "-1");
				DispatchSpawn(entity);
				SetVariantString(tName);
				AcceptEntityInput(entity, "SetParent", entity, entity);
				SetVariantString("mouth");
				AcceptEntityInput(entity, "SetParentAttachment");
				AcceptEntityInput(entity, "Enable");
				AcceptEntityInput(entity, "DisableCollision");
				SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
				TeleportEntity(entity, NULL_VECTOR, Angles, NULL_VECTOR);
			}
		}
	}
}
public Action:BossTankTimer2(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new color = GetEntityRenderColor(client);
		if(color == 0050)
		{
			new Float:Origin[3], Float:Angles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
			new ent[5];
			for(new count=1; count<=4; count++)
			{
				ent[count] = CreateEntityByName("prop_dynamic_override");
				if(IsValidEntity(ent[count]))
				{
					decl String:tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(ent[count], "model", "models/props_debris/concrete_chunk01a.mdl");
					SetEntityRenderColor(ent[count], 25, 25, 25, 255);
					DispatchKeyValue(ent[count], "targetname", "RockEntity");
					DispatchKeyValue(ent[count], "parentname", tName);
					DispatchKeyValueVector(ent[count], "origin", Origin);
					DispatchKeyValueVector(ent[count], "angles", Angles);
					DispatchSpawn(ent[count]);
					SetVariantString(tName);
					AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
					switch(count)
					{
						case 1:SetVariantString("relbow");
						case 2:SetVariantString("lelbow");
						case 3:SetVariantString("rshoulder");
						case 4:SetVariantString("lshoulder");
					}
					AcceptEntityInput(ent[count], "SetParentAttachment");
					AcceptEntityInput(ent[count], "Enable");
					AcceptEntityInput(ent[count], "DisableCollision");
					switch(count)
					{
						case 1,2:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.4);
						case 3,4:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.5);
					}
					SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
					Angles[0] = Angles[0] + GetRandomFloat(-90.0, 90.0);
					Angles[1] = Angles[1] + GetRandomFloat(-90.0, 90.0);
					Angles[2] = Angles[2] + GetRandomFloat(-90.0, 90.0);
					TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
		}
	}
}
public Action:SpypsyTankTimer(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 00255)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				Angles[0] += -90.0;
				new entity = CreateEntityByName("beam_spotlight");
				if(IsValidEntity(entity))
				{
					decl String:tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(entity, "targetname", "LightEntity");
					DispatchKeyValue(entity, "parentname", tName);
					DispatchKeyValueVector(entity, "origin", Origin);
					DispatchKeyValueVector(entity, "angles", Angles);
					DispatchKeyValue(entity, "spotlightwidth", "10");
					DispatchKeyValue(entity, "spotlightlength", "60");
					DispatchKeyValue(entity, "spawnflags", "3");
					DispatchKeyValue(entity, "rendercolor", "255 255 0");
					DispatchKeyValue(entity, "renderamt", "125");
					DispatchKeyValue(entity, "maxspeed", "100");
					DispatchKeyValue(entity, "HDRColorScale", "0.7");
					DispatchKeyValue(entity, "fadescale", "1");
					DispatchKeyValue(entity, "fademindist", "-1");
					DispatchSpawn(entity);
					SetVariantString(tName);
					AcceptEntityInput(entity, "SetParent", entity, entity);
					SetVariantString("mouth");
					AcceptEntityInput(entity, "SetParentAttachment");
					AcceptEntityInput(entity, "Enable");
					AcceptEntityInput(entity, "DisableCollision");
					SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(entity, NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
		}
	}
}
public Action:SpypsyTankTimer2(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 00255)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				new ent[5];
				for(new count=1; count<=4; count++)
				{
					ent[count] = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(ent[count]))
					{
						decl String:tName[64];
						Format(tName, sizeof(tName), "Tank%d", client);
						DispatchKeyValue(client, "targetname", tName);
						GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

						DispatchKeyValue(ent[count], "model", "models/props_debris/concrete_chunk01a.mdl");
						SetEntityRenderColor(ent[count], 255, 100, 0, 255);
						DispatchKeyValue(ent[count], "targetname", "RockEntity");
						DispatchKeyValue(ent[count], "parentname", tName);
						DispatchKeyValueVector(ent[count], "origin", Origin);
						DispatchKeyValueVector(ent[count], "angles", Angles);
						DispatchSpawn(ent[count]);
						SetVariantString(tName);
						AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
						switch(count)
						{
							case 1:SetVariantString("relbow");
							case 2:SetVariantString("lelbow");
							case 3:SetVariantString("rshoulder");
							case 4:SetVariantString("lshoulder");
						}
						AcceptEntityInput(ent[count], "SetParentAttachment");
						AcceptEntityInput(ent[count], "Enable");
						AcceptEntityInput(ent[count], "DisableCollision");
						switch(count)
						{
							case 1,2:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.4);
							case 3,4:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.5);
						}
						SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
						Angles[0] = Angles[0] + GetRandomFloat(-90.0, 90.0);
						Angles[1] = Angles[1] + GetRandomFloat(-90.0, 90.0);
						Angles[2] = Angles[2] + GetRandomFloat(-90.0, 90.0);
						TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
					}
				}
			}
		}
	}
}
public Action:SipowTankTimer(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new color = GetEntityRenderColor(client);
		if(color == 0255125)
		{
			new Float:Origin[3], Float:Angles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
			Angles[0] += -90.0;
			new entity = CreateEntityByName("beam_spotlight");
			if(IsValidEntity(entity))
			{
				decl String:tName[64];
				Format(tName, sizeof(tName), "Tank%d", client);
				DispatchKeyValue(client, "targetname", tName);
				GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

				DispatchKeyValue(entity, "targetname", "LightEntity");
				DispatchKeyValue(entity, "parentname", tName);
				DispatchKeyValueVector(entity, "origin", Origin);
				DispatchKeyValueVector(entity, "angles", Angles);
				DispatchKeyValue(entity, "spotlightwidth", "10");
				DispatchKeyValue(entity, "spotlightlength", "60");
				DispatchKeyValue(entity, "spawnflags", "3");
				DispatchKeyValue(entity, "rendercolor", "255 0 0");
				DispatchKeyValue(entity, "renderamt", "125");
				DispatchKeyValue(entity, "maxspeed", "100");
				DispatchKeyValue(entity, "HDRColorScale", "0.7");
				DispatchKeyValue(entity, "fadescale", "1");
				DispatchKeyValue(entity, "fademindist", "-1");
				DispatchSpawn(entity);
				SetVariantString(tName);
				AcceptEntityInput(entity, "SetParent", entity, entity);
				SetVariantString("mouth");
				AcceptEntityInput(entity, "SetParentAttachment");
				AcceptEntityInput(entity, "Enable");
				AcceptEntityInput(entity, "DisableCollision");
				SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
				TeleportEntity(entity, NULL_VECTOR, Angles, NULL_VECTOR);
			}
		}
	}
}
public Action:SipowTankTimer2(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 0255125)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				new ent[5];
				for(new count=1; count<=4; count++)
				{
					ent[count] = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(ent[count]))
					{
						decl String:tName[64];
						Format(tName, sizeof(tName), "Tank%d", client);
						DispatchKeyValue(client, "targetname", tName);
						GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

						DispatchKeyValue(ent[count], "model", "models/props_debris/concrete_chunk01a.mdl");
						SetEntityRenderColor(ent[count], 225, 0, 0, 255);
						DispatchKeyValue(ent[count], "targetname", "RockEntity");
						DispatchKeyValue(ent[count], "parentname", tName);
						DispatchKeyValueVector(ent[count], "origin", Origin);
						DispatchKeyValueVector(ent[count], "angles", Angles);
						DispatchSpawn(ent[count]);
						SetVariantString(tName);
						AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
						switch(count)
						{
							case 1:SetVariantString("relbow");
							case 2:SetVariantString("lelbow");
							case 3:SetVariantString("rshoulder");
							case 4:SetVariantString("lshoulder");
						}
						AcceptEntityInput(ent[count], "SetParentAttachment");
						AcceptEntityInput(ent[count], "Enable");
						AcceptEntityInput(ent[count], "DisableCollision");
						switch(count)
						{
							case 1,2:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.4);
							case 3,4:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.5);
						}
						SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
						Angles[0] = Angles[0] + GetRandomFloat(-90.0, 90.0);
						Angles[1] = Angles[1] + GetRandomFloat(-90.0, 90.0);
						Angles[2] = Angles[2] + GetRandomFloat(-90.0, 90.0);
						TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
					}
				}
			}
		}
	}
}
public Action:PsychoticTankTimer(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 000)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				new ent[5];
				for(new count=1; count<=4; count++)
				{
					ent[count] = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(ent[count]))
					{
						decl String:tName[64];
						Format(tName, sizeof(tName), "Tank%d", client);
						DispatchKeyValue(client, "targetname", tName);
						GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

						DispatchKeyValue(ent[count], "model", "models/props_debris/concrete_chunk01a.mdl");
						SetEntityRenderColor(ent[count], 200, 0, 0, 255);
						DispatchKeyValue(ent[count], "targetname", "RockEntity");
						DispatchKeyValue(ent[count], "parentname", tName);
						DispatchKeyValueVector(ent[count], "origin", Origin);
						DispatchKeyValueVector(ent[count], "angles", Angles);
						DispatchSpawn(ent[count]);
						SetVariantString(tName);
						AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
						switch(count)
						{
							case 1:SetVariantString("relbow");
							case 2:SetVariantString("lelbow");
							case 3:SetVariantString("rshoulder");
							case 4:SetVariantString("lshoulder");
						}
						AcceptEntityInput(ent[count], "SetParentAttachment");
						AcceptEntityInput(ent[count], "Enable");
						AcceptEntityInput(ent[count], "DisableCollision");
						switch(count)
						{
							case 1,2:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.4);
							case 3,4:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.5);
						}
						SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
						Angles[0] = Angles[0] + GetRandomFloat(-90.0, 90.0);
						Angles[1] = Angles[1] + GetRandomFloat(-90.0, 90.0);
						Angles[2] = Angles[2] + GetRandomFloat(-90.0, 90.0);
						TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
					}
				}
			}
		}
	}
}
public Action:PsychoticTankTimer2(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 000)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				Angles[0] += -90.0;
				new entity = CreateEntityByName("beam_spotlight");
				if(IsValidEntity(entity))
				{
					decl String:tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(entity, "targetname", "LightEntity");
					DispatchKeyValue(entity, "parentname", tName);
					DispatchKeyValueVector(entity, "origin", Origin);
					DispatchKeyValueVector(entity, "angles", Angles);
					DispatchKeyValue(entity, "spotlightwidth", "10");
					DispatchKeyValue(entity, "spotlightlength", "60");
					DispatchKeyValue(entity, "spawnflags", "3");
					DispatchKeyValue(entity, "rendercolor", "255 0 0");
					DispatchKeyValue(entity, "renderamt", "125");
					DispatchKeyValue(entity, "maxspeed", "100");
					DispatchKeyValue(entity, "HDRColorScale", "0.7");
					DispatchKeyValue(entity, "fadescale", "1");
					DispatchKeyValue(entity, "fademindist", "-1");
					DispatchSpawn(entity);
					SetVariantString(tName);
					AcceptEntityInput(entity, "SetParent", entity, entity);
					SetVariantString("mouth");
					AcceptEntityInput(entity, "SetParentAttachment");
					AcceptEntityInput(entity, "Enable");
					AcceptEntityInput(entity, "DisableCollision");
					SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(entity, NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
		}
	}
}
public Action:ArmageddonTankTimer(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 7500)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				new ent[5];
				for(new count=1; count<=4; count++)
				{
					ent[count] = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(ent[count]))
					{
						decl String:tName[64];
						Format(tName, sizeof(tName), "Tank%d", client);
						DispatchKeyValue(client, "targetname", tName);
						GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

						DispatchKeyValue(ent[count], "model", "models/props_debris/concrete_chunk01a.mdl");
						SetEntityRenderColor(ent[count], 25, 25, 25, 255);
						DispatchKeyValue(ent[count], "targetname", "RockEntity");
						DispatchKeyValue(ent[count], "parentname", tName);
						DispatchKeyValueVector(ent[count], "origin", Origin);
						DispatchKeyValueVector(ent[count], "angles", Angles);
						DispatchSpawn(ent[count]);
						SetVariantString(tName);
						AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
						switch(count)
						{
							case 1:SetVariantString("relbow");
							case 2:SetVariantString("lelbow");
							case 3:SetVariantString("rshoulder");
							case 4:SetVariantString("lshoulder");
						}
						AcceptEntityInput(ent[count], "SetParentAttachment");
						AcceptEntityInput(ent[count], "Enable");
						AcceptEntityInput(ent[count], "DisableCollision");
						switch(count)
						{
							case 1,2:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.4);
							case 3,4:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.5);
						}
						SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
						Angles[0] = Angles[0] + GetRandomFloat(-90.0, 90.0);
						Angles[1] = Angles[1] + GetRandomFloat(-90.0, 90.0);
						Angles[2] = Angles[2] + GetRandomFloat(-90.0, 90.0);
						TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
					}
				}
			}
		}
	}
}
public Action:GoliathTankTimer(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 00100)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				new ent[5];
				for(new count=1; count<=4; count++)
				{
					ent[count] = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(ent[count]))
					{
						decl String:tName[64];
						Format(tName, sizeof(tName), "Tank%d", client);
						DispatchKeyValue(client, "targetname", tName);
						GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

						DispatchKeyValue(ent[count], "model", "models/props_debris/concrete_chunk01a.mdl");
						SetEntityRenderColor(ent[count], 25, 25, 25, 255);
						DispatchKeyValue(ent[count], "targetname", "RockEntity");
						DispatchKeyValue(ent[count], "parentname", tName);
						DispatchKeyValueVector(ent[count], "origin", Origin);
						DispatchKeyValueVector(ent[count], "angles", Angles);
						DispatchSpawn(ent[count]);
						SetVariantString(tName);
						AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
						switch(count)
						{
							case 1:SetVariantString("relbow");
							case 2:SetVariantString("lelbow");
							case 3:SetVariantString("rshoulder");
							case 4:SetVariantString("lshoulder");
						}
						AcceptEntityInput(ent[count], "SetParentAttachment");
						AcceptEntityInput(ent[count], "Enable");
						AcceptEntityInput(ent[count], "DisableCollision");
						switch(count)
						{
							case 1,2:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.4);
							case 3,4:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.5);
						}
						SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
						Angles[0] = Angles[0] + GetRandomFloat(-90.0, 90.0);
						Angles[1] = Angles[1] + GetRandomFloat(-90.0, 90.0);
						Angles[2] = Angles[2] + GetRandomFloat(-90.0, 90.0);
						TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
					}
				}
			}
		}
	}
}
public Action:TrapTankTimer(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 5512570)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				new ent[5];
				for(new count=1; count<=4; count++)
				{
					ent[count] = CreateEntityByName("prop_dynamic_override");
					if(IsValidEntity(ent[count]))
					{
						decl String:tName[64];
						Format(tName, sizeof(tName), "Tank%d", client);
						DispatchKeyValue(client, "targetname", tName);
						GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

						DispatchKeyValue(ent[count], "model", "models/props_debris/concrete_chunk01a.mdl");
						SetEntityRenderColor(ent[count], 25, 25, 25, 255);
						DispatchKeyValue(ent[count], "targetname", "RockEntity");
						DispatchKeyValue(ent[count], "parentname", tName);
						DispatchKeyValueVector(ent[count], "origin", Origin);
						DispatchKeyValueVector(ent[count], "angles", Angles);
						DispatchSpawn(ent[count]);
						SetVariantString(tName);
						AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
						switch(count)
						{
							case 1:SetVariantString("relbow");
							case 2:SetVariantString("lelbow");
							case 3:SetVariantString("rshoulder");
							case 4:SetVariantString("lshoulder");
						}
						AcceptEntityInput(ent[count], "SetParentAttachment");
						AcceptEntityInput(ent[count], "Enable");
						AcceptEntityInput(ent[count], "DisableCollision");
						switch(count)
						{
							case 1,2:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.4);
							case 3,4:SetEntPropFloat(ent[count], Prop_Data, "m_flModelScale", 0.5);
						}
						SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
						Angles[0] = Angles[0] + GetRandomFloat(-90.0, 90.0);
						Angles[1] = Angles[1] + GetRandomFloat(-90.0, 90.0);
						Angles[2] = Angles[2] + GetRandomFloat(-90.0, 90.0);
						TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
					}
				}
			}
		}
	}
}
public Action:TrapTankTimer2(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 5512570)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				Angles[0] += -90.0;
				new entity = CreateEntityByName("beam_spotlight");
				if(IsValidEntity(entity))
				{
					decl String:tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(entity, "targetname", "LightEntity");
					DispatchKeyValue(entity, "parentname", tName);
					DispatchKeyValueVector(entity, "origin", Origin);
					DispatchKeyValueVector(entity, "angles", Angles);
					DispatchKeyValue(entity, "spotlightwidth", "10");
					DispatchKeyValue(entity, "spotlightlength", "60");
					DispatchKeyValue(entity, "spawnflags", "3");
					DispatchKeyValue(entity, "rendercolor", "255 255 255");
					DispatchKeyValue(entity, "renderamt", "125");
					DispatchKeyValue(entity, "maxspeed", "100");
					DispatchKeyValue(entity, "HDRColorScale", "0.7");
					DispatchKeyValue(entity, "fadescale", "1");
					DispatchKeyValue(entity, "fademindist", "-1");
					DispatchSpawn(entity);
					SetVariantString(tName);
					AcceptEntityInput(entity, "SetParent", entity, entity);
					SetVariantString("mouth");
					AcceptEntityInput(entity, "SetParentAttachment");
					AcceptEntityInput(entity, "Enable");
					AcceptEntityInput(entity, "DisableCollision");
					SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(entity, NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
		}
	}
}
public Action:JumperTankTimer(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new color = GetEntityRenderColor(client);
		if(color == 2002550)
		{
			new Float:Origin[3], Float:Angles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
			Angles[0] += 90.0;
			new ent[3];
			for(new count=1; count<=2; count++)
			{
				ent[count] = CreateEntityByName("prop_dynamic_override");
				if(IsValidEntity(ent[count]))
				{
					decl String:tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(ent[count], "model", "models/props_vehicles/tire001c_car.mdl");
					DispatchKeyValue(ent[count], "targetname", "TireEntity");
					DispatchKeyValue(ent[count], "parentname", tName);
					DispatchKeyValueVector(ent[count], "origin", Origin);
					DispatchKeyValueVector(ent[count], "angles", Angles);
					DispatchSpawn(ent[count]);
					SetVariantString(tName);
					AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
					switch(count)
					{
						case 1:SetVariantString("rfoot");
						case 2:SetVariantString("lfoot");
					}
					AcceptEntityInput(ent[count], "SetParentAttachment");
					AcceptEntityInput(ent[count], "Enable");
					AcceptEntityInput(ent[count], "DisableCollision");
					SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
		}
	}
}
public Action:PsychoticTankTimer3(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new color = GetEntityRenderColor(client);
		if(color == 000)
		{
			new Float:Origin[3], Float:Angles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
			Angles[0] += 90.0;
			new ent[3];
			for(new count=1; count<=2; count++)
			{
				ent[count] = CreateEntityByName("prop_dynamic_override");
				if(IsValidEntity(ent[count]))
				{
					decl String:tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(ent[count], "model", "models/props_vehicles/tire001c_car.mdl");
					SetEntityRenderColor(ent[count], 200, 0, 0, 255);
					DispatchKeyValue(ent[count], "targetname", "TireEntity");
					DispatchKeyValue(ent[count], "parentname", tName);
					DispatchKeyValueVector(ent[count], "origin", Origin);
					DispatchKeyValueVector(ent[count], "angles", Angles);
					DispatchSpawn(ent[count]);
					SetVariantString(tName);
					AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
					switch(count)
					{
						case 1:SetVariantString("rfoot");
						case 2:SetVariantString("lfoot");
					}
					AcceptEntityInput(ent[count], "SetParentAttachment");
					AcceptEntityInput(ent[count], "Enable");
					AcceptEntityInput(ent[count], "DisableCollision");
					SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
		}
	}
}

//Meme Tank
public Action:MemeTankTimer3(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new color = GetEntityRenderColor(client);
		if(color == 02550)
		{
			new Float:Origin[3], Float:Angles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
			Angles[0] += 90.0;
			new ent[3];
			for(new count=1; count<=2; count++)
			{
				ent[count] = CreateEntityByName("prop_dynamic_override");
				if(IsValidEntity(ent[count]))
				{
					decl String:tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(ent[count], "model", "models/props_vehicles/tire001c_car.mdl");
					SetEntityRenderColor(ent[count], 255, 0, 255, 255);
					DispatchKeyValue(ent[count], "targetname", "TireEntity");
					DispatchKeyValue(ent[count], "parentname", tName);
					DispatchKeyValueVector(ent[count], "origin", Origin);
					DispatchKeyValueVector(ent[count], "angles", Angles);
					DispatchSpawn(ent[count]);
					SetVariantString(tName);
					AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
					switch(count)
					{
						case 1:SetVariantString("rfoot");
						case 2:SetVariantString("lfoot");
					}
					AcceptEntityInput(ent[count], "SetParentAttachment");
					AcceptEntityInput(ent[count], "Enable");
					AcceptEntityInput(ent[count], "DisableCollision");
					SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
			new blackhole = CreateEntityByName("point_push");
			if(IsValidEntity(blackhole))
			{
				decl String:tName[64];
				Format(tName, sizeof(tName), "Tank%d", client);
				DispatchKeyValue(client, "targetname", tName);
				GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

				DispatchKeyValue(blackhole, "targetname", "BlackholeEntity");
				DispatchKeyValue(blackhole, "parentname", tName);
				DispatchKeyValueVector(blackhole, "origin", Origin);
				DispatchKeyValueVector(blackhole, "angles", Angles);
				DispatchKeyValue(blackhole, "radius", "750");
				DispatchKeyValueFloat(blackhole, "magnitude", flMemePullForce);
				DispatchKeyValue(blackhole, "spawnflags", "8");
				SetVariantString(tName);
				AcceptEntityInput(blackhole, "SetParent", blackhole, blackhole);
				AcceptEntityInput(blackhole, "Enable");
				SetEntProp(blackhole, Prop_Send, "m_glowColorOverride", client);
			}
		}
	}
}

//Boss Tank
public Action:BossTankTimer3(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new color = GetEntityRenderColor(client);
		if(color == 0050)
		{
			new Float:Origin[3], Float:Angles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
			Angles[0] += 90.0;
			new ent[3];
			for(new count=1; count<=2; count++)
			{
				ent[count] = CreateEntityByName("prop_dynamic_override");
				if(IsValidEntity(ent[count]))
				{
					decl String:tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(ent[count], "model", "models/props_vehicles/tire001c_car.mdl");
					SetEntityRenderColor(ent[count], 25, 25, 25, 255);
					DispatchKeyValue(ent[count], "targetname", "TireEntity");
					DispatchKeyValue(ent[count], "parentname", tName);
					DispatchKeyValueVector(ent[count], "origin", Origin);
					DispatchKeyValueVector(ent[count], "angles", Angles);
					DispatchSpawn(ent[count]);
					SetVariantString(tName);
					AcceptEntityInput(ent[count], "SetParent", ent[count], ent[count]);
					switch(count)
					{
						case 1:SetVariantString("rfoot");
						case 2:SetVariantString("lfoot");
					}
					AcceptEntityInput(ent[count], "SetParentAttachment");
					AcceptEntityInput(ent[count], "Enable");
					AcceptEntityInput(ent[count], "DisableCollision");
					SetEntProp(ent[count], Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(ent[count], NULL_VECTOR, Angles, NULL_VECTOR);
				}
			}
			new blackhole = CreateEntityByName("point_push");
			if(IsValidEntity(blackhole))
			{
				decl String:tName[64];
				Format(tName, sizeof(tName), "Tank%d", client);
				DispatchKeyValue(client, "targetname", tName);
				GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

				DispatchKeyValue(blackhole, "targetname", "BlackholeEntity");
				DispatchKeyValue(blackhole, "parentname", tName);
				DispatchKeyValueVector(blackhole, "origin", Origin);
				DispatchKeyValueVector(blackhole, "angles", Angles);
				DispatchKeyValue(blackhole, "radius", "1000");
				DispatchKeyValueFloat(blackhole, "magnitude", flBossPullForce);
				DispatchKeyValue(blackhole, "spawnflags", "8");
				SetVariantString(tName);
				AcceptEntityInput(blackhole, "SetParent", blackhole, blackhole);
				AcceptEntityInput(blackhole, "Enable");
				SetEntProp(blackhole, Prop_Send, "m_glowColorOverride", client);
			}
		}
	}
}
public Action:GravityTankTimer(Handle:timer, any:client)
{
	if(L4D2Version)
	{
		if(client > 0 && IsTank(client))
		{
			new color = GetEntityRenderColor(client);
			if(color == 333435)
			{
				new Float:Origin[3], Float:Angles[3];
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
				GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
				Angles[0] += -90.0;
				new entity = CreateEntityByName("beam_spotlight");
				if(IsValidEntity(entity))
				{
					decl String:tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(entity, "targetname", "LightEntity");
					DispatchKeyValue(entity, "parentname", tName);
					DispatchKeyValueVector(entity, "origin", Origin);
					DispatchKeyValueVector(entity, "angles", Angles);
					DispatchKeyValue(entity, "spotlightwidth", "10");
					DispatchKeyValue(entity, "spotlightlength", "60");
					DispatchKeyValue(entity, "spawnflags", "3");
					DispatchKeyValue(entity, "rendercolor", "100 100 100");
					DispatchKeyValue(entity, "renderamt", "125");
					DispatchKeyValue(entity, "maxspeed", "100");
					DispatchKeyValue(entity, "HDRColorScale", "0.7");
					DispatchKeyValue(entity, "fadescale", "1");
					DispatchKeyValue(entity, "fademindist", "-1");
					DispatchSpawn(entity);
					SetVariantString(tName);
					AcceptEntityInput(entity, "SetParent", entity, entity);
					SetVariantString("mouth");
					AcceptEntityInput(entity, "SetParentAttachment");
					AcceptEntityInput(entity, "Enable");
					AcceptEntityInput(entity, "DisableCollision");
					SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
					TeleportEntity(entity, NULL_VECTOR, Angles, NULL_VECTOR);
				}
				new blackhole = CreateEntityByName("point_push");
				if(IsValidEntity(blackhole))
				{
					decl String:tName[64];
					Format(tName, sizeof(tName), "Tank%d", client);
					DispatchKeyValue(client, "targetname", tName);
					GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

					DispatchKeyValue(blackhole, "targetname", "BlackholeEntity");
					DispatchKeyValue(blackhole, "parentname", tName);
					DispatchKeyValueVector(blackhole, "origin", Origin);
					DispatchKeyValueVector(blackhole, "angles", Angles);
					DispatchKeyValue(blackhole, "radius", "750");
					DispatchKeyValueFloat(blackhole, "magnitude", flGravityPullForce);
					DispatchKeyValue(blackhole, "spawnflags", "8");
					SetVariantString(tName);
					AcceptEntityInput(blackhole, "SetParent", blackhole, blackhole);
					AcceptEntityInput(blackhole, "Enable");
					SetEntProp(blackhole, Prop_Send, "m_glowColorOverride", client);
				}
			}
		}
	}
}
public Action:ArmageddonTankTimer2(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new color = GetEntityRenderColor(client);
		if(color == 7500)
		{
			new Float:Origin[3], Float:Angles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
			Angles[0] += -90.0;
			new blackhole = CreateEntityByName("point_push");
			if(IsValidEntity(blackhole))
			{
				decl String:tName[64];
				Format(tName, sizeof(tName), "Tank%d", client);
				DispatchKeyValue(client, "targetname", tName);
				GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

				DispatchKeyValue(blackhole, "targetname", "BlackholeEntity");
				DispatchKeyValue(blackhole, "parentname", tName);
				DispatchKeyValueVector(blackhole, "origin", Origin);
				DispatchKeyValueVector(blackhole, "angles", Angles);
				DispatchKeyValue(blackhole, "radius", "1000");
				DispatchKeyValueFloat(blackhole, "magnitude", flArmageddonPullForce);
				DispatchKeyValue(blackhole, "spawnflags", "8");
				SetVariantString(tName);
				AcceptEntityInput(blackhole, "SetParent", blackhole, blackhole);
				AcceptEntityInput(blackhole, "Enable");
				if(L4D2Version)
				{
					SetEntProp(blackhole, Prop_Send, "m_glowColorOverride", client);
				}
			}
		}
	}
}
public Action:FeedbackTankTimer(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client))
	{
		new color = GetEntityRenderColor(client);
		if(color == 906090)
		{
			new Float:Origin[3], Float:Angles[3];
			GetEntPropVector(client, Prop_Send, "m_vecOrigin", Origin);
			GetEntPropVector(client, Prop_Send, "m_angRotation", Angles);
			Angles[0] += -90.0;
			new blackhole = CreateEntityByName("point_push");
			if(IsValidEntity(blackhole))
			{
				decl String:tName[64];
				Format(tName, sizeof(tName), "Tank%d", client);
				DispatchKeyValue(client, "targetname", tName);
				GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));

				DispatchKeyValue(blackhole, "targetname", "BlackholeEntity");
				DispatchKeyValue(blackhole, "parentname", tName);
				DispatchKeyValueVector(blackhole, "origin", Origin);
				DispatchKeyValueVector(blackhole, "angles", Angles);
				DispatchKeyValue(blackhole, "radius", "1000");
				DispatchKeyValueFloat(blackhole, "magnitude", flFeedbackPushForce);
				DispatchKeyValue(blackhole, "spawnflags", "8");
				SetVariantString(tName);
				AcceptEntityInput(blackhole, "SetParent", blackhole, blackhole);
				AcceptEntityInput(blackhole, "Enable");
				if(L4D2Version)
				{
					SetEntProp(blackhole, Prop_Send, "m_glowColorOverride", client);
				}
			}
		}
	}
}
public Action:BlurEffect(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client) && TankAbility[client] == 1)
	{
		new Float:TankPos[3], Float:TankAng[3];
		GetClientAbsOrigin(client, TankPos);
		GetClientAbsAngles(client, TankAng);
		new Anim = GetEntProp(client, Prop_Send, "m_nSequence");
		new entity = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(entity))
		{
			DispatchKeyValue(entity, "model", "models/infected/hulk.mdl");
			DispatchKeyValue(entity, "solid", "6");
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "DisableCollision");
			SetEntityRenderColor(entity, 0, 105, 255, 50);
			SetEntProp(entity, Prop_Send, "m_nSequence", Anim);
			SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", 5.0);
			TeleportEntity(entity, TankPos, TankAng, NULL_VECTOR);
			CreateTimer(0.3, RemoveBlurEffect, entity, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Continue;
		}		
	}
	return Plugin_Stop;
}
public Action:RemoveBlurEffect(Handle:timer, any:entity)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if(StrEqual(classname, "prop_dynamic"))
		{
			decl String:model[128];
			GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
			if(StrEqual(model, "models/infected/hulk.mdl"))
			{
				AcceptEntityInput(entity, "Kill");
			}
		}	
	}
}
public Action:BlurEffect2(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client) && TankAbility[client] == 1)
	{
		new Float:TankPos[3], Float:TankAng[3];
		GetClientAbsOrigin(client, TankPos);
		GetClientAbsAngles(client, TankAng);
		new Anim = GetEntProp(client, Prop_Send, "m_nSequence");
		new entity = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(entity))
		{
			DispatchKeyValue(entity, "model", "models/infected/hulk.mdl");
			DispatchKeyValue(entity, "solid", "25");
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "DisableCollision");
			SetEntityRenderColor(entity, 255, 0, 0, 50);
			SetEntProp(entity, Prop_Send, "m_nSequence", Anim);
			SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", 5.0);
			TeleportEntity(entity, TankPos, TankAng, NULL_VECTOR);
			CreateTimer(0.3, RemoveBlurEffect2, entity, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Continue;
		}		
	}
	return Plugin_Stop;
}
public Action:RemoveBlurEffect2(Handle:timer, any:entity)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if(StrEqual(classname, "prop_dynamic"))
		{
			decl String:model[128];
			GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
			if(StrEqual(model, "models/infected/hulk.mdl"))
			{
				AcceptEntityInput(entity, "Kill");
			}
		}	
	}
}
public Action:BlurEffect3(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client) && TankAbility[client] == 1)
	{
		new Float:TankPos[3], Float:TankAng[3];
		GetClientAbsOrigin(client, TankPos);
		GetClientAbsAngles(client, TankAng);
		new Anim = GetEntProp(client, Prop_Send, "m_nSequence");
		new entity = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(entity))
		{
			DispatchKeyValue(entity, "model", "models/infected/hulk.mdl");
			DispatchKeyValue(entity, "solid", "25");
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "DisableCollision");
			SetEntityRenderColor(entity, 255, 255, 0, 50);
			SetEntProp(entity, Prop_Send, "m_nSequence", Anim);
			SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", 5.0);
			TeleportEntity(entity, TankPos, TankAng, NULL_VECTOR);
			CreateTimer(0.3, RemoveBlurEffect3, entity, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Continue;
		}		
	}
	return Plugin_Stop;
}
public Action:RemoveBlurEffect3(Handle:timer, any:entity)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if(StrEqual(classname, "prop_dynamic"))
		{
			decl String:model[128];
			GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
			if(StrEqual(model, "models/infected/hulk.mdl"))
			{
				AcceptEntityInput(entity, "Kill");
			}
		}	
	}
}
public Action:BlurEffect4(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client) && TankAbility[client] == 1)
	{
		new Float:TankPos[3], Float:TankAng[3];
		GetClientAbsOrigin(client, TankPos);
		GetClientAbsAngles(client, TankAng);
		new Anim = GetEntProp(client, Prop_Send, "m_nSequence");
		new entity = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(entity))
		{
			DispatchKeyValue(entity, "model", "models/infected/hulk.mdl");
			DispatchKeyValue(entity, "solid", "25");
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "DisableCollision");
			SetEntityRenderColor(entity, 1, 1, 1, 50);
			SetEntProp(entity, Prop_Send, "m_nSequence", Anim);
			SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", 5.0);
			TeleportEntity(entity, TankPos, TankAng, NULL_VECTOR);
			CreateTimer(0.3, RemoveBlurEffect4, entity, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Continue;
		}		
	}
	return Plugin_Stop;
}
public Action:RemoveBlurEffect4(Handle:timer, any:entity)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if(StrEqual(classname, "prop_dynamic"))
		{
			decl String:model[128];
			GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
			if(StrEqual(model, "models/infected/hulk.mdl"))
			{
				AcceptEntityInput(entity, "Kill");
			}
		}	
	}
}
public Action:BlurEffect5(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client) && TankAbility[client] == 1)
	{
		new Float:TankPos[3], Float:TankAng[3];
		GetClientAbsOrigin(client, TankPos);
		GetClientAbsAngles(client, TankAng);
		new Anim = GetEntProp(client, Prop_Send, "m_nSequence");
		new entity = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(entity))
		{
			DispatchKeyValue(entity, "model", "models/infected/hulk.mdl");
			DispatchKeyValue(entity, "solid", "25");
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "DisableCollision");
			SetEntityRenderColor(entity, 255, 100, 255, 50);
			SetEntProp(entity, Prop_Send, "m_nSequence", Anim);
			SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", 5.0);
			TeleportEntity(entity, TankPos, TankAng, NULL_VECTOR);
			CreateTimer(0.3, RemoveBlurEffect5, entity, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Continue;
		}		
	}
	return Plugin_Stop;
}
public Action:RemoveBlurEffect5(Handle:timer, any:entity)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if(StrEqual(classname, "prop_dynamic"))
		{
			decl String:model[128];
			GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
			if(StrEqual(model, "models/infected/hulk.mdl"))
			{
				AcceptEntityInput(entity, "Kill");
			}
		}	
	}
}

//Meme Tank
public Action:BlurEffect6(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client) && TankAbility[client] == 1)
	{
		new Float:TankPos[3], Float:TankAng[3];
		GetClientAbsOrigin(client, TankPos);
		GetClientAbsAngles(client, TankAng);
		new Anim = GetEntProp(client, Prop_Send, "m_nSequence");
		new entity = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(entity))
		{
			DispatchKeyValue(entity, "model", "models/infected/hulk.mdl");
			DispatchKeyValue(entity, "solid", "25");
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "DisableCollision");
			SetEntityRenderColor(entity, 0, 255, 0, 50);
			SetEntProp(entity, Prop_Send, "m_nSequence", Anim);
			SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", 5.0);
			TeleportEntity(entity, TankPos, TankAng, NULL_VECTOR);
			CreateTimer(0.3, RemoveBlurEffect6, entity, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Continue;
		}		
	}
	return Plugin_Stop;
}
public Action:RemoveBlurEffect6(Handle:timer, any:entity)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if(StrEqual(classname, "prop_dynamic"))
		{
			decl String:model[128];
			GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
			if(StrEqual(model, "models/infected/hulk.mdl"))
			{
				AcceptEntityInput(entity, "Kill");
			}
		}	
	}
}

//Boss Tank
public Action:BlurEffect7(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client) && TankAbility[client] == 1)
	{
		new Float:TankPos[3], Float:TankAng[3];
		GetClientAbsOrigin(client, TankPos);
		GetClientAbsAngles(client, TankAng);
		new Anim = GetEntProp(client, Prop_Send, "m_nSequence");
		new entity = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(entity))
		{
			DispatchKeyValue(entity, "model", "models/infected/hulk.mdl");
			DispatchKeyValue(entity, "solid", "25");
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "DisableCollision");
			SetEntityRenderColor(entity, 0, 0, 50, 50);
			SetEntProp(entity, Prop_Send, "m_nSequence", Anim);
			SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", 5.0);
			TeleportEntity(entity, TankPos, TankAng, NULL_VECTOR);
			CreateTimer(0.3, RemoveBlurEffect7, entity, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Continue;
		}		
	}
	return Plugin_Stop;
}
public Action:RemoveBlurEffect7(Handle:timer, any:entity)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if(StrEqual(classname, "prop_dynamic"))
		{
			decl String:model[128];
			GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
			if(StrEqual(model, "models/infected/hulk.mdl"))
			{
				AcceptEntityInput(entity, "Kill");
			}
		}	
	}
}
public Action:BlurEffect8(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client) && TankAbility[client] == 1)
	{
		new Float:TankPos[3], Float:TankAng[3];
		GetClientAbsOrigin(client, TankPos);
		GetClientAbsAngles(client, TankAng);
		new Anim = GetEntProp(client, Prop_Send, "m_nSequence");
		new entity = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(entity))
		{
			DispatchKeyValue(entity, "model", "models/infected/hulk.mdl");
			DispatchKeyValue(entity, "solid", "25");
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "DisableCollision");
			SetEntityRenderColor(entity, 0, 0, 255, 50);
			SetEntProp(entity, Prop_Send, "m_nSequence", Anim);
			SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", 5.0);
			TeleportEntity(entity, TankPos, TankAng, NULL_VECTOR);
			CreateTimer(0.3, RemoveBlurEffect8, entity, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Continue;
		}		
	}
	return Plugin_Stop;
}
public Action:RemoveBlurEffect8(Handle:timer, any:entity)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if(StrEqual(classname, "prop_dynamic"))
		{
			decl String:model[128];
			GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
			if(StrEqual(model, "models/infected/hulk.mdl"))
			{
				AcceptEntityInput(entity, "Kill");
			}
		}	
	}
}
public Action:BlurEffect9(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client) && TankAbility[client] == 1)
	{
		new Float:TankPos[3], Float:TankAng[3];
		GetClientAbsOrigin(client, TankPos);
		GetClientAbsAngles(client, TankAng);
		new Anim = GetEntProp(client, Prop_Send, "m_nSequence");
		new entity = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(entity))
		{
			DispatchKeyValue(entity, "model", "models/infected/hulk.mdl");
			DispatchKeyValue(entity, "solid", "25");
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "DisableCollision");
			SetEntityRenderColor(entity, 100, 50, 50, 50);
			SetEntProp(entity, Prop_Send, "m_nSequence", Anim);
			SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", 5.0);
			TeleportEntity(entity, TankPos, TankAng, NULL_VECTOR);
			CreateTimer(0.3, RemoveBlurEffect9, entity, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Continue;
		}		
	}
	return Plugin_Stop;
}
public Action:RemoveBlurEffect9(Handle:timer, any:entity)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if(StrEqual(classname, "prop_dynamic"))
		{
			decl String:model[128];
			GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
			if(StrEqual(model, "models/infected/hulk.mdl"))
			{
				AcceptEntityInput(entity, "Kill");
			}
		}	
	}
}
public Action:BlurEffect10(Handle:timer, any:client)
{
	if(client > 0 && IsTank(client) && TankAbility[client] == 1)
	{
		new Float:TankPos[3], Float:TankAng[3];
		GetClientAbsOrigin(client, TankPos);
		GetClientAbsAngles(client, TankAng);
		new Anim = GetEntProp(client, Prop_Send, "m_nSequence");
		new entity = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(entity))
		{
			DispatchKeyValue(entity, "model", "models/infected/hulk.mdl");
			DispatchKeyValue(entity, "solid", "25");
			DispatchSpawn(entity);
			AcceptEntityInput(entity, "DisableCollision");
			SetEntityRenderColor(entity, 25, 40, 25, 50);
			SetEntProp(entity, Prop_Send, "m_nSequence", Anim);
			SetEntPropFloat(entity, Prop_Send, "m_flPlaybackRate", 5.0);
			TeleportEntity(entity, TankPos, TankAng, NULL_VECTOR);
			CreateTimer(0.3, RemoveBlurEffect10, entity, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Continue;
		}		
	}
	return Plugin_Stop;
}
public Action:RemoveBlurEffect10(Handle:timer, any:entity)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if(StrEqual(classname, "prop_dynamic"))
		{
			decl String:model[128];
			GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
			if(StrEqual(model, "models/infected/hulk.mdl"))
			{
				AcceptEntityInput(entity, "Kill");
			}
		}	
	}
}
public SkillSmashClaw(target)
{
	new health = GetEntProp(target, Prop_Data, "m_iHealth");
	if(health > 1 && !IsPlayerIncap(target))
	{
		SetEntProp(target, Prop_Data, "m_iHealth", iSmasherMaimDamage);
		new Float:hbuffer = float(health) - float(iSmasherMaimDamage);
		if(hbuffer > 0.0)
		{
			SetEntPropFloat(target, Prop_Send, "m_healthBuffer", hbuffer);
		}
	}
	EmitSoundToAll("player/charger/hit/charger_smash_02.wav", target);
	ScreenShake(target, 30.0);
}
public SkillSmashClawKill(client, attacker)
{
	EmitSoundToAll("player/tank/voice/growl/tank_climb_01.wav", attacker);
	AttachParticle(client, PARTICLE_EXPLODE, 0.1, 0.0);
	DealDamagePlayer(client, attacker, 2, iSmasherCrushDamage);
	DealDamagePlayer(client, attacker, 2, iSmasherCrushDamage);
	CreateTimer(0.1, RemoveDeathBody, client, TIMER_FLAG_NO_MAPCHANGE);
}
public Action:RemoveDeathBody(Handle:timer, any:client)
{
	if(bSmasherRemoveBody)
	{
		if(client > 0)
		{
			if(IsClientInGame(client) && GetClientTeam(client) == 2)
			{
				new entity = -1;
				while ((entity = FindEntityByClassname(entity, "survivor_death_model")) != INVALID_ENT_REFERENCE)
				{
					new owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					if(client == owner)
					{
						AcceptEntityInput(entity, "Kill");
					}
				}
			}
		}
	}
}
public SkillArmageddonClaw(target)
{
	new health = GetEntProp(target, Prop_Data, "m_iHealth");
	if(health > 1 && !IsPlayerIncap(target))
	{
		SetEntProp(target, Prop_Data, "m_iHealth", iArmageddonMaimDamage);
		new Float:hbuffer = float(health) - float(iArmageddonMaimDamage);
		if(hbuffer > 0.0)
		{
			SetEntPropFloat(target, Prop_Send, "m_healthBuffer", hbuffer);
		}
	}
	EmitSoundToAll("player/charger/hit/charger_smash_02.wav", target);
	ScreenShake(target, 30.0);
}
public SkillArmageddonClawKill(client, attacker)
{
	EmitSoundToAll("player/tank/voice/growl/tank_climb_01.wav", attacker);
	AttachParticle(client, PARTICLE_EXPLODE, 0.1, 0.0);
	DealDamagePlayer(client, attacker, 2, iArmageddonCrushDamage);
	DealDamagePlayer(client, attacker, 2, iArmageddonCrushDamage);
	CreateTimer(0.1, RemoveDeathBody2, client, TIMER_FLAG_NO_MAPCHANGE);
}
public Action:RemoveDeathBody2(Handle:timer, any:client)
{
	if(bArmageddonRemoveBody)
	{
		if(client > 0)
		{
			if(IsClientInGame(client) && GetClientTeam(client) == 2)
			{
				new entity = -1;
				while ((entity = FindEntityByClassname(entity, "survivor_death_model")) != INVALID_ENT_REFERENCE)
				{
					new owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					if(client == owner)
					{
						AcceptEntityInput(entity, "Kill");
					}
				}
			}
		}
	}
}
public SkillTrapClaw(target)
{
	new health = GetEntProp(target, Prop_Data, "m_iHealth");
	if(health > 1 && !IsPlayerIncap(target))
	{
		SetEntProp(target, Prop_Data, "m_iHealth", iTrapMaimDamage);
		new Float:hbuffer = float(health) - float(iTrapMaimDamage);
		if(hbuffer > 0.0)
		{
			SetEntPropFloat(target, Prop_Send, "m_healthBuffer", hbuffer);
		}
	}
	EmitSoundToAll("player/charger/hit/charger_smash_02.wav", target);
	ScreenShake(target, 30.0);
}
public SkillTrapClawKill(client, attacker)
{
	EmitSoundToAll("player/tank/voice/growl/tank_climb_01.wav", attacker);
	AttachParticle(client, PARTICLE_EXPLODE, 0.1, 0.0);
	DealDamagePlayer(client, attacker, 2, iTrapCrushDamage);
	DealDamagePlayer(client, attacker, 2, iTrapCrushDamage);
	CreateTimer(0.1, RemoveDeathBody3, client, TIMER_FLAG_NO_MAPCHANGE);
}
public Action:RemoveDeathBody3(Handle:timer, any:client)
{
	if(bTrapRemoveBody)
	{
		if(client > 0)
		{
			if(IsClientInGame(client) && GetClientTeam(client) == 2)
			{
				new entity = -1;
				while ((entity = FindEntityByClassname(entity, "survivor_death_model")) != INVALID_ENT_REFERENCE)
				{
					new owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					if(client == owner)
					{
						AcceptEntityInput(entity, "Kill");
					}
				}
			}
		}
	}
}
public SkillGoliathClaw(target)
{
	new health = GetEntProp(target, Prop_Data, "m_iHealth");
	if(health > 1 && !IsPlayerIncap(target))
	{
		SetEntProp(target, Prop_Data, "m_iHealth", iGoliathMaimDamage);
		new Float:hbuffer = float(health) - float(iGoliathMaimDamage);
		if(hbuffer > 0.0)
		{
			SetEntPropFloat(target, Prop_Send, "m_healthBuffer", hbuffer);
		}
	}
	EmitSoundToAll("player/charger/hit/charger_smash_02.wav", target);
	ScreenShake(target, 30.0);
}
public SkillGoliathClawKill(client, attacker)
{
	EmitSoundToAll("player/tank/voice/growl/tank_climb_01.wav", attacker);
	AttachParticle(client, PARTICLE_EXPLODE, 0.1, 0.0);
	DealDamagePlayer(client, attacker, 2, iGoliathCrushDamage);
	DealDamagePlayer(client, attacker, 2, iGoliathCrushDamage);
	CreateTimer(0.1, RemoveDeathBody4, client, TIMER_FLAG_NO_MAPCHANGE);
}
public Action:RemoveDeathBody4(Handle:timer, any:client)
{
	if(bGoliathRemoveBody)
	{
		if(client > 0)
		{
			if(IsClientInGame(client) && GetClientTeam(client) == 2)
			{
				new entity = -1;
				while ((entity = FindEntityByClassname(entity, "survivor_death_model")) != INVALID_ENT_REFERENCE)
				{
					new owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					if(client == owner)
					{
						AcceptEntityInput(entity, "Kill");
					}
				}
			}
		}
	}
}

//Meme Tank
public SkillMemeClaw(target)
{
	new health = GetEntProp(target, Prop_Data, "m_iHealth");
	if(health > 1 && !IsPlayerIncap(target))
	{
		SetEntProp(target, Prop_Data, "m_iHealth", iMemeMaimDamage);
		new Float:hbuffer = float(health) - float(iMemeMaimDamage);
		if(hbuffer > 0.0)
		{
			SetEntPropFloat(target, Prop_Send, "m_healthBuffer", hbuffer);
		}
	}
	EmitSoundToAll("player/charger/hit/charger_smash_02.wav", target);
	ScreenShake(target, 30.0);
}
public SkillMemeClawKill(client, attacker)
{
	EmitSoundToAll("player/tank/voice/growl/tank_climb_01.wav", attacker);
	AttachParticle(client, PARTICLE_EXPLODE, 0.1, 0.0);
	DealDamagePlayer(client, attacker, 2, iMemeCrushDamage);
	DealDamagePlayer(client, attacker, 2, iMemeCrushDamage);
	CreateTimer(0.1, RemoveDeathBody5, client, TIMER_FLAG_NO_MAPCHANGE);
}
public Action:RemoveDeathBody5(Handle:timer, any:client)
{
	if(bMemeRemoveBody)
	{
		if(client > 0)
		{
			if(IsClientInGame(client) && GetClientTeam(client) == 2)
			{
				new entity = -1;
				while ((entity = FindEntityByClassname(entity, "survivor_death_model")) != INVALID_ENT_REFERENCE)
				{
					new owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					if(client == owner)
					{
						AcceptEntityInput(entity, "Kill");
					}
				}
			}
		}
	}
}

//Boss Tank
public SkillBossClaw(target)
{
	new health = GetEntProp(target, Prop_Data, "m_iHealth");
	if(health > 1 && !IsPlayerIncap(target))
	{
		SetEntProp(target, Prop_Data, "m_iHealth", iBossMaimDamage);
		new Float:hbuffer = float(health) - float(iBossMaimDamage);
		if(hbuffer > 0.0)
		{
			SetEntPropFloat(target, Prop_Send, "m_healthBuffer", hbuffer);
		}
	}
	EmitSoundToAll("player/charger/hit/charger_smash_02.wav", target);
	ScreenShake(target, 30.0);
}
public SkillBossClawKill(client, attacker)
{
	EmitSoundToAll("player/tank/voice/growl/tank_climb_01.wav", attacker);
	AttachParticle(client, PARTICLE_EXPLODE, 0.1, 0.0);
	DealDamagePlayer(client, attacker, 2, iBossCrushDamage);
	DealDamagePlayer(client, attacker, 2, iBossCrushDamage);
	CreateTimer(0.1, RemoveDeathBody6, client, TIMER_FLAG_NO_MAPCHANGE);
}
public Action:RemoveDeathBody6(Handle:timer, any:client)
{
	if(bBossRemoveBody)
	{
		if(client > 0)
		{
			if(IsClientInGame(client) && GetClientTeam(client) == 2)
			{
				new entity = -1;
				while ((entity = FindEntityByClassname(entity, "survivor_death_model")) != INVALID_ENT_REFERENCE)
				{
					new owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
					if(client == owner)
					{
						AcceptEntityInput(entity, "Kill");
					}
				}
			}
		}
	}
}
public SkillElecClaw(target, tank)
{
	if(target > 0)
	{
		if(IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target) == 2)
		{
			PlayerSpeed[target] += 3;
			new Handle:Pack = CreateDataPack();
			WritePackCell(Pack, target);
			WritePackCell(Pack, tank);
			WritePackCell(Pack, 4);
			CreateTimer(5.0, Timer_Volt, Pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			ScreenShake(target, 15.0);
			AttachParticle(target, PARTICLE_ELEC, 2.0, 30.0);
			EmitSoundToAll("ambient/energy/zap1.wav", target);
		}
	}
}
public SkillFeedbackClaw(target, tank)
{
	if(target > 0)
	{
		if(IsClientInGame(target) && IsPlayerAlive(target) && GetClientTeam(target) == 2)
		{
			PlayerSpeed[target] += 3;
			new Handle:Pack = CreateDataPack();
			WritePackCell(Pack, target);
			WritePackCell(Pack, tank);
			WritePackCell(Pack, 4);
			CreateTimer(5.0, Timer_Volt2, Pack, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			ScreenShake(target, 15.0);
			AttachParticle(target, PARTICLE_ELEC, 2.0, 30.0);
			EmitSoundToAll("ambient/energy/zap1.wav", target);
		}
	}
}
public Action:Timer_Volt(Handle:timer, any:Pack)
{
	ResetPack(Pack, false);
	new client = ReadPackCell(Pack);
	new tank = ReadPackCell(Pack);
	new amount = ReadPackCell(Pack);

	if(client > 0 && tank > 0)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2 && PlayerSpeed[client] == 0 && IsTank(tank))
		{
			if(amount > 0)
			{
				PlayerSpeed[client] += 2;
				ScreenShake(client, 2.0);
				DealDamagePlayer(client, tank, 2, iShockStunDamage);
				AttachParticle(client, PARTICLE_ELEC, 2.0, 30.0);
				new random = GetRandomInt(1,2);
				if(random == 1) 
				{
					EmitSoundToAll("ambient/energy/zap5.wav", client);
				}
				else
				{
					EmitSoundToAll("ambient/energy/zap7.wav", client);
				}
				ResetPack(Pack, true);
				WritePackCell(Pack, client);
				WritePackCell(Pack, tank);
				WritePackCell(Pack, amount - 1);
				return Plugin_Continue;
			}
		}
	}
	CloseHandle(Pack);
	return Plugin_Stop;
}
public Action:Timer_Volt2(Handle:timer, any:Pack)
{
	ResetPack(Pack, false);
	new client = ReadPackCell(Pack);
	new tank = ReadPackCell(Pack);
	new amount = ReadPackCell(Pack);

	if(client > 0 && tank > 0)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2 && PlayerSpeed[client] == 0 && IsTank(tank))
		{
			if(amount > 0)
			{
				PlayerSpeed[client] += 2;
				ScreenShake(client, 2.0);
				DealDamagePlayer(client, tank, 2, iFeedbackStunDamage);
				AttachParticle(client, PARTICLE_ELEC, 2.0, 30.0);
				new random = GetRandomInt(1,2);
				if(random == 1) 
				{
					EmitSoundToAll("ambient/energy/zap5.wav", client);
				}
				else
				{
					EmitSoundToAll("ambient/energy/zap7.wav", client);
				}
				ResetPack(Pack, true);
				WritePackCell(Pack, client);
				WritePackCell(Pack, tank);
				WritePackCell(Pack, amount - 1);
				return Plugin_Continue;
			}
		}
	}
	CloseHandle(Pack);
	return Plugin_Stop;
}
StartMeteorFall(client)
{
	TankAbility[client] = 1;
	decl Float:pos[3];
	GetClientEyePosition(client, pos);
	
	new Handle:h=CreateDataPack();
	WritePackCell(h, client);
	WritePackFloat(h, pos[0]);
	WritePackFloat(h, pos[1]);
	WritePackFloat(h, pos[2]);
	WritePackFloat(h, GetEngineTime());
	
	CreateTimer(0.6, UpdateMeteorFall, h, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}
StartArmageddonFall(client)
{
	TankAbility[client] = 1;
	decl Float:pos[3];
	GetClientEyePosition(client, pos);
	
	new Handle:h=CreateDataPack();
	WritePackCell(h, client);
	WritePackFloat(h, pos[0]);
	WritePackFloat(h, pos[1]);
	WritePackFloat(h, pos[2]);
	WritePackFloat(h, GetEngineTime());
	
	CreateTimer(0.6, UpdateArmageddonFall, h, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}
StartPsychoticFall(client)
{
	TankAbility[client] = 1;
	decl Float:pos[3];
	GetClientEyePosition(client, pos);
	
	new Handle:h=CreateDataPack();
	WritePackCell(h, client);
	WritePackFloat(h, pos[0]);
	WritePackFloat(h, pos[1]);
	WritePackFloat(h, pos[2]);
	WritePackFloat(h, GetEngineTime());
	
	CreateTimer(0.6, UpdatePsychoticFall, h, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

//Meme Tank
StartMemeFall(client)
{
	TankAbility[client] = 1;
	decl Float:pos[3];
	GetClientEyePosition(client, pos);
	
	new Handle:h=CreateDataPack();
	WritePackCell(h, client);
	WritePackFloat(h, pos[0]);
	WritePackFloat(h, pos[1]);
	WritePackFloat(h, pos[2]);
	WritePackFloat(h, GetEngineTime());
	
	CreateTimer(0.6, UpdateMemeFall, h, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

//Boss Tank
StartBossFall(client)
{
	TankAbility[client] = 1;
	decl Float:pos[3];
	GetClientEyePosition(client, pos);
	
	new Handle:h=CreateDataPack();
	WritePackCell(h, client);
	WritePackFloat(h, pos[0]);
	WritePackFloat(h, pos[1]);
	WritePackFloat(h, pos[2]);
	WritePackFloat(h, GetEngineTime());
	
	CreateTimer(0.6, UpdateBossFall, h, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}
StartSipowFall(client)
{
	TankAbility[client] = 1;
	decl Float:pos[3];
	GetClientEyePosition(client, pos);
	
	new Handle:h=CreateDataPack();
	WritePackCell(h, client);
	WritePackFloat(h, pos[0]);
	WritePackFloat(h, pos[1]);
	WritePackFloat(h, pos[2]);
	WritePackFloat(h, GetEngineTime());
	
	CreateTimer(0.6, UpdateSipowFall, h, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}
public Action:UpdateMeteorFall(Handle:timer, any:h)
{
	ResetPack(h);
	decl Float:pos[3];
	new client = ReadPackCell(h);
 	
	pos[0] = ReadPackFloat(h);
	pos[1] = ReadPackFloat(h);
	pos[2] = ReadPackFloat(h);

	new Float:time = ReadPackFloat(h);
	if((GetEngineTime() - time) > 5.0)
	{
		TankAbility[client] = 0;
	}
	new entity = -1;
	if(IsTank(client) && TankAbility[client] == 1)
	{
		decl Float:angle[3], Float:velocity[3], Float:hitpos[3];
		angle[0] = 0.0 + GetRandomFloat(-20.0, 20.0);
		angle[1] = 0.0 + GetRandomFloat(-20.0, 20.0);
		angle[2] = 60.0;
		
		GetVectorAngles(angle, angle);
		GetRayHitPos(pos, angle, hitpos, client, true);
		new Float:dis = GetVectorDistance(pos, hitpos);
		if(GetVectorDistance(pos, hitpos) > 2000.0)
		{
			dis = 1600.0;
		}
		decl Float:t[3];
		MakeVectorFromPoints(pos, hitpos, t);
		NormalizeVector(t,t);
		ScaleVector(t, dis - 40.0);
		AddVectors(pos, t, hitpos);
		
		if(dis > 100.0)
		{
			new ent = CreateEntityByName("tank_rock");
			if(ent > 0)
			{
				DispatchKeyValue(ent, "model", "models/props_debris/concrete_chunk01a.mdl"); 
				DispatchSpawn(ent);  
				decl Float:angle2[3];
				angle2[0] = GetRandomFloat(-180.0, 180.0);
				angle2[1] = GetRandomFloat(-180.0, 180.0);
				angle2[2] = GetRandomFloat(-180.0, 180.0);

				velocity[0] = GetRandomFloat(0.0, 350.0);
				velocity[1] = GetRandomFloat(0.0, 350.0);
				velocity[2] = GetRandomFloat(0.0, 30.0);

				TeleportEntity(ent, hitpos, angle2, velocity);
				ActivateEntity(ent);
	 
				AcceptEntityInput(ent, "Ignite");
				SetEntProp(ent, Prop_Send, "m_hOwnerEntity", client);
			}
		} 
	}
	else if(TankAbility[client] == 0)
	{
		while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
		{
			new ownerent = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
			if(client == ownerent)
			{
				ExplodeMeteor(entity, ownerent);
			}
		}
		CloseHandle(h);
		return Plugin_Stop;
	}
	while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
	{
		new ownerent = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
		if(client == ownerent)
		{
			if(OnGroundUnits(entity) < 200.0)
			{
				ExplodeMeteor(entity, ownerent);
			}
		}
	}
	return Plugin_Continue;	
}
public Action:UpdateArmageddonFall(Handle:timer, any:h)
{
	ResetPack(h);
	decl Float:pos[3];
	new client = ReadPackCell(h);
 	
	pos[0] = ReadPackFloat(h);
	pos[1] = ReadPackFloat(h);
	pos[2] = ReadPackFloat(h);

	new Float:time = ReadPackFloat(h);
	if((GetEngineTime() - time) > 5.0)
	{
		TankAbility[client] = 0;
	}
	new entity = -1;
	if(IsTank(client) && TankAbility[client] == 1)
	{
		decl Float:angle[3], Float:velocity[3], Float:hitpos[3];
		angle[0] = 0.0 + GetRandomFloat(-20.0, 20.0);
		angle[1] = 0.0 + GetRandomFloat(-20.0, 20.0);
		angle[2] = 60.0;
		
		GetVectorAngles(angle, angle);
		GetRayHitPos(pos, angle, hitpos, client, true);
		new Float:dis = GetVectorDistance(pos, hitpos);
		if(GetVectorDistance(pos, hitpos) > 2000.0)
		{
			dis = 1600.0;
		}
		decl Float:t[3];
		MakeVectorFromPoints(pos, hitpos, t);
		NormalizeVector(t,t);
		ScaleVector(t, dis - 40.0);
		AddVectors(pos, t, hitpos);
		
		if(dis > 100.0)
		{
			new ent = CreateEntityByName("tank_rock");
			if(ent > 0)
			{
				DispatchKeyValue(ent, "model", "models/props_debris/concrete_chunk01a.mdl"); 
				DispatchSpawn(ent);  
				decl Float:angle2[3];
				angle2[0] = GetRandomFloat(-180.0, 180.0);
				angle2[1] = GetRandomFloat(-180.0, 180.0);
				angle2[2] = GetRandomFloat(-180.0, 180.0);

				velocity[0] = GetRandomFloat(0.0, 350.0);
				velocity[1] = GetRandomFloat(0.0, 350.0);
				velocity[2] = GetRandomFloat(0.0, 30.0);

				TeleportEntity(ent, hitpos, angle2, velocity);
				ActivateEntity(ent);
	 
				AcceptEntityInput(ent, "Ignite");
				SetEntProp(ent, Prop_Send, "m_hOwnerEntity", client);
			}
		} 
	}
	else if(TankAbility[client] == 0)
	{
		while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
		{
			new ownerent = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
			if(client == ownerent)
			{
				ExplodeArmageddon(entity, ownerent);
			}
		}
		CloseHandle(h);
		return Plugin_Stop;
	}
	while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
	{
		new ownerent = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
		if(client == ownerent)
		{
			if(OnGroundUnits(entity) < 200.0)
			{
				ExplodeArmageddon(entity, ownerent);
			}
		}
	}
	return Plugin_Continue;	
}
public Action:UpdatePsychoticFall(Handle:timer, any:h)
{
	ResetPack(h);
	decl Float:pos[3];
	new client = ReadPackCell(h);
 	
	pos[0] = ReadPackFloat(h);
	pos[1] = ReadPackFloat(h);
	pos[2] = ReadPackFloat(h);

	new Float:time = ReadPackFloat(h);
	if((GetEngineTime() - time) > 5.0)
	{
		TankAbility[client] = 0;
	}
	new entity = -1;
	if(IsTank(client) && TankAbility[client] == 1)
	{
		decl Float:angle[3], Float:velocity[3], Float:hitpos[3];
		angle[0] = 0.0 + GetRandomFloat(-20.0, 20.0);
		angle[1] = 0.0 + GetRandomFloat(-20.0, 20.0);
		angle[2] = 60.0;
		
		GetVectorAngles(angle, angle);
		GetRayHitPos(pos, angle, hitpos, client, true);
		new Float:dis = GetVectorDistance(pos, hitpos);
		if(GetVectorDistance(pos, hitpos) > 2000.0)
		{
			dis = 1600.0;
		}
		decl Float:t[3];
		MakeVectorFromPoints(pos, hitpos, t);
		NormalizeVector(t,t);
		ScaleVector(t, dis - 40.0);
		AddVectors(pos, t, hitpos);
		
		if(dis > 100.0)
		{
			new ent = CreateEntityByName("tank_rock");
			if(ent > 0)
			{
				DispatchKeyValue(ent, "model", "models/props_debris/concrete_chunk01a.mdl"); 
				DispatchSpawn(ent);  
				decl Float:angle2[3];
				angle2[0] = GetRandomFloat(-180.0, 180.0);
				angle2[1] = GetRandomFloat(-180.0, 180.0);
				angle2[2] = GetRandomFloat(-180.0, 180.0);

				velocity[0] = GetRandomFloat(0.0, 350.0);
				velocity[1] = GetRandomFloat(0.0, 350.0);
				velocity[2] = GetRandomFloat(0.0, 30.0);

				TeleportEntity(ent, hitpos, angle2, velocity);
				ActivateEntity(ent);
	 
				AcceptEntityInput(ent, "Ignite");
				SetEntProp(ent, Prop_Send, "m_hOwnerEntity", client);
			}
		} 
	}
	else if(TankAbility[client] == 0)
	{
		while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
		{
			new ownerent = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
			if(client == ownerent)
			{
				ExplodePsychotic(entity, ownerent);
			}
		}
		CloseHandle(h);
		return Plugin_Stop;
	}
	while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
	{
		new ownerent = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
		if(client == ownerent)
		{
			if(OnGroundUnits(entity) < 200.0)
			{
				ExplodePsychotic(entity, ownerent);
			}
		}
	}
	return Plugin_Continue;	
}

//Meme Tank
public Action:UpdateMemeFall(Handle:timer, any:h)
{
	ResetPack(h);
	decl Float:pos[3];
	new client = ReadPackCell(h);
 	
	pos[0] = ReadPackFloat(h);
	pos[1] = ReadPackFloat(h);
	pos[2] = ReadPackFloat(h);

	new Float:time = ReadPackFloat(h);
	if((GetEngineTime() - time) > 5.0)
	{
		TankAbility[client] = 0;
	}
	new entity = -1;
	if(IsTank(client) && TankAbility[client] == 1)
	{
		decl Float:angle[3], Float:velocity[3], Float:hitpos[3];
		angle[0] = 0.0 + GetRandomFloat(-20.0, 20.0);
		angle[1] = 0.0 + GetRandomFloat(-20.0, 20.0);
		angle[2] = 60.0;
		
		GetVectorAngles(angle, angle);
		GetRayHitPos(pos, angle, hitpos, client, true);
		new Float:dis = GetVectorDistance(pos, hitpos);
		if(GetVectorDistance(pos, hitpos) > 2000.0)
		{
			dis = 1600.0;
		}
		decl Float:t[3];
		MakeVectorFromPoints(pos, hitpos, t);
		NormalizeVector(t,t);
		ScaleVector(t, dis - 40.0);
		AddVectors(pos, t, hitpos);
		
		if(dis > 100.0)
		{
			new ent = CreateEntityByName("tank_rock");
			if(ent > 0)
			{
				DispatchKeyValue(ent, "model", "models/props_debris/concrete_chunk01a.mdl"); 
				DispatchSpawn(ent);  
				decl Float:angle2[3];
				angle2[0] = GetRandomFloat(-180.0, 180.0);
				angle2[1] = GetRandomFloat(-180.0, 180.0);
				angle2[2] = GetRandomFloat(-180.0, 180.0);

				velocity[0] = GetRandomFloat(0.0, 350.0);
				velocity[1] = GetRandomFloat(0.0, 350.0);
				velocity[2] = GetRandomFloat(0.0, 30.0);

				TeleportEntity(ent, hitpos, angle2, velocity);
				ActivateEntity(ent);
	 
				AcceptEntityInput(ent, "Ignite");
				SetEntProp(ent, Prop_Send, "m_hOwnerEntity", client);
			}
		} 
	}
	else if(TankAbility[client] == 0)
	{
		while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
		{
			new ownerent = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
			if(client == ownerent)
			{
				ExplodeMeme(entity, ownerent);
			}
		}
		CloseHandle(h);
		return Plugin_Stop;
	}
	while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
	{
		new ownerent = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
		if(client == ownerent)
		{
			if(OnGroundUnits(entity) < 200.0)
			{
				ExplodeMeme(entity, ownerent);
			}
		}
	}
	return Plugin_Continue;	
}

//Boss Tank
public Action:UpdateBossFall(Handle:timer, any:h)
{
	ResetPack(h);
	decl Float:pos[3];
	new client = ReadPackCell(h);
 	
	pos[0] = ReadPackFloat(h);
	pos[1] = ReadPackFloat(h);
	pos[2] = ReadPackFloat(h);

	new Float:time = ReadPackFloat(h);
	if((GetEngineTime() - time) > 5.0)
	{
		TankAbility[client] = 0;
	}
	new entity = -1;
	if(IsTank(client) && TankAbility[client] == 1)
	{
		decl Float:angle[3], Float:velocity[3], Float:hitpos[3];
		angle[0] = 0.0 + GetRandomFloat(-20.0, 20.0);
		angle[1] = 0.0 + GetRandomFloat(-20.0, 20.0);
		angle[2] = 60.0;
		
		GetVectorAngles(angle, angle);
		GetRayHitPos(pos, angle, hitpos, client, true);
		new Float:dis = GetVectorDistance(pos, hitpos);
		if(GetVectorDistance(pos, hitpos) > 2000.0)
		{
			dis = 1600.0;
		}
		decl Float:t[3];
		MakeVectorFromPoints(pos, hitpos, t);
		NormalizeVector(t,t);
		ScaleVector(t, dis - 40.0);
		AddVectors(pos, t, hitpos);
		
		if(dis > 100.0)
		{
			new ent = CreateEntityByName("tank_rock");
			if(ent > 0)
			{
				DispatchKeyValue(ent, "model", "models/props_debris/concrete_chunk01a.mdl"); 
				DispatchSpawn(ent);  
				decl Float:angle2[3];
				angle2[0] = GetRandomFloat(-180.0, 180.0);
				angle2[1] = GetRandomFloat(-180.0, 180.0);
				angle2[2] = GetRandomFloat(-180.0, 180.0);

				velocity[0] = GetRandomFloat(0.0, 350.0);
				velocity[1] = GetRandomFloat(0.0, 350.0);
				velocity[2] = GetRandomFloat(0.0, 30.0);

				TeleportEntity(ent, hitpos, angle2, velocity);
				ActivateEntity(ent);
	 
				AcceptEntityInput(ent, "Ignite");
				SetEntProp(ent, Prop_Send, "m_hOwnerEntity", client);
			}
		} 
	}
	else if(TankAbility[client] == 0)
	{
		while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
		{
			new ownerent = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
			if(client == ownerent)
			{
				ExplodeBoss(entity, ownerent);
			}
		}
		CloseHandle(h);
		return Plugin_Stop;
	}
	while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
	{
		new ownerent = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
		if(client == ownerent)
		{
			if(OnGroundUnits(entity) < 200.0)
			{
				ExplodeBoss(entity, ownerent);
			}
		}
	}
	return Plugin_Continue;	
}
public Action:UpdateSipowFall(Handle:timer, any:h)
{
	ResetPack(h);
	decl Float:pos[3];
	new client = ReadPackCell(h);
 	
	pos[0] = ReadPackFloat(h);
	pos[1] = ReadPackFloat(h);
	pos[2] = ReadPackFloat(h);

	new Float:time = ReadPackFloat(h);
	if((GetEngineTime() - time) > 5.0)
	{
		TankAbility[client] = 0;
	}
	new entity = -1;
	if(IsTank(client) && TankAbility[client] == 1)
	{
		decl Float:angle[3], Float:velocity[3], Float:hitpos[3];
		angle[0] = 0.0 + GetRandomFloat(-20.0, 20.0);
		angle[1] = 0.0 + GetRandomFloat(-20.0, 20.0);
		angle[2] = 60.0;
		
		GetVectorAngles(angle, angle);
		GetRayHitPos(pos, angle, hitpos, client, true);
		new Float:dis = GetVectorDistance(pos, hitpos);
		if(GetVectorDistance(pos, hitpos) > 2000.0)
		{
			dis = 1600.0;
		}
		decl Float:t[3];
		MakeVectorFromPoints(pos, hitpos, t);
		NormalizeVector(t,t);
		ScaleVector(t, dis - 40.0);
		AddVectors(pos, t, hitpos);
		
		if(dis > 100.0)
		{
			new ent = CreateEntityByName("tank_rock");
			if(ent > 0)
			{
				DispatchKeyValue(ent, "model", "models/props_debris/concrete_chunk01a.mdl"); 
				DispatchSpawn(ent);  
				decl Float:angle2[3];
				angle2[0] = GetRandomFloat(-180.0, 180.0);
				angle2[1] = GetRandomFloat(-180.0, 180.0);
				angle2[2] = GetRandomFloat(-180.0, 180.0);

				velocity[0] = GetRandomFloat(0.0, 350.0);
				velocity[1] = GetRandomFloat(0.0, 350.0);
				velocity[2] = GetRandomFloat(0.0, 30.0);

				TeleportEntity(ent, hitpos, angle2, velocity);
				ActivateEntity(ent);
	 
				AcceptEntityInput(ent, "Ignite");
				SetEntProp(ent, Prop_Send, "m_hOwnerEntity", client);
			}
		} 
	}
	else if(TankAbility[client] == 0)
	{
		while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
		{
			new ownerent = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
			if(client == ownerent)
			{
				ExplodeSipow(entity, ownerent);
			}
		}
		CloseHandle(h);
		return Plugin_Stop;
	}
	while ((entity = FindEntityByClassname(entity, "tank_rock")) != INVALID_ENT_REFERENCE)
	{
		new ownerent = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
		if(client == ownerent)
		{
			if(OnGroundUnits(entity) < 200.0)
			{
				ExplodeMeteor(entity, ownerent);
			}
		}
	}
	return Plugin_Continue;	
}
public Float:OnGroundUnits(i_Ent)
{
	if(!(GetEntityFlags(i_Ent) & (FL_ONGROUND)))
	{ 
		decl Handle:h_Trace, Float:f_Origin[3], Float:f_Position[3], Float:f_Down[3] = { 90.0, 0.0, 0.0 };
		
		GetEntPropVector(i_Ent, Prop_Send, "m_vecOrigin", f_Origin);
		h_Trace = TR_TraceRayFilterEx(f_Origin, f_Down, CONTENTS_SOLID|CONTENTS_MOVEABLE, RayType_Infinite, TraceRayDontHitSelfAndLive, i_Ent);

		if(TR_DidHit(h_Trace))
		{
			decl Float:f_Units;
			TR_GetEndPosition(f_Position, h_Trace);
			
			f_Units = f_Origin[2] - f_Position[2];

			CloseHandle(h_Trace);
			
			return f_Units;
		}
		CloseHandle(h_Trace);
	} 
	
	return 0.0;
}
stock GetRayHitPos(Float:pos[3], Float:angle[3], Float:hitpos[3], ent=0, bool:useoffset=false)
{
	new Handle:trace;
	new hit=0;
	
	trace= TR_TraceRayFilterEx(pos, angle, MASK_SOLID, RayType_Infinite, TraceRayDontHitSelfAndLive, ent);
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(hitpos, trace);
		hit=TR_GetEntityIndex( trace);
	}
	CloseHandle(trace);
	
	if(useoffset)
	{
		decl Float:v[3];
		MakeVectorFromPoints(hitpos, pos, v);
		NormalizeVector(v, v);
		ScaleVector(v, 15.0);
		AddVectors(hitpos, v, hitpos);
	}
	return hit;
}
stock ExplodeMeteor(entity, client)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[16];
		GetEdictClassname(entity, classname, 16);
		if(!StrEqual(classname, "tank_rock", true))
		{
			return;
		}

		new Float:pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);	
		pos[2]+=50.0;
		AcceptEntityInput(entity, "Kill");
	
		new ent = CreateEntityByName("prop_physics"); 		
		DispatchKeyValue(ent, "model", "models/props_junk/propanecanister001a.mdl"); 
		DispatchSpawn(ent); 
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		ActivateEntity(ent);
		AcceptEntityInput(ent, "Break");

		new pointHurt = CreateEntityByName("point_hurt");   
		DispatchKeyValueFloat(pointHurt, "Damage", flMeteorStormDamage);     
		DispatchKeyValue(pointHurt, "DamageType", "2");  
		DispatchKeyValue(pointHurt, "DamageDelay", "0.0");
		DispatchKeyValueFloat(pointHurt, "DamageRadius", 200.0);  
		DispatchSpawn(pointHurt);
		TeleportEntity(pointHurt, pos, NULL_VECTOR, NULL_VECTOR);
		if(IsValidEntity(client) && IsTank(client))
		{
			AcceptEntityInput(pointHurt, "Hurt", client);
		}
		CreateTimer(0.1, DeletePointHurt, pointHurt, TIMER_FLAG_NO_MAPCHANGE); 
		
		new push = CreateEntityByName("point_push");         
  		DispatchKeyValueFloat (push, "magnitude", 600.0);                     
		DispatchKeyValueFloat (push, "radius", 200.0*1.0);                     
  		SetVariantString("spawnflags 24");                     
		AcceptEntityInput(push, "AddOutput");
 		DispatchSpawn(push);   
		TeleportEntity(push, pos, NULL_VECTOR, NULL_VECTOR);  
 		AcceptEntityInput(push, "Enable", -1, -1);
		CreateTimer(0.5, DeletePushForce, push, TIMER_FLAG_NO_MAPCHANGE);
	}
}
stock ExplodeArmageddon(entity, client)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[16];
		GetEdictClassname(entity, classname, 16);
		if(!StrEqual(classname, "tank_rock", true))
		{
			return;
		}

		new Float:pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);	
		pos[2]+=50.0;
		AcceptEntityInput(entity, "Kill");
	
		new ent = CreateEntityByName("prop_physics"); 		
		DispatchKeyValue(ent, "model", "models/props_junk/propanecanister001a.mdl"); 
		DispatchSpawn(ent); 
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		ActivateEntity(ent);
		AcceptEntityInput(ent, "Break");

		new pointHurt = CreateEntityByName("point_hurt");   
		DispatchKeyValueFloat(pointHurt, "Damage", flArmageddonStormDamage);     
		DispatchKeyValue(pointHurt, "DamageType", "2");  
		DispatchKeyValue(pointHurt, "DamageDelay", "0.0");
		DispatchKeyValueFloat(pointHurt, "DamageRadius", 200.0);  
		DispatchSpawn(pointHurt);
		TeleportEntity(pointHurt, pos, NULL_VECTOR, NULL_VECTOR);
		if(IsValidEntity(client) && IsTank(client))
		{
			AcceptEntityInput(pointHurt, "Hurt", client);
		}
		CreateTimer(0.1, DeletePointHurt, pointHurt, TIMER_FLAG_NO_MAPCHANGE); 
		
		new push = CreateEntityByName("point_push");         
  		DispatchKeyValueFloat (push, "magnitude", 600.0);                     
		DispatchKeyValueFloat (push, "radius", 200.0*1.0);                     
  		SetVariantString("spawnflags 24");                     
		AcceptEntityInput(push, "AddOutput");
 		DispatchSpawn(push);   
		TeleportEntity(push, pos, NULL_VECTOR, NULL_VECTOR);  
 		AcceptEntityInput(push, "Enable", -1, -1);
		CreateTimer(0.5, DeletePushForce, push, TIMER_FLAG_NO_MAPCHANGE);
	}
}
stock ExplodePsychotic(entity, client)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[16];
		GetEdictClassname(entity, classname, 16);
		if(!StrEqual(classname, "tank_rock", true))
		{
			return;
		}

		new Float:pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);	
		pos[2]+=50.0;
		AcceptEntityInput(entity, "Kill");
	
		new ent = CreateEntityByName("prop_physics"); 		
		DispatchKeyValue(ent, "model", "models/props_junk/propanecanister001a.mdl"); 
		DispatchSpawn(ent); 
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		ActivateEntity(ent);
		AcceptEntityInput(ent, "Break");

		new pointHurt = CreateEntityByName("point_hurt");   
		DispatchKeyValueFloat(pointHurt, "Damage", flPsychoticStormDamage);     
		DispatchKeyValue(pointHurt, "DamageType", "2");  
		DispatchKeyValue(pointHurt, "DamageDelay", "0.0");
		DispatchKeyValueFloat(pointHurt, "DamageRadius", 200.0);  
		DispatchSpawn(pointHurt);
		TeleportEntity(pointHurt, pos, NULL_VECTOR, NULL_VECTOR);
		if(IsValidEntity(client) && IsTank(client))
		{
			AcceptEntityInput(pointHurt, "Hurt", client);
		}
		CreateTimer(0.1, DeletePointHurt, pointHurt, TIMER_FLAG_NO_MAPCHANGE); 
		
		new push = CreateEntityByName("point_push");         
  		DispatchKeyValueFloat (push, "magnitude", 600.0);                     
		DispatchKeyValueFloat (push, "radius", 200.0*1.0);                     
  		SetVariantString("spawnflags 24");                     
		AcceptEntityInput(push, "AddOutput");
 		DispatchSpawn(push);   
		TeleportEntity(push, pos, NULL_VECTOR, NULL_VECTOR);  
 		AcceptEntityInput(push, "Enable", -1, -1);
		CreateTimer(0.5, DeletePushForce, push, TIMER_FLAG_NO_MAPCHANGE);
	}
}

//Meme Tank
stock ExplodeMeme(entity, client)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[16];
		GetEdictClassname(entity, classname, 16);
		if(!StrEqual(classname, "tank_rock", true))
		{
			return;
		}

		new Float:pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);	
		pos[2]+=50.0;
		AcceptEntityInput(entity, "Kill");
	
		new ent = CreateEntityByName("prop_physics"); 		
		DispatchKeyValue(ent, "model", "models/props_junk/propanecanister001a.mdl"); 
		DispatchSpawn(ent); 
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		ActivateEntity(ent);
		AcceptEntityInput(ent, "Break");

		new pointHurt = CreateEntityByName("point_hurt");   
		DispatchKeyValueFloat(pointHurt, "Damage", flMemeStormDamage);     
		DispatchKeyValue(pointHurt, "DamageType", "2");  
		DispatchKeyValue(pointHurt, "DamageDelay", "0.0");
		DispatchKeyValueFloat(pointHurt, "DamageRadius", 200.0);  
		DispatchSpawn(pointHurt);
		TeleportEntity(pointHurt, pos, NULL_VECTOR, NULL_VECTOR);
		if(IsValidEntity(client) && IsTank(client))
		{
			AcceptEntityInput(pointHurt, "Hurt", client);
		}
		CreateTimer(0.1, DeletePointHurt, pointHurt, TIMER_FLAG_NO_MAPCHANGE); 
		
		new push = CreateEntityByName("point_push");         
  		DispatchKeyValueFloat (push, "magnitude", 600.0);                     
		DispatchKeyValueFloat (push, "radius", 200.0*1.0);                     
  		SetVariantString("spawnflags 24");                     
		AcceptEntityInput(push, "AddOutput");
 		DispatchSpawn(push);   
		TeleportEntity(push, pos, NULL_VECTOR, NULL_VECTOR);  
 		AcceptEntityInput(push, "Enable", -1, -1);
		CreateTimer(0.5, DeletePushForce, push, TIMER_FLAG_NO_MAPCHANGE);
	}
}

//Boss Tank
stock ExplodeBoss(entity, client)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[16];
		GetEdictClassname(entity, classname, 16);
		if(!StrEqual(classname, "tank_rock", true))
		{
			return;
		}

		new Float:pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);	
		pos[2]+=50.0;
		AcceptEntityInput(entity, "Kill");
	
		new ent = CreateEntityByName("prop_physics"); 		
		DispatchKeyValue(ent, "model", "models/props_junk/propanecanister001a.mdl"); 
		DispatchSpawn(ent); 
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		ActivateEntity(ent);
		AcceptEntityInput(ent, "Break");

		new pointHurt = CreateEntityByName("point_hurt");   
		DispatchKeyValueFloat(pointHurt, "Damage", flBossStormDamage);     
		DispatchKeyValue(pointHurt, "DamageType", "2");  
		DispatchKeyValue(pointHurt, "DamageDelay", "0.0");
		DispatchKeyValueFloat(pointHurt, "DamageRadius", 200.0);  
		DispatchSpawn(pointHurt);
		TeleportEntity(pointHurt, pos, NULL_VECTOR, NULL_VECTOR);
		if(IsValidEntity(client) && IsTank(client))
		{
			AcceptEntityInput(pointHurt, "Hurt", client);
		}
		CreateTimer(0.1, DeletePointHurt, pointHurt, TIMER_FLAG_NO_MAPCHANGE); 
		
		new push = CreateEntityByName("point_push");         
  		DispatchKeyValueFloat (push, "magnitude", 600.0);                     
		DispatchKeyValueFloat (push, "radius", 200.0*1.0);                     
  		SetVariantString("spawnflags 24");                     
		AcceptEntityInput(push, "AddOutput");
 		DispatchSpawn(push);   
		TeleportEntity(push, pos, NULL_VECTOR, NULL_VECTOR);  
 		AcceptEntityInput(push, "Enable", -1, -1);
		CreateTimer(0.5, DeletePushForce, push, TIMER_FLAG_NO_MAPCHANGE);
	}
}
stock ExplodeSipow(entity, client)
{
	if(IsValidEntity(entity))
	{
		decl String:classname[16];
		GetEdictClassname(entity, classname, 16);
		if(!StrEqual(classname, "tank_rock", true))
		{
			return;
		}

		new Float:pos[3];
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);	
		pos[2]+=50.0;
		AcceptEntityInput(entity, "Kill");
	
		new ent = CreateEntityByName("prop_physics"); 		
		DispatchKeyValue(ent, "model", "models/props_junk/propanecanister001a.mdl"); 
		DispatchSpawn(ent); 
		TeleportEntity(ent, pos, NULL_VECTOR, NULL_VECTOR);
		ActivateEntity(ent);
		AcceptEntityInput(ent, "Break");

		new pointHurt = CreateEntityByName("point_hurt");   
		DispatchKeyValueFloat(pointHurt, "Damage", flSipowStormDamage);     
		DispatchKeyValue(pointHurt, "DamageType", "2");  
		DispatchKeyValue(pointHurt, "DamageDelay", "0.0");
		DispatchKeyValueFloat(pointHurt, "DamageRadius", 200.0);  
		DispatchSpawn(pointHurt);
		TeleportEntity(pointHurt, pos, NULL_VECTOR, NULL_VECTOR);
		if(IsValidEntity(client) && IsTank(client))
		{
			AcceptEntityInput(pointHurt, "Hurt", client);
		}
		CreateTimer(0.1, DeletePointHurt, pointHurt, TIMER_FLAG_NO_MAPCHANGE); 
		
		new push = CreateEntityByName("point_push");         
  		DispatchKeyValueFloat (push, "magnitude", 600.0);                     
		DispatchKeyValueFloat (push, "radius", 200.0*1.0);                     
  		SetVariantString("spawnflags 24");                     
		AcceptEntityInput(push, "AddOutput");
 		DispatchSpawn(push);   
		TeleportEntity(push, pos, NULL_VECTOR, NULL_VECTOR);  
 		AcceptEntityInput(push, "Enable", -1, -1);
		CreateTimer(0.5, DeletePushForce, push, TIMER_FLAG_NO_MAPCHANGE);
	}
}
public Action:DeletePushForce(Handle:timer, any:ent)
{
	 if(IsValidEntity(ent))
	 {
	 	decl String:classname[64];
		GetEdictClassname(ent, classname, sizeof(classname));
		if(StrEqual(classname, "point_push", false))
		{
			AcceptEntityInput(ent, "Kill"); 
		}
	 }
}
public Action:DeletePointHurt(Handle:timer, any:ent)
{
	 if(IsValidEntity(ent))
	 {
		decl String:classname[64];
		GetEdictClassname(ent, classname, sizeof(classname));
		if(StrEqual(classname, "point_hurt", false))
		{
			AcceptEntityInput(ent, "Kill"); 
		}
	 }
}
public bool:TraceRayDontHitSelfAndLive(entity, mask, any:data)
{
	if(entity == data) 
	{
		return false; 
	}
	else if(entity>0 && entity<=MaxClients)
	{
		if(IsClientInGame(entity))
		{
			return false;
		}
	}
	return true;
}
stock ExecTankDeath(client)
{
	TankAlive[client] = 0;
	TankAbility[client] = 0;

	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "prop_dynamic")) != INVALID_ENT_REFERENCE)
	{
		decl String:model[128];
            	GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
		if(StrEqual(model, "models/props_debris/concrete_chunk01a.mdl"))
		{
			new owner = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
			if(owner == client)
			{
				AcceptEntityInput(entity, "Kill");
			}
		}
		else if(StrEqual(model, "models/props_vehicles/tire001c_car.mdl"))
		{
			new owner = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
			if(owner == client)
			{
				AcceptEntityInput(entity, "Kill");
			}
		}
		else if(StrEqual(model, "models/props_unique/airport/atlas_break_ball.mdl"))
		{
			new owner = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
			if(owner == client)
			{
				AcceptEntityInput(entity, "Kill");
			}
		}
	}
	while ((entity = FindEntityByClassname(entity, "beam_spotlight")) != INVALID_ENT_REFERENCE)
	{
		new owner = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
		if(owner == client)
		{
			AcceptEntityInput(entity, "Kill");
		}
	}
	while ((entity = FindEntityByClassname(entity, "point_push")) != INVALID_ENT_REFERENCE)
	{
		if(L4D2Version)
		{
			new owner = GetEntProp(entity, Prop_Send, "m_glowColorOverride");
			if(owner == client)
			{
				AcceptEntityInput(entity, "Kill");
			}
		}
	}
	switch(iTankWave)
	{
		case 1: CreateTimer(5.0, TimerTankWave2, _, TIMER_FLAG_NO_MAPCHANGE);
		case 2: CreateTimer(5.0, TimerTankWave3, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}
public Action:TimerTankWave2(Handle:timer)
{
	CountTanks();
	if(iNumTanks == 0)
	{
		iTankWave = 2;
	}
}
public Action:TimerTankWave3(Handle:timer)
{
	CountTanks();
	if(iNumTanks == 0)
	{
		iTankWave = 3;
	}
}
public Action:SpawnTankTimer(Handle:timer)
{
	CountTanks();
	if(iTankWave == 1)
	{
		if(iNumTanks < iWave1Cvar)
		{
			new bot = CreateFakeClient("Tank");
			if(bot > 0)
			{
				SpawnInfected(bot, 8, true);
			}
		}
	}
	else if(iTankWave == 2)
	{
		if(iNumTanks < iWave2Cvar)
		{
			new bot = CreateFakeClient("Tank");
			if(bot > 0)
			{
				SpawnInfected(bot, 8, true);
			}
		}
	}
	else if(iTankWave == 3)
	{
		if(iNumTanks < iWave3Cvar)
		{
			new bot = CreateFakeClient("Tank");
			if(bot > 0)
			{
				SpawnInfected(bot, 8, true);
			}
		}
	}
}
public Action:Timer_UnFreeze(Handle:timer, any:client)
{
	if(client > 0)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 2)
		{
			SetEntityRenderMode(client, RenderMode:3);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			SetEntityMoveType(client, MOVETYPE_WALK);
		}
	}
}
public Action:Timer_ResetGravity(Handle:timer, any:client)
{
	if(client > 0)
	{
		if(IsClientInGame(client))
		{
			SetEntityGravity(client, 1.0);
		}
	}
}
public Action:Timer_AttachSPAWN(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 7595105)
	{
		AttachParticle(client, PARTICLE_SPAWN, 1.2, 0.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachSMOKE(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 12085120)
	{
		AttachParticle(client, PARTICLE_SPAWN, 1.2, 0.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

//Meme Tank
public Action:Timer_AttachMEME(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 02550)
	{
		AttachParticle(client, PARTICLE_SPAWN, 1.2, 0.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

//Boss Tank
public Action:Timer_AttachBOSS(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 0050)
	{
		AttachParticle(client, PARTICLE_SPAWN, 1.2, 0.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachFIRE(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 12800)
	{
		AttachParticle(client, PARTICLE_FIRE, 0.8, 0.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

//Meme Tank
public Action:Timer_AttachFIRE2(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 02550)
	{
		AttachParticle(client, PARTICLE_FIRE, 0.8, 0.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

//Boss Tank
public Action:Timer_AttachFIRE3(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 0050)
	{
		AttachParticle(client, PARTICLE_FIRE, 0.8, 0.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachFIRE_Rock(Handle:timer, any:entity)
{
	if(IsValidEntity(entity))
	{
		decl String: classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if(StrEqual(classname, "tank_rock"))
		{
			IgniteEntity(entity, 100.0);
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}
public Action:Timer_AttachICE(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 0100170)
	{
		AttachParticle(client, PARTICLE_ICE, 2.0, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

//Meme Tank
public Action:Timer_AttachICE2(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 02550)
	{
		AttachParticle(client, PARTICLE_ICE, 2.0, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

//Boss Tank
public Action:Timer_AttachICE3(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 0050)
	{
		AttachParticle(client, PARTICLE_ICE, 2.0, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_SpitSound(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 12115128)
	{
		EmitSoundToAll("player/spitter/voice/warn/spitter_spit_02.wav", client);
	}
}
public Action:Timer_SpitSound2(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 0255125)
	{
		EmitSoundToAll("player/spitter/voice/warn/spitter_spit_02.wav", client);
	}
}
public Action:Timer_AttachSPIT(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 12115128)
	{
		AttachParticle(client, PARTICLE_SPIT, 2.0, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachSPIT2(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 0255125)
	{
		AttachParticle(client, PARTICLE_SPIT, 2.0, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachSPIT_Rock(Handle:timer, any:entity)
{
	if(IsValidEntity(entity))
	{
		decl String: classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if(StrEqual(classname, "tank_rock"))
		{
			AttachParticle(entity, PARTICLE_SPITPROJ, 0.8, 0.0);
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}
public Action:Timer_AttachELEC(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 100165255)
	{
		AttachParticle(client, PARTICLE_ELEC, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachELEC2(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 25500)
	{
		AttachParticle(client, PARTICLE_ELEC, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachELEC3(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 2552550)
	{
		AttachParticle(client, PARTICLE_ELEC, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachELEC4(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 906090)
	{
		AttachParticle(client, PARTICLE_ELEC, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachELEC5(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 000)
	{
		AttachParticle(client, PARTICLE_ELEC, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachELEC6(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 111)
	{
		AttachParticle(client, PARTICLE_ELEC, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachELEC7(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 255100255)
	{
		AttachParticle(client, PARTICLE_ELEC, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

//Meme Tank
public Action:Timer_AttachELEC8(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 02550)
	{
		AttachParticle(client, PARTICLE_ELEC, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

//Boss Tank
public Action:Timer_AttachELEC9(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 0050)
	{
		AttachParticle(client, PARTICLE_ELEC, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachELEC10(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 00255)
	{
		AttachParticle(client, PARTICLE_ELEC, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachELEC11(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 1005050)
	{
		AttachParticle(client, PARTICLE_ELEC, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachELEC12(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 254025)
	{
		AttachParticle(client, PARTICLE_ELEC, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachELEC_Rock(Handle:timer, any:entity)
{
	if(IsValidEntity(entity))
	{
		decl String: classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if(StrEqual(classname, "tank_rock"))
		{
			AttachParticle(entity, PARTICLE_ELEC, 0.8, 0.0);
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}
public Action:Timer_AttachELEC_Rock2(Handle:timer, any:entity)
{
	if(IsValidEntity(entity))
	{
		decl String: classname[32];
		GetEdictClassname(entity, classname, sizeof(classname));
		if(StrEqual(classname, "tank_rock"))
		{
			AttachParticle(entity, PARTICLE_ELEC, 0.8, 0.0);
			return Plugin_Continue;
		}
	}
	return Plugin_Stop;
}
public Action:Timer_AttachBLOOD(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 255200255)
	{
		AttachParticle(client, PARTICLE_BLOOD, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

//Meme Tank
public Action:Timer_AttachBLOOD2(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 02550)
	{
		AttachParticle(client, PARTICLE_BLOOD, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

//Boss Tank
public Action:Timer_AttachBLOOD3(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 0050)
	{
		AttachParticle(client, PARTICLE_BLOOD, 0.8, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachMETEOR(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 1002525)
	{
		AttachParticle(client, PARTICLE_METEOR, 6.0, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachARMAGEDDON(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 7500)
	{
		AttachParticle(client, PARTICLE_METEOR, 6.0, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachPSYCHOTIC(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 000)
	{
		AttachParticle(client, PARTICLE_METEOR, 6.0, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

//Meme Tank
public Action:Timer_AttachMEME2(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 02550)
	{
		AttachParticle(client, PARTICLE_METEOR, 6.0, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}

//Boss Tank
public Action:Timer_AttachBOSS2(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 0050)
	{
		AttachParticle(client, PARTICLE_METEOR, 6.0, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:Timer_AttachSIPOW(Handle:timer, any:client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 0255125)
	{
		AttachParticle(client, PARTICLE_METEOR, 6.0, 30.0);
		return Plugin_Continue;
	}
	return Plugin_Stop;
}
public Action:ActivateShieldTimer(Handle:timer, any:client)
{
	ActivateShield(client);
}
public Action:ActivateShieldTimer2(Handle:timer, any:client)
{
	ActivateShield2(client);
}
public Action:ActivateShieldTimer3(Handle:timer, any:client)
{
	ActivateShield3(client);
}

//Boss Tank
public Action:ActivateShieldTimer4(Handle:timer, any:client)
{
	ActivateShield4(client);
}
stock ActivateShield(client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 135205255 && ShieldsUp[client] == 0)
	{
		decl Float:Origin[3];
		GetClientAbsOrigin(client, Origin);
		Origin[2] -= 120.0;
		new entity = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(entity))
		{
			decl String:tName[64];
			Format(tName, sizeof(tName), "Tank%d", client);
			DispatchKeyValue(client, "targetname", tName);
			GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));
			DispatchKeyValue(entity, "targetname", "Player");
			DispatchKeyValue(entity, "parentname", tName);
			DispatchKeyValue(entity, "model", "models/props_unique/airport/atlas_break_ball.mdl");
			DispatchKeyValueVector(entity, "origin", Origin);
			DispatchSpawn(entity);
			SetVariantString(tName);
			AcceptEntityInput(entity, "SetParent", entity, entity);
			SetEntityRenderMode(entity, RenderMode:3);
      	 		SetEntityRenderColor(entity, 25, 125, 125, 50);
			SetEntData(entity, GetEntSendPropOffs(entity, "m_CollisionGroup"), 1, 1, true);
			SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
		}
		ShieldsUp[client] = 1;
	}
}
stock ActivateShield2(client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 000 && ShieldsUp[client] == 0)
	{
		decl Float:Origin[3];
		GetClientAbsOrigin(client, Origin);
		Origin[2] -= 120.0;
		new entity = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(entity))
		{
			decl String:tName[64];
			Format(tName, sizeof(tName), "Tank%d", client);
			DispatchKeyValue(client, "targetname", tName);
			GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));
			DispatchKeyValue(entity, "targetname", "Player");
			DispatchKeyValue(entity, "parentname", tName);
			DispatchKeyValue(entity, "model", "models/props_unique/airport/atlas_break_ball.mdl");
			DispatchKeyValueVector(entity, "origin", Origin);
			DispatchSpawn(entity);
			SetVariantString(tName);
			AcceptEntityInput(entity, "SetParent", entity, entity);
			SetEntityRenderMode(entity, RenderMode:3);
      	 		SetEntityRenderColor(entity, 175, 60, 80, 50);
			SetEntData(entity, GetEntSendPropOffs(entity, "m_CollisionGroup"), 1, 1, true);
			SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
		}
		ShieldsUp[client] = 1;
	}
}
stock ActivateShield3(client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 00100 && ShieldsUp[client] == 0)
	{
		decl Float:Origin[3];
		GetClientAbsOrigin(client, Origin);
		Origin[2] -= 120.0;
		new entity = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(entity))
		{
			decl String:tName[64];
			Format(tName, sizeof(tName), "Tank%d", client);
			DispatchKeyValue(client, "targetname", tName);
			GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));
			DispatchKeyValue(entity, "targetname", "Player");
			DispatchKeyValue(entity, "parentname", tName);
			DispatchKeyValue(entity, "model", "models/props_unique/airport/atlas_break_ball.mdl");
			DispatchKeyValueVector(entity, "origin", Origin);
			DispatchSpawn(entity);
			SetVariantString(tName);
			AcceptEntityInput(entity, "SetParent", entity, entity);
			SetEntityRenderMode(entity, RenderMode:3);
      	 		SetEntityRenderColor(entity, 90, 85, 165, 50);
			SetEntData(entity, GetEntSendPropOffs(entity, "m_CollisionGroup"), 1, 1, true);
			SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
		}
		ShieldsUp[client] = 1;
	}
}

//Boss Tank
stock ActivateShield4(client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 0050 && ShieldsUp[client] == 0)
	{
		decl Float:Origin[3];
		GetClientAbsOrigin(client, Origin);
		Origin[2] -= 120.0;
		new entity = CreateEntityByName("prop_dynamic");
		if(IsValidEntity(entity))
		{
			decl String:tName[64];
			Format(tName, sizeof(tName), "Tank%d", client);
			DispatchKeyValue(client, "targetname", tName);
			GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));
			DispatchKeyValue(entity, "targetname", "Player");
			DispatchKeyValue(entity, "parentname", tName);
			DispatchKeyValue(entity, "model", "models/props_unique/airport/atlas_break_ball.mdl");
			DispatchKeyValueVector(entity, "origin", Origin);
			DispatchSpawn(entity);
			SetVariantString(tName);
			AcceptEntityInput(entity, "SetParent", entity, entity);
			SetEntityRenderMode(entity, RenderMode:3);
      	 		SetEntityRenderColor(entity, 0, 175, 255, 50);
			SetEntData(entity, GetEntSendPropOffs(entity, "m_CollisionGroup"), 1, 1, true);
			SetEntProp(entity, Prop_Send, "m_hOwnerEntity", client);
		}
		ShieldsUp[client] = 1;
	}
}
stock DeactivateShield(client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 135205255 && ShieldsUp[client] == 1)
	{
		new entity = -1;
		while ((entity = FindEntityByClassname(entity, "prop_dynamic")) != INVALID_ENT_REFERENCE)
		{
			decl String:model[128];
            		GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
			if(StrEqual(model, "models/props_unique/airport/atlas_break_ball.mdl"))
			{
				new owner = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
				if(owner == client)
				{
					AcceptEntityInput(entity, "Kill");
				}
			}
		}
		CreateTimer(flShieldShieldsDownInterval, ActivateShieldTimer, client, TIMER_FLAG_NO_MAPCHANGE);
		ShieldsUp[client] = 0;
	}
}
stock DeactivateShield2(client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 000 && ShieldsUp[client] == 1)
	{
		new entity = -1;
		while ((entity = FindEntityByClassname(entity, "prop_dynamic")) != INVALID_ENT_REFERENCE)
		{
			decl String:model[128];
            		GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
			if(StrEqual(model, "models/props_unique/airport/atlas_break_ball.mdl"))
			{
				new owner = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
				if(owner == client)
				{
					AcceptEntityInput(entity, "Kill");
				}
			}
		}
		CreateTimer(flPsychoticShieldsDownInterval, ActivateShieldTimer2, client, TIMER_FLAG_NO_MAPCHANGE);
		ShieldsUp[client] = 0;
	}
}
stock DeactivateShield3(client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 00100 && ShieldsUp[client] == 1)
	{
		new entity = -1;
		while ((entity = FindEntityByClassname(entity, "prop_dynamic")) != INVALID_ENT_REFERENCE)
		{
			decl String:model[128];
            		GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
			if(StrEqual(model, "models/props_unique/airport/atlas_break_ball.mdl"))
			{
				new owner = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
				if(owner == client)
				{
					AcceptEntityInput(entity, "Kill");
				}
			}
		}
		CreateTimer(flGoliathShieldsDownInterval, ActivateShieldTimer3, client, TIMER_FLAG_NO_MAPCHANGE);
		ShieldsUp[client] = 0;
	}
}

//Boss Tank
stock DeactivateShield4(client)
{
	if(IsTank(client) && GetEntityRenderColor(client) == 0050 && ShieldsUp[client] == 1)
	{
		new entity = -1;
		while ((entity = FindEntityByClassname(entity, "prop_dynamic")) != INVALID_ENT_REFERENCE)
		{
			decl String:model[128];
            		GetEntPropString(entity, Prop_Data, "m_ModelName", model, sizeof(model));
			if(StrEqual(model, "models/props_unique/airport/atlas_break_ball.mdl"))
			{
				new owner = GetEntProp(entity, Prop_Send, "m_hOwnerEntity");
				if(owner == client)
				{
					AcceptEntityInput(entity, "Kill");
				}
			}
		}
		CreateTimer(flBossShieldsDownInterval, ActivateShieldTimer4, client, TIMER_FLAG_NO_MAPCHANGE);
		ShieldsUp[client] = 0;
	}
}
stock TeleportTank(client)
{
	new random = GetRandomInt(1,iWarpTeleportDelay);
	if(random == 1)
	{
		new target = Pick();
		if(target)
		{
			new Float:Origin[3], Float:Angles[3];
			GetClientAbsOrigin(target, Origin);
                        GetClientAbsAngles(target, Angles);
			CreateParticle(client, PARTICLE_WARP, 1.0, 0.0);
			TeleportEntity(client, Origin, Angles, NULL_VECTOR);
		}
	}
}
stock TeleportTank2(client)
{
	new random = GetRandomInt(1,iFlashTeleportDelay);
	if(random == 1)
	{
		new target = Pick();
		if(target)
		{
			new Float:Origin[3], Float:Angles[3];
			GetClientAbsOrigin(target, Origin);
                        GetClientAbsAngles(target, Angles);
			CreateParticle(client, PARTICLE_WARP, 1.0, 0.0);
			TeleportEntity(client, Origin, Angles, NULL_VECTOR);
		}
	}
}
stock TeleportTank3(client)
{
	new random = GetRandomInt(1,iReverseFlashTeleportDelay);
	if(random == 1)
	{
		new target = Pick();
		if(target)
		{
			new Float:Origin[3], Float:Angles[3];
			GetClientAbsOrigin(target, Origin);
                        GetClientAbsAngles(target, Angles);
			CreateParticle(client, PARTICLE_WARP, 1.0, 0.0);
			TeleportEntity(client, Origin, Angles, NULL_VECTOR);
		}
	}
}
stock TeleportTank4(client)
{
	new random = GetRandomInt(1,iHallucinationTeleportDelay);
	if(random == 1)
	{
		new target = Pick();
		if(target)
		{
			new Float:Origin[3], Float:Angles[3];
			GetClientAbsOrigin(target, Origin);
                        GetClientAbsAngles(target, Angles);
			TeleportEntity(client, Origin, Angles, NULL_VECTOR);
		}
	}
}
stock TeleportTank5(client)
{
	new random = GetRandomInt(1,iDistractionTeleportDelay);
	if(random == 1)
	{
		new target = Pick();
		if(target)
		{
			new Float:Origin[3], Float:Angles[3];
			GetClientAbsOrigin(target, Origin);
                        GetClientAbsAngles(target, Angles);
			CreateParticle(client, PARTICLE_WARP, 1.0, 0.0);
			TeleportEntity(client, Origin, Angles, NULL_VECTOR);
		}
	}
}
stock TeleportTank6(client)
{
	new random = GetRandomInt(1,iFeedbackTeleportDelay);
	if(random == 1)
	{
		new target = Pick();
		if(target)
		{
			new Float:Origin[3], Float:Angles[3];
			GetClientAbsOrigin(target, Origin);
                        GetClientAbsAngles(target, Angles);
			CreateParticle(client, PARTICLE_WARP, 1.0, 0.0);
			TeleportEntity(client, Origin, Angles, NULL_VECTOR);
		}
	}
}
stock TeleportTank7(client)
{
	new random = GetRandomInt(1,iPsychoticTeleportDelay);
	if(random == 1)
	{
		new target = Pick();
		if(target)
		{
			new Float:Origin[3], Float:Angles[3];
			GetClientAbsOrigin(target, Origin);
                        GetClientAbsAngles(target, Angles);
			CreateParticle(client, PARTICLE_WARP, 1.0, 0.0);
			TeleportEntity(client, Origin, Angles, NULL_VECTOR);
		}
	}
}
stock TeleportTank8(client)
{
	new random = GetRandomInt(1,iPsykotikTeleportDelay);
	if(random == 1)
	{
		new target = Pick();
		if(target)
		{
			new Float:Origin[3], Float:Angles[3];
			GetClientAbsOrigin(target, Origin);
                        GetClientAbsAngles(target, Angles);
			CreateParticle(client, PARTICLE_WARP, 1.0, 0.0);
			TeleportEntity(client, Origin, Angles, NULL_VECTOR);
		}
	}
}
stock TeleportTank9(client)
{
	new random = GetRandomInt(1,iSpykotikTeleportDelay);
	if(random == 1)
	{
		new target = Pick();
		if(target)
		{
			new Float:Origin[3], Float:Angles[3];
			GetClientAbsOrigin(target, Origin);
                        GetClientAbsAngles(target, Angles);
			CreateParticle(client, PARTICLE_WARP, 1.0, 0.0);
			TeleportEntity(client, Origin, Angles, NULL_VECTOR);
		}
	}
}

//Meme Tank
stock TeleportTank10(client)
{
	new random = GetRandomInt(1,iMemeTeleportDelay);
	if(random == 1)
	{
		new target = Pick();
		if(target)
		{
			new Float:Origin[3], Float:Angles[3];
			GetClientAbsOrigin(target, Origin);
                        GetClientAbsAngles(target, Angles);
			CreateParticle(client, PARTICLE_WARP, 1.0, 0.0);
			TeleportEntity(client, Origin, Angles, NULL_VECTOR);
		}
	}
}

//Boss Tank
stock TeleportTank11(client)
{
	new random = GetRandomInt(1,iBossTeleportDelay);
	if(random == 1)
	{
		new target = Pick();
		if(target)
		{
			new Float:Origin[3], Float:Angles[3];
			GetClientAbsOrigin(target, Origin);
                        GetClientAbsAngles(target, Angles);
			CreateParticle(client, PARTICLE_WARP, 1.0, 0.0);
			TeleportEntity(client, Origin, Angles, NULL_VECTOR);
		}
	}
}
stock TeleportTank12(client)
{
	new random = GetRandomInt(1,iSpypsyTeleportDelay);
	if(random == 1)
	{
		new target = Pick();
		if(target)
		{
			new Float:Origin[3], Float:Angles[3];
			GetClientAbsOrigin(target, Origin);
                        GetClientAbsAngles(target, Angles);
			CreateParticle(client, PARTICLE_WARP, 1.0, 0.0);
			TeleportEntity(client, Origin, Angles, NULL_VECTOR);
		}
	}
}
stock TeleportTank13(client)
{
	new random = GetRandomInt(1,iPoltergeistTeleportDelay);
	if(random == 1)
	{
		new target = Pick();
		if(target)
		{
			new Float:Origin[3], Float:Angles[3];
			GetClientAbsOrigin(target, Origin);
                        GetClientAbsAngles(target, Angles);
			TeleportEntity(client, Origin, Angles, NULL_VECTOR);
		}
	}
}
stock TeleportTank14(client)
{
	new random = GetRandomInt(1,iMirageTeleportDelay);
	if(random == 1)
	{
		new target = Pick();
		if(target)
		{
			new Float:Origin[3], Float:Angles[3];
			GetClientAbsOrigin(target, Origin);
                        GetClientAbsAngles(target, Angles);
			CreateParticle(client, PARTICLE_WARP, 1.0, 0.0);
			TeleportEntity(client, Origin, Angles, NULL_VECTOR);
		}
	}
}
stock CountWitches()
{
	new count;
	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "witch")) != INVALID_ENT_REFERENCE)
	{
		count++;
	}
	return count;
}
stock SpawnWitch(client)
{
	new count;
	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "infected")) != INVALID_ENT_REFERENCE)
	{
		if(count < 4 && CountWitches() < iWitchMaxWitches)
		{
			decl Float:TankPos[3], Float:InfectedPos[3], Float:InfectedAng[3];
                        GetClientAbsOrigin(client, TankPos);
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", InfectedPos);
			GetEntPropVector(entity, Prop_Send, "m_angRotation", InfectedAng);
			new Float:distance = GetVectorDistance(InfectedPos, TankPos);
                        if(distance < 100.0)
			{
				AcceptEntityInput(entity, "Kill");
				new witch = CreateEntityByName("witch");
				DispatchSpawn(witch);
				ActivateEntity(witch);
				TeleportEntity(witch, InfectedPos, InfectedAng, NULL_VECTOR);
				SetEntProp(witch, Prop_Send, "m_hOwnerEntity", 255200255);
				count++;
			}
		}
	}
}

//Meme Tank
stock SpawnWitch2(client)
{
	new count;
	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "infected")) != INVALID_ENT_REFERENCE)
	{
		if(count < 4 && CountWitches() < iMemeMaxWitches)
		{
			decl Float:TankPos[3], Float:InfectedPos[3], Float:InfectedAng[3];
                        GetClientAbsOrigin(client, TankPos);
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", InfectedPos);
			GetEntPropVector(entity, Prop_Send, "m_angRotation", InfectedAng);
			new Float:distance = GetVectorDistance(InfectedPos, TankPos);
                        if(distance < 100.0)
			{
				AcceptEntityInput(entity, "Kill");
				new witch = CreateEntityByName("witch");
				DispatchSpawn(witch);
				ActivateEntity(witch);
				TeleportEntity(witch, InfectedPos, InfectedAng, NULL_VECTOR);
				SetEntProp(witch, Prop_Send, "m_hOwnerEntity", 255200255);
				count++;
			}
		}
	}
}

//Boss Tank
stock SpawnWitch3(client)
{
	new count;
	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "infected")) != INVALID_ENT_REFERENCE)
	{
		if(count < 4 && CountWitches() < iBossMaxWitches)
		{
			decl Float:TankPos[3], Float:InfectedPos[3], Float:InfectedAng[3];
                        GetClientAbsOrigin(client, TankPos);
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", InfectedPos);
			GetEntPropVector(entity, Prop_Send, "m_angRotation", InfectedAng);
			new Float:distance = GetVectorDistance(InfectedPos, TankPos);
                        if(distance < 100.0)
			{
				AcceptEntityInput(entity, "Kill");
				new witch = CreateEntityByName("witch");
				DispatchSpawn(witch);
				ActivateEntity(witch);
				TeleportEntity(witch, InfectedPos, InfectedAng, NULL_VECTOR);
				SetEntProp(witch, Prop_Send, "m_hOwnerEntity", 255200255);
				count++;
			}
		}
	}
}

stock HealthTank(client)
{
	new infectedfound = 0;
	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "infected")) != INVALID_ENT_REFERENCE)
	{
		decl Float:TankPos[3], Float:InfectedPos[3];
		GetClientAbsOrigin(client, TankPos);
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", InfectedPos);
		new Float:distance = GetVectorDistance(InfectedPos, TankPos);
		if(distance < 500)
		{
			new health = GetEntProp(client, Prop_Send, "m_iHealth");
			new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
			if(health <= (maxhealth - iHealthHealthCommons) && health > 500)
			{
				SetEntProp(client, Prop_Data, "m_iHealth", health + iHealthHealthCommons);
			}
			else if(health > 500)
			{
				SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
			}
			if(health > 500)
			{
				new glowcolor = RGB_TO_INT(0, 185, 0);
				if(L4D2Version)
				{
					SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
					SetEntProp(client, Prop_Send, "m_iGlowType", 3);
					SetEntProp(client, Prop_Send, "m_bFlashing", 1);
				}
				infectedfound = 1;
			}
		}
	}
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsSpecialInfected(i))
		{
			decl Float:TankPos[3], Float:InfectedPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPos);
			new Float:distance = GetVectorDistance(TankPos, InfectedPos);
			if(distance < 500)
			{
				new health = GetEntProp(client, Prop_Send, "m_iHealth");
				new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
				if(health <= (maxhealth - iHealthHealthSpecials) && health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", health + iHealthHealthSpecials);
				}
				else if(health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
				}
				if(health > 500 && infectedfound < 2)
				{
					new glowcolor = RGB_TO_INT(0, 220, 0);
					if(L4D2Version)
					{
						SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
						SetEntProp(client, Prop_Send, "m_iGlowType", 3);
						SetEntProp(client, Prop_Send, "m_bFlashing", 1);
					}
					infectedfound = 1;
				}
			}
		}
		else if(IsTank(i) && i != client)
		{
			decl Float:TankPos[3], Float:InfectedPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPos);
			new Float:distance = GetVectorDistance(TankPos, InfectedPos);
			if(distance < 500)
			{
				new health = GetEntProp(client, Prop_Send, "m_iHealth");
				new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
				if(health <= (maxhealth - iHealthHealthTanks) && health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", health + iHealthHealthTanks);
				}
				else if(health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
				}
				if(health > 500)
				{
					new glowcolor = RGB_TO_INT(0, 255, 0);
					if(L4D2Version)
					{
						SetEntProp(client, Prop_Send, "m_glowColorOverride", glowcolor);
						SetEntProp(client, Prop_Send, "m_iGlowType", 3);
						SetEntProp(client, Prop_Send, "m_bFlashing", 1);
					}
					infectedfound = 2;
				}
			}
		}
	}
	if(infectedfound == 0)
	{
		if(L4D2Version)
		{
			SetEntProp(client, Prop_Send, "m_glowColorOverride", 0);
			SetEntProp(client, Prop_Send, "m_iGlowType", 0);
			SetEntProp(client, Prop_Send, "m_bFlashing", 0);
		}
	}
}
stock PsychoticTank(client)
{
	new infectedfound = 0;
	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "infected")) != INVALID_ENT_REFERENCE)
	{
		decl Float:TankPos[3], Float:InfectedPos[3];
		GetClientAbsOrigin(client, TankPos);
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", InfectedPos);
		new Float:distance = GetVectorDistance(InfectedPos, TankPos);
		if(distance < 500)
		{
			new health = GetEntProp(client, Prop_Send, "m_iHealth");
			new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
			if(health <= (maxhealth - iPsychoticHealthCommons) && health > 500)
			{
				SetEntProp(client, Prop_Data, "m_iHealth", health + iPsychoticHealthCommons);
			}
			else if(health > 500)
			{
				SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
			}
			if(health > 500)
			{
				infectedfound = 1;
			}
		}
	}
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsSpecialInfected(i))
		{
			decl Float:TankPos[3], Float:InfectedPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPos);
			new Float:distance = GetVectorDistance(TankPos, InfectedPos);
			if(distance < 500)
			{
				new health = GetEntProp(client, Prop_Send, "m_iHealth");
				new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
				if(health <= (maxhealth - iPsychoticHealthSpecials) && health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", health + iPsychoticHealthSpecials);
				}
				else if(health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
				}
				if(health > 500 && infectedfound < 2)
				{
					infectedfound = 1;
				}
			}
		}
		else if(IsTank(i) && i != client)
		{
			decl Float:TankPos[3], Float:InfectedPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPos);
			new Float:distance = GetVectorDistance(TankPos, InfectedPos);
			if(distance < 500)
			{
				new health = GetEntProp(client, Prop_Send, "m_iHealth");
				new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
				if(health <= (maxhealth - iPsychoticHealthTanks) && health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", health + iPsychoticHealthTanks);
				}
				else if(health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
				}
				if(health > 500)
				{
					infectedfound = 2;
				}
			}
		}
	}
}
stock GoliathTank(client)
{
	new infectedfound = 0;
	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "infected")) != INVALID_ENT_REFERENCE)
	{
		decl Float:TankPos[3], Float:InfectedPos[3];
		GetClientAbsOrigin(client, TankPos);
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", InfectedPos);
		new Float:distance = GetVectorDistance(InfectedPos, TankPos);
		if(distance < 500)
		{
			new health = GetEntProp(client, Prop_Send, "m_iHealth");
			new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
			if(health <= (maxhealth - iGoliathHealthCommons) && health > 500)
			{
				SetEntProp(client, Prop_Data, "m_iHealth", health + iGoliathHealthCommons);
			}
			else if(health > 500)
			{
				SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
			}
			if(health > 500)
			{
				infectedfound = 1;
			}
		}
	}
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsSpecialInfected(i))
		{
			decl Float:TankPos[3], Float:InfectedPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPos);
			new Float:distance = GetVectorDistance(TankPos, InfectedPos);
			if(distance < 500)
			{
				new health = GetEntProp(client, Prop_Send, "m_iHealth");
				new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
				if(health <= (maxhealth - iGoliathHealthSpecials) && health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", health + iGoliathHealthSpecials);
				}
				else if(health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
				}
				if(health > 500 && infectedfound < 2)
				{
					infectedfound = 1;
				}
			}
		}
		else if(IsTank(i) && i != client)
		{
			decl Float:TankPos[3], Float:InfectedPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPos);
			new Float:distance = GetVectorDistance(TankPos, InfectedPos);
			if(distance < 500)
			{
				new health = GetEntProp(client, Prop_Send, "m_iHealth");
				new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
				if(health <= (maxhealth - iGoliathHealthTanks) && health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", health + iGoliathHealthTanks);
				}
				else if(health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
				}
				if(health > 500)
				{
					infectedfound = 2;
				}
			}
		}
	}
}
stock PsykotikTank(client)
{
	new infectedfound = 0;
	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "infected")) != INVALID_ENT_REFERENCE)
	{
		decl Float:TankPos[3], Float:InfectedPos[3];
		GetClientAbsOrigin(client, TankPos);
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", InfectedPos);
		new Float:distance = GetVectorDistance(InfectedPos, TankPos);
		if(distance < 500)
		{
			new health = GetEntProp(client, Prop_Send, "m_iHealth");
			new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
			if(health <= (maxhealth - iPsykotikHealthCommons) && health > 500)
			{
				SetEntProp(client, Prop_Data, "m_iHealth", health + iPsykotikHealthCommons);
			}
			else if(health > 500)
			{
				SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
			}
			if(health > 500)
			{
				infectedfound = 1;
			}
		}
	}
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsSpecialInfected(i))
		{
			decl Float:TankPos[3], Float:InfectedPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPos);
			new Float:distance = GetVectorDistance(TankPos, InfectedPos);
			if(distance < 500)
			{
				new health = GetEntProp(client, Prop_Send, "m_iHealth");
				new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
				if(health <= (maxhealth - iPsykotikHealthSpecials) && health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", health + iPsykotikHealthSpecials);
				}
				else if(health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
				}
				if(health > 500 && infectedfound < 2)
				{
					infectedfound = 1;
				}
			}
		}
		else if(IsTank(i) && i != client)
		{
			decl Float:TankPos[3], Float:InfectedPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPos);
			new Float:distance = GetVectorDistance(TankPos, InfectedPos);
			if(distance < 500)
			{
				new health = GetEntProp(client, Prop_Send, "m_iHealth");
				new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
				if(health <= (maxhealth - iPsykotikHealthTanks) && health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", health + iPsykotikHealthTanks);
				}
				else if(health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
				}
				if(health > 500)
				{
					infectedfound = 2;
				}
			}
		}
	}
}

//Boss Tank
stock BossTank(client)
{
	new infectedfound = 0;
	new entity = -1;
	while ((entity = FindEntityByClassname(entity, "infected")) != INVALID_ENT_REFERENCE)
	{
		decl Float:TankPos[3], Float:InfectedPos[3];
		GetClientAbsOrigin(client, TankPos);
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", InfectedPos);
		new Float:distance = GetVectorDistance(InfectedPos, TankPos);
		if(distance < 500)
		{
			new health = GetEntProp(client, Prop_Send, "m_iHealth");
			new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
			if(health <= (maxhealth - iBossHealthCommons) && health > 500)
			{
				SetEntProp(client, Prop_Data, "m_iHealth", health + iBossHealthCommons);
			}
			else if(health > 500)
			{
				SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
			}
			if(health > 500)
			{
				infectedfound = 1;
			}
		}
	}
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsSpecialInfected(i))
		{
			decl Float:TankPos[3], Float:InfectedPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPos);
			new Float:distance = GetVectorDistance(TankPos, InfectedPos);
			if(distance < 500)
			{
				new health = GetEntProp(client, Prop_Send, "m_iHealth");
				new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
				if(health <= (maxhealth - iBossHealthSpecials) && health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", health + iBossHealthSpecials);
				}
				else if(health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
				}
				if(health > 500 && infectedfound < 2)
				{
					infectedfound = 1;
				}
			}
		}
		else if(IsTank(i) && i != client)
		{
			decl Float:TankPos[3], Float:InfectedPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPos);
			new Float:distance = GetVectorDistance(TankPos, InfectedPos);
			if(distance < 500)
			{
				new health = GetEntProp(client, Prop_Send, "m_iHealth");
				new maxhealth = GetEntProp(client, Prop_Send, "m_iMaxHealth");
				if(health <= (maxhealth - iBossHealthTanks) && health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", health + iBossHealthTanks);
				}
				else if(health > 500)
				{
					SetEntProp(client, Prop_Data, "m_iHealth", maxhealth);
				}
				if(health > 500)
				{
					infectedfound = 2;
				}
			}
		}
	}
}
stock InfectedCloak(client)
{
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsSpecialInfected(i))
		{
			decl Float:TankPos[3], Float:InfectedPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPos);
			new Float:distance = GetVectorDistance(TankPos, InfectedPos);
			if(distance < 500)
			{
				SetEntityRenderMode(i, RenderMode:3);
      	 			SetEntityRenderColor(i, 255, 255, 255, 50);
			}
			else
			{
				SetEntityRenderMode(i, RenderMode:3);
      	 			SetEntityRenderColor(i, 255, 255, 255, 255);
			}
		}
	}
}
stock InfectedCloak2(client)
{
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsSpecialInfected(i))
		{
			decl Float:TankPos[3], Float:InfectedPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPos);
			new Float:distance = GetVectorDistance(TankPos, InfectedPos);
			if(distance < 500)
			{
				SetEntityRenderMode(i, RenderMode:3);
      	 			SetEntityRenderColor(i, 255, 255, 255, 50);
			}
			else
			{
				SetEntityRenderMode(i, RenderMode:3);
      	 			SetEntityRenderColor(i, 255, 255, 255, 255);
			}
		}
	}
}

//Meme Tank
stock InfectedCloak3(client)
{
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsSpecialInfected(i))
		{
			decl Float:TankPos[3], Float:InfectedPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPos);
			new Float:distance = GetVectorDistance(TankPos, InfectedPos);
			if(distance < 500)
			{
				SetEntityRenderMode(i, RenderMode:3);
      	 			SetEntityRenderColor(i, 0, 255, 0, 50);
			}
			else
			{
				SetEntityRenderMode(i, RenderMode:3);
      	 			SetEntityRenderColor(i, 0, 255, 0, 255);
			}
		}
	}
}

//Boss Tank
stock InfectedCloak4(client)
{
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsSpecialInfected(i))
		{
			decl Float:TankPos[3], Float:InfectedPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPos);
			new Float:distance = GetVectorDistance(TankPos, InfectedPos);
			if(distance < 500)
			{
				SetEntityRenderMode(i, RenderMode:3);
      	 			SetEntityRenderColor(i, 0, 0, 50, 50);
			}
			else
			{
				SetEntityRenderMode(i, RenderMode:3);
      	 			SetEntityRenderColor(i, 0, 0, 50, 255);
			}
		}
	}
}
stock InfectedCloak5(client)
{
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsSpecialInfected(i))
		{
			decl Float:TankPos[3], Float:InfectedPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, InfectedPos);
			new Float:distance = GetVectorDistance(TankPos, InfectedPos);
			if(distance < 500)
			{
				SetEntityRenderMode(i, RenderMode:3);
      	 			SetEntityRenderColor(i, 100, 50, 50, 50);
			}
			else
			{
				SetEntityRenderMode(i, RenderMode:3);
      	 			SetEntityRenderColor(i, 100, 50, 50, 255);
			}
		}
	}
}
stock CountSurvRange(client)
{
	new count = 0;
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
		{
			decl Float:TankPos[3], Float:PlayerPos[3];
			GetClientAbsOrigin(client, TankPos);
			GetClientAbsOrigin(i, PlayerPos);
			new Float:distance = GetVectorDistance(TankPos, PlayerPos);
			if(distance > 120)
			{
				count++;
			}
		}
	}
	return count;
}
stock GetEntityRenderColor(entity)
{
	if(entity > 0)
	{
		new offset = GetEntSendPropOffs(entity, "m_clrRender");
		new r = GetEntData(entity, offset, 1);
		new g = GetEntData(entity, offset+1, 1);
		new b = GetEntData(entity, offset+2, 1);
		decl String:rgb[10];
		Format(rgb, sizeof(rgb), "%d%d%d", r, g, b);
		new color = StringToInt(rgb);
		return color;
	}
	return 0;	
}
stock RGB_TO_INT(red, green, blue) 
{
	return (blue * 65536) + (green * 256) + red;
}
public Action:OnPlayerTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(bSuperTanksEnabled)
	{
		if(damage > 0.0 && IsValidClient(victim))
		{
			decl String:classname[32];
			if(GetClientTeam(victim) == 2)
			{
				if(IsWitch(attacker))
				{
					if(GetEntProp(attacker, Prop_Send, "m_hOwnerEntity") == 255200255)
					{
						damage = 16.0;
					}
				}
				else if(IsTank(attacker) && damagetype != 2)
				{
					new color = GetEntityRenderColor(attacker);
					switch(color)
					{
						//Fire Tank
						case 12800:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw") || StrEqual(classname, "weapon_tank_rock"))
							{
								SkillFlameClaw(victim);
							}
						}
						//Gravity Tank
						case 333435:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								SkillGravityClaw(victim);
							}
						}
						//Ice Tank
						case 0100170:
						{
							new flags = GetEntityFlags(victim);
							if(flags & FL_ONGROUND)
							{
								new random = GetRandomInt(1,3);
								if(random == 1)
								{
									SkillIceClaw(victim);
								}
							}
						}
						//Cobalt Tank
						case 0105255:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								TankAbility[attacker] = 0;
							}
						}
						//Smasher Tank
						case 7080100:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								new random = GetRandomInt(1,2);
								if(random == 1)
								{
									SkillSmashClawKill(victim, attacker);
								}
								else
								{
									SkillSmashClaw(victim);
								}
							}
						}
						//Spawn Tank
						case 7595105:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								new random = GetRandomInt(1,4);
								if(random == 1)
								{
									SDKCallVomitOnPlayer(victim, attacker);
								}
							}
						}
						//Shock Tank
						case 100165255:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								SkillElecClaw(victim, attacker);
							}
						}
						//Warp Tank
						case 130130255:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								new dmg = RoundFloat(damage / 2);
								DealDamagePlayer(victim, attacker, 2, dmg);
							}
						}
						//Flash Tank
						case 25500:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								TankAbility[attacker] = 0;
							}
						}
						//Reverse Flash Tank
						case 2552550:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								TankAbility[attacker] = 0;
							}
						}
						//Armageddon Tank
						case 7500:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								new random = GetRandomInt(1,2);
								if(random == 1)
								{
									SkillArmageddonClawKill(victim, attacker);
								}
								else
								{
									SkillArmageddonClaw(victim);
								}
							}
						}
						//Trap Tank
						case 5512570:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								new random = GetRandomInt(1,2);
								if(random == 1)
								{
									SkillTrapClawKill(victim, attacker);
								}
								else
								{
									SkillTrapClaw(victim);
								}
							}
						}
						//Distraction Tank
						case 2252250:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								new dmg = RoundFloat(damage / 2);
								DealDamagePlayer(victim, attacker, 2, dmg);
							}
						}
						//Feedback Tank
						case 906090:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								SkillFeedbackClaw(victim, attacker);
							}
						}
						//Goliath Tank
						case 00100:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								new random = GetRandomInt(1,2);
								if(random == 1)
								{
									SkillGoliathClawKill(victim, attacker);
								}
								else
								{
									SkillGoliathClaw(victim);
								}
							}
						}
						//Psykotik Tank
						case 111:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								TankAbility[attacker] = 0;
							}
						}
						//Spykotik Tank
						case 255100255:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								TankAbility[attacker] = 0;
							}
						}
						//Meme Tank
						case 02550:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								new random = GetRandomInt(1,2);
								if(random == 1)
								{
									SkillMemeClawKill(victim, attacker);
								}
								else
								{
									SkillMemeClaw(victim);
								}
							}
						}
						//Boss Tank
						case 0050:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								new random = GetRandomInt(1,2);
								if(random == 1)
								{
									SkillBossClawKill(victim, attacker);
								}
								else
								{
									SkillBossClaw(victim);
								}
							}
						}
						//Spypsy Tank
						case 00255:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								TankAbility[attacker] = 0;
							}
						}
						//Poltergeist Tank
						case 1005050:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								TankAbility[attacker] = 0;
							}
						}
						//Mirage Tank
						case 254025:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_tank_claw"))
							{
								TankAbility[attacker] = 0;
							}
						}
					}
				}
			}
			else if(IsTank(victim))
			{
				if(damagetype == 8 || damagetype == 2056 || damagetype == 268435464)
				{
					new index = GetSuperTankByRenderColor(GetEntityRenderColor(victim));
					if(index >= 0 && index <= 40)
					{
						if(bTankFireImmunity[index])
						{
							if(index != 0 || (index == 0 && bDefaultOverride))
							{
								return Plugin_Handled;
							}
						}
					}
				}
				if(IsSurvivor(attacker))
				{
					new color = GetEntityRenderColor(victim);
					switch(color)
					{
						//Fire Tank
						case 12800:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_melee"))
							{
								new random = GetRandomInt(1,4);
								if(random == 1)
								{
									SkillFlameGush(victim);
								}
							}
						}
						//Meteor Tank
						case 1002525:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_melee"))
							{
								new random = GetRandomInt(1,2);
								if(random == 1)
								{
									if(TankAbility[victim] == 0)
									{
										StartMeteorFall(victim);
									}
								}
							}
						}
						//Acid Tank
						case 12115128:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_melee"))
							{
								new random = GetRandomInt(1,4);
								if(random == 1)
								{
									new x = CreateFakeClient("Spitter");
									if(x > 0)
									{
										new Float:Pos[3];
										GetClientAbsOrigin(victim, Pos);
										TeleportEntity(x, Pos, NULL_VECTOR, NULL_VECTOR);	
										SDKCallSpitBurst(x);
										KickClient(x);
									}
								}
							}
						}
						//Ghost Tank
						case 100100100:
						{
							if(bGhostDisarm)
							{
								GetEdictClassname(inflictor, classname, sizeof(classname));
								if(StrEqual(classname, "weapon_melee"))
								{
									new random = GetRandomInt(1,4);
									if(random == 1)
									{
										ForceWeaponDrop(attacker);
										EmitSoundToClient(attacker, "npc/infected/action/die/male/death_42.wav", victim);
									}
								}
							}
						}
						//Shield Tank
						case 135205255:
						{
							if(damagetype == 64 || damagetype == 134217792 || damagetype == 33554432 || damagetype == 16777280)
							{
								if(ShieldsUp[victim] == 1)
								{
									DeactivateShield(victim);
								}
							}
							else
							{
								if(ShieldsUp[victim] == 1)
								{
									return Plugin_Handled;
								}
							}
						}
						//Armageddon Tank
						case 7500:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_melee"))
							{
								new random = GetRandomInt(1,2);
								if(random == 1)
								{
									if(TankAbility[victim] == 0)
									{
										StartArmageddonFall(victim);
									}
								}
							}
						}
						//Hallucination Tank
						case 505050:
						{
							if(bHallucinationDisarm)
							{
								GetEdictClassname(inflictor, classname, sizeof(classname));
								if(StrEqual(classname, "weapon_melee"))
								{
									new random = GetRandomInt(1,4);
									if(random == 1)
									{
										ForceWeaponDrop(attacker);
										EmitSoundToClient(attacker, "npc/infected/action/die/male/death_42.wav", victim);
									}
								}
							}
						}
						//Psychotic Tank
						case 000:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_melee"))
							{
								new random = GetRandomInt(1,2);
								if(random == 1)
								{
									if(TankAbility[victim] == 0)
									{
										StartPsychoticFall(victim);
									}
								}
							}
							if(damagetype == 64 || damagetype == 134217792 || damagetype == 33554432 || damagetype == 16777280)
							{
								if(ShieldsUp[victim] == 1)
								{
									DeactivateShield2(victim);
								}
							}
							else
							{
								if(ShieldsUp[victim] == 1)
								{
									return Plugin_Handled;
								}
							}
						}
						//Goliath Tank
						case 00100:
						{
							if(damagetype == 64 || damagetype == 134217792 || damagetype == 33554432 || damagetype == 16777280)
							{
								if(ShieldsUp[victim] == 1)
								{
									DeactivateShield3(victim);
								}
							}
							else
							{
								if(ShieldsUp[victim] == 1)
								{
									return Plugin_Handled;
								}
							}
						}
						//Meme Tank
						case 02550:
						{
							if(bMemeDisarm)
							{
								GetEdictClassname(inflictor, classname, sizeof(classname));
								if(StrEqual(classname, "weapon_melee"))
								{
									new random = GetRandomInt(1,4);
									if(random == 1)
									{
										ForceWeaponDrop(attacker);
										EmitSoundToClient(attacker, "npc/infected/action/die/male/death_42.wav", victim);
									}
								}
							}
						}
						//Boss Tank
						case 0050:
						{
							if(bBossDisarm)
							{
								GetEdictClassname(inflictor, classname, sizeof(classname));
								if(StrEqual(classname, "weapon_melee"))
								{
									new random = GetRandomInt(1,4);
									if(random == 1)
									{
										ForceWeaponDrop(attacker);
										EmitSoundToClient(attacker, "npc/infected/action/die/male/death_42.wav", victim);
									}
								}
							}
							if(damagetype == 64 || damagetype == 134217792 || damagetype == 33554432 || damagetype == 16777280)
							{
								if(ShieldsUp[victim] == 1)
								{
									DeactivateShield4(victim);
								}
							}
							else
							{
								if(ShieldsUp[victim] == 1)
								{
									return Plugin_Handled;
								}
							}
						}
						//Sipow Tank
						case 0255125:
						{
							GetEdictClassname(inflictor, classname, sizeof(classname));
							if(StrEqual(classname, "weapon_melee"))
							{
								new random = GetRandomInt(1,2);
								new random2 = GetRandomInt(1,4);
								if(random == 1)
								{
									if(TankAbility[victim] == 0)
									{
										StartSipowFall(victim);
									}
								}
								if(random2 == 1)
								{
									new x = CreateFakeClient("Spitter");
									if(x > 0)
									{
										new Float:Pos[3];
										GetClientAbsOrigin(victim, Pos);
										TeleportEntity(x, Pos, NULL_VECTOR, NULL_VECTOR);	
										SDKCallSpitBurst(x);
										KickClient(x);
									}
								}
							}
						}
						//Poltergeist Tank
						case 1005050:
						{
							if(bPoltergeistDisarm)
							{
								GetEdictClassname(inflictor, classname, sizeof(classname));
								if(StrEqual(classname, "weapon_melee"))
								{
									new random = GetRandomInt(1,4);
									if(random == 1)
									{
										ForceWeaponDrop(attacker);
										EmitSoundToClient(attacker, "npc/infected/action/die/male/death_42.wav", victim);
									}
								}
							}
						}
					}
				}
			}
		}
	}
	return Plugin_Changed;
}
stock DealDamagePlayer(target, attacker, dmgtype, dmg)
{
	if(target > 0 && target <= MaxClients)
	{
		if(IsClientInGame(target) && IsPlayerAlive(target))
		{
   	 		decl String:damage[16];
    			IntToString(dmg, damage, 16);
   	 		decl String:type[16];
    			IntToString(dmgtype, type, 16);
			new pointHurt = CreateEntityByName("point_hurt");
			if(pointHurt)
			{
				DispatchKeyValue(target, "targetname", "hurtme");
				DispatchKeyValue(pointHurt, "Damage", damage);
				DispatchKeyValue(pointHurt, "DamageTarget", "hurtme");
				DispatchKeyValue(pointHurt, "DamageType", type);
				DispatchSpawn(pointHurt);
				AcceptEntityInput(pointHurt, "Hurt", attacker);
				AcceptEntityInput(pointHurt, "Kill");
				DispatchKeyValue(target, "targetname", "donthurtme");
			}
		}
	}
}
stock DealDamageEntity(target, attacker, dmgtype, dmg)
{
	if(target > 32)
	{
		if(IsValidEntity(target))
		{
   	 		decl String:damage[16];
    			IntToString(dmg, damage, 16);
   	 		decl String:type[16];
    			IntToString(dmgtype, type, 16);
			new pointHurt = CreateEntityByName("point_hurt");
			if(pointHurt)
			{
				DispatchKeyValue(target, "targetname", "hurtme");
				DispatchKeyValue(pointHurt, "Damage", damage);
				DispatchKeyValue(pointHurt, "DamageTarget", "hurtme");
				DispatchKeyValue(pointHurt, "DamageType", type);
				DispatchSpawn(pointHurt);
				AcceptEntityInput(pointHurt, "Hurt", attacker);
				AcceptEntityInput(pointHurt, "Kill");
				DispatchKeyValue(target, "targetname", "donthurtme");
			}
		}
	}
}
stock ForceWeaponDrop(client)
{
	if(GetPlayerWeaponSlot(client, 1) > 0)
	{
		new weapon = GetPlayerWeaponSlot(client, 1);
		SDKHooks_DropWeapon(client, weapon, NULL_VECTOR, NULL_VECTOR);
	}
}
stock ResetInfectedAbility(client, Float:time)
{
	if(client > 0)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client) && GetClientTeam(client) == 3)
		{
			new ability = GetEntPropEnt(client, Prop_Send, "m_customAbility");
			if(ability > 0)
			{
				SetEntPropFloat(ability, Prop_Send, "m_duration", time);
				SetEntPropFloat(ability, Prop_Send, "m_timestamp", GetGameTime() + time);
			}
		}
	}
}
stock GetNearestSurvivorDist(client)
{
    	new Float:PlayerPos[3], Float:TargetPos[3], Float:nearest = 0.0, Float:distance = 0.0;
	if(client > 0)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			GetClientAbsOrigin(client, PlayerPos);
   			for(new i=1; i<=MaxClients; i++)
    			{
        			if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
				{
					GetClientAbsOrigin(i, TargetPos);
                        		distance = GetVectorDistance(PlayerPos, TargetPos);
                        		if(nearest == 0.0)
					{
						nearest = distance;
					}
					else if(nearest > distance)
					{
						nearest = distance;
					}
				}
			}
		} 
    }
    	return RoundFloat(distance);
}
stock GetSuperTankByRenderColor(color)
{
	if(L4D2Version)
	{
		switch(color)
		{
			//Fire Tank
			case 12800:
			{
				return 7;
			}
			//Gravity Tank
			case 333435:
			{
				return 20;
			}
			//Ice Tank
			case 0100170:
			{
				return 8;
			}
			//Cobalt Tank
			case 0105255:
			{
				return 18;
			}
			//Meteor Tank
			case 1002525:
			{
				return 4;
			}
			//Jumper Tank
			case 2002550:
			{
				return 19;
			}
			//Jockey Tank
			case 25516575:
			{
				return 9;
			}
			//Smasher Tank
			case 7080100:
			{
				return 2;
			}
			//Spawn Tank
			case 7595105:
			{
				return 1;
			}
			//Acid Tank
			case 12115128:
			{
				return 5;
			}
			//Health Tank
			case 100255200:
			{
				return 6;
			}
			//Ghost Tank
			case 100100100:
			{
				return 14;
			}
			//Shock Tank
			case 100165255:
			{
				return 15;
			}
			//Warp Tank
			case 130130255:
			{
				return 3;
			}
			//Flash Tank
			case 25500:
			{
				return 21;
			}
			//Reverse Flash Tank
			case 2552550:
			{
				return 22;
			}
			//Armageddon Tank
			case 7500:
			{
				return 23;
			}
			//Hallucination Tank
			case 505050:
			{
				return 24;
			}
			//Minion Tank
			case 225225225:
			{
				return 25;
			}
			//Bitch Tank
			case 255155255:
			{
				return 26;
			}
			//Trap Tank
			case 5512570:
			{
				return 27;
			}
			//Distraction Tank
			case 2252250:
			{
				return 28;
			}
			//Feedback Tank
			case 906090:
			{
				return 29;
			}
			//Psychotic Tank
			case 000:
			{
				return 30;
			}
			//Spitter Tank
			case 7525575:
			{
				return 31;
			}
			//Goliath Tank
			case 00100:
			{
				return 32;
			}
			//Psykotik Tank
			case 111:
			{
				return 33;
			}
			//Spykotik Tank
			case 255100255:
			{
				return 34;
			}
			//Meme Tank
			case 02550:
			{
				return 35;
			}
			//Boss Tank
			case 0050:
			{
				return 36;
			}
			//Spypsy Tank
			case 00255:
			{
				return 37;
			}
			//Sipow Tank
			case 0255125:
			{
				return 38;
			}
			//Poltergeist Tank
			case 1005050:
			{
				return 39;
			}
			//Mirage Tank
			case 254025:
			{
				return 40;
			}
			//Shield Tank
			case 135205255:
			{
				return 17;
			}
			//Witch Tank
			case 255200255:
			{
				return 16;
			}
			//Charger Tank
			case 4012540:
			{
				return 13;
			}
			//Boomer Tank
			case 651050:
			{
				return 12;
			}
			//Smoker Tank
			case 12085120:
			{
				return 11;
			}
			//Hunter Tank
			case 2590185:
			{
				return 10;
			}
			//Default Tank
			case 255255255:
			{
				return 0;
			}
		}
	}
	else
	{
		switch(color)
		{
			//Fire Tank
			case 12800:
			{
				return 7;
			}
			//Gravity Tank
			case 333435:
			{
				return 20;
			}
			//Cobalt Tank
			case 0105255:
			{
				return 18;
			}
			//Meteor Tank
			case 1002525:
			{
				return 4;
			}
			//Jumper Tank
			case 2002550:
			{
				return 19;
			}
			//Smasher Tank
			case 7080100:
			{
				return 2;
			}
			//Health Tank
			case 100255200:
			{
				return 6;
			}
			//Shock Tank
			case 100165255:
			{
				return 15;
			}
			//Warp Tank
			case 130130255:
			{
				return 3;
			}
			//Flash Tank
			case 25500:
			{
				return 21;
			}
			//Reverse Flash Tank
			case 2552550:
			{
				return 22;
			}
			//Armageddon Tank
			case 7500:
			{
				return 23;
			}
			//Minion Tank
			case 225225225:
			{
				return 25;
			}
			//Bitch Tank
			case 255155255:
			{
				return 26;
			}
			//Trap Tank
			case 5512570:
			{
				return 27;
			}
			//Distraction Tank
			case 2252250:
			{
				return 28;
			}
			//Feedback Tank
			case 906090:
			{
				return 29;
			}
			//Psychotic Tank
			case 000:
			{
				return 30;
			}
			//Goliath Tank
			case 00100:
			{
				return 32;
			}
			//Psykotik Tank
			case 111:
			{
				return 33;
			}
			//Spykotik Tank
			case 255100255:
			{
				return 34;
			}
			//Spypsy Tank
			case 00255:
			{
				return 37;
			}
			//Mirage Tank
			case 254025:
			{
				return 40;
			}
			//Shield Tank
			case 135205255:
			{
				return 17;
			}
			//Witch Tank
			case 255200255:
			{
				return 16;
			}
			//Boomer Tank
			case 651050:
			{
				return 12;
			}
			//Smoker Tank
			case 12085120:
			{
				return 11;
			}
			//Hunter Tank
			case 2590185:
			{
				return 10;
			}
			//Default Tank
			case 255255255:
			{
				return 0;
			}
		}
	}
	return -1;
}
//=============================
// COMMANDS
//=============================
stock CheatCommand(client, const String:command[], const String:arguments[])
{
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s %s", command, arguments );
	SetCommandFlags(command, flags | FCVAR_CHEAT);
}
stock DirectorCommand(client, String:command[])
{
	new flags = GetCommandFlags(command);
	SetCommandFlags(command, flags & ~FCVAR_CHEAT);
	FakeClientCommand(client, "%s", command);
	SetCommandFlags(command, flags | FCVAR_CHEAT);
}
//=============================
// GAMEFRAME
//=============================
public OnGameFrame()
{
	if(!IsServerProcessing()) return;

	if(bSuperTanksEnabled)
	{
		iFrame++;
		if(iFrame >= 3)
		{
			for(new i=1; i<=MaxClients; i++)
			{
				if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
				{
					SpeedRebuild(i);
					SpeedRebuild2(i);
				}
			}
			iFrame = 0;
		}
	}
}
//=============================
// TIMER 0.1
//=============================
public Action:TimerUpdate01(Handle:timer)
{
	if(!IsServerProcessing()) return Plugin_Continue;

	if(bSuperTanksEnabled && bDisplayHealthCvar)
	{
		for(new i=1; i<=MaxClients; i++)
		{
			if(IsClientInGame(i) && GetClientTeam(i) == 2)
			{
				if(!IsFakeClient(i))
				{
					new entity = GetClientAimTarget(i, false);
					if(IsValidEntity(entity))
					{
						new String:classname[32];
						GetEdictClassname(entity, classname, sizeof(classname));
						if(StrEqual(classname, "player", false))
						{
							if(entity > 0)
							{
								if(IsTank(entity))
								{
									new health = GetClientHealth(entity);
									PrintHintText(i, "%N (%d HP)", entity, health);
								}
							}
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}
//=============================
// TIMER 1.0
//=============================
public Action:TimerUpdate1(Handle:timer)
{
	if(!IsServerProcessing()) return Plugin_Continue;

	if(bSuperTanksEnabled)
	{
		TankController();
		SetConVarInt(FindConVar("z_max_player_zombies"), 32);
		for(new i=1; i<=MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				if(GetClientTeam(i) == 2)
				{
					if(PlayerSpeed[i] > 0)
					{
						PlayerSpeed[i] -= 1;
					}
				}
				else if(GetClientTeam(i) == 3)
				{
					if(IsFakeClient(i))
					{
						new zombie = GetEntData(i, FindSendPropInfo("CTerrorPlayer", "m_zombieClass"));
						if(zombie == 8)
						{
							CreateTimer(3.0, TankLifeCheck, i, TIMER_FLAG_NO_MAPCHANGE);
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}