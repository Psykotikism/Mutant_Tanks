# Changelog

## Version 8.46 (TBA)

Changes:

1. Added new target filters: @special, @infected
2. The "Ability Effect" settings are now disabled by default.
3. All Chance settings now accept 0.0% as a valid value.
4. The "Skin-Glow Colors" and "Props Colors" settings now use random RGBA combinations when given invalid values (values less than 0 or greater than 255).

Files:

1. Updated config file.
2. Updated include file.

## Version 8.45 (October 31, 2018)

Bug fixes:

1. Fixed the Clone and Minion abilities not resetting properly.
2. Fixed the Witch ability spamming chat.
3. Fixed the "Ability Message" settings not working properly.

Changes:

1. The sm_tank command now accepts partial name matches as input values. (Example: sm_tank "boss")
2. Moved some stock functions from include file to some of the module plugins.
3. Lowered the "Tank Name" setting's character limit from 128 to 32.
4. The Medic ability now lets Super Tanks heal nearby special infected by 1 HP every second.
5. The "Whirl Axis" setting now accepts different values.
6. The Throw ability now has a 4th option - Super Tanks can throw Witches.
7. Several abilities' "Ability Message" setting now accepts different values.
8. Added the "Clone Replace" setting.
9. Added the "Cloud Chance" setting.
10. Added the "Jump Mode" setting.
11. Added the "Jump Sporadic Chance" setting.
12. Added the "Jump Sporadic Height" setting.
13. Added the "Meteor Mode" setting.
14. Added the "Minion Replace" setting.
15. Added the "Regen Chance" setting.
16. Added the "Shield Chance" setting.
17. Added the "Throw Chance" setting.
18. Added the "Witch Chance" setting.
19. Removed some redundant code from multiple module plugins.

Files:

1. Updated config file.
2. Updated include file.
3. Updated translation file.

## Version 8.44 (October 16, 2018)

Bug fixes:

1. Fixed the Absorb, Fragile, and Hypno abilities not working properly.
2. Fixed the datapack leaks from various modules.
3. Fixed the Range Chance settings not working at all.
4. Fixed the issue with props and special effects not deleting themselves properly, thus causing crashes.
5. Fixed the Throw ability's cars having a strong velocity, thus pushing other entities away.

Changes:

1. Improved readability of the source code for each plugin.
2. Added the Aimless, Choke, Cloud, Drunk, and Whirl abilities.
3. Added new settings for several abilities to handle timer intervals and damage values.
4. The Electric, Hurt, and Splash abilities now use SDKHooks_TakeDamage() to damage players.
5. The damage settings of the Electric, Hurt, and Splash abilities now accept float values (decimals) instead of int values (whole numbers).
6. Renamed a bunch of settings.
7. Decreased Super Tank type limit back to 500 to avoid server freezes and lag spikes.
8. Removed the st_enableplugin cvar setting.
9. Chance and Range Chance settings now only accept decimal (float) values.
10. Chance and Range Chance settings now work differently. (Before: 1/X chances, After: X/100.0 probability)
11. Added the "Base Health" setting to determine the base health of each Super Tank.
12. Added the "Tank Chance" setting to determine the chances of a Super Tank type spawning.
13. Added the ST_TankChance() native for the new "Tank Chance" setting.
14. The core plugin and its modules now require SM 1.10.0.6352 or higher.
15. The core plugin now properly updates all settings when the config file is refreshed.
16. Removed the sm_tanklist command.

Files:

1. Updated config file with the new settings.
2. Updated include file for better readability.

## Version 8.43 (October 2, 2018)

Bug fixes:

1. Fixed some abilities not displaying messages.

Changes:

1. Renamed function parameters for better understanding.

Files:

1. Updated include file.

## Version 8.42 (October 2, 2018)

Bug fixes:

1. Marked the ST_TankName and ST_TankWave natives as optional to avoid potential issues.
2. Fixed the Flash ability errors. (Thanks Mi.Cura for reporting!)
3. Fixed the Rocket ability creating multiple timers for survivors who are getting sent into space.
4. Fixed several abilities not resetting when a Super Tank dies.

Changes:

1. Renamed/removed some stocks.
2. The plugin and its modules now requires SM 1.10.0.6317 or higher.
3. The Tank Notes now display a different message when the phrase for a Super Tank is not found.
4. Changed the directory of the configs from "cfg/sourcemod" to "addons/sourcemod/data".
5. Added a new native: ST_TankColors - Retrieves a Super Tank's colors.
6. The Gravity ability's "Gravity Value" now accepts higher values.
7. The Health ability no longer allows a Super Tank to set survivors to black and white.
8. The Jump ability now provides more features.
9. The Pyro ability now provides more features.
10. The Restart ability now removes all weapons from survivors before giving them new loadouts.
11. Lowered the amount of boss stages from 5 to 4. Any boss that spawns automatically starts at stage 1.
12. Moved various settings under new sections and reorganized/restructured the config file.
13. Merged the Cancer ability with the Health ability.
14. Added 2 new abilities: Lag and Recoil
15. Added the ST_PluginEnd() and ST_Preset() forwards.
16. Added several checks for better handling of timers.
17. Added several new settings.
18. Renamed several settings.

