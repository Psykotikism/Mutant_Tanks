# Changelog

## Version 8.95 (August 25, 2022)

### Bug Fixes

#### General
- Fixed a rare crash caused when the Tank's rock explodes. (Thanks to `thewintersoldier97`, `zaviier`, and `ddd123` for testing and reporting!)
- Fixed an issue where players are given the incorrect amount of special ammo when taking over a bot. (Thanks to `Slaven555` for testing and reporting!)
- Fixed error regarding the `Boss` feature. (Thanks to `yuzumi` for testing and reporting!)

#### Abilities
- Bury: Fixed survivors being able to shoot weapons and use items while affected. (Thanks to `ddd123` for reporting!)
- Choke: Fixed survivors being able to shoot weapons and use items while affected. (Thanks to `ddd123` for reporting!)
- Splatter: Fixed survivor bots getting affected by the ability.

### Changes

#### Game Data
- Removed unnecessary/unused sections.

#### Translations
- Updated English translations.
- Updated Simplified Chinese translations. (Thanks to `yuzumi`!)
- Updated Hungarian translations. (Thanks to `KasperH`/`Ladis`!)
- Updated Russian translations. (Thanks to `Blueberry`/`Kleiner`!)

#### Natives & Forwards
- Added the `MT_DeafenPlayer` native.
- Added the `MT_StaggerPlayer` native.

#### Abilities
- Changed the minimum value of the `* Damage` setting for several abilities from `1`/`1.0` to `0`/`0.0`.
- Blind
	- Added a flashbang option. (Thanks to `Silvers` for the code!)
	- Added the `Blind Mode` setting.
	- Added the `Blind Stagger` setting.
	- The ability can now affect bots.
- Medic
	- Added the `Medic Buff Damage` setting.
	- Added the `Medic Buff Resistance` setting.
	- Added the `Medic Buff Speed` setting.
	- Added the `Medic Symbiosis` setting.
- Quiet: The ability now silences footsteps. (Requested by `ddd123`.)
- Splatter
	- Changed how splatters are displayed. (Thanks to `Lux` and `Silvers` for the code!)
	- Removed the `Human Duration` setting.
	- Removed the `Human Mode` setting.
	- Added the `Immunity Flags` setting.
	- Added the `Ability Effect` setting.
	- Added the `Splatter Hit` setting.
	- Added the `Splatter Hit Mode` setting.
	- Added the `Splatter Range` setting.
	- Added the `Splatter Range Chance` setting.
	- Added the `Splatter Range Cooldown` setting.
	- Changed the default value of the `Splatter Duration` setting from `0` to `5`.
	- Changed the default value of the `Splatter Interval` setting from `5.0` to `1.0`.
- Yell
	- Added the `Yell Mode` setting.
	- Re-added the deafen feature. (Requested by `ddd123`.)
	- Changed the default value of the `Requires Humans` setting from `1` to `0`.

### Files

#### General
- The pre-compiled plugins included in the package are:
	- Compiled without any of the optional dependencies.
	- Compiled with the `SourceMod 1.11.0.6880` compiler.

#### Updates
- Updated config files.
- Updated gamedata file.
- Updated include file.
- Updated translation files.
- Updated updater file.

## Version 8.94 (July 4, 2022)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Abilities</summary>

#### Abilities
- Fixed the `* Cooldown` setting for several abilities. (Thanks to `Mi.Cura` for testing and reporting!)
- Jump: Fixed the Tank's periodical and sporadic jumping not ending properly. (Thanks to `Mi.Cura` for testing and reporting!)
- Spam: Fixed the ability not shooting any rocks. (Thanks to `Mi.Cura` for testing and reporting!)
</details>

### Changes
<details>
	<summary>General</summary>

#### General
- `SourceMod 1.11.0.6880` or higher is now required.
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Changed the minimum value of the `Human Duration` setting for several abilities from `1` to `0`.
- Absorb
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `Absorb Duration` setting from `1` to `0`.
- Car
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `Car Duration` setting from `1` to `0`.
- Cloud: Added the `Cloud Duration` setting.
- Fast
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `Fast Duration` setting from `1` to `0`.
- Fly
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `Fly Duration` setting from `1` to `0`.
- Fragile
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `Fragile Duration` setting from `1` to `0`.
- Ghost
	- Added the `Ghost Duration` setting.
	- The `Ghost Duration` setting can be substituted by the `Combo Duration` setting when combined with other abilities.
	- The `Ghost Fade Delay` setting can no longer be substituted by the `Combo Duration` setting when combined with other abilities.
	- The `Ghost Fade Rate` setting can no longer be substituted by the `Combo Interval` setting when combined with other abilities.
- God
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `God Duration` setting from `1` to `0`.
- Gravity
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `Gravity Duration` setting from `1` to `0`.
- Heal: Added the `Heal Duration` setting.
- Jump
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `Jump Duration` setting from `1` to `0`.
- Laser
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `Laser Duration` setting from `1` to `0`.
- Lightning
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `Lightning Duration` setting from `1` to `0`.
- Medic: Added the `Medic Duration` setting.
- Meteor
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `Meteor Duration` setting from `1` to `0`.
- Necro: Added the `Necro Duration` setting.
- Omni
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `Omni Duration` setting from `1` to `0`.
- Panic: Added the `Panic Duration` setting.
- Pyro
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `Pyro Duration` setting from `1` to `0`.
- Quiet: Added the `Quiet Filter` setting.
- Regen: Added the `Regen Duration` setting.
- Rock
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `Rock Duration` setting from `1` to `0`.
- Shield: Added the `Shield Duration` setting.
- Spam
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `Spam Duration` setting from `1` to `0`.
- Splash: Added the `Splash Duration` setting.
- Splatter: Added the `Splatter Duration` setting.
- Warp: Added the `Warp Duration` setting.
- Yell
	- Added the `Human Duration` setting.
	- Changed the minimum value of the `Yell Duration` setting from `1` to `0`.
	- Added the `Yell Damage` setting.
	- Added the `Yell Interval` setting.
	- Added the `Yell Pitch` setting.
	- Removed the deafen feature.
- Zombie: Added the `Zombie Duration` setting.
</details>

### Files
<details>
	<summary>General</summary>

#### General
- The pre-compiled plugins included in the package are:
	- Compiled without any of the optional dependencies.
	- Compiled with the `SourceMod 1.11.0.6880` compiler.
</details>
<details>
	<summary>Updates</summary>

#### Updates
- Updated config files.
- Updated gamedata file.
- Updated include file.
- Updated updater file.
</details>
</details>

## Version 8.93 (June 20, 2022)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Fixed the refill reward not working properly. (Thanks to `Mi.Cura` for testing and reporting!)
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Fixed an issue where the `Combo Set` setting was being formatted incorrectly, resulting in strange behavior. (Thanks to `ddd123` for reporting!)
- Drop: Fixed an issue where weapons attached to Tanks are not affected by the `Ghost` ability's fade feature.
- Ghost: Fixed main ability not activating in combinations when secondary ability is enabled.
- Gravity: Fixed main ability not activating in combinations when secondary ability is enabled.
- Heal: Fixed main ability not activating in combinations when secondary ability is enabled.
- Jump: Fixed main ability not activating in combinations when secondary ability is enabled.
- Warp:
	- Fixed main ability not activating in combinations when secondary ability is enabled.
	- Fixed an issue with choosing a random survivor or Tank to warp to.
</details>

### Changes
<details>
	<summary>General</summary>

#### General
- Mutant Tanks and its sub-plugins now check for duplicate plugins and several old versions (including `Super Tanks++`) before loading.
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Forwards are now registered before the plugin loads.
</details>
<details>
	<summary>Commands</summary>

#### Commands
- Removed the following commands (No longer used.):
	- `sm_mt_config2` - Same function as `sm_mt_config`
	- `sm_mt_list2` - Same function as `sm_mt_list`
	- `sm_mt_tank2`/`sm_tank2` - Same function as `sm_mt_tank`/`sm_tank`
	- `sm_mt_version2` - Same function as `sm_mt_version`
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Changed the default values of the following settings to `0.0`:
	- `Close Areas Only`
	- `Open Areas Only`
- Ghost: The `Ghost Fade Delay` setting can now be substituted by the `Combo Duration` setting when combined with other abilities.
</details>

### Files
<details>
	<summary>Updates</summary>

#### Updates
- Updated config files.
- Updated include file.
- Updated updater file.
</details>
</details>

## Version 8.92 (June 1, 2022)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Commands</summary>

#### Commands
- Fixed the `sm_mt_ability` and `sm_mt_ability2` commands not displaying a menu for several abilities.
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Fixed an issue where several claw/melee abilities will fail to activate when a human-controlled Tank uses up all their ammunition for their range abilities.
- Warp: Fixed the Tank teleporting inside solid objects.
</details>

### Changes
<details>
	<summary>General</summary>

#### General
- Improved plugin load speed on server startup.
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- The speed boost reward now allows recipients to burst open doors by running into them. (Thanks to `Silvers` for the code!)
- The bunny hop reward now allows better control with movement keys.
</details>
<details>
	<summary>Game Data</summary>

#### Game Data
- L4D2: Removed signatures for `CTerrorGameRules::IsGenericCooperativeMode`.
- L4D2: Added signatures for the following functions:
	- `CTerrorGameRules::IsCoopMode`
	- `CTerrorGameRules::IsRealismMode`
- The following functions' signatures are now dynamically generated (Thanks to `Silvers` for the code!):
	- `CDirector::IsFirstMapInScenario` (L4D2)
	- `CSpitterProjectile::Create` (L4D2)
	- `CTerrorGameRules::GetMissionFirstMap`
	- `CTerrorGameRules::IsCoopMode`
	- `CTerrorGameRules::IsMissionFinalMap`
	- `CTerrorGameRules::IsHoldoutMode` (L4D1)
	- `CTerrorGameRules::IsRealismMode` (L4D2)
	- `CTerrorGameRules::IsVersusMode` (L4D1)
	- `CTerrorPlayer::MaterializeFromGhost`
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Added the `Burst Doors Reward` setting under the `Plugin Settings->Rewards`, `Tank #->Rewards`, and `STEAM_ID->Rewards` sections.
- Added the `Close Areas Only` setting to determine which types or abilities are only for close areas. (Thanks to `Angelace113` for the idea!)
- Added the following settings under the `Tank #->Combo` and `STEAM_ID->Combo` sections:
	- `Combo Range Cooldown`
	- `Combo Rock Cooldown`
- The `Combo Cooldown` setting under the `Tank #->Combo` and `STEAM_ID->Combo` sections is now enabled.
</details>
<details>
	<summary>Translations</summary>

#### Translations
- Updated English translations.
- Updated Simplified Chinese translations.
- Updated Hungarian translations.
- Updated Russian translations. (Thanks to `Blueberry`/`Kleiner`!)
</details>
<details>
	<summary>Natives & Forwards</summary>

#### Natives & Forwards
- Updated the documentation for the `MT_GetCombinationSetting` native.
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Changed the default value of the `Human Cooldown` setting from `30` to `0`.
- Improved the code execution of several abilities' `Combo` logic.
- Added the following settings for several abilities (Requested by `Shao`.):
	- `Human Range Cooldown`
	- `Human Rock Cooldown`
	- `* Cooldown`
	- `* Range Cooldown`
	- `* Rock Cooldown`
- Acid
	- Added the `Human Rock Cooldown` setting. (Requested by `Shao`.)
	- Added the `Acid Rock Cooldown` setting. (Requested by `Shao`.)
- Bomb
	- Added the `Human Rock Cooldown` setting. (Requested by `Shao`.)
	- Added the `Bomb Rock Cooldown` setting. (Requested by `Shao`.)
- Fast: Changed the default value of the `Open Areas Only` setting from `0.0` to `150.0`.
- Fire
	- Added the `Human Rock Cooldown` setting. (Requested by `Shao`.)
	- Added the `Fire Rock Cooldown` setting. (Requested by `Shao`.)
- Track: Changed the default value of the `Open Areas Only` setting from `0.0` to `500.0`.
- Warp
	- Added the `Human Rock Cooldown` setting. (Requested by `Shao`.)
	- Added the `Warp Rock Cooldown` setting. (Requested by `Shao`.)
	- Removed non-working code.
- Zombie: Removed non-working code.
</details>

### Files
<details>
	<summary>General</summary>

#### General
- The pre-compiled plugins included in the package are:
	- Compiled without any of the optional dependencies.
	- Compiled with the `SourceMod 1.11.0.6806` compiler.
</details>
<details>
	<summary>Updates</summary>

#### Updates
- Updated config files.
- Updated gamedata file.
- Updated include file.
- Updated translation files.
- Updated updater file.
</details>
</details>

## Version 8.91 (April 16, 2022)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>General</summary>

