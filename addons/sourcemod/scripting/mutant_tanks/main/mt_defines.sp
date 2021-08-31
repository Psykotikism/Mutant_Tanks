/**
 * Mutant Tanks: a L4D/L4D2 SourceMod Plugin
 * Copyright (C) 2021  Alfred "Psyk0tik" Llagas
 *
 * This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **/

#if !defined MT_CORE_MAIN
        #error This file must be inside "scripting/mutant_tanks/main" while compiling "mutant_tanks.sp" to work.
#endif

#define MODEL_CONCRETE_CHUNK "models/props_debris/concrete_chunk01a.mdl"
#define MODEL_FIREWORKCRATE "models/props_junk/explosive_box001.mdl" // Only available in L4D2
#define MODEL_GASCAN "models/props_junk/gascan001a.mdl"
#define MODEL_OXYGENTANK "models/props_equipment/oxygentank01.mdl"
#define MODEL_PROPANETANK "models/props_junk/propanecanister001a.mdl"
#define MODEL_TANK_MAIN "models/infected/hulk.mdl"
#define MODEL_TANK_DLC "models/infected/hulk_dlc3.mdl"
#define MODEL_TANK_L4D1 "models/infected/hulk_l4d1.mdl" // Only available in L4D2
#define MODEL_TIRES "models/props_vehicles/tire001c_car.mdl"
#define MODEL_TREE_TRUNK "models/props_foliage/tree_trunk.mdl"
#define MODEL_WITCH "models/infected/witch.mdl"
#define MODEL_WITCHBRIDE "models/infected/witch_bride.mdl" // Only available in L4D2

#define PARTICLE_ACHIEVED "achieved"
#define PARTICLE_BLOOD "boomer_explode_D"
#define PARTICLE_ELECTRICITY "electrical_arc_01_system"
#define PARTICLE_FIRE "aircraft_destroy_fastFireTrail"
#define PARTICLE_FIREWORK "mini_fireworks"
#define PARTICLE_GORE "gore_wound_fullbody_1"
#define PARTICLE_ICE "apc_wheel_smoke1"
#define PARTICLE_METEOR "smoke_medium_01"
#define PARTICLE_SMOKE "smoker_smokecloud"
#define PARTICLE_SPIT "spitter_projectile" // Only available in L4D2
#define PARTICLE_SPIT2 "spitter_slime_trail" // Only available in L4D2

#define SOUND_ACHIEVEMENT "ui/pickup_misc42.wav"
#define SOUND_DAMAGE "player/damage1.wav"
#define SOUND_DAMAGE2 "player/damage2.wav"
#define SOUND_DEATH "ui/pickup_scifi37.wav"
#define SOUND_ELECTRICITY "items/suitchargeok1.wav"
#define SOUND_EXPLOSION2 "weapons/grenade_launcher/grenadefire/grenade_launcher_explode_2.wav" // Only available in L4D2
#define SOUND_EXPLOSION1 "animation/van_inside_debris.wav" // Only used in L4D1
#define SOUND_LADYKILLER "ui/alert_clink.wav"
#define SOUND_METAL "physics/metal/metal_solid_impact_hard5.wav"
#define SOUND_NULL "common/null.wav"
#define SOUND_SPAWN "ui/pickup_secret01.wav"
#define SOUND_SPIT "player/spitter/voice/warn/spitter_spit_02.wav" // Only available in L4D2

#define SPRITE_EXPLODE "sprites/zerogxplode.spr"
#define SPRITE_GLOW "sprites/glow01.vmt"
#define SPRITE_LASER "sprites/laser.vmt"
#define SPRITE_LASERBEAM "sprites/laserbeam.vmt"

#define MT_ARRIVAL_SPAWN (1 << 0) // announce spawn
#define MT_ARRIVAL_BOSS (1 << 1) // announce evolution
#define MT_ARRIVAL_RANDOM (1 << 2) // announce randomization
#define MT_ARRIVAL_TRANSFORM (1 << 3) // announce transformation
#define MT_ARRIVAL_REVERT (1 << 4) // announce revert

#define MT_CMD_SPAWN (1 << 0) // "sm_tank"/"sm_mt_tank"
#define MT_CMD_CONFIG (1 << 1) // "sm_mt_config"
#define MT_CMD_LIST (1 << 2) // "sm_mt_list"
#define MT_CMD_RELOAD (1 << 3) // "sm_mt_reload"
#define MT_CMD_VERSION (1 << 4) // "sm_mt_version"