Files:

1. Updated config file with all the new settings, presets, and organization/structure.
2. Updated gamedata file to remove unused signatures.
3. Updated include file to use new natives introduced in SM 1.9 and SM 1.10, and to add new forwards and natives.
4. Updated translation file with new phrases and reformatted the phrase name of the Tank Note phrases.

## Version 8.41 (September 18, 2018)

Bug fixes:

1. Fixed some abilities not accepting any 6+ digit values for damage settings.
2. Fixed the issue with the Shield ability not keeping the shield disabled when it's deactivated. (Thanks Mi.Cura for reporting!)

Changes:

1. Removed the "[ST++]" prefix from the Super Tank health display.
2. Added a message for each ability. (Each message can be configured in the translation file.)
3. Added an "Ability Message" setting to toggle the messages for each ability.
4. Added a range feature for some abilities.
5. Added a new native: ST_TankName(int client, char[] buffer) - Returns a Tank's custom name.
6. Removed the ST_Spawn(int client) forward. (Use ST_Ability(int client) instead for more flexibility.)
7. Added the "Flash Interval" setting for the Flash ability.
8. The "Tank Note" setting now only accepts 0 and 1 as values.
9. Tank Notes must now be created inside the translation file.

Files:

1. Updated config file with the new settings and modified some presets.
2. Updated include file to remove the ST_Spawn(int client) forward and add the new ST_TankName(int client, char[] buffer) native.
3. Updated translation file with the new messages and Tank Notes.

## Version 8.40 (September 11, 2018)

Bug fixes:

1. Fixed the datapack error with the Ghost ability.

Changes:

1. Changed all OnClientPostAdminCheck() forwards to OnClientPutInServer() instead.
2. Moved late loading code from OnMapStart() to OnPluginStart().

## Version 8.39 (September 10, 2018)

Bug fixes:

1. Fixed some abilities not working when their "Ability Enabled" setting is disabled. (Thanks huwong!)
2. Fixed the Gravity ability returning a datapack error.
3. Fixed the Bomb and Fire abilities not working in L4D1.
4. Fixed the Ice ability flinging survivors back at a high velocity after being unfrozen.
5. Fixed the Zombie ability not working properly.

Changes:

1. Added a new ability: Kamikaze ability - The Super Tank dies while taking a survivor with it.
2. Added a new ability: Leech ability - The Super Tank leeches health off of survivors.
3. Added a new ability: Necro ability - The Super Tank can resurrect nearby special infected that die.
4. Added a new ability: Quiet ability - The Super Tank can silence itself around survivors. (Useful for ninja-themed Super Tanks.)
5. Added a new native: ST_TankWave() - Returns the current finale wave.
6. Added a new native: ST_CloneAllowed(int client, bool clone) - Checks if a Super Tank's clone is allowed to use abilities like real Super Tanks.
7. Added the "Clone Mode" setting to determine if a Super Tank's clone can use abilities like real Super Tanks.
8. Added the "Finale Tank" setting to determine if a Super Tank only spawns during finales.
9. Added the "Tank Note" setting which is displayed in chat after a Super Tank spawns. (Character limit: 244)
10. Added a "X Hit Mode" (X = Name of ability) setting for various abilities.
11. Added the "Jump Range" setting to determine how close a Super Tank must be to a survivor before it can jump in the air.
12. Added the "Pyro Mode" setting to determine what kind of speed boost a Super Tank receives.
13. Added the "Zombie Interval" setting to determine how often a Super Tank can spawn zombie mobs.
14. The Ghost ability's "Ability Enabled" setting now has more options.
15. The Ghost ability no longer allows a Super Tank to cloak nearby special infected.
16. Removed the "Ghost Cloak Range" setting.
17. The Panic ability now allows the Tank to have a chance to start a panic event upon death.
18. The Warp ability's electricity particle effect now requires the "Particle Effect" and "Particle Effects" settings to allow it.
19. The code for various abilities have been slightly modified.
20. Updated the Super Tanks++ category in the admin menu.
21. Removed old code that was used for human support.
22. Made some code optimizations.

Files:

