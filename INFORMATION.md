# Information

## Notes
> This file contains everything you need to know about each ability/setting. Use this guide to learn about every setting/feature available before asking about it or reporting an issue. The original config format will be used for examples. Visit the [Wiki](https://github.com/Psykotikism/Mutant_Tanks/wiki) for more information, including examples and/or tutorials.

- Maximum Tank health: `1,000,000` (Increase/decrease the value in the `mutant_tanks.inc` file on lines `93-94` and recompile all the plugins, but expect game-breaking bugs with higher values.) [Default: `65,535`]
- Maximum types: `500` (Increase/decrease the value in the `mutant_tanks.inc` file on line `92` and recompile all the plugins, but expect server lag with higher values.)
- Most of the settings below can be overridden for each player.

## Sections
- Plugin Settings
	- General
	- Announcements
	- Rewards
	- Competitive
	- Difficulty
	- Health
	- Enhancements
	- Immunities
	- Administration
	- Human Support
	- Waves
	- ConVars
	- Game Modes
	- Custom

- Tank Settings
	- General
	- Announcements
	- Rewards
	- Glow
	- Administration
	- Human Support
	- Spawn
	- Boss
	- Combo
	- Random
	- Transform
	- Props
	- Particles
	- Health
	- Enhancements
	- Immunities

- Abilities Set #1 (A-L)
	- Absorb
	- Acid
	- Aimless
	- Ammo
	- Blind
	- Bomb
	- Bury
	- Car
	- Choke
	- Clone
	- Cloud
	- Drop
	- Drug
	- Drunk
	- Electric
	- Enforce
	- Fast
	- Fire
	- Fling
	- Fly
	- Fragile
	- Ghost
	- God
	- Gravity
	- Heal
	- Hit
	- Hurt
	- Hypno
	- Ice
	- Idle
	- Invert
	- Item
	- Jump
	- Kamikaze
	- Lag
	- Laser
	- Leech
	- Lightning

- Abilities Set #2 (M-Z)
	- Medic
	- Meteor
	- Minion
	- Necro
	- Nullify
	- Omni
	- Panic
	- Pimp
	- Puke
	- Pyro
	- Quiet
	- Recoil
	- Regen
	- Respawn
	- Restart
	- Rock
	- Rocket
	- Shake
	- Shield
	- Shove
	- Slow
	- Smash
	- Smite
	- Spam
	- Splash
	- Splatter
	- Throw
	- Track
	- Ultimate
	- Undead
	- Vampire
	- Vision
	- Warp
	- Whirl
	- Witch
	- Xiphos
	- Yell
	- Zombie

- Administration System
	- Administration
	- Tank Settings
	- Abilities

### Plugin Settings

#### General, Announcements, Rewards, Competitive, Difficulty, Health, Enhancements, Immunities, Administration, Human Support, Waves, ConVars, Game Modes, Custom
```
"Mutant Tanks"
{
	// These are the general plugin settings.
	// Note: The following settings will not work in custom config files:
	// - Any setting under the "Game Modes" section.
	// - Any setting under the "Custom" section.
	"Plugin Settings"
	{
		"General"
		{
			// Enable Mutant Tanks.
			// Note: This setting has a convar equivalent (mt_pluginenabled).
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Plugin Enabled"			"1"

			// Enable Mutant Tanks on listen servers.
			// Note: This setting has a convar equivalent (mt_listensupport).
			// Note: Supporting listen servers only extends to SourceMod's own limits.
			// Note: There is no guarantee that Mutant Tanks will work on listen servers.
			// Note: There is no guarantee that SourceMod will work on listen servers.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Listen Support"			"1"

			// The plugin will automatically disable any Mutant Tank whose abilities are not installed.
			// Note: The abilities cache is only updated when configs are loaded/refreshed.
			// Note: This setting does not disable Mutant Tanks that do not have any abilities.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for each Mutant Tank under the "General" section of their settings.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Check Abilities"			"1"

			// Mutant Tanks revert back to default Tanks upon death.
			// Note: This setting can be overridden for each Mutant Tank under the "General" section of their settings.
			// Note: This feature is simply for cosmetic purposes. You do not need to worry about this setting.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Death Revert"				"1"

			// Spawn Mutant Tanks during finales only.
			// Note: This setting can be used for standard Tanks.
			// --
			// 0: OFF, Mutant Tanks will spawn on any map.
			// 1: ON, Mutant Tanks will only spawn on finale maps.
			// 2: ON, Mutant Tanks will only spawn on non-finale maps.
			// 3: ON, Mutant Tanks will only spawn on finale maps before the rescue vehicle is called.
			// 4: ON, Mutant Tanks will only spawn on finale maps after the rescue vehicle is called.
			"Finales Only"				"0"

			// Check if Mutant Tanks are idle every time this many seconds passes and kill them if idle.
			// Note: It is recommended to use this in finale stage configs only since idle Tanks can prevent finales from ending.
			// Note: On non-finale maps, Tanks are only idle until survivors finally encounter them, but Tanks with no behavior can spawn on any map.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be used for standard Tanks.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0
			"Idle Check"				"10.0"

			// The type of idle mode to check for.
			// Note: It is recommended to set this to "2" on non-finale maps and "0" on finale maps.
			// Note: There is a rare bug where a Tank spawns with no behavior even though they look "idle" to survivors. Set this setting to "0" or "2" to detect this bug.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be used for standard Tanks.
			// --
			// 0: Both
			// 1: Only check for idle Tanks.
			// 2: Only check for Tanks with no behavior (rare bug).
			"Idle Check Mode"			"2"

			// Log all admin commands provided by Mutant Tanks.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 31
			// --
			// 0: OFF
			// 1: "sm_tank"/"sm_mt_tank"
			// 2: "sm_mt_config"
			// 4: "sm_mt_list"
			// 8: "sm_mt_reload"
			// 16: "sm_mt_version"
			"Log Commands"				"31"

			// Log all global chat messages and server messages generated by Mutant Tanks.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 31
			// --
			// 0: OFF
			// 1: Arrival and death announcements
			// 2: Boss evolution, randomization, and transformation announcements
			// 4: Ability activations
			// 8: Server notifications/confirmations
			// 16: Custom messages
			"Log Messages"				"0"

			// All Mutant Tanks are only effective toward human survivors.
			// Note: This setting can be overridden for each Mutant Tank under the "General" section of their settings.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for all Mutant Tanks to be effective.
			"Requires Humans"			"0"

			// Enable all Mutant Tanks.
			// Note: This setting determines full availability. Even if other spawn settings are enabled while this is disabled, all Mutant Tanks will stay disabled.
			// Note: This setting can be overridden for each Mutant Tank under the "General" section of their settings.
			// --
			// -1/"ignore"/"exclude"/"filter"/"remove": Let the setting with the same name from each Mutant Tank's "General" section decide.
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Tank Enabled"				"-1"

			// The model used by all Mutant Tanks.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "General" section of their settings.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF (Let the game decide.)
			// 1: Default model
			// 2: The Sacrifice model
			// 4: L4D1 model (Only available in Left 4 Dead 2.)
			"Tank Model"				"0"

			// The duration in seconds of all Mutant Tanks' afterburn.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "General" section of their settings.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0
			"Burn Duration"				"0.0"

			// The burnt percentage of all Mutant Tanks when they spawn.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "General" section of their settings.
			// --
			// -1.0: OFF
			// 0.0: Random
			// 0.01-1.0: Burn percentage
			"Burnt Skin"				"-1.0"

			// All Mutant Tanks can spawn.
			// Note: Mutant Tanks will still appear on the Mutant Tanks menu and other Mutant Tanks can still transform into each other.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for each Mutant Tank under the "General" section of their settings.
			// --
			// -1/"ignore"/"exclude"/"filter"/"remove": Let the setting with the same name from each Mutant Tank's "General" section decide.
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Spawn Enabled"				"-1"

			// The number of Mutant Tanks that can be alive at any given time.
			// Note: Clones, respawned Mutant Tanks, randomized Tanks, and Mutant Tanks spawned through the Mutant Tanks menu are not affected.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// Minimum: 0 (OFF)
			// Maximum: 32
			"Spawn Limit"				"0"

			// The range of types to check for.
			// --
			// Separate values with "-".
			// --
			// Value limit: 2
			// Character limit for each value: 4
			// --
			// Minimum number for each value: 0 (OFF)
			// Maximum number for each value: 500
			// --
			// 1st number = Minimum value
			// 2nd number = Maximum value
			// --
			// Example: "0-0" (Do not choose from any Mutant Tank types.)
			// Example: "1-25" (Choose a Mutant Tank type between 1 through 25.)
			// Example: "50-0" (Automatically change to "0-0" because "50" is higher than "0".)
			// Example: "1-1000" (Automatically change to "1-500" because "500" is the maximum number of Mutant Tank types allowed.)
			// Example: "0" (Automatically change to "0-500" because the maximum range is not specified.)
			// Example: "1000" (Automatically change to "500-500" because the maximum range is not specified and the minimum range exceeds the "500" limit.)
			// --
			// 0: OFF, use standard Tanks.
			// 1-500: ON, the type that will spawn.
			"Type Range"				"1-500"
		}
		"Announcements"
		{
			// Announce each Mutant Tank's arrival.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Announcements" section of their settings.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 31
			// --
			// 0: OFF
			// 1: Announce when a Mutant Tank spawns.
			// 2: Announce when a Mutant Tank evolves. (Only works when "Spawn Type" is set to "1".)
			// 4: Announce when a Mutant Tank randomizes. (Only works when "Spawn Type" is set to "2".)
			// 8: Announce when a Mutant Tank transforms. (Only works when "Spawn Type" is set to "3".)
			// 16: Announce when a Mutant Tank untransforms. (Only works when "Spawn Type" is set to "3".)
			"Announce Arrival"			"31"

			// Announce each Mutant Tank's death.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Announcements" section of their settings.
			// --
			// 0: OFF
			// 1: ON, announce deaths only.
			// 2: ON, announce deaths with killers.
			"Announce Death"			"1"

			// Announce each Mutant Tank's kill.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Announcements" section of their settings.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Announce Kill"				"1"

			// The message shown to players when a Mutant Tank arrives.
			// Note: This setting only works for the first option of the "Announce Arrival" setting.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Announcements" section of their settings.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 1023
			// --
			// 0 OR 1023: Pick randomly between the 10 messages.
			// 1: Message #1
			// 2: Message #2
			// 4: Message #3
			// 8: Message #4
			// 16: Message #5
			// 32: Message #6
			// 64: Message #7
			// 128: Message #8
			// 256: Message #9
			// 512: Message #10
			"Arrival Message"			"0"

			// A sound is played to players when a Mutant Tank arrives.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Announcements" section of their settings.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Arrival Sound"				"1"

			// The details shown when announcing Mutant Tanks' deaths.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Announcements" section of their settings.
			// --
			// 0: Damage done to Mutant Tanks' health.
			// 1: Percentage of damage done to Mutant Tanks' health.
			// 2: Damage and percentage of damage done to Mutant Tanks' health.
			// 3: Damage done to Mutant Tanks' health as a team.
			// 4: Percentage of damage done to Mutant Tanks' health as a team.
			// 5: Damage and percentage of damage done to Mutant Tanks' health as a team.
			"Death Details"				"5"

			// The message shown to players when a Mutant Tank dies.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Announcements" section of their settings.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 1023
			// --
			// 0 OR 1023: Pick randomly between the 10 messages.
			// 1: Message #1
			// 2: Message #2
			// 4: Message #3
			// 8: Message #4
			// 16: Message #5
			// 32: Message #6
			// 64: Message #7
			// 128: Message #8
			// 256: Message #9
			// 512: Message #10
			"Death Message"				"0"

			// A sound is played to players when a Mutant Tank dies.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Announcements" section of their settings.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Death Sound"				"1"

			// The message shown to players when a Mutant Tank kills a survivor.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Announcements" section of their settings.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 1023
			// --
			// 0 OR 1023: Pick randomly between the 10 messages.
			// 1: Message #1
			// 2: Message #2
			// 4: Message #3
			// 8: Message #4
			// 16: Message #5
			// 32: Message #6
			// 64: Message #7
			// 128: Message #8
			// 256: Message #9
			// 512: Message #10
			"Kill Message"				"0"

			// All alive survivors vocalize when a Mutant Tank arrives.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Announcements" section of their settings.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Vocalize Arrival"			"1"

			// All alive survivors vocalize when a Mutant Tank dies.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Announcements" section of their settings.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Vocalize Death"			"1"
		}
		"Rewards"
		{
			// Reward survivors for fighting Mutant Tanks.
			// Note: The same rewards cannot be stacked and will not overlap each other to avoid spam.
			// Note: Some rewards may require Lux's "WeaponHandling_API" plugin.
			// Link: https://forums.alliedmods.net/showthread.php?t=319947
			// Note: Some rewards may require patches from the "mutant_tanks_patches.cfg" config file to work.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Add up numbers together for different results.
			// --
			// Minimum value for each: -1
			// Maximum value for each: 2147483647
			// --
			// -1: OFF
			// 0: Random
			// 1: Health reward (temporary)
			// - Refill to 100% health.
			// - Automatically kill any current special infected attacker.
			// - Heal back to 100% health with first aid kits.
			// - Receive 100% temporary health after being revived.
			// - Slowly regenerate back to full health.
			// - Leech health off of any infected per melee hit.
			// 2: Speed boost reward (temporary)
			// - Run faster
			// - Jump higher (Disables the death fall camera for recipients.)
			// - Receive the adrenaline effect for the duration of the reward. (Only available in Left 4 Dead 2.)
			// 4: Damage boost reward (temporary)
			// - Extra damage
			// - Bypass Tank immunities
			// - Damage resistance
			// - Automatically kill Witches.
			// - Hollowpoint ammo
			// - Extended melee range
			// - Sledgehammer rounds
			// - Protected by thorns (deal damage towards attacker per hit taken)
			// 8: Attack boost reward (temporary)
			// - Bypass shove penalty
			// - Shoving Tanks does damage.
			// - Faster shove interval
			// - Faster shoot rate (guns)
			// - Faster reload rate (guns)
			// - Faster swing rate (melee)
			// - Faster throw time (throwables)
			// - Faster revive time
			// - Faster healing time (first aid kit)
			// - Faster defib time (defibrillator)
			// - Faster deploy time (ammo upgrade packs)
			// - Faster pour time (gas cans)
			// - Faster delivery time (cola bottles)
			// - Faster recovery time
			// 16: Ammo reward (temporary)
			// - Refill clip to max size
			// - Refill magazine to max size
			// - Extra clip and magazine size
			// - Receive one of the special ammo (incendiary or explosive). (Only available in Left 4 Dead 2.)
			// - Slowly regenerate back to full capacity.
			// 32: Item reward
			// - Give up to five items.
			// 64: God mode reward (temporary)
			// - Automatically kill all special infected attackers.
			// - Immune to all types of damage.
			// - Cannot be flung away by Chargers.
			// - Cannot be pushed around.
			// - Cannot be vomited on by Boomers.
			// - Reduced pushback from Tank punches
			// - Reduced pushback from hitting Tanks with melee immunity.
			// - Get clean kills (blocks Smoker clouds, Boomer explosions, and Spitter acid puddles)
			// 128: Health and ammo refill reward
			// - Refill to 100% health.
			// - Automatically kill any current special infected attacker.
			// - Refill clip to max size
			// - Refill magazine to max size
			// 256: Respawn reward
			// - Respawn and teleport to a teammate.
			// - Restore previous loadout
			// 512: Infinite ammo reward (temporary)
			// - Infinite ammo for primary weapons
			// - Infinite ammo for secondary weapons
			// - Infinite ammo for throwables
			// - Infinite ammo for medkits/defibs/ammo packs
			// - Infinite ammo for pills/adrenaline
			// 1023: All above rewards
			// 1024-2147483647: Reserved for third-party plugins
			// --
			// 1st number = Enable rewards for killers.
			// 2nd number = Enable rewards for assistants.
			// 3rd number = Enable rewards for teammates.
			"Reward Enabled"			"-1,-1,-1"

			// Reward survivor bots for fighting Mutant Tanks.
			// Note: The same rewards cannot be stacked and will not overlap each other to avoid spam.
			// Note: Some rewards may require Lux's "WeaponHandling_API" plugin.
			// Link: https://forums.alliedmods.net/showthread.php?t=319947
			// Note: Some rewards may require patches from the "mutant_tanks_patches.cfg" config file to work.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Add up numbers together for different results.
			// --
			// Minimum value for each: -1
			// Maximum value for each: 2147483647
			// --
			// -1: OFF
			// 0: Random
			// 1: Health reward (temporary)
			// - Refill to 100% health.
			// - Automatically kill any current special infected attacker.
			// - Heal back to 100% health with first aid kits.
			// - Receive 100% temporary health after being revived.
			// - Slowly regenerate back to full health.
			// - Leech health off of any infected per melee hit.
			// 2: Speed boost reward (temporary)
			// - Run faster
			// - Jump higher (Disables the death fall camera for recipients.)
			// - Receive the adrenaline effect for the duration of the reward. (Only available in Left 4 Dead 2.)
			// 4: Damage boost reward (temporary)
			// - Extra damage
			// - Bypass Tank immunities
			// - Damage resistance
			// - Automatically kill Witches.
			// - Hollowpoint ammo
			// - Extended melee range
			// - Sledgehammer rounds
			// - Protected by thorns (deal damage towards attacker per hit taken)
			// 8: Attack boost reward (temporary)
			// - Bypass shove penalty
			// - Shoving Tanks does damage.
			// - Faster shove interval
			// - Faster shoot rate (guns)
			// - Faster reload rate (guns)
			// - Faster swing rate (melee)
			// - Faster throw time (throwables)
			// - Faster revive time
			// - Faster healing time (first aid kit)
			// - Faster defib time (defibrillator)
			// - Faster deploy time (ammo upgrade packs)
			// - Faster pour time (gas cans)
			// - Faster delivery time (cola bottles)
			// - Faster recovery time
			// 16: Ammo reward (temporary)
			// - Refill clip to max size
			// - Refill magazine to max size
			// - Extra clip and magazine size
			// - Receive one of the special ammo (incendiary or explosive). (Only available in Left 4 Dead 2.)
			// - Slowly regenerate back to full capacity.
			// 32: Item reward
			// - Give up to five items.
			// 64: God mode reward (temporary)
			// - Automatically kill all special infected attackers.
			// - Immune to all types of damage.
			// - Cannot be flung away by Chargers.
			// - Cannot be pushed around.
			// - Cannot be vomited on by Boomers.
			// - Reduced pushback from Tank punches
			// - Reduced pushback from hitting Tanks with melee immunity.
			// - Get clean kills (blocks Smoker clouds, Boomer explosions, and Spitter acid puddles)
			// 128: Health and ammo refill reward
			// - Refill to 100% health.
			// - Automatically kill any current special infected attacker.
			// - Refill clip to max size
			// - Refill magazine to max size
			// 256: Respawn reward
			// - Respawn and teleport to a teammate.
			// - Restore previous loadout
			// 512: Infinite ammo reward (temporary)
			// - Infinite ammo for primary weapons
			// - Infinite ammo for secondary weapons
			// - Infinite ammo for throwables
			// - Infinite ammo for medkits/defibs/ammo packs
			// - Infinite ammo for pills/adrenaline
			// 1023: All above rewards
			// 1024-2147483647: Reserved for third-party plugins
			// --
			// 1st number = Enable rewards for killers.
			// 2nd number = Enable rewards for assistants.
			// 3rd number = Enable rewards for teammates.
			"Reward Bots"				"-1,-1,-1"

			// The chance to reward survivors for killing Mutant Tanks.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate chances with commas (",").
			// --
			// Chances limit: 3
			// Character limit for each chance: 6
			// --
			// Minimum value for each chance: 0.0 (No chance)
			// Maximum value for each chance: 100.0 (Highest chance)
			// --
			// 1st number = Chance to reward killers.
			// 2nd number = Chance to reward assistants.
			// 3rd number = Chance to reward teammates.
			"Reward Chance"				"33.3,33.3,33.3"

			// The duration of temporary rewards.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate durations with commas (",").
			// --
			// Durations limit: 3
			// Character limit for each duration: 9
			// --
			// Minimum value for each duration: 0.1 (Shortest)
			// Maximum value for each duration: 999999.0 (Longest)
			// --
			// 1st number = Duration for killer rewards.
			// 2nd number = Duration for assistant rewards.
			// 3rd number = Duration for teammate rewards.
			"Reward Duration"			"10.0,10.0,10.0"

			// The effects displayed when rewarding survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Add up numbers together for different results.
			// --
			// Minimum value for each: 0
			// Maximum value for each: 15
			// --
			// 0: OFF
			// 1: Trophy
			// 2: Fireworks particles
			// 4: Sound effect
			// 8: Thirdperson view
			// --
			// 1st number = Effect for killers.
			// 2nd number = Effect for assistants.
			// 3rd number = Effect for teammates.
			"Reward Effect"				"15,15,15"

			// Notify survivors when they receive a reward from Mutant Tanks.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Add up numbers together for different results.
			// --
			// Minimum value for each: 0
			// Maximum value for each: 3
			// --
			// 0: OFF
			// 1: When survivors solo a Mutant Tank or do not do enough damage to a Mutant Tank.
			// 2: When survivors receive a reward.
			// --
			// 1st number = Notify killers.
			// 2nd number = Notify assistants.
			// 3rd number = Notify teammates.
			"Reward Notify"				"3,3,3"

			// The minimum amount of damage in percentage required to receive a reward.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate percentages with commas (",").
			// --
			// Percentages limit: 3
			// Character limit for each percentage: 6
			// --
			// Minimum value for each percentage: 0.1 (Least)
			// Maximum value for each percentage: 100.0 (All)
			// --
			// 1st number = Percentage of damage required for killer rewards.
			// 2nd number = Percentage of damage required for assistant rewards.
			// 3rd number = Percentage of damage required for teammate rewards.
			"Reward Percentage"			"10.0,10.0,10.0"

			// Prioritize rewards in this order.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0
			// Maximum value for each: 3
			// --
			// 0: OFF (Do not reward anyone.)
			// 1: Reward killers.
			// 2: Reward assistants.
			// 3: Reward teammates.
			// --
			// 1st number = 1st priority
			// 2nd number = 2nd priority
			// 3rd number = 3rd priority
			"Reward Priority"			"1,2,3"

			// The visual effects displayed for rewards.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Add up numbers together for different results.
			// --
			// Minimum value for each: 0
			// Maximum value for each: 31
			// --
			// 0: OFF
			// 1: Screen color
			// 2: Glow outline (Only available in Left 4 Dead 2.)
			// 3: Body color
			// 8: Particle effect
			// 16: Looping voiceline
			// --
			// 1st number = Visual effect for killers.
			// 2nd number = Visual effect for assistants.
			// 3rd number = Visual effect for teammates.
			"Reward Visual"				"31,31,31"

			// The action duration to reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate durations with commas (",").
			// --
			// Durations limit: 3
			// Character limit for each duration: 9
			// --
			// Minimum value for each duration: 0.0 (OFF)
			// Maximum value for each duration: 999999.0 (Slowest)
			// --
			// 1st number = Duration for killers.
			// 2nd number = Duration for assistants.
			// 3rd number = Duration for teammates.
			"Action Duration Reward"		"2.0,2.0,2.0"

			// Give ammo boost as a reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Give ammo boost to killers.
			// 2nd number = Give ammo boost to assistants.
			// 3rd number = Give ammo boost to teammates.
			"Ammo Boost Reward"			"1,1,1"

			// The amount of ammo to regenerate per second as a reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate amounts with commas (",").
			// --
			// Amounts limit: 3
			// Character limit for each amount: 12
			// --
			// Minimum value for each amount: 0 (OFF)
			// Maximum value for each amount: 999999 (Highest)
			// --
			// 1st number = Amount for killers.
			// 2nd number = Amount for assistants.
			// 3rd number = Amount for teammates.
			"Ammo Regen Reward"			"1,1,1"

			// The attack boost to reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate boosts with commas (",").
			// --
			// Boosts limit: 3
			// Character limit for each boost: 9
			// --
			// Minimum value for each boost: 0.0 (OFF)
			// Maximum value for each boost: 999999.0 (Fastest)
			// --
			// 1st number = Boost for killers.
			// 2nd number = Boost for assistants.
			// 3rd number = Boost for teammates.
			"Attack Boost Reward"			"1.25,1.25,1.25"

			// Give clean kills (no Smoker clouds, Boomer explosions, and Spitter acide puddles) as a reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Give clean kills to killers.
			// 2nd number = Give clean kills to assistants.
			// 3rd number = Give clean kills to teammates.
			"Clean Kills Reward"			"1,1,1"

			// The damage boost to reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate boosts with commas (",").
			// --
			// Boosts limit: 3
			// Character limit for each boost: 9
			// --
			// Minimum value for each boost: 0.0 (OFF)
			// Maximum value for each boost: 999999.0 (Strongest)
			// --
			// 1st number = Boost for killers.
			// 2nd number = Boost for assistants.
			// 3rd number = Boost for teammates.
			"Damage Boost Reward"			"1.25,1.25,1.25"

			// The damage resistance to reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate resistances with commas (",").
			// --
			// Resistances limit: 3
			// Character limit for each resistance: 9
			// --
			// Minimum value for each resistance: 0.0 (OFF)
			// Maximum value for each resistance: 1.0 (None)
			// --
			// 1st number = Resistance for killers.
			// 2nd number = Resistance for assistants.
			// 3rd number = Resistance for teammates.
			"Damage Resistance Reward"		"0.5,0.5,0.5"

			// The voiceline that plays when survivors are falling.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate voicelines sets with commas (",").
			// --
			// Item sets limit: 3
			// Character limit for each set: 64
			// --
			// 1st set = Fall voiceline for killers.
			// 2nd set = Fall voiceline for assistants.
			// 3rd set = Fall voiceline for teammates.
			"Fall Voiceline Reward"			"PlayerLaugh,PlayerLaugh,PlayerLaugh"

			// The healing percentage from first aid kits to reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate percentages with commas (",").
			// --
			// Percentages limit: 3
			// Character limit for each percentage: 6
			// --
			// Minimum percentage for each: 0.0 (OFF)
			// Maximum percentage for each: 100.0 (Highest)
			// --
			// 1st number = Heal percentage for killers.
			// 2nd number = Heal percentage for assistants.
			// 3rd number = Heal percentage for teammates.
			"Heal Percent Reward"			"100.0,100.0,100.0"

			// The amount of health to regenerate per second as a reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate amounts with commas (",").
			// --
			// Amounts limit: 3
			// Character limit for each amount: 12
			// --
			// Minimum value for each amount: 0 (OFF)
			// Maximum value for each amount: 1000000 (Highest)
			// --
			// 1st number = Amount for killers.
			// 2nd number = Amount for assistants.
			// 3rd number = Amount for teammates.
			"Health Regen Reward"			"1,1,1"

			// Give hollowpoint ammo as a reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Give hollowpoint ammo to killers.
			// 2nd number = Give hollowpoint ammo to assistants.
			// 3rd number = Give hollowpoint ammo to teammates.
			"Hollowpoint Ammo Reward"		"1,1,1"

			// Give infinite ammo as a reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Add up numbers together for different results.
			// --
			// Minimum value for each: 0
			// Maximum value for each: 31
			// --
			// 0: OFF
			// 1: Infinite ammo for primary weapons
			// 2: Infinite ammo for secondary weapons
			// 4: Infinite ammo for throwables
			// 8: Infinite ammo for medkits/defibs/ammo packs
			// 16: Infinite ammo for pills/adrenaline
			// --
			// 1st number = Give infinite ammo to killers.
			// 2nd number = Give infinite ammo to assistants.
			// 3rd number = Give infinite ammo to teammates.
			"Infinite Ammo Reward"			"31,31,31"

			// The item(s) to reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate item sets with commas (",").
			// Separate items with semi-colons (";").
			// --
			// Item sets limit: 3
			// Character limit for each set: 320
			// --
			// 1st set = Item set to reward killers.
			// 2nd set = Item set to reward assistants.
			// 3rd set = Item set to reward teammates.
			"Item Reward"				"first_aid_kit,first_aid_kit,first_aid_kit"

			// The jump height to reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// Note: Any value above "150.0" may cause instant death from fall damage.
			// --
			// Separate heights with commas (",").
			// --
			// Heights limit: 3
			// Character limit for each height: 9
			// --
			// Minimum value for each height: 0.0 (OFF)
			// Maximum value for each height: 999999.0 (Highest)
			// --
			// 1st number = Height for killers.
			// 2nd number = Height for assistants.
			// 3rd number = Height for teammates.
			"Jump Height Reward"			"75.0,75.0,75.0"

			// Allow a number of Witches to be instantly killed as a reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 999999 (Highest)
			// --
			// 1st number = Number of lady killer bullets to give to killers.
			// 2nd number = Number of lady killer bullets to give to assistants.
			// 3rd number = Number of lady killer bullets to give to teammates.
			"Lady Killer Reward"			"1,1,1"

			// The amount of health to leech per hit as a reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate amounts with commas (",").
			// --
			// Amounts limit: 3
			// Character limit for each amount: 12
			// --
			// Minimum value for each amount: 0 (OFF)
			// Maximum value for each amount: 1000000 (Highest)
			// --
			// 1st number = Amount for killers.
			// 2nd number = Amount for assistants.
			// 3rd number = Amount for teammates.
			"Life Leech Reward"			"1,1,1"

			// The melee range to reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate ranges with commas (",").
			// --
			// Ranges limit: 3
			// Character limit for each range: 6
			// --
			// Minimum value for each range: 0 (OFF)
			// Maximum value for each range: 999999 (Highest)
			// --
			// 1st number = Range for killers.
			// 2nd number = Range for assistants.
			// 3rd number = Range for teammates.
			"Melee Range Reward"			"100,100,100"

			// The punch resistance to reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate resistances with commas (",").
			// --
			// Resistances limit: 3
			// Character limit for each resistance: 6
			// --
			// Minimum value for each resistance: 0.0 (OFF)
			// Maximum value for each resistance: 1.0 (None)
			// --
			// 1st number = Resistance for killers.
			// 2nd number = Resistance for assistants.
			// 3rd number = Resistance for teammates.
			"Punch Resistance Reward"		"0.25,0.25,0.25"

			// Restore the previous loadouts of survivors after respawning them.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Restore loadouts for killers.
			// 2nd number = Restore loadouts for assistants.
			// 3rd number = Restore loadouts for teammates.
			"Respawn Loadout Reward"		"1,1,1"

			// The revive health to reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 12
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1000000 (Highest)
			// --
			// 1st number = Health for killers.
			// 2nd number = Health for assistants.
			// 3rd number = Health for teammates.
			"Revive Health Reward"			"100,100,100"

			// The shove damage multiplier against Chargers, Witches, and Tanks to reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// Note: The max health of the target will be multiplied by this setting's value.
			// --
			// Separate multipliers with commas (",").
			// --
			// Multipliers limit: 3
			// Character limit for each multiplier: 9
			// --
			// Minimum value for each multiplier: 0.0 (OFF)
			// Maximum value for each multiplier: 999999.0 (Strongest)
			// --
			// 1st number = Multiplier for killers.
			// 2nd number = Multiplier for assistants.
			// 3rd number = Multiplier for teammates.
			// --
			// Example: 600 (default Charger health) * 0.025 (shove damage reward) = 15 damage per shove
			"Shove Damage Reward"			"0.025,0.025,0.025"

			// Remove shove penalty as a reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Remove shove penalty for killers.
			// 2nd number = Remove shove penalty for assistants.
			// 3rd number = Remove shove penalty for teammates.
			"Shove Penalty Reward"			"1,1,1"

			// The shove rate to reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// Note: The value of "z_gun_swing_interval" will be multiplied by this setting's value.
			// --
			// Separate rates with commas (",").
			// --
			// Rates limit: 3
			// Character limit for each rate: 9
			// --
			// Minimum value for each rate: 0.0 (OFF)
			// Maximum value for each rate: 999999.0 (Slowest)
			// --
			// 1st number = Rate for killers.
			// 2nd number = Rate for assistants.
			// 3rd number = Rate for teammates.
			// --
			// Example: 0.7 (default "z_gun_swing_interval" value) * 0.7 (shove rate reward) = 0.49 rate
			"Shove Rate Reward"			"0.7,0.7,0.7"

			// Give sledgehammer rounds as a reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Give sledgehammer rounds to killers.
			// 2nd number = Give sledgehammer rounds to assistants.
			// 3rd number = Give sledgehammer rounds to teammates.
			"Sledgehammer Rounds Reward"		"1,1,1"

			// Give special ammo as a reward to survivors. (Only available in Left 4 Dead 2.)
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0
			// Maximum value for each: 3
			// --
			// 0: OFF
			// 1: Incendiary ammo
			// 2: Explosive ammo
			// 4: Random
			// --
			// 1st number = Give special ammo to killers.
			// 2nd number = Give special ammo to assistants.
			// 3rd number = Give special ammo to teammates.
			"Special Ammo Reward"			"1,1,1"

			// The speed boost to reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate boosts with commas (",").
			// --
			// Boosts limit: 3
			// Character limit for each boost: 9
			// --
			// Minimum value for each boost: 0.0 (OFF)
			// Maximum value for each boost: 999999.0 (Fastest)
			// --
			// 1st number = Boost for killers.
			// 2nd number = Boost for assistants.
			// 3rd number = Boost for teammates.
			"Speed Boost Reward"			"1.25,1.25,1.25"

			// Allow rewards from Mutant Tanks to be stacked.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Stack rewards for killers.
			// 2nd number = Stack rewards for assistants.
			// 3rd number = Stack rewards for teammates.
			"Stack Rewards"				"1,1,1"

			// Give thorns as a reward to survivors.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Give thorns to killers.
			// 2nd number = Give thorns to assistants.
			// 3rd number = Give thorns to teammates.
			"Thorns Reward"				"1,1,1"

			// Include useful reward types depending on the status of the recipient.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate values with commas (",").
			// --
			// Add up numbers together for different results.
			// --
			// Minimum value for each: 0
			// Maximum value for each: 15
			// --
			// 0: OFF
			// 1: If the recipient is black and white and low on ammunition, they will receive Health and ammo refill as a reward.
			// 2: If the recipient is black and white, they will receive Health as a reward.
			// 4: If the recipient is low on ammunition, they will receive Ammo as a reward.
			// 8: If the recipient is dead, they will receive Respawn as a reward.
			// --
			// 1st number = Enable useful rewards for killers.
			// 2nd number = Enable useful rewards for assistants.
			// 3rd number = Enable useful rewards for teammates.
			"Useful Rewards"			"15,15,15"

			// These are the RGBA values of the recipients' body color visual.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// Note: Any value less than "0" will output a random color.
			// --
			// Separate RGBA sets with commas (",").
			// Separate RGBA values with semi-colons (";").
			// --
			// RGBA sets limit: 3
			// Character limit for each set: 16
			// Character limit for each value: 4
			// --
			// Minimum value for each: -1 (Random)
			// Maximum value for each: 255 (Brightest)
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			// --
			// 1st set = RGBA set for killers.
			// 2nd set = RGBA set for assistants.
			// 3rd set = RGBA set for teammates.
			"Body Color Visual"			"-1;-1;-1;-1,-1;-1;-1;-1,-1;-1;-1;-1"

			// These are the RGB values of the recipients' glow outline color visual.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// Note: Only available in Left 4 Dead 2.
			// Note: Any value less than "0" will output a random color.
			// --
			// Separate RGB sets with commas (",").
			// Separate RGB values with semi-colons (";").
			// --
			// RGBA sets limit: 3
			// Character limit for each set: 12
			// Character limit for each value: 4
			// --
			// Minimum value for each: -1 (Random)
			// Maximum value for each: 255 (Brightest)
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// --
			// 1st set = RGB set for killers.
			// 2nd set = RGB set for assistants.
			// 3rd set = RGB set for teammates.
			"Glow Color Visual"			"-1;-1;-1,-1;-1;-1,-1;-1;-1"

			// The voiceline that plays on loop throughout a survivor's reward duration.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Separate voicelines sets with commas (",").
			// --
			// Item sets limit: 3
			// Character limit for each set: 64
			// --
			// 1st set = Looping voiceline for killers.
			// 2nd set = Looping voiceline for assistants.
			// 3rd set = Looping voiceline for teammates.
			"Looping Voiceline Visual"		"PlayerDeath,PlayerDeath,PlayerDeath"

			// The particles for the recipients' particle effect visual.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 15
			// --
			// 0: OFF
			// 1: Blood Explosion
			// 2: Electric Jolt
			// 4: Fire Trail
			// 8: Acid Trail (Only available in Left 4 Dead 2.)
			"Particle Effect Visual"		"15,15,15"

			// These are the RGBA values of the recipients' screen color visual.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Rewards" section of their settings.
			// Note: Any value less than "0" will output a random color.
			// --
			// Separate RGBA sets with commas (",").
			// Separate RGBA values with semi-colons (";").
			// --
			// RGBA sets limit: 3
			// Character limit for each set: 16
			// Character limit for each value: 4
			// --
			// Minimum value for each: -1 (Random)
			// Maximum value for each: 255 (Brightest)
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			// --
			// 1st set = RGBA set for killers.
			// 2nd set = RGBA set for assistants.
			// 3rd set = RGBA set for teammates.
			"Screen Color Visual"			"-1;-1;-1;-1,-1;-1;-1;-1,-1;-1;-1;-1"
		}
		"Competitive"
		{
			// (Co-Op modes only) Mutant Tanks should attack immediately after spawning.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be used for standard Tanks.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF, let the game determine Mutant Tanks' initial behavior.
			// 1/"enabled"/"true"/"on"/"yes": ON, force Mutant Tanks to attack immediately.
			"Aggressive Tanks"			"0"

			// Survivors will be credited when damaging Mutant Tanks with fire.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be used for standard Tanks.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Credit Igniters"			"1"

			// (Co-Op modes only) Mutant Tanks in ghost mode will be forcefully spawned after this many seconds passes.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be used for standard Tanks.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0
			"Force Spawn"				"0.0"

			// The stasis mode of Mutant Tanks when spawning.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be used for standard Tanks.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF, let the game determine Mutant Tanks' stasis mode.
			// 1/"enabled"/"true"/"on"/"yes": ON, skip stasis mode and spawn Mutant Tanks right away.
			"Stasis Mode"				"0"

			// (Survival modes only) The delay in seconds before allowing Mutant Tanks to spawn.
			// Note: The survival timer starts when the first panic event is triggered, which is the same method used by this setting to delay Mutant Tanks from spawning.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Survival Delay"			"0.1"
		}
		"Difficulty"
		{
			// The damage scales to use for multiplying damage caused by Mutant Tanks.
			// --
			// Separate scales with commas (",").
			// --
			// Scale limit: 4
			// Character limit for each damage scale: 9
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0
			// --
			// 1st number = Damage scale for Easy difficulty.
			// 2nd number = Damage scale for Normal difficulty.
			// 3rd number = Damage scale for Advanced difficulty.
			// 4th number = Damage scale for Expert difficulty.
			"Difficulty Damage"			"0.0,0.0,0.0,0.0"

			// Scale all custom damage caused by Mutant Tanks based on the current difficulty.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Scale Damage"				"0"
		}
		"Health"
		{
			// Base health given to all Mutant Tanks.
			// Note: Tank's health limit on any difficulty is 1,000,000.
			// Note: Disable this setting if it conflicts with other plugins.
			// Note: Depending on the value of the "Multiply Health" setting, the Mutant Tank's health will be multiplied based on player count.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Health" section of their settings.
			// --
			// Minimum: 0 (OFF)
			// Maximum: 1000000
			"Base Health"				"0"

			// Display Mutant Tanks' names and health.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Health" section of their settings.
			// --
			// Minimum: 0
			// Maximum: 11
			// --
			// 0: OFF
			// 1: ON, show name only.
			// 2: ON, show health only.
			// 3: ON, show health percentage only.
			// 4: ON, show healthbar only.
			// 5: ON, show name and health only.
			// 6: ON, show name and health percentage only.
			// 7: ON, show name and healthbar only.
			// 8: ON, show health and healthbar only.
			// 9: ON, show health percentage and healthbar only.
			// 10: ON, show name, health, and healthbar.
			// 11: ON, show name, health percentage, and healthbar.
			"Display Health"			"11"

			// Display type of Mutant Tanks' names and health.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Health" section of their settings.
			// --
			// 0: OFF
			// 1: ON, show in hint text.
			// 2: ON, show in center text.
			"Display Health Type"			"1"

			// Extra health given to the Mutant Tank.
			// Note: Tank's health limit on any difficulty is 1,000,000.
			// Note: Disable this setting if it conflicts with other plugins.
			// Note: Depending on the value of the "Multiply Health" setting, the Mutant Tank's health will be multiplied based on player count.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Health" section of their settings.
			// --
			// Minimum: -1000000
			// Maximum: 1000000
			// --
			// Positive numbers: Current health + Extra health
			// Negative numbers: Current health - Extra health
			"Extra Health"				"0"

			// The characters used to represent the health bar of Mutant Tanks.
			// Note: This setting only takes effect when the "Display Health" setting is enabled.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Health" section of their settings.
			// --
			// Separate characters with commas (",").
			// --
			// Character limit: 2
			// Character limit for each character: 1
			// --
			// 1st character = Health indicator
			// 2nd character = Damage indicator
			"Health Characters"			"|,-"

			// The number of human survivors required for the "Multiply Health" setting to take effect.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Health" section of their settings.
			// --
			// Minimum: 1
			// Maximum: 32
			// --
			// 1: OFF, no health multiplication. (Health * 1)
			// 2-32: ON, the number of human survivors required to multiply Tank health. (Health * X)
			"Minimum Humans"			"2"

			// Multiply Mutant Tanks' health.
			// Note: Health multiplication only occurs when the requirement for the "Minimum Humans" setting is met.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Health" section of their settings.
			// --
			// 0: No changes to health.
			// 1: Multiply original health only.
			// 2: Multiply extra health only.
			// 3: Multiply both.
			"Multiply Health"			"0"
		}
		"Enhancements"
		{
			// Every Mutant Tank can only attack every time this many seconds passes.
			// Note: Default attack interval is 2.0 seconds.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Enhancements" section of their settings.
			// --
			// OFF: 0.0
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Attack Interval"			"0.0"

			// Every Mutant Tank's claw attacks do this much damage.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Enhancements" section of their settings.
			// --
			// OFF: -1.0
			// Minimum: 0.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "nodmg"/"friendly"/"harmless" - 0.0 damage
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Claw Damage"				"-1.0"

			// Every Mutant Tank's hittables do this much damage.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Enhancements" section of their settings.
			// --
			// OFF: -1.0
			// Minimum: 0.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "nodmg"/"friendly"/"harmless" - 0.0 damage
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Hittable Damage"			"-1.0"

			// Every Mutant Tank's punches have this much force.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Enhancements" section of their settings.
			// --
			// OFF: -1.0
			// Minimum: 0.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "nodmg"/"friendly"/"harmless" - 0.0 force
			// "weakest" - 1.0 force
			// "strongest" - 999999.0 force
			"Punch Force"				"-1.0"

			// Every Mutant Tank has this many chances out of 100.0% to punch and throw a rock simultaneously.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Enhancements" section of their settings.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Punch Throw"				"0.0"

			// Every Mutant Tank's rock throws do this much damage.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Enhancements" section of their settings.
			// --
			// OFF: -1.0
			// Minimum: 0.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "nodmg"/"friendly"/"harmless" - 0.0 damage
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Rock Damage"				"-1.0"

			// Set every Mutant Tank's run speed.
			// Note: Default run speed is 1.0.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Enhancements" section of their settings.
			// --
			// OFF: 0.0
			// Minimum: 0.1
			// Maximum: 3.0
			"Run Speed"				"0.0"

			// Skip every Mutant Tank's taunting animation after incapacitating survivors.
			// Note: Only available in Left 4 Dead 2.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Enhancements" section of their settings.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Skip Taunt"				"0"

			// Every Mutant Tank's punches hit all survivors within range.
			// Note: Both games already do this by default in Versus and Survival modes.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Enhancements" section of their settings.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Sweep Fist"				"0"

			// Every Mutant Tank throws a rock every time this many seconds passes.
			// Note: Default throw interval is 5.0 seconds.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Enhancements" section of their settings.
			// --
			// OFF: 0.0
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Throw Interval"			"0.0"
		}
		"Immunities"
		{
			// Give Mutant Tanks bullet immunity.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Immunities" section of their settings.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Bullet Immunity"			"0"

			// Give Mutant Tanks explosive immunity.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Immunities" section of their settings.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Explosive Immunity"			"0"

			// Give Mutant Tanks fire immunity.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Immunities" section of their settings.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Fire Immunity"				"0"

			// Give Mutant Tanks hittable immunity.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Immunities" section of their settings.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Hittable Immunity"			"0"

			// Give Mutant Tanks melee immunity.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Immunities" section of their settings.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Melee Immunity"			"0"

			// Give Mutant Tanks vomit immunity.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Immunities" section of their settings.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Vomit Immunity"			"0"
		}
		"Administration"
		{
			// Admins with one or more of these access flags have access to all Mutant Tank types.
			// Note: This setting can be overridden for each Mutant Tank under the "Administration" section of their settings.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Allow the developer to access the plugin when joining your server.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Allow Developer"			"0"

			// Admins with one or more of these immunity flags are immune to all Mutant Tanks' attacks.
			// Note: This setting can be overridden for each Mutant Tank under the "Administration" section of their settings.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""
		}
		"Human Support"
		{
			// Human-controlled Mutant Tanks must wait this long before changing their current Mutant Tank type.
			// Note: Players with the "mt_adminversus" override will be immune to this cooldown.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"600"

			// Human-controlled Mutant Tanks are exempted from cooldowns when using the "sm_mutanttank" command to switch their current Mutant Tank type.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Master Control"			"0"

			// The mode of how human-controlled Tanks spawn.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// 0: Spawn as a default Tank with access to the "sm_mutanttank" command.
			// 1: Spawn as a Mutant Tank.
			"Spawn Mode"				"1"
		}
		"Waves"
		{
			// Limit Tank spawns according to Mutant Tanks' limits.
			// Note: Set this setting to "0" for maps like Tank Challenge or Tanks Playground.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF, let the game, map, or other plugins determine the limit.
			// 1/"enabled"/"true"/"on"/"yes": ON, let Mutant Tanks limit Tank spawns.
			"Limit Extras"				"1"

			// The delay in seconds before spawning an extra Tank.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Extras Delay"				"0.1"

			// Spawn this many Tanks on non-finale maps periodically.
			// Note: Leave this off if you have a Multi-Tanks plugin installed that handles the limit.
			// Note: This will not work unless the "Regular Mode" setting is set to "1".
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF, no limit (only one Tank will spawn).
			// 1-32: ON, the number of Tanks that will spawn.
			"Regular Amount"			"0"

			// The delay in seconds before the regular wave spawner starts.
			// Note: The delay starts after a survivor leaves the saferoom.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Regular Delay"				"10.0"

			// Spawn Tanks on non-finale maps every time this many seconds passes.
			// Note: This will not work unless the "Regular Mode" setting is set to "1".
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Regular Interval"			"300.0"

			// How many waves of Tanks can spawn before the regular wave spawner stops.
			// Note: All Tanks from a previous wave must die before more waves of Tanks can spawn.
			// Note: This will not work unless the "Regular Mode" setting is set to "1".
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// 0: OFF
			// 1-999999: Only allow this number of waves.
			"Regular Limit"				"999999"

			// The mode of the regular wave spawner.
			// Note: This setting does not need the "Regular Wave" setting to be enabled.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// 0: Wait for a Tank to spawn before spawning extra Tanks. (Recommended)
			// 1: Use "Regular Wave" to spawn Tanks.
			"Regular Mode"				"0"

			// The type of Mutant Tank that will spawn.
			// Note: This will not work unless the "Regular Mode" setting is set to "1".
			// --
			// Separate values with "-".
			// --
			// Value limit: 2
			// Character limit for each value: 4
			// --
			// Minimum number for each value: -1 (OFF)
			// Maximum number for each value: 500
			// --
			// 1st number = Minimum value
			// 2nd number = Maximum value
			// --
			// Example: "0-0" (Do not choose from any Mutant Tank types.)
			// Example: "1-25" (Choose a Mutant Tank type between 1 through 25.)
			// Example: "50-0" (Automatically change to "0-0" because "50" is higher than "0".)
			// Example: "1-1000" (Automatically change to "1-500" because "500" is the maximum number of Mutant Tank types allowed.)
			// Example: "0" (Automatically change to "0-500" because the maximum range is not specified.)
			// Example: "1000" (Automatically change to "500-500" because the maximum range is not specified and the minimum range exceeds the "500" limit.)
			// --
			// 0: OFF, use standard Tanks.
			// 1-500: ON, the type that will spawn.
			"Regular Type"				"1-500"

			// Spawn Tanks on non-finale maps periodically.
			// Note: The timer starts after "Regular Delay" is up.
			// Note: Leave this off if you want a generic spawn rate for Tanks or if you have a Multi-Tanks plugin installed.
			// Note: This will not work unless the "Regular Mode" setting is set to "1".
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Regular Wave"				"0"

			// Allow this many Tanks on finale maps to spawn regardless of the current wave.
			// Note: This is checked instead of "Finale Waves" if set to anything greater than 0.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF, no limit (no Tanks will be kicked by this setting).
			// 1-32: ON, the number of Tanks that are allowed to spawn (unless the limit for "Finale Waves" is lower).
			"Finale Amount"				"0"

			// The types of Mutant Tanks that can spawn in each wave.
			// Note: If the chosen type is not available, a random type will be chosen in its place.
			// --
			// Separate types per wave with commas (",").
			// Separate values with "-".
			// --
			// Wave limit: 10
			// Character limit for each wave: 10
			// --
			// Minimum value for each wave: -1 (OFF)
			// Maximum value for each wave: 500
			// --
			// 1st number = Minimum value
			// 2nd number = Maximum value
			// --
			// Example: "0-0" (Do not choose from any Mutant Tank types.)
			// Example: "1-25" (Choose a Mutant Tank type between 1 through 25.)
			// Example: "50-0" (Automatically change to "0-0" because "50" is higher than "0".)
			// Example: "1-1000" (Automatically change to "1-500" because "500" is the maximum number of Mutant Tank types allowed.)
			// Example: "0" (Automatically change to "0-500" because the maximum range is not specified.)
			// Example: "1000" (Automatically change to "500-500" because the maximum range is not specified and the minimum range exceeds the "500" limit.)
			// --
			// 0: OFF, use standard Tanks.
			// 1-500: ON, the type that will spawn.
			"Finale Types"				"1-500,1-500,1-500,1-500,1-500,1-500,1-500,1-500,1-500,1-500"

			// Number of Tanks to spawn for each finale wave.
			// Note: This setting does not seem to work on the official Left 4 Dead 1 campaigns' finale maps in Left 4 Dead 2. They have their own finale scripts which limit the number of Tanks to 1 for each wave.
			// Note: Use Silvers' "VScript File Replacer" plugin to raise the Tank limits on Left 4 Dead 1 campaign finale maps so this setting can work.
			// Link: https://forums.alliedmods.net/showthread.php?t=318024
			// --
			// Separate waves with commas (",").
			// --
			// Wave limit: 10
			// Character limit for each wave: 3
			// --
			// Minimum value for each wave: 1
			// Maximum value for each wave: 32
			// --
			// 1st number = 1st wave
			// 2nd number = 2nd wave
			// 3rd number = 3rd wave
			// 4th number = 4th wave
			// 5th number = 5th wave
			// 6th number = 6th wave
			// 7th number = 7th wave
			// 8th number = 8th wave
			// 9th number = 9th wave
			// 10th number = 10th wave
			// --
			// 0: OFF, no limit.
			// 1-32: ON, the number of Tanks that will spawn.
			"Finale Waves"				"0,0,0,0,0,0,0,0,0,0"
		}
		"ConVars"
		{
			// All convars (except the ones provided by Mutant Tanks) can be modified in this section.
			// Each time the config file is read, the convars in this section will be modified with their associated values.
			// This is a very powerful feature so use it as you would with your server.cfg/listenserver.cfg file.
			// Here are some examples:

			// This will fail because the convar is provided by Mutant Tanks.
			"mt_pluginenabled"			"0"

			// It takes a total of 2 1/2 minutes for Tanks to burn to death.
			"tank_burn_duration"			"150"

			// Special infected's burnt skins can go up to 100% (completely toasted) instead of only 85% (game default).
			"z_burn_max"				"1.0"

			// This will work but will just be overridden by the "Base Health" and "Extra Health" settings.
			"z_tank_health"				"4000"
		}
		"Game Modes"
		{
			// Enable Mutant Tanks in these game mode types.
			// Note: This setting has a convar equivalent (mt_gamemodetypes), which is only checked if this setting is set to "0".
			// Note: This setting cannot be changed in custom config files.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 15
			// --
			// 0 OR 15: All game mode types.
			// 1: Co-Op modes only.
			// 2: Versus modes only.
			// 4: Survival modes only.
			// 8: Scavenge modes only. (Only available in Left 4 Dead 2.)
			"Game Mode Types"			"0"

			// Enable Mutant Tanks in these game modes.
			// Note: This setting has a convar equivalent (mt_enabledgamemodes), which is only checked if this setting is left empty.
			// Note: This setting cannot be changed in custom config files.
			// --
			// Separate game modes with commas (",").
			// --
			// Character limit: 512 (including commas)
			// --
			// Empty: All
			// Not empty: Enabled only in these game modes.
			"Enabled Game Modes"			""

			// Disable Mutant Tanks in these game modes.
			// Note: This setting has a convar equivalent (mt_disabledgamemodes), which is only checked if this setting is left empty.
			// Note: This setting cannot be changed in custom config files.
			// --
			// Separate game modes with commas (",").
			// --
			// Character limit: 512 (including commas)
			// --
			// Empty: None
			// Not empty: Disabled only in these game modes.
			"Disabled Game Modes"			""
		}
		"Custom"
		{
			// Enable Mutant Tanks custom configuration.
			// Note: This setting cannot be changed in custom config files.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Enable Custom Configs"			"0"

			// The type of custom config that Mutant Tanks creates.
			// Note: This setting cannot be changed in custom config files.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 255
			// --
			// 0: OFF
			// 1: Difficulties
			// 2: Maps
			// 4: Game modes
			// 8: Days
			// 16: Player count
			// 32: Survivor count (Humans only)
			// 64: Infected count (Humans only)
			// 128: Finale stages
			"Create Config Types"			"0"

			// The type of custom config that Mutant Tanks executes.
			// Note: Custom config files that do not exist will not be executed.
			// Note: This setting cannot be changed in custom config files.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 255
			// --
			// 0: OFF
			// 1: Difficulties
			// 2: Maps
			// 4: Game modes
			// 8: Days
			// 16: Player count
			// 32: Survivor count (Humans only)
			// 64: Infected count (Humans only)
			// 128: Finale stages
			"Execute Config Types"			"0"
		}
	}
}
```

### Tank Settings

#### General, Announcements, Rewards, Glow, Administration, Human Support, Spawn, Boss, Combo, Random, Transform, Props, Particles, Health, Enhancements, Immunities
```
"Mutant Tanks"
{
	"Tank #1"
	{
		"General"
		{
			// Name of the Mutant Tank.
			// Note: This name is only used for renaming the Mutant Tank in the server and checking which translation phrase to use.
			// Note: For displaying this name in chat messages and other forms of text, use the translation file.
			// Note: This setting can be overridden for specific players.
			// --
			// Character limit: 32
			// --
			// Empty: "Tank"
			// Not Empty: Tank's custom name
			"Tank Name"				"Tank #1"

			// Restrict the Mutant Tank to this game.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// 0: OFF
			// 1: Left 4 Dead 1 only.
			// 2: Left 4 Dead 2 only.
			"Game Type"				"0"

			// Enable the Mutant Tank.
			// Note: This setting determines full availability. Even if other spawn settings are enabled while this is disabled, the Mutant Tank will stay disabled.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// --
			// -1/"ignore"/"exclude"/"filter"/"remove": Let the setting with the same name from the "Plugin Settings/General" section decide.
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Tank Enabled"				"-1"

			// The Mutant Tank has this many chances out of 100.0% to spawn.
			// Note: Clones, respawned Mutant Tanks, randomized Tanks, and Mutant Tanks spawned through the Mutant Tanks menu are not affected.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Tank Chance"				"100.0"

			// Display a note for the Mutant Tank when it spawns.
			// Note: This note can also be displayed for clones if the "Clone Mode" setting is set to "1", so the chat could be spammed if multiple clones spawn.
			// Note: A note must be manually created in the translation file.
			// Note: Tank notes support chat color tags in the translation file.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Tank Note"				"0"

			// The Mutant Tank can spawn.
			// Note: The Mutant Tank will still appear on the Mutant Tanks menu and other Mutant Tanks can still transform into the Mutant Tank.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// --
			// -1/"ignore"/"exclude"/"filter"/"remove": Let the setting with the same name from the "Plugin Settings/General" section decide.
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Spawn Enabled"				"1"

			// The Mutant Tank can be spawned through the "sm_tank"/"sm_mt_tank" command.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Menu Enabled"				"1"

			// The plugin will automatically disable the Mutant Tank if none of its abilities are installed.
			// Note: The abilities cache is only updated when configs are loaded/refreshed.
			// Note: This setting does not disable the Mutant Tank if it does not have any abilities.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Check Abilities"			"0"

			// The Mutant Tank reverts back to default a Tank upon death.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// Note: This feature is simply for cosmetic purposes.
			// You do not need to worry about this setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Death Revert"				"0"

			// These are the RGBA values of the Mutant Tank's skin color.
			// Note: Any value less than "0" will output a random color.
			// Note: This setting can be overridden for specific players.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Skin Color"				"255,255,255,255"

			// The Mutant Tank is only effective toward human survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this Mutant Tank to be effective.
			"Requires Humans"			"0"

			// The model used by the Mutant Tank.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF (Let the game decide.)
			// 1: Default model
			// 2: The Sacrifice model
			// 4: L4D1 model (Only available in Left 4 Dead 2.)
			"Tank Model"				"0"

			// The duration in seconds of the Mutant Tank's afterburn.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0
			"Burn Duration"				"0.0"

			// The burnt percentage of the Mutant Tank when it spawns.
			// Note: This setting overrides the same setting under the "Plugin Settings/General" section.
			// Note: This setting can be overridden for specific players.
			// --
			// -1.0: OFF
			// 0.0: Random
			// 0.01-1.0: Burn percentage
			"Burnt Skin"				"-1.0"
		}
		"Announcements"
		{
			// Announce the Mutant Tank's arrival.
			// Note: This setting overrides the same setting under the "Plugin Settings/Announcements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 31
			// --
			// 0: OFF
			// 1: Announce when the Mutant Tank spawns.
			// 2: Announce when the Mutant Tank evolves. (Only works when "Spawn Type" is set to "1".)
			// 4: Announce when the Mutant Tank randomizes. (Only works when "Spawn Type" is set to "2".)
			// 8: Announce when the Mutant Tank transforms. (Only works when "Spawn Type" is set to "3".)
			// 16: Announce when the Mutant Tank untransforms. (Only works when "Spawn Type" is set to "3".)
			"Announce Arrival"			"0"

			// Announce the Mutant Tank's death.
			// Note: This setting overrides the same setting under the "Plugin Settings/Announcements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, announce deaths only.
			// 2: ON, announce deaths with killers.
			"Announce Death"			"0"

			// Announce the Mutant Tank's kill.
			// Note: This setting overrides the same setting under the "Plugin Settings/Announcements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Announce Kill"				"0"

			// The message shown to players when the Mutant Tank arrives.
			// Note: This setting only works for the first option of the "Announce Arrival" setting.
			// Note: This setting overrides the same setting under the "Plugin Settings/Announcements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 1023
			// --
			// 0 OR 1023: Pick randomly between the 10 messages.
			// 1: Message #1
			// 2: Message #2
			// 4: Message #3
			// 8: Message #4
			// 16: Message #5
			// 32: Message #6
			// 64: Message #7
			// 128: Message #8
			// 256: Message #9
			// 512: Message #10
			"Arrival Message"			"0"

			// A sound is played to players when the Mutant Tank arrives.
			// Note: This setting overrides the same setting under the "Plugin Settings/Announcements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Arrival Sound"				"1"

			// The details shown when announcing the Mutant Tank's death.
			// Note: This setting overrides the same setting under the "Plugin Settings/Announcements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Damage done to the Mutant Tank's health.
			// 1: Percentage of damage done to the Mutant Tank's health.
			// 2: Damage and percentage of damage done to the Mutant Tank's health.
			// 3: Damage done to the Mutant Tank's health as a team.
			// 4: Percentage of damage done to the Mutant Tank's health as a team.
			// 5: Damage and percentage of damage done to the Mutant Tank's health as a team.
			"Death Details"				"5"

			// The message shown to players when the Mutant Tank dies.
			// Note: This setting overrides the same setting under the "Plugin Settings/Announcements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 1023
			// --
			// 0 OR 1023: Pick randomly between the 10 messages.
			// 1: Message #1
			// 2: Message #2
			// 4: Message #3
			// 8: Message #4
			// 16: Message #5
			// 32: Message #6
			// 64: Message #7
			// 128: Message #8
			// 256: Message #9
			// 512: Message #10
			"Death Message"				"0"

			// A sound is played to players when the Mutant Tank dies.
			// Note: This setting overrides the same setting under the "Plugin Settings/Announcements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Death Sound"				"1"

			// The message shown to players when the Mutant Tank kills a survivor.
			// Note: This setting overrides the same setting under the "Plugin Settings/Announcements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 1023
			// --
			// 0 OR 1023: Pick randomly between the 10 messages.
			// 1: Message #1
			// 2: Message #2
			// 4: Message #3
			// 8: Message #4
			// 16: Message #5
			// 32: Message #6
			// 64: Message #7
			// 128: Message #8
			// 256: Message #9
			// 512: Message #10
			"Kill Message"				"0"

			// All alive survivors vocalize when the Mutant Tank arrives.
			// Note: This setting overrides the same setting under the "Plugin Settings/Announcements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Vocalize Arrival"			"1"

			// All alive survivors vocalize when the Mutant Tank dies.
			// Note: This setting overrides the same setting under the "Plugin Settings/Announcements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Vocalize Death"			"1"
		}
		"Rewards"
		{
			// Reward survivors for fighting the Mutant Tank.
			// Note: The same rewards cannot be stacked and will not overlap each other to avoid spam.
			// Note: Some rewards may require Lux's "WeaponHandling_API" plugin.
			// Link: https://forums.alliedmods.net/showthread.php?t=319947
			// Note: Some rewards may require patches from the "mutant_tanks_patches.cfg" config file to work.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Add up numbers together for different results.
			// --
			// Minimum value for each: -1
			// Maximum value for each: 2147483647
			// --
			// -1: OFF
			// 0: Random
			// 1: Health reward (temporary)
			// - Refill to 100% health.
			// - Automatically kill any current special infected attacker.
			// - Heal back to 100% health with first aid kits.
			// - Receive 100% temporary health after being revived.
			// - Slowly regenerate back to full health.
			// - Leech health off of any infected per melee hit.
			// 2: Speed boost reward (temporary)
			// - Run faster
			// - Jump higher (Disables the death fall camera for recipients.)
			// - Receive the adrenaline effect for the duration of the reward. (Only available in Left 4 Dead 2.)
			// 4: Damage boost reward (temporary)
			// - Extra damage
			// - Bypass Tank immunities
			// - Damage resistance
			// - Automatically kill Witches.
			// - Hollowpoint ammo
			// - Extended melee range
			// - Sledgehammer rounds
			// - Protected by thorns (deal damage towards attacker per hit taken)
			// 8: Attack boost reward (temporary)
			// - Bypass shove penalty
			// - Shoving Tanks does damage.
			// - Faster shove interval
			// - Faster shoot rate (guns)
			// - Faster reload rate (guns)
			// - Faster swing rate (melee)
			// - Faster throw time (throwables)
			// - Faster revive time
			// - Faster healing time (first aid kit)
			// - Faster defib time (defibrillator)
			// - Faster deploy time (ammo upgrade packs)
			// - Faster pour time (gas cans)
			// - Faster delivery time (cola bottles)
			// - Faster recovery time
			// 16: Ammo reward (temporary)
			// - Refill clip to max size
			// - Refill magazine to max size
			// - Extra clip and magazine size
			// - Receive one of the special ammo (incendiary or explosive). (Only available in Left 4 Dead 2.)
			// - Slowly regenerate back to full capacity.
			// 32: Item reward
			// - Give up to five items.
			// 64: God mode reward (temporary)
			// - Automatically kill all special infected attackers.
			// - Immune to all types of damage.
			// - Cannot be flung away by Chargers.
			// - Cannot be pushed around.
			// - Cannot be vomited on by Boomers.
			// - Reduced pushback from Tank punches
			// - Reduced pushback from hitting Tanks with melee immunity.
			// - Get clean kills (blocks Smoker clouds, Boomer explosions, and Spitter acid puddles)
			// 128: Health and ammo refill reward
			// - Refill to 100% health.
			// - Automatically kill any current special infected attacker.
			// - Refill clip to max size
			// - Refill magazine to max size
			// 256: Respawn reward
			// - Respawn and teleport to a teammate.
			// - Restore previous loadout
			// 512: Infinite ammo reward (temporary)
			// - Infinite ammo for primary weapons
			// - Infinite ammo for secondary weapons
			// - Infinite ammo for throwables
			// - Infinite ammo for medkits/defibs/ammo packs
			// - Infinite ammo for pills/adrenaline
			// 1023: All above rewards
			// 1024-2147483647: Reserved for third-party plugins
			// --
			// 1st number = Enable rewards for killers.
			// 2nd number = Enable rewards for assistants.
			// 3rd number = Enable rewards for teammates.
			"Reward Enabled"			"-1,-1,-1"

			// Reward survivor bots for fighting the Mutant Tank.
			// Note: The same rewards cannot be stacked and will not overlap each other to avoid spam.
			// Note: Some rewards may require Lux's "WeaponHandling_API" plugin.
			// Link: https://forums.alliedmods.net/showthread.php?t=319947
			// Note: Some rewards may require patches from the "mutant_tanks_patches.cfg" config file to work.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Add up numbers together for different results.
			// --
			// Minimum value for each: -1
			// Maximum value for each: 2147483647
			// --
			// -1: OFF
			// 0: Random
			// 1: Health reward (temporary)
			// - Refill to 100% health.
			// - Automatically kill any current special infected attacker.
			// - Heal back to 100% health with first aid kits.
			// - Receive 100% temporary health after being revived.
			// - Slowly regenerate back to full health.
			// - Leech health off of any infected per melee hit.
			// 2: Speed boost reward (temporary)
			// - Run faster
			// - Jump higher (Disables the death fall camera for recipients.)
			// - Receive the adrenaline effect for the duration of the reward. (Only available in Left 4 Dead 2.)
			// 4: Damage boost reward (temporary)
			// - Extra damage
			// - Bypass Tank immunities
			// - Damage resistance
			// - Automatically kill Witches.
			// - Hollowpoint ammo
			// - Extended melee range
			// - Sledgehammer rounds
			// - Protected by thorns (deal damage towards attacker per hit taken)
			// 8: Attack boost reward (temporary)
			// - Bypass shove penalty
			// - Shoving Tanks does damage.
			// - Faster shove interval
			// - Faster shoot rate (guns)
			// - Faster reload rate (guns)
			// - Faster swing rate (melee)
			// - Faster throw time (throwables)
			// - Faster revive time
			// - Faster healing time (first aid kit)
			// - Faster defib time (defibrillator)
			// - Faster deploy time (ammo upgrade packs)
			// - Faster pour time (gas cans)
			// - Faster delivery time (cola bottles)
			// - Faster recovery time
			// 16: Ammo reward (temporary)
			// - Refill clip to max size
			// - Refill magazine to max size
			// - Extra clip and magazine size
			// - Receive one of the special ammo (incendiary or explosive). (Only available in Left 4 Dead 2.)
			// - Slowly regenerate back to full capacity.
			// 32: Item reward
			// - Give up to five items.
			// 64: God mode reward (temporary)
			// - Automatically kill all special infected attackers.
			// - Immune to all types of damage.
			// - Cannot be flung away by Chargers.
			// - Cannot be pushed around.
			// - Cannot be vomited on by Boomers.
			// - Reduced pushback from Tank punches
			// - Reduced pushback from hitting Tanks with melee immunity.
			// - Get clean kills (blocks Smoker clouds, Boomer explosions, and Spitter acid puddles)
			// 128: Health and ammo refill reward
			// - Refill to 100% health.
			// - Automatically kill any current special infected attacker.
			// - Refill clip to max size
			// - Refill magazine to max size
			// 256: Respawn reward
			// - Respawn and teleport to a teammate.
			// - Restore previous loadout
			// 512: Infinite ammo reward (temporary)
			// - Infinite ammo for primary weapons
			// - Infinite ammo for secondary weapons
			// - Infinite ammo for throwables
			// - Infinite ammo for medkits/defibs/ammo packs
			// - Infinite ammo for pills/adrenaline
			// 1023: All above rewards
			// 1024-2147483647: Reserved for third-party plugins
			// --
			// 1st number = Enable rewards for killers.
			// 2nd number = Enable rewards for assistants.
			// 3rd number = Enable rewards for teammates.
			"Reward Bots"				"-1,-1,-1"

			// The chance to reward survivors for killing the Mutant Tank.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate chances with commas (",").
			// --
			// Chances limit: 3
			// Character limit for each chance: 6
			// --
			// Minimum value for each chance: 0.0 (No chance)
			// Maximum value for each chance: 100.0 (Highest chance)
			// --
			// 1st number = Chance to reward killers.
			// 2nd number = Chance to reward assistants.
			// 3rd number = Chance to reward teammates.
			"Reward Chance"				"0.0,0.0,0.0"

			// The duration of temporary rewards.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate durations with commas (",").
			// --
			// Durations limit: 3
			// Character limit for each duration: 9
			// --
			// Minimum value for each duration: 0.1 (Shortest)
			// Maximum value for each duration: 999999.0 (Longest)
			// --
			// 1st number = Duration for killer rewards.
			// 2nd number = Duration for assistant rewards.
			// 3rd number = Duration for teammate rewards.
			"Reward Duration"			"0.0,0.0,0.0"

			// The effects displayed when rewarding survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Add up numbers together for different results.
			// --
			// Minimum value for each: 0
			// Maximum value for each: 3
			// --
			// 0: OFF
			// 1: Trophy
			// 2: Fireworks particles
			// 4: Sound effect
			// 8: Thirdperson view
			// --
			// 1st number = Effect for killers.
			// 2nd number = Effect for assistants.
			// 3rd number = Effect for teammates.
			"Reward Effect"				"0,0,0"

			// Notify survivors when they receive a reward from the Mutant Tank.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Add up numbers together for different results.
			// --
			// Minimum value for each: 0
			// Maximum value for each: 3
			// --
			// 0: OFF
			// 1: When survivors solo the Mutant Tank or do not do enough damage to the Mutant Tank.
			// 2: When survivors receive a reward.
			// --
			// 1st number = Notify killers.
			// 2nd number = Notify assistants.
			// 3rd number = Notify teammates.
			"Reward Notify"				"0,0,0"

			// The minimum amount of damage in percentage required to receive a reward.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate percentages with commas (",").
			// --
			// Percentages limit: 3
			// Character limit for each percentage: 6
			// --
			// Minimum value for each percentage: 0.1 (Least)
			// Maximum value for each percentage: 100.0 (All)
			// --
			// 1st number = Percentage of damage required for killer rewards.
			// 2nd number = Percentage of damage required for assistant rewards.
			// 3rd number = Percentage of damage required for teammate rewards.
			"Reward Percentage"			"0.0,0.0,0.0"

			// Prioritize rewards in this order.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0
			// Maximum value for each: 3
			// --
			// 0: OFF (Do not reward anyone.)
			// 1: Reward killers.
			// 2: Reward assistants.
			// 3: Reward teammates.
			// --
			// 1st number = 1st priority
			// 2nd number = 2nd priority
			// 3rd number = 3rd priority
			"Reward Priority"			"0,0,0"

			// The visual effects displayed for rewards.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Add up numbers together for different results.
			// --
			// Minimum value for each: 0
			// Maximum value for each: 31
			// --
			// 0: OFF
			// 1: Screen color
			// 2: Glow outline (Only available in Left 4 Dead 2.)
			// 3: Body color
			// 8: Particle effect
			// 16: Looping voiceline
			// --
			// 1st number = Visual effect for killers.
			// 2nd number = Visual effect for assistants.
			// 3rd number = Visual effect for teammates.
			"Reward Visual"				"0,0,0"

			// The action duration to reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate durations with commas (",").
			// --
			// Durations limit: 3
			// Character limit for each duration: 9
			// --
			// Minimum value for each duration: 0.0 (OFF)
			// Maximum value for each duration: 999999.0 (Slowest)
			// --
			// 1st number = Duration for killers.
			// 2nd number = Duration for assistants.
			// 3rd number = Duration for teammates.
			"Action Duration Reward"		"0.0,0.0,0.0"

			// Give ammo boost as a reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Give ammo boost to killers.
			// 2nd number = Give ammo boost to assistants.
			// 3rd number = Give ammo boost to teammates.
			"Ammo Boost Reward"			"0,0,0"

			// The amount of ammo to regenerate per second as a reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate amounts with commas (",").
			// --
			// Amounts limit: 3
			// Character limit for each amount: 12
			// --
			// Minimum value for each amount: 0 (OFF)
			// Maximum value for each amount: 999999 (Highest)
			// --
			// 1st number = Amount for killers.
			// 2nd number = Amount for assistants.
			// 3rd number = Amount for teammates.
			"Ammo Regen Reward"			"0,0,0"

			// The attack boost to reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate boosts with commas (",").
			// --
			// Boosts limit: 3
			// Character limit for each boost: 9
			// --
			// Minimum value for each boost: 0.0 (OFF)
			// Maximum value for each boost: 999999.0 (Fastest)
			// --
			// 1st number = Boost for killers.
			// 2nd number = Boost for assistants.
			// 3rd number = Boost for teammates.
			"Attack Boost Reward"			"0.0,0.0,0.0"

			// Give clean kills (no Smoker clouds, Boomer explosions, and Spitter acide puddles) as a reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Give clean kills to killers.
			// 2nd number = Give clean kills to assistants.
			// 3rd number = Give clean kills to teammates.
			"Clean Kills Reward"			"0,0,0"

			// The damage boost to reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate boosts with commas (",").
			// --
			// Boosts limit: 3
			// Character limit for each boost: 9
			// --
			// Minimum value for each boost: 0.0 (OFF)
			// Maximum value for each boost: 999999.0 (Strongest)
			// --
			// 1st number = Boost for killers.
			// 2nd number = Boost for assistants.
			// 3rd number = Boost for teammates.
			"Damage Boost Reward"			"0.0,0.0,0.0"

			// The damage resistance to reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate resistances with commas (",").
			// --
			// Resistances limit: 3
			// Character limit for each resistance: 9
			// --
			// Minimum value for each resistance: 0.0 (OFF)
			// Maximum value for each resistance: 1.0 (None)
			// --
			// 1st number = Resistance for killers.
			// 2nd number = Resistance for assistants.
			// 3rd number = Resistance for teammates.
			"Damage Resistance Reward"		"0.0,0.0,0.0"

			// The voiceline that plays when survivors are falling.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate voicelines sets with commas (",").
			// --
			// Item sets limit: 3
			// Character limit for each set: 64
			// --
			// 1st set = Fall voiceline for killers.
			// 2nd set = Fall voiceline for assistants.
			// 3rd set = Fall voiceline for teammates.
			"Fall Voiceline Reward"			""

			// The healing percentage from first aid kits to reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate percentages with commas (",").
			// --
			// Percentages limit: 3
			// Character limit for each percentage: 6
			// --
			// Minimum percentage for each: 0.0 (OFF)
			// Maximum percentage for each: 100.0 (Highest)
			// --
			// 1st number = Heal percentage for killers.
			// 2nd number = Heal percentage for assistants.
			// 3rd number = Heal percentage for teammates.
			"Heal Percent Reward"			"0.0,0.0,0.0"

			// The amount of health to regenerate per second as a reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate amounts with commas (",").
			// --
			// Amounts limit: 3
			// Character limit for each amount: 12
			// --
			// Minimum value for each amount: 0 (OFF)
			// Maximum value for each amount: 1000000 (Highest)
			// --
			// 1st number = Amount for killers.
			// 2nd number = Amount for assistants.
			// 3rd number = Amount for teammates.
			"Health Regen Reward"			"0,0,0"

			// Give hollowpoint ammo as a reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Give hollowpoint ammo to killers.
			// 2nd number = Give hollowpoint ammo to assistants.
			// 3rd number = Give hollowpoint ammo to teammates.
			"Hollowpoint Ammo Reward"		"0,0,0"

			// Give infinite ammo as a reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Add up numbers together for different results.
			// --
			// Minimum value for each: 0
			// Maximum value for each: 31
			// --
			// 0: OFF
			// 1: Infinite ammo for primary weapons
			// 2: Infinite ammo for secondary weapons
			// 4: Infinite ammo for throwables
			// 8: Infinite ammo for medkits/defibs/ammo packs
			// 16: Infinite ammo for pills/adrenaline
			// --
			// 1st number = Give infinite ammo to killers.
			// 2nd number = Give infinite ammo to assistants.
			// 3rd number = Give infinite ammo to teammates.
			"Infinite Ammo Reward"			"0,0,0"

			// The item(s) to reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate item sets with commas (",").
			// Separate items with semi-colons (";").
			// --
			// Item sets limit: 3
			// Character limit for each set: 320
			// --
			// 1st set = Item set to reward killers.
			// 2nd set = Item set to reward assistants.
			// 3rd set = Item set to reward teammates.
			"Item Reward"				""

			// The jump height to reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// Note: Any value above "150.0" may cause instant death from fall damage.
			// --
			// Separate heights with commas (",").
			// --
			// Heights limit: 3
			// Character limit for each height: 9
			// --
			// Minimum value for each height: 0.0 (OFF)
			// Maximum value for each height: 999999.0 (Highest)
			// --
			// 1st number = Height for killers.
			// 2nd number = Height for assistants.
			// 3rd number = Height for teammates.
			"Jump Height Reward"			"0.0,0.0,0.0"

			// Allow a number of Witches to be instantly killed as a reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 999999 (Highest)
			// --
			// 1st number = Number of lady killer bullets to give to killers.
			// 2nd number = Number of lady killer bullets to give to assistants.
			// 3rd number = Number of lady killer bullets to give to teammates.
			"Lady Killer Reward"			"0,0,0"

			// The amount of health to leech per hit as a reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate amounts with commas (",").
			// --
			// Amounts limit: 3
			// Character limit for each amount: 12
			// --
			// Minimum value for each amount: 0 (OFF)
			// Maximum value for each amount: 1000000 (Highest)
			// --
			// 1st number = Amount for killers.
			// 2nd number = Amount for assistants.
			// 3rd number = Amount for teammates.
			"Life Leech Reward"			"0,0,0"

			// The melee range to reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate ranges with commas (",").
			// --
			// Ranges limit: 3
			// Character limit for each range: 6
			// --
			// Minimum value for each range: 0 (OFF)
			// Maximum value for each range: 999999 (Highest)
			// --
			// 1st number = Range for killers.
			// 2nd number = Range for assistants.
			// 3rd number = Range for teammates.
			"Melee Range Reward"			"0,0,0"

			// The punch resistance to reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate resistances with commas (",").
			// --
			// Resistances limit: 3
			// Character limit for each resistance: 6
			// --
			// Minimum value for each resistance: 0.0 (OFF)
			// Maximum value for each resistance: 1.0 (None)
			// --
			// 1st number = Resistance for killers.
			// 2nd number = Resistance for assistants.
			// 3rd number = Resistance for teammates.
			"Punch Resistance Reward"		"0.0,0.0,0.0"

			// Restore the previous loadouts of survivors after respawning them.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Restore loadouts for killers.
			// 2nd number = Restore loadouts for assistants.
			// 3rd number = Restore loadouts for teammates.
			"Respawn Loadout Reward"		"0,0,0"

			// The revive health to reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 12
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1000000 (Highest)
			// --
			// 1st number = Health for killers.
			// 2nd number = Health for assistants.
			// 3rd number = Health for teammates.
			"Revive Health Reward"			"0,0,0"

			// The shove damage multiplier against Chargers, Witches, and Tanks to reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// Note: The max health of the target will be multiplied by this setting's value.
			// --
			// Separate multipliers with commas (",").
			// --
			// Multipliers limit: 3
			// Character limit for each multiplier: 9
			// --
			// Minimum value for each multiplier: 0.0 (OFF)
			// Maximum value for each multiplier: 999999.0 (Strongest)
			// --
			// 1st number = Multiplier for killers.
			// 2nd number = Multiplier for assistants.
			// 3rd number = Multiplier for teammates.
			// --
			// Example: 600 (default Charger health) * 0.025 (shove damage reward) = 15 damage per shove
			"Shove Damage Reward"			"0.0,0.0,0.0"

			// Remove shove penalty as a reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Remove shove penalty for killers.
			// 2nd number = Remove shove penalty for assistants.
			// 3rd number = Remove shove penalty for teammates.
			"Shove Penalty Reward"			"0,0,0"

			// The shove rate to reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// Note: The value of "z_gun_swing_interval" will be multiplied by this setting's value.
			// --
			// Separate rates with commas (",").
			// --
			// Rates limit: 3
			// Character limit for each rate: 9
			// --
			// Minimum value for each rate: 0.0 (OFF)
			// Maximum value for each rate: 999999.0 (Slowest)
			// --
			// 1st number = Rate for killers.
			// 2nd number = Rate for assistants.
			// 3rd number = Rate for teammates.
			// --
			// Example: 0.7 (default "z_gun_swing_interval" value) * 0.7 (shove rate reward) = 0.49 rate
			"Shove Rate Reward"			"0.0,0.0,0.0"

			// Give sledgehammer rounds as a reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Give sledgehammer rounds to killers.
			// 2nd number = Give sledgehammer rounds to assistants.
			// 3rd number = Give sledgehammer rounds to teammates.
			"Sledgehammer Rounds Reward"		"0,0,0"

			// Give special ammo as a reward to survivors. (Only available in Left 4 Dead 2.)
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0
			// Maximum value for each: 3
			// --
			// 0: OFF
			// 1: Incendiary ammo
			// 2: Explosive ammo
			// 4: Random
			// --
			// 1st number = Give special ammo to killers.
			// 2nd number = Give special ammo to assistants.
			// 3rd number = Give special ammo to teammates.
			"Special Ammo Reward"			"0,0,0"

			// The speed boost to reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate boosts with commas (",").
			// --
			// Boosts limit: 3
			// Character limit for each boost: 9
			// --
			// Minimum value for each boost: 0.0 (OFF)
			// Maximum value for each boost: 999999.0 (Fastest)
			// --
			// 1st number = Boost for killers.
			// 2nd number = Boost for assistants.
			// 3rd number = Boost for teammates.
			"Speed Boost Reward"			"0.0,0.0,0.0"

			// Allow rewards from the Mutant Tank to be stacked.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Stack rewards for killers.
			// 2nd number = Stack rewards for assistants.
			// 3rd number = Stack rewards for teammates.
			"Stack Rewards"				"0,0,0"

			// Give thorns as a reward to survivors.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Values limit: 3
			// Character limit for each value: 1
			// --
			// Minimum value for each: 0 (OFF)
			// Maximum value for each: 1 (ON)
			// --
			// 1st number = Give thorns to killers.
			// 2nd number = Give thorns to assistants.
			// 3rd number = Give thorns to teammates.
			"Thorns Reward"				"0,0,0"

			// Include useful reward types depending on the status of the recipient.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with commas (",").
			// --
			// Add up numbers together for different results.
			// --
			// Minimum value for each: 0
			// Maximum value for each: 15
			// --
			// 0: OFF
			// 1: If the recipient is black and white and low on ammunition, they will receive Health and ammo refill as a reward.
			// 2: If the recipient is black and white, they will receive Health as a reward.
			// 4: If the recipient is low on ammunition, they will receive Ammo as a reward.
			// 8: If the recipient is dead, they will receive Respawn as a reward.
			// --
			// 1st number = Enable useful rewards for killers.
			// 2nd number = Enable useful rewards for assistants.
			// 3rd number = Enable useful rewards for teammates.
			"Useful Rewards"			"0,0,0"

			// These are the RGBA values of the recipients' body color visual.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// Note: Any value less than "0" will output a random color.
			// --
			// Separate RGBA sets with commas (",").
			// Separate RGBA values with semi-colons (";").
			// --
			// RGBA sets limit: 3
			// Character limit for each set: 16
			// Character limit for each value: 4
			// --
			// Minimum value for each: -1 (Random)
			// Maximum value for each: 255 (Brightest)
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			// --
			// 1st set = RGBA set for killers.
			// 2nd set = RGBA set for assistants.
			// 3rd set = RGBA set for teammates.
			"Body Color Visual"			""

			// These are the RGB values of the recipients' glow outline color visual.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// Note: Only available in Left 4 Dead 2.
			// Note: Any value less than "0" will output a random color.
			// --
			// Separate RGB sets with commas (",").
			// Separate RGB values with semi-colons (";").
			// --
			// RGBA sets limit: 3
			// Character limit for each set: 12
			// Character limit for each value: 4
			// --
			// Minimum value for each: -1 (Random)
			// Maximum value for each: 255 (Brightest)
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// --
			// 1st set = RGB set for killers.
			// 2nd set = RGB set for assistants.
			// 3rd set = RGB set for teammates.
			"Glow Color Visual"			""

			// The voiceline that plays on loop throughout a survivor's reward duration.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate voicelines sets with commas (",").
			// --
			// Item sets limit: 3
			// Character limit for each set: 64
			// --
			// 1st set = Looping voiceline for killers.
			// 2nd set = Looping voiceline for assistants.
			// 3rd set = Looping voiceline for teammates.
			"Looping Voiceline Visual"		""

			// The particles for the recipients' particle effect visual.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 15
			// --
			// 0: OFF
			// 1: Blood Explosion
			// 2: Electric Jolt
			// 4: Fire Trail
			// 8: Acid Trail (Only available in Left 4 Dead 2.)
			"Particle Effect Visual"		"0,0,0"

			// These are the RGBA values of the recipients' screen color visual.
			// Note: This setting overrides the same setting under the "Plugin Settings/Rewards" section.
			// Note: This setting can be overridden for specific players.
			// Note: Any value less than "0" will output a random color.
			// --
			// Separate RGBA sets with commas (",").
			// Separate RGBA values with semi-colons (";").
			// --
			// RGBA sets limit: 3
			// Character limit for each set: 16
			// Character limit for each value: 4
			// --
			// Minimum value for each: -1 (Random)
			// Maximum value for each: 255 (Brightest)
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			// --
			// 1st set = RGBA set for killers.
			// 2nd set = RGBA set for assistants.
			// 3rd set = RGBA set for teammates.
			"Screen Color Visual"			""
		}
		"Glow"
		{
			// The Mutant Tank will have a glow outline.
			// Note: This setting can be overridden for specific players.
			// Note: Only available in Left 4 Dead 2.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Glow Enabled"				"0"

			// These are the RGB values of the Mutant Tank's glow outline color.
			// Note: This setting can be overridden for specific players.
			// Note: Only available in Left 4 Dead 2.
			// Note: Any value less than "0" will output a random color.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			"Glow Color"				"255,255,255"

			// The Mutant Tank's glow outline will flash.
			// Note: This setting can be overridden for specific players.
			// Note: Only available in Left 4 Dead 2.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Glow Flashing"				"0"

			// The minimum range that a client can be away from the Mutant Tank until the glow outline starts to appear.
			// Note: This setting can be overridden for specific players.
			// Note: Only available in Left 4 Dead 2.
			// --
			// Separate values with "-".
			// --
			// Value limit: 2
			// Character limit for each value: 6
			// --
			// Minimum number for each value: 0 (Unlimited)
			// Maximum number for each value: 999999
			// --
			// 1st number = Minimum value
			// 2nd number = Maximum value
			"Glow Range"				"0-999999"

			// The Mutant Tank's glow outline visibility type.
			// Note: This setting can be overridden for specific players.
			// Note: Only available in Left 4 Dead 2.
			// --
			// 0: Glow outline visible only on sight.
			// 1: Glow outline visible through the walls.
			"Glow Type"				"0"
		}
		"Administration"
		{
			// Admins with one or more of these access flags has access to the Mutant Tank type.
			// Note: This setting overrides the same setting under the "Plugin Settings/Administration" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to all of the Mutant Tank's attacks.
			// Note: This setting overrides the same setting under the "Plugin Settings/Administration" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""
		}
		"Human Support"
		{
			// Allow players to play as the Mutant Tank.
			// --
			// 0: OFF
			// 1: ON, inform players about activating their abilities manually.
			// 2: ON, do not inform players about activating their abilities manually.
			"Human Support"				"0"
		}
		"Spawn"
		{
			// The number of Mutant Tanks with this type that can be alive at any given time.
			// Note: Clones, respawned Mutant Tanks, randomized Tanks, and Mutant Tanks spawned through the Mutant Tanks menu are not affected.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// Minimum: 0 (OFF)
			// Maximum: 32
			"Type Limit"				"0"

			// The Mutant Tank will only spawn on finale maps.
			// Note: Clones, respawned Mutant Tanks, randomized Tanks, and Mutant Tanks spawned through the Mutant Tanks menu are not affected.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// 0: OFF, the Mutant Tank can appear on any map.
			// 1: ON, the Mutant Tank can only appear on finale maps.
			// 2: ON, the Mutant Tank can only appear on non-finale maps.
			// 3: ON, the Mutant Tank can only appear on finale maps before the rescue vehicle is called.
			// 4: ON, the Mutant Tank can only appear on finale maps after the rescue vehicle is called.
			"Finale Tank"				"0"

			// The Mutant Tank can only spawn in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0.0"

			// The mode of the Mutant Tank's spawn status.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Spawn as normal Mutant Tanks.
			// 1: Spawn as Mutant Tank bosses.
			// 2: Spawn as Mutant Tanks that switch randomly between each type.
			// 3: Spawn as Mutant Tanks that temporarily transforms into a different type and reverts back after awhile.
			// 4: Spawn as normal Mutant Tanks that can combine abilities.
			"Spawn Type"				"0"
		}
		"Boss"
		{
			// The health of bosses needed for each stage.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "1".
			// Note: The values will be added to the boss's new health on every new stage.
			// Note: The values will determine when the boss evolves to the next stage.
			// Note: This setting can be overridden for specific players.
			// Example: When Stage 2 boss with 8000 base HP has 2500 HP or less, it will evolve into Stage 3 boss with 10500 HP (8000 + 2500 HP).
			// --
			// Separate abilities with commas (",").
			// --
			// Character limit: 44 (including commas)
			// Health stages limit: 4
			// Character limit for each health stage: 11
			// --
			// Minimum value for each health stage: 1
			// Maximum value for each health stage: 1000000
			// --
			// 1st number = Amount of health of the boss to make it evolve/Amount of health given to Stage 2 boss. (The "Boss Stages" setting must be set to "1" or higher.)
			// 2nd number = Amount of health of the boss to make it evolve/Amount of health given to Stage 3 boss. (The "Boss Stages" setting must be set to "2" or higher.)
			// 3rd number = Amount of health of the boss to make it evolve/Amount of health given to Stage 4 boss. (The "Boss Stages" setting must be set to "3" or higher.)
			// 4th number = Amount of health of the boss to make it evolve/Amount of health given to Stage 5 boss. (The "Boss Stages" setting must be set to "4" or higher.)
			"Boss Health Stages"			"5000,2500,1666,1250"

			// The number of stages for Mutant Tank bosses.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 4
			"Boss Stages"				"4"

			// The Mutant Tank types that the boss will evolve into.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "1".
			// Note: Make sure that the Mutant Tank types that the boss will evolve into are enabled.
			// Note: This setting can be overridden for specific players.
			// Example: When Stage 1 boss evolves into Stage 2, it will evolve into Tank #2.
			// --
			// Separate abilities with commas (",").
			// --
			// Character limit: 20
			// Stage types limit: 4
			// Character limit for each stage type: 5
			// --
			// Minimum: 1
			// Maximum: 500
			// --
			// 1st number = 2nd stage type
			// 2nd number = 3rd stage type
			// 3rd number = 4th stage type
			// 4th number = 5th stage type
			"Boss Types"				"2,3,4,5"
		}
		"Combo"
		{
			// The chance to trigger each ability in the combination.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "4".
			// Note: This setting can be overridden for specific players.
			// --
			// Separate chances with commas (",").
			// --
			// Chances limit: 10
			// Character limit for each chance: 6
			// --
			// Minimum value for each chance: 0.0 (No chance)
			// Maximum value for each chance: 100.0 (Highest chance)
			// --
			// 1st number = Chance to trigger the first ability.
			// 2nd number = Chance to trigger the second ability.
			// 3rd number = Chance to trigger the third ability.
			// 4th number = Chance to trigger the fourth ability.
			// 5th number = Chance to trigger the fifth ability.
			// 6th number = Chance to trigger the sixth ability.
			// 7th number = Chance to trigger the seventh ability.
			// 8th number = Chance to trigger the eighth ability.
			// 9th number = Chance to trigger the ninth ability.
			// 10th number = Chance to trigger the tenth ability.
			"Combo Chance"				"0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0"

			// The damage of each ability in the combination.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "4".
			// Note: This setting can be overridden for specific players.
			// --
			// Separate damages with commas (",").
			// --
			// Damages limit: 10
			// Character limit for each damage: 9
			// --
			// Minimum value for each damage: 0.0 (OFF)
			// Maximum value for each chance: 999999.0 (Strongest)
			// --
			// 1st number = Damage of the first ability.
			// 2nd number = Damage of the second ability.
			// 3rd number = Damage of the third ability.
			// 4th number = Damage of the fourth ability.
			// 5th number = Damage of the fifth ability.
			// 6th number = Damage of the sixth ability.
			// 7th number = Damage of the seventh ability.
			// 8th number = Damage of the eighth ability.
			// 9th number = Damage of the ninth ability.
			// 10th number = Damage of the tenth ability.
			"Combo Damage"				"0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0"

			// The chance to trigger each ability in the combination when the Mutant Tank dies.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "4".
			// Note: This setting can be overridden for specific players.
			// --
			// Separate chances with commas (",").
			// --
			// Chances limit: 10
			// Character limit for each chance: 6
			// --
			// Minimum value for each chance: 0.0 (No chance)
			// Maximum value for each chance: 100.0 (Highest chance)
			// --
			// 1st number = Chance of the first ability.
			// 2nd number = Chance of the second ability.
			// 3rd number = Chance of the third ability.
			// 4th number = Chance of the fourth ability.
			// 5th number = Chance of the fifth ability.
			// 6th number = Chance of the sixth ability.
			// 7th number = Chance of the seventh ability.
			// 8th number = Chance of the eighth ability.
			// 9th number = Chance of the ninth ability.
			// 10th number = Chance of the tenth ability.
			"Combo Death Chance"			"0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0"

			// The range needed to trigger each ability in the combination when the Mutant Tank dies.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "4".
			// Note: This setting can be overridden for specific players.
			// --
			// Separate ranges with commas (",").
			// --
			// Ranges limit: 10
			// Character limit for each range: 9
			// --
			// Minimum value for each range: 0.0 (OFF)
			// Maximum value for each range: 999999.0 (Farthest)
			// --
			// 1st number = Range of the first ability.
			// 2nd number = Range of the second ability.
			// 3rd number = Range of the third ability.
			// 4th number = Range of the fourth ability.
			// 5th number = Range of the fifth ability.
			// 6th number = Range of the sixth ability.
			// 7th number = Range of the seventh ability.
			// 8th number = Range of the eighth ability.
			// 9th number = Range of the ninth ability.
			// 10th number = Range of the tenth ability.
			"Combo Death Range"			"0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0"

			// The delay of each ability in the combination.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "4".
			// Note: This setting can be overridden for specific players.
			// --
			// Separate delays with commas (",").
			// --
			// Delays limit: 10
			// Character limit for each delay: 9
			// --
			// Minimum value for each delay: 0.0 (OFF)
			// Maximum value for each delay: 999999.0 (Longest)
			// --
			// 1st number = Delay of the first ability.
			// 2nd number = Delay of the second ability.
			// 3rd number = Delay of the third ability.
			// 4th number = Delay of the fourth ability.
			// 5th number = Delay of the fifth ability.
			// 6th number = Delay of the sixth ability.
			// 7th number = Delay of the seventh ability.
			// 8th number = Delay of the eighth ability.
			// 9th number = Delay of the ninth ability.
			// 10th number = Delay of the tenth ability.
			"Combo Delay"				"0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0"

			// The duration of each ability in the combination.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "4".
			// Note: This setting can be overridden for specific players.
			// --
			// Separate durations with commas (",").
			// --
			// Durations limit: 10
			// Character limit for each duration: 9
			// --
			// Minimum value for each duration: 0.0 (OFF)
			// Maximum value for each duration: 999999.0 (Longest)
			// --
			// 1st number = Duration of the first ability.
			// 2nd number = Duration of the second ability.
			// 3rd number = Duration of the third ability.
			// 4th number = Duration of the fourth ability.
			// 5th number = Duration of the fifth ability.
			// 6th number = Duration of the sixth ability.
			// 7th number = Duration of the seventh ability.
			// 8th number = Duration of the eighth ability.
			// 9th number = Duration of the ninth ability.
			// 10th number = Duration of the tenth ability.
			"Combo Duration"			"0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0"

			// The interval of each ability in the combination.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "4".
			// Note: This setting can be overridden for specific players.
			// --
			// Separate intervals with commas (",").
			// --
			// Intervals limit: 10
			// Character limit for each interval: 9
			// --
			// Minimum value for each interval: 0.0 (OFF)
			// Maximum value for each interval: 999999.0 (Longest)
			// --
			// 1st number = Interval of the first ability.
			// 2nd number = Interval of the second ability.
			// 3rd number = Interval of the third ability.
			// 4th number = Interval of the fourth ability.
			// 5th number = Interval of the fifth ability.
			// 6th number = Interval of the sixth ability.
			// 7th number = Interval of the seventh ability.
			// 8th number = Interval of the eighth ability.
			// 9th number = Interval of the ninth ability.
			// 10th number = Interval of the tenth ability.
			"Combo Interval"			"0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0"

			// The radius of each ability in the combination.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "4".
			// Note: This setting can be overridden for specific players.
			// --
			// Separate radiuses with commas (",").
			// Separate values with semi-colons (";").
			// --
			// Radiuses limit: 10
			// Character limit for each radius: 14
			// --
			// Minimum value for each radius: -200.0
			// Maximum value for each radius: 200.0
			// --
			// 1st number = Minimum value
			// 2nd number = Maximum value
			// --
			// 1st set = Radius of the first ability.
			// 2nd set = Radius of the second ability.
			// 3rd set = Radius of the third ability.
			// 4th set = Radius of the fourth ability.
			// 5th set = Radius of the fifth ability.
			// 6th set = Radius of the sixth ability.
			// 7th set = Radius of the seventh ability.
			// 8th set = Radius of the eighth ability.
			// 9th set = Radius of the ninth ability.
			// 10th set = Radius of the tenth ability.
			"Combo Radius"				"0.0;0.0,0.0;0.0,0.0;0.0,0.0;0.0,0.0;0.0,0.0;0.0,0.0;0.0,0.0;0.0,0.0;0.0,0.0;0.0"

			// The range of each ability in the combination.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "4".
			// Note: This setting can be overridden for specific players.
			// --
			// Separate ranges with commas (",").
			// --
			// Ranges limit: 10
			// Character limit for each range: 9
			// --
			// Minimum value for each range: 0.0 (OFF)
			// Maximum value for each range: 999999.0 (Farthest)
			// --
			// 1st number = Range of the first ability.
			// 2nd number = Range of the second ability.
			// 3rd number = Range of the third ability.
			// 4th number = Range of the fourth ability.
			// 5th number = Range of the fifth ability.
			// 6th number = Range of the sixth ability.
			// 7th number = Range of the seventh ability.
			// 8th number = Range of the eighth ability.
			// 9th number = Range of the ninth ability.
			// 10th number = Range of the tenth ability.
			"Combo Range"				"0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0"

			// The chance to trigger each ability in the combination when the Mutant Tank is within range of its target.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "4".
			// Note: This setting can be overridden for specific players.
			// --
			// Separate chances with commas (",").
			// --
			// Chances limit: 10
			// Character limit for each chance: 6
			// --
			// Minimum value for each chance: 0.0 (No chance)
			// Maximum value for each chance: 100.0 (Highest chance)
			// --
			// 1st number = Chance of the first ability.
			// 2nd number = Chance of the second ability.
			// 3rd number = Chance of the third ability.
			// 4th number = Chance of the fourth ability.
			// 5th number = Chance of the fifth ability.
			// 6th number = Chance of the sixth ability.
			// 7th number = Chance of the seventh ability.
			// 8th number = Chance of the eighth ability.
			// 9th number = Chance of the ninth ability.
			// 10th number = Chance of the tenth ability.
			"Combo Range Chance"			"0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0"

			// The chance to trigger each ability in the combination when the Mutant Tank throws/breaks a rock.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "4".
			// Note: This setting can be overridden for specific players.
			// --
			// Separate chances with commas (",").
			// --
			// Chances limit: 10
			// Character limit for each chance: 6
			// --
			// Minimum value for each chance: 0.0 (No chance)
			// Maximum value for each chance: 100.0 (Highest chance)
			// --
			// 1st number = Chance of the first ability.
			// 2nd number = Chance of the second ability.
			// 3rd number = Chance of the third ability.
			// 4th number = Chance of the fourth ability.
			// 5th number = Chance of the fifth ability.
			// 6th number = Chance of the sixth ability.
			// 7th number = Chance of the seventh ability.
			// 8th number = Chance of the eighth ability.
			// 9th number = Chance of the ninth ability.
			// 10th number = Chance of the tenth ability.
			"Combo Rock Chance"			"0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0"

			// The set of abilities to combine.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "4".
			// Note: Make sure that the abilities that the Mutant Tank will combine are set up properly.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate abilities with commas (",").
			// --
			// Character limit: 320 (including commas)
			// Abilities limit: 10
			// Character limit for each ability: 32
			// --
			// Example: "fast,slow"
			// Example: "Ghost Ability,WarpAbility"
			// Example: "fire,Pyro_Ability,Fast Ability"
			"Combo Set"				""

			// The speed of each ability in the combination.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "4".
			// Note: This setting can be overridden for specific players.
			// --
			// Separate speeds with commas (",").
			// --
			// Speeds limit: 10
			// Character limit for each speed: 9
			// --
			// Minimum value for each speed: 0.0 (OFF)
			// Maximum value for each speed: 999999.0 (Fastest)
			// --
			// 1st number = Speed of the first ability.
			// 2nd number = Speed of the second ability.
			// 3rd number = Speed of the third ability.
			// 4th number = Speed of the fourth ability.
			// 5th number = Speed of the fifth ability.
			// 6th number = Speed of the sixth ability.
			// 7th number = Speed of the seventh ability.
			// 8th number = Speed of the eighth ability.
			// 9th number = Speed of the ninth ability.
			// 10th number = Speed of the tenth ability.
			"Combo Speed"				"0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0"

			// The chance for each type of abilities to be combined.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "4".
			// Note: This setting can be overridden for specific players.
			// --
			// Separate chances with commas (",").
			// --
			// Chances limit: 6
			// Character limit for each chance: 6
			// --
			// Minimum value for each chance: 0.0 (No chance)
			// Maximum value for each chance: 100.0 (Highest chance)
			// --
			// 1st number = Chance to combine main/range abilities.
			// 2nd number = Chance to combine hit abilities.
			// 3rd number = Chance to combine rock throw abilities.
			// 4th number = Chance to combine rock break abilities.
			// 5th number = Chance to combine post-spawn abilities.
			// 6th number = Chance to combine upon-death abilities.
			"Combo Type Chance"			"0.0,0.0,0.0,0.0,0.0,0.0"
		}
		"Random"
		{
			// The Mutant Tank can be used by other Mutant Tanks who spawn with the Randomization mode feature.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Random Tank"				"1"

			// How long until the Mutant Tank stops randomizing into different types.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Random Duration"			"999999.0"

			// The Mutant Tank switches to a random type every time this many seconds passes.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Random Interval"			"5.0"
		}
		"Transform"
		{
			// The Mutant Tank is able to transform again after this many seconds passes.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "3".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Transform Delay"			"10.0"

			// The Mutant Tank's transformations last this long.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "3".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Transform Duration"			"10.0"

			// The types that the Mutant Tank can transform into.
			// Note: This setting only takes effect when the "Spawn Type" setting is set to "3".
			// Note: This setting can be overridden for specific players.
			// --
			// Separate game modes with commas (",").
			// --
			// Character limit: 50 (including commas)
			// Types limit: 10
			// Character limit for each type: 5
			// --
			// Example: "1,35,26,4"
			// Example: "4,9,49,94,449,499"
			// Example: "97,98,99,100,101,102,103,104,105,106"
			// --
			// Minimum: 1
			// Maximum: 500
			"Transform Types"			"1,2,3,4,5,6,7,8,9,10"
		}
		"Props"
		{
			// Props that the Mutant Tank can spawn with.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 511
			// --
			// 0: OFF
			// 1: Attach a blur effect only.
			// 2: Attach lights only.
			// 4: Attach oxygen tanks only.
			// 8: Attach flames to oxygen tanks.
			// 16: Attach rocks only.
			// 32: Attach tires only.
			// 64: Attach a propane tank only.
			// 128: Attach a flashlight only.
			// 256: Attach a crown only.
			"Props Attached"			"510" // Default is "462" on Left 4 Dead 1.

			// Each prop has this many chances out of 100.0% to appear when the Mutant Tank appears.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate chances with commas (",").
			// --
			// Chances limit: 9
			// Character limit for each chance: 6
			// --
			// Minimum value for each chance: 0.0 (No chance)
			// Maximum value for each chance: 100.0 (Highest chance)
			// --
			// 1st number = Chance for a blur effect to appear.
			// 2nd number = Chance for lights to appear.
			// 3rd number = Chance for oxygen tanks to appear.
			// 4th number = Chance for oxygen tank flames to appear.
			// 5th number = Chance for rocks to appear.
			// 6th number = Chance for tires to appear.
			// 7th number = Chance for a propane tank to appear.
			// 8th number = Chance for a flashlight to appear.
			// 9th number = Chance for a crown to appear.
			"Props Chance"				"33.3,33.3,33.3,33.3,33.3,33.3,33.3,33.3,33.3"

			// These are the RGBA values of the Mutant Tank's light prop's color.
			// Note: The lights will be found on the Tank's mouth and back of hands.
			// Note: Any value less than "0" will output a random color.
			// Note: This setting can be overridden for specific players.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Light Color"				"255,255,255,255"

			// These are the RGBA values of the Mutant Tank's oxygen tank prop's color.
			// Note: The oxygen tanks will be found on both outer sides of the Tank's legs.
			// Note: Any value less than "0" will output a random color.
			// Note: This setting can be overridden for specific players.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Oxygen Tank Color"			"255,255,255,255"

			// These are the RGBA values of the Mutant Tank's oxygen tank prop's flame's color.
			// Note: The flames will be found under the oxygen tanks.
			// Note: Any value less than "0" will output a random color.
			// Note: This setting can be overridden for specific players.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Flame Color"				"255,255,255,255"

			// These are the RGBA values of the Mutant Tank's rock prop's color.
			// Note: The rocks will be found all over both of the Tank's arms in random angles.
			// Note: Any value less than "0" will output a random color.
			// Note: This setting can be overridden for specific players.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Rock Color"				"255,255,255,255"

			// This is the model of the Mutant Tank's rocks, which includes the rocks attached to it and the ones that it throws/spawns.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF, use default model.
			// 1: ON, use tree chunk model.
			// 2: ON, switch between both.
			"Rock Model"				"2"

			// These are the RGBA values of the Mutant Tank's tire prop's color.
			// Note: The tires will be found on both outer sides of the Tank's legs.
			// Note: Any value less than "0" will output a random color.
			// Note: This setting can be overridden for specific players.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Tire Color"				"255,255,255,255"

			// These are the RGBA values of the Mutant Tank's propane tank prop's color.
			// Note: The propane tank will be found on the Tank's head acting like a helmet.
			// Note: Any value less than "0" will output a random color.
			// Note: This setting can be overridden for specific players.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Propane Tank Color"			"255,255,255,255"

			// These are the RGBA values of the Mutant Tank's flashlight's color.
			// Note: The flashlight will be found above the Tank shining down wherever the Tank is standing.
			// Note: Any value less than "0" will output a random color.
			// Note: This setting can be overridden for specific players.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Flashlight Color"			"255,255,255,255"

			// These are the RGBA values of the Mutant Tank's crown prop's color.
			// Note: The crown will be found above the Tank.
			// Note: Any value less than "0" will output a random color.
			// Note: This setting can be overridden for specific players.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Crown Color"				"255,255,255,255"
		}
		"Particles"
		{
			// The particle effects for the Mutant Tank's body.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 127
			// --
			// 0: OFF
			// 1: Blood Explosion
			// 2: Electric Jolt
			// 4: Fire Trail
			// 8: Ice Steam
			// 16: Meteor Smoke
			// 32: Smoker Cloud
			// 64: Acid Trail (Only available in Left 4 Dead 2.)
			"Body Effects"				"0"

			// The particle effects for the Mutant Tank's rock.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 15
			// --
			// 0: OFF
			// 1: Blood Explosion
			// 2: Electric Jolt
			// 4: Fire Trail
			// 8: Acid Trail (Only available in Left 4 Dead 2.)
			"Rock Effects"				"0"
		}
		"Health"
		{
			// Base health given to all Mutant Tanks.
			// Note: Tank's health limit on any difficulty is 1,000,000.
			// Note: Disable this setting if it conflicts with other plugins.
			// Note: Depending on the value of the "Multiply Health" setting, the Mutant Tank's health will be multiplied based on player count.
			// Note: This setting overrides the same setting under the "Plugin Settings/Health" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0 (OFF)
			// Maximum: 1000000
			"Base Health"				"0"

			// Display the Mutant Tank's name and health.
			// Note: This setting overrides the same setting under the "Plugin Settings/Health" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 11
			// --
			// 0: OFF
			// 1: ON, show name only.
			// 2: ON, show health only.
			// 3: ON, show health percentage only.
			// 4: ON, show healthbar only.
			// 5: ON, show name and health only.
			// 6: ON, show name and health percentage only.
			// 7: ON, show name and healthbar only.
			// 8: ON, show health and healthbar only.
			// 9: ON, show health percentage and healthbar only.
			// 10: ON, show name, health, and healthbar.
			// 11: ON, show name, health percentage, and healthbar.
			"Display Health"			"0"

			// Display type of the Mutant Tank's names and health.
			// Note: This setting overrides the same setting under the "Plugin Settings/Health" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, show in hint text.
			// 2: ON, show in center text.
			"Display Health Type"			"0"

			// Extra health given to the Mutant Tank.
			// Note: Tank's health limit on any difficulty is 1,000,000.
			// Note: Disable this setting if it conflicts with other plugins.
			// Note: Depending on the value of the "Multiply Health" setting, the Mutant Tank's health will be multiplied based on player count.
			// Note: This setting overrides the same setting under the "Plugin Settings/Health" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: -1000000
			// Maximum: 1000000
			// --
			// Positive numbers: Current health + Extra health
			// Negative numbers: Current health - Extra health
			"Extra Health"				"0"

			// The characters used to represent the health bar of the Mutant Tank.
			// Note: This setting only takes effect when the "Display Health" setting is enabled.
			// Note: This setting overrides the same setting under the "Plugin Settings/Health" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate characters with commas (",").
			// --
			// Character limit: 2
			// Character limit for each character: 1
			// --
			// 1st character = Health indicator
			// 2nd character = Damage indicator
			"Health Characters"			""

			// The number of human survivors required for the "Multiply Health" setting to take effect.
			// Note: This setting overrides the same setting under the "Plugin Settings/Health" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 32
			// --
			// 1: OFF, no health multiplication. (Health * 1)
			// 2-32: ON, the number of human survivors required to multiply Tank health. (Health * X)
			"Minimum Humans"			"0"

			// Multiply the Mutant Tank's health.
			// Note: Health multiplication only occurs when the requirement for the "Minimum Humans" setting is met.
			// Note: This setting overrides the same setting under the "Plugin Settings/Health" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: No changes to health.
			// 1: Multiply original health only.
			// 2: Multiply extra health only.
			// 3: Multiply both.
			"Multiply Health"			"0"
		}
		"Enhancements"
		{
			// The Mutant Tank can only attack every time this many seconds passes.
			// Note: Default attack interval is 2.0 seconds.
			// Note: This setting overrides the same setting under the "Plugin Settings/Enhancements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// OFF: 0.0
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Attack Interval"			"0.0"

			// The Mutant Tank's claw attacks do this much damage.
			// Note: This setting overrides the same setting under the "Plugin Settings/Enhancements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// OFF: -1.0
			// Minimum: 0.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "nodmg"/"friendly"/"harmless" - 0.0 damage
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Claw Damage"				"-1.0"

			// The Mutant Tank's hittables do this much damage.
			// Note: This setting overrides the same setting under the "Plugin Settings/Enhancements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// OFF: -1.0
			// Minimum: 0.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "nodmg"/"friendly"/"harmless" - 0.0 damage
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Hittable Damage"			"-1.0"

			// The Mutant Tank's punches have this much force.
			// Note: This setting overrides the same setting under the "Plugin Settings/Enhancements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// OFF: -1.0
			// Minimum: 0.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "nodmg"/"friendly"/"harmless" - 0.0 force
			// "weakest" - 1.0 force
			// "strongest" - 999999.0 force
			"Punch Force"				"-1.0"

			// The Mutant Tank has this many chances out of 100.0% to punch and throw a rock simultaneously.
			// Note: This setting overrides the same setting under the "Plugin Settings/Enhancements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Punch Throw"				"0.0"

			// The Mutant Tank's rock throws do this much damage.
			// Note: This setting overrides the same setting under the "Plugin Settings/Enhancements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// OFF: -1.0
			// Minimum: 0.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "nodmg"/"friendly"/"harmless" - 0.0 damage
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Rock Damage"				"-1.0"

			// Set the Mutant Tank's run speed.
			// Note: Default run speed is 1.0.
			// Note: This setting overrides the same setting under the "Plugin Settings/Enhancements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// OFF: 0.0
			// Minimum: 0.1
			// Maximum: 3.0
			"Run Speed"				"0.0"

			// Skip the Mutant Tank's taunting animation after incapacitating survivors.
			// Note: Only available in Left 4 Dead 2.
			// Note: This setting can be used for standard Tanks.
			// Note: This setting can be overridden for each Mutant Tank under the "Enhancements" section of their settings.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Skip Taunt"				"0"

			// The Mutant Tank's punches hit all survivors within range.
			// Note: Both games already do this by default in Versus and Survival modes.
			// Note: This setting overrides the same setting under the "Plugin Settings/Enhancements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Sweep Fist"				"0"

			// The Mutant Tank throws a rock every time this many seconds passes.
			// Note: Default throw interval is 5.0 seconds.
			// Note: This setting overrides the same setting under the "Plugin Settings/Enhancements" section.
			// Note: This setting can be overridden for specific players.
			// --
			// OFF: 0.0
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Throw Interval"			"0.0"
		}
		"Immunities"
		{
			// Give the Mutant Tank bullet immunity.
			// Note: This setting overrides the same setting under the "Plugin Settings/Immunities" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Bullet Immunity"			"0"

			// Give the Mutant Tank explosive immunity.
			// Note: This setting overrides the same setting under the "Plugin Settings/Immunities" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Explosive Immunity"			"0"

			// Give the Mutant Tank fire immunity.
			// Note: This setting overrides the same setting under the "Plugin Settings/Immunities" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Fire Immunity"				"0"

			// Give the Mutant Tank hittable immunity.
			// Note: This setting overrides the same setting under the "Plugin Settings/Immunities" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Hittable Immunity"			"0"

			// Give the Mutant Tank melee immunity.
			// Note: This setting overrides the same setting under the "Plugin Settings/Immunities" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Melee Immunity"			"0"

			// Give the Mutant Tank vomit immunity.
			// Note: This setting overrides the same setting under the "Plugin Settings/Immunities" section.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Vomit Immunity"			"0"
		}
	}
}
```

#### Abilities

##### Absorb Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank absorbs most of the damage it receives.
		// Requires "mt_abilities.smx" to be compiled with "mt_absorb.sp" to work.
		"Absorb Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The bullet damage received by the Mutant Tank is divided by this value.
			// Note: Damage = Bullet damage/Absorb bullet divisor
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Bullet damage/1.0 = Bullet damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Absorb Bullet Divisor"			"20.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Absorb Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Absorb Duration"			"5"

			// The explosive damage received by the Mutant Tank is divided by this value.
			// Note: Damage = Explosive damage/Absorb explosive divisor
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Explosive damage/1.0 = Explosive damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Absorb Explosive Divisor"		"20.0"

			// The fire damage received by the Mutant Tank is divided by this value.
			// Note: Damage = Fire damage/Absorb fire divisor
			// Example: Damage = 300.0/200.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Fire damage/1.0 = Fire damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Absorb Fire Divisor"			"200.0"

			// The hittable damage received by the Mutant Tank is divided by this value.
			// Note: Damage = Hittable damage/Absorb hittable divisor
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Hittable damage/1.0 = Hittable damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Absorb Hittable Divisor"		"20.0"

			// The melee damage received by the Mutant Tank is divided by this value.
			// Note: Damage = Melee damage/Absorb melee divisor
			// Example: Damage = 300.0/200.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Melee damage/1.0 = Melee damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Absorb Melee Divisor"			"200.0"
		}
	}
}
```

##### Acid Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank creates acid puddles. (Replaced by the Puke ability in Left 4 Dead 1.)
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, an acid puddle is created underneath the survivor.
		// - "Acid Range"
		// - "Acid Range Chance"
		// "Acid Death" - When the Mutant Tank dies, an acid puddle is created underneath the Mutant Tank.
		// - "Acid Death Chance"
		// - "Acid Death Range"
		// "Acid Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, an acid puddle is created underneath the survivor.
		// - "Acid Chance"
		// - "Acid Hit Mode"
		// "Acid Rock Break" - When the Mutant Tank's rock breaks, it creates an acid puddle.
		// - "Acid Rock Chance"
		// Requires "mt_abilities.smx" to be compiled with "mt_acid.sp" to work.
		// Note: Only available in Left 4 Dead 2.
		"Acid Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Acid Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the abilities activate/deactivate.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Display message only when "Acid Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// 4: Display message only when "Acid Rock Break" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "hit,ability" - 3
			// "rock" - 4
			// "hit,rock" - 5
			// "ability,rock" - 6
			// "hit,ability,rock"/"all" - 7
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Acid Chance"				"33.3"

			// Enable the Mutant Tank's upon-death range ability.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Acid Death"				"1"

			// The Mutant Tank has this many chances out of 100.0% to trigger the upon-death ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Acid Death Chance"			"33.3"

			// The distance between a survivor and the Mutant Tank needed to trigger the upon-death ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Acid Death Range"			"200.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Acid Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Acid Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Acid Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Acid Range Chance"			"15.0"

			// The Mutant Tank's rock creates an acid puddle when it breaks.
			// Note: This does not need "Ability Enabled" or "Acid Hit" set to "1".
			// Note: This setting can be overridden for specific players.
			// Note: Only available in Left 4 Dead 2.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Acid Rock Break"			"0"

			// The Mutant Tank's rock as this many chances out of 100.0% to trigger the rock break ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Acid Rock Chance"			"33.3"
		}
	}
}
```