#### General
- Fixed game events not being tracked properly. (Thanks to `Krufftys Killers` for reporting!)
- Fixed [`Updater`](https://github.com/Teamkiller324/Updater) support.
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Fixed the screen effect of abilities being fully visible. (Thanks to `ddd123` and `Mi.Cura` for testing and reporting!)
- Fixed a detour setup that caused Linux users to crash when Tank rocks are thrown.
- Fixed an issue where certain special infected cannot suicide because of the friendly-fire block.
- Fixed occasional invalid entity errors. (Thanks to `Mi.Cura` for reporting!)
- Fixed some code for the `Clone` ability being compiled when the `mt_clone.inc` include is not included.
- Fixed survivors not getting slowed down by common infected and most damage sources. (Thanks to `Shao` for testing and reporting!)
- Fixed the Tank's glow settings not working when a player passes control to the AI. (Thanks to `yuzumi` for testing and reporting!)
- Fixed the midair dashes reward counting the initial jump as a midair dash.
</details>
<details>
	<summary>Config Files</summary>

#### Config Files
- Fixed player count configs not updating when more than two players are detected. (Thanks to `Mi.Cura` for testing and reporting!)
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Fixed the `Skip Taunt` setting not working. (Thanks to `sorallll` for the code!)
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Fly: Fixed the `player_jump` game event not being hooked.
- Recoil: Fixed the `weapon_fire` game event not being hooked.
- Warp: Fixed the Tank teleporting in narrow areas. (Thanks to `yuzumi` for testing and reporting!)
</details>

### Changes
<details>
	<summary>General</summary>

#### General
- Mutant Tanks and its sub-plugins now properly support `Updater`.
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Raised the size for Steam ID buffers to support other outputs.
- Added log messages for tracking custom configs.
- Changed how the Tank's health is refilled when players switch between different Mutant Tank types. (Thanks to `yuzumi` for suggesting!)
- Added support for third-party plugins manually setting Tanks in ghost mode. (Requested by `yuzumi`.)
- The speed boost reward's forward jump boost now only applies to the bunny hop reward.
- The speed boost reward now allows recipients to change their voice pitch. (Thanks to `Marttt` for the code!)
</details>
<details>
	<summary>Commands</summary>

#### Commands
- Added a `Voice Pitch` option to the `sm_mt_admin` command's panel.
- Added a `Voice Pitch Visual` option to the `sm_mt_prefs` command's menu.
</details>
<details>
	<summary>Game Data</summary>

#### Game Data
- L4D2: The following functions' signatures are now dynamically generated (Thanks to `Silvers` for the code!):
	- `CTerrorGameRules::IsScavengeMode`
	- `CTerrorGameRules::IsSurvivalMode`
	- `CTerrorGameRules::IsVersusMode`
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Added the following settings under the `Tank #->Boss` section (Requested by `xcd222`.):
	- `Boss Base Type`
	- `Boss Limit`
- Added more options to the `Item Mode` setting.
- Added the `Incap Damage Multiplier` setting under the `Plugin Settings->Enhancements`, `Tank #->Enhancements`, and `STEAM_ID->Enhancements` sections. (Requested by `Shao`.)
- Added the `Combo Cooldown` setting under the `Tank #->Combo` and `STEAM_ID->Combo` sections. (Unused for now.)
- Added the following settings under the `Plugin Settings->Health`, `Tank #->Health`, and `STEAM_ID->Health` sections (Requested by `xcd222`.):
	- `Human Multiplier Mode`
	- `Health Percentage Multiplier`
- Added the `Voice Pitch Visual` setting under the `Plugin Settings->Rewards`, `Tank #->Rewards`, and `STEAM_ID->Rewards` sections.
</details>
<details>
	<summary>Translations</summary>

#### Translations
- Updated English translations.
- Updated Simplified Chinese translations.
- Updated Hungarian translations.
- Updated Russian translations.
</details>
<details>
	<summary>Natives & Forwards</summary>

#### Natives & Forwards
- Updated the documentation for the `MT_OnPluginEnd` forward.
- Updated the documentation for the `MT_GetCombinationSetting` native.
- Added the `MT_OnPluginUpdate` forward. (This forward only fires when `Updater` is installed.)
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Warp: Added logic for checking coordinates before teleporting the Tank.
- Zombie: Added logic for checking coordinates before spawning common infected.
</details>

### Files
<details>
	<summary>General</summary>

#### General
- The pre-compiled plugins included in the package are:
	- Compiled without any of the optional dependencies.
	- Compiled with the `SourceMod 1.11.0.6806` compiler.
</details>
<details>
	<summary>Additions</summary>

#### Additions
- A file named `mutant_tanks_temp.txt` will now be automatically created, handled, and maintained by the core plugin.
</details>
<details>
	<summary>Requirements</summary>

#### Requirements
- Windows users: The `mutant_tanks_signatures.cfg` config file is now used by the core plugin.
</details>
<details>
	<summary>Compilation</summary>

#### Compilation
- Added compiler warnings for the following plugin source files that notify users when one or more abilities are disabled/excluded (Thanks to `Marttt` for the idea!):
	- `mt_abilities.sp`
	- `mt_abilities2.sp`
</details>
<details>
	<summary>Updates</summary>

#### Updates
- Updated config files.
- Updated gamedata file.
- Updated include file.
- Updated translation files.
- Updated updater file.
</details>
</details>

## Version 8.90 (February 1, 2022)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Fixed props not deleting themselves when Tanks change their Mutant Tank types.
- Fixed the Tank's health not updating in some scenarios. (Thanks to `saberQAQ` for reporting!)
- Fixed the Tank's attack and throw intervals not resetting themselves when Tanks change their Mutant Tank types.
- Fixed Tanks devolving when spawning as later stages of the `Boss` feature. (Thanks to `Maku` for reporting!)
- Fixed custom configs not refreshing when the main config file is refreshed.
- Fixed `Client Preferences` not being optional.
- Fixed the logic for the detour and patching systems.
- Fixed any compilation errors on the latest `SM 1.11` builds.
- Fixed custom config files not being created. (Thanks to `kot4404` and `Mi.Cura` for testing and reporting!)
- Fixed grouped sections in config files not being read properly.
- Fixed fire immunity blocking overall damage from guns with incendiary ammo. (Thanks to `weffer` for testing and reporting!)
- Fixed explosive immunity blocking overall damage from guns with explosive rounds. (Thanks to `weffer` for testing and reporting!)
</details>
<details>
	<summary>Commands</summary>

#### Commands
- Fixed the `sm_mutanttank` command not resetting its cooldown between `Versus`/`Scavenge` rounds.
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Fixed the `Attack Interval` setting causing Tanks to never use their primary attack. (Thanks to `KadabraZz` for reporting!)
- Fixed the `Skip Taunt` setting not being exclusive to L4D2.
</details>
<details>
	<summary>Natives & Forwards</summary>

#### Natives & Forwards
- Fixed the `SDKCall` error for the `MT_VomitPlayer` native in L4D1.
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Acid: Fixed survivors not taking damage from acid puddles in some scenarios. (Thanks to `yuzumi` for testing and reporting!)
- Blind: Fixed the ability not resetting properly when the Tank dies before the duration ends. (Thanks to `Mi.Cura` for reporting!)
- Bury: Fixed survivors getting stuck under the map when the ability's effect wears off.
- Fly: Fixed camera bug where spectators are dropped to the ground and forced to travel to map origin. (Thanks to `Angelace113` for testing and reporting!)
- Spam: Fixed the rocks exploding upon launch in L4D1.
- Warp: Fixed the Tank teleporting inside props and other solid objects. (Thanks to `yuzumi` for testing and reporting!)
</details>

### Changes
<details>
	<summary>General</summary>

#### General
- The `mutant_tanks_detours.cfg` and `mutant_tanks_patches.cfg` files are now read differently.
- All settings in the `mutant_tanks_detours.cfg` and `mutant_tanks_patches.cfg` files can now be set globally and per platform.
- The `mutant_tanks_detours.cfg` and `mutant_tanks_patches.cfg` files now accept different formats like the main config file.
- Renamed and added several settings for the `mutant_tanks_detours.cfg` and `mutant_tanks_patches.cfg` files.
- Added [`Updater`](https://github.com/Teamkiller324/Updater) support.
- Added [`AutoExecConfig`](https://forums.alliedmods.net/showthread.php?t=204254) support.
- Added full MacOS support. (Untested)
- Created macros for several arbitrary values.
- Improved the RNG logic for all features that are RNG-based.
- Added developer HUD panel for viewing currently alive Tanks.
- `SourceMod 1.11.0.6806` or higher is now required.
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- The speed boost reward now does the following:
	- Allows recipients to bunny hop. (Thanks to `Chanz` for the code!)
	- Allows recipients to perform midair dashes (extra jumps). (Thanks to `epzminion` for the idea and help!)
- The attack boost reward now does the following:
	- Prevents recipients from being interrupted when performing any actions.
	- Prevents recipients from switching to their secondary slots when equipping secondary pistols. (Thanks to `HarryPotter` for the idea and `Forgetest` for the method!)
	- Prevents recipients from switching to their secondary slots when equipping throwables and health supplies given by teammates. (Thanks to `Silvers` for the code!)
	- Prevents recipients from being slowed down when attacked by infected.
	- Prevents infected attacks from offsetting recipients' aim.
- The damage boost reward now does the following:
	- Prevents recipients from dealing and receiving friendly-fire.
	- Allows recipients to burn their special infected targets indefinitely (until the recipient or target dies, or the reward ends).
	- Allows recipients to have an extended pipebomb duration.
	- Removes recipients' gun recoil. (Thanks to `epzminion` for the help!)
- The regular waves spawner now does the following (Requested by `yuzumi`.):
	- Stops when there is at least one Tank alive on the map.
	- Restarts once every Tank on the map is dead.
- Added another method for detecting vomited/unvomited players. (Thanks to `Marttt` for the information!)
- Improved friendly-fire checks. (Thanks to `Silvers` for the code!)
- Improved logging for patching system.
- Changed the method for aggravating idle Tanks. (Thanks to `cravenge` for the code and gamedata info!)
- Updated the logic for skipping the Tank's taunt animation. (Thanks to `sorallll` for the code!)
- Added compatibility for several third-party plugins that detour or patch functions.
</details>
<details>
	<summary>Commands</summary>

#### Commands
- Added the `sm_mtank` alias for the `sm_mutanttank` command.
</details>
<details>
	<summary>Game Data</summary>

#### Game Data
- Added offsets for `CPainPills::GetWeaponID`.
- Added signatures for `GetWeaponInfo`.
- Added signatures and patch offsets for the following functions:
	- `CTerrorGun::EquipSecondWeapon`
	- `CTerrorPlayer::OnTakeDamage_Alive`
- Added detour setup for the following functions:
	- `CTankRock::Detonate`
	- `CTerrorPlayer::OnITExpired`
- Added detour setup and signatures for the following functions:
	- `CBaseEntity::GetGroundEntity`
	- `CPipeBombProjectile::Create`
	- `CTankClaw::PrimaryAttack`
	- `CTerrorGameMovement::CheckJumpButton`
	- `CTerrorGun::FireBullet` (L4D1)
	- `CTerrorGun::Use`
	- `CTerrorPlayer::Extinguish`
	- `CThrow::ActivateAbility`
	- `CWeaponSpawn::Use`
- Added detour setup, signatures, and patch offsets for `TankBehavior::InitialContainedAction`.
- Updated documentation for finding several signatures and offsets.
- L4D1: Updated several offsets for the `1.0.4.1` update.
- L4D2: Updated several signatures for the `2.2.2.3` update.
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Added the `Auto Update` setting under the `Plugin Settings->General` section.
- Added the following settings under the `Plugin Settings->Rewards`, `Tank #->Rewards`, and `STEAM_ID->Rewards` sections:
	- `Bunny Hop Reward`
	- `Friendly Fire Reward`
	- `Inextinguishable Fire Reward`
	- `Looping Voiceline Interval`
	- `Midair Dashes Reward`
	- `Pipebomb Duration Reward`
	- `Recoil Dampener Reward`
- Added more options to the `Spawn Mode` setting. (Requested by `saberQAQ`.)
- Changed the default value of the `Aggressive Tanks` setting from `0` to `1`.
- The `Aggressive Tanks` setting under the `Plugin Settings->Competitive` can now be overridden for each Mutant Tank type.
- Renamed the `Aggressive Tanks` setting to `Auto Aggravate`.
- Added the `Rock Sound` setting under the `Plugin Settings->Enhancements`, `Tank #->Enhancements`, and `STEAM_ID->Enhancements` sections.
- Updated the following settings to support the `0th` wave on finale maps (before finale events start):
	- `Finale Types`
	- `Finale Waves`
- Changed the `Throw Interval` setting's logic.
- All settings with a maximum value of `999999` are now limited to `99999`.
</details>
<details>
	<summary>Translations</summary>

#### Translations
- Updated English translations.
- Updated Simplified Chinese translations. (Thanks to `yuzumi`!)
- Updated Hungarian translations. (Thanks to `KasperH`/`Ladis`!)
- Updated Russian translations. (Thanks to `Blueberry`/`Kleiner`!)
</details>
<details>
	<summary>Natives & Forwards</summary>

#### Natives & Forwards
- Updated all compiler warnings for deprecated forwards and natives.
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Bury: The ability now automatically teleports targeted survivors and blocks fall damage until they land to avoid being stuck under the map when the ability's effect ends.
- Fly
	- Incapacitated or ledge-hanging survivors are no longer affected.
	- Changed the default value of the `Open Areas Only` setting from `150.0` to `500.0`.
- Vampire
	- Added the `Vampire Health` setting. (Requested by `moschinovac`.)
	- Added the `Vampire Health Multiplier` setting. (Requested by `moschinovac`.)
- Warp
	- Added the `Warp Rock Break` setting.
	- Added the `Warp Rock Chance` setting.
</details>

### Files
<details>
	<summary>Additions</summary>

#### Additions
- Added the `mutant_tanks_updater.txt` file which is used by `Updater`.
</details>
<details>
	<summary>Updates</summary>

#### Updates
- Updated config files.
- Updated gamedata file.
- Updated include file.
- Updated translation files.
</details>
</details>

## Version 8.89 (September 11, 2021)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>General</summary>

#### General
- Fixed Tanks taking damage from their own rocks.
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Fixed error regarding functions that are not detoured. (Thanks to `KasperH`/`Ladis` for testing and reporting!)
- Fixed error regarding invalid address pointing to reserved memory. (Thanks to `yuzumi` and `Mi.Cura` for reporting!)
</details>
<details>
	<summary>Commands</summary>

#### Commands
- Fixed missing compiler checks for the following commands' callback functions:
	- `sm_mt_blind`
	- `sm_mt_restart`
	- `sm_mt_rocket`
	- `sm_mt_slow`
</details>
<details>
	<summary>Game Data</summary>

#### Game Data
- Fixed the `CTerrorGameRules::GetMissionFirstMap` function using the wrong signature.
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Fixed abilities resetting exclusive variables when Tanks spawn. (Thanks to `ddd123` for testing and reporting!)
- Fixed abilities using the wrong prototype for the `MT_OnChangeType` forward.
- Heal: Fixed the glow outline feature not relying on the settings under the `Tank #->Glow` and `STEAM_ID->Glow` sections. (Thanks to `ddd123` for testing and reporting!)
- Omni: Fixed settings not caching properly when the Tank spawns. (Thanks to `Mi.Cura` for testing and reporting!)
</details>

### Changes
<details>
	<summary>General</summary>

#### General
- Changed the method for checking idle Tanks.
- Changed the method for checking game modes. (Thanks to `epzminion` for the idea!)
- Removed the overabundant and unconditional usage of static variables and functions. This does not have any effect on plugin behavior but resolves any future/potential bugs and unnecessary storage for variables' infinite lifetime and exclusivity of functions.
- Removed parentheses of `sizeof` uses.
- Removed unnecessary usage of the `public` keyword.
- Removed unnecessary usage of the `OnAllPluginsLoaded` forward. (Thanks to `Silvers` for the information!)
- `SourceMod 1.11.0.6724` or higher is now required.
</details>
<details>
	<summary>Game Data</summary>

#### Game Data
- Added signatures, patch offsets, and detour setup for `CTankClaw::GroundPound`. (Thanks to `Forgetest` for the patch offsets!)
- Added signatures for the following functions:
	- `CTerrorGameRules::HasConfigurableDifficultySetting`
	- `CTerrorGameRules::IsCoopMode`
	- `CTerrorGameRules::IsGenericCooperativeMode`
	- `CTerrorGameRules::IsHoldoutMode`
	- `CTerrorGameRules::IsScavengeMode`
	- `CTerrorGameRules::IsSurvivalMode`
	- `CTerrorGameRules::IsVersusMode`
- Updated signatures for `CTerrorWeapon::CanDeploy` and `CTerrorWeapon::CanDeployFor` to be compatible with the [Incapped Weapons Patch](https://forums.alliedmods.net/showthread.php?t=322859) plugin.
- Removed some unused offsets.
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Added the `Ground Pound` setting under the `Plugin Settings->Enhancements`, `Tank #->Enhancements`, and `STEAM_ID->Enhancements` sections. (Thanks to `XYZC` for the idea!)
- Added the `Execute Config Delay` setting under the `Plugin Settings->Custom` section.
- Removed the `Allow Developer` setting. (No longer used.)
</details>
<details>
	<summary>Translations</summary>

#### Translations
- Updated Hungarian translations. (Thanks to `KasperH`/`Ladis`!)
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Heal: Added the `Heal Glow` setting. (Requested by `ddd123`.)
</details>

### Files
<details>
	<summary>Updates</summary>

#### Updates
- Updated config files.
- Updated gamedata file.
- Updated include file.
- Updated translation files.
</details>
</details>

## Version 8.88 (August 10, 2021)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Config Files</summary>

#### Config Files
- Fixed custom config filenames being case-sensitive. (Thanks to `ricksfishin` for testing and reporting!)
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Fixed the `Skip Taunt` setting not working in some config formats.
</details>

### Changes
<details>
	<summary>General</summary>

#### General
- Increased performance when patching the same address repeatedly. (Thanks to `Lux` for the example!)
- `SourceMod 1.11.0.6711` or higher is now required when recompiling the plugin.
- The `mutant_tanks_patches.cfg`'s `cvarcheck` key now allows up to `10` convar checks.
- The `mutant_tanks_patches.cfg`'s `type` key now accepts the `unused` value to disable patches.
- Improved readability by using named parameters instead of positional parameters.
- Replaced the method for blocking the strong wind sound caused by Tank rock debris with a patch.
- L4D1: Updated several offsets for the `1.0.4.0` update.
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- The attack boost reward now prevents recipients from being interrupted when reviving teammates who are taking damage. (Thanks to `BHaType` for the idea and `Lux` for the help!)
- Increased the interval for checking config files for changes from `1` to `10` seconds.
- Rewards now end properly at the end of each non-finale map. (Thanks to `epzminion` for the help!)
- Switched to a simpler method for checking `Versus` and `Scavenge` rounds.
- Switched to a better method for patching survivor fall screams.
</details>
<details>
	<summary>Game Data</summary>

#### Game Data
- Added detailed documentation for every detour, address, offset, and signature. (Thanks to `epzminion`, `Lux`, `Silvers`, and `Dragokas` for some of their methods included in the documentation!)
</details>
<details>
	<summary>Settings</summary>

#### Settings
1. Added the `Skip Incap` setting under the `Plugin Settings->Enhancements`, `Tank #->Enhancements`, and `STEAM_ID->Enhancements` sections. (Thanks to `epzminion` for the help!)
</details>

### Files
<details>
	<summary>Requirements</summary>

#### Requirements
- The `mutant_tanks_detours.cfg` config file is now used by the core plugin.
</details>
<details>
	<summary>Updates</summary>

#### Updates
- Updated config files.
- Updated gamedata file.
- Updated include file.
</details>
</details>

## Version 8.87 (July 20, 2021)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>General</summary>

#### General
- Fixed the `send reliable stream overflow` error. (Thanks to `Slaven555`, `Mi.Cura`, and `GL_INS` for testing and reporting!)
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Fixed the lady killer reward not resetting when the server changes to a different campaign without finishing the previous one first.
</details>

### Changes
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Reformatted the output of the `Death Details` setting's teammate list again.
- Recombined the list of rewards shown in chat when receiving rewards.
- Removed thirdperson check for survivors.
- Rewards are now transferred over properly between bots and idle players (and vice-versa).
- Tank spawn and death announcements will no longer appear once the rescue vehicle leaves.
- Added the `sm_mt_admin` command to allow admins to set their visual perks. (Requested by `XXrevoltadoXX`.)
- Changed the logic for stacking rewards.
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Added the following settings under the `Plugin Settings->Rewards`, `Tank #->Rewards`, and `STEAM_ID->Rewards` sections:
	- `Share Rewards` (Thanks to `FusionFlarez` for the idea!)
	- `Stack Limits`
</details>
<details>
	<summary>Translations</summary>

#### Translations
- Updated English translations.
- Updated Simplified Chinese translations. (Thanks to `yuzumi`!)
- Updated Hungarian translations. (Thanks to `KasperH`/`Ladis`!)
- Updated Russian translations. (Thanks to `Blueberry`/`Kleiner`!)
</details>

### Files
<details>
	<summary>Updates</summary>

#### Updates
- Updated config files.
- Updated gamedata file.
- Updated include file.
- Updated translation files.
</details>
</details>

## Version 8.86 (July 8, 2021)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>General</summary>

#### General
- Fixed the `send reliable stream overflow` error (hopefully). (Thanks to `Slaven555`, `Mi.Cura`, and `GL_INS` for testing and reporting!)
- Fixed the `CFirstAidKit::StartHealing` detour causing errors on L4D1 Linux. (Thanks to `Neki93` for reporting and `epzminion` for the help!)
- Fixed null-pointer errors from detours. (Thanks to `Shadowart` for reporting!)
- Fixed the `mutant_tanks_patches.cfg` causing errors on Linux servers.
</details>
<details>
	<summary>Config Files</summary>

#### Config Files
- Fixed the `Combo` section not being read. (Thanks to `Uncle Jessie` for reporting!)
</details>
<details>
	<summary>Game Data</summary>

#### Game Data
- Fixed the `CTerrorGameMovement::DoJump` jump height patch causing a crash on L4D1 Linux and glitching out on L4D2 Linux. (Thanks to `epzminion` for the help!)
</details>

### Changes
<details>
	<summary>General</summary>

#### General
- Lowered the buffer size for chat messages to avoid the `send reliable stream overflow` error.
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- The attack boost reward now allows recipients to perform actions while on ladders. (Thanks to `Lux` for the gamedata info!)
- Renamed some keys for the patch config.
- Improved late-loading and compatibility with `Left 4 DHooks`.
- Added extra finale/non-finale map checks.
- Reformatted the output of the `Death Details` setting's teammate list.
- Separated the list of rewards shown in chat when receiving rewards.
</details>
<details>
	<summary>Config Files</summary>

#### Config Files
- All custom config filenames are now case-insensitive. (Thanks to `Shadowart` for bringing up the subject!)
</details>
<details>
	<summary>Game Data</summary>

#### Game Data
- Added new signatures for functions that check maps. (Thanks to `Silvers` for the original signatures!)
- Updated all of the signatures to be compatible with detours.
- Renamed all detours to avoid conflicts with other plugins.
- Replaced patches for the `CTerrorGameMovement::DoJump` function with a conversion function. (Thanks to `epzminion` for the code!)
- L4D2: Updated several offsets for the `2.2.2.0` update.
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Added the `Ladder Actions Reward` setting under the `Plugin Settings->Rewards`, `Tank #->Rewards`, and `STEAM_ID->Rewards` sections.
</details>
<details>
	<summary>Translations</summary>

#### Translations
- Updated English translations.
- Updated Simplified Chinese translations. (Thanks to `yuzumi`!)
- Updated Hungarian translations. (Thanks to `KasperH`/`Ladis`!)
- Updated Russian translations. (Thanks to `Blueberry`/`Kleiner`!)
</details>

### Files
<details>
	<summary>Updates</summary>

#### Updates
- Updated config files.
- Updated gamedata file.
- Updated include file.
- Updated translation files.
</details>
</details>

## Version 8.85 (June 20, 2021)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>General</summary>

#### General
- Fixed crashing on Linux whenever Tank is throwing a rock. (Thanks to `ReCreator` for testing and reporting and to `epzminion` and `Dragokas` for the help!)
- Fixed the plugins not compiling when `Left 4 DHooks`, `Client Preferences`, `Admin Menu`, or the `Clone` ability is missing. (Thanks to `ReCreator` for pointing this out!)
- Fixed the strong wind sound caused by Tank rock debris. (Thanks to `Lux` for the help!)
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Fixed some developer tools not toggling properly.
- Fixed the lady killer reward reminding players of their remaining uses even when the reward is disabled.
- Fixed the heal percent reward stacking incorrectly.
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Bury: Fixed message displaying the wrong distance of burials.
- Necro: Fixed the ability not working. (Thanks to `ddd123` for reporting!)
</details>

### Changes
<details>
	<summary>General</summary>

#### General
- Mutant Tank types will now be consistently mirrored across both teams on `Versus` and `Scavenge` game modes.
</details>
<details>
	<summary>Game Data</summary>

#### Game Data
- Changed the `CTankRock::Create` detour to a `CBaseEntity::Create` detour in L4D1. (Thanks to `Dragokas` for the idea!)
- L4D2: Updated some signatures and several offsets for the `2.2.1.3` update. (Thanks to `epzminion` for the help!)
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Added the following settings under the `Plugin Settings->Rewards`, `Tank #->Rewards`, and `STEAM_ID->Rewards` sections:
	- `Prefs Notify` (Requested by `Mi.Cura`.)
	- `Teammate Limit` (Requested by `Mi.Cura`.)
	- `Light Color Visual` (Thanks to `DonProof` for the idea!)
- Added support for `8+` players for the `Death Details` setting's messages.
- Added a fourth parameter to all of the `Reward` system's settings. (Requested by `Mi.Cura`.)
- Removed the `Reward Priority` setting. (No longer used.)
- Added the `Colors` section under the `Plugin Settings` section which allows to create color presets.
- The following settings can now accept color presets from the new `Colors` section:
	- `Body Color Visual`
	- `Glow Color Visual`
	- `Light Color Visual`
	- `Screen Color Visual`
	- `Skin Color`
	- `Glow Color`
	- `Light Color`
	- `Oxygen Tank Color`
	- `Flame Color`
	- `Rock Color`
	- `Tire Color`
	- `Propane Tank Color`
	- `Flashlight Color`
	- `Crown Color`
- The following settings can now accept the `rainbow` keyword to cycle through each color (Thanks to `Pelipoika` for the code and `DonProof` for the idea!):
	- `Body Color Visual`
	- `Glow Color Visual`
	- `Light Color Visual`
	- `Screen Color Visual`
	- `Skin Color`
	- `Glow Color`
	- `Oxygen Tank Color`
	- `Flame Color`
	- `Rock Color`
	- `Tire Color`
	- `Propane Tank Color`
	- `Flashlight Color`
- Updated the `Stack Rewards` setting to accept different values.
- Updated the `Reward Visual` setting's options.
</details>
<details>
	<summary>Translations</summary>

#### Translations
- Updated English translations with new phrases.
- Updated Simplified Chinese translations with a new phrase.
- Updated Hungarian translations with a new phrase.
- Updated Russian translations with a new phrase.
</details>
<details>
	<summary>Natives & Forwards</summary>

#### Natives & Forwards
- Updated the documentation for the `MT_OnRewardSurvivor` forward.
- Added the `MT_GetConfigColors` native.
- Updated the following natives to support the new `rainbow` color feature:
	- `MT_GetTankColors`
	- `MT_GetPropColors`
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Medic: The `Medic Field Color` setting can now accept color presets from the new `Colors` section.
- Shield
	- The `Shield Color` setting can now accept color presets from the new `Colors` section.
	- The `Shield Color` setting can now accept the `rainbow` keyword to cycle through each color. (Thanks to `Pelipoika` for the code and `DonProof` for the idea!)
</details>

### Files
<details>
	<summary>Updates</summary>

#### Updates
- Updated config files.
- Updated gamedata file.
- Updated include files.
- Updated translation files.
</details>
</details>

## Version 8.84 (June 1, 2021)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>General</summary>

#### General
- Fixed chat, log, and server messages from Mutant Tanks not supporting enough characters.
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Fixed some developer tools not disabling themselves properly.
- Fixed the `Reward` system creating multiple effects per player and using wrong durations.
- Fixed the positioning of the Tank's light props.
- Fixed the difficulty config files using the wrong letter case. (Thanks to `Shadowart` for testing and reporting!)
- Fixed survivors with the ammo reward getting the incorrect ammo count in some cases.
- Fixed the health reward's life leech option not setting the correct amount of temporary health.
- Fixed the Tank spawner calling unnecessary functions when spawning non-Mutant Tanks.
- Fixed the developer tool panel not being deleted right away.
- Fixed thirdperson checks not working reliably.
</details>
<details>
	<summary>Natives & Forwards</summary>

#### Natives & Forwards
- Fixed the `MT_LogMessage` native logging messages even when the feature is disabled.
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Idle: Fixed the ability requiring `DHooks`.
- Kamikaze: Fixed survivor death models being removed on player spawn. (Thanks to `AlexAlcala` for reporting and `Lux` for the help!)
- Medic: Fixed the ability requiring an incapacitation check for special infected. (Thanks to `ddd123` for reporting!)
- Necro: Fixed the ability attempting to respawn special infected too late. (Thanks to `ddd123` for reporting!)
- Respawn: Fixed the ability requiring `DHooks`.
- Rocket: Fixed survivor death models being removed on player spawn. (Thanks to `AlexAlcala` for reporting and `Lux` for the help!)
- Smash: Fixed survivor death models being removed on player spawn. (Thanks to `AlexAlcala` for reporting and `Lux` for the help!)
- Smite: Fixed survivor death models being removed on player spawn. (Thanks to `AlexAlcala` for reporting and `Lux` for the help!)
</details>

### Changes
<details>
	<summary>General</summary>

#### General
- Mutant Tanks and its sub-plugins can be used in `SM 1.10`. `SourceMod 1.11.0.6511` or higher is only required when compiling the plugins. (Thanks to `Shadowart` for pointing this out!)
- Each ability's plugin is now a component that must be compiled through a main plugin.
- Optionally, each ability's plugin can still be compiled as a standalone plugin.
- Added listen server support for all commands provided by Mutant Tanks. (Thanks to `Marttt` for the code!)
- Reduced the number of electric particles attached to players to avoid lag.
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Added strict checking for hooking/unhooking events. (Thanks to `Shadowart` for reporting!)
- Updated the logic for checking which game modes to enable/disable the plugin on. (Thanks to `Shadowart` for reporting!)
- Added a `Tank #-1` option to the `sm_tank`/`sm_mt_tank` menu. (Thanks to `jeremyvillanueva` for the idea!)
- Added the `sm_mt_prefs` command for players to change their reward visual settings.
- Improved the `Reward` system's messages.
- Rewards can now be stacked.
</details>
<details>
	<summary>Commands</summary>

#### Commands
- Replaced all the `sm_mt_<ability name>` commands with `sm_mt_ability <name>`/`sm_mt_ability2 <name>`.
- The old commands are still available when compiling the abilities using the alternative method.
</details>
<details>
	<summary>ConVars</summary>

#### ConVars
- Added the `mt_listensupport` convar.
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Added the following settings under the `Plugin Settings->Rewards`, `Tank #->Rewards`, and `STEAM_ID->Rewards` sections:
	- `Reward Notify`
	- `Reward Priority`
	- `Reward Visual` (Requested by `3aljiyavslgazana`.)
	- `Body Color Visual` (Requested by `3aljiyavslgazana`.)
	- `Glow Color Visual` (Requested by `3aljiyavslgazana`.)
	- `Looping Voiceline Visual` (Requested by `3aljiyavslgazana`.)
	- `Particle Effect Visual` (Requested by `3aljiyavslgazana`.)
	- `Screen Color Visual` (Requested by `3aljiyavslgazana`.)
	- `Infinite Ammo Reward`
	- `Stack Rewards`
- Added the `Death Details` setting under the `Plugin Settings->Announcements`, `Tank #->Announcements`, and `STEAM_ID->Announcements` sections. (Requested by `Shadowart`.)
- Added the following settings under the `Plugin Settings->Enhancements`, `Tank #->Enhancements`, and `STEAM_ID->Enhancements` sections:
	- `Punch Throw` (Thanks to `ConnerRia` for the code!)
	- `Skip Taunt` (Thanks to `Lux` for the code!)
	- `Sweep Fist` (Thanks to `HarryPotter` for the idea!)
- Renamed the `Detect Plugins` setting under the `Plugin Settings->General`, `Tank #->General`, and `STEAM_ID->General` sections to `Check Abilities`.
- Increased the size of buffers for convar changes under the `Plugin Settings->ConVars` section.
- Added the `Listen Support` setting under the `Plugin Settings->General` section.
</details>
<details>
	<summary>Translations</summary>

#### Translations
- Updated English translations with new phrases.
- Updated Simplified Chinese translations with new phrases. (Thanks to `yuzumi`!)
- Updated Hungarian translations with new phrases. (Thanks to `KasperH`/`Ladis`!)
- Updated Russian translations with new phrases. (Thanks to `Blueberry`/`Kleiner`!)
</details>
<details>
	<summary>Natives & Forwards</summary>

#### Natives & Forwards
- Added backwards compatibility for the old `MT_CloneAllowed` native.
- Changed how parameters are passed to the following forwards:
	- `MT_OnAbilityCheck`
	- `MT_OnPluginCheck`
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Item
	- Added the `Item Pinata` setting.
	- Added the `Item Pinata Body` setting.
	- Added the `Item Pinata Chance` setting.
- Slow: Added the `Slow Incline` setting.
</details>

### Files
<details>
	<summary>Additions</summary>

#### Additions
- Added the `mt_abilities` plugin file which combines the first `38` abilities (A-L).
- Added the `mt_abilities2` plugin file which combines the second `38` abilities (M-Z).
</details>
<details>
	<summary>Locations</summary>

#### Locations
- Each ability's plugin must now be placed in the `scripting/mutant_tanks/abilities` (A-L) and `scripting/mutant_tanks/abilities2` (M-Z) folders.
</details>
<details>
	<summary>Requirements</summary>

#### Requirements
- The `mt_clone.inc` file is now only used by the core plugin and registered by either the new `mt_abilities` source file or the pre-existing `mt_clone` source file.
</details>
<details>
	<summary>Updates</summary>

#### Updates
- Updated config files.
- Updated gamedata file.
- Updated include files.
- Updated translation files.
</details>
</details>

## Version 8.83 (March 31, 2021)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>General</summary>

#### General
- Fixed Common infected developing wounds from blocked friendly-fire. (Thanks to `Marttt` for the code!)
- Fixed Tanks spawned from the `sm_tank`/`sm_mt_tank` menu raising the wave count when they die.
- Fixed clones, respawned Tanks, randomized Tanks, and Tanks spawned through the Mutant Tanks menu not being exempted from the `Type Limit` setting.
- Fixed game modes not being detected properly.
- Fixed some models, sounds, and particles precaching in the wrong game.
- Fixed Tank deaths raising the wave count while there are still other Tanks alive. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Fixed each Tank death raising the wave count. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Fixed AI Tanks in ghost mode not forcefully spawning. (Thanks to `yuzumi` for reporting!)
- Fixed Tank rocks breaking before leaving the Tank's hands. (Thanks to `weffer` for reporting!)
- Fixed the errors regarding Tank props. (Thanks to `ur5efj` for reporting!)
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Fixed the `sm_mutanttank` command not being accessible to non-admin Tanks. (Thanks to `yuzumi` for reporting!)
- Fixed the Mutant Tank type selection menu not appearing for human-controlled Tanks in competitive modes. (Thanks to `yuzumi` for reporting!)
- Fixed Tanks not setting up properly when exiting ghost mode. (Thanks to `yuzumi` for reporting!)
- Fixed Tank arrivals being announced when they are in ghost mode.
- Fixed the Tank spawner not allowing multiple copies of the same Mutant Tank type to spawn.
- Fixed inconsistent access levels for some developer commands.
- Fixed survivors with the godmode reward not being saved from special infected when given the health or refill reward.
- Fixed survivors with the godmode reward surviving underwater. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Fixed the `Boss` feature not calculating the Tank's total health properly.
- Fixed the `Reward` system notifying recipients twice when they do not do enough damage to Tanks. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Fixed the `Reward` system not detecting recipients' incapacitation/black and white counter after using `give health`. (Thanks to `Silvers` for the code!)
- Fixed damage toward Common infected and Witches not being hooked on late loads.
- Fixed props not attaching to Tanks properly.
</details>
<details>
	<summary>Game Data</summary>

#### Game Data
- Fixed some detours causing crashes due to having different argument names from other plugins. (Thanks to `3aljiyavslgazana` for testing and reporting!)
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Fixed the `Boss Health Stages` setting not being read entirely.
- Fixed the `Item Reward` setting not being read properly. (Thanks to `3aljiyavslgazana` for testing and reporting!)
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Absorb: Fixed all types of fire damage not being detected.
- Bury
	- Fixed survivors not being revived when receiving the godmode reward.
	- Fixed survivors not being healed when receiving the health or refill reward. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Choke
	- Fixed choked survivors not always lifting off the ground while being choked. (Thanks to `3aljiyavslgazana` and `Mi.Cura` for testing and reporting!)
	- Fixed choked survivors being stuck under the floor when the ability ends.
- Clone: Fixed clone deaths raising the wave count. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Drop: Fixed weapons not attaching properly.
- Fragile: Fixed all types of fire damage not being detected. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- God: Fixed Tanks not extinguishing from fires while the ability is activated. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Heal
	- Fixed players with the godmode reward being affected.
	- Fixed total health being miscalculated.
	- Fixed Tanks gaining health while in the dying animation.
	- Fixed all types of fire damage not being detected.
- Hit: Fixed the ability not working when the `Human Ability` setting is disabled.
- Hypno: Fixed all types of fire damage not being detected.
- Kamikaze: Fixed players with the godmode reward being affected. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Laser: Fixed the ability always targeting the first player that joined the server.
- Leech
	- Fixed total health being miscalculated.
	- Fixed Tanks gaining health while in the dying animation.
- Medic
	- Fixed total health being miscalculated.
	- Fixed Tanks gaining health while in the dying animation.
	- Fixed the `Medic Health` and `Medic Max Health` settings not being read entirely. (Thanks to `TheStarRocker` for testing and reporting!)
- Pyro: Fixed all types of fire damage not being detected.
- Recoil: Fixed the ability affecting all weapons instead of just guns.
- Regen
	- Fixed total health being miscalculated.
	- Fixed Tanks gaining health while in the dying animation.
- Respawn: Fixed Tanks not respawning when dying as a different type. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Restart: Fixed players with the godmode reward being affected.
- Rocket: Fixed players with the godmode reward being affected. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Shield: Fixed all types of fire damage not being detected.
- Smash: Fixed players with the godmode reward being affected. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Smite: Fixed players with the godmode reward being affected. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Ultimate
	- Fixed total health being miscalculated.
	- Fixed Tanks gaining health while in the dying animation.
- Undead
	- Fixed total health being miscalculated.
	- Fixed Tanks gaining health while in the dying animation.
- Vampire
	- Fixed total health being miscalculated.
	- Fixed Tanks gaining health while in the dying animation.
- Xiphos
	- Fixed total health being miscalculated.
	- Fixed Tanks gaining health while in the dying animation.
	- Fixed all types of fire damage not being detected.
- Yell: Fixed the errors regarding the sound hook. (Thanks to `ur5efj` for reporting!)
- Zombie: Fixed the ability trying to spawn Uncommon infected on L4D1.
</details>

### Changes
<details>
	<summary>General</summary>

#### General
- Changed the method for checking idle Tanks. (Thanks to `BHaType` for the code and `epzminion` for the help!)
- The hidden `z_burn_max` convar will no longer be automatically set to `1.0` while Mutant Tanks is running. (Use the new `Plugin Settings->ConVars` section to modify the convar setting instead.)
- Added extra failsafe checks to make sure offsets are retrieved properly before executing relevant code. (Thanks to `yuzumi` for the idea!)
- Added a command listener to intercept the `vocalize` and `go_away_from_keyboard` commands and block them when the player is no longer on the server.
- `Left 4 DHooks` is now optional again.
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Increased the height of the shockwave effect during boss transformations. (Requested by `3aljiyavslgazana`.)
- Added extra copies of the `Body Effects` setting's electric jolt option.
- Added a slime trail coming out of the Tank's mouth as part of the `Body Effects` setting's acid trail option.
- Increased verbosity of logging for admin commands.
- The vocalizer feature for Tank deaths now requires the `Vocalize Death` setting to be enabled.
- Changed the method for logging the admin commands. (Thanks to `Mi.Cura` for the idea!)
- Rewards that have a duration can now have their duration extended when received again. (Requested by `3aljiyavslgazana`.)
- The health display will no longer show the maximum health going over the value set in `mutant_tanks.inc`.
- The `Boss` feature's evolution now triggers a slow-motion effect for almost a second.
- The melee immunity feature's pushback effect has less magnitude and radius when triggered by recipients of the godmode reward. (Requested by `3aljiyavslgazana`.)
- The `Reward` system now validates all reward settings before applying them to recipients.
- Added the `sm_mt_dev` command for developer use.
- Decreased the delay for custom configs from `3` to `1.5` seconds.
- The health reward now does the following:
	- Gives the recipient more health when revived.
	- Allows the recipient to heal their target back to max health.
	- Slowly regenerates the player's health back to full health.
	- Allows the recipient to leech health off enemies per hit.
- The ammo reward now does the following:
	- Extends the recipient's max weapon clip and magazine sizes up to at least twice the default amount.
	- Gives the recipient one of the special ammo (incendiary or explosive).
	- Slowly regenerates the player's ammo back to full capacity.
- The speed boost reward now does the following:
	- Gives the recipient extra jump height. (Thanks to `epzminion` for the help!)
	- Blocks fall damage for the recipient within a certain height limit (`900` HMU). (Thanks to `epzminion` for the code!)
	- Use a different voiceline when falling.
	- Blocks the deathfall camera for the recipient. (Thanks to `epzminion` for the help!)
	- Gives the recipient the adrenaline effect until the reward ends. (Exclusive to L4D2.) [Thanks to `Lux` for the code!]
- The damage boost reward now does the following:
	- Allows the recipient to bypass all types of damage immunity that Tanks may have throughout its duration. (Requested by `3aljiyavslgazana`.)
	- Gives the recipient damage resistance throughout its duration.
	- Gives the recipient extended melee range. (Thanks to `epzminion` for the idea and `Silvers` for the code!)
	- Gives the recipient hollowpoint ammo which atomizes Common infected and Witches. (Thanks to `epzminion` for the code!)
	- Gives the recipient sledgehammer rounds which knock back special infected and has a `1%-10%` chance to knock back Tanks. (Thanks to `epzminion` for the code!)
	- Allows the recipient to deal damage to attackers for each hit taken. (Thanks to `epzminion` for the help!)
	- Allows the recipient to instantly kill Witches (limited uses). (Thanks to `epzminion` for the idea!)
- The godmode reward now does the following:
	- Automatically kills any special infected that attacks the recipient throughout its duration. (Thanks to `3aljiyavslgazana` for suggesting!)
	- Fully blocks all damage from registering. (Requested by `3aljiyavslgazana`.)
	- Blocks Boomer pukes on the recipient. (Thanks to `3aljiyavslgazana` for the idea and `epzminion` for the help and `Silvers` for the signatures!]
	- Automatically removes the Boomer puke screen effect. (Requested by `3aljiyavslgazana`.) [Thanks to `Silvers` for the signatures!]
	- Reduces the pushback force from Tank punches. (Requested by `3aljiyavslgazana`.) [Thanks to `Silvers` for the code and signatures!]
	- Prevents the recipient from getting flung away by Chargers.
	- Prevents the recipient from getting staggered.
	- Blocks Smoker clouds, Boomer explosions, and Spitter acid puddles when they die (clean kills). (Thanks to `epzminion` for the help!)
- The respawn reward no longer resets the recipient's stats. (Thanks to `Dragokas` for the code and gamedata info!)
- Added a `Tank #0` option to the `sm_tank`/`sm_mt_tank` menu.
</details>
<details>
	<summary>Game Data</summary>

#### Game Data
- Renamed all detour arguments to be consistent and compatible with `Left 4 Fix`'s and `Left 4 DHooks`' detours.
- Updated several signatures for detours. (Thanks to `epzminion` for the help!)
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Added the `Log Commands` setting under the `Plugin Settings->General` section. (Requested by `3aljiyavslgazana`.)
- Added the following settings under the `Plugin Settings->Announcements`, `Tank #->Announcements`, and `STEAM_ID->Announcements` sections:
	- `Arrival Sound` (Thanks to `Tank Rush` for the idea!)
	- `Death Sound` (Thanks to `Tank Rush` for the idea!)
	- `Vocalize Arrival`
	- `Vocalize Death`
- Added the `Enhancements` and `Immunities` sections under the `Plugin Settings` section for global use.
- The following settings now accept a value of `0` (standard Tanks) [Thanks to `Tonblader` for the idea!]:
	- `Type Range`
	- `Regular Type`
	- `Finale Types`
- Added the `Spawn Limit` setting under the `Plugin Settings->General` section. (Requested by `Tonblader`.)
- Added the `Survival Delay` setting under the `Plugin Settings->Competitive` section. (Requested by `Tonblader`.)
- Added the following new options for the `Reward Enabled` setting:
	- `Attack boost reward` (Requested by `3aljiyavslgazana`.) [Requires `WeaponHandling API`.]
	- `Infinite ammo reward` (Thanks to `epzminion` for helping!)
- The `Stasis Mode` setting now works in all game mode types. (Requested by `yuzumi`.)
- Added the `Game Type` setting under the `Tank #->General` sections.
- Added the following settings under the `Plugin Settings->Rewards`, `Tank #->Rewards`, and `STEAM_ID->Rewards` sections:
	- `Reward Bots` (Thanks to `Mi.Cura` for the idea!)
	- `Reward Effect` (Requested by `3aljiyavslgazana`.) [Thanks to `Silvers` for the code!]
	- `Attack Boost Reward` (Requested by `3aljiyavslgazana`.) [Requires `WeaponHandling API`.]
	- `Action Duration Reward` (Thanks to `epzminion` for the help!)
	- `Ammo Boost Reward` (Thanks to `epzminion` for the help!)
	- `Ammo Regen Reward`
	- `Clean Kills Reward` (Thanks to `epzminion` for the help!)
	- `Damage Resistance Reward`
	- `Fall Voiceline Reward` (Thanks to `epzminion` for the help!)
	- `Heal Percent Reward` (Thanks to `epzminion` for the help!)
	- `Health Regen Reward` (Thanks to `Silvers` for the code!)
	- `Hollowpoint Ammo Reward` (Thanks to `epzminion` for the code!)
	- `Jump Height Reward` (Thanks to `epzminion` for the help!)
	- `Lady Killer Reward` (Thanks to `epzminion` for the idea!)
	- `Life Leech Reward` (Thanks to `epzminion` for the idea!)
	- `Melee Range Reward` (Thanks to `epzminion` for the idea and `Silvers` for the code!)
	- `Punch Resistance Reward` (Thanks to `Silvers` for the code!)
	- `Revive Health Reward` (Thanks to `epzminion` for the help!)
	- `Shove Damage Reward` (Thanks to `epzminion` for the idea!)
	- `Shove Penalty Reward` (Thanks to `3aljiyavslgazana` for the idea!)
	- `Shove Rate Reward` (Thanks to `epzminion` for the help!)
	- `Sledgehammer Rounds Reward` (Thanks to `epzminion` for the code!)
	- `Special Ammo Reward` (Exclusive to L4D2.)
	- `Thorns Reward` (Thanks to `epzminion` for the idea!)
- Added the `Burn Duration` setting under the `Plugin Settings->General`, `Tank #->General`, and `STEAM_ID->General` sections. (Requested by `TheStarRocker`.) [Thanks to `Silvers` for the code!]
- Added the `ConVars` section under the `Plugin Settings` section which allows to change convar settings. (Requested by `TheStarRocker`.)
- Added the following settings under the `Plugin Settings->General` section for global use (Requested by `Maku`.):
	- `Tank Enabled`
	- `Spawn Enabled`
- Changed the minimum value of the `Tank Enabled` setting under the `Tank #->General` section from `0` to `-1`.
- Changed the minimum value of the following settings under the `Plugin Settings->Rewards`, `Tank #->Rewards`, `STEAM_ID->Rewards` sections from `1.1` to `0.0`:
	- `Damage Boost Reward`
	- `Speed Boost Reward`
- Added the following keywords for the `Tank Enabled` and `Spawn Enabled` settings:
	- `ignore`/`exclude`/`filter`/`remove` - `-1`
- Added the `Vomit Immunity` setting under the `Tank #->Immunities` and `STEAM_ID->Immunities` sections. (Thanks to `epzminion` for the help, `Marttt` for the idea, and `Silvers` for the signatures!)
- Added the `Punch Force` setting under the `Tank #->Enhancements` and `STEAM_ID->Enhancements` sections. (Thanks to `3aljiyavslgazana` for the idea and `Silvers` for the code and signatures!)
- Added the following keywords for the `Punch Force` setting:
	- `nodmg`/`friendly`/`harmless` - `0.0` force
	- `weakest` - `1.0` force
	- `strongest` - `999999.0` force
- Added the `Force Spawn` setting under the `Plugin Settings->Competitive` section. (Requested by `yuzumi`.)
- The following settings under the `Plugin Settings` section can now be used on standard Tanks (Requested by `Shadowart`.):
	- `Finales Only`
	- `Idle Check`
	- `Idle Check Mode`
	- `Tank Model`
	- `Burn Duration`
	- `Burnt Skin`
	- `Announce Arrival`
	- `Announce Death`
	- `Announce Kill`
	- `Arrival Message`
	- `Arrival Sound`
	- `Death Message`
	- `Death Sound`
	- `Kill Message`
	- `Vocalize Arrival`
	- `Vocalize Death`
	- `Reward Enabled`
	- `Reward Bots`
	- `Reward Effect`
	- `Reward Chance`
	- `Reward Duration`
	- `Reward Percentage`
	- `Action Duration Reward`
	- `Ammo Boost Reward`
	- `Ammo Regen Reward`
	- `Attack Boost Reward`
	- `Clean Kills Reward`
	- `Damage Boost Reward`
	- `Damage Resistance Reward`
	- `Fall Voiceline Reward`
	- `Heal Percent Reward`
	- `Health Regen Reward`
	- `Hollowpoint Ammo Reward`
	- `Item Reward`
	- `Jump Height Reward`
	- `Lady Killer Reward`
	- `Life Leech Reward`
	- `Melee Range Reward`
	- `Punch Resistance Reward`
	- `Respawn Loadout Reward`
	- `Revive Health Reward`
	- `Shove Damage Reward`
	- `Shove Penalty Reward`
	- `Shove Rate Reward`
	- `Sledgehammer Rounds Reward`
	- `Special Ammo Reward`
	- `Speed Boost Reward`
	- `Thorns Reward`
	- `Useful Rewards`
	- `Aggressive Tanks`
	- `Credit Igniters`
	- `Stasis Mode`
	- `Base Health`
	- `Display Health`
	- `Display Health Type`
	- `Extra Health`
	- `Health Characters`
	- `Minimum Humans`
	- `Multiply Health`
	- `Attack Interval`
	- `Claw Damage`
	- `Hittable Damage`
	- `Rock Damage`
	- `Run Speed`
	- `Throw Interval`
	- `Bullet Immunity`
	- `Explosive Immunity`
	- `Fire Immunity`
	- `Hittable Immunity`
	- `Melee Immunity`
	- `Vomit Immunity`
</details>
<details>
	<summary>Translations</summary>

#### Translations
- Updated English translations.
- Updated Simplified Chinese translations. (Thanks to `yuzumi`!)
- Updated Hungarian translations. (Thanks to `KasperH`/`Ladis`!)
- Updated Russian translations. (Thanks to `Blueberry`/`Kleiner`!)
- Moved the `Tank # Name`, `Tank #`, `STEAM_ID Name`, and `STEAM_ID` phrases to the `mutant_tanks_names.phrases.txt` file. (Requested by `yuzumi`.)
</details>
<details>
	<summary>Natives & Forwards</summary>

#### Natives & Forwards
- Updated the `MT_OnRewardSurvivor` forward.
- Added the `MT_OnFatalFalling` forward.
- Added the `MT_OnPlayerEventKilled` forward.
- Added the `MT_OnPlayerHitByVomitJar` forward.
- Added the `MT_OnPlayerShovedBySurvivor` forward.
- Added the `MT_RespawnSurvivor` native.
- Added the `MT_ShoveBySurvivor` native.
- Added the `MT_VomitPlayer` native.
- Added the `MT_UnvomitPlayer` native.
- Added the `MT_DoesSurvivorHaveRewardType` native.
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Absorb
	- The pushback effect no longer triggers for melee attacks unless the Tank takes at least one damage. (Requested by `3aljiyavslgazana`.)
	- The pushback effect has less magnitude and radius when triggered by recipients of the godmode reward. (Requested by `3aljiyavslgazana`.)
	- Added the `Absorb Hittable Divisor` setting.
	- Any damage below `1` dealt to Tanks with this ability activated will automatically round up to `1`.
- Acid: The ability is now exclusive to L4D2.
- Aimless: Survivors with the godmode reward are no longer affected. (Requested by `3aljiyavslgazana`.)
- Ammo: Survivors with no ammunition are no longer affected.
- Bury
	- Survivors with the godmode reward are no longer affected. (Requested by `3aljiyavslgazana`.)
	- Buried survivors can no longer attack, shove, or use/grab items. (Requested by `3aljiyavslgazana`.)
- Choke
	- Incapacitated or ledge-hanging survivors are no longer affected. (Requested by `3aljiyavslgazana`.)
	- Survivors with the godmode reward are no longer affected. (Requested by `3aljiyavslgazana`.)
	- The ability automatically ends when the targeted survivor becomes incapacitated. (Requested by `3aljiyavslgazana`.)
	- Choked survivors can no longer attack, shove, or use/grab items. (Requested by `3aljiyavslgazana`.)
	- Blocked survivors from taking non-fatal fall damage after the ability ends.
	- Removed the `Choke Height` setting.
- Clone
	- Clones no longer reward survivors after dying. (Thanks to `3aljiyavslgazana` for the idea!)
	- Clones no longer trigger announcements when spawning and dying. (Thanks to `3aljiyavslgazana` for the idea!)
	- Clones are removed when their Tank owner changes its Mutant Tank type if the `Clone Remove` setting is enabled. (Thanks to `3aljiyavslgazana` for suggesting!)
- Fling
	- Survivors with the godmode reward are no longer affected. (Requested by `3aljiyavslgazana`.)
	- The ability is now exclusive to L4D2.
- Fragile
	- Added the `Fragile Hittable Multiplier` setting.
	- Tank now have a `15%` chance of being knocked back when shoved by recipients of the attack boost reward. (Thanks to `3aljiyavslgazana` for suggesting!)
- God
	- The pushback effect has less magnitude and radius when triggered by recipients of the godmode reward. (Requested by `3aljiyavslgazana`.)
	- Tanks with this ability activated are no longer affected by bile bombs unless the thrower has the damage boost reward. (Requested by `3aljiyavslgazana`.)
- Gravity: Survivors with the speed boost reward are no longer affected by the hit and range attacks. (Requested by `3aljiyavslgazana`.)
- Hit: Survivors with the damage boost reward are no longer affected. (Requested by `3aljiyavslgazana`.)
- Hypno
	- The pushback effect has less magnitude and radius when triggered by recipients of the godmode reward. (Requested by `3aljiyavslgazana`.)
	- Added the `Hypno Hittable Divisor` setting.
	- Any damage below `1` dealt to Tanks with this ability activated will automatically round up to `1`.
- Idle
	- Ledge-hanging survivors are no longer affected. (Requested by `3aljiyavslgazana`.)
	- Survivors with the godmode reward are no longer affected. (Requested by `3aljiyavslgazana`.)
	- Removed idle fix code. (Use [`Lux's` "Survivor_AFK_Fix" plugin](https://forums.alliedmods.net/showthread.php?t=326742) instead.)
- Minion: Minions are removed when their Tank owner changes its Mutant Tank type if the `Minion Remove` setting is enabled. (Thanks to `3aljiyavslgazana` for suggesting!)
- Nullify: The pushback effect has less magnitude and radius when triggered by recipients of the godmode reward. (Requested by `3aljiyavslgazana`.)
- Pimp: Survivors with the godmode reward are no longer affected. (Requested by `3aljiyavslgazana`.)
- Puke
	- Survivors with the godmode reward are no longer affected. (Requested by `3aljiyavslgazana`.)
	- Added a Boomer puke fountain-like visual effect for the range and upon-death abilities. (Requested by `3aljiyavslgazana`.) [Thanks to `Marttt` for the code!]
- Respawn
	- Replaced the detour for the `CTerrorPlayer::Event_Killed` function with the new `MT_OnPlayerEventKilled` forward.
	- Tanks that respawn no longer give out rewards until their final deaths. (Thanks to `3aljiyavslgazana` for suggesting!)
- Restart: Respawned survivors no longer have their stats reset. (Thanks to `Dragokas` for the code and gamedata info!)
- Shield
	- The damage boost reward now allows the recipient to bypass all types of shields that Tanks may have throughout its duration. (Requested by `3aljiyavslgazana`.)
	- Shields that can be damaged by melee weapons will no longer create pushback effects when hit by melee weapons. (Requested by `3aljiyavslgazana`.)
	- The pushback effect has less magnitude and radius when triggered by recipients of the godmode reward. (Requested by `3aljiyavslgazana`.)
	- Tanks are immune to bile bombs while the shield is active. (Requested by `3aljiyavslgazana`.)
- Shove: Survivors with the godmode reward are no longer affected. (Requested by `3aljiyavslgazana`.)
- Slow: Survivors with the speed boost reward are no longer affected. (Requested by `3aljiyavslgazana`.)
- Throw
	- Thrown special infected are removed when their Tank owner changes its Mutant Tank type if the `Throw Infected Remove` setting is enabled. (Thanks to `3aljiyavslgazana` for suggesting!)
	- Thrown Witches are removed when their Tank owner changes its Mutant Tank type if the `Throw Witch Remove` setting is enabled. (Thanks to `3aljiyavslgazana` for suggesting!)
- Ultimate: The pushback effect has less magnitude and radius when triggered by recipients of the godmode reward. (Requested by `3aljiyavslgazana`.)
- Vision
	- Ledge-hanging survivors are no longer affected. (Requested by `3aljiyavslgazana`.)
	- Survivors with the godmode reward are no longer affected. (Requested by `3aljiyavslgazana`.)
- Warp: Incapacitated or ledge-hanging survivors are no longer affected by the hit and range attacks. (Requested by `3aljiyavslgazana`.)
- Whirl
	- Ledge-hanging survivors are no longer affected. (Requested by `3aljiyavslgazana`.)
	- Survivors with the godmode reward are no longer affected. (Requested by `3aljiyavslgazana`.)
- Witch: Witches are removed when their Tank owner changes its Mutant Tank type if the `Witch Remove` setting is enabled. (Thanks to `3aljiyavslgazana` for suggesting!)
- Xiphos: Any damage below `1` dealt to Tanks with this ability activated will automatically round up to `1`.
- Yell
	- Survivors with the godmode reward are no longer affected. (Requested by `3aljiyavslgazana`.)
	- The ability no longer blocks player sounds when active.
</details>

### Files
<details>
	<summary>Requirements</summary>

#### Requirements
- The `mutant_tanks_names.phrases` translation file is now used by all the plugins.
- The `mutant_tanks_patches.cfg` config file is now used by the core plugin.
</details>
<details>
	<summary>Updates</summary>

#### Updates
- Updated config files.
- Updated gamedata file.
- Updated include file.
- Updated translation files.
</details>
</details>

## Version 8.82 (January 25, 2021)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>General</summary>

#### General
- Fixed melee damage being counted as burn damage in certain cases.
- Fixed friendly-fire burn damage not being blocked. (Thanks to `3aljiyavslgazana` for reporting!)
- Fixed some menus allowing unauthorized access to the admin menu.
- Fixed Tanks automatically having burnt skin when being extinguished.
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Fixed the `sm_mt_mutanttank` command being available to non-Tank players.
- Fixed players being pushed back when shooting at Tanks with bullet immunity.
</details>
<details>
	<summary>Config Files</summary>

#### Config Files
- Fixed grouped sections and the `all` section not being read properly.
- Fixed disabled Mutant Tank types not having their settings read.
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Fixed the `Tank Model` setting's third option using the L4D2 model instead of the L4D1 model.
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Shield: Fixed Tanks taking fire damage in certain cases while shield is up. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Throw: Fixed the `Ability Enabled` setting not being checked properly for human-controlled Tanks.
</details>

### Changes
<details>
	<summary>General</summary>

#### General
- Added chat notifications for all admin commands. (Thanks to `Mi.Cura` for the idea!)
- Added logging for all admin commands. (Thanks to `Mi.Cura` for the idea!)
- The hidden `z_burn_max` convar will now be automatically set to `1.0` while Mutant Tanks is running.
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Restricted the following commands to admins with `z` (Root) flag:
	- `sm_mt_config`
	- `sm_mt_list`
	- `sm_mt_tank2`/`sm_tank2`
	- `sm_mt_version`
- Renamed the `mt_admin` override command to `mt_adminversus` for clarity.
- The following commands are now available only to the developer for testing purposes:
	- `sm_mt_config2` - Same function as `sm_mt_config`
	- `sm_mt_list2` - Same function as `sm_mt_list`
	- `sm_mt_tank2`/`sm_tank2` - Same function as `sm_mt_tank`/`sm_tank`
	- `sm_mt_version2` - Same function as `sm_mt_version`
- The `sm_mt_config`/`sm_mt_config2` command's menu now displays the names of Mutant Tank types. 
- Players will now be informed if they do not do enough damage to Tanks to earn rewards.
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Added the `Burnt Skin` setting under the `Plugin Settings->General`, `Tank #->General`, and `STEAM_ID->General` sections. (Thanks to `Marttt` for the code!)
- Changed the minimum value of the `Attack Interval` setting from `-1.0` to `0.0`.
- Changed the minimum value of the `Run Speed` setting from `-1.0` to `0.0`.
- Changed the minimum value of the `Throw Interval` setting from `-1.0` to `0.0`.
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Car: Added the `Car Owner` setting. (Requested by `3aljiyavslgazana`.)
- Throw: Added the `Throw Car Owner` setting. (Requested by `3aljiyavslgazana`.)
- Warp: Tanks can no longer teleport to survivors who are inside saferooms or spawn areas. (Requested by `3aljiyavslgazana`.)
</details>

### Files
<details>
	<summary>Updates</summary>

#### Updates
- Updated config files.
- Updated gamedata file.
- Updated include file.
- Updated translation files.
</details>
</details>

## Version 8.81 (January 20, 2021)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Abilities</summary>

#### Abilities
- Meteor: Fixed the random crashes caused when rocks explode. (Thanks to `3aljiyavslgazana`, `Mi.Cura`, and `Maku` for reporting!)
- Shield: Fixed the Tank throwing gas cans or propane tanks even when the `Shield Type` setting is not blast-based nor fire-based. (Thanks to `Mi.Cura` for letting me test on his servers!)
</details>

### Changes
<details>
	<summary>General</summary>

#### General
- Increased maximum Tank health from `65,535` to `1,000,000`. (Might cause bugs with other plugins and game stats when set higher than `65,535`.) [Thanks to `3aljiyavslgazana` for suggesting!]
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Added a pushback effect when players use their melee weapons against Tanks with melee immunity. (Thanks to `Marttt` for suggesting!)
- All admin menu items provided by Mutant Tanks will now return to the admin menu when appropriate. (Thanks to `Marttt` for suggesting!)
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Added the `Hittable Damage` setting under the `Tank #->Enhancements` and `STEAM_ID->Enhancements` sections. (Thanks to `Marttt` for the code!)
- Added the `Credit Igniters` setting under the `Plugin Settings->Competitive` section. (Thanks to `axelnieves2012` for the code!)
- Added the `Hittable Immunity` setting under the `Tank #->Immunities` and `STEAM_ID->Immunities` sections. (Thanks to `Marttt` for the code!)
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Absorb: Added a pushback effect when players use their melee weapons against Tanks with melee absorption.
- Car: All cars are now owned by Tanks. (Requested by `Marttt`.)
- God: Added a pushback effect when players use their melee weapons against Tanks with godmode.
- Hypno: Added a pushback effect when players use their melee weapons against Tanks while hypnotized.
- Nullify: Added a pushback effect when players use their melee weapons against Tanks while nullified.
- Shield: Added a pushback effect when players use their melee weapons against Tanks with shields.
- Throw: All cars are now owned by Tanks. (Requested by `Marttt`.)
- Ultimate: Added a pushback effect when players use their melee weapons against Tanks with godmode.
</details>

### Files
<details>
	<summary>Updates</summary>

#### Updates
- Updated config files.
- Updated include file.
</details>
</details>

## Version 8.80 (December 31, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>General</summary>

#### General
- Fixed some potential errors caused by invalid weapon slots.
- Fixed the SourceMod admin menu plugin not being optional.
- Fixed rare cases where non-Mutant Tanks are counted as Mutant Tanks.
- Fixed Tank rocks not breaking when hitting special and Common infected.
- Fixed the strong wind sound caused by Tank rock debris. (Thanks to `Dragokas` for the code!)
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Fixed log files being created even when the `Log Messages` setting is disabled. (Thanks to `KasperH`/`Ladis` for reporting!)
- Fixed some waves being skipped. (Thanks to `Tank Rush` for testing and reporting!)
- Fixed the glow outline not going away when Tanks are kicked.
- Fixed the Tank wave spawner not respecting the limits set by the `Regular Amount`, `Finale Amount`, and `Finale Waves` settings.
- Fixed some admin commands using the wrong access flags.
- Fixed parenting problems with some entities.
- Fixed Tanks in ghost or stasis mode having props and particle effects.
- Fixed the log messages causing errors for some server messages.
- Fixed the Tank's primary attack being blocked by the friendly-fire check.
- Fixed some cases where Tanks do not have props in thirdperson.
- Fixed some cases where props appear even when Tanks are in firstperson.
- Fixed the blur effect prop not deleting itself. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Fixed the blur effect prop not using the Tank's model.
- Fixed the `Boss` feature not carrying over bosses' stats to their evolution stages.
- Fixed the `Randomization` feature only changing the Tank once.
- Fixed the `Transformation` feature disabling itself after the first transformation ends. (Thanks to `Mi.Cura` for testing and reporting!)
- Fixed Tank spawns exceeding the limits set by the `Finale Amount`, `Finale Waves`, and `Regular Amount` settings.
</details>
<details>
	<summary>Config Files</summary>

#### Config Files
- Fixed the config parser storing previous values.
- Fixed the config parser not reading config files properly.
- Fixed the config parser not reading the settings of disabled types.
</details>
<details>
	<summary>Settings</summary>

#### Settings
- Fixed the `Requires Humans` setting not working in some config formats.
- Fixed the `Requires Humans` setting not working when deciding which Mutant Tank type to spawn.
- Fixed settings not having their values stored properly.
- Fixed color-related settings from not picking random colors when set to `-1`.
- Fixed the `Light Color` setting not working.
- Fixed the `Regular Amount` setting being used on finale maps when the finale has not started.
- Fixed the `Detect Plugins` setting not working when zero abilities are installed.
- Fixed the `Rock Damage` setting under the `Enhancements` section affecting rocks thrown by the `Rock` and `Spam` abilities. (Thanks to `3aljiyavslgazana` for testing and reporting!)
</details>
<details>
	<summary>Translations</summary>

#### Translations
- Fixed global chat messages not being translated. (Thanks to `Mi.Cura` for testing and reporting!)
- Fixed some phrases not being translated for other languages.
</details>
<details>
	<summary>Natives & Forwards</summary>

#### Natives & Forwards
- Fixed the `MT_GetPropColors` native not returning the right color for the light prop.
- Fixed the `MT_SetTankType` native not reverting changes properly in some scenarios. (Thanks to `Mi.Cura` for testing and reporting!)
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Fixed some abilities calling `DispatchSpawn` on entities before teleporting them.
- Fixed Tanks not activating their passive abilities after exiting idle mode.
- Fixed some abilities' damage settings not working properly.
- Fixed some messages for all abilities appearing when their `Human Mode` settings are set to `1`.
- Fixed all abilities not resetting when the Tank is passed between two players.
- Fixed some settings of multiple abilities having the wrong limits.
- Fixed abilities activating when the Tank is dying, which caused the Tank to be stuck in a looped dying animation.
- Absorb: Fixed the ability bypassing damage immunity settings. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Blind
	- Fixed the ability being enabled by default. (Thanks to `Mi.Cura` and `Tank Rush` for reporting!)
	- Fixed the sound effect not playing in L4D1 due to the file not existing.
- Bomb: Fixed the sound effect not playing in L4D1 due to the file not existing.
- Bury
	- Fixed players being left under the map. (Thanks to `Mi.Cura` for testing and reporting!)
	- Fixed players keeping their original velocity after being teleported.
- Car: Fixed cars giving players accelerated velocity when standing on them.
- Choke: Fixed survivors being launched too high up into the air regardless of the `Choke Height` setting's value.
- Clone
	- Fixed clones spawning uncontrollably. (Thanks to `3aljiyavslgazana` for testing and reporting!)
	- Fixed clones being detected by the `Finale Amount` and `Finale Waves` settings.
	- Fixed clones not being replaced when they have a different Mutant Tank type from the Tank. (Thanks to `3aljiyavslgazana` for testing and reporting!)
	- Fixed rare cases where Mutant Tanks are counted as clones. (Thanks to `Mi.Cura` for testing and reporting!)
	- Fixed clone count not supporting kicked clones.
	- Fixed the ability not being optional.
- Drug: Fixed the ability not requiring human survivors to be present by default.
- Drunk: Fixed the ability requiring human survivors to be present by default.
- Drop
	- Fixed the `Drop Weapon Name` setting not reading weapon names properly. (Thanks to `Tank Rush` and `moekai` for testing and reporting!)
	- Fixed weapons attached to Tanks not disappearing on mission loss or round restart.
- Electric
	- Fixed the ability not working sometimes. (Thanks to `Tank Rush` and `Mi.Cura` for testing and reporting!)
- Enforce: Fixed errors related to enforced weapon slots having invalid weapons.
- Fire: Fixed the sound effect not playing in L4D1 due to the file not existing.
- Fragile: Fixed the ability bypassing damage immunity settings. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Ghost
	- Fixed the range ability checking for the wrong ammo count.
	- Fixed special infected remaining transparent after the Tank dies.
	- Fixed client index errors. (Thanks to `Mi.Cura` for reporting!)
- Gravity: Fixed the range ability checking for the wrong ammo count.
- Heal
	- Fixed the glow outline not going away when Tanks die.
	- Fixed glow outlines not applying/resetting properly.
	- Fixed the range ability checking for the wrong ammo count.
- Hit: Fixed some of the settings not working in some config formats.
- Hypno: Fixed survivors taking too much damage when the Tank is incapacitated while survivors are still hypnotized.
- Jump: Fixed the range ability checking for the wrong ammo count.
- Meteor: Fixed the `Meteor Damage` setting not working properly. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Minion
	- Fixed minions being replaced even when the `Minion Replace` setting is set to `0`.
	- Fixed minion count not supporting kicked minions.
- Omni: Fixed type changes not being tracked properly. (Thanks to `Mi.Cura` for testing and reporting!)
- Panic: Fixed panic events not being called on L4D1.
- Respawn: Fixed the Tank not respawning consistently. (Thanks to `epzminion` for the method!)
- Rock
	- Fixed the rocks colliding with each other and producing lag.
	- Fixed the `Rock Damage` setting not working properly. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Shake: Fixed one of the messages using the wrong format specifier. (Thanks to `Mi.Cura` for reporting!)
- Shield
	- Fixed shields not disappearing on mission loss or round restart.
	- Fixed propane tanks and gas cans not having velocity when thrown.
- Spam
	- Fixed the rocks colliding with each other and producing lag.
	- Fixed the `Spam Damage` setting not working properly.
- Splatter: Fixed the `Splatter Type` setting using the wrong value limit. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Throw
	- Fixed cars giving players accelerated velocity when standing on them.
	- Fixed cars not having velocity when thrown. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Track
	- Fixed the glow outline not going away when rocks break.
	- Fixed glow outlines not applying/resetting properly.
- Warp
	- Fixed the range ability checking for the wrong ammo count.
	- Fixed players keeping their original velocity after teleporting.
- Witch
	- Fixed messages being spammed.
	- Fixed witches not dealing any damage to survivors. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Vampire: Fixed admin immunity not being checked properly.
- Xiphos
	- Fixed survivors receiving full health per hit.
	- Fixed survivors receiving health while Tank is in dying animation.
- Yell: Fixed messages providing the wrong information. (Thanks to `Mi.Cura` for reporting!)
</details>

### Changes
<details>
	<summary>General</summary>

#### General
- Provided full support for competitive game modes. (Thanks to `What` for bringing up the subject!)
- Decreased Mutant Tank type limit back to `500`.
- All Tank rocks affected by Mutant Tanks are now destroyed properly. (Thanks to `Luckylock` for the code!)
</details>
<details>
	<summary>Core Plugin</summary>

#### Core Plugin
- Added command aliases for `sm_tank` and `sm_tank2`.
- Increased the delay between each Tank wave in finales from `3` to `5` seconds.
- The regular waves spawner now has a delay and starts after a survivor has left the saferoom. (Requested by `Tank Rush`.)
- The core plugin now requires `DHooks 2.2.0-detours15` or higher.
- The arrival of Mutant Tanks is no longer announced when they are idle. Instead, the arrival is announced once the survivors trigger the Mutant Tank.
- Added better friendly-fire check for all abilities. (Thanks to `Silvers` for the code!)
- Human-controlled Tanks now keep the same Mutant Tank type between passes.
- Mutant Tank stats are now properly copied when passing Tanks between players.
- Added sound effects for bullet and melee immunities.
- Added the `sm_mt_reload` command to let admins reload all config files.
- Added the following target filters to let admins target Mutant Tanks:
	- `@mutants`
	- `@mtanks`
	- `@psytanks`
- Tanks will no longer activate their passive abilities on finale maps once the rescue vehicle leaves.
- Idle Tanks will no longer glow through walls even when the `Glow Type` setting is set to `1`.
- Idle Tanks will no longer turn into different types when the `Spawn Type` setting is set to `1`, `2`, or `3`.
- Changed the method for checking whether or not abilities are installed.
- The `Boss` feature now has new effects when evolving. (Thanks to `3aljiyavslgazana` for suggesting!)
- Tanks that use the `Randomization` feature no longer turn into Mutant Tank types that cannot spawn.
- AI Tanks that are kicked are now flagged as "dead" Tanks.
- Added the `mt_adminmenu` override to let users restrict the `MutantTanks` category in the admin menu to certain admin flags/groups.
</details>
<details>
	<summary>Config Files</summary>

#### Config Files
- Enabled the `Requires Humans` setting for some of the default Mutant Tank types.
- Config files now support multiple abilities using comma separation.
- The `all` section can now be grouped with multiple types and abilities in config files.
- Updated some of the default Mutant Tank types.
- Added two more default Mutant Tank types: `Trap Tank` and `Drug Addict Tank`
- Added the following keywords for toggle settings:
	- `enabled`/`true`/`on`/`yes` - `1`
	- `disabled`/`false`/`off`/`no` - `0`
- Added the following keywords for chance settings:
	- `never` - `0%` chance
	- `sometimes`/`unlikely`/`seldom` - `33.3%` chance
	- `maybe` - `50%` chance
	- `often`/`likely`/`frequently` - `66.6%` chance
	- `always` - `100%` chance
- Added the following keywords for damage settings:
	- `nodmg`/`friendly`/`harmless` - `0.0` damage
	- `weakest` - `1.0` damage
	- `strongest` - `999999.0` damage
- Added the following keywords for cooldown, delay, duration, interval, and lifetime settings:
	- `never`/`disabled`/`false`/`off`/`no` - `0` seconds
	- `milli`/`millisecond` - `0.1` seconds
	- `second` - `1` second
	- `minute` - `1` minute
	- `forever` - `999999` minutes
- Added the following keywords for height settings:
	- `shortest` - `0.1` height
	- `tallest` - `999999.0` height
- Added the following keywords for `Open Areas Only` settings:
	- `disabled`/`false`/`off`/`no` - `0.0` range
	- `farthest` - `999999.0` range
- Added the following keywords for range settings:
	- `closest` - `1.0` range
	- `farthest` - `999999.0` range
- Added the following keywords for hit mode settings:
	- `both`/`all` - `0`
	- `tank`/`attack` - `1`
	- `survivor`/`hurt` - `2`
- Added the following keywords for `Ability Effect` settings:
	- `none`/`off` - `0`
	- `attack` - `1`
	- `hurt` - `2`
	- `attack,hurt` - `3`
	- `range` - `4`
	- `attack,range` - `5`
	- `hurt,range` - `6`
	- `attack,hurt,range`/`all` - `7`
- Added the following keywords for `Ability Message` settings:
	- `none`/`off` - `0`
	- `hit` - `1`
	- `ability` - `2`
	- `both`/`all`/`hit,ability` - `3`
	- `rock` - `4`
	- `hit,rock` - `5`
	- `ability,rock` - `6`
	- `hit,ability,rock`/`all` - `7`
- Added the following keywords for `Human Ammo` settings:
	- `none`/`off` - `0` ammo
	- `infinite` - `999999` ammo
- Added the `default` keyword for each setting to force the default value set by Mutant Tanks.
- Added the `min` keyword for each setting to force the minimum value set by Mutant Tanks.
- Added the `max` keyword for each setting to force the maximum value set by Mutant Tanks.
</details>
<details>
	<summary>Settings</summary>

#### Settings
- The `Finale Waves` and `Finale Types` settings now support up to `10` waves. (Thanks to `3aljiyavslgazana` for testing and reporting!)
- Added a new option for the `Announce Death` setting.
- Changed the default value of the `Regular Limit` setting from `2` to `999999`.
- Changed the default value of the `Death Revert` setting under the `Plugin Settings->General` from `0` to `1`.
- Added the `Attack Interval` setting under the `Tank #->Enhancements` and `STEAM_ID->Enhancements` sections. (Thanks to `epzminion` for the code!)
- Added the `Regular Delay` setting under the `Plugin Settings->Waves` section. (Requested by `Tank Rush`.)
- Removed the `Rename Players` setting. (Too many bugs with special characters in people's names.)
- Added the `Extras Delay` settings under `Plugin Settings->Waves` section.
- Added the `Open Areas Only` setting to determine which types or abilities are only for open areas.
- Added the `Flashlight` and `Crown` options for the `Props Attached` setting.
- Added the `Flashlight Color` setting under the `Tank #->Props` and `STEAM_ID->Props` sections. (Thanks to `Ernecio` for the code!)
- Added the `Crown Color` setting under the `Tank #->Props` and `STEAM_ID->Props` sections. (Thanks to `Ernecio` for the code!)
- The `Props Chance` setting now accepts two extra values to support the `Flashlight` and `Crown` props.
- Added the `Aggressive Tanks` and `Stasis Mode` settings under the `Plugin Settings->Competitive` section.
- Added the `Scale Damage` and `Difficulty Damage` settings under the `Plugin Settings->Difficulty` section.
- Moved the following settings to the `Tank #->Glow` and `STEAM_ID->Glow` sections:
	- `Glow Enabled`
	- `Glow Color`
	- `Glow Flashing`
	- `Glow Range`
	- `Glow Type`
- Added a new option for the `Spawn Mode` setting under the `Tank #->Spawn` section.
- Added the following settings under the new `Tank #->Combo` and `STEAM_ID->Combo` sections. (Thanks to `3aljiyavslgazana` for suggesting!)
	- `Combo Chance`
	- `Combo Damage`
	- `Combo Death Chance`
	- `Combo Death Range`
	- `Combo Delay`
	- `Combo Duration`
	- `Combo Interval`
	- `Combo Radius`
	- `Combo Range`
	- `Combo Range Chance`
	- `Combo Rock Chance`
	- `Combo Set`
	- `Combo Speed`
	- `Combo Type Chance`
- Moved the following settings to the `Tank #->Boss` and `STEAM_ID->Boss` sections:
	- `Boss Health Stages`
	- `Boss Stages`
	- `Boss Types`
- Moved the following settings to the `Tank #->Random` and `STEAM_ID->Random` sections:
	- `Random Tank`
	- `Random Interval`
- Moved the following settings to the `Tank #->Transform` and `STEAM_ID->Transform` sections:
	- `Transform Delay`
	- `Transform Duration`
	- `Transform Types`
- Added the `Random Duration` setting under the `Tank #->Random` and `STEAM_ID->Random` sections.
- Renamed the `Spawn Mode` setting under the `Tank #->Spawn` section to `Spawn Type`.
- The `Spawn Type` setting under the `Tank #->Spawn` section can now be overridden for each player.
- Added a `Reward` system for fighting Mutant Tanks.
- Added the following settings under the `Plugin Settings->Rewards`, `Tank #->Rewards`, and `STEAM_ID->Rewards` sections:
	- `Reward Enabled`
	- `Reward Chance`
	- `Reward Duration`
	- `Reward Percentage`
	- `Damage Boost Reward`
	- `Item Reward`
	- `Respawn Loadout Reward`
	- `Speed Boost Reward`
	- `Useful Rewards`
- Moved the following settings to the `Plugin Settings->Announcements`, `Tank #->Announcements`, and `STEAM_ID->Announcements` sections:
	- `Announce Arrival`
	- `Announce Death`
- Added the following settings under the `Plugin Settings->Announcements`, `Tank #->Announcements`, and `STEAM_ID->Announcements` sections:
	- `Announce Kill`
	- `Arrival Message`
	- `Death Message`
	- `Kill Message`
- The `Base Health` setting can now be overridden for each type and player.
- The `Extra Health` setting can now be used globally for all types.
- The `Requires Humans` setting can no longer be overridden for each player.
- Added the `Limit Extras` setting under the `Plugin Settings->Waves` section.
- Added `Survivor count (Humans only)` as an option for the `Create Config Types` and `Execute Config Types` settings.
- Added `Infected count (Humans only)` as an option for the `Create Config Types` and `Execute Config Types` settings.
- Added the `Tank Model` setting under the `Plugin Settings->General`, `Tank #->General`, and `STEAM_ID->General` sections. (Thanks to `Marttt` for the code!)
- Several color settings' default values have been changed from `-1` to `255`.
- Added different developer tools for testing.
- Changed the default value of the `Allow Developer` setting from `1` to `0`.
</details>
<details>
	<summary>Translations</summary>

#### Translations
- The `Tank Name` setting can now be translated in the translation file by creating a `Tank # Name` section for each type or `STEAM_ID Name` section for each player. (Requested by `Mi.Cura`.)
- All logs generated by Mutant Tanks and its modules are now translated to use the server's language.
- Updated English translations.
- Updated Simplified Chinese translations.
- Updated Hungarian translations. (Thanks to `KasperH`/`Ladis`!)
- Added Russian translations. (Thanks to `Blueberry`/`Kleiner`!)
- Divided the translations into separate files. (Requested by `Blueberry`/`Kleiner`.)
</details>
<details>
	<summary>Natives & Forwards</summary>

#### Natives & Forwards
- Added the `MT_IsTankClone` native to allow developers to check if a Tank is a clone.
- Added the `MT_IsCustomTankSupported` native to allow developers to check if a Tank clone is able to use abilities like real Mutant Tanks.
- Added the `MT_GetScaledDamage` native to allow developers to get the proper scaled damage of Mutant Tanks.
- Added the `MT_GetGlowRange`, `MT_GetGlowType`, and `MT_IsGlowFlashing` natives to allow developers to retrieve the glow outline settings for Mutant Tanks.
- Added the `MT_OnCopyStats` forward to allow developers to properly copy over active Tank stats when Tanks are passed around in competitive game modes.
- Added the `MT_OnCombineAbilities` forward to allow developers to combine certain abilities.
- Added the `MT_GetCombinationSetting` native to allow developers to retrieve values for combined abilities.
- Added the `MT_GetSpawnType` native to allow developers to check what spawn type a Mutant Tank has.
- Added the `MT_TankMaxHealth` native to allow developers to get/set the Tank's max health.
- Added the `MT_OnRewardSurvivor` forward to allow developers to give custom rewards to survivors.
- Added the `MT_DetonateTankRock` native to allow developers to manually detonate Tank rocks.
- The `MT_OnChangeType` forward now has two more parameters.
- Updated all natives to have self-contained validity checks.
</details>
<details>
	<summary>Abilities</summary>

#### Abilities
- Enabled the `Requires Humans` setting for some more abilities by default.
- Added the `Fly` ability. (Thanks to `Ernecio` for the code!)
- Added the `Lightning` ability which is exclusive to L4D2.
- None of the abilities' plugins need to check if the `Clone` ability is installed anymore.
- Added the `Combo Ability` setting for each ability.
- Absorb
	- Added the `Immunity Flags` setting.
	- Changed the minimum value of the divisor settings from `0.1` to `1.0`.
	- Divisor settings will not take effect unless their values are greater than `1.0`.
- Blind: Added a sound effect for L4D1.
- Bomb: Added a sound effect for L4D1.
- Bury
	- Added the `Bury Buffer` setting. (Requested by `Mi.Cura`.)
	- Incapacitated or ledge-hanging survivors are no longer affected.
	- The ability no longer requires `Left 4 DHooks`.
- Car
	- Added the `Car Interval` setting.
	- Added the `Car Lifetime` setting.
- Choke: Changed the default value of the `Choke Height` setting from `300.0` to `200.0`.
- Clone
	- The `Clone Type` setting now takes in a type range. Example: `1-10` (Requested by `Neptunia`.)
	- Added the `Clone Remove` setting.
	- Added the `Clone Lifetime` setting. (Requested by `3aljiyavslgazana`.)
	- AI clones are now killed instead of kicked when the plugin is unloaded.
	- The `Clone Health` setting will now always determine clones' health. (Requested by `3aljiyavslgazana`.)
- Drop
	- Dropped weapons now have normal size. (Requested by `3aljiyavslgazana`.)
	- Weapons attached to Tanks are now affected by the `Ghost` ability's fade feature. (Requested by `3aljiyavslgazana`.)
- Fire: Added a sound effect for L4D1.
- Fling: Incapacitated or ledge-hanging survivors are no longer affected. (Requested by `3aljiyavslgazana`.)
- Fragile
	- Added the `Immunity Flags` setting.
	- Multiplier settings will not take effect unless their values are greater than `1.0`.
- Ghost
	- Rocks thrown by Tanks are now affected by the fade feature. (Requested by `3aljiyavslgazana`.)
	- Incapacitated or ledge-hanging survivors are no longer affected.
	- Special infected affected by the fade feature are now reverted back to normal upon death. (Requested by `3aljiyavslgazana`.)
- God: Added the `Immunity Flags` setting.
- Heal
	- Changed the default value of the `Heal Buffer` setting from `25.0` to `100.0`.
	- The ability now contributes to the Tank's overall health.
- Hypno
	- Updated method for hurting teammates to bypass plugins that block friendly-fire.
	- Incapacitated or ledge-hanging survivors are no longer affected.
	- Changed the minimum value of the divisor settings from `0.1` to `1.0`.
	- Divisor settings will not take effect unless their values are greater than `1.0`.
- Ice: Ledge-hanging survivors are no longer affected. (Requested by `3aljiyavslgazana`.)
- Idle
	- Applied a new idle fix method. (Thanks to `Lux` for the code!)
	- The ability now requires `DHooks`.
- Kamikaze: Added the `Kamikaze Body` setting.
- Leech: The ability now contributes to the Tank's overall health.
- Medic
	- Added the `Medic Field` and `Medic Field Color` settings. (Thanks to `Marttt` and `Silvers` for the code!)
	- The `Ability Enabled` setting now only has two options instead of four.
	- Modified all of the messages.
	- The ability now contributes to the Tank's overall health.
- Meteor
	- Added the `Meteor Interval` setting.
	- Added the `Meteor Lifetime` setting.
	- Added extra checks for tracking meteorites.
- Minion
	- Added the `Minion Remove` setting.
	- Added the `Minion Lifetime` setting.
	- AI minions are now killed instead of kicked when the plugin is unloaded.
- Nullify: Added a sound effect.
- Pyro: Added the `Pyro Reignite` setting.
- Regen: The ability now contributes to the Tank's overall health.
- Respawn
	- The `Respawn Type` setting now takes in a type range. Example: `1-10` (Requested by `Neptunia`.)
	- The ability now requires `DHooks`.
- Restart: The ability no longer requires `Left 4 DHooks`.
- Rock
	- Added the `Immunity Flags` setting.
	- Added the `Rock Interval` setting.
- Rocket: Added the `Rocket Body` setting.
- Shield
	- Added the `Shield Glow` setting.
	- The `Shield Type` setting now allows combinations of options.
	- Added the `Shield Throw Chance` setting.
	- Human-controlled Tanks are now put into thirdperson for `1.5` seconds after toggling the shield.
	- Added a sound effect.
- Shove: Incapacitated or ledge-hanging survivors are no longer affected.
- Smash: Added the `Smash Body` setting.
- Smite: Added the `Smite Body` setting.
- Spam
	- Added the `Immunity Flags` setting.
	- Added the `Spam Interval` setting.
- Throw
	- Added the `Immunity Flags` setting.
	- Added the `Throw Car Lifetime` setting.
	- Added the `Throw Infected Amount` setting.
	- Added the `Throw Infected Lifetime` setting.
	- Added the `Throw Infected Remove` setting.
	- Added the `Throw Witch Amount` setting.
	- Added the `Throw Witch Damage` setting.
	- Added the `Throw Witch Lifetime` setting.
	- Added the `Throw Witch Remove` setting.
	- Thrown Witches now use default speed when set on fire. (Requested by `3aljiyavslgazana`.)
- Track: Added the `Track Glow` setting.
- Ultimate
	- The ability now contributes to the Tank's overall health.
	- Added a sound effect.
	- Added the `Ultimate Chance` setting.
- Undead: The ability now contributes to the Tank's overall health.
- Vampire: The ability now contributes to the Tank's overall health.
- Witch
	- Added the `Witch Remove` setting.
	- Added the `Witch Lifetime` setting.
- Xiphos
	- The ability now contributes to the Tank's overall health.
	- The `Ability Message` setting now has an extra option.
	- Survivors now only get a portion of their damage against the Tank as health.
	- Incapacitated or ledge-hanging survivors are no longer affected.
- Yell
	- The ability now runs repeatedly while activated when `Human Mode` is set to `1`.
	- The ability no longer requires `Left 4 DHooks`.
- Zombie
	- Added the `Zombie Mode` setting.
	- Added the `Zombie Type` setting.
</details>

### Files
<details>
	<summary>Requirements</summary>

#### Requirements
- The `mt_clone` include file is now only used by the core plugin and the `Clone` ability.
</details>
<details>
	<summary>Updates</summary>

#### Updates
- Updated config files.
- Updated gamedata file.
- Updated include files.
- Updated translation files.
</details>
</details>

## Version 8.79 (October 10, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the core plugin creating the wrong folder for finale stage configs.
2. Fixed the `sm_mt_config` command causing errors when multiple players are using it.
3. Fixed the `Game Mode Types` setting and `mt_gamemodetypes` convar causing errors when set to anything higher than `0`. (Thanks to `KasperH`/`Ladis` for testing and reporting!)
4. Fixed the idle check for Tanks not detecting every type of idle mode.
5. Fixed some abilities' range attacks not working due to admin access.
6. Fixed client index errors for the `Zombie` ability.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. The `sm_mt_config` now allows users to choose from a list of config file paths.
2. Only one player may use the `sm_mt_config` command at a time to avoid spamming and overlapping parses.
3. Each config file that is executed by the core plugin can now be viewed by players.
4. Each config file path provided by the `sm_mt_config` command now generates its own list of section names available in its corresponding config file.
5. Added new options for the `Warp` ability's `Warp Mode` setting.
6. Added the `MT_OnResetTimers` forward to allow developers to reset repeating timers with intervals set by config files.
7. The timer for spawning Tanks periodically on non-finale maps now resets when `Regular Interval` is changed. (Thanks to `Tank Rush` for testing!)
8. Added the `Splatter` ability which is exclusive to L4D2. (Requested by `Tank Rush` and thanks to `Silvers` for the code.)
9. Added two new default Mutant Tanks in the config file to showcase the `Splatter` ability.
10. All the default Mutant Tanks that come with the main config file are now off by default. Users can enable them as needed.
11. `DHooks` and `Left 4 DHooks` are now mandatory.
12. The core plugin now constantly checks if Tanks are idle or not moving (no action). Use the `Idle Check` setting to determine the interval between each check.
13. Added the `Idle Check Mode` setting under the `Plugin Settings->General` section.
14. Changed the default value of the `Idle Check` setting from `0.0` to `10.0`.
15. Changed the default value of the `Props Attached` setting from `126` to `78` for L4D1 to disable huge props.
16. Changed the default value of the `Detect Plugins` setting from `0` to `1`.
17. The `Regular Amount` setting now works without the `Regular Mode` setting being set to `1`.
18. The `Bury` ability's plugin (`mt_bury.smx`) now uses `Left 4 DHooks` to revive survivors.
19. The `Yell` ability's plugin (`mt_yell.smx`) now uses `Left 4 DHooks` to deafen survivors.
20. Updated the `MT_IsTankIdle` native with an extra parameter to determine what idle mode to check for.
21. Global chat messages and server messages generated by Mutant Tanks can now be logged.
22. Added the `Log Messages` setting to allow different types of messages to be logged.
23. Added the `MT_OnLogMessage` forward to allow developers to intercept the logging feature.
24. Added the `MT_LogMessage` native to allow developers to log messages.
25. Added the `Requires Humans` setting to filter out certain types and abilities from being used when there are zero human survivors present.
26. Added the `MT_DoesTypeRequireHumans` native to allow developers to check if a certain type requires human survivors to be present.
27. Config files now support multiple Mutant Tank types using comma separation.
28. Raised the limit from `16` to `32` for the following settings (Requested by `Tank Rush`.):
- `Regular Amount`
- `Finale Amount`
- `Finale Waves`
- `Type Limit`
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config file.
2. Updated gamedata file.
3. Updated include file.
4. Updated translation file.
</details>
</details>

## Version 8.78 (October 2, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Fast`, `Ghost`, and `Item` abilities' settings not being read when using one of the other config formats.
2. Fixed props not showing up on Tanks sometimes regardless of settings. (Thanks to `Mi.Cura` for reporting!)
3. Fixed the `Drop` ability not creating nor dropping any weapons.
4. Fixed difficulty configs not updating their file time changes when the `z_difficulty` setting is updated.
5. Fixed the maximum value of the `Finales Only` and `Finale Tank` settings. (Thanks to `Tank Rush` for testing!)
6. Fixed the main config overlapping the custom configs by adding a `3`-second delay. (Thanks to `Tank Rush` for testing!)
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added the `Drop Weapon Name` setting for the `Drop` ability. (Requested by `Tank Rush`.)
2. The `Drop` ability now supports the two new melee weapons from `The Last Stand` update.
3. Changed the minimum value of the `Drop` ability's `Drop Weapon Scale` from `1.0` to `0.1`.
4. Set a fixed default size (`1.5`) for weapons attached to Tanks by the `Drop` ability.
5. Added the `Idle Check` setting under the `Plugin Settings->General` section.
6. Added the `MT_IsTankIdle` native which allows developers to check if a Tank is idle.
7. Idle Tanks will no longer activate their passive abilities.
8. Moved the following settings to the `Plugin Settings->Health` section:
- `Base Health`
- `Display Health`
- `Display Health Type`
- `Health Characters`
- `Minimum Humans`
- `Multiply Health`
9. Moved the following settings to the `Tank #->Health` and `STEAM_ID->Health` sections:
- `Display Health`
- `Display Health Type`
- `Extra Health`
- `Health Characters`
- `Minimum Humans`
- `Multiply Health`
10. Added `Finale stages` as an option for the `Create Config Types` and `Execute Config Types` settings.
11. The core plugin will no longer work if the main config file does not exist.
12. Custom config files are no longer executed if they do not exist.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config file.
2. Updated gamedata file.
3. Updated include file.
4. Updated translation file.
</details>
</details>

## Version 8.77 (September 11, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed some messages not converting chat color placeholders properly.
2. Fixed an invalid entity index error for the `Ammo` ability. (Thanks to `ur5efj` for reporting!)
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added multi-lingual support for all messages provided by Mutant Tanks. (Requested by `yuzumi`.)
2. Added Simplified Chinese translations. (Thanks to `yuzumi`!)
3. Added the `MT_OnMenuItemDisplayed` forward to allow developers to translate menu items.
4. Added the `Minimum Humans` setting to determine how many human survivors must be present before `Multiply Health` can take effect. (Thanks to `SilentBr` for suggesting!)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config files.
2. Updated include file.
3. Updated translation file.
</details>
</details>

## Version 8.76 (August 1, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed client index errors for the `Track` ability. (Thanks to `AK978` and `Mi.Cura` for reporting!)
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added the `Finale Amount` setting to limit the number of Tanks during finales regardless of the current wave. (Requested by `Neptunia`.)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config files.
2. Updated include file.
3. Updated translation file.
</details>
</details>

## Version 8.75 (July 5, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Drunk`, `Gravity`, and `Slow` abilities not resetting survivors speed/gravity to default (`1.0`). (Thanks to `Mi.Cura` for reporting!)
2. Fixed the `Regular Wave` setting taking effect even when `Regular Mode` is set to `0`. (Thanks to `Mi.Cura` for reporting!)
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added a `StopSound` check for the Tank's rocks to get rid of the loud wind sound. (Thanks to `Electr000999` for suggesting!)
2. More code optimizations.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.74 (June 24, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Finale Types` setting being read incorrectly. (Thanks to `Neptunia` for reporting!)
2. Fixed non-finale Tanks spawning on finale waves. (Thanks to `Neptunia` for reporting!)
3. Fixed the finale waves not resetting on mission lost. (Thanks to `Neptunia` for reporting!)
4. Fixed errors regarding detours. (Thanks to `Voevoda` for reporting and to `Silvers` for helping me figure out the cause!)
5. Fixed the `Finale Waves` and `Regular Wave` settings having the wrong default values.
6. Fixed the `MT_IsNonFinaleType` native not being optional.
7. Fixed several upon-death abilities not working. (Thanks to `ben12398` for reporting!)
8. Fixed the regular wave spawner not working when the `Regular Amount` setting is off. (Thanks to `ben12398` for reporting!)
9. Fixed the `Cloud` ability spamming too many clouds. (Thanks to `Mi.Cura` for reporting!)
10. Fixed the `Omni` ability not inheriting other Mutant Tank types' abilities when `Omni Mode` is set to `0`. (Thanks to `Mi.Cura` for reporting!)
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. `DHooks` is now optional. (Still required when compiling/using the plugin and its modules with `Left 4 DHooks`.)
2. Rewrote and improved the code for the finale waves and regular wave spawners.
3. All settings are now automatically re-cached after changing a Tank's type with the `MT_SetTankType` native.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.73 (June 11, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed buttons being auto-released when human-controlled Tanks activate their abilities. (Thanks to `Voevoda` for reporting!)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.72 (June 10, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed human players not turning into Mutant Tanks due to a cache fail. (Thanks to `Voevoda` for reporting!)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.71 (June 10, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the Tank's health status not showing up when using `Display Health` and `Display Health Type`. (Thanks to `Mi.Cura` for reporting!)
2. Fixed the plugin and its modules still not working when either the `Enabled Game Modes` or `Disabled Game Modes` setting is specified. (Thanks to `Voevoda` for reporting!)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.70 (June 10, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `NoItems` phrase not displaying properly. (Thanks to `ben12398` for reporting!)
2. Fixed some menus returning `0` items once finales have started. (Thanks to `ben12398` for reporting!)
3. Fixed non-finale Mutant Tank types being disabled once finales have started even when `Finale Tank` is set to 0. (Thanks to `ben12398` and `Mi.Cura` for reporting!)
4. Fixed the `Clone` ability preventing clones with different types from using their assigned/native abilities. (Thanks to `ben12398` for reporting!)
5. Fixed the `Cloud` ability's clouds not disappearing after a short period of time. (Thanks to `Mi.Cura` for reporting!)
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. The `Shield` ability's shield can now start out with health. (Requested by `Neptunia`.)
2. Added the following settings for the `Shield` Ability:
- `Shield Display Health`
- `Shield Display Health Type`
- `Shield Health`
- `Shield Health Characters`
3. Added more options to the `Finales Only` and `Finale Tank` settings.
4. Added an extra layer of security to the `Clone Type` and `Respawn Type` settings to make sure that users do not cause all kinds of bugs when choosing other types that also have the `Clone` or `Respawn` ability like their respective owners.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config files.
2. Updated include file.
3. Updated translation file.
</details>
</details>

## Version 8.69 (June 5, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the Tank's healthbar not updating properly. (Thanks to `Neptunia` and `Mi.Cura` for reporting!)
2. Fixed AI Tanks not being renamed due to the `Rename Players` setting not exempting bots. (Thanks to `Mi.Cura` for reporting!)
3. Fixed the plugin and its modules not working when either the `Enabled Game Modes` or `Disabled Game Modes` setting is specified. (Thanks to `Voevoda` for reporting!)
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Removed the `Respawn Mode` setting and updated the `Respawn Type` setting for the `Respawn` ability.
2. Added the `Clone Type` setting for the `Clone` ability. (Requested by `Neptunia`.)
3. More code optimizations.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config files.
2. Updated gamedata file.
3. Updated include file.
</details>
</details>

## Version 8.68 (June 1, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed more invalid handle errors. (Thanks to `user2000` and `MedicDTI` for reporting!)
2. Fixed the `bIsHumanSurvivor` stock not automatically checking with the `MT_CHECK_FAKECLIENT` flag.
3. Fixed some settings not being read by the config parser when their values are empty.
4. Fixed disabled Tanks spawning no matter what. (Thanks to `Mi.Cura` for reporting!)
5. Fixed admin access and immunity errors. (Thanks to `MedicDTI` for reporting!)
6. Fixed the `Native not bound` error for the `Restart` ability. (Thanks to `MedicDTI` for reporting!)
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
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

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
13. Added the `Regular Limit` setting under the `Waves` section to limit how many waves of Tanks are spawned on non-finale maps. (Requested by `RDiver`.)
14. Added extra checks for several abilities to avoid client index errors.
15. Moved the `Human Support` setting to its own section:
- `Tank #->General` to `Tank #->Human Support`
- `STEAM_ID->General` to `STEAM_ID->Human Support`
16. Added the `Rename Players` setting under the following sections:
- `Plugin Settings->Human Support`
- `Tank #->Human Support`
- `STEAM_ID->Human Support`
17. Replaced all cooldown timers by tracking `GetTime` instead.
18. Replaced all `GetEngineTime` instances with `GetTime` for more accuracy.
19. `RequestFrame` is now used instead of `0.1`-second timers.
20. The cooldowns for some abilities now start when the abilities end, not when they activate.
21. Added sound effects for the `Absorb`, `Blind`, `Bomb`, `Fire`, `God`, `Gravity`, `Hurt`, `Shake`, and `Slow` abilities. (Requested by `Tank Rush`.)
22. Added the `sm_mt_version` command which allows users to check the current version in-game.
23. Added backwards compatibility for old natives.
24. Updated/removed several phrases for each ability.
25. Moved all redundant code to the core plugin's include file for universal usage.
26. Changed how the administration system works. (Please read the `Administration System` section of the `README` file.)
27. Optimized the code of all the plugins included.
28. Added Hungarian translations. (Thanks to `KasperH`/`Ladis`!)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config files.
2. Updated gamedata file.
3. Updated include files.
4. Updated translation file.
</details>
</details>

## Version 8.67 (May 10, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed all abilities potentially not resetting when a Tank leaves the server.
2. Fixed invalid handle errors.
3. Fixed parsing failure errors.
4. Fixed several abilities not working for AI Tanks when `Human Ammo` is set to `0`.
5. Fixed more possible client index errors for the `MT_GetImmunityFlags` and `MT_GetAccessFlags` natives.
6. Fixed possible client index errors for the thirdperson detection.
7. Fixed invalid entity errors. (Thanks to `BloodyBlade` for reporting!)
8. Fixed all potential `Handle` leaks.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added extra checks to prevent disabled Tanks from spawning in certain situations.
2. `Left 4 DHooks` is now optional. (Thanks to `Silvers`!)
3. The `Hit Group` setting now allows for multiple hit groups to be specified using bit flags.
4. Added back the `sm_mt_config` command.
5. The core plugin now uses the `GetCmdArgInt()` function added in `SourceMod 1.11.0.6511`.
6. The `Human Support` setting now has an option to not inform human-controlled Tanks about the buttons used for activating their abilities manually. (Requested by `zaviier`.)
7. The `Human Ability` setting for several abilities now has an option to automate the ability for human-controlled Tanks. (Requested by `zaviier`.)
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
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config files.
2. Updated include file.
3. Updated translation file.
</details>
</details>

## Version 8.66 (May 1, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed props and glow outlines sticking around after Tanks die. (Thanks to everyone that reported!)
2. Fixed some settings not using their assigned default values.
3. Fixed possible client index errors for the `MT_GetImmunityFlags` and `MT_GetAccessFlags` natives.
4. Fixed admin access and immunity flags not being determined properly.
5. Fixed the `Gravity`, `Drug`, and `Blind` abilities not resetting properly. (Thanks to `Marttt` for reporting!)
6. Fixed the missing textures from the `Electric` and `Laser` abilities' particle effects. (Thanks to `Marttt` for reporting!)
7. Fixed `bIsPluginEnabled` potentially causing errors before map start.
8. Fixed the `Shield` ability's shield not breaking when the attacker has higher admin access than the Tank.
9. Fixed the `Shield` ability's default `Shield Color` values not being set to `-1`.
10. Fixed players with personalized Tanks not being renamed.
11. Fixed `sm_mt_list` returning invalid handle errors.
12. Fixed some abilities not working due to their corresponding plugins not being detected.
13. Fixed the `MT_OnConfigsLoaded` forward not sending the value of the `mode` parameter.
14. Fixed abilities not resetting upon player death.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Converted all plugins to use enum structs!
2. The `Tank Note` setting can now be overridden for specific players. A phrase must be created in the translation file for each specified player. The name of the phrase must be the player's SteamID32 or Steam3ID. See the bottom of the translation file for an example.
3. Added support for versus games in coop modes. (Requested by `Neptunia`.)
4. Added more `Display Health` options. (Requested by `foxhound27`.)
5. The `Finale Types` setting now takes in type ranges. Example: `1-10,11-20,21-30` (Requested by `Neptunia`.)
6. Added the `Rock Model` setting under the following sections (Requested by `Mi.Cura`.):
- `Tank #->Props`: Determines what model a Tank's rocks should look like.
- `STEAM_ID->Props`: Overrides the setting under the `Props` for specific players.
7. Added more particle and sound effects for the `Electric ability`.
8. Common infected are now immune to Tank abilities. They should no longer die from running into fires or explosions caused by certain abilities.
9. The rocks from the `Rock` and `Spam` abilities are now colored based on the Tank's `Rock Color` setting. (Thanks to `epzminion` for the detour idea and gamedata info!)
10. The leftover rocks created by the `Meteor` ability now explode after `10` seconds regardless if they hit the ground.
11. The `Rock` and `Spam` abilities now create three times more rocks.
12. Lowered the position of the `Spam` ability's rock launcher so that it's more likely to hit survivors.
13. The chat notification for changing names is now hidden when a player with a personalized Tank is renamed.
14. Added the `MT_OnTypeChosen` forward which allows developers to either override the chosen type, prevent the chosen type from being chosen which will force the plugin to rechoose, or prevent a Tank from mutating.
15. Added the `MT_IsNonFinaleType` native which allows developers to check if a certain type is only available on non-finale maps.
16. Renamed the `MT_CanTankSpawn` native to `MT_CanTypeSpawn`.
17. Renamed the `MT_IsFinaleTank` native to `MT_IsFinaleType`.
18. The `MT_CanTypeSpawn` native now calls `MT_IsNonFinaleType` and `MT_IsFinaleType` internally.
19. The `Finale Tank` setting now accepts the value `2` which sets the type to only be available on non-finale maps.
20. Tanks can now spawn with a propane tank helmet. (Requested by `Tank Rush`.)
21. The core plugin now uses a dynamic method for detecting ability plugins.
22. The core plugin can now detect up to `100` abilities.
23. Added the `MT_OnPluginCheck` forward to allow developers to register the filenames of custom ability plugins for the core plugin to detect.
24. Added the `MT_OnAbilityCheck` forward to allow developers to register the possible section names of custom abilities to be checked before reading the config file.
25. Added the `Propane Tank Color` setting under the `Props` section.
26. The `MT_GetPropColors` native's `mode` parameter now accepts values as high as `6` to add support for the new propane tank prop.
27. The `Regular Type` setting now takes in a type range. Example: `1-10` (Requested by `Neptunia`.)
28. The core plugin now uses `Left 4 DHooks` to check when Tanks enter ghost state and materializes them one second later.
29. The `Restart` ability's plugin (`mt_restart.smx`) now uses `Left 4 DHooks` to check when a survivor is inside the starting safe area in order to get their "spawn coordinates" to be used when `Restart Mode` is set to `0`.
30. Added the `mt_enabledgamemodes`, `mt_disabledgamemodes`, and `mt_gamemodetypes` cvars as cvar equivalents of the `Enabled Game Modes`, `Disabled Game Modes`, and `Game Mode Types` settings.
31. The core plugin now requires `DHooks` and `Left 4 DHooks`.
32. Removed some useless code.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config files.
2. Updated gamedata file.
3. Updated include file.
4. Updated translation file.
</details>
</details>

## Version 8.65 (April 20, 2020)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed model error for pump shotgun in L4D1. (Thanks to `Dragokas` for reporting!)
2. Fixed the `MT_GetPropColors` native not checking for player-assigned colors.
3. Fixed Tanks having black skin and prop colors when controlled by a player without assigned colors.
4. Fixed various override settings not working when their values are not defined in the config file.
5. Fixed variables not resetting on players. (This resulted in many bugs.)
6. Fixed the `Yell` ability using the wrong phrases.
7. Fixed the `Yell` ability not working when `Human Mode` is set to `1`.
8. Fixed the `Yell Range` setting using the `Yell Duration` setting's default value.
9. Fixed admin settings not being assigned default values.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Updated the L4D1 signatures for the `CTerrorPlayer_OnStaggered` function. (Thanks to `Dragokas` for reporting and providing the new signatures!)
2. Added more settings for glow option (Thanks to `Marttt` for the pull request!):
- `Glow Flashing`
- `Glow Range`
- `Glow Type`
3. Added sound hook to block wind sound. (Thanks to `Dragokas` for the code!)
4. Renamed the `MT_CHECK_KICKQUEUE` define to `MT_CHECK_INKICKQUEUE`.
5. Added the `Laser` ability. (Thanks to `Ernecio` for the code!)
6. Added `mt_pluginenabled` convar to enable/disable plugin via other plugins. (Requested by `sxslmk`.)
7. The `MT_OnConfigsLoad` and `MT_OnConfigsLoaded` forwards now each have one extra parameter to manage how much of the config file is read.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config files.
2. Updated gamedata file.
3. Updated include file.
4. Updated translation file.
</details>
</details>

## Version 8.64 (August 23, 2019)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed a timer error from the `Whirl` ability.
2. Fixed the `Clone` ability not replacing dead clones.
3. Fixed the issue with several abilities causing permanent gravity changes.
4. Fixed the issue with Tanks dying randomly.
</details>

### Files

1. Updated include file.
</details>

## Version 8.63 (June 25, 2019)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed Tanks glowing when they are no longer biled.
2. Fixed the issue with other plugins not reading the Tank's health properly. (Thanks to `Lux` for pointing it out!)
3. Fixed several abilities not resetting survivors' speed, gravity, and other stats to previous values.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added a check for AFK Tanks. (May not be entirely accurate.)
2. Switched to the `GlobalForward` methodmap added in `SourceMod 1.10.0.6421`.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated the include file.
</details>
</details>

## Version 8.62 (May 15, 2019)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed some sound effects not working due to non-existent files. (Thanks to `Marttt` for the pull request!)
2. Fixed the `Heal` ability returning errors on L4D1. (Thanks to `Marttt` for the pull request!)
3. Fixed the core plugin preventing other plugins from executing code on the `player_death` event.
4. Fixed the `Slow` ability targeting the Tank instead of the survivor victim. (Thanks to `Marttt` for the pull request!)
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added a check to hook/unhook some events on L4D2 only. (Thanks to `Marttt` for the pull request!)
2. Removed the `sm_mt_config` command.
3. Added a stock function to stop sounds. (Thanks to `Marttt` for the pull request!)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated the include file.
</details>
</details>

## Version 8.61 (May 2, 2019)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Track` ability spamming errors.
2. Fixed the core plugin returning errors when `plugins` directory is not found. (Thanks to `Marttt` for pointing them out and making a pull request!)
3. Fixed the translation file using the wrong phrases for certain Mutant Tanks. (Thanks to `Mi.Cura` for reporting!)
4. Fixed some entities by using their references instead of indices. (Thanks to `Lux` for pointing them out and making a pull request!)
5. Fixed the custom config files resetting to the main one when admins join.
6. Fixed the config file not being read when using custom SM folder paths. (Thanks to `Marttt` for pointing them out and making a pull request!)
7. Fixed some errors reported by `Mi.Cura`.
8. Fixed Mutant Tanks with no abilities not showing up.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. The administration system now detects SM's admin flags if the plugin's config file does not define specific flags for a user.
2. The `MT_IsTypeEnabled()` native now checks if abilities for Mutant Tanks are available.
3. Added the `Regular Mode` setting under the `Plugin Settings->Waves` section.
4. The core plugin now detects custom sourcemod directories when checking for the `plugins` folder.
5. Mutant Tanks no longer have a glow outline when biled. (Thanks to `Marttt` for the pull request!)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
2. Updated translation file.
</details>
</details>

## Version 8.60 (March 21, 2019)
<details>
	<summary>Click to expand!</summary>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Renamed the entire project to `Mutant Tanks`.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Renamed all files.
</details>
</details>

## Version 8.59 (March 20, 2019)
<details>
	<summary>Click to expand!</summary>

### Changes
<details>
	<summary>Click to expand!</summary>

1. The output of the `sm_st_config` command is now printed in chat instead of console to avoid overloading the buffer.
2. Added the `Omni`, `Xiphos`, and `Yell` abilities.
3. The `ST_GetTankName()` native now has a third argument.
4. Added the `Regular Type` and `Finale Types` settings under the `Plugin Settings->Waves` section.
5. Added the `Detect Plugins` setting under the `Plugin Settings->General` section.
6. Added the `Display Health Type` setting under the `Plugin Settings->General` section.
7. Added the `Health Characters` setting under the `Plugin Settings->General` section.
8. Added the `Access Flags` and `Immunity Flags` settings under the `Plugin Settings->Administration` section.
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
17. Added the `Allow Developer` setting under the `Plugin Settings->Administration`.
18. Improved health display.
19. The `sm_tank` and `sm_supertank` commands now use separate callbacks.
20. Added the `sm_tank2` and `sm_st_list` commands.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated the `super_tanks++.cfg` file with the above changes.
2. Updated the `super_tanks++.inc` file with the above changes.
3. Updated the `super_tanks++.phrases.txt` file with new phrases.
</details>
</details>

## Version 8.58 (March 1, 2019)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed several abilities not resetting properly when Super Tanks die.
2. Fixed the `Clone` ability spam-spawning Tank clones.
3. Fixed the `Respawn` ability not detecting finale Super Tanks.
4. Fixed all the plugins returning errors when the `Clone` ability is not installed.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

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
11. Added the `Ultimate` ability. (Requested by `foquaxticity`.)
12. The Medic ability now allows Super Tanks to heal other Tanks. (Requested by `FatalOE71`.)
13. The `ST_OnConfigsLoaded()` forward now has different parameters.
14. Added the `ST_OnConfigsLoad()` forward.
15. All KeyValues sections and settings no longer need quotation marks around them (unless they contain whitespaces).
16. The config file now accepts different formats. (See examples in the `addons/sourcemod/data/super_tanks++/backup_config` folder.)
17. All color settings need commas again as delimiters. (Example: `255,255,255,255`)
18. Increased Super Tank type limit back to `1000`.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated the `super_tanks++.cfg` file with new settings.
2. Updated the `super_tanks++.inc` file with the above changes.
3. Updated the `st_clone.inc` file with a new stock used by all plugins.
4. Updated the `super_tanks++.phrases.txt` file with new phrases.
</details>
</details>

## Version 8.57 (February 14, 2019)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed props staying attached to players after switching teams.
2. Fixed some entities not resetting properly upon death.
3. Fixed the `Finales Only` setting not working. (Thanks to `AK978` for reporting!)
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Minor code changes.
2. The core plugin now generates a `super_tanks++.cfg` file inside `cfg/sourcemod`. (Requested by `axelnieves2012`.)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated the `super_tanks++.inc` file.
</details>
</details>

## Version 8.56 (January 25, 2019)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed several abilities creating multiple timers for each Super Tank.
2. Fixed the `Regen` ability not working when using negative values for some settings. (Thanks to `Nokreb` for reporting!)
3. Fixed the `Shield` ability's `Shield Type` setting not working. (Thanks to `Nokreb` for reporting!)
4. Fixed the `Undead` ability making Super Tanks immortal. (Thanks to `fig101` for reporting!)
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added a small option to go back to previous menus when using the admin menu to access the Super Tanks++ menu. (Requested by `Marttt`.)
2. Added a different death effect for the L4D1 versions of the `Acid` and `Fling` abilities.
3. The `Regen` ability's `Regen Limit` setting no longer accepts negative values.
4. The initial damage that removes a Super Tank's shield no longer hurts the Super Tank.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated the `super_tanks++.cfg` file.
2. Updated the `super_tanks++.inc` file.
</details>
</details>

## Version 8.55 (January 15, 2019)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Clone` and `Minion` abilities not working properly.
2. Fixed the `Flash` and `Pyro` abilities glitching out when the `Run Speed` setting is not specified. (It now defaults to `1.0`.)
3. Fixed the light prop appearing even when disabled.
4. Fixed the `Heal` ability breaking the glow outline feature.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added the `ST_IsGlowEnabled` native.
2. Added the `ST_GetRunSpeed` native.
3. Added the `Death Revert` setting under the `Plugin Settings->General`. (Requested by `Mi.Cura`.)
4. Renamed all natives.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated the `super_tanks++.cfg` file.
2. Updated the `super_tanks++.inc` file.
</details>
</details>

## Version 8.54 (January 8, 2019)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the blur effect creating multiple timers.
2. Fixed the `Pyro` ability's `Pyro Damage Boost` setting not working properly.
3. Fixed the `Undead` ability not working properly.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Changed some lines on the code for the `Warp` ability.
2. Added the `ST_HideEntity()` native which hooks/unhooks any entity to/from the core plugin's SetTransmit callback.
3. Added the `Fling Force` setting for the `Fling` ability.
4. Added death effects for several abilities.
5. Added the `sm_supertank` command for players to use in versus game modes.
6. Added the following settings under the `Plugin Settings->Human Support` section for extended human support.
- `Human Cooldown`: Determines how long human-controlled Tanks need to wait before using the Super Tanks++ menu to change their type.
- `Master Control`: Determines whether human-controlled Tanks need to have a cooldown when using the Super Tanks++ menu to change their type.
- `Spawn Mode`: Determines whether human-controlled Tanks spawn as Super Tanks or as default Tanks with access to the `sm_supertank` command.
7. Added the `st_admin` override command for admins who are exempted from the `Human Cooldown` setting.
8. Super Tanks that switch to the same type as their current one switch back to a default Tank until their type is changed again.
9. Human-controlled Super Tanks can now choose the `Default Tank` option in the Super Tanks menu to revert back to a default Tank. (A cooldown will still be applied.)
10. Super Tanks now revert to default Tanks when incapacitated (about to die).
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated the `super_tanks++.cfg` file to reflect the above changes.
2. Updated the `super_tanks++.inc` file to reflect the above changes.
3. Updated the `super_tanks++.phrases.txt` file with new phrases.
</details>
</details>

## Version 8.53 (January 3, 2019)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Clone` and `Minion` abilities' `Replace` settings not working properly. (Thanks to `Mi.Cura` for reporting!)
2. Fixed the `Pyro` ability's `Pyro Damage Boost` setting not working properly.
3. Fixed the core plugin not detecting all the client buttons.
4. Fixed the blur effect colliding with the Super Tank it is attached to.
5. Fixed the plugins not detecting all Tank throw animation sequences.
6. Fixed the `Car` and `Meteor` abilities not resetting properly.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Removed the feature where the Infected team cannot damage each other.
2. Added better thirdperson detection to properly display props attached to Super Tanks.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated the `super_tanks++.cfg` file.
2. Updated the `super_tanks++.inc` file.
3. Updated the `super_tanks++.phrases.txt` file with new phrases.
</details>
</details>

## Version 8.52 (January 1, 2019)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed some chat messages being sent to AI Super Tanks.
2. Fixed the `Car` and `Meteor` abilities not working. (Thanks to `Mi.Cura` for reporting!)
3. Fixed the `Item` ability not disabling properly.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Removed `Human Ammo` and `Human Cooldown` settings for the `Kamikaze` ability.
2. The `Base Health` setting is now a global setting under the `Plugins Settings->General` section. (Requested by `KasperH`/`Ladis`.)
3. New ability added: `Hit` Ability - The Super Tank only takes damage in certain parts of its body.
4. New ability added: `Undead` ability - The Super Tank cannot die.
5. Renamed the `Human Duration` setting to `Car Duration` for the `Car` ability.
6. Renamed the `Human Duration` setting to `Meteor Duration` for the `Meteor` ability.
7. Renamed the `Pyro Boost` setting to `Pyro Speed Boost`.
8. Added the `Pyro Damage Boost` setting for the `Pyro` ability.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated the `super_tanks++.cfg` file with the new settings.
2. Updated the `super_tanks++.phrases.txt` file with various new phrases.
</details>
</details>

## Version 8.51 (December 26, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Clone`, `Minion`, and `Respawn` abilities not respecting the `Amount` settings.
2. Fixed the `Cloud` ability not respecting the `Human Mode` setting.
3. Fixed all abilities not resetting properly for human-controlled Super Tanks upon death.
</details>
</details>

## Version 8.50 (December 25, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the chat color tags not working properly.
2. Fixed several settings not working properly.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

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
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated the `super_tanks++.cfg` file with the new settings.
2. Updated the `super_tanks++.inc` file with new forwards, natives, and stocks.
3. Updated the `super_tanks++.phrases.txt` file with various new phrases.
</details>
</details>

## Version 8.49 (December 6, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `sm_tank` command not spawning disabled Super Tanks.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. The `sm_tank` command can now spawn more than one Super Tank at a time. (New syntax: `sm_tank "type 1-500 OR name" "amount: 1-32" "0: spawn at crosshair|1: spawn automatically"`)
</details>
</details>

## Version 8.48 (November 30, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed various timers not stopping when their corresponding settings are disabled.
</details>
</details>

## Version 8.47 (November 26, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Fling` and `Smite` abilities not working. (Thanks to `Mi.Cura` for reporting!)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file to fix documentation typos.
</details>
</details>

## Version 8.46 (November 22, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed various abilities not resetting properly.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added new target filters: `@special`, `@infected`
2. The `Ability Effect` settings are now disabled by default.
3. All Chance settings now accept `0.0%` as a valid value.
4. The `Skin-Glow Colors` and `Props Colors` settings have been divided into different settings.
5. The `Tank Chance`, `Type Limit`, and `Finale Tank` settings no longer affect respawned Tanks and randomized Tanks.
6. The `Announce Arrival` setting now accepts different values.
7. The `Throw` ability's `Ability Enabled` setting now accepts different values.
8. The `Throw` ability now allows for all `4` types to be enabled at once. (`1` of the `4` will be chosen randomly each time a Super Tank throws a rock.)
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
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config file.
2. Updated include file.
3. Updated translation file.
</details>
</details>

## Version 8.45 (October 31, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Clone` and `Minion` abilities not resetting properly.
2. Fixed the `Witch` ability spamming chat.
3. Fixed the `Ability Message` settings not working properly.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. The `sm_tank` command now accepts partial name matches as input values. (Example: `sm_tank boss`)
2. Moved some stock functions from include file to some of the module plugins.
3. Lowered the `Tank Name` setting's character limit from `128` to `32`.
4. The `Medic` ability now lets Super Tanks heal nearby special infected by `1 HP` every second.
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
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config file.
2. Updated include file.
3. Updated translation file.
</details>
</details>

## Version 8.44 (October 16, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Absorb`, `Fragile`, and `Hypno` abilities not working properly.
2. Fixed the datapack leaks from various modules.
3. Fixed the `Range Chance` settings not working at all.
4. Fixed the issue with props and special effects not deleting themselves properly, thus causing crashes.
5. Fixed the `Throw` ability's cars having a strong velocity, thus pushing other entities away.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Improved readability of the source code for each plugin.
2. Added the `Aimless`, `Choke`, `Cloud`, `Drunk`, and Whirl abilities.
3. Added new settings for several abilities to handle timer intervals and damage values.
4. The `Electric`, `Hurt`, and `Splash` abilities now use `SDKHooks_TakeDamage()` to damage players.
5. The damage settings of the `Electric`, `Hurt`, and `Splash` abilities now accept float values (decimals) instead of int values (whole numbers).
6. Renamed a bunch of settings.
7. Decreased Super Tank type limit back to `500` to avoid server freezes and lag spikes.
8. Removed the `st_enableplugin` cvar setting.
9. `Chance` and `Range Chance` settings now only accept decimal (float) values.
10. `Chance` and `Range Chance` settings now work differently. (Before: 1/X chances, After: X/100.0 probability)
11. Added the `Base Health` setting to determine the base health of each Super Tank.
12. Added the `Tank Chance` setting to determine the chances of a Super Tank type spawning.
13. Added the `ST_TankChance()` native for the new `Tank Chance` setting.
14. The core plugin and its modules now require `SourceMod 1.10.0.6352` or higher.
15. The core plugin now properly updates all settings when the config file is refreshed.
16. Removed the `sm_tanklist` command.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config file with the new settings.
2. Updated include file for better readability.
</details>
</details>

## Version 8.43 (October 2, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed some abilities not displaying messages.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Renamed function parameters for better understanding.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.42 (October 2, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Marked the `ST_TankName` and `ST_TankWave` natives as optional to avoid potential issues.
2. Fixed the `Flash` ability errors. (Thanks `Mi.Cura` for reporting!)
3. Fixed the `Rocket` ability creating multiple timers for survivors who are getting sent into space.
4. Fixed several abilities not resetting when a Super Tank dies.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Renamed/removed some stocks.
2. The core plugin and its modules now requires `SourceMod 1.10.0.6317` or higher.
3. The Tank Notes now display a different message when the phrase for a Super Tank is not found.
4. Changed the directory of the configs from `cfg/sourcemod` to `addons/sourcemod/data`.
5. Added a new native: `ST_TankColors` - Retrieves a Super Tank's colors.
6. The `Gravity` ability's `Gravity Value` now accepts higher values.
7. The `Health` ability no longer allows a Super Tank to set survivors to black and white.
8. The `Jump` ability now provides more features.
9. The `Pyro` ability now provides more features.
10. The `Restart` ability now removes all weapons from survivors before giving them new loadouts.
11. Lowered the amount of boss stages from `5` to `4`. Any boss that spawns automatically starts at stage `1`.
12. Moved various settings under new sections and reorganized/restructured the config file.
13. Merged the `Cancer` ability with the `Health` ability.
14. Added `2` new abilities: `Lag` and `Recoil`
15. Added the `ST_PluginEnd()` and `ST_Preset()` forwards.
16. Added several checks for better handling of timers.
17. Added several new settings.
18. Renamed several settings.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config file with all the new settings, presets, and organization/structure.
2. Updated gamedata file to remove unused signatures.
3. Updated include file to use new natives introduced in `SM 1.9` and `SM 1.10`, and to add new forwards and natives.
4. Updated translation file with new phrases and reformatted the phrase name of the Tank Note phrases.
</details>
</details>

## Version 8.41 (September 18, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed some abilities not accepting any 6+ digit values for damage settings.
2. Fixed the issue with the `Shield` ability not keeping the shield disabled when it's deactivated. (Thanks `Mi.Cura` for reporting!)
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Removed the `[ST++]` prefix from the Super Tank health display.
2. Added a message for each ability. (Each message can be configured in the translation file.)
3. Added an `Ability Message` setting to toggle the messages for each ability.
4. Added a range feature for some abilities.
5. Added a new native: `ST_TankName(int client, char[] buffer)` - Returns a Tank's custom name.
6. Removed the `ST_Spawn(int client)` forward. (Use `ST_Ability(int client)` instead for more flexibility.)
7. Added the `Flash Interval` setting for the `Flash` ability.
8. The `Tank Note` setting now only accepts `0` and `1` as values.
9. Tank Notes must now be created inside the translation file.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config file with the new settings and modified some presets.
2. Updated include file to remove the `ST_Spawn(int client)` forward and add the new `ST_TankName(int client, char[] buffer)` native.
3. Updated translation file with the new messages and Tank Notes.
</details>
</details>

## Version 8.40 (September 11, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the datapack error with the `Ghost` ability.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Changed all `OnClientPostAdminCheck()` forwards to `OnClientPutInServer()` instead.
2. Moved late-loading code from `OnMapStart()` to `OnPluginStart()`.
</details>
</details>

## Version 8.39 (September 10, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed some abilities not working when their `Ability Enabled` setting is disabled. (Thanks `huwong`!)
2. Fixed the `Gravity` ability returning a datapack error.
3. Fixed the `Bomb` and `Fire` abilities not working in L4D1.
4. Fixed the `Ice` ability flinging survivors back at a high velocity after being unfrozen.
5. Fixed the `Zombie` ability not working properly.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

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
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Added a translation file for the plugin. (Filename is `super_tanks++.phrases.txt`)
2. New file: `st_clone.inc` (Used for the `Clone` ability's library.)
3. Updated config file with all the new settings.
4. Updated include file to add/remove code.
</details>
</details>

## Version 8.38 (September 6, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed some modules not working properly for custom configs.
2. Fixed custom configs not working.
3. Fixed Tanks having the `unnamed` name when Boss mode is enabled. (Thanks `Zytheus`!)
4. Fixed the `Splash` ability creating multiple timers.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Increased the maximum amount of possible Super Tank types from `2500` to `5000`.
2. Replaced the `Maximum Types` setting with the new `Type Range` setting. (Usage: `Type Range` `1-5000`)
3. Changed the display info for each Super Tank type on the ST++ menu. (Before: `Tank's Name`, After: `Tank's Name (Tank #)`)
4. The core plugin no longer generates a config file nor a backup copy of it. (This feature was just wasting space and was overall unnecessary.)
5. Removed the `Create Backup` setting.
6. Removed support for human-controlled Tanks. (This feature was buggy and made the Infected team overpowered.)
7. Removed the `Human Super Tanks` setting.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file to add new natives, remove some stocks, and remove support for auto-config generation.
2. Smaller file sizes.
</details>
</details>

## Version 8.37 (August 30, 2018)
<details>
	<summary>Click to expand!</summary>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added support for dynamic loading to the modules. (Thanks `Lux`!)
2. Switched `RemoveEntity(entity)` back to `AcceptEntityInput(entity, "Kill")` just to be courteous to those who prefer to still use `SM 1.8`.
3. Removed `IsDedicatedServer()` just to be courteous to those who do not have dedicated servers. (Please do not report bugs if you're playing on a local/listen server.)
</details>
</details>

## Version 8.36 (August 20, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed issues with the Tank when the `Finales Only` setting is set to `1`.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Optimized code a bit for the plugin and all of its modules.
</details>
</details>

## Version 8.35 (August 16, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. `Rock` ability - Fixed the `Rock Radius` KeyValue setting not being read properly due to a small buffer size.
2. `Drop` ability - Fixed incorrect scaling on some of the melee weapons.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. `Warp` ability - The Super Tank will no longer warp to incapacitated survivors.
2. `Restart` ability - Survivors will no longer warp to incapacitated teammates.
3. New ability added: `Cancer` ability - The Super Tank gives survivors cancer (survivors die when they reach `0 HP` instead of getting incapacitated first).
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
7. The core plugin and all of its modules now require `SourceMod 1.9.0.6225` or higher to work.
8. Removed unnecessary code.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated gamedata file with a new signature for `CTerrorPlayer_OnStaggered` for Windows to make the `Shove` ability compatible with Left 4 Downtown 2. (Thanks `Spirit_12`!)
</details>
</details>

## Version 8.34 (August 12, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Drop` ability not properly deleting weapon entities attached to the Super Tank when he dies.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Moved some lines of code around, optimized some code, etc.
2. The `Puke` ability now gives the Super Tank a chance to puke on survivors when hit with a melee weapon.
3. The following settings can now be set for each Tank instead of affecting all Tanks at once:

- `Boss Health Stages`
- `Boss Stages`
- `Random Interval`
- `Spawn Mode`
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. The auto-generated config file has less presets (smaller file size).
</details>
</details>

## Version 8.33 (August 10, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Witch` ability causing crashes when converting Common infected into Witch minions.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added a boss mode feature, which is a feature taken from the original Last Boss. View the `INFORMATION.md` file for more details. (2 new settings: `Boss Health Stages` and `Boss Stages`)
2. Added a random mode feature, which is a feature that randomizes Super Tanks every X seconds after spawning. View the `INFORMATION.md` file for more details. (1 new setting: `Random Interval`)
3. Added a new forward to use for the boss and random modes:

`forward void ST_BossStage(int client);` (This forward is called when the Super Tank is evolving into the next stage.)

4. Added the `Spawn Mode` KeyValue setting to allow users to decide if Super Tanks either spawn normally, spawn as bosses (boss mode), or spawn as randomized Tanks (random mode).
5. The `Splash` ability now damages nearby survivors every X seconds while the Super Tank is alive.
6. Added the `Splash Interval` KeyValue setting to support the new Splash ability feature.
7. The `Vampire` ability's `Vampire Health` KeyValue setting now only applies to the `range` ability. (When the Super Tank hits a survivor, he now gains the amount of damage as health.)
8. The `Witch` ability's range used for detecting nearby Common infected can now be configurable via the new `Witch Range` KeyValue setting.
9. Changed a few lines of code.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file with the new settings.
2. Updated config file with the new settings.
3. Updated `INFORMATION.md` file with information about the new settings.
</details>
</details>

## Version 8.32 (August 6, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Enabled Game Modes` and `Disabled Game Modes` settings not allowing more than `64` characters.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Lowered the character limit of the `Enabled Game Modes` and `Disabled Game Modes` settings from `2048` to `512`.
2. Rocks thrown by Tanks now have the same color as the rocks attached to their bodies.
3. Removed the `information` folder in favor of the `INFORMATION.md` file that comes with the plugin's package.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file (`super_tanks++.inc`).
2. Updated core plugin (`super_tanks++.sp`).
3. Updated all plugins to stop creating information files.
4. Updated config file.
</details>
</details>

## Version 8.31 (August 4, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed errors reported by `Mi.Cura` regarding the `Rock` ability.
2. Fixed potential bugs and errors from various abilities.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added a 3rd parameter for the `sm_tank` command. (Usage: `sm_tank <1-2500> <0: spawn at crosshair, 1: spawn automatically>`)
2. Added the `Drop Mode` KeyValue setting to determine what kind of weapons the Super Tank can drop. `(0: Both|1: Guns only|2: Melee weapons only)`
3. Changed how the `Pyro` ability detects Tanks that are on fire.
4. Major code optimizations. (Thanks `Lux`!)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
2. Updated config file.
</details>
</details>

## Version 8.30 (August 2, 2018)
<details>
	<summary>Click to expand!</summary>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added the `Regen Limit` KeyValue setting for the Regen Ability. More information in the `information` folder and `README` file on GitHub.
2. Added the `Restart Mode` KeyValue setting for the `Restart` ability. More information in the `information` folder and `README` file on GitHub.
3. Added the `st_enableplugin` cvar so users can disable the plugin via console. (The ConVar-based config file is located in `cfg/sourcemod/` while the KeyValues-based config file is still located in `cfg/sourcemod/super_tanks++`.)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file with the new settings.
2. Updated config file with the new settings.
3. Added the `information` folder in the same location as the config file which contains information about each ability and setting.
</details>
</details>

## Version 8.29 (July 31, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed potential idle bug.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added the `Claw Damage` KeyValue setting under the `Enhancements` section which determines how much damage a Tank's claw attack does.
2. Added the `Rock Damage` KeyValue setting under the `Enhancements` section which determines how much damage a Tank's rock throw does.
2. Moved all stock/common functions to the include file.
3. Replaced multiple forwards with one forward to handle events hooked by the core plugin.
4. Removed an extra check for spawning Super Tanks from the `sm_tank` menu.
5. Removed unused code.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated gamedata file with new signatures for the `Idle` ability.
2. Updated include file to store more stock/common functions and to remove unused KeyValue settings from the auto-config generator.
3. Updated config file to remove unused KeyValue settings from the config file.
</details>
</details>

## Version 8.28 (July 28, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Panic` ability not working in L4D1.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Changed how the `Bomb` ability creates explosions to prevent crashes.
2. Removed the `Bomb Power` setting.
3. Optimized code a bit.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file to remove the `Bomb Power` setting from the auto-config generator.
2. Updated config file to remove the `Bomb Power` setting.
</details>
</details>

## Version 8.27 (July 28, 2018)
<details>
	<summary>Click to expand!</summary>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added extra checks to make sure the plugin spawns the proper amount of Tanks for each wave.
2. Lessened the occurrence of Tanks flashing all over the map on finales. (Set `Glow Effect` to `1` to completely disable the glow outlines.)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. `super_tanks++.sp` (Where the extra checks were added.)
2. `super_tanks++.inc` (Updated version number.)
</details>
</details>

## Version 8.26 (July 28, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed some abilities and features staying on even when the `Human Super Tanks` KeyValue setting is set to `0`.
2. Fixed some abilities and features staying on even when they're disabled for a specific Tank.
3. Fixed `OnTakeDamage` errors reported by `FatalOE71`.
4. Fixed the issue with so many Tanks spawning towards the end of finales.
5. Fixed various abilities not working properly.
6. Fixed the issue with Tanks that have the `Fragile` ability not dying properly.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added a new native for developers to use: `native bool ST_TankAllowed(int client)` - Returns the status of the `Human Super Tanks` setting.
2. Added a new native for developers to use: native int `ST_MaxTypes()` - Returns the value of the `Maximum Types` setting.
3. Added a new forward for developers to use: forward void `ST_Death2(int enemy, int client)` - Called when a Tank dies and returns the attacker's index.
4. Added checks to various timers in case abilities are disabled before the timers are triggered.
5. Added a check to prevent clone Tanks from counting as actual Tanks.
6. The `Clone` ability no longer spawns more clones when all of the current clones die. (This is to prevent glitches with the Tank spawner.)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file with the new natives and forward.
</details>
</details>

## Version 8.25 (July 26, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the Tank limit for each wave not working properly. (Thanks `Mi.Cura`!)
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added `Range Chance` settings and other settings for various abilities for better control.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file to include the new settings.
</details>
</details>

## Version 8.24 (July 26, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed various errors reported by `Princess LadyRain`.
2. Fixed various abilities not working properly.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added new abilities and renamed some settings.
2. Removed unnecessary code.
3. Divided the plugin into multiple files for the following reasons:

- To avoid slow compilation time.
- To make it easier to add new abilities.
- To make it easier to identify problems within the code.
- To make each ability optional.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file to remove unnecessary code and transfer some of it to other files.
2. Updated gamedata file to remove unused signatures.
3. Updated config file with new settings and presets.
</details>
</details>

## Version 8.23 (July 20, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed various errors reported by `Princess LadyRain`.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Users can now change settings inside the config file mid-game without having to reload the plugin or restart the server. (Basically the counterpart of `ConVar.AddChangeHook` for cvars.)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.22 (July 20, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the issue with some KeyValue settings not working properly.
2. Fixed various bugs.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Restructured the config file.
2. Added a ton of new KeyValues for many abilities.
3. Added new abilities.
4. Increased the maximum amount of possible Super Tank types from `1000` to `2500`.
5. The core plugin now creates a folder inside `cfg/sourcemod/super_tanks++` called `backup_config` which contains a copy of the config file in case users need it.
6. Added checks to trim all string-related settings to get rid of any white spaces.
7. Raised the value limits of various settings.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config file with the new settings and new presets.
2. Updated include file.
</details>
</details>

## Version 8.21 (July 14, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the error coming from `OnTakeDamage`.
2. Fixed the error regarding a missing translation phrase when a vote is in progress.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

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
</details>

### New Formats
<details>
	<summary>Click to expand!</summary>

`Props Attached` `123456`
`Props Chance` `3,3,3,3,3,3`
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated config file with new presets.
2. Updated include file.
</details>
</details>

## Version 8.20 (July 12, 2018)
<details>
	<summary>Click to expand!</summary>

### Changes
<details>
	<summary>Click to expand!</summary>

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
11. Added the `God Ability` KeyValue which lets the Super Tank have temporary godmode.
12. Added the `God Chance` KeyValue which determines how often the Super Tank gets temporary godmode.
13. Added the `God Duration` KeyValue which decides how long the Super Tank's temporary godmode lasts.
14. Added the `Clone Ability` KeyValue which lets the Super Tank spawn clones of itself.
15. Added the `Clone Amount` KeyValue which determines how many clones the Super Tank can spawn.
16. Added the `Clone Chance` KeyValue which determines how often the Super Tank can spawn clones of itself.
17. Added the `Clone Health` KeyValue which decides how much health each clone of the Super Tank gets.
18. Used a better method for preventing Tanks from getting stuck in the dying animation.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.19 (July 10, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Enabled Game Modes` and `Disabled Game Modes` KeyValues not working properly.
2. Fixed the particle effects for Super Tanks not appearing. (Thanks `Mi.Cura`!)
3. Fixed the wrong Super Tanks spawning when they are spawned through the Super Tanks++ Menu. (Thanks `Mi.Cura`!)
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Raised the character limit of the `Enabled Game Modes` and `Disabled Game Modes` KeyValues from `32` to `64`.
2. Added the `Game Mode Types` KeyValue to enable/disable the plugin in certain game mode types. (1: Co-Op, 2: Versus, 4: Survival, 8: Scavenge)
3. Changed the permissions for the config file directories.
</details>

### Files

1. Updated include file.
</details>

## Version 8.18 (July 8, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Spam` ability creating multiple timers.
2. Fixed the Super Tanks not taking any type of explosive damage.
3. Fixed the `Shield` ability preventing Super Tanks with less than `100 HP` from dying.
4. Fixed the `Bomb` ability's particle effects not appearing.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

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
13. The `Hypno` ability no longer sets survivors' HP to `1` when the inflicted damage is higher than their health, but rather incapacitates them.
14. Removed the `Tank Types` KeyValue.
15. Replaced the `Tank Character` KeyValue with `Tank Enabled`. (Now users can simply enable/disable each Tank without using a letter, number, or symbol.)
16. Added Tank death announcement messages.
17. Increased the maximum amount of possible Super Tank types from `250` to `1000`.
18. Added a Super Tanks++ menu to the admin menu.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.17 (June 6, 2018)
<details>
	<summary>Click to expand!</summary>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added the `Hypno Mode` KeyValue to decide whether hypnotized survivors can only hurt themselves or other teammates.
2. The `Hypno` ability now uses OnTakeDamage instead of TraceAttack and supports multiple damage types.
3. The `Hypno` ability's effect only activates when hypnotized survivors hurts/kills the Super Tank that hypnotized them.
4. The `Hypno` ability no longer kills hypnotized survivors when they kill the Super Tank that hypnotized them.
5. The bullet (gunshot) damage done onto a Super Tank by its hypnotized victim will now have `1`/`10` of it inflicted upon the hypnotized victim.
6. The slash (melee) damage done onto a Super Tank by its hypnotized victim will now have `1`/`1000` of it inflicted upon the hypnotized victim. 
7. Added the `Bury Height` KeyValue to decide how deep survivors are buried.
8. Added a check for only burying survivors that are on the ground to avoid bugs.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.16 (July 5, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the Car Throw Ability, Infected Throw Ability, and Shield Ability's propane throw not working.
2. Fixed the `Enabled Game Modes` and `Disabled Game Modes` KeyValues not having enough space for more than `2-4` game modes.
3. Fixed the issue with default `unnamed` Tanks appearing when certain Super Tanks are disabled.
4. Fixed the `Warp` ability's interval glitching out.
5. Fixed the `Gravity` ability creating more than one `point_push` entity per Tank.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Raised the character limit of the `Tank Types` KeyValue from `64` to `250`.
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
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.15 (June 30, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the shield color being overridden when the Super Tank has the Ghost Ability enabled.
2. Fixed custom configs not respecting the settings from the main config when KeyValues are not found inside the custom configs.
3. Fixed the `player_death` event callback returning the victim's user ID for the attacker.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Users can now choose different colors for each prop (Change `Skin-Prop-Glow Colors` to `Skin-Glow Colors` and add `Props Colors`). Format: `Skin-Glow Colors` `255,255,255,255|255,255,255`, `Props Colors` `255,255,255,255|255,255,255,255|255,255,255,255|255,255,255,255`
2. Added the `Multiply Health` KeyValue to determine how the Super Tank's health should be handled (0: No changes to health, 1: Multiply original health only, 2: Multiply extra health only, 3: Multiply both). Format: `Multiply Health` `3`
3. Added the `Bomb Rock Break` KeyValue which makes the Super Tank's rocks explode. Format: `Bomb Rock Break` `1`
4. Added the `Car Throw Ability` KeyValue which lets the Super Tank throw cars. Format: `Car Throw Ability` `1`
5. Added the `Vampire Claw-Rock` KeyValue which lets the Super Tank steal health from survivors. Format: `Vampire Claw-Rock` `1`
6. Added the `Vampire Health` KeyValue to determine how much health the Super Tank receives from hitting survivors. Format: `Vampire Health` `100`
7. Added the `Vampire Chance` KeyValue to determine the chances of the Super Tank stealing health from survivors. Format: `Vampire Chance` `33.3`
8. The config file is now automatically created if it does not exist already.
9. Optimized code even more.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Moved various stock functions to the include file.
</details>
</details>

## Version 8.14 (June 28, 2018)
<details>
	<summary>Click to expand!</summary>

### Changes
<details>
	<summary>Click to expand!</summary>

1. The `Flash` ability now fades properly when the Super Tank has the Ghost Ability enabled.
2. Raised the spawn point of the rocks for the `Spam` ability again to avoid collision with the Super Tank.
</details>
</details>

## Version 8.13 (June 28, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Ghost` ability not letting Super Tanks fade out to full invisibility.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Lowered the spawn point of the rocks for the `Spam` ability.
2. Added the `Ghost Fade Limit` KeyValue setting to adjust the intensity of the `Ghost` ability's fade feature (255: No effect, 0: Fully faded).
3. Added the `Glow Effect` KeyValue setting to determine whether or not Super Tanks will have a glow outline (0: OFF, 1: ON).
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
2. Updated `Boss` and `Meme` Tank's settings in the config file.
</details>
</details>

## Version 8.12 (June 28, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed all previously known/found bugs.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Any and all Super Tank types are now FULLY customizable.
2. Added support for up to `250` Super Tank Types.
3. Converted all ConVars to KeyValues.
4. Removed unnecessary code.
5. Optimized code a bit more.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated gamedata file.
2. Updated include file.
</details>
</details>

## Version 8.11 (June 22, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Witch Tank` not spawning Witches. (Thanks `ReCreator`!)
2. Fixed the `Shield Tank` not propelling its propane tanks forward. (Thanks `ReCreator`!)
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added the convar `st_gamemodetypes` to determine what game mode types to enable/disable the plugin in. (0: All, 1: coop modes only, 2: versus modes only, 4: survival modes only, 8: scavenge modes only.)
2. Removed the `@witches` target filter for not working properly.
3. Optimized code a bit more.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.10 (June 22, 2018)
<details>
	<summary>Click to expand!</summary>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Any extra health given to a Super Tank is now multiplied by the number of alive non-idle human survivors present when the Tank spawns. (Thanks `emsit`!)
2. Added the target filters `@smokers`, `@boomers`, `@hunters`, `@spitters`, `@jockeys`, `@chargers`, `@witches` for developers/testers to use.
3. Added the `sm_tank type 1-36` command to spawn each Tank for developing/testing purposes.
4. Added oxygen tank (jetpack) props to Tanks.
5. Modified the attachprops convars to now support multiple number combinations.
6. Removed unnecessary code.
7. Optimized code a bit.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.9 (June 21, 2018)
<details>
	<summary>Click to expand!</summary>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added a randomizer for Tanks spawning with props to add more variety.
2. Added the target filter `@tanks` for developers/testers to use.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.8 (June 21, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Shove` and `Smoker Tanks`' attachprops convars not working properly.
</details>

### Files

1. Updated include file.
</details>

## Version 8.7 (June 21, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Ghost Tank` and `Gravity Tank` convars being switched.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added options for the `st_displayhealth` convar. (1: show names only, 2: show health only, 3: show both names and health.)
2. Added a convar for each Tank type to decide what props to attach to it. (1: attach lights only, 2: attach rocks only, 3: attach tires only, 4: attach all 3.)
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.6 (June 21, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the proper amount of Tanks not spawning on the 2nd wave during finales.
2. Fixed the props attached to the Tanks not disappearing right away when they die.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.5 (June 20, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the Tank's effects not going away right after the Tank dies.
</details>
</details>

## Version 8.4 (June 20, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the infected thrower Tanks not throwing special infected directly from their rocks.
</details>
</details>

## Version 8.3 (June 20, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Meteor Tank`'s meteor shower not working after a certain amount of time.
</details>

### Changes
<details>
	<summary>Click to expand!</summary>

1. Added a check to destroy all effects when a Tank dies.
2. Added a check for `Bomber Tank`'s explosion to not damage any infected including the `Bomber Tank`.
3. Added a check for `Fire Tank`'s fires to not damage any infected including the `Fire Tank`.
4. Added a check for `Meteor Tank`'s meteor showers to not damage any infected including the `Meteor Tank`.
5. Converted some code to new syntax.
6. Removed unnecessary code.
7. Optimized some code.
</details>

### Files
<details>
	<summary>Click to expand!</summary>

1. Updated include file.
</details>
</details>

## Version 8.2 (June 19, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the Tank's rocks not doing anything when survivors are hit.
</details>
</details>

## Version 8.1 (June 19, 2018)
<details>
	<summary>Click to expand!</summary>

### Bug Fixes
<details>
	<summary>Click to expand!</summary>

1. Fixed the `Common Tank` not spawning any Common infected.
2. Fixed the `Gravity Tank`'s gravity force not stopping upon death.
3. Fixed the `Hypno Tank`'s effect instantly killing survivors (Now it sets survivors to `1 HP`).
4. Fixed the `Meteor Tank`'s meteor shower not working.
5. Fixed the special infected thrower Tanks not throwing any special infected.
</details>
</details>

## Version 8.0 (June 18, 2018)
<details>
	<summary>Click to expand!</summary>

1. Major code overhaul.
2. 36 (31 for L4D1) unique types.
3. Now requires a gamedata file.
4. Now requires an include file.
</details>

## Version 7.0 (November 24, 2017)
<details>
	<summary>Click to expand!</summary>

1. Disabled `Ice Tank` for L4D1 version.
2. Only 28/40 are available for the L4D1 version now.
3. Fixed `Shield Tank` and other Super Tank types with shields not having their shields shattered by explosions.
</details>

## Version 6.5 (November 24, 2017)
<details>
	<summary>Click to expand!</summary>

1. Fixed the SetConVarInt errors reported by `KasperH`/`Ladis` here.
</details>

## Version 6.0 (November 24, 2017)
<details>
	<summary>Click to expand!</summary>

1. Added support for L4D1.
2. L4D1 version only includes `29`/`40` Super Tank types.
3. L4D1 version excludes prop attachments (concrete chunk and beam spotlight).
4. L4D1 version excludes glow outlines.
5. Changed the `l4d2_` prefix to `l4d_` for the plugin and config files.
</details>

## Version 5.5 (October 23, 2017)
<details>
	<summary>Click to expand!</summary>

1. Applied another fix for the negative HP bug for `Boss`, `Goliath`, `Psychotic`, and `Psykotik Tanks`.
</details>

## Version 5.0 (October 22, 2017)
<details>
	<summary>Click to expand!</summary>

1. Applied a fix for a speed bug that was also in the original Super Tanks.
</details>

## Version 4.5 (October 21, 2017)
<details>
	<summary>Click to expand!</summary>

1. Fixed a bug that caused `Boss`, `Goliath`, `Psychotic`, and `Psykotik Tanks` to have negative HP.
</details>

## Version 4.0 (October 21, 2017)
<details>
	<summary>Click to expand!</summary>

1. Added 8 new combinations of Super Tanks.
- `Boss Tank`
- `Meme Tank`
- `Mirage Tank`
- `Poltergeist Tank`
- `Psykotik Tank`
- `Sipow Tank`
- `Spykotik Tank`
- `Spypsy Tank`
2. Fixed some bugs due to missing code.
</details>

## Version 3.0 (October 20, 2017)
<details>
	<summary>Click to expand!</summary>

1. Fixed the Flash and Reverse Flash special speed cvars not working.
</details>

## Version 2.0 (October 19, 2017)
<details>
	<summary>Click to expand!</summary>

1. Removed the screen color effect when getting hit by certain Super Tank types.
2. Redesigned and recolored `Trap Tank`.
3. Recolored `Bitch Tank`, `Distraction Tank`, and `Minion Tank`.
</details>

## Version 1.0 (October 18, 2017)
<details>
	<summary>Click to expand!</summary>

Initial Release.
</details>