1. Added a translation file for the plugin. (Filename is "super_tanks++.phrases.txt")
2. New file: st_clone.inc (Used for the Clone ability's library.)
3. Updated config file with all the new settings.
4. Updated include file to add/remove code.

## Version 8.38 (September 6, 2018)

Bug fixes:

1. Fixed some modules not working properly for custom configs.
2. Fixed custom configs not working.
3. Fixed Tanks having the "unnamed" name when Boss mode is enabled. (Thanks Zytheus!)
4. Fixed the Splash ability creating multiple timers.

Changes:

1. Increased the maximum amount of possible Super Tank types from 2500 to 5000.
2. Replaced the "Maximum Types" setting with the new "Type Range" setting. (Usage: "Type Range" "1-5000")
3. Changed the display info for each Super Tank type on the ST++ menu. (Before: "Tank's Name", After: "Tank's Name (Tank #)")
4. The plugin no longer generates a config file nor a backup copy of it. (This feature was just wasting space and was overall unnecessary.)
5. Removed the "Create Backup" setting.
6. Removed support for human-controlled Tanks. (This feature was buggy and made the Infected team overpowered.)
7. Removed the "Human Super Tanks" setting.

Files:

1. Updated include file to add new natives, remove some stocks, and remove support for auto-config generation.
2. Smaller file sizes.

## Version 8.37 (August 30, 2018)

Changes:

1. Added support for dynamic loading to the modules. (Thanks Lux!)
2. Switched RemoveEntity(entity) back to AcceptEntityInput(entity, "Kill") just to be courteous to those who prefer to still use SM 1.8.
3. Removed IsDedicatedServer() just to be courteous to those who do not have dedicated servers. (Please don't report bugs if you're playing on a local/listen server. :/)

## Version 8.36 (August 20, 2018)

Bug fixes:

1. Fixed issues with the Tank when the "Finales Only" setting is set to 1.

Changes:

1. Optimized code a bit for the plugin and all of its modules.

## Version 8.35 (August 16, 2018)

Bug fixes:

1. Rock ability - Fixed the "Rock Radius" KeyValue setting not being read properly due to a small buffer size.
2. Drop ability - Fixed incorrect scaling on some of the melee weapons.

Changes:

1. Warp ability - The Super Tank will no longer warp to incapacitated survivors.
2. Restart ability - Survivors will no longer warp to incapacitated teammates.
3. New ability added: Cancer ability - The Super Tank gives survivors cancer (survivors die when they reach 0 HP instead of getting incapacitated first).
4. Added the command "sm_tanklist" which prints a list of Super Tanks and their current statuses on the user's console.
5. Added the following new settings for the Absorb and Fragile abilities:

- "Absorb Bullet Damage"
- "Absorb Explosive Damage"
- "Absorb Fire Damage"
- "Absorb Melee Damage"
- "Fragile Bullet Damage"
- "Fragile Explosive Damage"
- "Fragile Fire Damage"
- "Fragile Melee Damage"

6. The plugin and all of its modules no longer work on locally-hosted/listen servers. (I'm tired of people reporting issues from their listen servers...)
7. The plugin and all of its modules now require SM 1.9.0.6225 or higher to work.
8. Removed unnecessary code.

Files:

1. Updated gamedata file with a new signature for "CTerrorPlayer_OnStaggered" for Windows to make the Shove ability compatible with Left 4 Downtown 2. (Thanks Spirit_12!)

## Version 8.34 (August 12, 2018)

Bug fixes:

1. Fixed the Drop ability not properly deleting weapon entities attached to the Super Tank when he dies.

Changes:

1. Moved some lines of code around, optimized some code, etc.
2. The Puke ability now gives the Super Tank a chance to puke on survivors when being hit with a melee weapon.
3. The following settings can now be set for each Tank instead of affecting all Tanks at once:

- "Boss Health Stages"
- "Boss Stages"
- "Random Interval"
- "Spawn Mode"

Files:

1. The auto-generated config file has less presets (smaller file size).

## Version 8.33 (August 10, 2018)

Bug fixes:

1. Fixed the Witch ability causing crashes when converting common infected into Witch minions.

Changes:

1. Added a boss mode feature, which is a feature taken from the original Last Boss. View the INFORMATION.md file for more details. (2 new settings: "Boss Health Stages" and "Boss Stages")
2. Added a random mode feature, which is a feature that randomizes Super Tanks every X seconds after spawning. View the INFORMATION.md file for more details. (1 new setting: "Random Interval")
3. Added a new forward to use for the boss and random modes:

forward void ST_BossStage(int client); (This forward is called when the Super Tank is evolving into the next stage.)

4. Added the "Spawn Mode" KeyValue setting to allow users to decide if Super Tanks either spawn normally, spawn as bosses (boss mode), or spawn as randomized Tanks (random mode).
5. The Splash ability now damages nearby survivors every X seconds while the Super Tank is alive.
6. Added the "Splash Interval" KeyValue setting to support the new Splash ability feature.
7. The Vampire ability's "Vampire Health" KeyValue setting now only applies to the range ability. (When the Super Tank hits a survivor, he now gains the amount of damage as health.)
8. The Witch ability's range used for detecting nearby common infected can now be configurable via the new "Witch Range" KeyValue setting.
9. Changed a few lines of code.

Files:

1. Updated include file with the new settings.
2. Updated config file with the new settings.
3. Updated INFORMATION.md file with information about the new settings.

## Version 8.32 (August 6, 2018)

Bug fixes:

1. Fixed the "Enabled Game Modes" and "Disabled Game Modes" settings not allowing more than 64 characters.

Changes:

1. Lowered the character limit of the "Enabled Game Modes" and "Disabled Game Modes" settings from 2048 to 512.
2. Rocks thrown by Tanks now have the same color as the rocks attached to their bodies.
3. Removed the "information" folder in favor of the INFORMATION.md file that comes with the plugin's package.

Files:

1. Updated include file (super_tanks++.inc).
2. Updated core plugin (super_tanks++.sp).
3. Updated all plugins to stop creating information files.
4. Updated config file.

## Version 8.31 (August 4, 2018)

Bug fixes:

1. Fixed errors reported by Mi.Cura regarding the Rock ability.
2. Fixed potential bugs and errors from various abilities.

Changes:

1. Added a 3rd parameter for the sm_tank command. (Usage: sm_tank <1-2500> <0: spawn at crosshair, 1: spawn automatically>)
2. Added the "Drop Mode" KeyValue setting to determine what kind of weapons the Super Tank can drop. (0: Both|1: Guns only|2: Melee weapons only)
3. Changed how the Pyro ability detects Tanks that are on fire.
4. Major code optimization. (Thanks Lux!)

Files:

1. Updated include file.
2. Updated config file.

## Version 8.30 (August 2, 2018)

Changes:

1. Added the "Regen Limit" KeyValue setting for the Regen Ability. More information in the "information" folder and README file on GitHub.
2. Added the "Restart Mode" KeyValue setting for the Restart ability. More information in the "information" folder and README file on GitHub.
3. Added the "st_enableplugin" cvar so users can disable the plugin via console. (The ConVar-based config file is located in cfg/sourcemod/ while the KeyValues-based config file is still located in cfg/sourcemod/super_tanks++.)

Files:

1. Updated include file with the new settings.
2. Updated config file with the new settings.
3. Added the "information" folder in the same location as the config file which contains information about each ability and setting.

## Version 8.29 (July 31, 2018)

Bug fixes:

1. Fixed potential idle bug.

Changes:

1. Added the "Claw Damage" KeyValue setting under the "Enhancements" section which determines how much damage a Tank's claw attack does.
2. Added the "Rock Damage" KeyValue setting under the "Enhancements" section which determines how much damage a Tank's rock throw does.
2. Moved all stock/common functions to the include file.
3. Replaced multiple forwards with one forward to handle events hooked by the core plugin.
4. Removed an extra check for spawning Super Tanks from the sm_tank menu.
5. Removed unused code.

Files:

1. Updated gamedata file with new signatures for the Idle ability.
2. Updated include file to store more stock/common functions and to remove unused KeyValue settings from the auto-config generator.
3. Updated config file to remove unused KeyValue settings from the config file.

## Version 8.28 (July 28, 2018)

Bug fixes:

1. Fixed the Panic ability not working in L4D1.

Changes:

1. Changed how the Bomb ability creates explosions to prevent crashes.
2. Removed the "Bomb Power" setting.
3. Optimized code a bit.

Files:

1. Updated include file to remove the "Bomb Power" setting from the auto-config generator.
2. Updated config file to remove the "Bomb Power" setting.

## Version 8.27 (July 28, 2018)

Changes:

1. Added extra checks to make sure the plugin spawns the proper amount of Tanks for each wave.
2. Lessened the occurrence of Tanks flashing all over the map on finales. (Set "Glow Effect" to 1 to completely disable the glow outlines.)

Files:

1. super_tanks++.sp (Where the extra checks were added.)
2. super_tanks++.inc (Updated version number.)

## Version 8.26 (July 28, 2018)

Bug fixes:

1. Fixed some abilities and features staying on even when the "Human Super Tanks" KeyValue setting is set to 0.
2. Fixed some abilities and features staying on even when they're disabled for a specific Tank.
3. Fixed OnTakeDamage errors reported by FatalOE71.
4. Fixed the issue with so many Tanks spawning towards the end of finales.
5. Fixed various abilities not working properly.
6. Fixed the issue with Tanks that have the Fragile ability not dying properly.

Changes:

1. Added a new native for developers to use: native bool ST_TankAllowed(int client) - Returns the status of the "Human Super Tanks" setting.
2. Added a new native for developers to use: native int ST_MaxTypes() - Returns the value of the "Maximum Types" setting.
3. Added a new forward for developers to use: forward void ST_Death2(int enemy, int client) - Called when a Tank dies and returns the attacker's index.
4. Added checks to various timers in case abilities are disabled before the timers are triggered.
5. Added a check to prevent clone Tanks from being counted as actual Tanks.
6. The Clone ability no longer spawns more clones when all of the current clones die. (This is to prevent glitches with the Tank spawner.)

Files:

1. Updated include file with the new natives and forward.

## Version 8.25 (July 26, 2018)

Bug fixes:

1. Fixed the Tank limit for each wave not working properly. (Thanks Mi.Cura!)

Changes:

1. Added Range Chance settings and other settings for various abilities for better control.

Files:

1. Updated include file to include the new settings.

## Version 8.24 (July 26, 2018)

Bug fixes:

1. Fixed various errors reported by Princess LadyRain.
2. Fixed various abilities not working properly.

Changes:

1. Added new abilities and renamed some settings.
2. Removed unnecessary code.
3. Divided the plugin into multiple files for the following reasons:

- To avoid slow compilation time.
- To make it easier to add new abilities.
- To make it easier to identify problems within the code.
- To make each ability optional.

Files:

1. Updated include file to remove unnecessary code and transfer some of it to other files.
2. Updated gamedata file to remove unused signatures.
3. Updated config file with new settings and presets.

## Version 8.23 (July 20, 2018)

Bug fixes:

1. Fixed various errors reported by Princess LadyRain.

Changes:

1. Users can now change settings inside the config file mid-game without having to reload the plugin or restart the server. (Basically the counterpart of ConVar.AddChangeHook for cvars.)

Files:

1. Updated include file.

## Version 8.22 (July 20, 2018)

Bug fixes:

1. Fixed the issue with some KeyValue settings not working properly.
2. Fixed various bugs.

Changes:

1. Restructured the config file.
2. Added a ton of new KeyValues for many abilities.
3. Added new abilities.
4. Increased the maximum amount of possible Super Tank types from 1000 to 2500.
5. The plugin now creates a folder inside cfg/sourcemod/super_tanks++ called "backup_config" which contains a copy of the config file in case users need it.
6. Added checks to trim all string-related settings to get rid of any white spaces.
7. Raised the value limits of various settings.

Files:

1. Updated config file with the new settings and new presets.
2. Updated include file.

## Version 8.21 (July 14, 2018)

Bug fixes:

1. Fixed the error coming from OnTakeDamage.
2. Fixed the error regarding a missing translation phrase when a vote is in progress.

Changes:

1. Added the "Regenerate Ability" KeyValue which lets the Super Tank regenerate health.
2. Added the "Regenerate Health" Keyvalue which determines how much health the Super Tank regenerates.
3. Added the "Regenerate Interval" KeyValue which decides how often the Super Tank regenerates health.
4. Added the "Rock Ability" KeyValue which lets the Super Tank start rock showers.
5. Added the "Rock Chance" KeyValue which decides how often the Super Tank can start rock showers.
6. Added the "Rock Damage" KeyValue which determines how much damage the Super Tank's rocks do.
7. Added the "Rock Duration" KeyValue which determines how long the Super Tank's rock shower lasts.
8. Added the "Rock Radius" KeyValue which determines the radius of the Super Tank's rock shower.
9. Added the "Meteor Radius" KeyValue which determines the radius of the Super Tank's meteor shower.
10. Added the "Rock Effect" KeyValue which lets users attach particle effects to the Super Tank's rocks.
11. Added the "Rock Effects" KeyValue which decides what particle effects are attached to the Super Tank's rocks.
12. Replaced the "Spam Amount" KeyValue with "Spam Chance" which decides how often the Super Tank can spam rocks at survivors.
13. Replaced the "Spam Interval" KeyValue with "Spam Duration" which determines how long the Super Tank's rock spam lasts.
14. Added the "Flash Duration" KeyValue which determines how long the Super Tank's special speed lasts.
15. The blur effect from the Flash ability is now treated as a prop.

New formats:

"Props Attached" "123456"
"Props Chance" "3,3,3,3,3,3"

Files:

1. Updated config file with new presets.
2. Updated include file.

## Version 8.20 (July 12, 2018)

Changes:

1. Renamed the "Common Ability" and "Common Amount" KeyValues to "Zombie Ability" and "Zombie Amount".
2. The "Acid Claw-Rock" and "Fling Claw-Rock" abilities are now replaced with the "Puke Claw-Rock" ability on L4D1, even if the Super Tank does not have the "Puke Claw-Rock" ability enabled for it.
3. Added the "Pimp Claw-Rock" KeyValue which lets the Super Tank pimp slap survivors.
4. Added the "Pimp Amount" KeyValue which determines how many times the Super Tank can pimp slap survivors in a row.
5. Added the "Pimp Chance" KeyValue which determines how often the Super Tank pimp slaps survivors.
6. Added the "Pimp Damage" KeyValue which determines the damage of the Super Tank's pimp slaps.
7. Added the "Minion Ability" KeyValue which lets the Super Tank spawn special infected behind itself.
8. Added the "Minion Amount" KeyValue which determines how many minions the Super Tank can spawn.
9. Added the "Minion Chance" KeyValue which determines how often the Super Tank spawns special infected behind itself.
10. Added the "Minion Types" KeyValue which decides what special infected the Super Tank can spawn behind itself.
11. Added the "God Ability" KeyValue which lets the Super Tank have temporary god mode.
12. Added the "God Chance" KeyValue which determines how often the Super Tank gets temporary god mode.
13. Added the "God Duration" KeyValue which decides how long the Super Tank's temporary god mode lasts.
14. Added the "Clone Ability" KeyValue which lets the Super Tank spawn clones of itself.
15. Added the "Clone Amount" KeyValue which determines how many clones the Super Tank can spawn.
16. Added the "Clone Chance" KeyValue which determines how often the Super Tank can spawn clones of itself.
17. Added the "Clone Health" KeyValue which decides how much health each clone of the Super Tank gets.
18. Used a better method for preventing Tanks from getting stuck in the dying animation.

Files:

1. Updated include file.

## Version 8.19 (July 10, 2018)

Bug fixes:

1. Fixed the "Enabled Game Modes" and "Disabled Game Modes" KeyValues not working properly.
2. Fixed the particle effects for Super Tanks not appearing. (Thanks Mi.Cura!)
3. Fixed the wrong Super Tanks spawning when they are spawned through the Super Tanks++ Menu. (Thanks Mi.Cura!)

Changes:

1. Raised the character limit of the "Enabled Game Modes" and "Disabled Game Modes" KeyValues from 32 to 64.
2. Added the "Game Mode Types" KeyValue to enable/disable the plugin in certain game mode types. (1: Co-Op, 2: Versus, 4: Survival, 8: Scavenge)
3. Changed the permissions for the config file directories.

Files:

1. Updated include file.

## Version 8.18 (July 8, 2018)

Bug fixes:

1. Fixed the Spam ability creating multiple timers.
2. Fixed the Super Tanks not taking any type of explosive damage.
3. Fixed the Shield ability preventing Super Tanks with less than 100 HP from dying.
4. Fixed the Bomb ability's particle effects not appearing.

Changes:

1. Added the "Explosive Immunity" KeyValue which gives the Super Tank immunity to blast damage.
2. Added the "Bullet Immunity" KeyValue which gives the Super Tank immunity to bullet damage.
3. Added the "Melee Immunity" KeyValue which gives the Super Tank immunity to melee damage.
4. Added the "Absorb Ability" KeyValue which lets the Super Tank absorb most of the damage it receives, so they take less damage.
5. Added the "Pyro Ability" KeyValue which lets the Super Tank gain a speed boost when on fire.
6. Added the "Pyro Boost" KeyValue which lets users decide how much speed boost the Super Tank gains when on fire.
7. Added the "Self Throw Ability" KeyValue which lets the Super Tank throw itself.
8. Added the "Nullify Claw-Rock" KeyValue which lets the Super Tank nullify all of a survivor's damage.
9. Added the "Nullify Chance" KeyValue which decides how often the Super Tank can nullify all of a survivor's damage.
10. Added the "Nullify Duration" KeyValue which decides how long the Super Tank can nullify all of a survivor's damage.
11. Buried survivors are now frozen in place.
12. Buried survivors are now teleported to nearby teammates to avoid falling through the map after being unburied.
13. The Hypno ability no longer sets survivors' HP to 1 when the inflicted damage is higher than their health, but rather incapacitates them.
14. Removed the "Tank Types" KeyValue.
15. Replaced the "Tank Character" KeyValue with "Tank Enabled". (Now users can simply enable/disable each Tank without using a letter, number, or symbol.)
16. Added Tank death announcement messages.
17. Increased the maximum amount of possible Super Tank types from 250 to 1000.
18. Added a Super Tanks++ menu to the admin menu.

Files:

1. Updated include file.

## Version 8.17 (June 6, 2018)

Changes:

1. Added the "Hypno Mode" KeyValue to decide whether hypnotized survivors can only hurt themselves or other teammates.
2. The Hypno ability now uses OnTakeDamage instead of TraceAttack and supports multiple damage types.
3. The Hypno ability's effect only activates when hypnotized survivors hurts/kills the Super Tank that hypnotized them.
4. The Hypno ability no longer kills hypnotized survivors when they kill the Super Tank that hypnotized them.
5. The bullet (gunshot) damage done onto a Super Tank by its hypnotized victim will now have 1/10 of it inflicted upon the hypnotized victim.
6. The slash (melee) damage done onto a Super Tank by its hypnotized victim will now have 1/1000 of it inflicted upon the hypnotized victim. 
7. Added the "Bury Height" KeyValue to decide how deep survivors are buried.
8. Added a check for only burying survivors that are on the ground to avoid bugs.

Files:

1. Updated include file.

## Version 8.16 (July 5, 2018)

Bug fixes:

1. Fixed the Car Throw Ability, Infected Throw Ability, and Shield Ability's propane throw not working.
2. Fixed the "Enabled Game Modes" and "Disabled Game Modes" KeyValues not having enough space for more than 2-4 game modes.
3. Fixed the issue with default "unnamed" Tanks appearing when certain Super Tanks are disabled.
4. Fixed the Warp ability's interval glitching out.
5. Fixed the Gravity ability creating more than 1 point_push entity per Tank.

Changes:

1. Raised the character limit of the "Tank Types" KeyValue from 64 to 250.
2. Added the "Particle Effect" and "Particle Effects" KeyValues to let users decide which particle effects to attach to Super Tanks.
3. Removed the "Smoke Effect" KeyValue.
4. Modified the "Props Attached" KeyValue to support the oxygen tank flames. New format: "Props Attached" "12345"
5. Modified the "Props Chance" KeyValue to support the oxygen tank flames. New format: "Props Chance" "3,3,3,3,3"
6. Modified the "Props Colors" KeyValue to support the oxygen tank flames. New format: "Props Colors" "255,255,255,255|255,255,255,255|255,255,255,255|255,255,255,255|255,255,255,255"
7. Added the "Panic Claw-Rock" KeyValue which lets the Super Tank start panic events.
8. Added the "Panic Chance" KeyValue which decides how often the Super Tank can start panic events.
9. Added the "Bury Claw-Rock" KeyValue which lets the Super Tank bury survivors.
10. Added the "Bury Chance" KeyValue which decides how often the Super Tank can bury survivors.
11. Added the "Bury Duration" KeyValue which decides how long the Super Tank can bury survivors.
12. Replaced the following KeyValues with the "Infected Options" KeyValue for more infected throw variety.

```
"Boomer Throw"
"Charger Throw"
"Clone Throw"
"Hunter Throw"
"Jockey Throw"
"Smoker Throw"
"Spitter Throw"
```

Files:

1. Updated include file.

## Version 8.15 (June 30, 2018)

Bug fixes:

1. Fixed the shield color being overridden when the Super Tank has the Ghost Ability enabled.
2. Fixed custom configs not respecting the settings from the main config when KeyValues aren't found inside the custom configs.
3. Fixed the player_death event callback returning the victim's user ID for the attacker.

Changes:

1. Users can now choose different colors for each prop (Change "Skin-Prop-Glow Colors" to "Skin-Glow Colors" and add "Props Colors"). Format: "Skin-Glow Colors" "255,255,255,255|255,255,255", "Props Colors" "255,255,255,255|255,255,255,255|255,255,255,255|255,255,255,255"
2. Added the "Multiply Health" KeyValue to determine how the Super Tank's health should be handled (0: No changes to health, 1: Multiply original health only, 2: Multiply extra health only, 3: Multiply both). Format: "Multiply Health" "3"
3. Added the "Bomb Rock Break" KeyValue which makes the Super Tank's rocks explode. Format: "Bomb Rock Break" "1"
4. Added the "Car Throw Ability" KeyValue which lets the Super Tank throw cars. Format: "Car Throw Ability" "1"
5. Added the "Vampire Claw-Rock" KeyValue which lets the Super Tank steal health from survivors. Format: "Vampire Claw-Rock" "1"
6. Added the "Vampire Health" KeyValue to determine how much health the Super Tank receives from hitting survivors. Format: "Vampire Health" "100"
7. Added the "Vampire Chance" KeyValue to determine the chances of the Super Tank stealing health from survivors. Format: "Bomb Rock Break" "4"
8. The config file is now automatically created if it doesn't exist already.
9. Optimized code even more.

Files:

1. Moved various stock functions to the include file.

## Version 8.14 (June 28, 2018)

Changes:

1. The Flash ability now fades properly when the Super Tank has the Ghost Ability enabled.
2. Raised the spawn point of the rocks for the Spam ability again to avoid collision with the Super Tank.

## Version 8.13 (June 28, 2018)

Bug fixes:

1. Fixed the Ghost ability not letting Super Tanks fade out to full invisibility.

Changes:

1. Lowered the spawn point of the rocks for the Spam ability.
2. Added the "Ghost Fade Limit" KeyValue setting to adjust the intensity of the Ghost Fade ability (255: No effect, 0: Fully faded).
3. Added the "Glow Effect" KeyValue setting to determine whether or not Super Tanks will have a glow outline (0: OFF, 1: ON).

Files:

1. Updated include file.
2. Updated Boss and Meme Tank's settings in the config file.

## Version 8.12 (June 28, 2018)

Bug fixes:

1. Fixed all previously known/found bugs.

Changes:

1. Any and all Super Tank types are now FULLY customizable.
2. Added support for up to 250 Super Tank Types.
3. Converted all ConVars to KeyValues.
4. Removed unnecessary code.
5. Optimized code a bit more.

Files:

1. Updated gamedata file.
2. Updated include file.

## Version 8.11 (June 22, 2018)

Bug fixes:

1. Fixed the Witch Tank not spawning Witches. (Thanks ReCreator!)
2. Fixed the Shield Tank not propelling its propane tanks forward. (Thanks ReCreator!)

Changes:

1. Added the convar st_gamemodetypes to determine what game mode types to enable/disable the plugin in. (0: All, 1: coop modes only, 2: versus modes only, 4: survival modes only, 8: scavenge modes only.)
2. Removed the "@witches" target filter for not working properly.
3. Optimized code a bit more.

Files:

1. Updated include file.

## Version 8.10 (June 22, 2018)

Changes:

1. Any extra health given to a Super Tank is now multiplied by the number of alive non-idle human survivors present when the Tank spawns. (Thanks emsit!)
2. Added the target filters "@smokers", "@boomers", "@hunters", "@spitters", "@jockeys", "@chargers", "@witches" for developers/testers to use.
3. Added the sm_tank "type 1-36" command to spawn each Tank for developing/testing purposes.
4. Added oxygen tank (jetpack) props to Tanks.
5. Modified the attachprops convars to now support multiple number combinations.
6. Removed unnecessary code.
7. Optimized code a bit.

Files:

1. Updated include file.

## Version 8.9 (June 21, 2018)

Changes:

1. Added a randomizer for Tanks spawning with props to add more variety.
2. Added the target filter "@tanks" for developers/testers to use.

Files:

1. Updated include file.

## Version 8.8 (June 21, 2018)

Bug fixes:

1. Fixed the Shove and Smoker Tanks' attachprops convars not working properly.

Files:

1. Updated include file.

## Version 8.7 (June 21, 2018)

Bug fixes:

1. Fixed the Ghost Tank and Gravity Tank convars being switched.

Changes:

1. Added options for the st_displayhealth convar. (1: show names only, 2: show health only, 3: show both names and health.)
2. Added a convar for each Tank type to decide what props to attach to it. (1: attach lights only, 2: attach rocks only, 3: attach tires only, 4: attach all 3.)

Files:

1. Updated include file.

## Version 8.6 (June 21, 2018)

Bug fixes:

1. Fixed the proper amount of Tanks not spawning on the 2nd wave during finales.
2. Fixed the props attached to the Tanks not disappearing right away when they die.

Files:

1. Updated include file.

## Version 8.5 (June 20, 2018)

Bug fixes:

1. Fixed the Tank's effects not going away right after the Tank dies.

## Version 8.4 (June 20, 2018)

Bug fixes:

1. Fixed the infected thrower Tanks not throwing special infected directly from their rocks.

## Version 8.3 (June 20, 2018)

Bug fixes:

1. Fixed the Meteor Tank's meteor shower not working after a certain amount of time.

Changes:

1. Added a check to destroy all effects when a Tank dies.
2. Added a check for Bomber Tank's explosion to not damage any infected including the Bomber Tank.
3. Added a check for Fire Tank's fires to not damage any infected including the Fire Tank.
4. Added a check for Meteor Tank's meteor showers to not damage any infected including the Meteor Tank.
5. Converted some code to new syntax.
6. Removed unnecessary code.
7. Optimized some code.

Files:

1. Updated include file.

## Version 8.2 (June 19, 2018)

Bug fixes:

1. Fixed the Tank's rocks not doing anything when survivors are hit.

## Version 8.1 (June 19, 2018)

Bug fixes:

1. Fixed the Common Tank not spawning any common infected.
2. Fixed the Gravity Tank's gravity force not stopping upon death.
3. Fixed the Hypno Tank's effect instantly killing survivors (Now it sets survivors to 1 HP).
4. Fixed the Meteor Tank's meteor shower not working.
5. Fixed the special infected thrower Tanks not throwing any special infected.

## Version 8.0 (June 18, 2018)

1. Major code overhaul.
2. 36 (31 for L4D1) unique types.
3. Now requires a gamedata file.
4. Now requires an include file.

## Version 7.0 (November 24, 2017)

1. Disabled Ice Tank for L4D version.
2. Only 28/40 are available for the L4D version now.
3. Fixed Shield Tank and other Tank types with shields not having their shields shattered by explosions.

## Version 6.5 (November 24, 2017)

1. Fixed the SetConVarInt errors reported by KasperH here.

## Version 6.0 (November 24, 2017)

1. Added support for L4D.
2. L4D version only includes 29/40 Tank types.
3. L4D version excludes prop attachments (concrete chunk and beam spotlight).
4. L4D version excludes glow outlines.
5. Changed the l4d2_ prefix to l4d_ for the plugin and config files.

## Version 5.5 (October 23, 2017)

1. Applied another fix for the negative HP bug for Boss, Goliath, Psychotic, and Psykotik Tanks.

## Version 5.0 (October 22, 2017)

1. Applied a fix for a speed bug that was also in the original Super Tanks.

## Version 4.5 (October 21, 2017)

1. Fixed a bug that caused Boss, Goliath, Psychotic, and Psykotik Tanks to have negative HP.

## Version 4.0 (October 21, 2017)

1. Added 8 new combinations of Super Tanks.
- Boss Tank
- Meme Tank
- Mirage Tank
- Poltergeist Tank
- Psykotik Tank
- Sipow Tank
- Spykotik Tank
- Spypsy Tank
2. Fixed some bugs due to missing code.

## Version 3.0 (October 20, 2017)

1. Fixed the Flash and Reverse Flash special speed cvars not working.

## Version 2.0 (October 19, 2017)

1. Removed the screen color effect when getting hit by certain Super Tank types.
2. Redesigned and recolored Trap Tank.
3. Recolored Bitch Tank, Distraction Tank, and Minion Tank.

## Version 1.0 (October 18, 2017)

Initial Release.