##### Aimless Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank prevents survivors from aiming.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor cannot aim.
		// - "Aimless Range"
		// - "Aimless Range Chance"
		// "Aimless Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor cannot aim.
		// - "Aimless Chance"
		// - "Aimless Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_aimless.sp" to work.
		"Aimless Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting does not affect the "Aimless Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Aimless Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Aimless Chance"			"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Aimless Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Aimless Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Aimless Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Aimless Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Aimless Range Chance"			"15.0"
		}
	}
}
```

##### Ammo Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank takes away survivors' ammunition.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, their ammunition is taken away.
		// - "Ammo Range"
		// - "Ammo Range Chance"
		// "Ammo Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, their ammunition is taken away.
		// - "Ammo Chance"
		// - "Ammo Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_ammo.sp" to work.
		"Ammo Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting does not affect the "Ammo Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Ammo Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Ammo Chance"				"33.3"

			// The Mutant Tank sets survivors' ammunition to this amount.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 25
			"Ammo Count"				"0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ammo Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Ammo Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Ammo Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Ammo Range Chance"			"15.0"
		}
	}
}
```

##### Blind Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank blinds survivors.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is blinded.
		// - "Blind Range"
		// - "Blind Range Chance"
		// "Blind Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is blinded.
		// - "Blind Chance"
		// - "Blind Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_blind.sp" to work.
		"Blind Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting does not affect the "Blind Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Blind Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Blind Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Blind Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Blind Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Blind Hit Mode"			"0"

			// The intensity of the Mutant Tank's blind effect.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0 (No effect)
			// Maximum: 255 (Fully blind)
			"Blind Intensity"			"255"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Blind Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Blind Range Chance"			"15.0"
		}
	}
}
```

##### Bomb Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank creates explosions.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, an explosion is created around the survivor. When the Mutant Tank dies, an explosion is created around the Mutant Tank.
		// - "Bomb Range"
		// - "Bomb Range Chance"
		// "Bomb Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, an explosion is created around the survivor.
		// - "Bomb Chance"
		// - "Bomb Hit Mode"
		// "Bomb Rock Break" - When the Mutant Tank's rock breaks, it creates an explosion.
		// - "Bomb Rock Chance"
		// Requires "mt_abilities.smx" to be compiled with "mt_bomb.sp" to work.
		"Bomb Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Bomb Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the abilities activate/deactivate.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Display message only when "Bomb Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// 4: Display message only when "Bomb Rock Break" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "hit,ability" - 3
			// "rock" - 4
			// "hit,rock" - 5
			// "ability,rock" - 6
			// "hit,ability,rock"/"all" - 7
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Bomb Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Bomb Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Bomb Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Bomb Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Bomb Range Chance"			"15.0"

			// The Mutant Tank's rock creates an explosion when it breaks.
			// Note: This does not need "Ability Enabled" or "Bomb Hit" set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Bomb Rock Break"			"0"

			// The Mutant Tank's rock as this many chances out of 100.0% to trigger the rock break ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Bomb Rock Chance"			"33.3"
		}
	}
}
```