#define MT_CONFIG_DIFFICULTY (1 << 0) // difficulty_configs
#define MT_CONFIG_MAP (1 << 1) // l4d_map_configs/l4d2_map_configs
#define MT_CONFIG_GAMEMODE (1 << 2) // l4d_gamemode_configs/l4d2_gamemode_configs
#define MT_CONFIG_DAY (1 << 3) // daily_configs
#define MT_CONFIG_PLAYERCOUNT (1 << 4) // playercount_configs
#define MT_CONFIG_SURVIVORCOUNT (1 << 5) // survivorcount_configs
#define MT_CONFIG_INFECTEDCOUNT (1 << 6) // infectedcount_configs
#define MT_CONFIG_FINALE (1 << 7) // l4d_finale_configs/l4d2_finale_configs

#define MT_CONFIG_FILE "mutant_tanks.cfg"
#define MT_CONFIG_PATH "data/mutant_tanks/"
#define MT_CONFIG_PATH_DAY "daily_configs/"
#define MT_CONFIG_PATH_DIFFICULTY "difficulty_configs/"
#define MT_CONFIG_PATH_FINALE "l4d_finale_configs/"
#define MT_CONFIG_PATH_FINALE2 "l4d2_finale_configs/"
#define MT_CONFIG_PATH_GAMEMODE "l4d_gamemode_configs/"
#define MT_CONFIG_PATH_GAMEMODE2 "l4d2_gamemode_configs/"
#define MT_CONFIG_PATH_INFECTEDCOUNT "infectedcount_configs/"
#define MT_CONFIG_PATH_MAP "l4d_map_configs/"
#define MT_CONFIG_PATH_MAP2 "l4d2_map_configs/"
#define MT_CONFIG_PATH_PLAYERCOUNT "playercount_configs/"
#define MT_CONFIG_PATH_SURVIVORCOUNT "survivorcount_configs/"

#define MT_CONFIG_SECTION_MAIN "Mutant Tanks"
#define MT_CONFIG_SECTION_MAIN2 "MutantTanks"
#define MT_CONFIG_SECTION_MAIN3 "Mutant_Tanks"
#define MT_CONFIG_SECTION_MAIN4 "MTanks"
#define MT_CONFIG_SECTION_MAIN5 "MT"
#define MT_CONFIG_SECTION_SETTINGS "PluginSettings"
#define MT_CONFIG_SECTION_SETTINGS2 "Plugin Settings"
#define MT_CONFIG_SECTION_SETTINGS3 "Plugin_Settings"
#define MT_CONFIG_SECTION_SETTINGS4 "settings"
#define MT_CONFIG_SECTION_GENERAL "General"
#define MT_CONFIG_SECTION_ANNOUNCE "Announcements"
#define MT_CONFIG_SECTION_ANNOUNCE2 "announce"
#define MT_CONFIG_SECTION_COLORS "Colors"
#define MT_CONFIG_SECTION_REWARDS "Rewards"
#define MT_CONFIG_SECTION_COMP "Competitive"
#define MT_CONFIG_SECTION_COMP2 "comp"
#define MT_CONFIG_SECTION_DIFF "Difficulty"
#define MT_CONFIG_SECTION_DIFF2 "diff"
#define MT_CONFIG_SECTION_HEALTH "Health"
#define MT_CONFIG_SECTION_HUMAN "HumanSupport"
#define MT_CONFIG_SECTION_HUMAN2 "Human Support"
#define MT_CONFIG_SECTION_HUMAN3 "Human_Support"
#define MT_CONFIG_SECTION_HUMAN4 "human"
#define MT_CONFIG_SECTION_WAVES "Waves"
#define MT_CONFIG_SECTION_CONVARS "ConVars"
#define MT_CONFIG_SECTION_CONVARS2 "cvars"
#define MT_CONFIG_SECTION_GAMEMODES "GameModes"
#define MT_CONFIG_SECTION_GAMEMODES2 "Game Modes"
#define MT_CONFIG_SECTION_GAMEMODES3 "Game_Modes"
#define MT_CONFIG_SECTION_GAMEMODES4 "modes"
#define MT_CONFIG_SECTION_CUSTOM "Custom"
#define MT_CONFIG_SECTION_GLOW "Glow"
#define MT_CONFIG_SECTION_SPAWN "Spawn"
#define MT_CONFIG_SECTION_BOSS "Boss"
#define MT_CONFIG_SECTION_COMBO "Combo"
#define MT_CONFIG_SECTION_RANDOM "Random"
#define MT_CONFIG_SECTION_TRANSFORM "Transform"
#define MT_CONFIG_SECTION_ADMIN "Administration"
#define MT_CONFIG_SECTION_ADMIN2 "admin"
#define MT_CONFIG_SECTION_PROPS "Props"
#define MT_CONFIG_SECTION_PARTICLES "Particles"
#define MT_CONFIG_SECTION_ENHANCE "Enhancements"
#define MT_CONFIG_SECTION_ENHANCE2 "enhance"
#define MT_CONFIG_SECTION_IMMUNE "Immunities"
#define MT_CONFIG_SECTION_IMMUNE2 "immune"

