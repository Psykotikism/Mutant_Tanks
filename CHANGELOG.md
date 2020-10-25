# Changelog

## Version 8.80 (December 31, 2020)

Bug fixes:

1. Fixed the core plugin creating log files even when `Log Messages` is disabled. (Thanks to KasperH/Ladis for reporting!)
2. Fixed clones created by the `Clone` ability being detected by the `Finale Amount` and `Finale Waves` settings.
3. Fixed some of the default Mutant Tanks that use the `Boss` and `Transformation` features turning into the wrong Mutant Tank types.
4. Fixed the `Blind` ability being enabled by default. (Thanks to Mi.Cura and Tank Rush for reporting!)
5. Fixed the `Drug` ability not requiring human survivors to be present by default.
6. Fixed the `Drunk` ability requiring human survivors to be present by default.
7. Fixed the `Drop Weapon Name` setting not reading non-melee weapon names properly.
8. Fixed the `Requires Humans` setting not working in some config formats.
9. Fixed the `Requires Humans` setting not working when the core plugin is deciding which Mutant Tank type to spawn.
10. Fixed some abilities calling `DispatchSpawn` on entities before teleporting them.
11. Fixed the core plugin skipping some waves. (Thanks to Tank Rush for testing and reporting!)
12. Fixed global chat messages not being translated. (Thanks to Mi.Cura for testing and reporting!)
13. Fixed settings not having their values stored properly.
14. Fixed color-related settings from not picking random colors when set to `-1`.
15. Fixed the core plugin's glow outline not going away when Tanks are kicked.
16. Fixed the `Health` ability's glow outline not going away when Tanks die.
17. Fixed the `Track` ability's glow outline not going away when rocks break.
18. Fixed the `Burier` ability sometimes leaving players under the map.
19. Fixed the `Yell` ability's phrases providing the wrong information. (Thanks to Mi.Cura for reporting!)
20. Fixed the `Clone` ability not being optional.
21. Fixed some phrases not being translated for other languages.
22. Fixed some of the `Hit` ability's settings not working in some config formats.
23. Fixed one of the `Shake` ability's messages using the wrong format specifier. (Thanks to Mi.Cura for reporting!)
24. Fixed Tanks not activating their passive abilities after exiting idle mode.
25. Fixed the `Light Color` setting not working.
26. Fixed the `Vampire` ability not checking admin immunity properly.
27. Fixed the `MT_GetPropColors` native not returning the right color for the light prop.
28. Fixed the Tank wave spawner not respecting the limits set by the `Regular Amount`, `Finale Amount`, and `Finale Waves` settings.
29. Fixed the `Omni` ability not tracking type changes properly. (Thanks to Mi.Cura for testing and reporting!)
30. Fixed the `MT_SetTankType` native not reverting changes properly in some scenarios. (Thanks to Mi.Cura for testing and reporting!)
31. Fixed some admin commands using the wrong access flags.
32. Fixed the `Rock` and `Spam` abilities' rocks colliding with each other.

Changes:

1. Added the `MT_IsTankClone` native to allow developers to check if a Tank is a clone.
2. The `mt_clone` include file is now used by all plugins related to Mutant Tanks.
3. The `Finale Waves` and `Finale Types` settings now support up to `10` waves. (Thanks to 3aljiyavslgazana for testing and reporting!)
4. Added a new option for the `Announce Death` setting.
5. Enabled the `Requires Humans` setting for some of the default Mutant Tank types.
6. Enabled the `Requires Humans` setting for some more abilities by default.
7. Added command aliases for `sm_tank` and `sm_tank2`.
8. Added the `Bury Buffer` setting for the `Bury` ability. (Requested by Mi.Cura.)
9. Changed the default value of the `Heal` ability's `Heal Buffer` setting from `25.0` to `100.0`.
10. Changed the default value of the `Regular Limit` setting from `2` to `999999`.
11. Changed the default value of the `Death Revert` setting under `Plugin Settings/General` from `0` to `1`.
12. Increased the delay between each Tank wave in finales from `3` to `5` seconds.
13. Added the `Attack Interval` setting under `Tank #/Enhancements` section. (Thanks to epz for the code!)
14. The regular waves spawner now has a delay and starts after a survivor has left the saferoom. (Requested by Tank Rush.)
15. Added the `Regular Delay` setting under `Plugin Settings/Waves` section. (Requested by Tank Rush.)
16. Config files now support multiple abilities using comma separation.
17. The `all` section can now be grouped with multiple types and abilities in config files.
18. The `Clone` ability's `Clone Type` setting and the `Respawn` ability's `Respawn Type` setting now both take in a type range. Example: `1-10` (Requested by Neptunia.)
19. The `Tank Name` setting can now be translated in the translation file by creating a `Tank # Name` section for each type or `STEAM_ID Name` section for each player. (Requested by Mi.Cura.)
20. Removed the `Rename Players` setting. (Too many bugs with special characters in people's names.)
21. Added the `Remove Extras` and `Extras Delay` settings under `Plugin Settings/Waves` section.
22. The arrival of Mutant Tanks is no longer announced when they are idle. Instead, the arrival is announced once the survivors trigger the Mutant Tank.
23. Added the `Fly` ability. (Thanks to Ernecio for the code!)
24. None of the abilities' plugins need to check if the `Clone` ability is installed anymore.
25. Added the `MT_IsCustomTankSupported` native to allow developers to check if a Tank clone is able to use abilities like real Mutant Tanks.
26. Applied a new idle fix method for the `Idle` ability. (Thanks to Lux for the code!)
27. Added the `Open Areas Only` setting to determine which types or abilities are only for open areas.
28. Added the `Flashlight` and `Crown` options for the `Props Attached` setting.
29. Added the `Flashlight Color` setting to determine the color of the Tank's dynamic flashlight prop. (Thanks to Ernecio for the code!)
30. Added the `Crown Color` setting to determine the color of the Tank's crown prop. (Thanks to Ernecio for the code!)
31. The `Props Chance` setting now accepts two extra values to support the `Flashlight` and `Crown` props.
32. The core plugin and its modules now requires `DHooks 2.2.0-detours15` or higher.
33. The `Rock` and `Spam` abilities spawn less rocks to reduce possible lag.

Files:

1. Updated config files.
2. Updated gamedata file.
3. Updated include files.
4. Updated translation file.

## Version 8.79 (October 10, 2020)

Bug fixes:

1. Fixed the core plugin creating the wrong folder for finale stage configs.
2. Fixed the `sm_mt_config` command causing errors when multiple players are using it.
3. Fixed the `Game Mode Types` setting and `mt_gamemodetypes` convar causing errors when set to anything higher than `0`. (Thanks to KasperH/Ladis for testing and reporting!)
4. Fixed the idle check for Tanks not detecting every type of idle mode.
5. Fixed some abilities' range attacks not working due to admin access.
6. Fixed client index errors for the `Zombie` ability.

Changes:

1. The `sm_mt_config` now allows users to choose from a list of config file paths.
2. Only one player may use the `sm_mt_config` command at a time to avoid spamming and overlapping parses.
3. Each config file that is executed by the core plugin can now be viewed by players.
4. Each config file path provided by the `sm_mt_config` command now generates its own list of section names available in its corresponding config file.
5. Added new options for the `Warp` ability's `Warp Mode` setting.
6. Added the `MT_OnResetTimers` forward to allow developers to reset repeating timers with intervals set by config files.
7. The timer for spawning Tanks periodically on non-finale maps now resets when `Regular Interval` is changed. (Thanks to Tank Rush for testing!)
8. Added the `Splatter` ability which is exclusive to Left 4 Dead 2. (Requested by Tank Rush and thanks to Silvers for the code.)
9. Added two new default Mutant Tanks in the config file to showcase the `Splatter` ability.
10. All the default Mutant Tanks that come with the main config file are now off by default. Users can enable them as needed.
11. DHooks and Left 4 DHooks are now mandatory.
12. The core plugin now constantly checks if Tanks are idle or not moving (no action). Use the `Idle Check` setting to determine the interval between each check.
13. Added the `Idle Check Mode` setting under `Plugin Settings/General` section.
14. Changed the default value of the `Idle Check` setting from `0.0` to `10.0`.
15. Changed the default value of the `Props Attached` setting from `126` to `78` for L4D1 to disable huge props.
16. Changed the default value of the `Detect Plugins` setting from `0` to `1`.
17. The `Regular Amount` setting now works without the `Regular Mode` setting being set to `1`.
18. The `Bury` ability's plugin (`mt_bury.smx`) now uses Left 4 DHooks to revive survivors.
19. The `Yell` ability's plugin (`mt_yell.smx`) now uses Left 4 DHooks to deafen survivors.
20. Updated the `MT_IsTankIdle` native with an extra parameter to determine what idle mode to check for.
21. Global chat messages and server messages generated by Mutant Tanks can now be logged.
22. Added the `Log Messages` setting to allow different types of messages to be logged.
23. Added the `MT_OnLogMessage` forward to allow developers to intercept the logging feature.
24. Added the `MT_LogMessage` native to allow developers to log messages.
25. Added the `Requires Humans` setting to filter out certain types and abilities from being used when there are zero human survivors present.
26. Added the `MT_DoesTypeRequireHumans` native to allow developers to check if a certain type requires human survivors to be present.
27. Config files now support multiple Mutant Tank types using comma separation.
28. Raised the limit from `16` to `32` for the following settings (Requested by Tank Rush.):
- `Regular Amount`
- `Finale Amount`
- `Finale Waves`
- `Type Limit`

Files:

1. Updated config file.
2. Updated gamedata file.
3. Updated include file.
4. Updated translation file.

## Version 8.78 (October 2, 2020)

Bug fixes:

1. Fixed the `Fast`, `Ghost`, and `Item` abilities' settings not being read when using one of the other config formats.
2. Fixed props not showing up on Tanks sometimes regardless of settings. (Thanks to Mi.Cura for reporting!)
3. Fixed the `Drop` ability not creating nor dropping any weapons.
4. Fixed difficulty configs not updating their file time changes when the `z_difficulty` setting is updated.
5. Fixed the maximum value of the `Finales Only` and `Finale Tank` settings. (Thanks to Tank Rush for testing!)
6. Fixed the main config overlapping the custom configs by adding a 3-second delay. (Thanks to Tank Rush for testing!)

Changes:

1. Added the `Drop Weapon Name` setting for the `Drop` ability. (Requested by Tank Rush.)
2. The `Drop` ability now supports the two new melee weapons from `The Last Stand` update.
3. Changed the minimum value of the `Drop` ability's `Drop Weapon Scale` from `1.0` to `0.1`.
4. Set a fixed default size (`1.5`) for weapons attached to Tanks by the `Drop` ability.
5. Added the `Idle Check` setting under `Plugin Settings/General` section.
6. Added the `MT_IsTankIdle` native which allows developers to check if a Tank is idle.
7. Idle Tanks will no longer activate their passive abilities.
8. Moved the following settings to the `Plugin Settings/Health` section:
- `Base Health`
- `Display Health`
- `Display Health Type`
- `Health Characters`
- `Minimum Humans`
- `Multiply Health`
9. Moved the following settings to the `Tank #/Health` and `STEAM_ID/Health` sections:
- `Display Health`
- `Display Health Type`
- `Extra Health`
- `Health Characters`
- `Minimum Humans`
- `Multiply Health`
10. Added `Finale stages` as an option for the `Create Config Types` and `Execute Config Types` settings.
11. The core plugin will no longer work if the main config file does not exist.
12. Custom config files are no longer executed if they do not exist.

Files:

1. Updated config file.
2. Updated gamedata file.
3. Updated include file.
4. Updated translation file.

## Version 8.77 (September 11, 2020)

Bug fixes:

1. Fixed some messages not converting chat color placeholders properly.
2. Fixed an invalid entity index error for the `Ammo` ability. (Thanks to ur5efj for reporting!)

Changes:

1. Added multi-lingual support for all messages provided by Mutant Tanks. (Requested by yuzumi.)
2. Added Simplified Chinese translations. (Thanks to yuzumi!)
3. Added the `MT_OnMenuItemDisplayed` forward to allow developers to translate menu items.
4. Added the `Minimum Humans` setting to determine how many human survivors must be present before `Multiply Health` can take effect. (Thanks to SilentBr for suggesting!)

Files:

1. Updated config files.
2. Updated include file.
3. Updated translation file.

## Version 8.76 (August 1, 2020)

Bug fixes:

1. Fixed client index errors for the `Track` ability. (Thanks to AK978 and Mi.Cura for reporting!)

Changes:

1. Added the `Finale Amount` setting to limit the number of Tanks during finales regardless of the current wave. (Requested by Neptunia.)

Files:

1. Updated config files.
2. Updated include file.
3. Updated translation file.

## Version 8.75 (July 5, 2020)

Bug fixes:

1. Fixed the `Drunk`, `Gravity`, and `Slow` abilities not resetting survivors speed/gravity to default (1.0). (Thanks to Mi.Cura for reporting!)
2. Fixed the `Regular Wave` setting taking effect even when `Regular Mode` is set to `0`. (Thanks to Mi.Cura for reporting!)

Changes:

1. Added a `StopSound` check for the Tank's rocks to get rid of the loud wind sound. (Thanks to Electr000999 for suggesting!)
2. More code optimization.

Files:

1. Updated include file.

## Version 8.74 (June 24, 2020)

Bug fixes:

1. Fixed the `Finale Types` setting being read incorrectly. (Thanks to Neptunia for reporting!)
2. Fixed non-finale Tanks spawning on finale waves. (Thanks to Neptunia for reporting!)
3. Fixed the finale waves not resetting on mission lost. (Thanks to Neptunia for reporting!)
4. Fixed errors regarding detours. (Thanks to Voevoda for reporting and to Silvers for helping me figure out the cause!)
5. Fixed the `Finale Waves` and `Regular Wave` settings having the wrong default values.
6. Fixed the `MT_IsNonFinaleType` native not being optional.
7. Fixed several upon-death abilities not working. (Thanks to ben12398 for reporting!)
8. Fixed the regular wave spawner not working when the `Regular Amount` setting is off. (Thanks to ben12398 for reporting!)
9. Fixed the `Cloud` ability spamming too many clouds. (Thanks to Mi.Cura for reporting!)
10. Fixed the `Omni` ability not inheriting other Mutant Tank types' abilities when `Omni Mode` is set to `0`. (Thanks to Mi.Cura for reporting!)

Changes:

1. DHooks is now optional. (Still required when compiling/using the plugin and its modules with Left 4 DHooks.)
2. Rewrote and improved the code for the finale waves and regular wave spawners.
3. All settings are now automatically re-cached after changing a Tank's type with the `MT_SetTankType` native.

Files:

1. Updated include file.

## Version 8.73 (June 11, 2020)

Bug fixes:

1. Fixed buttons being auto-released when human-controlled Tanks activate their abilities. (Thanks to Voevoda for reporting!)

Files:

1. Updated include file.

## Version 8.72 (June 10, 2020)

Bug fixes:

1. Fixed human players not turning into Mutant Tanks due to a cache fail. (Thanks to Voevoda for reporting!)

Files:

1. Updated include file.

## Version 8.71 (June 10, 2020)

Bug fixes:

1. Fixed the Tank's health status not showing up when using `Display Health` and `Display Health Type`. (Thanks to Mi.Cura for reporting!)
2. Fixed the plugin and its modules still not working when either the `Enabled Game Modes` or `Disabled Game Modes` setting is specified. (Thanks to Voevoda for reporting!)

Files:

1. Updated include file.

## Version 8.70 (June 10, 2020)

Bug fixes:

1. Fixed the `NoItems` phrase not displaying properly. (Thanks to ben12398 for reporting!)
2. Fixed some menus returning 0 items once finales have started. (Thanks to ben12398 for reporting!)
3. Fixed non-finale Mutant Tank types being disabled once finales have started even when `Finale Tank` is set to 0. (Thanks to ben12398 and Mi.Cura for reporting!)
4. Fixed the `Clone` ability preventing clones with different types from using their assigned/native abilities. (Thanks to ben12398 for reporting!)
5. Fixed the `Cloud` ability's clouds not disappearing after a short period of time. (Thanks to Mi.Cura for reporting!)

Changes:

1. The `Shield` ability's shield can now start out with health. (Requested by Neptunia.)
2. Added the following settings for the `Shield` Ability:
- `Shield Display Health`
- `Shield Display Health Type`
- `Shield Health`
- `Shield Health Characters`
3. Added more options to the `Finales Only` and `Finale Tank` settings.
4. Added an extra layer of security to the `Clone Type` and `Respawn Type` settings to make sure that users do not cause all kinds of bugs when choosing other types that also have the `Clone` or `Respawn` ability like their respective owners.

Files:

1. Updated config files.
2. Updated include file.
3. Updated translation file.

## Version 8.69 (June 5, 2020)

Bug fixes:

1. Fixed the Tank's healthbar not updating properly. (Thanks to Neptunia and Mi.Cura for reporting!)
2. Fixed AI Tanks not being renamed due to the `Rename Players` setting not exempting bots. (Thanks to Mi.Cura for reporting!)
3. Fixed the plugin and its modules not working when either the `Enabled Game Modes` or `Disabled Game Modes` setting is specified. (Thanks to Voevoda for reporting!)

Changes:

1. Removed the `Respawn Mode` setting and updated the `Respawn Type` setting for the `Respawn` ability.
2. Added the `Clone Type` setting for the `Clone` ability. (Requested by Neptunia.)
3. More code optimization.

Files:

1. Updated config files.
2. Updated gamedata file.
3. Updated include file.

## Version 8.68 (June 1, 2020)

Bug fixes:

1. Fixed more invalid handle errors. (Thanks to user2000 and MedicDTI for reporting!)
2. Fixed the `bIsHumanSurvivor` stock not automatically checking with the `MT_CHECK_FAKECLIENT` flag.
3. Fixed some settings not being read by the config parser when their values are empty.
4. Fixed disabled Tanks spawning no matter what. (Thanks to Mi.Cura for reporting!)
5. Fixed admin access and immunity errors. (Thanks to MedicDTI for reporting!)
6. Fixed the `Native not bound` error for the `Restart` ability. (Thanks to MedicDTI for reporting!)
7. Fixed the `Car Duration` setting not working.
8. Fixed some of the `Ghost` ability's settings not being read when using one of the other config formats.
9. Fixed the `Ghost` ability's cloak feature not affecting the propane tank prop attached to the Tank's head.
10. Fixed some of the `Heal` ability's settings not being read on some of the config formats.
11. Fixed the `Omni` ability not saving and retrieving the Tank's initial type properly.
12. Fixed the `Pyro` ability not igniting the Tank consistently.
13. Fixed the `Slow` ability not filtering its range ability.
14. Fixed some of the `Ultimate` ability's settings not having default values.
15. Fixed some abilities' post-spawn features being called too early.
16. Fixed some phrases having grammatical errors.

Changes:

1. All settings are now properly cached.
2. Added the `MT_OnSettingsCached` forward to allow developers to cache ability settings for each Tank.
3. All ability settings are now overridable for specific players.
4. The `MT_GetTankName` setting now only has two parameters.
5. Moved the `bIsCloneAllowed` stock to the core plugin's include file.
6. The `Clone` ability's `MT_IsCloneSupported` native now only has one parameter.
7. The `Clone` ability's library is now completely optional. (Still needed for compiling `mt_clone.sp` and using the `Clone` ability.)
8. Added the `Drop Hand Position` setting for the `Drop` ability.
9. Added the following settings for the `Fragile` ability:
- `Fragile Damage Boost`
- `Fragile Mode`
- `Fragile Speed Boost`
10. Added the following settings for the `Ghost` ability:
- `Ghost Specials`
- `Ghost Specials Chance`
- `Ghost Specials Range`
11. The `Omni` ability now prevents the Tank from transforming into other types that also have the ability enabled. (This prevents numerous bugs from ever happening.)
12. The `Pyro` ability now automatically activates when the Tank is taking fire damage.
13. Added the `Regular Limit` setting under the `Waves` section to limit how many waves of Tanks are spawned on non-finale maps. (Requested by RDiver.)
14. Added extra checks for several abilities to avoid client index errors.
15. Moved the `Human Support` setting to its own section:
- `Tank #/General` to `Tank #/Human Support`
- `STEAM_ID/General` to `STEAM_ID/Human Support`
16. Added the `Rename Players` setting under the following sections:
- `Plugin Settings/Human Support`
- `Tank #/Human Support`
- `STEAM_ID/Human Support`
17. Replaced all cooldown timers by tracking `GetTime` instead.
18. Replaced all `GetEngineTime` instances with `GetTime` for more accuracy.
19. `RequestFrame` is now used instead of 0.1-second timers.
20. The cooldowns for some abilities now start when the abilities end, not when they activate.
21. Added sound effects for the `Absorb`, `Blind`, `Bomb`, `Fire`, `God`, `Gravity`, `Hurt`, `Shake`, and `Slow` abilities. (Requested by Tank Rush.)
22. Added the `sm_mt_version` command which allows users to check the current version in-game.
23. Added backwards compatibility for old natives.
24. Updated/removed several phrases for each ability.
25. Moved all redundant code to the core plugin's include file for universal usage.
26. Changed how the administration system works. (Please read the `Administration System` section of the `README.md` file.)
27. Optimized the code of all the plugins included.
28. Added Hungarian translations. (Thanks to KasperH/Ladis!)

Files:

1. Updated config files.
2. Updated gamedata file.
3. Updated include files.
4. Updated translation file.

## Version 8.67 (May 10, 2020)

Bug fixes:

1. Fixed all abilities potentially not resetting when a Tank leaves the server.
2. Fixed invalid handle errors.
3. Fixed parsing failure errors.
4. Fixed several abilities not working for AI Tanks when `Human Ammo` is set to `0`.
5. Fixed more possible client index errors for the `MT_GetImmunityFlags` and `MT_GetAccessFlags` natives.
6. Fixed possible client index errors for the thirdperson detection.
7. Fixed invalid entity errors. (Thanks to BloodyBlade for reporting!)
8. Fixed all potential `Handle` leaks.

Changes:

1. Added extra checks to prevent disabled Tanks from spawning in certain situations.
2. Left 4 DHooks is now optional. (Thanks to Silvers!)
3. The `Hit Group` setting now allows for multiple hit groups to be specified using bit flags.
4. Added back the `sm_mt_config` command.
5. The core plugin now uses the `GetCmdArgInt()` function added in `SourceMod 1.11.0.6511`.
6. The `Human Support` setting now has an option to not inform human-controlled Tanks about the buttons used for activating their abilities manually. (Requested by zaviier.)
7. The `Human Ability` setting for several abilities now has an option to automate the ability for human-controlled Tanks. (Requested by zaviier.)
8. Removed redundant phrases from translation file.
9. The `Regular Amount` and `Finale Waves` settings can now be disabled with values of `0`.
10. Changed the default values for the `Regular Amount` and `Finale Waves` settings.
11. Improved thirdperson detection to know better when to display props.
12. The thirdperson detection timer is now faster.
13. Added the following settings for the `Acid`, `Bomb`, `Fire`, `Fling`, `Puke`, `Shake`, and `Shove` abilities:
- `* Death` - Whether the Mutant Tank will activate a range ability upon death.
- `* Death Chance` - The chance of the Mutant Tank activating a range ability upon death.
- `* Death Range` - The range of the Mutant Tank's range ability upon death. (Not available for `Bomb` and `Fire`.)
14. Optimized some of the code.

Files:

1. Updated config files.
2. Updated include file.
3. Updated translation file.

## Version 8.66 (May 1, 2020)

Bug fixes:

1. Fixed props and glow outlines sticking around after Tanks die. (Thanks to everyone that reported!)
2. Fixed some settings not using their assigned default values.
3. Fixed possible client index errors for the `MT_GetImmunityFlags` and `MT_GetAccessFlags` natives.
4. Fixed admin access and immunity flags not being determined properly.
5. Fixed the `Gravity`, `Drug`, and `Blind` abilities not resetting properly. (Thanks to Marttt for reporting!)
6. Fixed the missing textures from the `Electric` and `Laser` abilities' particle effects. (Thanks to Marttt for reporting!)
7. Fixed `bIsPluginEnabled` potentially causing errors before map start.
8. Fixed the `Shield` ability's shield not breaking when the attacker has higher admin access than the Tank.
9. Fixed the `Shield` ability's default `Shield Color` values not being set to `-1`.
10. Fixed players with personalized Tanks not being renamed.
11. Fixed `sm_mt_list` returning invalid handle errors.
12. Fixed some abilities not working due to their corresponding plugins not being detected.
13. Fixed the `MT_OnConfigsLoaded` forward not sending the value of the `mode` parameter.
14. Fixed abilities not resetting upon player death.

Changes:

1. Converted all plugins to use enum structs!
2. The `Tank Note` setting can now be overridden for specific players. A phrase must be created in the translation file for each specified player. The name of the phrase must be the player's SteamID32 or Steam3ID. See the bottom of the translation file for an example.
3. Added support for versus games in coop modes. (Requested by Neptunia.)
4. Added more `Display Health` options. (Requested by foxhound27.)
5. The `Finale Types` setting now takes in type ranges. Example: `1-10,11-20,21-30` (Requested by Neptunia.)
6. Added the `Rock Model` setting under the following sections (Requested by Mi.Cura.):
- `Tank #/Props`: Determines what model a Tank's rocks should look like.
- `STEAM_ID/Props`: Overrides the setting under `Props` for specific players.
7. Added more particle and sound effects for the `Electric ability`.
8. Common infected are now immune to Tank abilities. They should no longer die from running into fires or explosions caused by certain abilities.
9. The rocks from the `Rock` and `Spam` abilities are now colored based on the Tank's `Rock Color` setting. (Thanks to epz for the detour idea and gamedata info!)
10. The leftover rocks created by the `Meteor` ability now explode after 10 seconds regardless if they hit the ground.
11. The `Rock` and `Spam` abilities now create three times more rocks.
12. Lowered the position of the `Spam` ability's rock launcher so that it's more likely to hit survivors.
13. The chat notification for changing names is now hidden when a player with a personalized Tank is renamed.
14. Added the `MT_OnTypeChosen` forward which allows developers to either override the chosen type, prevent the chosen type from being chosen which will force the plugin to rechoose, or prevent a Tank from mutating.
15. Added the `MT_IsNonFinaleType` native which allows developers to check if a certain type is only available on non-finale maps.
16. Renamed the `MT_CanTankSpawn` native to `MT_CanTypeSpawn`.
17. Renamed the `MT_IsFinaleTank` native to `MT_IsFinaleType`.
18. The `MT_CanTypeSpawn` native now calls `MT_IsNonFinaleType` and `MT_IsFinaleType` internally.
19. The `Finale Tank` setting now accepts the value `2` which sets the type to only be available on non-finale maps.
20. Tanks can now spawn with a propane tank helmet. (Requested by Tank Rush.)
21. The core plugin now uses a dynamic method for detecting ability plugins.
22. The core plugin can now detect up to 100 abilities.
23. Added the `MT_OnPluginCheck` forward to allow developers to register the filenames of custom ability plugins for the core plugin to detect.
24. Added the `MT_OnAbilityCheck` forward to allow developers to register the possible section names of custom abilities to be checked before reading the config file.
25. Added the `Propane Tank Color` setting under the `Props` section.
26. The `MT_GetPropColors` native's `mode` parameter now accepts values as high as 6 to add support for the new propane tank prop.
27. The `Regular Type` setting now takes in a type range. Example: `1-10` (Requested by Neptunia.)
28. The core plugin now uses Left 4 DHooks to check when Tanks enter ghost state and materializes them 1 second later.
29. The `Restart` ability's plugin (`mt_restart.smx`) now uses Left 4 DHooks to check when a survivor is inside the starting safe area in order to get their "spawn coordinates" to be used when `Restart Mode` is set to `0`.
30. Added the `mt_enabledgamemodes`, `mt_disabledgamemodes`, and `mt_gamemodetypes` cvars as cvar equivalents of the `Enabled Game Modes`, `Disabled Game Modes`, and `Game Mode Types` settings.
31. The core plugin now requires DHooks and Left 4 DHooks.
32. Removed some useless code.

Files:

1. Updated config files.
2. Updated gamedata file.
3. Updated include file.
4. Updated translation file.

## Version 8.65 (April 20, 2020)

Bug fixes:

1. Fixed model error for pump shotgun in L4D1. (Thanks to Dragokas for reporting!)
2. Fixed the `MT_GetPropColors` native not checking for player-assigned colors.
3. Fixed Tanks having black skin and prop colors when controlled by a player without assigned colors.
4. Fixed various override settings not working when their values are not defined in the config file.
5. Fixed variables not resetting on players. (This resulted in many bugs.)
6. Fixed the `Yell` ability using the wrong phrases.
7. Fixed the `Yell` ability not working when `Human Mode` is set to `1`.
8. Fixed the `Yell Range` setting using the `Yell Duration` setting's default value.
9. Fixed admin settings not being assigned default values.

Changes:

1. Updated the L4D1 signatures for the `CTerrorPlayer_OnStaggered` function. (Thanks to Dragokas for reporting and providing the new signatures!)
2. Added more settings for glow option (Thanks to Marttt for the pull request!):
- `Glow Flashing`
- `Glow Range`
- `Glow Type`
3. Added sound hook to block wind sound. (Thanks to Dragokas for the code!)
4. Renamed the `MT_CHECK_KICKQUEUE` define to `MT_CHECK_INKICKQUEUE`.
5. Added the `Laser` ability. (Thanks to Ernecio for the code!)
6. Added `mt_pluginenabled` convar to enable/disable plugin via other plugins. (Requested by sxslmk.)
7. The `MT_OnConfigsLoad` and `MT_OnConfigsLoaded` forwards now each have one extra parameter to manage how much of the config file is read.

Files:

1. Updated config files.
2. Updated gamedata file.
3. Updated include file.
4. Updated translation file.

## Version 8.64 (August 23, 2019)

Bug fixes:

1. Fixed a timer error from the `Whirl` ability.
2. Fixed the `Clone` ability not replacing dead clones.
3. Fixed the issue with several abilities causing permanent gravity changes.
4. Fixed the issue with Tanks dying randomly.

Files:

1. Updated include file.

## Version 8.63 (June 25, 2019)

Bug fixes:

1. Fixed Tanks glowing when they are no longer biled.
2. Fixed the issue with other plugins not reading the Tank's health properly. (Thanks to Lux for pointing it out!)
3. Fixed several abilities not resetting survivors' speed, gravity, and other stats to previous values.

Changes:

1. Added a check for AFK Tanks. (May not be entirely accurate.)
2. Switched to the GlobalForward methodmap added in `SourceMod 1.10.0.6421`.

Files:

1. Updated the include file.

## Version 8.62 (May 15, 2019)

Bug fixes:

1. Fixed some sound effects not working due to non-existent files. (Thanks to Marttt for the pull request!)
2. Fixed the `Heal` ability returning errors on L4D1. (Thanks to Marttt for the pull request!)
3. Fixed the core plugin preventing other plugins from executing code on the `player_death` event.
4. Fixed the `Slow` ability targeting the Tank instead of the survivor victim. (Thanks to Marttt for the pull request!)

Changes:

1. Added a check to hook/unhook some events on L4D2 only. (Thanks to Marttt for the pull request!)
2. Removed the `sm_mt_config` command.
3. Added a stock function to stop sounds. (Thanks to Marttt for the pull request!)

Files:

1. Updated the include file.

## Version 8.61 (May 2, 2019)

Bug fixes:

1. Fixed the `Track` ability spamming errors.
2. Fixed the core plugin returning errors when `plugins` directory is not found. (Thanks to Marttt for pointing them out and making a pull request!)
3. Fixed the translation file using the wrong phrases for certain Mutant Tanks. (Thanks to Mi.Cura for reporting!)
4. Fixed some entities by using their references instead of indices. (Thanks to Lux for pointing them out and making a pull request!)
5. Fixed the custom config files resetting to the main one when admins join.
6. Fixed the config file not being read when using custom SM folder paths. (Thanks to Marttt for pointing them out and making a pull request!)
7. Fixed some errors reported by Mi.Cura.
8. Fixed Mutant Tanks with no abilities not showing up.

Changes:

1. The administration system now detects SM's admin flags if the plugin's config file doesn't define specific flags for a user.
2. The `MT_IsTypeEnabled()` native now checks if abilities for Mutant Tanks are available.
3. Added the `Regular Mode` setting under the `Plugin Settings/Waves` section.
4. The core plugin now detects custom sourcemod directories when checking for the `plugins` folder.
5. Mutant Tanks no longer have a glow outline when biled. (Thanks to Marttt for the pull request!)

Files:

1. Updated include file.
2. Updated translation file.

## Version 8.60 (March 21, 2019)

Changes:

1. Renamed the entire project to `Mutant Tanks`.

Files:

1. Renamed all files.

## Version 8.59 (March 20, 2019)

Changes:

1. The output of the `sm_st_config` command is now printed in chat instead of console to avoid overloading the buffer.
2. Added the `Omni`, `Xiphos`, and `Yell` abilities.
3. The `ST_GetTankName()` native now has a third argument.
4. Added the `Regular Type` and `Finale Types` settings under the `Plugin Settings/Waves` section.
5. Added the `Detect Plugins` setting under the `Plugin Settings/General` section.
6. Added the `Display Health Type` setting under the `Plugin Settings/General` section.
7. Added the `Health Characters` setting under the `Plugin Settings/General` section.
8. Added the `Access Flags` and `Immunity Flags` settings under the `Plugin Settings/Administration` section.
9. Added the `ST_FindAbility()`, `ST_HasAdminAccess()`, and `ST_IsAdminImmune()` natives.
10. All Color settings now accept values below `0` which will generate random colors.
11. The following settings can now be overridden for individual Super Tanks (View the `INFORMATION.md` file for details):
- `Access Flags`
- `Announce Arrival`
- `Announce Death`
- `Death Revert`
- `Detect Plugins`
- `Display Health`
- `Display Health Type`
- `Health Characters`
- `Immunity Flags`
- `Multiply Health`

12. Added `Access Flags` and `Immunity Flags` settings for each ability.
13. Updated documentation for several natives/forwards.
14. Added deprecated messages for old/deleted natives/forwards.
15. Added an administration system designed for the usage and effectiveness of each Super Tank type.
16. The administration system can now override any Super Tank type for each admin (View the `INFORMATION.md` file for details).
17. Added the `Allow Developer` setting under `Plugin Settings/Administration`.
18. Improved health display.
19. The `sm_tank` and `sm_supertank` commands now use separate callbacks.
20. Added the `sm_tank2` and `sm_st_list` commands.

Files:

1. Updated the `super_tanks++.cfg` file with the above changes.
2. Updated the `super_tanks++.inc` file with the above changes.
3. Updated the `super_tanks++.phrases.txt` file with new phrases.

## Version 8.58 (March 1, 2019)

Bug fixes:

1. Fixed several abilities not resetting properly when Super Tanks die.
2. Fixed the `Clone` ability spam-spawning Tank clones.
3. Fixed the `Respawn` ability not detecting finale Super Tanks.
4. Fixed all the plugins returning errors when the `Clone` ability is not installed.

Changes:

1. All `Ability Effect` and `Ability Message` settings now take in bit flags instead of strings.
2. Several settings now take in bit flags instead of strings.
3. All global variables are now initialized after the `AskPluginLoad2()` forward.
4. The `ST_IsTankSupported()` native's second argument now takes in bit flags instead of strings.
5. Renamed the `Flash` ability to `Fast` ability.
6. Renamed the `Stun` ability to `Slow` ability.
7. Renamed the `ST_OnPreset()` forward to `ST_OnPostTankSpawn()`.
8. Added the `sm_st_config` command.
9. Added a second argument to the `ST_OnChangeType()` forward.
10. Added the `ST_IsFinaleTank()` native.
11. Added the `Ultimate` ability. (Requested by foquaxticity.)
12. The Medic ability now allows Super Tanks to heal other Tanks. (Requested by FatalOE71.)
13. The `ST_OnConfigsLoaded()` forward now has different parameters.
14. Added the `ST_OnConfigsLoad()` forward.
15. All KeyValues sections and settings no longer need quotation marks around them (unless they contain whitespaces).
16. The config file now accepts different formats. (See examples in the `addons/sourcemod/data/super_tanks++/backup_config` folder.)
17. All color settings need commas again as delimiters. (Example: `255,255,255,255`)
18. Increased Super Tank type limit back to 1000.

Files:

1. Updated the `super_tanks++.cfg` file with new settings.
2. Updated the `super_tanks++.inc` file with the above changes.
3. Updated the `st_clone.inc` file with a new stock used by all plugins.
4. Updated the `super_tanks++.phrases.txt` file with new phrases.

## Version 8.57 (February 14, 2019)

Bug fixes:

1. Fixed props staying attached to players after switching teams.
2. Fixed some entities not resetting properly upon death.
3. Fixed the `Finales Only` setting not working. (Thanks to AK978 for reporting!)

Changes:

1. Minor code changes.
2. The core plugin now generates a `super_tanks++.cfg` file inside `cfg/sourcemod`. (Requested by axelnieves2012.)

Files:

1. Updated the `super_tanks++.inc` file.

## Version 8.56 (January 25, 2019)

Bug fixes:

1. Fixed several abilities creating multiple timers for each Super Tank.
2. Fixed the `Regen` ability not working when using negative values for some settings. (Thanks to Nokreb for reporting!)
3. Fixed the `Shield` ability's `Shield Type` setting not working. (Thanks to Nokreb for reporting!)
4. Fixed the `Undead` ability making Super Tanks immortal. (Thanks to fig101 for reporting!)

Changes:

1. Added a small option to go back to previous menus when using the admin menu to access the Super Tanks++ menu. (Requested by Marttt.)
2. Added a different death effect for the L4D1 versions of the `Acid` and `Fling` abilities.
3. The `Regen` ability's `Regen Limit` setting no longer accepts negative values.
4. The initial damage that removes a Super Tank's shield no longer hurts the Super Tank.

Files:

1. Updated the `super_tanks++.cfg` file.
2. Updated the `super_tanks++.inc` file.

## Version 8.55 (January 15, 2019)

Bug fixes:

1. Fixed the `Clone` and `Minion` abilities not working properly.
2. Fixed the `Flash` and `Pyro` abilities glitching out when the `Run Speed` setting is not specified. (It now defaults to `1.0`.)
3. Fixed the light prop appearing even when disabled.
4. Fixed the `Heal` ability breaking the glow outline feature.

Changes:

1. Added the `ST_IsGlowEnabled` native.
2. Added the `ST_GetRunSpeed` native.
3. Added the `Death Revert` setting under `Plugin Settings/General`. (Requested by Mi.Cura.)
4. Renamed all natives.

Files:

1. Updated the `super_tanks++.cfg` file.
2. Updated the `super_tanks++.inc` file.

## Version 8.54 (January 8, 2019)

Bug fixes:

1. Fixed the blur effect creating multiple timers.
2. Fixed the `Pyro` ability's `Pyro Damage Boost` setting not working properly.
3. Fixed the `Undead` ability not working properly.

Changes:

1. Changed some lines on the code for the `Warp` ability.
2. Added the `ST_HideEntity()` native which hooks/unhooks any entity to/from the core plugin's SetTransmit callback.
3. Added the `Fling Force` setting for the `Fling` ability.
4. Added death effects for several abilities.
5. Added the `sm_supertank` command for players to use in versus game modes.
6. Added the following settings under the `Plugin Settings/Human Support` section for extended human support.
- `Human Cooldown`: Determines how long human-controlled Tanks need to wait before using the Super Tanks++ menu to change their type.
- `Master Control`: Determines whether human-controlled Tanks need to have a cooldown when using the Super Tanks++ menu to change their type.
- `Spawn Mode`: Determines whether human-controlled Tanks spawn as Super Tanks or as default Tanks with access to the `sm_supertank` command.
7. Added the `st_admin` override command for admins who are exempted from the `Human Cooldown` setting.
8. Super Tanks that switch to the same type as their current one switch back to a default Tank until their type is changed again.
9. Human-controlled Super Tanks can now choose the `Default Tank` option in the Super Tanks menu to revert back to a default Tank. (A cooldown will still be applied.)
10. Super Tanks now revert to default Tanks when incapacitated (about to die).

Files:

1. Updated the `super_tanks++.cfg` file to reflect the above changes.
2. Updated the `super_tanks++.inc` file to reflect the above changes.
3. Updated the `super_tanks++.phrases.txt` file with new phrases.

## Version 8.53 (January 3, 2019)

Bug fixes:

1. Fixed the `Clone` and `Minion` abilities' `Replace` settings not working properly. (Thanks to Mi.Cura for reporting!)
2. Fixed the `Pyro` ability's `Pyro Damage Boost` setting not working properly.
3. Fixed the core plugin not detecting all the client buttons.
4. Fixed the blur effect colliding with the Super Tank it is attached to.
5. Fixed the plugins not detecting all Tank throw animation sequences.
6. Fixed the `Car` and `Meteor` abilities not resetting properly.

Changes:

1. Removed the feature where the Infected team cannot damage each other.
2. Added better thirdperson detection to properly display props attached to Super Tanks.

Files:

1. Updated the `super_tanks++.cfg` file.
2. Updated the `super_tanks++.inc` file.
3. Updated the `super_tanks++.phrases.txt` file with new phrases.

## Version 8.52 (January 1, 2019)

Bug fixes:

1. Fixed some chat messages being sent to AI Super Tanks.
2. Fixed the `Car` and `Meteor` abilities not working. (Thanks to Mi.Cura for reporting!)
3. Fixed the `Item` ability not disabling properly.

Changes:

1. Removed `Human Ammo` and `Human Cooldown` settings for the `Kamikaze` ability.
2. The `Base Health` setting is now a global setting under `Plugins Settings/General` section. (Requested by KasperH/Ladis.)
3. New ability added: `Hit` Ability - The Super Tank only takes damage in certain parts of its body.
4. New ability added: `Undead` ability - The Super Tank cannot die.
5. Renamed the `Human Duration` setting to `Car Duration` for the `Car` ability.
6. Renamed the `Human Duration` setting to `Meteor Duration` for the `Meteor` ability.
7. Renamed the `Pyro Boost` setting to `Pyro Speed Boost`.
8. Added the `Pyro Damage Boost` setting for the `Pyro` ability.

Files:

1. Updated the `super_tanks++.cfg` file with the new settings.
2. Updated the `super_tanks++.phrases.txt` file with various new phrases.

## Version 8.51 (December 26, 2018)

Bug fixes:

1. Fixed the `Clone`, `Minion`, and `Respawn` abilities not respecting the `Amount` settings.
2. Fixed the `Cloud` ability not respecting the `Human Mode` setting.
3. Fixed all abilities not resetting properly for human-controlled Super Tanks upon death.

## Version 8.50 (December 25, 2018)

Bug fixes:

1. Fixed the chat color tags not working properly.
2. Fixed several settings not working properly.

Changes:

1. Added the `Menu Enabled` setting to replace the `Spawn Enabled` setting.
2. The `Spawn Enabled` setting now determines if a Super Tank can spawn. (Correlates to the `Tank Chance` setting.)
3. The `Tank Enabled` setting is now an all-in-one setting for more flexibility.
4. The following settings can now be completely disabled with negative values and they are all set to `-1.0` by default:
- `Claw Damage` - If set to anything less than `0.0`, the Super Tank's claw damage will be untouched by the plugin.
- `Rock Damage` - If set to anything less than `0.0`, the Super Tank's rock damage will be untouched by the plugin.
- `Run Speed` - If set to anything less than `0.1`, the Super Tank's run speed will be untouched by the plugin.
- `Throw Interval` - If set to anything less than `0.1`, the Super Tank's rock throw interval will be untouched by the plugin.
5. New ability added: `Car` ability - The Super Tank creates car showers.
6. Added back human support, with manually controlled abilities.
- Added `Cooldown` and `Ammo` settings for most abilities.
- Added new forwards for many human support features.
7. Added `Rock Chance` settings for the `Acid`, `Bomb`, and `Fire` abilities.
8. Added various new settings for several abilities.
9. Removed/replaced several settings.
10. Reworked several abilities for balance and simplicity.

Files:

1. Updated the `super_tanks++.cfg` file with the new settings.
2. Updated the `super_tanks++.inc` file with new forwards, natives, and stocks.
3. Updated the `super_tanks++.phrases.txt` file with various new phrases.

## Version 8.49 (December 6, 2018)

Bug fixes:

1. Fixed the `sm_tank` command not spawning disabled Super Tanks.

Changes:

1. The `sm_tank` command can now spawn more than 1 Super Tank at a time. (New syntax: `sm_tank "type 1-500 OR name" "amount: 1-32" "0: spawn at crosshair|1: spawn automatically"`)

## Version 8.48 (November 30, 2018)

Bug fixes:

1. Fixed various timers not stopping when their corresponding settings are disabled.

## Version 8.47 (November 26, 2018)

Bug fixes:

1. Fixed the `Fling` and `Smite` abilities not working. (Thanks to Mi.Cura for reporting!)

Files:

1. Updated include file to fix documentation typos.

## Version 8.46 (November 22, 2018)

Bug fixes:

1. Fixed various abilities not resetting properly.

Changes:

1. Added new target filters: `@special`, `@infected`
2. The `Ability Effect` settings are now disabled by default.
3. All Chance settings now accept 0.0% as a valid value.
4. The `Skin-Glow Colors` and `Props Colors` settings have been divided into different settings.
5. The `Tank Chance`, `Type Limit`, and `Finale Tank` settings no longer affect respawned Tanks and randomized Tanks.
6. The `Announce Arrival` setting now accepts different values.
7. The `Throw` ability's `Ability Enabled` setting now accepts different values.
8. The `Throw` ability now allows for all 4 types to be enabled at once. (1 of the 4 will be chosen randomly each time a Super Tank throws a rock.)
9. Added the `Spawn Enabled` setting to determine if a Super Tank can be spawned through the `sm_tank` command. (Affects `Clone` and `Respawn` abilities.)
10. Added the `ST_PropsColors()` native to retrieve the RGBA colors of a Super Tank's props.
11. The `ST_TankColors()` native now retrieves the alpha of a Super Tank's colors.
12. Added the `ST_SpawnEnabled()` native to check if a Super Tank can be spawned through the `sm_tank` command.
13. Added the `Random Tank` setting to determine if a Super Tank can be used by other Super Tanks who spawn with the Randomization mode feature.
14. Added chat color tags for translation phrases.
15. Added the `ST_PrintToChat()` and `ST_PrintToChatAll()` stocks.
16. The `Super Tanks++` menu now transforms an existing Tank into the specified type when the command user is facing that Tank.
17. Renamed the `ST_BossStage()` and `ST_Event()` forwards to `ST_ChangeType()` and `ST_EventHandler()` respectively.
18. Removed the `Electric Speed` setting.

Files:

1. Updated config file.
2. Updated include file.
3. Updated translation file.

## Version 8.45 (October 31, 2018)

Bug fixes:

1. Fixed the `Clone` and `Minion` abilities not resetting properly.
2. Fixed the `Witch` ability spamming chat.
3. Fixed the `Ability Message` settings not working properly.

Changes:

1. The `sm_tank` command now accepts partial name matches as input values. (Example: `sm_tank boss`)
2. Moved some stock functions from include file to some of the module plugins.
3. Lowered the `Tank Name` setting's character limit from 128 to 32.
4. The `Medic` ability now lets Super Tanks heal nearby special infected by 1 HP every second.
5. The `Whirl` ability's `Whirl Axis` setting now accepts different values.
6. The `Throw` ability now has a 4th option - Super Tanks can throw Witches.
7. Several abilities' `Ability Message` setting now accepts different values.
8. Added the `Clone Replace` setting.
9. Added the `Cloud Chance` setting.
10. Added the `Jump Mode` setting.
11. Added the `Jump Sporadic Chance` setting.
12. Added the `Jump Sporadic Height` setting.
13. Added the `Meteor Mode` setting.
14. Added the `Minion Replace` setting.
15. Added the `Regen Chance` setting.
16. Added the `Shield Chance` setting.
17. Added the `Throw Chance` setting.
18. Added the `Witch Chance` setting.
19. Removed some redundant code from multiple module plugins.

Files:

1. Updated config file.
2. Updated include file.
3. Updated translation file.

## Version 8.44 (October 16, 2018)

Bug fixes:

1. Fixed the `Absorb`, `Fragile`, and `Hypno` abilities not working properly.
2. Fixed the datapack leaks from various modules.
3. Fixed the `Range Chance` settings not working at all.
4. Fixed the issue with props and special effects not deleting themselves properly, thus causing crashes.
5. Fixed the `Throw` ability's cars having a strong velocity, thus pushing other entities away.

Changes:

1. Improved readability of the source code for each plugin.
2. Added the `Aimless`, `Choke`, `Cloud`, `Drunk`, and Whirl abilities.
3. Added new settings for several abilities to handle timer intervals and damage values.
4. The `Electric`, `Hurt`, and `Splash` abilities now use `SDKHooks_TakeDamage()` to damage players.
5. The damage settings of the `Electric`, `Hurt`, and `Splash` abilities now accept float values (decimals) instead of int values (whole numbers).
6. Renamed a bunch of settings.
7. Decreased Super Tank type limit back to 500 to avoid server freezes and lag spikes.
8. Removed the `st_enableplugin` cvar setting.
9. `Chance` and `Range Chance` settings now only accept decimal (float) values.
10. `Chance` and `Range Chance` settings now work differently. (Before: 1/X chances, After: X/100.0 probability)
11. Added the `Base Health` setting to determine the base health of each Super Tank.
12. Added the `Tank Chance` setting to determine the chances of a Super Tank type spawning.
13. Added the `ST_TankChance()` native for the new `Tank Chance` setting.
14. The core plugin and its modules now require `SM 1.10.0.6352` or higher.
15. The core plugin now properly updates all settings when the config file is refreshed.
16. Removed the `sm_tanklist` command.

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

1. Marked the `ST_TankName` and `ST_TankWave` natives as optional to avoid potential issues.
2. Fixed the `Flash` ability errors. (Thanks Mi.Cura for reporting!)
3. Fixed the `Rocket` ability creating multiple timers for survivors who are getting sent into space.
4. Fixed several abilities not resetting when a Super Tank dies.

Changes:

1. Renamed/removed some stocks.
2. The core plugin and its modules now requires `SM 1.10.0.6317` or higher.
3. The Tank Notes now display a different message when the phrase for a Super Tank is not found.
4. Changed the directory of the configs from `cfg/sourcemod` to `addons/sourcemod/data`.
5. Added a new native: `ST_TankColors` - Retrieves a Super Tank's colors.
6. The `Gravity` ability's `Gravity Value` now accepts higher values.
7. The `Health` ability no longer allows a Super Tank to set survivors to black and white.
8. The `Jump` ability now provides more features.
9. The `Pyro` ability now provides more features.
10. The `Restart` ability now removes all weapons from survivors before giving them new loadouts.
11. Lowered the amount of boss stages from 5 to 4. Any boss that spawns automatically starts at stage 1.
12. Moved various settings under new sections and reorganized/restructured the config file.
13. Merged the `Cancer` ability with the `Health` ability.
14. Added 2 new abilities: `Lag` and `Recoil`
15. Added the `ST_PluginEnd()` and `ST_Preset()` forwards.
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
2. Fixed the issue with the `Shield` ability not keeping the shield disabled when it's deactivated. (Thanks Mi.Cura for reporting!)

Changes:

1. Removed the `[ST++]` prefix from the Super Tank health display.
2. Added a message for each ability. (Each message can be configured in the translation file.)
3. Added an `Ability Message` setting to toggle the messages for each ability.
4. Added a range feature for some abilities.
5. Added a new native: `ST_TankName(int client, char[] buffer)` - Returns a Tank's custom name.
6. Removed the `ST_Spawn(int client)` forward. (Use `ST_Ability(int client)` instead for more flexibility.)
7. Added the `Flash Interval` setting for the `Flash` ability.
8. The `Tank Note` setting now only accepts 0 and 1 as values.
9. Tank Notes must now be created inside the translation file.

Files:

1. Updated config file with the new settings and modified some presets.
2. Updated include file to remove the `ST_Spawn(int client)` forward and add the new `ST_TankName(int client, char[] buffer)` native.
3. Updated translation file with the new messages and Tank Notes.

## Version 8.40 (September 11, 2018)

Bug fixes:

1. Fixed the datapack error with the `Ghost` ability.

Changes:

1. Changed all `OnClientPostAdminCheck()` forwards to `OnClientPutInServer()` instead.
2. Moved late loading code from `OnMapStart()` to `OnPluginStart()`.

## Version 8.39 (September 10, 2018)

Bug fixes:

1. Fixed some abilities not working when their `Ability Enabled` setting is disabled. (Thanks huwong!)
2. Fixed the `Gravity` ability returning a datapack error.
3. Fixed the `Bomb` and `Fire` abilities not working in L4D1.
4. Fixed the `Ice` ability flinging survivors back at a high velocity after being unfrozen.
5. Fixed the `Zombie` ability not working properly.

Changes:

1. Added a new ability: `Kamikaze` ability - The Super Tank dies while taking a survivor with it.
2. Added a new ability: `Leech` ability - The Super Tank leeches health off of survivors.
3. Added a new ability: `Necro` ability - The Super Tank can resurrect nearby special infected that die.
4. Added a new ability: `Quiet` ability - The Super Tank can silence itself around survivors. (Useful for ninja-themed Super Tanks.)
5. Added a new native: `ST_TankWave()` - Returns the current finale wave.
6. Added a new native: `ST_CloneAllowed(int client, bool clone)` - Checks if a Super Tank's clone is allowed to use abilities like real Super Tanks.
7. Added the `Clone Mode` setting to determine if a Super Tank's clone can use abilities like real Super Tanks.
8. Added the `Finale Tank` setting to determine if a Super Tank only spawns during finales.
9. Added the `Tank Note` setting which is displayed in chat after a Super Tank spawns. (Character limit: 244)
10. Added a `X Hit Mode` (X = Name of ability) setting for various abilities.
11. Added the `Jump Range` setting to determine how close a Super Tank must be to a survivor before it can jump in the air.
12. Added the `Pyro Mode` setting to determine what kind of speed boost a Super Tank receives.
13. Added the `Zombie Interval` setting to determine how often a Super Tank can spawn zombie mobs.
14. The `Ghost` ability's `Ability Enabled` setting now has more options.
15. The `Ghost` ability no longer allows a Super Tank to cloak nearby special infected.
16. Removed the `Ghost` ability's `Ghost Cloak Range` setting.
17. The `Panic` ability now allows the Tank to have a chance to start a panic event upon death.
18. The `Warp` ability's electricity particle effect now requires the `Particle Effect` and `Particle Effects` settings to allow it.
19. The code for various abilities have been slightly modified.
20. Updated the Super Tanks++ category in the admin menu.
21. Removed old code that was used for human support.
22. Made some code optimizations.

Files:

1. Added a translation file for the plugin. (Filename is `super_tanks++.phrases.txt`)
2. New file: `st_clone.inc` (Used for the `Clone` ability's library.)
3. Updated config file with all the new settings.
4. Updated include file to add/remove code.

## Version 8.38 (September 6, 2018)

Bug fixes:

1. Fixed some modules not working properly for custom configs.
2. Fixed custom configs not working.
3. Fixed Tanks having the `unnamed` name when Boss mode is enabled. (Thanks Zytheus!)
4. Fixed the `Splash` ability creating multiple timers.

Changes:

1. Increased the maximum amount of possible Super Tank types from 2500 to 5000.
2. Replaced the `Maximum Types` setting with the new `Type Range` setting. (Usage: `Type Range` `1-5000`)
3. Changed the display info for each Super Tank type on the ST++ menu. (Before: `Tank's Name`, After: `Tank's Name (Tank #)`)
4. The core plugin no longer generates a config file nor a backup copy of it. (This feature was just wasting space and was overall unnecessary.)
5. Removed the `Create Backup` setting.
6. Removed support for human-controlled Tanks. (This feature was buggy and made the Infected team overpowered.)
7. Removed the `Human Super Tanks` setting.

Files:

1. Updated include file to add new natives, remove some stocks, and remove support for auto-config generation.
2. Smaller file sizes.

## Version 8.37 (August 30, 2018)

Changes:

1. Added support for dynamic loading to the modules. (Thanks Lux!)
2. Switched `RemoveEntity(entity)` back to `AcceptEntityInput(entity, "Kill")` just to be courteous to those who prefer to still use SM 1.8.
3. Removed `IsDedicatedServer()` just to be courteous to those who do not have dedicated servers. (Please do not report bugs if you're playing on a local/listen server. :/)

## Version 8.36 (August 20, 2018)

Bug fixes:

1. Fixed issues with the Tank when the `Finales Only` setting is set to 1.

Changes:

1. Optimized code a bit for the plugin and all of its modules.

## Version 8.35 (August 16, 2018)

Bug fixes:

1. `Rock` ability - Fixed the `Rock Radius` KeyValue setting not being read properly due to a small buffer size.
2. `Drop` ability - Fixed incorrect scaling on some of the melee weapons.

Changes:

1. `Warp` ability - The Super Tank will no longer warp to incapacitated survivors.
2. `Restart` ability - Survivors will no longer warp to incapacitated teammates.
3. New ability added: `Cancer` ability - The Super Tank gives survivors cancer (survivors die when they reach 0 HP instead of getting incapacitated first).
4. Added the command `sm_tanklist` which prints a list of Super Tanks and their current statuses on the user's console.
5. Added the following new settings for the `Absorb` and `Fragile` abilities:

- `Absorb Bullet Damage`
- `Absorb Explosive Damage`
- `Absorb Fire Damage`
- `Absorb Melee Damage`
- `Fragile Bullet Damage`
- `Fragile Explosive Damage`
- `Fragile Fire Damage`
- `Fragile Melee Damage`

6. The core plugin and all of its modules no longer work on locally-hosted/listen servers. (I'm tired of people reporting issues from their listen servers...)
7. The core plugin and all of its modules now require `SM 1.9.0.6225` or higher to work.
8. Removed unnecessary code.

Files:

1. Updated gamedata file with a new signature for `CTerrorPlayer_OnStaggered` for Windows to make the `Shove` ability compatible with Left 4 Downtown 2. (Thanks Spirit_12!)

## Version 8.34 (August 12, 2018)

Bug fixes:

1. Fixed the `Drop` ability not properly deleting weapon entities attached to the Super Tank when he dies.

Changes:

1. Moved some lines of code around, optimized some code, etc.
2. The `Puke` ability now gives the Super Tank a chance to puke on survivors when being hit with a melee weapon.
3. The following settings can now be set for each Tank instead of affecting all Tanks at once:

- `Boss Health Stages`
- `Boss Stages`
- `Random Interval`
- `Spawn Mode`

Files:

1. The auto-generated config file has less presets (smaller file size).

## Version 8.33 (August 10, 2018)

Bug fixes:

1. Fixed the `Witch` ability causing crashes when converting common infected into Witch minions.

Changes:

1. Added a boss mode feature, which is a feature taken from the original Last Boss. View the `INFORMATION.md` file for more details. (2 new settings: `Boss Health Stages` and `Boss Stages`)
2. Added a random mode feature, which is a feature that randomizes Super Tanks every X seconds after spawning. View the `INFORMATION.md` file for more details. (1 new setting: `Random Interval`)
3. Added a new forward to use for the boss and random modes:

`forward void ST_BossStage(int client);` (This forward is called when the Super Tank is evolving into the next stage.)

4. Added the `Spawn Mode` KeyValue setting to allow users to decide if Super Tanks either spawn normally, spawn as bosses (boss mode), or spawn as randomized Tanks (random mode).
5. The `Splash` ability now damages nearby survivors every X seconds while the Super Tank is alive.
6. Added the `Splash Interval` KeyValue setting to support the new Splash ability feature.
7. The `Vampire` ability's `Vampire Health` KeyValue setting now only applies to the `range` ability. (When the Super Tank hits a survivor, he now gains the amount of damage as health.)
8. The `Witch` ability's range used for detecting nearby common infected can now be configurable via the new `Witch Range` KeyValue setting.
9. Changed a few lines of code.

Files:

1. Updated include file with the new settings.
2. Updated config file with the new settings.
3. Updated `INFORMATION.md` file with information about the new settings.

## Version 8.32 (August 6, 2018)

Bug fixes:

1. Fixed the `Enabled Game Modes` and `Disabled Game Modes` settings not allowing more than 64 characters.

Changes:

1. Lowered the character limit of the `Enabled Game Modes` and `Disabled Game Modes` settings from 2048 to 512.
2. Rocks thrown by Tanks now have the same color as the rocks attached to their bodies.
3. Removed the `information` folder in favor of the `INFORMATION.md` file that comes with the plugin's package.

Files:

1. Updated include file (`super_tanks++.inc`).
2. Updated core plugin (`super_tanks++.sp`).
3. Updated all plugins to stop creating information files.
4. Updated config file.

## Version 8.31 (August 4, 2018)

Bug fixes:

1. Fixed errors reported by Mi.Cura regarding the `Rock` ability.
2. Fixed potential bugs and errors from various abilities.

Changes:

1. Added a 3rd parameter for the `sm_tank` command. (Usage: `sm_tank <1-2500> <0: spawn at crosshair, 1: spawn automatically>`)
2. Added the `Drop Mode` KeyValue setting to determine what kind of weapons the Super Tank can drop. `(0: Both|1: Guns only|2: Melee weapons only)`
3. Changed how the `Pyro` ability detects Tanks that are on fire.
4. Major code optimization. (Thanks Lux!)

Files:

1. Updated include file.
2. Updated config file.

## Version 8.30 (August 2, 2018)

Changes:

1. Added the `Regen Limit` KeyValue setting for the Regen Ability. More information in the `information` folder and `README` file on GitHub.
2. Added the `Restart Mode` KeyValue setting for the `Restart` ability. More information in the `information` folder and `README` file on GitHub.
3. Added the `st_enableplugin` cvar so users can disable the plugin via console. (The ConVar-based config file is located in `cfg/sourcemod/` while the KeyValues-based config file is still located in `cfg/sourcemod/super_tanks++`.)

Files:

1. Updated include file with the new settings.
2. Updated config file with the new settings.
3. Added the `information` folder in the same location as the config file which contains information about each ability and setting.

## Version 8.29 (July 31, 2018)

Bug fixes:

1. Fixed potential idle bug.

Changes:

1. Added the `Claw Damage` KeyValue setting under the `Enhancements` section which determines how much damage a Tank's claw attack does.
2. Added the `Rock Damage` KeyValue setting under the `Enhancements` section which determines how much damage a Tank's rock throw does.
2. Moved all stock/common functions to the include file.
3. Replaced multiple forwards with one forward to handle events hooked by the core plugin.
4. Removed an extra check for spawning Super Tanks from the `sm_tank` menu.
5. Removed unused code.

Files:

1. Updated gamedata file with new signatures for the `Idle` ability.
2. Updated include file to store more stock/common functions and to remove unused KeyValue settings from the auto-config generator.
3. Updated config file to remove unused KeyValue settings from the config file.

## Version 8.28 (July 28, 2018)

Bug fixes:

1. Fixed the `Panic` ability not working in L4D1.

Changes:

1. Changed how the `Bomb` ability creates explosions to prevent crashes.
2. Removed the `Bomb Power` setting.
3. Optimized code a bit.

Files:

1. Updated include file to remove the `Bomb Power` setting from the auto-config generator.
2. Updated config file to remove the `Bomb Power` setting.

## Version 8.27 (July 28, 2018)

Changes:

1. Added extra checks to make sure the plugin spawns the proper amount of Tanks for each wave.
2. Lessened the occurrence of Tanks flashing all over the map on finales. (Set `Glow Effect` to 1 to completely disable the glow outlines.)

Files:

1. `super_tanks++.sp` (Where the extra checks were added.)
2. `super_tanks++.inc` (Updated version number.)

## Version 8.26 (July 28, 2018)

Bug fixes:

1. Fixed some abilities and features staying on even when the `Human Super Tanks` KeyValue setting is set to 0.
2. Fixed some abilities and features staying on even when they're disabled for a specific Tank.
3. Fixed `OnTakeDamage` errors reported by FatalOE71.
4. Fixed the issue with so many Tanks spawning towards the end of finales.
5. Fixed various abilities not working properly.
6. Fixed the issue with Tanks that have the `Fragile` ability not dying properly.

Changes:

1. Added a new native for developers to use: `native bool ST_TankAllowed(int client)` - Returns the status of the `Human Super Tanks` setting.
2. Added a new native for developers to use: native int `ST_MaxTypes()` - Returns the value of the `Maximum Types` setting.
3. Added a new forward for developers to use: forward void `ST_Death2(int enemy, int client)` - Called when a Tank dies and returns the attacker's index.
4. Added checks to various timers in case abilities are disabled before the timers are triggered.
5. Added a check to prevent clone Tanks from being counted as actual Tanks.
6. The `Clone` ability no longer spawns more clones when all of the current clones die. (This is to prevent glitches with the Tank spawner.)

Files:

1. Updated include file with the new natives and forward.

## Version 8.25 (July 26, 2018)

Bug fixes:

1. Fixed the Tank limit for each wave not working properly. (Thanks Mi.Cura!)

Changes:

1. Added `Range Chance` settings and other settings for various abilities for better control.

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

1. Users can now change settings inside the config file mid-game without having to reload the plugin or restart the server. (Basically the counterpart of `ConVar.AddChangeHook` for cvars.)

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
5. The core plugin now creates a folder inside `cfg/sourcemod/super_tanks++` called `backup_config` which contains a copy of the config file in case users need it.
6. Added checks to trim all string-related settings to get rid of any white spaces.
7. Raised the value limits of various settings.

Files:

1. Updated config file with the new settings and new presets.
2. Updated include file.

## Version 8.21 (July 14, 2018)

Bug fixes:

1. Fixed the error coming from `OnTakeDamage`.
2. Fixed the error regarding a missing translation phrase when a vote is in progress.

Changes:

1. Added the `Regenerate Ability` KeyValue which lets the Super Tank regenerate health.
2. Added the `Regenerate Health` Keyvalue which determines how much health the Super Tank regenerates.
3. Added the `Regenerate Interval` KeyValue which decides how often the Super Tank regenerates health.
4. Added the `Rock Ability` KeyValue which lets the Super Tank start rock showers.
5. Added the `Rock Chance` KeyValue which decides how often the Super Tank can start rock showers.
6. Added the `Rock Damage` KeyValue which determines how much damage the Super Tank's rocks do.
7. Added the `Rock Duration` KeyValue which determines how long the Super Tank's rock shower lasts.
8. Added the `Rock Radius` KeyValue which determines the radius of the Super Tank's rock shower.
9. Added the `Meteor Radius` KeyValue which determines the radius of the Super Tank's meteor shower.
10. Added the `Rock Effect` KeyValue which lets users attach particle effects to the Super Tank's rocks.
11. Added the `Rock Effects` KeyValue which decides what particle effects are attached to the Super Tank's rocks.
12. Replaced the `Spam Amount` KeyValue with `Spam Chance` which decides how often the Super Tank can spam rocks at survivors.
13. Replaced the `Spam Interval` KeyValue with `Spam Duration` which determines how long the Super Tank's rock spam lasts.
14. Added the `Flash Duration` KeyValue which determines how long the Super Tank's special speed lasts.
15. The blur effect from the `Flash` ability is now treated as a prop.

New formats:

`Props Attached` `123456`
`Props Chance` `3,3,3,3,3,3`

Files:

1. Updated config file with new presets.
2. Updated include file.

## Version 8.20 (July 12, 2018)

Changes:

1. Renamed the `Common Ability` and `Common Amount` KeyValues to `Zombie Ability` and `Zombie Amount`.
2. The `Acid Claw-Rock` and `Fling Claw-Rock` abilities are now replaced with the `Puke Claw-Rock` ability on L4D1, even if the Super Tank does not have the `Puke Claw-Rock` ability enabled for it.
3. Added the `Pimp Claw-Rock` KeyValue which lets the Super Tank pimp slap survivors.
4. Added the `Pimp Amount` KeyValue which determines how many times the Super Tank can pimp slap survivors in a row.
5. Added the `Pimp Chance` KeyValue which determines how often the Super Tank pimp slaps survivors.
6. Added the `Pimp Damage` KeyValue which determines the damage of the Super Tank's pimp slaps.
7. Added the `Minion Ability` KeyValue which lets the Super Tank spawn special infected behind itself.
8. Added the `Minion Amount` KeyValue which determines how many minions the Super Tank can spawn.
9. Added the `Minion Chance` KeyValue which determines how often the Super Tank spawns special infected behind itself.
10. Added the `Minion Types` KeyValue which decides what special infected the Super Tank can spawn behind itself.
11. Added the `God Ability` KeyValue which lets the Super Tank have temporary god mode.
12. Added the `God Chance` KeyValue which determines how often the Super Tank gets temporary god mode.
13. Added the `God Duration` KeyValue which decides how long the Super Tank's temporary god mode lasts.
14. Added the `Clone Ability` KeyValue which lets the Super Tank spawn clones of itself.
15. Added the `Clone Amount` KeyValue which determines how many clones the Super Tank can spawn.
16. Added the `Clone Chance` KeyValue which determines how often the Super Tank can spawn clones of itself.
17. Added the `Clone Health` KeyValue which decides how much health each clone of the Super Tank gets.
18. Used a better method for preventing Tanks from getting stuck in the dying animation.

Files:

1. Updated include file.

## Version 8.19 (July 10, 2018)

Bug fixes:

1. Fixed the `Enabled Game Modes` and `Disabled Game Modes` KeyValues not working properly.
2. Fixed the particle effects for Super Tanks not appearing. (Thanks Mi.Cura!)
3. Fixed the wrong Super Tanks spawning when they are spawned through the Super Tanks++ Menu. (Thanks Mi.Cura!)

Changes:

1. Raised the character limit of the `Enabled Game Modes` and `Disabled Game Modes` KeyValues from 32 to 64.
2. Added the `Game Mode Types` KeyValue to enable/disable the plugin in certain game mode types. (1: Co-Op, 2: Versus, 4: Survival, 8: Scavenge)
3. Changed the permissions for the config file directories.

Files:

1. Updated include file.

## Version 8.18 (July 8, 2018)

Bug fixes:

1. Fixed the `Spam` ability creating multiple timers.
2. Fixed the Super Tanks not taking any type of explosive damage.
3. Fixed the `Shield` ability preventing Super Tanks with less than 100 HP from dying.
4. Fixed the `Bomb` ability's particle effects not appearing.

Changes:

1. Added the `Explosive Immunity` KeyValue which gives the Super Tank immunity to blast damage.
2. Added the `Bullet Immunity` KeyValue which gives the Super Tank immunity to bullet damage.
3. Added the `Melee Immunity` KeyValue which gives the Super Tank immunity to melee damage.
4. Added the `Absorb Ability` KeyValue which lets the Super Tank absorb most of the damage it receives, so they take less damage.
5. Added the `Pyro Ability` KeyValue which lets the Super Tank gain a speed boost when on fire.
6. Added the `Pyro Boost` KeyValue which lets users decide how much speed boost the Super Tank gains when on fire.
7. Added the `Self Throw Ability` KeyValue which lets the Super Tank throw itself.
8. Added the `Nullify Claw-Rock` KeyValue which lets the Super Tank nullify all of a survivor's damage.
9. Added the `Nullify Chance` KeyValue which decides how often the Super Tank can nullify all of a survivor's damage.
10. Added the `Nullify Duration` KeyValue which decides how long the Super Tank can nullify all of a survivor's damage.
11. Buried survivors are now frozen in place.
12. Buried survivors are now teleported to nearby teammates to avoid falling through the map after being unburied.
13. The `Hypno` ability no longer sets survivors' HP to 1 when the inflicted damage is higher than their health, but rather incapacitates them.
14. Removed the `Tank Types` KeyValue.
15. Replaced the `Tank Character` KeyValue with `Tank Enabled`. (Now users can simply enable/disable each Tank without using a letter, number, or symbol.)
16. Added Tank death announcement messages.
17. Increased the maximum amount of possible Super Tank types from 250 to 1000.
18. Added a Super Tanks++ menu to the admin menu.

Files:

1. Updated include file.

## Version 8.17 (June 6, 2018)

Changes:

1. Added the `Hypno Mode` KeyValue to decide whether hypnotized survivors can only hurt themselves or other teammates.
2. The `Hypno` ability now uses OnTakeDamage instead of TraceAttack and supports multiple damage types.
3. The `Hypno` ability's effect only activates when hypnotized survivors hurts/kills the Super Tank that hypnotized them.
4. The `Hypno` ability no longer kills hypnotized survivors when they kill the Super Tank that hypnotized them.
5. The bullet (gunshot) damage done onto a Super Tank by its hypnotized victim will now have 1/10 of it inflicted upon the hypnotized victim.
6. The slash (melee) damage done onto a Super Tank by its hypnotized victim will now have 1/1000 of it inflicted upon the hypnotized victim. 
7. Added the `Bury Height` KeyValue to decide how deep survivors are buried.
8. Added a check for only burying survivors that are on the ground to avoid bugs.

Files:

1. Updated include file.

## Version 8.16 (July 5, 2018)

Bug fixes:

1. Fixed the Car Throw Ability, Infected Throw Ability, and Shield Ability's propane throw not working.
2. Fixed the `Enabled Game Modes` and `Disabled Game Modes` KeyValues not having enough space for more than 2-4 game modes.
3. Fixed the issue with default `unnamed` Tanks appearing when certain Super Tanks are disabled.
4. Fixed the `Warp` ability's interval glitching out.
5. Fixed the `Gravity` ability creating more than 1 `point_push` entity per Tank.

Changes:

1. Raised the character limit of the `Tank Types` KeyValue from 64 to 250.
2. Added the `Particle Effect` and `Particle Effects` KeyValues to let users decide which particle effects to attach to Super Tanks.
3. Removed the `Smoke Effect` KeyValue.
4. Modified the `Props Attached` KeyValue to support the oxygen tank flames. New format: `Props Attached` `12345`
5. Modified the `Props Chance` KeyValue to support the oxygen tank flames. New format: `Props Chance` `3,3,3,3,3`
6. Modified the `Props Colors` KeyValue to support the oxygen tank flames. New format: `Props Colors` `255,255,255,255|255,255,255,255|255,255,255,255|255,255,255,255|255,255,255,255`
7. Added the `Panic Claw-Rock` KeyValue which lets the Super Tank start panic events.
8. Added the `Panic Chance` KeyValue which decides how often the Super Tank can start panic events.
9. Added the `Bury Claw-Rock` KeyValue which lets the Super Tank bury survivors.
10. Added the `Bury Chance` KeyValue which decides how often the Super Tank can bury survivors.
11. Added the `Bury Duration` KeyValue which decides how long the Super Tank can bury survivors.
12. Replaced the following KeyValues with the `Infected Options` KeyValue for more infected throw variety.

```
Boomer Throw
Charger Throw
Clone Throw
Hunter Throw
Jockey Throw
Smoker Throw
Spitter Throw
```

Files:

1. Updated include file.

## Version 8.15 (June 30, 2018)

Bug fixes:

1. Fixed the shield color being overridden when the Super Tank has the Ghost Ability enabled.
2. Fixed custom configs not respecting the settings from the main config when KeyValues aren't found inside the custom configs.
3. Fixed the `player_death` event callback returning the victim's user ID for the attacker.

Changes:

1. Users can now choose different colors for each prop (Change `Skin-Prop-Glow Colors` to `Skin-Glow Colors` and add `Props Colors`). Format: `Skin-Glow Colors` `255,255,255,255|255,255,255`, `Props Colors` `255,255,255,255|255,255,255,255|255,255,255,255|255,255,255,255`
2. Added the `Multiply Health` KeyValue to determine how the Super Tank's health should be handled (0: No changes to health, 1: Multiply original health only, 2: Multiply extra health only, 3: Multiply both). Format: `Multiply Health` `3`
3. Added the `Bomb Rock Break` KeyValue which makes the Super Tank's rocks explode. Format: `Bomb Rock Break` `1`
4. Added the `Car Throw Ability` KeyValue which lets the Super Tank throw cars. Format: `Car Throw Ability` `1`
5. Added the `Vampire Claw-Rock` KeyValue which lets the Super Tank steal health from survivors. Format: `Vampire Claw-Rock` `1`
6. Added the `Vampire Health` KeyValue to determine how much health the Super Tank receives from hitting survivors. Format: `Vampire Health` `100`
7. Added the `Vampire Chance` KeyValue to determine the chances of the Super Tank stealing health from survivors. Format: `Bomb Rock Break` `4`
8. The config file is now automatically created if it doesn't exist already.
9. Optimized code even more.

Files:

1. Moved various stock functions to the include file.

## Version 8.14 (June 28, 2018)

Changes:

1. The `Flash` ability now fades properly when the Super Tank has the Ghost Ability enabled.
2. Raised the spawn point of the rocks for the `Spam` ability again to avoid collision with the Super Tank.

## Version 8.13 (June 28, 2018)

Bug fixes:

1. Fixed the `Ghost` ability not letting Super Tanks fade out to full invisibility.

Changes:

1. Lowered the spawn point of the rocks for the `Spam` ability.
2. Added the `Ghost Fade Limit` KeyValue setting to adjust the intensity of the `Ghost` ability's fade feature (255: No effect, 0: Fully faded).
3. Added the `Glow Effect` KeyValue setting to determine whether or not Super Tanks will have a glow outline (0: OFF, 1: ON).

Files:

1. Updated include file.
2. Updated `Boss` and `Meme` Tank's settings in the config file.

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

1. Added the convar `st_gamemodetypes` to determine what game mode types to enable/disable the plugin in. (0: All, 1: coop modes only, 2: versus modes only, 4: survival modes only, 8: scavenge modes only.)
2. Removed the `@witches` target filter for not working properly.
3. Optimized code a bit more.

Files:

1. Updated include file.

## Version 8.10 (June 22, 2018)

Changes:

1. Any extra health given to a Super Tank is now multiplied by the number of alive non-idle human survivors present when the Tank spawns. (Thanks emsit!)
2. Added the target filters `@smokers`, `@boomers`, `@hunters`, `@spitters`, `@jockeys`, `@chargers`, `@witches` for developers/testers to use.
3. Added the `sm_tank type 1-36` command to spawn each Tank for developing/testing purposes.
4. Added oxygen tank (jetpack) props to Tanks.
5. Modified the attachprops convars to now support multiple number combinations.
6. Removed unnecessary code.
7. Optimized code a bit.

Files:

1. Updated include file.

## Version 8.9 (June 21, 2018)

Changes:

1. Added a randomizer for Tanks spawning with props to add more variety.
2. Added the target filter `@tanks` for developers/testers to use.

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

1. Added options for the `st_displayhealth` convar. (1: show names only, 2: show health only, 3: show both names and health.)
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

1. Disabled Ice Tank for L4D1 version.
2. Only 28/40 are available for the L4D1 version now.
3. Fixed Shield Tank and other Super Tank types with shields not having their shields shattered by explosions.

## Version 6.5 (November 24, 2017)

1. Fixed the SetConVarInt errors reported by KasperH/Ladis here.

## Version 6.0 (November 24, 2017)

1. Added support for L4D1.
2. L4D1 version only includes 29/40 Super Tank types.
3. L4D1 version excludes prop attachments (concrete chunk and beam spotlight).
4. L4D1 version excludes glow outlines.
5. Changed the `l4d2_` prefix to `l4d_` for the plugin and config files.

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