##### Bury Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank buries survivors.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is buried.
		// - "Bury Range"
		// - "Bury Range Chance"
		// "Bury Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is buried.
		// - "Bury Chance"
		// - "Bury Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_bury.sp" to work.
		"Bury Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Bury Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Bury Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The amount of temporary health given to survivors recovering from the Mutant Tank's bury ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 1000000.0
			"Bury Buffer"				"100.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Bury Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Bury Duration"				"5.0"

			// The Mutant Tank buries survivors this deep into the ground.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "shortest" - 0.1 height
			// "tallest" - 999999.0 height
			"Bury Height"				"50.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Bury Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Bury Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Bury Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Bury Range Chance"			"15.0"
		}
	}
}
```

##### Car Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank creates car showers.
		// Requires "mt_abilities.smx" to be compiled with "mt_car.sp" to work.
		"Car Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"500.0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Car Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Car Duration"				"5"

			// The Mutant Tank's car shower drops a car every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 1.0
			"Car Interval"				"0.6"

			// Cars dropped by the Mutant Tank's car shower will disappear after this many seconds.
			// Note: The timer starts when the car spawns, so take into account the time it takes to fall to the ground.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Car Lifetime"				"30.0"

			// The Mutant Tank create car showers with these cars.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0 OR 7: Pick randomly between the 3 cars.
			// 1: Small car with a big hatchback.
			// 2: Car that looks like a Chevrolet Impala SS.
			// 4: Car that looks like a Sixth Generation Chevrolet Impala.
			"Car Options"				"0"

			// Set the Mutant Tank as the owner of its cars.
			// Note: This setting is only used for compatibility with Marttt's "Replace Cars Into Car Alarms" plugin. Disable this setting if you do not use that plugin.
			// Link: https://forums.alliedmods.net/showthread.php?t=329806
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Car Owner"				"1"

			// The radius of the Mutant Tank's car shower.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 1st number = Minimum radius
			// Minimum: -200.0
			// Maximum: 0.0
			// --
			// 2nd number = Maximum radius
			// Minimum: 0.0
			// Maximum: 200.0
			"Car Radius"				"-180.0,180.0"
		}
	}
}
```