#define MT_DETOUR_LIMIT 100 // number of detours allowed

#define MT_EFFECT_TROPHY (1 << 0) // trophy
#define MT_EFFECT_FIREWORKS (1 << 1) // fireworks particles
#define MT_EFFECT_SOUND (1 << 2) // sound effect
#define MT_EFFECT_THIRDPERSON (1 << 3) // thirdperson view

#define MT_INFAMMO_PRIMARY (1 << 0) // primary weapon
#define MT_INFAMMO_SECONDARY (1 << 1) // secondary weapon
#define MT_INFAMMO_THROWABLE (1 << 2) // throwable
#define MT_INFAMMO_MEDKIT (1 << 3) // medkit
#define MT_INFAMMO_PILLS (1 << 4) // pills

#define MT_JUMP_FALLPASSES 3 // safe fall passes
#define MT_JUMP_FORWARDBOOST 50.0 // forward boost for each jump

#define MT_PARTICLE_BLOOD (1 << 0) // blood particle
#define MT_PARTICLE_ELECTRICITY (1 << 1) // electric particle
#define MT_PARTICLE_FIRE (1 << 2) // fire particle
#define MT_PARTICLE_ICE (1 << 3) // ice particle
#define MT_PARTICLE_METEOR (1 << 4) // meteor particle
#define MT_PARTICLE_SMOKE (1 << 5) // smoke particle
#define MT_PARTICLE_SPIT (1 << 6) // spit particle

#define MT_PATCH_LIMIT 50 // number of patches allowed
#define MT_PATCH_MAXLEN 48 // number of bytes allowed

#define MT_PROP_BLUR (1 << 0) // blur prop
#define MT_PROP_LIGHT (1 << 1) // light prop
#define MT_PROP_OXYGENTANK (1 << 2) // oxgyen tank prop
#define MT_PROP_FLAME (1 << 3) // flame prop
#define MT_PROP_ROCK (1 << 4) // rock prop
#define MT_PROP_TIRE (1 << 5) // tire prop
#define MT_PROP_PROPANETANK (1 << 6) // propane tank prop
#define MT_PROP_FLASHLIGHT (1 << 7) // flashlight prop
#define MT_PROP_CROWN (1 << 8) // crown prop

#define MT_ROCK_BLOOD (1 << 0) // blood particle
#define MT_ROCK_ELECTRICITY (1 << 1) // electric particle
#define MT_ROCK_FIRE (1 << 2) // fire particle
#define MT_ROCK_SPIT (1 << 3) // spit particle

#define MT_USEFUL_REFILL (1 << 0) // useful refill reward
#define MT_USEFUL_HEALTH (1 << 1) // useful health reward
#define MT_USEFUL_AMMO (1 << 2) // useful ammo reward
#define MT_USEFUL_RESPAWN (1 << 3) // useful respawn reward

#define MT_VISUAL_SCREEN (1 << 0) // screen color
#define MT_VISUAL_PARTICLE (1 << 1) // particle effect
#define MT_VISUAL_VOICELINE (1 << 2) // looping voiceline
#define MT_VISUAL_LIGHT (1 << 3) // flashlight
#define MT_VISUAL_BODY (1 << 4) // body color
#define MT_VISUAL_GLOW (1 << 5) // glow outline