##### Choke Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank chokes survivors in midair.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is choked in the air.
		// - "Choke Range"
		// - "Choke Range Chance"
		// "Choke Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is choked in the air.
		// - "Choke Chance"
		// - "Choke Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_choke.sp" to work.
		"Choke Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Choke Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Choke Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Choke Chance"				"33.3"

			// The Mutant Tank's chokes do this much damage.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Choke Damage"				"5.0"

			// The Mutant Tank chokes survivors in the air after this many seconds passes upon triggering the ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Choke Delay"				"1.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Choke Duration"			"5"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Choke Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Choke Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Choke Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Choke Range Chance"			"15.0"
		}
	}
}
```

##### Clone Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank creates clones of itself.
		// Requires "mt_abilities.smx" to be compiled with "mt_clone.sp" to work.
		"Clone Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"150.0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The amount of clones the Mutant Tank can create.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 15
			"Clone Amount"				"2"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Clone Chance"				"33.3"

			// The Mutant Tank's clone's health.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 1000000
			"Clone Health"				"1000"

			// Clones created by the Mutant Tank die after this many seconds.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (Until death)
			// Maximum: 999999.0 (Longest)
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever"/"death" - 999999 seconds
			"Clone Lifetime"			"0.0"

			// The Mutant Tank's clone will be treated as a real Mutant Tank.
			// Note: Clones cannot clone themselves regardless of the value for this setting for obvious safety reasons.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF, the clone cannot use abilities like real Mutant Tanks.
			// 1/"enabled"/"true"/"on"/"yes": ON, the clone can use abilities like real Mutant Tanks.
			"Clone Mode"				"0"

			// Remove all clones created by the Mutant Tank when it dies or changes its Mutant Tank type.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Clone Remove"				"1"

			// The Mutant Tank's clones are replaced with new ones when they die.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Clone Replace"				"1"

			// The type of the Mutant Tank's clone.
			// Note: Chosen types that also have the Clone ability will be replaced with the Mutant Tank's own type to prevent bugs.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with "-".
			// --
			// Value limit: 2
			// Character limit for each value: 4
			// --
			// Minimum number for each value: 0 (OFF)
			// Maximum number for each value: 500
			// --
			// 1st number = Minimum value
			// 2nd number = Maximum value
			// --
			// Example: "0-0" (Do not choose from any Mutant Tank types.)
			// Example: "1-25" (Choose a Mutant Tank type between 1 through 25.)
			// Example: "50-0" (Automatically change to "0-0" because "50" is higher than "0".)
			// Example: "1-1000" (Automatically change to "1-500" because "500" is the maximum number of Mutant Tank types allowed.)
			// Example: "0" (Automatically change to "0-500" because the maximum range is not specified.)
			// Example: "1000" (Automatically change to "500-500" because the maximum range is not specified and the minimum range exceeds the "500" limit.)
			// --
			// 0: OFF, use the randomization feature.
			// 1-500: ON, the type of the clone.
			"Clone Type"				"0-0"
		}
	}
}
```

##### Cloud Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank constantly emits clouds of smoke that damage survivors caught in them.
		// Requires "mt_abilities.smx" to be compiled with "mt_cloud.sp" to work.
		"Cloud Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Duration"			"5"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Cloud Chance"				"33.3"

			// The Mutant Tank's clouds do this much damage.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Cloud Damage"				"5.0"
		}
	}
}
```

##### Drop Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank drops weapons upon death.
		// Requires "mt_abilities.smx" to be compiled with "mt_drop.sp" to work.
		"Drop Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Drop Chance"				"33.3"

			// The Mutant Tank has this many chances out of 100.0% to drop guns with a full clip.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Drop Clip Chance"			"33.3"

			// The position of the Mutant Tank's weapon.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0 OR 3: Pick randomly between left and right hands.
			// 1: Right hand.
			// 2: Left hand.
			"Drop Hand Position"			"0"

			// The mode of the Mutant Tank's drop ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Guns only.
			// 2: Melee weapons only. (Only available in Left 4 Dead 2.)
			"Drop Mode"				"0"

			// The console name of the Mutant Tank's weapon.
			// Note: Leave this empty if you want a random weapon to be chosen.
			// Note: This setting can be overridden for specific players.
			// --
			// Weapon limit: 1
			// Character limit: 40
			"Drop Weapon Name"			""

			// The Mutant Tank's weapon size is multiplied by this value.
			// Note: Default weapon size (1.5) x Drop weapon scale
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 2.0
			"Drop Weapon Scale"			"1.0"
		}
	}
}
```

##### Drug Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank drugs survivors.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is drugged.
		// - "Drug Range"
		// - "Drug Range Chance"
		// "Drug Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is drugged.
		// - "Drug Chance"
		// - "Drug Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_drug.sp" to work.
		"Drug Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting does not affect the "Drug Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Drug Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Drug Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Drug Duration"				"5"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Drug Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Drug Hit Mode"				"0"

			// The Mutant Tank drugs survivors every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Drug Interval"				"1.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Drug Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Drug Range Chance"			"15.0"
		}
	}
}
```

##### Drunk Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank makes survivors drunk.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor gets drunk.
		// - "Drunk Range"
		// - "Drunk Range Chance"
		// "Drunk Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor gets drunk.
		// - "Drunk Chance"
		// - "Drunk Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_drunk.sp" to work.
		"Drunk Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Drunk Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Drunk Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Drunk Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Drunk Duration"			"5"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Drunk Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Drunk Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Drunk Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Drunk Range Chance"			"15.0"

			// The Mutant Tank causes the survivors' speed to randomly change every time this many seconds passes.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Drunk Speed Interval"			"1.5"

			// The Mutant Tank causes the survivors to turn at a random direction every time this many seconds passes.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Drunk Turn Interval"			"0.5"
		}
	}
}
```

##### Electric Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank electrocutes survivors.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is electrocuted.
		// - "Electric Range"
		// - "Electric Range Chance"
		// "Electric Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is electrocuted.
		// - "Electric Chance"
		// - "Electric Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_electric.sp" to work.
		"Electric Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Electric Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Electric Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Electric Chance"			"33.3"

			// The Mutant Tank's electrocutions do this much damage.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Electric Damage"			"5.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Electric Duration"			"5"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Electric Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Electric Hit Mode"			"0"

			// The Mutant Tank electrocutes survivors every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Electric Interval"			"1.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Electric Range"			"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Electric Range Chance"			"15.0"
		}
	}
}
```

##### Enforce Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank forces survivors to only use a certain weapon slot.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is forced to only use a certain weapon slot.
		// - "Enforce Range"
		// - "Enforce Range Chance"
		// "Enforce Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is forced to only use a certain weapon slot.
		// - "Enforce Chance"
		// - "Enforce Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_enforce.sp" to work.
		"Enforce Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Enforce Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Enforce Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Enforce Chance"			"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Enforce Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Enforce Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Enforce Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Enforce Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Enforce Range Chance"			"15.0"

			// The Mutant Tank forces survivors to only use one of the following weapon slots.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 31
			// --
			// 0 OR 31: Pick randomly between the 5 slots.
			// 1: 1st slot only.
			// 2: 2nd slot only.
			// 4: 3rd slot only.
			// 8: 4th slot only.
			// 16: 5th slot only.
			"Enforce Weapon Slots"			"0"
		}
	}
}
```

##### Fast Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank runs really fast like the Flash.
		// Requires "mt_abilities.smx" to be compiled with "mt_fast.sp" to work.
		"Fast Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Fast Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Fast Duration"				"5"

			// The Mutant Tank's special speed.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 3.0
			// Maximum: 10.0
			"Fast Speed"				"5.0"
		}
	}
}
```

##### Fire Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank creates fires.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, a fire is created around the survivor. When the Mutant Tank dies, a fire is created around the Mutant Tank.
		// - "Fire Range"
		// - "Fire Range Chance"
		// "Fire Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, a fire is created around the survivor.
		// - "Fire Chance"
		// - "Fire Hit Mode"
		// "Fire Rock Break" - When the Mutant Tank's rock breaks, it creates a fire.
		// - "Fire Rock Chance"
		// Requires "mt_abilities.smx" to be compiled with "mt_fire.sp" to work.
		"Fire Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Fire Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the abilities activate/deactivate.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Display message only when "Fire Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// 4: Display message only when "Fire Rock Break" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "hit,ability" - 3
			// "rock" - 4
			// "hit,rock" - 5
			// "ability,rock" - 6
			// "hit,ability,rock"/"all" - 7
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Fire Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Fire Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Fire Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Fire Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Fire Range Chance"			"15.0"

			// The Mutant Tank's rock creates a fire when it breaks.
			// Note: This does not need "Ability Enabled" or "Fire Hit" set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Fire Rock Break"			"0"

			// The Mutant Tank's rock as this many chances out of 100.0% to trigger the rock break ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Fire Rock Chance"			"33.3"
		}
	}
}
```

##### Fling Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank flings survivors high into the air. (Replaced by the Puke ability in Left 4 Dead 1.)
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is flung into the air.
		// - "Fling Range"
		// - "Fling Range Chance"
		// "Fling Death" - When the Mutant Tank dies, nearby survivors are flung into the air.
		// - "Fling Death Chance"
		// - "Fling Death Range"
		// "Fling Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is flung into the air.
		// - "Fling Chance"
		// - "Fling Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_fling.sp" to work.
		// Note: Only available in Left 4 Dead 2.
		"Fling Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Fling Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Fling Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Fling Chance"				"33.3"

			// Enable the Mutant Tank's upon-death range ability.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Fling Death"				"1"

			// The Mutant Tank has this many chances out of 100.0% to trigger the upon-death ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Fling Death Chance"			"33.3"

			// The distance between a survivor and the Mutant Tank needed to trigger the upon-death ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Fling Death Range"			"200.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Fling Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Fling Hit Mode"			"0"

			// The force of the Mutant Tank's ability.
			// Note: This setting determines how powerful the force is.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			"Fling Force"				"300.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Fling Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Fling Range Chance"			"15.0"
		}
	}
}
```

##### Fly Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank can fly.
		// "Fly Type" - AI (bot) Tanks - When an AI (bot) Tank throws a rock, attacks, gets hurt, or jumps, it has a chance to fly.
		// Requires "mt_abilities.smx" to be compiled with "mt_fly.sp" to work.
		"Fly Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"150.0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Fly Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Fly Duration"				"30"

			// The Mutant Tank's flight ability is this fast.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			"Fly Speed"				"500.0"

			// The type of event that triggers the Mutant Tank's flight ability.
			// Note: This setting does not affect human-controlled Tanks.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 15
			// --
			// 0 OR 15: All types of events.
			// 1: When the Mutant Tank hurts a survivor.
			// 2: When a survivor hurts a Mutant Tank.
			// 4: When the Mutant Tank throws a rock.
			// 8: When the Mutant Tank jumps.
			"Fly Type"				"0"
		}
	}
}
```

##### Fragile Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank takes more damage but becomes stronger.
		// Requires "mt_abilities.smx" to be compiled with "mt_fragile.sp" to work.
		"Fragile Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The bullet damage received by the Mutant Tank is multiplied by this value.
			// Note: Damage = Bullet damage x Fragile bullet multiplier
			// Example: Damage = 30.0 x 5.0 (150.0)
			// Note: Use the value "1.0" to disable this setting. (Bullet damage x 1.0 = Bullet damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Fragile Bullet Multiplier"		"5.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Fragile Chance"			"33.3"

			// The Mutant Tank's damage boost value when fragile.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			"Fragile Damage Boost"			"5.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Fragile Duration"			"5"

			// The explosive damage received by the Mutant Tank is multiplied by this value.
			// Note: Damage = Explosive damage x Fragile explosive multiplier
			// Example: Damage = 30.0 x 5.0 (150.0)
			// Note: Use the value "1.0" to disable this setting. (Explosive damage x 1.0 = Explosive damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Fragile Explosive Multiplier"		"5.0"

			// The fire damage received by the Mutant Tank is multiplied by this value.
			// Note: Damage = Fire damage x Fragile fire multiplier
			// Example: Damage = 30.0 x 3.0 (90.0)
			// Note: Use the value "1.0" to disable this setting. (Fire damage x 1.0 = Fire damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Fragile Fire Multiplier"		"3.0"

			// The hittable damage received by the Mutant Tank is multiplied by this value.
			// Note: Damage = Hittable damage x Fragile hittable multiplier
			// Example: Damage = 100.0 x 1.5 (150.0)
			// Note: Use the value "1.0" to disable this setting. (Hittable damage x 1.0 = Hittable damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Fragile Hittable Multiplier"		"1.5"

			// The melee damage received by the Mutant Tank is multiplied by this value.
			// Note: Damage = Melee damage x Fragile melee multiplier
			// Example: Damage = 100.0 x 1.5 (150.0)
			// Note: Use the value "1.0" to disable this setting. (Melee damage x 1.0 = Melee damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Fragile Melee Multiplier"		"1.5"

			// The mode of the Mutant Tank's damage and speed boosts.
			// Note: This setting can be overridden for specific players.
			// --
			// 0:
			// Mutant Tank's damage = Claw/rock damage + Fragile damage boost
			// Mutant Tank's speed = Run speed + Fragile speed boost
			// 1:
			// Mutant Tank's damage = Fragile damage boost
			// Mutant Tank's speed = Fragile speed boost
			"Fragile Mode"				"0"

			// The Mutant Tank's speed boost value when fragile.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 3.0
			"Fragile Speed Boost"			"1.0"
		}
	}
}
```

##### Ghost Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank cloaks itself and nearby special infected, and disarms survivors.
		// "Ability Enabled" - When the Mutant Tank spawns, it becomes invisible.
		// - "Ghost Fade Alpha"
		// - "Ghost Fade Delay"
		// - "Ghost Fade Limit"
		// - "Ghost Fade Rate"
		// - "Ghost Specials"
		// - "Ghost Specials Chance"
		// - "Ghost Specials Range"
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is disarmed.
		// - "Ghost Range"
		// - "Ghost Range Chance"
		// "Ghost Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is disarmed.
		// - "Ghost Chance"
		// - "Ghost Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_ghost.sp" to work.
		"Ghost Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Duration"			"5"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting does not apply to the range ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Ghost Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, the Mutant Tank can disarm survivors.
			// 2: ON, the Mutant Tank can cloak itself and nearby special infected.
			// 3: ON, the Mutant Tank can do both.
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the abilities activate/deactivate.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Display message only when "Ghost Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is set to "1" or "3".
			// 4: Display message only when "Ability Enabled" is set to "2" or "3".
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "hit,ability" - 3
			// "rock" - 4
			// "hit,rock" - 5
			// "ability,rock" - 6
			// "hit,ability,rock"/"all" - 7
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Ghost Chance"				"33.3"

			// The amount of alpha to take from the Mutant Tank's alpha every X seconds until the limit set by the "Ghost Fade Limit" is reached.
			// Note: The rate at which the Mutant Tank's alpha is reduced depends on the "Ghost Fade Rate" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0 (No effect)
			// Maximum: 255 (Fully faded)
			"Ghost Fade Alpha"			"2"

			// The Mutant Tank's ghost fade effect starts all over after this many seconds passes upon reaching the limit set by the "Ghost Fade Limit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Ghost Fade Delay"			"5"

			// The limit of the Mutant Tank's ghost fade effect.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0 (Fully faded)
			// Maximum: 255 (No effect)
			"Ghost Fade Limit"			"0"

			// The rate of the Mutant Tank's ghost fade effect.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1 (Fastest)
			// Maximum: 999999.0 (Slowest)
			"Ghost Fade Rate"			"0.1"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ghost Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Ghost Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Ghost Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Ghost Range Chance"			"15.0"

			// The Mutant Tank can cloak nearby special infected.
			// Note: This setting needs "Ability Enabled" to be set to "2" or higher than "3".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ghost Specials"			"1"

			// The Mutant Tank has this many chances out of 100.0% to cloak nearby special infected.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Ghost Specials Chance"			"33.3"

			// The distance between a special infected and the Mutant Tank needed to cloak that special infected.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Ghost Specials Range"			"500.0"

			// The Mutant Tank disarms the following weapon slots.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 31
			// --
			// 0 OR 31: All 5 slots.
			// 1: 1st slot only.
			// 2: 2nd slot only.
			// 4: 3rd slot only.
			// 8: 4th slot only.
			// 16: 5th slot only.
			"Ghost Weapon Slots"			"0"
		}
	}
}
```

##### God Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank gains temporary immunity to all types of damage.
		// Requires "mt_abilities.smx" to be compiled with "mt_god.sp" to work.
		"God Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"God Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"God Duration"				"5"
		}
	}
}
```

##### Gravity Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank pulls in or pushes away survivors and any other nearby infected, and changes the survivors' gravity.
		// "Ability Enabled" - Any nearby infected and survivors are pulled in or pushed away.
		// - "Gravity Force"
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor's gravity changes.
		// - "Gravity Range"
		// - "Gravity Range Chance"
		// "Gravity Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor's gravity changes.
		// - "Gravity Chance"
		// - "Gravity Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_gravity.sp" to work.
		"Gravity Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting does not apply to the range ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Gravity Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, the Mutant Tank can change survivors' gravity value.
			// 2: ON, the Mutant Tank can pull in or push away survivors.
			// 3: ON, the Mutant Tank can do both.
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the abilities activate/deactivate.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Display message only when "Gravity Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is set to "1" or "3".
			// 4: Display message only when "Ability Enabled" is set to "2" or "3".
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "hit,ability" - 3
			// "rock" - 4
			// "hit,rock" - 5
			// "ability,rock" - 6
			// "hit,ability,rock"/"all" - 7
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Gravity Chance"			"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Gravity Duration"			"5"

			// The Mutant Tank's gravity force.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: -100.0
			// Maximum: 100.0
			// --
			// Positive numbers = Push back
			// Negative numbers = Pull back
			"Gravity Force"				"-50.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Gravity Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Gravity Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Gravity Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Gravity Range Chance"			"15.0"

			// The Mutant Tank sets the survivors' gravity to this value.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			"Gravity Value"				"0.3"
		}
	}
}
```

##### Heal Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank gains health from other nearby infected and sets survivors to temporary health who will die when they reach 0 HP.
		// "Ability Enabled" - Any nearby infected can give the Mutant Tank some health.
		// - "Heal Absorb Range"
		// - "Heal Interval"
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is set to temporary health and will die when they reach 0 HP.
		// - "Heal Range"
		// - "Heal Range Chance"
		// "Heal Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is set to temporary health and will die when they reach 0 HP.
		// - "Heal Chance"
		// - "Heal Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_heal.sp" to work.
		"Heal Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Duration"			"5"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting does not apply to the range ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Heal Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, the Mutant Tank can give survivors temporary health.
			// 2: ON, the Mutant Tank can absorb health from nearby infected.
			// 3: ON, the Mutant Tank can do both.
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the abilities activate/deactivate.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Display message only when "Heal Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is set to "1" or "3".
			// 4: Display message only when "Ability Enabled" is set to "2" or "3".
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "hit,ability" - 3
			// "rock" - 4
			// "hit,rock" - 5
			// "ability,rock" - 6
			// "hit,ability,rock"/"all" - 7
			"Ability Message"			"0"

			// The distance between an infected and the Mutant Tank needed to trigger the ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Heal Absorb Range"			"500.0"

			// The amount of temporary health given to survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 1000000.0
			"Heal Buffer"				"100.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Heal Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Heal Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Heal Hit Mode"				"0"

			// The Mutant Tank receives health from nearby infected every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Heal Interval"				"5.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Heal Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Heal Range Chance"			"15.0"

			// The Mutant Tank receives this much health from nearby common infected.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: -1000000
			// Maximum: 1000000
			// --
			// Positive numbers: Current health + Health from commons
			// Negative numbers: Current health - Health from commons
			"Health From Commons"			"50"

			// The Mutant Tank receives this much health from other nearby special infected.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: -1000000
			// Maximum: 1000000
			// --
			// Positive numbers: Current health + Health from specials
			// Negative numbers: Current health - Health from specials
			"Health From Specials"			"100"

			// The Mutant Tank receives this much health from other nearby Tanks.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: -1000000
			// Maximum: 1000000
			// --
			// Positive numbers: Current health + Health from Tanks
			// Negative numbers: Current health - Health from Tanks
			"Health From Tanks"			"500"
		}
	}
}
```

##### Hit Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank only takes damage in certain parts of its body.
		// Requires "mt_abilities.smx" to be compiled with "mt_hit.sp" to work.
		"Hit Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON, players can use buttons to activate abilities.
			"Human Ability"				"0"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// The damage received by the Mutant Tank is multiplied by this value.
			// Note: Damage = Damage x Hit damage multiplier
			// Example: Damage = 30.0 x 1.5 (45.0)
			// Note: Use the value "1.0" to disable this setting. (Damage x 1.0 = Damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Hit Damage Multiplier"			"1.5"

			// The only part of the Mutant Tank that can be damaged.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 1
			// Maximum: 127
			// --
			// 1: Headshots only.
			// 2: Chest shots only.
			// 4: Stomach shots only.
			// 8: Left arm shots only.
			// 16: Right arm shots only.
			// 32: Left leg shots only.
			// 64: Right leg shots only.
			"Hit Group"				"1"
		}
	}
}
```

##### Hurt Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank repeatedly hurts survivors.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor gets hurt repeatedly.
		// - "Hurt Range"
		// - "Hurt Range Chance"
		// "Hurt Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor gets hurt repeatedly.
		// - "Hurt Chance"
		// - "Hurt Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_hurt.sp" to work.
		"Hurt Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Hurt Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Hurt Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Hurt Chance"				"33.3"

			// The Mutant Tank's pain inflictions do this much damage.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Hurt Damage"				"5.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Hurt Duration"				"5"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Hurt Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Hurt Hit Mode"				"0"

			// The Mutant Tank hurts survivors every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Hurt Interval"				"1.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Hurt Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Hurt Range Chance"			"15.0"
		}
	}
}
```

##### Hypno Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank hypnotizes survivors to damage themselves or their teammates.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is hypnotized.
		// - "Hypno Range"
		// - "Hypno Range Chance"
		// "Hypno Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is hypnotized.
		// - "Hypno Chance"
		// - "Hypno Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_hypno.sp" to work.
		"Hypno Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Hypno Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Hypno Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The bullet damage reflected towards survivors by the Mutant Tank is divided by this value.
			// Note: Damage = Bullet damage/Hypno bullet divisor
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Bullet damage/1.0 = Bullet damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Hypno Bullet Divisor"			"20.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Hypno Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Hypno Duration"			"5.0"

			// The explosive damage reflected towards survivors by the Mutant Tank is divided by this value.
			// Note: Damage = Explosive damage/Hypno explosive divisor
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Explosive damage/1.0 = Explosive damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Hypno Explosive Divisor"		"20.0"

			// The fire damage reflected towards survivors by the Mutant Tank is divided by this value.
			// Note: Damage = Fire damage/Hypno fire divisor
			// Example: Damage = 300.0/200.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Fire damage/1.0 = Fire damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Hypno Fire Divisor"			"200.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Hypno Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Hypno Hit Mode"			"0"

			// The hittable damage reflected towards survivors by the Mutant Tank is divided by this value.
			// Note: Damage = Hittable damage/Hypno hittable divisor
			// Example: Damage = 30.0/20.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Hittable damage/1.0 = Hittable damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Hypno Hittable Divisor"		"20.0"

			// The melee damage reflected towards survivors by the Mutant Tank is divided by this value.
			// Note: Damage = Melee damage/Hypno melee divisor
			// Example: Damage = 300.0/200.0 (1.5)
			// Note: Use the value "1.0" to disable this setting. (Melee damage/1.0 = Melee damage)
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Hypno Melee Divisor"			"200.0"

			// The mode of the Mutant Tank's hypno ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Hypnotized survivors hurt themselves.
			// 1: Hypnotized survivors can hurt their teammates.
			"Hypno Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Hypno Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Hypno Range Chance"			"15.0"
		}
	}
}
```

##### Ice Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank freezes survivors.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is frozen in place.
		// - "Ice Range"
		// - "Ice Range Chance"
		// "Ice Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is frozen in place.
		// - "Ice Chance"
		// - "Ice Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_ice.sp" to work.
		"Ice Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Ice Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Ice Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Ice Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Ice Duration"				"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ice Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Ice Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Ice Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Ice Range Chance"			"15.0"
		}
	}
}
```

##### Idle Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank forces survivors to go idle.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor goes idle.
		// - "Idle Range"
		// - "Idle Range Chance"
		// "Idle Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor goes idle.
		// - "Idle Chance"
		// - "Idle Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_idle.sp" to work.
		"Idle Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting does not affect the "Idle Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Idle Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Idle Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Idle Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Idle Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Idle Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Idle Range Chance"			"15.0"
		}
	}
}
```

##### Invert Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank inverts the survivors' movement keys.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor's movement keys are inverted.
		// - "Invert Range"
		// - "Invert Range Chance"
		// "Invert Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor's movement keys are inverted.
		// - "Invert Chance"
		// - "Invert Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_invert.sp" to work.
		"Invert Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Invert Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Invert Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Invert Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Invert Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Invert Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Invert Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Invert Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Invert Range Chance"			"15.0"
		}
	}
}
```

##### Item Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank gives survivors items upon death.
		// "Ability Enabled" - When the Mutant Tank dies, it gives survivors items.
		// - "Item Chance"
		// - "Item Loadout"
		// - "Item Mode"
		// "Item Pinata" - When the Mutant Tank kills a survivor, the survivor drops items.
		// - "Item Pinata Body"
		// - "Item Pinata Chance"
		// Requires "mt_abilities.smx" to be compiled with "mt_item.sp" to work.
		"Item Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Item Chance"				"33.3"

			// The Mutant Tank gives survivors this loadout.
			// Note: This setting can be overridden for specific players.
			// --
			// Item limit: 5
			// Character limit for each item: 64
			// --
			// Example: "rifle_m60,pistol,adrenaline,defibrillator"
			// Example: "katana,pain_pills,vomitjar"
			// Example: "first_aid_kit,defibrillator,knife,adrenaline"
			"Item Loadout"				"rifle,pistol,first_aid_kit,pain_pills"

			// The mode of the Mutant Tank's item ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Survivors get a random item.
			// 1: Survivors get all items.
			"Item Mode"				"0"

			// The Mutant Tank turns its dead survivor victims into pinatas that spawn certain items.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Item limit: 5
			// Character limit for each item: 64
			// --
			// Example: "pain_pills,pain_pills,pain_pills"
			// Example: "katana,katana,rifle_m60"
			// Example: "first_aid_kit,defibrillator,first_aid_kit,defibrillator"
			"Item Pinata"				""

			// Removes the death model of the survivor when killed.
			// Note: This setting only applies if the "Item Pinata" setting is not empty.
			// Note: This setting can be overridden for specific players.
			// Note: Only available in Left 4 Dead 2.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Item Pinata Body"			"1"

			// The Mutant Tank has this many chances out of 100.0% to turn its dead survivor victims into pinatas.
			// Note: This setting only applies if the "Item Pinata" setting is not empty.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Item Pinata Chance"			"33.3"
		}
	}
}
```

##### Jump Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank jumps periodically or sporadically and makes survivors jump uncontrollably.
		// "Ability Enabled" - The Mutant Tank jumps periodically or sporadically.
		// - "Jump Interval"
		// - "Jump Mode"
		// - "Jump Sporadic Chance"
		// - "Jump Sporadic Height"
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor jumps uncontrollably.
		// - "Jump Range"
		// - "Jump Range Chance"
		// "Jump Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor jumps uncontrollably.
		// - "Jump Chance"
		// - "Jump Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_jump.sp" to work.
		"Jump Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting does not apply to the range ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Jump Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, the Mutant Tank can force survivors to jump uncontrollably.
			// 2: ON, the Mutant Tank can jump periodically.
			// 3: ON, the Mutant Tank can do both.
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the abilities activate/deactivate.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Display message only when "Jump Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is set to "1" or "3".
			// 4: Display message only when "Ability Enabled" is set to "2" or "3".
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "hit,ability" - 3
			// "rock" - 4
			// "hit,rock" - 5
			// "ability,rock" - 6
			// "hit,ability,rock"/"all" - 7
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Jump Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Jump Duration"				"5"

			// The Mutant Tank and survivors jump this high off a surface.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "shortest" - 0.1 height
			// "tallest" - 999999.0 height
			"Jump Height"				"300.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Jump Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Jump Hit Mode"				"0"

			// The Mutant Tank jumps every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Jump Interval"				"1.0"

			// The mode of the Mutant Tank's jumping ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: The Mutant Tank jumps periodically.
			// 1: The Mutant Tank jumps sporadically.
			"Jump Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Jump Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Jump Range Chance"			"15.0"

			// The Mutant Tank has this many chances out of 100.0% to jump sporadically.
			// Note: This setting only applies if the "Jump Mode" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Jump Sporadic Chance"			"33.3"

			// The Mutant Tank jumps this high up into the air.
			// Note: This setting only applies if the "Jump Mode" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "shortest" - 0.1 height
			// "tallest" - 999999.0 height
			"Jump Sporadic Height"			"750.0"
		}
	}
}
```

##### Kamikaze Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank kills itself along with a survivor victim.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor dies along with the Mutant Tank.
		// - "Kamikaze Range"
		// - "Kamikaze Range Chance"
		// "Kamikaze Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor dies along with the Mutant Tank.
		// - "Kamikaze Chance"
		// - "Kamikaze Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_kamikaze.sp" to work.
		"Kamikaze Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Kamikaze Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Kamikaze Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// Removes the death model of the survivor when killed.
			// Note: This setting can be overridden for specific players.
			// Note: Only available in Left 4 Dead 2.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Kamikaze Body"				"1"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Kamikaze Chance"			"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Kamikaze Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Kamikaze Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Kamikaze Range"			"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Kamikaze Range Chance"			"15.0"
		}
	}
}
```

##### Lag Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank makes survivors lag.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor lags.
		// - "Lag Range"
		// - "Lag Range Chance"
		// "Lag Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor lags.
		// - "Lag Chance"
		// - "Lag Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_lag.sp" to work.
		"Lag Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting does not affect the "Lag Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Lag Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Lag Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Lag Duration"				"5"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Lag Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Lag Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Lag Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Lag Range Chance"			"15.0"
		}
	}
}
```

##### Laser Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank shoots lasers.
		// Requires "mt_abilities.smx" to be compiled with "mt_laser.sp" to work.
		"Laser Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Laser Chance"				"33.3"

			// The Mutant Tank's lasers do this much damage.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Laser Damage"				"5.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Laser Duration"			"5"

			// The Mutant Tank shoots lasers at survivors every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Laser Interval"			"1.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Laser Range"				"150.0"
		}
	}
}
```

##### Leech Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank leeches health off of survivors.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the Mutant Tank leeches health off of the survivor.
		// - "Leech Range"
		// - "Leech Range Chance"
		// "Leech Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the Mutant Tank leeches health off of the survivor.
		// - "Leech Chance"
		// - "Leech Hit Mode"
		// Requires "mt_abilities.smx" to be compiled with "mt_leech.sp" to work.
		"Leech Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Leech Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Leech Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Leech Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Leech Duration"			"5"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Leech Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Leech Hit Mode"			"0"

			// The Mutant Tank leeches health off of survivors every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Leech Interval"			"1.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Leech Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Leech Range Chance"			"15.0"
		}
	}
}
```

##### Lightning Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank creates lightning storms.
		// Requires "mt_abilities.smx" to be compiled with "mt_lightning.sp" to work.
		// Note: Only available in Left 4 Dead 2.
		"Lightning Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Lightning Chance"			"33.3"

			// The Mutant Tank's lightning storm strikes cause this much damage per hit.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Lightning Damage"			"5.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Lightning Duration"			"5"

			// The Mutant Tank's lightning storm strikes every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Lightning Interval"			"1.0"
		}
	}
}
```

##### Medic Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank heals nearby special infected.
		// Requires "mt_abilities2.smx" to be compiled with "mt_medic.sp" to work.
		"Medic Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Duration"			"5"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Medic Chance"				"33.3"

			// The Mutant Tank creates a healing field visual effect around it when healing fellow special infected.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Medic Field"				"1"

			// These are the RGB values of the Mutant Tank's healing field's color.
			// Note: Any value less than "0" will output a random color.
			// Note: This setting can be overridden for specific players.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			"Medic Field Color"			"0,255,0"

			// The Mutant Tank gives special infected this much health each time.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: -1000000
			// Maximum: 1000000
			// --
			// Positive numbers: Current health + Medic health
			// Negative numbers: Current health - Medic health
			// --
			// 1st number = Health given to Smokers.
			// 2nd number = Health given to Boomers.
			// 3rd number = Health given to Hunters.
			// 4th number = Health given to Spitters.
			// 5th number = Health given to Jockeys.
			// 6th number = Health given to Chargers.
			// 7th number = Health given to Tanks.
			"Medic Health"				"25,25,25,25,25,25,25"

			// The Mutant Tank heals nearby special infected every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Medic Interval"			"5.0"

			// The special infected's max health.
			// Note: The Mutant Tank will not heal special infected if they already have this much health.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 1000000
			// --
			// 1st number = Smoker's maximum health.
			// 2nd number = Boomer's maximum health.
			// 3rd number = Hunter's maximum health.
			// 4th number = Spitter's maximum health.
			// 5th number = Jockey's maximum health.
			// 6th number = Charger's maximum health.
			// 7th number = Tank's maximum health.
			"Medic Max Health"			"250,50,250,100,325,600,8000"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Medic Range"				"500.0"
		}
	}
}
```

##### Meteor Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank creates meteor showers.
		// Requires "mt_abilities2.smx" to be compiled with "mt_meteor.sp" to work.
		"Meteor Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"500.0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Meteor Chance"				"33.3"

			// The Mutant Tank's meteorites do this much damage.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting only applies if the "Meteor Mode" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Meteor Damage"				"5.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Meteor Duration"			"5"

			// The Mutant Tank's meteor shower drops a meteorite every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 1.0
			"Meteor Interval"			"0.6"

			// Meteorites dropped by the Mutant Tank's meteor shower will disappear after this many seconds.
			// Note: The timer starts when the meteorite spawns, so take into account the time it takes to fall to the ground.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Meteor Lifetime"				"15.0"

			// The mode of the Mutant Tank's meteor shower ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: The Mutant Tank's meteorites will explode and start fires.
			// 1: The Mutant Tank's meteorites will explode and damage and push back nearby survivors.
			"Meteor Mode"				"0"

			// The radius of the Mutant Tank's meteor shower.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 1st number = Minimum radius
			// Minimum: -200.0
			// Maximum: 0.0
			// --
			// 2nd number = Maximum radius
			// Minimum: 0.0
			// Maximum: 200.0
			"Meteor Radius"				"-180.0,180.0"
		}
	}
}
```

##### Minion Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank spawns minions.
		// Requires "mt_abilities2.smx" to be compiled with "mt_minion.sp" to work.
		"Minion Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"150.0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The amount of minions the Mutant Tank can spawn.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 15
			"Minion Amount"				"5"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Minion Chance"				"33.3"

			// Minions spawned by the Mutant Tank die after this many seconds.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (Until death)
			// Maximum: 999999.0 (Longest)
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever"/"death" - 999999 seconds
			"Minion Lifetime"			"0.0"

			// Remove all minions spawned by the Mutant Tank when it dies or changes its Mutant Tank type.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Minion Remove"				"1"

			// The Mutant Tank's minions are replaced with new ones when they die.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Minion Replace"			"1"

			// The Mutant Tank spawns these minions.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 63
			// --
			// 0 OR 63: Pick randomly between the 6 types.
			// 1: Smoker
			// 2: Boomer
			// 4: Hunter
			// 8: Spitter (Switches to Boomer in Left 4 Dead 1.)
			// 16: Jockey (Switches to Hunter in Left 4 Dead 1.)
			// 32: Charger (Switches to Smoker in Left 4 Dead 1.)
			"Minion Types"				"63"
		}
	}
}
```

##### Necro Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank resurrects nearby special infected that die.
		// Requires "mt_abilities2.smx" to be compiled with "mt_necro.sp" to work.
		"Necro Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Duration"			"5"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Necro Chance"				"33.3"

			// The distance between a special infected and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Necro Range"				"500.0"
		}
	}
}
```

##### Nullify Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank nullifies all of the survivors' damage.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor does not do any damage to the Mutant Tank.
		// - "Nullify Range"
		// - "Nullify Range Chance"
		// "Nullify Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor does not do any damage to the Mutant Tank.
		// - "Nullify Chance"
		// - "Nullify Hit Mode"
		// Requires "mt_abilities2.smx" to be compiled with "mt_nullify.sp" to work.
		"Nullify Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting does not affect the "Nullify Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Nullify Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Nullify Chance"			"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Nullify Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Nullify Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Nullify Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Nullify Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Nullify Range Chance"			"15.0"
		}
	}
}
```

##### Omni Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank has omni-level access to other nearby Mutant Tanks' abilities.
		// Requires "mt_abilities2.smx" to be compiled with "mt_omni.sp" to work.
		"Omni Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Omni Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Omni Duration"				"5"

			// The mode of the Mutant Tank's omni ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: The Mutant Tank's type becomes the same as the nearby Mutant Tank's type.
			// 1: The Mutant Tank physically transforms into the nearby Mutant Tank.
			"Omni Mode"				"0"

			// The distance between another Mutant Tank and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Omni Range"				"500.0"
		}
	}
}
```

##### Panic Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank starts panic events.
		// Requires "mt_abilities2.smx" to be compiled with "mt_panic.sp" to work.
		"Panic Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Duration"			"5"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Panic Chance"				"33.3"

			// The Mutant Tank starts a panic event every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Panic Interval"			"5.0"
		}
	}
}
```

##### Pimp Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank pimp slaps survivors.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is repeatedly pimp slapped.
		// - "Pimp Range"
		// - "Pimp Range Chance"
		// "Pimp Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is repeatedly pimp slapped.
		// - "Pimp Chance"
		// - "Pimp Hit Mode"
		// Requires "mt_abilities2.smx" to be compiled with "mt_pimp.sp" to work.
		"Pimp Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Pimp Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Pimp Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Pimp Chance"				"33.3"

			// The Mutant Tank's pimp slaps do this much damage.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Pimp Damage"				"5"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Pimp Duration"				"5"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Pimp Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Pimp Hit Mode"				"0"

			// The Mutant Tank pimp slaps survivors every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Pimp Interval"				"1.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Pimp Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Pimp Range Chance"			"15.0"
		}
	}
}
```

##### Puke Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank pukes on survivors.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the Mutant Tank pukes on the survivor.
		// - "Puke Range"
		// - "Puke Range Chance"
		// "Puke Death" - When the Mutant Tank dies, nearby survivors are puked on.
		// - "Puke Death Chance"
		// - "Puke Death Range"
		// "Puke Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the Mutant Tank pukes on the survivor.
		// - "Puke Chance"
		// - "Puke Hit Mode"
		// Requires "mt_abilities2.smx" to be compiled with "mt_puke.sp" to work.
		"Puke Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Puke Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Puke Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Puke Chance"				"33.3"

			// Enable the Mutant Tank's upon-death range ability.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Puke Death"				"1"

			// The Mutant Tank has this many chances out of 100.0% to trigger the upon-death ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Puke Death Chance"			"33.3"

			// The distance between a survivor and the Mutant Tank needed to trigger the upon-death ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Puke Death Range"			"200.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Puke Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Puke Hit Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Puke Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Puke Range Chance"			"15.0"
		}
	}
}
```

##### Pyro Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank ignites itself and gains a speed boost when on fire.
		// Requires "mt_abilities2.smx" to be compiled with "mt_pyro.sp" to work.
		"Pyro Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Pyro Chance"				"33.3"

			// The Mutant Tank's damage boost value when on fire.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			"Pyro Damage Boost"			"5.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Pyro Duration"				"5"

			// The mode of the Mutant Tank's damage and speed boosts.
			// Note: This setting can be overridden for specific players.
			// --
			// 0:
			// Mutant Tank's damage = Claw/rock damage + Pyro damage boost
			// Mutant Tank's speed = Run speed + Pyro speed boost
			// 1:
			// Mutant Tank's damage = Pyro damage boost
			// Mutant Tank's speed = Pyro speed boost
			"Pyro Mode"				"0"

			// The Mutant Tank will be reignited if it is extinguished while the ability is still activated.
			// Note: This setting will automatically deactivate the ability if set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Pyro Reignite"				"1"

			// The Mutant Tank's speed boost value when on fire.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 3.0
			"Pyro Speed Boost"			"1.0"
		}
	}
}
```

##### Quiet Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank silences itself around survivors.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor cannot hear the Mutant Tank's sounds.
		// - "Quiet Range"
		// - "Quiet Range Chance"
		// "Quiet Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor cannot hear the Mutant Tank's sounds.
		// - "Quiet Chance"
		// - "Quiet Hit Mode"
		// Requires "mt_abilities2.smx" to be compiled with "mt_quiet.sp" to work.
		"Quiet Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting does not affect the "Quiet Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Quiet Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Quiet Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Quiet Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Quiet Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Quiet Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Quiet Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Quiet Range Chance"			"15.0"
		}
	}
}
```

##### Recoil Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank gives survivors strong gun recoil.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor experiences strong recoil.
		// - "Recoil Range"
		// - "Recoil Range Chance"
		// "Recoil Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor experiences strong recoil.
		// - "Recoil Chance"
		// - "Recoil Hit Mode"
		// Requires "mt_abilities2.smx" to be compiled with "mt_recoil.sp" to work.
		"Recoil Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting does not affect the "Recoil Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Recoil Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Recoil Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Recoil Duration"			"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Recoil Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Recoil Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Recoil Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Recoil Range Chance"			"15.0"
		}
	}
}
```

##### Regen Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank regenerates health.
		// Requires "mt_abilities2.smx" to be compiled with "mt_regen.sp" to work.
		"Regen Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Duration"			"5"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Regen Chance"				"33.3"

			// The Mutant Tank regenerates this much health each time.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: -1000000
			// Maximum: 1000000
			// --
			// Positive numbers: Current health + Regen health
			// Negative numbers: Current health - Regen health
			"Regen Health"				"1"

			// The Mutant Tank regenerates health every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Regen Interval"			"1.0"

			// The Mutant Tank stops regenerating health at this value.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 1000000
			"Regen Limit"				"1000000"
		}
	}
}
```

##### Respawn Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank respawns upon death.
		// Requires "mt_abilities2.smx" to be compiled with "mt_respawn.sp" to work.
		"Respawn Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank respawns up to this many times.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			"Respawn Amount"			"1"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Respawn Chance"			"33.3"

			// The type that the Mutant Tank will respawn as.
			// Note: Chosen types that also have the Respawn ability will be replaced with the Mutant Tank's own type to prevent bugs.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate values with "-".
			// --
			// Value limit: 2
			// Character limit for each value: 4
			// --
			// Minimum number for each value: 0 (OFF)
			// Maximum number for each value: 500
			// --
			// 1st number = Minimum value
			// 2nd number = Maximum value
			// --
			// Example: "0-0" (Do not choose from any Mutant Tank types.)
			// Example: "1-25" (Choose a Mutant Tank type between 1 through 25.)
			// Example: "50-0" (Automatically change to "0-0" because "50" is higher than "0".)
			// Example: "1-1000" (Automatically change to "1-500" because "500" is the maximum number of Mutant Tank types allowed.)
			// Example: "0" (Automatically change to "0-500" because the maximum range is not specified.)
			// Example: "1000" (Automatically change to "500-500" because the maximum range is not specified and the minimum range exceeds the "500" limit.)
			// --
			// 0: OFF, use the randomization feature.
			// 1-500: ON, the type to respawn as.
			"Respawn Type"				"0-0"
		}
	}
}
```

##### Restart Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank forces survivors to restart at the beginning of the map or near a teammate with a new loadout.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor respawns at the start of the map or near a teammate.
		// - "Restart Range"
		// - "Restart Range Chance"
		// "Restart Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor respawns at the start of the map or near a teammate.
		// - "Restart Chance"
		// - "Restart Hit Mode"
		// Requires "mt_abilities2.smx" to be compiled with "mt_restart.sp" to work.
		"Restart Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Restart Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Restart Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Restart Chance"			"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Restart Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Restart Hit Mode"			"0"

			// The Mutant Tank makes survivors restart with this loadout.
			// Note: This setting can be overridden for specific players.
			// --
			// Item limit: 5
			// Character limit for each item: 64
			// --
			// Example: "smg_silenced,pistol,adrenaline,defibrillator"
			// Example: "katana,pain_pills,vomitjar"
			// Example: "first_aid_kit,defibrillator,knife,adrenaline"
			"Restart Loadout"			"smg,pistol,pain_pills"

			// The mode of the Mutant Tank's restart ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Survivors are teleported to the spawn area.
			// 1: Survivors are teleported to another teammate.
			"Restart Mode"				"1"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Restart Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Restart Range Chance"			"15.0"
		}
	}
}
```

##### Rock Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank creates rock showers.
		// Requires "mt_abilities2.smx" to be compiled with "mt_rock.sp" to work.
		"Rock Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"500.0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Rock Chance"				"33.3"

			// The Mutant Tank's rocks do this much damage.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Rock Damage"				"5"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Rock Duration"				"5"

			// The Mutant Tank's rock shower drops a rock every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 1.0
			"Rock Interval"				"0.2"

			// The radius of the Mutant Tank's rock shower.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 1st number = Minimum radius
			// Minimum: -5.0
			// Maximum: 0.0
			// --
			// 2nd number = Maximum radius
			// Minimum: 0.0
			// Maximum: 5.0
			"Rock Radius"				"-1.25,1.25"
		}
	}
}
```

##### Rocket Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank sends survivors into space.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is sent into space.
		// - "Rocket Range"
		// - "Rocket Range Chance"
		// "Rocket Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is sent into space.
		// - "Rocket Chance"
		// - "Rocket Hit Mode"
		// Requires "mt_abilities2.smx" to be compiled with "mt_rocket.sp" to work.
		"Rocket Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Rocket Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Rocket Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// Removes the death model of the survivor when killed.
			// Note: This setting can be overridden for specific players.
			// Note: Only available in Left 4 Dead 2.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Rocket Body"				"1"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Rocket Chance"				"33.3"

			// The Mutant Tank sends survivors into space after this many seconds passes upon triggering the ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Rocket Delay"				"1.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Rocket Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Rocket Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Rocket Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Rocket Range Chance"			"15.0"
		}
	}
}
```

##### Shake Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank shakes the survivors' screens.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor's screen is shaken.
		// - "Shake Range"
		// - "Shake Range Chance"
		// "Shake Death" - When the Mutant Tank dies, nearby survivors' screens are shaken.
		// - "Shake Death Chance"
		// - "Shake Death Range"
		// "Shake Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor's screen is shaken.
		// - "Shake Chance"
		// - "Shake Hit Mode"
		// Requires "mt_abilities2.smx" to be compiled with "mt_shake.sp" to work.
		"Shake Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting does not affect the "Shake Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Shake Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Shake Chance"				"33.3"

			// Enable the Mutant Tank's upon-death range ability.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Shake Death"				"1"

			// The Mutant Tank has this many chances out of 100.0% to trigger the upon-death ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Shake Death Chance"			"33.3"

			// The distance between a survivor and the Mutant Tank needed to trigger the upon-death ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Shake Death Range"			"200.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Shake Duration"			"5"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Shake Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Shake Hit Mode"			"0"

			// The Mutant Tank shakes survivors' screems every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Shake Interval"			"1.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Shake Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Shake Range Chance"			"15.0"
		}
	}
}
```

##### Shield Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank protects itself with a shield and throws propane tanks or gas cans.
		// Requires "mt_abilities2.smx" to be compiled with "mt_shield.sp" to work.
		"Shield Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Duration"			"5"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Shield Chance"				"33.3"

			// These are the RGBA values of the Mutant Tank's shield prop's color.
			// Note: Any value less than "0" will output a random color.
			// Note: This setting can be overridden for specific players.
			// --
			// 1st number = Red
			// 2nd number = Green
			// 3rd number = Blue
			// 4th number = Alpha
			"Shield Color"				"255,255,255,255"

			// The Mutant Tank's shield reactivates after this many seconds passes upon destroying the shield.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Shield Delay"				"5"

			// Display the Mutant Tank's shield's health.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 11
			// --
			// 0: OFF
			// 1: ON, show name only.
			// 2: ON, show health only.
			// 3: ON, show health percentage only.
			// 4: ON, show healthbar only.
			// 5: ON, show name and health only.
			// 6: ON, show name and health percentage only.
			// 7: ON, show name and healthbar only.
			// 8: ON, show health and healthbar only.
			// 9: ON, show health percentage and healthbar only.
			// 10: ON, show name, health, and healthbar.
			// 11: ON, show name, health percentage, and healthbar.
			"Shield Display Health"			"11"

			// Display type of the Mutant Tank's shield's health.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, show in hint text.
			// 2: ON, show in center text.
			"Shield Display Health Type"		"2"

			// The Mutant Tank's shield has a glow outline when activated.
			// Note: This setting relies on the glow settings under the "Tank #/Glow" section.
			// Note: The glow outline may not appear most of the time when the "Glow Type" setting is set to "0" because the shield must be fully visible to the player in order for the glow outline to appear. Since a part of the shield is always under the ground, it is only fully visible when the Tank is climbing or is in the air.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Shield Glow"				"1"

			// The Mutant Tank's shield starts out with this much health.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1-999999: The shield has this much health.
			"Shield Health"				"0"

			// The characters used to represent the health bar of the Mutant Tank's shield.
			// Note: This setting only takes effect when the "Shield Display Health" setting is enabled.
			// Note: This setting can be overridden for specific players.
			// --
			// Separate characters with commas (",").
			// --
			// Character limit: 2
			// Character limit for each character: 1
			// --
			// 1st character = Health indicator
			// 2nd character = Damage indicator
			"Shield Health Characters"		"],="

			// The Mutant Tank has this many chances out of 100.0% to throw an explosive that can destroy its shield.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Shield Throw Chance"			"100.0"

			// The type of the Mutant Tank's shield.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 15
			// --
			// 0: OFF
			// 1: Bullet-based (Requires bullets to break shield.)
			// 2: Blast-based (Requires explosives to break shield.)
			// 4: Fire-based (Requires fires to break shield.)
			// 8: Melee-based (Requires melee weapons to break shield.)
			"Shield Type"				"2"
		}
	}
}
```

##### Shove Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank repeatedly shoves survivors.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is shoved repeatedly.
		// - "Shove Range"
		// - "Shove Range Chance"
		// "Shove Death" - When the Mutant Tank dies, nearby survivors are shoved.
		// - "Shove Death Chance"
		// - "Shove Death Range"
		// "Shove Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is shoved repeatedly.
		// - "Shove Chance"
		// - "Shove Hit Mode"
		// Requires "mt_abilities2.smx" to be compiled with "mt_shove.sp" to work.
		"Shove Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Shove Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Shove Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Shove Chance"				"33.3"

			// Enable the Mutant Tank's upon-death range ability.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Shove Death"				"1"

			// The Mutant Tank has this many chances out of 100.0% to trigger the upon-death ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Shove Death Chance"			"33.3"

			// The distance between a survivor and the Mutant Tank needed to trigger the upon-death ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Shove Death Range"			"200.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Shove Duration"			"5"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Shove Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Shove Hit Mode"			"0"

			// The Mutant Tank shoves survivors every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Shove Interval"			"1.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Shove Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Shove Range Chance"			"15.0"
		}
	}
}
```

##### Slow Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank slows survivors down.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is slowed down.
		// - "Slow Range"
		// - "Slow Range Chance"
		// "Slow Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is slowed down.
		// - "Slow Chance"
		// - "Slow Hit Mode"
		// Requires "mt_abilities2.smx" to be compiled with "mt_slow.sp" to work.
		"Slow Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Slow Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Slow Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Slow Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Slow Duration"				"5.0"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Slow Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Slow Hit Mode"				"0"

			// The Mutant Tank prevents survivors from walking up inclines (ramps, stairs, etc.) while slowed down.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Slow Incline"				"1"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Slow Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Slow Range Chance"			"15.0"

			// The Mutant Tank sets the survivors' run speed to this value.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 0.99
			"Slow Speed"				"0.25"
		}
	}
}
```

##### Smash Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank smashes survivors to death.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is smashed to death.
		// - "Smash Range"
		// - "Smash Range Chance"
		// "Smash Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is smashed to death.
		// - "Smash Chance"
		// - "Smash Hit Mode"
		// Requires "mt_abilities2.smx" to be compiled with "mt_smash.sp" to work.
		"Smash Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Smash Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Smash Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// Removes the death model of the survivor when killed.
			// Note: This setting can be overridden for specific players.
			// Note: Only available in Left 4 Dead 2.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Smash Body"				"1"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Smash Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Smash Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Smash Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Smash Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Smash Range Chance"			"15.0"
		}
	}
}
```

##### Smite Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank smites survivors.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is smitten.
		// - "Smite Range"
		// - "Smite Range Chance"
		// "Smite Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is smitten.
		// - "Smite Chance"
		// - "Smite Hit Mode"
		// Requires "mt_abilities2.smx" to be compiled with "mt_smite.sp" to work.
		"Smite Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Smite Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Smite Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// Removes the death model of the survivor when killed.
			// Note: This setting can be overridden for specific players.
			// Note: Only available in Left 4 Dead 2.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Smite Body"				"1"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Smite Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Smite Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Smite Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Smite Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Smite Range Chance"			"15.0"
		}
	}
}
```

##### Spam Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank spams rocks at survivors.
		// Requires "mt_abilities2.smx" to be compiled with "mt_spam.sp" to work.
		"Spam Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"150.0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Spam Chance"				"33.3"

			// The Mutant Tank's rocks do this much damage.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Spam Damage"				"5"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Spam Duration"				"5"

			// The Mutant Tank's rock spammer throws a rock every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 1.0
			"Spam Interval"				"0.5"
		}
	}
}
```

##### Splash Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank constantly deals splash damage to nearby survivors.
		// Requires "mt_abilities2.smx" to be compiled with "mt_splash.sp" to work.
		"Splash Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Duration"			"5"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability is activated.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Splash Chance"				"33.3"

			// The Mutant Tank's splashes do this much damage.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Splash Damage"				"5.0"

			// The Mutant Tank deals splash damage to nearby survivors every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Splash Interval"			"5.0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Splash Range"				"500.0"
		}
	}
}
```

##### Splatter Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank covers everyone's screens with splatters.
		// Requires "mt_abilities2.smx" to be compiled with "mt_splatter.sp" to work.
		// Note: Only available in Left 4 Dead 2.
		"Splatter Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Duration"			"5"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Splatter Chance"			"33.3"

			// The Mutant Tank covers everyone's screens with splatters every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Splatter Interval"			"5.0"

			// The type of the Mutant Tank's splatter.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Random
			// 1: Adrenaline
			// 2: Adrenaline #2
			// 3: Hurt
			// 4: Hurt #2
			// 5: Blood
			// 6: Blood #2
			// 7: Blood #3
			// 8: Blood #4
			// 9: Blood #5
			// 10: Blood #6
			// 11: Smoker
			// 12: Smoker #2
			// 13: Mud
			// 14: Mud #2
			// 15: Bashed
			// 16: Bashed #2
			// 17: Bashed #3
			// 18: Burning
			// 19: Lightning
			"Splatter Type"				"0"
		}
	}
}
```

##### Throw Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank throws cars, special infected, Witches, or itself.
		// Requires "mt_abilities2.smx" to be compiled with "mt_throw.sp" to work.
		"Throw Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"500.0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 15
			// --
			// 0: OFF
			// 1: The Mutant Tank throws cars.
			// 2: The Mutant Tank throws special infected.
			// 4: The Mutant Tank throws itself.
			// 8: The Mutant Tank throws Witches.
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 15
			// --
			// 0: OFF
			// 1: Display message only when "Ability Enabled" includes option "1".
			// 2: Display message only when "Ability Enabled" includes option "2".
			// 4: Display message only when "Ability Enabled" includes option "4".
			// 8: Display message only when "Ability Enabled" includes option "8".
			"Ability Message"			"0"

			// Cars thrown by the Mutant Tank will disappear after this many seconds.
			// Note: The timer starts when the car spawns, so take into account the time it takes to hit something.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Throw Car Lifetime"				"10.0"

			// The Mutant Tank throws these cars.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0 OR 7: Pick randomly between the 3 cars.
			// 1: Small car with a big hatchback.
			// 2: Car that looks like a Chevrolet Impala SS.
			// 4: Car that looks like a Sixth Generation Chevrolet Impala.
			"Throw Car Options"			"0"

			// Set the Mutant Tank as the owner of its thrown cars.
			// Note: This setting is only used for compatibility with Marttt's "Replace Cars Into Car Alarms" plugin. Disable this setting if you do not use that plugin.
			// Link: https://forums.alliedmods.net/showthread.php?t=329806
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Throw Car Owner"			"1"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Throw Chance"				"33.3"

			// The amount of special infected the Mutant Tank can throw at any given time.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 15
			"Throw Infected Amount"			"2"

			// Special infected thrown by the Mutant Tank die after this many seconds.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (Until death)
			// Maximum: 999999.0 (Longest)
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever"/"death" - 999999 seconds
			"Throw Infected Lifetime"		"0.0"

			// The Mutant Tank throws these special infected.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 127
			// --
			// 0 OR 127: Pick randomly between the 7 options.
			// 1: Smoker
			// 2: Boomer
			// 4: Hunter
			// 8: Spitter (Switches to Boomer in Left 4 Dead 1.)
			// 16: Jockey (Switches to Hunter in Left 4 Dead 1.)
			// 32: Charger (Switches to Smoker in Left 4 Dead 1.)
			// 64: Tank
			"Throw Infected Options"		"0"

			// Remove all special infected thrown by the Mutant Tank when it dies or changes its Mutant Tank type.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Throw Infected Remove"			"1"

			// The amount of Witches the Mutant Tank can throw at any given time.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 25
			"Throw Witch Amount"			"3"

			// The Mutant Tank's thrown Witch causes this much damage per hit.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Throw Witch Damage"			"5.0"

			// Witches thrown by the Mutant Tank die after this many seconds.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (Until death)
			// Maximum: 999999.0 (Longest)
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever"/"death" - 999999 seconds
			"Throw Witch Lifetime"			"0.0"

			// Remove all Witches thrown by the Mutant Tank when it dies or changes its Mutant Tank type.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Throw Witch Remove"			"1"
		}
	}
}
```

##### Track Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank throws heat-seeking rocks that will track down the nearest survivors.
		// Requires "mt_abilities2.smx" to be compiled with "mt_track.sp" to work.
		"Track Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Track Chance"				"33.3"

			// The Mutant Tank's heat-seeking rocks have glow outlines when activated.
			// Note: This setting relies on the glow settings under the "Tank #/Glow" section.
			// Note: The glow outline may not appear when the "Glow Type" setting is set to "0" if the rock is not fully visible to the player.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Track Glow"				"1"

			// The mode of the Mutant Tank's track ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: The Mutant Tank's rock will only start tracking when it is near a survivor.
			// 1: The Mutant Tank's rock will track the nearest survivor.
			"Track Mode"				"1"

			// The Mutant Tank's track ability is this fast.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting only applies if the "Track Mode" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			"Track Speed"				"500.0"
		}
	}
}
```

##### Ultimate Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank activates ultimate mode when low on health to gain temporary godmode and damage boost.
		// Requires "mt_abilities2.smx" to be compiled with "mt_ultimate.sp" to work.
		"Ultimate Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank can activate ultimate mode up to this many times.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			"Ultimate Amount"			"1"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Ultimate Chance"			"33.3"

			// The Mutant Tank's damage boost value during ultimate mode.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			"Ultimate Damage Boost"			"1.2"

			// The Mutant Tank must deal this much damage to survivors to activate ultimate mode.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			"Ultimate Damage Required"		"200.0"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Ultimate Duration"			"5"

			// The Mutant Tank can activate ultimate mode when its health is equal to or below this value.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 1000000
			"Ultimate Health Limit"			"100"

			// The Mutant Tank regenerates up to this much percentage of its original health upon activating ultimate mode.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 1.0 (Full health)
			"Ultimate Health Portion"		"0.5"
		}
	}
}
```

##### Undead Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank cannot die.
		// Requires "mt_abilities2.smx" to be compiled with "mt_undead.sp" to work.
		"Undead Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank stays alive up to this many times.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			"Undead Amount"				"1"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Undead Chance"				"33.3"
		}
	}
}
```

##### Vampire Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank gains health from hurting survivors.
		// Requires "mt_abilities2.smx" to be compiled with "mt_vampire.sp" to work.
		"Vampire Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON, players can use buttons to activate abilities.
			"Human Ability"				"0"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Vampire Chance"			"33.3"
		}
	}
}
```

##### Vision Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank changes the survivors' field of view.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor's vision changes.
		// - "Vision Range"
		// - "Vision Range Chance"
		// "Vision Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor's vision changes.
		// - "Vision Chance"
		// - "Vision Hit Mode"
		// Requires "mt_abilities2.smx" to be compiled with "mt_vision.sp" to work.
		"Vision Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting does not affect the "Vision Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Vision Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Vision Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Vision Duration"			"5"

			// The Mutant Tank sets survivors' fields of view to this value.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 160
			"Vision FOV"				"160"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Vision Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Vision Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Vision Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Vision Range Chance"			"15.0"
		}
	}
}
```

##### Warp Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank warps to survivors and warps survivors to random teammates.
		// "Ability Enabled" - The Mutant Tank warps to a random survivor.
		// - "Warp Interval"
		// - "Warp Mode"
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor is warped to a random teammate.
		// - "Warp Range"
		// - "Warp Range Chance"
		// "Warp Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor is warped to a random teammate.
		// - "Warp Chance"
		// - "Warp Hit Mode"
		// Requires "mt_abilities2.smx" to be compiled with "mt_warp.sp" to work.
		"Warp Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Duration"			"5"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting does not apply to the range ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting does not affect the "Warp Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, the Mutant Tank can warp a survivor to a random teammate.
			// 2: ON, the Mutant Tank can warp itself to a survivor.
			// 3: ON, the Mutant Tank can do both.
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the abilities activate/deactivate.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Display message only when "Warp Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is set to "1" or "3".
			// 4: Display message only when "Ability Enabled" is set to "2" or "3".
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "hit,ability" - 3
			// "rock" - 4
			// "hit,rock" - 5
			// "ability,rock" - 6
			// "hit,ability,rock"/"all" - 7
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Warp Chance"				"33.3"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Warp Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Warp Hit Mode"				"0"

			// The Mutant Tank warps to a random survivor every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Warp Interval"				"5.0"

			// The mode of the Mutant Tank's warp ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: The Mutant Tank warps to a random survivor.
			// 1: The Mutant Tank switches places with a random survivor.
			// 2: The Mutant Tank warps to a random Tank.
			// 3: The Mutant Tank switches places with a random Tank.
			"Warp Mode"				"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Warp Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Warp Range Chance"			"15.0"
		}
	}
}
```

##### Whirl Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank makes survivors' screens whirl.
		// "Ability Enabled" - When a survivor is within range of the Mutant Tank, the survivor's screen whirls.
		// - "Whirl Range"
		// - "Whirl Range Chance"
		// "Whirl Hit" - When a survivor is hit by the Mutant Tank's claw or rock, or a survivor hits the Mutant Tank with a melee weapon, the survivor's screen whirls.
		// - "Whirl Chance"
		// - "Whirl Hit Mode"
		// Requires "mt_abilities2.smx" to be compiled with "mt_whirl.sp" to work.
		"Whirl Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting does not affect the "Whirl Hit" setting.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0: OFF
			// 1: Show effect when the Mutant Tank uses its claw/rock attack.
			// 2: Show effect when the Mutant Tank is hit by a melee weapon.
			// 4: Show effect when the Mutant Tank uses its range ability.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "attack" - 1
			// "hurt" - 2
			// "attack,hurt" - 3
			// "range" - 4
			// "attack,range" - 5
			// "hurt,range" - 6
			// "attack,hurt,range" - 7
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 3
			// --
			// 0: OFF
			// 1: Display message only when "Whirl Hit" is enabled.
			// 2: Display message only when "Ability Enabled" is enabled.
			// --
			// Keywords:
			// "none"/"off" - 0
			// "hit" - 1
			// "ability" - 2
			// "both"/"all"/"hit,ability" - 3
			"Ability Message"			"0"

			// The axis of the Mutant Tank's whirl effect.
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 7
			// --
			// 0 OR 7: Pick randomly between the 3 axes.
			// 1: X-Axis
			// 2: Y-Axis
			// 4: Z-Axis
			"Whirl Axis"				"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Whirl Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Whirl Duration"			"5"

			// Enable the Mutant Tank's claw/rock attack.
			// Note: This setting does not need the "Ability Enabled" setting to be set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Whirl Hit"				"0"

			// The mode of the Mutant Tank's claw/rock attack.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: Ability activates when the Mutant Tank hits a survivor.
			// 2: Ability activates when the Mutant Tank is hit by a survivor.
			// --
			// Keywords:
			// "both"/"all" - 0
			// "tank"/"attack" - 1
			// "survivor"/"hurt" - 2
			"Whirl Hit Mode"			"0"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Whirl Range"				"150.0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the range ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Whirl Range Chance"			"15.0"

			// The Mutant Tank makes survivors whirl at this speed.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			"Whirl Speed"				"500.0"
		}
	}
}
```

##### Witch Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank converts nearby common infected into Witch minions.
		// Requires "mt_abilities2.smx" to be compiled with "mt_witch.sp" to work.
		"Witch Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank converts this many common infected into Witch minions at once.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 25
			"Witch Amount"				"3"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Witch Chance"				"33.3"

			// The Mutant Tank's Witch minion causes this much damage per hit.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0
			// Maximum: 999999.0
			// --
			// Keywords:
			// "weakest" - 1.0 damage
			// "strongest" - 999999.0 damage
			"Witch Damage"				"5.0"

			// Witches spawned by the Mutant Tank die after this many seconds.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (Until death)
			// Maximum: 999999.0 (Longest)
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever"/"death" - 999999 seconds
			"Witch Lifetime"			"0.0"

			// The distance between a common infected and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Witch Range"				"500.0"

			// Remove all Witches spawned by the Mutant Tank when it dies or changes its Mutant Tank type.
			// Note: This setting spawns a Witch on the Mutant Tank's corpse if it is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Witch Remove"				"1"
		}
	}
}
```

##### Xiphos Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank can steal health from survivors and vice-versa.
		// Note: Survivors only get a portion of the damage as health while Tanks get the full damage as health.
		// Requires "mt_abilities2.smx" to be compiled with "mt_xiphos.sp" to work.
		"Xiphos Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON, players can use buttons to activate abilities.
			"Human Ability"				"0"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Show a screen fade effect when the Mutant Tank uses its abilities.
			// Note: The colors will randomly change between the colors set in the "Skin Color" and "Glow Color" settings.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Effect"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: Display message only when the Tank hurts a survivor.
			// 2: Display message only when a survivor hurts the Tank.
			// 3: Both
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Xiphos Chance"				"33.3"

			// The survivors' max health.
			// Note: Survivors will not gain health if they already have this much health.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0 (OFF, use the value set by the game.)
			// Maximum: 1000000
			"Xiphos Max Health"			"100"
		}
	}
}
```

##### Yell Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank yells to deafen survivors.
		// Requires "mt_abilities2.smx" to be compiled with "mt_yell.sp" to work.
		"Yell Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability's effects.
			// Note: If the Mutant Tank has one or more of these immunity flags or has the same immunity flags as the survivor victim, the immunity is cancelled.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"1"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Yell Chance"				"33.3"

			// The Mutant Tank's ability effects last this long.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Yell Duration"				"5"

			// The distance between a survivor and the Mutant Tank needed to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1.0 (Closest)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "closest" - 1.0 range
			// "farthest" - 999999.0 range
			"Yell Range"				"500.0"
		}
	}
}
```

##### Zombie Ability
```
"Mutant Tanks"
{
	"Tank #1"
	{
		// The Mutant Tank spawns zombies.
		// Requires "mt_abilities2.smx" to be compiled with "mt_zombie.sp" to work.
		"Zombie Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Use this ability in conjunction with other abilities.
			// Note: Only use this when "Spawn Type" is set to "4" for the Mutant Tank.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Ability" setting is set to "2".
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Combo Ability"				"0"

			// Allow human-controlled Mutant Tanks to use this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: OFF
			// 1: ON, players can use buttons to activate abilities.
			// 2: ON, abilities will activate automatically.
			"Human Ability"				"0"

			// Determines how many times human-controlled Mutant Tanks can use their abilities in one life.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "none"/"off" - 0 ammo
			// "infinite" - 999999 ammo
			"Human Ammo"				"5"

			// Human-controlled Mutant Tanks must wait this long before using their abilities again.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 999999
			// --
			// Keywords:
			// "never"/"disabled"/"false"/"off"/"no" - 0 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Cooldown"			"30"

			// The Mutant Tank's ability effects last this long.
			// Note: This setting does not affect human-controlled Mutant Tanks unless the "Human Mode" setting is set to "0".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 999999
			// --
			// Keywords:
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Human Duration"			"5"

			// The mode of how human-controlled Mutant Tanks activate their abilities.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Press buttons to activate corresponding abilities. Cooldown starts after ability's duration ends.
			// 1: Hold down buttons to keep corresponding abilities activated. Cooldown starts after the player lets go of the buttons.
			"Human Mode"				"1"

			// The ability can only activate in open areas.
			// Note: Do not change this setting if you are unsure of how it works.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (OFF)
			// Maximum: 999999.0 (Farthest)
			// --
			// Keywords:
			// "disabled"/"false"/"off"/"no" - 0.0 range
			// "farthest" - 999999.0 range
			"Open Areas Only"			"0"

			// The ability is only effective toward human survivors.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0
			// Maximum: 32
			// --
			// 0: OFF
			// 1-32: ON, the number of human survivors required to be present for this ability to be effective.
			"Requires Humans"			"0"

			// Enable this ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Enabled"			"0"

			// Display a message whenever the ability activates/deactivates.
			// Note: This setting can be overridden for specific players.
			// --
			// 0/"disabled"/"false"/"off"/"no": OFF
			// 1/"enabled"/"true"/"on"/"yes": ON
			"Ability Message"			"0"

			// The Mutant Tank spawns this many common infected at once.
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 1
			// Maximum: 100
			"Zombie Amount"				"10"

			// The Mutant Tank has this many chances out of 100.0% to trigger the ability.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.0 (No chance)
			// Maximum: 100.0 (Highest chance)
			// --
			// Keywords:
			// "never" - 0% chance
			// "sometimes"/"unlikely"/"seldom" - 33.3% chance
			// "maybe" - 50% chance
			// "often"/"likely"/"frequently" - 66.6% chance
			// "always" - 100% chance
			"Zombie Chance"				"33.3"

			// The Mutant Tank spawns a zombie mob every time this many seconds passes.
			// Note: This is ignored when the "Combo Ability" setting is set to "1".
			// Note: This setting can be overridden for specific players.
			// --
			// Minimum: 0.1
			// Maximum: 999999.0
			// --
			// Keywords:
			// "milli"/"millisecond" - 0.1 seconds
			// "second" - 1 second
			// "minute" - 1 minute
			// "forever" - 999999 seconds
			"Zombie Interval"			"5.0"

			// The mode of the Mutant Tank's zombie mob spawn ability.
			// Note: This setting can be overridden for specific players.
			// --
			// 0: Both
			// 1: The Mutant Tank spawns common infected.
			// 2: The Mutant Tank spawns uncommon infected.
			"Zombie Mode"				"0"

			// The type of zombies to spawn.
			// Note: This setting only works when the "Zombie Mode" setting is set to "0" or "2".
			// Note: This setting can be overridden for specific players.
			// --
			// Add up numbers together for different results.
			// --
			// Minimum: 0
			// Maximum: 127
			// --
			// 0 OR 127: Pick randomly between the 7 options.
			// 1: CEDA Worker (Dead Center)
			// 2: Jimmy Gibbs Jr. (Dead Center)
			// 4: Fallen Survivor (The Passing)
			// 8: Clown (Dark Carnival)
			// 16: Mudman (Swamp Fever)
			// 32: Roadcrew Worker (Hard Rain)
			// 64: Riot Cop (The Parish)
			"Zombie Type"				"0"
		}
	}
}
```

### Administration System

#### Administration, Tank Settings, Abilities
```
"Mutant Tanks"
{
	// Use the admin's SteamID32 or Steam3ID when making an entry.
	"STEAM_0:1:23456789" // [U:1:23456789]
	{
		"Administration"
		{
			// This is the Mutant Tank type that the admin will spawn with.
			// Note: If the "Spawn Mode" setting under the "Plugin Settings/Human Support" section is set to "1", the admin will be prompted with a menu asking if the admin wants to use this type.
			// --
			// 0: OFF, use the randomization feature.
			// 1-500: ON, the type that will be favorited.
			"Favorite Type"				"0"

			// Admins with one or more of these access flags have access to all Mutant Tank types that have any of these flags.
			// Note: This setting overrides all the settings with the same name above.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to all attacks of Mutant Tanks that have any of these flags.
			// Note: This setting overrides all the settings with the same name above.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""
		}
		// Each Mutant Tank type can be assigned its own access and immunity flags that will override all the "Access Flags" and "Immunity Flags" above.
		"Tank #1"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting overrides all other "Access Flags" settings above.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability.
			// Note: This setting overrides all other "Immunity Flags" settings above.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""
		}
		// Each ability can be assigned its own access and immunity flags that will override all the "Access Flags" and "Immunity Flags" above.
		"Absorb Ability"
		{
			// Admins with one or more of these access flags have access to this ability.
			// Note: This setting overrides all other "Access Flags" settings above.
			// --
			// Empty: No access flags have access.
			// Not empty: These access flags have access.
			"Access Flags"				""

			// Admins with one or more of these immunity flags are immune to this ability.
			// Note: This setting overrides all other "Immunity Flags" settings above.
			// --
			// Empty: No immunity flags are immune.
			// Not empty: These immunity flags are immune.
			"Immunity Flags"			""
		}
		// Note: Admins can each have their own personalized/custom Mutant Tanks by using the same settings above in the "Tank Settings" and "X Ability" sections.
	}
}
```